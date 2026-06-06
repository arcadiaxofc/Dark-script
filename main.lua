-- // ╔══════════════════════════════════════════════════════════╗
-- // ║         NEXUS v11.0 - DELTA OPTIMIZED                   ║
-- // ║   CORAÇÃO DO SCRIPT - Completo para Delta Executor      ║
-- // ╚══════════════════════════════════════════════════════════╝

-- ============================================================
-- DIAGNÓSTICO INICIAL (Para ver se está rodando)
-- ============================================================
print("=== NEXUS DELTA INICIADO ===")
print("Hora:", os.date("%H:%M:%S"))
print("PlaceId:", game.PlaceId)

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
        Title = "NEXUS DELTA", 
        Text = "Script exclusivo para Blox Fruits!\nPlaceId atual: " .. PlaceId, 
        Duration = 5
    })
    print("[ERRO] PlaceId inválido:", PlaceId)
    return
end
print("[OK] PlaceId válido:", PlaceId)

-- ============================================================
-- CARREGAMENTO DA UI (COM FALLBACK)
-- ============================================================
local DiscordLib = nil
local UI_Carregada = false

local UIs = {
    "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/UI_Library.lua",
    "https://raw.githubusercontent.com/script-organization/Hub/main/Library.lua",
    "https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua",
}

for _, url in ipairs(UIs) do
    if not UI_Carregada then
        local success, result = pcall(function()
            print("[UI] Tentando carregar:", url)
            return loadstring(game:HttpGet(url))()
        end)
        if success and result then
            DiscordLib = result
            UI_Carregada = true
            print("[UI] Carregada com sucesso!")
        else
            print("[UI] Falha ao carregar:", url)
        end
    end
end

-- Fallback: UI minimalista se nenhuma carregar
if not UI_Carregada then
    print("[UI] Usando fallback minimalista")
    DiscordLib = {
        Window = function(_, title) 
            print("[UI] Window:", title)
            return { 
                Server = function(_, name, id) 
                    print("[UI] Server:", name)
                    return {
                        Channel = function(_, channelName)
                            print("[UI] Channel:", channelName)
                            return {
                                Toggle = function(_, text, default, cb) 
                                    print("[UI] Toggle:", text, default)
                                    cb(default)
                                    return {}
                                end,
                                Dropdown = function(_, text, options, cb)
                                    print("[UI] Dropdown:", text)
                                    cb(options[1])
                                    return {}
                                end,
                                Slider = function(_, text, min, max, default, cb)
                                    print("[UI] Slider:", text, default)
                                    cb(default)
                                    return {}
                                end,
                                Button = function(_, text, cb)
                                    print("[UI] Button:", text)
                                    cb()
                                    return {}
                                end,
                                Label = function(_, text)
                                    print("[UI] Label:", text)
                                    return {}
                                end
                            }
                        end
                    }
                end
            }
        end,
        Notification = function(_, title, text, btn)
            print(string.format("[%s] %s", title, text))
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = title,
                    Text = text,
                    Duration = 5
                })
            end)
        end
    }
end

-- ============================================================
-- SERVIÇOS (SEM VIRTUALUSER)
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("[SERVIÇOS] Carregados com sucesso")

-- ============================================================
-- OTIMIZAÇÕES
-- ============================================================
if not Player.Character then
    print("[WAIT] Aguardando Character...")
    repeat task.wait(0.3) until Player.Character
end
print("[OK] Character encontrado:", Player.Character.Name)

task.wait(1)

pcall(function() 
    settings().Rendering.QualityLevel = 1 
    print("[OTIMIZAÇÃO] QualityLevel = 1")
end)
pcall(function() 
    Lighting.GlobalShadows = false 
    print("[OTIMIZAÇÃO] GlobalShadows = false")
end)
pcall(function() 
    Lighting.Brightness = 1.5 
end)
pcall(function() 
    Lighting.FogEnd = 5000 
end)

-- ============================================================
-- ANTI-AFK PARA DELTA (SEM VIRTUALUSER)
-- ============================================================
pcall(function()
    local idledConnections = getconnections and getconnections(Player.Idled) or {}
    for _, connection in ipairs(idledConnections) do
        connection:Disable()
        print("[ANTI-AFK] Conexão Idled desabilitada")
    end
end)

local lastInput = tick()
UserInputService.InputBegan:Connect(function()
    lastInput = tick()
end)

task.spawn(function()
    while task.wait(30) do
        if tick() - lastInput > 25 then
            pcall(function()
                local mouse = Player:GetMouse()
                if mouse then
                    local pos = mouse.X
                    mouse.Move(mouse.X + 1, mouse.Y)
                    task.wait(0.05)
                    mouse.Move(pos, mouse.Y)
                end
            end)
            lastInput = tick()
            print("[ANTI-AFK] Input simulado")
        end
    end
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
_G.Fast_Delay = 0.1
_G.StopTween = false
_G.Range = 300
_G.WeaponName = "None"

-- Variáveis GLOBAIS para CheckLevel
_G.Ms = ""
_G.NameQuest = ""
_G.QuestLv = 1
_G.NameMon = ""
_G.CFrameQ = CFrame.new(0,0,0)
_G.CFrameMon = CFrame.new(0,0,0)

print("[FLAGS] Configurações globais inicializadas")

-- ============================================================
-- DETECÇÃO DE SEA
-- ============================================================
local Sea1 = game.PlaceId == 2753915549
local Sea2 = game.PlaceId == 4442272183
local Sea3 = game.PlaceId == 7449423635

print("[SEA] Sea1:", Sea1, "Sea2:", Sea2, "Sea3:", Sea3)

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
print("[BOSSES]", #BossList, "bosses carregados")

-- ============================================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================================
local function GetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local comm = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF")
        if comm then return comm end
    end
    local comm = ReplicatedStorage:FindFirstChild("CommF_") or ReplicatedStorage:FindFirstChild("CommF")
    return comm
end

local function TP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end

local function TweenTP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local dist = (pos.Position - hrp.Position).Magnitude
    local duration = math.min(dist / 350, 3)
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = pos})
    tween:Play()
    return tween
end

local function Attack()
    pcall(function()
        local mouse = Player:GetMouse()
        if mouse and mouse.Target then
            mouse:Button1Down()
            task.wait(_G.Fast_Delay)
            mouse:Button1Up()
        end
        
        local remote = GetRemote()
        if remote then
            remote:InvokeServer("Attack")
        end
    end)
end

local function FastAttack()
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Modules")
        if net then net = net:FindFirstChild("Net") end
        if not net then return end
        
        local registerAttack = net:FindFirstChild("RE/RegisterAttack")
        local registerHit = net:FindFirstChild("RE/RegisterHit")
        
        if registerAttack then
            registerAttack:FireServer(0.01)
        end
        
        local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not myPos then return end
        
        local enemiesFolder = Workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return end
        
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local head = enemy:FindFirstChild("Head")
                if head and registerHit then
                    local distance = (myPos.Position - head.Position).Magnitude
                    if distance <= 60 then
                        registerHit:FireServer(head, {{enemy, head}})
                    end
                end
            end
        end
    end)
end

local function EquipWeapon()
    pcall(function()
        local toolName = nil
        for _, tool in pairs(Player.Backpack:GetChildren()) do
            if tool.ToolTip == _G.SelectWeapon then
                toolName = tool.Name
                _G.WeaponName = tool.Name
                Player.Character.Humanoid:EquipTool(tool)
                break
            end
        end
        
        if not toolName then
            for _, tool in pairs(Player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == _G.SelectWeapon then
                    _G.WeaponName = tool.Name
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
                if mob:IsA("Model") and string.lower(mob.Name):find(string.lower(name), 1, true) then
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
-- DADOS DO JOGO - CheckLevel CORRIGIDO
-- ============================================================
function CheckLevel()
    local lv = Player.Data.Level.Value
    
    if Sea1 then
        if lv <= 9 then
            _G.Ms = "Bandit"
            _G.NameQuest = "BanditQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Bandit"
            _G.CFrameQ = CFrame.new(1060.94, 16.46, 1547.78)
            _G.CFrameMon = CFrame.new(1038.55, 41.30, 1576.51)
        elseif lv <= 14 then
            _G.Ms = "Monkey"
            _G.NameQuest = "JungleQuest"
            _G.QuestLv = 1
            _G.NameMon = "Monkey"
            _G.CFrameQ = CFrame.new(-1601.66, 36.85, 153.39)
            _G.CFrameMon = CFrame.new(-1448.14, 50.85, 63.61)
        elseif lv <= 29 then
            _G.Ms = "Gorilla"
            _G.NameQuest = "JungleQuest"
            _G.QuestLv = 2
            _G.NameMon = "Gorilla"
            _G.CFrameQ = CFrame.new(-1601.66, 36.85, 153.39)
            _G.CFrameMon = CFrame.new(-1142.65, 40.46, -515.39)
        elseif lv <= 39 then
            _G.Ms = "Pirate"
            _G.NameQuest = "BuggyQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Pirate"
            _G.CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41)
            _G.CFrameMon = CFrame.new(-1201.09, 40.63, 3857.60)
        elseif lv <= 59 then
            _G.Ms = "Brute"
            _G.NameQuest = "BuggyQuest1"
            _G.QuestLv = 2
            _G.NameMon = "Brute"
            _G.CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41)
            _G.CFrameMon = CFrame.new(-1387.53, 24.59, 4100.96)
        elseif lv <= 74 then
            _G.Ms = "Desert Bandit"
            _G.NameQuest = "DesertQuest"
            _G.QuestLv = 1
            _G.NameMon = "Desert Bandit"
            _G.CFrameQ = CFrame.new(896.52, 6.44, 4390.15)
            _G.CFrameMon = CFrame.new(985.00, 16.11, 4417.91)
        elseif lv <= 89 then
            _G.Ms = "Desert Officer"
            _G.NameQuest = "DesertQuest"
            _G.QuestLv = 2
            _G.NameMon = "Desert Officer"
            _G.CFrameQ = CFrame.new(896.52, 6.44, 4390.15)
            _G.CFrameMon = CFrame.new(1547.15, 14.45, 4381.80)
        elseif lv <= 99 then
            _G.Ms = "Snow Bandit"
            _G.NameQuest = "SnowQuest"
            _G.QuestLv = 1
            _G.NameMon = "Snow Bandit"
            _G.CFrameQ = CFrame.new(1386.81, 87.27, -1298.36)
            _G.CFrameMon = CFrame.new(1356.30, 105.77, -1328.24)
        elseif lv <= 119 then
            _G.Ms = "Snowman"
            _G.NameQuest = "SnowQuest"
            _G.QuestLv = 2
            _G.NameMon = "Snowman"
            _G.CFrameQ = CFrame.new(1386.81, 87.27, -1298.36)
            _G.CFrameMon = CFrame.new(1218.80, 138.01, -1488.03)
        elseif lv <= 149 then
            _G.Ms = "Chief Petty Officer"
            _G.NameQuest = "MarineQuest2"
            _G.QuestLv = 1
            _G.NameMon = "Chief Petty Officer"
            _G.CFrameQ = CFrame.new(-5035.50, 28.68, 4324.18)
            _G.CFrameMon = CFrame.new(-4931.16, 65.79, 4121.84)
        elseif lv <= 174 then
            _G.Ms = "Sky Bandit"
            _G.NameQuest = "SkyQuest"
            _G.QuestLv = 1
            _G.NameMon = "Sky Bandit"
            _G.CFrameQ = CFrame.new(-4842.14, 717.70, -2623.05)
            _G.CFrameMon = CFrame.new(-4955.64, 365.46, -2908.19)
        elseif lv <= 209 then
            _G.Ms = "Prisoner"
            _G.NameQuest = "PrisonerQuest"
            _G.QuestLv = 1
            _G.NameMon = "Prisoner"
            _G.CFrameQ = CFrame.new(5310.61, 0.35, 474.95)
            _G.CFrameMon = CFrame.new(4937.32, 0.33, 649.57)
        elseif lv <= 249 then
            _G.Ms = "Dangerous Prisoner"
            _G.NameQuest = "PrisonerQuest"
            _G.QuestLv = 2
            _G.NameMon = "Dangerous Prisoner"
            _G.CFrameQ = CFrame.new(5310.61, 0.35, 474.95)
            _G.CFrameMon = CFrame.new(5099.66, 0.35, 1055.76)
        elseif lv <= 274 then
            _G.Ms = "Toga Warrior"
            _G.NameQuest = "ColosseumQuest"
            _G.QuestLv = 1
            _G.NameMon = "Toga Warrior"
            _G.CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48)
            _G.CFrameMon = CFrame.new(-1872.52, 49.08, -2913.81)
        elseif lv <= 299 then
            _G.Ms = "Gladiator"
            _G.NameQuest = "ColosseumQuest"
            _G.QuestLv = 2
            _G.NameMon = "Gladiator"
            _G.CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48)
            _G.CFrameMon = CFrame.new(-1521.37, 81.20, -3066.31)
        elseif lv <= 324 then
            _G.Ms = "Military Soldier"
            _G.NameQuest = "MagmaQuest"
            _G.QuestLv = 1
            _G.NameMon = "Military Soldier"
            _G.CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00)
            _G.CFrameMon = CFrame.new(-5369.00, 61.24, 8556.49)
        elseif lv <= 374 then
            _G.Ms = "Military Spy"
            _G.NameQuest = "MagmaQuest"
            _G.QuestLv = 2
            _G.NameMon = "Military Spy"
            _G.CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00)
            _G.CFrameMon = CFrame.new(-5787.00, 75.83, 8651.70)
        elseif lv <= 399 then
            _G.Ms = "Fishman Warrior"
            _G.NameQuest = "FishmanQuest"
            _G.QuestLv = 1
            _G.NameMon = "Fishman Warrior"
            _G.CFrameQ = CFrame.new(61122.65, 18.50, 1569.40)
            _G.CFrameMon = CFrame.new(60844.11, 98.46, 1298.40)
        elseif lv <= 449 then
            _G.Ms = "Fishman Commando"
            _G.NameQuest = "FishmanQuest"
            _G.QuestLv = 2
            _G.NameMon = "Fishman Commando"
            _G.CFrameQ = CFrame.new(61122.65, 18.50, 1569.40)
            _G.CFrameMon = CFrame.new(61738.40, 64.21, 1433.84)
        elseif lv <= 474 then
            _G.Ms = "God's Guard"
            _G.NameQuest = "SkyExp1Quest"
            _G.QuestLv = 1
            _G.NameMon = "God's Guard"
            _G.CFrameQ = CFrame.new(-4721.86, 845.30, -1953.85)
            _G.CFrameMon = CFrame.new(-4628.05, 866.93, -1931.24)
        elseif lv <= 524 then
            _G.Ms = "Shanda"
            _G.NameQuest = "SkyExp1Quest"
            _G.QuestLv = 2
            _G.NameMon = "Shanda"
            _G.CFrameQ = CFrame.new(-7863.16, 5545.52, -378.42)
            _G.CFrameMon = CFrame.new(-7685.15, 5601.08, -441.39)
        elseif lv <= 549 then
            _G.Ms = "Royal Squad"
            _G.NameQuest = "SkyExp2Quest"
            _G.QuestLv = 1
            _G.NameMon = "Royal Squad"
            _G.CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92)
            _G.CFrameMon = CFrame.new(-7654.25, 5637.11, -1407.76)
        elseif lv <= 624 then
            _G.Ms = "Royal Soldier"
            _G.NameQuest = "SkyExp2Quest"
            _G.QuestLv = 2
            _G.NameMon = "Royal Soldier"
            _G.CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92)
            _G.CFrameMon = CFrame.new(-7760.41, 5679.91, -1884.81)
        elseif lv <= 649 then
            _G.Ms = "Galley Pirate"
            _G.NameQuest = "FountainQuest"
            _G.QuestLv = 1
            _G.NameMon = "Galley Pirate"
            _G.CFrameQ = CFrame.new(5258.28, 38.53, 4050.04)
            _G.CFrameMon = CFrame.new(5557.17, 152.33, 3998.78)
        else
            _G.Ms = "Galley Captain"
            _G.NameQuest = "FountainQuest"
            _G.QuestLv = 2
            _G.NameMon = "Galley Captain"
            _G.CFrameQ = CFrame.new(5258.28, 38.53, 4050.04)
            _G.CFrameMon = CFrame.new(5677.68, 92.79, 4966.63)
        end
    elseif Sea2 then
        if lv <= 724 then
            _G.Ms = "Raider"
            _G.NameQuest = "Area1Quest"
            _G.QuestLv = 1
            _G.NameMon = "Raider"
            _G.CFrameQ = CFrame.new(-427.73, 73.00, 1835.94)
            _G.CFrameMon = CFrame.new(68.87, 93.64, 2429.68)
        elseif lv <= 774 then
            _G.Ms = "Mercenary"
            _G.NameQuest = "Area1Quest"
            _G.QuestLv = 2
            _G.NameMon = "Mercenary"
            _G.CFrameQ = CFrame.new(-427.73, 73.00, 1835.94)
            _G.CFrameMon = CFrame.new(-864.85, 122.47, 1453.15)
        elseif lv <= 799 then
            _G.Ms = "Swan Pirate"
            _G.NameQuest = "Area2Quest"
            _G.QuestLv = 1
            _G.NameMon = "Swan Pirate"
            _G.CFrameQ = CFrame.new(635.61, 73.10, 917.81)
            _G.CFrameMon = CFrame.new(1065.37, 137.64, 1324.38)
        elseif lv <= 874 then
            _G.Ms = "Factory Staff"
            _G.NameQuest = "Area2Quest"
            _G.QuestLv = 2
            _G.NameMon = "Factory Staff"
            _G.CFrameQ = CFrame.new(635.61, 73.10, 917.81)
            _G.CFrameMon = CFrame.new(533.22, 128.47, 355.63)
        elseif lv <= 899 then
            _G.Ms = "Marine Lieutenant"
            _G.NameQuest = "MarineQuest3"
            _G.QuestLv = 1
            _G.NameMon = "Marine Lieutenant"
            _G.CFrameQ = CFrame.new(-2440.99, 73.04, -3217.71)
            _G.CFrameMon = CFrame.new(-2489.26, 84.61, -3151.88)
        elseif lv <= 949 then
            _G.Ms = "Marine Captain"
            _G.NameQuest = "MarineQuest3"
            _G.QuestLv = 2
            _G.NameMon = "Marine Captain"
            _G.CFrameQ = CFrame.new(-2440.99, 73.04, -3217.71)
            _G.CFrameMon = CFrame.new(-2335.20, 79.79, -3245.87)
        elseif lv <= 974 then
            _G.Ms = "Zombie"
            _G.NameQuest = "ZombieQuest"
            _G.QuestLv = 1
            _G.NameMon = "Zombie"
            _G.CFrameQ = CFrame.new(-5494.34, 48.51, -794.59)
            _G.CFrameMon = CFrame.new(-5536.50, 101.09, -835.59)
        elseif lv <= 999 then
            _G.Ms = "Vampire"
            _G.NameQuest = "ZombieQuest"
            _G.QuestLv = 2
            _G.NameMon = "Vampire"
            _G.CFrameQ = CFrame.new(-5494.34, 48.51, -794.59)
            _G.CFrameMon = CFrame.new(-5806.11, 16.72, -1164.44)
        elseif lv <= 1049 then
            _G.Ms = "Snow Trooper"
            _G.NameQuest = "SnowMountainQuest"
            _G.QuestLv = 1
            _G.NameMon = "Snow Trooper"
            _G.CFrameQ = CFrame.new(607.06, 401.45, -5370.55)
            _G.CFrameMon = CFrame.new(535.21, 432.74, -5484.92)
        elseif lv <= 1099 then
            _G.Ms = "Winter Warrior"
            _G.NameQuest = "SnowMountainQuest"
            _G.QuestLv = 2
            _G.NameMon = "Winter Warrior"
            _G.CFrameQ = CFrame.new(607.06, 401.45, -5370.55)
            _G.CFrameMon = CFrame.new(1234.44, 456.95, -5174.13)
        elseif lv <= 1124 then
            _G.Ms = "Lab Subordinate"
            _G.NameQuest = "IceSideQuest"
            _G.QuestLv = 1
            _G.NameMon = "Lab Subordinate"
            _G.CFrameQ = CFrame.new(-6061.84, 15.93, -4902.04)
            _G.CFrameMon = CFrame.new(-5720.56, 63.31, -4784.61)
        elseif lv <= 1174 then
            _G.Ms = "Horned Warrior"
            _G.NameQuest = "IceSideQuest"
            _G.QuestLv = 2
            _G.NameMon = "Horned Warrior"
            _G.CFrameQ = CFrame.new(-6061.84, 15.93, -4902.04)
            _G.CFrameMon = CFrame.new(-6292.75, 91.18, -5502.65)
        elseif lv <= 1199 then
            _G.Ms = "Magma Ninja"
            _G.NameQuest = "FireSideQuest"
            _G.QuestLv = 1
            _G.NameMon = "Magma Ninja"
            _G.CFrameQ = CFrame.new(-5429.05, 15.98, -5297.96)
            _G.CFrameMon = CFrame.new(-5461.84, 130.36, -5836.47)
        elseif lv <= 1249 then
            _G.Ms = "Lava Pirate"
            _G.NameQuest = "FireSideQuest"
            _G.QuestLv = 2
            _G.NameMon = "Lava Pirate"
            _G.CFrameQ = CFrame.new(-5429.05, 15.98, -5297.96)
            _G.CFrameMon = CFrame.new(-5251.19, 55.16, -4774.41)
        elseif lv <= 1274 then
            _G.Ms = "Ship Deckhand"
            _G.NameQuest = "ShipQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Ship Deckhand"
            _G.CFrameQ = CFrame.new(1040.29, 125.08, 32911.04)
            _G.CFrameMon = CFrame.new(921.12, 125.98, 33088.33)
        elseif lv <= 1299 then
            _G.Ms = "Ship Engineer"
            _G.NameQuest = "ShipQuest1"
            _G.QuestLv = 2
            _G.NameMon = "Ship Engineer"
            _G.CFrameQ = CFrame.new(1040.29, 125.08, 32911.04)
            _G.CFrameMon = CFrame.new(886.28, 40.48, 32800.83)
        elseif lv <= 1324 then
            _G.Ms = "Ship Steward"
            _G.NameQuest = "ShipQuest2"
            _G.QuestLv = 1
            _G.NameMon = "Ship Steward"
            _G.CFrameQ = CFrame.new(971.42, 125.08, 33245.54)
            _G.CFrameMon = CFrame.new(943.86, 129.58, 33444.37)
        elseif lv <= 1349 then
            _G.Ms = "Ship Officer"
            _G.NameQuest = "ShipQuest2"
            _G.QuestLv = 2
            _G.NameMon = "Ship Officer"
            _G.CFrameQ = CFrame.new(971.42, 125.08, 33245.54)
            _G.CFrameMon = CFrame.new(955.38, 181.08, 33331.89)
        elseif lv <= 1374 then
            _G.Ms = "Arctic Warrior"
            _G.NameQuest = "FrostQuest"
            _G.QuestLv = 1
            _G.NameMon = "Arctic Warrior"
            _G.CFrameQ = CFrame.new(5668.14, 28.20, -6484.60)
            _G.CFrameMon = CFrame.new(5935.45, 77.26, -6472.76)
        elseif lv <= 1424 then
            _G.Ms = "Snow Lurker"
            _G.NameQuest = "FrostQuest"
            _G.QuestLv = 2
            _G.NameMon = "Snow Lurker"
            _G.CFrameQ = CFrame.new(5668.14, 28.20, -6484.60)
            _G.CFrameMon = CFrame.new(5628.48, 57.57, -6618.35)
        elseif lv <= 1449 then
            _G.Ms = "Sea Soldier"
            _G.NameQuest = "ForgottenQuest"
            _G.QuestLv = 1
            _G.NameMon = "Sea Soldier"
            _G.CFrameQ = CFrame.new(-3054.58, 236.87, -10147.79)
            _G.CFrameMon = CFrame.new(-3185.02, 58.79, -9663.61)
        else
            _G.Ms = "Water Fighter"
            _G.NameQuest = "ForgottenQuest"
            _G.QuestLv = 2
            _G.NameMon = "Water Fighter"
            _G.CFrameQ = CFrame.new(-3054.58, 236.87, -10147.79)
            _G.CFrameMon = CFrame.new(-3262.93, 298.69, -10552.53)
        end
    elseif Sea3 then
        if lv <= 1524 then
            _G.Ms = "Pirate Millionaire"
            _G.NameQuest = "PiratePortQuest"
            _G.QuestLv = 1
            _G.NameMon = "Pirate Millionaire"
            _G.CFrameQ = CFrame.new(-450.10, 107.68, 5950.73)
            _G.CFrameMon = CFrame.new(-193.99, 56.13, 5755.79)
        elseif lv <= 1574 then
            _G.Ms = "Pistol Billionaire"
            _G.NameQuest = "PiratePortQuest"
            _G.QuestLv = 2
            _G.NameMon = "Pistol Billionaire"
            _G.CFrameQ = CFrame.new(-450.10, 107.68, 5950.73)
            _G.CFrameMon = CFrame.new(-188.14, 84.50, 6337.04)
        elseif lv <= 1599 then
            _G.Ms = "Dragon Crew Warrior"
            _G.NameQuest = "DragonCrewQuest"
            _G.QuestLv = 1
            _G.NameMon = "Dragon Crew Warrior"
            _G.CFrameQ = CFrame.new(6735.11, 126.99, -711.10)
            _G.CFrameMon = CFrame.new(6615.23, 50.85, -978.93)
        elseif lv <= 1624 then
            _G.Ms = "Dragon Crew Archer"
            _G.NameQuest = "DragonCrewQuest"
            _G.QuestLv = 2
            _G.NameMon = "Dragon Crew Archer"
            _G.CFrameQ = CFrame.new(6735.11, 126.99, -711.10)
            _G.CFrameMon = CFrame.new(6818.59, 483.72, 512.73)
        elseif lv <= 1649 then
            _G.Ms = "Hydra Enforcer"
            _G.NameQuest = "VenomCrewQuest"
            _G.QuestLv = 1
            _G.NameMon = "Hydra Enforcer"
            _G.CFrameQ = CFrame.new(5446.88, 601.63, 749.46)
            _G.CFrameMon = CFrame.new(4547.12, 1001.60, 334.20)
        elseif lv <= 1699 then
            _G.Ms = "Venomous Assailant"
            _G.NameQuest = "VenomCrewQuest"
            _G.QuestLv = 2
            _G.NameMon = "Venomous Assailant"
            _G.CFrameQ = CFrame.new(5446.88, 601.63, 749.46)
            _G.CFrameMon = CFrame.new(4637.89, 1077.86, 882.42)
        elseif lv <= 1724 then
            _G.Ms = "Marine Commodore"
            _G.NameQuest = "MarineTreeIsland"
            _G.QuestLv = 1
            _G.NameMon = "Marine Commodore"
            _G.CFrameQ = CFrame.new(2179.99, 28.73, -6740.06)
            _G.CFrameMon = CFrame.new(2198.01, 128.71, -7109.50)
        elseif lv <= 1774 then
            _G.Ms = "Marine Rear Admiral"
            _G.NameQuest = "MarineTreeIsland"
            _G.QuestLv = 2
            _G.NameMon = "Marine Rear Admiral"
            _G.CFrameQ = CFrame.new(2179.99, 28.73, -6740.06)
            _G.CFrameMon = CFrame.new(3294.31, 385.41, -7048.63)
        elseif lv <= 1799 then
            _G.Ms = "Fishman Raider"
            _G.NameQuest = "DeepForestIsland3"
            _G.QuestLv = 1
            _G.NameMon = "Fishman Raider"
            _G.CFrameQ = CFrame.new(-10582.76, 331.79, -8757.67)
            _G.CFrameMon = CFrame.new(-10553.27, 521.38, -8176.95)
        elseif lv <= 1824 then
            _G.Ms = "Fishman Captain"
            _G.NameQuest = "DeepForestIsland3"
            _G.QuestLv = 2
            _G.NameMon = "Fishman Captain"
            _G.CFrameQ = CFrame.new(-10583.10, 331.79, -8759.46)
            _G.CFrameMon = CFrame.new(-10789.40, 427.19, -9131.44)
        elseif lv <= 1849 then
            _G.Ms = "Forest Pirate"
            _G.NameQuest = "DeepForestIsland"
            _G.QuestLv = 1
            _G.NameMon = "Forest Pirate"
            _G.CFrameQ = CFrame.new(-13232.66, 332.40, -7626.48)
            _G.CFrameMon = CFrame.new(-13489.40, 400.30, -7770.25)
        elseif lv <= 1899 then
            _G.Ms = "Mythological Pirate"
            _G.NameQuest = "DeepForestIsland"
            _G.QuestLv = 2
            _G.NameMon = "Mythological Pirate"
            _G.CFrameQ = CFrame.new(-13232.66, 332.40, -7626.48)
            _G.CFrameMon = CFrame.new(-13508.62, 582.46, -6985.30)
        elseif lv <= 1924 then
            _G.Ms = "Jungle Pirate"
            _G.NameQuest = "DeepForestIsland2"
            _G.QuestLv = 1
            _G.NameMon = "Jungle Pirate"
            _G.CFrameQ = CFrame.new(-12682.10, 390.89, -9902.12)
            _G.CFrameMon = CFrame.new(-12267.10, 459.75, -10277.20)
        elseif lv <= 1974 then
            _G.Ms = "Musketeer Pirate"
            _G.NameQuest = "DeepForestIsland2"
            _G.QuestLv = 2
            _G.NameMon = "Musketeer Pirate"
            _G.CFrameQ = CFrame.new(-12682.10, 390.89, -9902.12)
            _G.CFrameMon = CFrame.new(-13291.51, 520.47, -9904.64)
        elseif lv <= 1999 then
            _G.Ms = "Reborn Skeleton"
            _G.NameQuest = "HauntedQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Reborn Skeleton"
            _G.CFrameQ = CFrame.new(-9480.81, 142.13, 5566.37)
            _G.CFrameMon = CFrame.new(-8761.77, 183.43, 6168.33)
        elseif lv <= 2024 then
            _G.Ms = "Living Zombie"
            _G.NameQuest = "HauntedQuest1"
            _G.QuestLv = 2
            _G.NameMon = "Living Zombie"
            _G.CFrameQ = CFrame.new(-9480.81, 142.13, 5566.37)
            _G.CFrameMon = CFrame.new(-10103.75, 238.57, 6179.76)
        elseif lv <= 2049 then
            _G.Ms = "Demonic Soul"
            _G.NameQuest = "HauntedQuest2"
            _G.QuestLv = 1
            _G.NameMon = "Demonic Soul"
            _G.CFrameQ = CFrame.new(-9516.99, 178.01, 6078.47)
            _G.CFrameMon = CFrame.new(-9712.03, 204.70, 6193.32)
        elseif lv <= 2074 then
            _G.Ms = "Posessed Mummy"
            _G.NameQuest = "HauntedQuest2"
            _G.QuestLv = 2
            _G.NameMon = "Posessed Mummy"
            _G.CFrameQ = CFrame.new(-9516.99, 178.01, 6078.47)
            _G.CFrameMon = CFrame.new(-9545.78, 69.62, 6339.56)
        elseif lv <= 2099 then
            _G.Ms = "Peanut Scout"
            _G.NameQuest = "NutsIslandQuest"
            _G.QuestLv = 1
            _G.NameMon = "Peanut Scout"
            _G.CFrameQ = CFrame.new(-2105.53, 37.25, -10195.51)
            _G.CFrameMon = CFrame.new(-2150.59, 122.50, -10358.99)
        elseif lv <= 2124 then
            _G.Ms = "Peanut President"
            _G.NameQuest = "NutsIslandQuest"
            _G.QuestLv = 2
            _G.NameMon = "Peanut President"
            _G.CFrameQ = CFrame.new(-2105.53, 37.25, -10195.51)
            _G.CFrameMon = CFrame.new(-2150.59, 122.50, -10358.99)
        elseif lv <= 2149 then
            _G.Ms = "Ice Cream Chef"
            _G.NameQuest = "IceCreamIslandQuest"
            _G.QuestLv = 1
            _G.NameMon = "Ice Cream Chef"
            _G.CFrameQ = CFrame.new(-819.38, 64.93, -10967.28)
            _G.CFrameMon = CFrame.new(-789.94, 209.38, -11009.98)
        elseif lv <= 2199 then
            _G.Ms = "Ice Cream Commander"
            _G.NameQuest = "IceCreamIslandQuest"
            _G.QuestLv = 2
            _G.NameMon = "Ice Cream Commander"
            _G.CFrameQ = CFrame.new(-819.38, 64.93, -10967.28)
            _G.CFrameMon = CFrame.new(-789.94, 209.38, -11009.98)
        elseif lv <= 2224 then
            _G.Ms = "Cookie Crafter"
            _G.NameQuest = "CakeQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Cookie Crafter"
            _G.CFrameQ = CFrame.new(-2022.30, 36.93, -12030.98)
            _G.CFrameMon = CFrame.new(-2321.71, 36.70, -12216.79)
        elseif lv <= 2249 then
            _G.Ms = "Cake Guard"
            _G.NameQuest = "CakeQuest1"
            _G.QuestLv = 2
            _G.NameMon = "Cake Guard"
            _G.CFrameQ = CFrame.new(-2022.30, 36.93, -12030.98)
            _G.CFrameMon = CFrame.new(-1418.11, 36.67, -12255.73)
        elseif lv <= 2274 then
            _G.Ms = "Baking Staff"
            _G.NameQuest = "CakeQuest2"
            _G.QuestLv = 1
            _G.NameMon = "Baking Staff"
            _G.CFrameQ = CFrame.new(-1928.32, 37.73, -12840.63)
            _G.CFrameMon = CFrame.new(-1980.44, 36.67, -12983.84)
        elseif lv <= 2299 then
            _G.Ms = "Head Baker"
            _G.NameQuest = "CakeQuest2"
            _G.QuestLv = 2
            _G.NameMon = "Head Baker"
            _G.CFrameQ = CFrame.new(-1928.32, 37.73, -12840.63)
            _G.CFrameMon = CFrame.new(-2251.58, 52.27, -13033.40)
        elseif lv <= 2324 then
            _G.Ms = "Cocoa Warrior"
            _G.NameQuest = "ChocQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Cocoa Warrior"
            _G.CFrameQ = CFrame.new(231.75, 23.90, -12200.29)
            _G.CFrameMon = CFrame.new(167.98, 26.23, -12238.87)
        elseif lv <= 2349 then
            _G.Ms = "Chocolate Bar Battler"
            _G.NameQuest = "ChocQuest1"
            _G.QuestLv = 2
            _G.NameMon = "Chocolate Bar Battler"
            _G.CFrameQ = CFrame.new(231.75, 23.90, -12200.29)
            _G.CFrameMon = CFrame.new(701.31, 25.58, -12708.21)
        elseif lv <= 2374 then
            _G.Ms = "Sweet Thief"
            _G.NameQuest = "ChocQuest2"
            _G.QuestLv = 1
            _G.NameMon = "Sweet Thief"
            _G.CFrameQ = CFrame.new(151.20, 23.89, -12774.62)
            _G.CFrameMon = CFrame.new(-140.26, 25.58, -12652.31)
        elseif lv <= 2400 then
            _G.Ms = "Candy Rebel"
            _G.NameQuest = "ChocQuest2"
            _G.QuestLv = 2
            _G.NameMon = "Candy Rebel"
            _G.CFrameQ = CFrame.new(151.20, 23.89, -12774.62)
            _G.CFrameMon = CFrame.new(47.92, 25.58, -13029.24)
        elseif lv <= 2424 then
            _G.Ms = "Candy Pirate"
            _G.NameQuest = "CandyQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Candy Pirate"
            _G.CFrameQ = CFrame.new(-1149.33, 13.58, -14445.61)
            _G.CFrameMon = CFrame.new(-1437.56, 17.15, -14385.69)
        elseif lv <= 2449 then
            _G.Ms = "Snow Demon"
            _G.NameQuest = "CandyQuest1"
            _G.QuestLv = 2
            _G.NameMon = "Snow Demon"
            _G.CFrameQ = CFrame.new(-1149.33, 13.58, -14445.61)
            _G.CFrameMon = CFrame.new(-916.22, 17.15, -14638.81)
        elseif lv <= 2474 then
            _G.Ms = "Isle Outlaw"
            _G.NameQuest = "TikiQuest1"
            _G.QuestLv = 1
            _G.NameMon = "Isle Outlaw"
            _G.CFrameQ = CFrame.new(-16549.89, 55.69, -179.91)
            _G.CFrameMon = CFrame.new(-16162.82, 11.69, -96.45)
        elseif lv <= 2499 then
            _G.Ms = "Island Boy"
            _G.NameQuest = "TikiQuest1"
            _G.QuestLv = 2
            _G.NameMon = "Island Boy"
            _G.CFrameQ = CFrame.new(-16549.89, 55.69, -179.91)
            _G.CFrameMon = CFrame.new(-16357.31, 20.63, 1005.65)
        elseif lv <= 2524 then
            _G.Ms = "Sun-kissed Warrior"
            _G.NameQuest = "TikiQuest2"
            _G.QuestLv = 1
            _G.NameMon = "Sun-kissed Warrior"
            _G.CFrameQ = CFrame.new(-16541.02, 54.77, 1051.46)
            _G.CFrameMon = CFrame.new(-16357.31, 20.63, 1005.65)
        elseif lv <= 2549 then
            _G.Ms = "Isle Champion"
            _G.NameQuest = "TikiQuest2"
            _G.QuestLv = 2
            _G.NameMon = "Isle Champion"
            _G.CFrameQ = CFrame.new(-16541.02, 54.77, 1051.46)
            _G.CFrameMon = CFrame.new(-16848.94, 21.69, 1041.45)
        elseif lv <= 2574 then
            _G.Ms = "Serpent Hunter"
            _G.NameQuest = "TikiQuest3"
            _G.QuestLv = 1
            _G.NameMon = "Serpent Hunter"
            _G.CFrameQ = CFrame.new(-16665.19, 104.60, 1579.69)
            _G.CFrameMon = CFrame.new(-16621.41, 121.41, 1290.69)
        else
            _G.Ms = "Skull Slayer"
            _G.NameQuest = "TikiQuest3"
            _G.QuestLv = 2
            _G.NameMon = "Skull Slayer"
            _G.CFrameQ = CFrame.new(-16665.19, 104.60, 1579.69)
            _G.CFrameMon = CFrame.new(-16811.57, 84.63, 1542.24)
        end
    end
    
    print("[CHECKLEVEL] Ms:", _G.Ms, "| Quest:", _G.NameQuest, "| Level:", lv)
end

-- ============================================================
-- AUTO FARM LOOP (CORRIGIDO - VAI ATRÁS DOS MOBS)
-- ============================================================
task.spawn(function()
    print("[AUTO FARM] Loop iniciado")
    while task.wait(0.1) do
        if not _G.AutoFarm then 
            task.wait(1)
            continue 
        end
        
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
                                if title and title.Text and _G.NameMon and title.Text:find(_G.NameMon) then
                                    hasQuest = true
                                end
                            end
                        end
                    end
                end
            end)
            
            if not hasQuest and _G.AutoQuest then
                print("[AUTO FARM] Pegando quest:", _G.NameQuest)
                local remote = GetRemote()
                if remote then
                    remote:InvokeServer("AbandonQuest")
                    task.wait(0.3)
                    TweenTP(_G.CFrameQ)
                    task.wait(1)
                    if _G.CFrameQ and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (_G.CFrameQ.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= 15 then
                            remote:InvokeServer("StartQuest", _G.NameQuest, _G.QuestLv)
                            print("[AUTO FARM] Quest iniciada!")
                        end
                    end
                end
                return
            end
            
            if hasQuest or not _G.AutoQuest then
                EquipWeapon()
                
                if _G.AutoHaki then
                    pcall(function()
                        if not Player.Character:FindFirstChild("HasBuso") then
                            local remote = GetRemote()
                            if remote then remote:InvokeServer("Buso") end
                        end
                    end)
                end
                
                local foundMob = false
                local enemiesFolder = Workspace:FindFirstChild("Enemies")
                if enemiesFolder then
                    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if myPos then
                        for _, enemy in pairs(enemiesFolder:GetChildren()) do
                            if foundMob then break end
                            if enemy:IsA("Model") and enemy.Name == _G.Ms then
                                local hum = enemy:FindFirstChild("Humanoid")
                                if hum and hum.Health > 0 then
                                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        foundMob = true
                                        
                                        if _G.BringMob then
                                            hrp.CFrame = myPos.CFrame * CFrame.new(0, 5, 5)
                                            hum.WalkSpeed = 0
                                            hum.JumpPower = 0
                                        else
                                            local distance = (hrp.Position - myPos.Position).Magnitude
                                            if distance > 15 then
                                                TP(hrp.Position)
                                                task.wait(0.3)
                                            end
                                        end
                                        
                                        for attackCount = 1, 30 do
                                            if not _G.AutoFarm then break end
                                            if hum.Health <= 0 then break end
                                            
                                            if _G.FastAttack then
                                                FastAttack()
                                            else
                                                Attack()
                                            end
                                            task.wait(0.15)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if not foundMob then
                    print("[AUTO FARM] Indo para área de spawn:", _G.NameMon)
                    TweenTP(_G.CFrameMon)
                    task.wait(1)
                end
            end
        end)
    end
end)

-- ============================================================
-- AUTO BOSS LOOP
-- ============================================================
task.spawn(function()
    print("[AUTO BOSS] Loop iniciado")
    while task.wait(0.5) do
        if not _G.AutoBoss or _G.SelectBoss == "" then 
            task.wait(1)
            continue 
        end
        if _G.AutoFarm then continue end
        
        pcall(function()
            local boss = FindBoss(_G.SelectBoss)
            if boss then
                local bossHrp = boss:FindFirstChild("HumanoidRootPart")
                if bossHrp then
                    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if myPos and (bossHrp.Position - myPos.Position).Magnitude > 15 then
                        TP(bossHrp.Position)
                    end
                    
                    if _G.AutoHaki and not Player.Character:FindFirstChild("HasBuso") then
                        local remote = GetRemote()
                        if remote then remote:InvokeServer("Buso") end
                    end
                    
                    EquipWeapon()
                    
                    if _G.FastAttack then
                        FastAttack()
                    else
                        Attack()
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
            if hum and hum.Health > 0 then
                hum.Health = hum.MaxHealth
            end
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
            if remote then
                for i = 1, 3 do
                    remote:InvokeServer("AddPoint", "Melee", 1)
                end
                print("[AUTO STATS] Pontos adicionados")
            end
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
                if obj:IsA("BasePart") and obj.Name:lower():find("fruit", 1, true) then
                    if obj.Parent and obj.Parent:FindFirstChild("Handle") then
                        print("[FRUIT] Fruta encontrada em:", obj.Position)
                        TP(obj.Position)
                        task.wait(0.5)
                        break
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
                    if remote then
                        remote:InvokeServer("StoreFruit", fruit.Value)
                        print("[AUTO STORE] Fruta armazenada:", fruit.Value)
                    end
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
            if remote then
                remote:InvokeServer("FruitGacha", "Roll")
                print("[AUTO ROLL] Roll realizado")
            end
        end)
    end
end)

-- ============================================================
-- NOCLIP AUTOMÁTICO
-- ============================================================
RunService.Stepped:Connect(function()
    if not _G.AutoFarm and not _G.AutoBoss then return end
    pcall(function()
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- ============================================================
-- BODY VELOCITY ANTI-KNOCKBACK
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if (_G.AutoFarm or _G.AutoBoss) and Player.Character then
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and not hrp:FindFirstChild("BodyClip") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "BodyClip"
                    bv.Parent = hrp
                    bv.MaxForce = Vector3.new(100000, 100000, 100000)
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            elseif Player.Character then
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("BodyClip") then
                    hrp.BodyClip:Destroy()
                end
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
                if stun then
                    stun.Value = 0
                end
            end
        end)
    end
end)

-- ============================================================
-- UI - INSTALAR CATEGORIAS
-- ============================================================
print("[UI] Criando interface...")
local win = DiscordLib:Window("NEXUS SUPREMO DELTA")
local serv = win:Server("Blox Fruits", "http://www.roblox.com/asset/?id=6031075938")

-- CANAL: AUTO FARM
local farmChannel = serv:Channel("⚔️ Auto Farm")
farmChannel:Toggle("Auto Farm Level", false, function(v) 
    _G.AutoFarm = v 
    print("[UI] Auto Farm:", v)
end)
farmChannel:Toggle("Auto Quest", true, function(v) 
    _G.AutoQuest = v 
end)
farmChannel:Toggle("Bring Mob", true, function(v) 
    _G.BringMob = v 
end)
farmChannel:Toggle("Fast Attack", false, function(v) 
    _G.FastAttack = v 
end)
farmChannel:Toggle("Auto Haki", false, function(v) 
    _G.AutoHaki = v 
end)
farmChannel:Toggle("God Mode", false, function(v) 
    _G.GodMode = v 
end)
farmChannel:Dropdown("Select Weapon", {"Melee", "Sword", "Blox Fruit"}, function(v) 
    _G.SelectWeapon = v 
    print("[UI] Weapon selecionada:", v)
end)
farmChannel:Slider("Attack Range", 50, 500, 300, function(v) 
    _G.Range = v 
end)

-- CANAL: AUTO BOSS
local bossChannel = serv:Channel("💀 Auto Boss")
bossChannel:Toggle("Auto Boss", false, function(v) 
    _G.AutoBoss = v 
    print("[UI] Auto Boss:", v)
end)
bossChannel:Dropdown("Select Boss", BossList, function(v) 
    _G.SelectBoss = v 
    print("[UI] Boss selecionado:", v)
end)

-- CANAL: FRUTAS
local fruitChannel = serv:Channel("🍎 Frutas")
fruitChannel:Toggle("Fruit Sniper", false, function(v) 
    _G.FruitSniper = v 
end)
fruitChannel:Toggle("Auto Store", false, function(v) 
    _G.AutoStore = v 
end)
fruitChannel:Toggle("Auto Roll", false, function(v) 
    _G.AutoRoll = v 
end)

-- CANAL: CONFIGURAÇÕES
local settingsChannel = serv:Channel("⚙️ Configurações")
settingsChannel:Toggle("Auto Stats (Melee)", false, function(v) 
    _G.AutoStats = v 
end)
settingsChannel:Slider("Attack Delay (ms)", 0, 500, 100, function(v) 
    _G.Fast_Delay = v / 1000 
end)
settingsChannel:Button("🔄 Refresh Status", function()
    local lv = Player.Data.Level.Value
    local sea = Sea1 and "1" or Sea2 and "2" or Sea3 and "3" or "?"
    DiscordLib:Notification("NEXUS SUPREMO", "Sea: " .. sea .. " | Level: " .. lv .. " | Weapon: " .. (_G.WeaponName or "None"), "OK")
end)
settingsChannel:Button("🛑 Stop Everything", function()
    _G.AutoFarm = false
    _G.AutoBoss = false
    _G.GodMode = false
    _G.FruitSniper = false
    _G.AutoStore = false
    _G.AutoRoll = false
    _G.AutoStats = false
    _G.StopTween = true
    task.wait(0.5)
    _G.StopTween = false
    DiscordLib:Notification("NEXUS SUPREMO", "All systems have been STOPPED!", "OK")
    print("[UI] Todos os sistemas parados")
end)
settingsChannel:Label("NEXUS SUPREMO v11.0 - Delta Edition")
settingsChannel:Label("Made with ❤️ by Nexus Team")
settingsChannel:Label("Adaptado para Delta Executor")

-- ============================================================
-- NOTIFICAÇÃO INICIAL
-- ============================================================
print("[NEXUS] Script carregado com sucesso!")
print("[NEXUS] Level atual:", Player.Data.Level.Value)
print("[NEXUS] Sea:", Sea1 and "1" or Sea2 and "2" or Sea3 and "3")

DiscordLib:Notification("NEXUS SUPREMO DELTA", 
    "Script carregado com sucesso!\n\n" ..
    "⚔️ Auto Farm - Completo\n" ..
    "💀 Auto Boss - Todas as Seas\n" ..
    "🍎 Frutas - Sniper/Store/Roll\n" ..
    "⚙️ Configurações - Customizável\n\n" ..
    "Seu level: " .. Player.Data.Level.Value, 
    "🚀 INICIAR!"
)

print("=== NEXUS DELTA PRONTO ===")
print("Use o menu UI para ativar as funções")
print("Recomendação: Ative 'Auto Farm Level' primeiro")
