local wibox = require('wibox')
local menubar = require('menubar')
local awful = require('awful')
local beautiful = require('beautiful')
local theme = beautiful.get()
local gears = require('gears')
local constants = require('constants')
local sensors = require('widgets.sensors')

local weather_widget = require('awesome-wm-widgets.weather-widget.weather')
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local battery_widget = require('awesome-wm-widgets.battery-widget.battery')
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local cpu_widget = require('awesome-wm-widgets.cpu-widget.cpu-widget')
local ram_widget = require('widgets.ram-widget')
local modkey = constants.modkey
-- Menubar configuration
menubar.utils.terminal = constants.terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()
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
local taglist_buttons =
gears.table.join(
    awful.button( {}, 1, function(t) t:view_only() end),
    awful.button( { modkey }, 1,
        function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button( { modkey }, 3,
        function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end),
    awful.button( {}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button( {}, 5, function(t) awful.tag.viewprev(t.screen) end)
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
local textclock = nil
if not constants.notebook then
    textclock = wibox.widget.textclock('%a %d.%m, %H:%M')
else
    textclock = wibox.widget.textclock('%a %b\n%d\n%H:%M')
end
textclock.forced_width = theme.wibox_width
textclock.halign = 'center'

local month_calendar = awful.widget.calendar_popup.month(
                           {
        style_header = { border_width = 0 },
        style_weekday = { border_width = 0 },
        style_normal = { border_width = 0 }
    }
                       )

local langbox_timer = gears.timer { timeout = 0.5 }

local function show_langbox(show)
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
        local default = function ()
            return
            {
                layout = awful.layout.suit.tile,
                column_count = constants.notebook and 1 or 2,
                screen = s,
            }
        end
        addtag('1', default()):view_only()
        addtag('q', default())
        addtag('2', default())
        addtag(
            'w', constants.notebook and default() or {
                layout = awful.layout.suit.tile,
                column_count = 10,
                master_count = 0,
                screen = s
            }
        )
        addtag('3', default())
        addtag(
            'e', constants.notebook and default() or {
                layout = awful.layout.suit.tile,
                column_count = 10,
                master_count = 0,
                screen = s
            }
        )
        addtag('4', default())
        addtag('5', default())
        addtag('6', default())
        addtag('7', default())
        addtag('8', default())
        addtag('9', default())
        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contains an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.mylayoutbox = awful.widget.layoutbox(s)
        local function modLayout(dir)
            return function()
                awful.layout.inc(dir)
            end
        end
        s.mylayoutbox:buttons(
            gears.table.join(
                awful.button({}, 1, modLayout(1)),
                awful.button({}, 3, modLayout(-1)),
                awful.button({}, 4, modLayout(1)),
                awful.button({}, 5, modLayout(-1))
            )
        )

        local tag_base_layout = constants.notebook and {
            layout = wibox.layout.grid,
            forced_num_rows = 6,
            forced_num_cols = 3,
            homogenous = true,
            expand = true
        }
        or
        {
            layout = wibox.layout.grid,
            forced_num_rows = 2,
            forced_num_cols = 6,
            homogenous = true,
            expand = true
        }
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = taglist_buttons,
            base_layout = tag_base_layout,
            widget_template = {
                {
                    { id = 'label_role', widget = wibox.widget.textbox },
                    margins = { left = 4, right = 4, top = 2, bottom = 3 },
                    widget = wibox.container.margin
                },
                id = 'background_role',
                widget = wibox.container.background,
                -- Add support for hover colors and an index label
                create_callback = function(self, c3, _ , _) --index, tags)
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
                update_callback = function(self, c3, _, _) --index, tags)
                    self.label.markup = '<b>' .. c3.name .. '</b>'
                end
            }
        }

        local tooltip = awful.tooltip {}
        local widget_template = constants.notebook and
        {
            {
                layout = wibox.layout.align.vertical,
                {
                    awful.widget.clienticon,
                    margins = 3,
                    widget = wibox.container.margin,
                    forced_width = 30,
                    forced_height = 30
                },
                nil,
                {
                    {
                        id = 'text_role',
                        wrap = 'char',
                        visible = true,
                        ellipsize = false,
                        font      = "Sans 3",
                        widget = wibox.widget.textbox,
                    },
                    widget = function(widget)
                        return wibox.container.margin(widget, 5, 5)
                    end
                },
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
            forced_height = 100
        }
        or
        {
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
        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons,
            layout = {
                layout = wibox.layout.fixed.vertical
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
            widget_template = widget_template
        }

        local wibar_args = {
                position = 'left',
                height = s.geometry.height,
                screen = s,
                visible = true,
                opacity = 0.7
            }

        if constants.notebook then
            wibar_args.width = 57
        else
            wibar_args.width = theme.wibox_width
        end
        -- Create the wibox
        s.mywibox = awful.wibar(
            wibar_args
        )
        local wibox_cfg = not constants.notebook and
        {
            layout = wibox.layout.align.vertical,
            { -- Top widgets
                layout = wibox.layout.fixed.vertical,
                { layout = wibox.layout.flex.horizontal, s.mytaglist, forced_height = 40 },
                cpu_widget{ timeout = 2 },
                ram_widget{ timeout = 2 },
            },
            s.mytasklist, -- Middle widget
            { -- Bottom widgets
                layout = wibox.layout.fixed.vertical,
                {
                    {
                        layout = wibox.layout.fixed.vertical,
                        constants.sensors_format and sensors(constants.sensors_format),
                        {
                            layout = wibox.layout.align.horizontal,
                            s.mylayoutbox,
                            weather_widget(
                                {
                                    api_key = constants.weather_api_key,
                                    coordinates = { 60.004, 30.324 },
                                    show_hourly_forecast = true,
                                    show_daily_forecast = true,
                                    timeout = 600
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
                        volume_widget.create{
                            device = "pipewire",
                            widget_type = "horizontal_bar",
                            mixer_cmd = 'pavucontrol -t 5'
                        },
                        forced_height = 25,
                    },
                    widget = wibox.container.margin,
                    left = 4,
                    right = 4
                },
                { layout = wibox.layout.fixed.horizontal, forced_height = 25, textclock,  }
            }
        }
        or
        {
            layout = wibox.layout.align.vertical,
             -- Top widgets
            { layout = wibox.layout.flex.horizontal, s.mytaglist, forced_height = 90 },
            s.mytasklist, -- Middle widget
            { -- Bottom widgets
                layout = wibox.layout.fixed.vertical,
                {
                    {
                        layout = wibox.layout.fixed.vertical,
                        {
                            layout = wibox.layout.align.horizontal,
                            s.mylayoutbox,
                            mykeyboardlayout,
                            forced_height = 25
                        },
                        {
                            layout = wibox.layout.align.horizontal,
                            battery_widget(),
                            brightness_widget(),
                            forced_height = 25
                        },
                        weather_widget(
                            {
                                api_key = constants.weather_api_key,
                                coordinates = { 60.004, 30.324 },
                                show_hourly_forecast = true,
                                show_daily_forecast = true
                            }
                        ),
                        {
                            widget = wibox.widget.systray,
                            horizontal = false,
                            base_size = 24
                        }
                    },
                    widget = wibox.container.margin,
                    left = 2,
                    right = 2
                },
                {
                    {
                        layout = wibox.layout.fixed.horizontal,
                        volume_widget.create{
                            device = "pipewire",
                            widget_type = "horizontal_bar",
                            mixer_cmd = 'pavucontrol -t 5'
                        },
                        forced_height = 25,
                    },
                    widget = wibox.container.margin,
                    left = 4,
                    right = 4
                },
                { layout = wibox.layout.fixed.horizontal, forced_height = 75, textclock }
            }
        }
        -- Add widgets to the wibox
        s.mywibox:setup(wibox_cfg)

        s.langbox = wibox (
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
