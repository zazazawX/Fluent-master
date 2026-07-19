-- StandalonePanel example: Form on the left, History on the right.
local Fluent = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/dist/main.lua"
))()

local StandalonePanel = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/StandalonePanel.lua"
))()

StandalonePanel:SetLibrary(Fluent)

local ItemsByCategory = {
    Fruits = { "Tomato [1.58kg] [x1]", "Dragon's Breath [10.05kg] [x1]", "Corn [4.84kg] [x1]" },
    Seeds = { "Corn [x1]", "Bamboo [x10]", "Tulip [x13]", "Blueberry [x8]", "Carrot [x18]" },
    Pets = { "Red Fox [x1]", "Dragonfly [x1]", "Raccoon [x2]" },
    Gears = { "Trowel [x5]", "Sprinkler [x2]", "Teleport Pad [x1]" },
}

local function ItemList(Category)
    return table.concat(ItemsByCategory[Category] or {}, "\n\n")
end

local Panel = StandalonePanel:CreatePanel({
    Title = "Secure Mail",
    Icon = "mail",
    MetricTitle = "Items",
    Metric = 0,
    Theme = "Dark",
    AccentColor = Color3.fromRGB(96, 205, 255),
    Acrylic = false,
    OverlayTransparency = 0.72,

    FormWidthScale = 0.42,
    StackBreakpoint = 430,
    InputWidthScale = 0.82,
    InputHeight = 32,

    PreviewTitle = "Available Items",
    Preview = ItemList("Fruits"),
    HistoryTitle = "Gift Sending History",
    ShowHistory = false,
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
            Id = "Category",
            Type = "Choice",
            Title = "Target data category",
            Icon = "tags",
            Values = { "Fruits", "Seeds", "Pets", "Gears" },
            Default = "Fruits",
            OnChanged = function(Value, Controller)
                Controller:SetPreview(ItemList(Value), Value .. " Items")
            end,
        },
    },

    OnSubmit = function(Values, Controller)
        task.wait(1)
        Controller:SetMetric(Values.Amount, "Items")

        -- The returned string is appended to History automatically.
        return string.format("To: %s\n%s | %s | x%d", Values.Username, Values.Category, (ItemsByCategory[Values.Category] or {})[1] or "Unknown", Values.Amount)
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
