local Fluent = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/dist/main.lua"
))()

local StandalonePanel = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/StandalonePanel.lua"
))()

StandalonePanel:SetLibrary(Fluent)

local Panel = StandalonePanel:CreatePanel({
    Title = "Secure Mail",
    MetricTitle = "Total",
    Metric = 50,
    PreviewTitle = "History",
    Preview = "Ready to dispatch.",
    ActionText = "Dispatch Secure Mail",
    SubmittingText = "Dispatching...",
    OverlayTransparency = 0.72,
    Theme = "Dark",
    AccentColor = Color3.fromRGB(96, 205, 255),
    Acrylic = false, -- No screen blur
    PanelTransparency = 0.02,
    InputTransparency = 0.02,
    InputBorderTransparency = 0.35,
    CloseOnEscape = true,
    DestroyOnClose = false,

    Fields = {
        {
            Id = "Username",
            Type = "Input",
            Title = "Recipient username",
            Placeholder = "Enter username",
        },
        {
            Id = "Amount",
            Type = "Number",
            Title = "Item amount",
            Placeholder = "0",
            Default = 20,
        },
        {
            Id = "Delivery",
            Type = "Choice",
            Title = "Category",
            Values = { "Private", "Public", "Secure", "Fast" },
            Default = "Secure",
        },
    },

    OnSubmit = function(Values, Controller)
        assert(Values.Username and Values.Username ~= "", "Username is required")
        assert(Values.Amount and Values.Amount > 0, "Amount must be greater than zero")

        task.wait(1) -- Replace with your real action.

        Controller:SetMetric(Values.Amount, "Last amount")
        return string.format(
            "Sent %d item(s) to %s using %s delivery.",
            Values.Amount,
            Values.Username,
            Values.Delivery
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

