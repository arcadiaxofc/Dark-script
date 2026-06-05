-- ============================================================
-- NEXUS v10.0 - BLOX FRUITS COMPLETO
-- Deixa sua conta FORTE: Max Level, Frutas, Haki, V4, Race
-- ============================================================

-- [[ CONFIGURAÇÕES ]]
local CONFIG = {
    HubName = "NEXUS",
    Version = "v10.0",
    AntiAFK = true,
    FastAttack = true,
    AutoReconnect = true,
}

-- [[ SERVIÇOS ]]
local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualUser = game:GetService("VirtualUser"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    Lighting = game:GetService("Lighting"),
    HttpService = game:GetService("HttpService"),
    TeleportService = game:GetService("TeleportService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    CollectionService = game:GetService("CollectionService"),
}

-- [[ PLAYER ]]
local Player = Services.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Services.Workspace.CurrentCamera

-- [[ VARIÁVEIS ]]
local Flags = {
    -- Farm Principal
    AutoFarm = false,
    FarmMethod = "Level", -- Level, Boss, Mastery, Haki, V4, Race, Fragment, Bone
    
    -- Bosses
    AutoBoss = false,
    BossName = "",
    AllBosses = false,
    
    -- Skills
    AutoSkill = false,
    SkillKey = "Z",
    
    -- Proteção
    GodMode = false,
    InfiniteEnergy = false,
    NoStun = false,
    
    -- Movimento
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    Walkspeed = false,
    WalkSpeedValue = 100,
    JumpPower = false,
    JumpPowerValue = 150,
    
    -- Auto Upgrades
    AutoStats = false,
    AutoHaki = false,
    AutoV4 = false,
    AutoRace = false,
    AutoShop = false,
    
    -- Frutas
    AutoStore = false,
    AutoRoll = false,
    FruitSniper = false,
    
    -- ESP
    ESP = false,
    ESPType = "Players", -- Players, Fruits, Chests, Bosses
    
    -- Combate
    KillAura = false,
    Aimlock = false,
    AutoBounty = false,
    
    -- Range
    Range = 300,
    Kills = 0,
    Level = 1,
    Sea = 1,
    Beli = 0,
    Fragments = 0,
}

-- [[ UTILITÁRIOS ]]
local Utils = {}

function Utils.Notify(Title, Text, Duration)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = Title or CONFIG.HubName,
            Text = Text or "",
            Duration = Duration or 3,
        })
    end)
end

function Utils.TP(Position)
    pcall(function()
        local Char = Player.Character
        if not Char then return end
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
        
        local Distance = (Position - HRP.Position).Magnitude
        if Distance < 10 then
            HRP.CFrame = CFrame.new(Position)
        else
            local Speed = Distance < 170 and 350 or 300
            Services.TweenService:Create(HRP, TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(Position)
            }):Play()
        end
    end)
end

function Utils.TPTo(CFrameObj)
    if typeof(CFrameObj) == "CFrame" then
        Utils.TP(CFrameObj.Position)
    elseif typeof(CFrameObj) == "Vector3" then
        Utils.TP(CFrameObj)
    end
end

function Utils.Attack()
    pcall(function()
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
        task.wait(CONFIG.FastAttack and 0.01 or 0.05)
        Services.VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
        Flags.Kills = Flags.Kills + 1
    end)
end

function Utils.Skill(Key)
    pcall(function()
        local KeyCode = typeof(Key) == "string" and Enum.KeyCode[Key] or Key
        Services.VirtualInputManager:SendKeyEvent(true, KeyCode, false, game)
        task.wait(0.1)
        Services.VirtualInputManager:SendKeyEvent(false, KeyCode, false, game)
    end)
end

function Utils.UpdateStats()
    pcall(function()
        if Player.Data then
            if Player.Data:FindFirstChild("Level") then
                Flags.Level = Player.Data.Level.Value
            end
            if Player.Data:FindFirstChild("Beli") then
                Flags.Beli = Player.Data.Beli.Value
            end
            if Player.Data:FindFirstChild("Fragments") then
                Flags.Fragments = Player.Data.Fragments.Value
            end
            
            Flags.Sea = Flags.Level <= 700 and 1 or Flags.Level <= 1500 and 2 or 3
        end
    end)
end

function Utils.IsAlive()
    local Char = Player.Character
    if not Char then return false end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    return Hum and Hum.Health > 0
end

function Utils.GetHRP()
    local Char = Player.Character
    if not Char then return nil end
    return Char:FindFirstChild("HumanoidRootPart")
end

function Utils.IsEnemy(Model)
    if not Model or Model == Player.Character then return false end
    local Hum = Model:FindFirstChild("Humanoid")
    local HRP = Model:FindFirstChild("HumanoidRootPart")
    return Hum and HRP and Hum.Health > 0
end

function Utils.FindBoss(Name)
    -- Procura boss em várias pastas
    local Folders = {"Bosses", "Enemies", "Workspace"}
    for _, FolderName in ipairs(Folders) do
        local Folder = Services.Workspace:FindFirstChild(FolderName)
        if Folder then
            for _, Obj in ipairs(Folder:GetChildren()) do
                if Obj:IsA("Model") and Obj.Name:find(Name) and Utils.IsEnemy(Obj) then
                    return Obj
                end
            end
        end
    end
    
    -- Procura em todo workspace
    for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name:find(Name) and Utils.IsEnemy(Obj) then
            return Obj
        end
    end
    
    return nil
end

-- [[ DADOS DO JOGO ]]
local GameData = {
    -- Sea 1 Islands
    Islands = {
        [1] = {
            {"Pirate Starter Island", CFrame.new(1289, 11, 4191)},
            {"Jungle", CFrame.new(-1250, 15, 3850)},
            {"Desert", CFrame.new(966, 10, 1100)},
            {"Frozen Village", CFrame.new(1150, 25, 4350)},
            {"Marine Fortress", CFrame.new(-1500, 10, 5300)},
            {"Skylands", CFrame.new(-4850, 750, 1950)},
            {"Prison", CFrame.new(-5400, 15, -1700)},
            {"Colosseum", CFrame.new(-3560, 240, -80)},
            {"Magma Village", CFrame.new(-3420, 10, -2700)},
            {"Underwater City", CFrame.new(5500, -50, 2000)},
            {"Fountain City", CFrame.new(4500, 50, 1200)},
        },
        [2] = {
            {"Kingdom of Rose", CFrame.new(-1400, 10, -1400)},
            {"Green Zone", CFrame.new(6200, 80, 2500)},
            {"Ice Castle", CFrame.new(7200, 100, 3500)},
            {"Forgotten Island", CFrame.new(8500, 120, 4500)},
            {"Cafe", CFrame.new(-570, 310, -1220)},
        },
        [3] = {
            {"Port Town", CFrame.new(7200, 100, 3500)},
            {"Hydra Island", CFrame.new(6200, 80, 2500)},
            {"Great Tree", CFrame.new(8500, 120, 4500)},
            {"Castle on the Sea", CFrame.new(4500, 50, 1200)},
            {"Haunted Castle", CFrame.new(9800, 60, 5500)},
            {"Dark Arena", CFrame.new(10500, 100, 6000)},
            {"Floating Turtle", CFrame.new(11200, 90, 6500)},
        },
    },
    
    -- Bosses
    Bosses = {
        [1] = {
            "Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral",
            "Warden", "Chief Warden", "Saber Expert", "Swan", "Magma Admiral",
            "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral",
        },
        [2] = {
            "Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral",
            "Awakened Ice Admiral", "Tide Keeper",
        },
        [3] = {
            "Cake Prince", "Dough King", "Soul Reaper", "Rip Indra",
            "Darkbeard", "Stone", "Island Empress", "Hydra", "Leviathan",
        },
    },
    
    -- Farm por Level
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
    
    -- Frutas
    Fruits = {
        [1] = {"Rocket-Fruit", "Spin-Fruit", "Blade-Fruit", "Spring-Fruit", "Bomb-Fruit", "Smoke-Fruit", "Spike-Fruit", "Flame-Fruit", "Eagle-Fruit", "Ice-Fruit", "Sand-Fruit", "Dark-Fruit", "Diamond-Fruit", "Light-Fruit", "Barrier-Fruit", "Magma-Fruit", "Rumble-Fruit"},
        [2] = {"Creation-Fruit", "Quake-Fruit", "Buddha-Fruit", "Love-Fruit", "Spider-Fruit", "Sound-Fruit", "Phoenix-Fruit", "Portal-Fruit", "Lightning-Fruit", "Pain-Fruit", "Blizzard-Fruit"},
        [3] = {"Gravity-Fruit", "Mammoth-Fruit", "T-Rex-Fruit", "Dough-Fruit", "Shadow-Fruit", "Venom-Fruit", "Control-Fruit", "Gas-Fruit", "Spirit-Fruit", "Tiger-Fruit", "Yeti-Fruit", "Kitsune-Fruit", "Dragon-Fruit", "Leopard-Fruit"},
    },
    
    -- Itens da Loja
    Shop = {
        Swords = {"Cursed Dual Katana", "Dark Blade", "True Triple Katana", "Shark Anchor", "Spikey Trident"},
        Guns = {"Soul Guitar", "Skull Guitar", "Acidum Rifle", "Bizarre Rifle"},
        Accessories = {"Pale Scarf", "Lei", "Black Cape", "Swordsman Hat"},
        Styles = {"Superhuman", "Godhuman", "Sharkman Karate", "Electric Claw", "Dragon Talon"},
        Materials = {"Wood", "Iron", "Coal", "Gunpowder", "Leather"},
    },
}

-- [[ SISTEMAS DE FARM ]]
local FarmSystems = {}

-- Auto Farm Level
function FarmSystems.AutoFarmLevel()
    task.spawn(function()
        while task.wait() do
            if not Flags.AutoFarm or Flags.FarmMethod ~= "Level" then continue end
            
            pcall(function()
                Utils.UpdateStats()
                
                -- Pegar configuração atual
                local Config = GameData.FarmLevels[1]
                for _, v in ipairs(GameData.FarmLevels) do
                    if Flags.Level >= v.Level then Config = v end
                end
                
                -- Pegar Quest
                local QuestGui = Player.PlayerGui:FindFirstChild("Main")
                if QuestGui then
                    QuestGui = QuestGui:FindFirstChild("Quest")
                    if QuestGui and not QuestGui.Visible then
                        Utils.TP(Config.NPC.Position)
                        task.wait(0.9)
                        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Config.Quest, Config.QuestLevel)
                    end
                end
                
                -- Procurar e Atacar Mobs
                local Enemies = Services.Workspace:FindFirstChild("Enemies")
                if Enemies then
                    for _, Enemy in ipairs(Enemies:GetChildren()) do
                        if Enemy:IsA("Model") and Enemy.Name == Config.Mob then
                            local Hum = Enemy:FindFirstChild("Humanoid")
                            local HRP = Enemy:FindFirstChild("HumanoidRootPart")
                            
                            if Hum and HRP and Hum.Health > 0 then
                                HRP.Size = Vector3.new(60, 60, 60)
                                Utils.TP(HRP.Position + Vector3.new(0, 20, 0))
                                Utils.Attack()
                                
                                if Flags.AutoSkill then
                                    Utils.Skill(Flags.SkillKey)
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Auto Boss
function FarmSystems.AutoBoss()
    task.spawn(function()
        while task.wait() do
            if not Flags.AutoBoss then continue end
            
            pcall(function()
                if Flags.AllBosses then
                    -- Farmar todos os bosses do Sea atual
                    for _, BossName in ipairs(GameData.Bosses[Flags.Sea]) do
                        local Boss = Utils.FindBoss(BossName)
                        if Boss then
                            local HRP = Boss:FindFirstChild("HumanoidRootPart")
                            if HRP then
                                Utils.TP(HRP.Position + Vector3.new(0, 15, 5))
                                for _ = 1, 10 do
                                    Utils.Attack()
                                    if Flags.AutoSkill then Utils.Skill(Flags.SkillKey) end
                                    task.wait(0.05)
                                end
                            end
                        end
                        task.wait(1)
                    end
                elseif Flags.BossName ~= "" then
                    local Boss = Utils.FindBoss(Flags.BossName)
                    if Boss then
                        local HRP = Boss:FindFirstChild("HumanoidRootPart")
                        if HRP then
                            Utils.TP(HRP.Position + Vector3.new(0, 15, 5))
                            Utils.Attack()
                            if Flags.AutoSkill then Utils.Skill(Flags.SkillKey) end
                        end
                    end
                end
            end)
        end
    end)
end

-- Fruit Sniper
function FarmSystems.FruitSniper()
    task.spawn(function()
        while task.wait(5) do
            if not Flags.FruitSniper then continue end
            
            pcall(function()
                for Sea = 1, 3 do
                    for _, FruitName in ipairs(GameData.Fruits[Sea]) do
                        local Fruit = Services.Workspace:FindFirstChild(FruitName)
                        if Fruit and Fruit:FindFirstChild("Handle") then
                            Utils.TP(Fruit.Handle.Position)
                            Utils.Notify("🍎 Fruta", FruitName .. " encontrada!", 2)
                            task.wait(0.5)
                        end
                    end
                end
            end)
        end
    end)
end

-- [[ SISTEMAS DE PROTEÇÃO ]]
local ProtectionSystems = {}

function ProtectionSystems.GodMode()
    task.spawn(function()
        while task.wait(0.1) do
            if not Flags.GodMode then continue end
            pcall(function()
                local Char = Player.Character
                if Char then
                    local Hum = Char:FindFirstChildOfClass("Humanoid")
                    if Hum then
                        Hum.Health = Hum.MaxHealth
                    end
                end
            end)
        end
    end)
end

-- [[ SISTEMAS DE MOVIMENTO ]]
local MovementSystems = {}

function MovementSystems.Fly()
    task.spawn(function()
        while task.wait(0.05) do
            if not Flags.Fly then continue end
            pcall(function()
                local Char = Player.Character
                if not Char then return end
                local Hum = Char:FindFirstChildOfClass("Humanoid")
                local HRP = Utils.GetHRP()
                if not Hum or not HRP then return end
                
                Hum:ChangeState(Enum.HumanoidStateType.Freefall)
                
                -- Controles de voo
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    HRP.CFrame = HRP.CFrame * CFrame.new(0, 0, -Flags.FlySpeed * 0.01)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    HRP.CFrame = HRP.CFrame * CFrame.new(0, 0, Flags.FlySpeed * 0.01)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    HRP.CFrame = HRP.CFrame * CFrame.new(-Flags.FlySpeed * 0.01, 0, 0)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    HRP.CFrame = HRP.CFrame * CFrame.new(Flags.FlySpeed * 0.01, 0, 0)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    HRP.CFrame = HRP.CFrame * CFrame.new(0, Flags.FlySpeed * 0.01, 0)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    HRP.CFrame = HRP.CFrame * CFrame.new(0, -Flags.FlySpeed * 0.01, 0)
                end
            end)
        end
    end)
end

function MovementSystems.NoClip()
    task.spawn(function()
        while task.wait(0.3) do
            if not Flags.NoClip then continue end
            pcall(function()
                local Char = Player.Character
                if Char then
                    for _, Part in ipairs(Char:GetDescendants()) do
                        if Part:IsA("BasePart") then
                            Part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
end

function MovementSystems.Walkspeed()
    task.spawn(function()
        while task.wait(0.3) do
            if not Flags.Walkspeed then continue end
            pcall(function()
                local Char = Player.Character
                if Char then
                    local Hum = Char:FindFirstChildOfClass("Humanoid")
                    if Hum then
                        Hum.WalkSpeed = Flags.WalkSpeedValue
                    end
                end
            end)
        end
    end)
end

function MovementSystems.JumpPower()
    task.spawn(function()
        while task.wait(0.3) do
            if not Flags.JumpPower then continue end
            pcall(function()
                local Char = Player.Character
                if Char then
                    local Hum = Char:FindFirstChildOfClass("Humanoid")
                    if Hum then
                        Hum.JumpPower = Flags.JumpPowerValue
                    end
                end
            end)
        end
    end)
end

-- [[ SISTEMAS DE AUTO ]]
local AutoSystems = {}

function AutoSystems.AutoStats()
    task.spawn(function()
        while task.wait(30) do
            if not Flags.AutoStats then continue end
            pcall(function()
                local Stats = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
                for _, Stat in ipairs(Stats) do
                    Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", Stat, 3)
                end
            end)
        end
    end)
end

function AutoSystems.AutoHaki()
    task.spawn(function()
        while task.wait(120) do
            if not Flags.AutoHaki then continue end
            pcall(function()
                local Remotes = Services.ReplicatedStorage.Remotes
                Remotes.CommF_:InvokeServer("ActivateHaki", "Ken")
                Remotes.CommF_:InvokeServer("ActivateHaki", "Observation")
            end)
        end
    end)
end

function AutoSystems.AutoV4()
    task.spawn(function()
        while task.wait(180) do
            if not Flags.AutoV4 then continue end
            pcall(function()
                Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4", "Start")
            end)
        end
    end)
end

function AutoSystems.AutoRace()
    task.spawn(function()
        while task.wait(180) do
            if not Flags.AutoRace then continue end
            pcall(function()
                Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceAwakening", "Start")
            end)
        end
    end)
end

function AutoSystems.AutoStore()
    task.spawn(function()
        while task.wait(5) do
            if not Flags.AutoStore then continue end
            pcall(function()
                if Player.Data and Player.Data:FindFirstChild("Fruit") then
                    Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", Player.Data.Fruit.Value)
                end
            end)
        end
    end)
end

function AutoSystems.AutoRoll()
    task.spawn(function()
        while task.wait(15) do
            if not Flags.AutoRoll then continue end
            pcall(function()
                Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("FruitGacha", "Roll")
            end)
        end
    end)
end

function AutoSystems.AutoShop()
    task.spawn(function()
        while task.wait(300) do
            if not Flags.AutoShop then continue end
            pcall(function()
                local Remotes = Services.ReplicatedStorage.Remotes
                
                -- Comprar frutas raras
                Remotes.CommF_:InvokeServer("BuyItem", "Kitsune")
                Remotes.CommF_:InvokeServer("BuyItem", "Dragon")
                Remotes.CommF_:InvokeServer("BuyItem", "Leopard")
                
                -- Comprar espadas
                Remotes.CommF_:InvokeServer("BuyItem", "Cursed Dual Katana")
                Remotes.CommF_:InvokeServer("BuyItem", "Dark Blade")
                
                -- Comprar estilos
                Remotes.CommF_:InvokeServer("BuyItem", "Godhuman")
                
                -- Comprar acessórios
                Remotes.CommF_:InvokeServer("BuyItem", "Pale Scarf")
            end)
        end
    end)
end

-- [[ SISTEMAS DE COMBATE ]]
local CombatSystems = {}

function CombatSystems.KillAura()
    task.spawn(function()
        while task.wait(0.05) do
            if not Flags.KillAura then continue end
            
            pcall(function()
                local HRP = Utils.GetHRP()
                if not HRP then return end
                
                local Nearest = nil
                local MinDist = Flags.Range
                
                for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
                    if Utils.IsEnemy(Obj) then
                        local ObjHRP = Obj:FindFirstChild("HumanoidRootPart")
                        if ObjHRP then
                            local Dist = (ObjHRP.Position - HRP.Position).Magnitude
                            if Dist < MinDist then
                                MinDist = Dist
                                Nearest = ObjHRP
                            end
                        end
                    end
                end
                
                if Nearest then
                    HRP.CFrame = CFrame.new(HRP.Position, Nearest.Position)
                    Utils.Attack()
                    if Flags.AutoSkill then Utils.Skill(Flags.SkillKey) end
                end
            end)
        end
    end)
end

function CombatSystems.Aimlock()
    task.spawn(function()
        while task.wait(0.05) do
            if not Flags.Aimlock then continue end
            
            pcall(function()
                local HRP = Utils.GetHRP()
                if not HRP then return end
                
                local Nearest = nil
                local MinDist = Flags.Range
                
                for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
                    if Utils.IsEnemy(Obj) then
                        local ObjHRP = Obj:FindFirstChild("HumanoidRootPart")
                        if ObjHRP then
                            local Dist = (ObjHRP.Position - HRP.Position).Magnitude
                            if Dist < MinDist then
                                MinDist = Dist
                                Nearest = ObjHRP
                            end
                        end
                    end
                end
                
                if Nearest then
                    HRP.CFrame = CFrame.new(HRP.Position, Nearest.Position)
                end
            end)
        end
    end)
end

function CombatSystems.AutoBounty()
    task.spawn(function()
        while task.wait(10) do
            if not Flags.AutoBounty then continue end
            
            pcall(function()
                local Best = nil
                local BestDist = math.huge
                
                for _, Plr in ipairs(Services.Players:GetPlayers()) do
                    if Plr ~= Player and Plr.Character then
                        local PlrHRP = Plr.Character:FindFirstChild("HumanoidRootPart")
                        local MyHRP = Utils.GetHRP()
                        if PlrHRP and MyHRP then
                            local Dist = (PlrHRP.Position - MyHRP.Position).Magnitude
                            if Dist < BestDist then
                                BestDist = Dist
                                Best = Plr
                            end
                        end
                    end
                end
                
                if Best and Best.Character then
                    local PlrHRP = Best.Character:FindFirstChild("HumanoidRootPart")
                    if PlrHRP then
                        Utils.TP(PlrHRP.Position)
                        for _ = 1, 10 do
                            Utils.Attack()
                            if Flags.AutoSkill then Utils.Skill(Flags.SkillKey) end
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
    end)
end

-- [[ ESP ]]
local ESPSystems = {}

function ESPSystems.ESP()
    -- Implementação simplificada do ESP
    task.spawn(function()
        while task.wait(3) do
            if not Flags.ESP then continue end
            
            pcall(function()
                for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
                    if Obj:IsA("Model") and Obj:FindFirstChild("Head") and Obj ~= Player.Character then
                        local Show = false
                        local Color = Color3.fromRGB(255, 255, 255)
                        
                        if Flags.ESPType == "Players" then
                            local Plr = Services.Players:GetPlayerFromCharacter(Obj)
                            if Plr then
                                Show = true
                                Color = Color3.fromRGB(255, 0, 0)
                            end
                        elseif Flags.ESPType == "Fruits" and Obj.Name:find("Fruit") then
                            Show = true
                            Color = Color3.fromRGB(255, 0, 255)
                        elseif Flags.ESPType == "Chests" and Obj.Name:lower():find("chest") then
                            Show = true
                            Color = Color3.fromRGB(255, 215, 0)
                        elseif Flags.ESPType == "Bosses" then
                            local Hum = Obj:FindFirstChild("Humanoid")
                            if Hum and Hum.MaxHealth > 10000 then
                                Show = true
                                Color = Color3.fromRGB(255, 50, 50)
                            end
                        end
                        
                        if Show then
                            local Billboard = Instance.new("BillboardGui", Services.CoreGui)
                            Billboard.Adornee = Obj.Head
                            Billboard.Size = UDim2.new(0, 80, 0, 20)
                            Billboard.AlwaysOnTop = true
                            Billboard.MaxDistance = 500
                            
                            local Label = Instance.new("TextLabel", Billboard)
                            Label.Size = UDim2.new(1, 0, 1, 0)
                            Label.BackgroundTransparency = 0.7
                            Label.BackgroundColor3 = Color
                            Label.TextColor3 = Color3.new(1, 1, 1)
                            Label.TextSize = 8
                            Label.Font = Enum.Font.GothamBold
                            Label.Text = Obj.Name
                        end
                    end
                end
            end)
        end
    end)
end

-- [[ UI ]]
local function CreateUI()
    local GUI = Instance.new("ScreenGui")
    GUI.Name = CONFIG.HubName
    GUI.Parent = Services.CoreGui
    GUI.ResetOnSpawn = false
    
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 280, 0, 450)
    Main.Position = UDim2.new(0, 10, 0.5, -225)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Main.Parent = GUI
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Title.Text = "🔴 " .. CONFIG.HubName .. " " .. CONFIG.Version
    Title.TextColor3 = Color3.fromRGB(255, 70, 60)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main
    
    -- Container
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, 0, 1, -35)
    Container.Position = UDim2.new(0, 0, 0, 35)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 3
    Container.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Container.Parent = Main
    
    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 5)
    
    local Padding = Instance.new("UIPadding", Container)
    Padding.PaddingTop = UDim.new(0, 8)
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingRight = UDim.new(0, 8)
    
    -- Funções UI
    local function AddSection(Name)
        local Section = Instance.new("TextLabel")
        Section.Size = UDim2.new(1, 0, 0, 22)
        Section.BackgroundColor3 = Color3.fromRGB(255, 70, 60)
        Section.Text = "  " .. Name
        Section.TextColor3 = Color3.new(1, 1, 1)
        Section.TextSize = 11
        Section.Font = Enum.Font.GothamBold
        Section.TextXAlignment = Enum.TextXAlignment.Left
        Section.Parent = Container
        Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 4)
    end
    
    local function AddToggle(Name, Flag)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 30)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Frame.BorderSizePixel = 0
        Frame.Parent = Container
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -45, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 35, 0, 18)
        Button.Position = UDim2.new(1, -40, 0.5, -9)
        Button.Text = "OFF"
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.TextSize = 9
        Button.Font = Enum.Font.GothamBold
        Button.BackgroundColor3 = Color3.fromRGB(200, 50, 40)
        Button.BorderSizePixel = 0
        Button.AutoButtonColor = false
        Button.Parent = Frame
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
        
        local Enabled = false
        Button.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            Button.Text = Enabled and "ON" or "OFF"
            Button.BackgroundColor3 = Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 50, 40)
            Flags[Flag] = Enabled
        end)
    end
    
    -- [[ CONSTRUIR UI ]]
    
    -- FARM
    AddSection("⚔️ FARM PRINCIPAL")
    AddToggle("Auto Farm Level", "AutoFarm")
    AddToggle("Auto Boss", "AutoBoss")
    AddToggle("Farm All Bosses", "AllBosses")
    AddToggle("Auto Skill", "AutoSkill")
    AddToggle("Fruit Sniper", "FruitSniper")
    
    -- PROTEÇÃO
    AddSection("🛡️ PROTEÇÃO")
    AddToggle("God Mode", "GodMode")
    
    -- MOVIMENTO
    AddSection("🏃 MOVIMENTO")
    AddToggle("Fly", "Fly")
    AddToggle("No Clip", "NoClip")
    AddToggle("Walkspeed", "Walkspeed")
    AddToggle("Jump Power", "JumpPower")
    
    -- AUTO UPGRADES
    AddSection("⚙️ AUTO UPGRADES")
    AddToggle("Auto Stats", "AutoStats")
    AddToggle("Auto Haki", "AutoHaki")
    AddToggle("Auto V4", "AutoV4")
    AddToggle("Auto Race", "AutoRace")
    AddToggle("Auto Store Fruit", "AutoStore")
    AddToggle("Auto Roll Fruit", "AutoRoll")
    AddToggle("Auto Shop", "AutoShop")
    
    -- COMBATE
    AddSection("⚔️ COMBATE")
    AddToggle("Kill Aura", "KillAura")
    AddToggle("Aimlock", "Aimlock")
    AddToggle("Auto Bounty Hunt", "AutoBounty")
    
    -- ESP
    AddSection("👀 ESP")
    AddToggle("ESP", "ESP")
    
    -- FPS Counter
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0, 200, 0, 14)
    FPSLabel.Position = UDim2.new(0, 8, 1, -16)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "FPS: -- | Kills: 0"
    FPSLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    FPSLabel.TextSize = 9
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.Parent = Main
    
    local Frames, LastTime = 0, tick()
    Services.RunService.RenderStepped:Connect(function()
        Frames = Frames + 1
        local Now = tick()
        if Now - LastTime >= 1 then
            FPSLabel.Text = "FPS: " .. Frames .. " | Kills: " .. Flags.Kills
            Frames = 0
            LastTime = Now
        end
    end)
    
    -- Drag
    local Dragging, DragStart, StartPos = false
    Title.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = Main.Position
        end
    end)
    Title.InputEnded:Connect(function() Dragging = false end)
    Services.UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

-- [[ INICIAR TUDO ]]

-- Anti-AFK
if CONFIG.AntiAFK then
    Player.Idled:Connect(function()
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(1)
        Services.VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end)
end

-- Otimizações
pcall(function()
    settings().Rendering.QualityLevel = 1
    Services.Lighting.GlobalShadows = false
    Services.Lighting.Brightness = 2
end)

-- Iniciar Sistemas
FarmSystems.AutoFarmLevel()
FarmSystems.AutoBoss()
FarmSystems.FruitSniper()

ProtectionSystems.GodMode()

MovementSystems.Fly()
MovementSystems.NoClip()
MovementSystems.Walkspeed()
MovementSystems.JumpPower()

AutoSystems.AutoStats()
AutoSystems.AutoHaki()
AutoSystems.AutoV4()
AutoSystems.AutoRace()
AutoSystems.AutoStore()
AutoSystems.AutoRoll()
AutoSystems.AutoShop()

CombatSystems.KillAura()
CombatSystems.Aimlock()
CombatSystems.AutoBounty()

ESPSystems.ESP()

-- Criar UI
CreateUI()

-- Notificação Final
Utils.Notify(CONFIG.HubName .. " " .. CONFIG.Version, "✅ COMPLETO!\n🚀 Auto Farm Level 0-2500\n⚔️ Bosses, Haki, V4, Race\n🍎 Frutas, Loja Automática\n⚡ Conta Fica FORTE!", 8)
print("✅ " .. CONFIG.HubName .. " " .. CONFIG.Version .. " - COMPLETO!")
print("🚀 Level 0-2500 | ⚔️ Bosses | 🛡️ Haki/V4/Race | 🍎 Frutas")
