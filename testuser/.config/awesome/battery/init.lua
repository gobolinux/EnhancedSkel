
local battery = {}

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local lfs = require("lfs")
local timer = gears.timer or timer

local lgi = require("lgi")
local cairo = lgi.require("cairo")

local function draw_glow(cr, x, y, w, h, r, g, b, a, rad)
   local glow = cairo.Pattern.create_mesh()
   local function set_colors()
      glow:set_corner_color_rgba(0, r, g, b, a)
      glow:set_corner_color_rgba(1, r, g, b, 0)
      glow:set_corner_color_rgba(2, r, g, b, 0)
      glow:set_corner_color_rgba(3, r, g, b, a)
   end

   -- left   
   glow:begin_patch()
   glow:move_to(x, y)
   glow:line_to(x-rad, y-rad)
   glow:line_to(x-rad, y+h+rad)
   glow:line_to(x, y+h)
   glow:line_to(x, y)
   set_colors()
   glow:end_patch()

   -- top
   glow:begin_patch()
   glow:move_to(x, y)
   glow:line_to(x-rad, y-rad)
   glow:line_to(x+w+rad, y-rad)
   glow:line_to(x+w, y)
   glow:line_to(x, y)
   set_colors()
   glow:end_patch()

   -- right   
   glow:begin_patch()
   glow:move_to(x+w, y)
   glow:line_to(x+w+rad, y-rad)
   glow:line_to(x+w+rad, y+h+rad)
   glow:line_to(x+w, y+h)
   glow:line_to(x+w, y)
   set_colors()
   glow:end_patch()
   
   -- bottom
   glow:begin_patch()
   glow:move_to(x+w, y+h)
   glow:line_to(x+w+rad, y+h+rad)
   glow:line_to(x-rad, y+h+rad)
   glow:line_to(x, y+h)
   glow:line_to(x+w, y+h)
   set_colors()
   glow:end_patch()
   
   cr:set_source(glow)
   cr:paint()
end

local function glow_rectangle(cr, x, y, w, h, r, g, b, a, rad)
   draw_glow(cr, x, y, w, h, r, g, b, a, rad)
   cr:set_source_rgb(r, g, b)
   cr:rectangle(x, y, w, h)
   cr:fill()
end

local function draw_icon(surface, state)
   local cr = cairo.Context(surface)
  
   cr:set_source_rgb(0.5, 0.5, 0.5)
   cr:rectangle(25, 20, 50, 70)
   cr:rectangle(35, 10, 30, 10)
   cr:fill()

   local height = 80 * (state.percent / 100)

   if state.percent < 15 then
      glow_rectangle(cr, 25, 90 - height, 50, height, 1, 0, 0, 0.4, 8)
   else
      if height > 70 then
         local topheight = height - 70
         glow_rectangle(cr, 35, 20 - topheight, 30, topheight, 0, 1, 0.75, 0.3, 8)
         height = 70
      end
      glow_rectangle(cr, 25, 90 - height, 50, height, 0, 1, 0.75, 0.3, 8)
   end
   
   if state.mode == "Charging" then
      cr:set_source_rgb(0, 0, 0)
      cr:move_to(35, 80)
      cr:line_to(45, 55)
      cr:line_to(35, 55)
      cr:line_to(45, 30)
      cr:line_to(65, 30)
      cr:line_to(55, 45)
      cr:line_to(65, 45)
      cr:line_to(35, 80)
      cr:fill()
   end
end

local function update_icon(widget, state)
   local image = cairo.ImageSurface("ARGB32", 100, 100)
   draw_icon(image, state)
   widget:set_image(image)
end

local function update(state)
   local basedir = "/sys/class/power_supply"
   for dir in lfs.dir(basedir) do
      local fd = io.open(basedir.."/"..dir.."/capacity", "r")
      if fd then
         local capacity = tonumber(fd:read("*a"))
         fd:close()
         if capacity then
            state.percent = capacity
         end
         fd = io.open(basedir.."/"..dir.."/status", "r")
         if fd then
            state.mode = fd:read("*l")
            fd:close()
         end
         break
      end
   end
end

function battery.new()
   local widget = wibox.widget.imagebox()
   local state = {
      percent = 0
   }
   local widget_timer = timer({timeout=5})
   widget_timer:connect_signal("timeout", function()
      update(state)
      update_icon(widget, state)
   end)
   widget_timer:start()
   update(state)
   update_icon(widget, state)
   return widget
end

return battery
