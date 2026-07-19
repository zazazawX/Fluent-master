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
| `Icon` | nil | Lucide icon name or image string beside Title. |
| `Size` | responsive `UDim2` | Panel size, constrained between 320×360 and 760×520. |
| `MetricTitle` | `Total` | Top-right metric label. |
| `Metric` | `0` | Initial metric value. |
| `PreviewTitle` | `Preview` | Right/bottom panel title. |
| `Preview` | empty | Initial preview text. |
| `Fields` | `{}` | Ordered field definitions. |
| `InitialValues` | `{[Id]: value}` | Overrides field values after creation. |
| `ActionText` | `Submit` | Primary button label. |
| `ActionIcon` | nil | Lucide icon name or image string on the action button. |
| `SubmittingText` | `Working...` | Label while OnSubmit runs. |
| `SuccessText` | `Success` | Temporary label after OnSubmit succeeds. |
| `SuccessColor` | green | Color3 for the temporary success state. |
| `SuccessDuration` | `1.5` | Seconds before restoring the action button. |
| `OverlayTransparency` | `0.78` | Full-viewport dark overlay transparency. |
| `Overlay` | true | Set false to remove the dark full-screen scrim. |
| `Theme` | current Fluent theme | Applies a Fluent theme name before building the panel. |
| `AccentColor` | current Fluent accent | Applies a Color3 accent before building the panel. |
| `Acrylic` | `false` | Set true to enable Fluent Acrylic blur. It is off by default. |
| `PanelTransparency` | `0.02` | Non-Acrylic surface transparency; lower is more opaque. |
| `InputTransparency` | `0.02` | Input background transparency. |
| `InputBorderTransparency` | `0.35` | Input border transparency. |
| `PreviewTransparency` | `0.04` | Preview/history background transparency. |
| `ShowHistory` | true | Initial visibility of the preview/history area. |
| `HistoryButtonText` | `History` | Header toggle label beside the close button. |
| `HistoryTimestamp` | true | Adds a timestamp to every AppendLog entry. |
| `TimestampFormat` | `%H:%M:%S` | `os.date` format used by history. |
| `LogLimit` | `30` | Maximum lines kept by AppendLog. |
| `CloseOnEscape` | true | Escape hides the panel. |
| `DestroyOnClose` | false | Close button destroys instead of hiding. |
| `OnClose(controller)` | nil | Called after close-button behavior. |
| `OnSubmit(values, controller)` | required | Runs asynchronously; returning a string appends it to History. Errors are contained and notified. |
| `Confirm` | nil | `true` or a table enables confirmation before OnSubmit. |

Confirm table fields are `Title`, `Content`, `ConfirmText`, and `CancelText`.

Above 520 px the layout is a left form and right preview. Below 520 px it stacks the form above the preview.

## Fields

Every field requires a unique `Id`.

Common optional fields: `Title`, `Description`, `Icon`, `Default`, `OnChanged(value, controller)`, `Required`, `Min`, `Max`, `Pattern`, and `Validator`.

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

### Multiline

```lua
{
    Id = "Message",
    Type = "Multiline",
    Title = "Message",
    Description = "Optional note",
    Height = 80,
    Max = 160,
}
```

`Multiline = true` on an Input has the same effect.

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

### Toggle

```lua
{
    Id = "Notify",
    Type = "Toggle",
    Title = "Delivery notification",
    Default = true,
    OnText = "Enabled",
    OffText = "Disabled",
}
```

### Dropdown

```lua
{
    Id = "Region",
    Type = "Dropdown",
    Title = "Destination region",
    Values = { "Automatic", "Asia", "Europe" },
    Default = "Automatic",
}
```

The dropdown list expands inside the form and collapses after selection.

## Validation and inline errors

Validation runs before confirmation/submission. Every failure is displayed directly below its field.

| Field config | Behavior |
| --- | --- |
| `Required` | Rejects nil or empty text. |
| `Min` / `Max` | Numeric bounds for Number; character-length bounds for text. |
| `Pattern` | Lua string pattern required for nonempty text. |
| `Validator(value, allValues, controller)` | Return `false, "message"` to reject. |
| `RequiredMessage`, `MinMessage`, `MaxMessage`, `PatternMessage`, `NumberMessage`, `ValidationMessage` | Override default messages. |

```lua
{
    Id = "Username",
    Type = "Input",
    Required = true,
    Min = 3,
    Max = 20,
    Pattern = "^[%w_]+$",
    PatternMessage = "Use letters, numbers, and underscore only",
}
```

## History tools

- Header badge updates as `History (count)`.
- Entries receive timestamps by default.
- Clear removes all entries.
- Copy copies all entries using available clipboard APIs and reports the result.

## Controller

| Field/method | Description |
| --- | --- |
| `Values` | Current values indexed by field ID. |
| `Logs` | Current history lines. |
| `Opened` | Current visible state. |
| `Submitting` | Whether OnSubmit is running. |
| `HistoryVisible` | Current preview/history visibility. The header History button toggles it. |
| `SetValue(id, value)` | Updates any supported field and its stored value. |
| `SetMetric(value, title?)` | Updates top-right metric. |
| `SetPreview(text, title?)` | Replaces preview text/title. |
| `AppendLog(text)` | Adds a line, trims to LogLimit, and displays History. |
| `ClearHistory()` | Clears history and resets its badge. |
| `CopyHistory()` | Returns `success, error?` after copying history. |
| `SetFieldError(id, message?)` | Sets or clears an inline field error. |
| `ValidateField(field)` | Returns `valid, message?`. |
| `Validate()` | Validates every field and returns `valid, firstError?`. |
| `SetSubmitting(value, text?)` | Manually controls action-button busy state. Normally automatic. |
| `Submit(skipConfirm?)` | Validates, optionally confirms, then runs OnSubmit. |
| `PerformSubmit()` | Runs OnSubmit after validation/confirmation. |
| `SetSuccess(text?)` | Shows the temporary success button state. |
| `Open()` | Shows the existing ScreenGui. |
| `Close()` | Hides without destroying. |
| `Destroy()` | Permanently destroys the standalone UI. |
| `UpdateLayout()` | Reapplies responsive and history visibility layout. |

`Theme` and `AccentColor` use Fluent's theme APIs, so they also update other UI created by the same Fluent instance.

See [`Examples/StandalonePanel.lua`](../Examples/StandalonePanel.lua) for a complete mail-style example.

