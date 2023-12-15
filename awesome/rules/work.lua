local awful = require('awful')
return {
    {
        id = 'myoffice apps',
        rule_any = { class = { 'MyOffice .*' } },
        properties = { floating = true }
    },
    {
        id = 'squadus_conference_popup',
        rule = { name = 'Always on top conference'},
        properties = { floating = true, minimized = false, ontop = true, sticky = true, focus = function () end }
    },
    {
        id = 'devterm', --external terminal (alacritty) spawned from nvim-dap
        rule_any = { class = { 'devterm' } },
        callback = function(c)
            c.floating = true
            c.ontop = true
            c.opacity = 0.7
            awful.placement.top_right(c)
        end

    }

}
