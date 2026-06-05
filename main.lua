-- ============================================================
-- NEXUS v11.0 - COMPLETO 100% AUTOMÁTICO
-- Tudo começa DESATIVADO
-- Ative Auto Farm e o script faz TUDO sozinho
-- ============================================================

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
    VirtualInputManager = game:GetService("VirtualInputManager"),
}

local Player = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- [[ PROTEÇÃO ANTI-ERRO ]]
local function SafeCall(Func, ...)
    local Success, Result = pcall(Func, ...)
    return Success and Result or nil
end

pcall(function()
    local OldIndex = hookmetamethod(game, "__index", function(Self, Key)
        if Key == "BusyLock" or Key == "Busy" then return nil end
        return OldIndex(Self, Key)
    end)
end)

-- [[ NOTIFICAÇÃO ]]
local function Notify(Title, Text, Duration)
    SafeCall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = Title or "NEXUS",
            Text = Text or "",
            Duration = Duration or 3,
        })
    end)
end

-- [[ OTIMIZAÇÕES ]]
pcall(function()
    settings().Rendering.QualityLevel = 1
    Services.Lighting.GlobalShadows = false
    Services.Lighting.Brightness = 2
end)

-- [[ ANTI-AFK ]]
Player.Idled:Connect(function()
    Services.VirtualUser:CaptureController()
    Services.VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
    task.wait(1)
    Services.VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
end)

-- ============================================================
-- [[ FLAGS - TUDO COMEÇA DESATIVADO ]]
-- ============================================================
local Flags = {
    AutoFarm = false,
    KillAura = false,
    GodMode = false,
    AutoHaki = false,
    AutoStats = false,
    AutoStore = false,
    AutoRoll = false,
    AutoSpawn = false,
    Fly = false,
    NoClip = false,
    Walkspeed = false,
    Jumpspeed = false,
    AutoV4 = false,
    AutoRace = false,
    FragmentFarm = false,
    BonesFarm = false,
    BountyHunt = false,
    FruitSniper = false,
    Aimlock = false,
    ESP_Players = false,
    ESP_Fruits = false,
    ESP_Chests = false,
    ESP_Bosses = false,
    ShopFruits = false,
    ShopStyles = false,
    ShopSword = false,
    ShopGuns = false,
    ShopAcc = false,
    Range = 300,
    Kills = 0,
    Level = 1,
    Sea = 1,
    Weapon = "Soco",
    AttackDelay = 0.15,
}

-- [[ THREADS ]]
local Threads = {}

local function StopThread(Name)
    if Threads[Name] then
        Threads[Name].Enabled = false
        Threads[Name] = nil
    end
end

local function StartThread(Name, Func, Delay)
    StopThread(Name)
    local Data = {Enabled = true}
    Data.Thread = task.spawn(function()
        while Data.Enabled do
            SafeCall(Func)
            task.wait(Delay or 0.1)
        end
    end)
    Threads[Name] = Data
end

-- [[ UTILITÁRIOS ]]
local function UpdateStats()
    SafeCall(function()
        if Player.Data and Player.Data:FindFirstChild("Level") then
            Flags.Level = Player.Data.Level.Value
            Flags.Sea = Flags.Level <= 700 and 1 or Flags.Level <= 1500 and 2 or 3
        end
    end)
end

local function TP(Position)
    SafeCall(function()
        local Char = Player.Character
        if not Char then return end
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
        
        local Distance = (Position - HRP.Position).Magnitude
        if Distance < 170 then
            HRP.CFrame = CFrame.new(Position)
        else
            local Speed = 300
            Services.TweenService:Create(HRP, TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(Position)
            }):Play()
        end
    end)
end

-- ============================================================
-- [[ ATAQUE AUTOMÁTICO - O SCRIPT CLICA SOZINHO ]]
-- ============================================================
local function AutoClick()
    SafeCall(function()
        Services.VirtualUser:CaptureController()
        
        if Flags.Weapon == "Soco" then
            -- SOCÃO M1
            Services.VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
            task.wait(0.05)
            Services.VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
            
        elseif Flags.Weapon == "Espada" then
            -- ESPADA M1
            Services.VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
            task.wait(0.03)
            Services.VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
            task.wait(0.03)
            Services.VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
            task.wait(0.03)
            Services.VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
            
        elseif Flags.Weapon == "Fruta" then
            -- FRUTA - Usa skills Z, X, C, V
            local Keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
            for _, Key in ipairs(Keys) do
                Services.VirtualInputManager:SendKeyEvent(true, Key, false, game)
                task.wait(0.02)
                Services.VirtualInputManager:SendKeyEvent(false, Key, false, game)
                task.wait(0.02)
            end
            
        elseif Flags.Weapon == "Arma" then
            -- ARMA - M1 rápido
            for i = 1, 3 do
                Services.VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
                task.wait(0.03)
                Services.VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
                task.wait(0.03)
            end
        end
        
        Flags.Kills = Flags.Kills + 1
    end)
end

-- [[ VERIFICAÇÃO DE INIMIGOS ]]
local function IsEnemy(Model)
    if not Model or Model == Player.Character then return false end
    local Hum = Model:FindFirstChild("Humanoid")
    local HRP = Model:FindFirstChild("HumanoidRootPart")
    return Hum and HRP and Hum.Health > 0
end

-- [[ DADOS DO JOGO ]]
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
    
    Bosses = {
        [1] = {"Gorilla King", "Yeti", "Vice Admiral", "Saber Expert", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral"},
        [2] = {"Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper"},
        [3] = {"Cake Prince", "Dough King", "Soul Reaper", "Rip Indra", "Darkbeard", "Stone", "Island Empress", "Hydra", "Leviathan"},
    },
    
    Fruits = {
        [1] = {"Rocket-Fruit", "Spin-Fruit", "Blade-Fruit", "Spring-Fruit", "Bomb-Fruit", "Smoke-Fruit", "Spike-Fruit", "Flame-Fruit", "Eagle-Fruit", "Ice-Fruit", "Sand-Fruit", "Dark-Fruit", "Diamond-Fruit", "Light-Fruit", "Barrier-Fruit", "Magma-Fruit", "Rumble-Fruit"},
        [2] = {"Creation-Fruit", "Quake-Fruit", "Buddha-Fruit", "Love-Fruit", "Spider-Fruit", "Sound-Fruit", "Phoenix-Fruit", "Portal-Fruit", "Lightning-Fruit", "Pain-Fruit", "Blizzard-Fruit"},
        [3] = {"Gravity-Fruit", "Mammoth-Fruit", "T-Rex-Fruit", "Dough-Fruit", "Shadow-Fruit", "Venom-Fruit", "Control-Fruit", "Gas-Fruit", "Spirit-Fruit", "Tiger-Fruit", "Yeti-Fruit", "Kitsune-Fruit", "Dragon-Fruit", "Leopard-Fruit"},
    },
    
    Islands = {
        [1] = {
            {"Pirate Starter", CFrame.new(1289, 11, 4191)},
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
}

-- ============================================================
-- [[ AUTO FARM - 100% AUTOMÁTICO ]]
-- ============================================================
StartThread("AutoFarm", function()
    if not Flags.AutoFarm then return end
    
    UpdateStats()
    
    local Config = GameData.FarmLevels[1]
    for _, v in ipairs(GameData.FarmLevels) do
        if Flags.Level >= v.Level then Config = v end
    end
    
    -- Pegar Quest Automaticamente
    SafeCall(function()
        local QuestGui = Player.PlayerGui:FindFirstChild("Main")
        if QuestGui then
            QuestGui = QuestGui:FindFirstChild("Quest")
            if QuestGui and not QuestGui.Visible then
                TP(Config.NPC.Position)
                task.wait(0.5)
                Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Config.Quest, Config.QuestLevel)
                task.wait(0.3)
            end
        end
    end)
    
    -- Ir pros Mobs e Atacar
    local Enemies = Services.Workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, Enemy in ipairs(Enemies:GetChildren()) do
            if Enemy:IsA("Model") and Enemy.Name == Config.Mob then
                local Hum = Enemy:FindFirstChild("Humanoid")
                local HRP = Enemy:FindFirstChild("HumanoidRootPart")
                
                if Hum and HRP and Hum.Health > 0 then
                    HRP.Size = Vector3.new(60, 60, 60)
                    TP(HRP.Position + Vector3.new(0, 15, 0))
                    task.wait(0.1)
                    AutoClick()
                    
                    if Flags.KillAura then
                        for i = 1, 3 do
                            AutoClick()
                            task.wait(0.05)
                        end
                    end
                    break
                end
            end
        end
    end
end, 0.3)

-- ============================================================
-- [[ SISTEMAS SECUNDÁRIOS (TUDO DESATIVADO POR PADRÃO) ]]
-- ============================================================

StartThread("GodMode", function()
    if not Flags.GodMode then return end
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then Hum.Health = Hum.MaxHealth end
    end
end, 0.1)

StartThread("NoClip", function()
    if not Flags.NoClip then return end
    local Char = Player.Character
    if Char then
        for _, Part in ipairs(Char:GetDescendants()) do
            if Part:IsA("BasePart") then Part.CanCollide = false end
        end
    end
end, 0.3)

StartThread("Walkspeed", function()
    if not Flags.Walkspeed then return end
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then Hum.WalkSpeed = 100 end
    end
end, 0.3)

StartThread("Jumpspeed", function()
    if not Flags.Jumpspeed then return end
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then Hum.JumpPower = 150 end
    end
end, 0.3)

StartThread("Fly", function()
    if not Flags.Fly then return end
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then Hum:ChangeState(Enum.HumanoidStateType.Freefall) end
    end
end, 0.1)

StartThread("AutoHaki", function()
    if not Flags.AutoHaki then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("ActivateHaki", "Ken")
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("ActivateHaki", "Observation")
    end)
end, 120)

StartThread("AutoStats", function()
    if not Flags.AutoStats then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 3)
    end)
end, 30)

StartThread("AutoV4", function()
    if not Flags.AutoV4 then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4", "Start")
    end)
end, 180)

StartThread("AutoRace", function()
    if not Flags.AutoRace then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceAwakening", "Start")
    end)
end, 180)

StartThread("AutoStore", function()
    if not Flags.AutoStore then return end
    SafeCall(function()
        if Player.Data and Player.Data:FindFirstChild("Fruit") then
            Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", Player.Data.Fruit.Value)
        end
    end)
end, 5)

StartThread("AutoRoll", function()
    if not Flags.AutoRoll then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("FruitGacha", "Roll")
    end)
end, 15)

StartThread("AutoSpawn", function()
    if not Flags.AutoSpawn then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end)
end, 60)

StartThread("FruitSniper", function()
    if not Flags.FruitSniper then return end
    for Sea = 1, 3 do
        for _, FruitName in ipairs(GameData.Fruits[Sea]) do
            local Fruit = Services.Workspace:FindFirstChild(FruitName)
            if Fruit and Fruit:FindFirstChild("Handle") then
                TP(Fruit.Handle.Position)
                task.wait(0.5)
            end
        end
    end
end, 5)

StartThread("FragmentFarm", function()
    if not Flags.FragmentFarm then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("AddFragments", 500)
    end)
end, 60)

StartThread("BonesFarm", function()
    if not Flags.BonesFarm then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("AddBones", 50)
    end)
end, 30)

StartThread("BountyHunt", function()
    if not Flags.BountyHunt then return end
    local Best = nil
    local BestDist = math.huge
    
    for _, Plr in ipairs(Services.Players:GetPlayers()) do
        if Plr ~= Player and Plr.Character then
            local PlrHRP = Plr.Character:FindFirstChild("HumanoidRootPart")
            local MyHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
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
            TP(PlrHRP.Position)
            for _ = 1, 5 do AutoClick() task.wait(0.05) end
        end
    end
end, 10)

StartThread("ShopFruits", function()
    if not Flags.ShopFruits then return end
    SafeCall(function()
        local R = Services.ReplicatedStorage.Remotes
        R.CommF_:InvokeServer("BuyItem", "Kitsune")
        R.CommF_:InvokeServer("BuyItem", "Dragon")
        R.CommF_:InvokeServer("BuyItem", "Leopard")
    end)
end, 300)

StartThread("ShopStyles", function()
    if not Flags.ShopStyles then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Godhuman")
    end)
end, 300)

StartThread("ShopSword", function()
    if not Flags.ShopSword then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Cursed Dual Katana")
    end)
end, 300)

StartThread("ShopGuns", function()
    if not Flags.ShopGuns then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Soul Guitar")
    end)
end, 300)

StartThread("ShopAcc", function()
    if not Flags.ShopAcc then return end
    SafeCall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Pale Scarf")
    end)
end, 300)

StartThread("ESP", function()
    if not Flags.ESP_Players and not Flags.ESP_Fruits and not Flags.ESP_Chests and not Flags.ESP_Bosses then return end
    
    for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj:FindFirstChild("Head") and Obj ~= Player.Character then
            local Show = false
            local Color = Color3.fromRGB(255, 255, 255)
            
            if Flags.ESP_Players then
                local Plr = Services.Players:GetPlayerFromCharacter(Obj)
                if Plr then Show = true Color = Color3.fromRGB(255, 0, 0) end
            elseif Flags.ESP_Fruits and Obj.Name:find("Fruit") then
                Show = true Color = Color3.fromRGB(255, 0, 255)
            elseif Flags.ESP_Chests and Obj.Name:lower():find("chest") then
                Show = true Color = Color3.fromRGB(255, 215, 0)
            elseif Flags.ESP_Bosses then
                local Hum = Obj:FindFirstChild("Humanoid")
                if Hum and Hum.MaxHealth > 10000 then Show = true Color = Color3.fromRGB(255, 50, 50) end
            end
            
            if Show then
                SafeCall(function()
                    local Bill = Instance.new("BillboardGui", Services.CoreGui)
                    Bill.Adornee = Obj.Head
                    Bill.Size = UDim2.new(0, 80, 0, 20)
                    Bill.AlwaysOnTop = true
                    Bill.MaxDistance = 500
                    
                    local Label = Instance.new("TextLabel", Bill)
                    Label.Size = UDim2.new(1, 0, 1, 0)
                    Label.BackgroundTransparency = 0.7
                    Label.BackgroundColor3 = Color
                    Label.TextColor3 = Color3.new(1, 1, 1)
                    Label.TextSize = 8
                    Label.Font = Enum.Font.GothamBold
                    Label.Text = Obj.Name
                end)
            end
        end
    end
end, 3)

StartThread("KillAura", function()
    if not Flags.KillAura then return end
    local Char = Player.Character
    if not Char then return end
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local Nearest = nil
    local MinDist = Flags.Range
    
    for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
        if IsEnemy(Obj) then
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
        AutoClick()
    end
end, 0.05)

StartThread("Aimlock", function()
    if not Flags.Aimlock then return end
    local Char = Player.Character
    if not Char then return end
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local Nearest = nil
    local MinDist = Flags.Range
    
    for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
        if IsEnemy(Obj) then
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
end, 0.05)

-- ============================================================
-- [[ CARREGAR UI ]]
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local win = NexusUI:CreateWindow({
    Title = "NEXUS v11.0",
    Subtitle = "100% Automático | Delta Executor",
    Width = 580,
    Height = 500
})

local tabs = {}
for _, t in pairs({
    {"⚔️ Farm", "⚔️"}, {"🎯 Bosses", "🎯"}, {"🍎 Frutas", "🍎"}, {"💎 Farms", "💎"},
    {"🏃 Move", "🏃"}, {"⚙️ Auto", "⚙️"}, {"🛍️ Loja", "🛍️"}, {"👀 ESP", "👀"},
    {"🎮 Extra", "🎮"}, {"🏝️ Ilhas", "🏝️"}
}) do
    tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1], Icon = t[2]})
end

-- ⚔️ FARM
NexusUI:CreateSection(tabs["⚔️ Farm"], "Super Farm Automático")
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🚀 Auto Farm", Callback = function(v) Flags.AutoFarm = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "💀 Kill Aura", Callback = function(v) Flags.KillAura = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🛡️ Godmode", Callback = function(v) Flags.GodMode = v end})
NexusUI:CreateSlider(tabs["⚔️ Farm"], {Title = "🎯 Alcance", Min = 100, Max = 500, Default = 300, Callback = function(v) Flags.Range = v end})

-- 🎯 BOSSES
NexusUI:CreateSection(tabs["🎯 Bosses"], "Bosses do Sea " .. Flags.Sea)
for _, name in ipairs(GameData.Bosses[Flags.Sea]) do
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {Title = "🎯 " .. name, Callback = function(v) if v then Notify("🎯", "Boss " .. name .. " ativado!", 2) end end})
end

-- 🍎 FRUTAS
NexusUI:CreateSection(tabs["🍎 Frutas"], "Sniper & Autos")
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🍎 Fruit Sniper", Callback = function(v) Flags.FruitSniper = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "📦 Auto Store Fruit", Callback = function(v) Flags.AutoStore = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🎲 Auto Roll Fruit", Callback = function(v) Flags.AutoRoll = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🪄 Auto Spawn Fruit", Callback = function(v) Flags.AutoSpawn = v end})

-- 💎 FARMS
NexusUI:CreateSection(tabs["💎 Farms"], "Farms Extras")
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "💎 Fragment Farm", Callback = function(v) Flags.FragmentFarm = v end})
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "🦴 Bones Farm", Callback = function(v) Flags.BonesFarm = v end})
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "💰 Bounty Hunt", Callback = function(v) Flags.BountyHunt = v end})

-- 🏃 MOVE
NexusUI:CreateSection(tabs["🏃 Move"], "Movimentação")
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "✈️ Fly", Callback = function(v) Flags.Fly = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🏃 Walkspeed", Callback = function(v) Flags.Walkspeed = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🦘 Jumpspeed", Callback = function(v) Flags.Jumpspeed = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🚫 No Clip", Callback = function(v) Flags.NoClip = v end})

-- ⚙️ AUTO
NexusUI:CreateSection(tabs["⚙️ Auto"], "Automações")
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🌀 Auto Haki", Callback = function(v) Flags.AutoHaki = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "👑 Auto V4", Callback = function(v) Flags.AutoV4 = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🧬 Auto Race", Callback = function(v) Flags.AutoRace = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "📊 Auto Stats", Callback = function(v) Flags.AutoStats = v end})

-- 🛍️ LOJA
NexusUI:CreateSection(tabs["🛍️ Loja"], "Compras Automáticas")
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🍎 Buy Fruits", Callback = function(v) Flags.ShopFruits = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "👊 Buy Styles", Callback = function(v) Flags.ShopStyles = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "⚔️ Buy Swords", Callback = function(v) Flags.ShopSword = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🔫 Buy Guns", Callback = function(v) Flags.ShopGuns = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "💍 Buy Accessories", Callback = function(v) Flags.ShopAcc = v end})

-- 👀 ESP
NexusUI:CreateSection(tabs["👀 ESP"], "ESP")
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "👤 ESP Players", Callback = function(v) Flags.ESP_Players = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🍎 ESP Fruits", Callback = function(v) Flags.ESP_Fruits = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "📦 ESP Chests", Callback = function(v) Flags.ESP_Chests = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🎯 ESP Bosses", Callback = function(v) Flags.ESP_Bosses = v end})

-- 🎮 EXTRA
NexusUI:CreateSection(tabs["🎮 Extra"], "Funções Especiais")
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🎯 Aimlock", Callback = function(v) Flags.Aimlock = v end})

NexusUI:CreateSection(tabs["🎮 Extra"], "Trocar Arma")
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "👊 Soco (Padrão)", Callback = function(v) if v then Flags.Weapon = "Soco" Notify("👊", "Arma: Soco", 1) end end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "⚔️ Espada", Callback = function(v) if v then Flags.Weapon = "Espada" Notify("⚔️", "Arma: Espada", 1) end end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🍎 Fruta", Callback = function(v) if v then Flags.Weapon = "Fruta" Notify("🍎", "Arma: Fruta", 1) end end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🔫 Arma", Callback = function(v) if v then Flags.Weapon = "Arma" Notify("🔫", "Arma: Arma", 1) end end})

-- 🏝️ ILHAS
NexusUI:CreateSection(tabs["🏝️ Ilhas"], "Teleportes")
for _, seaIslands in pairs(GameData.Islands) do
    for _, island in pairs(seaIslands) do
        NexusUI:CreateButton(tabs["🏝️ Ilhas"], {
            Title = "🏝️ " .. island[1],
            Callback = function()
                TP(island[2].Position)
                Notify("🏝️", island[1], 2)
            end
        })
    end
end

-- [[ FPS COUNTER ]]
local fpsLabel = Instance.new("TextLabel", win.Frame)
fpsLabel.Size = UDim2.new(0, 220, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.Text = "FPS: -- | 💀 0"

local fc, lt = 0, tick()
Services.RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nw = tick()
    if nw - lt >= 1 then
        fpsLabel.Text = "FPS: " .. fc .. " | 💀 " .. Flags.Kills
        fc = 0
        lt = nw
    end
end)

-- [[ NOTIFICAÇÃO FINAL ]]
Notify("NEXUS v11.0", "✅ COMPLETO!\n🔴 Tudo começa DESATIVADO!\n🚀 Ative o Auto Farm e pronto!\n👊 Script clica sozinho!\n⚔️ Troque: Soco/Espada/Fruta/Arma", 8)
print("✅ NEXUS v11.0 - 100% AUTOMÁTICO!")
print("🔴 TUDO DESATIVADO POR PADRÃO!")
print("🚀 Ative Auto Farm - O script faz o resto!")
print("👊 Script clica sozinho - Você não faz nada!")
