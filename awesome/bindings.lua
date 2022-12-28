local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local menubar = require("menubar")
local const = require("constants")
local ut = require("utils")
local naughty = require("naughty")
local gears = require("gears")
local inspect = require("inspect")
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
-- {{{ Key bindings
awful.keyboard.append_global_keybindings({
    altkey ({ modkey, "Shift" }, "jk", awful.client.swap.byidx, "swap with next/previous client"),
    altkey ({ modkey }, "jk"            , awful.client.focus.byidx, "focus next/previous by index"),
    key    ({ modkey,           }, "u"     , awful.client.urgent.jumpto                           , "jump to urgent client"),
    key    ({ modkey,           }, "Tab"   , ut.prev                                              , "go back"),
    key    ({ modkey, "Control" }, "n"     , ut.restore_last_minimized                             , "restore minimized"),
    altkey ({ modkey,           }, "-="    , function (d) ut.inc_opacity(-d * 0.1)() end           , "increase/decrease opacity"),
    key    ({ modkey, "Shift"   }, "n"     , ut.restore_minimized_menu                             , "restore minimized menu"),
    key    ({ modkey            }, "c"     , ut.jump_to_hidden_client                              , "jump to hidden client"),
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
    key    ({ modkey            }, "p"     , ut.spawn("keepassxc")                                 , "keepass"),
    key    ({ modkey            }, "r"     , ut.rofi_default                                       , "run prompt"),
    key    ({ modkey , "Shift"  }, "r"     , ut.rofi_freedesktop                                   , "run prompt"),
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
    key    ({ modkey, "Shift"   }, "space" , function () awful.layout.inc(-1) end                   , "select previous"),
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
ut.vert = 1
ut.hor = 2
ut.maximize = function(mode)
    if mode == nil then
        return function(c)
            c.maximized = not c.maximized
            c:raise()
        end
    end
    if mode == ut.vert then
        return function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end
    end
    if mode == ut.hor then
        return function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end
    end
end

ut.fullscreen = function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
end
local props = {
    "window",
    "name",
    "skip_taskbar",
    "type",
    "class",
    "instance",
    "pid",
    "role",
    "machine",
    "icon_name",
    "icon",
    "icon_sizes",
    "screen",
    "hidden",
    "minimized",
    "size_hints_honor",
    "border_width",
    "border_color",
    "urgent",
    "content",
    "opacity",
    "ontop",
    "above",
    "below",
    "fullscreen",
    "maximized",
    "maximized_horizontal",
    "maximized_vertical",
    "transient_for",
    "group_window",
    "leader_window",
    "size_hints",
    "motif_wm_hints",
    "sticky",
    "modal",
    "focusable",
    "shape_bounding",
    "shape_clip",
    "shape_input",
    "client_shape_bounding",
    "client_shape_clip",
    "startup_id",
    "valid",
    "first_tag",
    "buttons",
    "keys",
    "marked",
    "is_fixed",
    "immobilized_horizontal",
    "immobilized_vertical",
    "floating",
    "x",
    "y",
    "width",
    "height",
    "dockable",
    "requests_no_titlebar",
    "shape",
    "active"
}
function ut.dumpclient(c)
    local repr = inspect(c)
    file = io.open("/home/reinhardt/lastclient.txt", "w")
    io.output(file)
    io.write(repr)
    io.write("\n")
    for k, v in pairs(props) do
        io.write(string.format("%s = %s \n",v,  inspect(c[v])))
    end
    io.close(file)
end

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        key   ({ modkey,           }, "f", ut.fullscreen, "toggle fullscreen", "client"),
        key   ({ modkey            }, "x",      function (c) c:kill()           end, "close", "client"),
        key   ({ modkey, "Control" }, "space",  awful.client.floating.toggle, "toggle floating", "client"),
        key   ({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, "move to master", "client"),
        key   ({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, "toggle keep on top", "client"),
        key   ({ modkey,           }, "n", function (c) c.minimized = true end , "minimize", "client"),
        altkey({ modkey,           }, "[]", function (d, c) awful.client.incwfact(0.05 * d, c) end , "dec/inc vertical size", "client"),
        key   ({ modkey,           }, "m", ut.maximize(), "(un)maximize", "client"),
        key   ({ modkey, "Control" }, "m", ut.maximize(ut.vert), "(un)maximize vertically", "client"),
        key   ({ modkey, "Shift"   }, "m", ut.maximize(ut.hor), "(un)maximize horizontally", "client"),
        key   ({ modkey }, "d", ut.dumpclient, "(un)maximize horizontally", "client"),
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
