-- StandalonePanel example: Form on the left, History on the right.
local Fluent = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/dist/main.lua"
))()

local StandalonePanel = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/StandalonePanel.lua"
))()

StandalonePanel:SetLibrary(Fluent)

local Panel = StandalonePanel:CreatePanel({
    Title = "Secure Mail",
    Icon = "mail",
    MetricTitle = "Items",
    Metric = 0,
    Theme = "Dark",
    AccentColor = Color3.fromRGB(96, 205, 255),
    Acrylic = false,
    OverlayTransparency = 0.72,

    FormWidthScale = 0.44,
    StackBreakpoint = 430,
    InputWidthScale = 0.82,
    InputHeight = 32,

    PreviewTitle = "History",
    Preview = "Ready.",
    ShowHistory = true,
    HistoryTimestamp = true,
    LogLimit = 30,

    ActionText = "Dispatch",
    ActionIcon = "send",
    SubmittingText = "Dispatching...",
    SuccessText = "Dispatched",

    Confirm = {
        Title = "Confirm dispatch",
        Content = "Check the information before continuing.",
        ConfirmText = "Dispatch",
        CancelText = "Cancel",
    },

    Fields = {
        {
            Id = "Username",
            Type = "Input",
            Title = "Recipient username",
            Description = "Enter the exact Roblox username.",
            Icon = "user",
            Placeholder = "Enter username",
            Required = true,
            Min = 3,
            Max = 20,
            Pattern = "^[%w_]+$",
            PatternMessage = "Letters, numbers and underscore only",
        },
        {
            Id = "Amount",
            Type = "Number",
            Title = "Item amount",
            Description = "Choose an amount from 1 to 100.",
            Icon = "package",
            Default = 20,
            Required = true,
            Min = 1,
            Max = 100,
        },
        {
            Id = "Delivery",
            Type = "Choice",
            Title = "Delivery method",
            Icon = "tags",
            Values = { "Private", "Public", "Secure", "Fast" },
            Default = "Secure",
        },
        {
            Id = "Region",
            Type = "Dropdown",
            Title = "Destination region",
            Icon = "map-pin",
            Values = { "Automatic", "Asia", "Europe", "North America" },
            Default = "Automatic",
            Required = true,
        },
        {
            Id = "Notify",
            Type = "Toggle",
            Title = "Delivery notification",
            Icon = "bell",
            Default = true,
        },
        {
            Id = "Message",
            Type = "Multiline",
            Title = "Message",
            Icon = "message-square",
            Placeholder = "Optional message...",
            Height = 76,
            Max = 160,
        },
    },

    OnSubmit = function(Values, Controller)
        task.wait(1)
        Controller:SetMetric(Values.Amount, "Items")

        -- The returned string is appended to History automatically.
        return string.format(
            "Sent %d item(s) to %s via %s (%s)",
            Values.Amount,
            Values.Username,
            Values.Delivery,
            Values.Region
        )
    end,
})

-- Controller examples:
-- Panel:AppendLog("Manual history entry")
-- Panel:SetValue("Username", "Builderman")
-- Panel:SetPreview("Custom text", "Preview")
-- Panel:ClearHistory()
-- Panel:CopyHistory()
-- Panel:Submit()
-- Panel:Close()
-- Panel:Open()
-- Panel:Destroy()
