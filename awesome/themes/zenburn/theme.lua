-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

local current_path = require("awful").util.getdir("config") .. "themes/zenburn/"
local themes_path = require("gears.filesystem").get_themes_dir()
local rnotification = require("ruled.notification")
local dpi = require("beautiful.xresources").apply_dpi

-- {{{ Main
local theme = {}
--theme.wallpaper = current_path .. "/zenburn-background-5120.png"
--theme.wallpaper = "/home/reinhardt/.config/wallpapers/wp7786809-5120x1440-wallpapers.png"
theme.wallpaper = "/home/reinhardt/.config/wallpapers/2043630.png"
-- }}}

-- {{{ Styles
theme.font      = "Noto Sans 9"

-- {{{ Colors
theme.fg_normal  = "#DCDCCC"
theme.fg_focus   = "#F0DFAF"
theme.fg_urgent  = "#CC9393"
theme.bg_normal  = "#2F2F2F"
theme.bg_focus   = "#101010"
theme.bg_urgent  = "#3F3F3F"
theme.bg_systray = theme.bg_normal
theme.systray_max_rows = 4
-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(0)
theme.border_width  = dpi(1)
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#e5961e"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
theme.border_widget    = "#000000"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(30)
theme.menu_width  = dpi(200)
theme.menu_border_width = 0
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = current_path .. "taglist/squarefz.png"
theme.taglist_squares_unsel = current_path .. "taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = current_path .. "zenburn/awesome-icon.png"
theme.menu_submenu_icon      = themes_path .. "default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = current_path .. "layouts/tile.png"
theme.layout_tileleft   = current_path .. "layouts/tileleft.png"
theme.layout_tilebottom = current_path .. "layouts/tilebottom.png"
theme.layout_tiletop    = current_path .. "layouts/tiletop.png"
theme.layout_fairv      = current_path .. "layouts/fairv.png"
theme.layout_fairh      = current_path .. "layouts/fairh.png"
theme.layout_spiral     = current_path .. "layouts/spiral.png"
theme.layout_dwindle    = current_path .. "layouts/dwindle.png"
theme.layout_max        = current_path .. "layouts/max.png"
theme.layout_fullscreen = current_path .. "layouts/fullscreen.png"
theme.layout_magnifier  = current_path .. "layouts/magnifier.png"
theme.layout_floating   = current_path .. "layouts/floating.png"
theme.layout_cornernw   = current_path .. "layouts/cornernw.png"
theme.layout_cornerne   = current_path .. "layouts/cornerne.png"
theme.layout_cornersw   = current_path .. "layouts/cornersw.png"
theme.layout_cornerse   = current_path .. "layouts/cornerse.png"
theme.layout_centerwork = current_path .. "layouts/centerwork.png"
theme.layout_termfair   = current_path .. "layouts/termfair.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = current_path .. "titlebar/close_focus.png"
theme.titlebar_close_button_normal = current_path .. "titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = current_path .. "titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = current_path .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = current_path .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = current_path .. "titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = current_path .. "titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = current_path .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = current_path .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = current_path .. "titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = current_path .. "titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = current_path .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = current_path .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = current_path .. "titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = current_path .. "titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = current_path .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = current_path .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = current_path .. "titlebar/maximized_normal_inactive.png"
theme.notification_max_width = 1080
theme.notification_max_height = 500
-- }}}
-- }}}

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = '#c4413d', fg = '#ffffff' }
    }
end)

theme.wibox_width=110

local gears = require('gears')
theme.hotkeys_shape = function(cr, width, height)
    gears.shape.partially_rounded_rect(
        cr, width, height, true, true, true, true, 10
    )
end
theme.hotkeys_border_color = '#333333'
return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
