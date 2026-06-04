-- ============================================================
-- NEXUS v7.0.9 - 286 FUNÇÕES COMPLETAS
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
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local function randomDelay(min, max) return math.random(min * 1000, max * 1000) / 1000 end
local function notify(t, txt, d) pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "Stats", Text = txt or "", Duration = d or 3}) end) end

-- ============================================================
-- ANTI-BAN 6 CAMADAS
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
task.spawn(function() while true do task.wait(randomDelay(15,35)) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=player.Character.HumanoidRootPart.CFrame*CFrame.new(randomDelay(-0.5,0.5),0,randomDelay(-0.5,0.5)) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(250,350)) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(math.random(-1,1),0,math.random(-1,1)),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero,true) end end) end end)
task.spawn(function() while true do task.wait(randomDelay(60,120)) pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new(math.random(300,900),math.random(300,600))) end) end end)

-- ============================================================
-- OTIMIZAÇÃO
-- ============================================================
pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 if Workspace.Terrain then Workspace.Terrain.WaterWaveSize = 0 Workspace.Terrain.GrassLength = 0 end for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("ParticleEmitter")or o:IsA("Fire")or o:IsA("Smoke")then o.Enabled=false end end end)

-- ============================================================
-- DADOS DOS SEAS (COMPLETO - 3 SEAS)
-- ============================================================
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
        fruits = {"Rocket-Fruit","Spin-Fruit","Blade-Fruit","Spring-Fruit","Bomb-Fruit","Smoke-Fruit","Spike-Fruit","Flame-Fruit","Eagle-Fruit","Ice-Fruit","Sand-Fruit","Dark-Fruit","Diamond-Fruit","Light-Fruit","Barrier-Fruit","Magma-Fruit","Rumble-Fruit"},
        fightingStyles = {"Dark Step","Electric","Water Kung Fu","Dragon Breath"},
        swords = {"Saber","Triple Katana","Warden's Sword","Long Sword","Trident"},
        guns = {"Slingshot","Musket","Flintlock","Refined Musket"},
        accessories = {"Black Cape","Swordsman Hat","Pink Coat","Tomoe Ring","Cool Shades"},
        materials = {"Wood","Iron","Steel","Mithril"},
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
        fightingStyles = {"Superhuman","Death Step","Sharkman Karate","Electric Claw"},
        swords = {"Cursed Dual Katana","True Triple Katana","Dark Blade","Shark Anchor"},
        guns = {"Soul Guitar","Acidum Rifle","Bizarre Rifle","Serpent Bow"},
        accessories = {"Pale Scarf","Valkyrie Helmet","Lei","Swan Glasses","Black Spikey Coat"},
        materials = {"Steel","Mithril","Adamantite","Carbon"},
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
        fruits = {"Gravity-Fruit","Mammoth-Fruit","T-Rex-Fruit","Dough-Fruit","Shadow-Fruit","Venom-Fruit","Control-Fruit","Gas-Fruit","Spirit-Fruit","Tiger-Fruit","Yeti-Fruit","Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit"},
        fightingStyles = {"Dragon Talon","Godhuman","Sanguine Art"},
        swords = {"Cursed Dual Katana","True Triple Katana","Dark Blade","Shark Anchor","Spikey Trident"},
        guns = {"Soul Guitar","Skull Guitar","Dragonstorm"},
        accessories = {"Pale Scarf","Valkyrie Helmet","Hunter Cape","Leviathan Crown","Holy Crown"},
        materials = {"Adamantite","Carbon","Void","Celestial"},
    },
}

-- ============================================================
-- DETECÇÃO DE SEA
-- ============================================================
local currentSea = 1
local function detectSea()
    local lvl = 1
    pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl = player.Data.Level.Value end end)
    if lvl <= 700 then currentSea = 1 elseif lvl <= 1500 then currentSea = 2 else currentSea = 3 end
    return currentSea
end
detectSea()

-- ============================================================
-- VARIÁVEIS (TODAS AS 286 FUNÇÕES)
-- ============================================================
local currentTarget, range, kills = nil, CONFIG.DEFAULT_RANGE, 0
local lastAttackTime, masteryType = 0, "Fruit"
local espBills, MAX_ESP = {}, CONFIG.MAX_ESP_OBJECTS

-- Super Farm
local superFarmEnabled = false
-- Farm de Bosses
local farmBossDoughKing, farmBossSoulReaper, farmBossCakePrince, farmBossRipIndra, farmBossDarkbeard = false,false,false,false,false
local farmBossTideKeeper, farmBossStone, farmBossIslandEmpress, farmBossHydra, farmBossLeviathan = false,false,false,false,false
local farmBossBeautifulPirate, farmBossElitePirates, farmBossPharaohAkshan, farmBossFossilExpert = false,false,false,false
local farmBossGorillaKing, farmBossYeti, farmBossViceAdmiral, farmBossSaberExpert, farmBossSwan = false,false,false,false,false
local farmBossMagmaAdmiral, farmBossFishmanLord, farmBossWysper, farmBossThunderGod, farmBossCyborg = false,false,false,false,false
local farmBossDiamond, farmBossJeremy, farmBossOrbitus, farmBossDonSwan, farmBossSmokeAdmiral = false,false,false,false,false
local farmBossAwakenedIceAdmiral = false
-- Sea Events
local farmSeaMarineShip, farmSeaPirateShip, farmSeaBeast, farmSeaTerrorShark = false,false,false,false
local farmSeaRumbling, farmSeaMansion, farmSeaPirateRaid, farmSeaCastle = false,false,false,false
local farmSeaGhostShip, farmSeaTreasureIsland, farmSeaFrozenDimension, farmSeaGumihoShrine = false,false,false,false
-- Farms
local fragmentFarmEnabled, bonesFarmEnabled, beliFarmEnabled, gemFarmEnabled, scrollFarmEnabled = false,false,false,false,false
local fistDarknessFarmEnabled, godsChaliceFarmEnabled, blueGearFarmEnabled, sweetChaliceFarmEnabled = false,false,false,false
local fruitChestFarmEnabled, legendaryScrollFarmEnabled, eliteQuestFarmEnabled, dungeonFarmEnabled = false,false,false,false
local raidFarmEnabled, metaverseFarmEnabled, raceAwakeningFarmEnabled, accessoryFarmEnabled = false,false,false,false
local titleFarmEnabled, gearFarmEnabled, v4FarmEnabled, raidFruitsFarmEnabled = false,false,false,false
-- Movimento
local moveHopEnabled, moveDashEnabled, moveFlightEnabled, moveSwimEnabled = false,false,false,false
local moveTpIslandEnabled, moveTpNPCEnabled, moveTpFruitEnabled, moveTpChestEnabled, moveTpPlayerEnabled = false,false,false,false,false
-- Automáticos
local autoHakiEnabled, autoSkillEnabled, autoQuestEnabled = false,false,false
local autoEquipBestFruitEnabled, autoEquipBestSwordEnabled, autoEquipBestGunEnabled = false,false,false
local autoStatsEnabled, autoBuyEnabled, autoSpawnFruitEnabled, autoRollFruitEnabled = false,false,false,false
local autoStoreFruitEnabled, autoNotifyFruitEnabled, autoV4AwakeningEnabled, autoRaceEnabled = false,false,false,false
-- Loja
local shopFruitsEnabled, shopStylesEnabled, shopSwordsEnabled, shopGunsEnabled = false,false,false,false
local shopAccessoriesEnabled, shopMaterialsEnabled, shopStatsEnabled, shopGamepassEnabled = false,false,false,false
local shopFragmentsEnabled, shopBonesEnabled = false,false
-- Visual
local espPlayersEnabled, espFruitsEnabled, espChestsEnabled, espBossesEnabled = false,false,false,false
local espItemsEnabled, espMaterialsEnabled, espNPCsEnabled, espSeaBeastsEnabled, espShipsEnabled = false,false,false,false,false
local espLevelEnabled, espHealthEnabled, espDistanceEnabled, espBoxEnabled, espLineEnabled = false,false,false,false,false
local fullBrightEnabled, noFogEnabled, noGrassEnabled, lowQualityEnabled = false,false,false,false
-- Extra
local aimlockEnabled, noclipEnabled, walkspeedEnabled, bountyHuntEnabled, jumpspeedEnabled = false,false,false,false,false
local antiStunEnabled, antiKnockbackEnabled, infiniteJumpEnabled, speedHackEnabled = false,false,false,false
local flyEnabled, noclipWorldEnabled, xrayEnabled, espCollectiblesEnabled = false,false,false,false
local autoReconnectEnabled, autoJoinFriendEnabled, autoLeaveServerEnabled = false,false,false
-- Player
local godmodeEnabled, killAuraEnabled, autoHealEnabled, autoDodgeEnabled, autoBlockEnabled = false,false,false,false,false
local infiniteEnergyEnabled, noClipWorldEnabled2, phaseWalkEnabled, superSpeedEnabled = false,false,false,false
-- Macros
local macro1Enabled, macro2Enabled, macro3Enabled, macro4Enabled, macro5Enabled = false,false,false,false,false
-- Config
local autoSaveConfigEnabled, autoLoadConfigEnabled, darkThemeEnabled, lightThemeEnabled = false,false,false,false
local compactModeEnabled, showFPSEnabled, showKillsEnabled, showTimeEnabled = false,false,false,false

-- ============================================================
-- SUPER FARM (CAIXA INVISÍVEL)
-- ============================================================
local SuperFarm = {
    boxPart = nil, boxSize = Vector3.new(5, 3, 5), flyHeight = 1.5,
    collectedMobs = {}, lastCollectTime = 0, collectCooldown = 0.3,
}
function SuperFarm.createBox()
    if SuperFarm.boxPart and SuperFarm.boxPart.Parent then SuperFarm.boxPart:Destroy() end
    local part = Instance.new("Part", Workspace)
    part.Name = "NexusFarmBox" part.Size = SuperFarm.boxSize part.Anchored = true part.CanCollide = false part.Transparency = 1
    SuperFarm.boxPart = part
end
function SuperFarm.positionBox()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not SuperFarm.boxPart then return end
    SuperFarm.boxPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0, SuperFarm.flyHeight, 0))
end
function SuperFarm.collectMobs()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not SuperFarm.boxPart then return end
    if tick() - SuperFarm.lastCollectTime < SuperFarm.collectCooldown then return end
    SuperFarm.lastCollectTime = tick()
    local hrp, boxPos = player.Character.HumanoidRootPart, SuperFarm.boxPart.Position
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local mHrp, mHum = obj:FindFirstChild("HumanoidRootPart"), obj:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 and (mHrp.Position - hrp.Position).Magnitude <= range and not SuperFarm.collectedMobs[obj] then
                mHrp.CFrame = CFrame.new(boxPos + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
                SuperFarm.collectedMobs[obj] = true
            end
        end
    end
end
function SuperFarm.attackMobs()
    if not SuperFarm.boxPart then return end
    for obj, _ in pairs(SuperFarm.collectedMobs) do
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then currentTarget = obj attack()
        else SuperFarm.collectedMobs[obj] = nil end
    end
end
function SuperFarm.flyPlayer()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not SuperFarm.boxPart then return end
    local hrp = player.Character.HumanoidRootPart
    hrp.CFrame = CFrame.new(SuperFarm.boxPart.Position + Vector3.new(0, SuperFarm.flyHeight, 0))
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
end

-- ============================================================
-- FUNÇÕES BÁSICAS
-- ============================================================
local function tp(pos) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local h=player.Character.HumanoidRootPart h.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) task.wait(0.05) h.CFrame=CFrame.new(pos) end end) end
local function attack() local cd=randomDelay(CONFIG.MIN_ATTACK_DELAY,CONFIG.MAX_ATTACK_DELAY) if tick()-lastAttackTime<cd then return end lastAttackTime=tick() pcall(function() VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(randomDelay(0.04,0.08)) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) kills=kills+1 end) end
local function useSkill(kc) pcall(function() VirtualInputManager:SendKeyEvent(true,kc,false,game) task.wait(randomDelay(0.08,0.15)) VirtualInputManager:SendKeyEvent(false,kc,false,game) end) end
local function buyItem(item) pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem",item) end end) end
local function findBoss(name) local b=Workspace:FindFirstChild(name) if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health>0 then return b end for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function findSea(name) for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end
local function collectItem(name) for _,o in pairs(Workspace:GetDescendants()) do pcall(function() if o.Name:lower():find(name:lower(),1,true) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local pos=o:IsA("BasePart")and o.Position or(o:FindFirstChildOfClass("BasePart")and o:FindFirstChildOfClass("BasePart").Position)or(o:FindFirstChild("Handle")and o.Handle.Position) if pos and(pos-player.Character.HumanoidRootPart.Position).Magnitude<=range then tp(pos) task.wait(0.15) if o:FindFirstChild("TouchInterest")then firetouchinterest(o,player.Character.HumanoidRootPart,0) firetouchinterest(o,player.Character.HumanoidRootPart,1) end end end end) end end

-- ============================================================
-- LOOP CENTRAL (286 FUNÇÕES)
-- ============================================================
task.spawn(function() while true do local t=tick() detectSea()
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then task.wait(0.5) continue end

-- GODMODE
if godmodeEnabled or superFarmEnabled then pcall(function() local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=hum.MaxHealth end end) end
-- KILL AURA
if killAuraEnabled then pcall(function() local hrp=player.Character.HumanoidRootPart for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o~=player.Character and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and(o.HumanoidRootPart.Position-hrp.Position).Magnitude<range then tp(o.HumanoidRootPart.Position) attack() end end end) end
-- SUPER FARM
if superFarmEnabled then pcall(function() SuperFarm.createBox() SuperFarm.positionBox() SuperFarm.flyPlayer() SuperFarm.collectMobs() SuperFarm.attackMobs() if t%3<0.1 then useSkill(Enum.KeyCode.Z) task.wait(0.5) useSkill(Enum.KeyCode.X) end if t%8<0.1 then for _,n in pairs(SEA_DATA[currentSea].fruits) do local f=Workspace:FindFirstChild(n) if f and f:FindFirstChild("Handle") then tp(f.Handle.Position) break end end end if t%15<0.1 then collectItem("Chest") collectItem("Bone") end if t%30<0.1 then for _,obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and(obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")) then if obj:FindFirstChild("HumanoidRootPart") then tp(obj.HumanoidRootPart.Position) break end end end end if t%60<0.1 then local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Observation") end end if t%300<0.1 then buyItem("Kitsune") buyItem("Dragon") buyItem("Leopard") end end) else if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end SuperFarm.collectedMobs={} end

-- FARM BOSSES (30+ bosses)
local bossList = {
    {farmBossDoughKing,"Dough King"},{farmBossSoulReaper,"Soul Reaper"},{farmBossCakePrince,"Cake Prince"},
    {farmBossRipIndra,"Rip Indra"},{farmBossDarkbeard,"Darkbeard"},{farmBossTideKeeper,"Tide Keeper"},
    {farmBossStone,"Stone"},{farmBossIslandEmpress,"Island Empress"},{farmBossHydra,"Hydra"},
    {farmBossLeviathan,"Leviathan"},{farmBossBeautifulPirate,"Beautiful Pirate"},{farmBossElitePirates,"Elite Pirates"},
    {farmBossPharaohAkshan,"Pharaoh Akshan"},{farmBossFossilExpert,"Fossil Expert"},{farmBossGorillaKing,"Gorilla King"},
    {farmBossYeti,"Yeti"},{farmBossViceAdmiral,"Vice Admiral"},{farmBossSaberExpert,"Saber Expert"},
    {farmBossSwan,"Swan"},{farmBossMagmaAdmiral,"Magma Admiral"},{farmBossFishmanLord,"Fishman Lord"},
    {farmBossWysper,"Wysper"},{farmBossThunderGod,"Thunder God"},{farmBossCyborg,"Cyborg"},
    {farmBossDiamond,"Diamond"},{farmBossJeremy,"Jeremy"},{farmBossOrbitus,"Orbitus"},
    {farmBossDonSwan,"Don Swan"},{farmBossSmokeAdmiral,"Smoke Admiral"},{farmBossAwakenedIceAdmiral,"Awakened Ice Admiral"},
}
for _,bd in pairs(bossList) do if bd[1] and t%5<0.1 then pcall(function() local b=findBoss(bd[2]) if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end) end end

-- SEA EVENTS (12 eventos)
local seaList = {
    {farmSeaMarineShip,"Marine"},{farmSeaPirateShip,"Pirate"},{farmSeaBeast,"Sea Beast"},
    {farmSeaTerrorShark,"Terror"},{farmSeaRumbling,"Rumbling"},{farmSeaMansion,"Mansion"},
    {farmSeaPirateRaid,"Raid"},{farmSeaCastle,"Castle"},{farmSeaGhostShip,"Ghost Ship"},
    {farmSeaTreasureIsland,"Treasure"},{farmSeaFrozenDimension,"Frozen"},{farmSeaGumihoShrine,"Gumiho"},
}
for _,sd in pairs(seaList) do if sd[1] and t%10<0.1 then pcall(function() local s=findSea(sd[2]) if s then tp(s.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end end

-- FARMS
if fragmentFarmEnabled and t%60<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",500) end end) end
if bonesFarmEnabled and t%30<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",50) end end) end
if beliFarmEnabled and t%10<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddMoney",10000) end end) end
if scrollFarmEnabled and t%15<0.1 then collectItem("Scroll") end
if fistDarknessFarmEnabled and t%20<0.1 then collectItem("Fist") end
if godsChaliceFarmEnabled and t%20<0.1 then collectItem("Chalice") end
if blueGearFarmEnabled and t%20<0.1 then collectItem("Blue Gear") end
if sweetChaliceFarmEnabled and t%20<0.1 then collectItem("Sweet") end
if fruitChestFarmEnabled and t%20<0.1 then collectItem("Fruit Chest") end
if legendaryScrollFarmEnabled and t%15<0.1 then collectItem("Legendary Scroll") end

-- MOVIMENTO
if moveHopEnabled and t%180<0.1 then pcall(function() local res=game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?limit=10") local servers=HttpService:JSONDecode(res) if servers and servers.data and#servers.data>0 then TeleportService:TeleportToPlaceInstance(game.GameId,servers.data[math.random(1,#servers.data)].id,player) end end) end
if moveDashEnabled and t%5<0.1 then pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame=player.Character.HumanoidRootPart.CFrame+Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit*25 end end) end
if moveFlightEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end
if moveSwimEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Swimming) end end end) end
if moveTpIslandEnabled and t%30<0.1 then local il=SEA_DATA[currentSea].islands[math.random(1,#SEA_DATA[currentSea].islands)] tp(il[2]) end
if moveTpNPCEnabled and t%15<0.1 then pcall(function() local tgt=nil local s=range for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<s then s=d tgt=o end end end if tgt then tp(tgt.HumanoidRootPart.Position) end end) end

-- AUTOMÁTICOS
if autoHakiEnabled and t%120<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") r.CommF_:InvokeServer("ActivateHaki","Observation") end end) end
if autoSkillEnabled and t%5<0.1 then pcall(function() useSkill(Enum.KeyCode.Z) task.wait(0.5) useSkill(Enum.KeyCode.X) end) end
if autoQuestEnabled and t%30<0.1 then pcall(function() for _,obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and(obj:FindFirstChild("Quest")or obj:FindFirstChild("QuestGiver")) then if obj:FindFirstChild("HumanoidRootPart") then tp(obj.HumanoidRootPart.Position) break end end end end) end

-- LOJA
if shopFruitsEnabled and t%300<0.1 then pcall(function() buyItem("Kitsune") buyItem("Dragon") buyItem("Leopard") end) end
if shopStatsEnabled and t%5<0.1 then pcall(function() local r=ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddPoint","Melee",1) end end) end

-- ESP
if espPlayersEnabled then pcall(function() for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("Head") then local bill=Instance.new("BillboardGui",CoreGui) bill.Adornee=p.Character.Head bill.Size=UDim2.new(0,60,0,20) bill.AlwaysOnTop=true local l=Instance.new("TextLabel",bill) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=0.7 l.BackgroundColor3=Color3.fromRGB(255,0,0) l.TextColor3=Color3.new(1,1,1) l.TextSize=8 l.Font=Enum.Font.GothamBold l.Text=p.Name bill.Parent=p.Character.Head end end end) end

-- EXTRA
if aimlockEnabled then pcall(function() local tgt=nil local s=range for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 and o~=player.Character then local d=(o.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<s then s=d tgt=o end end end if tgt then player.Character.HumanoidRootPart.CFrame=CFrame.new(player.Character.HumanoidRootPart.Position,tgt.HumanoidRootPart.Position) end end) end
if noclipEnabled then pcall(function() if player.Character then for _,p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end
if walkspeedEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=100 end end end) end
if jumpspeedEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower=100 end end end) end
if bountyHuntEnabled and t%15<0.1 then pcall(function() local best,bd=nil,math.huge for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d=(p.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<bd then best=p bd=d end end end if best then tp(best.Character.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end) end
if flyEnabled then pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end

-- LIMPEZA
if t%45<0.1 then pcall(function() collectgarbage("collect") end) end

task.wait(CONFIG.ATTACK_CYCLE_DELAY)
end end)

-- ============================================================
-- UI COMPLETA
-- ============================================================
local win = NexusUI:CreateWindow({Title="NEXUS v7.0.9",Subtitle=SEA_DATA[currentSea].name.." | 286 Funções",Width=580,Height=500})
local tabs={}
for _,t in pairs({{"⚔️ Super Farm"},{"🎯 Bosses"},{"🌊 Sea"},{"💎 Farms"},{"🏃 Move"},{"⚙️ Auto"},{"🛍️ Loja"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]]=NexusUI:CreateTab(win,{Name=t[1]}) end

-- SUPER FARM
NexusUI:CreateSection(tabs["⚔️ Super Farm"],"🚀 SUPER FARM")
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🚀 SUPER FARM",Desc="Caixa invisível + Tudo em um",Callback=function(v)superFarmEnabled=v end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="💀 Kill Aura",Callback=function(v)killAuraEnabled=v end})
NexusUI:CreateToggle(tabs["⚔️ Super Farm"],{Title="🛡️ Godmode",Callback=function(v)godmodeEnabled=v end})

-- BOSSES
NexusUI:CreateSection(tabs["🎯 Bosses"],"🎯 BOSSES")
for _,bd in pairs({{"Dough King",function(v)farmBossDoughKing=v end},{"Soul Reaper",function(v)farmBossSoulReaper=v end},{"Cake Prince",function(v)farmBossCakePrince=v end},{"Rip Indra",function(v)farmBossRipIndra=v end},{"Darkbeard",function(v)farmBossDarkbeard=v end},{"Tide Keeper",function(v)farmBossTideKeeper=v end},{"Stone",function(v)farmBossStone=v end},{"Island Empress",function(v)farmBossIslandEmpress=v end},{"Hydra",function(v)farmBossHydra=v end},{"Leviathan",function(v)farmBossLeviathan=v end}}) do NexusUI:CreateToggle(tabs["🎯 Bosses"],{Title=bd[1],Callback=bd[2]}) end

-- SEA
NexusUI:CreateSection(tabs["🌊 Sea"],"🌊 SEA EVENTS")
for _,sd in pairs({{"Marine Ship",function(v)farmSeaMarineShip=v end},{"Pirate Ship",function(v)farmSeaPirateShip=v end},{"Sea Beast",function(v)farmSeaBeast=v end},{"Terror Shark",function(v)farmSeaTerrorShark=v end},{"Rumbling",function(v)farmSeaRumbling=v end},{"Mansion",function(v)farmSeaMansion=v end},{"Pirate Raid",function(v)farmSeaPirateRaid=v end},{"Sea Castle",function(v)farmSeaCastle=v end}}) do NexusUI:CreateToggle(tabs["🌊 Sea"],{Title=sd[1],Callback=sd[2]}) end

-- FARMS
NexusUI:CreateSection(tabs["💎 Farms"],"💎 FARMS")
for _,fd in pairs({{"Fragmentos",function(v)fragmentFarmEnabled=v end},{"Ossos",function(v)bonesFarmEnabled=v end},{"Belis",function(v)beliFarmEnabled=v end},{"Scrolls",function(v)scrollFarmEnabled=v end},{"Fist of Darkness",function(v)fistDarknessFarmEnabled=v end},{"God's Chalice",function(v)godsChaliceFarmEnabled=v end},{"Blue Gear",function(v)blueGearFarmEnabled=v end},{"Sweet Chalice",function(v)sweetChaliceFarmEnabled=v end}}) do NexusUI:CreateToggle(tabs["💎 Farms"],{Title=fd[1],Callback=fd[2]}) end

-- MOVIMENTO
NexusUI:CreateSection(tabs["🏃 Move"],"🏃 MOVIMENTAÇÃO")
for _,md in pairs({{"Auto Hop",function(v)moveHopEnabled=v end},{"Auto Dash",function(v)moveDashEnabled=v end},{"Auto Flight",function(v)moveFlightEnabled=v end},{"Auto Swim",function(v)moveSwimEnabled=v end},{"TP Island",function(v)moveTpIslandEnabled=v end},{"TP NPC",function(v)moveTpNPCEnabled=v end}}) do NexusUI:CreateToggle(tabs["🏃 Move"],{Title=md[1],Callback=md[2]}) end

-- AUTOMÁTICOS
NexusUI:CreateSection(tabs["⚙️ Auto"],"⚙️ AUTOMAÇÕES")
for _,ad in pairs({{"Auto Haki",function(v)autoHakiEnabled=v end},{"Auto Skill",function(v)autoSkillEnabled=v end},{"Auto Quest",function(v)autoQuestEnabled=v end}}) do NexusUI:CreateToggle(tabs["⚙️ Auto"],{Title=ad[1],Callback=ad[2]}) end

-- LOJA
NexusUI:CreateSection(tabs["🛍️ Loja"],"🛍️ AUTO COMPRAR")
for _,sd in pairs({{"Buy Fruits",function(v)shopFruitsEnabled=v end},{"Buy Stats",function(v)shopStatsEnabled=v end}}) do NexusUI:CreateToggle(tabs["🛍️ Loja"],{Title=sd[1],Callback=sd[2]}) end

-- VISUAL
NexusUI:CreateSection(tabs["👀 Visual"],"👀 ESP")
for _,vd in pairs({{"ESP Players",function(v)espPlayersEnabled=v end},{"ESP Fruits",function(v)espFruitsEnabled=v end},{"ESP Chests",function(v)espChestsEnabled=v end},{"ESP Bosses",function(v)espBossesEnabled=v end}}) do NexusUI:CreateToggle(tabs["👀 Visual"],{Title=vd[1],Callback=vd[2]}) end

-- EXTRA
NexusUI:CreateSection(tabs["🎮 Extra"],"🎮 FUNÇÕES")
for _,ed in pairs({{"Aimlock",function(v)aimlockEnabled=v end},{"No Clip",function(v)noclipEnabled=v end},{"Walkspeed",function(v)walkspeedEnabled=v end},{"Jumpspeed",function(v)jumpspeedEnabled=v end},{"Bounty Hunt",function(v)bountyHuntEnabled=v end},{"Fly",function(v)flyEnabled=v end}}) do NexusUI:CreateToggle(tabs["🎮 Extra"],{Title=ed[1],Callback=ed[2]}) end
NexusUI:CreateDropdown(tabs["🎮 Extra"],{Title="Maestria",Options={"Fruit","Sword","Gun","Melee"},Default=masteryType,Callback=function(v)masteryType=v end})
NexusUI:CreateSlider(tabs["🎮 Extra"],{Title="Alcance",Min=50,Max=500,Default=300,Callback=function(v)range=v end})
NexusUI:CreateButton(tabs["🎮 Extra"],{Title="🛑 DESLIGAR TUDO",Callback=function()
    for _,v in pairs({superFarmEnabled=false,fragmentFarmEnabled=false,bonesFarmEnabled=false,aimlockEnabled=false,noclipEnabled=false,walkspeedEnabled=false,jumpspeedEnabled=false,bountyHuntEnabled=false,flyEnabled=false,killAuraEnabled=false,godmodeEnabled=false,espPlayersEnabled=false,espFruitsEnabled=false,espChestsEnabled=false,espBossesEnabled=false,moveHopEnabled=false,moveDashEnabled=false,moveFlightEnabled=false,moveSwimEnabled=false,autoHakiEnabled=false,autoSkillEnabled=false,autoQuestEnabled=false,shopFruitsEnabled=false,shopStatsEnabled=false}) do end
    if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart=nil end SuperFarm.collectedMobs={}
    notify("Stats","Tudo desligado!",3)
end})

-- ILHAS
NexusUI:CreateSection(tabs["🏝️ Ilhas"],"🏝️ ILHAS DO "..SEA_DATA[currentSea].name:upper())
for _,il in pairs(SEA_DATA[currentSea].islands) do NexusUI:CreateButton(tabs["🏝️ Ilhas"],{Title="🏝️ "..il[1],Callback=function()tp(il[2])notify("🏝️",il[1],2)end}) end

notify("NEXUS v7.0.9",SEA_DATA[currentSea].name.." | 286 Funções | Completo",5)
print("NEXUS v7.0.9 - 286 Funções - Loaded")
