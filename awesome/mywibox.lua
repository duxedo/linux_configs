local wibox = require('wibox')
local menubar = require('menubar')
local awful = require('awful')
local beautiful = require('beautiful')
local theme = beautiful.get()
local gears = require('gears')
local constants = require('constants')
local sensors = require('widgets.sensors')
local fs_widget = require('widgets.fs-widget')

--local weather_widget = require('awesome-wm-widgets.weather-widget.weather')
local weather_widget = require('awesome-wm-widgets.weather-api-widget.weather')
local net_widget = require('widgets.net-speed-widget.net-speed')
local volume_widget = require('widgets.pactl-widget.volume')
local battery_widget = require('awesome-wm-widgets.battery-widget.battery')
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local cpu_widget = require('awesome-wm-widgets.cpu-widget.cpu-widget')
local ram_widget = require('widgets.ram-widget')
local modkey = constants.modkey
local dpi = require("beautiful.xresources").apply_dpi
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
local function iffocussed(f)
    return function(t)
        if client.focus then
            f(client.focus, t)
        end
    end
end
-- Create a wibox for each screen and add it
local taglist_buttons =
    gears.table.join(
        awful.button({}, 1, function(t) t:view_only() end),
        awful.button({ modkey }, 1, iffocussed(awful.client.object.move_to_tag)),
        awful.button({}, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, iffocussed(awful.client.object.toggle_tag)),
        awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
        awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
    )

local tasklist_buttons =
    gears.table.join(
        awful.button({}, 1,
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
        awful.button({}, 2, function(c) c:kill() end),
        awful.button({}, 3, client_menu_toggle_fn()),
        awful.button({}, 4, function() awful.tag.viewnext() end),
        awful.button({}, 5, function() awful.tag.viewprev() end)
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

local function setup_tags(screen)
    local addtag = awful.tag.add
    local default = function()
        return
        {
            layout = awful.layout.suit.tile,
            column_count = constants.notebook and 1 or 2,
            screen = screen,
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
            screen = screen
        }
    )
    addtag('3', default())
    addtag(
        'e', constants.notebook and default() or {
            layout = awful.layout.suit.tile,
            column_count = 10,
            master_count = 0,
            screen = screen
        }
    )
    addtag('4', default())
    addtag('5', default())
    addtag('6', default())
    addtag('7', default())
    addtag('8', default())
    addtag('9', default())
end

local function create_taglist(screen)
    local tag_base_layout = constants.notebook and {
            layout = wibox.layout.grid,
            forced_num_cols = 3,
            homogenous = true,
            horizontal_expand = true,
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
    return awful.widget.taglist {
        screen = screen,
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
            create_callback = function(self, c3, _, _) --index, tags)
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
end

local function create_tasklist_template_notebook()
    local tooltip = awful.tooltip {}
    return
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
            {
                {
                    {
                        id        = 'text_role',
                        wrap      = 'char',
                        visible   = true,
                        ellipsize = false,
                        font      = "Sans 3",
                        widget    = wibox.widget.textbox,
                    },
                    direction = "east",
                    widget = wibox.container.rotate
                },
                widget = function(widget)
                    return wibox.container.margin(widget, 3, 3, 3, 5)
                end
            },
            nil,
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
        forced_height = dpi(200)
    }
end

local function create_tasklist_template()
    local tooltip = awful.tooltip {}
    return {
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
end

local function create_tasklist(screen)
    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            layout = constants.notebook and wibox.layout.flex.vertical or wibox.layout.fixed.vertical
        },
        style = {
            spacing = 5,
            shape_border_color = '#4A4A4A',
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(
                    cr, width, height, true, false, true, false, 10
                )
            end
        },
        bg = '#FF0000',
        widget_template = constants.notebook and create_tasklist_template_notebook() or create_tasklist_template()
    }
end

local function create_wibox_layout(screen)
    return {
        layout = wibox.layout.align.vertical,
        { -- Top widgets
            layout = wibox.layout.fixed.vertical,
            { layout = wibox.layout.flex.horizontal, screen.mytaglist,           forced_height = 40 },
            { layout = wibox.layout.flex.horizontal, cpu_widget { timeout = 2 }, forced_height = 40 },
            ram_widget { timeout = 2 },
        },
        screen.mytasklist, -- Middle widget
        {                  -- Bottom widgets
            layout = wibox.layout.fixed.vertical,
            {
                {
                    layout = wibox.layout.fixed.vertical,
                    awful.widget.watch("cat /home/reinhardt/notes/memo", 2),
                    constants.sensors_format and sensors(constants.sensors_format),
                    fs_widget { mounts = { '/', '/archive', '/mnt/stor', '/boot' } },
                    {
                        layout = wibox.layout.align.horizontal,
                        screen.mylayoutbox,
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
                    net_widget({ interface = "enp39s0" }),
                    { widget = wibox.widget.systray, horizontal = false, reverse = true, base_size = 25 },
                },
                widget = wibox.container.margin,
                left = 2,
                right = 2
            },

            wibox.widget {
                markup = " ",
                halign = "center",
                valign = "center",
                widget = wibox.widget.textbox
            },

            {
                layout = wibox.layout.fixed.horizontal,
                volume_widget {
                    --device = "pipewire",
                    widget_type = "horizontal_bar",
                    mixer_cmd = 'pavucontrol -t 5'
                },
                forced_height = 25,
            },
            { layout = wibox.layout.fixed.horizontal, forced_height = 25,              textclock, },
            { layout = wibox.layout.fixed.horizontal, forced_height = math.random(25), nil, }
        }
    }
end

local function create_wibox_layout_notebook(screen)
    return {
        layout = wibox.layout.align.vertical,
        { -- Top widgets
            -- Top widgets
            { layout = wibox.layout.flex.horizontal, screen.mytaglist },
            layout = wibox.layout.fixed.vertical,
            ram_widget { timeout = 2 },
            cpu_widget { timeout = 2 },
        },
        screen.mytasklist, -- Middle widget
        {                  -- Bottom widgets
            layout = wibox.layout.fixed.vertical,
            {
                {
                    layout = wibox.layout.fixed.vertical,
                    constants.sensors_format and sensors(constants.sensors_format),
                    {
                        layout = wibox.layout.align.horizontal,
                        screen.mylayoutbox,
                        mykeyboardlayout,
                        forced_height = dpi(25)
                    },
                    {
                        layout = wibox.layout.align.horizontal,
                        battery_widget(),
                        brightness_widget(),
                        forced_height = dpi(25)
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
                        base_size = dpi(24)
                    }
                },
                widget = wibox.container.margin,
                left = 2,
                right = 2
            },
            {
                {
                    layout = wibox.layout.fixed.horizontal,
                    volume_widget {
                        --device = "pipewire",
                        widget_type = "horizontal_bar",
                        mixer_cmd = 'pavucontrol -t 5'
                    },
                    forced_height = 30,
                },
                widget = wibox.container.margin,
                left = 4,
                right = 4
            },
            { layout = wibox.layout.fixed.horizontal, forced_height = dpi(75), textclock }
        }
    }
end

local function setup_screen(s)
    -- Each screen has its own tag table.
    -- awful.tag({ "1", "q", "2", "w", "3", "e"}, s, awful.layout.layouts[1])
    setup_tags(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    --
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

    s.mytaglist = create_taglist(s)

    -- Create a tasklist widget
    s.mytasklist = create_tasklist(s)
    -- Create the wibox
    s.mywibox = awful.wibar {
        position = 'left',
        height = s.geometry.height,
        screen = s,
        visible = true,
        opacity = 0.7,
        --bg = '#00000055',
        --bgimage = '/home/reinhardt/Documents/transp.png',
        width = constants.notebook and dpi(57) or theme.wibox_width
    }

    s.mywibox:setup(constants.notebook and create_wibox_layout_notebook(s) or create_wibox_layout(s))

    s.langbox = wibox {
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

    s.langbox:setup { layout = wibox.layout.align.horizontal, mykeyboardlayout }
end
screen.connect_signal('request::desktop_decoration', setup_screen)

screen.connect_signal(
    'request::resize', function(s)
        s.mywibox.height = s.geometry.height
    end
)
