-- ==================== NEXUS v7.0 - COMPLETO FINAL + BYPASS + UI CATEGORIAS ====================
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
local TweenService = game:GetService("TweenService")

-- ==================== BYPASS ANTI-BAN ====================
task.spawn(function()
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
end)
pcall(function() player.Kick = function() return nil end end)
task.spawn(function() while true do task.wait(30) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.Velocity = Vector3.zero end end) end end)

-- ==================== ANTI AFK ====================
task.spawn(function() while true do task.wait(300) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(1,0,0),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.new(0,0,0),true) end end) end end)

-- ==================== OTIMIZAÇÃO ====================
pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 if Workspace.Terrain then Workspace.Terrain.WaterWaveSize = 0 Workspace.Terrain.GrassLength = 0 end end)

-- ==================== VARIÁVEIS ====================
local currentTarget, range, attackDelay, espBills, MAX_ESP, kills, sessionStart = nil, 300, 0.5, {}, 10, 0, tick()
local states = {}
local stateNames = {"farmLevel","farmMastery","farmBoss","farmRaid","farmSea","farmDungeon","farmElite","farmScroll","fruitSniper","fruitStore","fruitSpawn","fruitRoll","fruitNotify","fruitESP","bossDK","bossSR","bossCP","bossRI","bossDB","bossTK","bossST","bossIE","bossHY","bossLV","seaShip","seaPirate","seaBeast","seaTerror","seaRumble","seaMansion","seaPRaid","seaCastle","colChest","colBones","colFist","colChalice","colBlue","colSweet","colScroll","colFruitChest","moveHop","moveDash","moveFlight","moveSwim","moveIsland","moveNPC","moveFruit","moveChest","movePlayer","atHaki","atSkill","atMeta","atRace","atAccessory","atTitle","atQuest","atGear","atV4","atRaidFruits","shopFruits","shopStyles","shopSword","shopGuns","shopAcc","shopMat","shopStats","shopGP","shopFrag","shopBones","espP","espF","espC","espB","espI","espM","espN","espSB","espShips","aimlock","noclip","walkspeed","jumpspeed","bountyHunt","fragmentFarm"}
for _, s in pairs(stateNames) do states[s] = false end

-- ==================== FUNÇÕES ====================
local function tp(pos) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) task.wait(0.05) player.Character.HumanoidRootPart.CFrame = CFrame.new(pos) end end) end
local function findTarget() local n,s=nil,range for _,o in pairs(Workspace:GetDescendants()) do pcall(function() if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<s then s=d n=o end end end) end return n end
local function findBoss(name) local b=Workspace:FindFirstChild(name) if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health>0 then return b end for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function findSea(name) for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function attack() pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Click") kills=kills+1 end end) end
local function useSkill(key) pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Skill",key) end end) end
local function buyItem(item) pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem",item) end end) end
local function collectItem(name) for _,o in pairs(Workspace:GetDescendants()) do pcall(function() if o.Name:lower():find(name:lower()) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local pos=o:IsA("BasePart") and o.Position or(o:FindFirstChildOfClass("BasePart") and o:FindFirstChildOfClass("BasePart").Position)or(o:FindFirstChild("Handle") and o.Handle.Position) if pos and(pos-player.Character.HumanoidRootPart.Position).Magnitude<=range then tp(pos) task.wait(0.15) if o:FindFirstChild("TouchInterest") then firetouchinterest(o,player.Character.HumanoidRootPart,0) firetouchinterest(o,player.Character.HumanoidRootPart,1) end end end end) end end
local function notify(title,text,dur) pcall(function() StarterGui:SetCore("SendNotification",{Title=title or"NEXUS",Text=text or"",Duration=dur or 3}) end) end
local function serverHop() pcall(function() local res=game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?limit=10") local servers=HttpService:JSONDecode(res) if servers and servers.data and#servers.data>0 then local s=servers.data[math.random(1,#servers.data)] TeleportService:TeleportToPlaceInstance(game.GameId,s.id,player) end end) end
local function createESP(color,filter) if espBills[filter] then for o,b in pairs(espBills) do if type(o)~="string" then b:Destroy() espBills[o]=nil end end end task.spawn(function() while espBills[filter] do pcall(function() local count=0 for _,o in pairs(Workspace:GetDescendants()) do if count>MAX_ESP then break end if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and o~=player.Character and not espBills[o] then local show=false if filter=="player" then show=Players:GetPlayerFromCharacter(o)~=nil elseif filter=="fruit" then show=o.Name:find("Fruit")~=nil elseif filter=="chest" then show=o.Name:lower():find("chest")~=nil elseif filter=="boss" then show=o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth>10000 elseif filter=="sea" then show=o.Name:lower():find("sea")~=nil elseif filter=="ship" then show=o.Name:lower():find("ship")~=nil elseif filter=="npc" then show=o:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(o) elseif filter=="item" then show=o.Name:find("Fist")or o.Name:find("Chalice")or o.Name:find("Gear")~=nil elseif filter=="material" then show=o.Name:find("Wood")or o.Name:find("Iron")or o.Name:find("Bone")~=nil end if show then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<=range then local bill=Instance.new("BillboardGui") bill.Size=UDim2.new(0,60,0,18) bill.AlwaysOnTop=true bill.MaxDistance=range bill.Parent=o.HumanoidRootPart local label=Instance.new("TextLabel") label.Size=UDim2.new(1,0,1,0) label.BackgroundTransparency=0.7 label.BackgroundColor3=color label.TextColor3=Color3.new(1,1,1) label.TextSize=8 label.Font=Enum.Font.GothamBold label.Text=o.Name label.Parent=bill espBills[o]=bill count=count+1 end end end end for o,b in pairs(espBills) do if type(o)~="string" then pcall(function() if not o.Parent or(o:FindFirstChild("Humanoid") and o.Humanoid.Health<=0) then b:Destroy() espBills[o]=nil end end) end end end) task.wait(3) end end) end

-- ==================== LOOP CENTRAL ====================
task.spawn(function() while true do local t=tick()
if states.farmLevel and t%attackDelay<0.05 then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local tgt=findTarget() if tgt then currentTarget=tgt if(player.Character.HumanoidRootPart.Position-tgt.HumanoidRootPart.Position).Magnitude>15 then tp(tgt.HumanoidRootPart.Position) end attack() end end end) end
if states.farmMastery and t%3<0.05 then pcall(function() useSkill("Z") task.wait(0.5) useSkill("X") end) end
if states.farmBoss and t%8<0.05 then pcall(function() local bosses={"Dough King","Soul Reaper","Cake Prince","Rip_indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"} for _,n in pairs(bosses) do if states.farmBoss then local b=findBoss(n) if b then tp(b.HumanoidRootPart.Position) for _=1,10 do attack() task.wait(0.3) end end end end end) end
if states.farmRaid and t%60<0.05 then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") then tp(o.Position) task.wait(0.5) firetouchinterest(o,player.Character.HumanoidRootPart,0) firetouchinterest(o,player.Character.HumanoidRootPart,1) break end end end) end
if states.farmSea and t%10<0.05 then pcall(function() local sea=findSea("Sea")or findSea("Ship") if sea then tp(sea.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.farmDungeon and t%attackDelay<0.05 then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) attack() end end) end
if states.farmElite and t%5<0.05 then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find("Elite") and o:FindFirstChild("Humanoid") and o.Humanoid.Health>0 then tp(o.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end break end end end) end
if states.farmScroll and t%15<0.05 then collectItem("Scroll") end
if states.fruitSniper and t%8<0.05 then pcall(function() local fruits={"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit","Control-Fruit","Shadow-Fruit","Rumble-Fruit","Buddha-Fruit","Portal-Fruit","Blizzard-Fruit"} for _,n in pairs(fruits) do local f=Workspace:FindFirstChild(n) if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) break end end end) end
if states.fruitStore and t%10<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then r.CommF_:InvokeServer("StoreFruit",player.Data.Fruit.Value) end end) end
if states.fruitSpawn and t%60<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Cousin","Buy") end end) end
if states.fruitRoll and t%15<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("FruitGacha","Roll") end end) end
if states.fruitNotify and t%30<0.05 then pcall(function() for _,n in pairs({"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit"}) do if Workspace:FindFirstChild(n) then notify("FRUTA RARA!",n.." spawnou!",5) end end end) end
if states.fruitESP then if not espBills["fruit"] then espBills["fruit"]=true createESP(Color3.fromRGB(255,0,255),"fruit") end else espBills["fruit"]=nil end
if states.bossDK and t%5<0.05 then pcall(function() local b=findBoss("Dough King") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossSR and t%5<0.05 then pcall(function() local b=findBoss("Soul Reaper") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossCP and t%5<0.05 then pcall(function() local b=findBoss("Cake Prince") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossRI and t%5<0.05 then pcall(function() local b=findBoss("Rip_indra") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossDB and t%5<0.05 then pcall(function() local b=findBoss("Darkbeard") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossTK and t%5<0.05 then pcall(function() local b=findBoss("Tide Keeper") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossST and t%5<0.05 then pcall(function() local b=findBoss("Stone") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossIE and t%5<0.05 then pcall(function() local b=findBoss("Island Empress") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossHY and t%5<0.05 then pcall(function() local b=findBoss("Hydra") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.bossLV and t%5<0.05 then pcall(function() local b=findBoss("Leviathan") if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end
if states.seaShip and t%10<0.05 then pcall(function() local s=findSea("Marine") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.seaPirate and t%10<0.05 then pcall(function() local s=findSea("Pirate") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.seaBeast and t%8<0.05 then pcall(function() local s=findSea("Sea Beast") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.seaTerror and t%10<0.05 then pcall(function() local s=findSea("Terror") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.seaRumble and t%15<0.05 then pcall(function() local s=findSea("Rumbling") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.seaMansion and t%20<0.05 then pcall(function() local s=findSea("Mansion") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.seaPRaid and t%15<0.05 then pcall(function() local s=findSea("Raid") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.seaCastle and t%20<0.05 then pcall(function() local s=findSea("Castle") if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.colChest and t%12<0.05 then collectItem("Chest") end
if states.colBones and t%8<0.05 then collectItem("Bone") end
if states.colFist and t%20<0.05 then collectItem("Fist") end
if states.colChalice and t%20<0.05 then collectItem("Chalice") end
if states.colBlue and t%20<0.05 then collectItem("Blue Gear") end
if states.colSweet and t%20<0.05 then collectItem("Sweet") end
if states.colScroll and t%15<0.05 then collectItem("Scroll") end
if states.colFruitChest and t%20<0.05 then collectItem("Fruit Chest") end
if states.moveHop and t%180<0.05 then serverHop() end
if states.moveDash and t%5<0.05 then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=player.Character.HumanoidRootPart.CFrame+Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit*25 end end) end
if states.moveFlight and t%2<0.05 then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end
if states.moveSwim and t%2<0.05 then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end end end) end
if states.moveIsland and t%30<0.05 then tp(Vector3.new(math.random(-5000,5000),50,math.random(-5000,5000))) end
if states.moveNPC and t%15<0.05 then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) end end) end
if states.moveFruit and t%15<0.05 then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o.Name:find("Fruit") and o:FindFirstChild("Handle") then tp(o.Handle.Position) break end end end) end
if states.moveChest and t%15<0.05 then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o.Name:find("Chest") and o:FindFirstChildOfClass("BasePart") then tp(o:FindFirstChildOfClass("BasePart").Position) break end end end) end
if states.movePlayer and t%20<0.05 then pcall(function() local best,bb=nil,0 for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b=p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b>bb then bb=b best=p end end end if best then tp(best.Character.HumanoidRootPart.Position) end end) end
if states.atHaki and t%120<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Buso") end end) end
if states.atSkill and t%5<0.05 then pcall(function() for _,s in pairs({"Z","X","C"}) do useSkill(s) task.wait(0.5) end end) end
if states.atMeta and t%180<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Metaverse","Start") end end) end
if states.atRace and t%180<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceAwakening","Start") end end) end
if states.atAccessory and t%8<0.05 then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) for _=1,3 do attack() task.wait(0.3) end end end) end
if states.atTitle and t%180<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Title","Equip") end end) end
if states.atQuest and t%30<0.05 then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and(o:FindFirstChild("Quest")or o:FindFirstChild("Talk")) then tp(o.HumanoidRootPart.Position) task.wait(1) local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest",o.Name) end break end end end) end
if states.atGear and t%20<0.05 then collectItem("Gear") end
if states.atV4 and t%180<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4","Start") end end) end
if states.atRaidFruits and t%120<0.05 then pcall(function() for _,o in pairs(Workspace:GetDescendants()) do if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") then tp(o.Position) task.wait(0.5) firetouchinterest(o,player.Character.HumanoidRootPart,0) firetouchinterest(o,player.Character.HumanoidRootPart,1) break end end end) end
if states.shopFruits and t%600<0.05 then for _,item in pairs({"Kitsune","Dragon","Leopard"}) do buyItem(item) task.wait(2) end end
if states.shopStyles and t%600<0.05 then for _,item in pairs({"Superhuman","Godhuman"}) do buyItem(item) task.wait(2) end end
if states.shopSword and t%600<0.05 then for _,item in pairs({"Cursed Dual Katana","Dark Blade"}) do buyItem(item) task.wait(2) end end
if states.shopGuns and t%600<0.05 then for _,item in pairs({"Soul Guitar"}) do buyItem(item) task.wait(2) end end
if states.shopAcc and t%600<0.05 then for _,item in pairs({"Pale Scarf"}) do buyItem(item) task.wait(2) end end
if states.shopMat and t%600<0.05 then for _,item in pairs({"Wood","Iron"}) do buyItem(item) task.wait(2) end end
if states.shopStats and t%5<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) end
if states.shopGP and t%900<0.05 then buyItem("Gamepass") end
if states.shopFrag and t%60<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) end
if states.shopBones and t%30<0.05 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end) end
if states.espP then if not espBills["player"] then espBills["player"]=true createESP(Color3.fromRGB(255,0,0),"player") end else espBills["player"]=nil end
if states.espF then if not espBills["fruit"] then espBills["fruit"]=true createESP(Color3.fromRGB(255,0,255),"fruit") end else espBills["fruit"]=nil end
if states.espC then if not espBills["chest"] then espBills["chest"]=true createESP(Color3.fromRGB(255,215,0),"chest") end else espBills["chest"]=nil end
if states.espB then if not espBills["boss"] then espBills["boss"]=true createESP(Color3.fromRGB(255,50,50),"boss") end else espBills["boss"]=nil end
if states.aimlock and t%0.3<0.05 then pcall(function() local tgt=findTarget() if tgt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position,tgt.HumanoidRootPart.Position) end end) end
if states.noclip and t%0.5<0.05 then pcall(function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end
if states.walkspeed and t%0.5<0.05 then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=100 end end end) end
if states.jumpspeed and t%0.5<0.05 then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=100 end end end) end
if states.bountyHunt and t%15<0.05 then pcall(function() local best,bb=nil,0 for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b=p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b>bb then bb=b best=p end end end if best then tp(best.Character.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if states.fragmentFarm and t%5<0.05 then pcall(function() local tgt=findTarget() if tgt then tp(tgt.HumanoidRootPart.Position) for _=1,3 do attack() task.wait(0.3) end end end) end
if states.farmLevel or states.farmBoss then pcall(function() if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.Health=h.MaxHealth end end end) end
if t%60<0.05 then pcall(function() collectgarbage("collect") for o,b in pairs(espBills) do if type(o)~="string" then pcall(function() if not o.Parent or(o:FindFirstChild("Humanoid") and o.Humanoid.Health<=0) then b:Destroy() espBills[o]=nil end end) end end end) end
task.wait(0.1) end end)

-- ==================== UI COM CATEGORIAS ====================
local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusUI"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Size = UDim2.new(0, 45, 0, 45)
    floatingBtn.Position = UDim2.new(1, -55, 0.5, -22)
    floatingBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 40)
    floatingBtn.BorderSizePixel = 0
    floatingBtn.Text = "⚡"
    floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingBtn.Font = Enum.Font.GothamBold
    floatingBtn.TextSize = 22
    floatingBtn.AutoButtonColor = false
    floatingBtn.Parent = gui
    Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(1, 0)
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 420, 0, 500)
    main.Position = UDim2.new(0.5, -210, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(200, 50, 40)
    Instance.new("UIStroke", main).Thickness = 1.5
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    header.BorderSizePixel = 0
    header.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 7)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "⚡ NEXUS v7.0"
    title.Parent = header
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 7)
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 7)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    -- Container principal
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, -45)
    container.Position = UDim2.new(0, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = main
    
    -- Sidebar de categorias
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 130, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    
    -- Área de conteúdo
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Size = UDim2.new(1, -130, 1, 0)
    contentArea.Position = UDim2.new(0, 130, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 3
    contentArea.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 40)
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.Parent = container
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 2)
    contentLayout.Parent = contentArea
    
    -- Categorias
    local categories = {
        {name = "⚔️ Combate", icon = "⚔️", items = {"Auto Farm Nível","Auto Farm Maestria","Auto Farm Boss","Auto Farm Raid","Auto Farm Sea","Auto Farm Dungeon","Auto Farm Elite","Auto Farm Scroll"}},
        {name = "🍎 Frutas", icon = "🍎", items = {"Fruit Sniper","Auto Store Fruit","Auto Spawn Fruit","Auto Roll Fruit","Fruit Notify","Fruit ESP"}},
        {name = "🎯 Bosses", icon = "🎯", items = {"Dough King","Soul Reaper","Cake Prince","Rip Indra","Darkbeard","Tide Keeper","Stone","Island Empress","Hydra","Leviathan"}},
        {name = "🌊 Sea", icon = "🌊", items = {"Marine Ship","Pirate Ship","Sea Beast","Terror Shark","Rumbling","Mansion","Pirate Raid","Sea Castle"}},
        {name = "📦 Coleta", icon = "📦", items = {"Auto Chest","Auto Bones","Fist of Darkness","God's Chalice","Blue Gear","Sweet Chalice","Scroll","Fruit Chest"}},
        {name = "🏃 Move", icon = "🏃", items = {"Auto Hop","Auto Dash","Auto Flight","Auto Swim","TP Island","TP NPC","TP Fruit","TP Chest","TP Player"}},
        {name = "⚙️ Auto", icon = "⚙️", items = {"Auto Haki","Auto Skill","Metaverse","Race Awakening","Accessory","Title","Auto Quest","Gear Farm","V4 Awakening","Raid Fruits"}},
        {name = "🛍️ Loja", icon = "🛍️", items = {"Buy Fruits","Buy Styles","Buy Sword","Buy Guns","Buy Accessories","Buy Materials","Buy Stats","Buy Gamepass","Buy Fragments","Buy Bones"}},
        {name = "👀 Visual", icon = "👀", items = {"ESP Players","ESP Fruits","ESP Chests","ESP Bosses","ESP Items","ESP Materials","ESP NPCs","ESP Sea","ESP Ships"}},
        {name = "🎮 Extra", icon = "🎮", items = {"Aimlock","No Clip","Walkspeed","Jumpspeed","Bounty Hunt","Fragment Farm"}},
    }
    
    local currentCategory = 1
    local categoryBtns = {}
    local contentFrames = {}
    
    -- Mapa de variáveis (mesmo de antes)
    local varMap = {
        ["Auto Farm Nível"] = function(v) states.farmLevel = v end,
        ["Auto Farm Maestria"] = function(v) states.farmMastery = v end,
        ["Auto Farm Boss"] = function(v) states.farmBoss = v end,
        ["Auto Farm Raid"] = function(v) states.farmRaid = v end,
        ["Auto Farm Sea"] = function(v) states.farmSea = v end,
        ["Auto Farm Dungeon"] = function(v) states.farmDungeon = v end,
        ["Auto Farm Elite"] = function(v) states.farmElite = v end,
        ["Auto Farm Scroll"] = function(v) states.farmScroll = v end,
        ["Fruit Sniper"] = function(v) states.fruitSniper = v end,
        ["Auto Store Fruit"] = function(v) states.fruitStore = v end,
        ["Auto Spawn Fruit"] = function(v) states.fruitSpawn = v end,
        ["Auto Roll Fruit"] = function(v) states.fruitRoll = v end,
        ["Fruit Notify"] = function(v) states.fruitNotify = v end,
        ["Fruit ESP"] = function(v) states.fruitESP = v end,
        ["Dough King"] = function(v) states.bossDK = v end,
        ["Soul Reaper"] = function(v) states.bossSR = v end,
        ["Cake Prince"] = function(v) states.bossCP = v end,
        ["Rip Indra"] = function(v) states.bossRI = v end,
        ["Darkbeard"] = function(v) states.bossDB = v end,
        ["Tide Keeper"] = function(v) states.bossTK = v end,
        ["Stone"] = function(v) states.bossST = v end,
        ["Island Empress"] = function(v) states.bossIE = v end,
        ["Hydra"] = function(v) states.bossHY = v end,
        ["Leviathan"] = function(v) states.bossLV = v end,
        ["Marine Ship"] = function(v) states.seaShip = v end,
        ["Pirate Ship"] = function(v) states.seaPirate = v end,
        ["Sea Beast"] = function(v) states.seaBeast = v end,
        ["Terror Shark"] = function(v) states.seaTerror = v end,
        ["Rumbling"] = function(v) states.seaRumble = v end,
        ["Mansion"] = function(v) states.seaMansion = v end,
        ["Pirate Raid"] = function(v) states.seaPRaid = v end,
        ["Sea Castle"] = function(v) states.seaCastle = v end,
        ["Auto Chest"] = function(v) states.colChest = v end,
        ["Auto Bones"] = function(v) states.colBones = v end,
        ["Fist of Darkness"] = function(v) states.colFist = v end,
        ["God's Chalice"] = function(v) states.colChalice = v end,
        ["Blue Gear"] = function(v) states.colBlue = v end,
        ["Sweet Chalice"] = function(v) states.colSweet = v end,
        ["Scroll"] = function(v) states.colScroll = v end,
        ["Fruit Chest"] = function(v) states.colFruitChest = v end,
        ["Auto Hop"] = function(v) states.moveHop = v end,
        ["Auto Dash"] = function(v) states.moveDash = v end,
        ["Auto Flight"] = function(v) states.moveFlight = v end,
        ["Auto Swim"] = function(v) states.moveSwim = v end,
        ["TP Island"] = function(v) states.moveIsland = v end,
        ["TP NPC"] = function(v) states.moveNPC = v end,
        ["TP Fruit"] = function(v) states.moveFruit = v end,
        ["TP Chest"] = function(v) states.moveChest = v end,
        ["TP Player"] = function(v) states.movePlayer = v end,
        ["Auto Haki"] = function(v) states.atHaki = v end,
        ["Auto Skill"] = function(v) states.atSkill = v end,
        ["Metaverse"] = function(v) states.atMeta = v end,
        ["Race Awakening"] = function(v) states.atRace = v end,
        ["Accessory"] = function(v) states.atAccessory = v end,
        ["Title"] = function(v) states.atTitle = v end,
        ["Auto Quest"] = function(v) states.atQuest = v end,
        ["Gear Farm"] = function(v) states.atGear = v end,
        ["V4 Awakening"] = function(v) states.atV4 = v end,
        ["Raid Fruits"] = function(v) states.atRaidFruits = v end,
        ["Buy Fruits"] = function(v) states.shopFruits = v end,
        ["Buy Styles"] = function(v) states.shopStyles = v end,
        ["Buy Sword"] = function(v) states.shopSword = v end,
        ["Buy Guns"] = function(v) states.shopGuns = v end,
        ["Buy Accessories"] = function(v) states.shopAcc = v end,
        ["Buy Materials"] = function(v) states.shopMat = v end,
        ["Buy Stats"] = function(v) states.shopStats = v end,
        ["Buy Gamepass"] = function(v) states.shopGP = v end,
        ["Buy Fragments"] = function(v) states.shopFrag = v end,
        ["Buy Bones"] = function(v) states.shopBones = v end,
        ["ESP Players"] = function(v) states.espP = v end,
        ["ESP Fruits"] = function(v) states.espF = v end,
        ["ESP Chests"] = function(v) states.espC = v end,
        ["ESP Bosses"] = function(v) states.espB = v end,
        ["ESP Items"] = function(v) states.espI = v end,
        ["ESP Materials"] = function(v) states.espM = v end,
        ["ESP NPCs"] = function(v) states.espN = v end,
        ["ESP Sea"] = function(v) states.espSB = v end,
        ["ESP Ships"] = function(v) states.espShips = v end,
        ["Aimlock"] = function(v) states.aimlock = v end,
        ["No Clip"] = function(v) states.noclip = v end,
        ["Walkspeed"] = function(v) states.walkspeed = v if not v and player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end end end,
        ["Jumpspeed"] = function(v) states.jumpspeed = v if not v and player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=50 end end end,
        ["Bounty Hunt"] = function(v) states.bountyHunt = v end,
        ["Fragment Farm"] = function(v) states.fragmentFarm = v end,
    }
    
    local toggleStates = {}
    
    -- Criar botões da sidebar
    for i, cat in pairs(categories) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.Position = UDim2.new(0, 5, 0, (i-1)*34 + 5)
        btn.Text = "  " .. cat.icon .. " " .. cat.name
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(200, 50, 40) or Color3.fromRGB(25, 25, 35)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        categoryBtns[i] = btn
        
        -- Criar frame de conteúdo
        local cf = Instance.new("Frame")
        cf.Size = UDim2.new(1, -10, 0, 0)
        cf.Position = UDim2.new(0, 5, 0, 0)
        cf.BackgroundTransparency = 1
        cf.Visible = (i == 1)
        cf.Parent = contentArea
        contentFrames[i] = cf
        
        local cfLayout = Instance.new("UIListLayout")
        cfLayout.Padding = UDim.new(0, 2)
        cfLayout.Parent = cf
        
        -- Adicionar toggles ao frame de conteúdo
        for j, itemName in pairs(cat.items) do
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 32)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = cf
            Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 5)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.65, 0, 1, 0)
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(220, 220, 230)
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = itemName
            label.Parent = toggleFrame
            
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 40, 0, 20)
            toggle.Position = UDim2.new(1, -46, 0.5, -10)
            toggle.Text = "OFF"
            toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggle.Font = Enum.Font.GothamBold
            toggle.TextSize = 9
            toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            toggle.BorderSizePixel = 0
            toggle.AutoButtonColor = false
            toggle.Parent = toggleFrame
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)
            
            toggleStates[itemName] = false
            
            toggle.MouseButton1Click:Connect(function()
                toggleStates[itemName] = not toggleStates[itemName]
                if varMap[itemName] then varMap[itemName](toggleStates[itemName]) end
                toggle.Text = toggleStates[itemName] and "ON" or "OFF"
                toggle.BackgroundColor3 = toggleStates[itemName] and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(60, 60, 70)
            end)
        end
        
        -- Ajustar tamanho do frame de conteúdo
        cf.Size = UDim2.new(1, -10, 0, #cat.items * 34 + 10)
        
        -- Evento do botão da categoria
        btn.MouseButton1Click:Connect(function()
            currentCategory = i
            for k, cbtn in pairs(categoryBtns) do
                cbtn.BackgroundColor3 = k == i and Color3.fromRGB(200, 50, 40) or Color3.fromRGB(25, 25, 35)
            end
            for k, cframe in pairs(contentFrames) do
                cframe.Visible = (k == i)
            end
            contentArea.CanvasSize = UDim2.new(0, 0, 0, #cat.items * 34 + 20)
        end)
    end
    
    contentArea.CanvasSize = UDim2.new(0, 0, 0, #categories[1].items * 34 + 20)
    
    -- Minimizar/Mostrar
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            container.Visible = false
            main.Size = UDim2.new(0, 280, 0, 45)
            floatingBtn.Visible = true
        else
            container.Visible = true
            main.Size = UDim2.new(0, 420, 0, 500)
            floatingBtn.Visible = false
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        minimized = true
        container.Visible = false
        main.Size = UDim2.new(0, 280, 0, 45)
        floatingBtn.Visible = true
    end)
    
    floatingBtn.MouseButton1Click:Connect(function()
        minimized = false
        container.Visible = true
        main.Size = UDim2.new(0, 420, 0, 500)
        floatingBtn.Visible = false
    end)
    
    -- FPS Label
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.4, 0, 0, 15)
    fpsLabel.Position = UDim2.new(0, 10, 1, -18)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextSize = 9
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Text = "FPS: --"
    fpsLabel.Parent = main
    
    local fc, lt = 0, tick()
    RunService.RenderStepped:Connect(function()
        fc = fc + 1
        local nw = tick()
        if nw - lt >= 1 then
            fpsLabel.Text = "FPS: " .. fc .. " | ⚔️" .. kills
            fc = 0 lt = nw
        end
    end)
    
    -- Arrastar
    local drag, ds, sp = false, nil, nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true ds = i.Position sp = main.Position end
    end)
    header.InputEnded:Connect(function() drag = false end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement and drag then
            local delta = i.Position - ds
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    
    -- Animação
    main.Size = UDim2.new(0, 0, 0, 500)
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 420, 0, 500)}):Play()
end

createUI()
notify("NEXUS v7.0", "84 Funções | Categorias | Bypass | Minimizar", 5)
print("NEXUS v7.0 - Completo Final - Loaded")
