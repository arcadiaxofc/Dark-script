-- ============================================================
-- NEXUS v7.0.9 PRO - COMPLETO COM TODOS OS NPCs REAIS
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
-- LISTA COMPLETA DE NPCs DE QUEST (TODOS OS MARES)
-- ============================================================
local QUEST_NPCS = {
    [1] = {
        "Bandit Quest Giver","Trainee Quest Giver","Desert Adventurer","Marine Leader",
        "Sky Adventurer","Head Jailer","Jail Keeper","Colosseum Quest Giver",
        "Submerged Quest Giver 1","Submerged Quest Giver 2","Sky Quest Giver 2",
        "Dark Step Teacher","Ability Teacher","Colors Specialist","Water Kung Fu Teacher",
        "Instinct Teacher","Aura Editor","Sick Man","Blox Fruit Dealer","Sword Dealer",
        "Boat Dealer","Sword Dealer of the West","Sword Dealer of the East",
        "Weapon Dealer","Advanced Weapon Dealer","Master Sword Dealer","Rich Man",
        "Hasan","Living Skeleton","Parlus","Yoshi","Mad Scientist","Robotmega",
        "Experienced Captain","Angler","Blacksmith","Remove Blox Fruit","Cousin",
        "Blox Fruit Gacha","Dog House","Teach","Bobby","Avalanche",
    },
    [2] = {
        "Colosseum Quest Giver","Deep Forest Quest Giver","Graveyard Quest Giver",
        "Snow Quest Giver","Fire Quest Giver","Ice Quest Giver","Forgotten Quest Giver",
        "Tort","Barista","Bounty Expert","Honor Expert","Bartilo","Awakenings Expert",
        "Titles Specialist","Nerd","Plokster","Mysterious Man","Mr. Captain","Angler",
        "Alchemist","Crew Captain","Martial Arts Master","Arlthmetic","Mysterious Scientist",
        "El Rodolfo","El Admin","El Perro","Experimic","Guashiem","Phoeyu The Reformed",
        "Daigrock The Sharkman","The Strongest God","Cyborg","Sabi","Mysterious Entity",
        "Aura Editor","Blacksmith","Sea Captain","Trevor","Arowe","King Red Head",
        "Don Swan","Jeremy","Diamond","Captain Elephant","Stone","Venus","Buddha","Mace",
    },
    [3] = {
        "Pirate Port Quest Giver","Hydra Town Quest Giver","Dragon Crew Quest Giver",
        "Marine Tree Quest Giver","Turtle Adventure Quest Giver","Haunted Castle Quest Giver 1",
        "Haunted Castle Quest Giver 2","Cake Quest Giver","Chocolate Quest Giver",
        "Ice Cream Quest Giver","Peanut Quest Giver","Candy Cane Quest Giver",
        "Tiki Quest Giver 1","Tiki Quest Giver 2","Tiki Quest Giver 3","Frost Quest Giver",
        "Elite Hunter","Player Hunter","Blox Fruit Dealer","Experienced Captain","Blacksmith",
        "Fisherman","Arena Trainer","Angler","Dojo Trainer","Dragon Wizard","Dragon Hunter",
        "Uzoth","Crew Captain","Mysterious Force","Crypt Master","Ancient Monk",
        "Previous Hero","Mysterious Entity","Citizen","Hungry Man","Horned Man",
        "Ghost","Gravestone","Death King","Weird Machine","Sick Scientist","Cake Scientist",
        "drip_mama","Sweet Crafter","Mysterious Scientist","Aura Editor","Phoeyu The Reformed",
        "Water Kung Fu Teacher","Dark Step Teacher","Daigrock The Sharkman","Martial Arts Master",
        "Sabi","Lunoven","Plokster","Butler","Tacomura","Mad Scientist","Beast Hunter",
        "Shark Hunter","Dragon Talon Sage","Shipwright Teacher","Submarine Worker","Shafi",
        "Spy","Advanced Fruit Dealer","Kitsune Shrine","Ancient Relic","Frozen Watcher",
        "Remove Blox Fruit","Barista","Rip_indra","Soul Reaper","Dragon","Cake Prince",
        "Frost Sorcerer","Kitsune","Dough King","Sea Beast",
    },
}

-- ============================================================
-- PAINEL DE STATUS
-- ============================================================
local StatusPanel = {logs = {}, maxLogs = 20}
function StatusPanel.create()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "NexusStatusPanel" gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 280, 0, 200) frame.Position = UDim2.new(1, -290, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 22) frame.BackgroundTransparency = 0.3 frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 25) title.BackgroundColor3 = Color3.fromRGB(200, 50, 40)
    title.Text = "📊 NEXUS STATUS" title.TextColor3 = Color3.new(1, 1, 1) title.TextSize = 12 title.Font = Enum.Font.GothamBold
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 1, -25) scroll.Position = UDim2.new(0, 0, 0, 25) scroll.BackgroundTransparency = 1 scroll.ScrollBarThickness = 3 scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", scroll) layout.Padding = UDim.new(0, 2)
    local logLabel = Instance.new("TextLabel", scroll)
    logLabel.Size = UDim2.new(1, -10, 0, 18) logLabel.Position = UDim2.new(0, 5, 0, 0) logLabel.BackgroundTransparency = 1
    logLabel.Text = "🟢 Aguardando...\n" logLabel.TextColor3 = Color3.fromRGB(0, 255, 100) logLabel.TextSize = 9 logLabel.Font = Enum.Font.Gotham logLabel.TextXAlignment = Enum.TextXAlignment.Left logLabel.TextWrapped = true logLabel.RichText = true
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5) end)
    StatusPanel.gui = gui StatusPanel.frame = frame StatusPanel.logLabel = logLabel
    local dragging, dragStart, startPos = false, nil, nil
    title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = frame.Position end end)
    title.InputEnded:Connect(function() dragging = false end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
function StatusPanel.log(msg, color)
    table.insert(StatusPanel.logs, {msg = msg, color = color or Color3.fromRGB(255,255,255), time = os.date("%H:%M:%S")})
    if #StatusPanel.logs > StatusPanel.maxLogs then table.remove(StatusPanel.logs, 1) end
    if StatusPanel.logLabel then
        local text = ""
        for i = #StatusPanel.logs, math.max(1, #StatusPanel.logs - 15), -1 do
            local log = StatusPanel.logs[i]
            text = text .. '<font color="rgb('..math.floor(log.color.R*255)..','..math.floor(log.color.G*255)..','..math.floor(log.color.B*255)..')">['..log.time..'] '..log.msg..'</font>\n'
        end
        StatusPanel.logLabel.Text = text
    end
end
function StatusPanel.success(msg) StatusPanel.log("✅ "..msg, Color3.fromRGB(0,255,100)) end
function StatusPanel.error(msg) StatusPanel.log("❌ "..msg, Color3.fromRGB(255,50,50)) end
function StatusPanel.warn(msg) StatusPanel.log("⚠️ "..msg, Color3.fromRGB(255,180,0)) end
function StatusPanel.info(msg) StatusPanel.log("ℹ️ "..msg, Color3.fromRGB(100,180,255)) end
StatusPanel.create()

-- ============================================================
-- ANTI-AFK
-- ============================================================
task.spawn(function() while true do task.wait(180) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(1,0,0),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero,true) end end) end end)

-- ============================================================
-- DADOS DOS SEAS
-- ============================================================
local SEA_DATA = {
    [1] = {name="First Sea", islands={{"Pirate Starter",Vector3.new(1289,11,4191)},{"Jungle",Vector3.new(-1250,15,3850)},{"Desert",Vector3.new(966,10,1100)},{"Frozen Village",Vector3.new(1150,25,4350)},{"Marine Fortress",Vector3.new(-1500,10,5300)},{"Skylands",Vector3.new(-4850,750,1950)},{"Prison",Vector3.new(-5400,15,-1700)},{"Colosseum",Vector3.new(-3560,240,-80)},{"Magma Village",Vector3.new(-3420,10,-2700)},{"Underwater City",Vector3.new(5500,-50,2000)},{"Fountain City",Vector3.new(4500,50,1200)}}, bosses={"Gorilla King","Yeti","Vice Admiral","Saber Expert","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"}, fruits={"Flame-Fruit","Ice-Fruit","Dark-Fruit","Light-Fruit","Magma-Fruit","Rumble-Fruit","Sand-Fruit","Barrier-Fruit"}},
    [2] = {name="Second Sea", islands={{"Kingdom of Rose",Vector3.new(-1400,10,-1400)},{"Green Zone",Vector3.new(6200,80,2500)},{"Hot and Cold",Vector3.new(-3420,10,-2700)},{"Ice Castle",Vector3.new(7200,100,3500)},{"Forgotten Island",Vector3.new(8500,120,4500)},{"Cafe",Vector3.new(-570,310,-1220)},{"Mansion",Vector3.new(-390,45,-800)}}, bosses={"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"}, fruits={"Buddha-Fruit","Portal-Fruit","Blizzard-Fruit","Phoenix-Fruit","Spider-Fruit","Sound-Fruit","Pain-Fruit"}},
    [3] = {name="Third Sea", islands={{"Port Town",Vector3.new(7200,100,3500)},{"Hydra Island",Vector3.new(6200,80,2500)},{"Great Tree",Vector3.new(8500,120,4500)},{"Castle on the Sea",Vector3.new(4500,50,1200)},{"Haunted Castle",Vector3.new(9800,60,5500)},{"Dark Arena",Vector3.new(10500,100,6000)},{"Floating Turtle",Vector3.new(11200,90,6500)},{"Prehistoric Island",Vector3.new(12500,80,7000)},{"Desert Kingdom",Vector3.new(13800,100,7500)}}, bosses={"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan","Beautiful Pirate","Elite Pirates","Pharaoh Akshan","Fossil Expert"}, fruits={"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit","Control-Fruit","Shadow-Fruit","T-Rex-Fruit"}},
}

local currentSea = 1
local function detectSea() local lvl=1 pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl=player.Data.Level.Value end end) if lvl<=700 then currentSea=1 elseif lvl<=1500 then currentSea=2 else currentSea=3 end end
detectSea()
StatusPanel.info("Sea: "..SEA_DATA[currentSea].name.." | "..#QUEST_NPCS[currentSea].." NPCs cadastrados")

-- ============================================================
-- VARIÁVEIS
-- ============================================================
local range = 300
local kills = 0
local masteryType = "Fruit"
local espBills = {}
local threads = {}

local function stopThread(name) if threads[name] then threads[name].enabled = false task.cancel(threads[name].thread) threads[name] = nil end end
local function startThread(name, loopFunc, delay) stopThread(name) local data = {enabled = true} data.thread = task.spawn(function() while data.enabled do pcall(loopFunc) task.wait(delay or 0.1) end end) threads[name] = data end

-- ============================================================
-- TELEPORTE
-- ============================================================
local function tp(pos) pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local hrp=player.Character.HumanoidRootPart hrp.CFrame=CFrame.new(pos+Vector3.new(0,25,0)) task.wait(0.1) hrp.CFrame=CFrame.new(pos+Vector3.new(0,5,0)) task.wait(0.05) hrp.CFrame=CFrame.new(pos) end end) end

-- ============================================================
-- ATAQUE
-- ============================================================
local function attack() pcall(function() VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(0.05) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) kills=kills+1 end) end

local function findBoss(name) local b=Workspace:FindFirstChild(name) if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health>0 then return b end for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o.Name:find(name) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health>0 then return o end end return nil end

-- ============================================================
-- VERIFICAÇÃO DE NPC DE QUEST
-- ============================================================
local function isQuestNPC(obj)
    for _, name in pairs(QUEST_NPCS[currentSea]) do if obj.Name == name then return true end end
    if obj:FindFirstChild("Talk") then return true end
    if obj.Name:find("Quest") or obj.Name:find("Giver") or obj.Name:find("Master") then return true end
    local head = obj:FindFirstChild("Head")
    if head then for _, child in pairs(head:GetChildren()) do if child:IsA("BillboardGui") then for _, element in pairs(child:GetDescendants()) do if element:IsA("TextLabel") and (element.Text:find("Quest") or element.Text:find("!")) then return true end end end end end
    return false
end

-- ============================================================
-- SUPER FARM COM NPCs REAIS
-- ============================================================
local SuperFarm = {boxPart=nil, collectedMobs={}, phase="quest", mobsKilled=0, mobsNeeded=10, lastQuestTime=0, debugCount=0}

function startSuperFarm()
    StatusPanel.success("Super Farm INICIADO")
    startThread("superFarm", function()
        SuperFarm.debugCount = SuperFarm.debugCount + 1
        if SuperFarm.debugCount % 20 == 0 then StatusPanel.info("Ciclo #"..SuperFarm.debugCount.." | Fase: "..SuperFarm.phase.." | Mobs: "..SuperFarm.mobsKilled) end
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
        
        -- FASE QUEST (com NPCs reais)
        if SuperFarm.phase == "quest" and tick() - SuperFarm.lastQuestTime > 45 then
            local nearest, shortest = nil, 500
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    if isQuestNPC(obj) then
                        local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist < shortest then shortest = dist nearest = obj end
                    end
                end
            end
            if nearest then
                StatusPanel.success("NPC: "..nearest.Name)
                tp(nearest.HumanoidRootPart.Position + Vector3.new(3, 0, 0))
                task.wait(1)
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StartQuest", nearest.Name) end
                SuperFarm.lastQuestTime = tick() SuperFarm.mobsKilled = 0 SuperFarm.phase = "collect"
                StatusPanel.success("Quest: "..nearest.Name)
            else
                StatusPanel.warn("Nenhum NPC encontrado (procurando entre "..#QUEST_NPCS[currentSea].." nomes)")
            end
        end
        
        -- FASE COLLECT
        if SuperFarm.phase == "collect" then
            local count = 0
            local boxPos = SuperFarm.boxPart.Position
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= player.Character then
                    local mHrp = obj:FindFirstChild("HumanoidRootPart")
                    local mHum = obj:FindFirstChild("Humanoid")
                    if mHrp and mHum and mHum.Health > 0 and not isQuestNPC(obj) then
                        if (mHrp.Position - hrp.Position).Magnitude <= range and not SuperFarm.collectedMobs[obj] then
                            mHrp.CFrame = CFrame.new(boxPos + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
                            SuperFarm.collectedMobs[obj] = true count = count + 1
                            if count >= 8 then break end
                        end
                    end
                end
            end
            if count > 0 then SuperFarm.phase = "attack" StatusPanel.info("Puxou "..count.." mobs") end
        end
        
        -- FASE ATTACK
        if SuperFarm.phase == "attack" then
            local alive = 0
            for obj, _ in pairs(SuperFarm.collectedMobs) do
                if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then attack() alive = alive + 1
                else SuperFarm.collectedMobs[obj] = nil SuperFarm.mobsKilled = SuperFarm.mobsKilled + 1 end
            end
            if alive <= 2 then SuperFarm.phase = "collect" end
            if SuperFarm.mobsKilled >= SuperFarm.mobsNeeded then
                SuperFarm.phase = "quest" SuperFarm.mobsKilled = 0 SuperFarm.collectedMobs = {}
                StatusPanel.success("Ciclo completo! "..SuperFarm.mobsNeeded.." mortos")
            end
        end
    end, 0.15)
end

function stopSuperFarm()
    stopThread("superFarm")
    if SuperFarm.boxPart then SuperFarm.boxPart:Destroy() SuperFarm.boxPart = nil end
    SuperFarm.collectedMobs = {} SuperFarm.phase = "quest" SuperFarm.mobsKilled = 0
    StatusPanel.warn("Super Farm PARADO")
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

function startBountyHunt() startThread("bounty", function() if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end local best,bd=nil,math.huge for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d=(p.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude if d<bd then best=p bd=d end end end if best then tp(best.Character.HumanoidRootPart.Position) for _=1,5 do attack() task.wait(0.3) end end end, 10) end
function stopBountyHunt() stopThread("bounty") end

-- ============================================================
-- BOSS FARM
-- ============================================================
function startBossFarm(name) startThread("boss_"..name:gsub(" ","_"), function() local b=findBoss(name) if b then tp(b.HumanoidRootPart.Position) for _=1,8 do attack() task.wait(0.3) end end end, 5) end
function stopBossFarm(name) stopThread("boss_"..name:gsub(" ","_")) end

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
                            bill.Adornee = o.Head bill.Size = UDim2.new(0, 60, 0, 18) bill.AlwaysOnTop = true bill.MaxDistance = range
                            local label = Instance.new("TextLabel", bill) label.Size = UDim2.new(1, 0, 1, 0) label.BackgroundTransparency = 0.7 label.BackgroundColor3 = color label.TextColor3 = Color3.new(1, 1, 1) label.TextSize = 8 label.Font = Enum.Font.GothamBold label.Text = o.Name
                            espBills[o] = bill count = count + 1
                        end
                    end
                end
                for o, b in pairs(espBills) do if type(o) ~= "string" then pcall(function() if not o.Parent or (o:FindFirstChild("Humanoid") and o.Humanoid.Health <= 0) then b:Destroy() espBills[o] = nil end end) end end
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
    StatusPanel.error("TUDO DESLIGADO!") notify("NEXUS", "Tudo desligado!", 3)
end

-- ============================================================
-- UI
-- ============================================================
local win = NexusUI:CreateWindow({Title="NEXUS v7.0.9 PRO", Subtitle=SEA_DATA[currentSea].name.." | "..#QUEST_NPCS[currentSea].." NPCs", Width=580, Height=500})
local tabs={}
for _,t in pairs({{"⚔️ Farm"},{"🎯 Bosses"},{"💎 Farms"},{"🏃 Move"},{"⚙️ Auto"},{"👀 Visual"},{"🎮 Extra"},{"🏝️ Ilhas"}}) do tabs[t[1]]=NexusUI:CreateTab(win,{Name=t[1]}) end

NexusUI:CreateSection(tabs["⚔️ Farm"],"SUPER FARM")
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="🚀 Super Farm",Callback=function(v) if v then startSuperFarm() else stopSuperFarm() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="💀 Kill Aura",Callback=function(v) if v then startKillAura() else stopKillAura() end end})
NexusUI:CreateToggle(tabs["⚔️ Farm"],{Title="🛡️ Godmode",Callback=function(v) if v then startGodmode() else stopGodmode() end end})

NexusUI:CreateSection(tabs["🎯 Bosses"],"BOSSES DO "..SEA_DATA[currentSea].name:upper())
for _, name in pairs(SEA_DATA[currentSea].bosses) do
    NexusUI:CreateToggle(tabs["🎯 Bosses"],{Title="🎯 "..name,Callback=function(v) if v then startBossFarm(name) else stopBossFarm(name) end end})
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

NexusUI:CreateSection(tabs["🏝️ Ilhas"],"ILHAS DO "..SEA_DATA[currentSea].name:upper().." ("..#SEA_DATA[currentSea].islands.." ilhas)")
for _,il in pairs(SEA_DATA[currentSea].islands) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"],{Title="🏝️ "..il[1],Callback=function()tp(il[2])StatusPanel.info("TP: "..il[1])notify("🏝️",il[1],2)end})
end

StatusPanel.success("Tudo carregado! "..#QUEST_NPCS[currentSea].." NPCs cadastrados")
notify("NEXUS v7.0.9 PRO","NPCs reais | Painel de Status | "..SEA_DATA[currentSea].name,8)
print("NEXUS v7.0.9 PRO - NPCs Reais - Loaded")
