local awful = require('awful')
local inspect = require('inspect')
local gears = require('gears')
local wibox = require('wibox')

local utils = {}

local audio_profiles = {
    profiles = {
        "pactl set-card-profile 41 output:iec958-stereo+input:analog-stereo",
        "pactl set-card-profile 41 output:analog-stereo+input:analog-stereo"
    },
    current = 0
}
function utils.toggle_audio_profile()
    audio_profiles.current = audio_profiles.current + 1
    audio_profiles.current = audio_profiles.current % #(audio_profiles.profiles)
    awful.spawn(audio_profiles.profiles[audio_profiles.current + 1])
end
function utils.toggle_wibar()
    scr = awful.screen.focused()
    scr.mywibox.visible = not scr.mywibox.visible
end
function utils.prevfocus()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end

function utils.restore_last_minimized()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
        c:activate { context = "restore" }
        c:raise()
    end
end

function utils.restore_minimized_menu()
    awful.menu.clients(
        nil, nil, function(c)
            if c.minimized and not c.hidden then
                for _, tag in pairs(c:tags()) do
                    if tag.selected then
                        return true
                    end
                end
                return false
            end
        end
    )
end

function utils.jump_to_hidden_client()
    awful.menu.clients(
        nil, nil, function(c)
            if c.minimized then
                return true
            end
            for _, tag in pairs(c:tags()) do
                if tag.selected then
                    return false
                end
            end
            return true
        end
    )
end

function utils.add_hidden_client()
    awful.menu.clients(
        nil, nil, function(c)
            if c.minimized then
                return true
            end
            for _, tag in pairs(c:tags()) do
                if tag.selected then
                    return false
                end
            end
            return true
        end
    )
end

function utils.resize(dir, c)
    local w = 0
    local h = 0
    local resize_constant = 40
    if dir == "Up" then
        h = resize_constant
    elseif dir == "Down" then
        h = -resize_constant
    elseif dir == "Left" then
        w = -resize_constant
    else
        w = resize_constant
    end
    c:relative_move(-w,-h, 2*w, 2*h)
end

function utils.move(dir, c)
    local x = 0
    local y = 0
    local resize_constant = 80
    if dir == "Up" then
        y = -resize_constant
    elseif dir == "Down" then
        y = resize_constant
    elseif dir == "Left" then
        x = -resize_constant
    else
        x = resize_constant
    end
    c:relative_move(x,y, 0, 0)
end
function utils.movefocus(next_client)
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

function utils.focus_by_idx(i)
    local next_client = awful.client.next(i)
    utils.movefocus(next_client)
end
local function makeArgs(args, prefix, arg_sep, sep)
    local args_str = ""
    for k, v in pairs(args) do
        args_str = args_str .. sep .. prefix .. k .. arg_sep .. v
    end
    return args_str
end

function utils.rofi(args, rules)
    local default_args={
        show = "run",
        matching = "regex",
        ["sorting-method"] = "fzf"
    }

    if not args then
        args = default_args
    else
        for k,v in pairs(default_args) do
            if not args[k] then
                args[k] = v
            end
        end
    end

    return function()
        local rcmd = 'rofi ' .. makeArgs(args, "-" , " ", " ") .. ' -run-command "echo {cmd}"'
        print(rcmd)
        awful.spawn.easy_async(
            rcmd, function(out)
                if out then
                    awful.spawn(out, rules)
                end
            end
        )
    end
end

function utils.lua_prompt()
    awful.prompt.run {
        prompt = 'Run Lua code: ',
        textbox = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. '/history_eval'
    }
end

function utils.spawn(cmd)
    return function()
        awful.spawn(cmd)
    end
end

function utils.raise_or_spawn(cmd)
    return function()
        awful.spawn.raise_or_spawn(cmd)
    end
end

function utils.screenshot(delay)
    if delay == 0 then
        return utils.spawn('flameshot gui')
    end
    return utils.spawn('sh -c "flameshot gui --delay ' .. tostring(delay) .. '"')
end

function utils.inc_opacity(amount)
    return function()
        if client.focus then
            local client = client.focus
            client.opacity = client.opacity + amount
            if client.opacity >= 1.0 then
                client.opacity = 1.0
            end
            if client.opacity <= 0.0 then
                client.opacity = 0.0
            end
        end
    end
end

function utils.view_tag(index)
    local screen = awful.screen.focused()
    local tag = screen.tags[index]
    if tag then
        tag:view_only()
    end
end
function utils.toggle_tag(index)
    local screen = awful.screen.focused()
    local tag = screen.tags[index]
    if tag then
        awful.tag.viewtoggle(tag)
    end
end
function utils.move_to_tag(index)
    if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
            client.focus:move_to_tag(tag)
        end
    end
end
function utils.move_and_switch(index)
    if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
            client.focus:move_to_tag(tag)
            tag:view_only()
        end
    end
end
function utils.toggle_client_on_tag(index)
    if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
            client.focus:toggle_tag(tag)
        end
    end
end

function utils.key(mods, key, on_press, description, group)
    return awful.key {
        modifiers   = mods,
        keygroup    = type(key) == 'table' and key[1] or nil,
        key         = type(key) == 'string' and key,
        description = description,
        group       = group,
        on_press    = on_press,
    }
end

function utils.register_bindings(binder, groups)
    for groupname, group in pairs(groups) do
        local bindings = {}
        for _, keydef in pairs(group) do
            table.insert(bindings, utils.key(keydef[1], keydef[2], keydef[3], keydef[4], groupname))
        end
        binder(bindings)
    end
end

function utils.register_global_bindings(groups)
    utils.register_bindings(awful.keyboard.append_global_keybindings, groups)
end

function utils.register_client_bindings(groups)
    utils.register_bindings(awful.keyboard.append_client_keybindings, groups)
end

utils.client_props = {
    'window',
    'name',
    'skip_taskbar',
    'type',
    'class',
    'instance',
    'pid',
    'role',
    'machine',
    'icon_name',
    'icon',
    'icon_sizes',
    'screen',
    'hidden',
    'minimized',
    'size_hints_honor',
    'border_width',
    'border_color',
    'urgent',
    'content',
    'opacity',
    'ontop',
    'above',
    'below',
    'fullscreen',
    'maximized',
    'maximized_horizontal',
    'maximized_vertical',
    'transient_for',
    'group_window',
    'leader_window',
    'size_hints',
    'motif_wm_hints',
    'sticky',
    'modal',
    'focusable',
    'shape_bounding',
    'shape_clip',
    'shape_input',
    'client_shape_bounding',
    'client_shape_clip',
    'startup_id',
    'valid',
    'first_tag',
    'buttons',
    'keys',
    'marked',
    'is_fixed',
    'immobilized_horizontal',
    'immobilized_vertical',
    'floating',
    'x',
    'y',
    'width',
    'height',
    'dockable',
    'requests_no_titlebar',
    'shape',
    'active'
}

function utils.dumpclient(c)
    local repr = inspect(c)
    file = io.open('/home/reinhardt/lastclient.txt', 'w')
    file:write(repr)
    file:write('\n')
    for k, v in pairs(utils.client_props) do
        file:write(string.format('%s = %s \n', v, inspect(c[v])))
    end
    file:close()
end


utils.vert = 1
utils.hor = 2
function utils.maximize(mode)
    if mode == nil then
        return function(c)
            c.maximized = not c.maximized
            c:raise()
        end
    end
    if mode == utils.vert then
        return function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end
    end
    if mode == utils.hor then
        return function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end
    end
end

function utils.fullscreen(c)
    c.fullscreen = not c.fullscreen
    c:raise()
end

function utils.setup_titlebar(c)
        -- buttons for the titlebar
        local buttons = gears.table.join(
                            awful.button(
                                {}, 1, function()
                    c:activate()
                    awful.mouse.client.move(c)
                end
                            ), awful.button(
                                {}, 3, function()
                    c:activate()
                    awful.mouse.client.resize(c, nil, awful.placement.right)
                end
                            )
                        )

        awful.titlebar(c).widget = {
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    halign = 'center',
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.stickybutton(c),
                -- awful.titlebar.widget.ontopbutton    (c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
        -- Hide the menubar if we are not floating
        local l = awful.layout.get(c.screen)
        if l ~= nil and not (l.name == 'floating' or c.floating) then
            --awful.titlebar.hide(c)
        end
end

function utils.toggle_titlebar(c)
    c.titlebars_enabled = not c.titlebars_enabled
    if c.titlebars_enabled then
        if not awful.titlebar(c).widget then
            utils.setup_titlebar(c)
        end
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end
return utils
