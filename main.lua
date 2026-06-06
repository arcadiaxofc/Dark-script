-- // ╔══════════════════════════════════════════════════════════╗
-- // ║     NEXUS SUPREMO - COMPLETO COM SAVE/LOAD              ║
-- // ║   Config salvável + Status + Todos os sistemas         ║
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
local DiscordLib = nil
local UIs = {
    "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord",
}
for _, url in ipairs(UIs) do
    if not DiscordLib then
        pcall(function()
            DiscordLib = loadstring(game:HttpGet(url))()
        end)
    end
end
if not DiscordLib then return end

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- ESPERAR CARREGAR
-- ============================================================
game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

-- ============================================================
-- OTIMIZAÇÕES
-- ============================================================
pcall(function() settings().Rendering.QualityLevel = 1 end)
Lighting.GlobalShadows = false
Lighting.Brightness = 1.5

-- ============================================================
-- ANTI-AFK
-- ============================================================
pcall(function()
    local connections = getconnections and getconnections(Player.Idled) or {}
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disable() end)
    end
end)

-- ============================================================
-- SISTEMA DE CONFIGURAÇÃO (SAVE/LOAD)
-- ============================================================
local ConfigManager = {}
local ConfigFolder = "NexusSupremo"
local ConfigFile = ConfigFolder .. "/config.json"

function ConfigManager:Init()
    if not isfolder or not writefile then return false end
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    return true
end

function ConfigManager:Save()
    if not self:Init() then return false end
    local config = {}
    for k, v in pairs(_G) do
        if type(v) ~= "function" and type(v) ~= "thread" and type(v) ~= "userdata" then
            pcall(function() config[k] = v end)
        end
    end
    pcall(function() writefile(ConfigFile, HttpService:JSONEncode(config)) end)
    return true
end

function ConfigManager:Load()
    if not self:Init() then return false end
    if not isfile(ConfigFile) then return false end
    local success, json = pcall(function() return readfile(ConfigFile) end)
    if not success then return false end
    local success2, config = pcall(function() return HttpService:JSONDecode(json) end)
    if not success2 then return false end
    for k, v in pairs(config) do
        if _G[k] ~= nil and type(_G[k]) == type(v) then
            _G[k] = v
        end
    end
    return true
end

function ConfigManager:Reset()
    local defaults = {
        AutoFarm = false, AutoQuest = true, AutoBoss = false, AutoHaki = false,
        GodMode = false, BringMob = true, FastAttack = false, AutoStats = false,
        FruitSniper = false, AutoStore = false, AutoRoll = false, SelectBoss = "",
        SelectWeapon = "Melee", Fast_Delay = 0.1, Range = 300,
        ESP_Enabled = false, ESP_Players = false, ESP_Fruits = false, ESP_Range = 500,
        WalkSpeed = false, WalkSpeedValue = 100, JumpPower = false, JumpPowerValue = 150,
        NoClip = false, Fly = false, FlySpeed = 50,
        AutoClicker = false, AutoClickerSpeed = 0.15, AutoClickerClicks = 5, AutoClickerMode = "Attack",
    }
    for k, v in pairs(defaults) do _G[k] = v end
    self:Save()
    return true
end

-- Auto-Salvar a cada 30s
task.spawn(function()
    while task.wait(30) do
        pcall(function() ConfigManager:Save() end)
    end
end)

-- ============================================================
-- CARREGAR CONFIGURAÇÃO SALVA
-- ============================================================
ConfigManager:Load()

-- ============================================================
-- FLAGS GLOBAIS (VALORES PADRÃO)
-- ============================================================
if _G.AutoFarm == nil then _G.AutoFarm = false end
if _G.AutoQuest == nil then _G.AutoQuest = true end
if _G.AutoBoss == nil then _G.AutoBoss = false end
if _G.AutoHaki == nil then _G.AutoHaki = false end
if _G.GodMode == nil then _G.GodMode = false end
if _G.BringMob == nil then _G.BringMob = true end
if _G.FastAttack == nil then _G.FastAttack = false end
if _G.AutoStats == nil then _G.AutoStats = false end
if _G.FruitSniper == nil then _G.FruitSniper = false end
if _G.AutoStore == nil then _G.AutoStore = false end
if _G.AutoRoll == nil then _G.AutoRoll = false end
if _G.SelectBoss == nil then _G.SelectBoss = "" end
if _G.SelectWeapon == nil then _G.SelectWeapon = "Melee" end
if _G.Fast_Delay == nil then _G.Fast_Delay = 0.1 end
if _G.Range == nil then _G.Range = 300 end
if _G.ESP_Enabled == nil then _G.ESP_Enabled = false end
if _G.ESP_Players == nil then _G.ESP_Players = false end
if _G.ESP_Fruits == nil then _G.ESP_Fruits = false end
if _G.ESP_Range == nil then _G.ESP_Range = 500 end
if _G.WalkSpeed == nil then _G.WalkSpeed = false end
if _G.WalkSpeedValue == nil then _G.WalkSpeedValue = 100 end
if _G.JumpPower == nil then _G.JumpPower = false end
if _G.JumpPowerValue == nil then _G.JumpPowerValue = 150 end
if _G.NoClip == nil then _G.NoClip = false end
if _G.Fly == nil then _G.Fly = false end
if _G.FlySpeed == nil then _G.FlySpeed = 50 end
if _G.AutoClicker == nil then _G.AutoClicker = false end
if _G.AutoClickerSpeed == nil then _G.AutoClickerSpeed = 0.15 end
if _G.AutoClickerClicks == nil then _G.AutoClickerClicks = 5 end
if _G.AutoClickerMode == nil then _G.AutoClickerMode = "Attack" end

-- Variáveis do CheckLevel
_G.Ms = ""
_G.NameQuest = ""
_G.QuestLv = 1
_G.NameMon = ""
_G.CFrameQ = CFrame.new(0,0,0)
_G.CFrameMon = CFrame.new(0,0,0)
_G.WeaponName = "None"

-- ============================================================
-- DETECÇÃO DE SEA
-- ============================================================
local Sea1 = game.PlaceId == 2753915549
local Sea2 = game.PlaceId == 4442272183
local Sea3 = game.PlaceId == 7449423635

-- ============================================================
-- LISTAS
-- ============================================================
local BossList = {}
if Sea1 then BossList = {"Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Warden","Chief Warden","Saber Expert","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"}
elseif Sea2 then BossList = {"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"}
elseif Sea3 then BossList = {"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan"} end

local TeleportList = {}
local TeleportCoords = {}
if Sea1 then
    TeleportList = {"Pirate Starter","Jungle","Desert","Frozen Village","Marine Fortress","Skylands","Prison","Colosseum","Magma Village","Underwater City","Fountain City"}
    TeleportCoords = {["Pirate Starter"]=Vector3.new(1289,11,4191),["Jungle"]=Vector3.new(-1250,15,3850),["Desert"]=Vector3.new(966,10,1100),["Frozen Village"]=Vector3.new(1150,25,4350),["Marine Fortress"]=Vector3.new(-1500,10,5300),["Skylands"]=Vector3.new(-4850,750,1950),["Prison"]=Vector3.new(-5400,15,-1700),["Colosseum"]=Vector3.new(-3560,240,-80),["Magma Village"]=Vector3.new(-3420,10,-2700),["Underwater City"]=Vector3.new(5500,-50,2000),["Fountain City"]=Vector3.new(4500,50,1200)}
elseif Sea2 then
    TeleportList = {"Kingdom of Rose","Green Zone","Ice Castle","Forgotten Island","Cafe"}
    TeleportCoords = {["Kingdom of Rose"]=Vector3.new(-1400,10,-1400),["Green Zone"]=Vector3.new(6200,80,2500),["Ice Castle"]=Vector3.new(7200,100,3500),["Forgotten Island"]=Vector3.new(8500,120,4500),["Cafe"]=Vector3.new(-570,310,-1220)}
elseif Sea3 then
    TeleportList = {"Port Town","Hydra Island","Great Tree","Castle on the Sea","Haunted Castle","Floating Turtle"}
    TeleportCoords = {["Port Town"]=Vector3.new(-6000,20,-4000),["Hydra Island"]=Vector3.new(6200,80,2500),["Great Tree"]=Vector3.new(8500,120,4500),["Castle on the Sea"]=Vector3.new(4500,50,1200),["Haunted Castle"]=Vector3.new(9800,60,5500),["Floating Turtle"]=Vector3.new(11200,90,6500)}
end

-- ============================================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================================
local function GetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then return remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF") end
    return nil
end

local function TP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
end

local function Attack()
    pcall(function()
        local remote = GetRemote()
        if remote then remote:InvokeServer("Attack") end
    end)
    pcall(function()
        local mouse = Player:GetMouse()
        if mouse then mouse:Button1Down(); task.wait(_G.Fast_Delay); mouse:Button1Up() end
    end)
end

local function FastAttack()
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        if modules then
            local net = modules:FindFirstChild("Net")
            if net then
                local regAttack = net:FindFirstChild("RE/RegisterAttack")
                if regAttack then regAttack:FireServer(0.01) end
                local regHit = net:FindFirstChild("RE/RegisterHit")
                if regHit then
                    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if myPos then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                local head = enemy:FindFirstChild("Head")
                                if head and (myPos.Position - head.Position).Magnitude <= 60 then
                                    regHit:FireServer(head, {{enemy, head}})
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function EquipWeapon()
    pcall(function()
        for _, tool in pairs(Player.Backpack:GetChildren()) do
            if tool.ToolTip == _G.SelectWeapon then
                _G.WeaponName = tool.Name
                Player.Character.Humanoid:EquipTool(tool)
                return
            end
        end
    end)
end

local function FindBoss(name)
    for _, folderName in ipairs({"Bosses","Enemies"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob.Name:lower():find(name:lower(),1,true) then
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then return mob end
                end
            end
        end
    end
    return nil
end

-- ============================================================
-- STATUS (O que está ativo)
-- ============================================================
local function GetStatus()
    local s = {}
    if _G.AutoFarm then s[#s+1] = "⚔️Farm" end
    if _G.AutoBoss then s[#s+1] = "💀Boss" end
    if _G.GodMode then s[#s+1] = "🛡️God" end
    if _G.FastAttack then s[#s+1] = "⚡Fast" end
    if _G.Fly then s[#s+1] = "🕊️Fly" end
    if _G.WalkSpeed then s[#s+1] = "🏃Speed" end
    if _G.ESP_Enabled then s[#s+1] = "👁️ESP" end
    if _G.AutoClicker then s[#s+1] = "🖱️Click" end
    if _G.FruitSniper then s[#s+1] = "🍎Fruit" end
    if #s == 0 then return "😴 Nada ativo" end
    return table.concat(s," ")
end

-- ============================================================
-- CHECKLEVEL (COMPLETO)
-- ============================================================
function CheckLevel()
    local lv = Player.Data.Level.Value
    if Sea1 then
        if lv <= 9 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Bandit","BanditQuest1",1,"Bandit"; _G.CFrameQ=CFrame.new(1060.94,16.46,1547.78); _G.CFrameMon=CFrame.new(1038.55,41.30,1576.51)
        elseif lv <= 14 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Monkey","JungleQuest",1,"Monkey"; _G.CFrameQ=CFrame.new(-1601.66,36.85,153.39); _G.CFrameMon=CFrame.new(-1448.14,50.85,63.61)
        elseif lv <= 29 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Gorilla","JungleQuest",2,"Gorilla"; _G.CFrameQ=CFrame.new(-1601.66,36.85,153.39); _G.CFrameMon=CFrame.new(-1142.65,40.46,-515.39)
        elseif lv <= 39 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Pirate","BuggyQuest1",1,"Pirate"; _G.CFrameQ=CFrame.new(-1140.18,4.75,3827.41); _G.CFrameMon=CFrame.new(-1201.09,40.63,3857.60)
        elseif lv <= 59 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Brute","BuggyQuest1",2,"Brute"; _G.CFrameQ=CFrame.new(-1140.18,4.75,3827.41); _G.CFrameMon=CFrame.new(-1387.53,24.59,4100.96)
        elseif lv <= 74 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Desert Bandit","DesertQuest",1,"Desert Bandit"; _G.CFrameQ=CFrame.new(896.52,6.44,4390.15); _G.CFrameMon=CFrame.new(985.00,16.11,4417.91)
        elseif lv <= 89 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Desert Officer","DesertQuest",2,"Desert Officer"; _G.CFrameQ=CFrame.new(896.52,6.44,4390.15); _G.CFrameMon=CFrame.new(1547.15,14.45,4381.80)
        elseif lv <= 99 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Snow Bandit","SnowQuest",1,"Snow Bandit"; _G.CFrameQ=CFrame.new(1386.81,87.27,-1298.36); _G.CFrameMon=CFrame.new(1356.30,105.77,-1328.24)
        elseif lv <= 119 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Snowman","SnowQuest",2,"Snowman"; _G.CFrameQ=CFrame.new(1386.81,87.27,-1298.36); _G.CFrameMon=CFrame.new(1218.80,138.01,-1488.03)
        elseif lv <= 149 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Chief Petty Officer","MarineQuest2",1,"Chief Petty Officer"; _G.CFrameQ=CFrame.new(-5035.50,28.68,4324.18); _G.CFrameMon=CFrame.new(-4931.16,65.79,4121.84)
        elseif lv <= 174 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Sky Bandit","SkyQuest",1,"Sky Bandit"; _G.CFrameQ=CFrame.new(-4842.14,717.70,-2623.05); _G.CFrameMon=CFrame.new(-4955.64,365.46,-2908.19)
        elseif lv <= 209 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Prisoner","PrisonerQuest",1,"Prisoner"; _G.CFrameQ=CFrame.new(5310.61,0.35,474.95); _G.CFrameMon=CFrame.new(4937.32,0.33,649.57)
        elseif lv <= 249 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Dangerous Prisoner","PrisonerQuest",2,"Dangerous Prisoner"; _G.CFrameQ=CFrame.new(5310.61,0.35,474.95); _G.CFrameMon=CFrame.new(5099.66,0.35,1055.76)
        elseif lv <= 274 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Toga Warrior","ColosseumQuest",1,"Toga Warrior"; _G.CFrameQ=CFrame.new(-1577.79,7.42,-2984.48); _G.CFrameMon=CFrame.new(-1872.52,49.08,-2913.81)
        elseif lv <= 299 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Gladiator","ColosseumQuest",2,"Gladiator"; _G.CFrameQ=CFrame.new(-1577.79,7.42,-2984.48); _G.CFrameMon=CFrame.new(-1521.37,81.20,-3066.31)
        elseif lv <= 324 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Military Soldier","MagmaQuest",1,"Military Soldier"; _G.CFrameQ=CFrame.new(-5316.12,12.26,8517.00); _G.CFrameMon=CFrame.new(-5369.00,61.24,8556.49)
        elseif lv <= 374 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Military Spy","MagmaQuest",2,"Military Spy"; _G.CFrameQ=CFrame.new(-5316.12,12.26,8517.00); _G.CFrameMon=CFrame.new(-5787.00,75.83,8651.70)
        elseif lv <= 399 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Fishman Warrior","FishmanQuest",1,"Fishman Warrior"; _G.CFrameQ=CFrame.new(61122.65,18.50,1569.40); _G.CFrameMon=CFrame.new(60844.11,98.46,1298.40)
        elseif lv <= 449 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Fishman Commando","FishmanQuest",2,"Fishman Commando"; _G.CFrameQ=CFrame.new(61122.65,18.50,1569.40); _G.CFrameMon=CFrame.new(61738.40,64.21,1433.84)
        elseif lv <= 474 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "God's Guard","SkyExp1Quest",1,"God's Guard"; _G.CFrameQ=CFrame.new(-4721.86,845.30,-1953.85); _G.CFrameMon=CFrame.new(-4628.05,866.93,-1931.24)
        elseif lv <= 524 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Shanda","SkyExp1Quest",2,"Shanda"; _G.CFrameQ=CFrame.new(-7863.16,5545.52,-378.42); _G.CFrameMon=CFrame.new(-7685.15,5601.08,-441.39)
        elseif lv <= 549 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Royal Squad","SkyExp2Quest",1,"Royal Squad"; _G.CFrameQ=CFrame.new(-7903.38,5635.99,-1410.92); _G.CFrameMon=CFrame.new(-7654.25,5637.11,-1407.76)
        elseif lv <= 624 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Royal Soldier","SkyExp2Quest",2,"Royal Soldier"; _G.CFrameQ=CFrame.new(-7903.38,5635.99,-1410.92); _G.CFrameMon=CFrame.new(-7760.41,5679.91,-1884.81)
        elseif lv <= 649 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Galley Pirate","FountainQuest",1,"Galley Pirate"; _G.CFrameQ=CFrame.new(5258.28,38.53,4050.04); _G.CFrameMon=CFrame.new(5557.17,152.33,3998.78)
        else _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Galley Captain","FountainQuest",2,"Galley Captain"; _G.CFrameQ=CFrame.new(5258.28,38.53,4050.04); _G.CFrameMon=CFrame.new(5677.68,92.79,4966.63) end
    elseif Sea2 then
        if lv <= 724 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Raider","Area1Quest",1,"Raider"; _G.CFrameQ=CFrame.new(-427.73,73.00,1835.94); _G.CFrameMon=CFrame.new(68.87,93.64,2429.68)
        elseif lv <= 774 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Mercenary","Area1Quest",2,"Mercenary"; _G.CFrameQ=CFrame.new(-427.73,73.00,1835.94); _G.CFrameMon=CFrame.new(-864.85,122.47,1453.15)
        elseif lv <= 799 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Swan Pirate","Area2Quest",1,"Swan Pirate"; _G.CFrameQ=CFrame.new(635.61,73.10,917.81); _G.CFrameMon=CFrame.new(1065.37,137.64,1324.38)
        elseif lv <= 874 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Factory Staff","Area2Quest",2,"Factory Staff"; _G.CFrameQ=CFrame.new(635.61,73.10,917.81); _G.CFrameMon=CFrame.new(533.22,128.47,355.63)
        elseif lv <= 899 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Marine Lieutenant","MarineQuest3",1,"Marine Lieutenant"; _G.CFrameQ=CFrame.new(-2440.99,73.04,-3217.71); _G.CFrameMon=CFrame.new(-2489.26,84.61,-3151.88)
        elseif lv <= 949 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Marine Captain","MarineQuest3",2,"Marine Captain"; _G.CFrameQ=CFrame.new(-2440.99,73.04,-3217.71); _G.CFrameMon=CFrame.new(-2335.20,79.79,-3245.87)
        elseif lv <= 974 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Zombie","ZombieQuest",1,"Zombie"; _G.CFrameQ=CFrame.new(-5494.34,48.51,-794.59); _G.CFrameMon=CFrame.new(-5536.50,101.09,-835.59)
        elseif lv <= 999 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Vampire","ZombieQuest",2,"Vampire"; _G.CFrameQ=CFrame.new(-5494.34,48.51,-794.59); _G.CFrameMon=CFrame.new(-5806.11,16.72,-1164.44)
        elseif lv <= 1049 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Snow Trooper","SnowMountainQuest",1,"Snow Trooper"; _G.CFrameQ=CFrame.new(607.06,401.45,-5370.55); _G.CFrameMon=CFrame.new(535.21,432.74,-5484.92)
        elseif lv <= 1099 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Winter Warrior","SnowMountainQuest",2,"Winter Warrior"; _G.CFrameQ=CFrame.new(607.06,401.45,-5370.55); _G.CFrameMon=CFrame.new(1234.44,456.95,-5174.13)
        elseif lv <= 1124 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Lab Subordinate","IceSideQuest",1,"Lab Subordinate"; _G.CFrameQ=CFrame.new(-6061.84,15.93,-4902.04); _G.CFrameMon=CFrame.new(-5720.56,63.31,-4784.61)
        elseif lv <= 1174 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Horned Warrior","IceSideQuest",2,"Horned Warrior"; _G.CFrameQ=CFrame.new(-6061.84,15.93,-4902.04); _G.CFrameMon=CFrame.new(-6292.75,91.18,-5502.65)
        elseif lv <= 1199 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Magma Ninja","FireSideQuest",1,"Magma Ninja"; _G.CFrameQ=CFrame.new(-5429.05,15.98,-5297.96); _G.CFrameMon=CFrame.new(-5461.84,130.36,-5836.47)
        elseif lv <= 1249 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Lava Pirate","FireSideQuest",2,"Lava Pirate"; _G.CFrameQ=CFrame.new(-5429.05,15.98,-5297.96); _G.CFrameMon=CFrame.new(-5251.19,55.16,-4774.41)
        elseif lv <= 1274 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Ship Deckhand","ShipQuest1",1,"Ship Deckhand"; _G.CFrameQ=CFrame.new(1040.29,125.08,32911.04); _G.CFrameMon=CFrame.new(921.12,125.98,33088.33)
        elseif lv <= 1299 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Ship Engineer","ShipQuest1",2,"Ship Engineer"; _G.CFrameQ=CFrame.new(1040.29,125.08,32911.04); _G.CFrameMon=CFrame.new(886.28,40.48,32800.83)
        elseif lv <= 1324 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Ship Steward","ShipQuest2",1,"Ship Steward"; _G.CFrameQ=CFrame.new(971.42,125.08,33245.54); _G.CFrameMon=CFrame.new(943.86,129.58,33444.37)
        elseif lv <= 1349 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Ship Officer","ShipQuest2",2,"Ship Officer"; _G.CFrameQ=CFrame.new(971.42,125.08,33245.54); _G.CFrameMon=CFrame.new(955.38,181.08,33331.89)
        elseif lv <= 1374 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Arctic Warrior","FrostQuest",1,"Arctic Warrior"; _G.CFrameQ=CFrame.new(5668.14,28.20,-6484.60); _G.CFrameMon=CFrame.new(5935.45,77.26,-6472.76)
        elseif lv <= 1424 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Snow Lurker","FrostQuest",2,"Snow Lurker"; _G.CFrameQ=CFrame.new(5668.14,28.20,-6484.60); _G.CFrameMon=CFrame.new(5628.48,57.57,-6618.35)
        elseif lv <= 1449 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Sea Soldier","ForgottenQuest",1,"Sea Soldier"; _G.CFrameQ=CFrame.new(-3054.58,236.87,-10147.79); _G.CFrameMon=CFrame.new(-3185.02,58.79,-9663.61)
        else _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Water Fighter","ForgottenQuest",2,"Water Fighter"; _G.CFrameQ=CFrame.new(-3054.58,236.87,-10147.79); _G.CFrameMon=CFrame.new(-3262.93,298.69,-10552.53) end
    elseif Sea3 then
        if lv <= 1524 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Pirate Millionaire","PiratePortQuest",1,"Pirate Millionaire"; _G.CFrameQ=CFrame.new(-450.10,107.68,5950.73); _G.CFrameMon=CFrame.new(-193.99,56.13,5755.79)
        elseif lv <= 1574 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Pistol Billionaire","PiratePortQuest",2,"Pistol Billionaire"; _G.CFrameQ=CFrame.new(-450.10,107.68,5950.73); _G.CFrameMon=CFrame.new(-188.14,84.50,6337.04)
        elseif lv <= 1599 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Dragon Crew Warrior","DragonCrewQuest",1,"Dragon Crew Warrior"; _G.CFrameQ=CFrame.new(6735.11,126.99,-711.10); _G.CFrameMon=CFrame.new(6615.23,50.85,-978.93)
        elseif lv <= 1624 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Dragon Crew Archer","DragonCrewQuest",2,"Dragon Crew Archer"; _G.CFrameQ=CFrame.new(6735.11,126.99,-711.10); _G.CFrameMon=CFrame.new(6818.59,483.72,512.73)
        else _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Hydra Enforcer","VenomCrewQuest",1,"Hydra Enforcer"; _G.CFrameQ=CFrame.new(5446.88,601.63,749.46); _G.CFrameMon=CFrame.new(4547.12,1001.60,334.20) end
    end
end

-- ============================================================
-- AUTO FARM LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.15) do
        if not _G.AutoFarm then task.wait(1); continue end
        pcall(function()
            CheckLevel()
            local hasQuest = false
            pcall(function()
                local main = Player.PlayerGui:FindFirstChild("Main")
                if main then
                    local quest = main:FindFirstChild("Quest")
                    if quest and quest:FindFirstChild("Container") and quest.Container:FindFirstChild("QuestTitle") then
                        local title = quest.Container.QuestTitle:FindFirstChild("Title")
                        if title and title.Text and _G.NameMon and title.Text:find(_G.NameMon) then hasQuest = true end
                    end
                end
            end)
            if not hasQuest and _G.AutoQuest then
                local remote = GetRemote()
                if remote then remote:InvokeServer("AbandonQuest"); task.wait(0.5)
                    TP(_G.CFrameQ.Position); task.wait(1)
                    if (_G.CFrameQ.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 10 then
                        remote:InvokeServer("StartQuest", _G.NameQuest, _G.QuestLv)
                    end
                end
                return
            end
            if hasQuest or not _G.AutoQuest then
                EquipWeapon()
                if _G.AutoHaki and not Player.Character:FindFirstChild("HasBuso") then
                    local remote = GetRemote(); if remote then remote:InvokeServer("Buso") end
                end
                local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if not myPos then return end
                local enemiesFolder = Workspace:FindFirstChild("Enemies")
                if not enemiesFolder then return end
                for _, enemy in pairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") and enemy.Name == _G.Ms then
                        local hum = enemy:FindFirstChild("Humanoid")
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")
                        if hum and hum.Health > 0 and hrp then
                            local dist = (hrp.Position - myPos.Position).Magnitude
                            if _G.BringMob then
                                hrp.CFrame = myPos.CFrame * CFrame.new(0,0,-5)
                                hrp.Velocity = Vector3.zero
                                hum.WalkSpeed = 0; hum.JumpPower = 0
                            elseif dist > 10 then TP(hrp.Position); task.wait(0.3) end
                            if _G.FastAttack then FastAttack() else Attack() end
                            break
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- AUTO BOSS LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.3) do
        if not _G.AutoBoss or _G.SelectBoss == "" then task.wait(1); continue end
        if _G.AutoFarm then continue end
        pcall(function()
            local boss = FindBoss(_G.SelectBoss)
            if boss then
                local hrp = boss:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if myPos then
                        if (hrp.Position - myPos.Position).Magnitude > 10 then TP(hrp.Position); task.wait(0.3) end
                        if _G.AutoHaki and not Player.Character:FindFirstChild("HasBuso") then
                            local remote = GetRemote(); if remote then remote:InvokeServer("Buso") end
                        end
                        EquipWeapon()
                        if _G.FastAttack then FastAttack() else Attack() end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- GOD MODE
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
-- AUTO STATS
-- ============================================================
task.spawn(function()
    while task.wait(60) do
        if not _G.AutoStats then continue end
        pcall(function()
            local remote = GetRemote()
            if remote then for _=1,3 do remote:InvokeServer("AddPoint","Melee",1) end end
        end)
    end
end)

-- ============================================================
-- FRUIT SNIPER
-- ============================================================
task.spawn(function()
    while task.wait(3) do
        if not _G.FruitSniper then continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("fruit",1,true) then
                    if obj.Parent and obj.Parent:FindFirstChild("Handle") then
                        TP(obj.Position); task.wait(0.5); break
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- AUTO STORE
-- ============================================================
task.spawn(function()
    while task.wait(10) do
        if not _G.AutoStore then continue end
        pcall(function()
            local data = Player:FindFirstChild("Data")
            if data then
                local fruit = data:FindFirstChild("Fruit")
                if fruit and fruit.Value ~= "" then
                    local remote = GetRemote()
                    if remote then remote:InvokeServer("StoreFruit",fruit.Value) end
                end
            end
        end)
    end
end)

-- ============================================================
-- AUTO ROLL
-- ============================================================
task.spawn(function()
    while task.wait(30) do
        if not _G.AutoRoll then continue end
        pcall(function()
            local remote = GetRemote()
            if remote then remote:InvokeServer("FruitGacha","Roll") end
        end)
    end
end)

-- ============================================================
-- ESP
-- ============================================================
local ESPObjects = {}
task.spawn(function()
    while task.wait(3) do
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
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = head; bg.Size = UDim2.new(0,80,0,16); bg.AlwaysOnTop = true
                    bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0,2,0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel",bg)
                    label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255,0,0); label.TextColor3 = Color3.new(1,1,1)
                    label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "👤 "..p.DisplayName
                    table.insert(ESPObjects,bg); count = count + 1
                end
            end
            if _G.ESP_Fruits then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if count >= 10 then break end
                    if not obj:IsA("BasePart") then continue end
                    if not obj.Name:lower():find("fruit",1,true) then continue end
                    if not (obj.Parent and obj.Parent:FindFirstChild("Handle")) then continue end
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = obj; bg.Size = UDim2.new(0,60,0,14); bg.AlwaysOnTop = true
                    bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0,2,0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel",bg)
                    label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255,0,255); label.TextColor3 = Color3.new(1,1,1)
                    label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "🍎 Fruit"
                    table.insert(ESPObjects,bg); count = count + 1
                end
            end
        end)
    end
end)

-- ============================================================
-- WALKSPEED / JUMPPOWER
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
-- NOCLIP
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
-- FLY
-- ============================================================
local FlyBV, FlyBG, FlyConn = nil, nil, nil
task.spawn(function()
    while task.wait(0.5) do
        if not _G.Fly then
            if FlyBV then FlyBV:Destroy(); FlyBV = nil end
            if FlyBG then FlyBG:Destroy(); FlyBG = nil end
            if FlyConn then FlyConn:Disconnect(); FlyConn = nil end
            continue
        end
        pcall(function()
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not FlyBV then FlyBV = Instance.new("BodyVelocity"); FlyBV.MaxForce = Vector3.new(400000,400000,400000); FlyBV.Velocity = Vector3.zero; FlyBV.Parent = hrp end
            if not FlyBG then FlyBG = Instance.new("BodyGyro"); FlyBG.MaxTorque = Vector3.new(400000,400000,400000); FlyBG.CFrame = hrp.CFrame; FlyBG.Parent = hrp end
            if not FlyConn then
                FlyConn = RunService.RenderStepped:Connect(function()
                    if not _G.Fly then return end
                    if not FlyBV or not FlyBV.Parent then return end
                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                    if dir.Magnitude > 0 then FlyBV.Velocity = dir.Unit * _G.FlySpeed else FlyBV.Velocity = Vector3.zero end
                    if FlyBG and FlyBG.Parent then FlyBG.CFrame = Camera.CFrame end
                end)
            end
        end)
    end
end)

-- ============================================================
-- AUTO CLICKER
-- ============================================================
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoClicker then task.wait(1); continue end
        if _G.AutoFarm then continue end
        for i = 1, _G.AutoClickerClicks do
            if not _G.AutoClicker then break end
            if _G.AutoClickerMode == "Attack" then Attack()
            elseif _G.AutoClickerMode == "FastAttack" then FastAttack()
            elseif _G.AutoClickerMode == "Jump" then
                pcall(function()
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.Jump = true
                    end
                end)
            end
            task.wait(_G.AutoClickerSpeed)
        end
    end
end)

-- ============================================================
-- NOCLIP AUTOMÁTICO (FARM)
-- ============================================================
RunService.Stepped:Connect(function()
    if not _G.AutoFarm and not _G.AutoBoss then return end
    pcall(function()
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end)

-- ============================================================
-- ANTI-KNOCKBACK
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if (_G.AutoFarm or _G.AutoBoss) and Player.Character then
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and not hrp:FindFirstChild("BodyClip") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "BodyClip"; bv.Parent = hrp
                    bv.MaxForce = Vector3.new(100000,100000,100000)
                    bv.Velocity = Vector3.new(0,0,0)
                end
            elseif Player.Character then
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("BodyClip") then hrp.BodyClip:Destroy() end
            end
        end)
    end
end)

-- ============================================================
-- ANTI-STUN
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if Player.Character then
                local stun = Player.Character:FindFirstChild("Stun")
                if stun then stun.Value = 0 end
            end
        end)
    end
end)

-- ============================================================
-- UI COMPLETA
-- ============================================================
local win = DiscordLib:Window("NEXUS SUPREMO")
local serv = win:Server("Blox Fruits", "http://www.roblox.com/asset/?id=6031075938")

-- Farm
local fCh = serv:Channel("⚔️ Auto Farm")
fCh:Toggle("Auto Farm", _G.AutoFarm, function(v) _G.AutoFarm = v end)
fCh:Toggle("Auto Quest", _G.AutoQuest, function(v) _G.AutoQuest = v end)
fCh:Toggle("Bring Mob", _G.BringMob, function(v) _G.BringMob = v end)
fCh:Toggle("Fast Attack", _G.FastAttack, function(v) _G.FastAttack = v end)
fCh:Toggle("Auto Haki", _G.AutoHaki, function(v) _G.AutoHaki = v end)
fCh:Toggle("God Mode", _G.GodMode, function(v) _G.GodMode = v end)
fCh:Dropdown("Arma", {"Melee","Sword","Blox Fruit"}, function(v) _G.SelectWeapon = v end)
fCh:Slider("Distância", 50, 500, _G.Range, function(v) _G.Range = v end)

-- Boss
local bCh = serv:Channel("💀 Auto Boss")
bCh:Toggle("Auto Boss", _G.AutoBoss, function(v) _G.AutoBoss = v end)
bCh:Dropdown("Boss", BossList, function(v) _G.SelectBoss = v end)

-- Clicker
local cCh = serv:Channel("🖱️ Auto Clicker")
cCh:Toggle("Auto Clicker", _G.AutoClicker, function(v) _G.AutoClicker = v end)
cCh:Dropdown("Modo", {"Attack","FastAttack","Jump"}, function(v) _G.AutoClickerMode = v end)
cCh:Slider("Cliques", 1, 20, _G.AutoClickerClicks, function(v) _G.AutoClickerClicks = v end)
cCh:Slider("Velocidade", 0.1, 1, _G.AutoClickerSpeed, function(v) _G.AutoClickerSpeed = v end)

-- Frutas
local frCh = serv:Channel("🍎 Frutas")
frCh:Toggle("Fruit Sniper", _G.FruitSniper, function(v) _G.FruitSniper = v end)
frCh:Toggle("Auto Store", _G.AutoStore, function(v) _G.AutoStore = v end)
frCh:Toggle("Auto Roll", _G.AutoRoll, function(v) _G.AutoRoll = v end)

-- Movimento
local mCh = serv:Channel("🏃 Movimento")
mCh:Toggle("WalkSpeed", _G.WalkSpeed, function(v) _G.WalkSpeed = v end)
mCh:Slider("Velocidade", 16, 350, _G.WalkSpeedValue, function(v) _G.WalkSpeedValue = v end)
mCh:Toggle("JumpPower", _G.JumpPower, function(v) _G.JumpPower = v end)
mCh:Slider("Altura Pulo", 50, 300, _G.JumpPowerValue, function(v) _G.JumpPowerValue = v end)
mCh:Toggle("NoClip", _G.NoClip, function(v) _G.NoClip = v end)
mCh:Toggle("Fly (WASD)", _G.Fly, function(v) _G.Fly = v end)
mCh:Slider("Fly Speed", 10, 200, _G.FlySpeed, function(v) _G.FlySpeed = v end)

-- ESP
local eCh = serv:Channel("👁️ ESP")
eCh:Toggle("ESP Ligado", _G.ESP_Enabled, function(v) _G.ESP_Enabled = v end)
eCh:Toggle("ESP Players", _G.ESP_Players, function(v) _G.ESP_Players = v end)
eCh:Toggle("ESP Fruits", _G.ESP_Fruits, function(v) _G.ESP_Fruits = v end)
eCh:Slider("Alcance ESP", 100, 1000, _G.ESP_Range, function(v) _G.ESP_Range = v end)

-- Teleportes
local tCh = serv:Channel("🏝️ Teleportes")
for _, nome in ipairs(TeleportList) do
    tCh:Button(nome, function()
        local pos = TeleportCoords[nome]
        if pos then TP(pos) end
    end)
end

-- Configurações (SAVE/LOAD)
local cfgCh = serv:Channel("⚙️ Configurações")
cfgCh:Toggle("Auto Stats", _G.AutoStats, function(v) _G.AutoStats = v end)
cfgCh:Slider("Delay Ataque (ms)", 0, 500, _G.Fast_Delay*1000, function(v) _G.Fast_Delay = v/1000 end)
cfgCh:Button("💾 Salvar Config", function()
    ConfigManager:Save()
    DiscordLib:Notification("CONFIG", "💾 Configurações salvas!", "OK")
end)
cfgCh:Button("📂 Carregar Config", function()
    ConfigManager:Load()
    DiscordLib:Notification("CONFIG", "📂 Configurações carregadas!", "OK")
end)
cfgCh:Button("🔄 Resetar Config", function()
    ConfigManager:Reset()
    DiscordLib:Notification("CONFIG", "🔄 Configurações resetadas!", "OK")
end)

-- Status
local stCh = serv:Channel("📊 Status")
local statusLabel = stCh:Label("😴 Nada ativo")
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local status = GetStatus()
            local lv = Player.Data.Level.Value
            local sea = Sea1 and "1" or Sea2 and "2" or Sea3 and "3" or "?"
            statusLabel.Text = string.format("%s | Lv.%d | Sea %s", status, lv, sea)
        end)
    end
end)
stCh:Button("🔄 Atualizar Status", function()
    local status = GetStatus()
    local lv = Player.Data.Level.Value
    DiscordLib:Notification("STATUS", string.format("%s\nLevel: %d", status, lv), "OK")
end)
stCh:Button("🛑 Parar Tudo", function()
    _G.AutoFarm = false; _G.AutoBoss = false; _G.AutoClicker = false; _G.GodMode = false
    _G.FruitSniper = false; _G.AutoStore = false; _G.AutoRoll = false; _G.AutoStats = false
    _G.WalkSpeed = false; _G.JumpPower = false; _G.NoClip = false; _G.Fly = false
    _G.ESP_Enabled = false
    ConfigManager:Save()
    DiscordLib:Notification("NEXUS", "🛑 Tudo parado e salvo!", "OK")
end)

-- ============================================================
-- NOTIFICAÇÃO INICIAL
-- ============================================================
local lv = Player.Data.Level.Value
local sea = Sea1 and "1" or Sea2 and "2" or Sea3 and "3" or "?"
DiscordLib:Notification("NEXUS SUPREMO", 
    "✅ Script carregado!\n\n" ..
    "⚔️ Farm | 💀 Boss | 🖱️ Clicker\n" ..
    "🍎 Frutas | 🏃 Mov | 👁️ ESP | 🏝️ TP\n" ..
    "💾 Save/Load | 📊 Status\n\n" ..
    "Sea: " .. sea .. " | Level: " .. lv, 
    "🚀 VAMOS LÁ!"
)
