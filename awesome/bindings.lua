local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local vimkeys = require("hotkeys.nvim")
local const = require("constants")
local ut = require("utils")
local constants = require("constants")

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

local hotkeys = hotkeys_popup.new {
    font= "Fira Code Bold 12",
    description_font = "Fira Code 12",
    width = 2000,
    height = 1000,
}

vimkeys(hotkeys)

local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
-- {{{ Key bindings
local mod =  { modkey }
local modc = { modkey, "Control" }
local mods = { modkey, "Shift" }
local modm = { modkey, "Mod1" }
local modcs = { modkey, "Control", "Shift" }
ut.register_global_bindings {
client = {
    { mods , {"jk"}  , awful.client.swap.byidx                  , "swap with next/previous client"},
    { mod  , {"jk"}  , ut.focus_by_idx                          , "focus next/previous by index"},
    { mod  , "u"     , awful.client.urgent.jumpto               , "jump to urgent client"},
    { mod  , "Tab"   , ut.prev                                   , "go back"},
    { modc , "n"     , ut.restore_last_minimized                , "restore minimized"},
    { mod  , {"-="}  , function (d) ut.inc_opacity(d * 0.1)() end, "increase/decrease opacity"},
    { mods , "n"     , ut.restore_minimized_menu                , "restore minimized menu"},
    { mod  , "c"     , ut.jump_to_hidden_client                   , "jump to hidden client"},
},
media = {
    {{}, "XF86AudioRaiseVolume"      , function() volume_widget:inc(5, true) end     , "increase volume"},
    {{}, "XF86AudioLowerVolume"      , function() volume_widget:dec(5, true) end     , "decrease volume"},
    {{}, "XF86AudioMute"             , function() volume_widget:toggle() end         , "mute"},
    {{modkey}, "F10"                 , ut.toggle_autdo_profile                       , "toggle audio profile"},
},
brightness = constants.notebook and {
    {{}, "XF86MonBrightnessUp"       ,  function() brightness_widget:inc() end       , "increase brightness"},
    {{}, "XF86MonBrightnessDown"     ,  function() brightness_widget:dec() end       , "decrease brightness"},
} or nil,
notifications = {
    { mod,  "v"     , ut.spawn("dunstctl close-all")        , "close all"},
    { modc, "v"     , ut.spawn("dunstctl history-pop")      , "hitory"},
    { mods, "v"     , ut.spawn("dunstctl context")          , "context menu"},
},
tag = {
    { mod, "Escape" , function() awful.tag.history.restore(nil, 1) end   , "go back"},
},
screen = {
    { modc,  {"jk"}  , awful.screen.focus_relative                , "focus the next/previous screen"},
},
awesome = {
    { mod,  "s"      , function() hotkeys:show_help() end            , "show help"},
    { mods, "b"      , ut.toggle_wibar                                  , "hide wibar"},
    { mod,  "'"      , ut.lua_prompt                                 , "lua execute prompt"},
    { modc, "r"      , awesome.restart                               , "reload awesome"},
    { modc, "x"      , awesome.quit                                  , "quit awesome"},
},
launcher = {
    { mod , "Return" , ut.spawn(const.terminal)                              , "open a terminal"},
    { modm, "l"      , ut.spawn("xscreensaver-command -lock")                , "lock station"},
    { mod , "a"      , ut.spawn(const.terminal)                              , "open a terminal"},
    { mod , "b"      , ut.spawn(const.browser)                               , "launch Browser"},
    { mod,  "p"      , ut.raise_or_spawn("keepassxc")                                 , "keepass"},
    { mod,  "r"      , ut.rofi(), "run prompt"},
    { mod,  "g"      , ut.rofi({show = "drun", ['drun-categories'] = "Game"}), "run games"},
    { mods, "r"      , ut.rofi({show = "drun"}), "run desktop apps"},
    { mod,  "d"      , ut.rofi(nil, {floating = true}), "run prompt floating"},
    { mods, "d"      , ut.rofi({show = "drun"}, {floating = true}), "run desktop apps floating"},
},
utility = {
    {{ modkey, "Mod1"    }, "s"     , ut.spawn("sync")                                      , "call fsync"},
},
layout = {
    { mod,   {"hl"}, function (d) awful.tag.incmwfact( d * 0.005) end      , "inc/dec master width factor"},
    { mods,  {"hl"}, function (d) awful.tag.incnmaster( d, nil, true) end  , "inc/dec # of master clients"},
    { modc,  {"hl"}, function (d) awful.tag.incncol( d, nil, true) end     , "inc/dec # of columns"},
    { mods,  {",."}, awful.layout.inc                                      , "previous/next"},
},
scrot = {
    { mod,  "Print", ut.screenshot(0)                                      , "flameshot"},
    { modm, "Print", ut.screenshot(3000)                                   , "flameshot with 3s delay"},
    { mods, "Print", ut.spawn("flameshot full --clipboard")                , "flameshot fullscreen to clipboard"},
    { mod,  "o"    , ut.spawn("sh -c \"sleep 3; xprop > ~/xpr\"")          , "write xprop to ~/xpr in 3 seconds"},
},
tags = {
    { mod,   {"tags"}, ut.view_tag, "view tag" },
    { modc,  {"tags"}, ut.toggle_tag, "toggle tag" },
    { mods,  {"tags"}, ut.move_to_tag, "move to tag" },
    { modm,  {"tags"}, ut.move_and_switch, "move + swtich to tag" },
    { modcs, {"tags"}, ut.toggle_client_on_tag, "toggle client on tag"},
}
}


client.connect_signal("request::default_keybindings", function(context)
    ut.register_client_bindings{
        client = {
            { mod , "f", ut.fullscreen, "toggle fullscreen"},
            { mod  , "x",      function (c) c:kill() end, "close"},
            { modc ,  "space",  awful.client.floating.toggle, "toggle floating"},
            { modc,  "Return", function (c) c:swap(awful.client.getmaster()) end, "move to master"},
            { mod , "t",      function (c) c.ontop = not c.ontop            end, "toggle keep on top"},
            { mod , "n", function (c) c.minimized = true end , "minimize"},
            { mod , {"[]"}, function (d, c) awful.client.incwfact(0.05 * d, c) end , "dec/inc size factor"},
            { mod , "m", ut.maximize(), "(un)maximize"},
            { modc,  "m", ut.maximize(ut.vert), "(un)maximize vertically"},
            { mods,  "m", ut.maximize(ut.hor), "(un)maximize horizontally"},
            { modc,  "d", ut.dumpclient, "dump client properties"},
            { mod, {"arrows"}, ut.resize, "resize client"},
            { mods,  {"arrows"}, ut.move, "move client"},
        }
    }
end)

--awful.keyboard.append_global_keybindings({
    --awful.key {
    --    modifiers   =  mod,
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
        awful.button( mod, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button( mod, 3, function (c)
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
--        { mod, 'z', function(self)
--            print('Is now active!', self)
--        end},
--    },
--    keypressed_callback = function(self, mod, key, event) debug_message("" .. key) end
--}
