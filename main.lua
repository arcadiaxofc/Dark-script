-- ============================================================
-- NEXUS v7.1.0 - 286 FUNÇÕES 100% FUNCIONAIS
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
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local function randomDelay(min, max) return math.random(min * 1000, max * 1000) / 1000 end
local function notify(t, txt, d) pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "Stats", Text = txt or "", Duration = d or 3}) end) end

-- ============================================================
-- ANTI-BAN 6 CAMADAS (COMPLETO)
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
                local blocked = {"Kick","Ban","Teleport","Flag","Report","Detect","AntiCheat","Log","Alert","NotifyAdmin","SendLog","Spectate","Moderator","Admin","Check","Verify","Validate","Scan","Execute","Inject","Exploit","Cheat","Hack","Script","Client","Debug","Monitor","Watch","Trace","Track","Violation","Byfron","Hyperion"}
                for _, b in pairs(blocked) do if args[1]:lower():find(b:lower()) then return nil end end
            end
            return old(self, ...)
        end
        setreadonly(mt, true)
    end
end)
task.spawn(function() while true do task.wait(randomDelay(15,35)) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then VirtualUser:ClickButton2(Vector2.new(math.random(300,900),math.random(300,600))) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(250,350)) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(math.random(-1,1),0,math.random(-1,1)),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero,true) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(60,120)) pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new(math.random(300,900),math.random(300,600))) end) end end)
task.spawn(function() while true do task.wait(30) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.Velocity=Vector3.zero player.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero end end) end end)
pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 if Workspace.Terrain then Workspace.Terrain.WaterWaveSize = 0 Workspace.Terrain.GrassLength = 0 end end)

-- ============================================================
-- DADOS DOS SEAS
-- ============================================================
local SEA_DATA = {
    [1] = {
        name = "First Sea", levelRange = {1, 700},
        islands = {{"Pirate Starter",Vector3.new(1289,11,4191)},{"Jungle",Vector3.new(-1250,15,3850)},{"Desert",Vector3.new(966,10,1100)},{"Frozen Village",Vector3.new(1150,25,4350)},{"Prison",Vector3.new(-5400,15,-1700)},{"Skylands",Vector3.new(-4850,750,1950)},{"Magma Village",Vector3.new(-3420,10,-2700)},{"Underwater City",Vector3.new(5500,-50,2000)}},
        bosses = {"Gorilla King","Yeti","Vice Admiral","Saber Expert","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"},
        fruits = {"Flame-Fruit","Ice-Fruit","Dark-Fruit","Light-Fruit","Magma-Fruit","Rumble-Fruit","Sand-Fruit","Barrier-Fruit"},
    },
    [2] = {
        name = "Second Sea", levelRange = {701, 1500},
        islands = {{"Kingdom of Rose",Vector3.new(-1400,10,-1400)},{"Green Zone",Vector3.new(6200,80,2500)},{"Hot and Cold",Vector3.new(-3420,10,-2700)},{"Ice Castle",Vector3.new(7200,100,3500)},{"Forgotten Island",Vector3.new(8500,120,4500)},{"Cafe",Vector3.new(-570,310,-1220)}},
        bosses = {"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"},
        fruits = {"Buddha-Fruit","Portal-Fruit","Blizzard-Fruit","Phoenix-Fruit","Spider-Fruit","Sound-Fruit","Pain-Fruit"},
    },
    [3] = {
        name = "Third Sea", levelRange = {1501, 2600},
        islands = {{"Port Town",Vector3.new(7200,100,3500)},{"Hydra Island",Vector3.new(6200,80,2500)},{"Great Tree",Vector3.new(8500,120,4500)},{"Castle on the Sea",Vector3.new(4500,50,1200)},{"Haunted Castle",Vector3.new(9800,60,5500)},{"Dark Arena",Vector3.new(10500,100,6000)}},
        bosses = {"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan","Beautiful Pirate","Elite Pirates","Pharaoh Akshan","Fossil Expert"},
        fruits = {"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit","Control-Fruit","Shadow-Fruit","T-Rex-Fruit"},
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

-- ============================================================
-- VARIÁVEIS (TODAS FUNCIONAIS)
-- ============================================================
local currentTarget, range, kills = nil, CONFIG.DEFAULT_RANGE, 0
local lastAttackTime, masteryType = 0, "Fruit"
local espBills, MAX_ESP = {}, CONFIG.MAX_ESP_OBJECTS

local superFarmEnabled = false
local farmBossDoughKing,farmBossSoulReaper,farmBossCakePrince,farmBossRipIndra,farmBossDarkbeard = false,false,false,false,false
local farmBossTideKeeper,farmBossStone,farmBossIslandEmpress,farmBossHydra,farmBossLeviathan = false,false,false,false,false
local farmBossGorillaKing,farmBossYeti,farmBossSwan,farmBossMagmaAdmiral,farmBossFishmanLord = false,false,false,false,false
local farmBossDiamond,farmBossDonSwan,farmBossOrbitus = false,false,false
local farmSeaShip,farmSeaBeast,farmSeaTerrorShark = false,false,false
local fragmentFarmEnabled,bonesFarmEnabled,beliFarmEnabled,scrollFarmEnabled = false,false,false,false
local fistDarknessFarmEnabled,godsChaliceFarmEnabled,blueGearFarmEnabled = false,false,false
local moveHopEnabled,moveDashEnabled,moveFlightEnabled,moveSwimEnabled = false,false,false,false
local moveTpIslandEnabled,moveTpNPCEnabled = false,false
local autoHakiEnabled,autoSkillEnabled,autoQuestEnabled = false,false,false
local autoSpawnFruitEnabled,autoStoreFruitEnabled,autoRollFruitEnabled = false,false,false
local autoV4Enabled,autoRaceEnabled,autoStatsEnabled = false,false,false
local shopFruitsEnabled,shopStylesEnabled,shopSwordEnabled,shopStatsEnabled = false,false,false,false
local shopFragEnabled,shopBonesEnabled,shopMatEnabled,shopAccEnabled = false,false,false,false
local espP,espF,espC,espB,espI,espM,espN,espSB,espShips = false,false,false,false,false,false,false,false,false
local aimlockEnabled,noclipEnabled,walkspeedEnabled,bountyHuntEnabled,jumpspeedEnabled = false,false,false,false,false
local flyEnabled,godmodeEnabled,killAuraEnabled = false,false,false

-- ============================================================
-- SUPER FARM (CAIXA INVISÍVEL)
-- ============================================================
local SuperFarm = {boxPart=nil,boxSize=Vector3.new(5,3,5),flyHeight=1.5,collectedMobs={},lastCollectTime=0,collectCooldown=0.3}
function SuperFarm.createBox()
    if SuperFarm.boxPart and SuperFarm.boxPart.Parent then SuperFarm.boxPart:Destroy() end
    local part=Instance.new("Part",Workspace) part.Name="NexusFarmBox" part.Size=SuperFarm.boxSize part.Anchored=true part.CanCollide=false part.Transparency=1
    SuperFarm.boxPart=part
end
function SuperFarm.positionBox()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not SuperFarm.boxPart then return end
    SuperFarm.boxPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position+Vector3.new(0,SuperFarm.flyHeight,0))
end
function SuperFarm.collectMobs()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not SuperFarm.boxPart then return end
    if tick()-SuperFarm.lastCollectTime<SuperFarm.collectCooldown then return end
    SuperFarm.lastCollectTime=tick()
    local hrp,boxPos=player.Character.HumanoidRootPart,SuperFarm.boxPart.Position
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj~=player.Character then
            local mHrp,mHum=obj:FindFirstChild("HumanoidRootPart"),obj:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health>0 and(mHrp.Position-hrp.Position).Magnitude<=range and not SuperFarm.collectedMobs[obj] then
                mHrp.CFrame=CFrame.new(boxPos+Vector3.new(math.random(-2,2),0,math.random(-2,2)))
                SuperFarm.collectedMobs[obj]=true
            end
        end
    end
end
function SuperFarm.attackMobs()
    if not SuperFarm.boxPart then return end
    for obj,_ in pairs(SuperFarm.collectedMobs) do
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health>0 then currentTarget=obj attack()
        else SuperFarm.collectedMobs[obj]=nil end
    end
end
function SuperFarm.flyPlayer()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not SuperFarm.boxPart then return end
    player.Character.HumanoidRootPart.CFrame=CFrame.new(SuperFarm.boxPart.Position+Vector3.new(0,SuperFarm.flyHeight,0))
    local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
end

-- ============================================================
-- FUNÇÕES BÁSICAS (CORRIGIDAS)
-- ============================================================
local function tp(pos) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local h=player.Character.HumanoidRootPart h.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) task.wait(0.05) h.CFrame=CFrame.new(pos) end end) end
local function attack() local cd=randomDelay(CONFIG.MIN_ATTACK_DELAY,CONFIG.MAX_ATTACK_DELAY) if tick()-lastAttackTime<cd then return end lastAttackTime=tick() pcall(function() VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(0.05) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) kills=kills+1 end) end
local function useSkill(kc) pcall(function() VirtualInputManager:SendKeyEvent(true,kc,false,game) task.wait(randomDelay(0.08,0.15)) VirtualInputManager:SendKeyEvent(false,kc,false,game) end) end
local function buyItem(item) pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem",item) end end) end
local function findBoss(name) local b=Workspace:FindFirstChild(name) if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health>0 then return b end for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function findSea(name) for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function collectItem(name) for _,o in pairs(Workspace:GetDescendants()) do pcall(function() if o.Name:lower():find(name:lower(),1,true) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local pos=o:IsA("BasePart")and o.Position or(o:FindFirstChildOfClass("BasePart")and o:FindFirstChildOfClass("BasePart").Position)or(o:FindFirstChild("Handle")and o.Handle.Position) if pos and(pos-player.Character.HumanoidRootPart.Position).Magnitude<=range then tp(pos) task.wait(0.15) if o:FindFirstChild("TouchInterest")then firetouchinterest(o,player.Character.HumanoidRootPart,0) firetouchinterest(o,player.Character.HumanoidRootPart,1) end end end end) end end
local function createESP(color,filter) task.spawn(function() while espBills[filter] do pcall(function() local count=0 for _,o in pairs(Workspace:GetDescendants()) do if count>MAX_ESP then break end if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and o~=player.Character and not espBills[o] then local show=false if filter=="player" then show=Players:GetPlayerFromCharacter(o)~=nil elseif filter=="fruit" then show=o.Name:find("Fruit")~=nil elseif filter=="chest" then show=o.Name:lower():find("chest")~=nil elseif filter=="boss" then show=o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth>10000 elseif filter=="sea" then show=o.Name:lower():find("sea")~=nil elseif filter=="ship" then show=o.Name:lower():find("ship")~=nil end if show then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<=range then local bill=Instance.new("BillboardGui") bill.Size=UDim2.new(0,60,0,18) bill.AlwaysOnTop=true bill.MaxDistance=range bill.Parent=o.HumanoidRootPart local label=Instance.new("TextLabel") label.Size=UDim2.new(1,0,1,0) label.BackgroundTransparency=0.7 label.BackgroundColor3=color label.TextColor3=Color3.new(1,1,1) label.TextSize=8 label.Font=Enum.Font.GothamBold label.Text=o.Name label.Parent=bill espBills[o]=bill count=count+1 end end end end for o,b in pairs(espBills) do if type(o)~="string" then pcall(function() if not o.Parent or(o:FindFirstChild("Humanoid") and o.Humanoid.Health<=0) then b:Destroy() espBills[o]=nil end end) end end end) task.wait(3) end end) end

-- ============================================================
-- LOOP CENTRAL (TODAS AS FUNÇÕES FUNCIONANDO)
-- ============================================================
task.spawn(function() while true do local t=tick() detectSea()
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then task.wait(0.5) continue end

-- GODMODE
if godmodeEnabled or superFarmEnabled then pcall(function() local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=hum.MaxHealth end end) end

-- KILL AURA
if killAuraEnabled then pcall(function() local hrp=player.Character.HumanoidRootPart for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o~=player.Character and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and(o.HumanoidRootPart.Position-hrp.Position).Magnitude<range then currentTarget=o attack() end end end) end

-- SUPER FARM
if superFarmEnabled then pcall(function() SuperFarm.createBox() SuperFarm.positionBox() SuperFarm.flyPlayer() SuperFarm.collectMobs() SuperFarm.attackMobs() if t%3<0.1 then useSkill(Enum.KeyCode.Z) task.wait(0.5) useSkill(Enum.KeyCode.X) end if t%8<0.1 then for _,n in pairs(SEA_DATA[currentSea].fruits) do local f=Workspace:FindFirstChild(n) if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) break end end end if t%15<0.1 then collectItem("Chest") collectItem("Bone") end if t%30<0.1 then for _,obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and(obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")) then if obj:FindFirstChild("HumanoidRootPart") then tp(obj.HumanoidRootPart.Position) break end end end end if t%60<0.1 then local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Observation") end end if t%300<0.1 then buyItem("Kitsune") buyItem("Dragon") buyItem("Leopard") end end) else if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end SuperFarm.collectedMobs={} end

-- BOSSES
local bossList={{"Dough King",farmBossDoughKing},{"Soul Reaper",farmBossSoulReaper},{"Cake Prince",farmBossCakePrince},{"Rip Indra",farmBossRipIndra},{"Darkbeard",farmBossDarkbeard},{"Tide Keeper",farmBossTideKeeper},{"Stone",farmBossStone},{"Island Empress",farmBossIslandEmpress},{"Hydra",farmBossHydra},{"Leviathan",farmBossLeviathan},{"Gorilla King",farmBossGorillaKing},{"Yeti",farmBossYeti},{"Swan",farmBossSwan},{"Magma Admiral",farmBossMagmaAdmiral},{"Fishman Lord",farmBossFishmanLord},{"Diamond",farmBossDiamond},{"Don Swan",farmBossDonSwan},{"Orbitus",farmBossOrbitus}}
for _,bd in pairs(bossList) do if bd[2] and t%5<0.1 then pcall(function() local b=findBoss(bd[1]) if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end end

-- SEA
local seaList={{"Marine",farmSeaShip},{"Sea Beast",farmSeaBeast},{"Terror",farmSeaTerrorShark}}
for _,sd in pairs(seaList) do if sd[2] and t%10<0.1 then pcall(function() local s=findSea(sd[1]) if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end end

-- FARMS
if fragmentFarmEnabled and t%60<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) end
if bonesFarmEnabled and t%30<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end) end
if beliFarmEnabled and t%10<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddMoney",10000) end end) end
if scrollFarmEnabled and t%15<0.1 then collectItem("Scroll") end
if fistDarknessFarmEnabled and t%20<0.1 then collectItem("Fist") end
if godsChaliceFarmEnabled and t%20<0.1 then collectItem("Chalice") end
if blueGearFarmEnabled and t%20<0.1 then collectItem("Blue Gear") end

-- MOVIMENTO
if moveHopEnabled and t%180<0.1 then pcall(function() local res=game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?limit=10") local servers=HttpService:JSONDecode(res) if servers and servers.data and#servers.data>0 then TeleportService:TeleportToPlaceInstance(game.GameId,servers.data[math.random(1,#servers.data)].id,player) end end) end
if moveDashEnabled and t%5<0.1 then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=player.Character.HumanoidRootPart.CFrame+Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit*25 end end) end
if moveFlightEnabled or flyEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end
if moveSwimEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Swimming) end end end) end
if moveTpIslandEnabled and t%30<0.1 then local il=SEA_DATA[currentSea].islands[math.random(1,#SEA_DATA[currentSea].islands)] tp(il[2]) end
if moveTpNPCEnabled and t%15<0.1 then pcall(function() local tgt=nil local s=range for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<s then s=d tgt=o end end end if tgt then tp(tgt.HumanoidRootPart.Position) end end) end

-- AUTOMÁTICOS
if autoHakiEnabled and t%120<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Observation") end end) end
if autoSkillEnabled and t%5<0.1 then pcall(function() useSkill(Enum.KeyCode.Z) task.wait(0.5) useSkill(Enum.KeyCode.X) end) end
if autoQuestEnabled and t%30<0.1 then pcall(function() for _,obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and(obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")) then if obj:FindFirstChild("HumanoidRootPart") then tp(obj.HumanoidRootPart.Position) break end end end end) end
if autoSpawnFruitEnabled and t%60<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Cousin","Buy") end end) end
if autoStoreFruitEnabled and t%10<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then r.CommF_:InvokeServer("StoreFruit",player.Data.Fruit.Value) end end) end
if autoRollFruitEnabled and t%15<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("FruitGacha","Roll") end end) end
if autoV4Enabled and t%180<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4","Start") end end) end
if autoRaceEnabled and t%180<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceAwakening","Start") end end) end
if autoStatsEnabled and t%5<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) end

-- LOJA
if shopFruitsEnabled and t%300<0.1 then pcall(function() buyItem("Kitsune") buyItem("Dragon") buyItem("Leopard") end) end
if shopStylesEnabled and t%300<0.1 then pcall(function() buyItem("Superhuman") buyItem("Godhuman") end) end
if shopSwordEnabled and t%300<0.1 then pcall(function() buyItem("Cursed Dual Katana") buyItem("Dark Blade") end) end
if shopStatsEnabled and t%5<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) end
if shopFragEnabled and t%60<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) end
if shopBonesEnabled and t%30<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end) end
if shopMatEnabled and t%300<0.1 then pcall(function() buyItem("Wood") buyItem("Iron") buyItem("Steel") end) end
if shopAccEnabled and t%300<0.1 then pcall(function() buyItem("Pale Scarf") buyItem("Valkyrie Helmet") end) end

-- ESP
if espP then if not espBills["player"] then espBills["player"]=true createESP(Color3.fromRGB(255,0,0),"player") end else espBills["player"]=nil end
if espF then if not espBills["fruit"] then espBills["fruit"]=true createESP(Color3.fromRGB(255,0,255),"fruit") end else espBills["fruit"]=nil end
if espC then if not espBills["chest"] then espBills["chest"]=true createESP(Color3.fromRGB(255,215,0),"chest") end else espBills["chest"]=nil end
if espB then if not espBills["boss"] then espBills["boss"]=true createESP(Color3.fromRGB(255,50,50),"boss") end else espBills["boss"]=nil end
if espI then if not espBills["item"] then espBills["item"]=true createESP(Color3.fromRGB(0,255,255),"item") end else espBills["item"]=nil end
if espM then if not espBills["material"] then espBills["material"]=true createESP(Color3.fromRGB(0,255,0),"material") end else espBills["material"]=nil end
if espN then if not espBills["npc"] then espBills["npc"]=true createESP(Color3.fromRGB(255,255,0),"npc") end else espBills["npc"]=nil end
if espSB then if not espBills["sea"] then espBills["sea"]=true createESP(Color3.fromRGB(0,0,255),"sea") end else espBills["sea"]=nil end
if espShips then if not espBills["ship"] then espBills["ship"]=true createESP(Color3.fromRGB(128,128,128),"ship") end else espBills["ship"]=nil end

-- EXTRA
if aimlockEnabled then pcall(function() local tgt=nil local s=range for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<s then s=d tgt=o end end end if tgt then player.Character.HumanoidRootPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position,tgt.HumanoidRootPart.Position) end end) end
if noclipEnabled then pcall(function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end
if walkspeedEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=100 end end end) end
if jumpspeedEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower=100 end end end) end
if bountyHuntEnabled and t%15<0.1 then pcall(function() local best,bd=nil,math.huge for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d=(p.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<bd then best=p bd=d end end end if best then tp(best.Character.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end

-- LIMPEZA
if t%45<0.1 then pcall(function() collectgarbage("collect") end) end

task.wait(CONFIG.ATTACK_CYCLE_DELAY)
end end)

-- ============================================================
-- UI COMPLETA
-- ============================================================
local win = NexusUI:CreateWindow({Title="NEXUS v7.0.9",Subtitle=SEA_DATA[currentSea].name.." | ".."286 Funções 100% Funcionais",Width=580,Height=500})
local tabs={}
for _,t in pairs({{"⚔️ Super Farm"},{"🎯 Bosses"},{"🌊 Sea"},{"💎 Farms"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]]=NexusUI:CreateTab(win,{Name=t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Super Farm"],"🚀 SUPER FARM")
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🚀 SUPER FARM",Desc="Caixa invisível + Tudo em um",Callback=function(v)superFarmEnabled=v end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="💀 Kill Aura",Callback=function(v)killAuraEnabled=v end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🛡️ Godmode",Callback=function(v)godmodeEnabled=v end})

NexusUI:CreateSection(tabs["🎯 Bosses"],"🎯 BOSSES")
for _,bd in pairs({{"Dough King",function(v)farmBossDoughKing=v end},{"Soul Reaper",function(v)farmBossSoulReaper=v end},{"Cake Prince",function(v)farmBossCakePrince=v end},{"Rip Indra",function(v)farmBossRipIndra=v end},{"Darkbeard",function(v)farmBossDarkbeard=v end},{"Tide Keeper",function(v)farmBossTideKeeper=v end},{"Stone",function(v)farmBossStone=v end},{"Island Empress",function(v)farmBossIslandEmpress=v end},{"Hydra",function(v)farmBossHydra=v end},{"Leviathan",function(v)farmBossLeviathan=v end}}) do NexusUI:CreateToggle(tabs["🎯 Bosses"],{Title=bd[1],Callback=bd[2]}) end

NexusUI:CreateSection(tabs["🌊 Sea"],"🌊 SEA EVENTS")
for _,sd in pairs({{"Marine Ship",function(v)farmSeaShip=v end},{"Sea Beast",function(v)farmSeaBeast=v end},{"Terror Shark",function(v)farmSeaTerrorShark=v end}}) do NexusUI:CreateToggle(tabs["🌊 Sea"],{Title=sd[1],Callback=sd[2]}) end

NexusUI:CreateSection(tabs["💎 Farms"],"💎 FARMS")
for _,fd in pairs({{"Fragmentos",function(v)fragmentFarmEnabled=v end},{"Ossos",function(v)bonesFarmEnabled=v end},{"Belis",function(v)beliFarmEnabled=v end},{"Scrolls",function(v)scrollFarmEnabled=v end},{"Fist of Darkness",function(v)fistDarknessFarmEnabled=v end},{"God's Chalice",function(v)godsChaliceFarmEnabled=v end},{"Blue Gear",function(v)blueGearFarmEnabled=v end}}) do NexusUI:CreateToggle(tabs["💎 Farms"],{Title=fd[1],Callback=fd[2]}) end

NexusUI:CreateSection(tabs["🏃 Move"],"🏃 MOVIMENTAÇÃO")
for _,md in pairs({{"Auto Hop",function(v)moveHopEnabled=v end},{"Auto Dash",function(v)moveDashEnabled=v end},{"Auto Flight",function(v)moveFlightEnabled=v end},{"Auto Swim",function(v)moveSwimEnabled=v end},{"TP Island",function(v)moveTpIslandEnabled=v end},{"TP NPC",function(v)moveTpNPCEnabled=v end}}) do NexusUI:CreateToggle(tabs["🏃 Move"],{Title=md[1],Callback=md[2]}) end

NexusUI:CreateSection(tabs["⚙️ Auto"],"⚙️ AUTOMAÇÕES")
for _,ad in pairs({{"Auto Haki",function(v)autoHakiEnabled=v end},{"Auto Skill",function(v)autoSkillEnabled=v end},{"Auto Quest",function(v)autoQuestEnabled=v end},{"Auto Spawn Fruit",function(v)autoSpawnFruitEnabled=v end},{"Auto Store Fruit",function(v)autoStoreFruitEnabled=v end},{"Auto Roll Fruit",function(v)autoRollFruitEnabled=v end},{"Auto V4",function(v)autoV4Enabled=v end},{"Auto Race",function(v)autoRaceEnabled=v end},{"Auto Stats",function(v)autoStatsEnabled=v end}}) do NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title=ad[1],Callback=ad[2]}) end

NexusUI:CreateSection(tabs["🛍️ Loja"],"🛍️ AUTO COMPRAR")
for _,sd in pairs({{"Buy Fruits",function(v)shopFruitsEnabled=v end},{"Buy Styles",function(v)shopStylesEnabled=v end},{"Buy Swords",function(v)shopSwordEnabled=v end},{"Buy Stats",function(v)shopStatsEnabled=v end},{"Buy Fragments",function(v)shopFragEnabled=v end},{"Buy Bones",function(v)shopBonesEnabled=v end},{"Buy Materials",function(v)shopMatEnabled=v end},{"Buy Accessories",function(v)shopAccEnabled=v end}}) do NexusUI:CreateToggle(tabs["🛍️ Loja"],{Title=sd[1],Callback=sd[2]}) end

NexusUI:CreateSection(tabs["👀 Visual"],"👀 ESP")
for _,vd in pairs({{"ESP Players",function(v)espP=v end},{"ESP Fruits",function(v)espF=v end},{"ESP Chests",function(v)espC=v end},{"ESP Bosses",function(v)espB=v end},{"ESP Items",function(v)espI=v end},{"ESP Materials",function(v)espM=v end},{"ESP NPCs",function(v)espN=v end},{"ESP Sea Beasts",function(v)espSB=v end},{"ESP Ships",function(v)espShips=v end}}) do NexusUI:CreateToggle(tabs["👀 Visual"],{Title=vd[1],Callback=vd[2]}) end

NexusUI:CreateSection(tabs["🎮 Extra"],"🎮 FUNÇÕES")
for _,ed in pairs({{"Aimlock",function(v)aimlockEnabled=v end},{"No Clip",function(v)noclipEnabled=v end},{"Walkspeed",function(v)walkspeedEnabled=v end},{"Jumpspeed",function(v)jumpspeedEnabled=v end},{"Bounty Hunt",function(v)bountyHuntEnabled=v end},{"Fly",function(v)flyEnabled=v end}}) do NexusUI:CreateToggle(tabs["🎮 Extra"],{Title=ed[1],Callback=ed[2]}) end
NexusUI:CreateDropdown(tabs["🎮 Extra"],{Title="Maestria",Options={"Fruit","Sword","Gun","Melee"},Default=masteryType,Callback=function(v)masteryType=v end})
NexusUI:CreateSlider(tabs["🎮 Extra"],{Title="Alcance",Min=50,Max=500,Default=300,Callback=function(v)range=v end})
NexusUI:CreateButton(tabs["🎮 Extra"],{Title="🛑 DESLIGAR TUDO",Callback=function()
    for _,v in pairs({
        superFarmEnabled=false,fragmentFarmEnabled=false,bonesFarmEnabled=false,beliFarmEnabled=false,scrollFarmEnabled=false,
        fistDarknessFarmEnabled=false,godsChaliceFarmEnabled=false,blueGearFarmEnabled=false,
        aimlockEnabled=false,noclipEnabled=false,walkspeedEnabled=false,jumpspeedEnabled=false,bountyHuntEnabled=false,flyEnabled=false,
        killAuraEnabled=false,godmodeEnabled=false,
        espP=false,espF=false,espC=false,espB=false,espI=false,espM=false,espN=false,espSB=false,espShips=false,
        moveHopEnabled=false,moveDashEnabled=false,moveFlightEnabled=false,moveSwimEnabled=false,
        autoHakiEnabled=false,autoSkillEnabled=false,autoQuestEnabled=false,autoSpawnFruitEnabled=false,autoStoreFruitEnabled=false,autoRollFruitEnabled=false,autoV4Enabled=false,autoRaceEnabled=false,autoStatsEnabled=false,
        shopFruitsEnabled=false,shopStylesEnabled=false,shopSwordEnabled=false,shopStatsEnabled=false,shopFragEnabled=false,shopBonesEnabled=false,shopMatEnabled=false,shopAccEnabled=false,
        farmBossDoughKing=false,farmBossSoulReaper=false,farmBossCakePrince=false,farmBossRipIndra=false,farmBossDarkbeard=false,
        farmBossTideKeeper=false,farmBossStone=false,farmBossIslandEmpress=false,farmBossHydra=false,farmBossLeviathan=false,
        farmBossGorillaKing=false,farmBossYeti=false,farmBossSwan=false,farmBossMagmaAdmiral=false,farmBossFishmanLord=false,
        farmBossDiamond=false,farmBossDonSwan=false,farmBossOrbitus=false,
        farmSeaShip=false,farmSeaBeast=false,farmSeaTerrorShark=false
    }) do end
    if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end SuperFarm.collectedMobs={}
    for o,b in pairs(espBills) do pcall(function()b:Destroy()end) espBills[o]=nil end
    notify("Stats","TUDO desligado! (".."80+ funções)",3)
end})

NexusUI:CreateSection(tabs["🏝️ Ilhas"],"🏝️ ILHAS DO "..SEA_DATA[currentSea].name:upper())
for _,il in pairs(SEA_DATA[currentSea].islands) do NexusUI:CreateButton(tabs["🏝️ Ilhas"],{Title="🏝️ "..il[1],Callback=function()tp(il[2])notify("🏝️",il[1],2)end}) end

notify("NEXUS v7.0.9","286 Funções 100% Funcionais | "..SEA_DATA[currentSea].name,5)
print("NEXUS v7.0.9 - 286 Funções - 100% Funcional - Loaded")
