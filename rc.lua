#!/usr/bin/env lua

-- DESCRIPTION
-- ========================================================================
-- Main configuration files for awesome WM

-- LIBRARY
-- ========================================================================
-- Required libraries
-- ------------------------------------------------------------------------
local os       = os
local string   = string
local ipairs   = ipairs
local tostring = tostring
local tonumber = tonumber
local type     = type

local awesome  = awesome
local client   = client
local mouse    = mouse
local screen   = screen
local tag      = tag

-- Awesome module libraries
-- ------------------------------------------------------------------------
-- Main awesome wm library
local awful         = require("awful")
                      require("awful.autofocus")
local hotkeys_popup = require("awful.hotkeys_popup.widget")
local rules         = require("awful.rules")
-- Awesome wm utility box
local gears         = require("gears")
-- Awesome wm theme library
local beautiful     = require("beautiful")
-- Awesome wm notification library
local naughty       = require("naughty")
-- Awesome wm windows management library
local wibox         = require("wibox")

-- PERSONNAL LIBRARY
-- ========================================================================
-- Update config path to load personnal widgets
local config_path   = awful.util.getdir("config")
package.path        = config_path .. "?.lua;"     .. package.path
package.path        = config_path .. "?/?.lua;"   .. package.path
package.path        = config_path .. "?/?/?.lua;" .. package.path

-- Personal tools, mainly for run_once method
require("utility")

-- FUNCTIONS
-- ========================================================================
-- Handlers
-- ------------------------------------------------------------------------
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors
    })
end
-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal(
    "debug::error",
    function (err)
      if in_error then return end
      in_error = true
      naughty.notify({ preset = naughty.config.presets.critical,
                       title = "Oops, an error happened!",
                       text = tostring(err) })
      in_error = false
    end)
end

-- VARIABLES
-- ========================================================================
-- Global Key
-- ------------------------------------------------------------------------
local modkey   = "Mod4"    -- "Windows" key
local altkey   = "Mod1"    -- "Alt" key
local ctrlkey  = "Control" -- "Ctrl" key
local shiftkey = "Shift"   -- "Shift" key
-- Programs
-- ------------------------------------------------------------------------
local terminal   = "st" or "terminator" or "xterm"
local editor     = os.getenv("EDITOR") or "vim" or "vi" or "nano"
local gui_editor = os.getenv("GUI_EDITOR") or "gvim"
local browser    = os.getenv("BROWSER") or "firefox" or "chromium-browser"
local explorer   = "pcmanfm" or "thunar"

local dpi                 = require("beautiful.xresources").apply_dpi
local theme_name          = "powerarrow-dark"
local mouse_raise_windows = false

-- GLOBAL CONFIGURATION
-- ========================================================================
-- Set awful terminal application
awful.util.terminal = terminal
-- Set prefered icon size
awesome.set_preferred_icon_size(24)
-- Set local
os.setlocale(os.getenv("LANG"))

-- STARTUP RUN ONCE
-- ========================================================================
run_once({
  "xcompmgr",        -- Composite manager, make term transparent
  "redshift",        -- redshift to avoid blue light at night
  "unclutter -root", -- hide mouse after 5 sec of inactivity
  "keynav",          -- manipulation of mouse with keyboard
  "nextcloud",       -- nextcloud client
  "xautolock -time 180 -locker ~/.bin/lock &" , -- lock the screen after 180 sec on inactivity
})

-- CONFIGURATION
-- ========================================================================
-- Layout
-- ------------------------------------------------------------------------
local layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
}

-- Tag
-- ------------------------------------------------------------------------
-- Set awful taglist
awful.util.tagnames = { " ", "爵", " ", " ", " " }
awful.layout.layouts = layouts

-- Tasklist mouse button management
-- ------------------------------------------------------------------------
awful.util.tasklist_buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    -- Right click on task will unminized if minized and give focus to clicked
    -- task
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
    -- This will also un-minimize the client, if needed
    client.focus = c
    c:raise()
    end
  end),
  -- Mouse scroll wheel switch to previous or next task
  awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
  awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

beautiful.init(string.format("%s/.config/awesome/theme/%s/theme.lua", os.getenv("HOME"), theme_name))

-- Screen
-- ------------------------------------------------------------------------
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end)

-- Virtual Desktop
-- ------------------------------------------------------------------------
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
  -- Apply theme to each screen
  beautiful.at_screen_connect(s)
end)

-- Key bindings
-- ------------------------------------------------------------------------
--local globalkeys = awful.util.table.join(
local globalkeys = gears.table.join(
  -- Take a screenshot
  -- https://github.com/lcpz/dots/blob/master/bin/screenshot
  awful.key({ modkey }, "p",
    function() os.execute("screenshot") end,
    {
      description = "\t\tTake a screenshot",
      group = "Hotkeys"
    }),

  -- Hotkeys
  awful.key({ modkey }, "F1",
    hotkeys_popup.show_help,
    {
      description = "\t\tShow help",
      group="Awesome"
    }),

  -- Tag browsing
  awful.key({ modkey, shiftkey }, "l",
    awful.tag.viewprev,
    {
      description = "\t\tView previous tag",
      group = "Tag"
    }),
  awful.key({ modkey, shiftkey }, "h",
    awful.tag.viewnext,
    {
      description = "\t\tView next tag",
      group = "Tag"
    }),
  awful.key({ modkey, }, "Tab",
    awful.tag.history.restore,
    {
      description = "\t\tSwitch with last used tag",
      group = "Tag"
    }),

  -- By direction client focus
  awful.key({ modkey }, "j",
    function()
      awful.client.focus.global_bydirection("down")
      if client.focus then client.focus:raise() end
    end,
    {
      description = "\t\tFocus down",
      group = "Client"
    }),
  awful.key({ modkey }, "k",
    function()
      awful.client.focus.global_bydirection("up")
      if client.focus then client.focus:raise() end
    end,
    {
      description = "\t\tFocus up",
      group = "Client"
    }),
  awful.key({ modkey }, "h",
    function()
      awful.client.focus.global_bydirection("left")
      if client.focus then client.focus:raise() end
    end,
    {
      description = "\t\tFocus left",
      group = "Client"
    }),
  awful.key({ modkey }, "l",
    function()
      awful.client.focus.global_bydirection("right")
      if client.focus then client.focus:raise() end
    end,
    {
      description = "\t\tFocus right",
      group = "Client"
    }),

  -- Layout manipulation
  awful.key({ modkey, shiftkey }, "j",
    function () awful.client.swap.byidx(1) end,
    {
      description = "\t\tSwap with next client by index",
      group = "Client"
    }),
  awful.key({ modkey, shiftkey }, "k",
    function () awful.client.swap.byidx(-1) end,
    {
      description = "\t\tSwap with previous client by index",
      group = "Client"
    }),
  awful.key({ modkey, "Control" }, "j",
    function () awful.screen.focus_relative(1) end,
    {
      description = "\t\tFocus the next screen",
      group = "Screen"
    }),
  awful.key({ modkey, "Control" }, "k",
    function () awful.screen.focus_relative(-1) end,
    {
      description = "\t\tFocus the previous screen",
      group = "Screen"
    }),
  awful.key({ modkey }, "u",
    awful.client.urgent.jumpto,
    {
      description = "\t\tJump to urgent client",
      group = "Client"
    }),

  -- Show/Hide Wibox
  awful.key({ modkey }, "b",
    function ()
      for s in screen do
        s.top_bar.visible = not s.top_bar.visible
        s.bot_bar.visible = not s.bot_bar.visible
      end
    end,
    {
      description = "\t\tToggle/Hide top and bottom wibox",
      group = "Screen"
    }),

  -- On the fly gaps change
  awful.key({ modkey, altkey }, "u",
    function() awful.tag.incgap(1) end,
    {
      description = "\t\tIncrease gap",
      group = "Screen"
    }),
  awful.key({ modkey, altkey }, "d",
    function () awful.tag.incgap(-1) end,
    {
      description = "\t\tDecrease gap",
      group = "Screen"
    }),

  -- Standard program
  awful.key({ modkey, "Control" }, "r",
    awesome.restart,
    {
      description = "\t\tReload awesome",
      group = "Awesome"
    }),
  awful.key({ modkey, shiftkey }, "q",
    awesome.quit,
    {
      description = "\t\tQuit awesome",
      group = "Awesome"
    }),

  -- Change client size
  awful.key({ modkey, altkey }, "l",
    function () awful.tag.incmwfact(0.01) end,
    {
      description = "\t\tIncrease client size width factor",
      group = "Screen"
    }),
  awful.key({ modkey, altkey }, "h",
    function () awful.tag.incmwfact(-0.01) end,
    {
      description = "\t\tDecrease client size width factor",
      group = "Screen"
    }),

  awful.key({ modkey }, "space",
    function () awful.layout.inc(1) end,
    {
      description = "\t\tSelect next layout",
      group = "Screen"
    }),
  awful.key({ modkey, "Shift" }, "space",
    function () awful.layout.inc(-1) end,
    {
      description = "\tSelect previous layout",
      group = "Screen"
    }),

  awful.key({ modkey, shiftkey }, "n",
    function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        client.focus = c
        c:raise()
      end
    end,
    {
      description = "\t\tRestore minimized",
      group = "Client"
    }),

  -- Brightness
  awful.key({ }, "XF86MonBrightnessUp",
    function () os.execute("xbacklight -inc 10") end,
    {
      description = "\tIncrease backlight +10%",
      group = "Hotkeys"
    }),
  awful.key({ }, "XF86MonBrightnessDown",
    function () os.execute("xbacklight -dec 10") end,
    {
      description = "\tDecrease backlight -10%",
      group = "Hotkeys"
    }),

  -- ALSA/Pulksemixer volume control
  awful.key({ }, "XF86AudioRaiseVolume",
    function ()
      os.execute(string.format("pulsemixer --change-volume +1"))
      if beautiful.volume then beautiful.volume.update() end
    end,
    {
      description = "\tVolume up",
      group = "Hotkeys"
    }),
  awful.key({ }, "XF86AudioLowerVolume",
    function ()
      os.execute(string.format("pulsemixer --change-volume -1"))
      if beautiful.volume then beautiful.volume.update() end
    end,
    {
      description = "\tVolume down",
      group = "Hotkeys"
    }),
  awful.key({ }, "XF86AudioMute",
    function ()
      os.execute(string.format("pulsemixer --toggle-mute"))
      if beautiful.volume then beautiful.volume.update() end
    end,
    {
      description = "\t\tToggle mute",
      group = "Hotkeys"
    }),

  awful.key({ modkey }, "Up",
    function ()
      os.execute(string.format("pulsemixer --change-volume +1"))
      if beautiful.volume then beautiful.volume.update() end
    end,
    {
      description = "\t\tVolume up",
      group = "Hotkeys"
    }),
  awful.key({ modkey }, "Down",
    function ()
      os.execute(string.format("pulsemixer --change-volume -1"))
      if beautiful.volume then beautiful.volume.update() end
    end,
    {
      description = "\t\tVolume down",
      group = "Hotkeys"
    }),
  awful.key({ modkey, shiftkey }, "m",
    function ()
      os.execute(string.format("pulsemixer --toggle-mute"))
      if beautiful.volume then beautiful.volume.update() end
    end,
    {
      description = "\t\tToggle mute",
      group = "Hotkeys"
    }),

  -- User programs
  awful.key({ modkey }, "Return",
    function () awful.spawn(terminal) end,
    {
      description = "\t\tOpen a terminal",
      group = "Applications"
    }),
  awful.key({ modkey }, "e",
    function () awful.util.spawn(explorer) end,
    {
      description = "\t\tOpen file explorer",
      group = "Applications"
    }),
  awful.key({ modkey }, "w",
    function () awful.spawn(browser) end,
    {
      description = "\t\tOpen web browser",
      group = "Applications"
    }),
  awful.key({ modkey }, "p",
    function () awful.util.spawn(terminal .. " -e pulsemixer") end,
    {
      description = "\t\tOpen pulsemixer",
      group = "Applications"
    }),

  -- Use rofi, a dmenu-like application with more features
  awful.key({ modkey }, "r",
    function ()
        awful.spawn("rofi -show run")
    end,
    {
      description = "\t\tRun rofi",
      group = "Applications"
    }),
  awful.key({ modkey }, "i",
    function ()
        awful.spawn.with_shell("~/.local/bin/dmenu_unicode")
    end,
    {
      description = "\t\tRun rofi to select unicode char",
      group = "Applications"
    })
)

local clientkeys = awful.util.table.join(
  awful.key({ modkey }, "f",
    function (c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {
      description = "\t\tToggle fullscreen",
      group = "Client"
    }),
  awful.key({ modkey, ctrlkey   }, "c",
    function (c) c:kill() end,
    {
      description = "\t\tSend SIGKILL",
      group = "Client"
    }),
  awful.key({ modkey, ctrlkey   }, "space",
    awful.client.floating.toggle,
    {
      description = "\tToggle floating",
      group = "Client"
    }),
  awful.key({ modkey }, "o",
    function (c) c:move_to_screen() end,
    {
      description = "\t\tMove to screen",
      group = "Client"
    }),
  awful.key({ modkey }, "t",
    function (c) c.ontop = not c.ontop end,
    {
      description = "\t\tToggle keep on top",
      group = "Client"
    }),
  awful.key({ modkey }, "s",
    function (c) c.sticky = not c.sticky end,
    {
      description = "\t\tToggle sticky client",
      group = "Client"
    }),
  awful.key({ modkey }, "n",
    function (c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end ,
    {
      description = "\t\tMinimize",
      group = "Client"
    }),
  awful.key({ modkey }, "m",
    function (c)
      c.maximized = not c.maximized
      c:raise()
    end ,
    {
      description = "\t\tMaximize",
      group = "Client"
    }),
  awful.key({ modkey , shiftkey }, "r",
    function () screen.focused().mypromptbox:run() end,
    {
      description = "\t\tRun prompt",
      group = "Client"
    })
)


-- Bind all key numbers to tags.
-- ------------------------------------------------------------------------
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey,         }, "#" .. i + 9,
    function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewonly(tag)
      end
    end,
    {
      description = "\tSwitch to # tags",
      group = "Tags"
    }),
    awful.key({ modkey, ctrlkey }, "#" .. i + 9,
    function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end,
    {
      description = "\tMerge content of tag # with current one",
      group = "Tags"
    }),
    awful.key({ modkey, shiftkey }, "#" .. i + 9,
    function ()
      local tag = awful.tag.gettags(client.focus.screen)[i]
      if client.focus and tag then
        awful.client.movetotag(tag)
      end
    end,
    {
      description = "\tSend client to tag #",
      group = "Tags"
    })
  )
end

-- Set Global Keys
-- -----------------------------------------------------------------------------
root.keys(globalkeys)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = { },
    properties =
    {
      border_width     = beautiful.border_width,
      border_color     = beautiful.border_normal,
      focus            = awful.client.focus.filter,
      raise            = true,
      keys             = clientkeys,
      buttons          = clientbuttons,
      screen           = awful.screen.preferred,
      placement        = awful.placement.no_overlap+awful.placement.no_offscreen,
      size_hints_honor = false
   }
  },
}

-- Signals
-- -----------------------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal("mouse::enter", function(c)
  -- Enable focus when mouse enter client
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)
client.connect_signal("request::activate",
  -- Color border of newly activated client
  function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("focus",
  -- Color border of focus client
  function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus",
  -- Uncolor border of unfocus client
  function(c)
    c.border_color = beautiful.border_normal
end)