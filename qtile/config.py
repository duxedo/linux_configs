# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from typing import List  # noqa: F401

from libqtile import bar, layout, widget, qtile
from libqtile.backend.x11.window import Window
from libqtile.widget.generic_poll_text import GenPollText
from libqtile.widget.textbox import TextBox
from libqtile.widget.groupbox import GroupBox
from libqtile.widget.currentlayout import CurrentLayoutIcon
from libqtile.widget.prompt import Prompt
from libqtile.widget.tasklist import TaskList
from libqtile.widget.sensors import ThermalSensor
from libqtile.widget.chord import Chord
from libqtile.widget.systray import Systray
from libqtile.widget.clock import Clock
from libqtile.widget.open_weather import OpenWeather
from libqtile.widget.keyboardlayout import KeyboardLayout
from libqtile.widget.sep import Sep
#from libqtile.widget.statusnotifier import StatusNotifier
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.command import lazy
from libqtile.utils import guess_terminal
from libqtile.core.manager import Qtile 
from libqtile import hook
from libqtile.log_utils import logger
import asyncio
import os
import subprocess
import re
import sys
from datetime import date, datetime
mod = "mod4"
terminal = "kitty"
browser = "firefox"
#3a2d4d
#281f33
#221e22,b4a4b6,a3aeb8
dark_purple = "#3a2d4d"
#dark_purple_bg = "#281f33"
dark_purple_bg = "#1e1726"
raisin_black = "#221e22"
heliotrope_gray = "#b4a4b6"
cadet_blue_crayola = "#a3aeb8"

#widgetfg = "#9f9f9f"
widgetfg = heliotrope_gray
widgetbg = dark_purple_bg


def unminimize_id(qtile:Qtile, windowid):
    qtile.windows_map[windowid].cmd_toggle_minimize()
    

async def choose_window_coro(qtile:Qtile):
    input = "\n".join([v.name + '\t' + str(v.wid) for v in qtile.current_group.windows if isinstance(v, Window) and v.minimized])
    print(input, file=sys.stderr)
    proc = await asyncio.subprocess.create_subprocess_shell('rofi -dmenu -display-columns 1 -no-custom', stdout=subprocess.PIPE, stdin = subprocess.PIPE)
    res = await proc.communicate(input.encode("utf-8"))
    if not res:
        return
    if not res[0]:
        return
    windowid = int(res[0].decode("utf-8").rpartition('\t')[2])
    unminimize_id(qtile, windowid)
    

@lazy.function
def choose_window(qtile:Qtile):
    asyncio.ensure_future(choose_window_coro(qtile), loop = asyncio.get_running_loop())

keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down / stack up"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up / stack down"),
    Key([mod], "o", lazy.layout.add_column(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    #Key([mod, "mod1"], "h", lazy.window.static(), desc="Make window static"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "x", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "space", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),

    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),

  #  Key([], "ISO_Next_Group", lazy.widget["keyboardlayout"].next_keyboard(), desc="Next keyboard layout."),

    Key([mod], "m", lazy.window.toggle_minimize(), desc="minimize active window"),
    Key([mod, "shift"], "m", choose_window, desc="choose window to unminimize"),
    Key([mod], "n", lazy.spawn("dunstctl close-all"), desc="close all notifications"),
    Key([mod,"shift"], "n", lazy.spawn("dunstctl history-pop"), desc="notification history"),
    Key([mod,"mod1"], "n", lazy.spawn("dunstctl context"), desc="notification action menu"),
    Key([mod], "r", lazy.spawn("rofi -show run -matching regex -sorting-method fzf"), desc="Spawn a command using rofi"),
    Key([mod, "shift"], "r", lazy.spawn("rofi -modi drun -show drun -matching regex -sorting-method fzf"), desc="Spawn appliction using a prompt widget"),
    Key([mod], "p", lazy.spawn("keepassxc"), desc="keepass"),
    Key([mod], "Print", lazy.spawn("flameshot gui"), desc="flameshot"),
    Key([mod, "mod1"], "Print", lazy.spawn("flameshot gui --delay 3000"), desc="flameshot with 3s delay"),
    Key([mod, "shift"], "Print", lazy.spawn("flameshot full --clipboard"), desc="flameshot fullscreen to clipboard"),
    Key([mod], "bracketleft", lazy.spawn('sh -c "xprop > ~/xpr"'), desc="xprop"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "z", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "b", lazy.spawn(browser), desc="Launch browser"),
    Key([mod, "control"], "b", lazy.hide_show_bar("bottom"), desc="Hide/show bar"),
    Key([mod, "mod1"], "l", lazy.spawn("xscreensaver-command -lock"), desc = 'lock screen')
]

im_clients = Match(wm_class=re.compile("(Slack|discord)"))
telegramMainWnd = Match(wm_class="TelegramDesktop", title="Telegram")
astudio = Match(wm_class="jetbrains-studio")

groups = [
    Group("1"),
    Group("q", matches = Match(wm_class = [
        'galaxyclient.exe',
        'Lutris',
        'battle.net.exe',
        'Steam'
        ])),
    Group("2", matches=[astudio]),
    Group("w"),
    Group("3"),
    Group("e", matches=[im_clients, telegramMainWnd], layout="im_columns"),
]
for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),

        # mod1 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=False),
            desc="Switch to & move focused window to group {}".format(i.name)),
        Key([mod, "mod1"], i.name, lazy.window.togroup(i.name, switch_group=True),
            desc="Switch to & move focused window to group {}".format(i.name)),
        # Or, use below if you prefer not to switch to that group.
        # # mod1 + shift + letter of group = move focused window to group
        # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
        #     desc="move focused window to group {}".format(i.name)),
    ])

focus_color = '#8FFF8F'

layouts = [
    layout.Columns(border_focus=focus_color, border_focus_stack='#75f5f5', border_width = 1),
    layout.Tile( border_width = 1),
    layout.MonadThreeCol(border_focus=focus_color, border_focus_stack='#75f5f5', new_client_position='after_current', border_width = 1),
    layout.Max( border_width = 1),
    layout.Columns(border_focus=focus_color, border_focus_stack='#75f5f5', num_columns=4, fair = True, name="im_columns", border_width = 1),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font='Noto Sans',
    fontsize=12,
    padding=3,
    foreground=widgetfg,
    background=widgetbg
)
extension_defaults = widget_defaults.copy()
def get_keyboard_layout():
    return subprocess.check_output(['xkblayout-state', 'print', '"%s"']).decode('utf-8').strip()[1:3]

kbdLayout = TextBox(text=get_keyboard_layout())


bottom_bar=bar.Bar(
    [
        CurrentLayoutIcon(custom_icon_paths=["/home/reinhardt/.config/qtile/theme/icons/layout-icons/"]),
        GroupBox(active = widgetfg, borderwidth = 2, disable_drag = True, urgent_border = "#af0000", background = widgetbg),
        Prompt(),
        TaskList(),
        Chord(
            chords_colors={
                'launch': ("#ff0000", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
        ),
        Systray(),
        Sep(linewidth=0, padding = 8),
        OpenWeather(cityid="498817", font="Noto Mono", format="{main_temp} °{units_temperature} {humidity}% {icon}"),
        Sep(linewidth=0, padding = 3),
        #kbdLayout,
        GenPollText(fontsize=(int(widget_defaults["fontsize"]) + 2), func=get_keyboard_layout, update_interval=0.5),
        #KeyboardLayout(configured_keyboards=['us', 'ru']),
        Sep(linewidth=0, padding = 3),
        ThermalSensor(foreground = widgetfg, tag_sensor="Tccd1"),
        ThermalSensor(foreground = widgetfg, tag_sensor="Tccd2"),
        Sep(linewidth=0, padding = 3),
        Clock(format='%m/%d %a %H:%M'),
        Sep(linewidth=0, padding = 30),
    ],
    24
)

screens = [
    Screen(
        wallpaper="/home/reinhardt/.config/wallpapers/wp7786809-5120x1440-wallpapers.png",
        bottom=bottom_bar
    ),
]
# Drag floating layouts.
mouse = [
    Drag([mod], "Button9", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button1", lazy.window.bring_to_front(floating=False))
]
class MyMatch(Match):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def compare(self, client):
        ret = super().compare(client)
        if ret and astudio.compare(client):
            logger.warning("matched wrong {} {}".format(repr(self), client.cmd_info()))
        return ret

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
accessed = False
with open("/home/reinhardt/log2.txt", "a+") as f:
    f.write("ass\n")
qbmatch = Match(wm_class="qBittorrent")
#@hook.subscribe.client_managed
def start_minimized(window):
    global accessed
    with open("/home/reinhardt/log2.txt", "a+") as f:
        try:
            f.write(repr(window) +  repr(window.get_wm_class()) + "\n")
        except Exception as x:
            f.write(repr(x) + "\n")
    if accessed:
        return
    if qbmatch.compare(window):
        if not window.minimized:
            window.cmd_toggle_minimize()
    pass
    

floating_layout = layout.Floating(
    #border_focus="#00EE00",
    float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class="TelegramDesktop", title="Media viewer"),
    Match(wm_class=[
        'mate-notification-daemon',
        "xmessage",
        'confirmreset',  # gitk
        'makebranch',  # gitk
        'maketag',  # gitk
        'ssh-askpass',  # ssh-askpass
        'Arandr', 
        'Sxiv',
        'Shutter',
        'KeePassXC',
        'qBittorrent',
        'galaxyclient.exe',
        'Lutris',
        'battle.net.exe',
        'Steam',
        'calc',
        'kittyfloat',
        'zoom'
    ]),
    #Match(wm_class=["jetbrains-studio"], title=["win0"]),
    Match(title=[
        'Event Tester',  # xev
        'Origin',  # GPG key password entry
     #   'Welcome to Android Studio', 
      #  'Android Virtual Device Manager',
        'branchdialog', # gitk
        'pinentry' # GPG key password entry
    ]),
    Match(role=[
        'AlarmWindow'  # Thunderbird cal
        'ConfigManager',  # Thunderbird config
        'pop-up'  # chrome's detached dev toold
    ])
])
auto_fullscreen = True
focus_on_window_activation = "smart"
#follow_mouse_focus = False
bring_front_click = False
#cursor_warp = True
#widget_defaults = dict()
# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
@hook.subscribe.startup_once
def autostart():
    now = datetime.now()
#    if now.date().weekday() < 5:
#        if now.timetz().hour > 11 and now.timetz().hour < 19:
#            subprocess.Popen("slack")
    subprocess.Popen("/home/reinhardt/.config/qtile/autorun.sh")
        
"""
@hook.subscribe.client_new
def astudio_hook(window):
    if astudio.compare(window) :
        floating = window.cmd_enable_floating
        def float(self):
            logger.warning(">>>{}".format(repr(self)))
            floating(self)
        window.cmd_enable_floating=float
        logger.warning("new client {} = {} = {}".format(repr(window), window.get_wm_class(), window.cmd_info()))
        logger.warning("matched")
        window.cmd_disable_floating()
        logger.warning("done")    
@hook.subscribe.client_managed
def astudio_hook(window):
    if astudio.compare(window) :
        logger.warning("managed client {} = {} = {}".format(repr(window), window.get_wm_class(), window.cmd_info()))
        logger.warning("matched")
        window.cmd_disable_floating()
        logger.warning("done")    
"""
