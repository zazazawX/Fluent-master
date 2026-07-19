# StandalonePanel

`Addons/StandalonePanel.lua` creates a separate Fluent-themed task/form window without creating the main Fluent Window. It is intended for mail, trade, queue, generator, batch action, admin tool, or other focused workflows.

## Load

```lua
local StandalonePanel = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/StandalonePanel.lua"
))()

StandalonePanel:SetLibrary(Fluent)
```

Fluent must already be loaded because StandalonePanel reuses its theme, notifications, Creator lifecycle, and safe callbacks.

## `StandalonePanel:CreatePanel(config) -> Controller`

`OnSubmit` is required. All other settings are optional.

| Config | Type/default | Description |
| --- | --- | --- |
| `Name` | `CoreXStandalonePanel` | ScreenGui name. |
| `Title` | `Standalone Panel` | Header title. |
| `Size` | responsive `UDim2` | Panel size, constrained between 320×360 and 760×520. |
| `MetricTitle` | `Total` | Top-right metric label. |
| `Metric` | `0` | Initial metric value. |
| `PreviewTitle` | `Preview` | Right/bottom panel title. |
| `Preview` | empty | Initial preview text. |
| `Fields` | `{}` | Ordered field definitions. |
| `InitialValues` | `{[Id]: value}` | Overrides field values after creation. |
| `ActionText` | `Submit` | Primary button label. |
| `SubmittingText` | `Working...` | Label while OnSubmit runs. |
| `OverlayTransparency` | `0.78` | Full-viewport dark overlay transparency. |
| `Overlay` | true | Set false to remove the dark full-screen scrim. |
| `Theme` | current Fluent theme | Applies a Fluent theme name before building the panel. |
| `AccentColor` | current Fluent accent | Applies a Color3 accent before building the panel. |
| `Acrylic` | `false` | Set true to enable Fluent Acrylic blur. It is off by default. |
| `ShowHistory` | true | Initial visibility of the preview/history area. |
| `HistoryButtonText` | `History` | Header toggle label beside the close button. |
| `LogLimit` | `30` | Maximum lines kept by AppendLog. |
| `CloseOnEscape` | true | Escape hides the panel. |
| `DestroyOnClose` | false | Close button destroys instead of hiding. |
| `OnClose(controller)` | nil | Called after close-button behavior. |
| `OnSubmit(values, controller)` | required | Runs asynchronously; returning a string appends it to History. Errors are contained and notified. |

Above 520 px the layout is a left form and right preview. Below 520 px it stacks the form above the preview.

## Fields

Every field requires a unique `Id`.

### Input

```lua
{
    Id = "Username",
    Type = "Input",
    Title = "Recipient username",
    Placeholder = "Enter username",
    Default = "",
    OnChanged = function(value, controller) end,
}
```

Omitting Type also creates an Input.

### Number

```lua
{
    Id = "Amount",
    Type = "Number",
    Title = "Amount",
    Default = 20,
}
```

The value is `number` when valid and nil while the text cannot be converted.

### Choice

```lua
{
    Id = "Delivery",
    Type = "Choice",
    Title = "Delivery method",
    Values = { "Private", "Public", "Secure", "Fast" },
    Default = "Secure",
    OnChanged = function(value, controller) end,
}
```

When Default is omitted, the first value is selected.

## Controller

| Field/method | Description |
| --- | --- |
| `Values` | Current values indexed by field ID. |
| `Logs` | Current history lines. |
| `Opened` | Current visible state. |
| `Submitting` | Whether OnSubmit is running. |
| `HistoryVisible` | Current preview/history visibility. The header History button toggles it. |
| `SetValue(id, value)` | Updates an Input, Number, or Choice and its stored value. |
| `SetMetric(value, title?)` | Updates top-right metric. |
| `SetPreview(text, title?)` | Replaces preview text/title. |
| `AppendLog(text)` | Adds a line, trims to LogLimit, and displays History. |
| `SetSubmitting(value, text?)` | Manually controls action-button busy state. Normally automatic. |
| `Submit()` | Runs OnSubmit unless already submitting. |
| `Open()` | Shows the existing ScreenGui. |
| `Close()` | Hides without destroying. |
| `Destroy()` | Permanently destroys the standalone UI. |
| `UpdateLayout()` | Reapplies responsive and history visibility layout. |

`Theme` and `AccentColor` use Fluent's theme APIs, so they also update other UI created by the same Fluent instance.

See [`Examples/StandalonePanel.lua`](../Examples/StandalonePanel.lua) for a complete mail-style example.

