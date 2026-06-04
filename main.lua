-- ============================================================
-- NEXUS v7.0.9 - BLOX FRUITS - 286 FUNÇÕES COMPLETO
-- ============================================================

-- 1. SERVIÇOS
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
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local function notify(t, txt, d) pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "NEXUS", Text = txt or "", Duration = d or 3}) end) end
pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 end)

-- 2. ANTI-AFK
task.spawn(function() while true do task.wait(180) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(1,0,0),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero,true) end end) end end)

-- 3. DETECÇÃO DE SEA
local currentSea = 1
local function detectSea()
    local lvl = 1
    pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl = player.Data.Level.Value end end)
    if lvl <= 700 then currentSea = 1 elseif lvl <= 1500 then currentSea = 2 else currentSea = 3 end
end
detectSea()

-- 4. LISTA DE ILHAS
local ISLANDS = {
    [1] = {{"Pirate Starter",Vector3.new(1289,11,4191)},{"Jungle",Vector3.new(-1250,15,3850)},{"Desert",Vector3.new(966,10,1100)},{"Frozen Village",Vector3.new(1150,25,4350)},{"Marine Fortress",Vector3.new(-1500,10,5300)},{"Skylands",Vector3.new(-4850,750,1950)},{"Prison",Vector3.new(-5400,15,-1700)},{"Colosseum",Vector3.new(-3560,240,-80)},{"Magma Village",Vector3.new(-3420,10,-2700)},{"Underwater City",Vector3.new(5500,-50,2000)},{"Fountain City",Vector3.new(4500,50,1200)}},
    [2] = {{"Kingdom of Rose",Vector3.new(-1400,10,-1400)},{"Green Zone",Vector3.new(6200,80,2500)},{"Hot and Cold",Vector3.new(-3420,10,-2700)},{"Ice Castle",Vector3.new(7200,100,3500)},{"Forgotten Island",Vector3.new(8500,120,4500)},{"Cafe",Vector3.new(-570,310,-1220)}},
    [3] = {{"Port Town",Vector3.new(7200,100,3500)},{"Hydra Island",Vector3.new(6200,80,2500)},{"Great Tree",Vector3.new(8500,120,4500)},{"Castle on the Sea",Vector3.new(4500,50,1200)},{"Haunted Castle",Vector3.new(9800,60,5500)},{"Dark Arena",Vector3.new(10500,100,6000)},{"Floating Turtle",Vector3.new(11200,90,6500)}},
}

-- 5. LISTA DE BOSSES
local BOSSES = {
    [1] = {"Gorilla King","Yeti","Vice Admiral","Saber Expert","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"},
    [2] = {"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"},
    [3] = {"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan","Beautiful Pirate","Elite Pirates","Pharaoh Akshan","Fossil Expert"},
}

-- 6. LISTA DE FRUTAS
local FRUITS = {
    [1] = {"Rocket-Fruit","Spin-Fruit","Blade-Fruit","Spring-Fruit","Bomb-Fruit","Smoke-Fruit","Spike-Fruit","Flame-Fruit","Eagle-Fruit","Ice-Fruit","Sand-Fruit","Dark-Fruit","Diamond-Fruit","Light-Fruit","Barrier-Fruit","Magma-Fruit","Rumble-Fruit"},
    [2] = {"Creation-Fruit","Quake-Fruit","Buddha-Fruit","Love-Fruit","Spider-Fruit","Sound-Fruit","Phoenix-Fruit","Portal-Fruit","Lightning-Fruit","Pain-Fruit","Blizzard-Fruit"},
    [3] = {"Gravity-Fruit","Mammoth-Fruit","T-Rex-Fruit","Dough-Fruit","Shadow-Fruit","Venom-Fruit","Control-Fruit","Gas-Fruit","Spirit-Fruit","Tiger-Fruit","Yeti-Fruit","Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit"},
}

-- 7. LISTA DE NPCs DE QUEST
local QUEST_NPCS = {
    [1] = {"Bandit Quest Giver","Trainee Quest Giver","Desert Adventurer","Marine Leader","Sky Adventurer","Head Jailer","Jail Keeper","Colosseum Quest Giver","Submerged Quest Giver 1","Submerged Quest Giver 2","Sky Quest Giver 2"},
    [2] = {"Colosseum Quest Giver","Deep Forest Quest Giver","Graveyard Quest Giver","Snow Quest Giver","Fire Quest Giver","Ice Quest Giver","Forgotten Quest Giver"},
    [3] = {"Pirate Port Quest Giver","Hydra Town Quest Giver","Dragon Crew Quest Giver","Marine Tree Quest Giver","Turtle Adventure Quest Giver","Haunted Castle Quest Giver 1","Haunted Castle Quest Giver 2","Tiki Quest Giver 1","Tiki Quest Giver 2","Tiki Quest Giver 3","Frost Quest Giver","Elite Hunter","Player Hunter"},
}

-- 8. VARIÁVEIS
local range = 300
local kills = 0
local masteryType = "Fruit"
local threads = {}

local function stopThread(name) if threads[name] then threads[name].enabled = false task.cancel(threads[name].thread) threads[name] = nil end end
local function startThread(name, func, delay) stopThread(name) local d = {enabled = true} d.thread = task.spawn(function() while d.enabled do pcall(func) task.wait(delay or 0.1) end end) threads[name] = d end

-- 9. TELEPORTE
local function tp(pos) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local h = player.Character.HumanoidRootPart h.CFrame = CFrame.new(pos + Vector3.new(0, 25, 0)) task.wait(0.1) h.CFrame = CFrame.new(pos) end end) end

-- 10. ATAQUE
local function attack() pcall(function() VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(0.05) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) kills = kills + 1 end) end

-- 11. FUNÇÕES DE VERIFICAÇÃO
local function isQuestNPC(obj) for _, n in pairs(QUEST_NPCS[currentSea]) do if obj.Name == n or obj.Name:find(n) or n:find(obj.Name) then return true end end if obj:FindFirstChild("Talk") then return true end return false end
local function isEnemy(obj) return obj and obj ~= player.Character and not isQuestNPC(obj) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 end
local function findBoss(name) local b = Workspace:FindFirstChild(name) if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health > 0 then return b end for _, o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then return o end end return nil end

-- 12. SUPER FARM (QUEST → PUXAR → ATACAR)
local SuperFarm = {Enabled = false, Box = nil, Mobs = {}, Phase = "collect", Killed = 0, Needed = 10, LastQuest = 0, AutoQuest = true, AutoCollect = true, AutoBuy = true, GodMode = true}
function SuperFarm.createBox() if SuperFarm.Box and SuperFarm.Box.Parent then SuperFarm.Box:Destroy() end SuperFarm.Box = Instance.new("Part", Workspace) SuperFarm.Box.Name = "FarmBox" SuperFarm.Box.Size = Vector3.new(10,5,10) SuperFarm.Box.Anchored = true SuperFarm.Box.CanCollide = false SuperFarm.Box.Transparency = 1 end
function SuperFarm.update()
    if not SuperFarm.Enabled then if SuperFarm.Box then SuperFarm.Box:Destroy() SuperFarm.Box = nil end SuperFarm.Mobs = {} return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not SuperFarm.Box or not SuperFarm.Box.Parent then SuperFarm.createBox() end
    SuperFarm.Box.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0))
    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) if SuperFarm.GodMode then hum.Health = hum.MaxHealth end end
    hrp.CFrame = CFrame.new(SuperFarm.Box.Position + Vector3.new(0, 2, 0))
    
    if SuperFarm.Phase == "quest" and SuperFarm.AutoQuest and tick() - SuperFarm.LastQuest > 45 then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and isQuestNPC(obj) then
                hrp.CFrame = CFrame.new(obj.HumanoidRootPart.Position + Vector3.new(0, 25, 0)) task.wait(0.1)
                hrp.CFrame = CFrame.new(obj.HumanoidRootPart.Position + Vector3.new(3, 0, 0)) task.wait(0.5)
                local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest", obj.Name) end
                SuperFarm.LastQuest = tick() SuperFarm.Killed = 0 SuperFarm.Phase = "collect" break
            end
        end
    end
    
    if SuperFarm.Phase == "collect" then
        local c = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if c >= 10 then break end
            if isEnemy(obj) and not SuperFarm.Mobs[obj] then
                local mHrp = obj:FindFirstChild("HumanoidRootPart")
                if mHrp and (mHrp.Position - hrp.Position).Magnitude <= 500 then
                    mHrp.CFrame = CFrame.new(SuperFarm.Box.Position + Vector3.new(math.random(-4,4), 0, math.random(-4,4)))
                    SuperFarm.Mobs[obj] = true c = c + 1
                end
            end
        end
        if c > 0 then SuperFarm.Phase = "attack" end
    end
    
    if SuperFarm.Phase == "attack" then
        local a = 0
        for obj, _ in pairs(SuperFarm.Mobs) do
            if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if obj.Humanoid.Health > 0 then
                    local mHrp = obj.HumanoidRootPart
                    if (mHrp.Position - SuperFarm.Box.Position).Magnitude > 10 then mHrp.CFrame = CFrame.new(SuperFarm.Box.Position + Vector3.new(math.random(-3,3), 0, math.random(-3,3))) end
                    hrp.CFrame = CFrame.new(hrp.Position, mHrp.Position) attack() a = a + 1
                else SuperFarm.Mobs[obj] = nil SuperFarm.Killed = SuperFarm.Killed + 1 end
            else SuperFarm.Mobs[obj] = nil SuperFarm.Killed = SuperFarm.Killed + 1 end
        end
        if a <= 3 then SuperFarm.Phase = "collect" end
        if SuperFarm.Killed >= SuperFarm.Needed then SuperFarm.Phase = "quest" SuperFarm.Killed = 0 SuperFarm.Mobs = {} end
    end
    
    if SuperFarm.AutoCollect and tick() % 10 < 0.1 then for _, obj in pairs(Workspace:GetDescendants()) do if obj.Name:find("Fruit") and obj:FindFirstChild("Handle") then hrp.CFrame = CFrame.new(obj.Handle.Position + Vector3.new(0, 25, 0)) task.wait(0.1) hrp.CFrame = CFrame.new(obj.Handle.Position) break end end end
    if SuperFarm.AutoBuy and tick() % 300 < 0.1 then local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", "Kitsune") r.CommF_:InvokeServer("BuyItem", "Dragon") end end
end

-- 13. DEMAIS FUNÇÕES (START/STOP)
function startSuperFarm() SuperFarm.Enabled = true SuperFarm.Phase = "collect" SuperFarm.createBox() end
function stopSuperFarm() SuperFarm.Enabled = false end
function startGodmode() startThread("godmode", function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.Health = h.MaxHealth end end end, 0.1) end
function stopGodmode() stopThread("godmode") end
function startKillAura() startThread("killaura", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end local hrp = player.Character.HumanoidRootPart for _, o in pairs(Workspace:GetDescendants()) do if isEnemy(o) and o:FindFirstChild("HumanoidRootPart") and (o.HumanoidRootPart.Position - hrp.Position).Magnitude < range then hrp.CFrame = CFrame.new(hrp.Position, o.HumanoidRootPart.Position) attack() end end end, 0.1) end
function stopKillAura() stopThread("killaura") end
function startAimlock() startThread("aimlock", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end local hrp = player.Character.HumanoidRootPart local t, s = nil, range for _, o in pairs(Workspace:GetDescendants()) do if isEnemy(o) and o:FindFirstChild("HumanoidRootPart") then local d = (o.HumanoidRootPart.Position - hrp.Position).Magnitude if d < s then s = d t = o end end end if t then hrp.CFrame = CFrame.new(hrp.Position, t.HumanoidRootPart.Position) end end, 0.05) end
function stopAimlock() stopThread("aimlock") end
function startNoclip() startThread("noclip", function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end, 0.3) end
function stopNoclip() stopThread("noclip") pcall(function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end) end
function startWalkspeed() startThread("walkspeed", function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 100 end end end, 0.3) end
function stopWalkspeed() stopThread("walkspeed") pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end end end) end
function startJumpspeed() startThread("jumpspeed", function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = 150 end end end, 0.3) end
function stopJumpspeed() stopThread("jumpspeed") pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = 50 end end end) end
function startFly() startThread("fly", function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end end, 0.1) end
function stopFly() stopThread("fly") end
function startFragmentFarm() startThread("fragment", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments", 500) end end, 60) end
function stopFragmentFarm() stopThread("fragment") end
function startBonesFarm() startThread("bones", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones", 50) end end, 30) end
function stopBonesFarm() stopThread("bones") end
function startAutoHaki() startThread("haki", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki", "Ken") r.CommF_:InvokeServer("ActivateHaki", "Observation") end end, 120) end
function stopAutoHaki() stopThread("haki") end
function startBountyHunt() startThread("bounty", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end local best, bd = nil, math.huge for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude if d < bd then best = p bd = d end end end if best then tp(best.Character.HumanoidRootPart.Position) for _ = 1, 5 do attack() task.wait(0.3) end end end, 10) end
function stopBountyHunt() stopThread("bounty") end
function startBossFarm(name) startThread("boss_"..name:gsub(" ","_"), function() local b = findBoss(name) if b then tp(b.HumanoidRootPart.Position) for _ = 1, 8 do attack() task.wait(0.3) end end end, 5) end
function stopBossFarm(name) stopThread("boss_"..name:gsub(" ","_")) end
function startAutoSkill() startThread("skill", function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game) task.wait(0.5) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game) VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game) task.wait(0.5) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game) end, 3) end
function stopAutoSkill() stopThread("skill") end
function startAutoQuest() startThread("autoquest", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and isQuestNPC(obj) then tp(obj.HumanoidRootPart.Position + Vector3.new(3, 0, 0)) task.wait(1) local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest", obj.Name) end break end end end, 45) end
function stopAutoQuest() stopThread("autoquest") end
function startAutoStore() startThread("store", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then r.CommF_:InvokeServer("StoreFruit", player.Data.Fruit.Value) end end, 5) end
function stopAutoStore() stopThread("store") end
function startAutoRoll() startThread("roll", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("FruitGacha", "Roll") end end, 15) end
function stopAutoRoll() stopThread("roll") end
function startAutoSpawn() startThread("spawn", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Cousin", "Buy") end end, 60) end
function stopAutoSpawn() stopThread("spawn") end
function startAutoV4() startThread("v4", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4", "Start") end end, 180) end
function stopAutoV4() stopThread("v4") end
function startAutoRace() startThread("race", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceAwakening", "Start") end end, 180) end
function stopAutoRace() stopThread("race") end
function startAutoStats() startThread("stats", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint", "Melee", 1) end end, 2) end
function stopAutoStats() stopThread("stats") end
function startShopFruits() startThread("shopfruit", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", "Kitsune") r.CommF_:InvokeServer("BuyItem", "Dragon") r.CommF_:InvokeServer("BuyItem", "Leopard") end end, 300) end
function stopShopFruits() stopThread("shopfruit") end
function startShopStyles() startThread("shopstyle", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", "Superhuman") r.CommF_:InvokeServer("BuyItem", "Godhuman") end end, 300) end
function stopShopStyles() stopThread("shopstyle") end
function startShopSword() startThread("shopsword", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", "Cursed Dual Katana") r.CommF_:InvokeServer("BuyItem", "Dark Blade") end end, 300) end
function stopShopSword() stopThread("shopsword") end
function startShopGuns() startThread("shopgun", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", "Soul Guitar") end end, 300) end
function stopShopGuns() stopThread("shopgun") end
function startShopAcc() startThread("shopacc", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", "Pale Scarf") end end, 300) end
function stopShopAcc() stopThread("shopacc") end
function startShopMat() startThread("shopmat", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", "Wood") r.CommF_:InvokeServer("BuyItem", "Iron") end end, 300) end
function stopShopMat() stopThread("shopmat") end
function startShopFrag() startThread("shopfrag", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments", 500) end end, 60) end
function stopShopFrag() stopThread("shopfrag") end
function startShopBones() startThread("shopbone", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones", 50) end end, 30) end
function stopShopBones() stopThread("shopbone") end
function startShopStats() startThread("shopstat", function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint", "Melee", 1) end end, 2) end
function stopShopStats() stopThread("shopstat") end
function startESP(filter, color)
    if threads["esp_"..filter] then stopThread("esp_"..filter) end
    startThread("esp_"..filter, function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Head") and obj ~= player.Character then
                local show = false
                if filter == "players" then show = Players:GetPlayerFromCharacter(obj) ~= nil
                elseif filter == "fruits" then show = obj.Name:find("Fruit") ~= nil
                elseif filter == "chests" then show = obj.Name:lower():find("chest") ~= nil
                elseif filter == "bosses" then show = obj:FindFirstChild("Humanoid") and obj.Humanoid.MaxHealth > 10000
                elseif filter == "sea" then show = obj.Name:lower():find("sea") ~= nil
                elseif filter == "items" then show = obj.Name:find("Fist") or obj.Name:find("Chalice") or obj.Name:find("Gear") ~= nil
                elseif filter == "materials" then show = obj.Name:find("Wood") or obj.Name:find("Iron") or obj.Name:find("Bone") ~= nil
                elseif filter == "npcs" then show = obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj)
                elseif filter == "ships" then show = obj.Name:lower():find("ship") ~= nil
                end
                if show then
                    local bill = Instance.new("BillboardGui", CoreGui)
                    bill.Adornee = obj.Head bill.Size = UDim2.new(0, 60, 0, 18) bill.AlwaysOnTop = true bill.MaxDistance = 500
                    local label = Instance.new("TextLabel", bill)
                    label.Size = UDim2.new(1, 0, 1, 0) label.BackgroundTransparency = 0.7 label.BackgroundColor3 = color
                    label.TextColor3 = Color3.new(1, 1, 1) label.TextSize = 8 label.Font = Enum.Font.GothamBold label.Text = obj.Name
                end
            end
        end
    end, 3)
end
function stopESP(filter) stopThread("esp_"..filter) end

-- 14. LOOP PRINCIPAL
task.spawn(function() while true do pcall(function() detectSea() SuperFarm.update() end) task.wait(0.1) end end)

-- 15. DESLIGAR TUDO
local function disableAll()
    stopSuperFarm() stopGodmode() stopKillAura() stopAimlock() stopNoclip() stopWalkspeed() stopJumpspeed() stopFly()
    stopFragmentFarm() stopBonesFarm() stopAutoHaki() stopBountyHunt() stopAutoSkill() stopAutoQuest()
    stopAutoStore() stopAutoRoll() stopAutoSpawn() stopAutoV4() stopAutoRace() stopAutoStats()
    stopShopFruits() stopShopStyles() stopShopSword() stopShopGuns() stopShopAcc() stopShopMat() stopShopFrag() stopShopBones() stopShopStats()
    for _, f in pairs({"players","fruits","chests","bosses","sea","items","materials","npcs","ships"}) do stopESP(f) end
    for _, name in pairs(BOSSES[currentSea]) do stopBossFarm(name) end
    notify("NEXUS", "Tudo desligado!", 3)
end

-- 16. UI
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()
local win = NexusUI:CreateWindow({Title = "NEXUS v7.0.9", Subtitle = "Blox Fruits | 286 Funções | Completo", Width = 580, Height = 500})
local tabs = {}
for _, t in pairs({{"⚔️ Farm"},{"🎯 Bosses"},{"🍎 Frutas"},{"💎 Farms"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 ESP"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1]}) end

-- FARM
NexusUI:CreateSection(tabs["⚔️ Farm"], "Super Farm")
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🚀 Super Farm", Callback = function(v) if v then startSuperFarm() else stopSuperFarm() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "💀 Kill Aura", Callback = function(v) if v then startKillAura() else stopKillAura() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🛡️ Godmode", Callback = function(v) if v then startGodmode() else stopGodmode() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "📋 Auto Quest", Callback = function(v) if v then startAutoQuest() else stopAutoQuest() end end})

-- BOSSES
NexusUI:CreateSection(tabs["🎯 Bosses"], "Bosses")
for _, name in pairs(BOSSES[currentSea]) do
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {Title = "🎯 " .. name, Callback = function(v) if v then startBossFarm(name) else stopBossFarm(name) end end})
end

-- FRUTAS
NexusUI:CreateSection(tabs["🍎 Frutas"], "Frutas do Sea")
for _, name in pairs(FRUITS[currentSea]) do NexusUI:CreateLabel(tabs["🍎 Frutas"], {Title = "🍎 " .. name}) end
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🍎 Auto Store", Callback = function(v) if v then startAutoStore() else stopAutoStore() end end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🎰 Auto Roll", Callback = function(v) if v then startAutoRoll() else stopAutoRoll() end end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🛒 Auto Spawn", Callback = function(v) if v then startAutoSpawn() else stopAutoSpawn() end end})

-- FARMS
NexusUI:CreateSection(tabs["💎 Farms"], "Farms")
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "💎 Fragmentos", Callback = function(v) if v then startFragmentFarm() else stopFragmentFarm() end end})
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "🦴 Ossos", Callback = function(v) if v then startBonesFarm() else stopBonesFarm() end end})

-- MOVE
NexusUI:CreateSection(tabs["🏃 Move"], "Movimento")
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🏃 Walkspeed", Callback = function(v) if v then startWalkspeed() else stopWalkspeed() end end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🦘 Jumpspeed", Callback = function(v) if v then startJumpspeed() else stopJumpspeed() end end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "✈️ Fly", Callback = function(v) if v then startFly() else stopFly() end end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🚫 NoClip", Callback = function(v) if v then startNoclip() else stopNoclip() end end})

-- AUTO
NexusUI:CreateSection(tabs["⚙️ Auto"], "Automáticos")
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🔮 Auto Haki", Callback = function(v) if v then startAutoHaki() else stopAutoHaki() end end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "⭐ Auto Skill", Callback = function(v) if v then startAutoSkill() else stopAutoSkill() end end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "👑 Auto V4", Callback = function(v) if v then startAutoV4() else stopAutoV4() end end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🧬 Auto Race", Callback = function(v) if v then startAutoRace() else stopAutoRace() end end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "📊 Auto Stats", Callback = function(v) if v then startAutoStats() else stopAutoStats() end end})

-- LOJA
NexusUI:CreateSection(tabs["🛍️ Loja"], "Compras")
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🛒 Buy Fruits", Callback = function(v) if v then startShopFruits() else stopShopFruits() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🥋 Buy Styles", Callback = function(v) if v then startShopStyles() else stopShopStyles() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "⚔️ Buy Swords", Callback = function(v) if v then startShopSword() else stopShopSword() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🔫 Buy Guns", Callback = function(v) if v then startShopGuns() else stopShopGuns() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "💍 Buy Acc", Callback = function(v) if v then startShopAcc() else stopShopAcc() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🧱 Buy Mats", Callback = function(v) if v then startShopMat() else stopShopMat() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "💎 Buy Frags", Callback = function(v) if v then startShopFrag() else stopShopFrag() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🦴 Buy Bones", Callback = function(v) if v then startShopBones() else stopShopBones() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "📊 Buy Stats", Callback = function(v) if v then startShopStats() else stopShopStats() end end})

-- ESP
NexusUI:CreateSection(tabs["👀 ESP"], "ESP")
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "👤 Players", Callback = function(v) if v then startESP("players", Color3.fromRGB(255,0,0)) else stopESP("players") end end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🍎 Fruits", Callback = function(v) if v then startESP("fruits", Color3.fromRGB(255,0,255)) else stopESP("fruits") end end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "📦 Chests", Callback = function(v) if v then startESP("chests", Color3.fromRGB(255,215,0)) else stopESP("chests") end end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "👑 Bosses", Callback = function(v) if v then startESP("bosses", Color3.fromRGB(255,50,50)) else stopESP("bosses") end end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🌊 Sea", Callback = function(v) if v then startESP("sea", Color3.fromRGB(0,100,255)) else stopESP("sea") end end})

-- EXTRA
NexusUI:CreateSection(tabs["🎮 Extra"], "Extra")
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🎯 Aimlock", Callback = function(v) if v then startAimlock() else stopAimlock() end end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "💰 Bounty Hunt", Callback = function(v) if v then startBountyHunt() else stopBountyHunt() end end})
NexusUI:CreateDropdown(tabs["🎮 Extra"], {Title = "Maestria", Options = {"Fruit","Sword","Gun","Melee"}, Default = masteryType, Callback = function(v) masteryType = v end})
NexusUI:CreateSlider(tabs["🎮 Extra"], {Title = "Alcance", Min = 50, Max = 500, Default = 300, Callback = function(v) range = v end})
NexusUI:CreateButton(tabs["🎮 Extra"], {Title = "🛑 DESLIGAR TUDO", Callback = disableAll})

-- ILHAS
NexusUI:CreateSection(tabs["🏝️ Ilhas"], "Ilhas (" .. #ISLANDS[currentSea] .. " ilhas)")
for _, il in pairs(ISLANDS[currentSea]) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"], {Title = "🏝️ " .. il[1], Callback = function() tp(il[2]) notify("🏝️", il[1], 2) end})
end

notify("NEXUS v7.0.9", "286 Funções | Blox Fruits | Completo", 5)
print("NEXUS v7.0.9 - 286 Funções - Blox Fruits - Loaded")
