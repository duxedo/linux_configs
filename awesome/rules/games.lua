local awful = require('awful')
local gears = require('gears')
local applyCompositorProps = function (windowId, value)
    print('apply compositor props' .. windowId .. ', ' .. value)
    awful.spawn.easy_async(
        'xprop -id ' .. windowId ..
            ' -f _NET_WM_BYPASS_COMPOSITOR 32c -set _NET_WM_BYPASS_COMPOSITOR ' .. value,
        function()
        end
    )
end
return {
    {
        id = 'steam_games',
        rule_any = { class = { 'steam_app.*', 'X4', 'RPCS3', 'hogwartslegacy.exe' ,'enshrouded.exe' } },
        -- properties = {
        --    _NET_WM_BYPASS_COMPOSITOR = 1
        -- }
        properties = { requested_border_width = 0 },
        callback = function(c)
            if c.class == "steam_app_8500"   then -- eve online
                return
            end
            if c.name == "Days Gone" then
                return
            end
            local clientref = setmetatable({ cl = c }, { __mode = 'kv' })
            c.border_width = 0
            print('new game: ' .. c.name)
            c.unredirect_timer = gears.timer {
                timeout = 2,
                single_shot = 1,
                autostart = true,
                callback = function()
                    local client = clientref.cl
                    if not client then
                        return
                    end

                    local value = '1'
                    --if client.class == "X4" then
                      --  value = '0'
                    --end
                    print('setting game properties: ' .. client.name)
                    applyCompositorProps(client.window, value)
                end
            }
        end
    },

    {
        id = 'rpcs3',
        rule_any = { class = { 'RPCS3', 'hogwartslegacy.exe' } },
        properties = { floating = true, titlebars_enabled = false }
    },

    {
        id = 'exp33',
        rule_any = { name = { 'Clair Obscur: Expedition 33' } },
        properties = {
            floating = true
            , titlebars_enabled = false,
        width     = 3440,
        height    = 1440,}
    }

}
