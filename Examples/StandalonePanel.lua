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
    MetricTitle = "Total",
    Metric = 50,
    PreviewTitle = "History",
    Preview = "Ready to dispatch.",
    ActionText = "Dispatch Secure Mail",
    ActionIcon = "send",
    SubmittingText = "Dispatching...",
    SuccessText = "Mail dispatched",
    SuccessDuration = 1.5,
    OverlayTransparency = 0.72,
    Theme = "Dark",
    AccentColor = Color3.fromRGB(96, 205, 255),
    Acrylic = false, -- No screen blur
    PanelTransparency = 0.02,
    InputTransparency = 0.02,
    InputBorderTransparency = 0.35,
    InputHeight = 32,
    InputHorizontalInset = 4,
    CloseOnEscape = true,
    DestroyOnClose = false,
    HistoryTimestamp = true,

    Confirm = {
        Title = "Confirm dispatch",
        Content = "Review the recipient, amount, and delivery options before continuing.",
        ConfirmText = "Dispatch",
        CancelText = "Go back",
    },

    Fields = {
        {
            Id = "Username",
            Type = "Input",
            Title = "Recipient username",
            Description = "The exact Roblox username that will receive the mail.",
            Icon = "user",
            Placeholder = "Enter username",
            Required = true,
            Min = 3,
            Max = 20,
            Pattern = "^[%w_]+$",
            PatternMessage = "Use letters, numbers, and underscore only",
        },
        {
            Id = "Amount",
            Type = "Number",
            Title = "Item amount",
            Description = "Choose an amount from 1 to 100.",
            Icon = "package",
            Placeholder = "0",
            Default = 20,
            Required = true,
            Min = 1,
            Max = 100,
        },
        {
            Id = "Delivery",
            Type = "Choice",
            Title = "Category",
            Description = "Controls how the mail is processed.",
            Icon = "tags",
            Values = { "Private", "Public", "Secure", "Fast" },
            Default = "Secure",
        },
        {
            Id = "Region",
            Type = "Dropdown",
            Title = "Destination region",
            Description = "Dropdown field example.",
            Icon = "map-pin",
            Values = { "Automatic", "Asia", "Europe", "North America" },
            Default = "Automatic",
            Required = true,
        },
        {
            Id = "Notification",
            Type = "Toggle",
            Title = "Delivery notification",
            Description = "Notify when the action is completed.",
            Icon = "bell",
            Default = true,
        },
        {
            Id = "Message",
            Type = "Multiline",
            Title = "Message",
            Description = "Optional note included with this delivery.",
            Icon = "message-square",
            Placeholder = "Write a short note...",
            Height = 76,
            Max = 160,
        },
    },

    OnSubmit = function(Values, Controller)
        task.wait(1) -- Replace with your real action.

        Controller:SetMetric(Values.Amount, "Last amount")
        return string.format(
            "Sent %d item(s) to %s using %s delivery (%s).",
            Values.Amount,
            Values.Username,
            Values.Delivery,
            Values.Region
        )
    end,

    OnClose = function(Controller)
        print("Standalone panel closed", Controller.Opened)
    end,
})

-- Controller examples:
-- Panel:Open()
-- Panel:Close()
-- Panel:SetValue("Username", "Builderman")
-- Panel:SetPreview("Custom preview text", "Preview")
-- Panel:AppendLog("A new history line")
-- Panel:Submit()
-- Panel:Destroy()

