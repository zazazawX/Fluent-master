<img src="Assets/logodark.png#gh-dark-mode-only" alt="Fluent">
<img src="Assets/logolight.png#gh-light-mode-only" alt="Fluent">

## Features

- Responsive desktop, tablet, and phone layouts
- Mobile navigation drawer and safe-area support
- Mouse, touch, keyboard, and gamepad input
- Notification queue with swipe-to-dismiss
- Reduced-motion mode and theme contrast reports
- Versioned configuration files with migrations
- Strict Luau public API types
- Searchable Command Palette (public API on desktop, Find on mobile)
- Callback Error Boundary with Retry, Disable, and Copy error actions

## Installation

~~~lua
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
~~~

See [Example.lua](Example.lua) for the complete public API.

## Component test place

The test place contains every element, responsive window presets, overlay tests,
theme contrast checks, and a create/destroy stress test.

~~~sh
pnpm run test-place
~~~

Connect Roblox Studio through Rojo using test.project.json, then use Device
Emulator to verify phone, tablet, desktop, and console navigation.

## Accessibility and motion

~~~lua
local Window = Fluent:CreateWindow({
    Title = "Example",
    ReducedMotion = false,
    NotificationLimit = 3,
})

Fluent:SetReducedMotion(true)
local Report = Fluent:CheckThemeContrast("Dark")
~~~

Keyboard and gamepad shortcuts:

- PageUp / PageDown or L1 / R1: change tabs
- M or gamepad X: toggle the mobile navigation drawer
- Escape or gamepad B: close the active overlay
- Arrow keys or D-pad: adjust a focused slider

## Command Palette and callback recovery

~~~lua
Tabs.Main:AddButton({
    Title = "Open settings",
    CommandId = "open-settings",
    CommandKeywords = { "preferences", "config" },
    Callback = function()
        Window:SelectTab(2)
    end,
})

Fluent:RegisterCommand({
    Id = "disable-feature",
    Title = "Disable feature",
    Callback = function()
        Options.MyToggle:SetValue(false)
    end,
})
~~~

Errors raised by Button and Toggle callbacks are contained so the rest of the UI
keeps running. The recovery dialog can retry the action, disable that callback,
or copy its traceback for debugging. Use `Fluent:GetErrors()` to inspect the log.

## Strict Luau types

~~~lua
local Types = require(game.ReplicatedStorage.Fluent.Types)
type WindowConfig = Types.WindowConfig
type NotificationConfig = Types.NotificationConfig
~~~

## Config migrations

SaveManager writes schema version 2. Existing unversioned files are migrated
from version 1 and backed up before the migrated file is written. Custom future
migrations can be registered with SaveManager:RegisterMigration().

## Credits

- [richie0866/remote-spy](https://github.com/richie0866/remote-spy) — UI assets and original code
- [violin-suzutsuki/LinoriaLib](https://github.com/violin-suzutsuki/LinoriaLib) — Elements and save-manager foundations
- [7kayoh/Acrylic](https://github.com/7kayoh/Acrylic) — Acrylic module port
- Latte Softworks & Kotera — Bundler
