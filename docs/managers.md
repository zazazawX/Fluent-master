# SaveManager and InterfaceManager

## SaveManager setup

```lua
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("MyHub/MyGame")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "TemporaryOption" })
SaveManager:BuildConfigSection(Tabs.Settings)

-- Call only after all saved elements exist.
SaveManager:LoadAutoloadConfig()
```

Default folder is `FluentSettings`; configs live in `<Folder>/settings/<name>.json`. Current schema is version 2.

The generated config section also includes JSON transfer controls. **Copy configuration as JSON**
exports the current supported option values to the clipboard. Paste that text into **Paste JSON to
import**, then press **Import configuration from JSON** to restore it on another device or executor.

## SaveManager API

| Method | Return | Description |
| --- | --- | --- |
| `SetLibrary(library)` | — | Required; also points manager Options to `library.Options`. |
| `SetFolder(folder)` | — | Sets folder and builds it. |
| `BuildFolderTree()` | `true` or `false,error` | Creates Folder and settings subfolder. |
| `SetIgnoreIndexes(list)` | — | Adds IDs to persistent ignore set. Calls do not clear older ignores. |
| `IgnoreThemeSettings()` | — | Ignores InterfaceTheme, AcrylicToggle, TransparentToggle, ReducedMotionToggle and MenuKeybind. |
| `GetConfigPath(name)` | `path, normalizedName` or `nil,error` | Validates and builds path. |
| `Save(name)` | `boolean, nameOrError` | Serializes supported Options and writes JSON. |
| `Load(name)` | `boolean, nameOrError` | Reads, migrates and asynchronously applies values. |
| `ExportString()` | `json` or `nil,error` | Serializes current supported Options without a file. |
| `ImportString(json)` | `boolean, error?` | Validates/migrates and asynchronously applies values. |
| `RefreshConfigList()` | `{string}` | Sorted JSON config names; empty on file API failure. |
| `SetAutoloadConfig(name)` | `boolean, nameOrError` | Requires an existing valid config and writes autoload.txt. |
| `GetAutoloadConfig()` | `name?`, `error?` | Reads and validates autoload name. |
| `LoadAutoloadConfig()` | notification/nil | Loads configured autoload and reports status. |
| `BuildConfigSection(tab)` | — | Adds create/load/overwrite/autoload controls to Tab or Section. |
| `RegisterMigration(fromVersion, callback)` | — | Registers migration for exactly that schema version. |
| `Migrate(data)` | `success, dataOrError, originalVersion?` | Advances sequentially to current schema. |

Valid config names are trimmed, 1–64 characters, cannot be `.`/`..`, end in `.`, contain control/path characters, or contain `< > : " | ? *`.

Saved types: Toggle, Slider, Dropdown, Colorpicker (hex + transparency), Keybind (key + mode), and Input. Unknown/missing option IDs are skipped during load. RangeSlider is not saved.

When loading an older schema, SaveManager writes `<file>.v<oldVersion>.bak` when possible, migrates the data, then overwrites the JSON with the current schema.

### Custom migration

```lua
SaveManager:RegisterMigration(2, function(data)
    -- transform data.objects
    data.version = 3
    return data
end)
SaveManager.SchemaVersion = 3
```

Every migration must return a table and advance `data.version`; gaps, backward versions and future configs are rejected.

### Export and import JSON from code

```lua
local json, exportError = SaveManager:ExportString()
if json then
    setclipboard(json)
end

local success, importError = SaveManager:ImportString(jsonFromUser)
if not success then
    warn(importError)
end
```

Imported JSON uses the same schema validation and migrations as saved files. Unknown element types
and option IDs that do not exist in the current interface are ignored.

## InterfaceManager setup

```lua
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("MyHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
```

Default settings:

```lua
{
    Theme = "Dark",
    Acrylic = true,
    Transparency = true,
    ReducedMotion = false,
    MenuKeybind = "LeftControl",
    CompactMode = false,
    Language = "en",
    AccentColor = nil, -- stored as hex after selection
}
```

## InterfaceManager API

| Method | Description |
| --- | --- |
| `SetLibrary(library)` | Required before building UI. |
| `SetFolder(folder)` | Sets path and builds nested folders. |
| `BuildFolderTree()` | Creates every segment plus settings directory. |
| `SaveSettings()` | Writes `<Folder>/options.json`. |
| `LoadSettings()` | Merges decoded stored values into defaults. Invalid JSON is ignored. |
| `BuildInterfaceSection(tab)` | Loads settings, applies language/compact/accent, and adds all available controls. |

The generated section includes Theme, Accent Color, optional Acrylic (only when Window Acrylic support exists), Transparency, Compact Mode, Reduced Motion, Language (`en`, `th`) and Menu Keybind. Changes save immediately. The Menu Keybind object is assigned to `Fluent.MinimizeKeybind`.

## Executor requirements

SaveManager and InterfaceManager expect filesystem compatibility. At minimum their complete workflow uses `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`, and `listfiles`. Wrap addon initialization in `pcall` or disable persistence when targeting executors without these functions.

