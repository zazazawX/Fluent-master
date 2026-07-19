# Key System

## Load and initialize

```lua
local KeySystem = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/KeySystem.lua"
))()

KeySystem:SetLibrary(Fluent)
```

`SetLibrary` is required before `CreateKeySystem`.

## `KeySystem:CreateKeySystem(config)`

Creates a responsive verification overlay. The dark overlay covers the full viewport, including the CoreGui inset area, while the key card remains centered and size-constrained. It returns no public controller; the UI owns its lifecycle.

### General config

| Field | Type | Required/default | Description |
| --- | --- | --- | --- |
| `OnVerified` | `function` | required | Runs asynchronously after successful verification and UI cleanup. |
| `Title` | `string` | `Key System` | Heading. |
| `SubTitle` | `string` | `Verification Required` | Secondary heading. |
| `Acrylic` | `boolean` | true | Set false to avoid key-screen blur. Previous Fluent acrylic state is restored on exit. |
| `OverlayTransparency` | `number` | `0.55` | Full-screen dark overlay transparency. |
| `Discord` | `string?` | nil | Shows Discord button and copies this value. |
| `GetKeyLink` | `string?` | provider-generated/nil | Explicit link copied by Get Key; takes priority. |
| `ShowReopenButton` | `boolean` | false | If true, close hides overlay and leaves a small KEY reopen button. False destroys the key UI. |
| `SaveKey` | `boolean` | false/nil | Saves a verified key in session and, when supported, a file. |
| `SavePath` | `string` | `fluent-key.txt` | Session/file key identifier. Use a unique path per script/service. |
| `BruteForceProtection` | `boolean` | true | False disables attempt lockout. |
| `MaxAttempts` | `number` | `5` | Failed attempts before lockout. |
| `LockoutDuration` | `number` | `60` | Lockout seconds. |

Saved keys are whitespace-stripped when read. A saved key is revalidated every run; saving does not bypass provider validation. Without file APIs it survives only while the executor environment/session store remains alive.

## Verification priority

Only the first configured strategy in this order is used:

1. `Providers`
2. `API`
3. `Preset`
4. `Callback`
5. `Key`
6. `Keys`

Do not configure multiple strategies unless you intentionally want this priority behavior.

## Static key

```lua
KeySystem:CreateKeySystem({
    Title = "Test Key",
    Key = "123456",
    SaveKey = true,
    SavePath = "my-hub/key.txt",
    OnVerified = function()
        StartScript()
    end,
})
```

Multiple keys:

```lua
Keys = { "KEY-A", "KEY-B" }
```

## Callback verification

```lua
Callback = function(key)
    return key == "accepted"
end
```

It must return exactly `true`. Errors become failed verification.

## Generic API

```lua
API = {
    Url = "https://example.com/verify/{key}",
    Method = "GET",
    Headers = { Authorization = "Bearer token" },
    SuccessField = "data.valid",
    SuccessValues = { true, "valid" },
}
```

| API field | Default | Description |
| --- | --- | --- |
| `Url` / `URL` | required | `{key}` is replaced. |
| `Method` | `GET` | GET, POST, etc. |
| `AppendKey` | true for GET | Appends a query key when URL has no `{key}`. |
| `KeyParam` | `key` | GET query parameter name. |
| `Headers` | `{}` | Request headers. |
| `Body` | nil | String body or table. A table is copied, receives the key field, then JSON-encoded. |
| `KeyField` | `key` | Body table field containing the key. |
| `Request` | executor resolver | Custom request function. |
| `SuccessField` | `success` | Dot path in JSON, e.g. `data.valid`. |
| `SuccessValues` | standard truth values | Exact accepted values. |
| `CheckFunction(response, key)` | nil | Custom response parser; must return true. |

Without `SuccessValues`, accepted decoded values are `true`, `"true"`, `"success"`, and `"valid"`. A non-JSON response passes only when it contains literal `true`. Non-GET requires a request-compatible function.

## Multiple providers

Providers are attempted in array order; the first true result grants access.

```lua
Providers = {
    { Callback = function(key) return key == "LOCAL" end },
    { Preset = "PandaAuthV4", PresetConfig = { ServiceId = "SERVICE_ID" } },
    { API = { Url = "https://example.com/check/{key}", SuccessField = "valid" } },
}
```

For a generic provider, fields may also be placed directly on the provider instead of inside `API`.

## Provider presets

Available names: `PandaAuth`, `PandaAuthV2`, `PandaAuthV3`, `PandaAuthV4`, `Luaguard`, `Keyguard`, `Custom`.

### PandaAuth V4 / PUSL-V4

```lua
KeySystem:CreateKeySystem({
    Preset = "PandaAuthV4",
    PresetConfig = {
        ServiceId = "YOUR_SERVICE_ID",
        Premium = false,
        Debug = false,
        KickOnDetect = false,
        GetKeyBaseUrl = "https://ads.pandauth.com",
    },
    SaveKey = true,
    SavePath = "my-hub/panda-v4.txt",
    OnVerified = StartScript,
})
```

V4 first uses `PresetConfig.Client` or injected `getgenv().PandaAuthV4` when it exposes `Validate`. This is the Kryptic Vault path and uses `Validate_Premium` when premium is required. Otherwise it fetches PUSL from `LibraryUrl` (default `https://secure.pandauth.com/pv4/lib`), configures it, validates, and starts the provider's own session behavior.

V4 fields: `ServiceId`/`serviceId`, `Client`, `Premium`/`RequirePremium`, `LibraryUrl`, `Debug`/`debug`, `KickOnDetect`/`kickOnDetect`, and `GetKeyBaseUrl`.

Kryptic Vault must inject `PandaAuthV4`; the standalone loader cannot manufacture the Vault-injected object. When not injected, the code intentionally falls back to external PUSL-V4.

### PandaAuth V3

V3 requires a Pelinda-compatible client supplied as `Client` or global `Pelinda`.

```lua
PresetConfig = {
    ServiceId = "YOUR_SERVICE_ID",
    Client = Pelinda,
    SilentMode = true,
    SecurityLevel = 1,
    Retries = 3,
    RetryDelay = 0.5,
    RequirePremium = false,
}
```

Successful status must equal `"validated!!"`. Premium reads `getgenv().__PELINDA_IS_PREMIUM__`. Get Key uses `Client.GetKeyLink({Service = ...})`.

### PandaAuth V2

Uses POST `{ServiceID, HWID, Key}` to `BaseURL .. "/keys/validate"` (`BaseURL` defaults to `https://api.pandauth.com/api/v1`). Requires `request`, `http_request`, `syn.request`, or `PresetConfig.Request`. Success means `Authenticated_Status == "Success"`; premium additionally requires `Key_Premium == true`.

Fields: `ServiceId`, `BaseURL`, `Request`, `HWID`, `GetHWID`, `Premium`/`RequirePremium`, `GetKeyBaseUrl`.

### Legacy PandaAuth

Uses GET against the legacy PandaDevelopment gateway with `PresetConfig.Service`.

### Luaguard and Keyguard

Both use `PresetConfig.Project`; success accepts provider JSON `success`/`valid` (Luaguard also accepts `status == "success"`).

### Custom preset

Uses `PresetConfig.Url`, replaces `{key}` or appends `key=`, and optionally calls `PresetConfig.CheckFunction(response)`. Prefer the newer top-level `API` config for full method/header/body control.

## Hardware ID resolution

Panda V2/V4 Get Key resolves in this order:

1. Explicit `HWID`.
2. `GetHWID()` callback.
3. Executor `gethwid()`.
4. `RbxAnalyticsService:GetClientId()` without hyphens.
5. LocalPlayer UserId.

## UI behavior

- Enter submits the input.
- Show/Hide changes only display masking.
- Verify is disabled and a spinner appears during asynchronous validation.
- Invalid keys update status, shake the card, count attempts, and may trigger lockout.
- Success saves when enabled, fades/destroys UI, restores acrylic, then spawns `OnVerified`.
- Get Key copies the explicit/generated link; it does not open a browser.
- Discord copies the configured string.

