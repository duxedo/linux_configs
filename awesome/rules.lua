local awful = require("awful")
local ruled = require("ruled")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

ruled.client.connect_signal("request::rules", function()
    -- @DOC_GLOBAL_RULE@
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        except     = { name = "Origin" },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            --size_hints_honor = false, -- Remove gaps between terminals
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
            callback  = awful.client.setslave
        }
    }

    -- @DOC_FLOATING_RULE@
    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
              "Arandr",
              "Sxiv",
              "Steam",
              "Spotify",
              "Shutter",
              "KeePassXC",
              "qBittorrent",
              "galaxyclient.exe",
              "Lutris"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
              "Event Tester",  -- xev.
              "Origin",   -- Origin client.
              "Welcome to Android Studio",
              "Android Virtual Device Manager" -- android studio AVD
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    ruled.client.append_rule {
        id = "im-clients",
        rule_any = {
            class = {"TelegramDesktop", "Slack"}
        }, 
        properties = { tags = {awful.screen.focused().tags[7]} },
    }

    ruled.client.append_rule {
        id = "android-studio",
        rule_any = {
            class = {"jetbrains-studio"}
        }, 
        properties = { tags = {awful.screen.focused().tags[2]}},
        callback = function(c) 
            if c.skip_taskbar then
                c.floating = true
                awful.placement.centered(c)
            end    
        end,
    }
    -- @DOC_DIALOG_RULE@
    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        -- @DOC_CSD_TITLEBARS@
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    ruled.client.append_rule {
        id         = "dialogs",
        rule       = { type = "dialog"  },
        callback = function (c)
            awful.placement.centered(c, nil)
        end
    }

    ruled.client.append_rule {
        id         = "dialogs",
        rule       = { role = "_NET_WM_STATE_FULLSCREEN"  },
        properties = { floating = true },
    }
end)

-- Signal function to execute when a new client appears.
client.connect_signal("request::manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    local name = c.name
    if name == "Origin" and c.skip_taskbar then
        --c.hidden = true
        --awful.placement.no_overlap(c)
    elseif awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c, nil, awful.placement.right)
        end)
    )

    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.stickybutton   (c),
           -- awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
        -- Hide the menubar if we are not floating
    local l = awful.layout.get(c.screen)
    if not (l.name == "floating" or c.floating) then
        awful.titlebar.hide(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Disable borders on lone windows
-- Handle border sizes of clients.
awful.screen.connect_for_each_screen(function(s)
    s:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout = awful.layout.getname(awful.layout.get(s))

        for _, c in pairs(clients) do
          if c.class == "Steam" then
                c.border_width = 0
          elseif c.maximized then
          -- No borders with only one humanly visible client
            -- NOTE: also handled in focus, but that does not cover maximizing from a
            -- tiled state (when the client had focus).
            c.border_width = 0
          elseif c.floating or layout == "floating" then
            c.border_width = beautiful.border_width
          elseif layout == "max" or layout == "fullscreen" then
            c.border_width = 0
          else
            local tiled = awful.client.tiled(c.screen)
            if #tiled == 1 then -- and c == tiled[1] then
              tiled[1].border_width = 0
              -- if layout ~= "max" and layout ~= "fullscreen" then
              -- XXX: SLOW!
              -- awful.client.moveresize(0, 0, 2, 0, tiled[1])
              -- end
            else
              c.border_width = beautiful.border_width
            end
          end
        end
    end)
end)

client.connect_signal("property::floating", function (c)
    if c.floating and not c.skip_taskbar then
        awful.titlebar.show(c)
        awful.placement.no_offscreen(c)
    else
        awful.titlebar.hide(c)
    end
end)

