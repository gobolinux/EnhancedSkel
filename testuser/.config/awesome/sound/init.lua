
local sound = {}

local icon_theme = require("menubar.icon_theme")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local timer = gears.timer or timer
local naughty = require("naughty")
local lgi = require("lgi")
local cairo = lgi.require("cairo")

local icons = icon_theme.new()

local function pread(cmd)
   local pd = io.popen(cmd, "r")
   if not pd then
      return ""
   end
   local data = pd:read("*a")
   pd:close()
   return data
end

local function update_state(state, output)
   local volume = output:match("%[([0-9.,]*)%%%]")
   local mute = output:match("%[([onf]*)%]")
   if not (volume and mute) then
      state.valid = false
      return
   end
   state.valid = true
   state.volume = tonumber(volume)
   state.mute = (mute == "off")
end

local function set_volume(state, config, val, delta)
   local setting = val.."%"..delta
   update_state(state, pread("amixer -M -c "..config.card.." -- set '"..config.channel.."' playback "..setting))
end

local function set_volume(state, config, val, delta)
   local setting = val.."%"..delta
   update_state(state, pread("amixer -M -c "..config.card.." -- set '"..config.channel.."' playback "..setting))
end


local function toggle_mute(state, config)
   local setting = state.mute and "on" or "off"
   update_state(state, pread("amixer -M -c "..config.card.." -- set '"..config.channel.."' mute "..setting))
end

local function update(state, config)
   update_state(state, pread("amixer -M -c "..config.card.." -- get '"..config.channel.."' playback"))
end

local function draw_handle(surface, volume)
   local cr = cairo.Context(surface)
   local ctm = cr:get_matrix()
   local r = volume < 50 and ((50 - volume) / 50) * -135
                                or ((volume - 50) / 50) * 135
   cr:set_source_rgb(0.2, 0.2, 0.2)
   cr:translate(65, 50)
   cr:rotate(math.rad(r))
   local px, py = 0, -15
   local pat = cairo.Pattern.create_radial(px, py, 0, px, py, 30)
   pat:add_color_stop_rgb(0, 0.2, 0.2, 0.2)
   pat:add_color_stop_rgb(1, 0.6, 0.6, 0.6)
   cr:set_source(pat)
   cr:rotate(math.rad(-r))
   cr:translate(-15, 0)
   cr:rotate(math.rad(r))
   cr:arc(0, -15, 10, 0, math.rad(360))
   cr:set_matrix(ctm)
   cr:fill()
end

local function draw_lights(surface, state)
   local cr = cairo.Context(surface)

   local ctm = cr:get_matrix()

   cr:translate(50, 50)
   cr:rotate(math.rad(-90))
   
   local stop = state.mute and 100 or state.volume
   local r = stop < 50 and ((50 - stop) / 50) * -135
                                or ((stop - 50) / 50) * 135

   cr:set_line_width(5)
   if state.mute == true then
      cr:set_source_rgb(1, 0, 0)
   else
      cr:set_source_rgb(0, 0.4, 0.4)
      cr:arc(0, 0, 42, math.rad(-135), math.rad(135))
      cr:stroke()
      cr:set_source_rgb(0, 1, 1)
   end
   cr:arc(0, 0, 42, math.rad(-135), math.rad(r))
   cr:stroke()

   cr:set_matrix(ctm)

   --[[
   for i = 0, 11 do -- it goes to eleven!
      local stop = 99 / 11 * i
      local r = stop < 50 and ((50 - stop) / 50) * -135
                                   or ((stop - 50) / 50) * 135

      local ctm = cr:get_matrix()
      cr:translate(50, 50)
      cr:rotate(math.rad(r))

      if state.mute == true then
         cr:set_source_rgb(1, 0, 0)
      elseif state.volume > stop then
         cr:set_source_rgb(0, 1, 1)
      else
         cr:set_source_rgb(0, 0.1, 0.1)
      end
      cr:arc(0, -40, 4, 0, math.rad(360))
      cr:set_matrix(ctm)
      cr:fill()
      
   end
   ]]
end

local function draw_icon(surface, state)

   local cr = cairo.Context(surface)

   local px, py = 0, 50
   local pat = cairo.Pattern.create_radial(px, py, 0, px, py, 100)
   pat:add_color_stop_rgb(0, 0.2, 0.2, 0.2)
   pat:add_color_stop_rgb(1, 0.6, 0.6, 0.6)
   cr:set_source(pat)
   cr:arc(50, 50, 30, 0, math.rad(360))
   cr:fill()

   draw_lights(surface, state)
   
   draw_handle(surface, state.volume)

end

local function update_icon(widget, state)
   local image = cairo.ImageSurface("ARGB32", 100, 100)
   draw_icon(image, state)
   widget:set_image(image)
end

function sound.new(card, channel)
   local widget = wibox.widget.imagebox()
   local config = {
      card = card or 0,
      channel = channel or "Master"
   }
   local state = {
      valid = false,
      volume = 0,
      mute = false
   }
   local widget_timer = timer({timeout=5})
   widget_timer:connect_signal("timeout", function()
      update(state, config)
      update_icon(widget, state)
   end)
   widget_timer:start()
   widget:buttons(awful.util.table.join(
      awful.button({ }, 1, function()
         toggle_mute(state, config)
         update_icon(widget, state)
      end),
      awful.button({ }, 4, function()
         set_volume(state, config, 5, "-")
         update_icon(widget, state)
      end),
      awful.button({ }, 5, function()
         set_volume(state, config, 5, "+")
         update_icon(widget, state)
      end)
   ))
   update(state, config)
   update_icon(widget, state)
   return widget
end

return sound

