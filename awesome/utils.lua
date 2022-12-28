local awful = require("awful")
local utils = {}

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
    awful.menu.clients (nil, nil, function(c)
      if c.minimized and not c.hidden then
        for _, tag in pairs(c:tags()) do
          if tag.selected then
            return true
          end
        end
        return false
      end
    end)
end

function utils.jump_to_hidden_client()
    awful.menu.clients (nil, nil, function(c)
      if c.minimized then
        return true
      end
      for _, tag in pairs(c:tags()) do
        if tag.selected then
          return false
        end
      end
      return true
    end)
end

function utils.add_hidden_client()
    awful.menu.clients (nil, nil, function(c)
      if c.minimized then
        return true
      end
      for _, tag in pairs(c:tags()) do
        if tag.selected then
          return false
        end
      end
      return true
    end)
end

function utils.rofi_default () 
    awful.spawn("rofi -show run -matching regex -sorting-method fzf")
end

function utils.rofi_freedesktop () 
    awful.spawn("rofi -show drun -matching regex -sorting-method fzf")
end

function utils.lua_prompt()
    awful.prompt.run {
      prompt       = "Run Lua code: ",
      textbox      = awful.screen.focused().mypromptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. "/history_eval"
    }
end

function utils.spawn(cmd)
    return function() awful.spawn(cmd) end
end

function utils.screenshot(delay)
    if delay == 0 then
        return utils.spawn("flameshot gui")
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
return utils
