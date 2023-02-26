local wibox = require('wibox')
local menubar = require('menubar')
local awful = require('awful')
local lain = require('lain')
local beautiful = require('beautiful')
local theme = beautiful.get()
local gears = require('gears')
local constants = require('constants')

local weather_widget = require('awesome-wm-widgets.weather-widget.weather')
volume_widget = require('awesome-wm-widgets.volume-widget.volume')
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()
-- {{{ Wibar

local function client_menu_toggle_fn()
    local instance = nil

    return function()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                            awful.button(
                                {}, 1, function(t)
            t:view_only()
        end
                            ), awful.button(
                                { modkey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end
                            ), awful.button({}, 3, awful.tag.viewtoggle), awful.button(
                                { modkey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end
                            ), awful.button(
                                {}, 4, function(t)
            awful.tag.viewnext(t.screen)
        end
                            ), awful.button(
                                {}, 5, function(t)
            awful.tag.viewprev(t.screen)
        end
                            )
                        )

local tasklist_buttons = 
    gears.table.join(
        awful.button( {}, 1,
            function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    -- Without this, the following
                    -- :isvisible() makes no sense
                    c.minimized = false
                    if not c:isvisible() and c.first_tag then
                        c.first_tag:view_only()
                    end
                    -- This will also un-minimize
                    -- the client, if needed
                    client.focus = c
                    c:raise()
                end
            end),
        awful.button( {}, 2, function(c) c:kill() end), 
        awful.button({}, 3, client_menu_toggle_fn()),
        awful.button( {}, 4, function() awful.tag.viewnext() end), 
        awful.button( {}, 5, function() awful.tag.viewprev() end)
     )

local textclock = wibox.widget.textclock()
local month_calendar = awful.widget.calendar_popup.month(
                           {
        style_header = { border_width = 0 },
        style_weekday = { border_width = 0 },
        style_normal = { border_width = 0 }
    }
                       )

local langbox_timer = gears.timer { timeout = 0.5 }

function show_langbox(show)
    return function()
        langbox_timer:stop()
        for s in screen do
            s.langbox.visible = show
        end
        if show then
            langbox_timer:start()
        end
    end
end

langbox_timer:connect_signal('timeout', show_langbox(false))
awesome.connect_signal('xkb::map_changed', show_langbox(true))
awesome.connect_signal('xkb::group_changed', show_langbox(true))

month_calendar:attach(textclock, 'bl')

screen.connect_signal(
    'request::desktop_decoration', function(s)

        -- Each screen has its own tag table.
        -- awful.tag({ "1", "q", "2", "w", "3", "e"}, s, awful.layout.layouts[1])
        local addtag = awful.tag.add
        addtag('1', { layout = awful.layout.suit.tile, column_count = 2, screen = s }):view_only()
        addtag('q', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        addtag('2', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        addtag(
            'w', {
                layout = awful.layout.suit.tile,
                column_count = 10,
                master_count = 0,
                screen = s
            }
        )
        addtag('3', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        addtag(
            'e', {
                layout = awful.layout.suit.tile,
                column_count = 10,
                master_count = 0,
                screen = s
            }
        )
        addtag('4', { layout = awful.layout.suit.tle, column_count = 2, screen = s })
        addtag('5', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        addtag('6', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        addtag('7', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        addtag('8', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        addtag('9', { layout = awful.layout.suit.tile, column_count = 2, screen = s })
        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contains an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(
            gears.table.join(
                awful.button(
                    {}, 1, function()
                        awful.layout.inc(1)
                    end
                ), awful.button(
                    {}, 3, function()
                        awful.layout.inc(-1)
                    end
                ), awful.button(
                    {}, 4, function()
                        awful.layout.inc(1)
                    end
                ), awful.button(
                    {}, 5, function()
                        awful.layout.inc(-1)
                    end
                )
            )
        )

        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = taglist_buttons,
            base_layout = {
                layout = wibox.layout.grid,
                forced_num_rows = 2,
                forced_num_cols = 6,
                homogenous = true,
                expand = true
            },
            widget_template = {
                {
                    { id = 'label_role', widget = wibox.widget.textbox },
                    margins = { left = 4, right = 4, top = 2, bottom = 3 },
                    widget = wibox.container.margin
                },
                id = 'background_role',
                widget = wibox.container.background,
                -- Add support for hover colors and an index label
                create_callback = function(self, c3, index, tags)
                    self.label = self.label or self:get_children_by_id('label_role')[1]
                    self.label.markup = '<b>' .. c3.name .. '</b>'
                    self:connect_signal(
                        'mouse::enter', function()
                            if self.bg ~= '#ee0000' then
                                self.backup = self.bg
                                self.has_backup = true
                            end
                            self.bg = '#ee0000'
                        end
                    )
                    self:connect_signal(
                        'mouse::leave', function()
                            if self.has_backup then
                                self.bg = self.backup
                            end
                        end
                    )
                end,
                update_callback = function(self, c3, index, tags)
                    self.label.markup = '<b>' .. c3.name .. '</b>'
                end
            }
        }

        local tooltip = awful.tooltip {}
        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons,
            layout = {
                layout = wibox.layout.fixed.vertical
                -- forced_height = 25
            },
            style = {
                shape_border_width = 1,
                shape_border_color = '#4A4A4A',
                shape = function(cr, width, height)
                    gears.shape.partially_rounded_rect(
                        cr, width, height, true, false, true, false, 10
                    )
                end
            },
            widget_template = {
                {
                    {
                        layout = wibox.layout.align.horizontal,
                        nil,
                        nil,
                        {
                            awful.widget.clienticon,
                            margins = 5,
                            widget = wibox.container.margin,
                            forced_width = 30,
                            forced_height = 30
                        }
                    },
                    {
                        { id = 'text_role', widget = wibox.widget.textbox, wrap = 'char' },
                        widget = function(widget)
                            return wibox.container.margin(widget, 5, 5)
                        end
                    },
                    layout = wibox.layout.fixed.vertical
                },
                id = 'background_role',
                widget = function(widget)
                    widget = wibox.container.background(widget)
                    widget:connect_signal(
                        'mouse::enter', function(self)
                            tooltip:add_to_object(widget)
                            tooltip.text = self:get_children_by_id('text_role')[1].text
                        end
                    )
                    return widget
                end,
                forced_height = 90
            }
        }

        -- Create the wibox
        s.mywibox = awful.wibar(
                        {
                position = 'left',
                width = 108,
                height = s.geometry.height,
                screen = s,
                visible = true,
                opacity = 0.7
            }
                    )
        -- Add widgets to the wibox
        s.mywibox:setup{
            layout = wibox.layout.align.vertical,
            { -- Top widgets
                layout = wibox.layout.fixed.vertical,
                { layout = wibox.layout.flex.horizontal, s.mytaglist, forced_height = 40 }
            },
            s.mytasklist, -- Middle widget
            { -- Bottom widgets
                layout = wibox.layout.fixed.vertical,
                {
                    {
                        layout = wibox.layout.fixed.vertical,
                        {
                            layout = wibox.layout.align.horizontal,
                            s.mylayoutbox,
                            weather_widget(
                                {
                                    api_key = constants.weather_api_key,
                                    coordinates = { 60.004, 30.324 },
                                    show_hourly_forecast = true,
                                    show_daily_forecast = true
                                }
                            ),
                            mykeyboardlayout,
                            forced_height = 22
                        },
                        { widget = wibox.widget.systray, horizontal = false, base_size = 25 },
                    },
                    widget = wibox.container.margin,
                    left = 2,
                    right = 2
                },
                {
                    {
                        layout = wibox.layout.fixed.horizontal,
                        volume_widget.create{device = "pipewire", widget_type = "horizontal_bar"},
                        forced_height = 25,
                    },
                    widget = wibox.container.margin,
                    left = 4,
                    right = 4
                },
                { layout = wibox.layout.fixed.horizontal, forced_height = 25, textclock }
            }
        }

        s.langbox = wibox(
                        {
                position = 'top',
                x = 40,
                y = s.geometry.height - 40,
                width = 20,
                height = 20,
                screen = s,
                ontop = true,
                visible = false,
                restrict_workarea = false,
                type = 'menu'
            }
                    )
        s.langbox:setup{ layout = wibox.layout.align.horizontal, mykeyboardlayout }
    end
)

screen.connect_signal(
    'request::resize', function(s)
        s.mywibox.height = s.geometry.height

    end
)
