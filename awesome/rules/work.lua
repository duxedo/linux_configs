return {
    {
        id = 'myoffice apps',
        rule_any = { class = { 'MyOffice .*' } },
        properties = { floating = true }
    },
    {
        id = 'squadus_conference_popup',
        rule = { name = 'Always on top conference'},
        properties = { floating = true, minimized = true, ontop = true, sticky = true, focus = function () end }
    }
}
