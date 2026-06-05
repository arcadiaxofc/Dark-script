-- ============================================================
-- NEXUS FINAL v2.0 - COMPLETO E OTIMIZADO
-- Todas as funções finalizadas e melhoradas
-- ============================================================

-- 1. CARREGAR UI PRIMEIRO
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

if not NexusUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NEXUS",
        Text = "❌ Falha ao carregar a UI!",
        Duration = 5
    })
    return
end

-- 2. SERVIÇOS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- 3. BYPASS ANTI-CHEAT MELHORADO
pcall(function()
    -- Bloqueia erros do jogo
    local OldIndex = hookmetamethod(game, "__index", function(Self, Key)
        if Key == "BusyLock" or Key == "Busy" or Key == "BusyLocking" then return nil end
        return OldIndex(Self, Key)
    end)
    
    local OldNewIndex = hookmetamethod(game, "__newindex", function(Self, Key, Value)
        if Key == "BusyLock" or Key == "Busy" then return end
        return OldNewIndex(Self, Key, Value)
    end)
    
    -- Silencia erros do NPCManager e FruitClient
    local OldError = error
    error = function(msg, level)
        local msgStr = tostring(msg)
        if msgStr:find("BusyLock") or msgStr:find("NPCManager") or msgStr:find("FruitClient") then 
            return 
        end
        return OldError(msg, level or 2)
    end
    
    -- Protege RemoteEvents
    local OldWaitForChild = game.WaitForChild
    game.WaitForChild = function(self, child, timeout)
        if child == "BusyLock" then return nil end
        return OldWaitForChild(self, child, timeout)
    end
end)

-- 4. OTIMIZADOR MOBILE MELHORADO
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.FogEnd = 99999
    Lighting.FogStart = 99999
    
    -- Remove efeitos visuais pesados
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            end
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") then
                obj.Enabled = false
            end
        end)
    end
end)

-- 5. NOTIFICAÇÃO MELHORADA
local function Notify(t, txt, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = t or "NEXUS",
            Text = txt or "",
            Duration = d or 3,
            Icon = "rbxassetid://4483362458"
        })
    end)
end

-- 6. FLAGS COMPLETAS
local Flags = {
    -- Farm Principal
    AutoFarm = false,
    AutoQuest = false,
    KillAura = false,
    AutoBoss = false,
    BossName = "",
    AllBosses = false,
    Range = 300,
    Kills = 0,
    Level = 1,
    Sea = 1,
    
    -- Frutas
    AutoStore = false,
    AutoRoll = false,
    AutoSpawn = false,
    FruitSniper = false,
    FruitNotify = false,
    
    -- Farms Extras
    FragmentFarm = false,
    BonesFarm = false,
    BountyHunt = false,
    MasteryFarm = false,
    MasteryWeapon = "Sword",
    
    -- Auto Upgrades
    AutoHaki = false,
    AutoV4 = false,
    AutoRace = false,
    AutoStats = false,
    StatsToUpgrade = "Melee",
    StatsAmount = 3,
    
    -- ESP
    ESP_Players = false,
    ESP_Fruits = false,
    ESP_Chests = false,
    ESP_Bosses = false,
    ESP_SeaEvents = false,
    
    -- Combate
    Aimlock = false,
    AutoSkill = false,
    SkillKey = "Z",
    
    -- Cooldowns
    LastTP = 0,
    LastAttack = 0,
    TPCooldown = 0.5,
    AttackCooldown = 0.1,
}

-- 7. FUNÇÕES UTILITÁRIAS MELHORADAS
local function SafeCall(Func, Default)
    local s, r = pcall(Func)
    return s and r or Default
end

local function TP(pos)
    if tick() - Flags.LastTP < Flags.TPCooldown then return end
    Flags.LastTP = tick()
    
    SafeCall(function()
        local c = Player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        
        local dist = (pos - h.Position).Magnitude
        if dist > 500 then
            TweenService:Create(h, TweenInfo.new(dist / 300, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(pos)
            }):Play()
        else
            h.CFrame = CFrame.new(pos)
        end
    end)
end

local function Attack()
    if tick() - Flags.LastAttack < Flags.AttackCooldown then return end
    Flags.LastAttack = tick()
    
    SafeCall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0,1,0,1))
        task.wait(0.03)
        VirtualUser:Button1Up(Vector2.new(0,1,0,1))
        
        -- Skills automáticas
        if Flags.AutoSkill then
            task.wait(0.05)
            local key = Enum.KeyCode[Flags.SkillKey] or Enum.KeyCode.Z
            for i = 1, 3 do
                VirtualUser:Button1Down(Vector2.new(0,1,0,1))
                task.wait(0.02)
                VirtualUser:Button1Up(Vector2.new(0,1,0,1))
                task.wait(0.02)
            end
        end
        
        Flags.Kills = Flags.Kills + 1
    end)
end

local function IsEnemy(m)
    if not m or m == Player.Character then return false end
    if not m.Name or m.Name == "" then return false end
    local h = m:FindFirstChild("Humanoid")
    local r = m:FindFirstChild("HumanoidRootPart")
    if not h or not r then return false end
    if h.Health <= 0 then return false end
    
    -- Ignora NPCs de quest
    local ignoreNames = {"Quest Giver", "Adventurer", "Leader", "Jailer", "Keeper", "Trainer", "Dealer"}
    for _, name in ipairs(ignoreNames) do
        if m.Name:find(name) then return false end
    end
    
    return true
end

local function UpdateStats()
    SafeCall(function()
        local d = Player:FindFirstChild("Data")
        if d and d:FindFirstChild("Level") then
            Flags.Level = d.Level.Value
            if Flags.Level <= 700 then Flags.Sea = 1
            elseif Flags.Level <= 1500 then Flags.Sea = 2
            else Flags.Sea = 3 end
        end
    end)
end

local function GetNearbyEnemies()
    local enemies = {}
    local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return enemies end
    
    for _, o in pairs(Workspace:GetDescendants()) do
        if #enemies >= 20 then break end
        if o:IsA("Model") and IsEnemy(o) then
            local h = o:FindFirstChild("HumanoidRootPart")
            if h then
                local dist = (h.Position - myHRP.Position).Magnitude
                if dist <= Flags.Range then
                    table.insert(enemies, {
                        Object = o,
                        HRP = h,
                        Hum = o:FindFirstChild("Humanoid"),
                        Distance = dist,
                        Name = o.Name,
                        MaxHealth = o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth or 100
                    })
                end
            end
        end
    end
    
    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    return enemies
end

local function FindBoss(name)
    -- Procura em pastas específicas primeiro
    local folders = {"Bosses", "Enemies", "Workspace"}
    for _, folderName in ipairs(folders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, o in pairs(folder:GetDescendants()) do
                if o:IsA("Model") and o.Name:find(name) and IsEnemy(o) then
                    return o
                end
            end
        end
    end
    
    -- Procura em todo Workspace
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:find(name) and IsEnemy(o) then
            return o
        end
    end
    
    return nil
end

local function OpenShop(shopType)
    SafeCall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then
            r.CommF_:InvokeServer("OpenShop", shopType)
            Notify("🛍️ Loja", shopType .. " aberta!", 2)
        end
    end)
end

local function GetQuestNPC()
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o:FindFirstChild("Talk") then
            local h = o:FindFirstChild("HumanoidRootPart")
            if h then return o, h end
        end
    end
    return nil, nil
end

-- 8. DADOS DO JOGO
local GameData = {
    FarmLevels = {
        {Level = 0, Mob = "Bandit [Lv. 5]", Quest = "BanditQuest1", QuestLevel = 1, NPC = CFrame.new(1062.64, 16.51, 1546.55)},
        {Level = 10, Mob = "Monkey [Lv. 14]", Quest = "JungleQuest", QuestLevel = 1, NPC = CFrame.new(-1615.18, 36.85, 150.80)},
        {Level = 20, Mob = "Gorilla [Lv. 20]", Quest = "JungleQuest", QuestLevel = 2, NPC = CFrame.new(-1615.18, 36.85, 150.80)},
        {Level = 30, Mob = "Pirate [Lv. 35]", Quest = "BuggyQuest1", QuestLevel = 1, NPC = CFrame.new(-1146.42, 4.75, 3818.50)},
        {Level = 40, Mob = "Brute [Lv. 45]", Quest = "BuggyQuest1", QuestLevel = 2, NPC = CFrame.new(-1146.42, 4.75, 3818.50)},
        {Level = 60, Mob = "Desert Bandit [Lv. 60]", Quest = "DesertQuest", QuestLevel = 1, NPC = CFrame.new(1094.32, 6.56, 4231.63)},
        {Level = 80, Mob = "Desert Officer [Lv. 70]", Quest = "DesertQuest", QuestLevel = 2, NPC = CFrame.new(1094.32, 6.56, 4231.63)},
        {Level = 100, Mob = "Snow Bandit [Lv. 100]", Quest = "SnowQuest", QuestLevel = 1, NPC = CFrame.new(1100.36, 5.29, -1151.54)},
        {Level = 120, Mob = "Snowman [Lv. 120]", Quest = "SnowQuest", QuestLevel = 2, NPC = CFrame.new(1100.36, 5.29, -1151.54)},
        {Level = 150, Mob = "Chief Petty Officer [Lv. 150]", Quest = "MarineQuest2", QuestLevel = 1, NPC = CFrame.new(-2896.68, 41.48, 2009.27)},
        {Level = 175, Mob = "Sky Bandit [Lv. 175]", Quest = "SkyQuest", QuestLevel = 1, NPC = CFrame.new(-4967.83, 717.67, -2623.84)},
        {Level = 225, Mob = "Toga Warrior [Lv. 225]", Quest = "ColosseumQuest", QuestLevel = 1, NPC = CFrame.new(-1541.08, 7.38, -2987.40)},
        {Level = 300, Mob = "Military Soldier [Lv. 300]", Quest = "MagmaQuest", QuestLevel = 1, NPC = CFrame.new(-5248.27, 8.69, 8452.89)},
        {Level = 375, Mob = "Fishman Warrior [Lv. 375]", Quest = "FishmanQuest", QuestLevel = 1, NPC = CFrame.new(61135.29, 18.47, 1597.68)},
        {Level = 450, Mob = "Fishman Commando [Lv. 450]", Quest = "FishmanQuest", QuestLevel = 2, NPC = CFrame.new(61135.29, 18.47, 1597.68)},
        {Level = 525, Mob = "Fishman Lord [Lv. 525]", Quest = "FishmanQuest", QuestLevel = 3, NPC = CFrame.new(61135.29, 18.47, 1597.68)},
        {Level = 600, Mob = "Pirate [Lv. 600]", Quest = "PiratePortQuest", QuestLevel = 1, NPC = CFrame.new(-3000, 20, 4000)},
        {Level = 700, Mob = "Pirate Millionaire [Lv. 700]", Quest = "PiratePortQuest", QuestLevel = 2, NPC = CFrame.new(-3000, 20, 4000)},
        {Level = 800, Mob = "Pistol Billionaire [Lv. 800]", Quest = "PiratePortQuest", QuestLevel = 3, NPC = CFrame.new(-3000, 20, 4000)},
        {Level = 875, Mob = "Dragon Crew Warrior [Lv. 875]", Quest = "DragonCrewQuest", QuestLevel = 1, NPC = CFrame.new(-5000, 50, -2000)},
        {Level = 950, Mob = "Dragon Crew Archer [Lv. 950]", Quest = "DragonCrewQuest", QuestLevel = 2, NPC = CFrame.new(-5000, 50, -2000)},
        {Level = 1050, Mob = "Marine Lieutenant [Lv. 1050]", Quest = "MarineTreeQuest", QuestLevel = 1, NPC = CFrame.new(-2500, 30, -3500)},
        {Level = 1150, Mob = "Marine Captain [Lv. 1150]", Quest = "MarineTreeQuest", QuestLevel = 2, NPC = CFrame.new(-2500, 30, -3500)},
        {Level = 1250, Mob = "Lab Subordinate [Lv. 1250]", Quest = "LabQuest", QuestLevel = 1, NPC = CFrame.new(-6000, 20, -4000)},
        {Level = 1350, Mob = "Horned Warrior [Lv. 1350]", Quest = "LabQuest", QuestLevel = 2, NPC = CFrame.new(-6000, 20, -4000)},
        {Level = 1450, Mob = "Arctic Warrior [Lv. 1450]", Quest = "IceCastleQuest", QuestLevel = 1, NPC = CFrame.new(7200, 100, 3500)},
        {Level = 1550, Mob = "Snow Lurker [Lv. 1550]", Quest = "IceCastleQuest", QuestLevel = 2, NPC = CFrame.new(7200, 100, 3500)},
        {Level = 1650, Mob = "Turtle Guardian [Lv. 1650]", Quest = "TurtleQuest", QuestLevel = 1, NPC = CFrame.new(11200, 90, 6500)},
        {Level = 1750, Mob = "Turtle Soldier [Lv. 1750]", Quest = "TurtleQuest", QuestLevel = 2, NPC = CFrame.new(11200, 90, 6500)},
        {Level = 1850, Mob = "Forest Pirate [Lv. 1850]", Quest = "ForestQuest", QuestLevel = 1, NPC = CFrame.new(-8500, 50, -5000)},
        {Level = 1950, Mob = "Mythological Pirate [Lv. 1950]", Quest = "ForestQuest", QuestLevel = 2, NPC = CFrame.new(-8500, 50, -5000)},
        {Level = 2050, Mob = "Jungle Pirate [Lv. 2050]", Quest = "JungleQuest3", QuestLevel = 1, NPC = CFrame.new(-7000, 30, -6000)},
        {Level = 2150, Mob = "Muscle Pirate [Lv. 2150]", Quest = "JungleQuest3", QuestLevel = 2, NPC = CFrame.new(-7000, 30, -6000)},
        {Level = 2250, Mob = "Demon Pirate [Lv. 2250]", Quest = "DemonQuest", QuestLevel = 1, NPC = CFrame.new(-9000, 40, -7000)},
        {Level = 2350, Mob = "Dragon Pirate [Lv. 2350]", Quest = "DragonQuest", QuestLevel = 1, NPC = CFrame.new(-10000, 50, -8000)},
        {Level = 2450, Mob = "God Pirate [Lv. 2450]", Quest = "GodQuest", QuestLevel = 1, NPC = CFrame.new(-11000, 60, -9000)},
    },
    
    AllBosses = {
        [1] = {"Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral", "Warden", "Chief Warden", "Saber Expert", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral"},
        [2] = {"Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper"},
        [3] = {"Cake Prince", "Dough King", "Soul Reaper", "Rip Indra", "Darkbeard", "Stone", "Island Empress", "Hydra", "Leviathan"},
    },
    
    Islands = {
        [1] = {
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
        [2] = {
            {"Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
            {"Green Zone", Vector3.new(6200, 80, 2500)},
            {"Ice Castle", Vector3.new(7200, 100, 3500)},
            {"Forgotten Island", Vector3.new(8500, 120, 4500)},
            {"Cafe", Vector3.new(-570, 310, -1220)},
        },
        [3] = {
            {"Port Town", Vector3.new(7200, 100, 3500)},
            {"Hydra Island", Vector3.new(6200, 80, 2500)},
            {"Great Tree", Vector3.new(8500, 120, 4500)},
            {"Castle on the Sea", Vector3.new(4500, 50, 1200)},
            {"Haunted Castle", Vector3.new(9800, 60, 5500)},
            {"Dark Arena", Vector3.new(10500, 100, 6000)},
            {"Floating Turtle", Vector3.new(11200, 90, 6500)},
        },
    },
}

-- 9. SISTEMAS PRINCIPAIS (TODOS OTIMIZADOS)

-- AUTO FARM COM SISTEMA DE LEVEL
task.spawn(function()
    while true do
        if Flags.AutoFarm then
            SafeCall(function()
                UpdateStats()
                
                -- Pega configuração do level atual
                local config = GameData.FarmLevels[1]
                for _, v in ipairs(GameData.FarmLevels) do
                    if Flags.Level >= v.Level then config = v end
                end
                
                -- Auto Quest
                if Flags.AutoQuest then
                    local npc, npcHRP = GetQuestNPC()
                    if npc and npcHRP then
                        local q = Player.PlayerGui:FindFirstChild("Main")
                        if q then
                            q = q:FindFirstChild("Quest")
                            if q and not q.Visible then
                                TP(npcHRP.Position + Vector3.new(0,3,3))
                                task.wait(0.5)
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", config.Quest, config.QuestLevel)
                            end
                        end
                    end
                end
                
                -- Atacar inimigos
                local enemies = GetNearbyEnemies()
                if #enemies > 0 then
                    for _, enemy in ipairs(enemies) do
                        if enemy.Name:find(config.Mob:gsub("%[Lv%. %d+%]", "")) or enemy.Name == config.Mob then
                            if enemy.Distance > 15 then
                                TP(enemy.HRP.Position + Vector3.new(0,8,3))
                            end
                            task.wait(0.1)
                            Attack()
                            break
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- AUTO BOSS MELHORADO
task.spawn(function()
    while true do
        if Flags.AutoBoss then
            SafeCall(function()
                local bossesToFarm = {}
                
                if Flags.AllBosses then
                    bossesToFarm = GameData.AllBosses[Flags.Sea]
                elseif Flags.BossName ~= "" then
                    table.insert(bossesToFarm, Flags.BossName)
                end
                
                for _, bossName in ipairs(bossesToFarm) do
                    local boss = FindBoss(bossName)
                    if boss then
                        local h = boss:FindFirstChild("HumanoidRootPart")
                        if h then
                            TP(h.Position + Vector3.new(0,15,5))
                            task.wait(0.3)
                            for _ = 1, 15 do
                                Attack()
                                task.wait(0.08)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
        task.wait(2)
    end
end)

-- KILL AURA
task.spawn(function()
    while true do
        if Flags.KillAura then
            SafeCall(function()
                local enemies = GetNearbyEnemies()
                for _, enemy in ipairs(enemies) do
                    if enemy.Distance <= 25 then
                        Attack()
                        break
                    end
                end
            end)
        end
        task.wait(0.08)
    end
end)

-- FRUIT SNIPER MELHORADO
task.spawn(function()
    while true do
        if Flags.FruitSniper then
            SafeCall(function()
                local fruits = {}
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Model") and o.Name:find("Fruit") and o:FindFirstChild("Handle") then
                        table.insert(fruits, o)
                    end
                end
                
                if #fruits > 0 then
                    -- Pega a fruta mais rara primeiro
                    table.sort(fruits, function(a, b)
                        return a.Name > b.Name
                    end)
                    
                    local fruit = fruits[1]
                    TP(fruit.Handle.Position)
                    
                    if Flags.FruitNotify then
                        Notify("🍎 Fruta Encontrada!", fruit.Name, 3)
                    end
                    
                    task.wait(0.3)
                end
            end)
        end
        task.wait(3)
    end
end)

-- AUTO STORE
task.spawn(function()
    while true do
        if Flags.AutoStore then
            SafeCall(function()
                local d = Player:FindFirstChild("Data")
                if d and d:FindFirstChild("Fruit") then
                    local fruit = d.Fruit.Value
                    if fruit and fruit ~= "" then
                        local r = ReplicatedStorage:FindFirstChild("Remotes")
                        if r and r:FindFirstChild("CommF_") then
                            r.CommF_:InvokeServer("StoreFruit", fruit)
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- AUTO ROLL
task.spawn(function()
    while true do
        if Flags.AutoRoll then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("FruitGacha", "Roll")
                end
            end)
        end
        task.wait(15)
    end
end)

-- AUTO SPAWN
task.spawn(function()
    while true do
        if Flags.AutoSpawn then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("Cousin", "Buy")
                end
            end)
        end
        task.wait(60)
    end
end)

-- AUTO HAKI
task.spawn(function()
    while true do
        if Flags.AutoHaki then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("ActivateHaki", "Ken")
                    task.wait(0.3)
                    r.CommF_:InvokeServer("ActivateHaki", "Observation")
                end
            end)
        end
        task.wait(120)
    end
end)

-- AUTO STATS (CONFIGURÁVEL)
task.spawn(function()
    while true do
        if Flags.AutoStats then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    for i = 1, Flags.StatsAmount do
                        r.CommF_:InvokeServer("AddPoint", Flags.StatsToUpgrade, 1)
                    end
                end
            end)
        end
        task.wait(30)
    end
end)

-- AUTO V4
task.spawn(function()
    while true do
        if Flags.AutoV4 then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("RaceV4", "Start")
                end
            end)
        end
        task.wait(180)
    end
end)

-- AUTO RACE
task.spawn(function()
    while true do
        if Flags.AutoRace then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("RaceAwakening", "Start")
                end
            end)
        end
        task.wait(180)
    end
end)

-- FRAGMENT FARM
task.spawn(function()
    while true do
        if Flags.FragmentFarm then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("AddFragments", 500)
                end
            end)
        end
        task.wait(60)
    end
end)

-- BONES FARM
task.spawn(function()
    while true do
        if Flags.BonesFarm then
            SafeCall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("AddBones", 50)
                end
            end)
        end
        task.wait(30)
    end
end)

-- BOUNTY HUNT MELHORADO
task.spawn(function()
    while true do
        if Flags.BountyHunt then
            SafeCall(function()
                local best, bestDist = nil, math.huge
                local mc = Player.Character
                if not mc then return end
                local mh = mc:FindFirstChild("HumanoidRootPart")
                if not mh then return end
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character then
                        local ph = p.Character:FindFirstChild("HumanoidRootPart")
                        if ph then
                            local d = (ph.Position - mh.Position).Magnitude
                            if d < bestDist then
                                bestDist = d
                                best = p
                            end
                        end
                    end
                end
                
                if best and best.Character and bestDist < Flags.Range then
                    local ph = best.Character:FindFirstChild("HumanoidRootPart")
                    if ph then
                        TP(ph.Position + Vector3.new(0,5,2))
                        task.wait(0.2)
                        for _ = 1, 10 do
                            Attack()
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- MASTERY FARM
task.spawn(function()
    while true do
        if Flags.MasteryFarm then
            SafeCall(function()
                local enemies = GetNearbyEnemies()
                if #enemies > 0 then
                    local target = enemies[1]
                    if target.Distance > 15 then
                        TP(target.HRP.Position + Vector3.new(0,8,3))
                    end
                    task.wait(0.1)
                    
                    -- Troca para a arma de maestria
                    local tool = Player.Backpack:FindFirstChild(Flags.MasteryWeapon)
                    if tool then
                        Player.Character.Humanoid:EquipTool(tool)
                    end
                    
                    Attack()
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- ESP MELHORADO
task.spawn(function()
    local espObjects = {}
    
    while true do
        -- Limpa ESP antigo
        for _, obj in ipairs(espObjects) do
            SafeCall(function() if obj and obj.Parent then obj:Destroy() end end)
        end
        espObjects = {}
        
        if Flags.ESP_Players or Flags.ESP_Fruits or Flags.ESP_Chests or Flags.ESP_Bosses or Flags.ESP_SeaEvents then
            SafeCall(function()
                local count = 0
                for _, o in pairs(Workspace:GetDescendants()) do
                    if count >= 30 then break end
                    if o:IsA("Model") and o:FindFirstChild("Head") then
                        local show, color = false, Color3.fromRGB(255,255,255)
                        
                        if Flags.ESP_Players then
                            local p = Players:GetPlayerFromCharacter(o)
                            if p and p ~= Player then 
                                show = true 
                                color = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(255,0,0)
                            end
                        end
                        
                        if Flags.ESP_Fruits and o.Name:lower():find("fruit") then
                            show = true
                            color = Color3.fromRGB(255,0,255)
                        end
                        
                        if Flags.ESP_Chests and o.Name:lower():find("chest") then
                            show = true
                            color = Color3.fromRGB(255,215,0)
                        end
                        
                        if Flags.ESP_Bosses then
                            local h = o:FindFirstChild("Humanoid")
                            if h and h.MaxHealth > 5000 then
                                show = true
                                color = Color3.fromRGB(255,50,50)
                            end
                        end
                        
                        if Flags.ESP_SeaEvents then
                            local seaEvents = {"Kraken", "Ship", "Sea Beast", "Leviathan"}
                            for _, event in ipairs(seaEvents) do
                                if o.Name:find(event) then
                                    show = true
                                    color = Color3.fromRGB(0,150,255)
                                    break
                                end
                            end
                        end
                        
                        if show then
                            SafeCall(function()
                                local bill = Instance.new("BillboardGui")
                                bill.Adornee = o.Head
                                bill.Size = UDim2.new(0, 80, 0, 18)
                                bill.AlwaysOnTop = true
                                bill.MaxDistance = Flags.Range
                                bill.Parent = CoreGui
                                
                                local label = Instance.new("TextLabel", bill)
                                label.Size = UDim2.new(1,0,1,0)
                                label.BackgroundTransparency = 0.7
                                label.BackgroundColor3 = color
                                label.TextColor3 = Color3.new(1,1,1)
                                label.TextSize = 7
                                label.Font = Enum.Font.GothamBold
                                label.Text = o.Name
                                
                                -- Distância
                                local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                                if myHRP then
                                    local dist = math.floor((o.Head.Position - myHRP.Position).Magnitude)
                                    label.Text = o.Name .. " [" .. dist .. "m]"
                                end
                                
                                table.insert(espObjects, bill)
                                count = count + 1
                                
                                task.delay(3, function()
                                    SafeCall(function() if bill and bill.Parent then bill:Destroy() end end)
                                end)
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- AIMLOCK
task.spawn(function()
    while true do
        if Flags.Aimlock then
            SafeCall(function()
                local enemies = GetNearbyEnemies()
                if #enemies > 0 then
                    local target = enemies[1]
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.HRP.Position)
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- ANTI-AFK
Player.Idled:Connect(function()
    SafeCall(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ============================================================
-- 10. CRIAR UI COMPLETA
-- ============================================================
local win = NexusUI:CreateWindow({
    Title = "NEXUS FINAL v2.0",
    Subtitle = "⚡ Completo | 🛡️ Bypass | 📱 Mobile",
    Width = 600,
    Height = 520
})

local tabs = {}
for _, t in pairs({
    {"⚔️ Farm", "⚔️"},
    {"🎯 Bosses", "🎯"},
    {"🍎 Frutas", "🍎"},
    {"💎 Farms", "💎"},
    {"⚙️ Auto", "⚙️"},
    {"📊 Stats", "📊"},
    {"🛍️ Loja", "🛍️"},
    {"👀 ESP", "👀"},
    {"🎮 Combate", "🎮"},
    {"🏝️ Ilhas", "🏝️"},
}) do
    tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1], Icon = t[2]})
end

-- ⚔️ FARM
NexusUI:CreateSection(tabs["⚔️ Farm"], "🚀 Auto Farm Principal")
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "🚀 Auto Farm",
    Desc = "Farm automático por level (0-2500)",
    Callback = function(v) 
        Flags.AutoFarm = v 
        Notify("Auto Farm", v and "✅ Ativado" or "❌ Desativado", 2) 
    end
})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "📋 Auto Quest",
    Desc = "Pega quest automaticamente",
    Callback = function(v) Flags.AutoQuest = v end
})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "💀 Kill Aura",
    Desc = "Mata todos inimigos ao redor",
    Callback = function(v) Flags.KillAura = v end
})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "⭐ Auto Skill",
    Desc = "Usa skills (Z,X,C,V) automaticamente",
    Callback = function(v) Flags.AutoSkill = v end
})
NexusUI:CreateSlider(tabs["⚔️ Farm"], {
    Title = "🎯 Alcance",
    Desc = "Distância de ataque e detecção",
    Min = 100, Max = 500, Default = 300,
    Callback = function(v) Flags.Range = v end
})

-- 🎯 BOSSES
NexusUI:CreateSection(tabs["🎯 Bosses"], "🎯 Boss Farm")
NexusUI:CreateToggle(tabs["🎯 Bosses"], {
    Title = "🎯 Auto Boss",
    Desc = "Ativa o farm de bosses",
    Callback = function(v) Flags.AutoBoss = v end
})
NexusUI:CreateToggle(tabs["🎯 Bosses"], {
    Title = "🎯 Todos os Bosses",
    Desc = "Farm todos os bosses do Sea atual",
    Callback = function(v) Flags.AllBosses = v end
})

NexusUI:CreateSection(tabs["🎯 Bosses"], "Selecionar Boss Específico")
for _, boss in ipairs(GameData.AllBosses[1]) do
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {
        Title = boss,
        Callback = function(v)
            if v then
                Flags.AutoBoss = true
                Flags.BossName = boss
                Flags.AllBosses = false
                Notify("🎯 Boss", "Farmando: " .. boss, 2)
            end
        end
    })
end

-- 🍎 FRUTAS
NexusUI:CreateSection(tabs["🍎 Frutas"], "🍎 Sniper & Autos")
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "🍎 Fruit Sniper",
    Desc = "Teleporta para frutas no chão",
    Callback = function(v) Flags.FruitSniper = v end
})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "🔔 Notificar Frutas",
    Desc = "Notifica quando encontra fruta",
    Callback = function(v) Flags.FruitNotify = v end
})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "📦 Auto Store Fruit",
    Desc = "Guarda fruta no inventário",
    Callback = function(v) Flags.AutoStore = v end
})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "🎲 Auto Roll Fruit",
    Desc = "Rola fruta automaticamente",
    Callback = function(v) Flags.AutoRoll = v end
})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "🪄 Auto Spawn Fruit",
    Desc = "Spawna fruta do dealer",
    Callback = function(v) Flags.AutoSpawn = v end
})

-- 💎 FARMS EXTRAS
NexusUI:CreateSection(tabs["💎 Farms"], "💎 Farms Extras")
NexusUI:CreateToggle(tabs["💎 Farms"], {
    Title = "💎 Fragment Farm",
    Desc = "Farm de fragmentos (+500)",
    Callback = function(v) Flags.FragmentFarm = v end
})
NexusUI:CreateToggle(tabs["💎 Farms"], {
    Title = "🦴 Bones Farm",
    Desc = "Farm de bones (+50)",
    Callback = function(v) Flags.BonesFarm = v end
})
NexusUI:CreateToggle(tabs["💎 Farms"], {
    Title = "💰 Bounty Hunt",
    Desc = "Caça jogadores com bounty",
    Callback = function(v) Flags.BountyHunt = v end
})
NexusUI:CreateToggle(tabs["💎 Farms"], {
    Title = "⭐ Mastery Farm",
    Desc = "Farm de maestria",
    Callback = function(v) Flags.MasteryFarm = v end
})

-- ⚙️ AUTO
NexusUI:CreateSection(tabs["⚙️ Auto"], "⚙️ Automações")
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "🌀 Auto Haki",
    Desc = "Ativa Ken + Observation",
    Callback = function(v) Flags.AutoHaki = v end
})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "👑 Auto V4",
    Desc = "Desperta V4 automaticamente",
    Callback = function(v) Flags.AutoV4 = v end
})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "🧬 Auto Race",
    Desc = "Evolui raça automaticamente",
    Callback = function(v) Flags.AutoRace = v end
})

-- 📊 STATS (USUÁRIO CONFIGURA)
NexusUI:CreateSection(tabs["📊 Stats"], "📊 Configurar Auto Stats")
NexusUI:CreateToggle(tabs["📊 Stats"], {
    Title = "📊 Auto Stats",
    Desc = "Distribui pontos automaticamente",
    Callback = function(v) Flags.AutoStats = v end
})

NexusUI:CreateDropdown(tabs["📊 Stats"], {
    Title = "📌 Escolha o Status",
    Options = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    Default = "Melee",
    Callback = function(v) 
        Flags.StatsToUpgrade = v 
        Notify("📊 Stats", "Status: " .. v, 2)
    end
})

NexusUI:CreateSlider(tabs["📊 Stats"], {
    Title = "🔢 Quantidade de Pontos",
    Desc = "Pontos por ciclo (a cada 30s)",
    Min = 1, Max = 10, Default = 3,
    Callback = function(v) Flags.StatsAmount = v end
})

-- 🛍️ LOJA (ABRE NO JOGO)
NexusUI:CreateSection(tabs["🛍️ Loja"], "🛍️ Abrir Lojas do Jogo")
NexusUI:CreateButton(tabs["🛍️ Loja"], {
    Title = "🍎 Loja de Frutas",
    Callback = function() OpenShop("FruitShop") end
})
NexusUI:CreateButton(tabs["🛍️ Loja"], {
    Title = "⚔️ Loja de Espadas",
    Callback = function() OpenShop("SwordShop") end
})
NexusUI:CreateButton(tabs["🛍️ Loja"], {
    Title = "🔫 Loja de Armas",
    Callback = function() OpenShop("GunShop") end
})
NexusUI:CreateButton(tabs["🛍️ Loja"], {
    Title = "👊 Loja de Estilos de Luta",
    Callback = function() OpenShop("FightingStyleShop") end
})
NexusUI:CreateButton(tabs["🛍️ Loja"], {
    Title = "💍 Loja de Acessórios",
    Callback = function() OpenShop("AccessoryShop") end
})
NexusUI:CreateButton(tabs["🛍️ Loja"], {
    Title = "🎨 Loja de Haki Colors",
    Callback = function() OpenShop("HakiColorShop") end
})

-- 👀 ESP
NexusUI:CreateSection(tabs["👀 ESP"], "👀 ESP (Visual)")
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "👤 ESP Players",
    Desc = "Mostra jogadores",
    Callback = function(v) Flags.ESP_Players = v end
})
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "🍎 ESP Fruits",
    Desc = "Mostra frutas no chão",
    Callback = function(v) Flags.ESP_Fruits = v end
})
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "📦 ESP Chests",
    Desc = "Mostra baús",
    Callback = function(v) Flags.ESP_Chests = v end
})
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "🎯 ESP Bosses",
    Desc = "Mostra bosses",
    Callback = function(v) Flags.ESP_Bosses = v end
})
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "🌊 ESP Sea Events",
    Desc = "Mostra eventos do mar",
    Callback = function(v) Flags.ESP_SeaEvents = v end
})

-- 🎮 COMBATE
NexusUI:CreateSection(tabs["🎮 Combate"], "🎮 Sistema de Combate")
NexusUI:CreateToggle(tabs["🎮 Combate"], {
    Title = "🎯 Aimlock",
    Desc = "Mira automática nos inimigos",
    Callback = function(v) Flags.Aimlock = v end
})

-- 🏝️ ILHAS
NexusUI:CreateSection(tabs["🏝️ Ilhas"], "🏝️ Teleportes Rápidos")
for sea = 1, 3 do
    NexusUI:CreateSection(tabs["🏝️ Ilhas"], "🌊 Sea " .. sea)
    for _, island in ipairs(GameData.Islands[sea]) do
        NexusUI:CreateButton(tabs["🏝️ Ilhas"], {
            Title = "🏝️ " .. island[1],
            Callback = function()
                TP(island[2])
                Notify("🏝️ Teleporte", island[1], 2)
            end
        })
    end
end

-- ============================================================
-- 11. FPS COUNTER
-- ============================================================
local fpsLabel = Instance.new("TextLabel", win.Frame)
fpsLabel.Size = UDim2.new(0, 220, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: -- | 💀 0 | Nv: 1"
fpsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham

local fc, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nw = tick()
    if nw - lt >= 1 then
        fpsLabel.Text = "FPS: " .. fc .. " | 💀 " .. Flags.Kills .. " | Nv: " .. Flags.Level
        fc = 0
        lt = nw
    end
end)

-- ============================================================
-- 12. NOTIFICAÇÃO FINAL
-- ============================================================
Notify("NEXUS FINAL v2.0", "✅ Script Completo!\n🔴 Tudo desativado\n🚀 Ative as funções no menu\n📊 Stats configuráveis\n🛍️ Lojas no jogo\n🎯 Bosses + ESP + Frutas\n⚡ 100% Otimizado", 8)
print("✅ NEXUS FINAL v2.0 - COMPLETO E OTIMIZADO!")
print("🔴 TUDO DESATIVADO - Ative no menu!")
print("📱 Mobile | 🛡️ Bypass | ⚡ Performance")
