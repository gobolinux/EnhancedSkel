
local wifi = {}

local gears = require("gears")
local timer = gears.timer or timer
local mouse = mouse
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local spawn = require("awful.spawn")

local function pread(cmd)
   local pd = io.popen(cmd, "r")
   if not pd then
      return ""
   end
   local data = pd:read("*a")
   pd:close()
   return data
end

local function read_wifi_level()
   local fd = io.open("/proc/net/wireless", "r")
   if fd then
      fd:read("*l")
      fd:read("*l")
      local data = fd:read("*l")
      fd:close()
      if data then
         local value = data:match("^%s*[^%s]+:%s+[^%s]+%s*(%d+)")
         if value then
            return tonumber(value)
         end
      end
   end
end

local function quality_icon(quality)
   if quality >= 75 then
      return beautiful.wifi_3_icon
   elseif quality >= 50 then
      return beautiful.wifi_2_icon
   elseif quality >= 25 then
      return beautiful.wifi_1_icon
   else
      return beautiful.wifi_0_icon
   end
end

local function disconnect()
   awful.util.spawn_with_shell("gobonet disconnect &")
end

local function forget(essid)
   awful.util.spawn_with_shell("gobonet forget '"..essid:gsub("'", "'\\''").."' &")
end

local function compact_entries(entries)
   local limit = 20
   if #entries > limit then
      local submenu = {}
      for i = limit + 1, #entries do
         table.insert(submenu, entries[i])
         entries[i] = nil
      end
      compact_entries(submenu)
      table.insert(entries, { "More...", submenu } )
   end
end

function wifi.new()
   local widget = wibox.widget.imagebox()
   local menu
   local wifi_menu_fn

   local is_scanning = function() return false end
   local is_connecting = function() return false end

   local function animated_operation(cmd, popup_menu)
      local waiting
      local is_waiting = function()
         if not waiting then return false end
         if waiting() ~= true then
            return true
         end
         waiting = nil
         return false
      end
      return function()
         if is_waiting() then
            return is_waiting
         end
         do
            local done = false
            waiting = function()
               return done
            end
            spawn.easy_async(cmd, function()
               done = true
            end)
         end
         local frames = {
            beautiful.wifi_0_icon,
            beautiful.wifi_1_icon,
            beautiful.wifi_2_icon,
            beautiful.wifi_3_icon,
         }
         local step = 1
         local animation_timer = timer({timeout=0.25})
         local function animate()
            if is_waiting() then
               widget:set_image(frames[step])
               step = step + 1
               if step == 5 then step = 1 end
            else
               animation_timer:stop()
               if popup_menu then
                  if menu then
                     menu:hide()
                     menu = nil
                  end
                  wifi_menu_fn(true)
               end
            end
         end
         animation_timer:connect_signal("timeout", animate)
         animation_timer:start()
         return is_waiting
      end
   end

   local rescan = animated_operation("gobonet_backend full-scan wlan0", true)

   local function connect(essid)
      return animated_operation("gobonet connect '"..essid:gsub("'", "'\\''").."'", false)()
   end
   
   local function update()
      if is_scanning() or is_connecting() then
         return
      end
      local wifi_level = read_wifi_level()
      if not wifi_level then
         widget:set_image(beautiful.wifi_down_icon)
      else
         local quality = (tonumber(wifi_level) / 70) * 100
         widget:set_image(quality_icon(quality))
      end
   end
   
   local coords
   wifi_menu_fn = function(auto_popped)
      if not auto_popped then
         coords = mouse.coords()
      end
      if menu then
         if menu.wibox.visible then
            menu:hide()
            menu = nil
            return
         else
            menu = nil
         end
      end
      local iwconfig = pread("iwconfig")
      local my_essid = iwconfig:match('ESSID:"([^\n]*)"%s*\n')
      local scan = ""
      if not is_scanning() then
         scan = pread("gobonet_backend quick-scan wlan0")
      end
      local entries = {}
      local curr_entry
      for key, value in scan:gmatch("%s*([^:=]+)[:=]([^\n]*)\n") do
         if key:match("^Cell ") then
            if curr_entry then
               table.insert(entries, curr_entry)
            end
            curr_entry = { [1] = " " .. value:gsub(" ", "") }
         elseif key == "ESSID" then
            local essid = value:match('^"(.*)"$')
            if essid ~= "" then
               local label = " " .. essid
               curr_entry[1] = label
               curr_entry[2] = function() is_connecting = connect(essid) end
            end
         elseif key == "Quality" then
            local cur, max = value:match("^(%d+)/(%d+)")
            local quality = (tonumber(cur) / tonumber(max)) * 100
            curr_entry.quality = quality
            curr_entry[3] = quality_icon(quality)
         end
      end
      if curr_entry then
         table.insert(entries, curr_entry)
      end
      table.sort(entries, function(a,b) 
         return (a.quality or 0) > (b.quality or 0)
      end)
      if my_essid then
         local disconnect_msg = is_connecting() and " Cancel connecting to " or " Disconnect "
         table.insert(entries, 1, { disconnect_msg .. my_essid, function() disconnect() end })
         table.insert(entries, 2, { " Forget " .. my_essid, function() forget(my_essid) end })
      end
      if is_scanning() then
         table.insert(entries, { " Scanning..." })
      elseif #entries == 0 and not auto_popped then
         table.insert(entries, { " Scanning..." })
         is_scanning = rescan()
      else
         table.insert(entries, { " Rescan", function() is_scanning = rescan() end } )
      end
      local len = 10
      for _, entry in ipairs(entries) do
         len = math.max(len, (#entry[1] + 1) * 10 )
      end
      entries.theme = { height = 24, width = len }
      compact_entries(entries)
      menu = awful.menu.new(entries)
      menu:show({ coords = coords })
   end
   
   widget:buttons(awful.util.table.join(
      awful.button({ }, 1, function() wifi_menu_fn() end ),
      awful.button({ }, 3, function() wifi_menu_fn() end )
   ))
   
   local wifi_timer = timer({timeout=2})
   wifi_timer:connect_signal("timeout", update)
   update()
   wifi_timer:start()
   
   return widget
end

return wifi