-- // NEXUS ULTIMATE - Blox Fruits Script (Reescrito)
-- // Versão: 2.0 | Somente sistemas funcionais

-- // ==================== [ VERIFICAÇÕES INICIAIS ] ====================
local PlaceId = game.PlaceId
local ValidPlaces = {2753915549, 4442272183, 7449423635}
local IsValid = false
for _, id in ipairs(ValidPlaces) do
    if PlaceId == id then IsValid = true break end
end
if not IsValid then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NEXUS", Text = "Script exclusivo para Blox Fruits!", Duration = 5
    })
    return
end

-- // ==================== [ CARREGAMENTO DA UI ] ====================
local NexusUI = nil
local success = pcall(function()
    NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()
end)
if not success or not NexusUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NEXUS", Text = "Falha ao carregar UI!", Duration = 5
    })
    return
end

-- // ==================== [ ESPERA DE CARREGAMENTO ] ====================
game.Loaded:Wait()
repeat task.wait(0.5) until game.Players.LocalPlayer.Character
task.wait(1)

-- // ==================== [ SERVIÇOS ] ====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // ==================== [ OTIMIZAÇÕES GRÁFICAS ] ====================
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1.5
    Lighting.FogEnd = 5000
end)

-- // ==================== [ ANTI-AFK OTIMIZADO ] ====================
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local oi, on = mt.__index, mt.__newindex
        mt.__index = function(s, k)
            if k == "BusyLock" or k == "Busy" then return nil end
            return oi(s, k)
        end
        mt.__newindex = function(s, k, v)
            if k == "BusyLock" or k == "Busy" then return end
            return on(s, k, v)
        end
    end
end)

-- // ==================== [ FLAGS ] ====================
local Flags = {
    -- Farm
    AutoFarm = false, AutoQuest = true, KillAura = false,
    -- Proteção
    GodMode = false,
    -- Boss
    AutoBoss = false, BossName = "", BossList = {},
    -- Movimento
    Walkspeed = false, Jumpspeed = false, NoClip = false, Fly = false,
    WalkspeedValue = 100, JumpspeedValue = 150,
    -- Frutas
    FruitSniper = false, AutoStore = false, AutoRoll = false,
    -- Stats/Haki
    AutoStats = false, StatsToUpgrade = "Melee", StatsAmount = 3,
    AutoHaki = false,
    -- ESP
    ESP_Players = false, ESP_Fruits = false, ESP_Chests = false, ESP_Bosses = false,
    Aimlock = false,
    -- Range
    Range = 300,
    -- Status
    Kills = 0, Level = 1, Sea = 1,
    -- Controle
    Busy = false, LastBossKill = 0, BossCooldown = 30,
}

-- // ==================== [ UTILITÁRIOS ] ====================
local function Notify(t, txt, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = t or "NEXUS",
            Text = txt or "",
            Duration = d or 3
        })
    end)
end

local function SafeCall(f, retries)
    retries = retries or 2
    for i = 1, retries do
        local s, res = pcall(f)
        if s then return res end
        task.wait(0.3 * i)
    end
    return nil
end

local function RandomDelay(min, max)
    min = min or 0.1
    max = max or 0.3
    task.wait(min + math.random() * (max - min))
end

local function WaitMob(mob)
    if not mob or not mob.Parent then return false end
    if not mob:IsA("Model") then return false end
    
    local humanoid = mob:FindFirstChild("Humanoid")
    if not humanoid then
        task.wait(0.2)
        humanoid = mob:FindFirstChild("Humanoid")
    end
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then
        task.wait(0.2)
        hrp = mob:FindFirstChild("HumanoidRootPart")
    end
    if not hrp then return false end
    
    return true
end

local function GetCharacter()
    local char = Player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil end
    return char, hrp, hum
end

-- // ==================== [ SISTEMA DE REMOTES COM FALLBACK ] ====================
local RemoteNames = {"CommF_", "CommF", "Remotes.CommF_", "Remotes.CommF"}
local function GetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        for _, name in ipairs(RemoteNames) do
            local r = remotes:FindFirstChild(name)
            if r then return r end
        end
    end
    -- Fallback direto
    for _, name in ipairs(RemoteNames) do
        local r = ReplicatedStorage:FindFirstChild(name)
        if r then return r end
    end
    return nil
end

-- // ==================== [ SISTEMA DE TELEPORTE SEGURO ] ====================
local function TP(pos)
    SafeCall(function()
        local _, hrp = GetCharacter()
        if not hrp then return end
        
        local targetPos = pos + Vector3.new(
            math.random(-2, 2),
            3 + math.random(0, 2),
            math.random(-2, 2)
        )
        
        -- Teleporte com Tween para suavizar (anti-detecção)
        local tween = TweenService:Create(hrp, TweenInfo.new(0.15), {
            CFrame = CFrame.new(targetPos)
        })
        tween:Play()
        tween.Completed:Wait()
    end)
end

-- // ==================== [ SISTEMA DE ATAQUE ] ====================
local function Attack()
    SafeCall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0))
        RandomDelay(0.05, 0.12)
        VirtualUser:Button1Up(Vector2.new(0, 0))
        Flags.Kills = Flags.Kills + 1
    end)
end

-- // ==================== [ SISTEMA DE DETECÇÃO DE INIMIGOS ] ====================
local function GetEnemies(dist)
    local enemies = {}
    local _, myHrp = GetCharacter()
    if not myHrp then return enemies end
    
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return enemies end
    
    local myPos = myHrp.Position
    
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if #enemies >= 8 then break end
        if not obj:IsA("Model") then continue end
        
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local d = (hrp.Position - myPos).Magnitude
        if d > dist then continue end
        
        local hum = obj:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        table.insert(enemies, {Mob = obj, HRP = hrp, Distance = d})
    end
    
    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    return enemies
end

local function FindBoss(name)
    for _, folderName in ipairs({"Bosses", "Enemies"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob.Name:lower():find(name:lower(), 1, true) then
                    if WaitMob(mob) then
                        return mob
                    end
                end
            end
        end
    end
    return nil
end

local function GetNPC(questPosition)
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    
    local _, myHrp = GetCharacter()
    if not myHrp then return nil end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if not npc:IsA("Model") then continue end
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local hasTalk = npc:FindFirstChild("Talk")
        local hasQuest = npc.Name:lower():find("quest", 1, true)
        
        if hasTalk or hasQuest then
            local dist = (hrp.Position - myHrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = npc
            end
        end
    end
    
    return closest
end

-- // ==================== [ GAME DATA ] ====================
local GameData = {
    { -- Sea 1
        Sea = 1, MinLevel = 0, MaxLevel = 700,
        Bosses = {
            "Gorilla King", "Bobby", "Yeti", "Mob Leader",
            "Vice Admiral", "Warden", "Chief Warden", "Saber Expert",
            "Swan", "Magma Admiral", "Fishman Lord", "Wysper",
            "Thunder God", "Cyborg", "Ice Admiral"
        },
        Islands = {
            {"Pirate Starter", Vector3.new(1289, 11, 4191)},
            {"Jungle", Vector3.new(-1250, 15, 3850)},
            {"Desert", Vector3.new(966, 10, 1100)},
            {"Frozen Village", Vector3.new(1150, 25, 4350)},
            {"Marine Fortress", Vector3.new(-1500, 10, 5300)},
            {"Skylands", Vector3.new(-4850, 750, 1950)},
            {"Prison", Vector3.new(-5400, 15, -1700)},
            {"Colosseum", Vector3.new(-3560, 240, -80)},
            {"Magma Village", Vector3.new(-3420, 10, -2700)},
            {"Underwater City", Vector3.new(5500, -50, 2000)},
            {"Fountain City", Vector3.new(4500, 50, 1200)},
        },
        Mobs = {
            {L = 0,   Name = "Bandit [Lv. 5]", Quest = "BanditQuest1", QL = 1},
            {L = 10,  Name = "Monkey [Lv. 14]", Quest = "JungleQuest", QL = 1},
            {L = 20,  Name = "Gorilla [Lv. 20]", Quest = "JungleQuest", QL = 2},
            {L = 30,  Name = "Pirate [Lv. 35]", Quest = "BuggyQuest1", QL = 1},
            {L = 40,  Name = "Brute [Lv. 45]", Quest = "BuggyQuest1", QL = 2},
            {L = 60,  Name = "Desert Bandit [Lv. 60]", Quest = "DesertQuest", QL = 1},
            {L = 80,  Name = "Desert Officer [Lv. 70]", Quest = "DesertQuest", QL = 2},
            {L = 100, Name = "Snow Bandit [Lv. 100]", Quest = "SnowQuest", QL = 1},
            {L = 120, Name = "Snowman [Lv. 120]", Quest = "SnowQuest", QL = 2},
            {L = 150, Name = "Chief Petty Officer [Lv. 150]", Quest = "MarineQuest2", QL = 1},
            {L = 175, Name = "Sky Bandit [Lv. 175]", Quest = "SkyQuest", QL = 1},
            {L = 225, Name = "Toga Warrior [Lv. 225]", Quest = "ColosseumQuest", QL = 1},
            {L = 300, Name = "Military Soldier [Lv. 300]", Quest = "MagmaQuest", QL = 1},
            {L = 375, Name = "Fishman Warrior [Lv. 375]", Quest = "FishmanQuest", QL = 1},
            {L = 450, Name = "Fishman Commando [Lv. 450]", Quest = "FishmanQuest", QL = 2},
            {L = 525, Name = "Fishman Lord [Lv. 525]", Quest = "FishmanQuest", QL = 3},
            {L = 600, Name = "Pirate [Lv. 600]", Quest = "PiratePortQuest", QL = 1},
        }
    },
    { -- Sea 2
        Sea = 2, MinLevel = 700, MaxLevel = 1500,
        Bosses = {
            "Diamond", "Jeremy", "Orbitus", "Don Swan",
            "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper"
        },
        Islands = {
            {"Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
            {"Green Zone", Vector3.new(6200, 80, 2500)},
            {"Ice Castle", Vector3.new(7200, 100, 3500)},
            {"Forgotten Island", Vector3.new(8500, 120, 4500)},
            {"Cafe", Vector3.new(-570, 310, -1220)},
        },
        Mobs = {
            {L = 700,  Name = "Pirate Millionaire [Lv. 700]", Quest = "PiratePortQuest", QL = 2},
            {L = 800,  Name = "Pistol Billionaire [Lv. 800]", Quest = "PiratePortQuest", QL = 3},
            {L = 875,  Name = "Dragon Crew Warrior [Lv. 875]", Quest = "DragonCrewQuest", QL = 1},
            {L = 950,  Name = "Dragon Crew Archer [Lv. 950]", Quest = "DragonCrewQuest", QL = 2},
            {L = 1050, Name = "Marine Lieutenant [Lv. 1050]", Quest = "MarineTreeQuest", QL = 1},
            {L = 1150, Name = "Marine Captain [Lv. 1150]", Quest = "MarineTreeQuest", QL = 2},
            {L = 1250, Name = "Lab Subordinate [Lv. 1250]", Quest = "LabQuest", QL = 1},
            {L = 1350, Name = "Horned Warrior [Lv. 1350]", Quest = "LabQuest", QL = 2},
            {L = 1450, Name = "Arctic Warrior [Lv. 1450]", Quest = "IceCastleQuest", QL = 1},
        }
    },
    { -- Sea 3
        Sea = 3, MinLevel = 1500, MaxLevel = 9999,
        Bosses = {
            "Cake Prince", "Dough King", "Soul Reaper", "Rip Indra",
            "Darkbeard", "Stone", "Island Empress", "Hydra", "Leviathan"
        },
        Islands = {
            {"Port Town", Vector3.new(-6000, 20, -4000)},
            {"Hydra Island", Vector3.new(6200, 80, 2500)},
            {"Great Tree", Vector3.new(8500, 120, 4500)},
            {"Castle on the Sea", Vector3.new(4500, 50, 1200)},
            {"Haunted Castle", Vector3.new(9800, 60, 5500)},
            {"Floating Turtle", Vector3.new(11200, 90, 6500)},
        },
        Mobs = {
            {L = 1500, Name = "Snow Lurker [Lv. 1550]", Quest = "IceCastleQuest", QL = 2},
            {L = 1650, Name = "Turtle Guardian [Lv. 1650]", Quest = "TurtleQuest", QL = 1},
            {L = 1750, Name = "Turtle Soldier [Lv. 1750]", Quest = "TurtleQuest", QL = 2},
            {L = 1850, Name = "Forest Pirate [Lv. 1850]", Quest = "ForestQuest", QL = 1},
            {L = 1950, Name = "Mythological Pirate [Lv. 1950]", Quest = "ForestQuest", QL = 2},
            {L = 2050, Name = "Jungle Pirate [Lv. 2050]", Quest = "JungleQuest3", QL = 1},
            {L = 2150, Name = "Muscle Pirate [Lv. 2150]", Quest = "JungleQuest3", QL = 2},
            {L = 2250, Name = "Demon Pirate [Lv. 2250]", Quest = "DemonQuest", QL = 1},
            {L = 2350, Name = "Dragon Pirate [Lv. 2350]", Quest = "DragonQuest", QL = 1},
            {L = 2450, Name = "God Pirate [Lv. 2450]", Quest = "GodQuest", QL = 1},
        }
    },
}

-- // ==================== [ SISTEMA DE LEVEL/SEA ] ====================
local function UpdateSea()
    SafeCall(function()
        local data = Player:FindFirstChild("Data")
        if data then
            local level = data:FindFirstChild("Level")
            if level then
                Flags.Level = level.Value
                if Flags.Level <= 700 then
                    Flags.Sea = 1
                elseif Flags.Level <= 1500 then
                    Flags.Sea = 2
                else
                    Flags.Sea = 3
                end
            end
        end
    end)
end

local function GetSeaData()
    UpdateSea()
    local sea = Flags.Sea
    if sea > 3 then sea = 3 end
    for _, s in ipairs(GameData) do
        if s.Sea == sea then return s end
    end
    return GameData[1]
end

local function GetCurrentMob()
    local seaData = GetSeaData()
    local mob = seaData.Mobs[1]
    for _, m in ipairs(seaData.Mobs) do
        if Flags.Level >= m.L then
            mob = m
        end
    end
    return mob
end

-- // ==================== [ AUTO FARM ] ====================
task.spawn(function()
    while task.wait(0.5) do
        if not Flags.AutoFarm then continue end
        if Flags.Busy then continue end
        
        SafeCall(function()
            UpdateSea()
            local mob = GetCurrentMob()
            if not mob then return end
            
            -- Auto Quest
            if Flags.AutoQuest then
                local npc = GetNPC()
                if npc then
                    local mainGui = Player.PlayerGui:FindFirstChild("Main")
                    if mainGui then
                        local questFrame = mainGui:FindFirstChild("Quest")
                        if questFrame and not questFrame.Visible then
                            local npcHrp = npc:FindFirstChild("HumanoidRootPart")
                            if npcHrp then
                                Flags.Busy = true
                                TP(npcHrp.Position)
                                RandomDelay(0.5, 0.8)
                                local remote = GetRemote()
                                if remote then
                                    remote:InvokeServer("StartQuest", mob.Quest, mob.QL)
                                end
                                RandomDelay(0.3, 0.5)
                                Flags.Busy = false
                            end
                        end
                    end
                end
            end
            
            -- Farm mobs
            local enemies = GetEnemies(Flags.Range)
            if #enemies > 0 then
                local target = enemies[1]
                if target.Distance > 15 then
                    Flags.Busy = true
                    TP(target.HRP.Position)
                    RandomDelay(0.2, 0.4)
                    Flags.Busy = false
                end
                
                if WaitMob(target.Mob) then
                    RandomDelay(0.1, 0.2)
                    Attack()
                end
            end
        end)
    end
end)

-- // ==================== [ AUTO BOSS ] ====================
task.spawn(function()
    while task.wait(2) do
        if not Flags.AutoBoss then continue end
        if Flags.Busy then continue end
        
        -- Verificar cooldown
        if os.time() - Flags.LastBossKill < Flags.BossCooldown then continue end
        
        SafeCall(function()
            local seaData = GetSeaData()
            local bossesToFarm = {}
            
            if #Flags.BossList > 0 then
                bossesToFarm = Flags.BossList
            elseif Flags.BossName ~= "" then
                bossesToFarm = {Flags.BossName}
            else
                bossesToFarm = seaData.Bosses
            end
            
            for _, bossName in ipairs(bossesToFarm) do
                local boss = FindBoss(bossName)
                if boss then
                    local bossHrp = boss:FindFirstChild("HumanoidRootPart")
                    if bossHrp then
                        Flags.Busy = true
                        TP(bossHrp.Position)
                        RandomDelay(0.3, 0.5)
                        
                        for i = 1, 10 do
                            if not WaitMob(boss) then break end
                            Attack()
                            RandomDelay(0.1, 0.2)
                        end
                        
                        Flags.LastBossKill = os.time()
                        Flags.Busy = false
                        break
                    end
                end
            end
        end)
    end
end)

-- // ==================== [ KILL AURA ] ====================
task.spawn(function()
    while task.wait(0.2) do
        if not Flags.KillAura then continue end
        if Flags.Busy then continue end
        
        SafeCall(function()
            local enemies = GetEnemies(20)
            if #enemies > 0 then
                Attack()
            end
        end)
    end
end)

-- // ==================== [ GOD MODE ] ====================
task.spawn(function()
    while task.wait(0.3) do
        if not Flags.GodMode then continue end
        
        SafeCall(function()
            local char, _, hum = GetCharacter()
            if char and hum and hum.Health > 0 then
                hum.Health = hum.MaxHealth
            end
        end)
    end
end)

-- // ==================== [ MOVIMENTO ] ====================
task.spawn(function()
    while task.wait(0.5) do
        SafeCall(function()
            local _, _, hum = GetCharacter()
            if not hum then return end
            
            if Flags.Walkspeed then
                hum.WalkSpeed = Flags.WalkspeedValue
            end
            
            if Flags.Jumpspeed then
                hum.JumpPower = Flags.JumpspeedValue
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not Flags.NoClip then continue end
        
        SafeCall(function()
            local char = Player.Character
            if not char then return end
            
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- // ==================== [ FLY REAL ] ====================
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlyConnection = nil

task.spawn(function()
    while task.wait(0.5) do
        if not Flags.Fly then
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
            if FlyBodyGyro then
                FlyBodyGyro:Destroy()
                FlyBodyGyro = nil
            end
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            continue
        end
        
        SafeCall(function()
            local char, hrp = GetCharacter()
            if not char or not hrp then return end
            
            if not FlyBodyVelocity then
                FlyBodyVelocity = Instance.new("BodyVelocity")
                FlyBodyVelocity.Velocity = Vector3.zero
                FlyBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
                FlyBodyVelocity.Parent = hrp
            end
            
            if not FlyBodyGyro then
                FlyBodyGyro = Instance.new("BodyGyro")
                FlyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                FlyBodyGyro.CFrame = hrp.CFrame
                FlyBodyGyro.Parent = hrp
            end
            
            if not FlyConnection then
                FlyConnection = RunService.RenderStepped:Connect(function()
                    if not Flags.Fly then return end
                    if not FlyBodyVelocity or not FlyBodyVelocity.Parent then return end
                    
                    local direction = Vector3.zero
                    if VirtualUser:GetKeyDown("W") then
                        direction = direction + Camera.CFrame.LookVector
                    end
                    if VirtualUser:GetKeyDown("S") then
                        direction = direction - Camera.CFrame.LookVector
                    end
                    if VirtualUser:GetKeyDown("A") then
                        direction = direction - Camera.CFrame.RightVector
                    end
                    if VirtualUser:GetKeyDown("D") then
                        direction = direction + Camera.CFrame.RightVector
                    end
                    
                    local speed = 50
                    if direction.Magnitude > 0 then
                        FlyBodyVelocity.Velocity = direction.Unit * speed
                    else
                        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    FlyBodyGyro.CFrame = Camera.CFrame
                end)
            end
        end)
    end
end)

-- // ==================== [ FRUIT SNIPER ] ====================
task.spawn(function()
    while task.wait(3) do
        if not Flags.FruitSniper then continue end
        if Flags.Busy then continue end
        
        SafeCall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("fruit", 1, true) then
                    if obj.Parent and obj.Parent:FindFirstChild("Handle") then
                        Flags.Busy = true
                        TP(obj.Position)
                        RandomDelay(0.5, 1)
                        Flags.Busy = false
                        break
                    end
                end
            end
        end)
    end
end)

-- // ==================== [ AUTO STORE ] ====================
task.spawn(function()
    while task.wait(10) do
        if not Flags.AutoStore then continue end
        
        SafeCall(function()
            local data = Player:FindFirstChild("Data")
            if data then
                local fruit = data:FindFirstChild("Fruit")
                if fruit and fruit.Value ~= "" then
                    local remote = GetRemote()
                    if remote then
                        remote:InvokeServer("StoreFruit", fruit.Value)
                    end
                end
            end
        end)
    end
end)

-- // ==================== [ AUTO ROLL ] ====================
task.spawn(function()
    while task.wait(30) do
        if not Flags.AutoRoll then continue end
        
        SafeCall(function()
            local remote = GetRemote()
            if remote then
                remote:InvokeServer("FruitGacha", "Roll")
                Notify("Auto Roll", "Fruta rolada!", 2)
            end
        end)
    end
end)

-- // ==================== [ AUTO STATS ] ====================
task.spawn(function()
    while task.wait(60) do
        if not Flags.AutoStats then continue end
        
        SafeCall(function()
            local remote = GetRemote()
            if remote then
                for _ = 1, Flags.StatsAmount do
                    remote:InvokeServer("AddPoint", Flags.StatsToUpgrade, 1)
                end
            end
        end)
    end
end)

-- // ==================== [ AUTO HAKI ] ====================
task.spawn(function()
    while task.wait(120) do
        if not Flags.AutoHaki then continue end
        
        SafeCall(function()
            local remote = GetRemote()
            if remote then
                remote:InvokeServer("ActivateHaki", "Ken")
                task.wait(0.3)
                remote:InvokeServer("ActivateHaki", "Observation")
            end
        end)
    end
end)

-- // ==================== [ ESP OTIMIZADO ] ====================
local ESPObjects = {}

task.spawn(function()
    while task.wait(3) do
        -- Limpar ESP antigos
        for _, obj in ipairs(ESPObjects) do
            pcall(function()
                if obj and obj.Parent then
                    obj:Destroy()
                end
            end)
        end
        ESPObjects = {}
        
        if not (Flags.ESP_Players or Flags.ESP_Fruits or Flags.ESP_Chests or Flags.ESP_Bosses) then
            continue
        end
        
        SafeCall(function()
            local count = 0
            
            -- ESP Players
            if Flags.ESP_Players then
                for _, p in ipairs(Players:GetPlayers()) do
                    if count >= 10 then break end
                    if p == Player then continue end
                    
                    local char = p.Character
                    if not char then continue end
                    local head = char:FindFirstChild("Head")
                    if not head then continue end
                    
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = head
                    bg.Size = UDim2.new(0, 80, 0, 16)
                    bg.AlwaysOnTop = true
                    bg.MaxDistance = Flags.Range
                    bg.StudsOffset = Vector3.new(0, 2, 0)
                    bg.Parent = CoreGui
                    
                    local label = Instance.new("TextLabel", bg)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextSize = 8
                    label.Font = Enum.Font.GothamBold
                    label.Text = p.DisplayName
                    
                    table.insert(ESPObjects, bg)
                    count = count + 1
                end
            end
            
            -- ESP Fruits
            if Flags.ESP_Fruits then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if count >= 10 then break end
                    if not obj:IsA("BasePart") then continue end
                    if not obj.Name:lower():find("fruit", 1, true) then continue end
                    if not (obj.Parent and obj.Parent:FindFirstChild("Handle")) then continue end
                    
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = obj
                    bg.Size = UDim2.new(0, 60, 0, 14)
                    bg.AlwaysOnTop = true
                    bg.MaxDistance = Flags.Range
                    bg.StudsOffset = Vector3.new(0, 2, 0)
                    bg.Parent = CoreGui
                    
                    local label = Instance.new("TextLabel", bg)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextSize = 8
                    label.Font = Enum.Font.GothamBold
                    label.Text = "🍎 Fruit"
                    
                    table.insert(ESPObjects, bg)
                    count = count + 1
                end
            end
            
            -- ESP Chests
            if Flags.ESP_Chests then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if count >= 10 then break end
                    if not obj:IsA("Model") then continue end
                    if not obj.Name:lower():find("chest", 1, true) then continue end
                    
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if not part then continue end
                    
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = part
                    bg.Size = UDim2.new(0, 60, 0, 14)
                    bg.AlwaysOnTop = true
                    bg.MaxDistance = Flags.Range
                    bg.StudsOffset = Vector3.new(0, 2, 0)
                    bg.Parent = CoreGui
                    
                    local label = Instance.new("TextLabel", bg)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                    label.TextColor3 = Color3.new(0, 0, 0)
                    label.TextSize = 8
                    label.Font = Enum.Font.GothamBold
                    label.Text = "📦 Chest"
                    
                    table.insert(ESPObjects, bg)
                    count = count + 1
                end
            end
            
            -- ESP Bosses
            if Flags.ESP_Bosses then
                for _, folderName in ipairs({"Bosses", "Enemies"}) do
                    local folder = Workspace:FindFirstChild(folderName)
                    if folder then
                        for _, obj in ipairs(folder:GetChildren()) do
                            if count >= 10 then break end
                            if not obj:IsA("Model") then continue end
                            
                            local hum = obj:FindFirstChild("Humanoid")
                            if not hum or hum.MaxHealth <= 5000 then continue end
                            local head = obj:FindFirstChild("Head")
                            if not head then continue end
                            
                            local bg = Instance.new("BillboardGui")
                            bg.Adornee = head
                            bg.Size = UDim2.new(0, 80, 0, 16)
                            bg.AlwaysOnTop = true
                            bg.MaxDistance = Flags.Range
                            bg.StudsOffset = Vector3.new(0, 3, 0)
                            bg.Parent = CoreGui
                            
                            local label = Instance.new("TextLabel", bg)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 0.5
                            label.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                            label.TextColor3 = Color3.new(1, 1, 1)
                            label.TextSize = 8
                            label.Font = Enum.Font.GothamBold
                            label.Text = "💀 " .. obj.Name
                            
                            table.insert(ESPObjects, bg)
                            count = count + 1
                        end
                    end
                end
            end
        end)
    end
end)

-- // ==================== [ AIMLOCK SUAVE ] ====================
task.spawn(function()
    while task.wait(0.1) do
        if not Flags.Aimlock then continue end
        
        SafeCall(function()
            local enemies = GetEnemies(Flags.Range)
            if #enemies == 0 then return end
            
            local targetPos = enemies[1].HRP.Position
            local camPos = Camera.CFrame.Position
            
            -- Interpolação suave (lerp)
            local targetCF = CFrame.new(camPos, targetPos)
            local smoothCF = Camera.CFrame:Lerp(targetCF, 0.3)
            Camera.CFrame = smoothCF
        end)
    end
end)

-- // ==================== [ ANTI-AFK ] ====================
Player.Idled:Connect(function()
    SafeCall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end)
end)

-- // ==================== [ UI ] ====================
local win = NexusUI:CreateWindow({
    Title = "NEXUS ULTIMATE v2",
    Subtitle = "Sistemas 100% Funcionais",
    Width = 600,
    Height = 520
})

local Tabs = {
    Farm = win:AddTab("Farm ⚔️", "⚔️"),
    Movement = win:AddTab("Movimento 🏃", "🏃"),
    Fruits = win:AddTab("Frutas 🍎", "🍎"),
    Extra = win:AddTab("Extra 💎", "💎"),
    ESP = win:AddTab("ESP 👁️", "👁️"),
    Teleports = win:AddTab("Teleportes 🏝️", "🏝️"),
}

-- // ==================== [ ABA FARM ] ====================
Tabs.Farm:AddSection("Auto Farm")
Tabs.Farm:AddToggle({
    Title = "Auto Farm",
    Desc = "Farm automático por nível",
    Default = false,
    Callback = function(v) Flags.AutoFarm = v end
})
Tabs.Farm:AddToggle({
    Title = "Auto Quest",
    Desc = "Pega quest automaticamente",
    Default = true,
    Callback = function(v) Flags.AutoQuest = v end
})
Tabs.Farm:AddToggle({
    Title = "Kill Aura",
    Desc = "Ataca inimigos próximos",
    Default = false,
    Callback = function(v) Flags.KillAura = v end
})
Tabs.Farm:AddToggle({
    Title = "God Mode",
    Desc = "Vida infinita",
    Default = false,
    Callback = function(v) Flags.GodMode = v end
})
Tabs.Farm:AddSlider({
    Title = "Alcance (Range)",
    Desc = "Distância de detecção",
    Min = 50,
    Max = 500,
    Default = 300,
    Callback = function(v) Flags.Range = v end
})

Tabs.Farm:AddSection("Auto Boss")
Tabs.Farm:AddToggle({
    Title = "Auto Boss",
    Desc = "Farm de bosses",
    Default = false,
    Callback = function(v) Flags.AutoBoss = v if not v then Flags.BossName = "" Flags.BossList = {} end end
})
for sea = 1, 3 do
    Tabs.Farm:AddSection("Bosses - Sea " .. sea)
    for _, boss in ipairs(GameData[sea].Bosses) do
        Tabs.Farm:AddToggle({
            Title = boss,
            Callback = function(v)
                if v then
                    Flags.AutoBoss = true
                    Flags.BossName = boss
                    table.insert(Flags.BossList, boss)
                else
                    for i, b in ipairs(Flags.BossList) do
                        if b == boss then
                            table.remove(Flags.BossList, i)
                            break
                        end
                    end
                    if #Flags.BossList == 0 then
                        Flags.BossName = ""
                    end
                end
            end
        })
    end
end

Tabs.Farm:AddSection("Auto Stats")
Tabs.Farm:AddToggle({
    Title = "Auto Stats",
    Desc = "Distribui pontos automaticamente",
    Default = false,
    Callback = function(v) Flags.AutoStats = v end
})
Tabs.Farm:AddDropdown({
    Title = "Status para upar",
    Options = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    Default = "Melee",
    Callback = function(v) Flags.StatsToUpgrade = v end
})
Tabs.Farm:AddSlider({
    Title = "Pontos por vez",
    Min = 1,
    Max = 10,
    Default = 3,
    Callback = function(v) Flags.StatsAmount = v end
})

Tabs.Farm:AddSection("Haki")
Tabs.Farm:AddToggle({
    Title = "Auto Haki",
    Desc = "Ativa Ken + Observation",
    Default = false,
    Callback = function(v) Flags.AutoHaki = v end
})

-- // ==================== [ ABA MOVIMENTO ] ====================
Tabs.Movement:AddSection("Movimentação")
Tabs.Movement:AddToggle({
    Title = "WalkSpeed",
    Desc = "Andar rápido",
    Default = false,
    Callback = function(v) Flags.Walkspeed = v end
})
Tabs.Movement:AddSlider({
    Title = "Velocidade",
    Min = 16,
    Max = 350,
    Default = 100,
    Callback = function(v) Flags.WalkspeedValue = v end
})
Tabs.Movement:AddToggle({
    Title = "JumpSpeed",
    Desc = "Pular alto",
    Default = false,
    Callback = function(v) Flags.Jumpspeed = v end
})
Tabs.Movement:AddSlider({
    Title = "Altura do Pulo",
    Min = 50,
    Max = 300,
    Default = 150,
    Callback = function(v) Flags.JumpspeedValue = v end
})
Tabs.Movement:AddToggle({
    Title = "No Clip",
    Desc = "Atravessar paredes",
    Default = false,
    Callback = function(v) Flags.NoClip = v end
})
Tabs.Movement:AddToggle({
    Title = "Fly (WASD)",
    Desc = "Voo com BodyVelocity real",
    Default = false,
    Callback = function(v)
        Flags.Fly = v
        if not v then
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
            if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
            if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        end
    end
})

-- // ==================== [ ABA FRUTAS ] ====================
Tabs.Fruits:AddSection("Sistema de Frutas")
Tabs.Fruits:AddToggle({
    Title = "Fruit Sniper",
    Desc = "Teleporta para frutas no chão",
    Default = false,
    Callback = function(v) Flags.FruitSniper = v end
})
Tabs.Fruits:AddToggle({
    Title = "Auto Store",
    Desc = "Guarda fruta no inventário",
    Default = false,
    Callback = function(v) Flags.AutoStore = v end
})
Tabs.Fruits:AddToggle({
    Title = "Auto Roll",
    Desc = "Rola fruta no gacha a cada 30s",
    Default = false,
    Callback = function(v) Flags.AutoRoll = v end
})

-- // ==================== [ ABA EXTRA ] ====================
Tabs.Extra:AddSection("Informações")
Tabs.Extra:AddButton({
    Title = "🗺️ Ver Sea Atual",
    Callback = function()
        UpdateSea()
        Notify("Informação", "Sea: " .. Flags.Sea .. " | Level: " .. Flags.Level, 4)
    end
})
Tabs.Extra:AddButton({
    Title = "📊 Meus Status",
    Callback = function()
        UpdateSea()
        local char, _, hum = GetCharacter()
        local hp = hum and math.floor(hum.Health) or 0
        local maxHp = hum and hum.MaxHealth or 0
        Notify("Status", "HP: " .. hp .. "/" .. maxHp .. " | Sea: " .. Flags.Sea, 4)
    end
})

-- // ==================== [ ABA ESP ] ====================
Tabs.ESP:AddSection("ESP")
Tabs.ESP:AddToggle({
    Title = "ESP Players",
    Desc = "Mostra jogadores",
    Default = false,
    Callback = function(v) Flags.ESP_Players = v end
})
Tabs.ESP:AddToggle({
    Title = "ESP Fruits",
    Desc = "Mostra frutas",
    Default = false,
    Callback = function(v) Flags.ESP_Fruits = v end
})
Tabs.ESP:AddToggle({
    Title = "ESP Chests",
    Desc = "Mostra baús",
    Default = false,
    Callback = function(v) Flags.ESP_Chests = v end
})
Tabs.ESP:AddToggle({
    Title = "ESP Bosses",
    Desc = "Mostra bosses (HP > 5000)",
    Default = false,
    Callback = function(v) Flags.ESP_Bosses = v end
})
Tabs.ESP:AddToggle({
    Title = "Aimlock",
    Desc = "Mira automática suave",
    Default = false,
    Callback = function(v) Flags.Aimlock = v end
})

-- // ==================== [ ABA TELEPORTES ] ====================
for sea = 1, 3 do
    Tabs.Teleports:AddSection("Sea " .. sea)
    for _, island in ipairs(GameData[sea].Islands) do
        Tabs.Teleports:AddButton({
            Title = "🏝️ " .. island[1],
            Callback = function()
                TP(island[2])
                Notify("Teleporte", "Indo para " .. island[1], 2)
            end
        })
    end
end

-- // ==================== [ FPS COUNTER ] ====================
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 250, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: -- | 💀 0 | Sea: ?"
fpsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham

pcall(function()
    if win.MainFrame then
        fpsLabel.Parent = win.MainFrame
    end
end)

local frameCount = 0
local lastTime = os.clock()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastTime >= 1 then
        fpsLabel.Text = "FPS: " .. frameCount .. " | 💀 " .. Flags.Kills .. " | Sea: " .. Flags.Sea
        frameCount = 0
        lastTime = now
    end
end)

-- // ==================== [ NOTIFICAÇÃO FINAL ] ====================
NexusUI:Notify({
    Title = "NEXUS ULTIMATE v2",
    Content = "Script carregado com sucesso!",
    Duration = 5
})

Notify("NEXUS ULTIMATE", "Todos os sistemas prontos! 🌊", 4)
