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
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Lain
local lain = require("lain")
-- Freedesktop menu
local freedesktop = require("freedesktop")
-- Enable VIM help for hotkeys widget when client with matching name is opened:
-- require("awful.hotkeys_popup.keys.vim")
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
naughty.config.presets.low.timeout = 10
naughty.config.presets.normal.timeout = 10
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}
--
presswait = { started = false }

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(awful.util.getdir("config") .. "/themes/cesious/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/zenburn/theme.lua")
beautiful.notification_font = "Noto Sans Regular 15"
local theme = beautiful.get()

local mywibox = require("mywibox")
-- This is used later as the default terminal and editor to run.
terminal = "kitty"
browser = "brave-bin"
filemanager = "fm"
editor = "kitty v"
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
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
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
-- }}}


-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s %s", editor, awesome.conffile) },
    { "restart", awesome.restart }
}

myexitmenu = {
    { "log out", function() awesome.quit() end, "/usr/share/icons/breeze-dark/actions/22/system-log-out.svg" },
    { "suspend", "systemctl suspend", "/usr/share/icons/breeze-dark/actions/22/system-suspend.svg" },
    { "hibernate", "systemctl hibernate", "/usr/share/icons/breeze-dark/actions/22/system-suspend-hibernate.svg" },
    { "reboot", "systemctl reboot", "/usr/share/icons/breeze-dark/actions/22/system-reboot.svg" },
    { "shutdown", "poweroff", "/usr/share/icons/breeze-dark/actions/22/system-shutdown.svg" }
}

mymainmenu = freedesktop.menu.build({
    before = {
        { "Terminal", terminal, "/usr/share/icons/breeze-dark/apps/22/utilities-terminal.svg" },
        { "Browser", browser, "/usr/share/icons/hicolor/128x128/apps/brave-bin.png" },
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
                                     menu = mymainmenu })


local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
--

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    --awful.key({ modkey, "Control" }, "l", function () awful.spawn("/usr/bin/dm-tool lock") end,
      --        {description = "lock screen", group = "screen"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Mod1"    }, "l", function () awful.spawn("xscreensaver-command -lock") end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "z", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", function() 
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = "testErr" })
        naughty.notify({ preset = naughty.config.presets.normal,
                         title = "Oops, an error happened!",
                         text = "testErr" })
        naughty.notify({ preset = naughty.config.presets.low,
                         title = "Oops, an error happened!",
                         text = "testErr" })
      --awesome.quit 
    end,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)                 end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)                 end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true)        end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true)        end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)           end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)           end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, Shift     }, "b", function () awful.spawn(browser)                   end,
              {description = "launch Browser", group = "launcher"}),
    awful.key({ modkey, "Control"}, "Escape", function () awful.spawn("/usr/bin/rofi -show drun -modi drun") end,
              {description = "launch rofi", group = "launcher"}),
    awful.key({ modkey,           }, "e", function () awful.spawn(filemanager)            end,
              {description = "launch filemanager", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                       end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.spawn("dmenu_run") end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "'",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "x",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "[",
        function (c)
            awful.client.incwfact(0.05, c)
        end ,
        {description = "inc vertical size", group = "client"}),
    awful.key({ modkey,           }, "]",
        function (c)
            awful.client.incwfact(-0.05, c)
        end ,
        {description = "dec verticals size", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise()
                 mymainmenu:hide() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, function (c) awful.mouse.client.resize(c) end))

-- Set keys
root.keys(globalkeys)
-- }}}
--
-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        except = { name = "Origin" },
        properties = { 
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            size_hints_honor = false, -- Remove gaps between terminals
            screen = awful.screen.preferred,
            callback = awful.client.setslave,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    { 
        rule_any = {
            instance = {
              "copyq",  -- Includes session name in class.
            },
            class = {
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

            name = {
              "Event Tester",  -- xev.
              "Origin",   -- Origin client.
              "Welcome to Android Studio",
              "Android Virtual Device Manager" -- android studio AVD
            },
            role = {
              "AlarmWindow",  -- Thunderbird's calendar.
              "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
        }, 
        properties = { floating = true }
    },

    { 
        rule_any = {
            class = {"TelegramDesktop", "Slack"}
        }, 
        properties = { tags = {awful.screen.focused().tags[7]} },
    },

    { 
        rule = { class = "jetbrains-studio" },
        properties = { tags = {awful.screen.focused().tags[2]}},
        callback = function(c) 
            if c.skip_taskbar then
                c.floating = true
                awful.placement.centered(c)
            end    
        end,
    },

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" } },
      properties = { titlebars_enabled = true }
    },
	
    { rule_any = {type = { "dialog" } },
      callback = function (c)
          awful.placement.centered(c, nil)
      end
    },
    { rule = { role = "_NET_WM_STATE_FULLSCREEN" },
  properties = { floating = true } },
}
-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
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

    awful.titlebar(c) : setup {
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

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--        and awful.client.focus.filter(c) then
--        client.focus = c
--    end
--end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Disable borders on lone windows
-- Handle border sizes of clients.
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
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
end

-- }}}

client.connect_signal("property::floating", function (c)
    if c.floating and not c.skip_taskbar then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end)
awful.spawn.with_shell(
       'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
       'xrdb -merge <<< "awesome.started:true";' ..
       -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
       'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
       )
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

