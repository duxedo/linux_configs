local awful = require('awful')
local gears = require('gears')
local weakvals = {}
weakvals.__mode = 'v'
return {
    {
        id = 'steam_games',
        rule_any = { class = { 'steam_app.*', 'RPCS3' } },
        -- properties = {
        --    _NET_WM_BYPASS_COMPOSITOR = 1
        -- }
        properties = { requested_border_width = 0 },
        callback = function(c)
            local clientref = { c }
            setmetatable(clientref, weakvals)
            c.border_width = 0
            print('new game' .. c.name)
            c.unredirect_timer = gears.timer {
                timeout = 1,
                single_shot = 1,
                autostart = true,
                callback = function()
                    print('new game')
                    if clientref[1] ~= nil then
                        local c = clientref[1]
                        awful.spawn.easy_async(
                            'xprop -id ' .. c.window ..
                                ' -f _NET_WM_BYPASS_COMPOSITOR 32c -set _NET_WM_BYPASS_COMPOSITOR 1',
                            function()
                            end
                        )
                    end
                end
            }
        end
    },

    {
        id = 'rpcs3',
        rule_any = { class = { 'RPCS3' } },
        properties = { floating = true, titlebars_enabled = false }
    }
}
