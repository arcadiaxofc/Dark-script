-- // ╔══════════════════════════════════════════════════════════╗
-- // ║              NEXUS SUPREMO v12.0 - FINAL                 ║
-- // ║   AutoFarm + AutoBoss + AutoClicker + Frutas + ESP      ║
-- // ║   TODOS OS MÉTODOS UNIFICADOS                           ║
-- // ╚══════════════════════════════════════════════════════════╝

-- ============================================================
-- VERIFICAÇÕES INICIAIS
-- ============================================================
local PlaceId = game.PlaceId
local ValidPlaces = {2753915549, 4442272183, 7449423635}
local IsValid = false
for _, id in ipairs(ValidPlaces) do
    if PlaceId == id then IsValid = true break end
end
if not IsValid then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NEXUS SUPREMO", Text = "Script exclusivo para Blox Fruits!", Duration = 5
    })
    return
end

-- ============================================================
-- CARREGAMENTO DA UI
-- ============================================================
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- ============================================================
-- OTIMIZAÇÕES
-- ============================================================
game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

pcall(function() settings().Rendering.QualityLevel = 1 end)
pcall(function() Lighting.GlobalShadows = false end)
pcall(function() Lighting.Brightness = 1.5 end)
pcall(function() Lighting.FogEnd = 5000 end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
end)

-- ============================================================
-- FLAGS GLOBAIS
-- ============================================================
_G.AutoFarm = false
_G.AutoQuest = true
_G.AutoBoss = false
_G.AutoHaki = false
_G.GodMode = false
_G.BringMob = true
_G.FastAttack = false
_G.AutoStats = false
_G.FruitSniper = false
_G.AutoStore = false
_G.AutoRoll = false
_G.SelectBoss = ""
_G.SelectWeapon = "Melee"
_G.WeaponName = ""
_G.Fast_Delay = 0.001
_G.StopTween = false
_G.Range = 300
_G.AutoClicker = false
_G.AutoClickerSpeed = 0.05
_G.AutoClickerClicks = 5
_G.AutoClickerMode = "Attack"
_G.ESP_Enabled = false
_G.ESP_Players = false
_G.ESP_Fruits = false
_G.ESP_Chests = false
_G.ESP_Bosses = false
_G.ESP_Range = 500
_G.WalkSpeed = false
_G.WalkSpeedValue = 100
_G.JumpPower = false
_G.JumpPowerValue = 150
_G.NoClip = false
_G.Fly = false
_G.FlySpeed = 50

-- ============================================================
-- DETECÇÃO DE SEA
-- ============================================================
local Sea1, Sea2, Sea3 = false, false, false
if game.PlaceId == 2753915549 then Sea1 = true
elseif game.PlaceId == 4442272183 then Sea2 = true
elseif game.PlaceId == 7449423635 then Sea3 = true end

-- ============================================================
-- LISTA DE BOSSES POR SEA
-- ============================================================
local BossList = {}
if Sea1 then
    BossList = {"Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral", "Warden", "Chief Warden", "Saber Expert", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral"}
elseif Sea2 then
    BossList = {"Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper"}
elseif Sea3 then
    BossList = {"Cake Prince", "Dough King", "Soul Reaper", "Rip Indra", "Darkbeard", "Stone", "Island Empress", "Hydra", "Leviathan"}
end

-- ============================================================
-- LISTA DE TELEPORTES
-- ============================================================
local TeleportList = {}
if Sea1 then
    TeleportList = {
        "Pirate Starter", "Jungle", "Desert", "Frozen Village",
        "Marine Fortress", "Skylands", "Prison", "Colosseum",
        "Magma Village", "Underwater City", "Fountain City"
    }
elseif Sea2 then
    TeleportList = {
        "Kingdom of Rose", "Green Zone", "Ice Castle",
        "Forgotten Island", "Cafe"
    }
elseif Sea3 then
    TeleportList = {
        "Port Town", "Hydra Island", "Great Tree",
        "Castle on the Sea", "Haunted Castle", "Floating Turtle"
    }
end

-- ============================================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================================
local function GetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        return remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF")
    end
    return nil
end

local function TP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

local function TweenTP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (pos.Position - hrp.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 350), {CFrame = pos})
    tween:Play()
end

local function Attack()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(0, 0))
    task.wait(_G.Fast_Delay)
    VirtualUser:Button1Up(Vector2.new(0, 0))
end

local function FastAttack()
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
        local registerAttack = remotes:WaitForChild("RE/RegisterAttack")
        local registerHit = remotes:WaitForChild("RE/RegisterHit")
        registerAttack:FireServer(1e-9)
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local head = enemy:FindFirstChild("Head")
                if head and (Player.Character.HumanoidRootPart.Position - head.Position).Magnitude <= 60 then
                    registerHit:FireServer(head, {{enemy, head}})
                end
            end
        end
    end)
end

local function EquipWeapon()
    pcall(function()
        if _G.SelectWeapon == "Melee" then
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                if tool.ToolTip == "Melee" then
                    Player.Character.Humanoid:EquipTool(tool)
                    break
                end
            end
        elseif _G.SelectWeapon == "Sword" then
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                if tool.ToolTip == "Sword" then
                    Player.Character.Humanoid:EquipTool(tool)
                    break
                end
            end
        elseif _G.SelectWeapon == "Blox Fruit" then
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                if tool.ToolTip == "Blox Fruit" then
                    Player.Character.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end)
end

local function FindBoss(name)
    for _, folderName in ipairs({"Bosses", "Enemies"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob.Name:lower():find(name:lower(), 1, true) then
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        return mob
                    end
                end
            end
        end
    end
    return nil
end

-- ============================================================
-- CHECKLEVEL COMPLETO (SEA 1, 2, 3)
-- ============================================================
function CheckLevel()
    local lv = Player.Data.Level.Value
    if Sea1 then
        if lv <= 9 then Ms, NameQuest, QuestLv, NameMon = "Bandit", "BanditQuest1", 1, "Bandit"; CFrameQ = CFrame.new(1060.94, 16.46, 1547.78); CFrameMon = CFrame.new(1038.55, 41.30, 1576.51)
        elseif lv <= 14 then Ms, NameQuest, QuestLv, NameMon = "Monkey", "JungleQuest", 1, "Monkey"; CFrameQ = CFrame.new(-1601.66, 36.85, 153.39); CFrameMon = CFrame.new(-1448.14, 50.85, 63.61)
        elseif lv <= 29 then Ms, NameQuest, QuestLv, NameMon = "Gorilla", "JungleQuest", 2, "Gorilla"; CFrameQ = CFrame.new(-1601.66, 36.85, 153.39); CFrameMon = CFrame.new(-1142.65, 40.46, -515.39)
        elseif lv <= 39 then Ms, NameQuest, QuestLv, NameMon = "Pirate", "BuggyQuest1", 1, "Pirate"; CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41); CFrameMon = CFrame.new(-1201.09, 40.63, 3857.60)
        elseif lv <= 59 then Ms, NameQuest, QuestLv, NameMon = "Brute", "BuggyQuest1", 2, "Brute"; CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41); CFrameMon = CFrame.new(-1387.53, 24.59, 4100.96)
        elseif lv <= 74 then Ms, NameQuest, QuestLv, NameMon = "Desert Bandit", "DesertQuest", 1, "Desert Bandit"; CFrameQ = CFrame.new(896.52, 6.44, 4390.15); CFrameMon = CFrame.new(985.00, 16.11, 4417.91)
        elseif lv <= 89 then Ms, NameQuest, QuestLv, NameMon = "Desert Officer", "DesertQuest", 2, "Desert Officer"; CFrameQ = CFrame.new(896.52, 6.44, 4390.15); CFrameMon = CFrame.new(1547.15, 14.45, 4381.80)
        elseif lv <= 99 then Ms, NameQuest, QuestLv, NameMon = "Snow Bandit", "SnowQuest", 1, "Snow Bandit"; CFrameQ = CFrame.new(1386.81, 87.27, -1298.36); CFrameMon = CFrame.new(1356.30, 105.77, -1328.24)
        elseif lv <= 119 then Ms, NameQuest, QuestLv, NameMon = "Snowman", "SnowQuest", 2, "Snowman"; CFrameQ = CFrame.new(1386.81, 87.27, -1298.36); CFrameMon = CFrame.new(1218.80, 138.01, -1488.03)
        elseif lv <= 149 then Ms, NameQuest, QuestLv, NameMon = "Chief Petty Officer", "MarineQuest2", 1, "Chief Petty Officer"; CFrameQ = CFrame.new(-5035.50, 28.68, 4324.18); CFrameMon = CFrame.new(-4931.16, 65.79, 4121.84)
        elseif lv <= 174 then Ms, NameQuest, QuestLv, NameMon = "Sky Bandit", "SkyQuest", 1, "Sky Bandit"; CFrameQ = CFrame.new(-4842.14, 717.70, -2623.05); CFrameMon = CFrame.new(-4955.64, 365.46, -2908.19)
        elseif lv <= 209 then Ms, NameQuest, QuestLv, NameMon = "Prisoner", "PrisonerQuest", 1, "Prisoner"; CFrameQ = CFrame.new(5310.61, 0.35, 474.95); CFrameMon = CFrame.new(4937.32, 0.33, 649.57)
        elseif lv <= 249 then Ms, NameQuest, QuestLv, NameMon = "Dangerous Prisoner", "PrisonerQuest", 2, "Dangerous Prisoner"; CFrameQ = CFrame.new(5310.61, 0.35, 474.95); CFrameMon = CFrame.new(5099.66, 0.35, 1055.76)
        elseif lv <= 274 then Ms, NameQuest, QuestLv, NameMon = "Toga Warrior", "ColosseumQuest", 1, "Toga Warrior"; CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48); CFrameMon = CFrame.new(-1872.52, 49.08, -2913.81)
        elseif lv <= 299 then Ms, NameQuest, QuestLv, NameMon = "Gladiator", "ColosseumQuest", 2, "Gladiator"; CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48); CFrameMon = CFrame.new(-1521.37, 81.20, -3066.31)
        elseif lv <= 324 then Ms, NameQuest, QuestLv, NameMon = "Military Soldier", "MagmaQuest", 1, "Military Soldier"; CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00); CFrameMon = CFrame.new(-5369.00, 61.24, 8556.49)
        elseif lv <= 374 then Ms, NameQuest, QuestLv, NameMon = "Military Spy", "MagmaQuest", 2, "Military Spy"; CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00); CFrameMon = CFrame.new(-5787.00, 75.83, 8651.70)
        elseif lv <= 399 then Ms, NameQuest, QuestLv, NameMon = "Fishman Warrior", "FishmanQuest", 1, "Fishman Warrior"; CFrameQ = CFrame.new(61122.65, 18.50, 1569.40); CFrameMon = CFrame.new(60844.11, 98.46, 1298.40)
        elseif lv <= 449 then Ms, NameQuest, QuestLv, NameMon = "Fishman Commando", "FishmanQuest", 2, "Fishman Commando"; CFrameQ = CFrame.new(61122.65, 18.50, 1569.40); CFrameMon = CFrame.new(61738.40, 64.21, 1433.84)
        elseif lv <= 474 then Ms, NameQuest, QuestLv, NameMon = "God's Guard", "SkyExp1Quest", 1, "God's Guard"; CFrameQ = CFrame.new(-4721.86, 845.30, -1953.85); CFrameMon = CFrame.new(-4628.05, 866.93, -1931.24)
        elseif lv <= 524 then Ms, NameQuest, QuestLv, NameMon = "Shanda", "SkyExp1Quest", 2, "Shanda"; CFrameQ = CFrame.new(-7863.16, 5545.52, -378.42); CFrameMon = CFrame.new(-7685.15, 5601.08, -441.39)
        elseif lv <= 549 then Ms, NameQuest, QuestLv, NameMon = "Royal Squad", "SkyExp2Quest", 1, "Royal Squad"; CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92); CFrameMon = CFrame.new(-7654.25, 5637.11, -1407.76)
        elseif lv <= 624 then Ms, NameQuest, QuestLv, NameMon = "Royal Soldier", "SkyExp2Quest", 2, "Royal Soldier"; CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92); CFrameMon = CFrame.new(-7760.41, 5679.91, -1884.81)
        elseif lv <= 649 then Ms, NameQuest, QuestLv, NameMon = "Galley Pirate", "FountainQuest", 1, "Galley Pirate"; CFrameQ = CFrame.new(5258.28, 38.53, 4050.04); CFrameMon = CFrame.new(5557.17, 152.33, 3998.78)
        else Ms, NameQuest, QuestLv, NameMon = "Galley Captain", "FountainQuest", 2, "Galley Captain"; CFrameQ = CFrame.new(5258.28, 38.53, 4050.04); CFrameMon = CFrame.new(5677.68, 92.79, 4966.63) end
    elseif Sea2 then
        if lv <= 724 then Ms, NameQuest, QuestLv, NameMon = "Raider", "Area1Quest", 1, "Raider"; CFrameQ = CFrame.new(-427.73, 73.00, 1835.94); CFrameMon = CFrame.new(68.87, 93.64, 2429.68)
        elseif lv <= 774 then Ms, NameQuest, QuestLv, NameMon = "Mercenary", "Area1Quest", 2, "Mercenary"; CFrameQ = CFrame.new(-427.73, 73.00, 1835.94); CFrameMon = CFrame.new(-864.85, 122.47, 1453.15)
        elseif lv <= 799 then Ms, NameQuest, QuestLv, NameMon = "Swan Pirate", "Area2Quest", 1, "Swan Pirate"; CFrameQ = CFrame.new(635.61, 73.10, 917.81); CFrameMon = CFrame.new(1065.37, 137.64, 1324.38)
        elseif lv <= 874 then Ms, NameQuest, QuestLv, NameMon = "Factory Staff", "Area2Quest", 2, "Factory Staff"; CFrameQ = CFrame.new(635.61, 73.10, 917.81); CFrameMon = CFrame.new(533.22, 128.47, 355.63)
        elseif lv <= 899 then Ms, NameQuest, QuestLv, NameMon = "Marine Lieutenant", "MarineQuest3", 1, "Marine Lieutenant"; CFrameQ = CFrame.new(-2440.99, 73.04, -3217.71); CFrameMon = CFrame.new(-2489.26, 84.61, -3151.88)
        elseif lv <= 949 then Ms, NameQuest, QuestLv, NameMon = "Marine Captain", "MarineQuest3", 2, "Marine Captain"; CFrameQ = CFrame.new(-2440.99, 73.04, -3217.71); CFrameMon = CFrame.new(-2335.20, 79.79, -3245.87)
        elseif lv <= 974 then Ms, NameQuest, QuestLv, NameMon = "Zombie", "ZombieQuest", 1, "Zombie"; CFrameQ = CFrame.new(-5494.34, 48.51, -794.59); CFrameMon = CFrame.new(-5536.50, 101.09, -835.59)
        elseif lv <= 999 then Ms, NameQuest, QuestLv, NameMon = "Vampire", "ZombieQuest", 2, "Vampire"; CFrameQ = CFrame.new(-5494.34, 48.51, -794.59); CFrameMon = CFrame.new(-5806.11, 16.72, -1164.44)
        elseif lv <= 1049 then Ms, NameQuest, QuestLv, NameMon = "Snow Trooper", "SnowMountainQuest", 1, "Snow Trooper"; CFrameQ = CFrame.new(607.06, 401.45, -5370.55); CFrameMon = CFrame.new(535.21, 432.74, -5484.92)
        elseif lv <= 1099 then Ms, NameQuest, QuestLv, NameMon = "Winter Warrior", "SnowMountainQuest", 2, "Winter Warrior"; CFrameQ = CFrame.new(607.06, 401.45, -5370.55); CFrameMon = CFrame.new(1234.44, 456.95, -5174.13)
        elseif lv <= 1124 then Ms, NameQuest, QuestLv, NameMon = "Lab Subordinate", "IceSideQuest", 1, "Lab Subordinate"; CFrameQ = CFrame.new(-6061.84, 15.93, -4902.04); CFrameMon = CFrame.new(-5720.56, 63.31, -4784.61)
        elseif lv <= 1174 then Ms, NameQuest, QuestLv, NameMon = "Horned Warrior", "IceSideQuest", 2, "Horned Warrior"; CFrameQ = CFrame.new(-6061.84, 15.93, -4902.04); CFrameMon = CFrame.new(-6292.75, 91.18, -5502.65)
        elseif lv <= 1199 then Ms, NameQuest, QuestLv, NameMon = "Magma Ninja", "FireSideQuest", 1, "Magma Ninja"; CFrameQ = CFrame.new(-5429.05, 15.98, -5297.96); CFrameMon = CFrame.new(-5461.84, 130.36, -5836.47)
        elseif lv <= 1249 then Ms, NameQuest, QuestLv, NameMon = "Lava Pirate", "FireSideQuest", 2, "Lava Pirate"; CFrameQ = CFrame.new(-5429.05, 15.98, -5297.96); CFrameMon = CFrame.new(-5251.19, 55.16, -4774.41)
        elseif lv <= 1274 then Ms, NameQuest, QuestLv, NameMon = "Ship Deckhand", "ShipQuest1", 1, "Ship Deckhand"; CFrameQ = CFrame.new(1040.29, 125.08, 32911.04); CFrameMon = CFrame.new(921.12, 125.98, 33088.33)
        elseif lv <= 1299 then Ms, NameQuest, QuestLv, NameMon = "Ship Engineer", "ShipQuest1", 2, "Ship Engineer"; CFrameQ = CFrame.new(1040.29, 125.08, 32911.04); CFrameMon = CFrame.new(886.28, 40.48, 32800.83)
        elseif lv <= 1324 then Ms, NameQuest, QuestLv, NameMon = "Ship Steward", "ShipQuest2", 1, "Ship Steward"; CFrameQ = CFrame.new(971.42, 125.08, 33245.54); CFrameMon = CFrame.new(943.86, 129.58, 33444.37)
        elseif lv <= 1349 then Ms, NameQuest, QuestLv, NameMon = "Ship Officer", "ShipQuest2", 2, "Ship Officer"; CFrameQ = CFrame.new(971.42, 125.08, 33245.54); CFrameMon = CFrame.new(955.38, 181.08, 33331.89)
        elseif lv <= 1374 then Ms, NameQuest, QuestLv, NameMon = "Arctic Warrior", "FrostQuest", 1, "Arctic Warrior"; CFrameQ = CFrame.new(5668.14, 28.20, -6484.60); CFrameMon = CFrame.new(5935.45, 77.26, -6472.76)
        elseif lv <= 1424 then Ms, NameQuest, QuestLv, NameMon = "Snow Lurker", "FrostQuest", 2, "Snow Lurker"; CFrameQ = CFrame.new(5668.14, 28.20, -6484.60); CFrameMon = CFrame.new(5628.48, 57.57, -6618.35)
        elseif lv <= 1449 then Ms, NameQuest, QuestLv, NameMon = "Sea Soldier", "ForgottenQuest", 1, "Sea Soldier"; CFrameQ = CFrame.new(-3054.58, 236.87, -10147.79); CFrameMon = CFrame.new(-3185.02, 58.79, -9663.61)
        else Ms, NameQuest, QuestLv, NameMon = "Water Fighter", "ForgottenQuest", 2, "Water Fighter"; CFrameQ = CFrame.new(-3054.58, 236.87, -10147.79); CFrameMon = CFrame.new(-3262.93, 298.69, -10552.53) end
    elseif Sea3 then
        if lv <= 1524 then Ms, NameQuest, QuestLv, NameMon = "Pirate Millionaire", "PiratePortQuest", 1, "Pirate Millionaire"; CFrameQ = CFrame.new(-450.10, 107.68, 5950.73); CFrameMon = CFrame.new(-193.99, 56.13, 5755.79)
        elseif lv <= 1574 then Ms, NameQuest, QuestLv, NameMon = "Pistol Billionaire", "PiratePortQuest", 2, "Pistol Billionaire"; CFrameQ = CFrame.new(-450.10, 107.68, 5950.73); CFrameMon = CFrame.new(-188.14, 84.50, 6337.04)
        elseif lv <= 1599 then Ms, NameQuest, QuestLv, NameMon = "Dragon Crew Warrior", "DragonCrewQuest", 1, "Dragon Crew Warrior"; CFrameQ = CFrame.new(6735.11, 126.99, -711.10); CFrameMon = CFrame.new(6615.23, 50.85, -978.93)
        elseif lv <= 1624 then Ms, NameQuest, QuestLv, NameMon = "Dragon Crew Archer", "DragonCrewQuest", 2, "Dragon Crew Archer"; CFrameQ = CFrame.new(6735.11, 126.99, -711.10); CFrameMon = CFrame.new(6818.59, 483.72, 512.73)
        elseif lv <= 1649 then Ms, NameQuest, QuestLv, NameMon = "Hydra Enforcer", "VenomCrewQuest", 1, "Hydra Enforcer"; CFrameQ = CFrame.new(5446.88, 601.63, 749.46); CFrameMon = CFrame.new(4547.12, 1001.60, 334.20)
        elseif lv <= 1699 then Ms, NameQuest, QuestLv, NameMon = "Venomous Assailant", "VenomCrewQuest", 2, "Venomous Assailant"; CFrameQ = CFrame.new(5446.88, 601.63, 749.46); CFrameMon = CFrame.new(4637.89, 1077.86, 882.42)
        elseif lv <= 1724 then Ms, NameQuest, QuestLv, NameMon = "Marine Commodore", "MarineTreeIsland", 1, "Marine Commodore"; CFrameQ = CFrame.new(2179.99, 28.73, -6740.06); CFrameMon = CFrame.new(2198.01, 128.71, -7109.50)
        elseif lv <= 1774 then Ms, NameQuest, QuestLv, NameMon = "Marine Rear Admiral", "MarineTreeIsland", 2, "Marine Rear Admiral"; CFrameQ = CFrame.new(2179.99, 28.73, -6740.06); CFrameMon = CFrame.new(3294.31, 385.41, -7048.63)
        elseif lv <= 1799 then Ms, NameQuest, QuestLv, NameMon = "Fishman Raider", "DeepForestIsland3", 1, "Fishman Raider"; CFrameQ = CFrame.new(-10582.76, 331.79, -8757.67); CFrameMon = CFrame.new(-10553.27, 521.38, -8176.95)
        elseif lv <= 1824 then Ms, NameQuest, QuestLv, NameMon = "Fishman Captain", "DeepForestIsland3", 2, "Fishman Captain"; CFrameQ = CFrame.new(-10583.10, 331.79, -8759.46); CFrameMon = CFrame.new(-10789.40, 427.19, -9131.44)
        elseif lv <= 1849 then Ms, NameQuest, QuestLv, NameMon = "Forest Pirate", "DeepForestIsland", 1, "Forest Pirate"; CFrameQ = CFrame.new(-13232.66, 332.40, -7626.48); CFrameMon = CFrame.new(-13489.40, 400.30, -7770.25)
        elseif lv <= 1899 then Ms, NameQuest, QuestLv, NameMon = "Mythological Pirate", "DeepForestIsland", 2, "Mythological Pirate"; CFrameQ = CFrame.new(-13232.66, 332.40, -7626.48); CFrameMon = CFrame.new(-13508.62, 582.46, -6985.30)
        elseif lv <= 1924 then Ms, NameQuest, QuestLv, NameMon = "Jungle Pirate", "DeepForestIsland2", 1, "Jungle Pirate"; CFrameQ = CFrame.new(-12682.10, 390.89, -9902.12); CFrameMon = CFrame.new(-12267.10, 459.75, -10277.20)
        elseif lv <= 1974 then Ms, NameQuest, QuestLv, NameMon = "Musketeer Pirate", "DeepForestIsland2", 2, "Musketeer Pirate"; CFrameQ = CFrame.new(-12682.10, 390.89, -9902.12); CFrameMon = CFrame.new(-13291.51, 520.47, -9904.64)
        else Ms, NameQuest, QuestLv, NameMon = "Reborn Skeleton", "HauntedQuest1", 1, "Reborn Skeleton"; CFrameQ = CFrame.new(-9480.81, 142.13, 5566.37); CFrameMon = CFrame.new(-8761.77, 183.43, 6168.33) end
    end
end

-- ============================================================
-- TELEPORTES POR NOME
-- ============================================================
local TeleportCoords = {}
if Sea1 then
    TeleportCoords = {
        ["Pirate Starter"] = CFrame.new(1289, 11, 4191),
        ["Jungle"] = CFrame.new(-1250, 15, 3850),
        ["Desert"] = CFrame.new(966, 10, 1100),
        ["Frozen Village"] = CFrame.new(1150, 25, 4350),
        ["Marine Fortress"] = CFrame.new(-1500, 10, 5300),
        ["Skylands"] = CFrame.new(-4850, 750, 1950),
        ["Prison"] = CFrame.new(-5400, 15, -1700),
        ["Colosseum"] = CFrame.new(-3560, 240, -80),
        ["Magma Village"] = CFrame.new(-3420, 10, -2700),
        ["Underwater City"] = CFrame.new(5500, -50, 2000),
        ["Fountain City"] = CFrame.new(4500, 50, 1200),
    }
elseif Sea2 then
    TeleportCoords = {
        ["Kingdom of Rose"] = CFrame.new(-1400, 10, -1400),
        ["Green Zone"] = CFrame.new(6200, 80, 2500),
        ["Ice Castle"] = CFrame.new(7200, 100, 3500),
        ["Forgotten Island"] = CFrame.new(8500, 120, 4500),
        ["Cafe"] = CFrame.new(-570, 310, -1220),
    }
elseif Sea3 then
    TeleportCoords = {
        ["Port Town"] = CFrame.new(-6000, 20, -4000),
        ["Hydra Island"] = CFrame.new(6200, 80, 2500),
        ["Great Tree"] = CFrame.new(8500, 120, 4500),
        ["Castle on the Sea"] = CFrame.new(4500, 50, 1200),
        ["Haunted Castle"] = CFrame.new(9800, 60, 5500),
        ["Floating Turtle"] = CFrame.new(11200, 90, 6500),
    }
end

-- ============================================================
-- SISTEMA DE ARMAS
-- ============================================================
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.SelectWeapon == "Melee" then
                for _, tool in pairs(Player.Backpack:GetChildren()) do
                    if tool.ToolTip == "Melee" then _G.WeaponName = tool.Name end
                end
            elseif _G.SelectWeapon == "Sword" then
                for _, tool in pairs(Player.Backpack:GetChildren()) do
                    if tool.ToolTip == "Sword" then _G.WeaponName = tool.Name end
                end
            elseif _G.SelectWeapon == "Blox Fruit" then
                for _, tool in pairs(Player.Backpack:GetChildren()) do
                    if tool.ToolTip == "Blox Fruit" then _G.WeaponName = tool.Name end
                end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 1: AUTO FARM LOOP (VAI ATÉ O MOB → PRIMEIRO HIT → CONTÍNUO)
-- ============================================================
task.spawn(function()
    print("[AUTO FARM] Loop iniciado")
    while task.wait(0.05) do
        if not _G.AutoFarm then task.wait(1); continue end
        pcall(function()
            CheckLevel()
            local hasQuest = false
            pcall(function()
                local main = Player.PlayerGui:FindFirstChild("Main")
                if main then
                    local quest = main:FindFirstChild("Quest")
                    if quest then
                        local container = quest:FindFirstChild("Container")
                        if container then
                            local questTitle = container:FindFirstChild("QuestTitle")
                            if questTitle then
                                local title = questTitle:FindFirstChild("Title")
                                if title and title.Text and _G.NameMon and title.Text:find(_G.NameMon) then hasQuest = true end
                            end
                        end
                    end
                end
            end)
            if not hasQuest and _G.AutoQuest then
                local remote = GetRemote()
                if remote then remote:InvokeServer("AbandonQuest"); task.wait(0.3); TweenTP(_G.CFrameQ); task.wait(1)
                    if _G.CFrameQ and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (_G.CFrameQ.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= 15 then remote:InvokeServer("StartQuest", _G.NameQuest, _G.QuestLv) end
                    end
                end
                return
            end
            if hasQuest or not _G.AutoQuest then
                EquipWeapon()
                if _G.AutoHaki then pcall(function() if not Player.Character:FindFirstChild("HasBuso") then local remote = GetRemote(); if remote then remote:InvokeServer("Buso") end end end) end
                local closestMob, closestDistance = nil, _G.Range
                local enemiesFolder = Workspace:FindFirstChild("Enemies")
                local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if enemiesFolder and myPos then
                    for _, enemy in pairs(enemiesFolder:GetChildren()) do
                        if enemy:IsA("Model") and enemy.Name == _G.Ms then
                            local hum = enemy:FindFirstChild("Humanoid")
                            local hrp = enemy:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health > 0 and hrp then
                                local dist = (hrp.Position - myPos.Position).Magnitude
                                if dist < closestDistance then closestDistance = dist; closestMob = enemy end
                            end
                        end
                    end
                end
                if closestMob and myPos then
                    local hum = closestMob:FindFirstChild("Humanoid")
                    local hrp = closestMob:FindFirstChild("HumanoidRootPart")
                    local head = closestMob:FindFirstChild("Head")
                    if hum and hrp and hum.Health > 0 then
                        if closestDistance > 10 then TP(hrp.Position); task.wait(0.3) end
                        myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if not myPos then return end
                        myPos.CFrame = CFrame.new(myPos.Position, hrp.Position)
                        pcall(function()
                            local mouse = Player:GetMouse()
                            if mouse and head then
                                local headPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                                if onScreen then mouse.Move(headPos.X, headPos.Y); task.wait(0.05) end
                                mouse:Button1Down(); task.wait(0.1); mouse:Button1Up()
                            end
                            local remote = GetRemote(); if remote then remote:InvokeServer("Attack") end
                        end)
                        task.wait(0.2)
                        if _G.BringMob then
                            local frente = myPos.CFrame * CFrame.new(0, 0, -5)
                            hrp.CFrame = frente; hrp.Velocity = Vector3.new(0, 0, 0); hrp.RotVelocity = Vector3.new(0, 0, 0)
                            hrp.Anchored = true; task.wait(0.01); hrp.Anchored = false
                            hum.WalkSpeed = 0; hum.JumpPower = 0
                        end
                        for attackCount = 1, 50 do
                            if not _G.AutoFarm then break end
                            if not hum or hum.Health <= 0 then break end
                            if _G.BringMob and hrp and myPos then hrp.CFrame = myPos.CFrame * CFrame.new(0, 0, -5); hrp.Velocity = Vector3.new(0, 0, 0) end
                            if myPos and hrp then myPos.CFrame = CFrame.new(myPos.Position, hrp.Position) end
                            if _G.FastAttack then FastAttack() else
                                pcall(function()
                                    local mouse = Player:GetMouse()
                                    if mouse and head then
                                        local headPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                                        if onScreen then mouse.Move(headPos.X, headPos.Y) end
                                        mouse:Button1Down(); task.wait(_G.Fast_Delay); mouse:Button1Up()
                                    end
                                    local remote = GetRemote(); if remote then remote:InvokeServer("Attack") end
                                end)
                            end
                            task.wait(0.1)
                        end
                    end
                else TweenTP(_G.CFrameMon); task.wait(1) end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 2: AUTO BOSS LOOP (VAI ATÉ O BOSS → PRIMEIRO HIT → CONTÍNUO)
-- ============================================================
task.spawn(function()
    print("[AUTO BOSS] Loop iniciado")
    while task.wait(0.05) do
        if not _G.AutoBoss or _G.SelectBoss == "" then task.wait(1); continue end
        if _G.AutoFarm then continue end
        pcall(function()
            local boss = FindBoss(_G.SelectBoss)
            if boss then
                local hum = boss:FindFirstChild("Humanoid")
                local hrp = boss:FindFirstChild("HumanoidRootPart")
                local head = boss:FindFirstChild("Head")
                if hum and hrp and hum.Health > 0 then
                    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if myPos then
                        local dist = (hrp.Position - myPos.Position).Magnitude
                        if dist > 10 then TP(hrp.Position); task.wait(0.3) end
                        myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if not myPos then return end
                        myPos.CFrame = CFrame.new(myPos.Position, hrp.Position)
                        pcall(function()
                            local mouse = Player:GetMouse()
                            if mouse and head then
                                local headPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                                if onScreen then mouse.Move(headPos.X, headPos.Y); task.wait(0.05) end
                                mouse:Button1Down(); task.wait(0.1); mouse:Button1Up()
                            end
                            local remote = GetRemote(); if remote then remote:InvokeServer("Attack") end
                        end)
                        task.wait(0.2)
                        if _G.AutoHaki and not Player.Character:FindFirstChild("HasBuso") then local remote = GetRemote(); if remote then remote:InvokeServer("Buso") end end
                        EquipWeapon()
                        for attackCount = 1, 100 do
                            if not _G.AutoBoss then break end
                            if not hum or hum.Health <= 0 then break end
                            local frente = myPos.CFrame * CFrame.new(0, 0, -5)
                            hrp.CFrame = frente; hrp.Velocity = Vector3.new(0, 0, 0); hrp.RotVelocity = Vector3.new(0, 0, 0)
                            hum.WalkSpeed = 0; hum.JumpPower = 0
                            myPos.CFrame = CFrame.new(myPos.Position, hrp.Position)
                            if _G.FastAttack then FastAttack() else
                                pcall(function()
                                    local mouse = Player:GetMouse()
                                    if mouse and head then
                                        local headPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                                        if onScreen then mouse.Move(headPos.X, headPos.Y) end
                                        mouse:Button1Down(); task.wait(_G.Fast_Delay); mouse:Button1Up()
                                    end
                                    local remote = GetRemote(); if remote then remote:InvokeServer("Attack") end
                                end)
                            end
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 3: AUTO CLICKER (ESTILO ANKULUA)
-- ============================================================
task.spawn(function()
    print("[AUTO CLICKER] Pronto")
    while task.wait(0.05) do
        if not _G.AutoClicker then task.wait(1); continue end
        if _G.AutoFarm then continue end
        for i = 1, _G.AutoClickerClicks do
            if not _G.AutoClicker then break end
            pcall(function()
                if _G.AutoClickerMode == "Attack" then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(0, 0))
                    task.wait(_G.AutoClickerSpeed)
                    VirtualUser:Button1Up(Vector2.new(0, 0))
                elseif _G.AutoClickerMode == "FastAttack" then
                    FastAttack()
                elseif _G.AutoClickerMode == "Jump" then
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.Jump = true
                    end
                elseif _G.AutoClickerMode == "Click" then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(0, 0))
                    task.wait(0.01)
                    VirtualUser:Button1Up(Vector2.new(0, 0))
                end
            end)
            task.wait(_G.AutoClickerSpeed)
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- MÉTODO 4: GOD MODE
-- ============================================================
task.spawn(function()
    while task.wait(0.3) do
        if not _G.GodMode then continue end
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum.Health = hum.MaxHealth end
        end)
    end
end)

-- ============================================================
-- MÉTODO 5: AUTO STATS
-- ============================================================
task.spawn(function()
    while task.wait(60) do
        if not _G.AutoStats then continue end
        pcall(function()
            for _ = 1, 3 do
                local remote = GetRemote(); if remote then remote:InvokeServer("AddPoint", "Melee", 1) end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 6: FRUIT SNIPER
-- ============================================================
task.spawn(function()
    while task.wait(3) do
        if not _G.FruitSniper then continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("fruit", 1, true) then
                    if obj.Parent and obj.Parent:FindFirstChild("Handle") then
                        TP(obj.Position); task.wait(0.5); break
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 7: AUTO STORE
-- ============================================================
task.spawn(function()
    while task.wait(10) do
        if not _G.AutoStore then continue end
        pcall(function()
            local data = Player:FindFirstChild("Data")
            if data then
                local fruit = data:FindFirstChild("Fruit")
                if fruit and fruit.Value ~= "" then
                    local remote = GetRemote(); if remote then remote:InvokeServer("StoreFruit", fruit.Value) end
                end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 8: AUTO ROLL
-- ============================================================
task.spawn(function()
    while task.wait(30) do
        if not _G.AutoRoll then continue end
        pcall(function()
            local remote = GetRemote(); if remote then remote:InvokeServer("FruitGacha", "Roll") end
        end)
    end
end)

-- ============================================================
-- MÉTODO 9: WALKSPEED / JUMPSPEED
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if _G.WalkSpeed then hum.WalkSpeed = _G.WalkSpeedValue end
                if _G.JumpPower then hum.JumpPower = _G.JumpPowerValue end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 10: NOCLIP
-- ============================================================
task.spawn(function()
    RunService.Stepped:Connect(function()
        if not _G.NoClip then return end
        pcall(function()
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end)
end)

-- ============================================================
-- MÉTODO 11: FLY
-- ============================================================
local FlyBodyVelocity, FlyBodyGyro, FlyConnection = nil, nil, nil
task.spawn(function()
    while task.wait(0.5) do
        if not _G.Fly then
            if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
            if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
            if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
            continue
        end
        pcall(function()
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not FlyBodyVelocity then FlyBodyVelocity = Instance.new("BodyVelocity"); FlyBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000); FlyBodyVelocity.Velocity = Vector3.zero; FlyBodyVelocity.Parent = hrp end
            if not FlyBodyGyro then FlyBodyGyro = Instance.new("BodyGyro"); FlyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000); FlyBodyGyro.CFrame = hrp.CFrame; FlyBodyGyro.Parent = hrp end
            if not FlyConnection then
                FlyConnection = RunService.RenderStepped:Connect(function()
                    if not _G.Fly then return end
                    if not FlyBodyVelocity or not FlyBodyVelocity.Parent then return end
                    local direction = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                    if direction.Magnitude > 0 then FlyBodyVelocity.Velocity = direction.Unit * _G.FlySpeed else FlyBodyVelocity.Velocity = Vector3.zero end
                    if FlyBodyGyro and FlyBodyGyro.Parent then FlyBodyGyro.CFrame = Camera.CFrame end
                end)
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 12: ESP (Drawing Library)
-- ============================================================
local ESPObjects = {}
task.spawn(function()
    while task.wait(2) do
        for _, obj in ipairs(ESPObjects) do pcall(function() if obj and obj.Parent then obj:Destroy() end end) end
        ESPObjects = {}
        if not _G.ESP_Enabled then continue end
        pcall(function()
            local count = 0
            if _G.ESP_Players then
                for _, p in ipairs(Players:GetPlayers()) do
                    if count >= 10 then break end
                    if p == Player then continue end
                    local char = p.Character; if not char then continue end
                    local head = char:FindFirstChild("Head"); if not head then continue end
                    local bg = Instance.new("BillboardGui"); bg.Adornee = head; bg.Size = UDim2.new(0, 80, 0, 16); bg.AlwaysOnTop = true; bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0, 2, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5; label.BackgroundColor3 = Color3.fromRGB(255, 0, 0); label.TextColor3 = Color3.new(1, 1, 1); label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "👤 " .. p.DisplayName
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
            if _G.ESP_Fruits then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if count >= 10 then break end
                    if not obj:IsA("BasePart") then continue end
                    if not obj.Name:lower():find("fruit", 1, true) then continue end
                    if not (obj.Parent and obj.Parent:FindFirstChild("Handle")) then continue end
                    local bg = Instance.new("BillboardGui"); bg.Adornee = obj; bg.Size = UDim2.new(0, 60, 0, 14); bg.AlwaysOnTop = true; bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0, 2, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5; label.BackgroundColor3 = Color3.fromRGB(255, 0, 255); label.TextColor3 = Color3.new(1, 1, 1); label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "🍎 Fruit"
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
            if _G.ESP_Chests then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if count >= 10 then break end
                    if not obj:IsA("Model") then continue end
                    if not obj.Name:lower():find("chest", 1, true) then continue end
                    local part = obj:FindFirstChildWhichIsA("BasePart"); if not part then continue end
                    local bg = Instance.new("BillboardGui"); bg.Adornee = part; bg.Size = UDim2.new(0, 60, 0, 14); bg.AlwaysOnTop = true; bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0, 2, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5; label.BackgroundColor3 = Color3.fromRGB(255, 215, 0); label.TextColor3 = Color3.new(0, 0, 0); label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "📦 Chest"
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
            if _G.ESP_Bosses then
                for _, folderName in ipairs({"Bosses", "Enemies"}) do
                    local folder = Workspace:FindFirstChild(folderName)
                    if folder then
                        for _, obj in ipairs(folder:GetChildren()) do
                            if count >= 10 then break end
                            if not obj:IsA("Model") then continue end
                            local hum = obj:FindFirstChild("Humanoid"); if not hum or hum.MaxHealth <= 5000 then continue end
                            local head = obj:FindFirstChild("Head"); if not head then continue end
                            local bg = Instance.new("BillboardGui"); bg.Adornee = head; bg.Size = UDim2.new(0, 80, 0, 16); bg.AlwaysOnTop = true; bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0, 3, 0); bg.Parent = CoreGui
                            local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5; label.BackgroundColor3 = Color3.fromRGB(255, 50, 50); label.TextColor3 = Color3.new(1, 1, 1); label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "💀 " .. obj.Name
                            table.insert(ESPObjects, bg); count = count + 1
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 13: NOCLIP AUTOMÁTICO (FARM)
-- ============================================================
task.spawn(function()
    RunService.Stepped:Connect(function()
        if not _G.AutoFarm and not _G.AutoBoss then return end
        pcall(function()
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end)
end)

-- ============================================================
-- MÉTODO 14: BODY VELOCITY ANTI-KNOCKBACK
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.AutoFarm or _G.AutoBoss then
                if not Player.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local bv = Instance.new("BodyVelocity"); bv.Name = "BodyClip"; bv.Parent = Player.Character.HumanoidRootPart
                    bv.MaxForce = Vector3.new(100000, 100000, 100000); bv.Velocity = Vector3.new(0, 0, 0)
                end
            elseif Player.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                Player.Character.HumanoidRootPart.BodyClip:Destroy()
            end
        end)
    end
end)

-- ============================================================
-- MÉTODO 15: ANTI-STUN
-- ============================================================
task.spawn(function()
    if Player.Character:FindFirstChild("Stun") then
        Player.Character.Stun.Changed:Connect(function()
            pcall(function()
                if Player.Character:FindFirstChild("Stun") then Player.Character.Stun.Value = 0 end
            end)
        end)
    end
end)

-- ============================================================
-- UI - INTERFACE COMPLETA
-- ============================================================
local win = DiscordLib:Window("NEXUS SUPREMO v12.0")
local serv = win:Server("Blox Fruits", "http://www.roblox.com/asset/?id=6031075938")

-- CANAL: AUTO FARM
local farmChannel = serv:Channel("⚔️ Auto Farm")
farmChannel:Toggle("Auto Farm Level", false, function(v) _G.AutoFarm = v end)
farmChannel:Toggle("Auto Quest", true, function(v) _G.AutoQuest = v end)
farmChannel:Toggle("Bring Mob", true, function(v) _G.BringMob = v end)
farmChannel:Toggle("Fast Attack", false, function(v) _G.FastAttack = v end)
farmChannel:Toggle("Auto Haki", false, function(v) _G.AutoHaki = v end)
farmChannel:Toggle("God Mode", false, function(v) _G.GodMode = v end)
farmChannel:Dropdown("Select Weapon", {"Melee", "Sword", "Blox Fruit"}, function(v) _G.SelectWeapon = v end)
farmChannel:Slider("Attack Range", 50, 500, 300, function(v) _G.Range = v end)

-- CANAL: AUTO BOSS
local bossChannel = serv:Channel("💀 Auto Boss")
bossChannel:Toggle("Auto Boss", false, function(v) _G.AutoBoss = v end)
bossChannel:Dropdown("Select Boss", BossList, function(v) _G.SelectBoss = v end)

-- CANAL: AUTO CLICKER
local clickerChannel = serv:Channel("🖱️ Auto Clicker")
clickerChannel:Toggle("Auto Clicker", false, function(v) _G.AutoClicker = v end)
clickerChannel:Dropdown("Click Mode", {"Attack", "FastAttack", "Jump", "Click"}, function(v) _G.AutoClickerMode = v end)
clickerChannel:Slider("Clicks per Cycle", 1, 20, 5, function(v) _G.AutoClickerClicks = v end)
clickerChannel:Slider("Click Speed", 0.01, 0.5, 0.05, function(v) _G.AutoClickerSpeed = v end)

-- CANAL: FRUTAS
local fruitChannel = serv:Channel("🍎 Frutas")
fruitChannel:Toggle("Fruit Sniper", false, function(v) _G.FruitSniper = v end)
fruitChannel:Toggle("Auto Store", false, function(v) _G.AutoStore = v end)
fruitChannel:Toggle("Auto Roll", false, function(v) _G.AutoRoll = v end)

-- CANAL: MOVIMENTO
local moveChannel = serv:Channel("🏃 Movimento")
moveChannel:Toggle("WalkSpeed", false, function(v) _G.WalkSpeed = v end)
moveChannel:Slider("Speed", 16, 350, 100, function(v) _G.WalkSpeedValue = v end)
moveChannel:Toggle("JumpPower", false, function(v) _G.JumpPower = v end)
moveChannel:Slider("Jump Height", 50, 300, 150, function(v) _G.JumpPowerValue = v end)
moveChannel:Toggle("NoClip", false, function(v) _G.NoClip = v end)
moveChannel:Toggle("Fly (WASD + Space/Shift)", false, function(v) _G.Fly = v end)
moveChannel:Slider("Fly Speed", 10, 200, 50, function(v) _G.FlySpeed = v end)

-- CANAL: ESP
local espChannel = serv:Channel("👁️ ESP")
espChannel:Toggle("ESP Master", false, function(v) _G.ESP_Enabled = v end)
espChannel:Toggle("ESP Players", false, function(v) _G.ESP_Players = v end)
espChannel:Toggle("ESP Fruits", false, function(v) _G.ESP_Fruits = v end)
espChannel:Toggle("ESP Chests", false, function(v) _G.ESP_Chests = v end)
espChannel:Toggle("ESP Bosses", false, function(v) _G.ESP_Bosses = v end)
espChannel:Slider("ESP Range", 100, 1000, 500, function(v) _G.ESP_Range = v end)

-- CANAL: TELEPORTES
local teleChannel = serv:Channel("🏝️ Teleportes")
for _, name in ipairs(TeleportList) do
    teleChannel:Button(name, function()
        local pos = TeleportCoords[name]
        if pos then TP(pos.Position) end
    end)
end

-- CANAL: CONFIGURAÇÕES
local settingsChannel = serv:Channel("⚙️ Configurações")
settingsChannel:Toggle("Auto Stats (Melee)", false, function(v) _G.AutoStats = v end)
settingsChannel:Slider("Attack Delay", 0, 10, 0, function(v) _G.Fast_Delay = v == 0 and 1e-9 or v / 10 end)
settingsChannel:Button("🔄 Refresh Status", function()
    local lv = Player.Data.Level.Value
    local sea = Sea1 and "1" or Sea2 and "2" or Sea3 and "3" or "?"
    DiscordLib:Notification("NEXUS SUPREMO", "Sea: " .. sea .. " | Level: " .. lv .. " | Weapon: " .. (_G.WeaponName or "None"), "OK")
end)
settingsChannel:Button("🛑 Stop Everything", function()
    _G.AutoFarm = false; _G.AutoBoss = false; _G.AutoClicker = false; _G.GodMode = false
    _G.FruitSniper = false; _G.AutoStore = false; _G.AutoRoll = false; _G.AutoStats = false
    _G.WalkSpeed = false; _G.JumpPower = false; _G.NoClip = false; _G.Fly = false
    _G.ESP_Enabled = false; _G.StopTween = true; task.wait(0.5); _G.StopTween = false
    DiscordLib:Notification("NEXUS SUPREMO", "All systems have been STOPPED!", "OK")
end)
settingsChannel:Label("NEXUS SUPREMO v12.0")
settingsChannel:Label("15 Métodos Unificados")
settingsChannel:Label("DiscordLib + HohoHub + Parvus + AnkuLua")

-- ============================================================
-- NOTIFICAÇÃO INICIAL
-- ============================================================
DiscordLib:Notification("NEXUS SUPREMO v12.0", "🚀 Script carregado!\n\n⚔️ AutoFarm | 💀 AutoBoss | 🖱️ AutoClicker\n🍎 Frutas | 🏃 Movimento | 👁️ ESP | 🏝️ Teleportes", "LET'S GO!")
