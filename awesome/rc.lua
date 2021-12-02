-- Standard awesome library
local capi = { key = key, root = root, awesome = awesome }
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Lain
local lain = require("lain")
-- Freedesktop menu
local freedesktop = require("freedesktop")

functions = {}

naughty.config.presets.low.timeout = 10
naughty.config.presets.normal.timeout = 10
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

beautiful.init(awful.util.getdir("config") .. "/themes/zenburn/theme.lua")
beautiful.notification_font = "Noto Sans Regular 15"

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
browser = "brave-bin"
filemanager = "fm"
editor = "kitty v"
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
      awful.layout.suit.tile,
      awful.layout.suit.floating,
      awful.layout.suit.tile.left,
      awful.layout.suit.tile.bottom,
      -- awful.layout.suit.tile.top,
      awful.layout.suit.fair,
      awful.layout.suit.fair.horizontal,
         awful.layout.suit.spiral,
       awful.layout.suit.spiral.dwindle,
      awful.layout.suit.max,
      -- awful.layout.suit.max.fullscreen,
      -- awful.layout.suit.magnifier,
       awful.layout.suit.corner.nw,
      -- awful.layout.suit.corner.ne,
      -- awful.layout.suit.corner.sw,
      -- awful.layout.suit.corner.se,
  })
end)

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s %s", editor, awesome.conffile) },
    { "restart", awesome.restart }
}

myexitmenu = {
    { "log out", function() awesome.quit() end, "/usr/share/icons/breeze-dark/actions/22/system-log-out.svg" },
    { "suspend", "systemctl suspend", "/usr/share/icons/breeze-dark/actions/22/system-suspend.svg" },
    { "hibernate", "systemctl hibernate", "/usr/share/icons/breeze-dark/actions/22/system-suspend-hibernate.svg" },
    { "reboot", "systemctl reboot", "/usr/share/icons/breeze-dark/actions/22/system-reboot.svg" },
    { "shutdown", "poweroff", "/usr/share/icons/breeze-dark/actions/22/system-shutdown.svg" }
}

mymainmenu = freedesktop.menu.build({
    before = {
        { "Terminal", terminal, "/usr/share/icons/breeze-dark/apps/22/utilities-terminal.svg" },
        { "Browser", browser, "/usr/share/icons/hicolor/128x128/apps/brave-bin.png" },
        { "Files", filemanager, "/usr/share/icons/Arc-Maia/places/32/user-home.png" },
        -- other triads can be put here
    },
    after = {
        { "Awesome", myawesomemenu, "/usr/share/awesome/icons/awesome16.png" },
        { "Exit", myexitmenu, "/usr/share/icons/breeze-dark/actions/22/system-restart.svg" },
        -- other triads can be put here
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
menubar.utils.terminal = terminal

require("mywibox")
require("bindings")
require("rules")

screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            {
                image     = beautiful.wallpaper,
                upscale   = true,
                downscale = true,
                widget    = wibox.widget.imagebox,
            },
            valign = "center",
            halign = "center",
            tiled  = false,
            widget = wibox.container.tile,
        }
    }
end)



awful.spawn.with_shell(
       'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
       'xrdb -merge <<< "awesome.started:true";' ..
       -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
       'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
       )
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

