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
| `ExportString(options?)` | `json` or `nil,error` | Serializes current supported Options without a file. |
| `ImportString(json, options?)` | `boolean, countOrError` | Validates/migrates and applies values. |
| `ExportFile(name, options?)` | `boolean, pathOrError` | Writes a portable JSON config to the settings folder. |
| `ImportFile(name, options?)` | `boolean, countOrError` | Reads and imports a portable JSON config. |
| `PreviewImport(json, options?)` | `boolean, previewOrError` | Reports changed and skipped options without applying them. |
| `Reset(options?)` | `true, count` | Restores values captured when `SetLibrary` was called. |
| `SetMetadata(table)` | — | Adds app/game metadata to future exports. |
| `SetOptionCategory(id, category)` | — | Assigns one option to an export category. |
| `SetCategoryIndexes(category, ids)` | — | Assigns several option IDs to one category. |
| `GetCategories()` | `{string}` | Returns sorted configured category names. |
| `SetShareProvider(provider)` | — | Configures external `Upload` and `Download` callbacks. |
| `CreateShareCode(options?)` | `boolean, codeOrError` | Uploads JSON through the configured share provider. |
| `ImportShareCode(code, options?)` | `boolean, countOrError` | Downloads and imports a share code. |
| `SetCloudProvider(provider)` | — | Configures external `Save` and `Load` callbacks. |
| `SaveCloud(key, options?)` | `boolean, result` | Saves the current config through the cloud provider. |
| `LoadCloud(key, options?)` | `boolean, countOrError` | Loads and applies a cloud config. |
| `RefreshConfigList()` | `{string}` | Sorted JSON config names; empty on file API failure. |
| `SetAutoloadConfig(name)` | `boolean, nameOrError` | Requires an existing valid config and writes autoload.txt. |
| `GetAutoloadConfig()` | `name?`, `error?` | Reads and validates autoload name. |
| `LoadAutoloadConfig()` | notification/nil | Loads configured autoload and reports status. |
| `BuildConfigSection(tab)` | — | Adds save/load/autoload and portable JSON controls to Tab or Section. |
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

### Metadata and cross-game protection

Every new export contains `gameId` and `placeId`. Game matching is enabled by default during portable
imports. Add your own hub version before exporting:

```lua
SaveManager:SetMetadata({
    app = "MyHub",
    appVersion = "3.1.0",
})
```

Require an exact place or app version when importing:

```lua
SaveManager:ImportString(json, {
    strictGame = true,
    strictPlace = true,
    strictVersion = true,
})
```

Legacy configs without metadata remain importable.

### Categories, preview, Merge, Replace and Reset

Categories are assigned by option ID:

```lua
SaveManager:SetCategoryIndexes("Farm", {
    "AutoFarm",
    "SelectedMob",
})
SaveManager:SetCategoryIndexes("Raid", {
    "AutoRaid",
    "RaidDifficulty",
})
SaveManager:SetOptionCategory("SelectedIsland", "Teleport")
```

Export only selected categories:

```lua
local json = SaveManager:ExportString({
    categories = { "Farm", "Raid" },
})
```

Preview and apply:

```lua
local options = {
    categories = { "Farm" },
    mode = "merge",
}

local ok, preview = SaveManager:PreviewImport(json, options)
if ok then
    print("Changes:", #preview.changes)
    print("Skipped:", #preview.skipped)
end

SaveManager:ImportString(json, options)
```

`merge` changes only values present in the JSON. `replace` first restores matching options to their
captured defaults and then applies the JSON. `SaveManager:Reset({ categories = { "Farm" } })` resets
only Farm. Call `SaveManager:CaptureDefaults()` again if your application intentionally changes what
should count as the defaults after `SetLibrary`.

### File transfer

```lua
SaveManager:ExportFile("farm-profile", {
    categories = { "Farm" },
})

SaveManager:ImportFile("farm-profile", {
    mode = "replace",
})
```

Both methods use `<Folder>/settings/<name>.json` and the same safe-name validation as regular configs.

### Share code provider

Share codes require storage controlled by you. The library deliberately does not send user settings
to a built-in third-party server.

```lua
SaveManager:SetShareProvider({
    Upload = function(self, json)
        -- POST json to your API and return a short code.
        return "A7K2Q9"
    end,
    Download = function(self, code)
        -- GET the JSON associated with code from your API.
        return downloadedJSON
    end,
})

local ok, code = SaveManager:CreateShareCode({ categories = { "Farm" } })
SaveManager:ImportShareCode(code, { mode = "merge" })
```

The provider should authenticate requests, use HTTPS, expire codes, rate-limit creation and downloads,
and enforce a small maximum JSON size.

### Cloud provider

```lua
SaveManager:SetCloudProvider({
    Save = function(self, key, json)
        -- Store json for the authenticated user.
        return true
    end,
    Load = function(self, key)
        -- Return the authenticated user's stored JSON.
        return downloadedJSON
    end,
})

SaveManager:SaveCloud("primary")
SaveManager:LoadCloud("primary", { mode = "replace" })
```

Authentication belongs in the provider. Do not embed a master API secret in a client-side Roblox
script; exchange a short-lived user token with your backend instead.

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

