-- Standard awesome library
local capi = { key = key, root = root, awesome = awesome }
local _dbus = dbus;
dbus = nil
local naughty = require('naughty')
dbus = _dbus
local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
require('awful.autofocus')
local hotkeys_popup = require('awful.hotkeys_popup').widget
local constants = require('constants')
-- Lain
local lain = require('lain')

awful.util.table.crush(
    naughty.config, {
        presets = { low = { timeout = 10 }, normal = { timeout = 10 } },
        defaults = { position = 'bottom_right', timeout = 10 },
        padding = 50
    }
)

function debug_message(msg)
    naughty.notification { urgency = 'critical', title = 'Debug message', message = msg }
end

naughty.connect_signal(
    'request::display_error', function(message, startup)
        naughty.notification {
            urgency = 'critical',
            title = 'Oops, an error happened' .. (startup and ' during startup!' or '!'),
            message = message
        }
    end
)

-- pactl get-sink-volume `pactl get-default-sink` | cut -sd/  -f2 | xargs

naughty.connect_signal(
    'request::display', function(n, context, args)
        naughty.layout.box { notification = n }
        if (args.app_name == 'pa-applet') then
            -- n.title = "Volume"
            -- n.message = "Volume"
            n:connect_signal(
                'property::message', function(self, val)
                    if val ~= 'Volume2' then
                        self.title = 'Volume2'
                    end
                end
            )
        end
    end
)
if constants.notebook then
    beautiful.init(awful.util.getdir('config') .. '/themes/zenburn_notebook/theme.lua')
else
    beautiful.init(awful.util.getdir('config') .. '/themes/zenburn/theme.lua')
end
beautiful.notification_font = 'Noto Sans Regular 16'

-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal(
    'request::default_layouts', function()
        awful.layout.append_default_layouts(
            {
                awful.layout.suit.tile,
                awful.layout.suit.floating,
                awful.layout.suit.tile.left,
                awful.layout.suit.fair,
                awful.layout.suit.fair.horizontal,
                awful.layout.suit.spiral,
                awful.layout.suit.spiral.dwindle,
                awful.layout.suit.magnifier,
                awful.layout.suit.corner.nw,
                lain.layout.termfair,
                lain.layout.centerwork
            }
        )
    end
)

require('mywibox')
require('bindings')
require('rules')

screen.connect_signal(
    'request::wallpaper', function(s)
        awful.wallpaper {
            screen = s,
            widget = {
                {
                    image = beautiful.wallpaper,
                    upscale = true,
                    downscale = true,
                    widget = wibox.widget.imagebox
                },
                valign = 'center',
                halign = 'center',
                tiled = false,
                widget = wibox.container.tile
            }
        }
    end
)

client.connect_signal(
    'property::fullscreen', function(c)
        if c.fullscreen then
            gears.timer.delayed_call(
                function()
                    if c.valid then
                        c:geometry(c.screen.geometry)
                    end
                end
            )
        end
    end
)

awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
        'xrdb -merge <<< "awesome.started:true";' .. '~/.config/awesome/autorun.sh;'
)

