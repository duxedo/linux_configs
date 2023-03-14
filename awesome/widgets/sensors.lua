local wibox = require('wibox')
local awful = require('awful')
local textbox = require("wibox.widget.textbox")
local json = require("json")

local function create()
    local widget = textbox("asd\nasd")
    widget.font = "Fira Code 10"
    local cbk = function (widget, stdout, stderr, exitreason, exitcode)
        if exitcode ~= 0 then
            return
        end
        local result = json.decode(stdout)
        local process_temp = function (t)
            return tostring(math.floor(t))
        end
        local process_rpm = function (t)
            return tostring(math.floor(t))
        end
        local k10temp = result["k10temp-pci-00c3"]
        local nct = result["nct6797-isa-0a20"]
        local gpu = result["amdgpu-pci-2f00"]
        widget.text =
            "c1: " .. process_temp(k10temp.Tccd1.temp3_input) .. " c2: " .. process_temp(k10temp.Tccd2.temp4_input) .. "\n" ..
            "ct: " .. process_temp(k10temp.Tctl.temp1_input) .. " mb: " .. process_temp(nct.SYSTIN.temp1_input) .. "\n" ..
            "fan: " .. process_rpm(nct.fan2.fan2_input) .. "\n" ..
            "gpu: \n" ..
            "tj: " .. process_temp(gpu.junction.temp2_input) .. " te: " .. process_temp(gpu.edge.temp1_input) .. "\n" ..
            "tmem: ".. process_temp(gpu.mem.temp3_input) .. "\n" ..
            "fan: " .. process_rpm(gpu.fan1.fan1_input)


    end
    return awful.widget.watch("sensors -j", 1, cbk, widget)
end

return create
