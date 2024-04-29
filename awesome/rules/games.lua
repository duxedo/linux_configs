local awful = require('awful')
local gears = require('gears')
local weakvals = {}
weakvals.__mode = 'v'
return {
    {
        id = 'steam_games',
        rule_any = { class = { 'steam_app.*', 'RPCS3', 'hogwartslegacy.exe' } },
        -- properties = {
        --    _NET_WM_BYPASS_COMPOSITOR = 1
        -- }
        properties = { requested_border_width = 0 },
        callback = function(c)
            local clientref = setmetatable({ cl = c }, { __mode = 'kv' })
            c.border_width = 0
            print('new game' .. c.name)
            c.unredirect_timer = gears.timer {
                timeout = 1,
                single_shot = 1,
                autostart = true,
                callback = function()
                    print('new game')
                    if clientref.cl ~= nil then
                        local client = clientref.cl
                        if client == nil then
                            return
                        end
                        awful.spawn.easy_async(
                            'xprop -id ' .. client.window ..
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
        rule_any = { class = { 'RPCS3', 'hogwartslegacy.exe' } },
        properties = { floating = true, titlebars_enabled = false }
    }
}
