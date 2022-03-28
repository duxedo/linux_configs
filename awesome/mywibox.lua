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
    awful.tag({ "1", "2", "3", "4", "5", "6", "im" }, s, awful.layout.layouts[1])

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
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "bottom",
        x = 0,
        y = 0,
        width = s.geometry.width,
        height = 20,
        screen = s, 
        ontop = true, 
        visible = true,
        restrict_workarea = true
    })
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
            seperator,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    wibox.widget.systray(),
                    mykeyboardlayout,
                    textclock,
                    s.mylayoutbox,
                },
    }
    s.detect = gears.timer {
        timeout = 0.5,
        callback = function ()
          if (mouse.screen ~= s) or
            (mouse.coords().y > 30)
           then  
             s.activation_zone.visible = true
             s.activation_zone.input_passthrough = false
             s.mywibox.visible = false
             s.detect:stop()
           end  
        end
    }

    s.enable_wibar = function ()
        s.mywibox.visible = true
        s.activation_zone.visible = false
        s.activation_zone.input_passthrough = true
        if not s.detect.started then
          s.detect:start()
        end
    end

    s.activation_zone = wibox ({
        x = s.geometry.x, y = s.geometry.y,
        opacity = 0.0, width = s.geometry.width, height = 1,
        screen = s, input_passthrough = false, visible = true,
        ontop = true, type = "dock",
    })

    s.activation_zone:connect_signal("mouse::enter", function ()
        s.detect:stop()
        s.enable_wibar()
    end)

   -- s.mywibox:connect_signal("mouse::leave", function()
   --     s.detect:start()
   -- end)
    
    s.langbox = wibox(
    {
        position = "top",
        x = s.geometry.width - 40,
        y = 20,
        width = 20,
        height = 20,
        screen = s, 
        ontop = true, 
        visible = true,
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
