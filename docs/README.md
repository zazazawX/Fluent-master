# Fluent documentation

เอกสารชุดนี้อ้างอิงจาก source code ใน repository โดยตรง และออกแบบให้แยกหน้าไปใช้กับเว็บไซต์ documentation ได้ทันที

## Contents

1. [Getting started](getting-started.md) — การติดตั้ง โครงสร้างพื้นฐาน และตัวอย่างเต็ม
2. [Core library](core-library.md) — `Fluent`, Window, Tab, Dialog, Notification, Command Palette และ Error Boundary
3. [Elements](elements.md) — config, methods, values และ callbacks ของ element ทุกชนิด
4. [Key System](key-system.md) — local keys, custom API และ provider presets ทุกแบบ
5. [SaveManager and InterfaceManager](managers.md) — config persistence, migration, autoload และ interface settings
6. [StandalonePanel](standalone-panel.md) — Fluent-themed focused forms that run separately from the main window

## Public files

| File | Purpose |
| --- | --- |
| `dist/main.lua` | Fluent library bundle |
| `Addons/KeySystem.lua` | Key verification UI and providers |
| `Addons/SaveManager.lua` | Save/load element values |
| `Addons/InterfaceManager.lua` | Theme and interface preference UI |
| `Addons/StandalonePanel.lua` | Separate focused task/form UI |
| `Example.lua` | Complete working example |

## Supported themes

`Dark`, `Darker`, `Light`, `Aqua`, `Amethyst`, `Rose` and a runtime `Custom` theme created by `Window:AddThemeCustomizer()`.

## Important conventions

- Methods use `:`. Write `Fluent:Notify(...)`, not `Fluent.Notify(...)`.
- Elements with an `Id` are stored in `Fluent.Options[Id]`.
- An `Id` must be unique. Reusing it replaces the reference used by managers and commands.
- `Color3`, `UDim2`, `Enum.KeyCode` and other Roblox values are passed as real Roblox values, not strings, unless explicitly documented.
- File persistence requires executor functions such as `readfile`, `writefile`, `isfile`, `isfolder`, `makefolder` and `listfiles`.
- Remote loading and third-party key providers require compatible HTTP functions.

