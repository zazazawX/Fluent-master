# Core library API

## Library fields

| Field | Type | Description |
| --- | --- | --- |
| `Version` | `string` | Current Fluent version. |
| `Theme` | `string` | Active theme name. |
| `Themes` | `{string}` | Available theme names. |
| `Options` | `{[string]: Element}` | Elements indexed by their IDs. |
| `Windows` | `{Window}` | Active windows. |
| `Window` | `Window?` | First active window, used for error dialogs. |
| `ReducedMotion` | `boolean` | Whether nonessential animation is reduced. |
| `NotificationLimit` | `number` | Maximum visible notifications. |
| `UseAcrylic` / `Acrylic` | `boolean` | Acrylic availability/current state. |
| `Commands` | `{[string]: Command}` | Explicitly registered commands. |
| `Errors` | `{ErrorRecord}` | Captured callback errors. |
| `MinimizeKeybind` | `Keybind?` | Optional InterfaceManager keybind object. |

`getgenv().Fluent` and `getgenv().CoreX` point to the loaded library when `getgenv` is available.

## `Fluent:CreateWindow(config)`

Creates and returns a Window.

| Config | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `Title` | `string` | yes | — | Window title. |
| `SubTitle` | `string` | no | — | Small title suffix. |
| `TabWidth` | `number` | no | component default | Sidebar width. |
| `Size` | `UDim2` | no | component default | Initial size. Offset-based sizes are recommended. |
| `Acrylic` | `boolean` | no | `false` | Enables acrylic blur support. |
| `Theme` | `string` | no | `Dark` | Initial theme; invalid names fall back to `Dark`. |
| `MinimizeKey` | `Enum.KeyCode` | no | `LeftControl` | Toggles the window when no manager keybind is assigned. |
| `ReducedMotion` | `boolean` | no | `false` | Reduces nonessential motion. |
| `NotificationLimit` | `number` | no | `3` | Visible notification limit, clamped to at least 1. |
| `ShowSplashScreen` | `boolean` | no | `true` | Set false to skip Fluent's opening splash. |

The window becomes compact below the responsive breakpoint and uses a mobile navigation drawer.

## Window methods

### `Window:AddTab(config) -> Tab`

Config: `Title: string`, optional `Icon: string`. An icon may be a Lucide name known by Fluent or a direct image string.

### `Window:SelectTab(tab)`

Selects a tab. Public examples use a 1-based numeric index.

### `Window:Dialog(config)`

```lua
Window:Dialog({
    Title = "Confirm",
    Content = "Continue?",
    Buttons = {
        { Title = "Yes", Callback = function() print("yes") end },
        { Title = "No", Callback = function() end },
    },
})
```

Only one dialog interaction is active at a time. Escape/gamepad B closes the active overlay.

### `Window:Minimize()`

Toggles the visibility of this window. It does not destroy it.

### `Window:SetSize(size, isInstant?)`

Resizes using a spring by default. `isInstant = true` skips the spring. Size is constrained to viewport and minimum/maximum bounds.

### `Window:SetNavigationDrawer(open)`

Opens/closes navigation only when the window is in compact mode.

### `Window:AddThemeCustomizer() -> Tab`

Creates and returns a Theme Editor tab, registers the runtime `Custom` theme if necessary, and adds controls for major theme colors.

### `Window:Destroy()`

Destroys this window and releases its drag, resize, dropdown and dialog state. Other Fluent windows remain active.

## Tab and Section

`Tab:AddSection(title) -> Section` creates a labeled section. Both Tab and Section support the same `Add<Element>` methods documented in [Elements](elements.md).

Keyboard/gamepad navigation:

- `PageUp` / `PageDown`, or gamepad `L1` / `R1`: previous/next tab.
- `M`, or gamepad `X`: mobile drawer.
- `Escape`, or gamepad `B`: close active dialog, dropdown or drawer.

## Notifications

### `Fluent:Notify(config) -> Notification`

| Config | Type | Default | Description |
| --- | --- | --- | --- |
| `Title` | `string?` | empty | Heading. |
| `Content` | `string?` | empty | Main content. |
| `SubContent` | `string?` | empty | Secondary content. |
| `Duration` | `number?` | component default | Seconds before close; nil may keep it open. |
| `Type` | `string?` | info | Visual type such as `Success`, `Warning`, `Error`. |

The returned notification exposes `:Open()` and `:Close()`.

### `Fluent:SetNotificationLimit(value)`

Sets the visible limit and immediately enforces it.

## Themes and appearance

| Method | Description |
| --- | --- |
| `SetTheme(name)` | Applies a known theme. Invalid names are ignored. |
| `SetAccentColor(color3)` | Overrides the accent color at runtime. |
| `SetCompactMode(boolean)` | Uses tighter padding and smaller element geometry. |
| `SetReducedMotion(boolean)` | Reduces nonessential animation. |
| `ToggleAcrylic(boolean)` | Enables/disables blur only if the window was created with Acrylic support. |
| `ToggleTransparency(boolean)` | Changes the acrylic window background transparency. |
| `CheckThemeContrast(theme?, minimum?)` | Returns one contrast report or nil for an unknown theme. |
| `CheckAllThemeContrast(minimum?)` | Returns reports indexed by theme name. |

A contrast report contains `Theme`, `Passed`, `Minimum`, `Issues` and `Ratios`. Each issue contains `Foreground`, `Background`, `Ratio` and `Minimum`.

## Language

| Method | Description |
| --- | --- |
| `SetLanguage("en" | "th")` | Changes active built-in translations. Unknown languages are ignored. |
| `Translate(key, ...)` | Returns and formats the translated string, falling back to English and then the key. |
| `OnLanguageChanged(callback)` | Registers a callback invoked after a supported language changes. |

## Command Palette

There is no global Ctrl+K shortcut. Open it explicitly on desktop; mobile also receives a `Find` button.

```lua
Fluent:OpenCommandPalette()
Fluent:CloseCommandPalette()
```

### Command object

```lua
{
    Id = "open-settings",       -- required, unique
    Title = "Open settings",    -- required
    Keywords = { "config" },    -- optional
    Callback = function() end,   -- required
}
```

| Method | Return | Description |
| --- | --- | --- |
| `RegisterCommand(command)` | command | Adds/replaces an explicit command. |
| `UnregisterCommand(id)` | — | Removes an explicit command. |
| `GetCommands()` | `{Command}` | Returns explicit commands plus dynamic commands for every Toggle. |
| `ExecuteCommand(commandOrId)` | `boolean` | Executes through `SafeCallback`; false when not found. String IDs address explicit commands. |

Buttons can register themselves with `CommandId`, `CommandTitle` and `CommandKeywords`. Toggles are searchable automatically.

## Error Boundary

Button and Toggle callbacks have context registered automatically. Other callbacks still run through `SafeCallback` but may use the generic title.

| Method | Description |
| --- | --- |
| `SafeCallback(callback, ...)` | Executes with `xpcall`; returns the first callback result, or `nil, traceback` on failure. |
| `RegisterCallbackContext(callback, context)` | Adds `{Title, Type, Id?}` metadata and returns the callback. |
| `GetErrors()` | Returns the live error-record array. |
| `ClearErrors()` | Clears captured records. |

An error record contains `Id`, `Message`, `Traceback`, `Callback`, `Arguments`, `Context`, `Count` and `Time`. The recovery dialog offers Retry, Disable and Copy error. Disable applies only to that callback function for the current Fluent session.

## Utility and lifecycle methods

| Method | Description |
| --- | --- |
| `Round(number, decimalPlaces?)` | Rounds using Roblox `math.round`. |
| `GetIcon(name)` | Returns a known Lucide asset string or nil. |
| `GetLayer(name)` | Returns `Window`, `Overlay`, `Notifications`, or SafeArea fallback. Advanced use. |
| `Destroy()` | Destroys the complete Fluent instance. |

`AcquireInteraction(owner)` and `ReleaseInteraction(owner)` are internal coordination APIs for drag/slider/color interactions; website users normally should not call them.

