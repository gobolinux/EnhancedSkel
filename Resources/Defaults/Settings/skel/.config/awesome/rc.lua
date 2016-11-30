
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
local menu_gen = require("menubar.menu_gen")
local icon_theme = require("menubar.icon_theme")
local hotkeys_popup = require("awful.hotkeys_popup.widget")

-- C API
local screen = screen
local mouse = mouse
local client = client
local awesome = awesome
local root = root
local mousegrabber = mousegrabber

local terminal = "urxvt -cr green -fn '*-lode sans mono-*' -fb '*-lode sans mono-*' -fi '*-lode sans mono-*' -fbi '*-lode sans mono-*' -depth 32 -bg rgba:0000/0000/0000/e5bb  -fg '#bcc' -sb -sr +st -sl 100000 -b 0 -tn rxvt"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor
local browser = "firefox"

local sound_widget = sound.new()
sound_widget.terminal = terminal

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init("~/.config/awesome/themes/neon/theme.lua")

hotkeys_popup.title_font = "Lode Sans Mono Bold 12"
hotkeys_popup.description_font = "Lode Sans Mono 12"
hotkeys_popup.group_margin = 20

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.

local ALT = "Mod1"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- Launch compositor
awful.spawn.with_shell("compton -cf "..
                    "--fade-delta 5 "..
                    "--shadow-radius 11 "..
                    "--shadow-green 1.0 "..
                    "--shadow-blue 1.0 "..
                    "--no-dock-shadow "..
                    "--clear-shadow "..
                    "--no-dnd-shadow "..
                    "--shadow-exclude '!focused'")

-- {{{ Error handling
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
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
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
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    for s = 1, screen.count() do
        if type(wallpaper) == "function" then
            gears.wallpaper.maximized(wallpaper(s), s, true)
        else
            gears.wallpaper.maximized(wallpaper, s, true)
        end
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end
-- }}}

local function show_help()
   local save_bg_normal = beautiful.bg_normal
   beautiful.bg_normal = "#000000"
   hotkeys_popup.show_help()
   beautiful.bg_normal = save_bg_normal
end

local function layout_fn(mode) return function() awful.layout.set(mode) end end

-- {{{ Menu
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
   { "Restart", awesome.restart },
   { "Quit", awesome.quit }
}

local mymainmenu = awful.menu({ items = awful.util.table.join(
                                    { { "Awesome WM", myawesomemenu, beautiful.awesome_icon },
                                      { "Run...", function() menubar.show() end, nil },
                                      { "Open Terminal", terminal }
                                    }
                                  ),
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
        table.insert(cat_submenus[entry.category], { entry.name, entry.cmdline, entry.icon })
    end
    table.sort(cat_keys)
    for _, k in ipairs(cat_keys) do
        if #cat_submenus[k] > 0 then
            local cat = menu_gen.all_categories[k]
            mymainmenu:add({ cat.name, cat_submenus[k], icon_theme():find_icon_path(cat.icon_name) })
        end
    end
end)

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
local mytextclock = awful.widget.textclock(nil, 5)

-- Create a wibox for each screen and add it
local mywibox = {}
local mypromptbox = {}
--mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
local mytasklist = {}
local clients_menu
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
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
                     awful.button({ }, 3, function ()
                                              if clients_menu then
                                                  clients_menu:hide()
                                                  clients_menu = nil
                                              else
                                                  clients_menu = awful.menu.clients({
                                                      theme = { width = 250, height = 24 }
                                                  })
                                              end
                                          end))

--[[
-- This works. Problem is, how to make it responsive.
-- By default, this only gets called with the top-left edge of the window
-- changes screen.
-- Using
--    client.connect_signal("property::geometry", function() client.emit_signal("property::screen") end.
-- works, but uses too much CPU when moving a window.
local function custom_tasklist_filter(c, scr)
    local area = screen[scr].geometry
    local curr = c:geometry()
    local cx1, cx2 = curr.x, curr.x + curr.width
    local cy1, cy2 = curr.y, curr.y + curr.height
    local ax1, ax2 = area.x, area.x + area.width
    local ay1, ay2 = area.y, area.y + area.height
    if (cx2 < ax1) then return false end
    if (cx1 > ax2) then return false end
    if (cy2 < ay1) then return false end
    if (cy1 > ay2) then return false end
    return true
end  
]]

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    --[[
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)))
    ]]
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(wibox.widget.systray())
        right_layout:add(gobonet.new())
        right_layout:add(battery.new())
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
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 1, function() mymainmenu:hide() end),
    awful.button({ }, 3, function() mymainmenu:toggle() end)
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = awful.util.table.join(

    awful.key({ modkey,           }, "s", show_help, { description = "Show hotkeys", group = "awesome" }),

    awful.key({ modkey,           }, ",", awful.tag.viewprev, { description = "View previous", group = "tag" }),
    awful.key({ modkey,           }, ".", awful.tag.viewnext, { description = "View next", group = "tag" }),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "Go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end, { description = "Focus previous by index", group = "client" }),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end, { description = "Focus next by index", group = "client" }),

    awful.key({ modkey,           }, "w", function () mymainmenu:show() end, { description = "Show main menu", group = "awesome" }),

    -- Layout manipulation
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "Swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "Swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "Focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "Focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "Jump to urgent client", group = "client"}),

    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, {description = "Go back to previous client", group = "client" }),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "Open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "Reload Awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "Quit Awesome", group = "awesome"}),

    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(browser) end,
              {description = "Open a browser", group = "launcher"}),
    awful.key({ modkey,           }, "a", function() for s = 1, screen.count() do beautiful.animated_wallpaper(s) end end,
              {description = "Regenerate GoboLinux wallpaper", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "Increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "Decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "Increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "Decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "Increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "Decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts, 1) end,
              {description = "Select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end,
              {description = "Select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "Restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () menubar.show() end,
              {description = "Show the menubar", group = "awesome gobolinux"}),

    awful.key({ ALT },            "F2",     function () menubar.show() end,
              {description = "Show the menubar", group = "awesome gobolinux"}),

    --[[
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    ]]
    
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "Show the menubar", group = "launcher"}),

    -- Switch windows
    awful.key({ ALT,           }, "Tab",
        function ()
            alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
        end,
        {description = "Switch between windows", group = "awesome gobolinux"}
    ),
    awful.key({ ALT, "Shift"   }, "Tab",
        function ()
            alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
        end,
        {description = "Switch between windows backwards", group = "awesome gobolinux"}
    ),

    -- Multimedia keys    
    awful.key({ }, "XF86HomePage",         function () awful.util.spawn(browser) end,
        {description = "Open a browser", group = "multimedia"}
    ),
    awful.key({ }, "XF86AudioRaiseVolume", function() sound_widget:set_volume(5, "+") end,
        {description = "Raise audio volume", group = "multimedia"}
    ),
    awful.key({ }, "XF86AudioLowerVolume", function() sound_widget:set_volume(5, "-") end,
        {description = "Lower audio volume", group = "multimedia"}
    ),
    awful.key({ }, "XF86AudioMute",        function() sound_widget:toggle_mute() end,
        {description = "Toggle mute", group = "multimedia"}
    ),
    awful.key({ }, "XF86MonBrightnessDown", function() os.execute("xbacklight -dec 10") end),
    awful.key({ }, "XF86MonBrightnessUp",   function() os.execute("xbacklight -inc 10") end)

)

local window_menus = {}
setmetatable(window_menus, { __mode = "k" })

local function kill_window_menu(c)
    if window_menus[c] then
        window_menus[c]:hide()
        window_menus[c] = nil
    end
end

local function window_menu(c, menu_opts)
    kill_window_menu(c)
    local entries = {}
    if c.maximized then
        table.insert(entries, { "Restore", function() c.maximized_vertical = false; c.maximized_horizontal = false; end, beautiful.titlebar_maximized_button_focus_active })
    else
        table.insert(entries, { "Maximize", function() c.maximized = true end, beautiful.titlebar_maximized_button_focus_inactive })
    end
    table.insert(entries, { "Minimize", function() c.minimized = true end, beautiful.titlebar_minimize_button_focus_inactive })
    table.insert(entries, { "Always on top", function() c.ontop = not c.ontop end, c.ontop and beautiful.check_icon or nil})
    table.insert(entries, { "Full screen", function() c.fullscreen = not c.fullscreen end, c.fullscreen and beautiful.check_icon or nil })
    table.insert(entries, { "Close", function() c:kill() end, beautiful.titlebar_close_button_focus })
    entries.theme = { height = 24, width = 150 }
    local menu = awful.menu.new(entries)
    menu:show(menu_opts)
    window_menus[c] = menu
end

local auto_tile = {}
setmetatable(auto_tile, { __mode = "k" })

local delta = 64

local function undock_auto_tile(c)
    c.border_width = beautiful.border_width
    auto_tile[c] = nil
end

local function move_key(orient, delta)
    local size, pos, upleft, downright
    if orient == "vertical" then
        size, pos, upleft, downright = "height", "y", "up", "down"
    else
        size, pos, upleft, downright = "width", "x", "left", "right"
    end
    return function(c)
        local curr = c:geometry()
        if auto_tile[c] then
            local mode = auto_tile[c].mode
            if mode == upleft then
                c:geometry({ [size] = curr[size] - delta })
            elseif mode == downright then
                c:geometry({ [size] = curr[size] + delta, [pos] = curr[pos] - delta })
            end
        else
            c:geometry({ [pos] = curr[pos] - delta })
        end
    end
end

local function save_relative_geometry(c, geo, reference)
    if not auto_tile[c] then
        local old = {
           x = geo.x - reference.x,
           y = geo.y - reference.y,
           width = geo.width,
           height = geo.height,
        }
        auto_tile[c] = { old = old }
    end
end

local function corner(bottom, right, mods, key)
    local fn = function (c)
        local area = screen[c.screen].workarea
        undock_auto_tile(c)
        c.maximized = false
        c:geometry({
            x = area.x + (right == "right" and (area.width / 2) or 0),
            y = area.y + (bottom == "bottom" and (area.height / 2) or 0),
            width = (area.width / 2) - (c.border_width * 2),
            height = (area.height / 2) - (c.border_width * 2),
        })
    end
    return awful.key(mods, key, fn, { description = "Arrange at "..bottom.."-"..right.." corner", group = "awesome gobolinux" })
end

local function dock_left(c)
    local curr = c:geometry()
    local area = screen[c.screen].workarea
    local s_area = area
    local half = math.floor(area.width / 2)
    local offset = 0
    local mode = "left"
    local maxd = c.maximized
    if (maxd or (curr.x == area.x and curr.y == area.y)) and area.x > 0 then
        local nextscreen = awful.screen.getbycoord(area.x - 1, area.y)
        area = screen[nextscreen].workarea
        if maxd then
            half = area.width
            offset = 0
            mode = "up"
            c.screen = nextscreen
        else
            half = math.floor(area.width / 2)
            offset = half
            mode = "right"
        end
    else
        c.maximized = false
    end
    c:geometry({ x = area.x + offset,
                 y = area.y,
                 width = half,
                 height = area.height
              })
    save_relative_geometry(c, curr, s_area)
    auto_tile[c].mode = mode
    c.border_width = 0
end

local function dock_right(c)
    local area = screen[c.screen].workarea
    local s_area = area
    local half = math.floor(area.width / 2)
    local curr = c:geometry()
    local offset = 0
    local mode = "right"
    local nextscreen = awful.screen.getbycoord(area.x + area.width, area.y, -1)
    local maxd = c.maximized
    if (maxd or (curr.x == area.x + half and curr.y == area.y)) and nextscreen ~= -1 then
        area = screen[nextscreen].workarea
        if maxd then
            half = area.width
            offset = area.width
            mode = "up"
            c.screen = nextscreen
        else
            half = math.floor(area.width / 2)
            offset = half
            mode = "left"
        end
    else
        c.maximized = false
    end
    c:geometry({ x = area.x + half - offset,
                 y = area.y,
                 width = half,
                 height = area.height
              })
    save_relative_geometry(c, curr, s_area)
    auto_tile[c].mode = mode
    c.border_width = 0
end

local function dock_up(c)
    local area = screen[c.screen].workarea
    local half = math.floor(area.height / 2)
    local curr = c:geometry()
    local tophalf = (curr.x == area.x and curr.y == area.y and math.abs(curr.height - half) < 20)
    if c.maximized or (not tophalf) then
        c.maximized = false
        c:geometry({ x = area.x,
                     y = area.y,
                     width = area.width,
                     height = half,
                  })
    elseif tophalf then
        c.maximized = true
        c:geometry({ x = area.x,
                     y = area.y,
                     width = area.width,
                     height = area.height,
                  })
    end
    save_relative_geometry(c, curr, area)
    auto_tile[c].mode = "up"
    c.border_width = 0
end

local function dock_down(c)
    c.maximized = false
    local area = screen[c.screen].workarea
    local half = math.floor(area.height / 2)
    local curr = c:geometry()
    if curr.y ~= area.y + half then
        c:geometry({ x = area.x,
                     y = area.y + half,
                     width = area.width,
                     height = half,
                  })
        save_relative_geometry(c, curr, area)
        auto_tile[c].mode = "down"
        c.border_width = 0
    elseif auto_tile[c] then
        local old = auto_tile[c].old
        if old.x == 0 and old.y == 0 then
            old = {
                x = area.x + (area.width / 4),
                y = area.y + (area.height / 4),
                width = area.width / 2,
                height = area.height / 2,
            }
        else
            old.x = old.x + area.x
            old.y = old.y + area.y
        end
        c:geometry(old)
        awful.placement.no_offscreen(c)
        undock_auto_tile(c)
    end
end

local clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end,
        {description = "Toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "Close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              {description = "Window always floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "Move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function(c) c:move_to_screen() end,
              {description = "Move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "Toggle always on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        {description = "Minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_vertical   = not c.maximized_vertical
            c.maximized_horizontal = not c.maximized_horizontal
        end,
        {description = "Maximize", group = "client"}),
    awful.key({ ALT,           }, "F4",      function (c) kill_window_menu(c); c:kill() end,
              {description = "Close", group = "client"}),
    awful.key({ ALT,           }, "space",   function (c) local geo = c:geometry(); window_menu(c, { coords = { x = geo.x, y = geo.y } } ) end,
        {description = "Open window menu", group = "client"}),

    awful.key({ modkey, ALT,   }, "Up",    move_key("vertical", delta),    { description = "Move floating window", group = "awesome gobolinux" }),
    awful.key({ modkey, ALT,   }, "Down",  move_key("vertical", -delta),   { description = "Move floating window", group = "awesome gobolinux" }),
    awful.key({ modkey, ALT,   }, "Left",  move_key("horizontal", delta),  { description = "Move floating window", group = "awesome gobolinux" }),
    awful.key({ modkey, ALT,   }, "Right", move_key("horizontal", -delta), { description = "Move floating window", group = "awesome gobolinux" }),

    awful.key({ modkey, "Ctrl", ALT }, "Up",    function (c) local curr = c:geometry(); if not auto_tile[c] then c:geometry({ height = curr.height - delta }); end; end, { description = "Resize floating window", group = "awesome gobolinux" }),
    awful.key({ modkey, "Ctrl", ALT }, "Down",  function (c) local curr = c:geometry(); if not auto_tile[c] then c:geometry({ height = curr.height + delta }); end; end, { description = "Resize floating window", group = "awesome gobolinux" }),
    awful.key({ modkey, "Ctrl", ALT }, "Left",  function (c) local curr = c:geometry(); if not auto_tile[c] then c:geometry({ width  = curr.width  - delta }); end; end, { description = "Resize floating window", group = "awesome gobolinux" }),
    awful.key({ modkey, "Ctrl", ALT }, "Right", function (c) local curr = c:geometry(); if not auto_tile[c] then c:geometry({ width  = curr.width  + delta }); end; end, { description = "Resize floating window", group = "awesome gobolinux" }),

    corner("top",    "left",  { modkey }, "KP_Home"),
    corner("top",    "right", { modkey }, "KP_Prior"),
    corner("bottom", "left",  { modkey }, "KP_End"),
    corner("bottom", "right", { modkey }, "KP_Next"),

    awful.key({ modkey }, "KP_Left", dock_left),
    awful.key({ modkey }, "KP_Right", dock_right),
    awful.key({ modkey }, "KP_Up", dock_up),
    awful.key({ modkey }, "KP_Down", dock_down),

    awful.key({ modkey }, "Left", dock_left, { description = "Dock / move docked window", group = "awesome gobolinux" }),
    awful.key({ modkey }, "Right", dock_right, { description = "Dock / move docked window", group = "awesome gobolinux" }),
    awful.key({ modkey }, "Up", dock_up, { description = "Dock / move docked window", group = "awesome gobolinux" }),
    awful.key({ modkey }, "Down", dock_down, { description = "Dock / move docked window", group = "awesome gobolinux" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 4.
for i = 1, 4 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end,
                  {description = "View tag #"..i, group = "tag"}),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "Toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end,
                  {description = "Move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end,
                  {description = "Toggle focused client on tag #" .. i, group = "tag"}))
end

local function custom_move(c)
    if c.maximized then
        c.border_width = 0
        mousegrabber.run(
            function (_mouse)
                if _mouse.buttons[1] then
                    local ms = mouse.screen
                    if mouse.screen ~= c.screen then
                        c.screen = ms
                        c:geometry(screen[ms].workarea)
                    end
                    return true
                end
                return false
            end, "fleur")
    else
        undock_auto_tile(c)
        awful.mouse.client.move(c)
    end
end

local clientbuttons = awful.util.table.join(
    awful.button({     }, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ ALT }, 1, function(c) client.focus = c; c:raise(); custom_move(c) end),
    awful.button({ "Control", ALT }, 1, function(c) client.focus = c; c:raise(); awful.mouse.client.resize(c); end),
    awful.button({ ALT }, 3, function(c) client.focus = c; c:raise(); awful.mouse.client.resize(c); end))

-- Set keys
root.keys(globalkeys)
-- }}}

local no_decorations = {
    ["plugin-container"] = true,
    ["Audacious"] = true,
    ["alsamixer"] = true,
}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     --border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     screen = awful.screen.focused,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}

for name, _ in pairs(no_decorations) do
    table.insert(awful.rules.rules, { rule = { class = name }, properties = { floating = true, border_width = 0 }})
    table.insert(awful.rules.rules, { rule = { name  = name }, properties = { floating = true, border_width = 0 }})
end

-- }}}

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

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

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
    
    --[[
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
    --]]

    -- Border resize
    c:connect_signal("button::press", function(c, x, y, button)
        if not c.maximized and button == 1 and (x < 0 or x >= c.width or y < 0 or y >= c.height) then
            awful.mouse.client.resize(c)
        end
    end)

    
    --[[
    -- Border mouse cursor
    -- Has issues with some applications (GTK+2?)
    c:connect_signal("mouse::move", function(c, x, y)
        if not c.maximized then
            if x < 0 then
                local third = c.height / 3
                if y < third then
                    root.cursor("top_left_corner")
                elseif y <= third * 2 then
                    root.cursor("left_side")
                else
                    root.cursor("bottom_left_corner")
                end
                return
            elseif x >= c.width then
                local third = c.height / 3
                if y < third then
                    root.cursor("top_right_corner")
                elseif y <= third * 2 then
                    root.cursor("right_side")
                else
                    root.cursor("bottom_right_corner")
                end
                return
            elseif y < 0 then
                local third = c.width / 3
                if x < third then
                    root.cursor("top_left_corner")
                elseif x <= third * 2 then
                    root.cursor("top_side")
                else
                    root.cursor("top_right_corner")
                end
                return
            elseif y >= c.height then
                local third = c.width / 3
                if x < third then
                    root.cursor("bottom_left_corner")
                elseif x <= third * 2 then
                    root.cursor("bottom_side")
                else
                    root.cursor("bottom_right_corner")
                end
                return
            end
        end
        root.cursor("left_ptr")
    end)
    --]]

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and ((c.type == "normal" or c.type == "dialog") and not (no_decorations[c.name] or no_decorations[c.class])) then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    kill_window_menu(c)
                    custom_move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    window_menu(c)
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
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("property::maximized", adjust_border_width)

-- }}}
