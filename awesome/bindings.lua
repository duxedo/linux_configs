local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local vimkeys = require("hotkeys.nvim")
local const = require("constants")
local ut = require("utils")
local constants = require("constants")
local sensors = require("widgets.sensors")
local awedebug = os.getenv("awesome_debug")
local modkey = (not awedebug) and const.modkey or 'Mod1'

local bindings = {
}

local function keygroup(name)
    return function(args)
        awful.key.keygroups[name] = args
    end
end

keygroup("jk") {
    {"j", -1},
    {"k", 1}
}

keygroup("hl") {
    {"h", -1},
    {"l", 1}
}

keygroup("-=") {
    {"-", -1},
    {"=", 1}
}

keygroup("[]") {
    {"[", -1},
    {"]", 1}
}

keygroup(",.") {
    {",", -1},
    {".", 1}
}

keygroup(";'") {
    {";", -1},
    {"'", 1}
}

keygroup("tags") {
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

keygroup("volume") {
    {"XF86AudioLowerVolume", -1},
    {"XF86AudioRaiseVolume", 1}
}

local hotkeys = hotkeys_popup.new {
    font= "Fira Code Bold 12",
    description_font = "Fira Code 12",
    width = 2000,
    height = 1000,
}

vimkeys(hotkeys)

local volume_widget = require('widgets.pactl-widget.volume')
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")

local function modvolume(value, notify)
    return function (d)
        if d >= 0 then
            volume_widget:inc(d * value, notify)
        else
            volume_widget:dec(d * -value, notify)
        end
    end
end

local mod =  { modkey }
local modc = { modkey, "Control" }
local mods = { modkey, "Shift" }
local modm = { modkey, "Mod1" }
local modcs = { modkey, "Control", "Shift" }
bindings.global = {
client = {
    { mods , {"jk"}  , awful.client.swap.byidx                  , "swap with next/previous client"},
    { mod  , {"jk"}  , ut.focus_by_idx                          , "focus next/previous by index"},
    { mod  , "u"     , awful.client.urgent.jumpto               , "jump to urgent client"},
    { mod  , "Tab"   , function() ut.focus_by_idx(1) end        , "cycle focus"},
    { modc , "n"     , ut.restore_last_minimized                , "restore minimized"},
    { modc  , {"-="}  , function (d) ut.inc_opacity(d * 0.1)() end, "increase/decrease opacity"},
    { mods , "n"     , ut.restore_minimized_menu                , "restore minimized menu"},
    { mod  , "c"     , ut.jump_to_hidden_client                   , "jump to hidden client"},
},
media = {
    {{}, {"volume"}      ,  modvolume(5, true)    , "inc/dec volume"},
    {{}, "XF86AudioMute" , function() volume_widget:toggle(true) end     , "mute"},
    {{modkey}, "F10"     , ut.toggle_audio_profile                       , "toggle audio profile"},
},
brightness = constants.notebook and {
    {{}, "XF86MonBrightnessUp"       ,  function() brightness_widget:inc() end       , "increase brightness"},
    {{}, "XF86MonBrightnessDown"     ,  function() brightness_widget:dec() end       , "decrease brightness"},
} or nil,
notifications = {
    { modc,  "v"     , ut.spawn("dunstctl close-all")        , "close all"},
    { mod, "v"     , function ()
        ut.spawn("dunstctl history-pop")()
        ut.spawn("dunstctl history-pop")()
        ut.spawn("dunstctl history-pop")()
        ut.spawn("dunstctl history-pop")()
        ut.spawn("dunstctl history-pop")()
    end     , "hitory"},
    { mods, "v"     , ut.spawn("dunstctl context")          , "context menu"},
},
tag = {
    { mod, "Escape" , function() awful.tag.history.restore(nil, 1) end   , "go back"},
},
screen = {
    { mod,  {";'"}  , awful.screen.focus_relative                , "focus the next/previous screen"},
    { mod,  "o"  , awful.client.movetoscreen                , "move to next screen"},
},
awesome = {
    { mod,  "s"      , function() hotkeys:show_help() end            , "show help"},
    { mods, "b"      , ut.toggle_wibar                                  , "hide wibar"},
    --{ mod,  "'"      , ut.lua_prompt                                 , "lua execute prompt"},
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
    { mods, "r"      , ut.rofi({show = "drun"}), "run desktop apps"},
    { mod,  "d"      , ut.rofi(nil, {floating = true}), "run prompt floating"},
    { mods, "d"      , ut.rofi({show = "drun"}, {floating = true}), "run desktop apps floating"},
},
utility = {
    { modm, "s"     , ut.spawn("sync")                                      , "call fsync"},
    { mod, "y"     , function () sensors.detailed = not sensors.detailed end         , "toggle sensors detailed output"},
},
layout = {
    { mod,   {"hl"}, function (d) awful.tag.incmwfact( d * 0.005) end      , "inc/dec master width factor"},
    { mod,   "=", function () awful.tag.setmwfact( 0.5) end      , "equalize master/slave width"},
    { mods,  {"hl"}, function (d) awful.tag.incnmaster( d, nil, true) end  , "inc/dec # of master clients"},
    { modc,  {"hl"}, function (d) awful.tag.incncol( d, nil, true) end     , "inc/dec # of columns"},
    { mods,  {",."}, awful.layout.inc                                      , "previous/next"},
},
scrot = {
    { mod,  "Print", ut.screenshot(0)                                      , "flameshot"},
    { modm, "Print", ut.screenshot(3000)                                   , "flameshot with 3s delay"},
    { mods, "Print", ut.spawn("flameshot full --clipboard")                , "flameshot fullscreen to clipboard"},
    --{ mod,  "o"    , ut.spawn("sh -c \"sleep 3; xprop > ~/xpr\"")          , "write xprop to ~/xpr in 3 seconds"},
},
tags = {
    { mod,   {"tags"}, ut.view_tag, "view tag" },
    { modc,  {"tags"}, ut.toggle_tag, "toggle tag" },
    { mods,  {"tags"}, ut.move_to_tag, "move to tag" },
    { modm,  {"tags"}, ut.move_and_switch, "move + swtich to tag" },
    { modcs, {"tags"}, ut.toggle_client_on_tag, "toggle client on tag"},
}
}

ut.register_global_bindings(bindings.global)

client.connect_signal("request::default_keybindings", function(context)
    ut.register_client_bindings{
        client = {
            { mod , "f", ut.fullscreen, "toggle fullscreen"},
            { mod  , "x",      function (c) c:kill() end, "close"},
            { modc ,  "space",  awful.client.floating.toggle, "toggle floating"},
            { modc,  "Return", function (c) c:swap(awful.client.getmaster()) end, "move to master"},
            { mod , "t",      function (c) c.ontop = not c.ontop            end, "toggle keep on top"},
            { mods, "t",
            function (c)
                c.sticky = not c.sticky
                c.ontop = c.sticky
            end, "toggle sticky"},
            { mod , "n", function (c) c.minimized = true end , "minimize"},
            { mod,  "g", ut.toggle_titlebar , "toggle client titlebar"},
            { mod , {"[]"}, function (d, c) awful.client.incwfact(0.05 * d, c) end , "dec/inc size factor"},
            { mod , "m", ut.maximize(), "(un)maximize"},
            { modc,  "m", ut.maximize(ut.vert), "(un)maximize vertically"},
            { mods,  "m", ut.maximize(ut.hor), "(un)maximize horizontally"},
            { modc,  "d", ut.dumpclient, "dump client properties"},
            { mods, {"arrows"}, ut.resize, "resize client"},
            { mod,  {"arrows"}, ut.move, "move client"},
        }
    }
end)

bindings.client_bindings = {
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
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings (bindings.client_bindings)
end)

return bindings
