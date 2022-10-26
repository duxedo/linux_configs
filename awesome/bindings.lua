local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local menubar = require("menubar")
local const = require("constants")
local ut = require("utils")
-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    --awful.button({ }, 3, function () mymainmenu:toggle() end),
    --awful.button({ }, 4, awful.tag.viewprev),
    --awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}
--
modkey = const.modkey



-- {{{ Key bindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "s"                , hotkeys_popup.show_help                              , {description="show help", group="awesome"}),
    awful.key({ modkey }, "Escape"           , function() awful.tag.history.restore(nil, 1) end     , {description = "go back", group = "tag"}),
    awful.key({ modkey }, "j"                , function () awful.client.focus.byidx( 1) end         , {description = "focus next by index", group = "client"}),
    awful.key({ modkey }, "k"                , function () awful.client.focus.byidx(-1) end         , {description = "focus previous by index", group = "client"}),

    -- Layout manipulation
    --
    awful.key({ modkey, "Shift"   }, "j"     , function () awful.client.swap.byidx(  1)    end      , {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k"     , function () awful.client.swap.byidx( -1)    end      , {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j"     , function () awful.screen.focus_relative( 1) end      , {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k"     , function () awful.screen.focus_relative(-1) end      , {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u"     , awful.client.urgent.jumpto                           , {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey,           }, "Tab"   , ut.prev                                              , {description = "go back", group = "client"}),

    awful.key({ modkey, "Shift"   }, "b"     , function () 
        scr = awful.screen.focused()
        scr.mywibox.visible = not scr.mywibox.visible
    end                 , {description = "hide wibar", group = "awesome"}),
    -- Standard program
    awful.key({ modkey,           }, "Return", ut.spawn(const.terminal)                              , {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Mod1"    }, "l"     , ut.spawn("xscreensaver-command -lock")                , {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "a"     , ut.spawn(const.terminal)                              , {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r"     , awesome.restart                                       , {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "q"     , awesome.quit                                          , {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l"     , function () awful.tag.incmwfact( 0.005) end           , {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h"     , function () awful.tag.incmwfact(-0.005) end           , {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h"     , function () awful.tag.incnmaster( 1, nil, true) end   , {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l"     , function () awful.tag.incnmaster(-1, nil, true) end   , {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h"     , function () awful.tag.incncol( 1, nil, true) end      , {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l"     , function () awful.tag.incncol(-1, nil, true) end      , {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "b"     , ut.spawn(const.browser)                               , {description = "launch Browser", group = "launcher"}),
    awful.key({ modkey            }, "p"     , ut.spawn("keepassxc")                                 , {description = "keepass", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "space" , function () awful.layout.inc(-1) end                  , {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Control" }, "n"     , ut.restore_last_minimized                             , {description = "restore minimized", group = "client"}),
    awful.key({ modkey, "Shift"   }, "n"     , ut.restore_minimized_menu                             , {description = "restore minimized menu", group = "client"}),
    awful.key({ modkey            }, "c"     , ut.jump_to_hidden_client                              , {description = "jump to hidden client", group = "client"}),
    -- Prompt
    awful.key({ modkey            }, "r"     , ut.rofi_default                                       , {description = "run prompt", group = "launcher"}),
    awful.key({ modkey , "Shift"  }, "r"     , ut.rofi_freedesktop                                   , {description = "run prompt", group = "launcher"}),
    awful.key({ modkey            }, "'"     , ut.lua_prompt                                         , {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey            }, "Print" , ut.screenshot(0)                                      , {description = "flameshot", group = "scrot"}),
    awful.key({ modkey , "Mod1"   }, "Print" , ut.screenshot(3000)                                   , {description = "flameshot with 3s delay", group = "scrot"}),
    awful.key({ modkey , "Shift"  }, "Print" , ut.spawn("flameshot full --clipboard")                , {description = "flameshot fullscreen to clipboard", group = "scrot"}),
    awful.key({ modkey            }, "o"     , ut.spawn("sh -c \"sleep 3; xprop > ~/xpr\"")          , {description = "write xprop to ~/xpr in 3 seconds", group = "scrot"}),
              
})

--awful.keyboard.append_global_keybindings({
        --awful.key({ modkey, "Shift"           }, "w",      function()
          --for s in screen do
            --s.activation_zone.visible = not s.activation_zone.visible
          --end
            --end ,
              --{description="disable wibar autoshow", group="awesome"}),
            --})

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey }, "x",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
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
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)

awful.key.keygroups["tags"] = {
    {"1", 1},
    {"q", 2},
    {"2", 3},
    {"w", 4},
    {"3", 5},
    {"e", 6},
}

awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "tags",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "tags",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "tags",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Mod1" },
        keygroup    = "tags",
        description = "move focused client to tag and switch to that tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                    tag:view_only()
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "tags",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)
