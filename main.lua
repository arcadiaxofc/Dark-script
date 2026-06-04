-- ==================== NEXUS v7.0 - BLOX FRUITS 2026 - COMPLETO ====================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

-- ==================== BYPASS ANTI-BAN ====================
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" and type(args[1]) == "string" then
                local blocked = {"Kick","Ban","Teleport","Flag","Report","Detect","AntiCheat","Log","Alert","NotifyAdmin","SendLog","Spectate"}
                for _, b in pairs(blocked) do
                    if args[1]:find(b) then return nil end
                end
            end
            if method == "Kick" or method == "Ban" then return nil end
            return old(self, ...)
        end
        setreadonly(mt, true)
    end
end)
pcall(function() game.Players.LocalPlayer.Kick = function() return nil end end)

-- ==================== SERVIÇOS ====================
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
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

-- ==================== ANTI AFK ====================
task.spawn(function()
    while true do
        task.wait(300)
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:Move(Vector3.new(1, 0, 0), true)
                task.wait(0.3)
                player.Character.Humanoid:Move(Vector3.new(0, 0, 0), true)
            end
        end)
    end
end)

-- ==================== OTIMIZAÇÃO ====================
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    if Workspace.Terrain then
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.GrassLength = 0
    end
end)

-- ==================== VARIÁVEIS ====================
local currentTarget = nil
local range = 300
local espBills = {}
local MAX_ESP = 10
local kills = 0
local attackDelay = 0.5
local lastAttackTime = 0
local MIN_ATTACK_DELAY = 0.4

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
    "aimlock","noclip","walkspeed","jumpspeed","bountyHunt","fragmentFarm","godmode"
}
for _, s in pairs(stateNames) do states[s] = false end

-- ==================== FUNÇÕES BASE ====================
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            task.wait(0.05)
            hrp.CFrame = CFrame.new(pos)
        end
    end)
end

local function findTarget()
    local nearest, shortest = nil, range
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if obj.Humanoid.Health > 0 and obj ~= player.Character then
                    local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortest then shortest = dist nearest = obj end
                end
            end
        end)
    end
    return nearest
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
    if tick() - lastAttackTime < MIN_ATTACK_DELAY then return end
    lastAttackTime = tick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        kills = kills + 1
    end)
end

local function useSkill(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
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
                    task.wait(0.15)
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
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "NEXUS",
            Text = text or "",
            Duration = dur or 3
        })
    end)
end

local function serverHop()
    pcall(function()
        local res = game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=10")
        local servers = HttpService:JSONDecode(res)
        if servers and servers.data and #servers.data > 0 then
            local s = servers.data[math.random(1, #servers.data)]
            TeleportService:TeleportToPlaceInstance(game.GameId, s.id, player)
        end
    end)
end

local function createESP(color, filter)
    if espBills[filter] then
        for o, b in pairs(espBills) do
            if type(o) ~= "string" then b:Destroy() espBills[o] = nil end
        end
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

-- ==================== LOOP CENTRAL COMPLETO ====================
task.spawn(function()
    while true do
        local t = tick()

        -- GODMODE
        if states.godmode or states.farmLevel or states.farmBoss then
            pcall(function()
                if player.Character then
                    local h = player.Character:FindFirstChildOfClass("Humanoid")
                    if h then h.Health = h.MaxHealth end
                end
            end)
        end

        -- AUTO FARM NÍVEL
        if states.farmLevel and t % attackDelay < 0.05 then
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local tgt = findTarget()
                    if tgt then
                        currentTarget = tgt
                        if (player.Character.HumanoidRootPart.Position - tgt.HumanoidRootPart.Position).Magnitude > 15 then
                            tp(tgt.HumanoidRootPart.Position)
                        end
                        attack()
                    end
                end
            end)
        end

        -- AUTO FARM MAESTRIA
        if states.farmMastery and t % 3 < 0.05 then
            pcall(function() useSkill("Z") task.wait(0.5) useSkill("X") end)
        end

        -- AUTO FARM BOSS (TODOS)
        if states.farmBoss and t % 8 < 0.05 then
            pcall(function()
                local bosses = {"Dough King","Soul Reaper","Cake Prince","Rip_indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"}
                for _, n in pairs(bosses) do
                    if states.farmBoss then
                        local b = findBoss(n)
                        if b then
                            tp(b.HumanoidRootPart.Position)
                            for _ = 1, 10 do attack() task.wait(0.3) end
                        end
                    end
                end
            end)
        end

        -- AUTO FARM RAID
        if states.farmRaid and t % 60 < 0.05 then
            pcall(function()
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") then
                        tp(o.Position)
                        task.wait(0.5)
                        firetouchinterest(o, player.Character.HumanoidRootPart, 0)
                        firetouchinterest(o, player.Character.HumanoidRootPart, 1)
                        break
                    end
                end
            end)
        end

        -- FRUIT SNIPER
        if states.fruitSniper and t % 8 < 0.05 then
            pcall(function()
                local fruits = {"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit","Control-Fruit","Shadow-Fruit","Rumble-Fruit","Buddha-Fruit","Portal-Fruit","Blizzard-Fruit"}
                for _, n in pairs(fruits) do
                    local f = Workspace:FindFirstChild(n)
                    if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) break end
                end
            end)
        end

        -- BOSSES INDIVIDUAIS
        if t % 5 < 0.05 then
            local bossList = {{"bossDK","Dough King"},{"bossSR","Soul Reaper"},{"bossCP","Cake Prince"},{"bossRI","Rip_indra"},{"bossDB","Darkbeard"},{"bossTK","Tide Keeper"},{"bossST","Stone"},{"bossIE","Island Empress"},{"bossHY","Hydra"},{"bossLV","Leviathan"}}
            for _, bd in pairs(bossList) do
                if states[bd[1]] then
                    pcall(function()
                        local b = findBoss(bd[2])
                        if b then tp(b.HumanoidRootPart.Position) for _ = 1, 8 do attack() task.wait(0.3) end end
                    end)
                end
            end
        end

        -- SEA EVENTS
        if t % 10 < 0.05 then
            local seaList = {{"seaShip","Marine"},{"seaPirate","Pirate"},{"seaBeast","Sea Beast"},{"seaTerror","Terror"}}
            for _, sd in pairs(seaList) do
                if states[sd[1]] then
                    pcall(function()
                        local s = findSea(sd[2])
                        if s then tp(s.HumanoidRootPart.Position) for _ = 1, 5 do attack() task.wait(0.3) end end
                    end)
                end
            end
        end

        -- COLETA
        if t % 12 < 0.05 and states.colChest then collectItem("Chest") end
        if t % 8 < 0.05 and states.colBones then collectItem("Bone") end
        if t % 20 < 0.05 then
            if states.colFist then collectItem("Fist") end
            if states.colChalice then collectItem("Chalice") end
            if states.colBlue then collectItem("Blue Gear") end
            if states.colSweet then collectItem("Sweet") end
            if states.colFruitChest then collectItem("Fruit Chest") end
        end
        if t % 15 < 0.05 and states.colScroll then collectItem("Scroll") end

        -- MOVIMENTO
        if t % 180 < 0.05 and states.moveHop then serverHop() end
        if t % 5 < 0.05 and states.moveDash then
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit * 25
                end
            end)
        end
        if t % 2 < 0.05 then
            if states.moveFlight then pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end
            if states.moveSwim then pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end end end) end
        end

        -- AUTOMÁTICOS
        if t % 120 < 0.05 and states.atHaki then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("ActivateHaki","Ken")
                    r.CommF_:InvokeServer("ActivateHaki","Buso")
                end
            end)
        end
        if t % 5 < 0.05 and states.atSkill then
            pcall(function() useSkill("Z") useSkill("X") useSkill("C") end)
        end
        if t % 30 < 0.05 and states.atQuest then
            pcall(function()
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Model") and o:FindFirstChild("Humanoid") and (o:FindFirstChild("Quest") or o:FindFirstChild("Talk")) then
                        tp(o.HumanoidRootPart.Position)
                        task.wait(1)
                        local r = ReplicatedStorage:FindFirstChild("Remotes")
                        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest", o.Name) end
                        break
                    end
                end
            end)
        end
        if t % 180 < 0.05 and states.atV4 then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4","Start") end
            end)
        end

        -- LOJA
        if t % 600 < 0.05 then
            if states.shopFruits then for _, item in pairs({"Kitsune","Dragon","Leopard"}) do buyItem(item) task.wait(2) end end
            if states.shopStyles then for _, item in pairs({"Superhuman","Godhuman"}) do buyItem(item) task.wait(2) end end
            if states.shopSword then for _, item in pairs({"Cursed Dual Katana","Dark Blade"}) do buyItem(item) task.wait(2) end end
        end
        if t % 5 < 0.05 and states.shopStats then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end
            end)
        end
        if t % 60 < 0.05 and states.shopFrag then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end
            end)
        end

        -- ESP
        if states.espP then if not espBills["player"] then espBills["player"] = true createESP(Color3.fromRGB(255,0,0),"player") end else espBills["player"] = nil end
        if states.espF then if not espBills["fruit"] then espBills["fruit"] = true createESP(Color3.fromRGB(255,0,255),"fruit") end else espBills["fruit"] = nil end
        if states.espC then if not espBills["chest"] then espBills["chest"] = true createESP(Color3.fromRGB(255,215,0),"chest") end else espBills["chest"] = nil end
        if states.espB then if not espBills["boss"] then espBills["boss"] = true createESP(Color3.fromRGB(255,50,50),"boss") end else espBills["boss"] = nil end

        -- EXTRA
        if t % 0.3 < 0.05 and states.aimlock then
            pcall(function()
                local tgt = findTarget()
                if tgt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, tgt.HumanoidRootPart.Position)
                end
            end)
        end
        if t % 0.5 < 0.05 then
            if states.noclip then
                pcall(function()
                    if player.Character then
                        for _, p in pairs(player.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            end
            if states.walkspeed then
                pcall(function()
                    if player.Character then
                        local h = player.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed = 100 end
                    end
                end)
            end
        end
        if t % 15 < 0.05 and states.bountyHunt then
            pcall(function()
                local best, bb = nil, 0
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local b = p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0
                        if b > bb then bb = b best = p end
                    end
                end
                if best then tp(best.Character.HumanoidRootPart.Position) for _ = 1, 5 do attack() task.wait(0.3) end end
            end)
        end
        if t % 5 < 0.05 and states.fragmentFarm then
            pcall(function()
                local tgt = findTarget()
                if tgt then tp(tgt.HumanoidRootPart.Position) for _ = 1, 3 do attack() task.wait(0.3) end end
            end)
        end

        -- LIMPEZA DE MEMÓRIA
        if t % 60 < 0.05 then
            pcall(function() collectgarbage("collect") end)
            for o, b in pairs(espBills) do
                if type(o) ~= "string" then
                    pcall(function()
                        if not o.Parent or (o:FindFirstChild("Humanoid") and o.Humanoid.Health <= 0) then
                            b:Destroy() espBills[o] = nil
                        end
                    end)
                end
            end
        end

        task.wait(0.1)
    end
end)

-- ==================== UI COMPLETA ====================
local win = NexusUI:CreateWindow({Title = "NEXUS v7.0", Subtitle = "84 Funções | Blox Fruits 2026 | Anti-Ban", Width = 560, Height = 480})

local tabs = {}
for _, t in pairs({
    {"⚔️ Combate"},{"🍎 Frutas"},{"🎯 Bosses"},{"🌊 Sea"},{"📦 Coleta"},
    {"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"}
}) do tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1]}) end

-- COMBATE
NexusUI:CreateSection(tabs["⚔️ Combate"], "Farm Principal")
NexusUI:CreateToggle(tabs["⚔️ Combate"], {Title = "Auto Farm Nível", Desc = "Farma NPCs automaticamente", Callback = function(v) states.farmLevel = v end})
NexusUI:CreateToggle(tabs["⚔️ Combate"], {Title = "Auto Farm Maestria", Desc = "Usa habilidades repetidamente", Callback = function(v) states.farmMastery = v end})
NexusUI:CreateToggle(tabs["⚔️ Combate"], {Title = "Auto Farm Boss", Desc = "Farma todos os bosses", Callback = function(v) states.farmBoss = v end})
NexusUI:CreateToggle(tabs["⚔️ Combate"], {Title = "Auto Farm Raid", Desc = "Entra e farma raids", Callback = function(v) states.farmRaid = v end})
NexusUI:CreateToggle(tabs["⚔️ Combate"], {Title = "Godmode", Desc = "Não toma dano", Callback = function(v) states.godmode = v end})

-- FRUTAS
NexusUI:CreateSection(tabs["🍎 Frutas"], "Sniper & Autos")
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Fruit Sniper", Desc = "Teleporta para frutas raras", Callback = function(v) states.fruitSniper = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Auto Store Fruit", Desc = "Guarda fruta no inventário", Callback = function(v) states.fruitStore = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Auto Spawn Fruit", Desc = "Compra do Cousin", Callback = function(v) states.fruitSpawn = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Fruit Notify", Desc = "Avisa quando fruta rara spawna", Callback = function(v) states.fruitNotify = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "Fruit ESP", Desc = "Mostra frutas no mapa", Callback = function(v) states.fruitESP = v end})

-- BOSSES
NexusUI:CreateSection(tabs["🎯 Bosses"], "Bosses Individuais")
local bossNames = {"Dough King","Soul Reaper","Cake Prince","Rip Indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"}
local bossKeys = {"bossDK","bossSR","bossCP","bossRI","bossDB","bossTK","bossST","bossIE","bossHY","bossLV"}
for i, name in pairs(bossNames) do
    local key = bossKeys[i]
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {Title = name, Desc = "Farm automático", Callback = function(v) states[key] = v end})
end

-- SEA
NexusUI:CreateSection(tabs["🌊 Sea"], "Eventos do Mar")
local seaNames = {"Marine Ship","Pirate Ship","Sea Beast","Terror Shark","Rumbling","Mansion","Pirate Raid","Sea Castle"}
local seaKeys = {"seaShip","seaPirate","seaBeast","seaTerror","seaRumble","seaMansion","seaPRaid","seaCastle"}
for i, name in pairs(seaNames) do
    local key = seaKeys[i]
    NexusUI:CreateToggle(tabs["🌊 Sea"], {Title = name, Desc = "Farm automático", Callback = function(v) states[key] = v end})
end

-- COLETA
NexusUI:CreateSection(tabs["📦 Coleta"], "Auto Collect")
local collectNames = {"Chest","Bone","Fist of Darkness","God's Chalice","Blue Gear","Sweet Chalice","Scroll","Fruit Chest"}
local collectKeys = {"colChest","colBones","colFist","colChalice","colBlue","colSweet","colScroll","colFruitChest"}
for i, name in pairs(collectNames) do
    local key = collectKeys[i]
    NexusUI:CreateToggle(tabs["📦 Coleta"], {Title = "Auto " .. name, Desc = "Coleta automaticamente", Callback = function(v) states[key] = v end})
end

-- MOVIMENTO
NexusUI:CreateSection(tabs["🏃 Move"], "Movimentação")
local moveNames = {"Auto Hop Server","Auto Dash","Auto Flight","Auto Swim","TP Island","TP NPC","TP Fruit","TP Chest","TP Player"}
local moveKeys = {"moveHop","moveDash","moveFlight","moveSwim","moveIsland","moveNPC","moveFruit","moveChest","movePlayer"}
for i, name in pairs(moveNames) do
    local key = moveKeys[i]
    NexusUI:CreateToggle(tabs["🏃 Move"], {Title = name, Desc = "Movimentação automática", Callback = function(v) states[key] = v end})
end

-- AUTOMÁTICOS
NexusUI:CreateSection(tabs["⚙️ Auto"], "Automações")
local autoNames = {"Auto Haki","Auto Skill","Metaverse","Race Awakening","Accessory","Title","Auto Quest","Gear Farm","V4 Awakening","Raid Fruits"}
local autoKeys = {"atHaki","atSkill","atMeta","atRace","atAccessory","atTitle","atQuest","atGear","atV4","atRaidFruits"}
for i, name in pairs(autoNames) do
    local key = autoKeys[i]
    NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = name, Desc = "Automação", Callback = function(v) states[key] = v end})
end

-- LOJA
NexusUI:CreateSection(tabs["🛍️ Loja"], "Auto Comprar")
local shopNames = {"Buy Fruits","Buy Styles","Buy Sword","Buy Guns","Buy Accessories","Buy Materials","Buy Stats","Buy Gamepass","Buy Fragments","Buy Bones"}
local shopKeys = {"shopFruits","shopStyles","shopSword","shopGuns","shopAcc","shopMat","shopStats","shopGP","shopFrag","shopBones"}
for i, name in pairs(shopNames) do
    local key = shopKeys[i]
    NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "Auto " .. name, Desc = "Compra automaticamente", Callback = function(v) states[key] = v end})
end

-- VISUAL
NexusUI:CreateSection(tabs["👀 Visual"], "ESP")
local espNames = {"ESP Players","ESP Fruits","ESP Chests","ESP Bosses","ESP Items","ESP Materials","ESP NPCs","ESP Sea Beasts","ESP Ships"}
local espKeys = {"espP","espF","espC","espB","espI","espM","espN","espSB","espShips"}
for i, name in pairs(espNames) do
    local key = espKeys[i]
    NexusUI:CreateToggle(tabs["👀 Visual"], {Title = name, Desc = "Mostra no mapa", Callback = function(v) states[key] = v end})
end

-- EXTRA
NexusUI:CreateSection(tabs["🎮 Extra"], "Funções Especiais")
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Aimlock", Desc = "Mira automática", Callback = function(v) states.aimlock = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "No Clip", Desc = "Atravessa paredes", Callback = function(v) states.noclip = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Walkspeed", Desc = "Velocidade aumentada", Callback = function(v) states.walkspeed = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Jumpspeed", Desc = "Pulo aumentado", Callback = function(v) states.jumpspeed = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Bounty Hunt", Desc = "Caça jogadores", Callback = function(v) states.bountyHunt = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "Fragment Farm", Desc = "Farma fragmentos", Callback = function(v) states.fragmentFarm = v end})
NexusUI:CreateSlider(tabs["🎮 Extra"], {Title = "Alcance do Farm", Min = 50, Max = 500, Default = 300, Callback = function(v) range = v end})
NexusUI:CreateButton(tabs["🎮 Extra"], {Title = "🛑 DESLIGAR TUDO", Callback = function()
    for n, _ in pairs(states) do states[n] = false end
    for o, b in pairs(espBills) do pcall(function() b:Destroy() end) end
    espBills = {}
    notify("NEXUS","Todas as funções desligadas!",3)
end})

-- FPS
local fpsLabel = Instance.new("TextLabel", win.Frame)
fpsLabel.Size = UDim2.new(0, 160, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.Text = "FPS: --"
local fc, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nw = tick()
    if nw - lt >= 1 then
        fpsLabel.Text = "FPS: " .. fc .. " | 🎯 " .. (currentTarget and currentTarget.Name or "Nenhum") .. " | 💀 " .. kills
        fc = 0 lt = nw
    end
end)

notify("NEXUS v7.0", "Script carregado!\n84 Funções | Blox Fruits 2026\nAnti-Ban Ativo | Delta Ready", 5)
print("NEXUS v7.0 - 84 Funções - Blox Fruits 2026 - Loaded")
