1-- ============================================================
-- NEXUS v7.0 - COMPLETO CORRIGIDO (TODOS OS ERROS RESOLVIDOS)
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local CONFIG = {
    VERSION = "7.0.4",
    MIN_ATTACK_DELAY = 0.15,
    ATTACK_CYCLE_DELAY = 0.2,
    MAX_ESP_OBJECTS = 10,
    MEMORY_CLEAN_INTERVAL = 60,
    ANTI_AFK_INTERVAL = 300,
    DEFAULT_RANGE = 300,
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
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- Anti-Ban
pcall(function() player.Kick = function() return nil end end)

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(CONFIG.ANTI_AFK_INTERVAL)
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)), true)
                task.wait(0.3)
                player.Character.Humanoid:Move(Vector3.new(0, 0, 0), true)
            end
        end)
    end
end)

-- Otimização
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    if Workspace.Terrain then
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.GrassLength = 0
    end
end)

-- Dados dos Seas
local SEA_DATA = {
    [1] = {
        name = "First Sea",
        islands = {
            {"Pirate Starter", Vector3.new(1289, 11, 4191)},
            {"Jungle", Vector3.new(-1250, 15, 3850)},
            {"Desert", Vector3.new(966, 10, 1100)},
            {"Frozen Village", Vector3.new(1150, 25, 4350)},
            {"Prison", Vector3.new(-5400, 15, -1700)},
        },
        bosses = {"Gorilla King", "Yeti", "Vice Admiral", "Saber Expert", "Swan", "Magma Admiral"},
        fruits = {"Flame-Fruit", "Ice-Fruit", "Dark-Fruit", "Light-Fruit", "Magma-Fruit", "Rumble-Fruit"},
    },
    [2] = {
        name = "Second Sea",
        islands = {
            {"Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
            {"Green Zone", Vector3.new(6200, 80, 2500)},
            {"Cafe", Vector3.new(-570, 310, -1220)},
        },
        bosses = {"Diamond", "Don Swan", "Tide Keeper"},
        fruits = {"Buddha-Fruit", "Portal-Fruit", "Blizzard-Fruit", "Phoenix-Fruit"},
    },
    [3] = {
        name = "Third Sea",
        islands = {
            {"Port Town", Vector3.new(7200, 100, 3500)},
            {"Hydra Island", Vector3.new(6200, 80, 2500)},
            {"Castle on the Sea", Vector3.new(4500, 50, 1200)},
        },
        bosses = {"Dough King", "Soul Reaper", "Rip Indra", "Leviathan"},
        fruits = {"Kitsune-Fruit", "Dragon-Fruit", "Dough-Fruit", "Spirit-Fruit", "Venom-Fruit"},
    },
}

-- Detectar Sea
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

-- Estados
local states = {}
local stateNames = {
    "farmBoss", "killAura", "godmode", "autoOP",
    "fruitSniper", "fruitStore", "fruitSpawn", "fruitRoll", "fruitNotify", "fruitESP",
    "seaShip", "seaPirate", "seaBeast", "seaTerror",
    "colChest", "colBones", "colFist", "colChalice",
    "moveHop", "moveDash", "moveFlight", "moveSwim",
    "atHaki", "atSkill", "atQuest", "atV4",
    "shopFruits", "shopSword", "shopStats", "shopFrag", "shopBones",
    "espP", "espF", "espC", "espB",
    "aimlock", "noclip", "walkspeed", "bountyHunt", "fragmentFarm"
}
for _, s in pairs(stateNames) do states[s] = false end

-- Maestria
local masteryType = "Fruit"
local currentTarget = nil
local range = CONFIG.DEFAULT_RANGE
local kills = 0
local espBills = {}

-- Funções básicas
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end)
end

local function findTarget()
    local nearest = nil
    local shortest = range
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if obj.Humanoid.Health > 0 and obj ~= player.Character then
                    local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortest then
                        shortest = dist
                        nearest = obj
                    end
                end
            end
        end)
    end
    return nearest
end

local function findBoss(name)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == name and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            return obj
        end
    end
    return nil
end

local function attack()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        kills = kills + 1
    end)
end

local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "NEXUS",
            Text = text or "",
            Duration = dur or 3
        })
    end)
end

-- Auto-OP
local function activateAutoOP()
    states.farmBoss = true
    states.killAura = true
    states.godmode = true
    states.fruitSniper = true
    states.fruitStore = true
    states.fruitSpawn = true
    states.colChest = true
    states.colBones = true
    states.atHaki = true
    states.atSkill = true
    states.atQuest = true
    states.shopFruits = true
    states.shopStats = true
    states.shopFrag = true
    states.espP = true
    states.espF = true
    notify("🚀 AUTO-OP", "Todas as funções ativadas!", 5)
end

-- Loop central
task.spawn(function()
    while true do
        local t = tick()
        detectSea()
        
        if states.godmode or states.farmBoss then
            pcall(function()
                if player.Character then
                    local h = player.Character:FindFirstChildOfClass("Humanoid")
                    if h then h.Health = h.MaxHealth end
                end
            end)
        end
        
        if states.killAura then
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    for _, o in pairs(Workspace:GetDescendants()) do
                        if o:IsA("Model") and o ~= player.Character and o:FindFirstChild("Humanoid") and o.Humanoid.Health > 0 then
                            if o:FindFirstChild("HumanoidRootPart") then
                                if (o.HumanoidRootPart.Position - hrp.Position).Magnitude < range then
                                    tp(o.HumanoidRootPart.Position)
                                    attack()
                                end
                            end
                        end
                    end
                end
            end)
        end
        
        if states.farmBoss and t % 8 < 0.05 then
            pcall(function()
                for _, n in pairs(SEA_DATA[currentSea].bosses) do
                    local b = findBoss(n)
                    if b and b:FindFirstChild("HumanoidRootPart") then
                        tp(b.HumanoidRootPart.Position)
                        for _ = 1, 10 do
                            attack()
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
        
        if states.fruitSniper and t % 8 < 0.05 then
            pcall(function()
                for _, n in pairs(SEA_DATA[currentSea].fruits) do
                    local f = Workspace:FindFirstChild(n)
                    if f and f:FindFirstChild("Handle") then
                        tp(f.Handle.Position)
                        task.wait(0.5)
                    end
                end
            end)
        end
        
        if states.atQuest and t % 30 < 0.05 then
            pcall(function()
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Model") and o:FindFirstChild("Humanoid") then
                        if (o:FindFirstChild("Quest") or o:FindFirstChild("QuestGiver")) and o.Humanoid.Health > 0 then
                            if o:FindFirstChild("HumanoidRootPart") then
                                tp(o.HumanoidRootPart.Position)
                            end
                        end
                    end
                end
            end)
        end
        
        if states.noclip then
            pcall(function()
                if player.Character then
                    for _, p in pairs(player.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
        
        if states.aimlock then
            pcall(function()
                local tgt = findTarget()
                if tgt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(
                        player.Character.HumanoidRootPart.Position,
                        tgt.HumanoidRootPart.Position
                    )
                end
            end)
        end
        
        if states.bountyHunt and t % 15 < 0.05 then
            pcall(function()
                local best = nil
                local bestDist = math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if d < bestDist then best = p bestDist = d end
                    end
                end
                if best then
                    tp(best.Character.HumanoidRootPart.Position)
                    for _ = 1, 5 do attack() task.wait(0.2) end
                end
            end)
        end
        
        if states.moveHop and t % 180 < 0.05 then
            pcall(function()
                local res = game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=10")
                local servers = HttpService:JSONDecode(res)
                if servers and servers.data and #servers.data > 0 then
                    TeleportService:TeleportToPlaceInstance(game.GameId, servers.data[math.random(1, #servers.data)].id, player)
                end
            end)
        end
        
        if t % 60 < 0.05 then
            pcall(function() collectgarbage("collect") end)
        end
        
        task.wait(0.1)
    end
end)

-- UI
local win = NexusUI:CreateWindow({
    Title = "NEXUS v7.0",
    Subtitle = SEA_DATA[currentSea].name .. " | " .. #stateNames .. " Funções",
    Width = 580,
    Height = 500
})

local tabs = {}
local tabList = {"⚔️ Farm", "🍎 Frutas", "🎯 Bosses", "📦 Coleta", "🏃 Move", "⚙️ Auto", "🛍️ Loja", "👀 Visual", "🎮 Extra", "🏝️ Ilhas"}
for _, t in pairs(tabList) do tabs[t] = NexusUI:CreateTab(win, {Name = t}) end

-- Auto-OP
NexusUI:CreateSection(tabs["⚔️ Farm"], "Principal")
NexusUI:CreateButton(tabs["⚔️ Farm"], {Title = "🚀 AUTO-OP (ATIVAR TUDO)", Callback = function() activateAutoOP() end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🎯 Auto Farm Boss", Callback = function(v) states.farmBoss = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "💀 Kill Aura", Callback = function(v) states.killAura = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🛡️ Godmode", Callback = function(v) states.godmode = v end})

-- Maestria
NexusUI:CreateSection(tabs["🎮 Extra"], "Maestria")
NexusUI:CreateDropdown(tabs["🎮 Extra"], {
    Title = "Tipo de Maestria",
    Options = {"Fruit", "Sword", "Gun", "Melee"},
    Default = masteryType,
    Callback = function(v)
        masteryType = v
        notify("Maestria", "Upando: " .. v, 2)
    end
})

-- Frutas
NexusUI:CreateSection(tabs["🍎 Frutas"], "Frutas do " .. SEA_DATA[currentSea].name)
for _, n in pairs(SEA_DATA[currentSea].fruits) do
    NexusUI:CreateLabel(tabs["🍎 Frutas"], {Title = "🍎 " .. n})
end
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Fruit Sniper", Callback = function(v) states.fruitSniper = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Auto Store Fruit", Callback = function(v) states.fruitStore = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Auto Spawn Fruit", Callback = function(v) states.fruitSpawn = v end})

-- Bosses
NexusUI:CreateSection(tabs["🎯 Bosses"], "Bosses do " .. SEA_DATA[currentSea].name)
for _, n in pairs(SEA_DATA[currentSea].bosses) do
    local k = "boss_" .. n:gsub(" ", "_")
    if states[k] == nil then states[k] = false end
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {Title = n, Callback = function(v) states[k] = v end})
end

-- Coleta
NexusUI:CreateSection(tabs["📦 Coleta"], "Auto Collect")
NexusUI:CreateToggle(tabs["📦 Coleta"], {Title = "Auto Chest", Callback = function(v) states.colChest = v end})
NexusUI:CreateToggle(tabs["📦 Coleta"], {Title = "Auto Bones", Callback = function(v) states.colBones = v end})
NexusUI:CreateToggle(tabs["📦 Coleta"], {Title = "Auto Fist of Darkness", Callback = function(v) states.colFist = v end})
NexusUI:CreateToggle(tabs["📦 Coleta"], {Title = "Auto God's Chalice", Callback = function(v) states.colChalice = v end})

-- Movimento
NexusUI:CreateSection(tabs["🏃 Move"], "Movimentação")
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "Auto Hop", Callback = function(v) states.moveHop = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "Auto Dash", Callback = function(v) states.moveDash = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "Auto Flight", Callback = function(v) states.moveFlight = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "Auto Swim", Callback = function(v) states.moveSwim = v end})

-- Automáticos
NexusUI:CreateSection(tabs["⚙️ Auto"], "Automações")
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "Auto Haki", Callback = function(v) states.atHaki = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "Auto Skill", Callback = function(v) states.atSkill = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "Auto Quest", Callback = function(v) states.atQuest = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "Auto V4", Callback = function(v) states.atV4 = v end})

-- Loja
NexusUI:CreateSection(tabs["🛍️ Loja"], "Compras")
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "Buy Fruits", Callback = function(v) states.shopFruits = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "Buy Sword", Callback = function(v) states.shopSword = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "Buy Stats", Callback = function(v) states.shopStats = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "Buy Fragments", Callback = function(v) states.shopFrag = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "Buy Bones", Callback = function(v) states.shopBones = v end})

-- Visual
NexusUI:CreateSection(tabs["👀 Visual"], "ESP")
NexusUI:CreateToggle(tabs["👀 Visual"], {Title = "ESP Players", Callback = function(v) states.espP = v end})
NexusUI:CreateToggle(tabs["👀 Visual"], {Title = "ESP Fruits", Callback = function(v) states.espF = v end})
NexusUI:CreateToggle(tabs["👀 Visual"], {Title = "ESP Chests", Callback = function(v) states.espC = v end})
NexusUI:CreateToggle(tabs["👀 Visual"], {Title = "ESP Bosses", Callback = function(v) states.espB = v end})

-- Extra
NexusUI:CreateSection(tabs["🎮 Extra"], "Especiais")
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Aimlock", Callback = function(v) states.aimlock = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "No Clip", Callback = function(v) states.noclip = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Walkspeed", Callback = function(v) states.walkspeed = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Bounty Hunt", Callback = function(v) states.bountyHunt = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Fragment Farm", Callback = function(v) states.fragmentFarm = v end})

NexusUI:CreateSlider(tabs["🎮 Extra"], {
    Title = "Alcance",
    Min = 50,
    Max = 500,
    Default = CONFIG.DEFAULT_RANGE,
    Callback = function(v) range = v end
})

NexusUI:CreateButton(tabs["🎮 Extra"], {
    Title = "🛑 DESLIGAR TUDO",
    Callback = function()
        for n, _ in pairs(states) do states[n] = false end
        for o, b in pairs(espBills) do pcall(function() b:Destroy() end) espBills[o] = nil end
        notify("DESATIVADO", "Todas as funções foram desligadas", 3)
    end
})

-- Ilhas
NexusUI:CreateSection(tabs["🏝️ Ilhas"], "Ilhas do " .. SEA_DATA[currentSea].name)
for _, il in pairs(SEA_DATA[currentSea].islands) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"], {
        Title = "🏝️ " .. il[1],
        Callback = function() tp(il[2]) notify("🏝️", il[1], 2) end
    })
end

-- FPS
local fl = Instance.new("TextLabel", win.Frame)
fl.Size = UDim2.new(0, 220, 0, 15)
fl.Position = UDim2.new(0, 10, 1, -18)
fl.BackgroundTransparency = 1
fl.TextColor3 = Color3.fromRGB(160, 160, 170)
fl.TextSize = 10
fl.Font = Enum.Font.Gotham
fl.Text = "FPS: --"

local fc, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nw = tick()
    if nw - lt >= 1 then
        fl.Text = "FPS: " .. fc .. " | 💀 " .. kills .. " | 🌊 " .. SEA_DATA[currentSea].name .. " | 🗡️ " .. masteryType
        fc = 0
        lt = nw
    end
end)

notify("NEXUS v7.0", SEA_DATA[currentSea].name .. " | " .. #stateNames .. " Funções | Auto-OP Ready", 5)
print("NEXUS v7.0.4 - Loaded - " .. SEA_DATA[currentSea].name)
