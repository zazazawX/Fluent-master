# Getting started

## Load Fluent

Use a commit URL in production for predictable builds. Use `main` during development when you want the latest version.

```lua
local Fluent = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/dist/main.lua"
))()
```

Some executors cache URLs aggressively. If an update is not being received, use a commit URL or a new URL path rather than relying only on a query string.

## Minimal window

```lua
local Window = Fluent:CreateWindow({
    Title = "My Hub",
    SubTitle = "Fluent",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
    ReducedMotion = false,
    NotificationLimit = 3,
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Tabs.Main:AddToggle("Enabled", {
    Title = "Enabled",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})

Window:SelectTab(1)
```

## Load addons

```lua
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/InterfaceManager.lua"
))()
local KeySystem = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/KeySystem.lua"
))()

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
KeySystem:SetLibrary(Fluent)
```

## Recommended startup order

1. Load Fluent and addons.
2. If required, run `KeySystem:CreateKeySystem()` and create the main window inside `OnVerified`.
3. Create the Window, Tabs and Elements.
4. Configure manager folders.
5. Build InterfaceManager and SaveManager sections.
6. Call `SaveManager:LoadAutoloadConfig()` after every saved element exists.

## Clean shutdown

```lua
if getgenv and getgenv().Fluent then
    pcall(function()
        getgenv().Fluent:Destroy()
    end)
end
```

`Destroy()` removes Fluent windows, notifications, registered UI signals and the root GUI. Feature loops created by your own script must still be stopped by your script.

