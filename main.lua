-- ============================================================
-- NEXUS v7.0.9 - SUPER FARM UNIFICADO + COMPLETO
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local CONFIG = {
    VERSION = "7.0.9",
    MIN_ATTACK_DELAY = 0.15,
    MAX_ATTACK_DELAY = 0.35,
    ATTACK_CYCLE_DELAY = 0.2,
    MAX_ESP_OBJECTS = 8,
    MEMORY_CLEAN_INTERVAL = 45,
    ANTI_AFK_INTERVAL = 180,
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
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function randomDelay(min, max) return math.random(min * 1000, max * 1000) / 1000 end

-- ============================================================
-- ANTI-BAN
-- ============================================================
pcall(function() player.Kick = function() return nil end end)
pcall(function() if Players.LocalPlayer then Players.LocalPlayer.Kick = function() return nil end end end)

pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "Kick" or method == "Ban" then return nil end
            if method == "FireServer" and type(args[1]) == "string" then
                local blocked = {"Kick","Ban","Teleport","Flag","Report","Detect","AntiCheat","Log","Alert","NotifyAdmin","SendLog","Spectate","Moderator","Admin","Check","Verify","Validate","Scan","Execute","Inject","Exploit","Cheat","Hack","Script","Client","Debug","Monitor","Watch","Trace","Track","Violation"}
                for _, b in pairs(blocked) do
                    if args[1]:lower():find(b:lower()) then return nil end
                end
            end
            return old(self, ...)
        end
        setreadonly(mt, true)
    end
end)

task.spawn(function() while true do task.wait(randomDelay(15,35)) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local hrp=player.Character.HumanoidRootPart hrp.CFrame=hrp.CFrame*CFrame.new(randomDelay(-0.5,0.5),0,randomDelay(-0.5,0.5)) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(250,350)) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(math.random(-1,1),0,math.random(-1,1)),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero,true) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(60,120)) pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new(math.random(300,900),math.random(300,600))) end) end end)

-- ============================================================
-- OTIMIZAÇÃO
-- ============================================================
pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 if Workspace.Terrain then Workspace.Terrain.WaterWaveSize = 0 Workspace.Terrain.GrassLength = 0 end end)

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
        bosses = {"Gorilla King","Chef","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"},
        fruits = {"Rocket-Fruit","Spin-Fruit","Blade-Fruit","Spring-Fruit","Bomb-Fruit","Smoke-Fruit","Spike-Fruit","Flame-Fruit","Eagle-Fruit","Ice-Fruit","Sand-Fruit","Dark-Fruit","Diamond-Fruit","Light-Fruit","Barrier-Fruit","Magma-Fruit","Rumble-Fruit"},
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
        bosses = {"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan","Beautiful Pirate","Elite Pirates","Pharaoh Akshan","Fossil Expert"},
        fruits = {"Gravity-Fruit","Mammoth-Fruit","T-Rex-Fruit","Dough-Fruit","Shadow-Fruit","Venom-Fruit","Control-Fruit","Gas-Fruit","Spirit-Fruit","Tiger-Fruit","Yeti-Fruit","Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit"},
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
local currentTarget = nil
local range = CONFIG.DEFAULT_RANGE
local espBills = {}
local kills = 0
local lastAttackTime = 0
local masteryType = "Fruit"
local fragmentFarmEnabled = false
local bonesFarmEnabled = false
local aimlockEnabled = false
local noclipEnabled = false
local walkspeedEnabled = false
local bountyHuntEnabled = false

-- ============================================================
-- SUPER FARM (CAIXA INVISÍVEL)
-- ============================================================
local SuperFarm = {
    enabled = false,
    boxPart = nil,
    boxSize = Vector3.new(5, 3, 5),
    flyHeight = 1.5,
    collectedMobs = {},
    lastCollectTime = 0,
    collectCooldown = 0.3,
}

function SuperFarm.createBox()
    if SuperFarm.boxPart and SuperFarm.boxPart.Parent then
        SuperFarm.boxPart:Destroy()
    end
    local part = Instance.new("Part")
    part.Name = "NexusFarmBox"
    part.Size = SuperFarm.boxSize
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = Workspace
    SuperFarm.boxPart = part
end

function SuperFarm.positionBox()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not SuperFarm.boxPart then return end
    local hrp = player.Character.HumanoidRootPart
    SuperFarm.boxPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, SuperFarm.flyHeight, 0))
end

function SuperFarm.collectMobs()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if tick() - SuperFarm.lastCollectTime < SuperFarm.collectCooldown then return end
    SuperFarm.lastCollectTime = tick()
    
    local hrp = player.Character.HumanoidRootPart
    local boxPos = SuperFarm.boxPart.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local mobHrp = obj:FindFirstChild("HumanoidRootPart")
            local mobHum = obj:FindFirstChild("Humanoid")
            if mobHrp and mobHum and mobHum.Health > 0 then
                local dist = (mobHrp.Position - hrp.Position).Magnitude
                if dist <= range and not SuperFarm.collectedMobs[obj] then
                    local offset = Vector3.new(
                        math.random(-SuperFarm.boxSize.X/2 + 1, SuperFarm.boxSize.X/2 - 1),
                        0,
                        math.random(-SuperFarm.boxSize.Z/2 + 1, SuperFarm.boxSize.Z/2 - 1)
                    )
                    mobHrp.CFrame = CFrame.new(boxPos + offset)
                    SuperFarm.collectedMobs[obj] = true
                end
            end
        end
    end
end

function SuperFarm.attackMobs()
    if not SuperFarm.boxPart then return end
    for obj, _ in pairs(SuperFarm.collectedMobs) do
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            currentTarget = obj
            attack()
        else
            SuperFarm.collectedMobs[obj] = nil
        end
    end
end

function SuperFarm.flyPlayer()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not SuperFarm.boxPart then return end
    local hrp = player.Character.HumanoidRootPart
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local targetPos = SuperFarm.boxPart.Position + Vector3.new(0, SuperFarm.flyHeight, 0)
    hrp.CFrame = CFrame.new(targetPos)
    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
end

local function startSuperFarm()
    SuperFarm.enabled = true
    SuperFarm.createBox()
    SuperFarm.collectedMobs = {}
    notify("🚀 SUPER FARM", "Caixa invisível ativada!", 5)
end

local function stopSuperFarm()
    SuperFarm.enabled = false
    if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart = nil end
    SuperFarm.collectedMobs = {}
    notify("🚀 SUPER FARM", "Desligado!", 3)
end

-- ============================================================
-- FUNÇÕES BÁSICAS
-- ============================================================
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local h = player.Character.HumanoidRootPart
            h.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            task.wait(0.05)
            h.CFrame = CFrame.new(pos)
        end
    end)
end

local function attack()
    local cd = randomDelay(CONFIG.MIN_ATTACK_DELAY, CONFIG.MAX_ATTACK_DELAY)
    if tick() - lastAttackTime < cd then return end
    lastAttackTime = tick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(randomDelay(0.04, 0.08))
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        kills = kills + 1
    end)
end

local function useSkill(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(randomDelay(0.08, 0.15))
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

local function buyItem(item)
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", item) end
    end)
end

local function notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = title or "Stats", Text = text or "", Duration = dur or 3}) end)
end

-- ============================================================
-- LOOP CENTRAL
-- ============================================================
task.spawn(function()
    while true do
        local t = tick()
        detectSea()
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
            continue
        end
        
        -- SUPER FARM
        if SuperFarm.enabled then
            pcall(function()
                SuperFarm.positionBox()
                SuperFarm.flyPlayer()
                SuperFarm.collectMobs()
                SuperFarm.attackMobs()
                
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
                
                if t % 3 < 0.1 then useSkill("Z") task.wait(0.5) useSkill("X") end
                if t % 8 < 0.1 then
                    for _, n in pairs(SEA_DATA[currentSea].fruits) do
                        local f = Workspace:FindFirstChild(n)
                        if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) break end
                    end
                end
                if t % 15 < 0.1 then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("chest") or obj.Name:lower():find("bone") then
                            local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChildOfClass("BasePart") and obj:FindFirstChildOfClass("BasePart").Position)
                            if pos then tp(pos) break end
                        end
                    end
                end
                if t % 30 < 0.1 then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and (obj:FindFirstChild("Quest") or obj:FindFirstChild("QuestGiver")) then
                            if obj:FindFirstChild("HumanoidRootPart") then tp(obj.HumanoidRootPart.Position) break end
                        end
                    end
                end
                if t % 60 < 0.1 then
                    local r = ReplicatedStorage:FindFirstChild("Remotes")
                    if r and r:FindFirstChild("CommF_") then
                        r.CommF_:InvokeServer("ActivateHaki", "Ken")
                        r.CommF_:InvokeServer("ActivateHaki", "Observation")
                    end
                end
                if t % 300 < 0.1 then
                    buyItem("Kitsune")
                    buyItem("Dragon")
                    buyItem("Leopard")
                end
            end)
        end
        
        -- AIMLOCK
        if aimlockEnabled then
            pcall(function()
                local tgt = nil
                local shortest = range
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 and o ~= player.Character then
                        local d = (o.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if d < shortest then shortest = d tgt = o end
                    end
                end
                if tgt then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, tgt.HumanoidRootPart.Position)
                end
            end)
        end
        
        -- NO CLIP
        if noclipEnabled then
            pcall(function()
                if player.Character then
                    for _, p in pairs(player.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
        
        -- WALKSPEED
        if walkspeedEnabled then
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 100 end
                end
            end)
        end
        
        -- BOUNTY HUNT
        if bountyHuntEnabled and t % 15 < 0.1 then
            pcall(function()
                local best, bestDist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if d < bestDist then best = p bestDist = d end
                    end
                end
                if best then tp(best.Character.HumanoidRootPart.Position) for _ = 1, 5 do attack() task.wait(0.3) end end
            end)
        end
        
        -- FRAGMENTOS
        if fragmentFarmEnabled and t % 60 < 0.1 then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments", 500) end
            end)
        end
        
        -- OSSOS
        if bonesFarmEnabled and t % 30 < 0.1 then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones", 50) end
            end)
        end
        
        if t % 45 < 0.1 then pcall(function() collectgarbage("collect") end) end
        
        task.wait(CONFIG.ATTACK_CYCLE_DELAY)
    end
end)

-- ============================================================
-- UI
-- ============================================================
local win = NexusUI:CreateWindow({Title = "Stats", Subtitle = SEA_DATA[currentSea].name .. " | v" .. CONFIG.VERSION, Width = 580, Height = 500})
local tabs = {}
for _, t in pairs({{"⚔️ Farm"},{"🍎 Frutas"},{"🎯 Bosses"},{"🌊 Sea"},{"📦 Coleta"},{"🏃 Move"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1]}) end

-- SUPER FARM
NexusUI:CreateLabel(tabs["⚔️ Farm"], {Title = "🚀 SUPER FARM (TUDO EM UM)"})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🚀 SUPER FARM", Desc = "Caixa invisível + Voo + Ataque + Coleta + Quest + Haki + Skills + Compras", Callback = function(v) if v then startSuperFarm() else stopSuperFarm() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "💎 Auto Fragmentos", Callback = function(v) fragmentFarmEnabled = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🦴 Auto Ossos", Callback = function(v) bonesFarmEnabled = v end})

-- FRUTAS
NexusUI:CreateLabel(tabs["🍎 Frutas"], {Title = "🍎 FRUTAS DO " .. SEA_DATA[currentSea].name:upper()})
for _, n in pairs(SEA_DATA[currentSea].fruits) do NexusUI:CreateLabel(tabs["🍎 Frutas"], {Title = "🍎 " .. n}) end

-- BOSSES
NexusUI:CreateLabel(tabs["🎯 Bosses"], {Title = "🎯 BOSSES"})
for _, n in pairs(SEA_DATA[currentSea].bosses) do NexusUI:CreateLabel(tabs["🎯 Bosses"], {Title = n}) end

-- SEA
NexusUI:CreateLabel(tabs["🌊 Sea"], {Title = "🌊 SEA EVENTS"})
for _, n in pairs({"Marine Ship","Pirate Ship","Sea Beast","Terror Shark","Rumbling","Mansion","Pirate Raid","Sea Castle"}) do NexusUI:CreateLabel(tabs["🌊 Sea"], {Title = n}) end

-- COLETA
NexusUI:CreateLabel(tabs["📦 Coleta"], {Title = "📦 COLETA (Inclusa no Super Farm)"})
for _, n in pairs({"Chest","Bone","Fist of Darkness","God's Chalice","Blue Gear","Sweet Chalice","Scroll","Fruit Chest"}) do NexusUI:CreateLabel(tabs["📦 Coleta"], {Title = n}) end

-- MOVIMENTO
NexusUI:CreateLabel(tabs["🏃 Move"], {Title = "🏃 MOVIMENTAÇÃO"})
for _, n in pairs({"Auto Hop","Auto Dash","Auto Flight","Auto Swim","TP Island","TP NPC","TP Fruit","TP Chest","TP Player"}) do NexusUI:CreateLabel(tabs["🏃 Move"], {Title = n}) end

-- VISUAL
NexusUI:CreateLabel(tabs["👀 Visual"], {Title = "👀 ESP"})
for _, n in pairs({"ESP Players","ESP Fruits","ESP Chests","ESP Bosses","ESP Items","ESP Materials","ESP NPCs","ESP Sea Beasts","ESP Ships"}) do NexusUI:CreateLabel(tabs["👀 Visual"], {Title = n}) end

-- EXTRA
NexusUI:CreateLabel(tabs["🎮 Extra"], {Title = "🎮 EXTRA"})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🎯 Aimlock", Callback = function(v) aimlockEnabled = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🚫 No Clip", Callback = function(v) noclipEnabled = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🏃 Walkspeed", Callback = function(v) walkspeedEnabled = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "💰 Bounty Hunt", Callback = function(v) bountyHuntEnabled = v end})
NexusUI:CreateDropdown(tabs["🎮 Extra"], {Title = "Maestria", Options = {"Fruit","Sword","Gun","Melee"}, Default = masteryType, Callback = function(v) masteryType = v end})
NexusUI:CreateSlider(tabs["🎮 Extra"], {Title = "Alcance", Min = 50, Max = 500, Default = 300, Callback = function(v) range = v end})
NexusUI:CreateButton(tabs["🎮 Extra"], {Title = "🛑 DESLIGAR TUDO", Callback = function()
    stopSuperFarm()
    fragmentFarmEnabled = false
    bonesFarmEnabled = false
    aimlockEnabled = false
    noclipEnabled = false
    walkspeedEnabled = false
    bountyHuntEnabled = false
    notify("Stats", "Desligado", 3)
end})

-- ILHAS
NexusUI:CreateLabel(tabs["🏝️ Ilhas"], {Title = "🏝️ ILHAS DO " .. SEA_DATA[currentSea].name:upper()})
for _, il in pairs(SEA_DATA[currentSea].islands) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"], {Title = "🏝️ " .. il[1], Callback = function() tp(il[2]) notify("🏝️", il[1], 2) end})
end

-- FPS
local fl = Instance.new("TextLabel", win.Frame)
fl.Size = UDim2.new(0, 260, 0, 15)
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
        fl.Text = "FPS: " .. fc .. " | 💀 " .. kills .. " | 🌊 " .. SEA_DATA[currentSea].name
        fc = 0 lt = nw
    end
end)

notify("Stats", SEA_DATA[currentSea].name .. " | v" .. CONFIG.VERSION .. " | Super Farm Ready", 5)
print("NEXUS v7.0.9 - Super Farm Unificado - Loaded")
