local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
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
awful.key.keygroups["[]"] = {
    {"[", -1},
    {"]", 1}
}
local altkey = function (mods, keygroup, on_press, description, group)
    return awful.key {
        modifiers   = mods,
        keygroup    = keygroup,
        description = description,
        group       = group,
        on_press    = on_press,
    }
end
local key = function (mods, key, on_press, description, group)
    return awful.key(mods, key, on_press , {description=description, group=group})
end

local toggle_wibar = function ()
    scr = awful.screen.focused()
    scr.mywibox.visible = not scr.mywibox.visible
end

local function movefocus(next_client)
    local prev_client = client.focus
    local prev_client_box = prev_client and { x = prev_client.x, y = prev_client.y, w = prev_client.width, h = prev_client.height } or nil
    next_client:emit_signal("request::activate", "movefocus",
                       {raise=true})

    local coords = mouse.coords()

    if prev_client_box ~= nil then
        coords.x = coords.x - prev_client_box.x
        coords.x = coords.x / prev_client_box.w
        coords.y = coords.y - prev_client_box.y
        coords.y = coords.y / prev_client_box.h
    else
        coords = { x = 0.5, y = 0.5 }
    end

    if coords.y < 0 or coords.y > 1 or coords.x < 0 or coords.x > 1 then
      return
    end

    coords.y = coords.y * next_client.height
    coords.y = coords.y + next_client.y
    coords.x = coords.x * next_client.width
    coords.x = coords.x + next_client.x
    mouse.coords(coords, true) -- x,y, silent (don't fire signals such as enter/leave)
end

local function focus_by_idx(i)
    local next_client = awful.client.next(i)
    movefocus(next_client)
end
-- {{{ Key bindings
awful.keyboard.append_global_keybindings({
    altkey ({ modkey, "Shift" }, "jk", awful.client.swap.byidx, "swap with next/previous client"),
    altkey ({ modkey }, "jk"            , focus_by_idx, "focus next/previous by index"),
    key    ({ modkey,           }, "u"     , awful.client.urgent.jumpto                           , "jump to urgent client"),
    key    ({ modkey,           }, "Tab"   , ut.prev                                              , "go back"),
    key    ({ modkey, "Control" }, "n"     , ut.restore_last_minimized                             , "restore minimized"),
    altkey ({ modkey,           }, "-="    , function (d) ut.inc_opacity(-d * 0.1)() end           , "increase/decrease opacity"),
    key    ({ modkey, "Shift"   }, "n"     , ut.restore_minimized_menu                             , "restore minimized menu"),
    key    ({ modkey            }, "c"     , ut.jump_to_hidden_client                              , "jump to hidden client"),
--    key    ({}, "XF86AudioRaiseVolume"     , ut.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")                              , "increase volume"),
--    key    ({}, "XF86AudioLowerVolume "    , ut.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")                              , "decrease volume"),
    group = "client"
})
awful.keyboard.append_global_keybindings({
    key    ({ modkey }, "Escape"           , function() awful.tag.history.restore(nil, 1) end   , "go back"),
    group = "tag"
})
awful.keyboard.append_global_keybindings({
    altkey ({ modkey, "Control" }, "jk"    , awful.screen.focus_relative                          , "focus the next/previous screen"),
    group = "screen"
})
awful.keyboard.append_global_keybindings({
    key    ({ modkey }, "s"  , hotkeys_popup.show_help                                            , "show help"),
    key    ({ modkey, "Shift"   }, "b"     , toggle_wibar                                         , "hide wibar"),
    key    ({ modkey            }, "'"     , ut.lua_prompt                                        , "lua execute prompt"),
    key    ({ modkey, "Control" }, "r"     , awesome.restart                                      , "reload awesome"),
    key    ({ modkey, "Control", "Mod1"    }, "x"     , awesome.quit                              , "quit awesome"),
    group = "awesome"
})
awful.keyboard.append_global_keybindings({
    key    ({ modkey,           }, "Return", ut.spawn(const.terminal)                              , "open a terminal"),
    key    ({ modkey, "Mod1"    }, "l"     , ut.spawn("xscreensaver-command -lock")                , "open a terminal"),
    key    ({ modkey,           }, "a"     , ut.spawn(const.terminal)                              , "open a terminal"),
    key    ({ modkey,           }, "b"     , ut.spawn(const.browser)                               , "launch Browser"),
    key    ({ modkey            }, "p"     , ut.raise_or_spawn("keepassxc")                                 , "keepass"),
    key    ({ modkey            }, "r"     , ut.rofi(), "run prompt"),
    key    ({ modkey            }, "g"     , ut.rofi({show = "drun", ['drun-categories'] = "Game"}), "run games"),
    key    ({ modkey , "Shift"  }, "r"     , ut.rofi({show = "drun"}), "run prompt"),
    key    ({ modkey            }, "d"     , ut.rofi(nil, {floating = true}), "run prompt"),
    key    ({ modkey , "Shift"  }, "d"     , ut.rofi({show = "drun"}, {floating = true}), "run prompt"),
    group = "launcher"
})

awful.keyboard.append_global_keybindings({
    key    ({ modkey, "Mod1"    }, "s"     , ut.spawn("sync")                                      , "call fsync"),
    group = "utility"
})
awful.keyboard.append_global_keybindings({
    altkey ({ modkey            }, "hl"    , function (d) awful.tag.incmwfact( -d * 0.005) end      , "increase/decrease master width factor"),
    altkey ({ modkey, "Shift"   }, "hl"    , function (d) awful.tag.incnmaster( -d, nil, true) end  , "increase/decrease the number of master clients"),
    altkey ({ modkey, "Control" }, "hl"    , function (d) awful.tag.incncol( -d, nil, true) end     , "increase/decrease the number of columns"),
    key    ({ modkey, "Shift"   }, ","     , function () awful.layout.inc(-1) end                   , "select previous"),
    key    ({ modkey, "Shift"   }, "."     , function () awful.layout.inc(1) end                   , "select previous"),
    group = "layout"
})
awful.keyboard.append_global_keybindings({
    key    ({ modkey            }, "Print" , ut.screenshot(0)                                      , "flameshot"),
    key    ({ modkey , "Mod1"   }, "Print" , ut.screenshot(3000)                                   , "flameshot with 3s delay"),
    key    ({ modkey , "Shift"  }, "Print" , ut.spawn("flameshot full --clipboard")                , "flameshot fullscreen to clipboard"),
    key    ({ modkey            }, "o"     , ut.spawn("sh -c \"sleep 3; xprop > ~/xpr\"")          , "write xprop to ~/xpr in 3 seconds"),
    group = "scrot"
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
        key   ({ modkey,           }, "f", ut.fullscreen, "toggle fullscreen", "client"),
        key   ({ modkey            }, "x",      function (c) awful.client.focus.history.previous() c:kill() end, "close", "client"),
        key   ({ modkey, "Control" }, "space",  awful.client.floating.toggle, "toggle floating", "client"),
        key   ({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, "move to master", "client"),
        key   ({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, "toggle keep on top", "client"),
        key   ({ modkey,           }, "n", function (c) c.minimized = true end , "minimize", "client"),
        altkey({ modkey,           }, "[]", function (d, c) awful.client.incwfact(0.05 * d, c) end , "dec/inc vertical size", "client"),
        key   ({ modkey,           }, "m", ut.maximize(), "(un)maximize", "client"),
        key   ({ modkey, "Control" }, "m", ut.maximize(ut.vert), "(un)maximize vertically", "client"),
        key   ({ modkey, "Shift"   }, "m", ut.maximize(ut.hor), "(un)maximize horizontally", "client"),
        key   ({ modkey, "Control" }, "d", ut.dumpclient, "dump client properties", "client"),
    })
end)

awful.key.keygroups["tags"] = {
    {"1", 1},
    {"q", 2},
    {"2", 3},
    {"w", 4},
    {"3", 5},
    {"e", 6},
    {"4", 7},
    {"5", 8},
    {"6", 9},
    {"7", 10},
    {"8", 11},
    {"9", 12},
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
