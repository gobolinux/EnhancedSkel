--
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local gobonet = require("gobo.awesome.gobonet")
local sound = require("gobo.awesome.sound")
local battery = require("gobo.awesome.battery")
local alttab = require("gobo.awesome.alttab")
local docking = require("gobo.awesome.docking")
local light = require("gobo.awesome.light")
local bluetooth = require("gobo.awesome.bluetooth")
local window_menu = require("gobo.awesome.window_menu")
local menu_gen = require("menubar.menu_gen")
local icon_theme = require("menubar.icon_theme")
local hotkeys_popup = require("awful.hotkeys_popup.widget")

-- C API
local screen = screen
local mouse = mouse
local client = client
local awesome = awesome
local root = root

local terminal = "urxvt"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor
local browser = "firefox"

local titlebars_enabled = true
local sloppy_focus = false

local light_widget = light.new()
local sound_widget = sound.new()
sound_widget.terminal = terminal

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init("~/.config/awesome/themes/neon017/theme.lua")

awful.titlebar.enable_tooltip = false
hotkeys_popup.title_font = "Lode Sans Mono Bold 12"
hotkeys_popup.description_font = "Lode Sans Mono 12"
hotkeys_popup.group_margin = 20

-- Variable definitions
-- Themes define colors, icons, font and wallpapers.

local ALT = "Mod1"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end


-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function(err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true
      naughty.notify({ preset = naughty.config.presets.critical,
                       title = "Oops, an error happened!",
                       text = err })
      in_error = false
   end)
end

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.fair.horizontal,
   awful.layout.suit.spiral,
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier
}

-- Wallpaper
if beautiful.animated_wallpaper then
   local wallpaper = require("gears.wallpaper")
   local cairo = require("lgi").cairo
   for s = 1, screen.count() do
      local geom, wcr = wallpaper.prepare_context(screen[s])
      wcr:set_source_rgb(0,0,0)
      wcr.operator = cairo.Operator.SOURCE
      wcr:paint()
   end
   
   local anim = gears.timer({timeout=0.5})
   anim:connect_signal("timeout", function()
      for s = 1, screen.count() do
         beautiful.animated_wallpaper(s)
      end
      anim:stop()
   end)
   anim:start()
elseif beautiful.wallpaper then
   local wallpaper = beautiful.wallpaper
   for s = 1, screen.count() do
      if type(wallpaper) == "function" then
         gears.wallpaper.maximized(wallpaper(s), s, true)
      else
         gears.wallpaper.maximized(wallpaper, s, true)
      end
   end
end

-- Tags
-- Define a tag table which hold all screen tags.
local tags = {}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end

local function show_help()
   local save_bg_normal = beautiful.bg_normal
   beautiful.bg_normal = "#000000"
   hotkeys_popup.show_help()
   beautiful.bg_normal = save_bg_normal
end

local function layout_fn(mode) return function() awful.layout.set(mode) end end

local function regenerate_wallpaper()
   for s = 1, screen.count() do
      beautiful.animated_wallpaper(s)
   end
end

-- Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
   { "Window control mode", {
      { "Floating windows", layout_fn(awful.layout.suit.floating), beautiful.layout_floating },
      { "Tiled", layout_fn(awful.layout.suit.tile), beautiful.layout_tile },
      { "Tiled left", layout_fn(awful.layout.suit.tile.left), beautiful.layout_tileleft },
      { "Tiled bottom", layout_fn(awful.layout.suit.tile.bottom), beautiful.layout_tilebottom },
      { "Tiled top", layout_fn(awful.layout.suit.tile.top), beautiful.layout_tiletop },
      { "Fair vertical", layout_fn(awful.layout.suit.fair), beautiful.layout_fairv },
      { "Fair horizontal", layout_fn(awful.layout.suit.fair.horizontal), beautiful.layout_fairh },
      { "Spiral", layout_fn(awful.layout.suit.spiral), beautiful.layout_spiral },
      { "Dwindle", layout_fn(awful.layout.suit.spiral.dwindle), beautiful.layout_dwindle },
      { "All windows maximized", layout_fn(awful.layout.suit.max), beautiful.layout_max },
      { "Full screen", layout_fn(awful.layout.suit.max.fullscreen), beautiful.layout_fullscreen },
      { "Magnifier", layout_fn(awful.layout.suit.magnifier), beautiful.layout_magnifier }}},
   { "Hotkeys", function() return false, show_help end},
   { "Manual", terminal .. " -e pinfo awesome" },
   { "Edit Config", editor_cmd .. " " .. awesome.conffile },
   { "Regenerate Wallpaper", regenerate_wallpaper },
   { "Restart Awesome", awesome.restart },
   { "Quit", function() awesome.quit() end }
}

local mymainmenu = awful.menu({
   items = awful.util.table.join({
      { "Awesome WM", myawesomemenu, beautiful.awesome_icon },
      { "Run...", function() menubar.show() end, nil },
      { "Open Terminal", terminal }
   }),
   theme = { width = 300, height = 32 },
})

menu_gen.generate(function(entries)
   local cat_keys = {}
   local cat_submenus = {}

   for k, _ in pairs(menu_gen.all_categories) do
      table.insert(cat_keys, k)
      cat_submenus[k] = {}
   end

   for _, entry in ipairs(entries) do
      if entry.category ~= nil and entry.name ~= nil and entry.cmdline ~= nil and entry.icon ~= nil then
         table.insert(cat_submenus[entry.category], { entry.name, entry.cmdline, entry.icon })
      end
   end
   table.sort(cat_keys)
   for _, k in ipairs(cat_keys) do
      if #cat_submenus[k] > 0 then
         local cat = menu_gen.all_categories[k]
         mymainmenu:add({ cat.name, cat_submenus[k], icon_theme():find_icon_path(cat.icon_name) })
      end
   end
end)

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Wibox
-- Create a textclock widget
local mytextclock = wibox.widget.textclock(nil, 5)

-- Create a wibox for each screen and add it
local mywibox = {}
local mypromptbox = {}
--mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({}, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({}, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({}, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({}, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
local mytasklist = {}
local clients_menu
mytasklist.buttons = awful.util.table.join(
   awful.button({}, 1, function(c)
      if clients_menu then
         clients_menu:hide()
         clients_menu = nil
      end
      if c == client.focus then
         c.minimized = true
      else
         -- Without this, the following
         -- :isvisible() makes no sense
         c.minimized = false
         if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
         end
         -- This will also un-minimize
         -- the client, if needed
         client.focus = c
         c:raise()
      end
   end),
   awful.button({}, 3, function()
      if clients_menu then
         clients_menu:hide()
         clients_menu = nil
      else
         clients_menu = awful.menu.clients({
            theme = { width = 250, height = 24 }
         })
      end
   end)
)

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   --[[
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
   awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
   awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
   awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
   awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))
   ]]
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
   
   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
   
   -- Create the wibox
   mywibox[s] = awful.wibar({ position = "top", screen = s })
   
   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mylauncher)
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])
   
   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   if s == 1 then
      right_layout:add(wibox.widget.systray())
      right_layout:add(bluetooth.new())
      right_layout:add(gobonet.new())
      right_layout:add(battery.new())
      right_layout:add(light_widget)
      right_layout:add(sound_widget)
   end
   right_layout:add(mytextclock)
   --right_layout:add(mylayoutbox[s])
   
   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)
   
   mywibox[s]:set_widget(layout)
end


-- Mouse bindings
root.buttons(awful.util.table.join(
   awful.button({}, 1, function() mymainmenu:hide() end),
   awful.button({}, 3, function() mymainmenu:toggle() end)
   --awful.button({}, 4, awful.tag.viewnext),
   --awful.button({}, 5, awful.tag.viewprev)
))

local function screenshot()
   local name = os.getenv("HOME") .. "/screenshot-" .. os.date("%Y-%m-%d-%H-%M-%S") .. ".png"
   os.execute("import "..name.."; cat "..name.." | xclip -i -selection clipboard -t image/png")
   naughty.notify({ preset = naughty.config.presets.normal,
                    title = "Screen captured",
                    text = "Screenshot saved to"..name})
end

-- Key bindings
local globalkeys = awful.util.table.join(

   awful.key({}, "Print",
      screenshot,
      { description = "Screenshot", group = "awesome gobolinux" }),

   awful.key({ modkey }, "s",
      show_help,
      { description = "Show hotkeys", group = "awesome" }),

   awful.key({ modkey }, ",",
      awful.tag.viewprev,
      { description = "View previous", group = "tag" }),

   awful.key({ modkey }, ".",
      awful.tag.viewnext,
      { description = "View next", group = "tag" }),

   awful.key({ modkey }, "Escape",
      awful.tag.history.restore,
      { description = "Go back", group = "tag" }),

   awful.key({ modkey }, "j",
      function()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
      end,
      { description = "Focus previous by index", group = "client" }),

   awful.key({ modkey }, "k",
      function()
         awful.client.focus.byidx(1)
         if client.focus then client.focus:raise() end
      end,
      { description = "Focus next by index", group = "client" }),

   awful.key({ modkey }, "w",
      function()
         mymainmenu:show()
      end,
      { description = "Show main menu", group = "awesome" }),

   -- Layout manipulation
   awful.key({ modkey, "Shift" }, "j",
      function()
         awful.client.swap.byidx(1) 
      end,
      { description = "Swap with next client by index", group = "client" }),

   awful.key({ modkey, "Shift" }, "k",
      function()
         awful.client.swap.byidx(-1)
      end,
      { description = "Swap with previous client by index", group = "client" }),
   
   awful.key({ modkey, "Control" }, "j",
      function()
         awful.screen.focus_relative(1)
      end,
      { description = "Focus the next screen", group = "screen" }),
   
   awful.key({ modkey, "Control" }, "k",
      function() 
         awful.screen.focus_relative(-1)
      end,
      { description = "Focus the previous screen", group = "screen" }),
   
   awful.key({ modkey }, "u",
      awful.client.urgent.jumpto,
      { description = "Jump to urgent client", group = "client" }),

   awful.key({ modkey }, "Tab",
      function()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end,
      { description = "Go back to previous client", group = "client" }),

   -- Standard program
   awful.key({ modkey }, "Return",
      function()
         awful.spawn(terminal)
      end,
      { description = "Open a terminal", group = "launcher" }),

   awful.key({ modkey, "Shift" }, "Return",
      function()
         awful.util.spawn(browser)
      end,
      { description = "Open a browser", group = "launcher" }),

   awful.key({ modkey, "Control" }, "r",
      awesome.restart,
      { description = "Reload Awesome", group = "awesome" }),

   awful.key({ modkey, "Shift" }, "q",
      awesome.quit,
      { description = "Quit Awesome", group = "awesome" }),

   awful.key({ modkey }, "a",
      regenerate_wallpaper,
      { description = "Regenerate GoboLinux wallpaper", group = "awesome gobolinux" }),

   awful.key({ modkey }, "l",
      function()
         awful.tag.incmwfact(0.05)
      end,
      { description = "Increase master width factor", group = "layout" }),

   awful.key({ modkey }, "h",
      function()
         awful.tag.incmwfact(-0.05)
      end,
      { description = "Decrease master width factor", group = "layout" }),

   awful.key({ modkey, "Shift" }, "h",
      function()
         awful.tag.incnmaster( 1, nil, true)
      end,
      { description = "Increase the number of master clients", group = "layout" }),

   awful.key({ modkey, "Shift" }, "l",
      function()
         awful.tag.incnmaster(-1, nil, true)
      end,
      { description = "Decrease the number of master clients", group = "layout" }),

   awful.key({ modkey, "Control" }, "h",
      function()
         awful.tag.incncol( 1, nil, true)
      end,
      { description = "Increase the number of columns", group = "layout" }),

   awful.key({ modkey, "Control" }, "l",
      function()
         awful.tag.incncol(-1, nil, true)
      end,
      { description = "Decrease the number of columns", group = "layout" }),

   awful.key({ modkey }, "space",
      function()
         awful.layout.inc(layouts, 1)
      end,
      { description = "Select next", group = "layout" }),

   awful.key({ modkey, "Shift" }, "space",
      function()
         awful.layout.inc(layouts, -1)
      end,
      { description = "Select previous", group = "layout" }),

   awful.key({ modkey, "Control" }, "n",
      function()
         local c = awful.client.restore()
         -- Focus restored client
         if c then
            client.focus = c
            c:raise()
         end
      end,
      { description = "Restore minimized", group = "client" }),

   -- Prompt
   awful.key({ modkey }, "r",
      function()
         menubar.show()
      end,
      { description = "Show the menubar", group = "awesome gobolinux" }),

   awful.key({ ALT }, "F2",
      function()
         menubar.show()
      end,
      { description = "Show the menubar", group = "awesome gobolinux" }),

   --[[
   awful.key({ modkey }, "x",
      function()
         awful.prompt.run({ prompt = "Run Lua code: " },
         mypromptbox[mouse.screen].widget,
         awful.util.eval, nil,
         awful.util.getdir("cache") .. "/history_eval")
      end
      { description = "Run Lua code", group = "awesome" }),
   ]]

   -- Menubar
   awful.key({ modkey }, "p",
      function() menubar.show() end,
      { description = "Show the menubar", group = "launcher" }),

   -- Switch windows
   awful.key({ ALT, }, "Tab",
      function()
         alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
      end,
      { description = "Switch between windows", group = "awesome gobolinux" }),
   
   awful.key({ ALT, "Shift" }, "Tab",
      function()
         alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
      end,
      { description = "Switch between windows backwards", group = "awesome gobolinux" }),

   -- Multimedia keys    
   awful.key({}, "XF86HomePage",
      function()
         awful.util.spawn(browser)
      end,
      { description = "Open a browser", group = "multimedia" }),
   
   awful.key({}, "XF86AudioRaiseVolume",
      function()
         sound_widget:set_volume(5, "+")
      end,
      { description = "Raise audio volume", group = "multimedia" }),
   
   awful.key({}, "XF86AudioLowerVolume",
      function()
         sound_widget:set_volume(5, "-") 
      end,
      { description = "Lower audio volume", group = "multimedia" }),
   
   awful.key({}, "XF86AudioMute",
      function() 
         sound_widget:toggle_mute() 
      end,
      { description = "Toggle mute", group = "multimedia" }),
   
   awful.key({}, "XF86MonBrightnessDown", function() light_widget:dec_brightness(5) end,
      { description = "Lower screen brightness", group = "multimedia" }
   ),
   
   awful.key({}, "XF86MonBrightnessUp", function() light_widget:inc_brightness(5) end,
      { description = "Raise screen brightness", group = "multimedia" }
   )
)

local delta = 64

local clientkeys = awful.util.table.join(

   awful.key({ modkey }, "f",
      function(c)
         c.fullscreen = not c.fullscreen
      end,
      { description = "Toggle fullscreen", group = "client" }),
   
   awful.key({ modkey, "Shift" }, "c",
      function(c)
         c:kill()
      end,
      { description = "Close", group = "client" }),
   
   awful.key({ modkey, "Control" }, "space",
      awful.client.floating.toggle,
      { description = "Window always floating", group = "client" }),

   awful.key({ modkey, "Control" }, "Return",
      function(c)
         c:swap(awful.client.getmaster())
      end,
      { description = "Move to master", group = "client" }),

   awful.key({ modkey }, "o",
      function(c)
         c:move_to_screen() 
      end,
      { description = "Move to screen", group = "client" }),

   awful.key({ modkey }, "t",
      function(c)
         c.ontop = not c.ontop
      end,
      { description = "Toggle always-on-top", group = "client" }),

   awful.key({ modkey }, "n",
      function(c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end,
      { description = "Minimize", group = "client" }),

   awful.key({ modkey }, "m",
      function(c)
         c.maximized_vertical   = not c.maximized_vertical
         c.maximized_horizontal = not c.maximized_horizontal
      end,
      { description = "Maximize", group = "client" }),

   awful.key({ ALT }, "F4",
      function(c)
         window_menu.hide(c)
         c:kill()
      end,
      { description = "Close", group = "client" }),

   awful.key({ ALT }, "space",
      function(c)
         local geo = c:geometry()
         window_menu.show(c, { coords = { x = geo.x, y = geo.y } })
      end,
      { description = "Open window menu", group = "client" }),

   docking.move_key("vertical",   -delta, { modkey, ALT }, "Up"),
   docking.move_key("vertical",    delta, { modkey, ALT }, "Down"),
   docking.move_key("horizontal", -delta, { modkey, ALT }, "Left"),
   docking.move_key("horizontal",  delta, { modkey, ALT }, "Right"),

   docking.resize_key("vertical",   -delta, { modkey, ALT, "Ctrl" }, "Up"),
   docking.resize_key("vertical",    delta, { modkey, ALT, "Ctrl" }, "Down"),
   docking.resize_key("horizontal", -delta, { modkey, ALT, "Ctrl" }, "Left"),
   docking.resize_key("horizontal",  delta, { modkey, ALT, "Ctrl" }, "Right"),

   docking.corner_key("top",    "left",  { modkey }, "KP_Home"),
   docking.corner_key("top",    "right", { modkey }, "KP_Prior"),
   docking.corner_key("bottom", "left",  { modkey }, "KP_End"),
   docking.corner_key("bottom", "right", { modkey }, "KP_Next"),

   awful.key({ modkey }, "KP_Left",  docking.dock_left),
   awful.key({ modkey }, "KP_Right", docking.dock_right),
   awful.key({ modkey }, "KP_Up",    docking.dock_up),
   awful.key({ modkey }, "KP_Down",  docking.dock_down),

   awful.key({ modkey }, "Left",  docking.dock_left,  { description = "Dock / move docked window", group = "awesome gobolinux" }),
   awful.key({ modkey }, "Right", docking.dock_right, { description = "Dock / move docked window", group = "awesome gobolinux" }),
   awful.key({ modkey }, "Up",    docking.dock_up,    { description = "Dock / move docked window", group = "awesome gobolinux" }),
   awful.key({ modkey }, "Down",  docking.dock_down,  { description = "Dock / move docked window", group = "awesome gobolinux" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 4.
for i = 1, 4 do
   globalkeys = awful.util.table.join(globalkeys,

   awful.key({ modkey }, "#" .. i + 9,
      function()
         local screen = mouse.screen
         local tag = awful.tag.gettags(screen)[i]
         if tag then
            awful.tag.viewonly(tag)
         end
      end,
      { description = "View tag #"..i, group = "tag" }),

   awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
         local screen = mouse.screen
         local tag = awful.tag.gettags(screen)[i]
         if tag then
            awful.tag.viewtoggle(tag)
         end
      end,
      { description = "Toggle tag #" .. i, group = "tag" }),

   awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
         if client.focus then
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if tag then
               awful.client.movetotag(tag)
            end
         end
      end,
      { description = "Move focused client to tag #"..i, group = "tag" }),

   awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
         if client.focus then
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if tag then
               awful.client.toggletag(tag)
            end
         end
      end,
      { description = "Toggle focused client on tag #" .. i, group = "tag" }))
end

local clientbuttons = awful.util.table.join(

   awful.button({}, 1,
      function(c)
         client.focus = c
         c:raise()
      end),

   awful.button({ ALT }, 1,
      function(c) client.focus = c
         c:raise()
         docking.smart_mouse_move(c)
      end),

   awful.button({ "Control", ALT }, 1, 
      function(c) client.focus = c
         c:raise()
         awful.mouse.client.resize(c)
      end),

   awful.button({ ALT }, 3, 
      function(c) 
         client.focus = c
         c:raise()
         awful.mouse.client.resize(c)
      end)
)

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).

local default_properties = {
   border_width = beautiful.border_width,
   focus = awful.client.focus.filter,
   raise = true,
   keys = clientkeys,
   screen = awful.screen.focused,
   buttons = clientbuttons
}

awful.rules.rules = {
   { rule = {}, properties = default_properties },  -- All clients will match this rule.
   { rule = { class = "MPlayer" }, properties = { floating = true } },
   { rule = { class = "pinentry" }, properties = { floating = true } },
   { rule = { class = "gimp" }, properties = { floating = true } },
   -- Add titlebars to normal clients and dialogs
   { rule_any = {type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },
}

local no_decorations = {
    ["plugin-container"] = true,
    ["Audacious"] = true,
    ["alsamixer"] = true,
    ["ncpamixer"] = true,
}

for name, _ in pairs(no_decorations) do
   table.insert(awful.rules.rules, { rule = { class = name }, properties = { floating = true, border_width = 0, titlebars_enabled = false }})
   table.insert(awful.rules.rules, { rule = { name  = name }, properties = { floating = true, border_width = 0, titlebars_enabled = false }})
end

local function hover_bright(name, w)
   local hover_img = beautiful["titlebar_"..name.."_button_hover"]
   if hover_img then
      w:connect_signal( "mouse::enter", function() w:set_image(hover_img) end )
      w:connect_signal( "mouse::leave", w.update )
   end
   return w
end

local function adjust_border_width(c)
   if c.maximized or (no_decorations[c.name] or no_decorations[c.class]) then
      c.border_width = 0
   else
      c.border_width = beautiful.border_width
   end
end

local function normal_border(c)
   if c == client.focus then
      c.border_color = beautiful.border_focus
   else
      c.border_color = beautiful.border_normal
   end
end

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)

   adjust_border_width(c)
    
   -- When we only have one screen and we are restoring
   -- windows that were closed in the second screen,
   -- move them to the first screen.
   if screen.count() == 1 then
      local geo = screen[1].geometry
      if c.x > geo.width or c.x < geo.x then
         c.x = geo.x
      end
      if c.y > geo.height or c.y < geo.y then
         c.y = geo.y
      end
   end

   if sloppy_focus then
      c:connect_signal("mouse::enter", function(c)
         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
         end
      end)
   end

   -- Border resize
   c:connect_signal("button::press", function(c, x, y, button)
      if not c.maximized and button == 1 and (x < 0 or x >= c.width or y < 0 or y >= c.height) then
         awful.mouse.client.resize(c)
      end
   end)

   if not startup then
      -- Put windows in a smart way, only if they does not set an initial position.
      if not c.size_hints.user_position and not c.size_hints.program_position then
         awful.placement.no_overlap(c)
         awful.placement.no_offscreen(c)
      end
   end

end)

client.connect_signal("request::titlebars", function(c, context, hints)
   if not titlebars_enabled then
      return 
   end
   
   -- buttons for the titlebar
   local buttons = awful.util.table.join(
      awful.button({}, 1,
         function()
            client.focus = c
            c:raise()
            window_menu.hide(c)
            docking.smart_mouse_move(c)
         end),
      awful.button({}, 3,
         function()
            client.focus = c
            c:raise()
            window_menu.show(c)
         end)
   )

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(awful.titlebar.widget.iconwidget(c))
   --left_layout:add(awful.titlebar.widget.stickybutton(c))
   --left_layout:add(awful.titlebar.widget.ontopbutton(c))
   left_layout:buttons(buttons)

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   right_layout:add(hover_bright("minimize", awful.titlebar.widget.minimizebutton(c)))
   right_layout:add(hover_bright("maximized", awful.titlebar.widget.maximizedbutton(c)))
   right_layout:add(hover_bright("close", awful.titlebar.widget.closebutton(c)))

   -- The title goes in the middle
   local middle_layout = wibox.layout.flex.horizontal()
   local title = awful.titlebar.widget.titlewidget(c)
   title:set_align("center")
   middle_layout:add(title)
   middle_layout:buttons(buttons)

   -- Now bring it all together
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_right(right_layout)
   layout:set_middle(middle_layout)

   awful.titlebar(c):set_widget(layout)

   c:connect_signal("mouse::move", function(c, x, y)
      if x < 0 or x >= c.width or y < 0 or y >= c.height then
         if client.focus == c then
            c.border_color = "#ffffff"
         else
            c.border_color = "#777777"
         end
      else
         normal_border(c)
      end
   end)
   c:connect_signal("mouse::enter", normal_border)
   c:connect_signal("mouse::leave", normal_border)

end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("property::maximized", adjust_border_width)

