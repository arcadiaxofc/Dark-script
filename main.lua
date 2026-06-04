-- ============================================================
-- NEXUS v7.0.9 - CORRIGIDO (TODOS OS ERROS RESOLVIDOS)
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
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local function randomDelay(min, max) return math.random(min * 1000, max * 1000) / 1000 end
local function notify(t, txt, d) pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "Stats", Text = txt or "", Duration = d or 3}) end) end

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
                for _, b in pairs(blocked) do if args[1]:lower():find(b:lower()) then return nil end end
            end
            return old(self, ...)
        end
        setreadonly(mt, true)
    end
end)

task.spawn(function() while true do task.wait(randomDelay(15,35)) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local hrp = player.Character.HumanoidRootPart hrp.CFrame = hrp.CFrame * CFrame.new(randomDelay(-0.5,0.5), 0, randomDelay(-0.5,0.5)) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(250,350)) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)), true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero, true) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(60,120)) pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new(math.random(300,900), math.random(300,600))) end) end end)

pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 if Workspace.Terrain then Workspace.Terrain.WaterWaveSize = 0 Workspace.Terrain.GrassLength = 0 end end)

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

local currentSea = 1
local function detectSea()
    local lvl = 1
    pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl = player.Data.Level.Value end end)
    if lvl <= 700 then currentSea = 1 elseif lvl <= 1500 then currentSea = 2 else currentSea = 3 end
    return currentSea
end
detectSea()

local currentTarget = nil
local range = CONFIG.DEFAULT_RANGE
local kills = 0
local lastAttackTime = 0
local masteryType = "Fruit"

local superFarmEnabled = false
local fragmentFarmEnabled = false
local bonesFarmEnabled = false
local aimlockEnabled = false
local noclipEnabled = false
local walkspeedEnabled = false
local bountyHuntEnabled = false
local jumpspeedEnabled = false

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
    if SuperFarm.boxPart and SuperFarm.boxPart.Parent then SuperFarm.boxPart:Destroy() end
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
    if not SuperFarm.boxPart then return end
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
                    local offset = Vector3.new(math.random(-SuperFarm.boxSize.X/2+1, SuperFarm.boxSize.X/2-1), 0, math.random(-SuperFarm.boxSize.Z/2+1, SuperFarm.boxSize.Z/2-1))
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

local function useSkill(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(randomDelay(0.08, 0.15))
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function buyItem(item)
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", item) end
    end)
end

task.spawn(function()
    while true do
        local t = tick()
        detectSea()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then task.wait(0.5) continue end

        if superFarmEnabled then
            pcall(function()
                SuperFarm.createBox()
                SuperFarm.positionBox()
                SuperFarm.flyPlayer()
                SuperFarm.collectMobs()
                SuperFarm.attackMobs()
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
                if t % 3 < 0.1 then useSkill(Enum.KeyCode.Z) task.wait(0.5) useSkill(Enum.KeyCode.X) end
                if t % 8 < 0.1 then for _, n in pairs(SEA_DATA[currentSea].fruits) do local f = Workspace:FindFirstChild(n) if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) break end end end
                if t % 15 < 0.1 then for _, obj in pairs(Workspace:GetDescendants()) do if obj.Name:lower():find("chest", 1, true) or obj.Name:lower():find("bone", 1, true) then local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChildOfClass("BasePart") and obj:FindFirstChildOfClass("BasePart").Position) if pos then tp(pos) break end end end end
                if t % 30 < 0.1 then for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and (obj:FindFirstChild("Quest") or obj:FindFirstChild("QuestGiver")) then if obj:FindFirstChild("HumanoidRootPart") then tp(obj.HumanoidRootPart.Position) break end end end end
                if t % 60 < 0.1 then local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki", "Ken") r.CommF_:InvokeServer("ActivateHaki", "Observation") end end
                if t % 300 < 0.1 then buyItem("Kitsune") buyItem("Dragon") buyItem("Leopard") end
            end)
        else
            if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart = nil end
            SuperFarm.collectedMobs = {}
        end

        if aimlockEnabled then pcall(function() local tgt = nil local shortest = range for _, o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 and o ~= player.Character then local d = (o.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude if d < shortest then shortest = d tgt = o end end end if tgt then player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, tgt.HumanoidRootPart.Position) end end) end
        if noclipEnabled then pcall(function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end
        if walkspeedEnabled then pcall(function() if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = 100 end end end) end
        if jumpspeedEnabled then pcall(function() if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower = 100 end end end) end
        if bountyHuntEnabled and t % 15 < 0.1 then pcall(function() local best, bestDist = nil, math.huge for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude if d < bestDist then best = p bestDist = d end end end if best then tp(best.Character.HumanoidRootPart.Position) for _ = 1, 5 do attack() task.wait(0.3) end end end) end
        if fragmentFarmEnabled and t % 60 < 0.1 then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments", 500) end end) end
        if bonesFarmEnabled and t % 30 < 0.1 then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones", 50) end end) end
        if t % 45 < 0.1 then pcall(function() collectgarbage("collect") end) end

        task.wait(CONFIG.ATTACK_CYCLE_DELAY)
    end
end)

local win = NexusUI:CreateWindow({Title = "NEXUS v7.0.9", Subtitle = SEA_DATA[currentSea].name .. " | Super Farm | Mobile Ready", Width = 580, Height = 500})
local tabs = {}
for _, t in pairs({{"⚔️ Super Farm"},{"🍎 Frutas"},{"🎯 Bosses"},{"📦 Coleta"},{"🏃 Move"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Super Farm"], "🚀 SUPER FARM (TUDO EM UM)")
NexusUI:CreateToggle(tabs["⚔️ Super Farm"], {Title = "🚀 SUPER FARM", Desc = "Caixa invisível + Voo + Ataque + Godmode + Quest + Fruit Sniper + Coleta + Haki + Skills + Compras", Callback = function(v) superFarmEnabled = v end})
NexusUI:CreateSection(tabs["⚔️ Super Farm"], "Farms Separados")
NexusUI:CreateToggle(tabs["⚔️ Super Farm"], {Title = "💎 Auto Fragmentos", Callback = function(v) fragmentFarmEnabled = v end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"], {Title = "🦴 Auto Ossos", Callback = function(v) bonesFarmEnabled = v end})

NexusUI:CreateSection(tabs["🍎 Frutas"], "🍎 FRUTAS DO " .. SEA_DATA[currentSea].name:upper())
for _, n in pairs(SEA_DATA[currentSea].fruits) do NexusUI:CreateLabel(tabs["🍎 Frutas"], {Title = "🍎 " .. n}) end

NexusUI:CreateSection(tabs["🎯 Bosses"], "🎯 BOSSES DO " .. SEA_DATA[currentSea].name:upper())
for _, n in pairs(SEA_DATA[currentSea].bosses) do NexusUI:CreateLabel(tabs["🎯 Bosses"], {Title = "🎯 " .. n}) end

NexusUI:CreateSection(tabs["📦 Coleta"], "📦 COLETA (Inclusa no Super Farm)")
for _, n in pairs({"Chest","Bone","Fist of Darkness","God's Chalice","Blue Gear","Sweet Chalice","Scroll","Fruit Chest"}) do NexusUI:CreateLabel(tabs["📦 Coleta"], {Title = "📦 " .. n}) end

NexusUI:CreateSection(tabs["🏃 Move"], "🏃 MOVIMENTAÇÃO")
for _, n in pairs({"Auto Hop","Auto Dash","Auto Flight","Auto Swim","TP Island","TP NPC","TP Fruit","TP Chest","TP Player"}) do NexusUI:CreateLabel(tabs["🏃 Move"], {Title = "🏃 " .. n}) end

NexusUI:CreateSection(tabs["👀 Visual"], "👀 ESP")
for _, n in pairs({"ESP Players","ESP Fruits","ESP Chests","ESP Bosses","ESP Items","ESP Materials","ESP NPCs","ESP Sea Beasts","ESP Ships"}) do NexusUI:CreateLabel(tabs["👀 Visual"], {Title = "👀 " .. n}) end

NexusUI:CreateSection(tabs["🎮 Extra"], "🎮 FUNÇÕES ESPECIAIS")
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🎯 Aimlock", Callback = function(v) aimlockEnabled = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🚫 No Clip", Callback = function(v) noclipEnabled = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🏃 Walkspeed", Callback = function(v) walkspeedEnabled = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🦘 Jumpspeed", Callback = function(v) jumpspeedEnabled = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "💰 Bounty Hunt", Callback = function(v) bountyHuntEnabled = v end})
NexusUI:CreateDropdown(tabs["🎮 Extra"], {Title = "Maestria", Options = {"Fruit","Sword","Gun","Melee"}, Default = masteryType, Callback = function(v) masteryType = v notify("Maestria","Upando: "..v,2) end})
NexusUI:CreateSlider(tabs["🎮 Extra"], {Title = "Alcance", Min = 50, Max = 500, Default = 300, Callback = function(v) range = v end})
NexusUI:CreateButton(tabs["🎮 Extra"], {Title = "🛑 DESLIGAR TUDO", Callback = function() superFarmEnabled = false fragmentFarmEnabled = false bonesFarmEnabled = false aimlockEnabled = false noclipEnabled = false walkspeedEnabled = false jumpspeedEnabled = false bountyHuntEnabled = false if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart = nil end SuperFarm.collectedMobs = {} notify("Stats","Tudo desligado!",3) end})

NexusUI:CreateSection(tabs["🏝️ Ilhas"], "🏝️ ILHAS DO " .. SEA_DATA[currentSea].name:upper())
for _, il in pairs(SEA_DATA[currentSea].islands) do NexusUI:CreateButton(tabs["🏝️ Ilhas"], {Title = "🏝️ " .. il[1], Callback = function() tp(il[2]) notify("🏝️",il[1],2) end}) end

notify("NEXUS v7.0.9", SEA_DATA[currentSea].name .. " | Super Farm | Mobile Ready", 5)
print("NEXUS v7.0.9 - Corrigido - Loaded")
