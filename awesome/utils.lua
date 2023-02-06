local awful = require('awful')
local inspect = require('inspect')

utils = {}

function utils.prevfocus()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end

function utils.restore_last_minimized()
    c = awful.client.restore()
    -- Focus restored client
    if c then
        client.focus = c
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

return utils
