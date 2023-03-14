local wibox = require('wibox')
local awful = require('awful')
local textbox = require("wibox.widget.textbox")
local json = require("json")

local function create(format_callback)
    local widget = textbox()
    widget.font = "Fira Code 10"
    local cbk = function (widget, stdout, stderr, exitreason, exitcode)
        if exitcode ~= 0 then
            return
        end
        local result = json.decode(stdout)
        format_callback(widget, result)
    end
    return awful.widget.watch("sensors -j", 1, cbk, widget)
end

return create
