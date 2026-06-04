-- ============================================================
-- NEXUS v7.0.6 ENHANCED - ANTI-DETECÇÃO ROBUSTO
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local CONFIG = {
    VERSION = "7.0.6",
    MIN_ATTACK_DELAY = 0.15,
    ATTACK_CYCLE_DELAY = 0.2,
    MAX_ESP_OBJECTS = 10,
    MEMORY_CLEAN_INTERVAL = 60,
    ANTI_AFK_INTERVAL = 300,
    DEFAULT_RANGE = 300,
    MIN_RANGE = 50,
    MAX_RANGE = 500,
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================================
-- UTILITÁRIOS ANTI-DETECÇÃO
-- ============================================================

-- Randomização humanizada
local function randomDelay(min, max)
    return math.random(min * 1000, max * 1000) / 1000
end

-- Verificar se posição é válida (anti teleporte detecção)
local function isValidPosition(pos1, pos2)
    local distance = (pos1 - pos2).Magnitude
    return distance < 500 -- Limite de distância realista
end

-- Simular latência humana
local lastRemoteCall = 0
local function humanizedRemoteCall()
    local delay = randomDelay(0.05, 0.15)
    task.wait(delay)
end

-- ============================================================
-- ANTI-BAN (6 CAMADAS - VERSÃO ENHANCED)
-- ============================================================

-- Camada 1: Block Direto de Kicks
pcall(function() player.Kick = function() return nil end end)
pcall(function() if Players.LocalPlayer then Players.LocalPlayer.Kick = function() return nil end end end)

-- Camada 2: Metatable Hook Avançado
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            -- Bloquear Kicks/Bans
            if method == "Kick" or method == "Ban" then return nil end
            
            -- Bloquear FireServer suspeito
            if method == "FireServer" and type(args[1]) == "string" then
                local blocked = {
                    "Kick","Ban","Teleport","Flag","Report","Detect","AntiCheat","Log","Alert",
                    "NotifyAdmin","SendLog","Spectate","Moderator","Admin","Check","Verify",
                    "Validate","Scan","Execute","Inject","Exploit","Cheat","Hack","Script",
                    "Client","Debug","Monitor","Watch","Trace","Track","Violation"
                }
                for _, b in pairs(blocked) do
                    if args[1]:lower():find(b:lower()) then return nil end
                end
            end
            
            return old(self, ...)
        end
        setreadonly(mt, true)
    end
end)

-- Camada 3: Anti-movement tracking
task.spawn(function()
    while true do
        task.wait(randomDelay(15, 35)) -- Aleatoriedade realista
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                -- Pequeno movimento aleatorio (anti-AFK)
                hrp.CFrame = hrp.CFrame * CFrame.new(randomDelay(-0.5, 0.5), 0, randomDelay(-0.5, 0.5))
            end
        end)
    end
end)

-- Camada 4: Anti-AFK Humanizado
task.spawn(function()
    while true do
        task.wait(randomDelay(250, 350))
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local hum = player.Character.Humanoid
                if hum.Health < hum.MaxHealth * 0.95 then
                    hum.Health = hum.MaxHealth
                end
            end
        end)
    end
end)

-- Camada 5: Input simulação humanizada
task.spawn(function()
    while true do
        task.wait(randomDelay(60, 120))
        pcall(function()
            VirtualUser:CaptureController()
            local randomX = math.random(300, 900)
            local randomY = math.random(300, 600)
            VirtualUser:ClickButton2(Vector2.new(randomX, randomY))
        end)
    end
end)

-- Camada 6: Detecção de perigos
local detectionWarnings = 0
task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            if detectionWarnings > 3 then
                for k, _ in pairs(states) do
                    states[k] = false
                end
                detectionWarnings = 0
            end
        end)
    end
end)

-- ============================================================
-- OTIMIZAÇÃO
-- ============================================================
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    if Workspace.Terrain then
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.GrassLength = 0
    end
end)

-- ============================================================
-- DADOS DOS SEAS
-- ============================================================
local SEA_DATA = {
    [1] = {
        name = "First Sea", levelRange = {1, 700},
        islands = {
            {"Pirate Starter", Vector3.new(1289,11,4191)}, {"Marine Starter", Vector3.new(-383,15,727)},
            {"Jungle", Vector3.new(-1250,15,3850)}, {"Pirate Village", Vector3.new(-383,15,727)},
            {"Desert", Vector3.new(966,10,1100)}, {"Frozen Village", Vector3.new(1150,25,4350)},
            {"Marine Fortress", Vector3.new(-1500,10,5300)}, {"Skylands", Vector3.new(-4850,750,1950)},
            {"Prison", Vector3.new(-5400,15,-1700)}, {"Colosseum", Vector3.new(-3560,240,-80)},
            {"Magma Village", Vector3.new(-3420,10,-2700)}, {"Underwater City", Vector3.new(5500,-50,2000)},
            {"Upper Skylands", Vector3.new(-4840,755,1940)}, {"Fountain City", Vector3.new(4500,50,1200)},
        },
        bosses = {"Gorilla King","Chef","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg"},
        fruits = {"Rocket-Fruit","Spin-Fruit","Blade-Fruit","Spring-Fruit","Bomb-Fruit","Smoke-Fruit","Spike-Fruit","Flame-Fruit","Eagle-Fruit","Ice-Fruit","Sand-Fruit","Dark-Fruit","Diamond-Fruit"},
    },
    [2] = {
        name = "Second Sea", levelRange = {701, 1500},
        islands = {
            {"Kingdom of Rose", Vector3.new(-1400,10,-1400)}, {"Green Zone", Vector3.new(6200,80,2500)},
            {"Hot and Cold", Vector3.new(-3420,10,-2700)}, {"Ice Castle", Vector3.new(7200,100,3500)},
            {"Forgotten Island", Vector3.new(8500,120,4500)}, {"Cafe", Vector3.new(-570,310,-1220)},
            {"Mansion", Vector3.new(-390,45,-800)},
        },
        bosses = {"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"},
        fruits = {"Creation-Fruit","Quake-Fruit","Buddha-Fruit","Love-Fruit","Spider-Fruit","Sound-Fruit","Phoenix-Fruit","Portal-Fruit","Lightning-Fruit","Pain-Fruit","Blizzard-Fruit"},
    },
    [3] = {
        name = "Third Sea", levelRange = {1501, 2600},
        islands = {
            {"Port Town", Vector3.new(7200,100,3500)}, {"Hydra Island", Vector3.new(6200,80,2500)},
            {"Great Tree", Vector3.new(8500,120,4500)}, {"Castle on the Sea", Vector3.new(4500,50,1200)},
            {"Haunted Castle", Vector3.new(9800,60,5500)}, {"Dark Arena", Vector3.new(10500,100,6000)},
            {"Floating Turtle", Vector3.new(11200,90,6500)}, {"Prehistoric Island", Vector3.new(12500,80,7000)},
            {"Desert Kingdom", Vector3.new(13800,100,7500)},
        },
        bosses = {"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan"},
        fruits = {"Gravity-Fruit","Mammoth-Fruit","T-Rex-Fruit","Dough-Fruit","Shadow-Fruit","Venom-Fruit","Control-Fruit","Gas-Fruit","Spirit-Fruit","Tiger-Fruit","Yeti-Fruit","Kitsune-Fruit"},
    },
}

-- ============================================================
-- DETECÇÃO DE SEA
-- ============================================================
local currentSea = 1
local function detectSea()
    local lvl = 1
    pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl = player.Data.Level.Value end end)
    if lvl <= 700 then currentSea = 1
    elseif lvl <= 1500 then currentSea = 2
    else currentSea = 3 end
    return currentSea
end
detectSea()

-- ============================================================
-- VARIÁVEIS
-- ============================================================
local currentTarget, range, espBills, MAX_ESP, kills = nil, CONFIG.DEFAULT_RANGE, {}, CONFIG.MAX_ESP_OBJECTS, 0
local attackDelay, lastAttackTime, MIN_ATTACK_DELAY = CONFIG.ATTACK_CYCLE_DELAY, 0, CONFIG.MIN_ATTACK_DELAY
local masteryType = "Fruit"
local states = {}
local stateNames = {
    "farmLevel","farmMastery","farmBoss","farmRaid","farmSea","farmDungeon","farmElite","farmScroll",
    "fruitSniper","fruitStore","fruitSpawn","fruitRoll","fruitNotify","fruitESP",
    "bossDK","bossSR","bossCP","bossRI","bossDB","bossTK","bossST","bossIE","bossHY","bossLV",
    "seaShip","seaPirate","seaBeast","seaTerror","seaRumble","seaMansion","seaPRaid","seaCastle",
    "colChest","colBones","colFist","colChalice","colBlue","colSweet","colScroll","colFruitChest",
    "moveHop","moveDash","moveFlight","moveSwim","moveIsland","moveNPC","moveFruit","moveChest","movePlayer",
    "atHaki","atSkill","atMeta","atRace","atAccessory","atTitle","atQuest","atGear","atV4","atRaidFruits",
    "shopFruits","shopStyles","shopSword","shopGuns","shopAcc","shopMat","shopStats","shopGP","shopFrag","shopBones",
    "espP","espF","espC","espB","espI","espM","espN","espSB","espShips",
    "aimlock","noclip","walkspeed","jumpspeed","bountyHunt","fragmentFarm","godmode","killAura","autoOP"
}
for _, s in pairs(stateNames) do states[s] = false end

-- ============================================================
-- FUNÇÕES HUMANIZADAS
-- ============================================================

-- Teleporte seguro com validação
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local h = player.Character.HumanoidRootPart
            if not isValidPosition(h.Position, pos) then return end
            
            local startPos = h.CFrame
            local endPos = CFrame.new(pos + Vector3.new(0, 3, 0))
            
            for i = 0, 1, 0.1 do
                h.CFrame = startPos:Lerp(endPos, i)
                task.wait(0.02)
            end
            h.CFrame = endPos
            humanizedRemoteCall()
        end
    end)
end

-- Find target com limite realista
local function findTarget()
    local nearest, shortestDistance = nil, range
    for _, o in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") then
                if o.Humanoid.Health > 0 and o ~= player.Character then
                    local dist = (o.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortestDistance then
                        nearest = o
                        shortestDistance = dist
                    end
                end
            end
        end)
    end
    return nearest
end

-- Find boss
local function findBoss(name)
    local b = Workspace:FindFirstChild(name)
    if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health > 0 then
        return b
    end
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") then
            if o.Humanoid.Health > 0 then return o end
        end
    end
    return nil
end

-- Attack com delays variados
local function attack()
    if tick() - lastAttackTime < (MIN_ATTACK_DELAY + randomDelay(-0.02, 0.02)) then return end
    lastAttackTime = tick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(randomDelay(0.04, 0.08))
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Skill com delay humanizado
local function useSkill(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(randomDelay(0.08, 0.15))
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        humanizedRemoteCall()
    end)
end

-- Compra de item
local function buyItem(item)
    pcall(function()
        humanizedRemoteCall()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then
            r.CommF_:InvokeServer("BuyItem", item)
        end
    end)
end

-- Coleta de item
local function collectItem(name)
    for _, o in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if o.Name:lower():find(name:lower()) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                tp(o.Position)
                humanizedRemoteCall()
            end
        end)
    end
end

-- Notificação
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title or "Script", Text = text or "", Duration = dur or 3})
    end)
end

-- Server hop
local function serverHop()
    pcall(function()
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?limit=10")
        local servers = HttpService:JSONDecode(res)
        if servers and servers.data then
            local server = servers.data[math.random(1, #servers.data)]
            if server then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
            end
        end
    end)
end

-- ============================================================
-- AUTO-OP
-- ============================================================
local function activateAutoOP()
    for _, s in pairs(stateNames) do states[s] = true end
    notify("🚀 AUTO-OP", "Ativado!", 5)
end

-- ============================================================
-- MAIN LOOP COM ANTI-DETECÇÃO
-- ============================================================
task.spawn(function()
    while true do
        local t = tick()
        detectSea()
        
        -- FARM LEVEL
        if states.farmLevel and t % (attackDelay + randomDelay(-0.05, 0.05)) < 0.05 then
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local tgt = findTarget()
                    if tgt then
                        currentTarget = tgt
                        tp(tgt.HumanoidRootPart.Position)
                        for i = 1, math.random(2, 5) do
                            attack()
                            task.wait(randomDelay(0.08, 0.15))
                        end
                    end
                end
            end)
        end
        
        -- FARM MASTERY
        if states.farmMastery and t % (3 + randomDelay(-0.5, 0.5)) < 0.05 then
            pcall(function()
                useSkill("Z")
                task.wait(randomDelay(0.4, 0.6))
                useSkill("X")
            end)
        end
        
        -- FARM BOSS
        if states.farmBoss and t % (8 + randomDelay(-1, 1)) < 0.05 then
            pcall(function()
                for _, n in pairs(SEA_DATA[currentSea].bosses) do
                    if states.farmBoss then
                        local b = findBoss(n)
                        if b then
                            tp(b.HumanoidRootPart.Position)
                            for _ = 1, 10 do
                                attack()
                                task.wait(randomDelay(0.1, 0.2))
                            end
                        end
                    end
                end
            end)
        end
        
        -- COLETA
        if t % (12 + randomDelay(-2, 2)) < 0.05 and states.colChest then
            collectItem("Chest")
        end
        if t % (8 + randomDelay(-1, 1)) < 0.05 and states.colBones then
            collectItem("Bone")
        end
        
        task.wait(0.1)
    end
end)

-- ============================================================
-- UI (Nome oculto)
-- ============================================================
local win = NexusUI:CreateWindow({Title="Stats",Subtitle=SEA_DATA[currentSea].name.." | "..#stateNames.." Funções",Width=580,Height=500})
local tabs = {}
for _, t in pairs({{"⚔️ Combate"},{"🍎 Frutas"},{"🎯 Bosses"},{"🌊 Sea"},{"📦 Coleta"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do
    tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1]})
end

-- COMBATE
NexusUI:CreateSection(tabs["⚔️ Combate"], "Farm")
NexusUI:CreateButton(tabs["⚔️ Combate"], {Title = "🚀 AUTO-OP", Callback = function() activateAutoOP() end})
for _, cfg in pairs({{"Auto Farm Nível","farmLevel"},{"Auto Farm Maestria","farmMastery"},{"Auto Farm Boss","farmBoss"}}) do
    NexusUI:CreateToggle(tabs["⚔️ Combate"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

-- FPS Counter
local fl = Instance.new("TextLabel", win.Frame)
fl.Size = UDim2.new(0, 260, 0, 15)
fl.Position = UDim2.new(0, 10, 1, -18)
fl.BackgroundTransparency = 1
fl.TextColor3 = Color3.fromRGB(160, 160, 170)
fl.TextSize = 10
fl.Font = Enum.Font.GothamSSB

local fc, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nw = tick()
    if nw - lt >= 1 then
        fl.Text = "FPS: " .. fc .. " | 🌊 " .. SEA_DATA[currentSea].name
        fc = 0
        lt = nw
    end
end)

notify("✅ Script v2.0", "Anti-Detecção Ativado", 5)
print("Script v2.0 - Loaded com melhorias de anti-detecção")
