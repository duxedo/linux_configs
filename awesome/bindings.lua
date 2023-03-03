local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local vimkeys = require("hotkeys.nvim")
local const = require("constants")
local ut = require("utils")

local modkey = const.modkey

awful.key.keygroups["jk"] = {
    {"j", -1},
    {"k", 1}
}
awful.key.keygroups["hl"] = {
    {"h", -1},
    {"l", 1}
}
awful.key.keygroups["-="] = {
    {"-", -1},
    {"=", 1}
}
awful.key.keygroups["[]"] = {
    {"[", -1},
    {"]", 1}
}
awful.key.keygroups[",."] = {
    {",", -1},
    {".", 1}
}

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

local key = ut.key
local hotkeys = hotkeys_popup.new({font= "Fira Code Bold 12", description_font = "Fira Code 12", width = 2000, height = 1000,
--modifiers_fg = theme.fg_normal
})
vimkeys(hotkeys)

local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
-- {{{ Key bindings
ut.register_global_bindings {
client = {
    {{ modkey, "Shift"   }, {"jk"}      , awful.client.swap.byidx                       , "swap with next/previous client"},
    {{ modkey            }, {"jk"}      , ut.focus_by_idx                               , "focus next/previous by index"},
    {{ modkey,           }, "u"         , awful.client.urgent.jumpto                    , "jump to urgent client"},
    {{ modkey,           }, "Tab"       , ut.prev                                       , "go back"},
    {{ modkey, "Control" }, "n"         , ut.restore_last_minimized                     , "restore minimized"},
    {{ modkey,           }, {"-="}      , function (d) ut.inc_opacity(d * 0.1)() end    , "increase/decrease opacity"},
    {{ modkey, "Shift"   }, "n"         , ut.restore_minimized_menu                     , "restore minimized menu"},
    {{ modkey            }, "c"         , ut.jump_to_hidden_client                      , "jump to hidden client"},
},
media = {
    {{}, "XF86AudioRaiseVolume"      , function() volume_widget:inc(5, true) end     , "increase volume"},
    {{}, "XF86AudioLowerVolume"      , function() volume_widget:dec(5, true) end     , "decrease volume"},
    {{}, "XF86AudioMute"             , function() volume_widget:toggle() end         , "mute"},
    {{modkey}, "F10"                 , ut.toggle_autdo_profile                       , "toggle audio profile"},
},
notifications = {
    {{modkey }, "v"                  , ut.spawn("dunstctl close-all")                , "close all"},
    {{modkey, "Control" }, "v"       , ut.spawn("dunstctl history-pop")              , "hitory"},
    {{modkey, "Shift" }, "v"         , ut.spawn("dunstctl context")                  , "context menu"},
},
tag = {
    {{ modkey }, "Escape"            , function() awful.tag.history.restore(nil, 1) end   , "go back"},
},
screen = {
    {{ modkey, "Control" }, {"jk"}      , awful.screen.focus_relative                , "focus the next/previous screen"},
},
awesome = {
    {{ modkey }           , "s"      , function() hotkeys:show_help() end            , "show help"},
    {{ modkey, "Shift"   }, "b"      , ut.toggle_wibar                                  , "hide wibar"},
    {{ modkey            }, "'"      , ut.lua_prompt                                 , "lua execute prompt"},
    {{ modkey, "Control" }, "r"      , awesome.restart                               , "reload awesome"},
    {{ modkey, "Control" }, "x"      , awesome.quit                                  , "quit awesome"},
},
launcher = {
    {{ modkey,           }, "Return", ut.spawn(const.terminal)                              , "open a terminal"},
    {{ modkey, "Mod1"    }, "l"     , ut.spawn("xscreensaver-command -lock")                , "lock station"},
    {{ modkey,           }, "a"     , ut.spawn(const.terminal)                              , "open a terminal"},
    {{ modkey,           }, "b"     , ut.spawn(const.browser)                               , "launch Browser"},
    {{ modkey            }, "p"     , ut.raise_or_spawn("keepassxc")                                 , "keepass"},
    {{ modkey            }, "r"     , ut.rofi(), "run prompt"},
    {{ modkey            }, "g"     , ut.rofi({show = "drun", ['drun-categories'] = "Game"}), "run games"},
    {{ modkey , "Shift"  }, "r"     , ut.rofi({show = "drun"}), "run desktop apps"},
    {{ modkey            }, "d"     , ut.rofi(nil, {floating = true}), "run prompt floating"},
    {{ modkey , "Shift"  }, "d"     , ut.rofi({show = "drun"}, {floating = true}), "run desktop apps floating"},
},
utility = {
    {{ modkey, "Mod1"    }, "s"     , ut.spawn("sync")                                      , "call fsync"},
},
layout = {
    {{ modkey            }, {"hl"}  , function (d) awful.tag.incmwfact( d * 0.005) end      , "inc/dec master width factor"},
    {{ modkey, "Shift"   }, {"hl"}  , function (d) awful.tag.incnmaster( d, nil, true) end  , "inc/dec # of master clients"},
    {{ modkey, "Control" }, {"hl"}  , function (d) awful.tag.incncol( d, nil, true) end     , "inc/dec # of columns"},
    {{ modkey, "Shift"   }, {",."}  , awful.layout.inc                                      , "previous/next"},
},
scrot = {
    {{ modkey            }, "Print" , ut.screenshot(0)                                      , "flameshot"},
    {{ modkey , "Mod1"   }, "Print" , ut.screenshot(3000)                                   , "flameshot with 3s delay"},
    {{ modkey , "Shift"  }, "Print" , ut.spawn("flameshot full --clipboard")                , "flameshot fullscreen to clipboard"},
    {{ modkey            }, "o"     , ut.spawn("sh -c \"sleep 3; xprop > ~/xpr\"")          , "write xprop to ~/xpr in 3 seconds"},
},
tags = {
    {{ modkey }, {"tags"}, ut.view_tag, "view tag" },
    {{ modkey, "Control" }, {"tags"}, ut.toggle_tag, "toggle tag" },
    {{ modkey, "Shift" }, {"tags"}, ut.move_to_tag, "move to tag" },
    {{ modkey, "Mod1" }, {"tags"}, ut.move_and_switch, "move + swtich to tag" },
    {{ modkey, "Control", "Shift" }, {"tags"}, ut.toggle_client_on_tag, "toggle client on tag"},
}
}


client.connect_signal("request::default_keybindings", function(context)
    ut.register_client_bindings{
        client = {
            {{ modkey,           }, "f", ut.fullscreen, "toggle fullscreen"},
            {{ modkey            }, "x",      function (c) awful.client.focus.history.previous() c:kill() end, "close"},
            {{ modkey, "Control" }, "space",  awful.client.floating.toggle, "toggle floating"},
            {{ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, "move to master"},
            {{ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, "toggle keep on top"},
            {{ modkey,           }, "n", function (c) c.minimized = true end , "minimize"},
            {{ modkey,           }, {"[]"}, function (d, c) awful.client.incwfact(0.05 * d, c) end , "dec/inc size factor"},
            {{ modkey,           }, "m", ut.maximize(), "(un)maximize"},
            {{ modkey, "Control" }, "m", ut.maximize(ut.vert), "(un)maximize vertically"},
            {{ modkey, "Shift"   }, "m", ut.maximize(ut.hor), "(un)maximize horizontally"},
            {{ modkey, "Control" }, "d", ut.dumpclient, "dump client properties"},
            {{ modkey            }, {"arrows"}, ut.resize, "resize client"},
            {{ modkey, "Shift"   }, {"arrows"}, ut.move, "move client"},
        }
    }
end)

--awful.keyboard.append_global_keybindings({
    --awful.key {
    --    modifiers   = { modkey },
    --    keygroup    = "numpad",
    --    description = "select layout directly",
    --    group       = "layout",
    --    on_press    = function (index)
    --        local t = awful.screen.focused().selected_tag
    --        if t then
    --            t.layout = t.layouts[index] or t.layout
    --        end
    --    end,
    --}
--})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings {
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    }
end)

--local function stop(cbk)
--    return
--    function(grabber)
--        cbk()
--        grabber:stop()
--    end
--end
--
--awful.keygrabber {
--    keybindings = {
--        awful.key({}, "c", stop(ut.spawn("calc")))
--    },
--    stop_event         = 'release',
--    root_keybindings = {
--        {{modkey}, 'z', function(self)
--            print('Is now active!', self)
--        end},
--    },
--    keypressed_callback = function(self, mod, key, event) debug_message("" .. key) end
--}
