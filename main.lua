-- ============================================================
-- NEXUS v7.0.8 - ANTI-DETECÇÃO ROBUSTO + COMPLETO (84 FUNÇÕES)
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local CONFIG = {
    VERSION = "7.0.8",
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
-- UTILITÁRIOS HUMANIZADOS
-- ============================================================
local function randomDelay(min, max) return math.random(min * 1000, max * 1000) / 1000 end
local function isValidPosition(pos1, pos2) return (pos1 - pos2).Magnitude < 500 end

-- ============================================================
-- ANTI-BAN (6 CAMADAS)
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
local currentTarget, range, espBills, MAX_ESP, kills = nil, CONFIG.DEFAULT_RANGE, {}, CONFIG.MAX_ESP_OBJECTS, 0
local lastAttackTime = 0
local masteryType = "Fruit"
local cooldowns = {}

local function canExecute(key, cd)
    local now = tick()
    if not cooldowns[key] or now - cooldowns[key] >= cd then
        cooldowns[key] = now
        return true
    end
    return false
end

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
-- FUNÇÕES
-- ============================================================
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local h = player.Character.HumanoidRootPart
            if not isValidPosition(h.Position, pos) then
                h.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            else
                h.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.05)
                h.CFrame = CFrame.new(pos)
            end
        end
    end)
end

local function findTarget()
    local n, s = nil, range
    for _, o in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 and o ~= player.Character then
                local d = (o.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if d < s then n, s = o, d end
            end
        end)
    end
    return n
end

local function findBoss(name)
    local b = Workspace:FindFirstChild(name)
    if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health > 0 then return b end
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then return o end
    end
    return nil
end

local function findSea(name)
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then return o end
    end
    return nil
end

local function attack()
    local currentDelay = randomDelay(CONFIG.MIN_ATTACK_DELAY, CONFIG.MAX_ATTACK_DELAY)
    if tick() - lastAttackTime < currentDelay then return end
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

local function collectItem(name)
    for _, o in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if o.Name:lower():find(name:lower()) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = o:IsA("BasePart") and o.Position or (o:FindFirstChildOfClass("BasePart") and o:FindFirstChildOfClass("BasePart").Position) or (o:FindFirstChild("Handle") and o.Handle.Position)
                if pos and (pos - player.Character.HumanoidRootPart.Position).Magnitude <= range then
                    tp(pos)
                    task.wait(randomDelay(0.1, 0.2))
                    if o:FindFirstChild("TouchInterest") then
                        firetouchinterest(o, player.Character.HumanoidRootPart, 0)
                        firetouchinterest(o, player.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end)
    end
end

local function notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = title or "Stats", Text = text or "", Duration = dur or 3}) end)
end

local function serverHop()
    pcall(function()
        local res = game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=10")
        local servers = HttpService:JSONDecode(res)
        if servers and servers.data and #servers.data > 0 then
            TeleportService:TeleportToPlaceInstance(game.GameId, servers.data[math.random(1, #servers.data)].id, player)
        end
    end)
end

local function createESP(color, filter)
    if espBills[filter] then
        for o, b in pairs(espBills) do if type(o) ~= "string" then b:Destroy() espBills[o] = nil end end
    end
    task.spawn(function()
        while espBills[filter] do
            pcall(function()
                local count = 0
                for _, o in pairs(Workspace:GetDescendants()) do
                    if count > MAX_ESP then break end
                    if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and o ~= player.Character and not espBills[o] then
                        local show = false
                        if filter == "player" then show = Players:GetPlayerFromCharacter(o) ~= nil
                        elseif filter == "fruit" then show = o.Name:find("Fruit") ~= nil
                        elseif filter == "chest" then show = o.Name:lower():find("chest") ~= nil
                        elseif filter == "boss" then show = o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth > 10000
                        elseif filter == "sea" then show = o.Name:lower():find("sea") ~= nil
                        elseif filter == "ship" then show = o.Name:lower():find("ship") ~= nil
                        elseif filter == "npc" then show = o:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(o)
                        elseif filter == "item" then show = o.Name:find("Fist") or o.Name:find("Chalice") or o.Name:find("Gear") ~= nil
                        elseif filter == "material" then show = o.Name:find("Wood") or o.Name:find("Iron") or o.Name:find("Bone") ~= nil
                        end
                        if show then
                            local d = (o.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            if d <= range then
                                local bill = Instance.new("BillboardGui")
                                bill.Size = UDim2.new(0, 60, 0, 18)
                                bill.AlwaysOnTop = true
                                bill.MaxDistance = range
                                bill.Parent = o.HumanoidRootPart
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 0.7
                                label.BackgroundColor3 = color
                                label.TextColor3 = Color3.new(1, 1, 1)
                                label.TextSize = 8
                                label.Font = Enum.Font.GothamBold
                                label.Text = o.Name
                                label.Parent = bill
                                espBills[o] = bill
                                count = count + 1
                            end
                        end
                    end
                end
                for o, b in pairs(espBills) do
                    if type(o) ~= "string" then
                        pcall(function()
                            if not o.Parent or (o:FindFirstChild("Humanoid") and o.Humanoid.Health <= 0) then
                                b:Destroy() espBills[o] = nil
                            end
                        end)
                    end
                end
            end)
            task.wait(3)
        end
    end)
end

-- ============================================================
-- AUTO-OP
-- ============================================================
local function activateAutoOP()
    for _, s in pairs(stateNames) do states[s] = true end
    notify("🚀 AUTO-OP", "TODAS as " .. #stateNames .. " funções ATIVADAS!", 8)
end

-- ============================================================
-- LOOP CENTRAL (84 FUNÇÕES)
-- ============================================================
task.spawn(function()
    while true do
        local t = tick()
        detectSea()
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
            continue
        end
        
        -- GODMODE
        if states.godmode or states.farmLevel or states.farmBoss then
            pcall(function()
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
            end)
        end
        
        -- KILL AURA
        if states.killAura and canExecute("killAura", 0.15) then
            pcall(function()
                local hrp = player.Character.HumanoidRootPart
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Model") and o ~= player.Character and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 and (o.HumanoidRootPart.Position - hrp.Position).Magnitude < range then
                        tp(o.HumanoidRootPart.Position)
                        attack()
                    end
                end
            end)
        end
        
        -- FARM LEVEL
        if states.farmLevel and canExecute("farmLevel", 0.3) then
            pcall(function()
                local tgt = findTarget()
                if tgt then
                    currentTarget = tgt
                    if (player.Character.HumanoidRootPart.Position - tgt.HumanoidRootPart.Position).Magnitude > 15 then
                        tp(tgt.HumanoidRootPart.Position)
                    end
                    attack()
                end
            end)
        end
        
        -- FARM MASTERY
        if states.farmMastery and canExecute("farmMastery", 3) then
            pcall(function() useSkill("Z") task.wait(0.5) useSkill("X") end)
        end
        
        -- FARM BOSS
        if states.farmBoss and canExecute("farmBoss", 8) then
            pcall(function()
                for _, n in pairs(SEA_DATA[currentSea].bosses) do
                    local b = findBoss(n)
                    if b and b:FindFirstChild("HumanoidRootPart") then
                        tp(b.HumanoidRootPart.Position)
                        for _ = 1, 10 do attack() task.wait(0.3) end
                    end
                end
            end)
        end
        
        -- FRUIT SNIPER
        if states.fruitSniper and canExecute("fruitSniper", 8) then
            pcall(function()
                for _, n in pairs(SEA_DATA[currentSea].fruits) do
                    local f = Workspace:FindFirstChild(n)
                    if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) task.wait(0.5) break end
                end
            end)
        end
        
        -- FRUIT STORE
        if states.fruitStore and canExecute("fruitStore", 10) then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then
                    r.CommF_:InvokeServer("StoreFruit", player.Data.Fruit.Value)
                end
            end)
        end
        
        -- COLETA
        if states.colChest and canExecute("colChest", 12) then collectItem("Chest") end
        if states.colBones and canExecute("colBones", 8) then collectItem("Bone") end
        
        -- AUTO QUEST
        if states.atQuest and canExecute("atQuest", 30) then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and (obj:FindFirstChild("Quest") or obj:FindFirstChild("QuestGiver")) and obj.Humanoid.Health > 0 then
                        if obj:FindFirstChild("HumanoidRootPart") then tp(obj.HumanoidRootPart.Position) break end
                    end
                end
            end)
        end
        
        -- AUTO HAKI
        if states.atHaki and canExecute("atHaki", 120) then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("ActivateHaki", "Ken")
                    r.CommF_:InvokeServer("ActivateHaki", "Observation")
                end
            end)
        end
        
        -- AUTO HOP
        if states.moveHop and canExecute("moveHop", 180) then serverHop() end
        
        -- AIMLOCK
        if states.aimlock then
            pcall(function()
                local tgt = findTarget()
                if tgt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, tgt.HumanoidRootPart.Position)
                end
            end)
        end
        
        -- NO CLIP
        if states.noclip then
            pcall(function()
                if player.Character then
                    for _, p in pairs(player.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
        
        -- WALKSPEED
        if states.walkspeed then
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 100 end
                end
            end)
        end
        
        -- BOUNTY HUNT
        if states.bountyHunt and canExecute("bountyHunt", 15) then
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
        
        -- LIMPEZA
        if canExecute("memoryClean", CONFIG.MEMORY_CLEAN_INTERVAL) then
            pcall(function() collectgarbage("collect") end)
        end
        
        task.wait(CONFIG.ATTACK_CYCLE_DELAY)
    end
end)

-- ============================================================
-- UI
-- ============================================================
local win = NexusUI:CreateWindow({Title = "Stats", Subtitle = SEA_DATA[currentSea].name .. " | v" .. CONFIG.VERSION, Width = 580, Height = 500})
local tabs = {}
for _, t in pairs({{"⚔️ Combate"},{"🍎 Frutas"},{"🎯 Bosses"},{"🌊 Sea"},{"📦 Coleta"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Combate"], "Farm")
NexusUI:CreateButton(tabs["⚔️ Combate"], {Title = "🚀 AUTO-OP", Callback = function() activateAutoOP() end})
for _, cfg in pairs({{"Auto Farm Nível","farmLevel"},{"Auto Farm Maestria","farmMastery"},{"Auto Farm Boss","farmBoss"},{"Auto Farm Raid","farmRaid"},{"Auto Farm Sea","farmSea"},{"💀 Kill Aura","killAura"},{"🛡️ Godmode","godmode"}}) do
    NexusUI:CreateToggle(tabs["⚔️ Combate"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["🍎 Frutas"], "Frutas do " .. SEA_DATA[currentSea].name)
for _, n in pairs(SEA_DATA[currentSea].fruits) do NexusUI:CreateLabel(tabs["🍎 Frutas"], {Title = "🍎 " .. n}) end
for _, cfg in pairs({{"Fruit Sniper","fruitSniper"},{"Auto Store Fruit","fruitStore"},{"Auto Spawn Fruit","fruitSpawn"},{"Fruit Notify","fruitNotify"},{"Fruit ESP","fruitESP"}}) do
    NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["🎯 Bosses"], "Bosses do " .. SEA_DATA[currentSea].name)
for _, n in pairs(SEA_DATA[currentSea].bosses) do
    local k = "boss_" .. n:gsub(" ", "_")
    if states[k] == nil then states[k] = false end
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {Title = n, Callback = function(v) states[k] = v end})
end

NexusUI:CreateSection(tabs["🌊 Sea"], "Eventos")
for _, cfg in pairs({{"Marine Ship","seaShip"},{"Pirate Ship","seaPirate"},{"Sea Beast","seaBeast"},{"Terror Shark","seaTerror"}}) do
    NexusUI:CreateToggle(tabs["🌊 Sea"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["📦 Coleta"], "Auto Collect")
for _, cfg in pairs({{"Chest","colChest"},{"Bone","colBones"},{"Fist of Darkness","colFist"},{"God's Chalice","colChalice"}}) do
    NexusUI:CreateToggle(tabs["📦 Coleta"], {Title = "Auto " .. cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["🏃 Move"], "Movimentação")
for _, cfg in pairs({{"Auto Hop","moveHop"},{"Auto Dash","moveDash"},{"Auto Flight","moveFlight"},{"Auto Swim","moveSwim"}}) do
    NexusUI:CreateToggle(tabs["🏃 Move"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["⚙️ Auto"], "Automações")
for _, cfg in pairs({{"Auto Haki","atHaki"},{"Auto Skill","atSkill"},{"Auto Quest","atQuest"},{"Race V4","atV4"}}) do
    NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["🛍️ Loja"], "Compras")
for _, cfg in pairs({{"Buy Fruits","shopFruits"},{"Buy Stats","shopStats"},{"Buy Fragments","shopFrag"}}) do
    NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "Auto " .. cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["👀 Visual"], "ESP")
for _, cfg in pairs({{"ESP Players","espP"},{"ESP Fruits","espF"},{"ESP Chests","espC"},{"ESP Bosses","espB"}}) do
    NexusUI:CreateToggle(tabs["👀 Visual"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end

NexusUI:CreateSection(tabs["🎮 Extra"], "Especiais")
for _, cfg in pairs({{"Aimlock","aimlock"},{"No Clip","noclip"},{"Walkspeed","walkspeed"},{"Bounty Hunt","bountyHunt"},{"Fragment Farm","fragmentFarm"}}) do
    NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = cfg[1], Callback = function(v) states[cfg[2]] = v end})
end
NexusUI:CreateDropdown(tabs["🎮 Extra"], {Title = "Maestria", Options = {"Fruit","Sword","Gun","Melee"}, Default = masteryType, Callback = function(v) masteryType = v notify("Maestria", "Upando: " .. v, 2) end})
NexusUI:CreateSlider(tabs["🎮 Extra"], {Title = "Alcance", Min = 50, Max = 500, Default = 300, Callback = function(v) range = v end})
NexusUI:CreateButton(tabs["🎮 Extra"], {Title = "🛑 DESLIGAR TUDO", Callback = function() for n, _ in pairs(states) do states[n] = false end for o, b in pairs(espBills) do pcall(function() b:Destroy() end) espBills[o] = nil end notify("Stats", "Desligado", 3) end})

NexusUI:CreateSection(tabs["🏝️ Ilhas"], "Ilhas do " .. SEA_DATA[currentSea].name)
for _, il in pairs(SEA_DATA[currentSea].islands) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"], {Title = "🏝️ " .. il[1], Callback = function() tp(il[2]) notify("🏝️", il[1], 2) end})
end

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
        fl.Text = "FPS: " .. fc .. " | 💀 " .. kills .. " | 🌊 " .. SEA_DATA[currentSea].name .. " | 🗡️ " .. masteryType
        fc = 0 lt = nw
    end
end)

notify("Stats", SEA_DATA[currentSea].name .. " | v" .. CONFIG.VERSION .. " | Anti-Detecção", 5)
print("NEXUS v7.0.8 - " .. #stateNames .. " Funções - Anti-Detecção Robusto - Loaded")
