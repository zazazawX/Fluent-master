-- รอให้ตัวเกมและกล้องโหลดเสร็จสมบูรณ์ 100% ก่อนรัน UI เพื่อป้องกัน Error Lacking capability
repeat task.wait() until game:IsLoaded()
repeat task.wait() until workspace.CurrentCamera
pcall(function() repeat task.wait() until game:GetService("CoreGui") end)

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/6ee9b37/dist/main.lua?v=" .. tostring(math.random(1, 100000))))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/SaveManager.lua?v=" .. tostring(math.random(1, 100000))))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/InterfaceManager.lua?v=" .. tostring(math.random(1, 100000))))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SimpleWorldLib = nil
local Bridges = {}

pcall(function()
    SimpleWorldLib = require(ReplicatedStorage:WaitForChild("SimpleWorld"):WaitForChild("Library"))
    
    Bridges.RequestChangeWorld = SimpleWorldLib.getBridge("RequestChangeWorld")
    
    Bridges.RaidJoin = SimpleWorldLib.getBridge("RaidJoin")
    Bridges.RaidLeave = SimpleWorldLib.getBridge("RaidLeave")
    Bridges.RaidAutoArise = SimpleWorldLib.getBridge("RaidAutoArise")
    Bridges.RaidGateTeleport = SimpleWorldLib.getBridge("RaidGateTeleport")
    Bridges.RaidWaveCleared = SimpleWorldLib.getBridge("RaidWaveCleared")
    Bridges.RaidMapReady = SimpleWorldLib.getBridge("RaidMapReady")
    Bridges.RaidEnded = SimpleWorldLib.getBridge("RaidEnded")
    
    Bridges.TimeTrialJoin = SimpleWorldLib.getBridge("TimeTrialJoin")
    Bridges.TimeTrialLeave = SimpleWorldLib.getBridge("TimeTrialLeave")
    
    Bridges.DungeonJoin = SimpleWorldLib.getBridge("DungeonJoin")
    Bridges.DungeonLeave = SimpleWorldLib.getBridge("DungeonLeave")
end)

local PlayerState = {
    InRaid = false,
    InTrial = false,
    InDungeon = false,
    IsJoiningAny = false
}

pcall(function()
    if SimpleWorldLib.getBridge("RaidMapReady") then SimpleWorldLib.getBridge("RaidMapReady"):Connect(function() PlayerState.InRaid = true end) end
    if SimpleWorldLib.getBridge("RaidEnded") then SimpleWorldLib.getBridge("RaidEnded"):Connect(function() PlayerState.InRaid = false end) end
    if SimpleWorldLib.getBridge("TimeTrialMapReady") then SimpleWorldLib.getBridge("TimeTrialMapReady"):Connect(function() PlayerState.InTrial = true end) end
    if SimpleWorldLib.getBridge("TimeTrialEnded") then SimpleWorldLib.getBridge("TimeTrialEnded"):Connect(function() PlayerState.InTrial = false end) end
    if SimpleWorldLib.getBridge("DungeonMapReady") then SimpleWorldLib.getBridge("DungeonMapReady"):Connect(function() PlayerState.InDungeon = true end) end
    if SimpleWorldLib.getBridge("DungeonEnded") then SimpleWorldLib.getBridge("DungeonEnded"):Connect(function() PlayerState.InDungeon = false end) end
end)

local Window = Fluent:CreateWindow({
    Title = "Auto Farm Hub",
    SubTitle = "by Lume.Dev",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "sword" }),
    Raid = Window:AddTab({ Title = "Gamemodes", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local PlayerLog = Tabs.Main:AddParagraph({ Title = "Active Data Tracking", Content = "Clan: Loading..." })

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local clanValue = game.Players.LocalPlayer.PlayerGui.MainGui.PlayerData.Clan.Value
            PlayerLog:SetDesc("Clan: " .. tostring(clanValue))
        end)
    end
end)

local AutoFarmEnabled = false
Tabs.Main:AddToggle("AutoFarmToggle", { Title = "เปิดใช้งาน Auto Combat", Default = false }):OnChanged(function(Value)
    AutoFarmEnabled = Value
end)

local RaidMap = {
    ["Timeless Raid"] = "World0", ["Ninja Raid"] = "World1", ["Tomb Raid"] = "World1Aldedo",
    ["InfinityCastle"] = "World6", ["Clover Raid"] = "World7", ["Soul Raid"] = "World10"
}
local TrialMap = { ["Timetrial easy"] = "Easy", ["Timetrial Medium"] = "Medium" }
local DungeonMap = { ["FireDungeon"] = "World9Dungeon" }

local GamemodeWorlds = {
    ["World0"] = 0, ["World1"] = 1, ["World1Aldedo"] = 1, ["World5"] = 5,
    ["World6"] = 6, ["World7"] = 7, ["World10"] = 10,
    ["Easy"] = 1, ["Medium"] = 1,
    ["World9Dungeon"] = 9
}

local AutoJoinRaid, AutoFarmRaid = false, false
local SelectedRaidName = "Timeless Raid"
local AutoJoinGate = false
local SelectedGateRanks = {}
local AutoJoinTrial, AutoFarmTrial, LeaveForTrial = false, false, false
local SelectedTrialNames = { ["Timetrial easy"] = true } 
local AutoJoinFire, AutoFarmFire, LeaveForFire = false, false, false
local SelectedDungeonName = "FireDungeon"
local DungeonTpMode = "Follow Monster"

local RaidAutoLeaveSettings = {
    World0 = { Enabled = false, Wave = 50 },
    World1 = { Enabled = false, Wave = 100 },
    World1Aldedo = { Enabled = false, Wave = 100 },
    World6 = { Enabled = false, Wave = 30 },
    World7 = { Enabled = false, Wave = 50 },
    World10 = { Enabled = false, Wave = 60 },
    World5 = { Enabled = false, Wave = 2 },
}
local ActiveRaidKey = nil
local CurrentRaidWave = 0
local AutoLeaveFired = false
local AutoLeaveCooldownUntil = 0

Tabs.Raid:AddSection("Raid Selection")
Tabs.Raid:AddDropdown("RaidSelect", {
    Title = "เลือกดันเจี้ยน Raid",
    Values = {"Timeless Raid", "Ninja Raid", "Tomb Raid", "InfinityCastle", "Clover Raid", "Soul Raid"},
    Multi = false, Default = 1,
}):OnChanged(function(Value) SelectedRaidName = Value end)
Tabs.Raid:AddToggle("AutoJoinRaid", { Title = "Auto Join Raid (Priority 4)", Default = false }):OnChanged(function(V) AutoJoinRaid = V end)
Tabs.Raid:AddToggle("AutoFarmRaid", { Title = "Auto Farm Raid", Default = false }):OnChanged(function(V) AutoFarmRaid = V end)
Tabs.Raid:AddToggle("AutoArise", { Title = "Auto Arise (เฉพาะ Gate)", Default = false }):OnChanged(function(V)
    if Bridges.RaidAutoArise then Bridges.RaidAutoArise:Fire(V) end
end)
Tabs.Raid:AddButton({ Title = "บังคับออกจาก Raid ทันที", Callback = function()
    if Bridges.RaidLeave then Bridges.RaidLeave:Fire() end
    PlayerState.InRaid = false
end})

Tabs.Raid:AddSection("Gate Selection")
Tabs.Raid:AddDropdown("GateRankSelect", {
    Title = "Gate Ranks (A-E)",
    Description = "Select multiple ranks; only active GamemodeNotify gates are used",
    Values = {"A", "B", "C", "D", "E"},
    Multi = true,
    Default = {},
}):OnChanged(function(Value)
    SelectedGateRanks = Value
end)
Tabs.Raid:AddToggle("AutoJoinGate", {
    Title = "Auto Join Gate (Priority 3)",
    Default = false,
}):OnChanged(function(Value)
    AutoJoinGate = Value
end)

Tabs.Raid:AddSection("Auto Leave by Raid")
local RaidAutoLeaveOptions = {
    { Id = "Timeless", Name = "Timeless Raid", Key = "World0" },
    { Id = "Ninja", Name = "Ninja Raid", Key = "World1" },
    { Id = "Tomb", Name = "Tomb Raid", Key = "World1Aldedo" },
    { Id = "Infinity", Name = "InfinityCastle", Key = "World6" },
    { Id = "Clover", Name = "Clover Raid", Key = "World7" },
    { Id = "Soul", Name = "Soul Raid", Key = "World10" },
    { Id = "Gate", Name = "Gate", Key = "World5" },
}

for _, raidOption in ipairs(RaidAutoLeaveOptions) do
    local setting = RaidAutoLeaveSettings[raidOption.Key]
    Tabs.Raid:AddInput("AutoLeaveWave" .. raidOption.Id, {
        Title = raidOption.Name .. " - Leave Wave",
        Default = tostring(setting.Wave),
        Placeholder = "Wave number",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local wave = tonumber(Value)
            if wave then
                setting.Wave = math.max(1, math.floor(wave))
            end
        end,
    })
    Tabs.Raid:AddToggle("AutoLeave" .. raidOption.Id, {
        Title = "Auto Leave " .. raidOption.Name,
        Default = false,
    }):OnChanged(function(Value)
        setting.Enabled = Value
        if not Value and ActiveRaidKey == raidOption.Key then
            AutoLeaveFired = false
        end
    end)
end

Tabs.Raid:AddSection("Time Trial Selection")
Tabs.Raid:AddDropdown("TrialSelect", {
    Title = "เลือกระดับ Time Trial",
    Values = {"Timetrial easy", "Timetrial Medium"},
    Multi = true, Default = {"Timetrial easy"},
}):OnChanged(function(Value) SelectedTrialNames = Value end)
Tabs.Raid:AddToggle("AutoJoinTrial", { Title = "Auto Join Trial (Priority 2)", Default = false }):OnChanged(function(V) AutoJoinTrial = V end)
Tabs.Raid:AddToggle("AutoFarmTrial", { Title = "Auto Farm Trial", Default = false }):OnChanged(function(V) AutoFarmTrial = V end)
Tabs.Raid:AddToggle("LeaveForTrial", { Title = "Leave Gamemode for Trial", Default = false }):OnChanged(function(V) LeaveForTrial = V end)
Tabs.Raid:AddButton({ Title = "บังคับออกจาก Time Trial ทันที", Callback = function()
    if Bridges.TimeTrialLeave then Bridges.TimeTrialLeave:Fire() end
    PlayerState.InTrial = false
end})

Tabs.Raid:AddSection("Dungeon Selection & Settings")
Tabs.Raid:AddDropdown("DungeonSelect", {
    Title = "เลือกดันเจี้ยน",
    Values = {"FireDungeon"},
    Multi = false, Default = 1,
}):OnChanged(function(Value) SelectedDungeonName = Value end)
Tabs.Raid:AddDropdown("DungeonTpMode", {
    Title = "Teleport Mode",
    Values = {"Follow Monster", "Center Room"},
    Multi = false, Default = 1,
}):OnChanged(function(Value) DungeonTpMode = Value end)
Tabs.Raid:AddToggle("AutoJoinFire", { Title = "Auto Join Fire (Priority 1)", Default = false }):OnChanged(function(V) AutoJoinFire = V end)
Tabs.Raid:AddToggle("AutoFarmFire", { Title = "Auto Farm Fire", Default = false }):OnChanged(function(V) AutoFarmFire = V end)
Tabs.Raid:AddToggle("LeaveForFire", { Title = "Leave Gamemode for Fire", Default = false }):OnChanged(function(V) LeaveForFire = V end)
Tabs.Raid:AddButton({ Title = "บังคับออกจาก Fire Dungeon ทันที", Callback = function()
    if Bridges.DungeonLeave then Bridges.DungeonLeave:Fire() end
    PlayerState.InDungeon = false
end})

local function IsNotificationActive(gamemodeType, key)
    local isActive = false
    pcall(function()
        local gamemodeNotify = game.Players.LocalPlayer.PlayerGui.HUD.Main:FindFirstChild("GamemodeNotify")
        if gamemodeNotify and gamemodeNotify:FindFirstChild("Notify_" .. gamemodeType .. "_" .. key) then
            isActive = true
        end
    end)
    return isActive
end

local function FindActiveGateKey()
    local rankPriority = {"A", "B", "C", "D", "E"}
    local keysByRank = {}

    pcall(function()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local hud = playerGui:WaitForChild("HUD")
        local gamemodeNotify = hud:WaitForChild("Main"):FindFirstChild("GamemodeNotify")
        if not gamemodeNotify then return end

        for _, card in ipairs(gamemodeNotify:GetChildren()) do
            if card:GetAttribute("GamemodePopupIsPortal") == true then
                local rank = card:GetAttribute("GamemodePopupGateRank")
                local key = string.match(card.Name, "^Notify_Raid_(.+)$")
                if type(rank) == "string" and key then
                    keysByRank[rank] = key
                end
            end
        end
    end)

    for _, rank in ipairs(rankPriority) do
        if SelectedGateRanks[rank] and keysByRank[rank] then
            return keysByRank[rank], rank
        end
    end
    return nil, nil
end

local function TeleportToWorld(worldId)
    if not worldId then return end
    pcall(function()
        local ClientFolder = ReplicatedStorage:WaitForChild("SimpleWorld"):WaitForChild("Library"):WaitForChild("Client")
        local WorldController = require(ClientFolder:WaitForChild("WorldController"))
        if WorldController:GetCurrentWorld() ~= worldId then
            if Bridges.RequestChangeWorld then
                Bridges.RequestChangeWorld:Fire(worldId)
                task.wait(4)
            end
        end
    end)
end

pcall(function()
    if Bridges.RaidMapReady then
        Bridges.RaidMapReady:Connect(function(instanceKey, raidKey)
            local resolvedKey = raidKey or instanceKey
            ActiveRaidKey = RaidAutoLeaveSettings[resolvedKey] and resolvedKey or nil
            CurrentRaidWave = 0
            AutoLeaveFired = false
        end)
    end

    if Bridges.RaidWaveCleared then
        Bridges.RaidWaveCleared:Connect(function()
            if not PlayerState.InRaid or not ActiveRaidKey then return end

            CurrentRaidWave = CurrentRaidWave + 1
            local setting = RaidAutoLeaveSettings[ActiveRaidKey]
            if setting and setting.Enabled and not AutoLeaveFired and CurrentRaidWave >= setting.Wave then
                AutoLeaveFired = true
                AutoLeaveCooldownUntil = os.clock() + 1
                if Bridges.RaidLeave then
                    Bridges.RaidLeave:Fire()
                end
                PlayerState.InRaid = false
                Fluent:Notify({
                    Title = "Auto Leave Raid",
                    Content = "Left " .. ActiveRaidKey .. " after wave " .. tostring(CurrentRaidWave),
                    Duration = 4,
                })
            end
        end)
    end

    if Bridges.RaidEnded then
        Bridges.RaidEnded:Connect(function()
            ActiveRaidKey = nil
            CurrentRaidWave = 0
            AutoLeaveFired = false
        end)
    end
end)

local function GetClosestEnemy(playerPosition)
    local closestEnemy = nil
    local shortestDist = math.huge
    local arenas = {
        workspace:FindFirstChild("DungeonArenas"),
        workspace:FindFirstChild("TimeTrialArenas"),
        workspace:FindFirstChild("RaidArenas")
    }
    
    for _, arenaContainer in pairs(arenas) do
        if arenaContainer then
            for _, room in pairs(arenaContainer:GetChildren()) do
                local enemyFolder = room:FindFirstChild("Enemies") or room:FindFirstChild("EnemySpawns") or room:FindFirstChild("EnemyRoomSpawns")
                if enemyFolder then
                    for _, enemy in pairs(enemyFolder:GetDescendants()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                            local hum = enemy:FindFirstChild("Humanoid")
                            if hum and hum.Health > 0 then
                                local dist = (enemy.HumanoidRootPart.Position - playerPosition).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    closestEnemy = enemy
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestEnemy
end

task.spawn(function()
    while task.wait() do 
        local CanCombat = false
        if PlayerState.InDungeon and AutoFarmFire then CanCombat = true end
        if PlayerState.InTrial and AutoFarmTrial then CanCombat = true end
        if PlayerState.InRaid and AutoFarmRaid then CanCombat = true end

        if CanCombat and AutoFarmEnabled then
            pcall(function()
                local character = game.Players.LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                local hrp = character.HumanoidRootPart
                local targetEnemy = GetClosestEnemy(hrp.Position)
                
                if targetEnemy then
                    local enemyHRP = targetEnemy:FindFirstChild("HumanoidRootPart")
                    local dist = (hrp.Position - enemyHRP.Position).Magnitude
                    
                    if DungeonTpMode == "Follow Monster" then
                        if dist > 6 then
                            hrp.CFrame = enemyHRP.CFrame * CFrame.new(0, 0, 4)
                        else
                            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(enemyHRP.Position.X, hrp.Position.Y, enemyHRP.Position.Z))
                        end
                    elseif DungeonTpMode == "Center Room" then
                        local spawnPart = targetEnemy.Parent.Parent:FindFirstChild("Spawn", true)
                        if spawnPart then
                            hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
                        else
                            hrp.CFrame = enemyHRP.CFrame * CFrame.new(0, 0, 4)
                        end
                    end
                    
                    -- ** ใส่คำสั่งโจมตีที่นี่ **
                    
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if PlayerState.IsJoiningAny then continue end

        local actualDungeonKey = DungeonMap[SelectedDungeonName]
        local fireDungeonActive = IsNotificationActive("Dungeon", actualDungeonKey)
        local activeTrialKey = nil
        local activeGateKey = nil
        local activeGateRank = nil
        
        for uiName, isSelected in pairs(SelectedTrialNames) do
            if isSelected then 
                local tKey = TrialMap[uiName]
                if IsNotificationActive("TimeTrial", tKey) then
                    activeTrialKey = tKey
                    break 
                end
            end
        end

        if AutoJoinGate then
            activeGateKey, activeGateRank = FindActiveGateKey()
        end

        if AutoJoinFire and fireDungeonActive then
            if PlayerState.InRaid then
                if not LeaveForFire then continue end
                if Bridges.RaidLeave then Bridges.RaidLeave:Fire() end
                task.wait(3)
                PlayerState.InRaid = false
            elseif PlayerState.InTrial then
                if not LeaveForFire then continue end
                if Bridges.TimeTrialLeave then Bridges.TimeTrialLeave:Fire() end
                task.wait(3)
                PlayerState.InTrial = false
            end
            
            if not PlayerState.InDungeon then
                PlayerState.IsJoiningAny = true
                TeleportToWorld(GamemodeWorlds[actualDungeonKey])
                if Bridges.DungeonJoin then Bridges.DungeonJoin:Fire("Join", actualDungeonKey) end
                task.wait(6)
                PlayerState.IsJoiningAny = false
                PlayerState.InDungeon = true
            end
            continue
        end

        if AutoJoinTrial and activeTrialKey and not PlayerState.InDungeon then
            if PlayerState.InRaid then
                if not LeaveForTrial then continue end
                if Bridges.RaidLeave then Bridges.RaidLeave:Fire() end
                task.wait(3)
                PlayerState.InRaid = false
            end
            
            if not PlayerState.InTrial then
                PlayerState.IsJoiningAny = true
                TeleportToWorld(GamemodeWorlds[activeTrialKey])
                if Bridges.TimeTrialJoin then Bridges.TimeTrialJoin:Fire("Join", activeTrialKey) end
                task.wait(6)
                PlayerState.IsJoiningAny = false
                PlayerState.InTrial = true
            end
            continue
        end

        if AutoJoinGate and activeGateKey and os.clock() >= AutoLeaveCooldownUntil and not PlayerState.InDungeon and not PlayerState.InTrial and not PlayerState.InRaid then
            if Bridges.RaidGateTeleport then
                PlayerState.IsJoiningAny = true
                Fluent:Notify({
                    Title = "Joining Gate",
                    Content = "Moving to World 5 for Gate Rank " .. tostring(activeGateRank),
                    Duration = 3,
                })

                TeleportToWorld(GamemodeWorlds.World5)
                task.wait(1)

                local refreshedGateKey, refreshedGateRank = FindActiveGateKey()
                local portalKey = activeGateKey
                if refreshedGateKey and refreshedGateRank == activeGateRank then
                    portalKey = refreshedGateKey
                end
                Bridges.RaidGateTeleport:Fire(portalKey)
                task.wait(6)
                PlayerState.IsJoiningAny = false
                continue
            end
        end

        if AutoJoinRaid and os.clock() >= AutoLeaveCooldownUntil and not PlayerState.InDungeon and not PlayerState.InTrial then
            if not PlayerState.InRaid then
                PlayerState.IsJoiningAny = true
                local actualRaidKey = RaidMap[SelectedRaidName]
                local raidIsActive = IsNotificationActive("Raid", actualRaidKey)

                if raidIsActive then
                    TeleportToWorld(GamemodeWorlds[actualRaidKey])
                    if Bridges.RaidJoin then Bridges.RaidJoin:Fire("Join", actualRaidKey) end
                    task.wait(6)
                    PlayerState.InRaid = true
                end
                PlayerState.IsJoiningAny = false
            end
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({ Title = "Loaded Successfully!", Content = "พร้อมใช้งาน 100% แล้วครับ", Duration = 5 })
