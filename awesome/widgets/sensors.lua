local awful = require('awful')
local json = require("json")


local sensors = {
    detailed = false
}

local mt = {
}
function mt.__call(self, format_callback)
    local widget = format_callback(nil, nil)
    local cbk = function (widget_ref, stdout, stderr, exitreason, exitcode)
        if exitcode ~= 0 then
            return
        end
        local result = json.decode(stdout)
        format_callback(widget_ref, result, self.detailed)
    end
    return awful.widget.watch("sensors -j", 2, cbk, widget)
end
setmetatable(sensors, mt)

return sensors
