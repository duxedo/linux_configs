local awful = require('awful')
local ruled = require('ruled')
local gears = require('gears')
local beautiful = require('beautiful')
local wibox = require('wibox')
local constants = require('constants')
local bindings = require('bindings')

ruled.client.connect_signal(
    'request::rules', function()
        -- @DOC_GLOBAL_RULE@
        -- All clients will match this rule.
        ruled.client.append_rule {
            id = 'global',
            rule = {},
            except = { name = 'Origin' },
            properties = {
                focus = awful.client.focus.filter,
                raise = true,
                -- size_hints_honor = false, -- Remove gaps between terminals
                screen = awful.screen.preferred,
                titlebars_enabled = false,
                requested_border_width = beautiful.border_width
                -- placement = awful.placement.no_overlap+awful.placement.no_offscreen,
            }
        }
        -- @DOC_FLOATING_RULE@
        -- Floating clients.
        ruled.client.append_rule {
            id = 'floating',
            rule_any = {
                instance = { 'copyq', 'pinentry' },
                class = {
                    'Arandr',
                    'Sxiv',
                    'steam',
                    'Spotify',
                    'Shutter',
                    'KeePassXC',
                    'qBittorrent',
                    'galaxyclient.exe',
                    'Lutris',
                    'battle.net.exe',
                    'calc',
                    'evelauncher.exe',
                    'zoom',
                    'RPCS3',
                    'Pavucontrol',
                    'Blueman-manager'
                },
                -- Note that the name property shown in xprop might be set slightly after creation of the client
                -- and the name shown there might not match defined rules here.
                name = {
                    'Event Tester', -- xev.
                    'Origin', -- Origin client.
                    'Welcome to Android Studio',
                    'Android Virtual Device Manager' -- android studio AVD
                },
                role = {
                    'AlarmWindow', -- Thunderbird's calendar.
                    'ConfigManager', -- Thunderbird's about:config.
                    'pop-up' -- e.g. Google Chrome's (detached) Developer Tools.
                }
            },
            properties = {
                floating = true,
                titlebars_enabled = false
            }
        }

        ruled.client.append_rule {
            id = 'im-clients',
            rule_any = {
                class = {
                    'TelegramDesktop',
                    'Slack',
                    'discord',
                    'Signal',
                    'Skype',
                    constants.notebook and nil or 'Squadus'
                }
            },
            properties = { tags = { awful.screen.focused().tags[6] } }
        }

        if constants.notebook then
            ruled.client.append_rule {
                id = 'squadus',
                rule = {
                    class = 'Squadus',
                },
                properties = { tags = { awful.screen.focused().tags[7] } }
            }
        end

        ruled.client.append_rule {
            id = 'game-launchers',
            rule_any = {
                class = { 'steam', 'Lutris', 'battle.net.exe', 'Origin', 'gamescope' }
            },
            properties = { tags = { awful.screen.focused().tags[2] } }
        }

        ruled.client.append_rule {
            id = 'disable-ctrl-shift-c',
            rule_any = {
                class = { 'firefox' }
            },
            callback = function (c)
                c:append_keybinding(
                    awful.key {
                        modifiers   = { "Control", "Shift" },
                        key         = "c",
                        description = "disable firefox debug console",
                        group       = "fixes",
                        on_press    = function () end,
                        on_release    = function ()
                            local root = require("root")
                            root.fake_input("key_press", "Control_L")
                            root.fake_input("key_press", "c")
                            root.fake_input("key_release", "c")
                            root.fake_input("key_release", "Control_L")
                        end,
                    }
                )
            end
        }

        ruled.client.append_rule {
            id = 'default_master',
            rule_any = { class = { 'exefile.exe', 'smplayer' } },
            properties = { default_master = true }
        }

        ruled.client.append_rule {
            id = 'logs',
            rule_any = { class = { 'logs' } },
            properties = { tags = { awful.screen.focused().tags[9] } }
        }

        ruled.client.append_rule {
            id = 'deluge_main_window',
            rule = { class = 'Deluge', type = 'normal' },
            properties = { tags = { awful.screen.focused().tags[11] } }
        }

        ruled.client.append_rule {
            id = 'android-studio',
            rule_any = { class = { 'jetbrains-studio' } },
            properties = { tags = { awful.screen.focused().tags[3] } },
            callback = function(c)
                if c.skip_taskbar then
                    c.floating = true
                    awful.placement.centered(c)
                end
            end
        }

        ruled.client.append_rule {
            -- @DOC_CSD_TITLEBARS@
            id = 'titlebars',
            rule_any = { type = { 'normal', 'dialog' } },
            properties = { titlebars_enabled = false }
        }

        ruled.client.append_rule {
            id = 'dialogs',
            rule_any = {
                type = {'dialog'},
                class = {
                    'Pavucontrol',
                    'KeePassXC',
                    'Blueman-manager'
                }
            },
            callback = function(c)
                awful.placement.centered(c, nil)
            end,
            properties = {
                buttons = gears.table.join(bindings.client_bindings, {
                        awful.button({ }, 2, function (c) c:kill() end)
                    })
            }
        }
        ruled.client.append_rule {
            id = 'noborder',
            rule_any = { class = { 'steam', 'evelauncher.exe' } },
            properties = { requested_border_width = 0 }
        }
        ruled.client.append_rule {
            id = 'zoom-popup',
            rule = { class = 'zoom', name = 'zoom' },
            properties = { focus = function() return nil end }
        }
        local games = require('rules.games')
        local work = require('rules.work')
        for _, rule in pairs(games) do
            ruled.client.append_rule(rule)
        end
        for _, rule in pairs(work) do
            ruled.client.append_rule(rule)
        end
    end
)

-- Signal function to execute when a new client appears.
client.connect_signal(
    'request::manage', function(c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end
        print(
            'AWSM: New client Name=\'' .. (c.name or 'nil') .. '\' class=\'' ..
                (c.class or '<nil>') .. '\' windowid=\'' .. (c.window or 'nil') .. '\''
        )
        local name = c.name
        if name == 'Origin' and c.skip_taskbar then
            -- c.hidden = true
            -- awful.placement.no_overlap(c)
        elseif awesome.startup and not c.size_hints.user_position and
            not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            --  awful.placement.no_offscreen(c)
        else
            if not c.default_master then
                awful.client.setslave(c)
            end
        end

    end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
    'request::titlebars', function(c)
        -- buttons for the titlebar
        local buttons = gears.table.join(
                            awful.button(
                                {}, 1, function()
                    c:activate()
                    awful.mouse.client.move(c)
                end
                            ), awful.button(
                                {}, 3, function()
                    c:activate()
                    awful.mouse.client.resize(c, nil, awful.placement.right)
                end
                            )
                        )

        awful.titlebar(c).widget = {
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    halign = 'center',
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.stickybutton(c),
                -- awful.titlebar.widget.ontopbutton    (c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
        -- Hide the menubar if we are not floating
        local l = awful.layout.get(c.screen)
        if l ~= nil and not (l.name == 'floating' or c.floating) then
            awful.titlebar.hide(c)
        end
    end
)

client.connect_signal(
    'focus', function(c)
        c.border_color = beautiful.border_focus
    end
)
client.connect_signal(
    'unfocus', function(c)
        c.border_color = beautiful.border_normal
    end
)

-- Disable borders on lone windows
-- Handle border sizes of clients.
awful.screen.connect_for_each_screen(
    function(s)
        s:connect_signal(
            'arrange', function()
                local clients = s.clients
                local layout = awful.layout.getname(awful.layout.get(s))
                local single = #s.tiled_clients == 1
                if #clients == 0 then
                    return
                end
                for _, c in pairs(clients) do
                    if c.maximized or c.fullscreen or layout == 'max' or layout ==
                        'fullscreen' or single and c == s.tiled_clients[1] then
                        if c.border_width ~= 0 then
                            c.border_width = 0
                        end
                    else
                        if c.requested_border_width ~= nil then
                            if c.border_width ~= c.requested_border_width then
                                c.border_width = c.requested_border_width
                            end
                        end
                    end
                end
            end
        )
    end
)

ruled.notification.connect_signal(
    'request::rules', function()
        -- All notifications will match this rule.
        ruled.notification.append_rule {
            rule = {},
            properties = { screen = awful.screen.preferred, implicit_timeout = 10 }
        }
    end
)

client.connect_signal(
    'mouse::enter', function(c)
        c:activate{ context = 'mouse_enter', raise = false }
    end
)

