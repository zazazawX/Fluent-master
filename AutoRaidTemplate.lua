-- Auto Raid controller for a Roblox experience you own or are authorized to test.
-- Connect the functions in RaidAdapter to server-validated APIs in your own game.

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/dist/main.lua?v=" .. tostring(math.random(1, 100000))))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/SaveManager.lua?v=" .. tostring(math.random(1, 100000))))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/InterfaceManager.lua?v=" .. tostring(math.random(1, 100000))))()

local Window = Fluent:CreateWindow({
    Title = "Auto Raid",
    SubTitle = "Authorized test controller",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
    Raid = Window:AddTab({ Title = "Raid", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- Replace only this adapter with the server-validated raid API from your game.
-- Do not trust the client for rewards, damage, cooldowns, or completion checks.
local RaidAdapter = {}

function RaidAdapter:IsInRaid()
    -- Example: return game.ReplicatedStorage.RaidState.InProgress.Value
    return false
end

function RaidAdapter:StartRaid(raidName)
    -- Example for your own game:
    -- game.ReplicatedStorage.Remotes.RequestRaidStart:FireServer(raidName)
    warn("RaidAdapter:StartRaid is not connected:", raidName)
end

function RaidAdapter:IsRaidComplete()
    -- Example: return game.ReplicatedStorage.RaidState.Completed.Value
    return false
end

function RaidAdapter:LeaveRaid()
    -- Example: game.ReplicatedStorage.Remotes.RequestRaidLeave:FireServer()
end

local State = {
    Running = false,
    SelectedRaid = "Easy",
    RunId = 0,
}

local Status = Tabs.Raid:AddParagraph({
    Title = "Status",
    Content = "Idle",
})

local function setStatus(text)
    Status:SetDesc(text)
end

Tabs.Raid:AddDropdown("SelectedRaid", {
    Title = "Select Raid",
    Values = { "Easy", "Normal", "Hard" },
    Multi = false,
    Default = "Easy",
    Callback = function(value)
        State.SelectedRaid = value
    end,
})

Tabs.Raid:AddSlider("RaidPollDelay", {
    Title = "Check interval",
    Description = "Seconds between state checks",
    Default = 1,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
})

Tabs.Raid:AddSlider("NextRaidDelay", {
    Title = "Next raid delay",
    Description = "Seconds to wait before starting another raid",
    Default = 5,
    Min = 1,
    Max = 30,
    Rounding = 0,
})

local function waitWhileActive(seconds, runId)
    local finishAt = os.clock() + seconds
    while State.Running and State.RunId == runId and os.clock() < finishAt do
        task.wait(math.min(0.25, finishAt - os.clock()))
    end
    return State.Running and State.RunId == runId
end

local function runAutoRaid(runId)
    while State.Running and State.RunId == runId do
        local ok, err = pcall(function()
            if not RaidAdapter:IsInRaid() then
                setStatus("Starting: " .. State.SelectedRaid)
                RaidAdapter:StartRaid(State.SelectedRaid)
            elseif RaidAdapter:IsRaidComplete() then
                setStatus("Raid complete")

                if Options.AutoLeaveRaid.Value then
                    RaidAdapter:LeaveRaid()
                end

                if not Options.RepeatRaid.Value then
                    Options.AutoRaid:SetValue(false)
                    return
                end

                setStatus("Waiting for next raid")
                waitWhileActive(Options.NextRaidDelay.Value, runId)
            else
                setStatus("Raid in progress: " .. State.SelectedRaid)
            end
        end)

        if not ok then
            setStatus("Error: " .. tostring(err))
            Fluent:Notify({
                Title = "Auto Raid stopped",
                Content = tostring(err),
                Duration = 6,
            })
            Options.AutoRaid:SetValue(false)
            return
        end

        if not waitWhileActive(Options.RaidPollDelay.Value, runId) then
            break
        end
    end

    setStatus("Idle")
end

Tabs.Raid:AddToggle("RepeatRaid", {
    Title = "Repeat Raid",
    Default = true,
})

Tabs.Raid:AddToggle("AutoLeaveRaid", {
    Title = "Leave when complete",
    Default = true,
})

Tabs.Raid:AddToggle("AutoRaid", {
    Title = "Auto Raid",
    Description = "Starts the selected raid and repeats after completion",
    Default = false,
    Callback = function(enabled)
        State.Running = enabled
        State.RunId += 1

        if enabled then
            local runId = State.RunId
            task.spawn(runAutoRaid, runId)
        else
            setStatus("Idle")
        end
    end,
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AutoRaid")
SaveManager:SetFolder("AutoRaid/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

