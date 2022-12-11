local wibox = require("wibox")
local menubar = require("menubar")
local awful = require("awful")
local lain = require("lain")
local beautiful = require("beautiful")
local theme = beautiful.get()
local gears = require("gears")
local naughty = require("naughty")
local constants = require("constants")

local weather_widget = require("awesome-wm-widgets.weather-widget.weather")
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()
-- {{{ Wibar

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
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
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
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
                     awful.button({ }, 2, function(c) 
                        c:kill()
                     end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.tag.viewnext()
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.tag.viewprev()
                                          end))


local textclock = wibox.widget.textclock()
local month_calendar = awful.widget.calendar_popup.month({style_header = { border_width = 0}, style_weekday = { border_width = 0}, style_normal = { border_width = 0 }})

local langbox_timer = gears.timer { timeout = 0.5 }

function show_langbox(show)
    return function () 
        langbox_timer:stop()
        for s in screen do s.langbox.visible = show end
        if show  then
          langbox_timer:start()
        end
    end
end

langbox_timer:connect_signal("timeout", show_langbox(false))
awesome.connect_signal("xkb::map_changed", show_langbox(true))
awesome.connect_signal("xkb::group_changed", show_langbox(true))

month_calendar:attach(textclock, "bl")

screen.connect_signal("request::desktop_decoration", function(s)

    -- Each screen has its own tag table.
    --awful.tag({ "1", "q", "2", "w", "3", "e"}, s, awful.layout.layouts[1])
    
    awful.tag.add("1", {
        layout = awful.layout.suit.tile,
        screen = s,
    }):view_only()
    awful.tag.add("q", {
        layout = awful.layout.suit.tile,
        screen = s,
    })
    awful.tag.add("2", {
        layout = awful.layout.suit.tile,
        screen = s,
    })
    awful.tag.add("w", {
        layout = awful.layout.suit.tile,
        screen = s,
    })
    awful.tag.add("3", {
        layout = awful.layout.suit.tile,
        screen = s,
    })
    awful.tag.add("e", {
        layout = lain.layout.termfair,
        screen = s,
        master_count = 4,
    })
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist{
        screen = s, 
        filter = awful.widget.taglist.filter.all, 
        buttons = taglist_buttons,
        layout  = {
            layout = wibox.layout.flex.horizontal,
        }
    }

    local tooltip = awful.tooltip {}
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist{
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            layout = wibox.layout.fixed.vertical,
            --forced_height = 25
        },
        style = {
            shape_border_width = 2,
            shape_border_color  = "#4A4A4A",
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, true, false, true, false, 10)
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
                        widget  = wibox.container.margin,
                        forced_width = 30,
                        forced_height = 30
                    },
                },
                {
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                        wrap = "char",
                    },
                    widget = function(widget) 
                        wig =  wibox.container.margin(widget, 5, 5)
                        return wig
                    end
                },
                layout = wibox.layout.fixed.vertical,
            },
            id            = "background_role",
            widget        = function(widget)
                widget = wibox.container.background(widget)
                widget:connect_signal('mouse::enter' , function(self)
                    tooltip:add_to_object(widget)
                    tooltip.text = self:get_children_by_id('text_role')[1].text
                end)
                return widget
            end,
            forced_height = 90,
        },
    }

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "left",
        x = 0,
        y = 0,
        width = 110,
        height = s.geometry.height,
        screen = s, 
        visible = true,
        opacity = 0.7
    })
    -- Add widgets to the wibox
    s.mywibox:setup {
        
        layout = wibox.layout.align.vertical,
        { -- Left widgets
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.layout.flex.horizontal,
                s.mytaglist,
                forced_height = 20
            },
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.layout.align.horizontal,
                s.mylayoutbox,
                weather_widget({
                    api_key=constants.weather_api_key,
                    coordinates = {60.004, 30.324},
                    show_hourly_forecast = true,
                    show_daily_forecast = true,
                }),
                mykeyboardlayout,
                forced_height = 25,
            },
            {
                widget = wibox.widget.systray,
                horizontal = true,
                base_size = 25
            },
            {
                layout = wibox.layout.fixed.horizontal,
                forced_height = 25,
                textclock,
            },
        },
    }

    s.langbox = wibox(
    {
        position = "top",
        x = 40,
        y = s.geometry.height - 40,
        width = 20,
        height = 20,
        screen = s, 
        ontop = true, 
        visible = false,
        restrict_workarea = false,
        type = "menu"
    })
    s.langbox:setup {
        layout = wibox.layout.align.horizontal,
        mykeyboardlayout,
    }
end)


screen.connect_signal("request::resize", function(s)
    s.mywibox.height = s.geometry.height

end)
