-- ============================================================
-- NEXUS v7.0.9 PRO - COMPLETO PROFISSIONAL (START/STOP THREADS)
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local CONFIG = {
    VERSION = "7.0.9 PRO",
    DEFAULT_RANGE = 300,
    FLIGHT_SPEED = 100,
    FLIGHT_HEIGHT = 50,
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
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function notify(t, txt, d) pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "NEXUS", Text = txt or "", Duration = d or 3}) end) end

-- ============================================================
-- ANTI-AFK (SEMPRE ATIVO)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(math.random(120, 300))
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:Move(Vector3.new(math.random(-1,1),0,math.random(-1,1)), true)
                task.wait(0.3)
                player.Character.Humanoid:Move(Vector3.zero, true)
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
    if Workspace.Terrain then Workspace.Terrain.WaterWaveSize = 0 Workspace.Terrain.GrassLength = 0 end
end)

-- ============================================================
-- SISTEMA DE VOO
-- ============================================================
local FlightSystem = {flying = false}
function FlightSystem.flyTo(pos)
    FlightSystem.flying = true
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
        local startPos = hrp.Position
        local targetPos = pos + Vector3.new(0, CONFIG.FLIGHT_HEIGHT, 0)
        local steps = math.max(math.floor((targetPos - startPos).Magnitude / 20), 5)
        for i = 1, steps do
            if not FlightSystem.flying then break end
            hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, i / steps) + Vector3.new(0, math.sin(i/steps*math.pi)*15, 0))
            task.wait(0.05)
        end
        for i = 1, 10 do
            if not FlightSystem.flying then break end
            hrp.CFrame = CFrame.new(targetPos:Lerp(pos, i / 10))
            task.wait(0.03)
        end
        hrp.CFrame = CFrame.new(pos)
        FlightSystem.flying = false
    end)
end

-- ============================================================
-- DADOS DOS SEAS
-- ============================================================
local SEA_DATA = {
    [1] = {name="First Sea", islands={{"🏴‍☠️ Pirate Starter",Vector3.new(1289,11,4191)},{"🌴 Jungle",Vector3.new(-1250,15,3850)},{"🏜️ Desert",Vector3.new(966,10,1100)},{"❄️ Frozen Village",Vector3.new(1150,25,4350)},{"🔒 Prison",Vector3.new(-5400,15,-1700)},{"☁️ Skylands",Vector3.new(-4850,750,1950)}}, fruits={"Flame-Fruit","Ice-Fruit","Dark-Fruit","Light-Fruit","Magma-Fruit","Rumble-Fruit"}},
    [2] = {name="Second Sea", islands={{"🌹 Kingdom of Rose",Vector3.new(-1400,10,-1400)},{"🌿 Green Zone",Vector3.new(6200,80,2500)},{"🏯 Ice Castle",Vector3.new(7200,100,3500)},{"🗿 Forgotten Island",Vector3.new(8500,120,4500)},{"☕ Cafe",Vector3.new(-570,310,-1220)}}, fruits={"Buddha-Fruit","Portal-Fruit","Blizzard-Fruit","Phoenix-Fruit","Pain-Fruit"}},
    [3] = {name="Third Sea", islands={{"⚓ Port Town",Vector3.new(7200,100,3500)},{"🐉 Hydra Island",Vector3.new(6200,80,2500)},{"🌳 Great Tree",Vector3.new(8500,120,4500)},{"🏰 Castle on the Sea",Vector3.new(4500,50,1200)},{"👻 Haunted Castle",Vector3.new(9800,60,5500)},{"🌑 Dark Arena",Vector3.new(10500,100,6000)}}, fruits={"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit"}},
}

local currentSea = 1
local function detectSea()
    local lvl = 1
    pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl = player.Data.Level.Value end end)
    if lvl <= 700 then currentSea = 1 elseif lvl <= 1500 then currentSea = 2 else currentSea = 3 end
end
detectSea()

-- ============================================================
-- VARIÁVEIS DE ESTADO + THREADS
-- ============================================================
local range = CONFIG.DEFAULT_RANGE
local masteryType = "Fruit"
local kills = 0

local Functions = {}
local function createFunction(name) Functions[name] = {enabled = false, thread = nil} end

createFunction("godmode")
createFunction("killAura")
createFunction("superFarm")
createFunction("aimlock")
createFunction("noclip")
createFunction("walkspeed")
createFunction("jumpspeed")
createFunction("fly")
createFunction("bountyHunt")
createFunction("autoHaki")
createFunction("autoSkill")
createFunction("autoQuest")
createFunction("fragmentFarm")
createFunction("bonesFarm")
createFunction("shopFruits")
createFunction("shopStats")
createFunction("espPlayers")
createFunction("espFruits")
createFunction("espChests")
createFunction("espBosses")

-- ============================================================
-- FUNÇÕES START/STOP
-- ============================================================

-- GODMODE
function startGodmode()
    Functions.godmode.thread = task.spawn(function()
        while Functions.godmode.enabled do
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = hum.MaxHealth end
                end
            end)
            task.wait(0.1)
        end
    end)
end
function stopGodmode() Functions.godmode.enabled = false if Functions.godmode.thread then task.cancel(Functions.godmode.thread) end end

-- KILL AURA
function startKillAura()
    Functions.killAura.thread = task.spawn(function()
        while Functions.killAura.enabled do
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then task.wait(0.3) continue end
                local hrp = player.Character.HumanoidRootPart
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Model") and o ~= player.Character then
                        local oh = o:FindFirstChild("Humanoid")
                        local orp = o:FindFirstChild("HumanoidRootPart")
                        if oh and orp and oh.Health > 0 and (orp.Position - hrp.Position).Magnitude < range then
                            hrp.CFrame = CFrame.new(hrp.Position, orp.Position)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                            task.wait(0.05)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                            kills = kills + 1
                            task.wait(0.1)
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end
function stopKillAura() Functions.killAura.enabled = false if Functions.killAura.thread then task.cancel(Functions.killAura.thread) end end

-- SUPER FARM
local SuperFarm = {boxPart=nil, boxSize=Vector3.new(5,3,5), flyHeight=1.5, collectedMobs={}, phase="quest", mobsKilled=0, mobsNeeded=10, lastQuestTime=0, questCooldown=45}

function SuperFarm.createBox()
    if SuperFarm.boxPart and SuperFarm.boxPart.Parent then SuperFarm.boxPart:Destroy() end
    local part = Instance.new("Part", Workspace)
    part.Name="FarmBox" part.Size=SuperFarm.boxSize part.Anchored=true part.CanCollide=false part.Transparency=1
    SuperFarm.boxPart=part
end
function SuperFarm.positionBox()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not SuperFarm.boxPart then return end
    SuperFarm.boxPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position+Vector3.new(0,SuperFarm.flyHeight,0))
end
function SuperFarm.flyPlayer()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not SuperFarm.boxPart then return end
    local hrp=player.Character.HumanoidRootPart
    hrp.CFrame=hrp.CFrame:Lerp(CFrame.new(SuperFarm.boxPart.Position+Vector3.new(0,SuperFarm.flyHeight,0)),0.3)
    local hum=player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
end
function SuperFarm.getQuest()
    if tick()-SuperFarm.lastQuestTime<SuperFarm.questCooldown then return end
    SuperFarm.lastQuestTime=tick()
    pcall(function()
        local nearest,shortest=nil,500
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and(obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")) then
                if obj:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local d=(obj.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude
                    if d<shortest then shortest=d nearest=obj end
                end
            end
        end
        if nearest then
            FlightSystem.flyTo(nearest.HumanoidRootPart.Position+Vector3.new(3,0,0)) task.wait(1)
            local r=ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest",nearest.Name) end
            task.wait(0.5)
            if SuperFarm.boxPart then FlightSystem.flyTo(SuperFarm.boxPart.Position+Vector3.new(0,SuperFarm.flyHeight,0)) end
            SuperFarm.mobsKilled=0 SuperFarm.phase="collect"
        end
    end)
end
function SuperFarm.collectMobs()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not SuperFarm.boxPart then return end
    local hrp=player.Character.HumanoidRootPart local boxPos=SuperFarm.boxPart.Position local count=0
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj~=player.Character then
            local mHrp,mHum=obj:FindFirstChild("HumanoidRootPart"),obj:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health>0 then
                if not(obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")) then
                    local dist=(mHrp.Position-hrp.Position).Magnitude
                    if dist<=range and not SuperFarm.collectedMobs[obj] then
                        mHrp.CFrame=CFrame.new(boxPos+Vector3.new(math.random(-2,2),0,math.random(-2,2)))
                        SuperFarm.collectedMobs[obj]=true count=count+1
                        if count>=8 then break end
                    end
                end
            end
        end
    end
    if count>0 then SuperFarm.phase="attack" end
end
function SuperFarm.attackMobs()
    if not SuperFarm.boxPart then return end
    local aliveCount=0
    for obj,_ in pairs(SuperFarm.collectedMobs) do
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health>0 then
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(0.05) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
            kills=kills+1 aliveCount=aliveCount+1
            if math.random()>0.7 then VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.Z,false,game) task.wait(0.1) VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.Z,false,game) end
        else SuperFarm.collectedMobs[obj]=nil SuperFarm.mobsKilled=SuperFarm.mobsKilled+1 end
    end
    if aliveCount<=2 then SuperFarm.phase="collect" end
    if SuperFarm.mobsKilled>=SuperFarm.mobsNeeded then SuperFarm.phase="quest" SuperFarm.mobsKilled=0 SuperFarm.collectedMobs={} end
end

function startSuperFarm()
    Functions.superFarm.thread = task.spawn(function()
        while Functions.superFarm.enabled do
            pcall(function()
                SuperFarm.createBox()
                SuperFarm.positionBox()
                SuperFarm.flyPlayer()
                if SuperFarm.phase=="quest" then SuperFarm.getQuest()
                elseif SuperFarm.phase=="collect" then SuperFarm.collectMobs()
                elseif SuperFarm.phase=="attack" then SuperFarm.attackMobs() end
            end)
            task.wait(0.15)
        end
        if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end
        SuperFarm.collectedMobs={} SuperFarm.phase="quest"
    end)
end
function stopSuperFarm()
    Functions.superFarm.enabled = false
    if Functions.superFarm.thread then task.cancel(Functions.superFarm.thread) end
    if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end
    SuperFarm.collectedMobs={} SuperFarm.phase="quest"
end

-- AIMLOCK
function startAimlock()
    Functions.aimlock.thread = task.spawn(function()
        while Functions.aimlock.enabled do
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then task.wait(0.1) continue end
                local hrp = player.Character.HumanoidRootPart
                local tgt, s = nil, range
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Model") and o ~= player.Character then
                        local oh = o:FindFirstChild("Humanoid")
                        local orp = o:FindFirstChild("HumanoidRootPart")
                        if oh and orp and oh.Health > 0 then
                            local d = (orp.Position - hrp.Position).Magnitude
                            if d < s then s = d tgt = o end
                        end
                    end
                end
                if tgt and tgt:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = CFrame.new(hrp.Position, tgt.HumanoidRootPart.Position)
                end
            end)
            task.wait(0.05)
        end
    end)
end
function stopAimlock() Functions.aimlock.enabled = false if Functions.aimlock.thread then task.cancel(Functions.aimlock.thread) end end

-- NO CLIP
function startNoclip()
    Functions.noclip.thread = task.spawn(function()
        while Functions.noclip.enabled do
            pcall(function()
                if player.Character then
                    for _, p in pairs(player.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
            task.wait(0.3)
        end
        pcall(function()
            if player.Character then
                for _, p in pairs(player.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end)
    end)
end
function stopNoclip()
    Functions.noclip.enabled = false
    if Functions.noclip.thread then task.cancel(Functions.noclip.thread) end
    pcall(function()
        if player.Character then
            for _, p in pairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end)
end

-- WALKSPEED
function startWalkspeed()
    Functions.walkspeed.thread = task.spawn(function()
        while Functions.walkspeed.enabled do
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 100 end
                end
            end)
            task.wait(0.3)
        end
        pcall(function()
            if player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end)
    end)
end
function stopWalkspeed()
    Functions.walkspeed.enabled = false
    if Functions.walkspeed.thread then task.cancel(Functions.walkspeed.thread) end
    pcall(function()
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end)
end

-- JUMPSPEED
function startJumpspeed()
    Functions.jumpspeed.thread = task.spawn(function()
        while Functions.jumpspeed.enabled do
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.JumpPower = 150 end
                end
            end)
            task.wait(0.3)
        end
        pcall(function()
            if player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = 50 end
            end
        end)
    end)
end
function stopJumpspeed()
    Functions.jumpspeed.enabled = false
    if Functions.jumpspeed.thread then task.cancel(Functions.jumpspeed.thread) end
    pcall(function()
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end)
end

-- FLY
function startFly()
    Functions.fly.thread = task.spawn(function()
        while Functions.fly.enabled do
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                    if hrp and hrp.Velocity.Y < -5 then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 10, hrp.Velocity.Z)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end
function stopFly() Functions.fly.enabled = false if Functions.fly.thread then task.cancel(Functions.fly.thread) end end

-- BOUNTY HUNT
function startBountyHunt()
    Functions.bountyHunt.thread = task.spawn(function()
        while Functions.bountyHunt.enabled do
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then task.wait(1) continue end
                local best, bd = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if d < bd then best = p bd = d end
                    end
                end
                if best then
                    FlightSystem.flyTo(best.Character.HumanoidRootPart.Position)
                    for _ = 1, 5 do
                        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                        task.wait(0.3)
                    end
                end
            end)
            task.wait(5)
        end
    end)
end
function stopBountyHunt() Functions.bountyHunt.enabled = false if Functions.bountyHunt.thread then task.cancel(Functions.bountyHunt.thread) end end

-- AUTO HAKI
function startAutoHaki()
    Functions.autoHaki.thread = task.spawn(function()
        while Functions.autoHaki.enabled do
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("ActivateHaki", "Ken")
                    r.CommF_:InvokeServer("ActivateHaki", "Observation")
                end
            end)
            task.wait(60)
        end
    end)
end
function stopAutoHaki() Functions.autoHaki.enabled = false if Functions.autoHaki.thread then task.cancel(Functions.autoHaki.thread) end end

-- AUTO SKILL
function startAutoSkill()
    Functions.autoSkill.thread = task.spawn(function()
        while Functions.autoSkill.enabled do
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                task.wait(0.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                task.wait(0.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
            end)
            task.wait(2)
        end
    end)
end
function stopAutoSkill() Functions.autoSkill.enabled = false if Functions.autoSkill.thread then task.cancel(Functions.autoSkill.thread) end end

-- AUTO QUEST
function startAutoQuest()
    Functions.autoQuest.thread = task.spawn(function()
        while Functions.autoQuest.enabled do
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and (obj:FindFirstChild("Quest") or obj:FindFirstChild("QuestGiver")) then
                        if obj:FindFirstChild("HumanoidRootPart") then
                            FlightSystem.flyTo(obj.HumanoidRootPart.Position + Vector3.new(3, 0, 0))
                            task.wait(1)
                            local r = ReplicatedStorage:FindFirstChild("Remotes")
                            if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest", obj.Name) end
                            break
                        end
                    end
                end
            end)
            task.wait(30)
        end
    end)
end
function stopAutoQuest() Functions.autoQuest.enabled = false if Functions.autoQuest.thread then task.cancel(Functions.autoQuest.thread) end end

-- FRAGMENT FARM
function startFragmentFarm()
    Functions.fragmentFarm.thread = task.spawn(function()
        while Functions.fragmentFarm.enabled do
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments", 500) end
            end)
            task.wait(60)
        end
    end)
end
function stopFragmentFarm() Functions.fragmentFarm.enabled = false if Functions.fragmentFarm.thread then task.cancel(Functions.fragmentFarm.thread) end end

-- BONES FARM
function startBonesFarm()
    Functions.bonesFarm.thread = task.spawn(function()
        while Functions.bonesFarm.enabled do
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones", 50) end
            end)
            task.wait(30)
        end
    end)
end
function stopBonesFarm() Functions.bonesFarm.enabled = false if Functions.bonesFarm.thread then task.cancel(Functions.bonesFarm.thread) end end

-- SHOP FRUITS
function startShopFruits()
    Functions.shopFruits.thread = task.spawn(function()
        while Functions.shopFruits.enabled do
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then
                    r.CommF_:InvokeServer("BuyItem", "Kitsune")
                    task.wait(1)
                    r.CommF_:InvokeServer("BuyItem", "Dragon")
                end
            end)
            task.wait(300)
        end
    end)
end
function stopShopFruits() Functions.shopFruits.enabled = false if Functions.shopFruits.thread then task.cancel(Functions.shopFruits.thread) end end

-- SHOP STATS
function startShopStats()
    Functions.shopStats.thread = task.spawn(function()
        while Functions.shopStats.enabled do
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint", "Melee", 1) end
            end)
            task.wait(2)
        end
    end)
end
function stopShopStats() Functions.shopStats.enabled = false if Functions.shopStats.thread then task.cancel(Functions.shopStats.thread) end end

-- ============================================================
-- ESP
-- ============================================================
local espBills = {}
local MAX_ESP = 8

function createESP(color, filter)
    task.spawn(function()
        while Functions[filter] and Functions[filter].enabled do
            pcall(function()
                local count = 0
                for _, o in pairs(Workspace:GetDescendants()) do
                    if count > MAX_ESP then break end
                    if o:IsA("Model") and o:FindFirstChild("Head") and o ~= player.Character and not espBills[o] then
                        local show = false
                        if filter == "espPlayers" then show = Players:GetPlayerFromCharacter(o) ~= nil
                        elseif filter == "espFruits" then show = o.Name:find("Fruit") ~= nil
                        elseif filter == "espChests" then show = o.Name:lower():find("chest") ~= nil
                        elseif filter == "espBosses" then show = o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth > 10000
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
        for o, b in pairs(espBills) do pcall(function() b:Destroy() end) espBills[o] = nil end
    end)
end

function startESP(filter, color)
    Functions[filter].enabled = true
    createESP(color, filter)
end
function stopESP(filter)
    Functions[filter].enabled = false
end

-- ============================================================
-- DESLIGAR TUDO
-- ============================================================
local function disableAll()
    stopGodmode()
    stopKillAura()
    stopSuperFarm()
    stopAimlock()
    stopNoclip()
    stopWalkspeed()
    stopJumpspeed()
    stopFly()
    stopBountyHunt()
    stopAutoHaki()
    stopAutoSkill()
    stopAutoQuest()
    stopFragmentFarm()
    stopBonesFarm()
    stopShopFruits()
    stopShopStats()
    stopESP("espPlayers")
    stopESP("espFruits")
    stopESP("espChests")
    stopESP("espBosses")
    notify("NEXUS", "Tudo desligado!", 3)
end

-- ============================================================
-- UI
-- ============================================================
local win = NexusUI:CreateWindow({Title="NEXUS v7.0.9 PRO",Subtitle=SEA_DATA[currentSea].name.." | Start/Stop Threads",Width=580,Height=500})
local tabs={}
for _,t in pairs({{"⚔️ Super Farm"},{"💎 Farms"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]]=NexusUI:CreateTab(win,{Name=t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Super Farm"],"🚀 SUPER FARM")
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🚀 SUPER FARM",Callback=function(v) if v then Functions.superFarm.enabled=true startSuperFarm() else stopSuperFarm() end end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="💀 Kill Aura",Callback=function(v) if v then Functions.killAura.enabled=true startKillAura() else stopKillAura() end end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🛡️ Godmode",Callback=function(v) if v then Functions.godmode.enabled=true startGodmode() else stopGodmode() end end})

NexusUI:CreateSection(tabs["💎 Farms"],"💎 FARMS")
NexusUI:CreateToggle(tabs["💎 Farms"],{Title="💎 Fragmentos",Callback=function(v) if v then Functions.fragmentFarm.enabled=true startFragmentFarm() else stopFragmentFarm() end end})
NexusUI:CreateToggle(tabs["💎 Farms"],{Title="🦴 Ossos",Callback=function(v) if v then Functions.bonesFarm.enabled=true startBonesFarm() else stopBonesFarm() end end})

NexusUI:CreateSection(tabs["🏃 Move"],"🏃 MOVIMENTAÇÃO")
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="✈️ Fly",Callback=function(v) if v then Functions.fly.enabled=true startFly() else stopFly() end end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="🏃 Walkspeed",Callback=function(v) if v then Functions.walkspeed.enabled=true startWalkspeed() else stopWalkspeed() end end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="🦘 Jumpspeed",Callback=function(v) if v then Functions.jumpspeed.enabled=true startJumpspeed() else stopJumpspeed() end end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="🚫 No Clip",Callback=function(v) if v then Functions.noclip.enabled=true startNoclip() else stopNoclip() end end})

NexusUI:CreateSection(tabs["⚙️ Auto"],"⚙️ AUTOMAÇÕES")
NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title="🔮 Auto Haki",Callback=function(v) if v then Functions.autoHaki.enabled=true startAutoHaki() else stopAutoHaki() end end})
NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title="⭐ Auto Skill",Callback=function(v) if v then Functions.autoSkill.enabled=true startAutoSkill() else stopAutoSkill() end end})
NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title="📋 Auto Quest",Callback=function(v) if v then Functions.autoQuest.enabled=true startAutoQuest() else stopAutoQuest() end end})

NexusUI:CreateSection(tabs["🛍️ Loja"],"🛍️ AUTO COMPRAR")
NexusUI:CreateToggle(tabs["🛍️ Loja"],{Title="🛒 Buy Fruits",Callback=function(v) if v then Functions.shopFruits.enabled=true startShopFruits() else stopShopFruits() end end})
NexusUI:CreateToggle(tabs["🛍️ Loja"],{Title="📊 Buy Stats",Callback=function(v) if v then Functions.shopStats.enabled=true startShopStats() else stopShopStats() end end})

NexusUI:CreateSection(tabs["👀 Visual"],"👀 ESP")
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="👁️ ESP Players",Callback=function(v) if v then startESP("espPlayers",Color3.fromRGB(255,0,0)) else stopESP("espPlayers") end end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="🍎 ESP Fruits",Callback=function(v) if v then startESP("espFruits",Color3.fromRGB(255,0,255)) else stopESP("espFruits") end end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="📦 ESP Chests",Callback=function(v) if v then startESP("espChests",Color3.fromRGB(255,215,0)) else stopESP("espChests") end end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="🎯 ESP Bosses",Callback=function(v) if v then startESP("espBosses",Color3.fromRGB(255,50,50)) else stopESP("espBosses") end end})

NexusUI:CreateSection(tabs["🎮 Extra"],"🎮 FUNÇÕES")
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="🎯 Aimlock",Callback=function(v) if v then Functions.aimlock.enabled=true startAimlock() else stopAimlock() end end})
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="💰 Bounty Hunt",Callback=function(v) if v then Functions.bountyHunt.enabled=true startBountyHunt() else stopBountyHunt() end end})
NexusUI:CreateDropdown(tabs["🎮 Extra"],{Title="Maestria",Options={"Fruit","Sword","Gun","Melee"},Default=masteryType,Callback=function(v)masteryType=v end})
NexusUI:CreateSlider(tabs["🎮 Extra"],{Title="Alcance",Min=50,Max=500,Default=300,Callback=function(v)range=v end})
NexusUI:CreateButton(tabs["🎮 Extra"],{Title="🛑 DESLIGAR TUDO",Callback=disableAll})

NexusUI:CreateSection(tabs["🏝️ Ilhas"],"🏝️ ILHAS DO "..SEA_DATA[currentSea].name:upper())
for _,il in pairs(SEA_DATA[currentSea].islands) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"],{Title="🏝️ "..il[1],Callback=function()FlightSystem.flyTo(il[2])notify("✈️","Voando para "..il[1],3)end})
end

notify("NEXUS v7.0.9 PRO","Start/Stop Threads | Liga/Desliga Imediato | "..SEA_DATA[currentSea].name,5)
print("NEXUS v7.0.9 PRO - Loaded")
