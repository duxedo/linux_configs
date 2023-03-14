local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local watch = require("awful.widget.watch")
local wibox = require("wibox")


local ramgraph_widget = {}


local function worker(user_args)
    local args = user_args or {}
    local timeout = args.timeout or 1
    local color_used = args.color_used or beautiful.fg_normal
    local color_free = args.color_free or beautiful.bg_urgent
    local color_buf  = args.color_buf  or beautiful.border_focus
    local widget_height = args.widget_height or 25
    local widget_width = args.widget_width or 25

    --- Main ram widget shown on wibar
    local progressbar = wibox.widget{
        border_width = 0,
        color = {
           type = "linear",
           from = { 0, 0 },
           to   = { 100, 0},
           stops = {
              {0, color_used},
              { 0.33, color_used},
              { 0.33, color_buf},
              { 0.66, color_buf},
              { 0.68, color_free},
              { 1, color_free},
           }
        },
        max_value = 1,
        paddings = { top = 4, bottom = 2, left = 2 , right = 2 },
        background_color = "#00000000",
        display_labels = false,
        value = 1,
        widget = wibox.widget.progressbar,
        set_data = function(self, used, free, cached)
            local total = used + free + cached
            local used_stop = used / total
            local cached_stop = used_stop + cached / total
            self.color = {
               type = "linear",
               from = { 0, 0 },
               to   = { 100, 0},
               stops = {
                  {0, color_used},
                  { used_stop, color_used},
                  { used_stop, color_buf},
                  { cached_stop, color_buf},
                  { cached_stop, color_free},
                  { 1, color_free},
               }
            }
        end
    }

    local swap_progress = wibox.widget{
        widget = wibox.widget.progressbar,
        paddings = { top = 2, bottom = 4, left = 2 , right = 2 },
        background_color = "#00000000",
        color = color_used
    }


    ramgraph_widget = wibox.widget {
       progressbar,
       swap_progress,
       forced_height = widget_height,
       forced_width = widget_width,
       layout  = wibox.layout.flex.vertical,
       ram_bar = progressbar
    }

    --- Widget which is shown when user clicks on the ram widget
    local popup = awful.popup{
       ontop = true,
       visible = false,
       widget = {
          widget = wibox.widget.piechart,
          forced_height = 200,
          forced_width = 400,
          colors = {
             color_used,
             color_free,
             color_buf,  -- buf_cache
          },
       },
       shape = gears.shape.rounded_rect,
       border_color = beautiful.border_color_active,
       border_width = 1,
       offset = { y = 5 },
    }

    --luacheck:ignore 231
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap

    local function getPercentage(value, total)
        return math.floor(value / (total) * 100 + 0.5) .. '%'
    end

    watch('bash -c "LANGUAGE=en_US.UTF-8 free | grep -z Mem.*Swap.*"', timeout,
        function(widget, stdout)
            total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
                stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
            widget.ram_bar:set_data(used, free, buff_cache)
            swap_progress.value = used_swap / (used_swap + free_swap)
            if popup.visible then
               popup:get_widget().data_list = {
                  {'used ' .. getPercentage(used, total), used},
                  {'free ' .. getPercentage(free, total), free},
                  {'buff_cache ' .. getPercentage(buff_cache, total), buff_cache}
                }
            end
        end,
        ramgraph_widget
    )

    ramgraph_widget:buttons(
        awful.util.table.join(
           awful.button({}, 1, function()
                 popup:get_widget().data_list = {
                    {'used ' .. getPercentage(used, total), used},
                    {'free ' .. getPercentage(free, total), free},
                    {'buff_cache ' .. getPercentage(buff_cache, total), buff_cache}
                }

                if popup.visible then
                   popup.visible = not popup.visible
                else
                   popup:move_next_to(mouse.current_widget_geometry)
                end
            end)
        )
    )

    return ramgraph_widget
end


return setmetatable(ramgraph_widget, { __call = function(_, ...)
    return worker(...)
end })
