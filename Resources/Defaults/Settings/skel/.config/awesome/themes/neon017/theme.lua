---------------------------------
--  "neon" awesome theme       --
--  by Hisham Muhammad         --
--  <hisham@gobolinux.org>     --
--  based on "zenburn" by      --
--    By Adrian C. (anrxc)     --
---------------------------------

-- {{{ Main
local theme = {}

local SCANLINES = true

math.randomseed(os.time())

local naughty = require("naughty")

local function pre_calculate(width, height, count, step, h, lines)
   local bh = height * (0.25 + math.random()/2)

   local terrain = {}
   do
      local d = math.random(2,5)
      local sy = 0
      for i = 1, count do
         if math.random() > 0.75 then
            d = d * -1
         end
         sy = sy + (d * (1.5 - math.random()))
         terrain[i] = sy
      end
   end

   local d = math.random(2,5)
   local sx = 0

   local grid = {}
   for l = 1, lines do
      if math.random() > 0.75 then
         d = d * -1
      end
      sx = sx + (d * (1.5 - math.random()))

      grid[l] = {}
      local s = (width / 2) - (step * count / 2)
      for i = 1, count do
         grid[l][i] = { x = s + i * step, y = bh + l * h - (terrain[i] * sx) }
      end
      h = h * 1.2
      step = step * 1.2
   end
   
   return grid
end

local function draw_line(cr, grid, lw, r, g, b, count, l)
   cr:set_line_width(lw)
   local gs = l / 19 * 2
   lw = lw * 1.2
   for i = 1, count - 1 do
      cr:set_source_rgba(gs/(1.9 + r), gs * ((1-(i/count))+g), gs *2 * (i/count + b), 0.2)
      local x1 = grid[l][i]
      local x2 = grid[l][i+1]
      local y1 = grid[l+1][i]
      local y2 = grid[l+1][i+1]
      cr:move_to(x1.x, x1.y)
      cr:line_to(x2.x, x2.y)
      cr:line_to(y2.x, y2.y)
      cr:line_to(y1.x, y1.y)
      cr:move_to(x1.x, x1.y)
      cr:fill()
      cr:set_source_rgb(gs/(1.9 + r), gs * ((1-(i/count))+g), gs*2 * (i/count + b))
      cr:move_to(x1.x, x1.y)
      cr:line_to(x2.x, x2.y)
      cr:line_to(y2.x, y2.y)
      cr:line_to(y1.x, y1.y)
      cr:move_to(x1.x, x1.y)
      cr:stroke()
   end
   return lw
end

-- {{{ Wallpaper
--theme.wallpaper = "~/.config/awesome/themes/neon/wallpaper.png"
--theme.wallpaper = "/Data/Wallpapers/TongariroColors.jpg"
local anim_reset = 0
theme.animated_wallpaper = function()
   
   anim_reset = anim_reset + 1

   for s = 1, screen.count() do
      
      local cairo = require("lgi").cairo
      local gears = require("gears")
      local wallpaper = require("gears.wallpaper")
      local timer = gears.timer or timer
      
      local width = screen[s].geometry.width
      local height = screen[s].geometry.height
      
      local scanlines
      if SCANLINES then
         scanlines = cairo.ImageSurface("RGB32", width, height)
         local scr = cairo.Context(scanlines)
         scr:set_line_width(width / 720)
         scr:set_source_rgb(0, 0, 0)
         for i = 1, 256 do
            scr:move_to(0, height / 256 * i)
            scr:line_to(width, height / 256 * i)
         end
         scr:stroke()
      end

      local count = width / 32  -- for 1920 == 60
      local step = width / 48   -- for 1920 == 40
      local h = height / 108    -- for 1080 == 10
      local lines = height / 54 -- for 1080 == 20
      local grid = pre_calculate(width, height, count, step, h, lines)

      local r = math.random()*0.1
      local g = math.random()*0.5
      local b = math.random()*0.2
  
      local anim = timer({timeout=0.1})
      local anim_id = anim_reset

      local l = 1

      anim:connect_signal("timeout", function()

         local geom, wcr = wallpaper.prepare_context(screen[s])
   
         wcr:set_source_rgb(0,0,0)
         wcr.operator = cairo.Operator.SOURCE
         wcr:paint()
         wcr.operator = cairo.Operator.OVER

         local lw = width / 720 / 2
         for i = 1, l do
            lw = draw_line(wcr, grid, lw, r, g, b, count, i)
         end
         
         if SCANLINES then
            wcr:set_source_surface(scanlines, 0, 0)
            wcr:paint()
         end
         
         l = l + 1
   
         if l >= lines - 1 or anim_id ~= anim_reset then
            anim:stop()
         end
         
      end)
      anim:start()
   end

   --img:finish()
end
-- }}}

local function dot(cr, x, y, sz)
   sz = sz or 5
   cr:move_to(x, y)
   cr:line_to(x + sz, y)
   cr:line_to(x + sz, y + sz)
   cr:line_to(x, y + sz)
   cr:move_to(x, y)
   cr:fill()
end

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
   local height = s.geometry.height
   local width = s.geometry.width
   local img = cairo.RecordingSurface(cairo.Content.COLOR, cairo.Rectangle { x = 0, y = 0, width = width, height = height })
   local cr = cairo.Context(img)
   
   cr:set_source(gears.color("#000000"))
   cr:paint()

   local count = 60
   local step = 40
   local h = 10
   local lines = 20
   local grid = pre_calculate(width, height, count, step, h, lines)

   local lw = width / 720 / 2
   local r = math.random()*0.1
   local g = math.random()*0.5
   local b = math.random()*0.2
   for l = 1, 19 do
      lw = draw_line(cr, grid, lw, r, g, b, count, l)
   end

   cr:set_line_width(width / 720)
   cr:set_source_rgb(0, 0, 0)
   for i = 1, 256 do
      cr:move_to(0, height / 256 * i)
      cr:line_to(width, height / 256 * i)
   end
   cr:stroke()

   return img
end
-- }}}

-- {{{ Styles
theme.font          = "xft:Lode Sans 10"
naughty.config.defaults.font = "sans 10"
naughty.config.presets.critical.bg = { type = "linear", from = {0,0}, to = {0,35}, stops = { {0, "#FF0000"}, {1, "#770000"} } }
naughty.config.defaults.fg = "#97b9b9"

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
theme.menu_bg_normal = "#2F3F3F90"
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
theme.wired_up_icon         = "~/.config/awesome/themes/neon/wired_up.png"
theme.wired_down_icon         = "~/.config/awesome/themes/neon/wired_down.png"

theme.check_icon       = "~/.config/awesome/themes/neon/check.png"

-- }}}

theme[1] = theme
return theme
