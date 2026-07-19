# Elements API

Elements are added to a Tab or Section. Stateful elements require a unique ID and are available through `Fluent.Options[Id]`.

Most visual element objects provide `SetTitle(text)`, `SetDesc(text)` and `Destroy()`. Stateless Button, Paragraph, CopyButton and Image return their visual frame rather than being stored in `Options`.

## Common config

| Field | Type | Description |
| --- | --- | --- |
| `Title` | `string` | Required visible title. Some manager-generated titles are translation keys. |
| `Description` | `string?` | Optional secondary text. |
| `Tooltip` | `string?` | Optional hover/help tooltip where supported. |
| `Callback` | `function?` | Called when the value/action changes. Defaults to a no-op. |

## Button

```lua
local button = Tab:AddButton({
    Title = "Run",
    Description = "Run the action",
    Tooltip = "Optional help",
    CommandId = "run-action",
    CommandTitle = "Run action",
    CommandKeywords = { "start", "go" },
    Callback = function() end,
})
```

`Title` is required. `CommandId` registers the callback in the Command Palette; the other command fields are optional. The returned visual element supports `SetTitle`, `SetDesc`, and `Destroy`.

## CopyButton

```lua
Tab:AddCopyButton({
    Title = "Copy Discord",
    Description = "Copies an invite",
    Value = "https://discord.gg/example",
    Callback = function(copiedText) end,
})
```

`Value` may be a string or a function returning the current text. Clipboard resolution uses `setclipboard`, `toclipboard`, or `Clipboard.set`. A notification reports success/failure. Callback receives the resolved text.

## Toggle

```lua
local toggle = Tab:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Example feature",
    Default = false,
    Keybind = Enum.KeyCode.F,
    Tooltip = "Optional help",
    Callback = function(value) end,
})
```

| Member/method | Type/return | Description |
| --- | --- | --- |
| `Value` | `boolean` | Current state. |
| `Title` | `string` | Searchable title. |
| `Type` | `"Toggle"` | Manager type. |
| `Keybind` | `string?` | Optional assigned key name. |
| `SetValue(value)` | — | Coerces to boolean, updates UI, calls Callback and Changed. |
| `OnChanged(callback)` | — | Registers Changed and immediately calls it with current value. |
| `Destroy()` | — | Disconnects keybind, destroys UI, removes the Options entry. |

Every Toggle is included dynamically in `Fluent:GetCommands()`.

## Slider

```lua
local slider = Tab:AddSlider("Speed", {
    Title = "Speed",
    Default = 10,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Step = 5,
    Callback = function(value) end,
})
```

`Default`, `Min`, `Max`, and non-negative integer `Rounding` are required. `Min < Max`. Optional `Step` must be positive and defaults to `1 / 10^Rounding`.

Members: `Value`, `Min`, `Max`, `Rounding`, `Step`, `Type = "Slider"`. Methods: `SetValue(number)`, `OnChanged(callback)`, `SetTitle`, `SetDesc`, `Destroy`. Values are clamped and rounded. Arrow/D-pad adjusts a focused slider by Step.

## RangeSlider

```lua
local range = Tab:AddRangeSlider("Range", {
    Title = "Range",
    Min = 0,
    Max = 100,
    Default = { 20, 80 },
    Rounding = 0,
    Step = 5,
    Callback = function(value)
        print(value.Min, value.Max)
    end,
})
```

`Default` is optional and falls back to `{Min, Max}`. Current `Value` is `{Min = number, Max = number}`. Methods: `SetValue(minValue, maxValue)`, `OnChanged(callback)`, `SetTitle`, `SetDesc`, `Destroy`. SetValue clamps, rounds, and ensures minimum does not exceed maximum.

## Dropdown

```lua
local dropdown = Tab:AddDropdown("Weapon", {
    Title = "Weapon",
    Values = { "Sword", "Bow", "Staff" },
    Default = "Sword", -- or 1
    Multi = false,
    AllowNull = false,
    Search = false,
    Callback = function(value) end,
})
```

| Config | Description |
| --- | --- |
| `Values` | Array of allowed values; defaults to empty. |
| `Default` | Single value/index, or multi-selection table. |
| `Multi` | When true, Value is a map such as `{Sword = true}`. |
| `AllowNull` | Allows the final selected item to be deselected. |
| `Search` | True always shows search; false disables it; nil enables it automatically when more than six values exist. |

Methods:

- `Open()` / `Close()` — control popup.
- `Display()` — refresh visible selected text.
- `GetActiveValues() -> number` — number selected in Multi mode.
- `BuildDropdownList()` — rebuild buttons from Values.
- `SetValues(newValues)` — replace list and rebuild it.
- `SetValue(value)` — normalize and apply value, then invoke callbacks.
- `OnChanged(callback)` — register and immediately invoke it.
- `Destroy()` — closes popup, destroys UI, removes Options entry.

Single Default may be a value or a 1-based numeric index. Multi Default accepts `{ "Sword", "Bow" }` or `{ Sword = true, Bow = true }`.

## Input

```lua
local input = Tab:AddInput("Name", {
    Title = "Name",
    Default = "",
    Placeholder = "Type here",
    Numeric = false,
    Finished = true,
    MaxLength = 32,
    Callback = function(text) end,
})
```

`Finished = true` calls SetValue only when Enter ends focus; false updates while typing. `Numeric` rejects nonnumeric nonempty values. `MaxLength` truncates text. Methods: `SetValue(text)`, `OnChanged(callback)`, `SetTitle`, `SetDesc`, `Destroy`. `Value` is always stored as text.

## Keybind

```lua
local keybind = Tab:AddKeybind("MenuKey", {
    Title = "Menu key",
    Default = "LeftControl",
    Mode = "Toggle", -- Always, Toggle, Hold
    Callback = function(toggled) end,
    ChangedCallback = function(newInput) end,
})
```

`Default` is required and uses an Enum.KeyCode/UserInputType name string.

| Method | Description |
| --- | --- |
| `GetState() -> boolean` | Computes current state for Always/Hold/Toggle. False while a text box is focused, except Always. |
| `SetValue(key?, mode?)` | Changes key and/or mode. |
| `OnClick(callback)` | Registers an action callback invoked by `DoClick`. |
| `OnChanged(callback)` | Registers assignment-change callback and immediately receives current key string. |
| `DoClick()` | Invokes primary Callback and OnClick callback with toggled state. |
| `Destroy()` | Disconnects capture/input and removes Options entry. |

`ChangedCallback` receives the captured input object; `OnChanged` receives the assigned key name.

## Colorpicker

```lua
local picker = Tab:AddColorpicker("Accent", {
    Title = "Accent",
    Default = Color3.fromRGB(96, 205, 255),
    Transparency = 0,
    Callback = function(color) end,
})
```

`Default: Color3` is required. `Transparency` defaults to 0. Members include `Value: Color3`, `Transparency`, HSV fields, and `Type = "Colorpicker"`.

| Method | Description |
| --- | --- |
| `SetHSVFromRGB(color)` | Updates internal Hue/Sat/Vib. |
| `Display()` | Refreshes preview and invokes callbacks. |
| `SetValue(hsvTable, transparency?)` | Sets from `{Hue, Sat, Vib}`/compatible numeric indices. |
| `SetValueRGB(color, transparency?)` | Sets from Color3. |
| `OnChanged(callback)` | Registers and immediately receives current Color3. |
| `Destroy()` | Closes/release interaction and removes Options entry. |

The primary callback receives Color3. Read `picker.Transparency` separately when needed.

## Paragraph

```lua
local paragraph = Tab:AddParagraph({
    Title = "Information",
    Content = "Line one\nLine two",
})
```

`Title` is required; `Content` defaults to empty. Returned visual element supports `SetTitle`, `SetDesc` (updates content), and `Destroy`.

## Image

```lua
local image = Tab:AddImage({
    Title = "Preview",
    Description = "Current icon",
    Image = "rbxassetid://10709791437",
    Size = UDim2.fromOffset(64, 64),
    ScaleType = Enum.ScaleType.Fit,
})

image:SetImage("rbxassetid://NEW_ID")
```

`Title` and `Image` are required. Size defaults to 64×64 and ScaleType to Fit. The returned object also supports the common visual methods.

## Saved element types

SaveManager serializes `Toggle`, `Slider`, `Dropdown`, `Colorpicker`, `Keybind`, and `Input`. RangeSlider and stateless elements are not currently serialized by SaveManager.

