local wibox = require("wibox")
local menubar = require("menubar")
local awful = require("awful")
local lain = require("lain")
local beautiful = require("beautiful")
local theme = beautiful.get()
local gears = require("gears")
local naughty = require("naughty")
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()
-- {{{ Wibar

blue        = "#9EBABA"
red         = "#EB8F8F"

local seperator = wibox.widget.textbox(' <span color="' .. blue .. '">| </span>')
local spacer = wibox.widget.textbox(' <span color="' .. blue .. '"> </span>')

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
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.tag.viewnext()
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.tag.viewprev()
                                          end))


local textclock = wibox.widget.textclock()
local month_calendar = awful.widget.calendar_popup.month({style_header = { border_width = 0}, style_weekday = { border_width = 0}, style_normal = { border_width = 0 }})
langbox_timer = gears.timer {
        timeout = 0.5,
        callback = function ()
          show_langbox(false)
        end
    }

function show_langbox(show)
    langbox_timer:stop()
    for s in screen do s.langbox.visible = show end
    if show  then
      langbox_timer:start()
    end
end
month_calendar:attach(textclock, "tr")

awesome.connect_signal("xkb::map_changed",
                          function ()
                            show_langbox(true)
                          end)
awesome.connect_signal("xkb::group_changed",
                          function () 
                            show_langbox(true)
                          end);

screen.connect_signal("request::desktop_decoration", function(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "q", "w", "e"}, s, awful.layout.layouts[1])

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
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
	
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist{
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            layout = wibox.layout.fixed.vertical,
            forced_height = 25
        },
        style = {
            shape_border_width = 1,
            shape_border_color  = "#1A1A1A",
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, true, false, true, false, 20)
            end
        },
        widget_template = {
            {
                {
                    awful.widget.clienticon,
                    margins = 5,
                    widget  = wibox.container.margin,
                    forced_width = 40
                },
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                    wrap = "char"
                },
                layout = wibox.layout.fixed.horizontal,
            },
            id            = "background_role",
            widget        = wibox.container.background,
            forced_height = 75,
        },
    }

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "left",
        x = 0,
        y = 0,
        width = 150,
        height = s.geometry.height,
        screen = s, 
        visible = true,
    })
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.vertical,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
            forced_height = 25
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.layout.fixed.horizontal,
                mykeyboardlayout,
                wibox.widget.systray(),
            },
            {
                layout = wibox.layout.fixed.horizontal,
                forced_height = 25,
                s.mylayoutbox,
                textclock,
            },
        },
    }

    s.langbox = wibox(
    {
        position = "top",
        x = s.geometry.width - 40,
        y = 20,
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
    s.mywibox.width = s.geometry.width
end)
