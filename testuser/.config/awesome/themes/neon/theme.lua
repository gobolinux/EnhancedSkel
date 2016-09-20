---------------------------------
--  "neon" awesome theme       --
--  by Hisham Muhammad         --
--  <hisham@gobolinux.org>     --
--  based on "zenburn" by      --
--    By Adrian C. (anrxc)     --
---------------------------------

-- {{{ Main
local theme = {}

-- {{{ Wallpaper
--theme.wallpaper = "~/.config/awesome/themes/neon/wallpaper.png"
--theme.wallpaper = "/Data/Wallpapers/TongariroColors.jpg"
theme.wallpaper = function(s)
   if type(s) == "number" then
      s = screen[s]
   elseif not s then
      s = screen.primary
   end
   local cairo = require("lgi").cairo
   local gears = require("gears")
   local height = s.workarea.height
   local width = s.workarea.width
   local img = cairo.RecordingSurface(cairo.Content.COLOR, cairo.Rectangle { x = 0, y = 0, width = width, height = height })
   local cr = cairo.Context(img)
   
   cr:set_source(gears.color("#000000"))
   cr:paint()
   
   cr:set_source(gears.color("#ffffff"))
   cr:set_line_width(width / 720)

   for a = 1, 10 do
      local fac = a / 10

      local rx = math.random(0, width)
      local ry = math.random(0, height)

      local ax = math.random(0, width)
      local ay = math.random(0, height)

      local bx = math.random(0, width)
      local by = math.random(0, height)

      local ln = 75
      for i = 1, ln do
         local pc = i/ln
         cr:set_source_rgb((i - 25) / ln * fac, (ln - i) / ln * fac, (i + 50) / ln * fac)
         --[[
         cr:rectangle(
            10 * i, 10 * i,
            10 * i + 9, 10 * i + 9
         )
         ]]
         cr:stroke()
         --cr:fill()
   
         cr:move_to(rx, ry)
         cr:line_to(ax + (ax - bx) * pc, ay + (ay - by) * pc)
         cr:stroke()
      end   
   
   end

   cr:set_source_rgb(0, 0, 0)
   for i = 1, 256 do
      cr:move_to(0, height / 256 * i)
      cr:line_to(width, height / 256 * i)
      cr:stroke()
   end

   return img

--   return "~/.config/awesome/themes/neon/wallpaper.png"
end
-- }}}

-- {{{ Styles
theme.font          = "Lode Sans 10"

-- {{{ Colors
local topbar_gradient = { type = "linear", from = {0,0}, to = {0,15}, stops = { {0, "#1F373F"}, {1, "#0F171F"} } }

theme.fg_normal  = "#668888"
theme.fg_focus   = "#00FFFF"
theme.fg_urgent  = "#CC9393"
theme.bg_normal  = topbar_gradient -- "#2F3F3F"
theme.bg_focus   = "#000000"
theme.bg_urgent  = "#2F3F3F"
theme.bg_systray = topbar_gradient --theme.bg_normal
-- }}}

-- {{{ Borders
theme.border_width  = 2
theme.border_normal = "#2F3F3F"
theme.border_focus  = "#00FFFF"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = { type = "linear", from = {0,0}, to = {0,16}, stops = { {0, "#002525c0"}, {1, "#060606c0"} } }
theme.titlebar_bg_normal = { type = "linear", from = {0,0}, to = {0,16}, stops = { {0, "#002525c0"}, {1, "#060606c0"} } }
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
theme.tasklist_bg_focus = { type = "linear", from = {0,15}, to = {0,40}, stops = { {0, "#001010"}, {1, "#0FB7BF"} } }


theme.tasklist_bg_normal = topbar_gradient
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_fg_normal = "#779999"
theme.menu_bg_normal = "#2F3F3F70"
theme.menu_height = 15
theme.menu_width  = 100
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = "~/.config/awesome/themes/neon/taglist/squarefz.png"
theme.taglist_squares_unsel = "~/.config/awesome/themes/neon/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = "~/.config/awesome/themes/neon/awesome-icon.png"
theme.menu_submenu_icon      = "~/.config/awesome/themes/neon/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = "~/.config/awesome/themes/neon/layouts/tile.png"
theme.layout_tileleft   = "~/.config/awesome/themes/neon/layouts/tileleft.png"
theme.layout_tilebottom = "~/.config/awesome/themes/neon/layouts/tilebottom.png"
theme.layout_tiletop    = "~/.config/awesome/themes/neon/layouts/tiletop.png"
theme.layout_fairv      = "~/.config/awesome/themes/neon/layouts/fairv.png"
theme.layout_fairh      = "~/.config/awesome/themes/neon/layouts/fairh.png"
theme.layout_spiral     = "~/.config/awesome/themes/neon/layouts/spiral.png"
theme.layout_dwindle    = "~/.config/awesome/themes/neon/layouts/dwindle.png"
theme.layout_max        = "~/.config/awesome/themes/neon/layouts/max.png"
theme.layout_fullscreen = "~/.config/awesome/themes/neon/layouts/fullscreen.png"
theme.layout_magnifier  = "~/.config/awesome/themes/neon/layouts/magnifier.png"
theme.layout_floating   = "~/.config/awesome/themes/neon/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_hover  = "~/.config/awesome/themes/neon/titlebar/close_hover.png"
theme.titlebar_close_button_focus  = "~/.config/awesome/themes/neon/titlebar/close_focus.png"
theme.titlebar_close_button_normal = "~/.config/awesome/themes/neon/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = "~/.config/awesome/themes/neon/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = "~/.config/awesome/themes/neon/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = "~/.config/awesome/themes/neon/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = "~/.config/awesome/themes/neon/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = "~/.config/awesome/themes/neon/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = "~/.config/awesome/themes/neon/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = "~/.config/awesome/themes/neon/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = "~/.config/awesome/themes/neon/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = "~/.config/awesome/themes/neon/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = "~/.config/awesome/themes/neon/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = "~/.config/awesome/themes/neon/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = "~/.config/awesome/themes/neon/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_hover = "~/.config/awesome/themes/neon/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_focus_active  = "~/.config/awesome/themes/neon/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = "~/.config/awesome/themes/neon/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = "~/.config/awesome/themes/neon/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = "~/.config/awesome/themes/neon/titlebar/maximized_normal_inactive.png"

theme.titlebar_minimize_button_hover  = "~/.config/awesome/themes/neon/titlebar/minimize_hover.png"
theme.titlebar_minimize_button_focus_active  = "~/.config/awesome/themes/neon/titlebar/minimize_focus.png"
theme.titlebar_minimize_button_normal_active = "~/.config/awesome/themes/neon/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus_inactive  = "~/.config/awesome/themes/neon/titlebar/minimize_focus.png"
theme.titlebar_minimize_button_normal_inactive = "~/.config/awesome/themes/neon/titlebar/minimize_normal.png"

--[[
-- for Awesome 3.6/git:
theme.titlebar_minimize_button_hover  = "~/.config/awesome/themes/neon/titlebar/minimize_hover.png"
theme.titlebar_minimize_button_focus  = "~/.config/awesome/themes/neon/titlebar/minimize_focus.png"
theme.titlebar_minimize_button_normal = "~/.config/awesome/themes/neon/titlebar/minimize_normal.png"

-- for Awesome 3.5:
theme.titlebar_minimize_button_focus_active = theme.titlebar_minimize_button_focus
theme.titlebar_minimize_button_focus_inactive = theme.titlebar_minimize_button_focus
theme.titlebar_minimize_button_normal_active = theme.titlebar_minimize_button_normal
theme.titlebar_minimize_button_normal_inactive = theme.titlebar_minimize_button_normal
]]
-- }}}


theme.wifi_up_icon           = "~/.config/awesome/themes/neon/wifi_up.png"
theme.wifi_3_icon           = "~/.config/awesome/themes/neon/wifi_3.png"
theme.wifi_2_icon           = "~/.config/awesome/themes/neon/wifi_2.png"
theme.wifi_1_icon           = "~/.config/awesome/themes/neon/wifi_1.png"
theme.wifi_0_icon           = "~/.config/awesome/themes/neon/wifi_0.png"
theme.wifi_down_icon         = "~/.config/awesome/themes/neon/wifi_down.png"

-- }}}

return theme
