local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local menubar = require("menubar")
local const = require("constants")
local ut = require("utils")
local naughty = require("naughty")
local gears = require("gears")
-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    --awful.button({ }, 3, function () mymainmenu:toggle() end),
    --awful.button({ }, 4, awful.tag.viewprev),
    --awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}
--
modkey = const.modkey


awful.key.keygroups["jk"] = {
    {"j", 1},
    {"k", -1}
}
awful.key.keygroups["hl"] = {
    {"h", 1},
    {"l", -1}
}
awful.key.keygroups["-="] = {
    {"-", 1},
    {"=", -1}
}

local altkey = function (mods, keygroup, on_press, group, description)
    return awful.key {
        modifiers   = mods,
        keygroup    = keygroup,
        description = description,
        group       = group,
        on_press    = on_press,
    }
end
local key = function (mods, key, on_press, group, description)
    return awful.key(mods, key, on_press , {description=description, group=group})
end

local toggle_wibar = function ()
        scr = awful.screen.focused()
        scr.mywibox.visible = not scr.mywibox.visible
end
-- {{{ Key bindings
awful.keyboard.append_global_keybindings({
    altkey ({ modkey, "Shift" }, "jk", awful.client.swap.byidx, "client",  "swap with next/previous client"),
    key    ({ modkey }, "s"  , hotkeys_popup.show_help                       , "awesome", "show help"),
    key    ({ modkey }, "Escape"           , function() awful.tag.history.restore(nil, 1) end   , "tag", "go back"),
    altkey ({ modkey }, "jk"            , awful.client.focus.byidx, "client", "focus next/previous by index"),

    -- Layout manipulation
    --
    altkey ({ modkey, "Control" }, "jk"    , awful.screen.focus_relative                          , "screen", "focus the next/previous screen"),
    key    ({ modkey,           }, "u"     , awful.client.urgent.jumpto                           , "client", "jump to urgent client"),
    key    ({ modkey,           }, "Tab"   , ut.prev                                              , "client", "go back"),
    key    ({ modkey, "Shift"   }, "b"     , toggle_wibar                                         , "awesome", "hide wibar"),
    -- Standard program
    key    ({ modkey,           }, "Return", ut.spawn(const.terminal)                              , "launcher", "open a terminal"),
    key    ({ modkey, "Mod1"    }, "l"     , ut.spawn("xscreensaver-command -lock")                , "launcher", "open a terminal"),
    key    ({ modkey,           }, "a"     , ut.spawn(const.terminal)                              , "launcher", "open a terminal"),
    key    ({ modkey, "Control" }, "r"     , awesome.restart                                       , "awesome", "reload awesome"),
    key    ({ modkey, "Mod1"    }, "q"     , awesome.quit                                          , "awesome", "quit awesome"),

    altkey ({ modkey            }, "hl"    , function (d) awful.tag.incmwfact( -d * 0.005) end      , "layout", "increase/decrease master width factor"),
    altkey ({ modkey, "Shift"   }, "hl"    , function (d) awful.tag.incnmaster( -d, nil, true) end  , "layout", "increase/decrease the number of master clients"),
    altkey ({ modkey, "Control" }, "hl"    , function (d) awful.tag.incncol( -d, nil, true) end     , "layout", "increase/decrease the number of columns"),
    key    ({ modkey,           }, "b"     , ut.spawn(const.browser)                               , "launcher", "launch Browser"),
    key    ({ modkey            }, "p"     , ut.spawn("keepassxc")                                 , "launcher", "keepass"),
    key    ({ modkey, "Shift"   }, "space" , function () awful.layout.inc(-1) end                  , "layout", "select previous"),
    key    ({ modkey, "Control" }, "n"     , ut.restore_last_minimized                             , "client", "restore minimized"),
    altkey ({ modkey,           }, "-="    , function (d) ut.inc_opacity(-d * 0.1)() end              , "client", "increase/decrease opacity"),
    key    ({ modkey, "Shift"   }, "n"     , ut.restore_minimized_menu                             , "client", "restore minimized menu"),
    key    ({ modkey            }, "c"     , ut.jump_to_hidden_client                              , "client", "jump to hidden client"),
    -- Prompt
    key    ({ modkey            }, "r"     , ut.rofi_default                                       , "launcher", "run prompt"),
    key    ({ modkey , "Shift"  }, "r"     , ut.rofi_freedesktop                                   , "launcher", "run prompt"),
    key    ({ modkey            }, "'"     , ut.lua_prompt                                         , "awesome", "lua execute prompt"),
    -- Menubar
    key    ({ modkey            }, "Print" , ut.screenshot(0)                                      , "scrot", "flameshot"),
    key    ({ modkey , "Mod1"   }, "Print" , ut.screenshot(3000)                                   , "scrot", "flameshot with 3s delay"),
    key    ({ modkey , "Shift"  }, "Print" , ut.spawn("flameshot full --clipboard")                , "scrot", "flameshot fullscreen to clipboard"),
    key    ({ modkey            }, "o"     , ut.spawn("sh -c \"sleep 3; xprop > ~/xpr\"")          , "scrot", "write xprop to ~/xpr in 3 seconds"),
              
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

chords = {
    c = ut.spawn("calc")
}

local function stop(cbk)
    return 
    function(grabber)
        cbk()
        grabber:stop()
    end
end

awful.keygrabber {
    keybindings = {
        awful.key({}, "c", stop(ut.spawn("calc")))
    },
    stop_event         = 'release',
    root_keybindings = {
        {{modkey}, 'z', function(self)
            print('Is now active!', self)
        end},
    },
    keypressed_callback = function(self, mod, key, event) debug_message("" .. key) end
}
