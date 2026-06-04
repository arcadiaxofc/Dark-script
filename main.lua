-- ============================================================
-- NEXUS v7.0 - COMPLETO COM AUTO-OP E MAESTRIA SELECIONÁVEL
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local CONFIG = {
    VERSION = "7.0.3", MIN_ATTACK_DELAY = 0.15, ATTACK_CYCLE_DELAY = 0.2,
    MAX_ESP_OBJECTS = 10, MEMORY_CLEAN_INTERVAL = 60, ANTI_AFK_INTERVAL = 300,
    DEFAULT_RANGE = 300, MIN_RANGE = 50, MAX_RANGE = 500,
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

pcall(function() player.Kick = function() return nil end end)
task.spawn(function() while true do task.wait(30) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.Velocity = Vector3.zero player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero end end) end end)
task.spawn(function() while true do task.wait(CONFIG.ANTI_AFK_INTERVAL) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(1,0,0),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.new(0,0,0),true) end end) end end)
pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 if Workspace.Terrain then Workspace.Terrain.WaterWaveSize = 0 Workspace.Terrain.GrassLength = 0 end end)

local masteryType = "Fruit"

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
        fruits = {"Rocket-Fruit","Spin-Fruit","Blade-Fruit","Spring-Fruit","Bomb-Fruit","Smoke-Fruit","Spike-Fruit","Flame-Fruit","Eagle-Fruit","Ice-Fruit","Sand-Fruit","Dark-Fruit","Diamond-Fruit","Light-Fruit","Rubber-Fruit","Ghost-Fruit","Magma-Fruit"},
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
        fruits = {"Gravity-Fruit","Mammoth-Fruit","T-Rex-Fruit","Dough-Fruit","Shadow-Fruit","Venom-Fruit","Control-Fruit","Gas-Fruit","Spirit-Fruit","Tiger-Fruit","Yeti-Fruit","Kitsune-Fruit","Dragon-Fruit"},
    },
}

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

local currentTarget, range, espBills, MAX_ESP, kills = nil, CONFIG.DEFAULT_RANGE, {}, CONFIG.MAX_ESP_OBJECTS, 0
local attackDelay, lastAttackTime, MIN_ATTACK_DELAY = CONFIG.ATTACK_CYCLE_DELAY, 0, CONFIG.MIN_ATTACK_DELAY
local states = {}
local stateNames = {
    "farmBoss","killAura","godmode","autoOP",
    "fruitSniper","fruitStore","fruitSpawn","fruitRoll","fruitNotify","fruitESP",
    "seaShip","seaPirate","seaBeast","seaTerror","seaRumble","seaMansion","seaPRaid","seaCastle",
    "colChest","colBones","colFist","colChalice","colBlue","colSweet","colScroll","colFruitChest",
    "moveHop","moveDash","moveFlight","moveSwim","moveIsland","moveNPC","moveFruit","moveChest","movePlayer",
    "atHaki","atSkill","atMeta","atRace","atAccessory","atTitle","atQuest","atGear","atV4","atRaidFruits",
    "shopFruits","shopStyles","shopSword","shopGuns","shopAcc","shopMat","shopStats","shopGP","shopFrag","shopBones",
    "espP","espF","espC","espB","espI","espM","espN","espSB","espShips",
    "aimlock","noclip","walkspeed","jumpspeed","bountyHunt","fragmentFarm"
}
for _, s in pairs(stateNames) do states[s] = false end

local function tp(pos) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local h=player.Character.HumanoidRootPart h.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) task.wait(0.05) h.CFrame=CFrame.new(pos) end end) end
local function findTarget() local n,s=nil,range for _,o in pairs(Workspace:GetDescendants()) do pcall(function() if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<s then s=d n=o end end end) end return n end
local function findBoss(name) local b=Workspace:FindFirstChild(name) if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health>0 then return b end for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function findSea(name) for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function attack() if tick()-lastAttackTime<MIN_ATTACK_DELAY then return end lastAttackTime=tick() pcall(function() VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(0.05) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) kills=kills+1 end) end
local function useSkill(key) pcall(function() VirtualInputManager:SendKeyEvent(true,key,false,game) task.wait(0.1) VirtualInputManager:SendKeyEvent(false,key,false,game) end) end
local function buyItem(item) pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem",item) end end) end
local function collectItem(name) for _,o in pairs(Workspace:GetDescendants()) do pcall(function() if o.Name:lower():find(name:lower()) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local pos=o:IsA("BasePart") and o.Position or(o:FindFirstChildOfClass("BasePart") and o:FindFirstChildOfClass("BasePart").Position)or(o:FindFirstChild("Handle") and o.Handle.Position) if pos and(pos-player.Character.HumanoidRootPart.Position).Magnitude<=range then tp(pos) task.wait(0.15) if o:FindFirstChild("TouchInterest") then firetouchinterest(o,player.Character.HumanoidRootPart,0) firetouchinterest(o,player.Character.HumanoidRootPart,1) end end end end) end end
local function notify(title,text,dur) pcall(function() StarterGui:SetCore("SendNotification",{Title=title or"NEXUS",Text=text or"",Duration=dur or 3}) end) end
local function serverHop() pcall(function() local res=game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?limit=10") local servers=HttpService:JSONDecode(res) if servers and servers.data and#servers.data>0 then local s=servers.data[math.random(1,#servers.data)] TeleportService:TeleportToPlaceInstance(game.GameId,s.id,player) end end) end
local function createESP(color,filter) if espBills[filter] then for o,b in pairs(espBills) do if type(o)~="string" then b:Destroy() espBills[o]=nil end end end task.spawn(function() while espBills[filter] do pcall(function() local count=0 for _,o in pairs(Workspace:GetDescendants()) do if count>MAX_ESP then break end if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and o~=player.Character and not espBills[o] then local show=false if filter=="player" then show=Players:GetPlayerFromCharacter(o)~=nil elseif filter=="fruit" then show=o.Name:find("Fruit")~=nil elseif filter=="chest" then show=o.Name:lower():find("chest")~=nil elseif filter=="boss" then show=o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth>10000 elseif filter=="sea" then show=o.Name:lower():find("sea")~=nil elseif filter=="ship" then show=o.Name:lower():find("ship")~=nil elseif filter=="npc" then show=o:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(o) elseif filter=="item" then show=o.Name:find("Fist")or o.Name:find("Chalice")or o.Name:find("Gear")~=nil elseif filter=="material" then show=o.Name:find("Wood")or o.Name:find("Iron")or o.Name:find("Bone")~=nil end if show then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<=range then local bill=Instance.new("BillboardGui") bill.Size=UDim2.new(0,60,0,18) bill.AlwaysOnTop=true bill.MaxDistance=range bill.Parent=o.HumanoidRootPart local label=Instance.new("TextLabel") label.Size=UDim2.new(1,0,1,0) label.BackgroundTransparency=0.7 label.BackgroundColor3=color label.TextColor3=Color3.new(1,1,1) label.TextSize=8 label.Font=Enum.Font.GothamBold label.Text=o.Name label.Parent=bill espBills[o]=bill count=count+1 end end end end for o,b in pairs(espBills) do if type(o)~="string" then pcall(function() if not o.Parent or(o:FindFirstChild("Humanoid") and o.Humanoid.Health<=0) then b:Destroy() espBills[o]=nil end end) end end end) task.wait(3) end end) end

local function activateAutoOP()
    states.farmBoss = true
    states.killAura = true
    states.godmode = true
    states.fruitSniper = true
    states.fruitStore = true
    states.fruitSpawn = true
    states.fruitRoll = true
    states.fruitNotify = true
    states.fruitESP = true
    states.colChest = true
    states.colBones = true
    states.colFist = true
    states.colChalice = true
    states.colBlue = true
    states.colSweet = true
    states.colScroll = true
    states.colFruitChest = true
    states.atHaki = true
    states.atSkill = true
    states.atQuest = true
    states.atV4 = true
    states.atRace = true
    states.shopFruits = true
    states.shopStyles = true
    states.shopSword = true
    states.shopStats = true
    states.shopFrag = true
    states.espP = true
    states.espF = true
    states.espC = true
    states.espB = true
    notify("🚀 AUTO-OP", "Todas as funções foram ATIVADAS!\nFarm Boss + Kill Aura + Godmode + Coleta + Compras + ESP", 8)
end

task.spawn(function() while true do local t=tick()
detectSea()
if states.autoOP then activateAutoOP() states.autoOP = false end
if states.godmode or states.farmBoss then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.Health=h.MaxHealth end end end) end
if states.killAura then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local hrp=player.Character.HumanoidRootPart for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-hrp.Position).Magnitude if d<=range then currentTarget=o hrp.CFrame=CFrame.new(hrp.Position,o.HumanoidRootPart.Position) attack() task.wait(0.03) end end end end end) end
if states.farmBoss and t%8<0.05 then pcall(function() for _,n in pairs(SEA_DATA[currentSea].bosses) do if states.farmBoss then local b=findBoss(n) if b then tp(b.HumanoidRootPart.Position) for _=1,10 do attack() task.wait(0.3) end end end end end) end
if states.fruitSniper and t%8<0.05 then pcall(function() for _,n in pairs(SEA_DATA[currentSea].fruits) do local f=Workspace:FindFirstChild(n) if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) break end end end) end
if states.fruitStore and t%10<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then r.CommF_:InvokeServer("StoreFruit",player.Data.Fruit.Value) end end) end
if states.fruitSpawn and t%60<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Cousin","Buy") end end) end
if states.fruitRoll and t%15<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("FruitGacha","Roll") end end) end
if states.fruitNotify and t%30<0.05 then pcall(function() for _,n in pairs({"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit"}) do if Workspace:FindFirstChild(n) then notify("FRUTA RARA!",n.." spawnou!",5) end end end) end
if t%10<0.05 then local sl={{"seaShip","Marine"},{"seaPirate","Pirate"},{"seaBeast","Sea Beast"},{"seaTerror","Terror"},{"seaRumble","Rumbling"},{"seaMansion","Mansion"},{"seaPRaid","Raid"},{"seaCastle","Castle"}} for _,sd in pairs(sl) do if states[sd[1]] then pcall(function() local s=findSea(sd[2]) if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end end end
if t%12<0.05 and states.colChest then collectItem("Chest") end
if t%8<0.05 and states.colBones then collectItem("Bone") end
if t%20<0.05 then for _,sk in pairs({"colFist","colChalice","colBlue","colSweet","colFruitChest"}) do if states[sk] then local nm=sk:gsub("col",""):gsub("FruitChest","Fruit Chest"):gsub("Blue","Blue Gear") collectItem(nm) end end end
if t%15<0.05 and states.colScroll then collectItem("Scroll") end
if t%180<0.05 and states.moveHop then serverHop() end
if t%5<0.05 and states.moveDash then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=player.Character.HumanoidRootPart.CFrame+Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit*25 end end) end
if t%2<0.05 then if states.moveFlight then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end if states.moveSwim then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end end end) end end
if t%30<0.05 and states.moveIsland then local il=SEA_DATA[currentSea].islands[math.random(1,#SEA_DATA[currentSea].islands)] tp(il[2]) end
if t%15<0.05 and states.moveNPC then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) end end) end
if t%15<0.05 and states.moveFruit then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o.Name:find("Fruit") and o:FindFirstChild("Handle") then tp(o.Handle.Position) break end end end) end
if t%15<0.05 and states.moveChest then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o.Name:find("Chest") and o:FindFirstChildOfClass("BasePart") then tp(o:FindFirstChildOfClass("BasePart").Position) break end end end) end
if t%20<0.05 and states.movePlayer then pcall(function() local best,bb=nil,0 for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b=p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b>bb then bb=b best=p end end end if best then tp(best.Character.HumanoidRootPart.Position) end end) end
if t%120<0.05 and states.atHaki then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Buso") end end) end
if t%5<0.05 and states.atSkill then pcall(function() useSkill("Z") useSkill("X") useSkill("C") end) end
if t%180<0.05 and states.atMeta then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Metaverse","Start") end end) end
if t%180<0.05 and states.atRace then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceAwakening","Start") end end) end
if t%8<0.05 and states.atAccessory then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) for _=1,3 do attack() task.wait(0.3) end end end) end
if t%180<0.05 and states.atTitle then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Title","Equip") end end) end
if t%30<0.05 and states.atQuest then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and(o:FindFirstChild("Quest")or o:FindFirstChild("Talk")) then tp(o.HumanoidRootPart.Position) task.wait(1) local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest",o.Name) end break end end end) end
if t%20<0.05 and states.atGear then collectItem("Gear") end
if t%180<0.05 and states.atV4 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4","Start") end end) end
if t%120<0.05 and states.atRaidFruits then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") then tp(o.Position) task.wait(0.5) firetouchinterest(o,player.Character.HumanoidRootPart,0) firetouchinterest(o,player.Character.HumanoidRootPart,1) break end end end) end
if t%600<0.05 then if states.shopFruits then for _,item in pairs({"Kitsune","Dragon","Leopard","Dough","Spirit","Venom"}) do buyItem(item) task.wait(2) end end if states.shopStyles then for _,item in pairs({"Superhuman","Death Step","Godhuman"}) do buyItem(item) task.wait(2) end end if states.shopSword then for _,item in pairs({"Cursed Dual Katana","Dark Blade"}) do buyItem(item) task.wait(2) end end end
if t%5<0.05 and states.shopStats then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) end
if t%60<0.05 and states.shopFrag then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) end
if t%30<0.05 and states.shopBones then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end) end
if states.espP then if not espBills["player"] then espBills["player"]=true createESP(Color3.fromRGB(255,0,0),"player") end else espBills["player"]=nil end
if states.espF then if not espBills["fruit"] then espBills["fruit"]=true createESP(Color3.fromRGB(255,0,255),"fruit") end else espBills["fruit"]=nil end
if states.espC then if not espBills["chest"] then espBills["chest"]=true createESP(Color3.fromRGB(255,215,0),"chest") end else espBills["chest"]=nil end
if states.espB then if not espBills["boss"] then espBills["boss"]=true createESP(Color3.fromRGB(255,50,50),"boss") end else espBills["boss"]=nil end
if states.espI then if not espBills["item"] then espBills["item"]=true createESP(Color3.fromRGB(0,255,255),"item") end else espBills["item"]=nil end
if states.espM then if not espBills["material"] then espBills["material"]=true createESP(Color3.fromRGB(0,255,0),"material") end else espBills["material"]=nil end
if states.espN then if not espBills["npc"] then espBills["npc"]=true createESP(Color3.fromRGB(255,255,0),"npc") end else espBills["npc"]=nil end
if states.espSB then if not espBills["sea"] then espBills["sea"]=true createESP(Color3.fromRGB(0,0,255),"sea") end else espBills["sea"]=nil end
if states.espShips then if not espBills["ship"] then espBills["ship"]=true createESP(Color3.fromRGB(128,128,128),"ship") end else espBills["ship"]=nil end
if t%0.3<0.05 and states.aimlock then pcall(function() local tgt=findTarget() if tgt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position,tgt.HumanoidRootPart.Position) end end) end
if t%0.5<0.05 then if states.noclip then pcall(function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end if states.walkspeed then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=100 end end end) end if states.jumpspeed then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=100 end end end) end end
if t%15<0.05 and states.bountyHunt then pcall(function() local best,bb=nil,0 for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b=p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b>bb then bb=b best=p end end end if best then tp(best.Character.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if t%5<0.05 and states.fragmentFarm then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) for _=1,3 do attack() task.wait(0.3) end end end) end
if t%60<0.05 then pcall(function() collectgarbage("collect") for o,b in pairs(espBills) do if type(o)~="string" then pcall(function() if not o.Parent or(o:FindFirstChild("Humanoid") and o.Humanoid.Health<=0) then b:Destroy() espBills[o]=nil end end) end end end) end
task.wait(0.1) end end)

local win = NexusUI:CreateWindow({Title="NEXUS v7.0",Subtitle=SEA_DATA[currentSea].name.." | Auto-OP Ready",Width=580,Height=500})
local tabs={}
for _,t in pairs({{"⚔️ Farm"},{"🍎 Frutas"},{"🎯 Bosses"},{"🌊 Sea"},{"📦 Coleta"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]]=NexusUI:CreateTab(win,{Name=t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Farm"],"Principal")
NexusUI:CreateButton(tabs["⚔️ Farm"],{Title="🚀 AUTO-OP (ATIVAR TUDO)",Callback=function()activateAutoOP()end})
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="🎯 Auto Farm Boss ("..SEA_DATA[currentSea].name..")",Callback=function(v)states.farmBoss=v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="💀 Kill Aura",Callback=function(v)states.killAura=v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="🛡️ Godmode",Callback=function(v)states.godmode=v end})

NexusUI:CreateSection(tabs["🎮 Extra"],"Maestria (Escolha o que upar)")
local masteryOptions = {"Fruit","Sword","Gun","Melee"}
NexusUI:CreateDropdown(tabs["🎮 Extra"],{Title="Tipo de Maestria",Options=masteryOptions,Default=masteryType,Callback=function(v)masteryType=v notify("Maestria","Upando: "..v,2)end})

NexusUI:CreateSection(tabs["🍎 Frutas"],"Frutas do "..SEA_DATA[currentSea].name)
for _,n in pairs(SEA_DATA[currentSea].fruits) do NexusUI:CreateLabel(tabs["🍎 Frutas"],{Title="🍎 "..n}) end
for _,cfg in pairs({{"Fruit Sniper ("..SEA_DATA[currentSea].name..")","fruitSniper"},{"Auto Store Fruit","fruitStore"},{"Auto Spawn Fruit","fruitSpawn"},{"Auto Roll Fruit","fruitRoll"},{"Fruit Notify","fruitNotify"},{"Fruit ESP","fruitESP"}}) do NexusUI:CreateToggle(tabs["🍎 Frutas"],{Title=cfg[1],Callback=function(v)states[cfg[2]]=v end}) end

NexusUI:CreateSection(tabs["🎯 Bosses"],"Bosses do "..SEA_DATA[currentSea].name)
for _,n in pairs(SEA_DATA[currentSea].bosses) do local k="boss"..n:gsub(" ","") if states[k]==nil then states[k]=false end NexusUI:CreateToggle(tabs["🎯 Bosses"],{Title=n,Callback=function(v)states[k]=v end}) end

NexusUI:CreateSection(tabs["🌊 Sea"],"Eventos")
for _,cfg in pairs({{"Marine Ship","seaShip"},{"Pirate Ship","seaPirate"},{"Sea Beast","seaBeast"},{"Terror Shark","seaTerror"},{"Rumbling","seaRumble"},{"Mansion","seaMansion"},{"Pirate Raid","seaPRaid"},{"Sea Castle","seaCastle"}}) do NexusUI:CreateToggle(tabs["🌊 Sea"],{Title=cfg[1],Callback=function(v)states[cfg[2]]=v end}) end

NexusUI:CreateSection(tabs["📦 Coleta"],"Auto Collect")
for _,cfg in pairs({{"Chest","colChest"},{"Bone","colBones"},{"Fist of Darkness","colFist"},{"God's Chalice","colChalice"},{"Blue Gear","colBlue"},{"Sweet Chalice","colSweet"},{"Scroll","colScroll"},{"Fruit Chest","colFruitChest"}}) do NexusUI:CreateToggle(tabs["📦 Coleta"],{Title="Auto "..cfg[1],Callback=function(v)states[cfg[2]]=v end}) end

NexusUI:CreateSection(tabs["🏃 Move"],"Movimentação")
for _,cfg in pairs({{"Auto Hop","moveHop"},{"Auto Dash","moveDash"},{"Auto Flight","moveFlight"},{"Auto Swim","moveSwim"},{"TP Island ("..SEA_DATA[currentSea].name..")","moveIsland"},{"TP to NPC","moveNPC"},{"TP to Fruit","moveFruit"},{"TP to Chest","moveChest"},{"TP to Player","movePlayer"}}) do NexusUI:CreateToggle(tabs["🏃 Move"],{Title=cfg[1],Callback=function(v)states[cfg[2]]=v end}) end

NexusUI:CreateSection(tabs["⚙️ Auto"],"Automações")
for _,cfg in pairs({{"Auto Haki","atHaki"},{"Auto Skill","atSkill"},{"Metaverse","atMeta"},{"Race Awakening","atRace"},{"Accessory Farm","atAccessory"},{"Title Farm","atTitle"},{"Auto Quest","atQuest"},{"Gear Farm","atGear"},{"V4 Awakening","atV4"},{"Raid Fruits","atRaidFruits"}}) do NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title=cfg[1],Callback=function(v)states[cfg[2]]=v end}) end

NexusUI:CreateSection(tabs["🛍️ Loja"],"Compras")
for _,cfg in pairs({{"Buy Fruits","shopFruits"},{"Buy Styles","shopStyles"},{"Buy Swords","shopSword"},{"Buy Guns","shopGuns"},{"Buy Accessories","shopAcc"},{"Buy Materials","shopMat"},{"Buy Stats","shopStats"},{"Buy Gamepass","shopGP"},{"Buy Fragments","shopFrag"},{"Buy Bones","shopBones"}}) do NexusUI:CreateToggle(tabs["🛍️ Loja"],{Title="Auto "..cfg[1],Callback=function(v)states[cfg[2]]=v end}) end

NexusUI:CreateSection(tabs["👀 Visual"],"ESP")
for _,cfg in pairs({{"ESP Players","espP"},{"ESP Fruits","espF"},{"ESP Chests","espC"},{"ESP Bosses","espB"},{"ESP Items","espI"},{"ESP Materials","espM"},{"ESP NPCs","espN"},{"ESP Sea Beasts","espSB"},{"ESP Ships","espShips"}}) do NexusUI:CreateToggle(tabs["👀 Visual"],{Title=cfg[1],Callback=function(v)states[cfg[2]]=v end}) end

NexusUI:CreateSection(tabs["🎮 Extra"],"Especiais")
for _,cfg in pairs({{"Aimlock","aimlock"},{"No Clip","noclip"},{"Walkspeed","walkspeed"},{"Jumpspeed","jumpspeed"},{"Bounty Hunt","bountyHunt"},{"Fragment Farm","fragmentFarm"}}) do NexusUI:CreateToggle(tabs["🎮 Extra"],{Title=cfg[1],Callback=function(v)states[cfg[2]]=v end}) end
NexusUI:CreateSlider(tabs["🎮 Extra"],{Title="Alcance",Min=50,Max=500,Default=300,Callback=function(v)range=v end})
NexusUI:CreateButton(tabs["🎮 Extra"],{Title="🛑 DESLIGAR TUDO",Callback=function() for n,_ in pairs(states) do states[n]=false end for o,b in pairs(espBills) do pcall(function()b:Destroy()end) end espBills={} notify("NEXUS","Tudo desligado!",3) end})
NexusUI:CreateLabel(tabs["🎮 Extra"],{Title="🌊 "..SEA_DATA[currentSea].name.." | Nível "..SEA_DATA[currentSea].levelRange[1].."-"..SEA_DATA[currentSea].levelRange[2]})
NexusUI:CreateLabel(tabs["🎮 Extra"],{Title="🗡️ Maestria: "..masteryType})

NexusUI:CreateSection(tabs["🏝️ Ilhas"],"Ilhas do "..SEA_DATA[currentSea].name.." ("..#SEA_DATA[currentSea].islands..")")
for _,il in pairs(SEA_DATA[currentSea].islands) do NexusUI:CreateButton(tabs["🏝️ Ilhas"],{Title="🏝️ "..il[1],Callback=function()tp(il[2])notify("🏝️",il[1],2)end}) end

local fl=Instance.new("TextLabel",win.Frame) fl.Size=UDim2.new(0,220,0,15) fl.Position=UDim2.new(0,10,1,-18) fl.BackgroundTransparency=1 fl.TextColor3=Color3.fromRGB(160,160,170) fl.TextSize=10 fl.Font=Enum.Font.Gotham fl.Text="FPS: --"
local fc,lt=0,tick() RunService.RenderStepped:Connect(function() fc=fc+1 local nw=tick() if nw-lt>=1 then fl.Text="FPS: "..fc.." | 💀 "..kills.." | 🌊 "..SEA_DATA[currentSea].name.." | 🗡️ "..masteryType fc=0 lt=nw end end)
notify("NEXUS v7.0",SEA_DATA[currentSea].name.." | Auto-OP Ready | 🗡️ "..masteryType,5)
print("NEXUS v7.0 - Loaded - "..SEA_DATA[currentSea].name.." - Maestria: "..masteryType)
