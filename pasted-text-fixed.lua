local config_url = "https://raw.githubusercontent.com/Zinflow/reture/refs/heads/main/Normal%20op"

local success, config_data = pcall(function()
    return loadstring(game:HttpGet(config_url))()
end)

if not success then
    warn("โหลด config ไม่ได้ ")
    return
end

if not config_data.script_enabled then
    warn("สครืิปปิด")
    return
end

-- ==========================================
-- WEAPON GROUPS CONFIG (บังคับถืออาวุธตามกลุ่ม)
-- ==========================================
local SelectedWeaponGroup = "-"
local WeaponGroups = {
    ["Combat"] = {
        "Combat", "Aizen", "Akaza", "Garou", "Gojo", "Gojo (Shibuya)", "Invincible", "Jin Mori", "Kaneki", "Naoya", "OFA", "Okarun", "Qin Shi", "Sandevistan", "Shadow", "Shigaraki", "Suiryu", "Sukuna", "Sukuna (Shibuya)", "Todoroki","Hakari"
    }, 
    ["Sword"] = { 
        "Katana","Abyssbreaker","Anti-Magic Sword","Dark Blade","Divine Bident","Dual Dagger","Dual Katana","Gryphon","Hellsing Dual Pistol","Herta's Hammer","Inverted Spear of Heaven","Kafka's Katana","Kusanagi","Metal Bat","Solemn Lament","Spiritual Katana","Tanjiro's Nichirin","Tensa Zangetsu","Venuzdonoa","Wado","Yuta's Katana","Zangetsu"
    } 
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidrootpart = character:WaitForChild("HumanoidRootPart")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Global Variable for Farm Position
_G.FarmPosMode = "Behind" -- Default

task.spawn(function()
	local PlayerGui = Player:WaitForChild("PlayerGui", 5)
	if not PlayerGui then return end

	local ToggleGui = PlayerGui:FindFirstChild("LCtrlCircleButtonUI")
	if not ToggleGui then
		ToggleGui = Instance.new("ScreenGui")
		ToggleGui.Name = "LCtrlCircleButtonUI"
		ToggleGui.ResetOnSpawn = false
		ToggleGui.Parent = PlayerGui
	end

	local imageUrl = "https://img2.pic.in.th/Hub.png"
	local imageName = "Zynx.png"
	local customImageId = ""

	if isfile and writefile and getcustomasset then
		if not isfile(imageName) then
			local success, result = pcall(function() return game:HttpGet(imageUrl) end)
			if success then writefile(imageName, result) end
		end
		if isfile(imageName) then customImageId = getcustomasset(imageName) end
	end

	local Button = ToggleGui:FindFirstChild("ToggleButton")
	if not Button then
		Button = Instance.new("ImageButton")
		Button.Name = "ToggleButton"
		Button.Size = UDim2.new(0, 60, 0, 60)
		Button.AnchorPoint = Vector2.new(0.5, 0.5)
		Button.Position = UDim2.new(0.3, 0, 0.2, 0)
		Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Button.BackgroundTransparency = 0.5
		Button.BorderSizePixel = 0
		Button.ZIndex = 10
		Button.Active = true
		Button.Draggable = true

		local UIStroke = Instance.new("UIStroke")

		if customImageId ~= "" then Button.Image = customImageId end
		Button.Parent = ToggleGui

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(0, 8)
		UICorner.Parent = Button

		Button.MouseButton1Click:Connect(function()
			if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
				if Window then Window:Minimize() end
			else
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
				task.wait(0.05)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
			end
		end)
	end
end)

function HitMon()
    for i, Equip in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
        if Equip:IsA("Tool") then
            selectedweapon = Equip.Name
            selectedtype = Equip.ToolTip
            
            local args = { "Server", selectedtype, "M1s", selectedweapon, 4 }
            game:GetService("ReplicatedStorage")
                :WaitForChild("Remotes")
                :WaitForChild("Serverside")
                :FireServer(unpack(args))
                task.wait()
                
        end
    end
end

local function EquipCombatTool()
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Combat" then
            LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(tool)
            task.wait(0.1)
            return
        end
    end
end

function UseOneSkill(skillNumber)
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local weaponType = tool.ToolTip
            local weaponName = tool.Name
            local mode = (weaponType == "Combat") and 0 or 1

            game:GetService("ReplicatedStorage").Remotes.Serverside:FireServer(
                "Server",
                weaponType,
                "Skill"..skillNumber,
                weaponName,
                mode
            )
            break
        end
    end
end
local RunService = cloneref(game:GetService('RunService'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local lplr = game.Players.LocalPlayer
local hrp = lplr.Character.HumanoidRootPart

local function Use(weaponType, attackType, weapon, m1)
    ReplicatedStorage.Remotes.Serverside:FireServer(
        'Server', weaponType, attackType, weapon, m1
    )
end

_G.EnableInstaKill = false
_G.IsInstaKilling = false

-- Global variables to manage physics kill state
_G.PhysicsKillActive = false

-- Function to handle physics simulation radius (Must be running in a loop if using physics kill)
local function StartPhysicsLoop()
    -- Apply immediately (No wait)
    pcall(function()
        local LocalPlayer = game.Players.LocalPlayer
        settings().Physics.AllowSleep = false
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
        else
            LocalPlayer.SimulationRadius = math.huge
        end
    end)

    if _G.PhysicsLoopRunning then return end
    _G.PhysicsLoopRunning = true
    
    task.spawn(function()
        local RunService = game:GetService("RunService")
        local LocalPlayer = game.Players.LocalPlayer
        while _G.PhysicsKillActive or _G.AutoKillHakari or _G.AutoBoss or _G.FEKillAura do
            RunService.Stepped:Wait() -- Stepped is better for physics ownership
            pcall(function()
                settings().Physics.AllowSleep = false
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
                
                if sethiddenproperty then
                    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                    sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
                else
                    LocalPlayer.SimulationRadius = math.huge
                end
            end)
        end
        _G.PhysicsLoopRunning = false
    end)
end

-- New Physics InstaKill Function (Replaces old burst logic)
local function instaKill(mob, force)
    -- Activate Physics Loop if not already
    _G.PhysicsKillActive = true
    StartPhysicsLoop()

    if not mob or not mob:FindFirstChild("Humanoid") or not mob:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = mob.HumanoidRootPart
    local hum = mob.Humanoid
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    
    -- [Force Owner Logic] Teleport to exact CFrame to force claim ownership
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = hrp.CFrame
    end

    -- Force unanchor and kill immediately (No waiting for ownership check in conditional)
    -- This might be the cause of delayed death if ownership isn't transferred fast enough
    -- Let's try to force update more aggressively without waiting
    
    task.spawn(function()
        for i = 1, 5 do -- Try multiple times quickly
            if hrp then
                hrp.Anchored = false
                hrp.CanCollide = false
                hrp.Velocity = Vector3.new(0, -100, 0)
            end
            
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Dead)
                hum.Health = 0
            end
            
            -- Extra force for all parts
            for _, part in pairs(mob:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, -100, 0)
                end
            end
            task.wait() -- Minimal wait
        end
    end)
end

local function removeHead(model)
    local head = model:FindFirstChild("Head")
    if head then
        head:Destroy()
    end
end

local interactduplicated = false
local function interact(path)
    if interactduplicated then return false end
    if typeof(path) ~= "Instance" or not path.Parent then return false end

    local button = path
    if not button:IsA("GuiButton") then
        button = button:FindFirstChildWhichIsA("GuiButton", true)
    end
    if not button or not button:IsDescendantOf(game) then return false end

    interactduplicated = true

    local success, err = pcall(function()
        -- GuiButton:Activate() ไม่ต้องพึ่ง SelectedObject และใช้ได้กับปุ่มเมาส์/ทัชโดยตรง
        local activated = pcall(function()
            button:Activate()
        end)

        if not activated then
            -- Fallback สำหรับ GUI ที่รับเฉพาะ navigation input
            button.Active = true
            button.Selectable = true

            local selected = pcall(function()
                GuiService.SelectedObject = button
            end)

            if selected and GuiService.SelectedObject == button then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.03)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                task.wait(0.03)
            end

            pcall(function()
                if GuiService.SelectedObject == button then
                    GuiService.SelectedObject = nil
                end
            end)
        end
    end)

    if not success then
        warn("Interact Error: " .. tostring(err))
    end

    interactduplicated = false
    return success
end

-- ==========================================
-- NEW PHYSICS & COLLISION SYSTEM (แก้ตัวจมดิน + แก้เดินไม่ได้ + ปรับตำแหน่ง)
-- ==========================================
_G.CurrentFarmTarget = nil

RunService.Stepped:Connect(function()
    local OnState = _G.AutoFarm
        or _G.AutoFarmV
        or _G.AutoBoss
        or _G.Autusummon
        or _G.AutoTanjio
        or _G.AutoTanJo
        or _G.AutoGem
        or _G.AutoMission
        or _G.AutoSorcererTeacher
        or _G.AutoAllBoss
        or _G.AutoCraftShadowCore
        or _G.AutoKanekiBlood
        or _G.AutoKanekiBloodss
        or _G.Autoherta
        or _G.Rk
        or _G.Rkd
        or _G.AutoFarmadmin
        or _G.AutoOpenChest
        or _G.AutoSummonBoss
        or _G.AutoSummonHakari
        or _G.AutoKillHakari
        or _G.AutoSummonDungeon
        or _G.AutoCraftPotionState
        or _G.AutoUsePotionState
        
    if OnState and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        -- บังคับวาร์ปและล็อกขา "เฉพาะเมื่อมีเป้าหมาย" เท่านั้น
        if _G.CurrentFarmTarget and _G.CurrentFarmTarget:FindFirstChild("HumanoidRootPart") then
            local targetCFrame = _G.CurrentFarmTarget.HumanoidRootPart.CFrame
            
            -- Logic เลือกตำแหน่งการยืน (Positions)
            if _G.FarmPosMode == "Above" then
                -- แก้ไข: ใช้ Position ล้วนๆ เพื่อให้ "บน" คือ "บนฟ้า" จริงๆ ไม่เอียงตามมอน + เพิ่มความสูงเป็น 12
                hrp.CFrame = CFrame.new(targetCFrame.Position + Vector3.new(0, 12, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
            else
                -- ข้างหลัง: ถอยหลัง 5 หน่วย (Default เดิม)
                hrp.CFrame = targetCFrame * CFrame.new(0, 0, 5)
            end
            
            -- ล็อกความเร็วทุกมิติ (เพื่อให้เกาะติดมอนสเตอร์)
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            if hum then
                hum.PlatformStand = true 
                hum.AutoRotate = false  
            end

            for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false -- ทะลุกำแพงตอนตี
                    v.Anchored = false 
                end
            end
        else
            -- เมื่อไม่มีเป้าหมาย หรือหาไม่เจอ ให้คืนค่าการเคลื่อนไหวทันที
            if hum then 
                hum.PlatformStand = false 
                hum.AutoRotate = true
            end
            
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true -- เปิดชนสิ่งของ กันตกแมพ
                end
            end
        end
    else
        -- คืนค่าปกติเมื่อปิด Toggle ทั้งหมด
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            h.PlatformStand = false
            h.AutoRotate = true
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end)

local MonFarms = {
    Bandit = {
        Bname = "Bandit",
        QuestName = "Defeat Bandits",
        QuestNameTp = "1",
        Island = "Windmill Village",
        MobFolder = "Bandit",
    },
    BanditLeader = {
        Bname = "Bandit Leader",
        QuestName = "Defeat Bandit Leader",
        QuestNameTp = "2",
        Island = "Windmill Village",
        MobFolder = "Bandit Leader",
    },
    Skeleton = {
        Bname = "Skeleton",
        QuestName = "Defeat Skeleton",
        QuestNameTp = "3",
        Island = "Whispering Jungle",
        MobFolder = "Skeleton",
    },
    PirateSkeleton = {
        Bname = "Pirate Skeleton",
        QuestName = "Defeat Pirate Skeleton",
        QuestNameTp = "4",
        Island = "Whispering Jungle",
        MobFolder = "Pirate Skeleton",
    },
    DesertThief = {
        Bname = "Desert Thief",
        QuestName = "Defeat Desert Thief",
        QuestNameTp = "5",
        Island = "Sandora Island",
        MobFolder = "Desert Thief",
    },
    KatanaMaster = {
        Bname = "Katana Master",
        QuestName = "Defeat Katana Master",
        QuestNameTp = "6",
        Island = "Sandora Island",
        MobFolder = "Katana Master",
    },
    Mihawk = {
        Bname = "Mihawk",
        QuestName = "Defeat Mihawk's",
        QuestNameTp = "7",
        Island = "Glacier Isle",
        MobFolder = "Mihawk",
    },
    SlayersTrainee = {
        Bname = "Slayer's Trainee",
        QuestName = "Defeat Slayer's Trainee",
        QuestNameTp = "8",
        Island = "Forge Isle",
        MobFolder = "Slayer's Trainee",
    },
    SnowBrawler = {
        Bname = "Snow Brawler",
        QuestName = "Defeat Snow Brawlers",
        QuestNameTp = "13",
        Island = "Xmas Island",
        MobFolder = "Snow Brawler",
    },
    SorcerersStudent = {
        Bname = "Sorcerer's Student",
        QuestName = "Defeat Sorcerer's Student",
        QuestNameTp = "9",
        Island = "Jujutsu Highschool",
        MobFolder = "Sorcerer's Student",
    },
    SorcerersTeacher = {
        Bname = "Sorcerer's Teacher",
        QuestName = "Defeat Sorcerer's Teacher",
        QuestNameTp = "10",
        Island = "Jujutsu Highschool",
        MobFolder = "Sorcerer's Teacher",
    },
    KonohaNinja = {
        Bname = "Konoha's Ninja",
        QuestName = "Defeat Konoha's Ninja",
        QuestNameTp = "11",
        Island = "Konoha Village",
        MobFolder = "Konoha's Ninja",
    },
    KonohaHeadNinja = {
        Bname = "Konoha's Head Ninja",
        QuestName = "Defeat Konoha's Head Ninja",
        QuestNameTp = "12",
        Island = "Konoha Village",
        MobFolder = "Konoha's Head Ninja",
    },
    MagicKnight = {
        Bname = "Magic Knight",
        QuestName = "Defeat Magic Knight's",
        QuestNameTp = "13",
        Island = "Hage Island",
        MobFolder = "Magic Knight",
    },
}

task.spawn(function()
local Workspace = game:GetService("Workspace")

local Main = Workspace:WaitForChild("Main", 10)
if not Main then return end

local NPCs = Main:WaitForChild("NPCs", 10)
if not NPCs then return end

local function fixPrompt(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end

-- ของที่มีอยู่แล้ว
for _, npc in ipairs(NPCs:GetChildren()) do
    for _, v in ipairs(npc:GetDescendants()) do
        fixPrompt(v)
    end
end

-- ของที่เกิดใหม่ (กันเซิร์ฟโหลดช้า)
NPCs.DescendantAdded:Connect(function(obj)
    fixPrompt(obj)
end)
end)


local Library =
    loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Fluent =
    loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
)()
local InterfaceManager = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

local Window = Fluent:CreateWindow({
    Title = "[RESTLESS GAMBLER] Rogue Piece",
    SubTitle = "by LumeDev",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "plus" }), 
    AutoFarm = Window:AddTab({ Title = "AutoFarm", Icon = "sun-medium" }),
    bos = Window:AddTab({ Title = "Boss", Icon = "crown" }),
    Swo = Window:AddTab({ Title = "Dungeon", Icon = "sword" }),
    Che = Window:AddTab({ Title = "Open Chest", Icon = "gift" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }), 
    safe = Window:AddTab({ Title = "Reroll", Icon = "sun-medium" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}
-- Removed Admin Tab as requested
-- Removed Auto Skill Tab as requested (Merged into AutoFarm)
Window:SelectTab(1)

-- จัดลำดับ Section ใหม่ (ย้าย Auto Skill มาไว้ใน AutoFarm เหนือ Haki)
local SayHigh = Tabs.AutoFarm:AddSection("Equip")
local FarmSection = Tabs.AutoFarm:AddSection("AutoFarm")
local PositionSection = Tabs.AutoFarm:AddSection("Positions") -- New Section
local SkillSection = Tabs.AutoFarm:AddSection("Auto Skill")   -- Relocated Here
local FarmHaki = Tabs.AutoFarm:AddSection("HakiFarm")
-- Removed Stats Section as requested

local Dun = Tabs.Swo
-- ==========================================
-- AUTO SUMMON DUNGEON (Moved to Top)
-- ==========================================
local SelectedDungeon = "Ragnarok"
local DungeonList = {"Ragnarok", "Anti-Magic"}

Dun:AddDropdown("DungeonSelect", {
    Title = "Select Dungeon",
    Values = DungeonList,
    Multi = false,
    Default = "Ragnarok",
    Callback = function(val)
        SelectedDungeon = val
    end,
})

Dun:AddToggle("AutoSummonDungeon", {
    Title = "Auto Summon Dungeon",
    Default = false,
    Callback = function(state)
        _G.AutoSummonDungeon = state
        task.spawn(function()
            while _G.AutoSummonDungeon do
                task.wait(1)
                pcall(function()
                    local player = game.Players.LocalPlayer
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                    local hrp = player.Character.HumanoidRootPart
                    local gui = player.PlayerGui
                    
                    local joinCF = CFrame.new(537.229248, 6.02718163, 1006.9328, -6.1750412e-05, 0.88677907, 0.462193608, -1, -6.1750412e-05, -1.50948763e-05, 1.50948763e-05, -0.462193608, 0.88677907)

                    -- Check if already at join spot (Don't go back to NPC if close to join spot)
                    if (hrp.Position - joinCF.Position).Magnitude < 20 then
                        -- Just wait here, press E occasionally just in case
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        return
                    end

                    -- 1. Check if Dungeon UI is open
                    local dungeonUI = gui:FindFirstChild("Button") and gui.Button:FindFirstChild("Dungeon Spawn")
                    
                    if not dungeonUI or not dungeonUI.Visible then
                        -- Teleport to NPC and Interact
                        local npc = workspace.Main.NPCs:FindFirstChild("Boss Spawn2")
                        if npc and npc:FindFirstChild("HumanoidRootPart") then
                            hrp.CFrame = npc.HumanoidRootPart.CFrame
                            task.wait(0.5)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                    else
                        -- UI is open, check selection
                        local dungeonFrame = dungeonUI:FindFirstChild("Dungeon")
                        if dungeonFrame then
                            -- Select Dungeon based on Dropdown
                            local frameContainer = dungeonFrame:FindFirstChild("Frame")
                            if frameContainer then
                                local targetBtn = nil
                                if SelectedDungeon == "Ragnarok" then
                                    targetBtn = frameContainer:FindFirstChild("Ragnarok")
                                elseif SelectedDungeon == "Anti-Magic" then
                                    targetBtn = frameContainer:FindFirstChild("Anti-Magic")
                                end
                                
                                if targetBtn then
                                    -- Try to find interactable button inside if it's a frame
                                    local btn = targetBtn
                                    if not targetBtn:IsA("TextButton") and not targetBtn:IsA("ImageButton") then
                                        btn = targetBtn:FindFirstChild("Button") or targetBtn:FindFirstChildOfClass("TextButton") or targetBtn:FindFirstChildOfClass("ImageButton")
                                    end
                                    
                                    if btn then
                                        interact(btn)
                                        task.wait(0.5)
                                    end
                                end
                            end

                            -- Click Spawn
                            local spawnBtn = dungeonFrame:FindFirstChild("Spawn") and dungeonFrame.Spawn:FindFirstChild("Button")
                            if spawnBtn then
                                interact(spawnBtn)
                                
                                -- Wait and Warp to Start Point
                                task.wait(2)
                                hrp.CFrame = joinCF
                                task.wait(0.5)
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(1)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

Dun:AddToggle("AutoStartDungeon", {
    Title = "Auto Start Dungeon",
    Default = false,
    Callback = function(state)
        _G.AutoStartDungeon = state
        task.spawn(function()
            while _G.AutoStartDungeon do
                task.wait(1)
                pcall(function()
                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    if playerGui:FindFirstChild("Dungeon") and playerGui.Dungeon:FindFirstChild("Start") and playerGui.Dungeon.Start:FindFirstChild("Button") then
                         if playerGui.Dungeon.Start.Visible then
                            interact(playerGui.Dungeon.Start.Button)
                         end
                    end
                end)
            end
        end)
    end
})

local char = LocalPlayer.Character

local FIXED_CF =
    CFrame.new(
        -84.6907959, 2.22509861, -384.012054,
        0.999512434, -6.19467073e-08, -0.0312235635,
        6.45793392e-08, 1, 8.33070501e-08,
        0.0312235635, -8.52828279e-08, 0.999512434
    )
    * CFrame.new(0, 0, 5)

local RK_CF = CFrame.new(
-84.6907959, 2.22509861, -384.012054,
0.999512434, -6.19467073e-08, -0.0312235635,
6.45793392e-08, 1, 8.33070501e-08,
0.0312235635, -8.52828279e-08, 0.999512434
)

local function GetCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char
end

local Toggle = Dun:AddToggle("MyToggle", {
Title = "Auto Dungeon Hit",
Description = "",
Default = false,
Callback = function(state)
    _G.Rkd = state

    task.spawn(function()
        while _G.Rkd do
            task.wait()

            pcall(function()
                local char = GetCharacter()
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                local myHum = char:FindFirstChild("Humanoid")

                if not myHRP or not myHum or myHum.Health <= 0 then
                    return
                end

                local function FindTarget()
                    local dungeon = workspace.Main.Characters.Dungeon

                    if _G.LockedDungeonTarget and _G.LockedDungeonTarget.Parent and _G.LockedDungeonTarget:FindFirstChild("Humanoid") and _G.LockedDungeonTarget.Humanoid.Health > 0 then
                        return _G.LockedDungeonTarget
                    end

                    local mobFolder = dungeon:FindFirstChild("Mob")
                    if mobFolder then
                        for _, v in pairs(mobFolder:GetChildren()) do
                            local hum = v:FindFirstChildOfClass("Humanoid")
                            local hrp = v:FindFirstChild("HumanoidRootPart")
                            if hum and hrp and hum.Health > 0 then
                                _G.LockedDungeonTarget = v
                                return v
                            end
                        end
                    end

                    local bossFolder = dungeon:FindFirstChild("Boss")
                    if bossFolder then
                        for _, v in pairs(bossFolder:GetChildren()) do
                            local hum = v:FindFirstChildOfClass("Humanoid")
                            local hrp = v:FindFirstChild("HumanoidRootPart")
                            if hum and hrp and hum.Health > 0 then
                                _G.LockedDungeonTarget = v
                                return v
                            end
                        end
                    end
                    return nil
                end

                local target = FindTarget()
                if not target then 
                    _G.CurrentFarmTarget = nil
                    return 
                end

                local hum = target:FindFirstChildOfClass("Humanoid")
                local hrp = target:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp then return end

                while hum.Health > 0 and _G.Rkd do
                    _G.CurrentFarmTarget = target
                    HitMon()
                    task.wait()
                end
            end)
        end
        _G.CurrentFarmTarget = nil
        _G.LockedDungeonTarget = nil
    end)
end,
})

local pressedRestart = false
local pressedStart = false

LocalPlayer.CharacterAdded:Connect(function()
pressedRestart = false
pressedStart = false
end)

local Toggle = Dun:AddToggle("MyToggle", {
Title = "Auto Restart",
Default = false,
Callback = function(state)
    _G.Restart = state

    task.spawn(function()
        while _G.Restart do
            task.wait(0.25)

            pcall(function()
                local gui = LocalPlayer:WaitForChild("PlayerGui", 5)
                if not gui then return end

                local dungeon = gui:FindFirstChild("Dungeon")
                if not dungeon then return end

                local restartUI = dungeon:FindFirstChild("Restart")
                if restartUI and restartUI.Visible then
                    local btn = restartUI:FindFirstChild("Button")
                    if btn and not pressedRestart then
                        pressedRestart = true
                        interact(btn)
                    end
                else
                    pressedRestart = false
                end

                local startUI = dungeon:FindFirstChild("Start")
                if startUI and startUI.Visible then
                    local btn = startUI:FindFirstChild("Button")
                    if btn and not pressedStart then
                        pressedStart = true
                        interact(btn)
                    end
                else
                    pressedStart = false
                end
            end)
        end
    end)
end,
})

Dun:AddButton({
Title = "Teleport Dungeon",
Description = "",
Callback = function()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(96105075537655, LocalPlayer)
end
})

local Sword = Tabs.Swo:AddSection("Sword")
local Boss = Tabs.bos:AddSection("AddBossSummon")
local Bos = Tabs.bos:AddSection("AddBoss")
local Csh = Tabs.Che:AddSection("Chest")
local Cshh = Tabs.Che:AddSection("Buy Item")

local TeleportIslandSection = Tabs.Teleport:AddSection("ISLAND")
local TeleportNPCSection = Tabs.Teleport:AddSection("NPC")

local Gem = Tabs.bos:AddSection("AutoFarmGem")
local Tanjio = Tabs.bos:AddSection("Summon Boss Farm") 

-- New Section: Hakari
local HakariSection = Tabs.bos:AddSection("Hakari")


local safeee = Tabs.safe:AddSection("Reroll")
local safeeee = Tabs.safe:AddSection("Potion")
local MiscSec = Tabs.Main:AddSection("Character")
local EspSec = Tabs.Main:AddSection("ESP")
local CodeSec = Tabs.Main:AddSection("Codes")

-- ==========================================
-- LOCK TARGET SYSTEM
-- ==========================================
_G.LockedTarget = nil
local function GetLockTarget(folder, name)
    if _G.LockedTarget and _G.LockedTarget.Parent == folder and _G.LockedTarget.Name == name and _G.LockedTarget:FindFirstChild("Humanoid") and _G.LockedTarget.Humanoid.Health > 0 then
        return _G.LockedTarget
    end
    
    _G.LockedTarget = nil
    for _, v in pairs(folder:GetChildren()) do
        if v:IsA("Model") and v.Name == name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            _G.LockedTarget = v
            return v
        end
    end
    return nil
end

local selectedmonInfo = nil
local questChangePending = false
local questCancelConfirmPending = false
local questAcceptPending = false
local questAcceptPendingAt = 0

local Dropdown = FarmSection:AddDropdown("Dropdown", {
    Title = "Select Monters",
    Values = {
        "Bandit",
        "BanditLeader",
        "Skeleton",
        "PirateSkeleton",
        "DesertThief",
        "KatanaMaster",
        "Mihawk",
        "SlayersTrainee",
        "SorcerersStudent",
        "SorcerersTeacher",
        "KonohaNinja" ,
        "KonohaHeadNinja",
        "MagicKnight"
    },
    Multi = false,
    Default = "-",
    Callback = function(MonFarmsInfo)
        local nextMonInfo = MonFarms[MonFarmsInfo]
        questChangePending = selectedmonInfo ~= nil
            and nextMonInfo ~= nil
            and selectedmonInfo ~= nextMonInfo
        selectedmonInfo = nextMonInfo
        _G.LockedTarget = nil
        _G.CurrentFarmTarget = nil
    end,
})

local Farm = FarmSection:AddToggle("FarmToggle", {
    Title = "Auto Farm",
    Description = "",
    Default = false,
    Callback = function(state)
        _G.AutoFarm = state
        task.spawn(function()
            while _G.AutoFarm do
                task.wait(0.15)

                local buttonGui = LocalPlayer.PlayerGui:FindFirstChild("Button")
                local questConfirm = buttonGui and buttonGui:FindFirstChild("Quest_Confirm")
                if questAcceptPending then
                    if questConfirm and questConfirm.Visible then
                        local accept = questConfirm:FindFirstChild("Accept")
                        local acceptButton = accept and accept:FindFirstChild("Button")

                        if acceptButton then
                            interact(acceptButton)
                            task.wait(0.5)
                            questAcceptPending = false
                        end

                        continue
                    elseif os.clock() - questAcceptPendingAt < 2 then
                        -- รอให้ popup รับเควสเปิด แต่ไม่ปล่อยให้ล็อก Auto Farm ตลอดไป
                        continue
                    else
                        questAcceptPending = false
                    end
                end

                local confirm = buttonGui and buttonGui:FindFirstChild("Confirm")
                if questCancelConfirmPending and confirm and confirm.Visible then
                    local accept = confirm:FindFirstChild("Accept")
                    local acceptButton = accept and accept:FindFirstChild("Button")

                    if acceptButton then
                        interact(acceptButton)
                        task.wait(0.5)
                        questCancelConfirmPending = false
                    end

                    continue
                end

                pcall(function()
                    if not selectedmonInfo then return end

                    local questUI = LocalPlayer.PlayerGui:FindFirstChild("Button") 
                        and LocalPlayer.PlayerGui.Button:FindFirstChild("Quest_Frame")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame:FindFirstChild("Main Quest")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"]:FindFirstChild("Scroll")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"].Scroll:FindFirstChild("Quest")

                    if not questUI or not questUI.Visible then
                        task.wait()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Quests:FindFirstChild(
                            selectedmonInfo.QuestNameTp
                        ).HumanoidRootPart.CFrame
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                        task.wait()
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                        questChangePending = false
                        questAcceptPending = true
                        questAcceptPendingAt = os.clock()
                        return
                    else
                        local label2 = questUI:FindFirstChild("Bar") and questUI.Bar:FindFirstChild("Label2")
                        if label2 then
                            if questChangePending and not string.find(label2.Text, selectedmonInfo.QuestName, 1, true) then
                                local cancel = questUI.Bar:FindFirstChild("Cancel")
                                local cancelButton = cancel and cancel:FindFirstChild("Button")

                                if cancelButton then
                                    interact(cancelButton)
                                    task.wait(0.3)
                                    questChangePending = false
                                    questCancelConfirmPending = true
                                end

                                return
                            elseif string.find(label2.Text, selectedmonInfo.QuestName, 1, true) then
                                questChangePending = false
                            end
                        end
                    end

                    local folder = workspace.Main.Characters[selectedmonInfo.Island][selectedmonInfo.MobFolder]
                    local enemy = GetLockTarget(folder, selectedmonInfo.Bname)
                    if enemy then
                        _G.CurrentFarmTarget = enemy
                        HitMon()
                        task.wait()
                    else
                        _G.CurrentFarmTarget = nil
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})

-- Removed Auto Farm V2 as requested

-- ==========================================
-- POSITIONS SECTION
-- ==========================================
PositionSection:AddDropdown("FarmPosSelector", {
    Title = "Farm Position Mode",
    Values = {"Above", "Behind"},
    Multi = false,
    Default = "Behind",
    Callback = function(val)
        _G.FarmPosMode = val
    end,
})


-- ==========================================
-- AUTO SKILL SECTION (Relocated to AutoFarm Tab)
-- ==========================================
local SkillList = {"Z", "X", "C", "V", "F"}
local SelectedSkills = {}

local SkillDropdown = SkillSection:AddDropdown("SkillSelector", {
    Title = "Select Skills to Use",
    Values = SkillList,
    Multi = true,
    Default = {},
    Callback = function(val)
        SelectedSkills = val
    end,
})

SkillSection:AddToggle("AutoSkillToggle", {
    Title = "Auto Use Skills",
    Description = "Use selected skills",
    Default = false,
    Callback = function(state)
        _G.AutoSkillState = state
        task.spawn(function()
            while _G.AutoSkillState do
                task.wait()
                pcall(function()
                    for skillName, isSelected in pairs(SelectedSkills) do
                        if isSelected then
                            local skillNum = 0
                            if skillName == "Z" then skillNum = 1 end
                            if skillName == "X" then skillNum = 2 end
                            if skillName == "C" then skillNum = 3 end
                            if skillName == "V" then skillNum = 4 end
                            if skillName == "F" then skillNum = 5 end
                            
                            if skillNum > 0 then
                                UseOneSkill(skillNum)
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

-- ==========================================
-- FE PHYSICS KILL (New Section)
-- ==========================================
local PhysicsSection = Tabs.AutoFarm:AddSection("FE Physics Kill (Radius)")

-- ฟังก์ชันปรับ Simulation Radius
local function SetSimulationRadius()
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(game.Players.LocalPlayer, "MaxSimulationRadius", math.huge)
        else
            game.Players.LocalPlayer.SimulationRadius = math.huge
        end
    end)
end

PhysicsSection:AddToggle("FEKillAura", {
    Title = "FE Kill Aura (Nearby)",
    Description = "Kills mobs you have network ownership of (Stand close)",
    Default = false,
    Callback = function(state)
        _G.FEKillAura = state
        
        -- Loop ขยาย Radius
        if state then
            StartPhysicsLoop()
            
            -- Loop ฆ่า
            task.spawn(function()
                while _G.FEKillAura do
                    task.wait() 
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        
                        -- รัศมีฆ่า
                        local radius = 30 
                        
                        local mainFolder = workspace:FindFirstChild("Main")
                        local charFolder = mainFolder and mainFolder:FindFirstChild("Characters")
                        
                        if charFolder then
                            for _, island in pairs(charFolder:GetChildren()) do
                                for _, mobType in pairs(island:GetChildren()) do
                                    for _, mob in pairs(mobType:GetChildren()) do
                                        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                                            local dist = (mob.HumanoidRootPart.Position - root.Position).Magnitude
                                            if dist <= radius then
                                                -- เช็คความเป็นเจ้าของ (Network Ownership)
                                                local isOwner = false
                                                if isnetworkowner then
                                                    isOwner = isnetworkowner(mob.HumanoidRootPart)
                                                else
                                                    isOwner = (mob.HumanoidRootPart.ReceiveAge == 0)
                                                end
                                                
                                                -- ถ้าเราเป็นเจ้าของ หรือมอนไม่ได้ Anchor (มีโอกาสแย่งได้)
                                                if isOwner or (not mob.HumanoidRootPart.Anchored) then
                                                    mob.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                                                    mob.Humanoid.Health = 0
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

local LastHakiState = false
local player = Players.LocalPlayer
local serverside = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Serverside")

local function isHakiActive()
    local char = player.Character
    if char then
        local tryNames = { "Haki", "HasHaki", "HakiActive", "IsHaki" }
        for _, name in ipairs(tryNames) do
            local v = char:FindFirstChild(name)
            if v and v:IsA("BoolValue") then
                if v.Value == true then
                    return true
                end
            elseif v then
                return true
            end
        end
    end

    if player:FindFirstChild("Leaderstats") then
        local ls = player.Leaderstats
        if ls:FindFirstChild("Haki") and ls.Haki.Value and ls.Haki.Value > 0 then
            return true
        end
    end

    local success, attr = pcall(function()
        return player:GetAttribute("Haki")
    end)
    if success and attr then
        if type(attr) == "boolean" and attr == true then
            return true
        end
        if type(attr) == "number" and attr > 0 then
            return true
        end
    end

    return false
end

local function sendHakiCmd(num)
    pcall(function()
        local args = { "Server", "Misc", "Haki", num }
        serverside:FireServer(unpack(args))
    end)
end

local respawnConn

local Toggle = FarmHaki:AddToggle("MyToggle", {
    Title = "AutoHaki",
    Description = "",
    Default = false,
    Callback = function(Hari)
        _G.AutoHaki = Hari

        if Hari then
            if not isHakiActive() then
                sendHakiCmd(1)
            end

            respawnConn = player.CharacterAdded:Connect(function(char)
                char:WaitForChild("Humanoid", 5)
                task.wait(0.5)
                if not isHakiActive() then
                    sendHakiCmd(1)
                end
            end)
        else
            sendHakiCmd(2)

            if respawnConn then
                respawnConn:Disconnect()
                respawnConn = nil
            end
        end
    end,
})

local args = {
    "Server",
    "Misc",
    "Observation",
    1,
}

local function ActivateObservation()
    pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remotes")
            :WaitForChild("Serverside")
            :FireServer(unpack(args))
    end)
end

local Toggle = FarmHaki:AddToggle("MyToggleObservation", {
    Title = "Auto Observation",
    Description = "",
    Default = false,
    Callback = function(state)
        _G.AutoObservation = state

        if state then
            task.spawn(function()
                while _G.AutoObservation do
                    task.wait()
                    pcall(function()
                        ActivateObservation()
                        task.wait(0.2)
                    end)
                end
            end)
        end
    end,
})

local Toggle = Gem:AddToggle("MyToggle", {
    Title = "FarmGem",
    Description = "KillMihawk",
    Default = false,
    Callback = function(Farbos)
        _G.AutoGem = Farbos
        task.spawn(function()
            while _G.AutoGem do
                task.wait()
                pcall(function()
                    local questUI = LocalPlayer.PlayerGui:FindFirstChild("Button") 
                        and LocalPlayer.PlayerGui.Button:FindFirstChild("Quest_Frame")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame:FindFirstChild("Main Quest")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"]:FindFirstChild("Scroll")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"].Scroll:FindFirstChild("Quest")

                    if not questUI or not questUI.Visible then
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Quests:FindFirstChild(
                            MonFarms.Mihawk.QuestNameTp
                        ).HumanoidRootPart.CFrame
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                        task.wait()
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                    else
                        local label2 = questUI:FindFirstChild("Bar") and questUI.Bar:FindFirstChild("Label2")
                        if label2 then
                            if not string.find(label2.Text, MonFarms.Mihawk.QuestName) then
                                local cancelButton = questUI.Bar:FindFirstChild("Cancel") and questUI.Bar.Cancel:FindFirstChild("Button")
                                if cancelButton then interact(cancelButton) end
                                return
                            end
                        end
                    end
                    
                    local folder = workspace.Main.Characters[MonFarms.Mihawk.Island].Mihawk
                    local enemy = GetLockTarget(folder, MonFarms.Mihawk.Bname)
                    if enemy then
                        _G.CurrentFarmTarget = enemy
                        HitMon()
                        if enemy.Humanoid.Health / enemy.Humanoid.MaxHealth < 0.9 then
                            enemy.Humanoid.Health = 0
                        end
                    else
                        _G.CurrentFarmTarget = nil
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})
local Toggle = Gem:AddToggle("MyToggle", {
    Title = "Farm Sorcerer's Teacher",
    Description = "Sorcerer's Teacher Que",
    Default = false,
    Callback = function(FarTeache)
        _G.AutoSorcererTeacher = FarTeache
        task.spawn(function()
            while _G.AutoSorcererTeacher do
                task.wait()
                pcall(function()
                    local questUI = LocalPlayer.PlayerGui:FindFirstChild("Button") 
                        and LocalPlayer.PlayerGui.Button:FindFirstChild("Quest_Frame")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame:FindFirstChild("Main Quest")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"]:FindFirstChild("Scroll")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"].Scroll:FindFirstChild("Quest")

                    if not questUI then
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Quests:FindFirstChild(
                            MonFarms.SorcerersTeacher.QuestNameTp
                        ).HumanoidRootPart.CFrame
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                        task.wait()
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                    else
                        local label2 = questUI:FindFirstChild("Bar") and questUI.Bar:FindFirstChild("Label2")
                        if label2 then
                            if not string.find(label2.Text, MonFarms.SorcerersTeacher.QuestName) then
                                local cancelButton = questUI.Bar:FindFirstChild("Cancel") and questUI.Bar.Cancel:FindFirstChild("Button")
                                if cancelButton then interact(cancelButton) end
                                return
                            end
                        end
                    end
                    
                    local folder = workspace.Main.Characters[MonFarms.SorcerersTeacher.Island]["Sorcerer's Teacher"]
                    local enemy = GetLockTarget(folder, MonFarms.SorcerersTeacher.Bname)
                    if enemy then
                        _G.CurrentFarmTarget = enemy
                        HitMon()
                        if enemy.Humanoid.Health / enemy.Humanoid.MaxHealth < 0.9 then
                            enemy.Humanoid.Health = 0
                        end
                    else
                        _G.CurrentFarmTarget = nil
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})

local function isAlive(boss)
    if boss and boss:FindFirstChild("Humanoid") then
        return boss.Humanoid.Health > 0
    end
    return false
end

local Toggle = Sword:AddToggle("MyToggle", {
    Title = "Auto Yuta",
    Default = false,
    Callback = function(TanJo)
        _G.AutoTanJo = TanJo

        task.spawn(function()
            while _G.AutoTanJo do
                task.wait()
                pcall(function()
                    local FoundBoss = false
                    local TargetBoss = nil

                    local BossList = {
                        workspace.Main.Characters["Jujutsu Highschool"].Boss:FindFirstChild("Yuta"),
                        workspace.Main.Characters["Rogue Town [Backside]"].Boss:FindFirstChild("Sung Jin Woo"),
                        workspace.Main.Characters["Rogue Town [Backside]"].Boss:FindFirstChild("Silver Fang"),
                        workspace.Main.Characters["Forge Isle"].Boss:FindFirstChild("Tanjiro"),
                        workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Akaza"),
                        workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Sukuna"),
                        workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("David"),
                        workspace.Main.Characters["Huecomundo"].Boss:FindFirstChild("Aizen"),
                        workspace.Main.Characters["Rogue Town"].Boss:FindFirstChild("Shigaraki"),
                        workspace.Main.Characters["Abyss Hill"].Boss:FindFirstChild("Abyssal Beast"),
                    }

                    for _, B in pairs(BossList) do
                        if isAlive(B) then
                            FoundBoss = true
                            TargetBoss = B
                            break
                        end
                    end
                    if FoundBoss then
                        _G.CanCancel = true
                        _G.CurrentFarmTarget = TargetBoss
                        HitMon()
                        return
                    end

                    if not FoundBoss and _G.CanCancel then
                        _G.CurrentFarmTarget = nil
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            CFrame.new(-802.703918, 5.76603603, 643.961426, -0.882289171, 0.171407714, -0.43838945, 0.190775529, 0.981633663, -0.000135950744, 0.430314571, -0.0837539211, -0.898785114)

                        _G.CanCancel = false
                        return
                    end

                    local BossTan = workspace.Main.Characters["Forge Isle"].Boss:FindFirstChild("Tanjiro")

                    if not (BossTan and BossTan:FindFirstChild("Humanoid") and BossTan.Humanoid.Health > 0) then
                        local folder = workspace.Main.Characters[MonFarms.SlayersTrainee.Island][MonFarms.SlayersTrainee.MobFolder]
                        local Cat = GetLockTarget(folder, MonFarms.SlayersTrainee.Bname)
                        
                        if Cat then
                            _G.CurrentFarmTarget = Cat
                            HitMon()
                        else
                            _G.CurrentFarmTarget = nil
                        end

                        local text = workspace.Main.NPCs["Boss Spawn3"]["{}"].ActionText
                        local current = tonumber(string.match(text, "(%d+)%s*/%s*%d+"))

                        if current and current >= 50 then
                            _G.CurrentFarmTarget = nil
                            LocalPlayer.Character.HumanoidRootPart.CFrame =
                                workspace.Main.NPCs:FindFirstChild("Boss Spawn3").HumanoidRootPart.CFrame

                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                        end
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})


local Toggle = Bos:AddToggle("MyToggle", {
    Title = "FarmAllBoss",
    Description = "KillBoss",
    Default = false,
    Callback = function(Farbosall)
        _G.AutoAllBoss = Farbosall

        task.spawn(function()
            while _G.AutoAllBoss do
                task.wait()
                pcall(function()
                    local FoundBoss = false

                    local BossGojo = workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Gojo")
                    if isAlive(BossGojo) then
                        _G.CurrentFarmTarget = BossGojo
                        HitMon()
                        FoundBoss = true
                    end
                    if not FoundBoss then
                        local BossKafka = workspace.Main.Characters["Abyss Hill [Upper]"].Boss:FindFirstChild("Jin Mori")
                        if isAlive(BossKafka) then
                            _G.CurrentFarmTarget = BossKafka
                            HitMon()
                            FoundBoss = true
                        end
                    end

                    if not FoundBoss then
                        local BossYuta = workspace.Main.Characters["Jujutsu Highschool"].Boss:FindFirstChild("Yuta")
                        if isAlive(BossYuta) then
                            _G.CurrentFarmTarget = BossYuta
                            HitMon()
                            FoundBoss = true
                        end
                    end

                    if not FoundBoss then
                        local BossToji = workspace.Main.Characters["Jujutsu Highschool"].Boss:FindFirstChild("Toji")
                        if isAlive(BossToji) then
                            _G.CurrentFarmTarget = BossToji
                            HitMon()
                            FoundBoss = true
                        end
                    end

                    if not FoundBoss then
                        local BossNaoya = workspace.Main.Characters["Abyss Hill [Upper]"].Boss:FindFirstChild("Naoya")
                        if isAlive(BossNaoya) then
                            _G.CurrentFarmTarget = BossNaoya
                            HitMon()
                            FoundBoss = true
                        end
                    end
                    
                    
                    if not FoundBoss then
                        local BossSung = workspace.Main.Characters["Rogue Town [Backside]"].Boss:FindFirstChild("Sung Jin Woo")
                        if isAlive(BossSung) then
                            _G.CurrentFarmTarget = BossSung
                            HitMon()
                            FoundBoss = true
                        end
                    end
                    if not FoundBoss then
                        local BossSung = workspace.Main.Characters["Rogue Town [Backside]"].Boss:FindFirstChild("Silver Fang")
                        if isAlive(BossSung) then
                            _G.CurrentFarmTarget = BossSung
                            HitMon()
                            FoundBoss = true
                        end
                    end

                    if not FoundBoss then
                        local BossDavid = workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("David")
                        if isAlive(BossDavid) then
                            _G.CurrentFarmTarget = BossDavid
                            HitMon()
                            FoundBoss = true
                        end
                    end
                    
                                            if not FoundBoss then
                        local BossBeast = workspace.Main.Characters["Abyss Hill"].Boss:FindFirstChild("Abyssal Beast")
                        if isAlive(BossBeast) then
                            _G.CurrentFarmTarget = BossBeast
                            HitMon()
                            FoundBoss = true
                        end
                    end
                                            if not FoundBoss then
                        local BossShigaraki = workspace.Main.Characters["Rogue Town"].Boss:FindFirstChild("Shigaraki")
                        if isAlive(BossShigaraki) then
                            _G.CurrentFarmTarget = BossShigaraki
                            HitMon()
                            FoundBoss = true
                        end
                    end
                    if not FoundBoss then
                        local BossAizen = workspace.Main.Characters["Huecomundo"].Boss:FindFirstChild("Aizen")
                        if isAlive(BossAizen) then
                            _G.CurrentFarmTarget = BossAizen
                            HitMon()
                            FoundBoss = true
                        end
                    end
                                if not FoundBoss then
                        local BossAkaza = workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Akaza")
                        if isAlive(BossAkaza) then
                            _G.CurrentFarmTarget = BossAkaza
                            HitMon()
                            FoundBoss = true
                        end
                    end 
                    if not FoundBoss then
                        local BossSukuna = workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Sukuna")
                        if isAlive(BossSukuna) then
                            _G.CurrentFarmTarget = BossSukuna
                            HitMon()
                            FoundBoss = true
                        end
                    end
                                            if not FoundBoss then
                        local BossSukunaShibuya = workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Sukuna Shibuya")
                        if isAlive(BossSukunaShibuya) then
                            _G.CurrentFarmTarget = BossSukunaShibuya
                            HitMon()
                            FoundBoss = true
                        end
                    end
                                            if not FoundBoss then
                        local BossGojoShibuya = workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Gojo Shibuya")
                        if isAlive(BossGojoShibuya) then
                            _G.CurrentFarmTarget = BossGojoShibuya
                            HitMon()
                            FoundBoss = true
                        end
                    end
                    
                                            if not FoundBoss then
                        local BossTodoroki = workspace.Main.Characters["Throne Isle"].Boss:FindFirstChild("Todoroki")
                        if isAlive(BossTodoroki) then
                            _G.CurrentFarmTarget = BossTodoroki
                            HitMon()
                            FoundBoss = true
                        end
                    end

                    if not FoundBoss and _G.CanCancel then
                        local questUI = LocalPlayer.PlayerGui:FindFirstChild("Button") 
                            and LocalPlayer.PlayerGui.Button:FindFirstChild("Quest_Frame")
                            and LocalPlayer.PlayerGui.Button.Quest_Frame:FindFirstChild("Main Quest")
                            and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"]:FindFirstChild("Scroll")
                            and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"].Scroll:FindFirstChild("Quest")

                        if questUI then
                            local cancelButton = questUI:FindFirstChild("Bar") and questUI.Bar:FindFirstChild("Cancel") and questUI.Bar.Cancel:FindFirstChild("Button")
                            if cancelButton then interact(cancelButton) end
                        end
                        _G.CanCancel = false
                    end

                    if FoundBoss then
                        _G.CanCancel = true
                    else
                        _G.CurrentFarmTarget = nil
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})

-- =======================================================
-- TANJIRO & SASUKE (DROPDOWN SELECT) + GLOBAL TP
-- =======================================================
local SelectedSummonBoss = "Tanjiro"

-- Spawn Locations for global check
local TanjiroSpawn = CFrame.new(-802.703918, 5.76603603, 643.961426) -- Forge Isle
local SasukeSpawn = CFrame.new(-213.062195, 4.12318802, 1101.14148) -- Konoha Island

Tanjio:AddDropdown("SummonBossSelect", {
    Title = "Select Boss to Farm",
    Values = {"Tanjiro", "Sasuke"},
    Multi = false,
    Default = "Tanjiro",
    Callback = function(val)
        SelectedSummonBoss = val
        _G.CurrentFarmTarget = nil
        _G.LockedTarget = nil
    end,
})

local Toggle = Tanjio:AddToggle("AutoSummonBossFarm", {
    Title = "Auto Summon & Farm Boss",
    Default = false,
    Callback = function(state)
        _G.AutoSummonBoss = state
        task.spawn(function()
            while _G.AutoSummonBoss do
                task.wait()
                pcall(function()
                    if SelectedSummonBoss == "Tanjiro" then
                        local Boss = workspace.Main.Characters["Forge Isle"].Boss:FindFirstChild("Tanjiro")
                        
                        if not Boss or not Boss:FindFirstChild("Humanoid") or Boss.Humanoid.Health <= 0 then
                            -- Global Check: ถ้าหาบอสไม่เจอ ให้วาร์ปไปจุดเกิดบอสก่อนเพื่อโหลดแมพ
                            if (LocalPlayer.Character.HumanoidRootPart.Position - TanjiroSpawn.Position).Magnitude > 500 then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = TanjiroSpawn
                                task.wait(1)
                            end
                            
                            -- เช็คเควสรับเงิน (Optional)
                            local questUI = LocalPlayer.PlayerGui:FindFirstChild("Button") 
                                and LocalPlayer.PlayerGui.Button:FindFirstChild("Quest_Frame")
                                and LocalPlayer.PlayerGui.Button.Quest_Frame:FindFirstChild("Main Quest")
                                and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"]:FindFirstChild("Scroll")
                                and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"].Scroll:FindFirstChild("Quest")

                            if not questUI then
                                task.wait()
                                LocalPlayer.Character.HumanoidRootPart.CFrame =
                                    workspace.Main.NPCs.Quests:FindFirstChild("8").HumanoidRootPart.CFrame
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                            end
                        
                            local folder = workspace.Main.Characters[MonFarms.SlayersTrainee.Island][MonFarms.SlayersTrainee.MobFolder]
                            local Cat = GetLockTarget(folder, MonFarms.SlayersTrainee.Bname)

                            if Cat then
                                _G.CurrentFarmTarget = Cat
                                HitMon()
                                task.wait()
                            else
                                _G.CurrentFarmTarget = nil
                            end

                            local text = workspace.Main.NPCs["Boss Spawn3"]["{}"].ActionText
                            local current = tonumber(string.match(text, "(%d+)%s*/%s*%d+"))

                            if current and current >= 50 then
                                _G.CurrentFarmTarget = nil
                                task.wait()
                                LocalPlayer.Character.HumanoidRootPart.CFrame =
                                    workspace.Main.NPCs:FindFirstChild("Boss Spawn3").HumanoidRootPart.CFrame
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                            end
                        else
                            -- บอสเกิดแล้ว
                            _G.CurrentFarmTarget = nil
                            while Boss and Boss:FindFirstChild("Humanoid") and Boss.Humanoid.Health > 0 and _G.AutoSummonBoss and SelectedSummonBoss == "Tanjiro" do
                                task.wait(1)
                                if Boss and Boss:FindFirstChild("Humanoid") and Boss.Humanoid.Health > 0 then
                                    _G.CurrentFarmTarget = Boss
                                    HitMon()
                                end
                            end
                            _G.CurrentFarmTarget = nil
                        end

                    elseif SelectedSummonBoss == "Sasuke" then
                        local konohaBossFolder = workspace.Main.Characters["Konoha Village"].Boss
                        local Boss = nil
                        for _, v in pairs(konohaBossFolder:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                Boss = v
                                break
                            end
                        end

                        if not Boss then
                            -- Global Check: วาร์ปไป Konoha เพื่อโหลดแมพ
                            if (LocalPlayer.Character.HumanoidRootPart.Position - SasukeSpawn.Position).Magnitude > 500 then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = SasukeSpawn
                                task.wait(1)
                            end

                            -- Farm Minions (Konoha's Head Ninja)
                            local folder = workspace.Main.Characters[MonFarms.KonohaHeadNinja.Island][MonFarms.KonohaHeadNinja.MobFolder]
                            local Minion = GetLockTarget(folder, MonFarms.KonohaHeadNinja.Bname)

                            if Minion then
                                _G.CurrentFarmTarget = Minion
                                HitMon()
                                task.wait()
                            else
                                _G.CurrentFarmTarget = nil
                            end

                            -- Check Counter at Boss Spawn6
                            local spawnNode = workspace.Main.NPCs:FindFirstChild("Boss Spawn6")
                            if spawnNode and spawnNode:FindFirstChild("{}") then
                                local text = spawnNode["{}"].ActionText
                                local current = tonumber(string.match(text, "(%d+)%s*/%s*%d+"))

                                if current and current >= 25 then
                                    _G.CurrentFarmTarget = nil
                                    task.wait()
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawnNode.HumanoidRootPart.CFrame
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                                    task.wait(1)
                                end
                            end
                        else
                            -- Kill Boss
                            _G.CurrentFarmTarget = nil
                            while Boss and Boss:FindFirstChild("Humanoid") and Boss.Humanoid.Health > 0 and _G.AutoSummonBoss and SelectedSummonBoss == "Sasuke" do
                                task.wait(1)
                                if Boss and Boss:FindFirstChild("Humanoid") and Boss.Humanoid.Health > 0 then
                                    _G.CurrentFarmTarget = Boss
                                    HitMon()
                                end
                            end
                            _G.CurrentFarmTarget = nil
                        end
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})

local Toggle = Gem:AddToggle("MyToggle", {
    Title = "FramGemMission",
    Description = "Toggle description",
    Default = false,
    Callback = function(Mission)
        _G.AutoMission = Mission
        task.spawn(function()
            while _G.AutoMission do
                task.wait()
                pcall(function()
                    local questUI = LocalPlayer.PlayerGui:FindFirstChild("Button") 
                        and LocalPlayer.PlayerGui.Button:FindFirstChild("Quest_Frame")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame:FindFirstChild("Main Quest")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"]:FindFirstChild("Scroll")
                        and LocalPlayer.PlayerGui.Button.Quest_Frame["Main Quest"].Scroll:FindFirstChild("Quest")

                    if not questUI then
                        task.wait()
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            workspace.Main.NPCs:FindFirstChild("Mission").HumanoidRootPart.CFrame
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                        task.wait()
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                    else
                        local label2 = questUI:FindFirstChild("Bar") and questUI.Bar:FindFirstChild("Label2")
                        if label2 then
                            if not string.find(label2.Text, "[Mission] Defeat Mihawk's 5 times") then
                                local cancelButton = questUI.Bar:FindFirstChild("Cancel") and questUI.Bar.Cancel:FindFirstChild("Button")
                                if cancelButton then interact(cancelButton) end
                                return
                            end
                        end
                    end
                    
                    local folder = workspace.Main.Characters["Glacier Isle"]["Mihawk"]
                    local enemy = GetLockTarget(folder, "Mihawk")
                    if enemy then
                        _G.CurrentFarmTarget = enemy
                        HitMon()
                        if enemy.Humanoid.Health / enemy.Humanoid.MaxHealth < 0.9 then
                            enemy.Humanoid.Health = 0
                        end
                    else
                        _G.CurrentFarmTarget = nil
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})

local Toggle = HakariSection:AddToggle("AutoSummonHakari", {
    Title = "Auto Summon Hakari",
    Default = false,
    Callback = function(state)
        _G.AutoSummonHakari = state
        task.spawn(function()
            while _G.AutoSummonHakari do
                task.wait(1)
                pcall(function()
                    local folder = workspace.Main.Characters["Rogue Town"].Boss
                    local hakari = folder:FindFirstChild("Hakari")
                    
                    if hakari and hakari:FindFirstChild("Humanoid") and hakari.Humanoid.Health > 0 then
                        return
                    end

                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    local materialFrame = playerGui.Button.Storage_Frame.Material_Frame
                    local gamblerSpirit = materialFrame:FindFirstChild("Gambler Spirit")
                    
                    if gamblerSpirit and gamblerSpirit:FindFirstChild("Button") then
                        interact(gamblerSpirit.Button)
                        task.wait(0.5)
                        
                        local confirm = playerGui.Button.Confirm
                        if confirm and confirm:FindFirstChild("Accept") and confirm.Accept:FindFirstChild("Button") then
                            interact(confirm.Accept.Button)
                        end
                    end
                end)
            end
        end)
    end,
})

local Toggle = HakariSection:AddToggle("AutoKillHakari", {
    Title = "Auto Kill Hakari (Physics < 90%)",
    Default = false,
    Callback = function(state)
        _G.AutoKillHakari = state
        
        -- Start Loop for Simulation Radius
        if state then
            StartPhysicsLoop()
        end

        task.spawn(function()
            while _G.AutoKillHakari do
                task.wait()
                pcall(function()
                    local folder = workspace.Main.Characters["Rogue Town"].Boss
                    local enemy = GetLockTarget(folder, "Hakari")
                    
                    if enemy then
                        _G.CurrentFarmTarget = enemy
                        HitMon()

                        -- Check HP & Execute
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local hpPercent = enemy.Humanoid.Health / enemy.Humanoid.MaxHealth
                            
                            -- Kill Threshold 90% -> Adjusted logic to ensure trigger
                            if hpPercent < 0.9 then 
                                instaKill(enemy, true)
                            end
                        end

                    else
                        _G.CurrentFarmTarget = nil
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})

-- ==========================================
-- EQUIP SECTION LOGIC (DROPDOWN Sword/Combat)
-- ==========================================
local DropdownEquip = SayHigh:AddDropdown("Dropdown", {
    Title = "Selected Weapon Group",
    Values = {"Combat", "Sword"},
    Multi = false,
    Default = "-",
    Callback = function(c)
        SelectedWeaponGroup = c
    end,
})

local ToggleEquip = SayHigh:AddToggle("MyToggle", {
Title = "Equip Weapon",
Default = false,
Callback = function(state)
    AutoEquip = state
    if state then
        task.spawn(function()
            while AutoEquip do
                task.wait(0.5)

                if _G.IsInstaKilling then
                    continue
                end

                pcall(function()
                    if SelectedWeaponGroup ~= "-" then
                        local backpack = LocalPlayer.Backpack
                        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local humanoid = char:WaitForChild("Humanoid")
                        
                        local currentTool = char:FindFirstChildOfClass("Tool")
                        local isHoldingCorrect = false
                        if currentTool and table.find(WeaponGroups[SelectedWeaponGroup], currentTool.Name) then
                            isHoldingCorrect = true
                        end

                        if not isHoldingCorrect then
                            for _, tool in ipairs(backpack:GetChildren()) do
                                if tool:IsA("Tool") and table.find(WeaponGroups[SelectedWeaponGroup], tool.Name) then
                                    humanoid:EquipTool(tool)
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end,
})

-- ==========================================
-- MISC FEATURES (Speed, Jump, ESP, Code)
-- ==========================================
MiscSec:AddToggle("Speedhack", {
    Title = "Speedhack",
    Default = false,
    Callback = function(v)
        _G.Speedhack = v
        task.spawn(function()
            while _G.Speedhack do
                task.wait()
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.WalkSpeed = 100
                    end
                end)
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end)
    end
})

MiscSec:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v)
        _G.InfJump = v
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local function CreateESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 1
    box.Filled = false
    
    local text = Drawing.new("Text")
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 16
    text.Center = true
    text.Outline = true

    local function Update()
        local conn
        conn = game:GetService("RunService").RenderStepped:Connect(function()
            if not _G.ESPPlayer or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
                box.Visible = false
                text.Visible = false
                if not plr.Parent then
                    box:Remove()
                    text:Remove()
                    conn:Disconnect()
                end
                return
            end

            local hrp = plr.Character.HumanoidRootPart
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude

            if onScreen then
                box.Visible = true
                box.Size = Vector2.new(1000 / dist * 2, 2000 / dist * 2)
                box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)

                text.Visible = true
                text.Position = Vector2.new(vector.X, vector.Y + box.Size.Y / 2)
                text.Text = string.format("%s\n[%d m]", plr.Name, math.floor(dist))
            else
                box.Visible = false
                text.Visible = false
            end
        end)
    end
    Update()
end

EspSec:AddToggle("ESPPlayer", {
    Title = "ESP Player",
    Default = false,
    Callback = function(v)
        _G.ESPPlayer = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                CreateESP(p)
            end
            Players.PlayerAdded:Connect(CreateESP)
        end
    end
})

local CodesToRedeem = {"NINJAARC!", "VOXUP"}
CodeSec:AddButton({
    Title = "Redeem All Codes",
    Callback = function()
        local codeRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Serverside")
        for _, code in ipairs(CodesToRedeem) do
            -- Generic attempt to redeem using common args, since specific args are unknown
            -- Try finding Code UI input
            local success, err = pcall(function()
                local gui = LocalPlayer.PlayerGui
                -- Try to find any frame named Code
                local codeBox = nil
                for _, v in pairs(gui:GetDescendants()) do
                    if v:IsA("TextBox") and (v.Name == "Code" or v.Name == "EnterCode") then
                        codeBox = v
                        break
                    end
                end
                
                if codeBox then
                    codeBox.Text = code
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                else
                    -- Blind fire generic event
                    codeRemote:FireServer("Server", "Codes", "Redeem", code) 
                    codeRemote:FireServer("Server", "Code", code)
                end
            end)
        end
        Fluent:Notify({Title = "Redeem", Content = "Attempted to redeem codes.", Duration = 3})
    end
})

local Bosses = {
    Sukuna = {
    Bname = "Sukuna",
    QuestName = "Defeat Bandits",
    QuestNameTp = "Boss Spawn1",
    Island = "Throne Isle",
    MobFolder = "Boss",
    NeedSummon = true
},
Todoroki = {
    Bname = "Todoroki",
    QuestName = "Defeat Bandits",
    QuestNameTp = "Boss Spawn1",
    Island = "Throne Isle",
    MobFolder = "Boss",
    NeedSummon = true,
    InstaKill = true, 
    },
SukunaShibuya = {
Bname = "Sukuna Shibuya",
QuestName = "Defeat Bandits",
QuestNameTp = "Boss Spawn1",
Island = "Throne Isle",
MobFolder = "Boss",
NeedSummon = true,
InstaKill = true, 
},

GojoShibuya = {
Bname = "Gojo Shibuya",
QuestName = "Defeat Bandits",
QuestNameTp = "Boss Spawn1",
Island = "Throne Isle",
MobFolder = "Boss",
NeedSummon = true,
InstaKill = true, 
},
    
Gojo = {
    Bname = "Gojo",
    QuestName = "",
    QuestNameTp = "Boss Spawn1",
    Island = "Throne Isle",
    MobFolder = "Boss",
    NeedSummon = true
},
Akaza = {
    Bname = "Akaza",
    QuestName = "Defeat Bandits",
    QuestNameTp = "Boss Spawn1",
    Island = "Throne Isle",
    MobFolder = "Boss",
    NeedSummon = true
},
David = {
    Bname = "David",
    QuestName = "Defeat Bandits",
    QuestNameTp = "Boss Spawn1",
    Island = "Throne Isle",
    MobFolder = "Boss",
    NeedSummon = true
},
    SungJinWoo = {
        Bname = "Sung Jin Woo",
        QuestName = "Defeat Bandits",
        QuestNameTp = "1",
        Island = "Rogue Town [Backside]",
        MobFolder = "Boss",
    },
    SilverFang = {
        Bname = "Silver Fang",
        QuestName = "Defeat Bandits",
        QuestNameTp = "1",
        Island = "Rogue Town [Backside]",
        MobFolder = "Boss",
    },
    Aizen = {
    Bname = "Aizen",
    QuestName = "Defeat Bandits",
    QuestNameTp = "Boss Spawn5",
    Island = "Huecomundo",
    MobFolder = "Boss",
    NeedSummon = true 
    },
    Yami = {
    Bname = "Yami",
    QuestName = "",
    QuestNameTp = "Boss Spawn7",
    Island = "Hage Island",
    MobFolder = "Boss",
    NeedSummon = true,
    InstaKill = true, 
    },
    AbyssalBeast = {
        Bname = "Abyssal Beast",
        QuestName = "",
        QuestNameTp = "",
        Island = "Abyss Hill",
        MobFolder = "Boss",
    },
    Kaneki = {
        Bname = "Kaneki",
        QuestName = "",
        QuestNameTp = "Boss Spawn4",
        Island = "Abyss Hill [Upper]",
        MobFolder = "Boss",
    },
    Naoya = {
        Bname = "Naoya",
        QuestName = "",
        QuestNameTp = "Boss Spawn4",
        Island = "Abyss Hill [Upper]",
        MobFolder = "Boss",
        InstaKill = true, 
    },
    Jinmori = {
        Bname = "Jin Mori",
        QuestName = "",
        QuestNameTp = "",
        Island = "Abyss Hill [Upper]",
        MobFolder = "Boss",
    },

    Yuta = {
        Bname = "Yuta",
        QuestName = "",
        QuestNameTp = "",
        Island = "Jujutsu Highschool",
        MobFolder = "Boss",
    },
    Toji = {
        Bname = "Toji",
        QuestName = "",
        QuestNameTp = "",
        Island = "Jujutsu Highschool",
        MobFolder = "Boss",
        InstaKill = true, 
    },
    Shigaraki = {
        Bname = "Shigaraki",
        QuestName = "",
        QuestNameTp = "",
        Island = "Rogue Town",
        MobFolder = "Boss",
    },
    Herta = {
        Bname = "Herta",
        QuestName = "",
        QuestNameTp = "",
        Island = "Xmas Island",
        MobFolder = "Boss",
    },
}
local DropdownBoss = Boss:AddDropdown("Dropdown", {
    Title = "SelectedBoss",
    Description = "",
    Values = {
        "Sukuna",
        "Akaza",
        "David",
        "Todoroki",
        "SungJinWoo",
        "Aizen",
        "Kaneki",
        "Herta" ,
        "Yuta",
        "Gojo",
        "SilverFang",
        "AbyssalBeast",
        "Shigaraki",
        "Jinmori",
        "SukunaShibuya",
        "GojoShibuya",
        "Toji",
        "Yami",
        "Naoya"
        
    },
    Multi = false,
    Default = "-",
    Callback = function(value)
        selectedBossInfo = Bosses[value]
        _G.LockedTarget = nil
        _G.CurrentFarmTarget = nil
    end,
})
local DropdownPity = Boss:AddDropdown("Dropdown", {
    Title = "Select Boss Pity 25",
    Values = {
        "-" ,
        "Sukuna",
        "Akaza",
        "David",
        "Todoroki",
        "SungJinWoo",
        "Aizen",
        "Kaneki",
        "Herta",
        "Yuta",
        "Shigaraki",
        "SilverFang",
        "AbyssalBeast",
        "Jinmori",
        "SukunaShibuya",
        "GojoShibuya",
        "Toji",
        "Yami",
        "Naoya"
    },
    Multi = false,
    Default = "-",
    Callback = function(value)
        selectedBossPityInfo = Bosses[value]
    end,
})
local function IsBossAlive(target)
if not target then return false end

local island = workspace.Main.Characters:FindFirstChild(target.Island)
if not island then return false end

local folder = island:FindFirstChild(target.MobFolder)
if not folder then return false end

for _, v in pairs(folder:GetChildren()) do
    if v.Name == target.Bname
    and v:FindFirstChild("Humanoid")
    and v.Humanoid.Health > 0 then
        return true
    end
end

return false
end

local function GetCurrentTarget()
local target = selectedBossInfo

if LocalPlayer.Pity.Boss.Value == 25 and selectedBossPityInfo then
    if selectedBossPityInfo.NeedSummon then
        target = selectedBossPityInfo
    else
        if IsBossAlive(selectedBossPityInfo) then
            target = selectedBossPityInfo
        end
    end
end

return target
end

local ToggleFarmBoss = Boss:AddToggle("FarmBoss", {
Title = "FarmBoss",
Default = false,
Callback = function(state)
    _G.AutoBoss = state

    task.spawn(function()
        while _G.AutoBoss do
            task.wait()

            pcall(function()
                local xmasIsland = workspace.Main.Characters:FindFirstChild("Xmas Island")
                if xmasIsland then
                    local bossFolder = xmasIsland:FindFirstChild("Boss")
                    if bossFolder then
                        local herta = bossFolder:FindFirstChild("Herta")
                        if herta
                        and herta:FindFirstChild("Humanoid")
                        and herta:FindFirstChild("HumanoidRootPart")
                        and herta.Humanoid.Health > 0 then
                            _G.CurrentFarmTarget = herta
                            HitMon()
                            if (herta.Humanoid.Health / herta.Humanoid.MaxHealth) < 0.5 then
                                instaKill(herta)
                            end
                        else
                            _G.CurrentFarmTarget = nil
                        end
                    end
                end

                local currentTarget = GetCurrentTarget()
                if not currentTarget then return end

                local island = workspace.Main.Characters:FindFirstChild(currentTarget.Island)
                if not island then return end

                local bossFolder = island:FindFirstChild(currentTarget.MobFolder)
                if not bossFolder then return end

                local Boss = GetLockTarget(bossFolder, currentTarget.Bname)
                if Boss then
                    _G.CurrentFarmTarget = Boss
                    HitMon()
                    -- ใช้ Physics Kill ถ้าบอสนั้นตั้งค่า InstaKill ไว้
                    if (Boss.Humanoid.Health / Boss.Humanoid.MaxHealth) < 0.85 then
                        if currentTarget.InstaKill then
                            instaKill(Boss)
                        end
                    end
                else
                    _G.CurrentFarmTarget = nil
                end
            end)
        end
        _G.CurrentFarmTarget = nil
        _G.LockedTarget = nil
    end)
end,
})


local ToggleHaki = FarmSection:AddToggle("MyToggle", {
    Title = "Auto FarmHaki",
    Default = false,
    Callback = function(Haki)
        _G.Haki = Haki
        task.spawn(function()
            while _G.Haki do
                task.wait()
                pcall(function()
                    local args = { "Server", "Misc", "Haki", 1 }
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Remotes")
                        :WaitForChild("Serverside")
                        :FireServer(unpack(args))
                    local args = { "Server", "Misc", "Haki", 2 }
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Remotes")
                        :WaitForChild("Serverside")
                        :FireServer(unpack(args))
                end)
            end
        end)
    end,
})

local SummonLock = false
local LAST_SUMMON_TIME = 0
local SUMMON_COOLDOWN = 3
local LastBossAlive = false

local ToggleSummon = Boss:AddToggle("AutoSummon", {
	Title = "Auto Summon",
	Description = "Summon Boss",
	Default = false,
	Callback = function(state)
		_G.Autusummon = state

		task.spawn(function()
			while _G.Autusummon do
				task.wait()

				pcall(function()
					local currentTarget = GetCurrentTarget()
					if not currentTarget then return end

					local island = workspace.Main.Characters:FindFirstChild(currentTarget.Island)
					if not island then return end

					local bossFolder = island:FindFirstChild(currentTarget.MobFolder)
					if not bossFolder then return end

					local bossAlive = IsBossAlive(currentTarget)

					if LastBossAlive and not bossAlive then
						SummonLock = false
						LAST_SUMMON_TIME = 0
					end
					LastBossAlive = bossAlive

					if bossAlive then
						return
					end

					if not currentTarget.NeedSummon then
						return
					end

					if currentTarget == selectedBossPityInfo
					and LocalPlayer.Pity.Boss.Value < 25 then
						return
					end

					if SummonLock then return end
					if os.clock() - LAST_SUMMON_TIME < SUMMON_COOLDOWN then return end

					SummonLock = true
                    _G.CurrentFarmTarget = nil

					if currentTarget.Bname == "Abyssal Beast" then
						LocalPlayer.Character.HumanoidRootPart.CFrame =
							CFrame.new(84.6231308, 2.05233765, -1275.61133)

						local Aby = LocalPlayer.PlayerGui.Button.Storage_Frame.Material_Frame["Core of Shadow"].Button
						interact(Aby)

						local confirm = LocalPlayer.PlayerGui.Button.Confirm
						if confirm and confirm:FindFirstChild("Accept") then
							interact(confirm.Accept.Button)
						end
                    elseif currentTarget.Bname == "Aizen" then
                        local npc = workspace.Main.NPCs:FindFirstChild("Boss Spawn5")
                        if npc then
                            local part = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0, -2)
                                task.wait()
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                                task.wait(0.1)
                                vim:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                            end
                        end
                    elseif currentTarget.Bname == "Yami" then
                        local npc = workspace.Main.NPCs:FindFirstChild("Boss Spawn7")
                        if npc then
                            local part = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0, -2)
                                task.wait()
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                                task.wait(0.1)
                                vim:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                            end
                        end
					else
                        -- [Generic Summon Logic] (Fast & Fixed Pos)
                        
                        -- 2. Interact with GUI directly (No 'E' press, Fast)
						local gui = LocalPlayer.PlayerGui.Button:FindFirstChild("Boss Spawn")
						if gui then
                             -- Select Boss
                             local targetBtn = gui.Frame:FindFirstChild(currentTarget.Bname) and gui.Frame[currentTarget.Bname]:FindFirstChild("Button")
                             if targetBtn then
                                 interact(targetBtn)
                             end
                             
                             -- Click Spawn (Rapidly)
                             local spawnBtn = gui.Spawn:FindFirstChild("Button")
                             if spawnBtn then 
                                interact(spawnBtn) 
                             end
                        end
					end

					LAST_SUMMON_TIME = os.clock()
					SummonLock = false
				end)
			end
		end)
	end,
})

local NpcLocations = {
    ["Aizen"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.Aizen:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Akaza"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.Akaza:FindFirstChild("HumanoidRootPart").CFrame end,
    ["David"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.David:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Gojo"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.Gojo:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Sukuna"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.Sukuna:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Tensa Zangetsu"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Sword["Tanjiro's Nichirin"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Garou"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.Garou:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Metal Bat"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Sword["Metal Bat"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Craft"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Main.NPCs.Craft:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Shigaraki"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.Shigaraki:FindFirstChild("HumanoidRootPart").CFrame end,
    ["OFA"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Combat.OFA:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Tanjiro's Nichirin"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Sword["Tensa Zangetsu"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Zangetsu"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Sword.Zangetsu:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Boss Spawn1"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Boss Spawn1"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Boss Spawn2"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Boss Spawn2"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Boss Spawn3"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Boss Spawn3"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Exchange"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Exchange:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Fruit Reroll Gem"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Fruit Reroll Gem"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Fruit Reroll Money"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Fruit Reroll Money"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Guarantee"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Guarantee:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Haki Trainer"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Haki Trainer"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Mission"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Mission:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Observation Trainer"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Observation Trainer"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Rank Up"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Rank Up"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Shop"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Shop:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Stats Reroll"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Stats Reroll"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Titlex"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs.Title:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Trait Reroll"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Main.NPCs["Trait Reroll"]:FindFirstChild("HumanoidRootPart").CFrame end,
    ["Gryphon Seller"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-653.216431, 12.4093266, -137.052368, -0.899187803, -9.23316961e-08, 0.437562883, -7.49186313e-08, 1, 5.70564289e-08, -0.437562883, 1.85228348e-08, -0.899187803) end,
    ["Dark Blade Seller"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(16.1474495, 4.92373991, 161.662933, 1, 9.87983584e-10, 1.48601343e-14, -9.87983584e-10, 1, 3.90733845e-09, -1.48562752e-14, -3.90733845e-09, 1) end,
    ["Katana Seller"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8.16558456, 8.98901463, -299.434937, 1, 6.76208174e-08, 2.79884193e-06, -6.76205048e-08, 1, -1.11793391e-07, -2.79884193e-06, 1.11793206e-07, 1) end,
    ["Dual Katana Seller"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(427.317322, 6.73008156, -0.800981462, 0.999563396, -2.07526654e-08, -0.0295462385, 2.41920013e-08, 1, 1.16047723e-07, 0.0295462385, -1.16711838e-07, 0.999563396) end,
    ["Yuta Katana"] = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1150.33704, 13.1109982, -235.757065, 0.999256253, -4.89314402e-08, -0.0385607332, 5.24925596e-08, 1, 9.13384781e-08, 0.0385607332, -9.32946946e-08, 0.999256253) end,
}

local NpcList = {}
for name, _ in pairs(NpcLocations) do
    table.insert(NpcList, name)
end
table.sort(NpcList)

local SelectedNPC = nil

TeleportNPCSection:AddDropdown("NPCDropdown", {
    Title = "Select NPC",
    Values = NpcList,
    Multi = false,
    Default = "-",
    Callback = function(val)
        SelectedNPC = val
    end,
})

TeleportNPCSection:AddButton({
    Title = "Teleport to NPC",
    Description = "Teleport to selected NPC",
    Callback = function()
        if SelectedNPC and NpcLocations[SelectedNPC] then
            NpcLocations[SelectedNPC]()
        end
    end
})

local IslandLocations = {
    ["Windmill Village"] = CFrame.new(-44.0609131, 3.08807135, -571.113708, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["Whispering Jungle"] = CFrame.new(-690.277222, 1.78928399, 5.34004211, -0.0799411535, 0.191931754, -0.97814703, -0.0688033774, 0.97788471, 0.197503358, 0.994422197, 0.0830884501, -0.0649676323),
    ["Throne Isle"] = CFrame.new(961.135742, 2.49908042, -1313.3645, -0.766061664, 2.95228074e-05, -0.642767608, -2.95228074e-05, 1, 8.11165592e-05, 0.642767608, 8.11165592e-05, -0.766061664),
    ["Jujutsu Highschool"] = CFrame.new(1050.82178, 1.35501599, 194.751434, -0.939700961, -1.49886746e-05, 0.341998369, 1.49886746e-05, 1, 8.50107754e-05, -0.341998369, 8.50107754e-05, -0.939700961),
    ["Sandora Island"] = CFrame.new(608.72644, 3.97227073, -516.0672, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Rogue Town"] = CFrame.new(563.232422, 1.54122496, 659.901978, -0.462240219, 0, 0.886754811, 0, 1, 0, -0.886754811, 0, -0.462240219),
    ["HuceoMundo"] = CFrame.new(-881.05127, 3.88862944, -960.520691, 0.674007297, 0, 0.738724709, 0, 1, 0, -0.738724709, 0, 0.674007297),
    ["Glacier Isle"] = CFrame.new(-3.45288086, 8.36556435, 25.2759247, -0.991586566, 0.0124191586, -0.128851101, 0.0170360655, 0.999249399, -0.0347912572, 0.128322318, -0.0366936438, -0.99105382),
    ["Forge Isle"] = CFrame.new(-802.703918, 5.76603603, 643.961426, -0.882289171, 0.171407714, -0.43838945, 0.190775529, 0.981633663, -0.000135950744, 0.430314571, -0.0837539211, -0.898785114),
    ["Abyss Hill"] = CFrame.new(228.779907, 12.4649067, -1680.9585, 0.980784655, -0, -0.195093334, 0, 1, -0, 0.195093334, 0, 0.980784655),
    ["Konoha Island"] = CFrame.new(-213.062195, 4.12318802, 1101.14148, -0.0459707975, 0, 0.998942792, 0, 1, 0, -0.998942792, 0, -0.0459707975),
    ["Hage Island"] = CFrame.new(-939.560486, 3.47815585, -746.768616, -0.823644161, 0, 0.567107022, 0, 1, 0, -0.567107022, 0, -0.823644161)
}

local IslandList = {}
for name, _ in pairs(IslandLocations) do
    table.insert(IslandList, name)
end
table.sort(IslandList)

local SelectedIsland = nil

TeleportIslandSection:AddDropdown("IslandDropdown", {
    Title = "Select Island",
    Values = IslandList,
    Multi = false,
    Default = "-",
    Callback = function(val)
        SelectedIsland = val
    end,
})

TeleportIslandSection:AddButton({
    Title = "Teleport to Island",
    Description = "Teleport to selected Island",
    Callback = function()
        if SelectedIsland and IslandLocations[SelectedIsland] then
            LocalPlayer.Character.HumanoidRootPart.CFrame = IslandLocations[SelectedIsland]
        end
    end
})

local function setChestAmount(amount)
    local PlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end
    
    local confirm = PlayerGui:FindFirstChild("Button") and PlayerGui.Button:FindFirstChild("Confirm")
    if not confirm then return end

    local textBox = confirm.Search.BG.TextBox
    if not textBox then return end

    textBox:CaptureFocus()
    task.wait(0.2)
    textBox.Text = tostring(amount)
    
    -- กด Enter เพื่อยืนยันตัวเลขกับเกม
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    
    task.wait(0.2)
    textBox:ReleaseFocus()
end

local function AutoOpenChest(chestName, needAmount, openAmount)
    local PlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end

    if not PlayerGui:FindFirstChild("Button") then return end
    
    local materialFrame =
        PlayerGui.Button.Storage_Frame.Material_Frame:FindFirstChild(chestName)
    if not materialFrame then return end

    local amountText = materialFrame.Amout.Text
    local amount = tonumber(amountText:match("%d+")) or 0
    
    -- [Fix] แก้เงื่อนไขให้เปิดได้แม้มีของน้อย (แต่ต้องมีอย่างน้อย 1)
    if amount <= 0 then return end 

    -- [Fix] คำนวณจำนวนที่จะเปิด ไม่ให้เกินที่มี
    local actualOpen = openAmount
    if amount < openAmount then
        actualOpen = amount
    end

    interact(materialFrame.Button)

    local confirm = PlayerGui.Button:WaitForChild("Confirm", 3)
    if not confirm or not confirm.Visible then return end

    task.wait(1) -- รอให้ UI เด้งขึ้นมาให้ครบก่อน
    setChestAmount(actualOpen) -- ใช้จำนวนที่คำนวณแล้ว
    task.wait(0.5) -- รอหลังใส่ตัวเลข

    if confirm.Accept and confirm.Accept:FindFirstChild("Button") then
        interact(confirm.Accept.Button)
        -- กดครั้งเดียวพอ ไม่กดซ้ำ
    end

    task.wait(3) -- รอ Animation จบ และรอ Cooldown เกมหายไปก่อนเริ่มใหม่
end

local ChestsList = {
    "Common Chest",
    "Rare Chest",
    "Legendary Chest",
    "Mythical Chest"
}
local SelectedChest = "Common Chest"

Csh:AddDropdown("ChestSelect", {
    Title = "Select Chest Type",
    Values = ChestsList,
    Multi = false,
    Default = "Common Chest",
    Callback = function(val)
        SelectedChest = val
    end
})

Csh:AddToggle("AutoOpenChestToggle", {
    Title = "Auto Open Selected Chest",
    Default = false,
    Callback = function(v)
        _G.AutoOpenChest = v
        if v then
            task.spawn(function()
                while _G.AutoOpenChest do
                    task.wait(2)
                    pcall(function()
                        -- กำหนดจำนวนเปิดอัตโนมัติ
                        local openAmt = 200
                        if SelectedChest == "Mythical Chest" then
                            openAmt = 100
                        end
                        
                        AutoOpenChest(SelectedChest, 0, openAmt)
                    end)
                end
            end)
        end
    end
})


        local DropdownBuy = Cshh:AddDropdown("Dropdown", {
        Title = "Select Items",
        Description = "",
        Values = {
            "Common Chest",
            "Legendary Chest",
            "Mythical Chest",
            "Rare Chest",
            "Summon Orb"
            },
        Multi = false,
        Default = "-",
        Callback = function(value)
            selectedBuy = value
        end,
    })
local Input = Cshh:AddInput("Input", {
    Title = "Set Amount",
    Default = "20",
    Placeholder = "Put number here",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local Event =
            game:GetService("Players")
            .LocalPlayer
            .PlayerGui
            .Button
            ["Shop Item"]
            ["{}"]
            .Event

        Event:FireServer(tostring(Value))
    end
})

local gui = LocalPlayer.PlayerGui

local ToggleBuy = Cshh:AddToggle("AutoBuy", {
    Title = "AutoBuy Summon Orb",
    Default = false,
    Callback = function(TaAutoAutoBuy)
        _G.AutoBuy = TaAutoAutoBuy

        task.spawn(function()
            while _G.AutoBuy do
                task.wait()

                pcall(function()
                    local PlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
                    if not PlayerGui then return end
                    
                    local material = PlayerGui.Button.Storage_Frame.Material_Frame
                    local amount = 0
                    local orb = material:FindFirstChild("Summon Orb")

                    if orb and orb:FindFirstChild("Amout") and orb.Amout:IsA("TextLabel") then
                        amount = tonumber(string.match(orb.Amout.Text, "%d+")) or 0
                    end

                    if amount <= 100 then
                        local ok, buyBtn = pcall(function()
                            return PlayerGui.Button["Shop Item"].Gems["Summon Orb"].Buy.Button
                        end)

                        if ok and buyBtn then
                            interact(buyBtn)
                        end
                    end
                end)
            end
        end)
    end,
})



Cshh:AddButton({
    Title = "Buy Item (Gems)",
    Callback = function()
       obb = game:GetService("Players").LocalPlayer.PlayerGui.Button["Shop Item"].Gems[selectedBuy].Buy.Button
       interact(obb)
    end
})
Cshh:AddButton({
    Title = "Buy Item (Gold)",
    Callback = function()
       obb = game:GetService("Players").LocalPlayer.PlayerGui.Button["Shop Item"].Money[selectedBuy].Buy.Button
       interact(obb)
    end
})

-- ==========================================
-- GUI OPEN SECTION (New)
-- ==========================================
local GuiOpenSec = Tabs.Che:AddSection("Gui Open")

local GuiOpenList = {
    "None",
    "Blacksmith", "Capsule", "Chest Exchange", "Craft", "Exchange",
    "Gacha", "Gacha (Hakari)", "Gacha (Solemn Lament)", "Guarantee",
    "Night Market", "Rank Up", "Reroll Stats", "Shop Item",
    "Snowflake Exchange", "Titlex", "Trait Reroll"
}

local GuiPathNames = {
    ["Blacksmith"] = "Blacksmith",
    ["Capsule"] = "Capsule",
    ["Chest Exchange"] = "Chest Exchange",
    ["Craft"] = "Craft",
    ["Exchange"] = "Exchange_Frame",
    ["Gacha"] = "Gacha",
    ["Gacha (Hakari)"] = "Gacha (Hakari)",
    ["Gacha (Solemn Lament)"] = "Gacha (Solemn Lament)",
    ["Guarantee"] = "Guarantee",
    ["Night Market"] = "Night Market",
    ["Rank Up"] = "Rank Up",
    ["Reroll Stats"] = "Reroll Stats",
    ["Shop Item"] = "Shop Item",
    ["Snowflake Exchange"] = "Snowflake Exchange",
    ["Titlex"] = "Title_Frame",
    ["Trait Reroll"] = "Trait Reroll"
}

local LastOpenedInstance = nil

GuiOpenSec:AddDropdown("GuiOpenSelector", {
    Title = "Select GUI to Open",
    Values = GuiOpenList,
    Multi = false,
    Default = "None",
    Callback = function(val)
        local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        local buttonFolder = playerGui:FindFirstChild("Button")
        if not buttonFolder then return end

        -- ปิดอันเก่าที่เคยเปิดไว้
        if LastOpenedInstance then
            LastOpenedInstance.Visible = false
            LastOpenedInstance = nil
        end

        if val == "None" then
            return
        end

        local targetName = GuiPathNames[val]
        if targetName then
            local target = buttonFolder:FindFirstChild(targetName)
            if target then
                target.Visible = true
                LastOpenedInstance = target
            end
        end
    end,
})

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Window:SelectTab(1)

    Fluent:Notify({
        Title = "[RESTLESS GAMBLER] Rogue Piece",
        Content = "The script has been loaded.",
        Duration = 8,
    })

    SaveManager:LoadAutoloadConfig()

    Tabs.Settings:AddToggle("WhiteScreenMode", {
        Title = "White Screen",
        Description = "if open can't off",
        Default = false,
        Callback = function(Value)
            local RunService = game:GetService("RunService")
            local CoreGui = game:GetService("CoreGui")
            local overlayName = "Xrzv_WhiteScreen"

            if Value then
                if not CoreGui:FindFirstChild(overlayName) then
                    local sg = Instance.new("ScreenGui")
                    sg.Name = overlayName
                    sg.IgnoreGuiInset = true
                    sg.Parent = CoreGui
                    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

                    local fr = Instance.new("Frame")
                    fr.Parent = sg
                    fr.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    fr.Size = UDim2.new(1, 0, 1, 0)
                    fr.ZIndex = 99999
                end

                if CoreGui:FindFirstChild(overlayName) then
                    CoreGui[overlayName].Enabled = true
                end

                RunService:Set3dRenderingEnabled(false)
            else
                RunService:Set3dRenderingEnabled(true)

                if CoreGui:FindFirstChild(overlayName) then
                    CoreGui[overlayName].Enabled = false
                end
            end
        end,
    })

    local TraitModule = require(game:GetService("ReplicatedStorage").Modules.MetaData.Trait_Info)
    local TraitList = {}
    for TraitName, _ in pairs(TraitModule) do
        table.insert(TraitList, TraitName)
    end

    local SelectedTraits = {}
    
    -- Removed admin tab creation as requested

    local TraitDropdown = safeee:AddDropdown("TraitSelector", {
        Title = "Select Trait To Reroll",
        Values = TraitList,
        Multi = true,
        Default = {},
        Callback = function(Value)
            SelectedTraits = Value
        end,
    })

    local AutoTraitToggle = safeee:AddToggle("AutoTraitReroll", {
        Title = "Auto Trait Reroll",
        Description = "",
        Default = false,
        Callback = function(Value)
            _G.AutoTraitReroll = Value

            task.spawn(function()
                while _G.AutoTraitReroll do
                    task.wait(0.1)
                    pcall(function()
                        local CurrentTrait = Player.Info.Trait.Value
                        local IsTraitSatisfied = false

                        for TargetTrait, IsSelected in pairs(SelectedTraits) do
                            if IsSelected and TargetTrait == CurrentTrait then
                                IsTraitSatisfied = true
                                break
                            end
                        end

                        if not IsTraitSatisfied then
                            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                                Player.Character.HumanoidRootPart.CFrame =
                                    CFrame.new(549.034607, 0.278488636, 841.805359, 0.46224016, -0, -0.886754811, 0, 1, -0, 0.886754811, 0, 0.46224016)
                            end

                            local ButtonGui = Player.PlayerGui:FindFirstChild("Button")
                            if ButtonGui then
                                local ConfirmGui = ButtonGui:FindFirstChild("Confirm")
                                local TraitGui = ButtonGui:FindFirstChild("Trait Reroll")

                                if ConfirmGui and ConfirmGui.Visible then
                                    local AcceptButton = ConfirmGui:FindFirstChild("Accept")
                                        and ConfirmGui.Accept:FindFirstChild("Button")
                                    if AcceptButton then
                                        interact(AcceptButton)
                                    end
                                elseif TraitGui and TraitGui.Visible then
                                    local RerollButton = TraitGui:FindFirstChild("Reroll")
                                        and TraitGui.Reroll:FindFirstChild("Button")
                                    if RerollButton then
                                        local CheckAgain = Player.Info.Trait.Value
                                        local StopRolling = false
                                        for TargetTrait, IsSelected in pairs(SelectedTraits) do
                                            if IsSelected and TargetTrait == CheckAgain then
                                                StopRolling = true
                                                break
                                            end
                                        end

                                        if not StopRolling then
                                            interact(RerollButton)
                                        end
                                    end
                                else
                                    if _G.AutoTraitReroll then
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait()
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    end
                                end
                            end
                        else
                            task.wait(1)
                        end
                    end)
                end
            end)
        end,
    })


local function safeGetAmount(parentFrame, itemName)
    if not parentFrame then return nil end
    local item = parentFrame:FindFirstChild(itemName)
    if not item then return nil end
    local txtObj = item:FindFirstChild("Amout") or item:FindFirstChild("Amount")
    if not txtObj then
        txtObj = item:FindFirstChildWhichIsA("TextLabel")
    end
    if not txtObj then return nil end
    return tonumber(string.match(tostring(txtObj.Text or ""), "%d+"))
end

local ToggleCraft = safeee:AddToggle("AutoCraftShadowCore", {
    Title = "Auto Craft Darkness Spirit",
    Default = false,
    Callback = function(Value)
        _G.AutoCraftShadowCore = Value

        local VIM = game:GetService("VirtualInputManager")
        local bossFolder = workspace.Main.Characters["Throne Isle"]["Boss"]

        task.spawn(function()
            while _G.AutoCraftShadowCore do
                task.wait()
                pcall(function()
                    local gui = LocalPlayer.PlayerGui
                    local materialFrame = gui.Button
                        and gui.Button.Storage_Frame
                        and gui.Button.Storage_Frame.Material_Frame

                    if not materialFrame then return end

                    local dark = safeGetAmount(materialFrame, "Darkness Spirit")
                    local sommon = safeGetAmount(materialFrame, "Summon Orb")
                    local token = safeGetAmount(materialFrame, "Boss Token")

                    if dark and dark >= 499 then
                        _G.AutoCraftShadowCore = false
                        return
                    end

                    if not (sommon and sommon > 0) or (sommon <= 400) then
                        local ok, buyBtn = pcall(function()
                            return gui.Button["Shop Item"].Gems["Summon Orb"].Buy.Button
                        end)
                        if ok and buyBtn then interact(buyBtn) end
                    end

                    if not (token and token > 0) or (token < 499) then
                        local bossAlive = false
                        for _, v in pairs(bossFolder:GetChildren()) do
                            if v.Name == "Sukuna" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                bossAlive = true
                                break
                            end
                        end

                        if not bossAlive then
                            LocalPlayer.Character.HumanoidRootPart.CFrame =
                                workspace.Main.NPCs["Boss Spawn1"].HumanoidRootPart.CFrame
                            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, LocalPlayer)
                            task.wait(0.1)
                            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, LocalPlayer)
                            local guiSpawn = gui.Button["Boss Spawn"]
                            if guiSpawn then
                                local summonBtn = guiSpawn.Frame and guiSpawn.Frame["Sukuna"] and guiSpawn.Frame["Sukuna"].Button
                                local spawnBtn = guiSpawn.Spawn and guiSpawn.Spawn.Button
                                if summonBtn then interact(summonBtn) end
                                if spawnBtn then interact(spawnBtn) end
                            end
                        end

                        local Boten = GetLockTarget(bossFolder, "Sukuna")
                        if Boten then
                            _G.CurrentFarmTarget = Boten
                            HitMon()
                        else
                            _G.CurrentFarmTarget = nil
                        end
                    end

                    if (sommon and sommon >= 52) and (token and token >= 27) then
                        local ok, craftBtn = pcall(function()
                            return gui.Button.Craft.Craft_Frame.Scroll["Darkness Spirit"].Craft.Button
                        end)
                        if ok and craftBtn then
                            interact(craftBtn)
                            task.wait()
                        end
                    end
                end)
            end
            _G.CurrentFarmTarget = nil
            _G.LockedTarget = nil
        end)
    end,
})

local function GetPotionAmount(potionFrame)
    if not potionFrame then return 0 end
    local amountLabel = potionFrame:FindFirstChild("Amout")
    if not amountLabel or not amountLabel.Text then return 0 end
    return tonumber(amountLabel.Text:match("%d+")) or 0
end

-- ==========================================
-- POTION SECTION (Replaced with Dropdown)
-- ==========================================
local SelectedPotionType = "Luck Potion"

safeeee:AddDropdown("PotionSelect", {
    Title = "Select Potion",
    Values = {"Luck Potion", "Gems Potion", "Money Potion"},
    Multi = false,
    Default = "Luck Potion",
    Callback = function(val)
        SelectedPotionType = val
    end,
})

safeeee:AddToggle("AutoCraftPotion", {
    Title = "Auto Craft Selected Potion",
    Default = false,
    Callback = function(state)
        _G.AutoCraftPotionState = state
        task.spawn(function()
            while _G.AutoCraftPotionState do
                task.wait()
                pcall(function()
                    local gui = LocalPlayer.PlayerGui
                    local material = gui.Button.Storage_Frame.Material_Frame
                    
                    if SelectedPotionType == "Luck Potion" then
                        local ark = safeGetAmount(material, "Luck Potion") or 0
                        if safeGetAmount(material, "Clover Leaf") and safeGetAmount(material, "Clover Leaf") > 0 and ark < 10 then
                            interact(gui.Button.Craft.Craft_Frame.Scroll["Luck Potion"].Craft.Button)
                        end
                    elseif SelectedPotionType == "Gems Potion" then
                        local ark = safeGetAmount(material, "Gems Potion") or 0
                        if safeGetAmount(material, "Broken Edge") and safeGetAmount(material, "Broken Edge") > 0 and ark < 10 then
                            interact(gui.Button.Craft.Craft_Frame.Scroll["Gems Potion"].Craft.Button)
                        end
                    elseif SelectedPotionType == "Money Potion" then
                        local ark = safeGetAmount(material, "Money Potion") or 0
                        if safeGetAmount(material, "Golden Oath") and safeGetAmount(material, "Golden Oath") > 0 and ark < 10 then
                            interact(gui.Button.Craft.Craft_Frame.Scroll["Money Potion"].Craft.Button)
                        end
                    end
                end)
            end
        end)
    end,
})

safeeee:AddToggle("AutoUsePotion", {
    Title = "Auto Use Selected Potion",
    Default = false,
    Callback = function(state)
        _G.AutoUsePotionState = state
        task.spawn(function()
            while _G.AutoUsePotionState do
                task.wait(0.5)
                pcall(function()
                    local gui = LocalPlayer.PlayerGui
                    local materialFrame = gui.Button.Storage_Frame.Material_Frame
                    
                    local activeBuffName = ""
                    if SelectedPotionType == "Luck Potion" then activeBuffName = "Luck"
                    elseif SelectedPotionType == "Gems Potion" then activeBuffName = "Gems"
                    elseif SelectedPotionType == "Money Potion" then activeBuffName = "Money" 
                    end

                    -- Check if buff is already active
                    if activeBuffName ~= "" and gui.Misc.Potions:FindFirstChild(activeBuffName) and gui.Misc.Potions[activeBuffName].Visible then
                        return
                    end

                    local potionFrame = materialFrame:FindFirstChild(SelectedPotionType)
                    if not potionFrame or GetPotionAmount(potionFrame) <= 0 then return end
                    
                    interact(potionFrame.Button)
                    task.wait(0.1)
                    if gui.Button.Confirm.Visible then
                        interact(gui.Button.Confirm.Accept.Button)
                    end
                end)
            end
        end)
    end,
})

    

    -- ==========================================
    -- GACHA SECTION (Reroll Tab)
    -- ==========================================
    local GachaSection = Tabs.safe:AddSection("Gacha")
    local SelectedGacha = "Zangetsu"
    GachaSection:AddDropdown("GachaSelect", {
        Title = "Select Gacha",
        Values = {"Zangetsu", "Hakari", "Solemn Lament"},
        Default = "Zangetsu",
        Callback = function(val)
            SelectedGacha = val
        end,
    })

    GachaSection:AddToggle("AutoGacha", {
        Title = "Auto Gacha x10",
        Default = false,
        Callback = function(state)
            _G.AutoGacha = state
            task.spawn(function()
                while _G.AutoGacha do
                    task.wait(0.5)
                    pcall(function()
                        local gui = game:GetService("Players").LocalPlayer.PlayerGui
                        local btn = nil
                        
                        -- เลือกปุ่มตามที่เลือกใน Dropdown
                        if SelectedGacha == "Zangetsu" then
                            -- ใช้ Path ตามที่ขอสำหรับ Zangetsu (ใช้ปุ่มเดิมที่เคยใช้ได้)
                            btn = gui.Button.Gacha.x10.Button 
                        elseif SelectedGacha == "Hakari" then
                            btn = gui.Button["Gacha (Hakari)"].x10.Button
                        elseif SelectedGacha == "Solemn Lament" then
                            btn = gui.Button["Gacha (Solemn Lament)"].x10.Button
                        end

                        if btn then
                            interact(btn)
                        end
                    end)
                end
            end)
        end,
    })

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("SailorPiece_Mamypoko")
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

task.delay(1, function()
    if Fluent.Options.InterfaceTheme then
        Fluent.Options.InterfaceTheme:SetValue("Darker")
    end
    if Fluent.Options.TransparentToggle then
        Fluent.Options.TransparentToggle:SetValue(false)
    end
end)

Window:SelectTab(1)
