    repeat task.wait(1) until game:IsLoaded()
  
  pcall(function()
      game:GetService("CoreGui").RobloxGui["CoreScripts/NetworkPause"]:Destroy()
  end)
  
  pcall(function()
      game:GetService("RunService").Heartbeat:Connect(function()
          _G.ActiveToolSelf = nil
      end)
  end)
  
  local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/dist/main.lua?v=" .. tostring(math.random(1, 100000))))()
  local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/SaveManager.lua?v=" .. tostring(math.random(1, 100000))))()
  local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/InterfaceManager.lua?v=" .. tostring(math.random(1, 100000))))()
  
  local TweenService = game:GetService("TweenService")
  local Players = game:GetService("Players")
  local ReplicatedStorage = game:GetService("ReplicatedStorage")
  local UserInputService = game:GetService("UserInputService")
  local VirtualInputManager = game:GetService("VirtualInputManager")
  local VirtualUser = game:GetService("VirtualUser")
  local Player = Players.LocalPlayer
  
  local TraitConfig = nil
  pcall(function()
      TraitConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("TraitConfig"))
  end)
  
  local mobdata = {
      ["Bandit ( Lv.5 )"] = { Mobname = "Bandit", QuestName = "Quest Bandits", Portal = "Starter" },
      ["Bandit ( Lv.200 )"] = { Mobname = "Bandit Leader", QuestName = "Quest Bandit Leader", Portal = "Starter" },
      ["Namekian ( Lv.250 )"] = { Mobname = "Namekian", QuestName = "Quest Namekians", Portal = "JungleIsland" },
      ["Piccolo ( Lv.500 )"] = { Mobname = "Piccolo", QuestName = "Quest Piccolo", Portal = "JungleIsland" },
      ["Serpoian ( Lv.750 )"] = { Mobname = "Serpoian", QuestName = "Quest Serpoians", Portal = "JungleIsland" },
      ["Serpoian (True Form) ( Lv.1000 )"] = { Mobname = "Serpoian (True Form)", QuestName = "Quest Serpoian (True Form)", Portal = "JungleIsland" },
      ["Beggar ( Lv.1350 )"] = { Mobname = "Beggar", QuestName = "Quest Beggars", Portal = "ACity" },
      ["Aristocrat ( Lv.1750 )"] = { Mobname = "Aristocrat", QuestName = "Quest Aristocrat", Portal = "ACity" },
      ["Cursed Students ( Lv.2250 )"] = { Mobname = "Cursed Student", QuestName = "Quest Cursed Students", Portal = "JujutsuAcademy" },
      ["Cursed Teacher ( Lv.2750 )"] = { Mobname = "Cursed Teacher", QuestName = "Quest Cursed Teacher", Portal = "JujutsuAcademy" },
      ["Hollows ( Lv.3250 )"] = { Mobname = "Hollow", QuestName = "Quest Hollows", Portal = "HollowLand" },
      ["Shinigami ( Lv.3850 )"] = { Mobname = "Shinigami", QuestName = "Quest Shinigami", Portal = "HollowLand" },
      ["Demon Slayer ( Lv.4500 )"] = { Mobname = "Demon Slayer", QuestName = "Quest Demon Slayers", Portal = "SlayerMansion" },
      ["Nameless Pillar ( Lv.5250 )"] = { Mobname = "Nameless Pillar", QuestName = "Quest Nameless Pillar", Portal = "SlayerMansion" },
      ["Ghoul Investigator ( Lv.6000 )"] = { Mobname = "Ghoul Investigator", QuestName = "Quest Ghoul Investigators", Portal = "TokyoGhoul" },
      ["Ghoul ( Lv.6750 )"] = { Mobname = "Ghoul", QuestName = "Quest Ghouls", Portal = "TokyoGhoul" },
		["Hishaku Member ( Lv.7750 )"] = { Mobname = "Hishaku Member", QuestName = "Quest Hishaku Members", Portal = "RuinCity"},
      ["Distortion Monsters ( Lv.7750 )"] = { Mobname = "Distortion Monster", QuestName = "Quest Distortion Monsters", Portal = "RuinCity" },
  
      ["Fire Force Bandit ( Lv.8100 )"] = { Mobname = "Fire Force Bandit", QuestName = "Quest Fire Force Bandit", Portal = "7thComanpyIsland" },
      ["Fire Force E.Bandit ( Lv.8500 )"] = { Mobname = "Fire Force E.Bandit", QuestName = "Quest Fire Force E.Bandit", Portal = "7thComanpyIsland"},
  }
  
  local bossdata = {
      ["Garou"] = { Mobname = "Garou", Portals = {"ACity"} },
      ["Blast"] = { Mobname = "Blast", Portals = {"ACity"} },
      ["Flashy Flash"] = { Mobname = "Flashy Flash", Portals = {"ACity"} },
      ["Rudo Surebrec"] = { Mobname = "Rudo Surebrec", Portals = {"ACity"} },
      ["Cid Kagenou [World Boss]"] = { Mobname = "Cid Kagenou [World Boss]", Portals = {"ACity", "JujutsuAcademy", "TokyoGhoul","HollowLand","RuinCity"} },
      ["One-Eyed Owl [World Boss]"] = { Mobname = "One-Eyed Owl [World Boss]", Portals = {"JujutsuAcademy", "TokyoGhoul","ACity","HollowLand","RuinCity"} },
      ["Sosuke Aizen"] = { Mobname = "Sosuke Aizen", Portals = {"HollowLand"} },
      ["Chihora"] = { Mobname = "Chihora", Portals = {"RuinCity"} },
      ["Akaza"] = { Mobname = "Akaza", Portals = {"SlayerMansion"} },
      ["Ichigo Kurosaki"] = { Mobname = "Ichigo Kurosaki", Portals = {"HollowLand"} },
      ["Satoru Gojo"] = { Mobname = "Satoru Gojo", Portals = {"JujutsuAcademy"} },
      ["Ken Kaneki"] = { Mobname = "Ken Kaneki", Portals = {"TokyoGhoul"} },
      ["Ryomen Sukuna"] = { Mobname = "Ryomen Sukuna", Portals = {"JujutsuAcademy"} },
      ["The Red Mist"] = { Mobname = "The Red Mist", Portals = {"RuinCity","ACity","HollowLand","TokyoGhoul"} },
		["Demon Infernal"] = { Mobname = "Demon Infernal", Portals = {"RuinCity","7thComanpyIsland","ACity","HollowLand","TokyoGhoul"} },
      ["Turbo Granny"] = { Mobname = "Turbo Granny", Portals = {"JungleIsland"} },
		["Infernal Ambusher"] = { Mobname = "Infernal Ambusher", Portals = {"7thComanpyIsland","ACity","RuinCity"} },
  }
  
  local summonbossdata = {
      ["Ken Kaneki"] = { NPCName = "Gray Whisperer", BossName = "Ken Kaneki", Portal = "TokyoGhoul", Mobname = "Ken Kaneki" },
      ["Akaza"] = { NPCName = "Pink Whisperer", BossName = "Akaza", Portal = "SlayerMansion", Mobname = "Akaza" },
      ["Ichigo Kurosaki"] = { NPCName = "The Whisperer", BossName = "Ichigo Kurosaki", Portal = "HollowLand", Mobname = "Ichigo Kurosaki" },
      ["Sosuke Aizen"] = { NPCName = "The Whisperer", BossName = "Sosuke Aizen", Portal = "HollowLand", Mobname = "Sosuke Aizen" },
      ["Satoru Gojo"] = { NPCName = "Yellow Whisperer", BossName = "Satoru Gojo", Portal = "JujutsuAcademy", Mobname = "Satoru Gojo" },
      ["Ryomen Sukuna"] = { NPCName = "Yellow Whisperer", BossName = "Ryomen Sukuna", Portal = "JujutsuAcademy", Mobname = "Ryomen Sukuna" },
      ["Blast"] = { NPCName = "White Whisperer", BossName = "Blast", Portal = "ACity", Mobname = "Blast" },
      ["Flashy Flash"] = { NPCName = "White Whisperer", BossName = "Flashy Flash", Portal = "ACity", Mobname = "Flashy Flash" },
      ["Garou"] = { NPCName = "White Whisperer", BossName = "Garou", Portal = "ACity", Mobname = "Garou" },
		["Chihora"] = { NPCName = "PauPau Whisperer", BossName = "Chihora", Portal = "RuinCity", Mobname = "Chihora" },
      ["Cid Kagenou [World Boss]"] = { NPCName = "Sacrifice Table", BossName = "Cid Kagenou", Portal = "RuinCity", Portals = {"ACity", "JujutsuAcademy", "TokyoGhoul","RuinCity"}, Mobname = "Cid Kagenou [World Boss]" },
      ["One-Eyed Owl [World Boss]"] = { NPCName = "Sacrifice Table", BossName = "One-Eyed Owl", Portal = "RuinCity", Portals = {"JujutsuAcademy", "TokyoGhoul", "ACity","RuinCity"}, Mobname = "One-Eyed Owl [World Boss]" },
      ["The Red Mist"] = { NPCName = "Sacrifice Table", BossName = "The Red Mist", Portal = "RuinCity", Portals = {"ACity", "HollowLand", "TokyoGhoul","RuinCity"}, Mobname = "The Red Mist" },
      ["Demon Infernal"] = { NPCName = "Sacrifice Table", BossName = "Demon Infernal", Portal = "RuinCity", Portals = {"RuinCity", "7thComanpyIsland", "ACity", "HollowLand", "TokyoGhoul"}, Mobname = "Demon Infernal" },
  }
  
  local ruinCitySacrificeBosses = {
      ["Cid Kagenou [World Boss]"] = true,
      ["One-Eyed Owl [World Boss]"] = true,
      ["The Red Mist"] = true,
      ["Demon Infernal"] = true
  }
  
  local allCodesList = {
      "sorryforbugs7!", "smallgift!", "update0.5!", "thanksfor1kccu!",
      "smallcodes!", "sorryforbugs4!", "addedbosspawn!", "sorryforbugs3!",
      "RELEASE!", "THANKSFORPLAYING!", "sorryforbugs!", "sorryforbugs2!",
      "sorryforbugs5!", "thanksfor1.5kccu!!", "performancefix!!!"
  }
  
  local MonsterList = {}
  for displayName, _ in pairs(mobdata) do table.insert(MonsterList, displayName) end
  table.sort(MonsterList, function(a, b)
      local numA = tonumber(string.match(a, "Lv%.%s*(%d+)")) or 0
      local numB = tonumber(string.match(b, "Lv%.%s*(%d+)")) or 0
      return numA < numB
  end)
  
  local BossList = {}
  for displayName, _ in pairs(bossdata) do table.insert(BossList, displayName) end
  table.sort(BossList)
  
  local SummonBossList = {}
  for displayName, _ in pairs(summonbossdata) do table.insert(SummonBossList, displayName) end
  table.sort(SummonBossList)
  
  local PityFarmBossList = {"Flashy Flash", "Garou", "Blast"}
  local PityTargetBossList = {}
  for _, displayName in ipairs(SummonBossList) do table.insert(PityTargetBossList, displayName) end
  
  
  local FireForceQuestDefinitions = {
      BattleExperience = {Code = "BE", Name = "Battle Experience", ObjType = "KillAny", Amounts = {250, 500, 1000, 2000}},
      DemonSlayer = {Code = "DS", Name = "Demon Slayer", ObjType = "Kill", Target = "Demon Infernal", Amounts = {1, 3, 6, 10}},
      AmbushHunt = {Code = "AH", Name = "Infernal Ambush", ObjType = "Kill", Target = "Infernal Ambusher", Amounts = {1, 3, 6, 10}},
      SpecialSuppression = {Code = "SS", Name = "Special Suppression", ObjType = "KillSpecialBoss", Amounts = {10, 20, 30, 50}},
      CatHunt = {Code = "CH", Name = "Stray Patrol", ObjType = "Cat", Amounts = {3, 5, 8, 12}},
      HostageRescue = {Code = "HR", Name = "Rescue Duty", ObjType = "Hostage", Amounts = {2, 4, 6, 10}}
  }
  local FireForceQuestOrder = {"BattleExperience", "DemonSlayer", "AmbushHunt", "SpecialSuppression", "CatHunt", "HostageRescue"}
  
  local EmbeddedIslandsData = {
      ["Starter Island"] = { PortalId = "Starter", LayoutOrder = 1, Npcs = { ["Mining"] = "Miner" } },
      ["Legacy Island"] = { PortalId = "Legacy", LayoutOrder = 2, Npcs = { ["Fishing"] = "Fisherman", ["Prestige"] = "Prestige Overseer", ["Stat Reroll"] = "Potential Reroll", ["Trait Reroll"] = "Trait Reroll", ["Summon"] = "Summon" } },
      ["Jungle Island"] = { PortalId = "JungleIsland", LayoutOrder = 3, Npcs = { ["Flashstep"] = "Rob Lucci" } },
      ["Ice Island"] = { PortalId = "IceIsland", LayoutOrder = 4, Npcs = { ["Armament Haki"] = "Rayleigh", ["Sovereign of Fates"] = "Spec Overwrite", ["Enhancement"] = "Enhancement" } },
      ["A-City"] = { PortalId = "ACity", LayoutOrder = 5, WorldKeys = {"A-City"}, Npcs = { ["Material Shop"] = "Material Shop", ["Observation Haki"] = "Enel", ["Boss Summon"] = "White Whisperer" } },
      ["Jujutsu Academy"] = { PortalId = "JujutsuAcademy", LayoutOrder = 6, WorldKeys = {"Jujutsu Academy"}, Npcs = { ["The Gatekeeper"] = "The Gatekeeper", ["Boss Summon"] = "Yellow Whisperer" } },
      ["Hollow Land"] = { PortalId = "HollowLand", LayoutOrder = 7, WorldKeys = {"Hollow Land", "Hueco Mundo"}, Npcs = { ["Boss Summon"] = "The Whisperer" } },
      ["Slayer Mansion"] = { PortalId = "SlayerMansion", LayoutOrder = 8, WorldKeys = {"Slayer Mansion", "Ubuyashiki Mansion"}, Npcs = { ["Boss Summon"] = "Pink Whisperer" } },
      ["Tokyo Ghoul"] = { PortalId = "TokyoGhoul", LayoutOrder = 9, WorldKeys = {"Tokyo Ghoul"}, Npcs = { ["Boss Summon"] = "Gray Whisperer" } },
      ["Ruin City"] = { PortalId = "RuinCity", LayoutOrder = 10, WorldKeys = {"Ruin City"}, Npcs = { ["Sacrifice Table"] = "Sacrifice Table", ["Boss Summon"] = "PauPau Whisperer" } },
      ["7th Company Island"] = { PortalId = "7thComanpyIsland", LayoutOrder = 11, WorldKeys = {"7th Company Island"}, Npcs = { ["Captain Burns"] = "Captain Burns" } }
  }
  
  local IslandNames = {}
  local sortedIslands = {}
  for name, data in pairs(EmbeddedIslandsData) do table.insert(sortedIslands, {name = name, order = data.LayoutOrder}) end
  table.sort(sortedIslands, function(a, b) return a.order < b.order end)
  for _, item in ipairs(sortedIslands) do table.insert(IslandNames, item.name) end
  
  local WeaponGroups = {
      ["Combat"] = { "Beast", "Akaza", "Thomas", "Kaneki", "Rudo", "Garou", "Goku", "Okarun", "Combat" },
      ["Sword"] = { "Cursed Child", "Toji", "LuBu", "Flashy Flash", "Arima", "Chae Hae In", "Cid", "Zenitsu", "Starrk", "Aizen", "Ichigo", "Night Blade", "Ace", "Saber", "Pipe", "Katana", "Chihora", "Geburo", "Gunbai", "Kama" },
      ["Ability"] = {
          "Shinru", "Benimaro", "Jane Julliet", "Gojo", "Sukuna", "Blast",
          "Choi Jong In", "Tatsumaki", "Light", "Magma", "Spin", "Invisible"
      }
  }
  
  _G.SelectedWeaponGroup = "Combat"
  _G.SelectedAbility = "Auto"
  _G.AutoEquipEnabled = false
  _G.AutoPrestigeEnabled = false
  local IsRerolling = false
  
  _G.SelectedStatToRoll = "DamageAmplifier"
  _G.TargetStatRank = "S"
  _G.AutoRollStatsEnabled = false
  _G.TraitRollMode = "By Rarity"
  _G.TargetTraitRarity = "Legendary"
  _G.TargetSpecificTrait = "Dominion"
  _G.AutoRollTraitsEnabled = false
  _G.AutoSkillEnabled = false
  _G.SelectedSkills = { Z = false, X = false, C = false, V = false, F = false }
  _G.AutoAddStats = false
  _G.SelectedAddStats = {}
  _G.AddStatAmount = 1
  _G.SelectedNoQuestMonsters = {}
  _G.CurrentNoQuestIndex = 1
  _G.SelectedWorldBosses = {}
  _G.InstaKillEnabled = false
  
  _G.AutoDungeonCreateEnabled = false
  _G.AutoDungeonVoteEnabled = false
  _G.AutoDungeonStartEnabled = false
  _G.AutoDungeonKillEnabled = false
  _G.DungeonDifficulty = "Easy"
  
  local CurrentSelectedPortal = nil
  local SelectedMonsterDisplay = MonsterList[1] or "None"
  local SelectedSummonBossDisplay = SummonBossList[1] or "None"
  
  local MovementMethod = "Tween"
  local FarmPosition = "Behind"
  local FarmSpeed = 120
  local SelectedTeleportIsland = IslandNames[1]
  local SelectedTeleportSpot = "Main Portal"
  
  local AutoFarmToggle = false
  local AutoBossToggle = false
  local AutoNoQuestToggle = false
  local AutoSummonOnlyToggle = false
  local AutoKillSummonToggle = false
  local AutoPityToggle = false
  local AutoAllQuestToggle = false
  local ActiveFireForceQuestKey = nil
  local SelectedFireForceSummonBoss = SummonBossList[1] or "Demon Infernal"
  local SelectedFireForceFarmMonster = "Fire Force Bandit ( Lv.8100 )"
  local SelectedPityFarmBoss = "Flashy Flash"
  local SelectedPityTargetBoss = "Flashy Flash"
  local PityCurrentBossDisplay = nil
  local PityState = {
      LastProgress = nil,
      TargetPhase = false,
      LastSummonAt = 0,
      LastPortalAt = 0,
      LastBossSeenAt = 0,
      CurrentBossDisplay = nil,
      TrackedBoss = nil,
      ScanIndex = 1,
      LastStatusKey = nil,
      LastMissingGuiNotify = 0,
      LastErrorNotify = 0
  }
  local getClosestMonster
  _G.IsBossSpawnedAndFarming = false 
  _G.LastBossDetectedTime = 0
  _G.LastDetectedBossPortal = nil
  _G.LastDetectedBossPortalTime = 0
  _G.LastBossAnnouncementText = ""
  _G.SummonedBossActive = false
  _G.SummonedBossConfirmed = false
  _G.SummonedBossModelSeen = false
  _G.SummonedBossIndicatorSeen = false
  _G.SummonedBossDisplay = nil
  _G.LastSummonAttemptTime = 0
  _G.SummonedBossMissingSince = 0
  _G.TrackedSummonedBoss = nil
  
  local statRankOrder = { F = 1, E = 2, d = 3, C = 4, B = 5, A = 6, S = 7, SS = 8, SSS = 9, Kami = 10 }
  local traitRarityOrder = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythical = 5, Secret = 6 }
  
  local function cleanString(str)
      return string.gsub(string.lower(str), "[%s%-]", "")
  end
  
  
  local function getCurrentIslandPortalId()
      if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return nil end
      local myPos = Player.Character.HumanoidRootPart.Position
      local closestPortal = nil
      local shortestDist = math.huge
      
      if workspace:FindFirstChild("NPCs") then
          for _, islandData in pairs(EmbeddedIslandsData) do
              if islandData.Npcs then
                  for _, npcName in pairs(islandData.Npcs) do
                      local npc = workspace.NPCs:FindFirstChild(npcName)
                      if npc then
                          local npcPos = npc:IsA("Model") and npc:GetPivot().Position or (npc:IsA("BasePart") and npc.Position)
                          if npcPos then
                              local dist = (npcPos - myPos).Magnitude
                              if dist < shortestDist then
                                  shortestDist = dist
                                  closestPortal = islandData.PortalId
                              end
                          end
                      end
                  end
              end
          end
      end
      return closestPortal
  end
  
  local function getPortalFromPosition(position)
      if not position then return nil end
      local closestPortal = nil
      local shortestDist = math.huge
      
      if workspace:FindFirstChild("NPCs") then
          for _, islandData in pairs(EmbeddedIslandsData) do
              if islandData.Npcs then
                  for _, npcName in pairs(islandData.Npcs) do
                      local npc = workspace.NPCs:FindFirstChild(npcName)
                      if npc then
                          local npcPos = npc:IsA("Model") and npc:GetPivot().Position or (npc:IsA("BasePart") and npc.Position)
                          if npcPos then
                              local dist = (npcPos - position).Magnitude
                              if dist < shortestDist then
                                  shortestDist = dist
                                  closestPortal = islandData.PortalId
                              end
                          end
                      end
                  end
              end
          end
      end
      
      if (not closestPortal or shortestDist > 3000) and workspace:FindFirstChild("Enemies") then
          for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
              if enemy:FindFirstChild("HumanoidRootPart") then
                  local dist = (enemy.HumanoidRootPart.Position - position).Magnitude
                  if dist < shortestDist then
                      for _, info in pairs(mobdata) do
                          if info.Mobname == enemy.Name then
                              shortestDist = dist
                              closestPortal = info.Portal
                              break
                          end
                      end
                  end
              end
          end
      end
      
      return closestPortal
  end
  
  local function getInstancePosition(instance)
      if not instance then return nil end
      if instance:IsA("BasePart") then return instance.Position end
      if instance:IsA("Attachment") then return instance.WorldPosition end
      if instance:IsA("Model") then return instance:GetPivot().Position end
      local attachment = instance:FindFirstChildWhichIsA("Attachment", true)
      if attachment then return attachment.WorldPosition end
      local part = instance:FindFirstChildWhichIsA("BasePart", true)
      if part then return part.Position end
      return nil
  end
  
  local function isPlayerNearInstance(instance, maxDistance)
      if not instance or not Player.Character then return false end
      local root = Player.Character:FindFirstChild("HumanoidRootPart")
      local position = getInstancePosition(instance)
      if not root or not position then return false end
      return (root.Position - position).Magnitude <= (maxDistance or 1200)
  end
  
  local function normalizeBossName(value)
      local normalized = string.lower(tostring(value or ""))
      normalized = string.gsub(normalized, "%[world%s+boss%]", "")
      return string.gsub(normalized, "[^%w]", "")
  end
  
  local function announcementMatchesBoss(message, bossInfo)
      if not bossInfo then return false end
      local normalizedMessage = normalizeBossName(message)
      local names = {}
      local function addName(name)
          if type(name) == "string" and name ~= "" then table.insert(names, name) end
      end
      addName(bossInfo.Mobname)
      addName(bossInfo.BossName)
      addName(string.match(tostring(bossInfo.Mobname or ""), "^(%S+)"))
      addName(string.match(tostring(bossInfo.BossName or ""), "^(%S+)"))
      for _, name in ipairs(names) do
          local normalizedName = normalizeBossName(name)
          if #normalizedName >= 4 and string.find(normalizedMessage, normalizedName, 1, true) then return true end
      end
      return false
  end
  
  local function isBossIndicatorDead(indicator)
      if not indicator then return false end
      for _, child in ipairs(indicator:GetDescendants()) do
          if child:IsA("TextLabel") then
              local text = tostring(child.Text or "")
              local percentText = string.match(text, "(%d+)%s*%%")
              if (percentText and tonumber(percentText) <= 0)
                  or string.find(string.lower(text), "dead", 1, true)
                  or string.match(text, "^%s*0%s*/") then
                  return true
              end
          end
      end
      return false
  end
  
  local function indicatorMatchesBoss(indicator, bossInfo)
      if not indicator or not bossInfo then return false end
      if announcementMatchesBoss(indicator.Name, bossInfo) then return true end
      for _, child in ipairs(indicator:GetDescendants()) do
          if child:IsA("TextLabel") and announcementMatchesBoss(child.Text, bossInfo) then return true end
      end
      return false
  end
  
  local function findBossIndicatorState(bossInfo)
      for _, instance in ipairs(workspace:GetChildren()) do
          if string.find(string.lower(instance.Name), "bossindicator", 1, true)
              and indicatorMatchesBoss(instance, bossInfo) then
              return instance, isBossIndicatorDead(instance)
          end
      end
      return nil, false
  end
  
  local function findBossIndicator(bossInfo)
      local indicator, isDead = findBossIndicatorState(bossInfo)
      if indicator and not isDead then return indicator end
      return nil
  end
  
  local function portalIsInList(portalId, portals)
      if not portalId then return false end
      for _, portal in ipairs(portals) do
          if portal == portalId then return true end
      end
      return false
  end
  
  local function stripRichText(text)
      return string.gsub(tostring(text or ""), "<[^>]+>", "")
  end
  
  local bossPortalKeywords = {
      {Portal = "JujutsuAcademy", WorldKeys = {"Jujutsu Academy"}, Names = {"jujutsu academy", "jujutsuacademy", "jujutsu", "academy"}},
      {Portal = "TokyoGhoul", WorldKeys = {"Tokyo Ghoul"}, Names = {"tokyo ghoul", "tokyoghoul"}},
      {Portal = "HollowLand", WorldKeys = {"Hollow Land", "Hueco Mundo"}, Names = {"hollow land", "hollowland", "hueco mundo", "huecomundo", "hueco"}},
      {Portal = "SlayerMansion", WorldKeys = {"Slayer Mansion", "Ubuyashiki Mansion"}, Names = {"slayer mansion", "slayermansion", "ubuyashiki mansion", "ubuyashikimansion", "ubuyashiki"}},
      {Portal = "RuinCity", WorldKeys = {"Ruin City"}, Names = {"ruin city", "ruincity"}},
      {Portal = "ACity", WorldKeys = {"A-City"}, Names = {"a-city", "a city", "acity"}},
      {Portal = "JungleIsland", WorldKeys = {"Jungle Island"}, Names = {"jungle island", "jungleisland", "jungle"}},
      {Portal = "IceIsland", WorldKeys = {"Ice Island"}, Names = {"ice island", "iceisland"}},
      {Portal = "Starter", WorldKeys = {"Starter Island"}, Names = {"starter island", "starterisland", "starter"}},
      {Portal = "Legacy", WorldKeys = {"Legacy Island"}, Names = {"legacy island", "legacyisland", "legacy"}},
      {Portal = "7thComanpyIsland", WorldKeys = {"7th Company Island"}, Names = {"7th company island", "7thcompanyisland", "7th company", "company island"}}
  }
  
  local function addPortalKeyword(portalData, keyword)
      keyword = string.lower(stripRichText(keyword))
      keyword = string.gsub(keyword, "^%s+", "")
      keyword = string.gsub(keyword, "%s+$", "")
      if keyword == "" then return end
      for _, current in ipairs(portalData.Names) do
          if current == keyword then return end
      end
      table.insert(portalData.Names, keyword)
  end
  
  
  pcall(function()
      local shared = ReplicatedStorage:FindFirstChild("Shared")
      local dataFolder = shared and shared:FindFirstChild("Data")
      local module = dataFolder and dataFolder:FindFirstChild("UniversalWorldData")
      local universalWorldData = module and require(module)
      if type(universalWorldData) ~= "table" then return end
  
      for _, portalData in ipairs(bossPortalKeywords) do
          for _, worldKey in ipairs(portalData.WorldKeys or {}) do
              addPortalKeyword(portalData, worldKey)
              local worldInfo = universalWorldData[worldKey]
              if type(worldInfo) == "table" and type(worldInfo.Title) == "string" then
                  addPortalKeyword(portalData, worldInfo.Title)
                  addPortalKeyword(portalData, string.gsub(worldInfo.Title, "[%s%-]", ""))
              end
          end
      end
  end)
  
  local function detectPortalFromAnnouncement(message)
      local cleaned = string.lower(stripRichText(message))
      local deathWords = {"defeated", "slain", "died", "dead", "killed", "despawned", "vanished"}
      for _, word in ipairs(deathWords) do
          if string.find(cleaned, word, 1, true) then return nil, cleaned end
      end
  
      local spawnWords = {
          "spawned", "spawn", "appeared", "appear", "summoned", "arrived",
          "emerged", "materialized", "spotted", "located", "has come",
          "is attacking", "invasion", "invaded", "now roaming"
      }
      local isSpawn = false
      for _, word in ipairs(spawnWords) do
          if string.find(cleaned, word, 1, true) then isSpawn = true break end
      end
      if not isSpawn then return nil, cleaned end
  
      for _, portalData in ipairs(bossPortalKeywords) do
          for _, keyword in ipairs(portalData.Names) do
              if string.find(cleaned, keyword, 1, true) then
                  return portalData.Portal, cleaned
              end
          end
      end
      return nil, cleaned
  end
  local function resetSummonedBossState(expectedDisplay)
      if expectedDisplay and _G.SummonedBossDisplay and _G.SummonedBossDisplay ~= expectedDisplay then return false end
      _G.SummonedBossActive = false
      _G.SummonedBossConfirmed = false
      _G.SummonedBossModelSeen = false
      _G.SummonedBossIndicatorSeen = false
      _G.SummonedBossDisplay = nil
      _G.LastSummonAttemptTime = 0
      _G.SummonedBossMissingSince = 0
      _G.TrackedSummonedBoss = nil
      _G.LastDetectedBossPortal = nil
      _G.LastDetectedBossPortalTime = 0
      _G.LastBossAnnouncementText = ""
      CurrentSelectedPortal = nil
      return true
  end
  
  local function markSummonAttempt(displayName)
      _G.SummonedBossActive = true
      _G.SummonedBossConfirmed = false
      _G.SummonedBossModelSeen = false
      _G.SummonedBossIndicatorSeen = false
      _G.SummonedBossDisplay = displayName
      _G.LastSummonAttemptTime = os.clock()
      _G.SummonedBossMissingSince = 0
      _G.TrackedSummonedBoss = nil
  end
  
  local function markSummonedBossAlive(bossModel, indicatorSeen)
      local displayName = SelectedSummonBossDisplay
      _G.SummonedBossActive = true
      _G.SummonedBossConfirmed = true
      _G.SummonedBossDisplay = displayName
      _G.SummonedBossMissingSince = 0
      if indicatorSeen then _G.SummonedBossIndicatorSeen = true end
      if not bossModel then return end
      _G.SummonedBossModelSeen = true
      if _G.TrackedSummonedBoss ~= bossModel then
          _G.TrackedSummonedBoss = bossModel
          local humanoid = bossModel:FindFirstChild("Humanoid")
          local trackedDisplay = displayName
          if humanoid then
              humanoid.Died:Connect(function()
                  task.defer(function()
                      if _G.TrackedSummonedBoss == bossModel and _G.SummonedBossDisplay == trackedDisplay then
                          resetSummonedBossState(trackedDisplay)
                      end
                  end)
              end)
          end
      end
  end
  
  local function updateSummonedBossDeathState(bossInfo)
      if not _G.SummonedBossActive or _G.SummonedBossDisplay ~= SelectedSummonBossDisplay then return false end
      local indicator, indicatorDead = findBossIndicatorState(bossInfo)
      local trackedBoss = _G.TrackedSummonedBoss
      local humanoid = trackedBoss and trackedBoss:FindFirstChild("Humanoid")
      if (indicator and indicatorDead) or (humanoid and humanoid.Health <= 0) then
          resetSummonedBossState(SelectedSummonBossDisplay)
          return true
      end
      local disappeared = (_G.SummonedBossModelSeen and (not trackedBoss or not trackedBoss.Parent))
          or (_G.SummonedBossIndicatorSeen and not indicator)
      if disappeared then
          if (_G.SummonedBossMissingSince or 0) == 0 then
              _G.SummonedBossMissingSince = os.clock()
          elseif os.clock() - _G.SummonedBossMissingSince >= 1.5 then
              resetSummonedBossState(SelectedSummonBossDisplay)
              return true
          end
      else
          _G.SummonedBossMissingSince = 0
      end
      return false
  end
  
  local function processBossAnnouncement(message, source)
      if type(message) ~= "string" then return end
      local cleaned = string.lower(stripRichText(message))
      local summonInfo = summonbossdata[SelectedSummonBossDisplay]
      local matchesSummon = summonInfo and announcementMatchesBoss(cleaned, summonInfo)
      local pityInfo = AutoPityToggle and PityCurrentBossDisplay and summonbossdata[PityCurrentBossDisplay]
      local matchesPity = pityInfo and announcementMatchesBoss(cleaned, pityInfo)
      local allQuestInfo = nil
      if AutoAllQuestToggle then
          if ActiveFireForceQuestKey == "DemonSlayer" then
              allQuestInfo = summonbossdata["Demon Infernal"]
          elseif ActiveFireForceQuestKey == "AmbushHunt" then
              allQuestInfo = bossdata["Infernal Ambusher"]
          elseif ActiveFireForceQuestKey == "SpecialSuppression" then
              allQuestInfo = summonbossdata[SelectedFireForceSummonBoss]
          end
      end
      local matchesAllQuest = allQuestInfo and announcementMatchesBoss(cleaned, allQuestInfo)
      if _G.SummonedBossActive and matchesSummon then
          for _, word in ipairs({"defeated", "slain", "died", "dead", "killed", "à¸•à¸²à¸¢", "à¸–à¸¹à¸à¸à¸³à¸ˆà¸±à¸”"}) do
              if string.find(cleaned, word, 1, true) then
                  resetSummonedBossState(SelectedSummonBossDisplay)
                  return
              end
          end
      end
  
      local portalId, spawnText = detectPortalFromAnnouncement(message)
      if not portalId then return end
      local matchesWorld = false
      if AutoBossToggle then
          for _, displayName in ipairs(_G.SelectedWorldBosses) do
              local info = bossdata[displayName]
              if info and announcementMatchesBoss(spawnText, info) then matchesWorld = true break end
          end
      end
      local relevant = ((AutoSummonOnlyToggle or AutoKillSummonToggle) and matchesSummon)
          or (AutoBossToggle and matchesWorld)
          or (AutoPityToggle and matchesPity)
          or (AutoAllQuestToggle and matchesAllQuest)
      if not relevant then return end
  
      local now = os.clock()
      if spawnText == _G.LastBossAnnouncementText and now - (_G.LastDetectedBossPortalTime or 0) < 2 then return end
      _G.LastDetectedBossPortal = portalId
      _G.LastDetectedBossPortalTime = now
      _G.LastBossAnnouncementText = spawnText
      if (AutoSummonOnlyToggle or AutoKillSummonToggle) and matchesSummon then markSummonedBossAlive(nil, false) end
      if AutoBossToggle and matchesWorld then
          _G.IsBossSpawnedAndFarming = true
          _G.LastBossDetectedTime = now + 10
      end
  
      pcall(function()
          Fluent:Notify({Title = "Boss Tracker (" .. tostring(source) .. ")", Content = "Boss map: " .. portalId, Duration = 4})
      end)
  
      if AutoBossToggle or AutoKillSummonToggle or AutoPityToggle or AutoAllQuestToggle then
          local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("TeleportToPortal")
          local currentPortal = getCurrentIslandPortalId()
          if currentPortal == portalId then
              CurrentSelectedPortal = portalId
          elseif remote then
              remote:FireServer(portalId)
              CurrentSelectedPortal = portalId
          end
      end
  end
  
  
  
  
  task.spawn(function()
      pcall(function()
          local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
          local UI = Shared and Shared:WaitForChild("UI", 10)
          local NotifyModule = UI and UI:WaitForChild("Notify", 10)
  
          if NotifyModule and hookfunction then
              local Notify = require(NotifyModule)
              local oldSend
              
              local islandKeywords = {
                  ["a-city"] = "ACity",
                  ["acity"] = "ACity",
                  ["jujutsu"] = "JujutsuAcademy",
                  ["academy"] = "JujutsuAcademy",
                  ["tokyo"] = "TokyoGhoul",
                  ["ghoul"] = "TokyoGhoul",
                  ["hollow"] = "HollowLand",
                  ["slayer"] = "SlayerMansion",
                  ["mansion"] = "SlayerMansion",
                  ["ruin"] = "RuinCity",
                  ["jungle"] = "JungleIsland",
                  ["ice"] = "IceIsland",
                  ["starter"] = "Starter",
                  ["legacy"] = "Legacy",
                  ["7th"] = "7thComanpyIsland",
                  ["company"] = "7thComanpyIsland"
              }
  
              local function stripRichText(text)
                  return string.gsub(text, "<[^>]+>", "")
              end
  
              oldSend = hookfunction(Notify.Send, function(message, config)
                  if type(message) == "string" then
                      task.spawn(processBossAnnouncement, message, "Notify")
                      task.spawn(function()
                          local cleanMessage = string.lower(stripRichText(message))
                          if cleanMessage:find("spawn") or cleanMessage:find("boss") or cleanMessage:find("appear") then
                              if false and (AutoBossToggle or AutoKillSummonToggle) then
                                  for keyword, portalId in pairs(islandKeywords) do
                                      if cleanMessage:find(keyword) then
                                          local teleportRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("TeleportToPortal")
                                          if teleportRemote then
                                              pcall(function()
                                                  Fluent:Notify({
                                                      Title = "💡 Notify Tracker",
                                                      Content = "พบประกาศบอสเกิดที่เกาะ: " .. portalId .. " กำลังเทเลพอร์ตข้ามพอร์ทัลทันที!",
                                                      Duration = 4
                                                  })
                                              end)
                                              teleportRemote:FireServer(portalId)
                                              CurrentSelectedPortal = portalId 
                                              _G.CurrentBossPortalIndex = 1
                                              _G.CurrentSummonKillIndex = 1
                                          end
                                          break
                                      end
                                  end
                              end
                          end
                      end)
                  end
                  return oldSend(message, config)
              end)
          end
      end)
  end)
  
  
  task.spawn(function()
      pcall(function()
          game:GetService("TextChatService").MessageReceived:Connect(function(message)
              if message and type(message.Text) == "string" then
                  task.spawn(processBossAnnouncement, message.Text, "TextChat")
              end
          end)
      end)
      pcall(function()
          local events = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
          local event = events and events:FindFirstChild("OnMessageDoneFiltering")
          if event then
              event.OnClientEvent:Connect(function(data)
                  if type(data) == "table" and type(data.Message) == "string" then
                      task.spawn(processBossAnnouncement, data.Message, "LegacyChat")
                  end
              end)
          end
      end)
  end)
  
  
  task.spawn(function()
      local function inspectTextObject(object)
          if not (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then return end
          task.spawn(function()
              local lastText = nil
              for _, delayTime in ipairs({0.05, 0.15, 0.35, 0.7}) do
                  task.wait(delayTime)
                  if not object.Parent then return end
                  local text = tostring(object.Text or "")
                  if text ~= "" and text ~= lastText then
                      lastText = text
                      processBossAnnouncement(text, "ScreenNotify")
                  end
              end
          end)
      end
  
      local function watchGuiRoot(root)
          if not root then return end
          root.DescendantAdded:Connect(inspectTextObject)
      end
  
      watchGuiRoot(Player:FindFirstChild("PlayerGui") or Player:WaitForChild("PlayerGui", 10))
      pcall(function() watchGuiRoot(game:GetService("CoreGui")) end)
  end)
  
  local function StartPhysicsLoop()
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
          while _G.PhysicsKillActive or _G.AutoKillHakari or _G.AutoBoss or _G.FEKillAura or _G.InstaKillEnabled do
              RunService.Stepped:Wait()
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
  
  local function instaKill(mob, force)
      _G.PhysicsKillActive = true
      StartPhysicsLoop()
      if not mob or not mob:FindFirstChild("Humanoid") or not mob:FindFirstChild("HumanoidRootPart") then return end
      local hrp = mob.HumanoidRootPart
      local hum = mob.Humanoid
      local lp = game.Players.LocalPlayer
      local char = lp.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
          char.HumanoidRootPart.CFrame = hrp.CFrame
      end
      task.spawn(function()
          for i = 1, 5 do
              if hrp then
                  hrp.Anchored = false
                  hrp.CanCollide = false
                  hrp.Velocity = Vector3.new(0, -100, 0)
              end
              if hum then
                  hum:ChangeState(Enum.HumanoidStateType.Dead)
                  hum.Health = 0
              end
              for _, part in pairs(mob:GetChildren()) do
                  if part:IsA("BasePart") then
                      part.Anchored = false
                      part.CanCollide = false
                      part.Velocity = Vector3.new(0, -100, 0)
                  end
              end
              task.wait()
          end
      end)
  end
  
  local function checkHasQuest(questName)
      local dataFolder = Player:FindFirstChild("Data")
      if dataFolder then
          local questsFolder = dataFolder:FindFirstChild("Quests")
          if questsFolder then
              local mainQuest = nil
              local mainFolder = questsFolder:FindFirstChild("Main")
              if mainFolder then mainQuest = mainFolder:FindFirstChild(questName) end
              
              local dailyQuest = nil
              local dailyFolder = questsFolder:FindFirstChild("Daily")
              if dailyFolder then dailyQuest = dailyFolder:FindFirstChild(questName) end
              
              if mainQuest then return true, mainQuest end
              if dailyQuest then return true, dailyQuest end
          end
      end
      return false, nil
  end
  
  local function triggerProximityPrompt(prompt)
      if not prompt then return end
      local oldLineOfSight = prompt.RequiresLineOfSight
      local oldMaxDistance = prompt.MaxActivationDistance
      pcall(function() 
          prompt.RequiresLineOfSight = false 
          prompt.MaxDistance = 50 
      end)
      local function forceFire()
          if fireproximityprompt then 
              fireproximityprompt(prompt, 1, true)
          elseif firePrompt then 
              firePrompt(prompt)
          else
              prompt:InputHoldBegin()
              task.wait(prompt.HoldDuration + 0.05)
              prompt:InputHoldEnd()
          end
      end
      forceFire()
      task.wait(0.2) 
      forceFire()
      task.delay(0.5, function() 
          pcall(function() 
              prompt.RequiresLineOfSight = oldLineOfSight 
              prompt.MaxActivationDistance = oldMaxDistance
          end) 
      end)
  end
  
  local function EquipWeapon(groupName)
      if not _G.AutoEquipEnabled then return end
      if not Player.Character then return end
      local humanoid = Player.Character:FindFirstChild("Humanoid")
      if not humanoid then return end
      local targetWeapons = WeaponGroups[groupName] or {groupName}
      if groupName == "Ability" and _G.SelectedAbility and _G.SelectedAbility ~= "Auto" then
          targetWeapons = {_G.SelectedAbility}
      end
      for _, name in ipairs(targetWeapons) do 
          if Player.Character:FindFirstChild(name) then return end 
      end
      if Player:FindFirstChild("Backpack") then
          for _, name in ipairs(targetWeapons) do
              local tool = Player.Backpack:FindFirstChild(name)
              if tool then humanoid:EquipTool(tool) return end
          end
      end
  end
  
  getClosestMonster = function(mobName)
      local closest, shortestDistance = nil, math.huge
      if not Player.Character then return nil end
      if not Player.Character:FindFirstChild("HumanoidRootPart") then return nil end
      local enemies = workspace:FindFirstChild("Enemies")
      if not enemies then return nil end
  
      local wantedName = normalizeBossName(mobName)
      for _, v in ipairs(enemies:GetDescendants()) do
          if v:IsA("Model") then
              local candidateName = normalizeBossName(v.Name)
              local nameMatches = candidateName == wantedName
                  or string.find(candidateName, wantedName, 1, true) == 1
              if nameMatches then
                  local humanoid = v:FindFirstChildWhichIsA("Humanoid", true)
                  local rootPart = v:FindFirstChild("HumanoidRootPart", true)
                      or v:FindFirstChild("RootPart", true)
                  if humanoid and humanoid.Health > 0 and rootPart and rootPart:IsA("BasePart") then
                      local distance = (Player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                      if distance < shortestDistance then
                          shortestDistance = distance
                          closest = v
                      end
                  end
              end
          end
      end
      return closest
  end
  
  local function smartMoveCharacter(target)
      if not Player.Character then return end
      if not Player.Character:FindFirstChild("HumanoidRootPart") then return end
      local root = Player.Character.HumanoidRootPart
      local targetCFrame = nil
      
      if typeof(target) == "Instance" then
          if target:IsA("Model") then
              if target:FindFirstChild("HumanoidRootPart") then 
                  targetCFrame = target.HumanoidRootPart.CFrame 
              else
                  targetCFrame = target:GetPivot()
              end
          elseif target:IsA("BasePart") then 
              targetCFrame = target.CFrame 
          end
      elseif typeof(target) == "Vector3" then 
          targetCFrame = CFrame.new(target)
      elseif typeof(target) == "CFrame" then 
          targetCFrame = target 
      end
      
      if not targetCFrame then return end
      local distance = (root.Position - targetCFrame.Position).Magnitude
      
      if MovementMethod == "Instant" then
          root.CFrame = targetCFrame
      else
          if distance < 15 then 
              root.CFrame = targetCFrame 
              return 
          end
          local duration = distance / FarmSpeed
          local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
          tween:Play()
          tween.Completed:Wait()
      end
  end
  
  local Window = Fluent:CreateWindow({
      Title = "Legacy Piece 1.1",
      SubTitle = "by.voltz",
      TabWidth = 160,
      Size = UDim2.fromOffset(580, 520),
      Acrylic = false,
      Theme = "Dark",
      MinimizeKey = Enum.KeyCode.LeftControl
  })
  
  local Tabs = {
      Main = Window:AddTab({ Title = "Main", Icon = "user" }),
      AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
      AllQuest = Window:AddTab({ Title = "All Quest", Icon = "list" }),
      Pity = Window:AddTab({ Title = "Pity", Icon = "target" }),
      Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "swords" }),
      Stats = Window:AddTab({ Title = "Stats", Icon = "star" }),
      Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
      Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
  }
  
  Tabs.Main:AddSection("Player Settings")
  
  local ESPToggle = Tabs.Main:AddToggle("ESPPlayer", { Title = "ESP Player", Default = false })
  ESPToggle:OnChanged(function()
      _G.ESPEnabled = ESPToggle.Value
      if not _G.ESPEnabled then
          for _, v in pairs(Players:GetPlayers()) do
              if v.Character and v.Character:FindFirstChild("Highlight") then
                  v.Character.Highlight:Destroy()
              end
          end
      end
  end)
  
  local SpeedToggle = Tabs.Main:AddToggle("SpeedHack", { Title = "Speed Hack", Default = false })
  SpeedToggle:OnChanged(function() _G.SpeedHack = SpeedToggle.Value end)
  
  local InfJumpToggle = Tabs.Main:AddToggle("InfJump", { Title = "Infinity Jump", Default = false })
  InfJumpToggle:OnChanged(function() _G.InfJump = InfJumpToggle.Value end)
  
  Tabs.Main:AddSection("Redeem Codes")
  
  Tabs.Main:AddButton({
      Title = "Auto Redeem ALL Codes",
      Callback = function()
          task.spawn(function()
              for _, code in ipairs(allCodesList) do
                  pcall(function()
                      local args = { "Code", code }
                      game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("Input"):InvokeServer(unpack(args))
                      Fluent:Notify({ Title = "Auto Redeem", Content = "กำลังกรอกโค้ด: " .. code, Duration = 2 })
                  end)
                  task.wait(1.5)
              end
              Fluent:Notify({ Title = "Auto Redeem", Content = "เติมโค้ดทั้งหมดเรียบร้อยแล้ว!", Duration = 5 })
          end)
      end
  })
  
  Tabs.AutoFarm:AddSection("Weapon & Ability Settings")
  do
      local weaponDropdown = Tabs.AutoFarm:AddDropdown("SelectWeapon", {
          Title = "Select Weapon / Ability",
          Values = {"Combat", "Sword", "Ability"},
          Default = "Combat"
      })
      weaponDropdown:OnChanged(function(Value) _G.SelectedWeaponGroup = Value end)
  
      local abilityValues = {"Auto"}
      for _, abilityName in ipairs(WeaponGroups.Ability) do table.insert(abilityValues, abilityName) end
      local abilityDropdown = Tabs.AutoFarm:AddDropdown("SelectAbility", {
          Title = "Select Ability",
          Values = abilityValues,
          Default = "Auto"
      })
      abilityDropdown:OnChanged(function(Value) _G.SelectedAbility = Value end)
  
      local autoEquipToggle = Tabs.AutoFarm:AddToggle("AutoEquip", { Title = "Auto Equip Weapon / Ability", Default = false })
      autoEquipToggle:OnChanged(function()
          _G.AutoEquipEnabled = autoEquipToggle.Value
          task.spawn(function()
              while _G.AutoEquipEnabled do
                  task.wait(0.5)
                  pcall(function() if _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end end)
              end
          end)
      end)
  end
  
  Tabs.AutoFarm:AddSection("Farm Settings")
  local MonsterDropdown = Tabs.AutoFarm:AddDropdown("MonsterDropdown", { Title = "Select Monster", Values = MonsterList, Default = MonsterList[1] or "", Callback = function(Value) SelectedMonsterDisplay = Value end })
  local MethodDropdown = Tabs.AutoFarm:AddDropdown("MovementDropdown", { Title = "Movement Method", Values = {"Tween", "Instant"}, Default = "Tween", Callback = function(Value) MovementMethod = Value end })
  local PositionDropdown = Tabs.AutoFarm:AddDropdown("PositionDropdown", { Title = "Farm Position", Values = {"Above", "Behind"}, Default = "Behind", Callback = function(Value) FarmPosition = Value end })
  local SpeedSlider = Tabs.AutoFarm:AddSlider("TweenSpeed", { Title = "Tween Speed", Default = 120, Min = 50, Max = 250, Rounding = 0, Callback = function(Value) FarmSpeed = Value end })
  
  local FarmToggleUI
  local BossFarmToggleUI
  local NoQuestToggleUI
  local SummonToggleUI
  local KillSummonToggleUI
  local PityToggleUI
  local FireForceQuestToggleUIs = {}
  local SetAllQuestEnabled
  
  local AutoDungeonCreateToggleUI
  local AutoDungeonVoteToggleUI
  local AutoDungeonStartToggleUI
  local AutoDungeonKillToggleUI
  
  local function DisableOtherFarms(exceptCategory)
      if exceptCategory ~= "AllQuest" and SetAllQuestEnabled then SetAllQuestEnabled(nil, false) end
      if exceptCategory ~= "Pity" and PityToggleUI then PityToggleUI:SetValue(false) end
      if exceptCategory == "Farm" then
          if NoQuestToggleUI then NoQuestToggleUI:SetValue(false) end
          if SummonToggleUI then SummonToggleUI:SetValue(false) end
          if KillSummonToggleUI then KillSummonToggleUI:SetValue(false) end
          if AutoDungeonCreateToggleUI then AutoDungeonCreateToggleUI:SetValue(false) end
          if AutoDungeonVoteToggleUI then AutoDungeonVoteToggleUI:SetValue(false) end
          if AutoDungeonStartToggleUI then AutoDungeonStartToggleUI:SetValue(false) end
          if AutoDungeonKillToggleUI then AutoDungeonKillToggleUI:SetValue(false) end
      elseif exceptCategory == "NoQuest" then
          if FarmToggleUI then FarmToggleUI:SetValue(false) end
          if SummonToggleUI then SummonToggleUI:SetValue(false) end
          if KillSummonToggleUI then KillSummonToggleUI:SetValue(false) end
          if AutoDungeonCreateToggleUI then AutoDungeonCreateToggleUI:SetValue(false) end
          if AutoDungeonVoteToggleUI then AutoDungeonVoteToggleUI:SetValue(false) end
          if AutoDungeonStartToggleUI then AutoDungeonStartToggleUI:SetValue(false) end
          if AutoDungeonKillToggleUI then AutoDungeonKillToggleUI:SetValue(false) end
      elseif exceptCategory == "Boss" then
          if SummonToggleUI then SummonToggleUI:SetValue(false) end
          if KillSummonToggleUI then KillSummonToggleUI:SetValue(false) end
          if AutoDungeonCreateToggleUI then AutoDungeonCreateToggleUI:SetValue(false) end
          if AutoDungeonVoteToggleUI then AutoDungeonVoteToggleUI:SetValue(false) end
          if AutoDungeonStartToggleUI then AutoDungeonStartToggleUI:SetValue(false) end
          if AutoDungeonKillToggleUI then AutoDungeonKillToggleUI:SetValue(false) end
      elseif exceptCategory == "SummonFarm" then
          if FarmToggleUI then FarmToggleUI:SetValue(false) end
          if NoQuestToggleUI then NoQuestToggleUI:SetValue(false) end
          if BossFarmToggleUI then BossFarmToggleUI:SetValue(false) end
          if AutoDungeonCreateToggleUI then AutoDungeonCreateToggleUI:SetValue(false) end
          if AutoDungeonVoteToggleUI then AutoDungeonVoteToggleUI:SetValue(false) end
          if AutoDungeonStartToggleUI then AutoDungeonStartToggleUI:SetValue(false) end
          if AutoDungeonKillToggleUI then AutoDungeonKillToggleUI:SetValue(false) end
      elseif exceptCategory == "Pity" then
          if FarmToggleUI then FarmToggleUI:SetValue(false) end
          if NoQuestToggleUI then NoQuestToggleUI:SetValue(false) end
          if BossFarmToggleUI then BossFarmToggleUI:SetValue(false) end
          if SummonToggleUI then SummonToggleUI:SetValue(false) end
          if KillSummonToggleUI then KillSummonToggleUI:SetValue(false) end
          if AutoDungeonCreateToggleUI then AutoDungeonCreateToggleUI:SetValue(false) end
          if AutoDungeonVoteToggleUI then AutoDungeonVoteToggleUI:SetValue(false) end
          if AutoDungeonStartToggleUI then AutoDungeonStartToggleUI:SetValue(false) end
          if AutoDungeonKillToggleUI then AutoDungeonKillToggleUI:SetValue(false) end
      elseif exceptCategory == "AllQuest" then
          if FarmToggleUI then FarmToggleUI:SetValue(false) end
          if NoQuestToggleUI then NoQuestToggleUI:SetValue(false) end
          if BossFarmToggleUI then BossFarmToggleUI:SetValue(false) end
          if SummonToggleUI then SummonToggleUI:SetValue(false) end
          if KillSummonToggleUI then KillSummonToggleUI:SetValue(false) end
          if AutoDungeonCreateToggleUI then AutoDungeonCreateToggleUI:SetValue(false) end
          if AutoDungeonVoteToggleUI then AutoDungeonVoteToggleUI:SetValue(false) end
          if AutoDungeonStartToggleUI then AutoDungeonStartToggleUI:SetValue(false) end
          if AutoDungeonKillToggleUI then AutoDungeonKillToggleUI:SetValue(false) end
      elseif exceptCategory == "Dungeon" then
          if FarmToggleUI then FarmToggleUI:SetValue(false) end
          if NoQuestToggleUI then NoQuestToggleUI:SetValue(false) end
          if BossFarmToggleUI then BossFarmToggleUI:SetValue(false) end
          if SummonToggleUI then SummonToggleUI:SetValue(false) end
          if KillSummonToggleUI then KillSummonToggleUI:SetValue(false) end
      end
  end
  
  FarmToggleUI = Tabs.AutoFarm:AddToggle("FarmToggle", { Title = "Auto Farm", Default = false, Callback = function(Value) 
      AutoFarmToggle = Value 
      if Value == true then 
          CurrentSelectedPortal = nil 
          DisableOtherFarms("Farm")
      end
  end })
  
  Tabs.AutoFarm:AddSection("Auto Farm No Quest")
  local NoQuestDropdown = Tabs.AutoFarm:AddDropdown("NoQuestDropdown", {
      Title = "Select Monsters (No Quest)",
      Values = MonsterList,
      Multi = true,
      Default = {},
      Callback = function(Value)
          _G.SelectedNoQuestMonsters = {}
          for _, mobNameDisplay in ipairs(MonsterList) do
              if Value[mobNameDisplay] == true then 
                  table.insert(_G.SelectedNoQuestMonsters, mobdata[mobNameDisplay])
              end
          end
          _G.CurrentNoQuestIndex = 1 
      end
  })
  
  NoQuestToggleUI = Tabs.AutoFarm:AddToggle("NoQuestToggle", { Title = "Auto Farm No Quest", Default = false, Callback = function(Value)
      AutoNoQuestToggle = Value
      if Value == true then
          CurrentSelectedPortal = nil
          DisableOtherFarms("NoQuest")
      end
  end })
  
  Tabs.AutoFarm:AddSection("World Boss Settings")
  local BossDropdown = Tabs.AutoFarm:AddDropdown("BossDropdown", { 
      Title = "Select World Boss", 
      Values = BossList, 
      Multi = true,
      Default = {}, 
      Callback = function(Value) 
          _G.SelectedWorldBosses = {}
          for bossName, state in pairs(Value) do
              if state == true then 
                  table.insert(_G.SelectedWorldBosses, bossName) 
              end
          end
      end 
  })
  
  BossFarmToggleUI = Tabs.AutoFarm:AddToggle("BossFarmToggle", { Title = "Auto Farm World Boss", Default = false, Callback = function(Value) 
      AutoBossToggle = Value 
      if Value == true then 
          CurrentSelectedPortal = nil 
          DisableOtherFarms("Boss")
      end
  end })
  
  Tabs.AutoFarm:AddSection("Auto Summon & Kill Boss")
  local SummonBossDropdown = Tabs.AutoFarm:AddDropdown("SummonBossDropdown", { Title = "Select Boss", Values = SummonBossList, Default = SummonBossList[1] or "", Callback = function(Value) SelectedSummonBossDisplay = Value end })
  
  SummonToggleUI = Tabs.AutoFarm:AddToggle("AutoSummonOnlyToggle", { Title = "Auto Summon Boss",Default = false, Callback = function(Value) 
      AutoSummonOnlyToggle = Value 
      if Value == true then
          CurrentSelectedPortal = nil
          DisableOtherFarms("SummonFarm")
      end
  end })
  
  KillSummonToggleUI = Tabs.AutoFarm:AddToggle("AutoKillSummonToggle", { Title = "Auto Kill Summoned Boss",Default = false, Callback = function(Value) 
      AutoKillSummonToggle = Value 
      if Value == true then
          CurrentSelectedPortal = nil
          DisableOtherFarms("SummonFarm")
      end
  end })
  
  Tabs.AutoFarm:AddSection("Auto Skill Settings")
  local MasterSkillToggle = Tabs.AutoFarm:AddToggle("MasterSkillToggle", { Title = "Enable Auto Skill", Default = false, Callback = function(Value) _G.AutoSkillEnabled = Value end })
  local InstaKillToggle = Tabs.AutoFarm:AddToggle("InstaKillToggle", { Title = "Enable InstaKill", Default = false, Callback = function(Value) _G.InstaKillEnabled = Value end })
  local SkillMultiDropdown = Tabs.AutoFarm:AddDropdown("SkillMultiDropdown", {
      Title = "Select Skills to Cast",
      Values = {"Z", "X", "C", "V","F"},
      Multi = true,
      Default = {},
      Callback = function(Value)
          _G.SelectedSkills = { Z = false, X = false, C = false, V = false, F = false }
          for skillName, state in pairs(Value) do
              if state == true then _G.SelectedSkills[skillName] = true end
          end
      end
  })
  
  Tabs.Dungeon:AddSection("Dungeon Settings")
  
  local DungeonDiffDropdown = Tabs.Dungeon:AddDropdown("DungeonDifficulty", {
      Title = "Select Difficulty",
      Values = {"Easy", "Medium", "Hard", "Extreme"},
      Default = "Easy",
      Callback = function(Value)
          _G.DungeonDifficulty = Value
      end
  })
  
  AutoDungeonCreateToggleUI = Tabs.Dungeon:AddToggle("AutoDungeonCreateToggle", { 
      Title = "Auto Create Dungeon", 
      Default = false, 
      Callback = function(Value)
          _G.AutoDungeonCreateEnabled = Value
          if Value == true then
              CurrentSelectedPortal = nil
              DisableOtherFarms("Dungeon")
          end
      end 
  })
  
  AutoDungeonVoteToggleUI = Tabs.Dungeon:AddToggle("AutoDungeonVoteToggle", { 
      Title = "Auto Vote Dungeon", 
      Default = false, 
      Callback = function(Value)
          _G.AutoDungeonVoteEnabled = Value
          if Value == true then
              CurrentSelectedPortal = nil
              DisableOtherFarms("Dungeon")
          end
      end 
  })
  
  AutoDungeonStartToggleUI = Tabs.Dungeon:AddToggle("AutoDungeonStartToggle", { 
      Title = "Auto Start Dungeon", 
      Default = false, 
      Callback = function(Value)
          _G.AutoDungeonStartEnabled = Value
          if Value == true then
              CurrentSelectedPortal = nil
              DisableOtherFarms("Dungeon")
          end
      end 
  })
  
  Tabs.Dungeon:AddSection("Dungeon Combat")
  
  AutoDungeonKillToggleUI = Tabs.Dungeon:AddToggle("AutoDungeonKillToggle", { 
      Title = "Auto Kill Dungeon Mobs", 
      Default = false, 
      Callback = function(Value)
          _G.AutoDungeonKillEnabled = Value
          if Value == true then
              CurrentSelectedPortal = nil
              DisableOtherFarms("Dungeon")
          end
      end 
  })
  
  Tabs.Stats:AddSection("Auto Add Stats")
  
  local AddStatsDropdown = Tabs.Stats:AddDropdown("AddStatsDropdown", {
      Title = "Select Stats to Upgrade",
      Values = {"Strength", "Defense", "Weapon", "Ability"},
      Multi = true,
      Default = {},
      Callback = function(Value)
          _G.SelectedAddStats = {}
          for statName, state in pairs(Value) do
              if state == true then _G.SelectedAddStats[statName] = true end
          end
      end
  })
  
  local StatAmountInput = Tabs.Stats:AddInput("StatAmountInput", {
      Title = "Amount per Upgrade",
      Default = "1",
      Placeholder = "ใส่จำนวน Point ต่อการอัป",
      Numeric = true,
      Finished = false,
      Callback = function(Value)
          _G.AddStatAmount = tonumber(Value) or 1
      end
  })
  
  local AutoStatsToggle = Tabs.Stats:AddToggle("AutoStatsToggle", { Title = "Auto Add Stats", Default = false })
  AutoStatsToggle:OnChanged(function() _G.AutoAddStats = AutoStatsToggle.Value end)
  
  Tabs.Stats:AddButton({
      Title = "Reset Stats (Refund)",
      Callback = function()
          pcall(function()
              local args = { "Stats", "Refund" }
              game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("Input"):InvokeServer(unpack(args))
              Fluent:Notify({ Title = "Stats Reset", Content = "รีเซ็ตสเตตัสเรียบร้อยแล้ว!", Duration = 3 })
          end)
      end
  })
  
  Tabs.Stats:AddSection("Prestige & Ranks")
  local AutoPrestigeToggle = Tabs.Stats:AddToggle("AutoPrestige", { 
      Title = "Auto Prestige (Fast Remote)", 
      Default = false 
  })
  AutoPrestigeToggle:OnChanged(function() _G.AutoPrestigeEnabled = AutoPrestigeToggle.Value end)
  
  Tabs.Stats:AddSection("Stat Potential Reroll")
  local StatDropdown = Tabs.Stats:AddDropdown("SelectStatReroll", { Title = "Select Stat", Values = {"DamageAmplifier", "HPMax", "CooldownReduction", "CriticalChance", "CriticalDamage", "DamageReduction", "Luck", "DefensePenetration"}, Default = "DamageAmplifier" })
  StatDropdown:OnChanged(function(Value) _G.SelectedStatToRoll = Value end)
  local StatRankDropdown = Tabs.Stats:AddDropdown("SelectStatRank", { Title = "Stop at Rank", Values = {"F", "E", "D", "C", "B", "A", "S", "SS", "SSS", "Kami"}, Default = "S" })
  StatRankDropdown:OnChanged(function(Value) _G.TargetStatRank = Value end)
  local AutoStatToggle = Tabs.Stats:AddToggle("AutoStatReroll", { Title = "Auto Reroll Stats", Default = false })
  AutoStatToggle:OnChanged(function() _G.AutoRollStatsEnabled = AutoStatToggle.Value end)
  
  Tabs.Stats:AddSection("Trait Reroll")
  local TraitModeDropdown = Tabs.Stats:AddDropdown("SelectTraitMode", { Title = "Reroll Mode", Values = {"By Rarity", "By Specific Trait"}, Default = "By Rarity" })
  TraitModeDropdown:OnChanged(function(Value) _G.TraitRollMode = Value end)
  local TraitRarityDropdown = Tabs.Stats:AddDropdown("SelectTraitRarity", { Title = "Stop at Rarity", Values = {"Epic", "Legendary", "Mythical", "Secret"}, Default = "Legendary" })
  TraitRarityDropdown:OnChanged(function(Value) _G.TargetTraitRarity = Value end)
  local SpecificTraitDropdown = Tabs.Stats:AddDropdown("SelectSpecificTrait", { Title = "Stop at Specific Trait", Values = {"Dominion", "AstralCore", "BlackHole", "TyrantKing", "WorldBreaker", "Flashstep", "Limitless", "SupremeWill", "Ascension", "Unstoppable", "Warlord", "Rebirth", "Predator", "Vicious", "Equilibrium"}, Default = "Dominion" })
  SpecificTraitDropdown:OnChanged(function(Value) _G.TargetSpecificTrait = Value end)
  local AutoTraitToggle = Tabs.Stats:AddToggle("AutoTraitReroll", { Title = "Auto Reroll Traits", Default = false })
  AutoTraitToggle:OnChanged(function() _G.AutoRollTraitsEnabled = AutoTraitToggle.Value end)
  
  local TeleportSwordData = {
      ["Chihora - Chihora [Ruin City]"] = { Island = "Ruin City", Portal = "RuinCity", Target = "Chihora", Aliases = {"Chihora"}, Kind = "Enemy" },
      ["Cursed Child - Cursed Child [Jujutsu Academy]"] = { Island = "Jujutsu Academy", Portal = "JujutsuAcademy", Target = "Cursed Child", Aliases = {"Cursed Child"}, Kind = "Enemy" },
      ["LuBu - Lu Bu [Ice Island]"] = { Island = "Ice Island", Portal = "IceIsland", Target = "Lu Bu", Aliases = {"Lu Bu", "LuBu"}, Kind = "Enemy" },
      ["Arima - Kishou Arima [Tokyo Ghoul]"] = { Island = "Tokyo Ghoul", Portal = "TokyoGhoul", Target = "Kishou Arima", Aliases = {"Kishou Arima", "Arima"}, Kind = "Enemy" },
      ["Flashy Flash - Flashy Flash [A-City]"] = { Island = "A-City", Portal = "ACity", Target = "Flashy Flash", Aliases = {"Flashy Flash"}, Kind = "Enemy" },
      ["Aizen - Sosuke Aizen [Hollow Land]"] = { Island = "Hollow Land", Portal = "HollowLand", Target = "Sosuke Aizen", Aliases = {"Sosuke Aizen", "Aizen"}, Kind = "Enemy" },
      ["Ichigo - Ichigo Kurosaki [Hollow Land]"] = { Island = "Hollow Land", Portal = "HollowLand", Target = "Ichigo Kurosaki", Aliases = {"Ichigo Kurosaki", "Ichigo"}, Kind = "Enemy" },
      ["Cid - Cid Kagenou [World Boss]"] = { Island = "Ruin City", Portal = "RuinCity", Portals = {"RuinCity", "ACity", "JujutsuAcademy", "TokyoGhoul"}, Target = "Cid Kagenou [World Boss]", Aliases = {"Cid Kagenou [World Boss]", "Cid Kagenou", "Cid"}, Kind = "Enemy" },
      ["Geburo - The Red Mist [World Boss]"] = { Island = "Ruin City", Portal = "RuinCity", Portals = {"RuinCity", "ACity", "HollowLand", "TokyoGhoul"}, Target = "The Red Mist", Aliases = {"The Red Mist", "Geburo"}, Kind = "Enemy" },
      ["Katana - Cursed Student High Tier [Jujutsu Academy]"] = { Island = "Jujutsu Academy", Portal = "JujutsuAcademy", Target = "Cursed Student High Tier", Aliases = {"Cursed Student High Tier"}, Kind = "Enemy" },
      ["Katana - Cursed Teacher High Tier [Jujutsu Academy]"] = { Island = "Jujutsu Academy", Portal = "JujutsuAcademy", Target = "Cursed Teacher High Tier", Aliases = {"Cursed Teacher High Tier"}, Kind = "Enemy" },
      ["Katana - Shinigami [Hollow Land]"] = { Island = "Hollow Land", Portal = "HollowLand", Target = "Shinigami", Aliases = {"Shinigami"}, Kind = "Enemy" },
      ["Katana - Demon Slayer [Slayer Mansion]"] = { Island = "Slayer Mansion", Portal = "SlayerMansion", Target = "Demon Slayer", Aliases = {"Demon Slayer"}, Kind = "Enemy" },
      ["Katana - Nameless Pillar [Slayer Mansion]"] = { Island = "Slayer Mansion", Portal = "SlayerMansion", Target = "Nameless Pillar", Aliases = {"Nameless Pillar"}, Kind = "Enemy" },
      ["Katana - Ghoul Investigator [Tokyo Ghoul]"] = { Island = "Tokyo Ghoul", Portal = "TokyoGhoul", Target = "Ghoul Investigator", Aliases = {"Ghoul Investigator"}, Kind = "Enemy" },
      ["Katana - Ghoul [Tokyo Ghoul]"] = { Island = "Tokyo Ghoul", Portal = "TokyoGhoul", Target = "Ghoul", Aliases = {"Ghoul"}, Kind = "Enemy" },
      ["Katana - Hishaku Member [Ruin City]"] = { Island = "Ruin City", Portal = "RuinCity", Target = "Hishaku Member", Aliases = {"Hishaku Member"}, Kind = "Enemy" },
      ["Katana - Distortion Monster [Ruin City]"] = { Island = "Ruin City", Portal = "RuinCity", Target = "Distortion Monster", Aliases = {"Distortion Monster"}, Kind = "Enemy" },
      ["Pipe - Fire Force Bandit [7th Company Island]"] = { Island = "7th Company Island", Portal = "7thComanpyIsland", Target = "Fire Force Bandit", Aliases = {"Fire Force Bandit"}, Kind = "Enemy" },
      ["Pipe - Fire Force E.Bandit [7th Company Island]"] = { Island = "7th Company Island", Portal = "7thComanpyIsland", Target = "Fire Force E.Bandit", Aliases = {"Fire Force E.Bandit"}, Kind = "Enemy" }
  }
  
  local TeleportCombatData = {
      ["Kaneki - Ken Kaneki [Tokyo Ghoul]"] = { Island = "Tokyo Ghoul", Portal = "TokyoGhoul", Target = "Ken Kaneki", Aliases = {"Ken Kaneki", "Kaneki"}, Kind = "Enemy" },
      ["Garou - Garou [A-City]"] = { Island = "A-City", Portal = "ACity", Target = "Garou", Aliases = {"Garou"}, Kind = "Enemy" },
      ["Rudo - Rudo Surebrec [A-City]"] = { Island = "A-City", Portal = "ACity", Target = "Rudo Surebrec", Aliases = {"Rudo Surebrec", "Rudo"}, Kind = "Enemy" },
      ["Okarun - Turbo Granny [Jungle Island]"] = { Island = "Jungle Island", Portal = "JungleIsland", Target = "Turbo Granny", Aliases = {"Turbo Granny", "Okarun"}, Kind = "Enemy" },
      ["Akaza - Akaza [Slayer Mansion]"] = { Island = "Slayer Mansion", Portal = "SlayerMansion", Target = "Akaza", Aliases = {"Akaza"}, Kind = "Enemy" },
      ["Garou - Fire Force Thug [7th Company Island]"] = { Island = "7th Company Island", Portal = "7thComanpyIsland", Target = "Fire Force Thug", Aliases = {"Fire Force Thug"}, Kind = "Enemy" },
      ["Combat - Bandit [Starter Island]"] = { Island = "Starter Island", Portal = "Starter", Target = "Bandit", Aliases = {"Bandit"}, Kind = "Enemy" },
      ["Combat - Bandit Leader [Starter Island]"] = { Island = "Starter Island", Portal = "Starter", Target = "Bandit Leader", Aliases = {"Bandit Leader"}, Kind = "Enemy" },
      ["Combat - Namekian [Jungle Island]"] = { Island = "Jungle Island", Portal = "JungleIsland", Target = "Namekian", Aliases = {"Namekian"}, Kind = "Enemy" },
      ["Combat - Piccolo [Jungle Island]"] = { Island = "Jungle Island", Portal = "JungleIsland", Target = "Piccolo", Aliases = {"Piccolo"}, Kind = "Enemy" },
      ["Combat - Serpoian [Jungle Island]"] = { Island = "Jungle Island", Portal = "JungleIsland", Target = "Serpoian", Aliases = {"Serpoian"}, Kind = "Enemy" },
      ["Combat - Serpoian True Form [Jungle Island]"] = { Island = "Jungle Island", Portal = "JungleIsland", Target = "Serpoian (True Form)", Aliases = {"Serpoian (True Form)"}, Kind = "Enemy" },
      ["Combat - Beggar [A-City]"] = { Island = "A-City", Portal = "ACity", Target = "Beggar", Aliases = {"Beggar"}, Kind = "Enemy" },
      ["Combat - Aristocrat [A-City]"] = { Island = "A-City", Portal = "ACity", Target = "Aristocrat", Aliases = {"Aristocrat"}, Kind = "Enemy" },
      ["Combat - Cursed Student [Jujutsu Academy]"] = { Island = "Jujutsu Academy", Portal = "JujutsuAcademy", Target = "Cursed Student", Aliases = {"Cursed Student"}, Kind = "Enemy" },
      ["Combat - Cursed Teacher [Jujutsu Academy]"] = { Island = "Jujutsu Academy", Portal = "JujutsuAcademy", Target = "Cursed Teacher", Aliases = {"Cursed Teacher"}, Kind = "Enemy" },
      ["Combat - Hollow [Hollow Land]"] = { Island = "Hollow Land", Portal = "HollowLand", Target = "Hollow", Aliases = {"Hollow"}, Kind = "Enemy" }
  }
  
  local function getIslandNameFromPortal(portalId)
      for islandName, config in pairs(EmbeddedIslandsData) do
          if config.PortalId == portalId then return islandName end
      end
      return nil
  end
  
  local TeleportNPCData = {}
  local seenTeleportNPCs = {}
  
  for islandName, config in pairs(EmbeddedIslandsData) do
      for npcDisplay, npcName in pairs(config.Npcs or {}) do
          local key = tostring(config.PortalId) .. "|" .. tostring(npcName)
          if not seenTeleportNPCs[key] then
              seenTeleportNPCs[key] = true
              local label = npcDisplay .. " - " .. npcName .. " [" .. islandName .. "]"
              TeleportNPCData[label] = {
                  Island = islandName,
                  Portal = config.PortalId,
                  Spot = npcName,
                  Target = npcName,
                  Aliases = {npcName, npcDisplay},
                  Kind = "NPC"
              }
          end
      end
  end
  
  for _, bossInfo in pairs(summonbossdata) do
      local islandName = getIslandNameFromPortal(bossInfo.Portal)
      local npcName = bossInfo.NPCName
      if islandName and npcName then
          local key = tostring(bossInfo.Portal) .. "|" .. tostring(npcName)
          if not seenTeleportNPCs[key] then
              seenTeleportNPCs[key] = true
              local label = npcName .. " [" .. islandName .. "]"
              TeleportNPCData[label] = {
                  Island = islandName,
                  Portal = bossInfo.Portal,
                  Spot = npcName,
                  Target = npcName,
                  Aliases = {npcName},
                  Kind = "NPC"
              }
          end
      end
  end
  
  local function makeSortedTeleportList(data)
      local values = {}
      for label in pairs(data) do table.insert(values, label) end
      table.sort(values)
      return values
  end
  
  local TeleportSwordList = makeSortedTeleportList(TeleportSwordData)
  local TeleportNPCList = makeSortedTeleportList(TeleportNPCData)
  local TeleportCombatList = makeSortedTeleportList(TeleportCombatData)
  
  local function normalizeTeleportTargetName(value)
      local name = string.lower(tostring(value or ""))
      name = string.gsub(name, "%[world%s+boss%]", "")
      name = string.gsub(name, "%s*%(%s*lv%.?%s*[%d,]+%s*%)%s*$", "")
      return string.gsub(name, "[^%w]", "")
  end
  
  local function teleportNameMatches(instanceName, aliases, allowPartial)
      local normalizedInstance = normalizeTeleportTargetName(instanceName)
      for _, alias in ipairs(aliases) do
          local normalizedAlias = normalizeTeleportTargetName(alias)
          if normalizedAlias ~= "" then
              if normalizedInstance == normalizedAlias then return true end
              if allowPartial and #normalizedAlias >= 4 and string.find(normalizedInstance, normalizedAlias, 1, true) then return true end
          end
      end
      return false
  end
  
  local function findTeleportTarget(entry)
      if not entry then return nil end
      local aliases = {}
      if entry.Target then table.insert(aliases, entry.Target) end
      if entry.Spot then table.insert(aliases, entry.Spot) end
      for _, alias in ipairs(entry.Aliases or {}) do table.insert(aliases, alias) end
  
      local containers = {}
      if workspace:FindFirstChild("NPCs") then table.insert(containers, workspace.NPCs) end
      if workspace:FindFirstChild("Enemies") then table.insert(containers, workspace.Enemies) end
  
      for _, container in ipairs(containers) do
          for _, instance in ipairs(container:GetChildren()) do
              if teleportNameMatches(instance.Name, aliases, false) then return instance end
          end
      end
      for _, container in ipairs(containers) do
          for _, instance in ipairs(container:GetChildren()) do
              if teleportNameMatches(instance.Name, aliases, true) then return instance end
          end
      end
      return nil
  end
  
  local function isPortalInTeleportEntry(portalId, entry)
      if not portalId or not entry then return false end
      if entry.Portals then
          for _, allowedPortal in ipairs(entry.Portals) do
              if allowedPortal == portalId then return true end
          end
          return false
      end
      return entry.Portal == portalId
  end
  
  local function resolveTeleportEntryPortal(entry)
      local target = findTeleportTarget(entry)
      if target then
          local targetPosition = getInstancePosition(target)
          local targetPortal = getPortalFromPosition(targetPosition)
          if targetPortal and isPortalInTeleportEntry(targetPortal, entry) then
              return targetPortal, target
          end
          local currentPortal = getCurrentIslandPortalId()
          if currentPortal and isPortalInTeleportEntry(currentPortal, entry) then
              return currentPortal, target
          end
      end
  
      if entry.Portals
          and _G.LastDetectedBossPortal
          and isPortalInTeleportEntry(_G.LastDetectedBossPortal, entry)
          and announcementMatchesBoss(_G.LastBossAnnouncementText, {Mobname = entry.Target, BossName = entry.Target}) then
          return _G.LastDetectedBossPortal, target
      end
      return entry.Portal, target
  end
  
  local function waitForTeleportCharacter(requestId, requestState, timeout)
      local deadline = os.clock() + (timeout or 8)
      repeat
          if requestState.Id ~= requestId then return nil end
          local character = Player.Character
          local root = character and character:FindFirstChild("HumanoidRootPart")
          if root then return root end
          task.wait(0.15)
      until os.clock() >= deadline
      return nil
  end
  
  local function waitForTeleportMap(entry, portalId, requestId, requestState, timeout)
      local deadline = os.clock() + (timeout or 8)
      repeat
          if requestState.Id ~= requestId then return nil, false end
          local target = findTeleportTarget(entry)
          local currentPortal = getCurrentIslandPortalId()
          if currentPortal == portalId then return target, true end
          if target then return target, true end
          task.wait(0.2)
      until os.clock() >= deadline
      return findTeleportTarget(entry), false
  end
  
  local function waitForTeleportTarget(entry, requestId, requestState, timeout)
      local deadline = os.clock() + (timeout or 4)
      repeat
          if requestState.Id ~= requestId then return nil end
          local target = findTeleportTarget(entry)
          if target then return target end
          task.wait(0.2)
      until os.clock() >= deadline
      return nil
  end
  
  local function instantTeleportToTarget(target)
      local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
      if not root or not target then return false end
  
      local targetCFrame
      if target:IsA("Model") then
          local targetRoot = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
          targetCFrame = targetRoot and targetRoot.CFrame or target:GetPivot()
      elseif target:IsA("BasePart") then
          targetCFrame = target.CFrame
      else
          local part = target:FindFirstChildWhichIsA("BasePart", true)
          targetCFrame = part and part.CFrame
      end
      if not targetCFrame then return false end
  
      root.CFrame = targetCFrame * CFrame.new(0, 0, 4)
      return true
  end
  
  local TeleportRequestState = {Id = 0}
  
  local function beginSafeTeleport(entry, sectionName)
      if not entry then return end
      TeleportRequestState.Id = TeleportRequestState.Id + 1
      local requestId = TeleportRequestState.Id
  
      task.spawn(function()
          local ok, err = pcall(function()
              DisableOtherFarms("None")
              task.wait(0.1)
              if TeleportRequestState.Id ~= requestId then return end
  
              local portalId = resolveTeleportEntryPortal(entry)
              if not portalId then
                  Fluent:Notify({ Title = sectionName, Content = "Portal data was not found.", Duration = 4 })
                  return
              end
  
              local remotes = ReplicatedStorage:WaitForChild("Remotes")
              local portalRemote = remotes:FindFirstChild("TeleportToPortal")
              local spotRemote = remotes:FindFirstChild("TeleportToIslandSpot")
              local currentPortal = getCurrentIslandPortalId()
              local islandName = getIslandNameFromPortal(portalId) or entry.Island
  
              if currentPortal ~= portalId then
                  if not portalRemote then
                      Fluent:Notify({ Title = sectionName, Content = "TeleportToPortal remote was not found.", Duration = 4 })
                      return
                  end
                  Fluent:Notify({ Title = sectionName, Content = "Going to " .. tostring(islandName) .. " first...", Duration = 3 })
                  portalRemote:FireServer(portalId)
                  waitForTeleportCharacter(requestId, TeleportRequestState, 8)
                  waitForTeleportMap(entry, portalId, requestId, TeleportRequestState, 8)
                  task.wait(0.35)
              end
  
              if TeleportRequestState.Id ~= requestId then return end
              if entry.Kind == "Island" then
                  Fluent:Notify({ Title = sectionName, Content = "Teleported to " .. tostring(islandName) .. ".", Duration = 3 })
                  return
              end
  
              waitForTeleportCharacter(requestId, TeleportRequestState, 5)
  
              if entry.Kind == "NPC" then
                  if spotRemote and entry.Spot then
                      spotRemote:FireServer(islandName, entry.Spot)
                      Fluent:Notify({ Title = sectionName, Content = "Teleported to " .. tostring(entry.Spot) .. ".", Duration = 3 })
                      return
                  end
  
                  local npcTarget = waitForTeleportTarget(entry, requestId, TeleportRequestState, 2)
                  if npcTarget and instantTeleportToTarget(npcTarget) then
                      Fluent:Notify({ Title = sectionName, Content = "Teleported to " .. tostring(entry.Target) .. ".", Duration = 3 })
                  else
                      Fluent:Notify({ Title = sectionName, Content = "NPC was not found after the island loaded.", Duration = 4 })
                  end
                  return
              end
  
              local target = waitForTeleportTarget(entry, requestId, TeleportRequestState, 4)
              if not target and spotRemote and entry.Target then
                  spotRemote:FireServer(islandName, entry.Target)
                  target = waitForTeleportTarget(entry, requestId, TeleportRequestState, 2)
              end
  
              if target and instantTeleportToTarget(target) then
                  Fluent:Notify({ Title = sectionName, Content = "Teleported to " .. tostring(entry.Target) .. ".", Duration = 3 })
              else
                  Fluent:Notify({ Title = sectionName, Content = tostring(entry.Target) .. " is not spawned on this island right now.", Duration = 5 })
              end
          end)
  
          if not ok then
              Fluent:Notify({ Title = sectionName, Content = "Teleport error: " .. tostring(err), Duration = 5 })
          end
      end)
  end
  
  Tabs.Teleport:AddSection("Teleport Island")
  Tabs.Teleport:AddDropdown("SelectIslandTP", {
      Title = "Select Island",
      Values = IslandNames,
      Default = SelectedTeleportIsland,
      Callback = function(Value) SelectedTeleportIsland = Value end
  })
  Tabs.Teleport:AddButton({
      Title = "Teleport to Island",
      Callback = function()
          local config = EmbeddedIslandsData[SelectedTeleportIsland]
          if config then
              beginSafeTeleport({
                  Island = SelectedTeleportIsland,
                  Portal = config.PortalId,
                  Kind = "Island"
              }, "Teleport Island")
          end
      end
  })
  
  Tabs.Teleport:AddSection("Teleport Sword")
  local SelectedTeleportSword = TeleportSwordList[1]
  Tabs.Teleport:AddDropdown("SelectTeleportSword", {
      Title = "Select Sword",
      Values = TeleportSwordList,
      Default = SelectedTeleportSword,
      Callback = function(Value) SelectedTeleportSword = Value end
  })
  Tabs.Teleport:AddButton({
      Title = "Teleport to Sword Source",
      Callback = function()
          beginSafeTeleport(TeleportSwordData[SelectedTeleportSword], "Teleport Sword")
      end
  })
  
  Tabs.Teleport:AddSection("Teleport NPC")
  local SelectedTeleportNPC = TeleportNPCList[1]
  Tabs.Teleport:AddDropdown("SelectTeleportNPC", {
      Title = "Select NPC",
      Values = TeleportNPCList,
      Default = SelectedTeleportNPC,
      Callback = function(Value) SelectedTeleportNPC = Value end
  })
  Tabs.Teleport:AddButton({
      Title = "Teleport to NPC",
      Callback = function()
          beginSafeTeleport(TeleportNPCData[SelectedTeleportNPC], "Teleport NPC")
      end
  })
  
  Tabs.Teleport:AddSection("Teleport Combat")
  local SelectedTeleportCombat = TeleportCombatList[1]
  Tabs.Teleport:AddDropdown("SelectTeleportCombat", {
      Title = "Select Combat",
      Values = TeleportCombatList,
      Default = SelectedTeleportCombat,
      Callback = function(Value) SelectedTeleportCombat = Value end
  })
  Tabs.Teleport:AddButton({
      Title = "Teleport to Combat Source",
      Callback = function()
          beginSafeTeleport(TeleportCombatData[SelectedTeleportCombat], "Teleport Combat")
      end
  })
  
  task.spawn(function()
      while task.wait(1) do
          if _G.ESPEnabled then
              for _, v in pairs(Players:GetPlayers()) do
                  if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                      if not v.Character:FindFirstChild("Highlight") then
                          local hl = Instance.new("Highlight")
                          hl.Name = "Highlight"
                          hl.FillColor = Color3.fromRGB(255, 0, 0)
                          hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                          hl.FillTransparency = 0.5
                          hl.OutlineTransparency = 0
                          hl.Parent = v.Character
                      end
                  end
              end
          end
      end
  end)
  
  task.spawn(function()
      game:GetService("RunService").RenderStepped:Connect(function()
          if _G.SpeedHack and Player.Character and Player.Character:FindFirstChild("Humanoid") then
              Player.Character.Humanoid.WalkSpeed = 160
          end
      end)
  end)
  
  UserInputService.JumpRequest:Connect(function()
      if _G.InfJump and Player.Character and Player.Character:FindFirstChild("Humanoid") then
          Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
  end)
  
  _G.AntiAFK = true
  Player.Idled:Connect(function()
      if _G.AntiAFK then
          VirtualUser:CaptureController()
          VirtualUser:ClickButton2(Vector2.new())
      end
  end)
  
  task.spawn(function()
      while true do
          task.wait(0.2)
          if _G.AutoAddStats then
              pcall(function()
                  for statName, isSelected in pairs(_G.SelectedAddStats) do
                      if isSelected then
                          local args = {
                              "AddPoint",
                              statName,
                              _G.AddStatAmount
                          }
                          game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("Input"):InvokeServer(unpack(args))
                          task.wait(0.1)
                      end
                  end
              end)
          end
      end
  end)
  
  task.spawn(function()
      while true do
          task.wait(0.8)
          if _G.AutoPrestigeEnabled then
              pcall(function()
                  local dataFolder = Player:FindFirstChild("Data")
                  if dataFolder then
                      local currentPrestige = 0
                      local prestigeVal = dataFolder:FindFirstChild("Prestige")
                      if prestigeVal then currentPrestige = prestigeVal.Value end
                      local currentLevel = 0
                      local levelVal = dataFolder:FindFirstChild("Level")
                      if levelVal then currentLevel = levelVal.Value end
                      local targetMaxLevel = 1500
                      if _G.PrestigeData and _G.PrestigeData.GetLevelCap then
                          targetMaxLevel = _G.PrestigeData.GetLevelCap(currentPrestige)
                      end
                      if currentLevel >= targetMaxLevel then
                          local args = { "Prestige" }
                          game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("Input"):InvokeServer(unpack(args))
                          task.wait(3)
                      end
                  end
              end)
          end
          if _G.AutoRollStatsEnabled and _G.SelectedStatToRoll and _G.TargetStatRank and _G.InputFunction
              and not AutoBossToggle and not AutoSummonOnlyToggle and not AutoKillSummonToggle and not AutoPityToggle and not AutoAllQuestToggle then
              IsRerolling = true
              pcall(function()
                  local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                  local teleportToIslandSpot = Remotes:FindFirstChild("TeleportToIslandSpot")
                  if teleportToIslandSpot then
                      teleportToIslandSpot:FireServer("Legacy Island", "Potential Reroll")
                      task.wait(1)
                  end
                  local result = _G.InputFunction:InvokeServer("Reroll", "StatRerollGet")
                  if result and type(result) == "table" then
                      local currentRerolls = result.rerolls or result
                      local currentStatData = currentRerolls[_G.SelectedStatToRoll]
                      local currentRank = currentStatData and currentStatData.rank or "F"
                      local currentScore = statRankOrder[currentRank] or 1
                      local targetScore = statRankOrder[_G.TargetStatRank] or 1
                      if currentScore < targetScore then
                          local shardsVal = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Shards")
                          if shardsVal and shardsVal.Value >= 1000 then
                              _G.InputFunction:InvokeServer("Reroll", "StatReroll", _G.SelectedStatToRoll)
                          else
                              Fluent:Notify({ Title = "Auto Stat Reroll", Content = "Shards ไม่เพียงพอ! ระบบสุ่มปิดการทำงาน", Duration = 4 })
                              AutoStatToggle:SetValue(false)
                              IsRerolling = false
                          end
                      else
                          Fluent:Notify({ Title = "Auto Stat Reroll", Content = "ได้รับระดับสเตตัสตามเป้าหมายเรียบร้อยแล้ว!", Duration = 5 })
                          AutoStatToggle:SetValue(false)
                          IsRerolling = false
                      end
                  else
                      IsRerolling = false
                  end
              end)
          end
          if _G.AutoRollTraitsEnabled and TraitConfig
              and not AutoBossToggle and not AutoSummonOnlyToggle and not AutoKillSummonToggle and not AutoPityToggle and not AutoAllQuestToggle then
              IsRerolling = true
              pcall(function()
                  local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                  local teleportToIslandSpot = Remotes:FindFirstChild("TeleportToIslandSpot")
                  if teleportToIslandSpot then
                      teleportToIslandSpot:FireServer("Legacy Island", "Trait Reroll")
                      task.wait(1)
                  end
                  local traitDataFolder = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Trait")
                  local TraitRerollRemote = Remotes:FindFirstChild("TraitReroll")
                  if traitDataFolder and TraitRerollRemote then
                      local currentTrait = traitDataFolder.Value
                      local traitConfigData = TraitConfig.Traits[currentTrait]
                      local currentRarity = traitConfigData and traitConfigData.Rarity or "Common"
                      local stopRolling = false
                      if _G.TraitRollMode == "By Specific Trait" then
                          if currentTrait:lower() == _G.TargetSpecificTrait:lower() then stopRolling = true end
                      else
                          local currentScore = traitRarityOrder[currentRarity] or 1
                          local targetScore = traitRarityOrder[_G.TargetTraitRarity] or 3
                          if currentScore >= targetScore then stopRolling = true end
                      end
                      if stopRolling then
                          Fluent:Notify({ Title = "Auto Trait Reroll", Content = "ได้รับคุณสมบัติหรือระดับที่ต้องการแล้ว!", Duration = 5 })
                          AutoTraitToggle:SetValue(false)
                          IsRerolling = false
                      else
                          local ok, response = pcall(function() return TraitRerollRemote:InvokeServer() end)
                          if ok and response and response.Error == "InsufficientCurrency" then
                              Fluent:Notify({ Title = "Auto Trait Reroll", Content = "ไอเทมใบสุ่มหมด! ปิดระบบอัตโนมัติ", Duration = 4 })
                              AutoTraitToggle:SetValue(false)
                              IsRerolling = false
                          end
                      end
                  else
                      IsRerolling = false
                  end
              end)
          end
          if not _G.AutoRollStatsEnabled and not _G.AutoRollTraitsEnabled then IsRerolling = false end
      end
  end)
  
  
  
  
  task.spawn(function()
      while true do
          task.wait(1)
          if IsRerolling then continue end
          if AutoSummonOnlyToggle and SelectedSummonBossDisplay ~= "None" then
              pcall(function()
                  local bossInfo = summonbossdata[SelectedSummonBossDisplay]
                  if not bossInfo then return end
                  if bossInfo.NPCName == "Sacrifice Table" and (bossInfo.Portal ~= "RuinCity" or not ruinCitySacrificeBosses[SelectedSummonBossDisplay]) then return end
                  local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                  
                  local targetBoss = getClosestMonster(bossInfo.Mobname)
                  local targetIndicator = findBossIndicator(bossInfo)
                  if targetBoss then
                      markSummonedBossAlive(targetBoss, false)
                      return
                  elseif targetIndicator then
                      markSummonedBossAlive(nil, true)
                      return
                  end
  
                  if updateSummonedBossDeathState(bossInfo) then
                      
                  elseif _G.SummonedBossActive and _G.SummonedBossDisplay == SelectedSummonBossDisplay then
                      if _G.SummonedBossConfirmed then return end
                      if os.clock() - (_G.LastSummonAttemptTime or 0) < 8 then return end
                      resetSummonedBossState(SelectedSummonBossDisplay)
                  elseif _G.SummonedBossActive then
                      resetSummonedBossState(_G.SummonedBossDisplay)
                  end
  
                  
  
  
                  local isNPCHere = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild(bossInfo.NPCName)
                  local currentIsland = getCurrentIslandPortalId()
                  local isAtSummonIsland = currentIsland == bossInfo.Portal
                      or isPlayerNearInstance(isNPCHere, 1200)
                  
                  if not isAtSummonIsland then
                      local teleportToPortal = Remotes:FindFirstChild("TeleportToPortal")
                      if teleportToPortal then
                          teleportToPortal:FireServer(bossInfo.Portal)
                          CurrentSelectedPortal = bossInfo.Portal
                          _G.LastSummonTeleportTime = os.clock()
                          task.wait(1.5)
                          return
                      end
                  end
                  
                  if isNPCHere then
                      CurrentSelectedPortal = bossInfo.Portal 
                      
                      if bossInfo.NPCName == "Sacrifice Table" then
                          local tableCFrame = CFrame.new(-2846.15283, 13.2565403, 4210.13281, 0.893080592, 0, -0.449896663, 0, 1, 0, 0.449896663, 0, 0.893080592)
                          smartMoveCharacter(tableCFrame * CFrame.new(0, 0, 4))
                      elseif isNPCHere:FindFirstChild("HumanoidRootPart") then
                          smartMoveCharacter(isNPCHere.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                      elseif isNPCHere:IsA("Model") then
                          smartMoveCharacter(isNPCHere:GetPivot() * CFrame.new(0, 0, 4))
                      end
                      
                      task.wait(0.5)
                      
                      local args = { "SpawnBoss", isNPCHere, bossInfo.BossName }
                      markSummonAttempt(SelectedSummonBossDisplay)
                      game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("Input"):InvokeServer(unpack(args))
                      task.wait(1)
                  else
                      if os.clock() - (_G.LastSummonTeleportTime or 0) > 4 then
                          CurrentSelectedPortal = nil
                      end
                  end
              end)
          end
      end
  end)
  
  
  
  
  task.spawn(function()
      local lastSkillUsed = { Z = 0, X = 0, C = 0, V = 0, F = 0 }
      local SKILL_COOLDOWN = 2.0 
      local lastPortalSwitchTime = 0
      while task.wait() do
          if IsRerolling then 
              task.wait(0.5)
              continue 
          end
          if AutoKillSummonToggle and SelectedSummonBossDisplay ~= "None" then
              pcall(function()
                  local bossInfo = summonbossdata[SelectedSummonBossDisplay]
                  if not bossInfo then return end
                  if bossInfo.NPCName == "Sacrifice Table" and (bossInfo.Portal ~= "RuinCity" or not ruinCitySacrificeBosses[SelectedSummonBossDisplay]) then return end
                  local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                  
                  local targetBoss = getClosestMonster(bossInfo.Mobname)
                  local targetIndicatorInstance = findBossIndicator(bossInfo)
                  if targetBoss then markSummonedBossAlive(targetBoss, false)
                  elseif targetIndicatorInstance then markSummonedBossAlive(nil, true) end
                  if updateSummonedBossDeathState(bossInfo) then return end
  
                  local targetPortals = bossInfo.Portals or {bossInfo.Portal}
                  local trackingBoss = _G.SummonedBossActive and _G.SummonedBossDisplay == SelectedSummonBossDisplay
                  local hasAnnouncementPortal = trackingBoss
                      and portalIsInList(_G.LastDetectedBossPortal, targetPortals)
                      and announcementMatchesBoss(_G.LastBossAnnouncementText, bossInfo)
                  local isBossAliveGlobally = targetBoss ~= nil or targetIndicatorInstance ~= nil or trackingBoss
                  if not isBossAliveGlobally then return end
                  local currentIsland = getCurrentIslandPortalId() 
                  
                  local actualPortal = nil
                  if #targetPortals == 1 then
                      actualPortal = targetPortals[1]
                  elseif hasAnnouncementPortal and portalIsInList(_G.LastDetectedBossPortal, targetPortals) then
                      actualPortal = _G.LastDetectedBossPortal
                  elseif targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") then
                      local detectedPortal = getPortalFromPosition(targetBoss.HumanoidRootPart.Position)
                      if portalIsInList(detectedPortal, targetPortals) then
                          actualPortal = detectedPortal
                      end
  
                  end
                  if not actualPortal then
                      if not _G.CurrentSummonKillIndex or _G.CurrentSummonKillIndex > #targetPortals then _G.CurrentSummonKillIndex = 1 end
                      actualPortal = targetPortals[_G.CurrentSummonKillIndex]
                  end
                  
                  
                  local bossPortalConfirmed = currentIsland ~= nil and currentIsland == actualPortal
                  if not bossPortalConfirmed then
                      if os.clock() - lastPortalSwitchTime >= 2 then
                          local teleportToPortal = Remotes:FindFirstChild("TeleportToPortal")
                          if teleportToPortal then
                              teleportToPortal:FireServer(actualPortal)
                              CurrentSelectedPortal = actualPortal
                              lastPortalSwitchTime = os.clock()
                              task.wait(1.5)
                          end
                      end
                      return 
                  end
                  
                  if targetBoss or targetIndicatorInstance or trackingBoss then
                      if not targetBoss then
                          if hasAnnouncementPortal then
                              
                          else
                              if isBossAliveGlobally and os.clock() - lastPortalSwitchTime > 3 then
                                  _G.CurrentSummonKillIndex = _G.CurrentSummonKillIndex + 1
                                  if _G.CurrentSummonKillIndex > #targetPortals then _G.CurrentSummonKillIndex = 1 end
                                  CurrentSelectedPortal = nil
                                  lastPortalSwitchTime = 0
                                  task.wait(0.25)
                              end
                          end
                      else
                          _G.CurrentSummonKillIndex = 1
                          if _G.InstaKillEnabled and targetBoss:FindFirstChild("Humanoid") and targetBoss.Humanoid.Health <= (targetBoss.Humanoid.MaxHealth * 0.9) then
                              instaKill(targetBoss)
                          else
                              local farmCFrame = nil
                              if FarmPosition == "Above" then farmCFrame = targetBoss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                              elseif FarmPosition == "Behind" then farmCFrame = targetBoss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5) end
                              if farmCFrame then smartMoveCharacter(farmCFrame) end
                              
                              if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
                              local currentTool = Player.Character:FindFirstChildOfClass("Tool")
                              if currentTool then 
                                  Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, "M1")
                                  task.wait(0.1) 
                                  if _G.AutoSkillEnabled then
                                      local bossPart = targetBoss:FindFirstChild("HumanoidRootPart")
                                      if bossPart then
                                          local pos = bossPart.Position
                                          local targetVector = Vector3.new(pos.X, pos.Y, pos.Z)
                                          local currentTime = os.clock()
                                          for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
                                              if _G.SelectedSkills[skill] and (currentTime - lastSkillUsed[skill] >= SKILL_COOLDOWN) then
                                                  Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, skill, targetVector)
                                                  lastSkillUsed[skill] = currentTime
                                                  task.wait(0.1)
                                              end
                                          end
                                      end
                                  end
                              end
                          end
                      end
                  end
              end)
          end
      end
  end)
  
  task.spawn(function()
      local lastSkillUsed = { Z = 0, X = 0, C = 0, V = 0, F = 0 }
      local SKILL_COOLDOWN = 2.0 
      while task.wait() do
          if IsRerolling then 
              task.wait(0.5)
              continue 
          end
          if AutoFarmToggle and SelectedMonsterDisplay ~= "None" then
              if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then
                  task.wait(0.5)
                  continue
              end
              pcall(function()
                  local currentMobData = mobdata[SelectedMonsterDisplay]
                  if not currentMobData then return end
                  local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                  local npcWindow = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild(currentMobData.QuestName)
                  local targetMob = getClosestMonster(currentMobData.Mobname)
                  
                  if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                  
                  if CurrentSelectedPortal ~= currentMobData.Portal then
                      local teleportToPortal = Remotes:FindFirstChild("TeleportToPortal")
                      if teleportToPortal then
                          teleportToPortal:FireServer(currentMobData.Portal)
                          CurrentSelectedPortal = currentMobData.Portal
                          task.wait(0.5)
                          return
                      end
                  end
                  local isLocalLoaded = (npcWindow ~= nil or targetMob ~= nil)
                  if isLocalLoaded then CurrentSelectedPortal = currentMobData.Portal end
                  
                  local hasQuest, questFolder = checkHasQuest(currentMobData.QuestName)
                  if not hasQuest then
                      if npcWindow then
                          local prompt = npcWindow:FindFirstChildWhichIsA("ProximityPrompt", true)
                          if prompt then
                              if npcWindow:FindFirstChild("HumanoidRootPart") then
                                  smartMoveCharacter(npcWindow.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
                              else
                                  smartMoveCharacter(npcWindow:GetPivot() * CFrame.new(0, 0, 2))
                              end
                              task.wait(0.8) 
                              local startTimer = os.clock()
                              repeat 
                                  triggerProximityPrompt(prompt)
                                  pcall(function()
                                      VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                      task.wait(0.05)
                                      VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                  end)
                                  task.wait(0.5) 
                              until checkHasQuest(currentMobData.QuestName) or (os.clock() - startTimer > 4)
                          end
                      end
                  else
                      local completedValue = questFolder:FindFirstChild("Completed")
                      if completedValue and completedValue.Value == true then
                          if _G.InputFunction then
                              _G.InputFunction:InvokeServer("Quest", "Claim", currentMobData.QuestName)
                              task.wait(0.5)
                          end
                      else
                          if targetMob then
                              if _G.InstaKillEnabled and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health <= (targetMob.Humanoid.MaxHealth * 0.9) then
                                  if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                                  instaKill(targetMob)
                              else
                                  local farmCFrame = nil
                                  if FarmPosition == "Above" then farmCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                                  elseif FarmPosition == "Behind" then farmCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5) end
                                  if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                                  if farmCFrame then smartMoveCharacter(farmCFrame) end
                                  if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
                                  local currentTool = Player.Character:FindFirstChildOfClass("Tool")
                                  if currentTool then 
                                      if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                                      Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, "M1")
                                      task.wait(0.1) 
                                      if _G.AutoSkillEnabled then
                                          local mobPart = targetMob:FindFirstChild("HumanoidRootPart")
                                          if mobPart then
                                              local pos = mobPart.Position
                                              local targetVector = Vector3.new(pos.X, pos.Y, pos.Z)
                                              local currentTime = os.clock()
                                              for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
                                                  if _G.SelectedSkills[skill] and (currentTime - lastSkillUsed[skill] >= SKILL_COOLDOWN) then
                                                      if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                                                      Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, skill, targetVector)
                                                      lastSkillUsed[skill] = currentTime
                                                      task.wait(0.1)
                                                  end
                                              end
                                          end
                                      end
                                  end
                              end
                          end
                      end
                  end
              end)
          end
      end
  end)
  
  task.spawn(function()
      local lastSkillUsed = { Z = 0, X = 0, C = 0, V = 0, F = 0 }
      local SKILL_COOLDOWN = 2.0 
      while task.wait() do
          if IsRerolling then 
              task.wait(0.5)
              continue 
          end
          if AutoNoQuestToggle and #_G.SelectedNoQuestMonsters > 0 then
              if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then
                  task.wait(0.5)
                  continue
              end
              pcall(function()
                  local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                  if not _G.CurrentNoQuestIndex or _G.CurrentNoQuestIndex > #_G.SelectedNoQuestMonsters then
                      _G.CurrentNoQuestIndex = 1
                  end
                  local currentMobData = _G.SelectedNoQuestMonsters[_G.CurrentNoQuestIndex]
                  local targetMob = getClosestMonster(currentMobData.Mobname)
                  
                  if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                  
                  if CurrentSelectedPortal ~= currentMobData.Portal then
                      local teleportToPortal = Remotes:FindFirstChild("TeleportToPortal")
                      if teleportToPortal then
                          teleportToPortal:FireServer(currentMobData.Portal)
                          CurrentSelectedPortal = currentMobData.Portal
                          task.wait(0.5)
                          return
                      end
                  end
                  local isLocalLoaded = (targetMob ~= nil)
                  if isLocalLoaded then CurrentSelectedPortal = currentMobData.Portal end
                  if targetMob then
                      if _G.InstaKillEnabled and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health <= (targetMob.Humanoid.MaxHealth * 0.9) then
                          if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                          instaKill(targetMob)
                      else
                          local farmCFrame = nil
                          if FarmPosition == "Above" then farmCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                          elseif FarmPosition == "Behind" then farmCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5) end
                          
                          if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                          if farmCFrame then smartMoveCharacter(farmCFrame) end
                          
                          if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
                          local currentTool = Player.Character:FindFirstChildOfClass("Tool")
                          if currentTool then 
                              if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                              Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, "M1")
                              task.wait(0.1) 
                              if _G.AutoSkillEnabled then
                                  local mobPart = targetMob:FindFirstChild("HumanoidRootPart")
                                  if mobPart then
                                      local pos = mobPart.Position
                                      local targetVector = Vector3.new(pos.X, pos.Y, pos.Z)
                                      local currentTime = os.clock()
                                      for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
                                          if _G.SelectedSkills[skill] and (currentTime - lastSkillUsed[skill] >= SKILL_COOLDOWN) then
                                              if _G.IsBossSpawnedAndFarming or AutoSummonOnlyToggle or AutoKillSummonToggle then return end
                                              Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, skill, targetVector)
                                              lastSkillUsed[skill] = currentTime
                                              task.wait(0.1)
                                          end
                                      end
                                  end
                              end
                          end
                      end
                  else
                      _G.CurrentNoQuestIndex = _G.CurrentNoQuestIndex + 1
                      task.wait(0.5)
                  end
              end)
          end
      end
  end)
  
  
  
  
  task.spawn(function()
      local lastSkillUsed = { Z = 0, X = 0, C = 0, V = 0, F = 0 }
      local SKILL_COOLDOWN = 2.0 
      local lastPortalSwitchTime = 0
      while task.wait() do
          if IsRerolling then 
              task.wait(0.5)
              continue 
          end
          if AutoBossToggle and #_G.SelectedWorldBosses > 0 then
              if AutoSummonOnlyToggle or AutoKillSummonToggle then
                  task.wait(0.5)
                  continue
              end
              pcall(function()
                  local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                  local targetBossData = nil
                  local targetBossModel = nil
                  local targetIndicatorInstance = nil
                  local bossIsAlive = false
                  
                  for _, bossNameDisplay in ipairs(_G.SelectedWorldBosses) do
                      local currentBossData = bossdata[bossNameDisplay]
                      if currentBossData then
                          local localTarget = getClosestMonster(currentBossData.Mobname)
                          if localTarget and localTarget:FindFirstChild("Humanoid") and localTarget.Humanoid.Health > 0 then
                              bossIsAlive = true
                              targetBossData = currentBossData
                              targetBossModel = localTarget
                              break 
                          end
                      end
                  end
                  
                  if not targetBossModel then
                      for _, bossNameDisplay in ipairs(_G.SelectedWorldBosses) do
                          local currentBossData = bossdata[bossNameDisplay]
                          if currentBossData then
                              local shortName = string.split(currentBossData.Mobname, " ")[1]
                              for _, v in ipairs(workspace:GetChildren()) do
                                  if v.Name:find("BossIndicator") and v.Name:find(shortName) then
                                      local isGhostIndicator = false
                                      for _, child in ipairs(v:GetDescendants()) do
                                          if child:IsA("TextLabel") and (tonumber(child.Text:match("(%d+)%s*%%")) == 0 or child.Text:lower():find("dead") or child.Text:find("0 /")) then
                                              isGhostIndicator = true
                                              break
                                          end
                                      end
                                      if not isGhostIndicator then
                                          bossIsAlive = true
                                          targetBossData = currentBossData
                                          targetIndicatorInstance = v
                                          break
                                      end
                                  end
                              end
                              if bossIsAlive then break end
                          end
                      end
                  end
                  
                  
                  
                  local announcementPortalForTarget = nil
                  local announcementIsFresh = _G.LastDetectedBossPortal
                      and os.clock() - (_G.LastDetectedBossPortalTime or 0) <= 15
  
                  if announcementIsFresh then
                      for _, bossNameDisplay in ipairs(_G.SelectedWorldBosses) do
                          local announcedBossData = bossdata[bossNameDisplay]
                          if announcedBossData
                              and portalIsInList(_G.LastDetectedBossPortal, announcedBossData.Portals)
                              and announcementMatchesBoss(_G.LastBossAnnouncementText, announcedBossData) then
                              if not bossIsAlive then
                                  bossIsAlive = true
                                  targetBossData = announcedBossData
                              end
                              if targetBossData == announcedBossData then
                                  announcementPortalForTarget = _G.LastDetectedBossPortal
                              end
                              break
                          end
                      end
                  end
                  if bossIsAlive and targetBossData then
                      _G.IsBossSpawnedAndFarming = true
                      _G.LastBossDetectedTime = os.clock()
                      
                      local currentIsland = getCurrentIslandPortalId()
                      local actualPortal = nil
                      
                      local shortName = string.split(targetBossData.Mobname, " ")[1]
                      local indicator = targetIndicatorInstance
                      if not indicator then
                          for _, v in ipairs(workspace:GetChildren()) do
                              if v.Name:find("BossIndicator") and v.Name:find(shortName) then
                                    local isGhost = false
                                  for _, child in ipairs(v:GetDescendants()) do
                                      if child:IsA("TextLabel") and (tonumber(child.Text:match("(%d+)%s*%%")) == 0 or child.Text:lower():find("dead")) then
                                          isGhost = true
                                          break
                                      end
                                  end
                                  if not isGhost then
                                      indicator = v
                                      break
                                  end
                              end
                          end
                      end
                      
                      if #targetBossData.Portals == 1 then
                          actualPortal = targetBossData.Portals[1]
                      elseif announcementPortalForTarget then
                          actualPortal = announcementPortalForTarget
                      elseif targetBossModel and targetBossModel:FindFirstChild("HumanoidRootPart") then
                          local detectedPortal = getPortalFromPosition(targetBossModel.HumanoidRootPart.Position)
                          if portalIsInList(detectedPortal, targetBossData.Portals) then
                              actualPortal = detectedPortal
                          end
  
                      end
                      
                      if not actualPortal then
                          if not _G.CurrentBossPortalIndex or _G.CurrentBossPortalIndex > #targetBossData.Portals then
                              _G.CurrentBossPortalIndex = 1
                          end
                          actualPortal = targetBossData.Portals[_G.CurrentBossPortalIndex]
                      end
                      
                      
                      local bossPortalConfirmed = currentIsland ~= nil and currentIsland == actualPortal
                      if not bossPortalConfirmed then
                          if os.clock() - lastPortalSwitchTime >= 2 then
                              local teleportToPortal = Remotes:FindFirstChild("TeleportToPortal")
                              if teleportToPortal then
                                  teleportToPortal:FireServer(actualPortal)
                                  CurrentSelectedPortal = actualPortal
                                  lastPortalSwitchTime = os.clock()
                                  task.wait(1.5)
                              end
                          end
                          return 
                      end
                      
                      if targetBossModel or indicator or bossIsAlive then
                          if not targetBossModel then
                              if announcementPortalForTarget then
                                  
                              else
                                  if os.clock() - lastPortalSwitchTime >= 3 then
                                      _G.CurrentBossPortalIndex = _G.CurrentBossPortalIndex + 1
                                      if _G.CurrentBossPortalIndex > #targetBossData.Portals then _G.CurrentBossPortalIndex = 1 end
                                      CurrentSelectedPortal = nil
                                      lastPortalSwitchTime = 0
                                      task.wait(0.25)
                                  end
                              end
                          else
                              _G.CurrentBossPortalIndex = 1
                              if _G.InstaKillEnabled and targetBossModel:FindFirstChild("Humanoid") and targetBossModel.Humanoid.Health <= (targetBossModel.Humanoid.MaxHealth * 0.9) then
                                  instaKill(targetBossModel)
                              else
                                  local farmCFrame = nil
                                  if FarmPosition == "Above" then farmCFrame = targetBossModel.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                                  elseif FarmPosition == "Behind" then farmCFrame = targetBossModel.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5) end
                                  if farmCFrame then smartMoveCharacter(farmCFrame) end
                                  if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
                                  local currentTool = Player.Character:FindFirstChildOfClass("Tool")
                                  if currentTool then 
                                      Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, "M1")
                                      task.wait(0.1) 
                                      if _G.AutoSkillEnabled then
                                          local bossPart = targetBossModel:FindFirstChild("HumanoidRootPart")
                                          if bossPart then
                                              local pos = bossPart.Position
                                              local targetVector = Vector3.new(pos.X, pos.Y, pos.Z)
                                              local currentTime = os.clock()
                                              for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
                                                  if _G.SelectedSkills[skill] and (currentTime - lastSkillUsed[skill] >= SKILL_COOLDOWN) then
                                                      Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, skill, targetVector)
                                                      lastSkillUsed[skill] = currentTime
                                                      task.wait(0.1)
                                                  end
                                              end
                                          end
                                      end
                                  end
                              end
                          end
                      end
                  else
                      if os.clock() - (_G.LastBossDetectedTime or 0) > 5 then
                          _G.IsBossSpawnedAndFarming = false
                          _G.CurrentBossPortalIndex = 1
                      else
                          _G.IsBossSpawnedAndFarming = true
                      end
                  end
              end)
          else
              if os.clock() - (_G.LastBossDetectedTime or 0) > 5 then
                  _G.IsBossSpawnedAndFarming = false
                  _G.CurrentBossPortalIndex = 1
              else
                  _G.IsBossSpawnedAndFarming = true
              end
          end
      end
  end)
  
  task.spawn(function()
      local lastSkillUsed = { Z = 0, X = 0, C = 0, V = 0, F = 0 }
      local SKILL_COOLDOWN = 2.0 
      local lastPortalTime = 0
      while task.wait() do
          if IsRerolling then 
              task.wait(0.5)
              continue 
          end
          local hasMobInDungeon = false
          local targetMob = nil
          local shortestDistance = math.huge
          if workspace:FindFirstChild("Enemies") then
              for _, v in ipairs(workspace.Enemies:GetChildren()) do
                  if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                      hasMobInDungeon = true
                      if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                          local dist = (Player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                          if dist < shortestDistance then
                              shortestDistance = dist
                              targetMob = v
                          end
                      end
                  end
              end
          end
          if _G.AutoDungeonKillEnabled and targetMob then
              if _G.InstaKillEnabled and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health <= (targetMob.Humanoid.MaxHealth * 0.9) then
                  instaKill(targetMob)
              else
                  pcall(function()
                      local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                      local farmCFrame = nil
                      if FarmPosition == "Above" then farmCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                      elseif FarmPosition == "Behind" then farmCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5) end
                      if farmCFrame then smartMoveCharacter(farmCFrame) end
                      if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
                      local currentTool = Player.Character:FindFirstChildOfClass("Tool")
                      if currentTool then 
                          Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, "M1")
                          task.wait(0.1) 
                          if _G.AutoSkillEnabled then
                              local mobPart = targetMob:FindFirstChild("HumanoidRootPart")
                              if mobPart then
                                      local pos = mobPart.Position
                                      local targetVector = Vector3.new(pos.X, pos.Y, pos.Z)
                                      local currentTime = os.clock()
                                      for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
                                          if _G.SelectedSkills[skill] and (currentTime - lastSkillUsed[skill] >= SKILL_COOLDOWN) then
                                              Remotes:WaitForChild("Input"):FireServer("Tool", currentTool, skill, targetVector)
                                              lastSkillUsed[skill] = currentTime
                                              task.wait(0.1)
                                          end
                                      end
                              end
                          end
                      end
                  end)
              end
          end
          if not hasMobInDungeon then
              if os.clock() - lastPortalTime > 5 then 
                  pcall(function()
                      local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                      local EventsFolder = Remotes:WaitForChild("Events", 5)
                      local CursedChildPortal = EventsFolder and EventsFolder:FindFirstChild("CursedChildPortal")
                      local DungeonInsideSync = EventsFolder and EventsFolder:FindFirstChild("DungeonInsideSync")
                      local actionTriggered = false
                      if _G.AutoDungeonCreateEnabled and CursedChildPortal then
                          CursedChildPortal:FireServer("Create")
                          task.wait(0.5)
                          actionTriggered = true
                      end
                      if _G.AutoDungeonVoteEnabled and DungeonInsideSync then
                          DungeonInsideSync:FireServer("Vote", _G.DungeonDifficulty)
                          task.wait(0.5)
                          actionTriggered = true
                      end
                      if _G.AutoDungeonStartEnabled and CursedChildPortal then
                          CursedChildPortal:FireServer("Start")
                          actionTriggered = true
                      end
                      if actionTriggered then
                          lastPortalTime = os.clock()
                      end
                  end)
              end
          end
      end
  end)
  
  
  
  
  local function resetPityState(initialProgress)
      PityState.LastProgress = initialProgress
      PityState.TargetPhase = false
      PityState.LastSummonAt = 0
      PityState.LastPortalAt = 0
      PityState.LastBossSeenAt = 0
      PityState.CurrentBossDisplay = nil
      PityState.TrackedBoss = nil
      PityState.ScanIndex = 1
      PityState.LastStatusKey = nil
      PityCurrentBossDisplay = nil
  end
  
  local function readPityProgress()
      local playerGui = Player:FindFirstChild("PlayerGui")
      local bossGui = playerGui and playerGui:FindFirstChild("Boss")
      local frame = bossGui and bossGui:FindFirstChild("Frame")
      local pityObject = frame and frame:FindFirstChild("Pity")
      if not pityObject then return nil, nil, nil end
  
      local texts = {}
      local function addText(instance)
          pcall(function()
              if type(instance.Text) == "string" and instance.Text ~= "" then table.insert(texts, instance.Text) end
          end)
          pcall(function()
              if type(instance.Value) == "string" and instance.Value ~= "" then table.insert(texts, instance.Value) end
          end)
      end
  
      addText(pityObject)
      for _, descendant in ipairs(pityObject:GetDescendants()) do addText(descendant) end
  
      for _, text in ipairs(texts) do
          local current, maximum = string.match(text, "[Pp][Ii][Tt][Yy]%s*:%s*(%d+)%s*/%s*(%d+)")
          if not current then current, maximum = string.match(text, "(%d+)%s*/%s*(%d+)") end
          if current and maximum then return tonumber(current), tonumber(maximum), text end
      end
      return nil, nil, table.concat(texts, " | ")
  end
  
  local function pityPortalIsAllowed(portalId, portals)
      if not portalId then return false end
      for _, allowedPortal in ipairs(portals) do
          if portalId == allowedPortal then return true end
      end
      return false
  end
  
  local function getRecentPityAnnouncementPortal(bossInfo, portals)
      if not bossInfo or not _G.LastDetectedBossPortal then return nil end
      if os.clock() - (_G.LastDetectedBossPortalTime or 0) > 20 then return nil end
      if not pityPortalIsAllowed(_G.LastDetectedBossPortal, portals) then return nil end
      if not announcementMatchesBoss(_G.LastBossAnnouncementText, bossInfo) then return nil end
      return _G.LastDetectedBossPortal
  end
  
  local function resolvePityBossPortal(bossInfo, bossModel, indicator)
      local portals = bossInfo.Portals or {bossInfo.Portal}
      local announcementPortal = getRecentPityAnnouncementPortal(bossInfo, portals)
      if announcementPortal then return announcementPortal, true end
      if #portals == 1 then return portals[1], true end
  
      if bossModel and bossModel:FindFirstChild("HumanoidRootPart") then
          local detectedPortal = getPortalFromPosition(bossModel.HumanoidRootPart.Position)
          if pityPortalIsAllowed(detectedPortal, portals) then return detectedPortal, true end
      end
  
  
      if PityState.ScanIndex < 1 or PityState.ScanIndex > #portals then PityState.ScanIndex = 1 end
      return portals[PityState.ScanIndex], false
  end
  
  local function teleportPityPortal(portalId)
      if not portalId or os.clock() - (PityState.LastPortalAt or 0) < 2 then return end
      local remotes = ReplicatedStorage:FindFirstChild("Remotes")
      local teleportRemote = remotes and remotes:FindFirstChild("TeleportToPortal")
      if teleportRemote then
          teleportRemote:FireServer(portalId)
          CurrentSelectedPortal = portalId
          PityState.LastPortalAt = os.clock()
      end
  end
  
  local PitySkillLastUsed = {Z = 0, X = 0, C = 0, V = 0, F = 0}
  
  local function attackPityBoss(bossModel, pityValue)
      if not bossModel or not bossModel:FindFirstChild("Humanoid") or not bossModel:FindFirstChild("HumanoidRootPart") then return end
      local humanoid = bossModel.Humanoid
      if humanoid.Health <= 0 then return end
  
      PityState.LastBossSeenAt = os.clock()
      if PityState.TrackedBoss ~= bossModel then
          PityState.TrackedBoss = bossModel
          humanoid.Died:Connect(function()
              if PityState.TrackedBoss == bossModel then
                  PityState.LastBossSeenAt = os.clock()
                  PityState.TrackedBoss = nil
              end
          end)
      end
  
      if _G.InstaKillEnabled and humanoid.Health <= humanoid.MaxHealth * 0.9 then
          instaKill(bossModel)
          return
      end
  
      local farmCFrame
      if FarmPosition == "Above" then
          farmCFrame = bossModel.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
      else
          farmCFrame = bossModel.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5)
      end
      smartMoveCharacter(farmCFrame)
  
      if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
      local currentTool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
      if not currentTool then return end
  
      local remotes = ReplicatedStorage:WaitForChild("Remotes")
      local inputRemote = remotes:WaitForChild("Input")
      inputRemote:FireServer("Tool", currentTool, "M1")
  
      if _G.AutoSkillEnabled then
          local targetVector = bossModel.HumanoidRootPart.Position
          local now = os.clock()
          for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
              if _G.SelectedSkills[skill] and now - (PitySkillLastUsed[skill] or 0) >= 2 then
                  inputRemote:FireServer("Tool", currentTool, skill, targetVector)
                  PitySkillLastUsed[skill] = now
                  task.wait(0.08)
              end
          end
      end
  end
  
  local function summonPityBoss(displayName, bossInfo)
      local remotes = ReplicatedStorage:WaitForChild("Remotes")
      local currentPortal = getCurrentIslandPortalId()
      if currentPortal ~= bossInfo.Portal then
          teleportPityPortal(bossInfo.Portal)
          return false
      end
  
      local npcs = workspace:FindFirstChild("NPCs")
      local summonNPC = npcs and npcs:FindFirstChild(bossInfo.NPCName)
      if not summonNPC then
          teleportPityPortal(bossInfo.Portal)
          return false
      end
  
      if bossInfo.NPCName == "Sacrifice Table" then
          local tableCFrame = CFrame.new(-2846.15283, 13.2565403, 4210.13281, 0.893080592, 0, -0.449896663, 0, 1, 0, 0.449896663, 0, 0.893080592)
          smartMoveCharacter(tableCFrame * CFrame.new(0, 0, 4))
      elseif summonNPC:FindFirstChild("HumanoidRootPart") then
          smartMoveCharacter(summonNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
      elseif summonNPC:IsA("Model") then
          smartMoveCharacter(summonNPC:GetPivot() * CFrame.new(0, 0, 4))
      end
  
      task.wait(0.35)
      if not AutoPityToggle or PityCurrentBossDisplay ~= displayName then return false end
  
      PityState.LastSummonAt = os.clock()
      PityState.CurrentBossDisplay = displayName
      PityState.TrackedBoss = nil
      PityState.ScanIndex = 1
      local inputFunction = remotes:WaitForChild("Functions"):WaitForChild("Input")
      inputFunction:InvokeServer("SpawnBoss", summonNPC, bossInfo.BossName)
      Fluent:Notify({Title = "Auto Pity", Content = "Summoned " .. displayName .. ".", Duration = 3})
      return true
  end
  
  local function finishPityAutomation(message)
      Fluent:Notify({Title = "Auto Pity Complete", Content = message, Duration = 6})
      if PityToggleUI then PityToggleUI:SetValue(false) else AutoPityToggle = false end
  end
  
  Tabs.Pity:AddSection("Pity Settings")
  Tabs.Pity:AddDropdown("PityFarmBossDropdown", {
      Title = "Select Boss",
      Values = PityFarmBossList,
      Default = SelectedPityFarmBoss,
      Callback = function(Value)
          SelectedPityFarmBoss = Value
          if AutoPityToggle then resetPityState(select(1, readPityProgress())) end
      end
  })
  
  Tabs.Pity:AddDropdown("PityTargetBossDropdown", {
      Title = "Select Pity",
      Values = PityTargetBossList,
      Default = SelectedPityTargetBoss,
      Callback = function(Value)
          SelectedPityTargetBoss = Value
          if AutoPityToggle then resetPityState(select(1, readPityProgress())) end
      end
  })
  
  PityToggleUI = Tabs.Pity:AddToggle("AutoPityToggle", {
      Title = "Auto Pity",
      Default = false,
      Callback = function(Value)
          AutoPityToggle = Value
          if Value then
              DisableOtherFarms("Pity")
              CurrentSelectedPortal = nil
              _G.LastDetectedBossPortal = nil
              _G.LastDetectedBossPortalTime = 0
              _G.LastBossAnnouncementText = ""
              local current = select(1, readPityProgress())
              resetPityState(current)
              Fluent:Notify({Title = "Auto Pity", Content = "Started at Pity: " .. tostring(current or "?") .. "/25.", Duration = 4})
          else
              PityCurrentBossDisplay = nil
              PityState.CurrentBossDisplay = nil
              PityState.TrackedBoss = nil
          end
      end
  })
  
  Tabs.Pity:AddButton({
      Title = "Read Current Pity",
      Callback = function()
          local current, maximum, rawText = readPityProgress()
          Fluent:Notify({
              Title = "Pity Status",
              Content = current and ("Pity: " .. current .. "/" .. maximum) or ("Pity text not found: " .. tostring(rawText or "nil")),
              Duration = 5
          })
      end
  })
  
  task.spawn(function()
      while task.wait(0.15) do
          if not AutoPityToggle then continue end
  
          local ok, err = pcall(function()
              if IsRerolling then return end
              local currentPity, maximumPity = readPityProgress()
              if currentPity == nil then
                  if os.clock() - (PityState.LastMissingGuiNotify or 0) >= 5 then
                      PityState.LastMissingGuiNotify = os.clock()
                      Fluent:Notify({Title = "Auto Pity", Content = "Waiting for PlayerGui.Boss.Frame.Pity...", Duration = 4})
                  end
                  return
              end
  
              maximumPity = maximumPity and maximumPity > 0 and maximumPity or 25
              local previousPity = PityState.LastProgress
              if currentPity >= maximumPity
                  or (PityState.TargetPhase and previousPity and currentPity < previousPity) then
                  finishPityAutomation("Pity boss completed. Current Pity: " .. currentPity .. "/" .. maximumPity .. ".")
                  return
              end
  
              if previousPity ~= currentPity then
                  PityState.LastProgress = currentPity
                  PityState.LastSummonAt = 0
                  PityState.LastBossSeenAt = 0
                  PityState.CurrentBossDisplay = nil
                  PityState.TrackedBoss = nil
                  PityState.ScanIndex = 1
                  
                  
                  _G.LastDetectedBossPortal = nil
                  _G.LastDetectedBossPortalTime = 0
                  _G.LastBossAnnouncementText = ""
              end
  
              local targetPhase = currentPity >= math.max(0, maximumPity - 1)
              if targetPhase then PityState.TargetPhase = true end
              local displayName = targetPhase and SelectedPityTargetBoss or SelectedPityFarmBoss
              local bossInfo = summonbossdata[displayName]
              if not bossInfo then
                  finishPityAutomation("Boss data was not found for " .. tostring(displayName) .. ".")
                  return
              end
  
              PityCurrentBossDisplay = displayName
              local statusKey = tostring(currentPity) .. "|" .. displayName
              if PityState.LastStatusKey ~= statusKey then
                  PityState.LastStatusKey = statusKey
                  local phaseText = targetPhase and "PITY KILL 25" or "BUILD PITY"
                  Fluent:Notify({Title = "Auto Pity - " .. phaseText, Content = "Pity: " .. currentPity .. "/" .. maximumPity .. " | Boss: " .. displayName, Duration = 4})
              end
  
              local bossModel = getClosestMonster(bossInfo.Mobname)
              local indicator = findBossIndicator(bossInfo)
              local currentPortal = getCurrentIslandPortalId()
  
              if bossModel or indicator then
                  local actualPortal, portalConfirmed = resolvePityBossPortal(bossInfo, bossModel, indicator)
                  if not portalConfirmed then
                      if currentPortal == actualPortal and CurrentSelectedPortal == actualPortal
                          and os.clock() - (PityState.LastPortalAt or 0) >= 3 then
                          local portals = bossInfo.Portals or {bossInfo.Portal}
                          PityState.ScanIndex = PityState.ScanIndex % #portals + 1
                          actualPortal = portals[PityState.ScanIndex]
                      end
                      teleportPityPortal(actualPortal)
                      return
                  end
  
                  if currentPortal ~= actualPortal then
                      teleportPityPortal(actualPortal)
                      return
                  end
  
                  if bossModel then attackPityBoss(bossModel, currentPity) end
                  return
              end
  
              local portals = bossInfo.Portals or {bossInfo.Portal}
              local announcedPortal = getRecentPityAnnouncementPortal(bossInfo, portals)
              if announcedPortal then
                  if currentPortal ~= announcedPortal then teleportPityPortal(announcedPortal) end
                  return
              end
  
              if PityState.LastBossSeenAt > 0 and os.clock() - PityState.LastBossSeenAt < 3 then return end
              if PityState.CurrentBossDisplay == displayName and os.clock() - (PityState.LastSummonAt or 0) < 8 then return end
  
              summonPityBoss(displayName, bossInfo)
          end)
  
          if not ok and os.clock() - (PityState.LastErrorNotify or 0) >= 5 then
              PityState.LastErrorNotify = os.clock()
              Fluent:Notify({Title = "Auto Pity Error", Content = tostring(err), Duration = 5})
          end
      end
  end)
  
  
  
  
  
  
  
  
  local HttpService = game:GetService("HttpService")
  local FireForceTierRoman = {"I", "II", "III", "IV"}
  
  local AllQuestState = {
      Key = nil,
      LastPortalAt = 0,
      LastSummonAt = 0,
      LastAmbushAt = 0,
      LastInteractionAt = 0,
      LastStatusAt = 0,
      LastStatusKey = nil,
      LastClaimAt = 0,
      PortalScanIndex = 1,
      RescuePhase = "Search",
      RescueTarget = nil,
      RescueProgress = nil,
      RescueCarryAt = 0,
      LastRescueScanAt = 0,
      LastDeliverAt = 0,
      LastRuinStreamAt = 0,
      RuinStreamIndex = 0,
      RuinSpawnArrivalAt = 0,
      RuinFallbackStartedAt = 0,
      AmbusherRuinUntil = 0,
      RescueEncounterStarted = false,
      RescueAmbusherSeen = false,
      RescueEncounterAt = 0
  }
  
  local function resetAllQuestState(key)
      AllQuestState.Key = key
      AllQuestState.LastPortalAt = 0
      AllQuestState.LastSummonAt = 0
      AllQuestState.LastAmbushAt = 0
      AllQuestState.LastInteractionAt = 0
      AllQuestState.LastStatusAt = 0
      AllQuestState.LastStatusKey = nil
      AllQuestState.LastClaimAt = 0
      AllQuestState.PortalScanIndex = 1
      AllQuestState.RescuePhase = "Search"
      AllQuestState.RescueTarget = nil
      AllQuestState.RescueProgress = nil
      AllQuestState.RescueCarryAt = 0
      AllQuestState.LastRescueScanAt = 0
      AllQuestState.LastDeliverAt = 0
      AllQuestState.LastRuinStreamAt = 0
      AllQuestState.RuinStreamIndex = 0
      AllQuestState.RuinSpawnArrivalAt = 0
      AllQuestState.RuinFallbackStartedAt = 0
      AllQuestState.AmbusherRuinUntil = 0
      AllQuestState.RescueEncounterStarted = false
      AllQuestState.RescueAmbusherSeen = false
      AllQuestState.RescueEncounterAt = 0
      _G.LastDetectedBossPortal = nil
      _G.LastDetectedBossPortalTime = 0
      _G.LastBossAnnouncementText = ""
      CurrentSelectedPortal = nil
  end
  
  SetAllQuestEnabled = function(key, enabled)
      if enabled and key then
          ActiveFireForceQuestKey = key
          AutoAllQuestToggle = true
          resetAllQuestState(key)
          for otherKey, toggle in pairs(FireForceQuestToggleUIs) do
              if otherKey ~= key and toggle and toggle.Value then toggle:SetValue(false) end
          end
      else
          ActiveFireForceQuestKey = nil
          AutoAllQuestToggle = false
          resetAllQuestState(nil)
          for _, toggle in pairs(FireForceQuestToggleUIs) do
              if toggle and toggle.Value then toggle:SetValue(false) end
          end
      end
  end
  
  local function findFireForceQuestModule()
      local modules = ReplicatedStorage:FindFirstChild("Modules")
      local configurations = modules and modules:FindFirstChild("Configurations")
      return configurations and configurations:FindFirstChild("FireForceQuestData")
  end
  
  local function readFireForceQuestState(key)
      local definition = FireForceQuestDefinitions[key]
      if not definition then
          return {Available = false, Tier = 1, Progress = 0, Goal = 0, Completed = false}
      end
  
      local data = Player:FindFirstChild("Data")
      local stateObject = data and data:FindFirstChild("FireForceQuestState")
      if not stateObject or not stateObject:IsA("StringValue") then
          return {Available = false, Tier = 1, Progress = 0, Goal = definition.Amounts[1], Completed = false}
      end
  
      local ok, decoded = pcall(function()
          return HttpService:JSONDecode(stateObject.Value or "{}")
      end)
      if not ok or type(decoded) ~= "table" then decoded = {} end
  
      local encodedState = decoded[definition.Code]
      local tier = 1
      local progress = 0
      if type(encodedState) == "table" then
          tier = tonumber(encodedState[1]) or 1
          progress = tonumber(encodedState[2]) or 0
      end
      tier = math.clamp(math.floor(tier), 1, #FireForceTierRoman)
      progress = math.max(0, math.floor(progress))
      local goal = definition.Amounts[tier]
  
      return {
          Available = ok,
          Tier = tier,
          Progress = progress,
          Goal = goal,
          Completed = progress >= goal,
          Raw = encodedState,
          StateObject = stateObject
      }
  end
  
  local function getFireForceInputFunction()
      if _G.InputFunction then return _G.InputFunction end
      local remotes = ReplicatedStorage:FindFirstChild("Remotes")
      local functions = remotes and remotes:FindFirstChild("Functions")
      return functions and functions:FindFirstChild("Input")
  end
  
  local function claimFireForceQuest(key)
      if os.clock() - (AllQuestState.LastClaimAt or 0) < 1.5 then return false end
      local inputFunction = getFireForceInputFunction()
      if not inputFunction then return false end
      AllQuestState.LastClaimAt = os.clock()
      local ok, result = pcall(function()
          return inputFunction:InvokeServer("FireForce", "Claim", key)
      end)
      if ok and result == true then
          Fluent:Notify({Title = "All Quest", Content = "Claimed " .. FireForceQuestDefinitions[key].Name .. ". Tier will update automatically.", Duration = 4})
      end
      return ok and result == true
  end
  
  local function requestFireForceAmbush()
      if os.clock() - (AllQuestState.LastAmbushAt or 0) < 3 then return false end
      if getClosestMonster("Infernal Ambusher") then return false end
      local info = bossdata["Infernal Ambusher"]
      if info and _G.LastDetectedBossPortal
          and os.clock() - (_G.LastDetectedBossPortalTime or 0) <= 20
          and announcementMatchesBoss(_G.LastBossAnnouncementText, info) then
          return false
      end
      local inputFunction = getFireForceInputFunction()
      if not inputFunction then return false end
      AllQuestState.LastAmbushAt = os.clock()
      return pcall(function()
          inputFunction:InvokeServer("FireForce", "Ambush")
      end)
  end
  
  local function teleportAllQuestPortal(portalId)
      if not portalId or os.clock() - (AllQuestState.LastPortalAt or 0) < 1.8 then return false end
      local remotes = ReplicatedStorage:FindFirstChild("Remotes")
      local remote = remotes and remotes:FindFirstChild("TeleportToPortal")
      if not remote then return false end
      remote:FireServer(portalId)
      CurrentSelectedPortal = portalId
      AllQuestState.LastPortalAt = os.clock()
      return true
  end
  
  local AllQuestSkillLastUsed = {Z = 0, X = 0, C = 0, V = 0, F = 0}
  local function attackAllQuestEnemy(enemy)
      if not AutoAllQuestToggle or not enemy or not enemy.Parent then return end
      local humanoid = enemy:FindFirstChildWhichIsA("Humanoid", true)
      local rootPart = enemy:FindFirstChild("HumanoidRootPart", true)
          or enemy:FindFirstChild("RootPart", true)
      if not humanoid or humanoid.Health <= 0 or not rootPart then return end
      if _G.InstaKillEnabled and humanoid.Health <= humanoid.MaxHealth * 0.9 then instaKill(enemy) return end
  
      local farmCFrame = FarmPosition == "Above" and rootPart.CFrame * CFrame.new(0, 5, 0)
          or rootPart.CFrame * CFrame.new(0, 0, 3.5)
      smartMoveCharacter(farmCFrame)
      if not AutoAllQuestToggle then return end
      if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
      local currentTool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
      if not currentTool and _G.SelectedWeaponGroup then
          EquipWeapon(_G.SelectedWeaponGroup)
          currentTool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
      end
      if not currentTool then return end
      local remotes = ReplicatedStorage:FindFirstChild("Remotes")
      local input = remotes and remotes:FindFirstChild("Input")
      if not input then return end
      input:FireServer("Tool", currentTool, "M1")
      if _G.AutoSkillEnabled then
          local now = os.clock()
          for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
              if _G.SelectedSkills[skill] and now - (AllQuestSkillLastUsed[skill] or 0) >= 2 then
                  input:FireServer("Tool", currentTool, skill, rootPart.Position)
                  AllQuestSkillLastUsed[skill] = now
                  task.wait(0.08)
              end
          end
      end
  end
  
  local function runBattleExperienceQuest()
      local info = mobdata[SelectedFireForceFarmMonster]
      if not info then return end
      local target = getClosestMonster(info.Mobname)
      local currentPortal = getCurrentIslandPortalId()
      local portalConfirmed = currentPortal == info.Portal
      if target and target:FindFirstChild("HumanoidRootPart") then
          portalConfirmed = portalConfirmed or getPortalFromPosition(target.HumanoidRootPart.Position) == info.Portal
      end
      if not portalConfirmed then teleportAllQuestPortal(info.Portal) return end
      if target then attackAllQuestEnemy(target) end
  end
  
  local function getRecentAllQuestBossPortal(info, portals)
      if not _G.LastDetectedBossPortal or os.clock() - (_G.LastDetectedBossPortalTime or 0) > 20 then return nil end
      if not announcementMatchesBoss(_G.LastBossAnnouncementText, info) then return nil end
      for _, portal in ipairs(portals) do
          if portal == _G.LastDetectedBossPortal then return portal end
      end
      return nil
  end
  
  AllQuestState.StreamRuinCityForAmbusher = function()
      if os.clock() - (AllQuestState.LastRuinStreamAt or 0) < 0.8 then return end
      AllQuestState.LastRuinStreamAt = os.clock()
  
      local fallbackCFrame = CFrame.new(
          -2645.34595, 24.0435047, 3537.48999,
          1, 0, 0,
          0, 1, 0,
          0, 0, 1
      )
      local spawnEntries = {}
      local extra = workspace:FindFirstChild("Extra")
      local fireForceQuest = extra and extra:FindFirstChild("FireForceQuest")
      local investigatePoints = fireForceQuest and fireForceQuest:FindFirstChild("InvestigatePoints")
      if investigatePoints then
          for _, pointName in ipairs({"BossSpawn1", "BossSpawn2", "BossSpawn3", "BossSpawn5", "BossSpawn6"}) do
              local spawnPoint = investigatePoints:FindFirstChild(pointName, true)
              if spawnPoint then
                  local pointCFrame = spawnPoint:IsA("BasePart") and spawnPoint.CFrame
                      or (spawnPoint:IsA("Attachment") and spawnPoint.WorldCFrame)
                      or (spawnPoint:IsA("Model") and spawnPoint:GetPivot())
                  local position = pointCFrame and pointCFrame.Position or getInstancePosition(spawnPoint)
                  if position then
                      table.insert(spawnEntries, {
                          Instance = spawnPoint,
                          CFrame = pointCFrame or CFrame.new(position)
                      })
                  end
              end
          end
      end
      if #spawnEntries == 0 then
          table.insert(spawnEntries, {Instance = nil, CFrame = fallbackCFrame})
      end
  
      if AllQuestState.RuinStreamIndex < 1 or AllQuestState.RuinStreamIndex > #spawnEntries then
          AllQuestState.RuinStreamIndex = 1
      end
      local targetEntry = spawnEntries[AllQuestState.RuinStreamIndex]
      local targetCFrame = targetEntry.CFrame
      local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
      if not root then return end
  
      local offset = targetCFrame.Position - root.Position
      local distance = offset.Magnitude
      local approachCFrame = targetCFrame * CFrame.new(0, 8, 0)
      if distance > 220 then
          AllQuestState.RuinSpawnArrivalAt = 0
          local stepDistance = math.min(250, math.max(distance - 180, 1))
          local nextPosition = root.Position + offset.Unit * stepDistance
          approachCFrame = CFrame.new(nextPosition, nextPosition + offset.Unit)
      elseif AllQuestState.RuinSpawnArrivalAt == 0 then
          AllQuestState.RuinSpawnArrivalAt = os.clock()
      end
  
      local targetPosition = approachCFrame.Position
      pcall(function()
          Player:RequestStreamAroundAsync(targetPosition, 2)
      end)
  
      -- Infernal Ambusher is created around a numbered BossSpawn investigate
      -- point. Visiting each point forces the matching enemy model to replicate.
      if AutoAllQuestToggle and not getClosestMonster("Infernal Ambusher") then
          smartMoveCharacter(approachCFrame)
          if distance <= 220 and targetEntry.Instance then
              local investigatePrompt = targetEntry.Instance:FindFirstChildWhichIsA("ProximityPrompt", true)
              if investigatePrompt then
                  local promptText = string.lower(tostring(investigatePrompt.ActionText) .. " " .. tostring(investigatePrompt.ObjectText))
                  if string.find(promptText, "investigate", 1, true) then
                      triggerProximityPrompt(investigatePrompt)
                  end
              end
          end
          if distance <= 220 and os.clock() - (AllQuestState.RuinSpawnArrivalAt or 0) >= 3 then
              AllQuestState.RuinStreamIndex = AllQuestState.RuinStreamIndex % #spawnEntries + 1
              AllQuestState.RuinSpawnArrivalAt = 0
          end
      end
  end
  
  local function summonAllQuestBoss(displayName, info)
      if not info or os.clock() - (AllQuestState.LastSummonAt or 0) < 2.5 then return end
      if getCurrentIslandPortalId() ~= info.Portal then teleportAllQuestPortal(info.Portal) return end
      local npcs = workspace:FindFirstChild("NPCs")
      local npc = npcs and npcs:FindFirstChild(info.NPCName)
      if not npc then teleportAllQuestPortal(info.Portal) return end
      if info.NPCName == "Sacrifice Table" then
          smartMoveCharacter(CFrame.new(-2846.15283, 13.2565403, 4210.13281) * CFrame.new(0, 0, 4))
      elseif npc:IsA("Model") then
          smartMoveCharacter(npc:GetPivot() * CFrame.new(0, 0, 4))
      elseif npc:IsA("BasePart") then
          smartMoveCharacter(npc.CFrame * CFrame.new(0, 0, 4))
      end
      if not AutoAllQuestToggle then return end
      local remotes = ReplicatedStorage:FindFirstChild("Remotes")
      local functions = remotes and remotes:FindFirstChild("Functions")
      local input = functions and functions:FindFirstChild("Input")
      if input then
          AllQuestState.LastSummonAt = os.clock()
          _G.LastDetectedBossPortal = nil
          _G.LastDetectedBossPortalTime = 0
          _G.LastBossAnnouncementText = ""
          input:InvokeServer("SpawnBoss", npc, info.BossName)
          Fluent:Notify({Title = "All Quest", Content = "Summoned " .. displayName .. ".", Duration = 3})
      end
  end
  
  local function runAllQuestBoss(displayName, canSummon)
      local summonInfo = summonbossdata[displayName]
      local bossInfo = bossdata[displayName] or summonInfo
      if not bossInfo then return end
      local mobName = bossInfo.Mobname or (summonInfo and summonInfo.Mobname)
      local bossModel = mobName and getClosestMonster(mobName)
      local portals = bossInfo.Portals or (summonInfo and summonInfo.Portals) or {(summonInfo and summonInfo.Portal) or bossInfo.Portal}
      local currentPortal = getCurrentIslandPortalId()
      local actualPortal = getRecentAllQuestBossPortal(bossInfo, portals)
      if displayName == "Infernal Ambusher" then
          if actualPortal == "RuinCity" then
              AllQuestState.AmbusherRuinUntil = os.clock() + 90
          elseif os.clock() < (AllQuestState.AmbusherRuinUntil or 0) then
              actualPortal = "RuinCity"
          end
      end
      local bossRoot = bossModel and (bossModel:FindFirstChild("HumanoidRootPart", true)
          or bossModel:FindFirstChild("RootPart", true))
      if not actualPortal and bossRoot then
          local detected = getPortalFromPosition(bossRoot.Position)
          for _, portal in ipairs(portals) do if detected == portal then actualPortal = detected break end end
  
      end
      if not actualPortal and #portals == 1 then actualPortal = portals[1] end
  
      if bossModel then
          -- A replicated live boss is a stronger signal than portal detection. Attack it
          -- immediately instead of leaving it behind while cycling through portals.
          if displayName == "Infernal Ambusher" then
              AllQuestState.PortalScanIndex = 1
              attackAllQuestEnemy(bossModel)
              return
          end
          if not actualPortal then
              if AllQuestState.PortalScanIndex < 1 or AllQuestState.PortalScanIndex > #portals then
                  AllQuestState.PortalScanIndex = 1
              end
              local scanPortal = portals[AllQuestState.PortalScanIndex]
              if currentPortal ~= scanPortal then
                  teleportAllQuestPortal(scanPortal)
              elseif os.clock() - (AllQuestState.LastPortalAt or 0) >= 3 then
                  AllQuestState.PortalScanIndex = AllQuestState.PortalScanIndex % #portals + 1
                  teleportAllQuestPortal(portals[AllQuestState.PortalScanIndex])
              end
              return
          end
          if currentPortal ~= actualPortal then
              teleportAllQuestPortal(actualPortal)
              return
          end
          AllQuestState.PortalScanIndex = 1
          attackAllQuestEnemy(bossModel)
          return
      end
  
      if displayName == "Infernal Ambusher" and actualPortal == "RuinCity" then
          -- Current-island detection is unreliable while Ruin City is partially
          -- streamed. Trust the announcement/last teleport instead of returning
          -- to the portal on every loop.
          if currentPortal ~= "RuinCity" and CurrentSelectedPortal ~= "RuinCity" then
              teleportAllQuestPortal("RuinCity")
              return
          end
          AllQuestState.StreamRuinCityForAmbusher()
          return
      end
      if actualPortal and currentPortal ~= actualPortal then teleportAllQuestPortal(actualPortal) return end
      if canSummon and summonInfo then summonAllQuestBoss(displayName, summonInfo) return end
  
      if AllQuestState.PortalScanIndex < 1 or AllQuestState.PortalScanIndex > #portals then AllQuestState.PortalScanIndex = 1 end
      local scanPortal = portals[AllQuestState.PortalScanIndex]
      if displayName == "Infernal Ambusher"
          and scanPortal == "RuinCity"
          and (currentPortal == "RuinCity" or CurrentSelectedPortal == "RuinCity") then
          if AllQuestState.RuinFallbackStartedAt == 0 then
              AllQuestState.RuinFallbackStartedAt = os.clock()
              AllQuestState.RuinStreamIndex = 1
              AllQuestState.RuinSpawnArrivalAt = 0
          end
          if os.clock() - AllQuestState.RuinFallbackStartedAt < 45 then
              AllQuestState.StreamRuinCityForAmbusher()
              return
          end
          AllQuestState.RuinFallbackStartedAt = 0
      elseif scanPortal ~= "RuinCity" then
          AllQuestState.RuinFallbackStartedAt = 0
      end
      if currentPortal ~= scanPortal then
          teleportAllQuestPortal(scanPortal)
      elseif os.clock() - (AllQuestState.LastPortalAt or 0) >= 3 then
          AllQuestState.PortalScanIndex = AllQuestState.PortalScanIndex % #portals + 1
          teleportAllQuestPortal(portals[AllQuestState.PortalScanIndex])
      end
  end
  
  local function getInteractionContext(instance)
      if not instance then return "" end
      local context = tostring(instance.Name)
      if instance:IsA("ProximityPrompt") then
          context = context .. " " .. tostring(instance.ActionText) .. " " .. tostring(instance.ObjectText)
      end
      local current = instance.Parent
      for _ = 1, 6 do
          if not current then break end
          context = context .. " " .. tostring(current.Name)
          current = current.Parent
      end
      return string.lower(context)
  end
  
  local function contextContainsAny(context, keywords)
      for _, keyword in ipairs(keywords) do
          if context:find(keyword, 1, true) then return true end
      end
      return false
  end
  
  local function interactionPromptMatches(prompt, objectiveType)
      local context = getInteractionContext(prompt)
      local keywords = objectiveType == "Cat"
          and {"stray cat", "cat", "neko", "collect"}
          or {"hostage", "rescue", "civilian", "captive", "prisoner", "carry", "pick up", "pickup"}
      return contextContainsAny(context, keywords)
  end
  
  local function findClosestFireForceInteraction(objectiveType, includeDisabled)
      local characterRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
      if not characterRoot then return nil end
      local closest, shortest = nil, math.huge
      for _, descendant in ipairs(workspace:GetDescendants()) do
          if descendant:IsA("ProximityPrompt")
              and (includeDisabled or descendant.Enabled)
              and interactionPromptMatches(descendant, objectiveType) then
              local position = getInstancePosition(descendant.Parent)
              if position then
                  local distance = (characterRoot.Position - position).Magnitude
                  if distance < shortest then closest, shortest = descendant, distance end
              end
          end
      end
      return closest
  end
  
  local function runFireForceCatInteraction()
      local targetPortal = "7thComanpyIsland"
      if getCurrentIslandPortalId() ~= targetPortal then teleportAllQuestPortal(targetPortal) return end
      local prompt = findClosestFireForceInteraction("Cat", false)
      if not prompt then return end
      local position = getInstancePosition(prompt.Parent)
      if position then smartMoveCharacter(CFrame.new(position + Vector3.new(0, 0, 3))) end
      if AutoAllQuestToggle and os.clock() - (AllQuestState.LastInteractionAt or 0) >= 0.8 then
          AllQuestState.LastInteractionAt = os.clock()
          triggerProximityPrompt(prompt)
      end
  end
  
  local function hostageObjectMatches(instance)
      local context = getInteractionContext(instance)
      if contextContainsAny(context, {"deliver", "return hostage", "drop off", "dropoff"}) then return false end
      return contextContainsAny(context, {"hostage", "rescue", "civilian", "captive", "prisoner"})
  end
  
  local function positionIsInsideRuinCity(position)
      if not position then return false end
      local npcs = workspace:FindFirstChild("NPCs")
      if not npcs then return false end
  
      local shortestDistance = math.huge
      local foundLandmark = false
      for _, npcName in ipairs({"Sacrifice Table", "PauPau Whisperer"}) do
          local landmark = npcs:FindFirstChild(npcName)
          local landmarkPosition = landmark and getInstancePosition(landmark)
          if landmarkPosition then
              foundLandmark = true
              shortestDistance = math.min(shortestDistance, (position - landmarkPosition).Magnitude)
          end
      end
      return foundLandmark and shortestDistance <= 1800
  end
  
  local function findClosestHostageTarget()
      if AllQuestState.RescueTarget and AllQuestState.RescueTarget.Parent then
          local cachedPosition = getInstancePosition(AllQuestState.RescueTarget:IsA("ProximityPrompt")
              and AllQuestState.RescueTarget.Parent or AllQuestState.RescueTarget)
          if positionIsInsideRuinCity(cachedPosition) then
              return AllQuestState.RescueTarget
          end
          AllQuestState.RescueTarget = nil
      end
      if os.clock() - (AllQuestState.LastRescueScanAt or 0) < 0.65 then return nil end
      AllQuestState.LastRescueScanAt = os.clock()
  
      local characterRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
      if not characterRoot then return nil end
      local closest, shortest = nil, math.huge
  
      for _, descendant in ipairs(workspace:GetDescendants()) do
          if descendant:IsA("ProximityPrompt") and hostageObjectMatches(descendant) then
              local position = getInstancePosition(descendant.Parent)
              if position and positionIsInsideRuinCity(position) then
                  local distance = (characterRoot.Position - position).Magnitude
                  if distance < shortest then closest, shortest = descendant, distance end
              end
          end
      end
  
      if not closest then
          for _, descendant in ipairs(workspace:GetDescendants()) do
              if (descendant:IsA("Model") or descendant:IsA("BasePart")) and hostageObjectMatches(descendant) then
                  local position = getInstancePosition(descendant)
                  if position and positionIsInsideRuinCity(position) then
                      local distance = (characterRoot.Position - position).Magnitude
                      if distance < shortest then closest, shortest = descendant, distance end
                  end
              end
          end
      end
  
      AllQuestState.RescueTarget = closest
      return closest
  end
  local function getTargetPrompt(target)
      if not target then return nil end
      if target:IsA("ProximityPrompt") and target.KeyboardKeyCode == Enum.KeyCode.E then
          return target
      end
      for _, descendant in ipairs(target:GetDescendants()) do
          if descendant:IsA("ProximityPrompt") and descendant.KeyboardKeyCode == Enum.KeyCode.E then
              return descendant
          end
      end
      if target:IsA("ProximityPrompt") then return target end
      return target:FindFirstChildWhichIsA("ProximityPrompt", true)
  end
  local function getClosestEnemyToPosition(position, maximumDistance)
      local enemies = workspace:FindFirstChild("Enemies")
      if not enemies or not position then return nil end
      local closest, shortest = nil, maximumDistance or math.huge
      for _, enemy in ipairs(enemies:GetChildren()) do
          local humanoid = enemy:FindFirstChild("Humanoid")
          local rootPart = enemy:FindFirstChild("HumanoidRootPart")
          if humanoid and humanoid.Health > 0 and rootPart and positionIsInsideRuinCity(rootPart.Position) then
              local distance = (rootPart.Position - position).Magnitude
              if distance < shortest then closest, shortest = enemy, distance end
          end
      end
      return closest
  end
  
  local function getClosestAliveEnemy()
      local characterRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
      return characterRoot and getClosestEnemyToPosition(characterRoot.Position, math.huge) or nil
  end
  
  local function markerValueIsActive(instance)
      if instance:IsA("BoolValue") then return instance.Value == true end
      if instance:IsA("ObjectValue") then return instance.Value ~= nil end
      if instance:IsA("StringValue") then return instance.Value ~= "" end
      if instance:IsA("IntValue") or instance:IsA("NumberValue") then return instance.Value > 0 end
      return instance:IsA("Model") or instance:IsA("BasePart") or instance:IsA("Weld") or instance:IsA("WeldConstraint")
  end
  
  local function attributesShowCarriedHostage(instance)
      if not instance then return false end
      for name, value in pairs(instance:GetAttributes()) do
          local normalized = string.lower(tostring(name))
          if contextContainsAny(normalized, {"carryinghostage", "iscarryinghostage", "hashostage", "carriedhostage", "rescuedcivilian"})
              and value ~= false and value ~= nil and value ~= 0 and value ~= "" then
              return true
          end
      end
      return false
  end
  
  local function isCarryingHostage()
      local character = Player.Character
      local data = Player:FindFirstChild("Data")
      if attributesShowCarriedHostage(Player) or attributesShowCarriedHostage(character) or attributesShowCarriedHostage(data) then
          return true
      end
      if not character then return false end
      for _, descendant in ipairs(character:GetDescendants()) do
          local normalized = string.lower(descendant.Name)
          if contextContainsAny(normalized, {"hostage", "carryinghostage", "rescuedcivilian", "carriedcivilian"})
              and markerValueIsActive(descendant) then
              return true
          end
      end
      return false
  end
  
  local function findRescueReceiver()
      local npcs = workspace:FindFirstChild("NPCs")
      if not npcs then return nil, nil end
  
      local captain = npcs:FindFirstChild("Captain Burns")
      if not captain then return nil, nil end
  
      local fallback = nil
      for _, descendant in ipairs(captain:GetDescendants()) do
          if descendant:IsA("ProximityPrompt") then
              fallback = fallback or descendant
              if descendant.KeyboardKeyCode == Enum.KeyCode.F then
                  return captain, descendant
              end
          end
      end
      return captain, fallback
  end
  
  local function pressRescuePickupPrompt(prompt)
      if not prompt or not prompt.Enabled or prompt.KeyboardKeyCode ~= Enum.KeyCode.E then return false end
  
      local oldLineOfSight = prompt.RequiresLineOfSight
      local oldMaxDistance = prompt.MaxActivationDistance
      local holdDuration = math.max(tonumber(prompt.HoldDuration) or 0, 0)
      local success = pcall(function()
          prompt.RequiresLineOfSight = false
          prompt.MaxActivationDistance = math.max(oldMaxDistance, 50)
          prompt:InputHoldBegin()
          task.wait(holdDuration + 0.06)
          prompt:InputHoldEnd()
      end)
      pcall(function()
          prompt.RequiresLineOfSight = oldLineOfSight
          prompt.MaxActivationDistance = oldMaxDistance
      end)
  
      if not success and fireproximityprompt then
          success = pcall(function()
              fireproximityprompt(prompt, holdDuration, false)
          end)
      end
      return success
  end
  local function holdRescueDeliveryPrompt(prompt)
      if not prompt or not prompt.Enabled then return false end
  
      local oldLineOfSight = prompt.RequiresLineOfSight
      local oldMaxDistance = prompt.MaxActivationDistance
      local holdDuration = math.max(tonumber(prompt.HoldDuration) or 0, 0.35)
      local success = pcall(function()
          prompt.RequiresLineOfSight = false
          prompt.MaxActivationDistance = math.max(oldMaxDistance, 50)
          prompt:InputHoldBegin()
          task.wait(holdDuration + 0.12)
          prompt:InputHoldEnd()
      end)
      pcall(function()
          prompt.RequiresLineOfSight = oldLineOfSight
          prompt.MaxActivationDistance = oldMaxDistance
      end)
  
      if not success and fireproximityprompt then
          success = pcall(function()
              fireproximityprompt(prompt, holdDuration, false)
          end)
      end
      return success
  end
  
  local function deliverCarriedHostage()
      local receiver, prompt = findRescueReceiver()
      if not receiver then return false end
  
      local targetCFrame
      if receiver:IsA("Model") then targetCFrame = receiver:GetPivot() * CFrame.new(0, 0, 3)
      elseif receiver:IsA("BasePart") then targetCFrame = receiver.CFrame * CFrame.new(0, 0, 3) end
      if targetCFrame then smartMoveCharacter(targetCFrame) end
      if not AutoAllQuestToggle then return false end
  
      if prompt and prompt.Enabled and os.clock() - (AllQuestState.LastDeliverAt or 0) >= 1 then
          AllQuestState.LastDeliverAt = os.clock()
          holdRescueDeliveryPrompt(prompt)
      end
      return true
  end
  local RescuePortalLandmarks = {
      RuinCity = {"Sacrifice Table", "PauPau Whisperer"},
      ["7thComanpyIsland"] = {"Captain Burns"}
  }
  
  local function rescuePortalIsStrictlyConfirmed(portalId)
      local characterRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
      local npcs = workspace:FindFirstChild("NPCs")
      local landmarks = RescuePortalLandmarks[portalId]
      if not characterRoot or not npcs or not landmarks then return false end
  
      local shortestDistance = math.huge
      local landmarkFound = false
      for _, npcName in ipairs(landmarks) do
          local landmark = npcs:FindFirstChild(npcName)
          local position = landmark and getInstancePosition(landmark)
          if position then
              landmarkFound = true
              shortestDistance = math.min(shortestDistance, (characterRoot.Position - position).Magnitude)
          end
      end
  
      
      
      return landmarkFound and shortestDistance <= 1800
  end
  
  local function ensureRescuePortal(portalId)
      if rescuePortalIsStrictlyConfirmed(portalId) then
          CurrentSelectedPortal = portalId
          return true
      end
      teleportAllQuestPortal(portalId)
      return false
  end
  local function findAliveRescueAmbusher()
      local enemies = workspace:FindFirstChild("Enemies")
      if not enemies then return nil end
  
      local characterRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
      local closest, shortestDistance = nil, math.huge
      for _, enemy in ipairs(enemies:GetChildren()) do
          if enemy.Name == "Infernal Ambusher" then
              local humanoid = enemy:FindFirstChildOfClass("Humanoid")
              local rootPart = enemy:FindFirstChild("HumanoidRootPart")
              if humanoid and humanoid.Health > 0 and rootPart and positionIsInsideRuinCity(rootPart.Position) then
                  local distance = characterRoot and (characterRoot.Position - rootPart.Position).Magnitude or 0
                  if distance < shortestDistance then
                      shortestDistance = distance
                      closest = enemy
                  end
              end
          end
      end
      return closest
  end
  
  local function runFireForceRescueDuty(state)
      local rescuePortal = "RuinCity"
      local deliveryPortal = "7thComanpyIsland"
  
      if AllQuestState.RescueProgress == nil then
          AllQuestState.RescueProgress = state.Progress
      elseif state.Progress ~= AllQuestState.RescueProgress then
          AllQuestState.RescueProgress = state.Progress
          AllQuestState.RescuePhase = "Search"
          AllQuestState.RescueTarget = nil
          AllQuestState.RescueCarryAt = 0
          AllQuestState.RescueEncounterStarted = false
          AllQuestState.RescueAmbusherSeen = false
          AllQuestState.RescueEncounterAt = 0
      end
  
      local carryingHostage = isCarryingHostage()
      local infernalAmbusher = findAliveRescueAmbusher()
  
      
      
      if infernalAmbusher then
          AllQuestState.RescueEncounterStarted = true
          AllQuestState.RescueAmbusherSeen = true
          AllQuestState.RescuePhase = "Combat"
      elseif carryingHostage and AllQuestState.RescueAmbusherSeen then
          AllQuestState.RescuePhase = "Deliver"
          if AllQuestState.RescueCarryAt == 0 then AllQuestState.RescueCarryAt = os.clock() end
      elseif carryingHostage then
          
          
          AllQuestState.RescueEncounterStarted = true
          if AllQuestState.RescueEncounterAt == 0 then AllQuestState.RescueEncounterAt = os.clock() end
          AllQuestState.RescuePhase = "WaitAmbusher"
      end
  
      local requiredPortal = AllQuestState.RescuePhase == "Deliver" and deliveryPortal or rescuePortal
      if not ensureRescuePortal(requiredPortal) then
          return
      end
  
      if infernalAmbusher then
          attackAllQuestEnemy(infernalAmbusher)
          return
      end
  
      if AllQuestState.RescuePhase == "Deliver" then
          deliverCarriedHostage()
          if not isCarryingHostage()
              and os.clock() - (AllQuestState.RescueCarryAt or 0) >= 12 then
              AllQuestState.RescuePhase = "Search"
              AllQuestState.RescueTarget = nil
              AllQuestState.RescueCarryAt = 0
              AllQuestState.RescueEncounterStarted = false
              AllQuestState.RescueAmbusherSeen = false
              AllQuestState.RescueEncounterAt = 0
          end
          return
      end
  
      
      if carryingHostage then return end
  
      local target = findClosestHostageTarget()
      local prompt = getTargetPrompt(target)
      if not prompt or prompt.KeyboardKeyCode ~= Enum.KeyCode.E or not prompt.Enabled then
          return
      end
  
      local promptPosition = getInstancePosition(prompt.Parent)
      if promptPosition then smartMoveCharacter(CFrame.new(promptPosition + Vector3.new(0, 0, 3))) end
  
      if not AllQuestState.RescueAmbusherSeen then
          
          if AllQuestState.RescuePhase == "WaitAmbusher"
              and os.clock() - (AllQuestState.RescueEncounterAt or 0) < 3 then
              return
          end
          if AutoAllQuestToggle and os.clock() - (AllQuestState.LastInteractionAt or 0) >= 0.8 then
              AllQuestState.LastInteractionAt = os.clock()
              pressRescuePickupPrompt(prompt)
              AllQuestState.RescueEncounterStarted = true
              AllQuestState.RescueEncounterAt = os.clock()
              AllQuestState.RescuePhase = "WaitAmbusher"
          end
          return
      end
  
      
      
      AllQuestState.RescuePhase = "Pickup"
      if AutoAllQuestToggle and os.clock() - (AllQuestState.LastInteractionAt or 0) >= 0.8 then
          AllQuestState.LastInteractionAt = os.clock()
          pressRescuePickupPrompt(prompt)
          task.wait(0.35)
          if isCarryingHostage() then
              AllQuestState.RescuePhase = "Deliver"
              AllQuestState.RescueCarryAt = os.clock()
          else
              AllQuestState.RescuePhase = "Pickup"
              AllQuestState.RescueCarryAt = 0
          end
      end
  end
  local function notifyAllQuestStatus(key, state)
      local tierText = FireForceTierRoman[state.Tier] or tostring(state.Tier)
      local progressText = tostring(state.Progress) .. "/" .. tostring(state.Goal)
      local statusKey = key .. ":" .. state.Tier .. ":" .. progressText
      if statusKey ~= AllQuestState.LastStatusKey or os.clock() - (AllQuestState.LastStatusAt or 0) >= 20 then
          AllQuestState.LastStatusKey = statusKey
          AllQuestState.LastStatusAt = os.clock()
          Fluent:Notify({Title = "All Quest - " .. FireForceQuestDefinitions[key].Name, Content = "Auto Tier " .. tierText .. " | Progress: " .. progressText, Duration = 4})
      end
  end
  
  for _, key in ipairs(FireForceQuestOrder) do
      local objectiveKey = key
      local definition = FireForceQuestDefinitions[objectiveKey]
      Tabs.AllQuest:AddSection(definition.Name)
      if objectiveKey == "BattleExperience" then
          Tabs.AllQuest:AddDropdown("FireForceFarmMonster", {
              Title = "Select Monster",
              Values = MonsterList,
              Default = SelectedFireForceFarmMonster,
              Callback = function(value) SelectedFireForceFarmMonster = value end
          })
      elseif objectiveKey == "SpecialSuppression" then
          Tabs.AllQuest:AddDropdown("FireForceSpecialBoss", {
              Title = "Select Ticket Boss",
              Values = SummonBossList,
              Default = SelectedFireForceSummonBoss,
              Callback = function(value)
                  SelectedFireForceSummonBoss = value
                  if ActiveFireForceQuestKey == "SpecialSuppression" then resetAllQuestState("SpecialSuppression") end
              end
          })
      end
  
      FireForceQuestToggleUIs[objectiveKey] = Tabs.AllQuest:AddToggle("AutoFireForce_" .. objectiveKey, {
          Title = "Auto " .. definition.Name,
          Default = false,
          Callback = function(value)
              if value then
                  SetAllQuestEnabled(objectiveKey, true)
                  DisableOtherFarms("AllQuest")
                  local state = readFireForceQuestState(objectiveKey)
                  Fluent:Notify({Title = "All Quest", Content = "Started " .. definition.Name .. " at Tier " .. (FireForceTierRoman[state.Tier] or state.Tier) .. ".", Duration = 4})
              elseif ActiveFireForceQuestKey == objectiveKey then
                  SetAllQuestEnabled(nil, false)
              end
          end
      })
  end
  
  task.spawn(function()
      while task.wait(0.2) do
          if not AutoAllQuestToggle or not ActiveFireForceQuestKey then continue end
          local ok, err = pcall(function()
              local key = ActiveFireForceQuestKey
              local definition = FireForceQuestDefinitions[key]
              if not definition then return end
              if AllQuestState.Key ~= key then resetAllQuestState(key) end
  
              local state = readFireForceQuestState(key)
              notifyAllQuestStatus(key, state)
              if state.Completed then
                  claimFireForceQuest(key)
                  return
              end
  
              if definition.ObjType == "KillAny" then
                  runBattleExperienceQuest()
              elseif key == "DemonSlayer" then
                  runAllQuestBoss("Demon Infernal", true)
              elseif key == "AmbushHunt" then
                  requestFireForceAmbush()
                  runAllQuestBoss("Infernal Ambusher", false)
              elseif definition.ObjType == "KillSpecialBoss" then
                  runAllQuestBoss(SelectedFireForceSummonBoss, true)
              elseif definition.ObjType == "Cat" then
                  runFireForceCatInteraction()
              elseif definition.ObjType == "Hostage" then
                  runFireForceRescueDuty(state)
              end
          end)
          if not ok and os.clock() - (AllQuestState.LastStatusAt or 0) >= 5 then
              AllQuestState.LastStatusAt = os.clock()
              Fluent:Notify({Title = "All Quest Error", Content = tostring(err), Duration = 5})
          end
      end
  end)
  Tabs.Settings:AddSection("Anti-AFK System")
  local AntiAFKToggleUI = Tabs.Settings:AddToggle("AntiAFK", { Title = "Anti-AFK", Default = true })
  AntiAFKToggleUI:OnChanged(function() _G.AntiAFK = AntiAFKToggleUI.Value end)
  
  Player.CharacterAdded:Connect(function() CurrentSelectedPortal = nil end)
  SaveManager:SetLibrary(Fluent)
  InterfaceManager:SetLibrary(Fluent)
  SaveManager:IgnoreThemeSettings()
  SaveManager:SetIgnoreIndexes({})
  InterfaceManager:SetFolder("FluentScriptHub")
  SaveManager:SetFolder("Voltz_Lineage")
  SaveManager:BuildConfigSection(Tabs.Settings)
  InterfaceManager:BuildInterfaceSection(Tabs.Settings)
  
  if MonsterList[1] then MonsterDropdown:SetValue(MonsterList[1]) end
  MethodDropdown:SetValue("Tween") 
  PositionDropdown:SetValue("Behind")
  
  Window:SelectTab(1)
  SaveManager:LoadAutoloadConfig()
  
  task.delay(1, function()
      if Fluent.Options.InterfaceTheme then Fluent.Options.InterfaceTheme:SetValue("Darker") end
      if Fluent.Options.TransparentToggle then Fluent.Options.TransparentToggle:SetValue(false) end
  end)
  
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
      local imageUrl = "https://img1.pic.in.th/images/logo62de603c9fdc4aad.th.png"
      local imageName = "volt.png"
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
          if customImageId ~= "" then Button.Image = customImageId end
          Button.Parent = ToggleGui
          local UICorner = Instance.new("UICorner")
          UICorner.CornerRadius = UDim.new(0, 8)
          UICorner.Parent = Button
          Button.MouseButton1Click:Connect(function()
              VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
              task.wait(0.05)
              VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
          end)
      end
  end)
