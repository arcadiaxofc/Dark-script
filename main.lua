-- ============================================================
-- NEXUS v7.0.9 PRO - COMPLETO COM TUDO RESTAURADO
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

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

local function notify(t, txt, d) pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "NEXUS", Text = txt or "", Duration = d or 3}) end) end

pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
task.spawn(function() while true do task.wait(180) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(1,0,0),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero,true) end end) end end)

-- ============================================================
-- DADOS COMPLETOS DOS 3 SEAS (ILHAS, BOSSES, FRUTAS)
-- ============================================================
local SEA_DATA = {
    [1] = {
        name = "First Sea", levelRange = {1, 700},
        islands = {
            {"🏴‍☠️ Pirate Starter", Vector3.new(1289, 11, 4191)},
            {"⚓ Marine Starter", Vector3.new(-383, 15, 727)},
            {"🌴 Jungle", Vector3.new(-1250, 15, 3850)},
            {"🏘️ Pirate Village", Vector3.new(-383, 15, 727)},
            {"🏜️ Desert", Vector3.new(966, 10, 1100)},
            {"❄️ Frozen Village", Vector3.new(1150, 25, 4350)},
            {"🏰 Marine Fortress", Vector3.new(-1500, 10, 5300)},
            {"☁️ Skylands", Vector3.new(-4850, 750, 1950)},
            {"🔒 Prison", Vector3.new(-5400, 15, -1700)},
            {"🏟️ Colosseum", Vector3.new(-3560, 240, -80)},
            {"🌋 Magma Village", Vector3.new(-3420, 10, -2700)},
            {"🐠 Underwater City", Vector3.new(5500, -50, 2000)},
            {"🏛️ Fountain City", Vector3.new(4500, 50, 1200)},
        },
        bosses = {"Gorilla King","Chef","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"},
        fruits = {"Rocket-Fruit","Spin-Fruit","Blade-Fruit","Spring-Fruit","Bomb-Fruit","Smoke-Fruit","Spike-Fruit","Flame-Fruit","Eagle-Fruit","Ice-Fruit","Sand-Fruit","Dark-Fruit","Diamond-Fruit","Light-Fruit","Barrier-Fruit","Magma-Fruit","Rumble-Fruit"},
    },
    [2] = {
        name = "Second Sea", levelRange = {701, 1500},
        islands = {
            {"🌹 Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
            {"🌿 Green Zone", Vector3.new(6200, 80, 2500)},
            {"🔥 Hot and Cold", Vector3.new(-3420, 10, -2700)},
            {"🏯 Ice Castle", Vector3.new(7200, 100, 3500)},
            {"🗿 Forgotten Island", Vector3.new(8500, 120, 4500)},
            {"☕ Cafe", Vector3.new(-570, 310, -1220)},
            {"🏚️ Mansion", Vector3.new(-390, 45, -800)},
        },
        bosses = {"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"},
        fruits = {"Creation-Fruit","Quake-Fruit","Buddha-Fruit","Love-Fruit","Spider-Fruit","Sound-Fruit","Phoenix-Fruit","Portal-Fruit","Lightning-Fruit","Pain-Fruit","Blizzard-Fruit"},
    },
    [3] = {
        name = "Third Sea", levelRange = {1501, 2600},
        islands = {
            {"⚓ Port Town", Vector3.new(7200, 100, 3500)},
            {"🐉 Hydra Island", Vector3.new(6200, 80, 2500)},
            {"🌳 Great Tree", Vector3.new(8500, 120, 4500)},
            {"🏰 Castle on the Sea", Vector3.new(4500, 50, 1200)},
            {"👻 Haunted Castle", Vector3.new(9800, 60, 5500)},
            {"🌑 Dark Arena", Vector3.new(10500, 100, 6000)},
            {"🐢 Floating Turtle", Vector3.new(11200, 90, 6500)},
            {"🦖 Prehistoric Island", Vector3.new(12500, 80, 7000)},
            {"🏜️ Desert Kingdom", Vector3.new(13800, 100, 7500)},
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
end
detectSea()

-- ============================================================
-- VARIÁVEIS
-- ============================================================
local range = 300
local kills = 0
local masteryType = "Fruit"
local espBills = {}
local threads = {}

local function stopThread(name)
    if threads[name] then
        threads[name].enabled = false
        task.cancel(threads[name].thread)
        threads[name] = nil
    end
end

local function startThread(name, loopFunc, delay)
    stopThread(name)
    local data = {enabled = true}
    data.thread = task.spawn(function()
        while data.enabled do
            pcall(loopFunc)
            task.wait(delay or 0.1)
        end
    end)
    threads[name] = data
end

-- ============================================================
-- TELEPORTE + VOO
-- ============================================================
local function tp(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 25, 0))
            task.wait(0.1)
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            task.wait(0.05)
            hrp.CFrame = CFrame.new(pos)
        end
    end)
end

local function flyTo(pos)
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
        local startPos = hrp.Position
        local targetPos = pos + Vector3.new(0, 50, 0)
        local steps = math.max(math.floor((targetPos - startPos).Magnitude / 20), 5)
        for i = 1, steps do
            hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, i / steps) + Vector3.new(0, math.sin(i/steps*math.pi)*15, 0))
            task.wait(0.05)
        end
        for i = 1, 10 do
            hrp.CFrame = CFrame.new(targetPos:Lerp(pos, i / 10))
            task.wait(0.03)
        end
        hrp.CFrame = CFrame.new(pos)
    end)
end

-- ============================================================
-- ATAQUE
-- ============================================================
local function attack()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        kills = kills + 1
    end)
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

-- ============================================================
-- SUPER FARM
-- ============================================================
local SuperFarm = {boxPart=nil, collectedMobs={}, phase="quest", mobsKilled=0, mobsNeeded=10, lastQuestTime=0}

function startSuperFarm()
    startThread("superFarm", function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character.HumanoidRootPart
        
        if not SuperFarm.boxPart or not SuperFarm.boxPart.Parent then
            local part = Instance.new("Part", Workspace)
            part.Name="FarmBox" part.Size=Vector3.new(5,3,5) part.Anchored=true part.CanCollide=false part.Transparency=1
            SuperFarm.boxPart=part
        end
        
        SuperFarm.boxPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0))
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(SuperFarm.boxPart.Position + Vector3.new(0, 1.5, 0)), 0.3)
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) hum.Health = hum.MaxHealth end
        
        if SuperFarm.phase == "quest" and tick() - SuperFarm.lastQuestTime > 45 then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and (obj:FindFirstChild("Quest") or obj:FindFirstChild("QuestGiver")) then
                    if obj:FindFirstChild("HumanoidRootPart") then
                        flyTo(obj.HumanoidRootPart.Position + Vector3.new(3, 0, 0))
                        task.wait(1)
                        local r = ReplicatedStorage:FindFirstChild("Remotes")
                        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest", obj.Name) end
                        SuperFarm.lastQuestTime = tick() SuperFarm.mobsKilled = 0 SuperFarm.phase = "collect"
                        break
                    end
                end
            end
        end
        
        if SuperFarm.phase == "collect" then
            local count = 0
            local boxPos = SuperFarm.boxPart.Position
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= player.Character then
                    local mHrp = obj:FindFirstChild("HumanoidRootPart")
                    local mHum = obj:FindFirstChild("Humanoid")
                    if mHrp and mHum and mHum.Health > 0 and not (obj:FindFirstChild("Quest") or obj:FindFirstChild("QuestGiver")) then
                        if (mHrp.Position - hrp.Position).Magnitude <= range and not SuperFarm.collectedMobs[obj] then
                            mHrp.CFrame = CFrame.new(boxPos + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
                            SuperFarm.collectedMobs[obj] = true count = count + 1
                            if count >= 8 then break end
                        end
                    end
                end
            end
            if count > 0 then SuperFarm.phase = "attack" end
        end
        
        if SuperFarm.phase == "attack" then
            local alive = 0
            for obj, _ in pairs(SuperFarm.collectedMobs) do
                if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then attack() alive = alive + 1
                else SuperFarm.collectedMobs[obj] = nil SuperFarm.mobsKilled = SuperFarm.mobsKilled + 1 end
            end
            if alive <= 2 then SuperFarm.phase = "collect" end
            if SuperFarm.mobsKilled >= SuperFarm.mobsNeeded then SuperFarm.phase = "quest" SuperFarm.mobsKilled = 0 SuperFarm.collectedMobs = {} end
        end
    end, 0.15)
end

function stopSuperFarm()
    stopThread("superFarm")
    if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart = nil end
    SuperFarm.collectedMobs = {} SuperFarm.phase = "quest"
end

-- ============================================================
-- DEMAIS FUNÇÕES
-- ============================================================
function startGodmode() startThread("godmode", function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=hum.MaxHealth end end end, 0.1) end
function stopGodmode() stopThread("godmode") end

function startKillAura() startThread("killAura", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end local hrp=player.Character.HumanoidRootPart for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o~=player.Character then local oh=o:FindFirstChild("Humanoid") local orp=o:FindFirstChild("HumanoidRootPart") if oh and orp and oh.Health>0 and(orp.Position-hrp.Position).Magnitude<range then hrp.CFrame=CFrame.new(hrp.Position,orp.Position) attack() end end end end, 0.1) end
function stopKillAura() stopThread("killAura") end

function startAimlock() startThread("aimlock", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end local hrp=player.Character.HumanoidRootPart local tgt,s=nil,range for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o~=player.Character then local oh=o:FindFirstChild("Humanoid") local orp=o:FindFirstChild("HumanoidRootPart") if oh and orp and oh.Health>0 then local d=(orp.Position-hrp.Position).Magnitude if d<s then s=d tgt=o end end end end if tgt and tgt:FindFirstChild("HumanoidRootPart") then hrp.CFrame=CFrame.new(hrp.Position,tgt.HumanoidRootPart.Position) end end, 0.05) end
function stopAimlock() stopThread("aimlock") end

function startNoclip() startThread("noclip", function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end, 0.3) end
function stopNoclip() stopThread("noclip") pcall(function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end) end

function startWalkspeed() startThread("walkspeed", function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=100 end end end, 0.3) end
function stopWalkspeed() stopThread("walkspeed") pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=16 end end end) end

function startJumpspeed() startThread("jumpspeed", function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower=150 end end end, 0.3) end
function stopJumpspeed() stopThread("jumpspeed") pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower=50 end end end) end

function startFly() startThread("fly", function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end end end, 0.1) end
function stopFly() stopThread("fly") end

function startFragmentFarm() startThread("fragment", function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end, 60) end
function stopFragmentFarm() stopThread("fragment") end

function startBonesFarm() startThread("bones", function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end, 30) end
function stopBonesFarm() stopThread("bones") end

function startAutoHaki() startThread("haki", function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Observation") end end, 120) end
function stopAutoHaki() stopThread("haki") end

function startBountyHunt() startThread("bounty", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end local best,bd=nil,math.huge for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d=(p.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<bd then best=p bd=d end end end if best then flyTo(best.Character.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end, 10) end
function stopBountyHunt() stopThread("bounty") end

-- ============================================================
-- BOSS FARM INDIVIDUAL
-- ============================================================
local bossFarmList = {}
for _, name in pairs(SEA_DATA[currentSea].bosses) do
    bossFarmList[name] = false
end

function startBossFarm(name)
    startThread("boss_" .. name:gsub(" ", "_"), function()
        local b = findBoss(name)
        if b then tp(b.HumanoidRootPart.Position) for _ = 1, 8 do attack() task.wait(0.3) end end
    end, 5)
end

function stopBossFarm(name)
    stopThread("boss_" .. name:gsub(" ", "_"))
end

-- ============================================================
-- SEA EVENT FARM
-- ============================================================
function startSeaFarm(name)
    startThread("sea_" .. name:gsub(" ", "_"), function()
        local s = findSea(name)
        if s then tp(s.HumanoidRootPart.Position) for _ = 1, 5 do attack() task.wait(0.3) end end
    end, 10)
end

function stopSeaFarm(name)
    stopThread("sea_" .. name:gsub(" ", "_"))
end

-- ============================================================
-- ESP
-- ============================================================
local espThreads = {}
function startESP(filter, color)
    if espThreads[filter] then stopESP(filter) end
    espThreads[filter] = {enabled = true}
    espThreads[filter].thread = task.spawn(function()
        while espThreads[filter] and espThreads[filter].enabled do
            pcall(function()
                local count = 0
                for _, o in pairs(Workspace:GetDescendants()) do
                    if count > 8 then break end
                    if o:IsA("Model") and o:FindFirstChild("Head") and o ~= player.Character and not espBills[o] then
                        local show = false
                        if filter == "players" then show = Players:GetPlayerFromCharacter(o) ~= nil
                        elseif filter == "fruits" then show = o.Name:find("Fruit") ~= nil
                        elseif filter == "chests" then show = o.Name:lower():find("chest") ~= nil
                        elseif filter == "bosses" then show = o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth > 10000
                        end
                        if show then
                            local bill = Instance.new("BillboardGui", CoreGui)
                            bill.Adornee = o.Head
                            bill.Size = UDim2.new(0, 60, 0, 18)
                            bill.AlwaysOnTop = true
                            bill.MaxDistance = range
                            local label = Instance.new("TextLabel", bill)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 0.7
                            label.BackgroundColor3 = color
                            label.TextColor3 = Color3.new(1, 1, 1)
                            label.TextSize = 8
                            label.Font = Enum.Font.GothamBold
                            label.Text = o.Name
                            espBills[o] = bill
                            count = count + 1
                        end
                    end
                end
                for o, b in pairs(espBills) do
                    if type(o) ~= "string" then
                        pcall(function() if not o.Parent or (o:FindFirstChild("Humanoid") and o.Humanoid.Health <= 0) then b:Destroy() espBills[o] = nil end end)
                    end
                end
            end)
            task.wait(3)
        end
        for o, b in pairs(espBills) do pcall(function() b:Destroy() end) espBills[o] = nil end
    end)
end
function stopESP(filter) if espThreads[filter] then espThreads[filter].enabled = false task.cancel(espThreads[filter].thread) espThreads[filter] = nil end end

-- ============================================================
-- DESLIGAR TUDO
-- ============================================================
local function disableAll()
    stopSuperFarm() stopGodmode() stopKillAura() stopAimlock() stopNoclip() stopWalkspeed() stopJumpspeed() stopFly()
    stopFragmentFarm() stopBonesFarm() stopAutoHaki() stopBountyHunt()
    for _, name in pairs(SEA_DATA[currentSea].bosses) do stopBossFarm(name) end
    stopESP("players") stopESP("fruits") stopESP("chests") stopESP("bosses")
    notify("NEXUS", "Tudo desligado!", 3)
end

-- ============================================================
-- UI COMPLETA
-- ============================================================
local win = NexusUI:CreateWindow({Title="NEXUS v7.0.9 PRO", Subtitle=SEA_DATA[currentSea].name.." | Completo", Width=580, Height=500})
local tabs={}
for _,t in pairs({{"⚔️ Farm"},{"🎯 Bosses"},{"🌊 Sea"},{"💎 Farms"},{"🏃 Move"},{"⚙️ Auto"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]]=NexusUI:CreateTab(win,{Name=t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Farm"],"SUPER FARM")
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="🚀 Super Farm",Callback=function(v) if v then startSuperFarm() else stopSuperFarm() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="💀 Kill Aura",Callback=function(v) if v then startKillAura() else stopKillAura() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="🛡️ Godmode",Callback=function(v) if v then startGodmode() else stopGodmode() end end})

NexusUI:CreateSection(tabs["🎯 Bosses"],"BOSSES DO "..SEA_DATA[currentSea].name:upper())
for _, name in pairs(SEA_DATA[currentSea].bosses) do
    NexusUI:CreateToggle(tabs["🎯 Bosses"],{Title="🎯 "..name,Callback=function(v) if v then startBossFarm(name) else stopBossFarm(name) end end})
end

NexusUI:CreateSection(tabs["🌊 Sea"],"SEA EVENTS")
for _, name in pairs({"Marine Ship","Pirate Ship","Sea Beast","Terror Shark","Rumbling","Mansion","Pirate Raid","Sea Castle"}) do
    NexusUI:CreateToggle(tabs["🌊 Sea"],{Title="🌊 "..name,Callback=function(v) if v then startSeaFarm(name) else stopSeaFarm(name) end end})
end

NexusUI:CreateSection(tabs["💎 Farms"],"FARMS")
NexusUI:CreateToggle(tabs["💎 Farms"],{Title="💎 Fragmentos",Callback=function(v) if v then startFragmentFarm() else stopFragmentFarm() end end})
NexusUI:CreateToggle(tabs["💎 Farms"],{Title="🦴 Ossos",Callback=function(v) if v then startBonesFarm() else stopBonesFarm() end end})

NexusUI:CreateSection(tabs["🏃 Move"],"MOVIMENTAÇÃO")
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="✈️ Fly",Callback=function(v) if v then startFly() else stopFly() end end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="🏃 Walkspeed",Callback=function(v) if v then startWalkspeed() else stopWalkspeed() end end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="🦘 Jumpspeed",Callback=function(v) if v then startJumpspeed() else stopJumpspeed() end end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="🚫 No Clip",Callback=function(v) if v then startNoclip() else stopNoclip() end end})

NexusUI:CreateSection(tabs["⚙️ Auto"],"AUTOMAÇÕES")
NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title="🔮 Auto Haki",Callback=function(v) if v then startAutoHaki() else stopAutoHaki() end end})

NexusUI:CreateSection(tabs["👀 Visual"],"ESP")
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="👁️ ESP Players",Callback=function(v) if v then startESP("players",Color3.fromRGB(255,0,0)) else stopESP("players") end end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="🍎 ESP Fruits",Callback=function(v) if v then startESP("fruits",Color3.fromRGB(255,0,255)) else stopESP("fruits") end end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="📦 ESP Chests",Callback=function(v) if v then startESP("chests",Color3.fromRGB(255,215,0)) else stopESP("chests") end end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="🎯 ESP Bosses",Callback=function(v) if v then startESP("bosses",Color3.fromRGB(255,50,50)) else stopESP("bosses") end end})

NexusUI:CreateSection(tabs["🎮 Extra"],"FUNÇÕES")
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="🎯 Aimlock",Callback=function(v) if v then startAimlock() else stopAimlock() end end})
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="💰 Bounty Hunt",Callback=function(v) if v then startBountyHunt() else stopBountyHunt() end end})
NexusUI:CreateDropdown(tabs["🎮 Extra"],{Title="Maestria",Options={"Fruit","Sword","Gun","Melee"},Default=masteryType,Callback=function(v)masteryType=v end})
NexusUI:CreateSlider(tabs["🎮 Extra"],{Title="Alcance",Min=50,Max=500,Default=300,Callback=function(v)range=v end})
NexusUI:CreateButton(tabs["🎮 Extra"],{Title="🛑 DESLIGAR TUDO",Callback=disableAll})

NexusUI:CreateSection(tabs["🏝️ Ilhas"],"🏝️ ILHAS DO "..SEA_DATA[currentSea].name:upper().." ("..#SEA_DATA[currentSea].islands.." ilhas)")
for _,il in pairs(SEA_DATA[currentSea].islands) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"],{Title="🏝️ "..il[1],Callback=function()flyTo(il[2])notify("✈️","Voando para "..il[1],3)end})
end

notify("NEXUS v7.0.9 PRO","Tudo restaurado! | "..SEA_DATA[currentSea].name.." | "..#SEA_DATA[currentSea].islands.." ilhas | "..#SEA_DATA[currentSea].bosses.." bosses",5)
print("NEXUS v7.0.9 PRO - Completo - Loaded")
