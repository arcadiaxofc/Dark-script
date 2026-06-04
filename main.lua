-- ============================================================
-- NEXUS v7.1.0 - COMPLETO E CORRIGIDO PARA DELTA EXECUTOR
-- ============================================================

-- 1. SERVIÇOS
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- 2. FUNÇÃO DE NOTIFICAÇÃO
local function notify(t, txt, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = t or "NEXUS",
            Text = txt or "",
            Duration = d or 3
        })
    end)
end

-- 3. OTIMIZAÇÕES
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
end)

-- 4. ANTI-AFK
coroutine.wrap(function()
    while true do
        wait(180)
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:Move(Vector3.new(1, 0, 0), true)
                wait(0.3)
                player.Character.Humanoid:Move(Vector3.zero, true)
            end
        end)
    end
end)()

-- 5. DETECÇÃO DE SEA
local currentSea = 1
local function detectSea()
    local lvl = 1
    pcall(function()
        if player.Data and player.Data:FindFirstChild("Level") then
            lvl = player.Data.Level.Value
        end
    end)
    if lvl <= 700 then
        currentSea = 1
    elseif lvl <= 1500 then
        currentSea = 2
    else
        currentSea = 3
    end
end
detectSea()

-- 6. LISTAS
local ISLANDS = {
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
        {"Fountain City", Vector3.new(4500, 50, 1200)}
    },
    [2] = {
        {"Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
        {"Green Zone", Vector3.new(6200, 80, 2500)},
        {"Hot and Cold", Vector3.new(-3420, 10, -2700)},
        {"Ice Castle", Vector3.new(7200, 100, 3500)},
        {"Forgotten Island", Vector3.new(8500, 120, 4500)},
        {"Cafe", Vector3.new(-570, 310, -1220)}
    },
    [3] = {
        {"Port Town", Vector3.new(7200, 100, 3500)},
        {"Hydra Island", Vector3.new(6200, 80, 2500)},
        {"Great Tree", Vector3.new(8500, 120, 4500)},
        {"Castle on the Sea", Vector3.new(4500, 50, 1200)},
        {"Haunted Castle", Vector3.new(9800, 60, 5500)},
        {"Dark Arena", Vector3.new(10500, 100, 6000)},
        {"Floating Turtle", Vector3.new(11200, 90, 6500)}
    }
}

local BOSSES = {
    [1] = {"Gorilla King", "Yeti", "Vice Admiral", "Saber Expert", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral"},
    [2] = {"Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper"},
    [3] = {"Cake Prince", "Dough King", "Soul Reaper", "Rip Indra", "Darkbeard", "Stone", "Island Empress", "Hydra", "Leviathan"}
}

local FRUITS = {
    [1] = {"Rocket-Fruit", "Spin-Fruit", "Blade-Fruit", "Spring-Fruit", "Bomb-Fruit", "Smoke-Fruit", "Spike-Fruit", "Flame-Fruit", "Eagle-Fruit", "Ice-Fruit", "Sand-Fruit", "Dark-Fruit", "Diamond-Fruit", "Light-Fruit", "Barrier-Fruit", "Magma-Fruit", "Rumble-Fruit"},
    [2] = {"Creation-Fruit", "Quake-Fruit", "Buddha-Fruit", "Love-Fruit", "Spider-Fruit", "Sound-Fruit", "Phoenix-Fruit", "Portal-Fruit", "Lightning-Fruit", "Pain-Fruit", "Blizzard-Fruit"},
    [3] = {"Gravity-Fruit", "Mammoth-Fruit", "T-Rex-Fruit", "Dough-Fruit", "Shadow-Fruit", "Venom-Fruit", "Control-Fruit", "Gas-Fruit", "Spirit-Fruit", "Tiger-Fruit", "Yeti-Fruit", "Kitsune-Fruit", "Dragon-Fruit", "Leopard-Fruit"}
}

local QUEST_NPCS = {
    [1] = {"Bandit Quest Giver", "Trainee Quest Giver", "Desert Adventurer", "Marine Leader", "Sky Adventurer", "Head Jailer", "Jail Keeper", "Colosseum Quest Giver", "Submerged Quest Giver 1", "Submerged Quest Giver 2", "Sky Quest Giver 2"},
    [2] = {"Colosseum Quest Giver", "Deep Forest Quest Giver", "Graveyard Quest Giver", "Snow Quest Giver", "Fire Quest Giver", "Ice Quest Giver", "Forgotten Quest Giver"},
    [3] = {"Pirate Port Quest Giver", "Hydra Town Quest Giver", "Dragon Crew Quest Giver", "Marine Tree Quest Giver", "Turtle Adventure Quest Giver", "Haunted Castle Quest Giver 1", "Haunted Castle Quest Giver 2", "Tiki Quest Giver 1", "Tiki Quest Giver 2", "Tiki Quest Giver 3", "Frost Quest Giver", "Elite Hunter", "Player Hunter"}
}

-- 7. VARIÁVEIS
local range = 300
local kills = 0
local threads = {}

local function stopThread(name)
    if threads[name] then
        threads[name].enabled = false
        threads[name] = nil
    end
end

local function startThread(name, func, delay)
    stopThread(name)
    local d = {enabled = true}
    coroutine.wrap(function()
        while d.enabled do
            pcall(func)
            wait(delay or 0.1)
        end
    end)()
    threads[name] = d
end

-- 8. TELEPORTE
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local h = player.Character.HumanoidRootPart
            h.CFrame = CFrame.new(pos + Vector3.new(0, 25, 0))
            wait(0.1)
            h.CFrame = CFrame.new(pos)
        end
    end)
end

-- 9. ATAQUE (CORRIGIDO PARA DELTA)
local function attack()
    pcall(function()
        -- Método 1: Mouse
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        -- Método 2: Tecla Z (skills)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
        
        kills = kills + 1
    end)
end

-- 10. FUNÇÕES DE VERIFICAÇÃO
local function isQuestNPC(obj)
    for _, n in pairs(QUEST_NPCS[currentSea]) do
        if obj.Name == n or obj.Name:find(n) or n:find(obj.Name) then
            return true
        end
    end
    if obj:FindFirstChild("Talk") then
        return true
    end
    return false
end

local function isEnemy(obj)
    return obj and obj ~= player.Character and not isQuestNPC(obj) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0
end

local function findBoss(name)
    local b = Workspace:FindFirstChild(name)
    if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health > 0 then
        return b
    end
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then
            return o
        end
    end
    return nil
end

-- 11. SUPER FARM COMPLETO E CORRIGIDO
local SuperFarm = {
    Enabled = false,
    Box = nil,
    Mobs = {},
    Phase = "collect",
    Killed = 0,
    Needed = 10,
    LastAttack = 0,
    AttackCooldown = 0.3
}

function SuperFarm.createBox()
    pcall(function()
        if SuperFarm.Box and SuperFarm.Box.Parent then
            SuperFarm.Box:Destroy()
        end
        
        SuperFarm.Box = Instance.new("Part", Workspace)
        SuperFarm.Box.Name = "FarmBox"
        SuperFarm.Box.Size = Vector3.new(15, 1, 15)
        SuperFarm.Box.Anchored = true
        SuperFarm.Box.CanCollide = false
        SuperFarm.Box.Transparency = 0.7
        SuperFarm.Box.Color = Color3.fromRGB(255, 0, 0)
        SuperFarm.Box.Material = Enum.Material.Neon
    end)
end

function SuperFarm.cleanupMobs()
    local toRemove = {}
    for obj, _ in pairs(SuperFarm.Mobs) do
        if not obj or not obj.Parent or not obj:FindFirstChild("Humanoid") or obj.Humanoid.Health <= 0 then
            table.insert(toRemove, obj)
            SuperFarm.Killed = SuperFarm.Killed + 1
        end
    end
    for _, obj in pairs(toRemove) do
        SuperFarm.Mobs[obj] = nil
    end
end

function SuperFarm.pullMob(obj)
    pcall(function()
        if not SuperFarm.Box or not SuperFarm.Box.Parent then return end
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if hrp then
            local newPos = SuperFarm.Box.Position + Vector3.new(math.random(-6, 6), 2, math.random(-6, 6))
            hrp.CFrame = CFrame.new(newPos)
        end
    end)
end

function SuperFarm.update()
    if not SuperFarm.Enabled then
        if SuperFarm.Box then
            SuperFarm.Box:Destroy()
            SuperFarm.Box = nil
        end
        SuperFarm.Mobs = {}
        return
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local hrp = player.Character.HumanoidRootPart
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    
    -- Criar/posicionar caixa
    if not SuperFarm.Box or not SuperFarm.Box.Parent then
        SuperFarm.createBox()
    end
    
    if SuperFarm.Box then
        SuperFarm.Box.CFrame = CFrame.new(hrp.Position + Vector3.new(0, -3, 0))
    end
    
    -- Godmode
    if hum then
        hum.Health = hum.MaxHealth
    end
    
    -- Limpar mobs mortos
    SuperFarm.cleanupMobs()
    
    -- FASE: PUXAR MOBS
    if SuperFarm.Phase == "collect" then
        local mobsEncontrados = 0
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if mobsEncontrados >= 10 then break end
            
            if obj:IsA("Model") and obj ~= player.Character and not SuperFarm.Mobs[obj] then
                local objHum = obj:FindFirstChild("Humanoid")
                local objHrp = obj:FindFirstChild("HumanoidRootPart")
                
                if objHum and objHrp and objHum.Health > 0 and not isQuestNPC(obj) then
                    local dist = (objHrp.Position - hrp.Position).Magnitude
                    
                    if dist <= 500 then
                        SuperFarm.pullMob(obj)
                        SuperFarm.Mobs[obj] = true
                        mobsEncontrados = mobsEncontrados + 1
                    end
                end
            end
        end
        
        if mobsEncontrados > 0 then
            print("📦 Puxados " .. mobsEncontrados .. " mobs para farm!")
            SuperFarm.Phase = "attack"
        end
    end
    
    -- FASE: ATACAR
    if SuperFarm.Phase == "attack" then
        local mobsVivos = 0
        local alvo = nil
        local menorDist = math.huge
        
        -- Encontrar mob mais próximo
        for obj, _ in pairs(SuperFarm.Mobs) do
            if obj.Parent and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < menorDist then
                    menorDist = dist
                    alvo = obj
                end
                mobsVivos = mobsVivos + 1
                
                -- Manter mobs perto da caixa
                if dist > 15 then
                    SuperFarm.pullMob(obj)
                end
            end
        end
        
        -- Atacar o alvo mais próximo
        if alvo and tick() - SuperFarm.LastAttack >= SuperFarm.AttackCooldown then
            local alvoHrp = alvo:FindFirstChild("HumanoidRootPart")
            if alvoHrp then
                -- Mirar no mob
                hrp.CFrame = CFrame.new(hrp.Position, alvoHrp.Position)
                -- Atacar
                attack()
                SuperFarm.LastAttack = tick()
            end
        end
        
        -- Se não tem mobs vivos, voltar a puxar
        if mobsVivos == 0 then
            print("🔄 Todos mortos! Voltando a puxar...")
            SuperFarm.Phase = "collect"
            SuperFarm.Mobs = {}
        end
        
        -- Ciclo completo
        if SuperFarm.Killed >= SuperFarm.Needed then
            print("✅ CICLO COMPLETO! " .. SuperFarm.Killed .. " kills!")
            SuperFarm.Killed = 0
            SuperFarm.Phase = "collect"
            SuperFarm.Mobs = {}
        end
    end
end

function startSuperFarm()
    SuperFarm.Enabled = true
    SuperFarm.Phase = "collect"
    SuperFarm.Killed = 0
    SuperFarm.Mobs = {}
    SuperFarm.createBox()
    print("🚀 SUPER FARM INICIADO!")
    notify("FARM", "Super Farm ativado!", 2)
end

function stopSuperFarm()
    SuperFarm.Enabled = false
    print("🛑 SUPER FARM PARADO!")
    notify("FARM", "Super Farm desativado!", 2)
end

-- 12. OUTRAS FUNÇÕES DE FARM
function startKillAura()
    startThread("killaura", function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character.HumanoidRootPart
        local alvo = nil
        local menorDist = range
        
        for _, o in pairs(Workspace:GetDescendants()) do
            if isEnemy(o) and o:FindFirstChild("HumanoidRootPart") then
                local d = (o.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < menorDist then
                    menorDist = d
                    alvo = o
                end
            end
        end
        
        if alvo then
            hrp.CFrame = CFrame.new(hrp.Position, alvo.HumanoidRootPart.Position)
            attack()
        end
    end, 0.15)
end

function stopKillAura()
    stopThread("killaura")
end

function startGodmode()
    startThread("godmode", function()
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.Health = h.MaxHealth
            end
        end
    end, 0.1)
end

function stopGodmode()
    stopThread("godmode")
end

function startAutoQuest()
    startThread("autoquest", function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and isQuestNPC(obj) then
                tp(obj.HumanoidRootPart.Position + Vector3.new(3, 0, 0))
                wait(1)
                pcall(function()
                    local r = ReplicatedStorage:FindFirstChild("Remotes")
                    if r and r:FindFirstChild("CommF_") then
                        r.CommF_:InvokeServer("StartQuest", obj.Name)
                    end
                end)
                break
            end
        end
    end, 45)
end

function stopAutoQuest()
    stopThread("autoquest")
end

-- 13. FUNÇÕES DE MOVIMENTO
function startNoclip()
    startThread("noclip", function()
        if player.Character then
            for _, p in pairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end, 0.3)
end

function stopNoclip()
    stopThread("noclip")
    pcall(function()
        if player.Character then
            for _, p in pairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
    end)
end

function startWalkspeed()
    startThread("walkspeed", function()
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.WalkSpeed = 100
            end
        end
    end, 0.3)
end

function stopWalkspeed()
    stopThread("walkspeed")
    pcall(function()
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.WalkSpeed = 16
            end
        end
    end)
end

function startJumpspeed()
    startThread("jumpspeed", function()
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.JumpPower = 150
            end
        end
    end, 0.3)
end

function stopJumpspeed()
    stopThread("jumpspeed")
    pcall(function()
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.JumpPower = 50
            end
        end
    end)
end

function startFly()
    startThread("fly", function()
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end
    end, 0.1)
end

function stopFly()
    stopThread("fly")
end

-- 14. FUNÇÕES DE FARMS EXTRAS
function startFragmentFarm()
    startThread("fragment", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("AddFragments", 500)
            end
        end)
    end, 60)
end

function stopFragmentFarm()
    stopThread("fragment")
end

function startBonesFarm()
    startThread("bones", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("AddBones", 50)
            end
        end)
    end, 30)
end

function stopBonesFarm()
    stopThread("bones")
end

function startBountyHunt()
    startThread("bounty", function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local best, bd = nil, math.huge
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if d < bd then
                    best = p
                    bd = d
                end
            end
        end
        
        if best then
            tp(best.Character.HumanoidRootPart.Position)
            for _ = 1, 5 do
                attack()
                wait(0.3)
            end
        end
    end, 10)
end

function stopBountyHunt()
    stopThread("bounty")
end

function startBossFarm(name)
    startThread("boss_" .. name:gsub(" ", "_"), function()
        local b = findBoss(name)
        if b then
            tp(b.HumanoidRootPart.Position)
            for _ = 1, 8 do
                attack()
                wait(0.3)
            end
        end
    end, 5)
end

function stopBossFarm(name)
    stopThread("boss_" .. name:gsub(" ", "_"))
end

-- 15. FUNÇÕES DE AUTO
function startAutoHaki()
    startThread("haki", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("ActivateHaki", "Ken")
                r.CommF_:InvokeServer("ActivateHaki", "Observation")
            end
        end)
    end, 120)
end

function stopAutoHaki()
    stopThread("haki")
end

function startAutoSkill()
    startThread("skill", function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        wait(0.5)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
    end, 3)
end

function stopAutoSkill()
    stopThread("skill")
end

function startAutoV4()
    startThread("v4", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("RaceV4", "Start")
            end
        end)
    end, 180)
end

function stopAutoV4()
    stopThread("v4")
end

function startAutoRace()
    startThread("race", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("RaceAwakening", "Start")
            end
        end)
    end, 180)
end

function stopAutoRace()
    stopThread("race")
end

function startAutoStats()
    startThread("stats", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("AddPoint", "Melee", 1)
            end
        end)
    end, 2)
end

function stopAutoStats()
    stopThread("stats")
end

-- 16. FUNÇÕES DE FRUTAS
function startAutoStore()
    startThread("store", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then
                r.CommF_:InvokeServer("StoreFruit", player.Data.Fruit.Value)
            end
        end)
    end, 5)
end

function stopAutoStore()
    stopThread("store")
end

function startAutoRoll()
    startThread("roll", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("FruitGacha", "Roll")
            end
        end)
    end, 15)
end

function stopAutoRoll()
    stopThread("roll")
end

function startAutoSpawn()
    startThread("spawn", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("Cousin", "Buy")
            end
        end)
    end, 60)
end

function stopAutoSpawn()
    stopThread("spawn")
end

-- 17. FUNÇÕES DE LOJA
function startShopFruits()
    startThread("shopfruit", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("BuyItem", "Kitsune")
                r.CommF_:InvokeServer("BuyItem", "Dragon")
                r.CommF_:InvokeServer("BuyItem", "Leopard")
            end
        end)
    end, 300)
end

function stopShopFruits()
    stopThread("shopfruit")
end

function startShopStyles()
    startThread("shopstyle", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("BuyItem", "Superhuman")
                r.CommF_:InvokeServer("BuyItem", "Godhuman")
            end
        end)
    end, 300)
end

function stopShopStyles()
    stopThread("shopstyle")
end

function startShopSword()
    startThread("shopsword", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("BuyItem", "Cursed Dual Katana")
                r.CommF_:InvokeServer("BuyItem", "Dark Blade")
            end
        end)
    end, 300)
end

function stopShopSword()
    stopThread("shopsword")
end

function startShopGuns()
    startThread("shopgun", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("BuyItem", "Soul Guitar")
            end
        end)
    end, 300)
end

function stopShopGuns()
    stopThread("shopgun")
end

function startShopAcc()
    startThread("shopacc", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("BuyItem", "Pale Scarf")
            end
        end)
    end, 300)
end

function stopShopAcc()
    stopThread("shopacc")
end

function startShopMat()
    startThread("shopmat", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("BuyItem", "Wood")
                r.CommF_:InvokeServer("BuyItem", "Iron")
            end
        end)
    end, 300)
end

function stopShopMat()
    stopThread("shopmat")
end

function startShopFrag()
    startThread("shopfrag", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("AddFragments", 500)
            end
        end)
    end, 60)
end

function stopShopFrag()
    stopThread("shopfrag")
end

function startShopBones()
    startThread("shopbone", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("AddBones", 50)
            end
        end)
    end, 30)
end

function stopShopBones()
    stopThread("shopbone")
end

function startShopStats()
    startThread("shopstat", function()
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("AddPoint", "Melee", 1)
            end
        end)
    end, 2)
end

function stopShopStats()
    stopThread("shopstat")
end

-- 18. ESP
function startESP(filter, color)
    if threads["esp_" .. filter] then
        stopThread("esp_" .. filter)
    end
    startThread("esp_" .. filter, function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Head") and obj ~= player.Character then
                local show = false
                if filter == "players" then
                    show = Players:GetPlayerFromCharacter(obj) ~= nil
                elseif filter == "fruits" then
                    show = obj.Name:find("Fruit") ~= nil
                elseif filter == "chests" then
                    show = obj.Name:lower():find("chest") ~= nil
                elseif filter == "bosses" then
                    show = obj:FindFirstChild("Humanoid") and obj.Humanoid.MaxHealth > 10000
                elseif filter == "sea" then
                    show = obj.Name:lower():find("sea") ~= nil
                end
                
                if show then
                    pcall(function()
                        local bill = Instance.new("BillboardGui", CoreGui)
                        bill.Adornee = obj.Head
                        bill.Size = UDim2.new(0, 60, 0, 18)
                        bill.AlwaysOnTop = true
                        bill.MaxDistance = 500
                        
                        local label = Instance.new("TextLabel", bill)
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 0.7
                        label.BackgroundColor3 = color
                        label.TextColor3 = Color3.new(1, 1, 1)
                        label.TextSize = 8
                        label.Font = Enum.Font.GothamBold
                        label.Text = obj.Name
                    end)
                end
            end
        end
    end, 3)
end

function stopESP(filter)
    stopThread("esp_" .. filter)
end

-- 19. AIMLOCK
function startAimlock()
    startThread("aimlock", function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character.HumanoidRootPart
        local t, s = nil, range
        
        for _, o in pairs(Workspace:GetDescendants()) do
            if isEnemy(o) and o:FindFirstChild("HumanoidRootPart") then
                local d = (o.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < s then
                    s = d
                    t = o
                end
            end
        end
        
        if t then
            hrp.CFrame = CFrame.new(hrp.Position, t.HumanoidRootPart.Position)
        end
    end, 0.05)
end

function stopAimlock()
    stopThread("aimlock")
end

-- 20. FRUIT SNIPER
local fruitSniperRunning = false

local function startFruitSniper()
    fruitSniperRunning = true
    coroutine.wrap(function()
        while fruitSniperRunning do
            pcall(function()
                for _, sea in pairs({1, 2, 3}) do
                    for _, fruitName in pairs(FRUITS[sea]) do
                        local fruit = Workspace:FindFirstChild(fruitName)
                        if fruit and fruit:FindFirstChild("Handle") then
                            tp(fruit.Handle.Position)
                            wait(0.5)
                        end
                    end
                end
            end)
            wait(5)
        end
    end)()
end

local function stopFruitSniper()
    fruitSniperRunning = false
end

-- 21. LOOP PRINCIPAL
coroutine.wrap(function()
    while true do
        pcall(function()
            detectSea()
            SuperFarm.update()
        end)
        wait(0.1)
    end
end)()

-- 22. DESLIGAR TUDO
local function disableAll()
    stopSuperFarm()
    stopGodmode()
    stopKillAura()
    stopAimlock()
    stopNoclip()
    stopWalkspeed()
    stopJumpspeed()
    stopFly()
    stopFragmentFarm()
    stopBonesFarm()
    stopAutoHaki()
    stopBountyHunt()
    stopAutoSkill()
    stopAutoQuest()
    stopAutoStore()
    stopAutoRoll()
    stopAutoSpawn()
    stopAutoV4()
    stopAutoRace()
    stopAutoStats()
    stopShopFruits()
    stopShopStyles()
    stopShopSword()
    stopShopGuns()
    stopShopAcc()
    stopShopMat()
    stopShopFrag()
    stopShopBones()
    stopShopStats()
    stopFruitSniper()
    
    for _, f in pairs({"players", "fruits", "chests", "bosses", "sea"}) do
        stopESP(f)
    end
    
    for _, name in pairs(BOSSES[currentSea]) do
        stopBossFarm(name)
    end
    
    notify("NEXUS", "Tudo desligado!", 3)
end

-- 23. UI LIBRARY
local NexusUI = {}
NexusUI.__index = NexusUI

NexusUI.Colors = {
    MainBg = Color3.fromRGB(20, 20, 25),
    SidebarBg = Color3.fromRGB(15, 15, 20),
    HeaderBg = Color3.fromRGB(25, 25, 30),
    ElementBg = Color3.fromRGB(30, 30, 38),
    ElementHover = Color3.fromRGB(40, 40, 48),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 170),
    Title = Color3.fromRGB(230, 70, 60),
    Success = Color3.fromRGB(0, 180, 0),
    Danger = Color3.fromRGB(200, 50, 40),
    Border = Color3.fromRGB(45, 45, 55),
}

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local viewport = Workspace.CurrentCamera.ViewportSize

local function criarBotaoRedondo(texto, cor, pai, posX, posY, tamanho)
    local btn = Instance.new("TextButton", pai)
    btn.Size = UDim2.new(0, tamanho or 30, 0, tamanho or 30)
    btn.Position = UDim2.new(1, posX, 0.5, posY)
    btn.Text = texto
    btn.TextColor3 = NexusUI.Colors.Text
    btn.TextSize = tamanho and 16 or 14
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = cor
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

function NexusUI:CreateWindow(config)
    config = config or {}
    
    local winW = isMobile and math.min(config.Width or 560, viewport.X - 40) or (config.Width or 560)
    local winH = isMobile and math.min(config.Height or 500, viewport.Y - 100) or (config.Height or 500)
    local sideW = isMobile and 130 or 140
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusUI"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, winW, 0, winH)
    win.Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2)
    win.BackgroundColor3 = NexusUI.Colors.MainBg
    win.BorderSizePixel = 0
    win.Parent = gui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
    
    local topLine = Instance.new("Frame", win)
    topLine.Size = UDim2.new(1, 0, 0, 3)
    topLine.BackgroundColor3 = NexusUI.Colors.Title
    topLine.BorderSizePixel = 0
    
    local header = Instance.new("Frame", win)
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = NexusUI.Colors.HeaderBg
    header.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -100, 0, 25)
    title.Position = UDim2.new(0, 12, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "NEXUS"
    title.TextColor3 = NexusUI.Colors.Title
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local subtitle = Instance.new("TextLabel", header)
    subtitle.Size = UDim2.new(1, -100, 0, 16)
    subtitle.Position = UDim2.new(0, 12, 0, 26)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = config.Subtitle or ""
    subtitle.TextColor3 = NexusUI.Colors.TextDim
    subtitle.TextSize = 9
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = criarBotaoRedondo("✕", NexusUI.Colors.ElementBg, header, -12, -12)
    closeBtn.TextColor3 = NexusUI.Colors.Danger
    
    local sidebar = Instance.new("ScrollingFrame", win)
    sidebar.Size = UDim2.new(0, sideW, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = NexusUI.Colors.SidebarBg
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local sidebarContent = Instance.new("Frame", sidebar)
    sidebarContent.Size = UDim2.new(1, 0, 0, 0)
    sidebarContent.BackgroundTransparency = 1
    sidebarContent.AutomaticSize = Enum.AutomaticSize.Y
    
    local sidebarLayout = Instance.new("UIListLayout", sidebarContent)
    sidebarLayout.Padding = UDim.new(0, 6)
    
    local sidebarPadding = Instance.new("UIPadding", sidebarContent)
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingBottom = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    
    local contentFrame = Instance.new("Frame", win)
    contentFrame.Size = UDim2.new(1, -(sideW + 5), 1, -50)
    contentFrame.Position = UDim2.new(0, sideW + 5, 0, 50)
    contentFrame.BackgroundTransparency = 1
    
    local contentScroll = Instance.new("ScrollingFrame", contentFrame)
    contentScroll.Size = UDim2.new(1, 0, 1, 0)
    contentScroll.BackgroundTransparency = 1
    contentScroll.ScrollBarThickness = 4
    contentScroll.ScrollBarImageColor3 = NexusUI.Colors.Title
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local contentLayout = Instance.new("UIListLayout", contentScroll)
    contentLayout.Padding = UDim.new(0, 6)
    
    local contentPadding = Instance.new("UIPadding", contentScroll)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 5)
    contentPadding.PaddingRight = UDim.new(0, 5)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    local arrastando, dragStart, posInicial = false
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastando = true
            dragStart = input.Position
            posInicial = win.Position
        end
    end)
    header.InputEnded:Connect(function() arrastando = false end)
    UserInputService.InputChanged:Connect(function(input)
        if arrastando and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local novaX = math.clamp(posInicial.X.Offset + delta.X, -winW/2, viewport.X - winW/2)
            local novaY = math.clamp(posInicial.Y.Offset + delta.Y, -winH/2, viewport.Y - winH/2)
            win.Position = UDim2.new(posInicial.X.Scale, novaX, posInicial.Y.Scale, novaY)
        end
    end)
    
    -- FPS Counter
    local fpsLabel = Instance.new("TextLabel", win)
    fpsLabel.Size = UDim2.new(0, 200, 0, 15)
    fpsLabel.Position = UDim2.new(0, 10, 1, -18)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = NexusUI.Colors.TextDim
    fpsLabel.TextSize = 10
    fpsLabel.Font = Enum.Font.Gotham
    
    local fc, lt = 0, tick()
    RunService.RenderStepped:Connect(function()
        fc = fc + 1
        local nw = tick()
        if nw - lt >= 1 then
            fpsLabel.Text = "FPS: " .. fc .. " | 💀 " .. kills
            fc = 0
            lt = nw
        end
    end)
    
    local windowObj = {
        Gui = gui,
        Frame = win,
        Sidebar = sidebarContent,
        Content = contentScroll,
        Tabs = {}
    }
    
    return windowObj
end

function NexusUI:CreateTab(window, config)
    local btn = Instance.new("TextButton", window.Sidebar)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Text = "  " .. (config.Icon or "📁") .. " " .. config.Name
    btn.TextColor3 = NexusUI.Colors.TextDim
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = NexusUI.Colors.SidebarBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local content = Instance.new("ScrollingFrame", window.Content)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.ScrollBarThickness = 0
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 6)
    
    local padding = Instance.new("UIPadding", content)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.PaddingTop = UDim.new(0, 5)
    
    local function selecionar()
        for _, t in pairs(window.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = NexusUI.Colors.SidebarBg
            t.Button.TextColor3 = NexusUI.Colors.TextDim
        end
        content.Visible = true
        btn.BackgroundColor3 = NexusUI.Colors.ElementBg
        btn.TextColor3 = NexusUI.Colors.Title
    end
    
    btn.MouseButton1Click:Connect(selecionar)
    
    local tab = {
        Name = config.Name,
        Icon = config.Icon,
        Button = btn,
        Content = content,
        Select = selecionar
    }
    table.insert(window.Tabs, tab)
    if #window.Tabs == 1 then selecionar() end
    return tab
end

function NexusUI:CreateSection(tab, title)
    local section = Instance.new("Frame", tab.Content)
    section.Size = UDim2.new(1, 0, 0, 32)
    section.BackgroundColor3 = NexusUI.Colors.ElementBg
    section.BorderSizePixel = 0
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", section)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = NexusUI.Colors.Title
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame", section)
    line.Size = UDim2.new(0, 2, 1, -10)
    line.Position = UDim2.new(0, 0, 0, 5)
    line.BackgroundColor3 = NexusUI.Colors.Title
    line.BorderSizePixel = 0
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 2)
    
    return section
end

function NexusUI:CreateToggle(tab, config)
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Toggle"
    title.TextColor3 = NexusUI.Colors.Text
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(1, -12, 0.5, -12)
    toggle.Text = "OFF"
    toggle.TextColor3 = NexusUI.Colors.Text
    toggle.TextSize = 10
    toggle.Font = Enum.Font.GothamBold
    toggle.BackgroundColor3 = NexusUI.Colors.Danger
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)
    
    local estado = false
    local callback = config.Callback or function() end
    
    toggle.MouseButton1Click:Connect(function()
        estado = not estado
        toggle.Text = estado and "ON" or "OFF"
        toggle.BackgroundColor3 = estado and NexusUI.Colors.Success or NexusUI.Colors.Danger
        callback(estado)
    end)
    
    return {
        Set = function(v)
            estado = v
            toggle.Text = estado and "ON" or "OFF"
            toggle.BackgroundColor3 = estado and NexusUI.Colors.Success or NexusUI.Colors.Danger
            callback(estado)
        end,
        Get = function() return estado end
    }
end

function NexusUI:CreateButton(tab, config)
    local btn = Instance.new("TextButton", tab.Content)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = config.Title or "Button"
    btn.TextColor3 = NexusUI.Colors.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = NexusUI.Colors.ElementBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)
    
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = NexusUI.Colors.ElementHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = NexusUI.Colors.ElementBg end)
    
    return btn
end

function NexusUI:CreateSlider(tab, config)
    local min, max, valor = config.Min or 0, config.Max or 100, config.Default or 50
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = config.Title .. ": " .. valor
    title.TextColor3 = NexusUI.Colors.Text
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local barra = Instance.new("Frame", frame)
    barra.Size = UDim2.new(1, -24, 0, 4)
    barra.Position = UDim2.new(0, 12, 0, 38)
    barra.BackgroundColor3 = NexusUI.Colors.Border
    Instance.new("UICorner", barra).CornerRadius = UDim.new(1, 0)
    
    local preenchimento = Instance.new("Frame", barra)
    preenchimento.Size = UDim2.new((valor - min) / (max - min), 0, 1, 0)
    preenchimento.BackgroundColor3 = NexusUI.Colors.Title
    Instance.new("UICorner", preenchimento).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", barra)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((valor - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = NexusUI.Colors.Text
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local arrastando, callback = false, config.Callback or function() end
    
    local function atualizar(v)
        v = math.clamp(v, min, max)
        local perc = (v - min) / (max - min)
        preenchimento.Size = UDim2.new(perc, 0, 1, 0)
        knob.Position = UDim2.new(perc, -6, 0.5, -6)
        title.Text = config.Title .. ": " .. math.floor(v)
        callback(v)
        return v
    end
    
    barra.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastando = true
            local perc = math.clamp((input.Position.X - barra.AbsolutePosition.X) / barra.AbsoluteSize.X, 0, 1)
            valor = atualizar(min + perc * (max - min))
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if arrastando and input.UserInputType == Enum.UserInputType.MouseMovement then
            local perc = math.clamp((input.Position.X - barra.AbsolutePosition.X) / barra.AbsoluteSize.X, 0, 1)
            valor = atualizar(min + perc * (max - min))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then arrastando = false end
    end)
    
    return {
        Set = function(v) valor = atualizar(v) end,
        Get = function() return valor end
    }
end

-- 24. CRIAR UI
local win = NexusUI:CreateWindow({
    Title = "NEXUS v7.1.0",
    Subtitle = "Blox Fruits | Delta Executor",
    Width = 580,
    Height = 480
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
NexusUI:CreateSection(tabs["⚔️ Farm"], "Super Farm")
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "🚀 Super Farm",
    Callback = function(v) if v then startSuperFarm() else stopSuperFarm() end end
})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "💀 Kill Aura",
    Callback = function(v) if v then startKillAura() else stopKillAura() end end
})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "🛡️ Godmode",
    Callback = function(v) if v then startGodmode() else stopGodmode() end end
})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {
    Title = "📋 Auto Quest",
    Callback = function(v) if v then startAutoQuest() else stopAutoQuest() end end
})
NexusUI:CreateSlider(tabs["⚔️ Farm"], {
    Title = "🎯 Alcance",
    Min = 100, Max = 500, Default = 300,
    Callback = function(v) range = v end
})

-- 🎯 BOSSES
NexusUI:CreateSection(tabs["🎯 Bosses"], "Bosses do Sea " .. currentSea)
for _, name in pairs(BOSSES[currentSea]) do
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {
        Title = "🎯 " .. name,
        Callback = function(v) if v then startBossFarm(name) else stopBossFarm(name) end end
    })
end

-- 🍎 FRUTAS
NexusUI:CreateSection(tabs["🍎 Frutas"], "Sniper & Autos")
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "🍎 Fruit Sniper",
    Callback = function(v) if v then startFruitSniper() else stopFruitSniper() end end
})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "📦 Auto Store Fruit",
    Callback = function(v) if v then startAutoStore() else stopAutoStore() end end
})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "🎲 Auto Roll Fruit",
    Callback = function(v) if v then startAutoRoll() else stopAutoRoll() end end
})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {
    Title = "🪄 Auto Spawn Fruit",
    Callback = function(v) if v then startAutoSpawn() else stopAutoSpawn() end end
})

-- 💎 FARMS
NexusUI:CreateSection(tabs["💎 Farms"], "Farms Extras")
NexusUI:CreateToggle(tabs["💎 Farms"], {
    Title = "💎 Fragment Farm",
    Callback = function(v) if v then startFragmentFarm() else stopFragmentFarm() end end
})
NexusUI:CreateToggle(tabs["💎 Farms"], {
    Title = "🦴 Bones Farm",
    Callback = function(v) if v then startBonesFarm() else stopBonesFarm() end end
})
NexusUI:CreateToggle(tabs["💎 Farms"], {
    Title = "💰 Bounty Hunt",
    Callback = function(v) if v then startBountyHunt() else stopBountyHunt() end end
})

-- 🏃 MOVE
NexusUI:CreateSection(tabs["🏃 Move"], "Movimentação")
NexusUI:CreateToggle(tabs["🏃 Move"], {
    Title = "✈️ Fly",
    Callback = function(v) if v then startFly() else stopFly() end end
})
NexusUI:CreateToggle(tabs["🏃 Move"], {
    Title = "🏃 Walkspeed",
    Callback = function(v) if v then startWalkspeed() else stopWalkspeed() end end
})
NexusUI:CreateToggle(tabs["🏃 Move"], {
    Title = "🦘 Jumpspeed",
    Callback = function(v) if v then startJumpspeed() else stopJumpspeed() end end
})
NexusUI:CreateToggle(tabs["🏃 Move"], {
    Title = "🚫 No Clip",
    Callback = function(v) if v then startNoclip() else stopNoclip() end end
})

-- ⚙️ AUTO
NexusUI:CreateSection(tabs["⚙️ Auto"], "Automações")
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "🌀 Auto Haki",
    Callback = function(v) if v then startAutoHaki() else stopAutoHaki() end end
})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "⭐ Auto Skill",
    Callback = function(v) if v then startAutoSkill() else stopAutoSkill() end end
})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "👑 Auto V4",
    Callback = function(v) if v then startAutoV4() else stopAutoV4() end end
})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "🧬 Auto Race",
    Callback = function(v) if v then startAutoRace() else stopAutoRace() end end
})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {
    Title = "📊 Auto Stats",
    Callback = function(v) if v then startAutoStats() else stopAutoStats() end end
})

-- 🛍️ LOJA
NexusUI:CreateSection(tabs["🛍️ Loja"], "Compras Automáticas")
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "🍎 Buy Fruits",
    Callback = function(v) if v then startShopFruits() else stopShopFruits() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "👊 Buy Styles",
    Callback = function(v) if v then startShopStyles() else stopShopStyles() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "⚔️ Buy Swords",
    Callback = function(v) if v then startShopSword() else stopShopSword() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "🔫 Buy Guns",
    Callback = function(v) if v then startShopGuns() else stopShopGuns() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "💍 Buy Accessories",
    Callback = function(v) if v then startShopAcc() else stopShopAcc() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "📦 Buy Materials",
    Callback = function(v) if v then startShopMat() else stopShopMat() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "💎 Buy Fragments",
    Callback = function(v) if v then startShopFrag() else stopShopFrag() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "🦴 Buy Bones",
    Callback = function(v) if v then startShopBones() else stopShopBones() end end
})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {
    Title = "📊 Buy Stats",
    Callback = function(v) if v then startShopStats() else stopShopStats() end end
})

-- 👀 ESP
NexusUI:CreateSection(tabs["👀 ESP"], "ESP")
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "👤 ESP Players",
    Callback = function(v) if v then startESP("players", Color3.fromRGB(255, 0, 0)) else stopESP("players") end end
})
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "🍎 ESP Fruits",
    Callback = function(v) if v then startESP("fruits", Color3.fromRGB(255, 0, 255)) else stopESP("fruits") end end
})
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "📦 ESP Chests",
    Callback = function(v) if v then startESP("chests", Color3.fromRGB(255, 215, 0)) else stopESP("chests") end end
})
NexusUI:CreateToggle(tabs["👀 ESP"], {
    Title = "🎯 ESP Bosses",
    Callback = function(v) if v then startESP("bosses", Color3.fromRGB(255, 50, 50)) else stopESP("bosses") end end
})

-- 🎮 EXTRA
NexusUI:CreateSection(tabs["🎮 Extra"], "Funções Especiais")
NexusUI:CreateToggle(tabs["🎮 Extra"], {
    Title = "🎯 Aimlock",
    Callback = function(v) if v then startAimlock() else stopAimlock() end end
})
NexusUI:CreateButton(tabs["🎮 Extra"], {
    Title = "🛑 DESLIGAR TUDO",
    Callback = disableAll
})

-- 🏝️ ILHAS
NexusUI:CreateSection(tabs["🏝️ Ilhas"], "Teleportes")
for _, seaIslands in pairs(ISLANDS) do
    for _, island in pairs(seaIslands) do
        NexusUI:CreateButton(tabs["🏝️ Ilhas"], {
            Title = "🏝️ " .. island[1],
            Callback = function()
                tp(island[2])
                notify("🏝️", "Teleportado para " .. island[1], 2)
            end
        })
    end
end

-- 25. NOTIFICAÇÃO FINAL
notify("NEXUS v7.1.0", "✅ Script carregado!\n🚀 Super Farm Corrigido\n⚡ Todas funções prontas", 5)
print("✅ NEXUS v7.1.0 - CARREGADO COM SUCESSO!")
print("🚀 Ative o Super Farm e veja a caixa vermelha!")
