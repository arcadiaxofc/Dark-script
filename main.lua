-- ============================================================
-- NEXUS v7.0.9 - COMPLETO COM VOO + ANTI-BAN PROFISSIONAL
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

local function randomDelay(min, max) return math.random(min * 1000, max * 1000) / 1000 end
local function notify(t, txt, d) pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "Stats", Text = txt or "", Duration = d or 3}) end) end

-- ============================================================
-- ANTI-BAN PROFISSIONAL (5 CAMADAS)
-- ============================================================
task.spawn(function() while true do task.wait(math.random(120,300)) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then local hum=player.Character.Humanoid local moveDir=Vector3.new(math.random(-1,1),0,math.random(-1,1)) hum:Move(moveDir,true) task.wait(math.random(150,400)/1000) hum:Move(Vector3.zero,true) if math.random()>0.6 then hum.Jump=true task.wait(0.2) hum.Jump=false end end end) end end)
task.spawn(function() while true do task.wait(math.random(20,45)) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local hrp=player.Character.HumanoidRootPart if hrp.Velocity.Magnitude>50 or hrp.AssemblyLinearVelocity.Magnitude>50 then hrp.Velocity=Vector3.zero hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end end end) end end)
task.spawn(function() while true do task.wait(math.random(60,180)) pcall(function() VirtualInputManager:SendMouseWheelEvent(math.random(-1,1),game) task.wait(0.1) VirtualInputManager:SendMouseMovement(math.random(-5,5),math.random(-5,5),game) end) end end)

local lastActionTime = 0
local function humanAttack() local now=tick() if now-lastActionTime<0.3 then return end lastActionTime=now pcall(function() if math.random()>0.5 then VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(math.random(4,8)/100) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) else VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.E,false,game) task.wait(math.random(4,8)/100) VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.E,false,game) end end) end

-- ============================================================
-- SISTEMA DE VOO
-- ============================================================
local FlightSystem = {flying=false,targetPos=nil}
function FlightSystem.flyTo(pos)
    FlightSystem.targetPos=pos FlightSystem.flying=true
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp=player.Character.HumanoidRootPart local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
        local startPos=hrp.Position local targetPos=pos+Vector3.new(0,CONFIG.FLIGHT_HEIGHT,0) local direction=(targetPos-startPos).Unit local distance=(targetPos-startPos).Magnitude local steps=math.max(math.floor(distance/20),5)
        for i=1,steps do if not FlightSystem.flying then break end local alpha=i/steps local currentTarget=startPos:Lerp(targetPos,alpha) local heightVariation=math.sin(alpha*math.pi)*15 currentTarget=currentTarget+Vector3.new(0,heightVariation,0) hrp.CFrame=CFrame.new(currentTarget) hrp.Velocity=direction*CONFIG.FLIGHT_SPEED task.wait(0.05) end
        for i=1,10 do if not FlightSystem.flying then break end local alpha=i/10 hrp.CFrame=CFrame.new(targetPos:Lerp(pos,alpha)) task.wait(0.03) end
        hrp.CFrame=CFrame.new(pos) hrp.Velocity=Vector3.zero FlightSystem.flying=false
        if hum then hum:Move(Vector3.new(math.random(-2,2),0,math.random(-2,2)),true) task.wait(0.2) hum:Move(Vector3.zero,true) end
    end)
end
function FlightSystem.stop() FlightSystem.flying=false FlightSystem.targetPos=nil end

-- ============================================================
-- OTIMIZAÇÃO
-- ============================================================
pcall(function() settings().Rendering.QualityLevel=1 Lighting.GlobalShadows=false Lighting.Brightness=2 if Workspace.Terrain then Workspace.Terrain.WaterWaveSize=0 Workspace.Terrain.GrassLength=0 end end)

-- ============================================================
-- DADOS DOS SEAS
-- ============================================================
local SEA_DATA={
    [1]={name="First Sea",levelRange={1,700},islands={{"Pirate Starter",Vector3.new(1289,11,4191)},{"Marine Starter",Vector3.new(-383,15,727)},{"Jungle",Vector3.new(-1250,15,3850)},{"Desert",Vector3.new(966,10,1100)},{"Frozen Village",Vector3.new(1150,25,4350)},{"Prison",Vector3.new(-5400,15,-1700)},{"Skylands",Vector3.new(-4850,750,1950)},{"Magma Village",Vector3.new(-3420,10,-2700)}},bosses={"Gorilla King","Yeti","Vice Admiral","Saber Expert","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"},fruits={"Flame-Fruit","Ice-Fruit","Dark-Fruit","Light-Fruit","Magma-Fruit","Rumble-Fruit"}},
    [2]={name="Second Sea",levelRange={701,1500},islands={{"Kingdom of Rose",Vector3.new(-1400,10,-1400)},{"Green Zone",Vector3.new(6200,80,2500)},{"Hot and Cold",Vector3.new(-3420,10,-2700)},{"Ice Castle",Vector3.new(7200,100,3500)},{"Forgotten Island",Vector3.new(8500,120,4500)},{"Cafe",Vector3.new(-570,310,-1220)}},bosses={"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"},fruits={"Buddha-Fruit","Portal-Fruit","Blizzard-Fruit","Phoenix-Fruit","Pain-Fruit"}},
    [3]={name="Third Sea",levelRange={1501,2600},islands={{"Port Town",Vector3.new(7200,100,3500)},{"Hydra Island",Vector3.new(6200,80,2500)},{"Great Tree",Vector3.new(8500,120,4500)},{"Castle on the Sea",Vector3.new(4500,50,1200)},{"Haunted Castle",Vector3.new(9800,60,5500)},{"Dark Arena",Vector3.new(10500,100,6000)}},bosses={"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan"},fruits={"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit","Control-Fruit"}},
}

local currentSea=1
local function detectSea() local lvl=1 pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl=player.Data.Level.Value end end) if lvl<=700 then currentSea=1 elseif lvl<=1500 then currentSea=2 else currentSea=3 end return currentSea end
detectSea()

-- ============================================================
-- VARIÁVEIS
-- ============================================================
local currentTarget,range,kills=nil,CONFIG.DEFAULT_RANGE,0
local masteryType="Fruit"

local superFarmEnabled=false
local godmodeEnabled=false
local killAuraEnabled=false
local aimlockEnabled=false
local noclipEnabled=false
local walkspeedEnabled=false
local jumpspeedEnabled=false
local bountyHuntEnabled=false
local flyEnabled=false
local espP,espF,espC,espB=false,false,false,false
local moveHopEnabled=false
local moveFlightEnabled=false
local autoHakiEnabled=false
local autoSkillEnabled=false
local autoQuestEnabled=false
local fragmentFarmEnabled=false
local bonesFarmEnabled=false
local shopFruitsEnabled=false
local shopStatsEnabled=false

-- ============================================================
-- SUPER FARM (QUEST → PUXAR → ATACAR → REPETIR)
-- ============================================================
local SuperFarm={boxPart=nil,boxSize=Vector3.new(5,3,5),flyHeight=1.5,collectedMobs={},lastQuestTime=0,questCooldown=45,phase="quest",mobsKilled=0,mobsNeeded=10}

function SuperFarm.createBox() if SuperFarm.boxPart and SuperFarm.boxPart.Parent then SuperFarm.boxPart:Destroy() end local part=Instance.new("Part",Workspace) part.Name="FarmBox" part.Size=SuperFarm.boxSize part.Anchored=true part.CanCollide=false part.Transparency=1 SuperFarm.boxPart=part end
function SuperFarm.positionBox() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end if not SuperFarm.boxPart then return end SuperFarm.boxPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position+Vector3.new(0,SuperFarm.flyHeight,0)) end

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
            local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest",nearest.Name) end
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
                local isQuestNPC=obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")
                if not isQuestNPC then
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
            currentTarget=obj humanAttack() aliveCount=aliveCount+1
            if math.random()>0.7 then VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.Z,false,game) task.wait(0.1) VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.Z,false,game) end
        else SuperFarm.collectedMobs[obj]=nil SuperFarm.mobsKilled=SuperFarm.mobsKilled+1 end
    end
    if aliveCount<=2 then SuperFarm.phase="collect" end
    if SuperFarm.mobsKilled>=SuperFarm.mobsNeeded then SuperFarm.phase="quest" SuperFarm.mobsKilled=0 SuperFarm.collectedMobs={} end
end

function SuperFarm.flyPlayer()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not SuperFarm.boxPart then return end
    local hrp=player.Character.HumanoidRootPart local targetPos=SuperFarm.boxPart.Position+Vector3.new(0,SuperFarm.flyHeight,0)
    hrp.CFrame=hrp.CFrame:Lerp(CFrame.new(targetPos),0.3)
    local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
end

-- ============================================================
-- LOOP CENTRAL
-- ============================================================
task.spawn(function() while true do local t=tick() detectSea()
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then task.wait(0.5) continue end

if godmodeEnabled or superFarmEnabled then pcall(function() local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=hum.MaxHealth end end) end

if superFarmEnabled then pcall(function() SuperFarm.createBox() SuperFarm.positionBox() SuperFarm.flyPlayer() if SuperFarm.phase=="quest" then SuperFarm.getQuest() elseif SuperFarm.phase=="collect" then SuperFarm.collectMobs() elseif SuperFarm.phase=="attack" then SuperFarm.attackMobs() end end)
else if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end SuperFarm.collectedMobs={} SuperFarm.phase="quest" end

if killAuraEnabled then pcall(function() local hrp=player.Character.HumanoidRootPart for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o~=player.Character and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and(o.HumanoidRootPart.Position-hrp.Position).Magnitude<range then currentTarget=o humanAttack() end end end) end
if aimlockEnabled then pcall(function() local tgt,s=nil,range for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<s then s=d tgt=o end end end if tgt then player.Character.HumanoidRootPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position,tgt.HumanoidRootPart.Position) end end) end
if noclipEnabled then pcall(function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end
if walkspeedEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=100 end end end) end
if jumpspeedEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower=100 end end end) end
if flyEnabled or moveFlightEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end
if moveHopEnabled and t%180<0.1 then pcall(function() local res=game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?limit=10") local servers=HttpService:JSONDecode(res) if servers and servers.data and#servers.data>0 then TeleportService:TeleportToPlaceInstance(game.GameId,servers.data[math.random(1,#servers.data)].id,player) end end) end
if autoHakiEnabled and t%120<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Observation") end end) end
if autoSkillEnabled and t%5<0.1 then pcall(function() VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.Z,false,game) task.wait(0.5) VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.Z,false,game) end) end
if autoQuestEnabled and t%30<0.1 then pcall(function() for _,obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and(obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")) then if obj:FindFirstChild("HumanoidRootPart") then FlightSystem.flyTo(obj.HumanoidRootPart.Position+Vector3.new(3,0,0)) break end end end end) end
if fragmentFarmEnabled and t%60<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) end
if bonesFarmEnabled and t%30<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end) end
if shopFruitsEnabled and t%300<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem","Kitsune") r.CommF_:InvokeServer("BuyItem","Dragon") end end) end
if shopStatsEnabled and t%5<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) end
if bountyHuntEnabled and t%15<0.1 then pcall(function() local best,bd=nil,math.huge for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d=(p.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<bd then best=p bd=d end end end if best then FlightSystem.flyTo(best.Character.HumanoidRootPart.Position) for _=1,5 do humanAttack() task.wait(0.3) end end end) end
if t%45<0.1 then pcall(function() collectgarbage("collect") end) end

task.wait(CONFIG.ATTACK_CYCLE_DELAY)
end end)

-- ============================================================
-- UI (USANDO BIBLIOTECA)
-- ============================================================
local win = NexusUI:CreateWindow({Title="NEXUS v7.0.9",Subtitle=SEA_DATA[currentSea].name.." | Voo + Anti-Ban Pro",Width=580,Height=500})
local tabs={}
for _,t in pairs({{"⚔️ Super Farm"},{"💎 Farms"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]]=NexusUI:CreateTab(win,{Name=t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Super Farm"],"🚀 SUPER FARM")
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🚀 SUPER FARM",Desc="Voa → Quest → Puxa → Ataca → Repete",Callback=function(v)superFarmEnabled=v end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="💀 Kill Aura",Callback=function(v)killAuraEnabled=v end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🛡️ Godmode",Callback=function(v)godmodeEnabled=v end})

NexusUI:CreateSection(tabs["💎 Farms"],"💎 FARMS")
NexusUI:CreateToggle(tabs["💎 Farms"],{Title="💎 Fragmentos",Callback=function(v)fragmentFarmEnabled=v end})
NexusUI:CreateToggle(tabs["💎 Farms"],{Title="🦴 Ossos",Callback=function(v)bonesFarmEnabled=v end})

NexusUI:CreateSection(tabs["🏃 Move"],"🏃 MOVIMENTAÇÃO")
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="🔄 Auto Hop",Callback=function(v)moveHopEnabled=v end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="✈️ Auto Flight",Callback=function(v)moveFlightEnabled=v end})
NexusUI:CreateToggle(tabs["🏃 Move"],{Title="✈️ Fly",Callback=function(v)flyEnabled=v end})

NexusUI:CreateSection(tabs["⚙️ Auto"],"⚙️ AUTOMAÇÕES")
NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title="🔮 Auto Haki",Callback=function(v)autoHakiEnabled=v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title="⭐ Auto Skill",Callback=function(v)autoSkillEnabled=v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title="📋 Auto Quest",Callback=function(v)autoQuestEnabled=v end})

NexusUI:CreateSection(tabs["🛍️ Loja"],"🛍️ AUTO COMPRAR")
NexusUI:CreateToggle(tabs["🛍️ Loja"],{Title="🛒 Buy Fruits",Callback=function(v)shopFruitsEnabled=v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"],{Title="📊 Buy Stats",Callback=function(v)shopStatsEnabled=v end})

NexusUI:CreateSection(tabs["👀 Visual"],"👀 ESP")
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="👁️ ESP Players",Callback=function(v)espP=v end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="🍎 ESP Fruits",Callback=function(v)espF=v end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="📦 ESP Chests",Callback=function(v)espC=v end})
NexusUI:CreateToggle(tabs["👀 Visual"],{Title="🎯 ESP Bosses",Callback=function(v)espB=v end})

NexusUI:CreateSection(tabs["🎮 Extra"],"🎮 FUNÇÕES")
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="🎯 Aimlock",Callback=function(v)aimlockEnabled=v end})
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="🚫 No Clip",Callback=function(v)noclipEnabled=v end})
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="🏃 Walkspeed",Callback=function(v)walkspeedEnabled=v end})
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="🦘 Jumpspeed",Callback=function(v)jumpspeedEnabled=v end})
NexusUI:CreateToggle(tabs["🎮 Extra"],{Title="💰 Bounty Hunt",Callback=function(v)bountyHuntEnabled=v end})
NexusUI:CreateDropdown(tabs["🎮 Extra"],{Title="Maestria",Options={"Fruit","Sword","Gun","Melee"},Default=masteryType,Callback=function(v)masteryType=v end})
NexusUI:CreateSlider(tabs["🎮 Extra"],{Title="Alcance",Min=50,Max=500,Default=300,Callback=function(v)range=v end})
NexusUI:CreateButton(tabs["🎮 Extra"],{Title="🛑 DESLIGAR TUDO",Callback=function()
    superFarmEnabled=false godmodeEnabled=false killAuraEnabled=false aimlockEnabled=false noclipEnabled=false walkspeedEnabled=false jumpspeedEnabled=false bountyHuntEnabled=false flyEnabled=false moveHopEnabled=false moveFlightEnabled=false autoHakiEnabled=false autoSkillEnabled=false autoQuestEnabled=false fragmentFarmEnabled=false bonesFarmEnabled=false shopFruitsEnabled=false shopStatsEnabled=false espP=false espF=false espC=false espB=false
    if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end SuperFarm.collectedMobs={} SuperFarm.phase="quest"
    notify("Stats","Tudo desligado!",3)
end})

NexusUI:CreateSection(tabs["🏝️ Ilhas"],"🏝️ ILHAS DO "..SEA_DATA[currentSea].name:upper())
for _,il in pairs(SEA_DATA[currentSea].islands) do NexusUI:CreateButton(tabs["🏝️ Ilhas"],{Title="🏝️ "..il[1],Callback=function()FlightSystem.flyTo(il[2])notify("✈️","Voando para "..il[1],3)end}) end

notify("NEXUS v7.0.9","Sistema de Voo + Anti-Ban Pro | "..SEA_DATA[currentSea].name,5)
print("NEXUS v7.0.9 - Voo + Anti-Ban Pro - Loaded")
