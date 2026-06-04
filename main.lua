-- ==================== NEXUS v7.0 - MAIN SCRIPT ====================
-- Carrega a biblioteca UI
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

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
local currentTarget, range, espBills, MAX_ESP, kills = nil, 300, {}, 10, 0
local attackDelay = 0.5
local sessionStart = tick()

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
    "aimlock","noclip","walkspeed","jumpspeed","bountyHunt","fragmentFarm"
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

local function findSea(name)
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then
            return o
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
        if r and r:FindFirstChild("CommF_") then
            r.CommF_:InvokeServer("BuyItem", item)
        end
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

-- ==================== ESP ====================
local function createESP(color, filter)
    if espBills[filter] then
        for o, b in pairs(espBills) do
            if type(o) ~= "string" then
                b:Destroy()
                espBills[o] = nil
            end
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
                                b:Destroy()
                                espBills[o] = nil
                            end
                        end)
                    end
                end
            end)
            task.wait(3)
        end
    end)
end

-- ==================== LOOP CENTRAL ====================
task.spawn(function()
    while true do
        local t = tick()
        
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
        
        if states.farmMastery and t % 3 < 0.05 then
            pcall(function()
                useSkill("Z")
                task.wait(0.5)
                useSkill("X")
            end)
        end
        
        if states.farmBoss and t % 8 < 0.05 then
            pcall(function()
                local bosses = {"Dough King","Soul Reaper","Cake Prince","Rip_indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"}
                for _, n in pairs(bosses) do
                    if states.farmBoss then
                        local b = findBoss(n)
                        if b then
                            tp(b.HumanoidRootPart.Position)
                            for _ = 1, 10 do
                                attack()
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end)
        end
        
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
        
        if states.fruitSniper and t % 8 < 0.05 then
            pcall(function()
                local fruits = {"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit","Control-Fruit","Shadow-Fruit","Rumble-Fruit","Buddha-Fruit"}
                for _, n in pairs(fruits) do
                    local f = Workspace:FindFirstChild(n)
                    if f and f:FindFirstChild("Handle") then
                        tp(f.Handle.Position)
                        break
                    end
                end
            end)
        end
        
        -- Bosses individuais
        if states.bossDK and t % 5 < 0.05 then pcall(function() local b=findBoss("Dough King") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossSR and t % 5 < 0.05 then pcall(function() local b=findBoss("Soul Reaper") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossCP and t % 5 < 0.05 then pcall(function() local b=findBoss("Cake Prince") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossRI and t % 5 < 0.05 then pcall(function() local b=findBoss("Rip_indra") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossDB and t % 5 < 0.05 then pcall(function() local b=findBoss("Darkbeard") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossTK and t % 5 < 0.05 then pcall(function() local b=findBoss("Tide Keeper") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossST and t % 5 < 0.05 then pcall(function() local b=findBoss("Stone") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossIE and t % 5 < 0.05 then pcall(function() local b=findBoss("Island Empress") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossHY and t % 5 < 0.05 then pcall(function() local b=findBoss("Hydra") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        if states.bossLV and t % 5 < 0.05 then pcall(function() local b=findBoss("Leviathan") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
        
        -- Sea Events
        if states.seaShip and t % 10 < 0.05 then pcall(function() local s=findSea("Marine") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
        if states.seaPirate and t % 10 < 0.05 then pcall(function() local s=findSea("Pirate") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
        if states.seaBeast and t % 8 < 0.05 then pcall(function() local s=findSea("Sea Beast") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
        if states.seaTerror and t % 10 < 0.05 then pcall(function() local s=findSea("Terror") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
        
        -- Coleta
        if states.colChest and t % 12 < 0.05 then collectItem("Chest") end
        if states.colBones and t % 8 < 0.05 then collectItem("Bone") end
        if states.colFist and t % 20 < 0.05 then collectItem("Fist") end
        if states.colChalice and t % 20 < 0.05 then collectItem("Chalice") end
        if states.colBlue and t % 20 < 0.05 then collectItem("Blue Gear") end
        if states.colSweet and t % 20 < 0.05 then collectItem("Sweet") end
        if states.colScroll and t % 15 < 0.05 then collectItem("Scroll") end
        if states.colFruitChest and t % 20 < 0.05 then collectItem("Fruit Chest") end
        
        -- Movimento
        if states.moveHop and t % 180 < 0.05 then serverHop() end
        if states.moveDash and t % 5 < 0.05 then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit * 25 end end) end
        if states.moveFlight and t % 2 < 0.05 then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end
        if states.moveSwim and t % 2 < 0.05 then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end end end) end
        
        -- Automáticos
        if states.atHaki and t % 120 < 0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Buso") end end) end
        if states.atSkill and t % 5 < 0.05 then pcall(function() useSkill("Z") useSkill("X") useSkill("C") end) end
        if states.atQuest and t % 30 < 0.05 then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and(o:FindFirstChild("Quest")or o:FindFirstChild("Talk")) then tp(o.HumanoidRootPart.Position) task.wait(1) local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest",o.Name) end break end end end) end
        if states.atV4 and t % 180 < 0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4","Start") end end) end
        
        -- Loja
        if states.shopFruits and t % 600 < 0.05 then for _,item in pairs({"Kitsune","Dragon","Leopard"}) do buyItem(item) task.wait(2) end end
        if states.shopStyles and t % 600 < 0.05 then for _,item in pairs({"Superhuman","Godhuman"}) do buyItem(item) task.wait(2) end end
        if states.shopSword and t % 600 < 0.05 then for _,item in pairs({"Cursed Dual Katana","Dark Blade"}) do buyItem(item) task.wait(2) end end
        if states.shopGuns and t % 600 < 0.05 then for _,item in pairs({"Soul Guitar"}) do buyItem(item) task.wait(2) end end
        if states.shopAcc and t % 600 < 0.05 then for _,item in pairs({"Pale Scarf"}) do buyItem(item) task.wait(2) end end
        if states.shopMat and t % 600 < 0.05 then for _,item in pairs({"Wood","Iron"}) do buyItem(item) task.wait(2) end end
        if states.shopStats and t % 5 < 0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) end
        if states.shopFrag and t % 60 < 0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) end
        
        -- ESP
        if states.espP then if not espBills["player"] then espBills["player"]=true createESP(Color3.fromRGB(255,0,0),"player") end else espBills["player"]=nil end
        if states.espF then if not espBills["fruit"] then espBills["fruit"]=true createESP(Color3.fromRGB(255,0,255),"fruit") end else espBills["fruit"]=nil end
        if states.espC then if not espBills["chest"] then espBills["chest"]=true createESP(Color3.fromRGB(255,215,0),"chest") end else espBills["chest"]=nil end
        if states.espB then if not espBills["boss"] then espBills["boss"]=true createESP(Color3.fromRGB(255,50,50),"boss") end else espBills["boss"]=nil end
        
        -- Extra
        if states.aimlock and t % 0.3 < 0.05 then pcall(function() local tgt=findTarget() if tgt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position,tgt.HumanoidRootPart.Position) end end) end
        if states.noclip and t % 0.5 < 0.05 then pcall(function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end
        if states.walkspeed and t % 0.5 < 0.05 then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=100 end end end) end
        if states.bountyHunt and t % 15 < 0.05 then pcall(function() local best,bb=nil,0 for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b=p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b>bb then bb=b best=p end end end if best then tp(best.Character.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
        if states.fragmentFarm and t % 5 < 0.05 then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) for _=1,3 do attack() task.wait(0.3) end end end) end
        
        -- Godmode
        if states.farmLevel or states.farmBoss then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.Health=h.MaxHealth end end end) end
        
        -- Limpeza de memória
        if t % 60 < 0.05 then
            pcall(function() collectgarbage("collect") end)
            for o, b in pairs(espBills) do
                if type(o) ~= "string" then
                    pcall(function() if not o.Parent or (o:FindFirstChild("Humanoid") and o.Humanoid.Health <= 0) then b:Destroy() espBills[o] = nil end end)
                end
            end
        end
        
        task.wait(0.1)
    end
end)

-- ==================== UI (USANDO A BIBLIOTECA) ====================
local win = NexusUI:CreateWindow({
    Title = "NEXUS v7.0",
    Subtitle = "84 Funções | Delta Ready",
    Width = 560,
    Height = 480
})

-- Criar abas
local combatTab = NexusUI:CreateTab(win, {Name = "⚔️ Combate", Icon = "⚔️"})
local fruitTab = NexusUI:CreateTab(win, {Name = "🍎 Frutas", Icon = "🍎"})
local bossTab = NexusUI:CreateTab(win, {Name = "🎯 Bosses", Icon = "🎯"})
local seaTab = NexusUI:CreateTab(win, {Name = "🌊 Sea", Icon = "🌊"})
local collectTab = NexusUI:CreateTab(win, {Name = "📦 Coleta", Icon = "📦"})
local moveTab = NexusUI:CreateTab(win, {Name = "🏃 Move", Icon = "🏃"})
local autoTab = NexusUI:CreateTab(win, {Name = "⚙️ Auto", Icon = "⚙️"})
local shopTab = NexusUI:CreateTab(win, {Name = "🛍️ Loja", Icon = "🛍️"})
local visualTab = NexusUI:CreateTab(win, {Name = "👀 Visual", Icon = "👀"})
local extraTab = NexusUI:CreateTab(win, {Name = "🎮 Extra", Icon = "🎮"})

-- ==================== COMBATE ====================
NexusUI:CreateSection(combatTab, "Farm Principal")
NexusUI:CreateToggle(combatTab, {Title = "Auto Farm Nível", Desc = "Farma NPCs automaticamente", Callback = function(v) states.farmLevel = v end})
NexusUI:CreateToggle(combatTab, {Title = "Auto Farm Maestria", Desc = "Usa habilidades repetidamente", Callback = function(v) states.farmMastery = v end})
NexusUI:CreateToggle(combatTab, {Title = "Auto Farm Boss", Desc = "Farma todos os bosses", Callback = function(v) states.farmBoss = v end})
NexusUI:CreateToggle(combatTab, {Title = "Auto Farm Raid", Desc = "Entra e farma raids", Callback = function(v) states.farmRaid = v end})

-- ==================== FRUTAS ====================
NexusUI:CreateSection(fruitTab, "Sniper & Autos")
NexusUI:CreateToggle(fruitTab, {Title = "Fruit Sniper", Desc = "Teleporta para frutas raras", Callback = function(v) states.fruitSniper = v end})
NexusUI:CreateToggle(fruitTab, {Title = "Auto Store Fruit", Desc = "Guarda fruta no inventário", Callback = function(v) states.fruitStore = v end})
NexusUI:CreateToggle(fruitTab, {Title = "Auto Spawn Fruit", Desc = "Compra do Cousin", Callback = function(v) states.fruitSpawn = v end})

-- ==================== BOSSES ====================
NexusUI:CreateSection(bossTab, "Bosses Individuais")
local bossNames = {"Dough King","Soul Reaper","Cake Prince","Rip Indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"}
for i, name in pairs(bossNames) do
    NexusUI:CreateToggle(bossTab, {Title = name, Desc = "Farm automático", Callback = function(v)
        if i == 1 then states.bossDK = v elseif i == 2 then states.bossSR = v elseif i == 3 then states.bossCP = v
        elseif i == 4 then states.bossRI = v elseif i == 5 then states.bossDB = v elseif i == 6 then states.bossTK = v
        elseif i == 7 then states.bossST = v elseif i == 8 then states.bossIE = v elseif i == 9 then states.bossHY = v
        elseif i == 10 then states.bossLV = v end
    end})
end

-- ==================== SEA ====================
NexusUI:CreateSection(seaTab, "Eventos do Mar")
local seaNames = {"Marine Ship","Pirate Ship","Sea Beast","Terror Shark"}
local seaStateNames = {"seaShip","seaPirate","seaBeast","seaTerror"}
for i, name in pairs(seaNames) do
    NexusUI:CreateToggle(seaTab, {Title = name, Desc = "Farm automático", Callback = function(v) states[seaStateNames[i]] = v end})
end

-- ==================== COLETA ====================
NexusUI:CreateSection(collectTab, "Auto Collect")
local collectNames = {"Chest","Bone","Fist of Darkness","God's Chalice","Blue Gear","Sweet Chalice","Scroll","Fruit Chest"}
local collectStateNames = {"colChest","colBones","colFist","colChalice","colBlue","colSweet","colScroll","colFruitChest"}
for i, name in pairs(collectNames) do
    NexusUI:CreateToggle(collectTab, {Title = "Auto " .. name, Desc = "Coleta automaticamente", Callback = function(v) states[collectStateNames[i]] = v end})
end

-- ==================== MOVIMENTO ====================
NexusUI:CreateSection(moveTab, "Movimentação")
NexusUI:CreateToggle(moveTab, {Title = "Auto Hop Server", Desc = "Troca de servidor", Callback = function(v) states.moveHop = v end})
NexusUI:CreateToggle(moveTab, {Title = "Auto Dash", Desc = "Dash automático", Callback = function(v) states.moveDash = v end})
NexusUI:CreateToggle(moveTab, {Title = "Auto Flight", Desc = "Voo infinito", Callback = function(v) states.moveFlight = v end})
NexusUI:CreateToggle(moveTab, {Title = "Auto Swim", Desc = "Nado automático", Callback = function(v) states.moveSwim = v end})

-- ==================== AUTOMÁTICOS ====================
NexusUI:CreateSection(autoTab, "Automações")
NexusUI:CreateToggle(autoTab, {Title = "Auto Haki", Desc = "Ativa Ken e Buso", Callback = function(v) states.atHaki = v end})
NexusUI:CreateToggle(autoTab, {Title = "Auto Skill", Desc = "Usa habilidades em loop", Callback = function(v) states.atSkill = v end})
NexusUI:CreateToggle(autoTab, {Title = "Auto Quest", Desc = "Pega quests automaticamente", Callback = function(v) states.atQuest = v end})
NexusUI:CreateToggle(autoTab, {Title = "Auto V4 Awakening", Desc = "Desperta Raça V4", Callback = function(v) states.atV4 = v end})

-- ==================== LOJA ====================
NexusUI:CreateSection(shopTab, "Auto Comprar")
local shopNames = {"Fruits","Styles","Sword","Guns","Accessories","Materials"}
local shopStateNames = {"shopFruits","shopStyles","shopSword","shopGuns","shopAcc","shopMat"}
for i, name in pairs(shopNames) do
    NexusUI:CreateToggle(shopTab, {Title = "Auto Buy " .. name, Desc = "Compra automaticamente", Callback = function(v) states[shopStateNames[i]] = v end})
end
NexusUI:CreateToggle(shopTab, {Title = "Auto Buy Stats", Desc = "Compra pontos de status", Callback = function(v) states.shopStats = v end})
NexusUI:CreateToggle(shopTab, {Title = "Auto Buy Fragments", Desc = "Compra fragmentos", Callback = function(v) states.shopFrag = v end})

-- ==================== VISUAL ====================
NexusUI:CreateSection(visualTab, "ESP")
NexusUI:CreateToggle(visualTab, {Title = "ESP Players", Desc = "Mostra jogadores", Callback = function(v) states.espP = v end})
NexusUI:CreateToggle(visualTab, {Title = "ESP Fruits", Desc = "Mostra frutas", Callback = function(v) states.espF = v end})
NexusUI:CreateToggle(visualTab, {Title = "ESP Chests", Desc = "Mostra baús", Callback = function(v) states.espC = v end})
NexusUI:CreateToggle(visualTab, {Title = "ESP Bosses", Desc = "Mostra bosses", Callback = function(v) states.espB = v end})

-- ==================== EXTRA ====================
NexusUI:CreateSection(extraTab, "Funções Especiais")
NexusUI:CreateToggle(extraTab, {Title = "Aimlock", Desc = "Mira automática", Callback = function(v) states.aimlock = v end})
NexusUI:CreateToggle(extraTab, {Title = "No Clip", Desc = "Atravessa paredes", Callback = function(v) states.noclip = v end})
NexusUI:CreateToggle(extraTab, {Title = "Walkspeed", Desc = "Velocidade aumentada", Callback = function(v) states.walkspeed = v end})
NexusUI:CreateToggle(extraTab, {Title = "Bounty Hunt", Desc = "Caça jogadores com bounty", Callback = function(v) states.bountyHunt = v end})
NexusUI:CreateToggle(extraTab, {Title = "Fragment Farm", Desc = "Farma fragmentos", Callback = function(v) states.fragmentFarm = v end})

NexusUI:CreateSlider(extraTab, {Title = "Alcance do Farm", Min = 50, Max = 500, Default = 300, Callback = function(v) range = v end})

-- ==================== FPS LABEL ====================
local fpsLabel = Instance.new("TextLabel", win.Frame)
fpsLabel.Size = UDim2.new(0, 120, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.Text = "FPS: --"

local frameCount, lastTime = 0, tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        fpsLabel.Text = "FPS: " .. frameCount .. " | 🎯 " .. (currentTarget and currentTarget.Name or "Nenhum")
        frameCount = 0
        lastTime = now
    end
end)

-- ==================== INICIAR ====================
notify("NEXUS v7.0", "Script carregado com sucesso!\n" .. (#stateNames) .. " funções disponíveis", 5)
print("NEXUS v7.0 - Carregado - " .. (#stateNames) .. " funções")
