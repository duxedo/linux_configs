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
naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Lain
local lain = require("lain")
-- Freedesktop menu
local freedesktop = require("freedesktop")
local ruled = require("ruled")

functions = {}

naughty.config.presets.low.timeout = 10
naughty.config.presets.normal.timeout = 10
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.timeout = 10
naughty.config.padding = 50
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)


ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

-- pactl get-sink-volume `pactl get-default-sink` | cut -sd/  -f2 | xargs

naughty.connect_signal("request::display", function(n, context, args)
    naughty.layout.box { notification = n }
    if(args.app_name == "pa-applet") then
       -- n.title = "Volume"
        --n.message = "Volume"
        n:connect_signal("property::message", function (self, val) 
            if val ~= "Volume2" then
                self.title = "Volume2"
            end
        end)
    end
end)

beautiful.init(awful.util.getdir("config") .. "/themes/zenburn/theme.lua")
beautiful.notification_font = "Noto Sans Regular 15"

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
browser = "firefox"
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
       lain.layout.termfair,
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
    { "hibernate", "systemctl hibernate", "/usr/share/icons/breeze-dark/actions/22/system-suspend-hibernate.svg" },
    { "suspend", "systemctl suspend", "/usr/share/icons/breeze-dark/actions/22/system-suspend.svg" },
    { "log out", function() awesome.quit() end, "/usr/share/icons/breeze-dark/actions/22/system-log-out.svg" },
    { "", function() end, "" },
    { "reboot", "systemctl reboot", "/usr/share/icons/breeze-dark/actions/22/system-reboot.svg" },
    { "shutdown", "poweroff", "/usr/share/icons/breeze-dark/actions/22/system-shutdown.svg" }
}

mymainmenu = freedesktop.menu.build({
    before = {
        { "Terminal", terminal, "/usr/share/icons/breeze-dark/apps/22/utilities-terminal.svg" },
        { "Browser", browser, "/usr/share/icons/hicolor/128x128/apps/firefox-bin.png" },
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
                                     menu = mymainmenu, upscale = false, forced_height = 50, forced_width = 50})
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

client.connect_signal("property::fullscreen", function(c)
  if c.fullscreen then
    gears.timer.delayed_call(function()
      if c.valid then
        c:geometry(c.screen.geometry)
      end
    end)
  end
end)

awful.spawn.with_shell(
       'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
       'xrdb -merge <<< "awesome.started:true";'
       -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
       )
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)
