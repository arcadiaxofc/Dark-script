-- ==================== NEXUS v7.0 - DELTA COMPATIBLE - 84 FUNÇÕES CORRIGIDO ====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

-- ==================== ANTI AFK ====================
task.spawn(function()
    while true do
        task.wait(180)
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
task.spawn(function()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.FogEnd = 200
        if Workspace.Terrain then
            Workspace.Terrain.WaterWaveSize = 0
            Workspace.Terrain.GrassLength = 0
            Workspace.Terrain.CloudsEnabled = false
        end
    end)
end)

-- ==================== VARIÁVEIS ====================
local farmLevel, farmMastery, farmBoss, farmRaid, farmSea, farmDungeon, farmElite, farmScroll = false,false,false,false,false,false,false,false
local fruitSniper, fruitStore, fruitSpawn, fruitRoll, fruitNotify, fruitESP = false,false,false,false,false,false
local bossDK, bossSR, bossCP, bossRI, bossDB, bossTK, bossST, bossIE, bossHY, bossLV = false,false,false,false,false,false,false,false,false,false
local seaShip, seaPirate, seaBeast, seaTerror, seaRumble, seaMansion, seaPRaid, seaCastle = false,false,false,false,false,false,false,false
local colChest, colBones, colFist, colChalice, colBlue, colSweet, colScroll, colFruitChest = false,false,false,false,false,false,false,false
local moveHop, moveDash, moveFlight, moveSwim, moveIsland, moveNPC, moveFruit, moveChest, movePlayer = false,false,false,false,false,false,false,false,false
local atHaki, atSkill, atMeta, atRace, atAccessory, atTitle, atQuest, atGear, atV4, atRaidFruits = false,false,false,false,false,false,false,false,false,false
local shopFruits, shopStyles, shopSword, shopGuns, shopAcc, shopMat, shopStats, shopGP, shopFrag, shopBones = false,false,false,false,false,false,false,false,false,false
local espP, espF, espC, espB, espI, espM, espN, espSB, espShips = false,false,false,false,false,false,false,false,false
local aimlock, noclip, walkspeed, jumpspeed, bountyHunt, fragmentFarm = false,false,false,false,false,false

local currentTarget = nil
local range = 300
local attackDelay = 0.5
local espBills = {}
local MAX_ESP = 30
local walkspeedVal = 100
local jumpspeedVal = 100

-- ==================== FUNÇÕES BÁSICAS ====================
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            task.wait(0.1)
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
    end)
end

local function findTarget()
    local nearest, shortest = nil, range
    for _, obj in pairs(Workspace:GetDescendants()) do pcall(function()
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj.Humanoid.Health > 0 and obj ~= player.Character then
            local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then shortest = dist; nearest = obj end
        end
    end) end
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
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Click") end
    end)
end

local function useSkill(key)
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Skill", key) end
    end)
end

local function buyItem(item)
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", item) end
    end)
end

local function collectItem(name)
    local count = 0
    for _, o in pairs(Workspace:GetDescendants()) do pcall(function()
        if count > 10 then return end
        if o.Name:lower():find(name:lower()) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = o:IsA("BasePart") and o.Position or (o:FindFirstChildOfClass("BasePart") and o:FindFirstChildOfClass("BasePart").Position) or (o:FindFirstChild("Handle") and o.Handle.Position)
            if pos then
                local dist = (pos - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= range then
                    tp(pos) task.wait(0.2)
                    if o:FindFirstChild("TouchInterest") then
                        firetouchinterest(o, player.Character.HumanoidRootPart, 0)
                        firetouchinterest(o, player.Character.HumanoidRootPart, 1)
                        count = count + 1
                    end
                end
            end
        end
    end) end
end

local function notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = title or "NEXUS", Text = text or "", Duration = dur or 3}) end)
end

local function serverHop()
    pcall(function()
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?limit=10")
        local servers = HttpService:JSONDecode(res)
        if servers and servers.data and #servers.data > 0 then
            local s = servers.data[math.random(1, #servers.data)]
            TeleportService:TeleportToPlaceInstance(game.GameId, s.id, player)
        end
    end)
end

local function createESP(color, filter)
    task.spawn(function()
        while espBills[filter] do
            pcall(function()
                local count = 0
                for _, o in pairs(Workspace:GetDescendants()) do
                    if count > MAX_ESP then break end
                    if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and o ~= player.Character and not espBills[o] then
                        local show = false
                        if filter == "player" then show = Players:GetPlayerFromCharacter(o) ~= nil
                        elseif filter == "fruit" then show = o.Name:find("Fruit") ~= nil and o:FindFirstChild("Handle")
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
                                bill.Size = UDim2.new(0, 80, 0, 20)
                                bill.AlwaysOnTop = true
                                bill.MaxDistance = range
                                bill.Parent = o.HumanoidRootPart
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 0.7
                                label.BackgroundColor3 = color
                                label.TextColor3 = Color3.new(1, 1, 1)
                                label.TextSize = 9
                                label.Font = Enum.Font.GothamBold
                                label.Text = o.Name
                                label.Parent = bill
                                espBills[o] = bill
                                count = count + 1
                            end
                        end
                    end
                end
                for o, b in pairs(espBills) do if type(o) ~= "string" then pcall(function() if not o.Parent or (o:FindFirstChild("Humanoid") and o.Humanoid.Health <= 0) then b:Destroy() espBills[o] = nil end end) end end
            end)
            task.wait(3)
        end
    end)
end

-- ==================== FUNÇÕES DE FARM (84) ====================
task.spawn(function() while true do if farmLevel then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local t = findTarget() if t then currentTarget = t if (player.Character.HumanoidRootPart.Position - t.HumanoidRootPart.Position).Magnitude > 15 then tp(t.HumanoidRootPart.Position) end attack() end end end) end task.wait(attackDelay) end end)
task.spawn(function() while true do if farmMastery then pcall(function() for _, s in pairs({"Z","X","C"}) do useSkill(s) task.wait(0.5) end end) task.wait(3) end end)
task.spawn(function() while true do if farmBoss then pcall(function() local bosses = {"Dough King","Soul Reaper","Cake Prince","Rip_indra","Darkbeard","Tide Keeper"} for _, n in pairs(bosses) do local b = findBoss(n) if b then currentTarget = b tp(b.HumanoidRootPart.Position) for _=1,20 do attack() task.wait(0.3) end end end end) task.wait(5) end end)
task.spawn(function() while true do if farmRaid then pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") then tp(o.Position) task.wait(0.5) firetouchinterest(o, player.Character.HumanoidRootPart, 0) firetouchinterest(o, player.Character.HumanoidRootPart, 1) break end end end) task.wait(30) end end)
task.spawn(function() while true do if farmSea then pcall(function() local t = findSea("Sea") or findSea("Ship") if t then tp(t.HumanoidRootPart.Position) for _=1,10 do attack() task.wait(0.3) end end end) task.wait(5) end end)
task.spawn(function() while true do if farmDungeon then pcall(function() local t = findTarget() if t then tp(t.HumanoidRootPart.Position) attack() end end) task.wait(attackDelay) end end)
task.spawn(function() while true do if farmElite then pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find("Elite") and o:FindFirstChild("Humanoid") and o.Humanoid.Health > 0 then tp(o.HumanoidRootPart.Position) for _=1,10 do attack() task.wait(0.3) end break end end end) task.wait(3) end end)
task.spawn(function() while true do if farmScroll then collectItem("Scroll") task.wait(8) end end)

task.spawn(function() while true do if fruitSniper then pcall(function() local fruits = {"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit"} for _, n in pairs(fruits) do local f = Workspace:FindFirstChild(n) if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) task.wait(0.5) break end end end) task.wait(5) end end)
task.spawn(function() while true do if fruitStore then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then r.CommF_:InvokeServer("StoreFruit", player.Data.Fruit.Value) end end) task.wait(5) end end)
task.spawn(function() while true do if fruitSpawn then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Cousin","Buy") end end) task.wait(30) end end)
task.spawn(function() while true do if fruitRoll then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("FruitGacha","Roll") end end) task.wait(10) end end)
task.spawn(function() while true do if fruitNotify then pcall(function() for _, n in pairs({"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit"}) do if Workspace:FindFirstChild(n) then notify("FRUTA RARA!", n .. " spawnou!", 5) end end end) task.wait(15) end end)
task.spawn(function() while true do if fruitESP then espBills["fruit"] = true createESP(Color3.fromRGB(255,0,255), "fruit") else espBills["fruit"] = nil end task.wait(2) end end)

local bossNames = {"Dough King","Soul Reaper","Cake Prince","Rip_indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"}
local bossVars = {bossDK,bossSR,bossCP,bossRI,bossDB,bossTK,bossST,bossIE,bossHY,bossLV}
task.spawn(function() while true do for i, name in pairs(bossNames) do if bossVars[i] then pcall(function() local b = findBoss(name) if b then tp(b.HumanoidRootPart.Position) for _=1,20 do attack() task.wait(0.3) end end end) end end task.wait(5) end end)

local seaNames = {"Marine","Pirate","Sea Beast","Terror","Rumbling","Mansion","Raid","Castle"}
local seaVars = {seaShip,seaPirate,seaBeast,seaTerror,seaRumble,seaMansion,seaPRaid,seaCastle}
task.spawn(function() while true do for i, name in pairs(seaNames) do if seaVars[i] then pcall(function() local t = findSea(name) if t then tp(t.HumanoidRootPart.Position) for _=1,10 do attack() task.wait(0.3) end end end) end end task.wait(5) end end)

task.spawn(function() while true do if colChest then collectItem("Chest") task.wait(8) end end)
task.spawn(function() while true do if colBones then collectItem("Bone") task.wait(5) end end)
task.spawn(function() while true do if colFist then collectItem("Fist") task.wait(10) end end)
task.spawn(function() while true do if colChalice then collectItem("Chalice") task.wait(10) end end)
task.spawn(function() while true do if colBlue then collectItem("Blue Gear") task.wait(10) end end)
task.spawn(function() while true do if colSweet then collectItem("Sweet") task.wait(10) end end)
task.spawn(function() while true do if colScroll then collectItem("Scroll") task.wait(8) end end)
task.spawn(function() while true do if colFruitChest then collectItem("Fruit Chest") task.wait(10) end end)

task.spawn(function() while true do if moveHop then serverHop() task.wait(120) end end)
task.spawn(function() while true do if moveDash then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit * 25 end end) task.wait(math.random(3,8)) end end)
task.spawn(function() while true do if moveFlight then pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end end) task.wait(1) end end)
task.spawn(function() while true do if moveSwim then pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end end end) task.wait(1) end end)
task.spawn(function() while true do if moveIsland then tp(Vector3.new(math.random(-5000,5000),50,math.random(-5000,5000))) task.wait(15) end end)
task.spawn(function() while true do if moveNPC then pcall(function() local t = findTarget() if t then tp(t.HumanoidRootPart.Position) end end) task.wait(8) end end)
task.spawn(function() while true do if moveFruit then pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:find("Fruit") and o:FindFirstChild("Handle") then tp(o.Handle.Position) break end end end) task.wait(8) end end)
task.spawn(function() while true do if moveChest then pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:find("Chest") and o:FindFirstChildOfClass("BasePart") then tp(o:FindFirstChildOfClass("BasePart").Position) break end end end) task.wait(8) end end)
task.spawn(function() while true do if movePlayer then pcall(function() local best, bb = nil, 0 for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b = p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b > bb then bb = b best = p end end end if best then tp(best.Character.HumanoidRootPart.Position) end end) task.wait(10) end end)

task.spawn(function() while true do if atHaki then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") task.wait(0.5) r.CommF_:InvokeServer("ActivateHaki","Buso") end end) task.wait(60) end end)
task.spawn(function() while true do if atSkill then pcall(function() for _, s in pairs({"Z","X","C"}) do useSkill(s) task.wait(0.5) end end) task.wait(3) end end)
task.spawn(function() while true do if atMeta then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Metaverse","Start") end end) task.wait(120) end end)
task.spawn(function() while true do if atRace then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceAwakening","Start") end end) task.wait(120) end end)
task.spawn(function() while true do if atAccessory then pcall(function() local t = findTarget() if t then tp(t.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) task.wait(3) end end)
task.spawn(function() while true do if atTitle then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Title","Equip") end end) task.wait(120) end end)
task.spawn(function() while true do if atQuest then pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and (o:FindFirstChild("Quest") or o:FindFirstChild("Talk")) then tp(o.HumanoidRootPart.Position) task.wait(1) local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest", o.Name) end break end end end) task.wait(15) end end)
task.spawn(function() while true do if atGear then collectItem("Gear") task.wait(10) end end)
task.spawn(function() while true do if atV4 then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4","Start") end end) task.wait(120) end end)
task.spawn(function() while true do if atRaidFruits then pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") then tp(o.Position) task.wait(0.5) firetouchinterest(o, player.Character.HumanoidRootPart, 0) firetouchinterest(o, player.Character.HumanoidRootPart, 1) break end end end) task.wait(60) end end)

task.spawn(function() while true do if shopFruits then for _, item in pairs({"Kitsune","Dragon","Leopard"}) do buyItem(item) task.wait(1) end task.wait(300) end end)
task.spawn(function() while true do if shopStyles then for _, item in pairs({"Superhuman","Godhuman"}) do buyItem(item) task.wait(1) end task.wait(300) end end)
task.spawn(function() while true do if shopSword then for _, item in pairs({"Cursed Dual Katana","Dark Blade"}) do buyItem(item) task.wait(1) end task.wait(300) end end)
task.spawn(function() while true do if shopGuns then for _, item in pairs({"Soul Guitar"}) do buyItem(item) task.wait(1) end task.wait(300) end end)
task.spawn(function() while true do if shopAcc then for _, item in pairs({"Pale Scarf"}) do buyItem(item) task.wait(1) end task.wait(300) end end)
task.spawn(function() while true do if shopMat then for _, item in pairs({"Wood","Iron"}) do buyItem(item) task.wait(1) end task.wait(300) end end)
task.spawn(function() while true do if shopStats then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) task.wait(2) end end)
task.spawn(function() while true do if shopGP then buyItem("Gamepass") task.wait(600) end end)
task.spawn(function() while true do if shopFrag then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) task.wait(30) end end)
task.spawn(function() while true do if shopBones then pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end) task.wait(15) end end)

task.spawn(function() while true do if aimlock then pcall(function() local t = findTarget() if t and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, t.HumanoidRootPart.Position) end end) task.wait(0.1) end end)
task.spawn(function() while true do if noclip then pcall(function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) task.wait(0.3) end end)
task.spawn(function() while true do if walkspeed then pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = walkspeedVal end end end) task.wait(0.3) end end)
task.spawn(function() while true do if jumpspeed then pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = jumpspeedVal end end end) task.wait(0.3) end end)
task.spawn(function() while true do if bountyHunt then pcall(function() local best, bb = nil, 0 for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b = p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b > bb then bb = b best = p end end end if best then tp(best.Character.HumanoidRootPart.Position) for _=1,10 do attack() task.wait(0.3) end end end) task.wait(10) end end)
task.spawn(function() while true do if fragmentFarm then pcall(function() local t = findTarget() if t then tp(t.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) task.wait(2) end end)

-- ==================== MENU ====================
local function createMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusMenu"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 370, 0, 520)
    frame.Position = UDim2.new(0, 10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
    title.TextColor3 = Color3.fromRGB(230, 65, 50)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Text = "NEXUS v7.0 - 84 FUNÇÕES"
    title.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -32)
    scroll.Position = UDim2.new(0, 0, 0, 32)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 3600)
    scroll.ScrollBarThickness = 4
    scroll.Parent = frame
    
    local function btn(t, y, h)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.9, 0, 0, h)
        b.Position = UDim2.new(0.05, 0, 0, y)
        b.Text = t
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        return b
    end
    
    local function section(title, y)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.9, 0, 0, 20)
        lbl.Position = UDim2.new(0.05, 0, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(230, 65, 50)
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = title
        lbl.Parent = scroll
        return y + 22
    end
    
    local y = 5
    local allBtns, allNames = {}, {}
    
    local sections = {
        {"⚔️ COMBATE", {"Auto Farm Nível","Auto Farm Maestria","Auto Farm Boss","Auto Farm Raid","Auto Farm Sea","Auto Farm Dungeon","Auto Farm Elite","Auto Farm Scroll"}},
        {"🍎 FRUTAS", {"Fruit Sniper","Auto Store Fruit","Auto Spawn Fruit","Auto Roll Fruit","Fruit Notify","Fruit ESP"}},
        {"🎯 BOSSES", {"Dough King","Soul Reaper","Cake Prince","Rip Indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"}},
        {"🌊 SEA", {"Marine Ship","Pirate Ship","Sea Beast","Terror Shark","Rumbling","Mansion","Pirate Raid","Sea Castle"}},
        {"📦 COLETA", {"Auto Chest","Auto Bones","Fist of Darkness","God's Chalice","Blue Gear","Sweet Chalice","Scroll","Fruit Chest"}},
        {"🏃 MOVIMENTO", {"Auto Hop","Auto Dash","Auto Flight","Auto Swim","TP Island","TP NPC","TP Fruit","TP Chest","TP Player"}},
        {"⚙️ AUTOMÁTICOS", {"Auto Haki","Auto Skill","Metaverse","Race Awakening","Accessory","Title","Auto Quest","Gear Farm","V4 Awakening","Raid Fruits"}},
        {"🛍️ LOJA", {"Buy Fruits","Buy Styles","Buy Sword","Buy Guns","Buy Accessories","Buy Materials","Buy Stats","Buy Gamepass","Buy Fragments","Buy Bones"}},
        {"👀 VISUAL", {"ESP Players","ESP Fruits","ESP Chests","ESP Bosses","ESP Items","ESP Materials","ESP NPCs","ESP Sea","ESP Ships"}},
        {"🎮 EXTRA", {"Aimlock","No Clip","Walkspeed","Jumpspeed","Bounty Hunt","Fragment Farm"}},
    }
    
    for _, sec in pairs(sections) do
        y = section(sec[1], y)
        for _, name in pairs(sec[2]) do
            table.insert(allBtns, btn(name .. ": OFF", y, 32))
            table.insert(allNames, name)
            y = y + 36
        end
    end
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.9, 0, 0, 18)
    fpsLabel.Position = UDim2.new(0.05, 0, 0, y + 10)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(150, 150, 165)
    fpsLabel.TextSize = 11
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Text = "FPS: -- | TARGET: NONE"
    fpsLabel.Parent = scroll
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 40)
    
    -- Mapeamento de nomes para variáveis
    local varMap = {
        ["Auto Farm Nível"] = function(v) farmLevel = v end,
        ["Auto Farm Maestria"] = function(v) farmMastery = v end,
        ["Auto Farm Boss"] = function(v) farmBoss = v end,
        ["Auto Farm Raid"] = function(v) farmRaid = v end,
        ["Auto Farm Sea"] = function(v) farmSea = v end,
        ["Auto Farm Dungeon"] = function(v) farmDungeon = v end,
        ["Auto Farm Elite"] = function(v) farmElite = v end,
        ["Auto Farm Scroll"] = function(v) farmScroll = v end,
        ["Fruit Sniper"] = function(v) fruitSniper = v end,
        ["Auto Store Fruit"] = function(v) fruitStore = v end,
        ["Auto Spawn Fruit"] = function(v) fruitSpawn = v end,
        ["Auto Roll Fruit"] = function(v) fruitRoll = v end,
        ["Fruit Notify"] = function(v) fruitNotify = v end,
        ["Fruit ESP"] = function(v) fruitESP = v if v then espBills["fruit"]=true createESP(Color3.fromRGB(255,0,255),"fruit") else espBills["fruit"]=nil end end,
        ["Dough King"] = function(v) bossDK = v end, ["Soul Reaper"] = function(v) bossSR = v end,
        ["Cake Prince"] = function(v) bossCP = v end, ["Rip Indra"] = function(v) bossRI = v end,
        ["Darkbeard"] = function(v) bossDB = v end, ["Tide Keeper"] = function(v) bossTK = v end,
        ["Stone"] = function(v) bossST = v end, ["Island Empress"] = function(v) bossIE = v end,
        ["Hydra"] = function(v) bossHY = v end, ["Leviathan"] = function(v) bossLV = v end,
        ["Marine Ship"] = function(v) seaShip = v end, ["Pirate Ship"] = function(v) seaPirate = v end,
        ["Sea Beast"] = function(v) seaBeast = v end, ["Terror Shark"] = function(v) seaTerror = v end,
        ["Rumbling"] = function(v) seaRumble = v end, ["Mansion"] = function(v) seaMansion = v end,
        ["Pirate Raid"] = function(v) seaPRaid = v end, ["Sea Castle"] = function(v) seaCastle = v end,
        ["Auto Chest"] = function(v) colChest = v end, ["Auto Bones"] = function(v) colBones = v end,
        ["Fist of Darkness"] = function(v) colFist = v end, ["God's Chalice"] = function(v) colChalice = v end,
        ["Blue Gear"] = function(v) colBlue = v end, ["Sweet Chalice"] = function(v) colSweet = v end,
        ["Scroll"] = function(v) colScroll = v end, ["Fruit Chest"] = function(v) colFruitChest = v end,
        ["Auto Hop"] = function(v) moveHop = v end, ["Auto Dash"] = function(v) moveDash = v end,
        ["Auto Flight"] = function(v) moveFlight = v end, ["Auto Swim"] = function(v) moveSwim = v end,
        ["TP Island"] = function(v) moveIsland = v end, ["TP NPC"] = function(v) moveNPC = v end,
        ["TP Fruit"] = function(v) moveFruit = v end, ["TP Chest"] = function(v) moveChest = v end,
        ["TP Player"] = function(v) movePlayer = v end,
        ["Auto Haki"] = function(v) atHaki = v end, ["Auto Skill"] = function(v) atSkill = v end,
        ["Metaverse"] = function(v) atMeta = v end, ["Race Awakening"] = function(v) atRace = v end,
        ["Accessory"] = function(v) atAccessory = v end, ["Title"] = function(v) atTitle = v end,
        ["Auto Quest"] = function(v) atQuest = v end, ["Gear Farm"] = function(v) atGear = v end,
        ["V4 Awakening"] = function(v) atV4 = v end, ["Raid Fruits"] = function(v) atRaidFruits = v end,
        ["Buy Fruits"] = function(v) shopFruits = v end, ["Buy Styles"] = function(v) shopStyles = v end,
        ["Buy Sword"] = function(v) shopSword = v end, ["Buy Guns"] = function(v) shopGuns = v end,
        ["Buy Accessories"] = function(v) shopAcc = v end, ["Buy Materials"] = function(v) shopMat = v end,
        ["Buy Stats"] = function(v) shopStats = v end, ["Buy Gamepass"] = function(v) shopGP = v end,
        ["Buy Fragments"] = function(v) shopFrag = v end, ["Buy Bones"] = function(v) shopBones = v end,
        ["ESP Players"] = function(v) espP=v if v then espBills["player"]=true createESP(Color3.fromRGB(255,0,0),"player") else espBills["player"]=nil end end,
        ["ESP Fruits"] = function(v) espF=v if v then espBills["fruit"]=true createESP(Color3.fromRGB(255,0,255),"fruit") else espBills["fruit"]=nil end end,
        ["ESP Chests"] = function(v) espC=v if v then espBills["chest"]=true createESP(Color3.fromRGB(255,215,0),"chest") else espBills["chest"]=nil end end,
        ["ESP Bosses"] = function(v) espB=v if v then espBills["boss"]=true createESP(Color3.fromRGB(255,50,50),"boss") else espBills["boss"]=nil end end,
        ["ESP Items"] = function(v) espI=v if v then espBills["item"]=true createESP(Color3.fromRGB(0,255,255),"item") else espBills["item"]=nil end end,
        ["ESP Materials"] = function(v) espM=v if v then espBills["material"]=true createESP(Color3.fromRGB(0,255,0),"material") else espBills["material"]=nil end end,
        ["ESP NPCs"] = function(v) espN=v if v then espBills["npc"]=true createESP(Color3.fromRGB(255,255,0),"npc") else espBills["npc"]=nil end end,
        ["ESP Sea"] = function(v) espSB=v if v then espBills["sea"]=true createESP(Color3.fromRGB(0,0,255),"sea") else espBills["sea"]=nil end end,
        ["ESP Ships"] = function(v) espShips=v if v then espBills["ship"]=true createESP(Color3.fromRGB(128,128,128),"ship") else espBills["ship"]=nil end end,
        ["Aimlock"] = function(v) aimlock = v end,
        ["No Clip"] = function(v) noclip = v end,
        ["Walkspeed"] = function(v) walkspeed = v if not v and player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end end end,
        ["Jumpspeed"] = function(v) jumpspeed = v if not v and player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=50 end end end,
        ["Bounty Hunt"] = function(v) bountyHunt = v end,
        ["Fragment Farm"] = function(v) fragmentFarm = v end,
    }
    
    local states = {}
    for _, name in pairs(allNames) do states[name] = false end
    
    for i, btn in pairs(allBtns) do
        btn.MouseButton1Click:Connect(function()
            local name = allNames[i]
            states[name] = not states[name]
            if varMap[name] then varMap[name](states[name]) end
            btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
            btn.BackgroundColor3 = states[name] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        end)
    end
    
    local fc, lt = 0, tick()
    RunService.RenderStepped:Connect(function()
        fc = fc + 1
        local nw = tick()
        if nw - lt >= 1 then
            fpsLabel.Text = "FPS: " .. fc .. " | TARGET: " .. (currentTarget and currentTarget.Name or "NONE")
            fc = 0 lt = nw
        end
    end)
    
    local drag, ds, sp = false, nil, nil
    frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true ds = i.Position sp = frame.Position end end)
    frame.InputEnded:Connect(function() drag = false end)
    UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and drag then local delta = i.Position - ds frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
end

createMenu()
notify("NEXUS v7.0", "84 Funções | Delta Ready | v7.0.1", 5)
print("NEXUS v7.0.1 - 84 Funções - Delta Compatible - Loaded")
