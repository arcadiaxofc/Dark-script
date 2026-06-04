-- ============================================================
-- NEXUS v7.0.9 - PARVUS STYLE - BLOX FRUITS - CORRIGIDO
-- ============================================================

-- 1. INICIALIZAÇÃO (SERVIÇOS)
local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    TeleportService = game:GetService("TeleportService"),
    HttpService = game:GetService("HttpService"),
    Lighting = game:GetService("Lighting"),
    RunService = game:GetService("RunService"),
    StarterGui = game:GetService("StarterGui"),
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    CollectionService = game:GetService("CollectionService"),
}
local player = Services.Players.LocalPlayer
local camera = Services.Workspace.CurrentCamera

local function notify(t, txt, d) pcall(function() Services.StarterGui:SetCore("SendNotification", {Title = t or "NEXUS", Text = txt or "", Duration = d or 3}) end) end
pcall(function() settings().Rendering.QualityLevel = 1 Services.Lighting.GlobalShadows = false Services.Lighting.Brightness = 2 end)

-- 2. ANTI-DETECÇÃO
pcall(function()
    local old = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" and type(args[1]) == "string" then
            local blocked = {"Kick","Ban","Teleport","Flag","Report","Detect","AntiCheat","Log","Alert","NotifyAdmin","SendLog","Spectate","Moderator","Admin","Check","Verify","Validate","Scan","Execute","Inject","Exploit","Cheat","Hack","Script","Client","Debug","Monitor","Watch","Trace","Track","Violation","Byfron","Hyperion"}
            for _, b in pairs(blocked) do if args[1]:lower():find(b:lower()) then return nil end end
        end
        if method == "Kick" or method == "Ban" then return nil end
        return old(self, ...)
    end)
end)
task.spawn(function() while true do task.wait(180) pcall(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:Move(Vector3.new(1,0,0),true) task.wait(0.3) player.Character.Humanoid:Move(Vector3.zero,true) end end) end end)

-- 3. DRAWING LIBRARY (ESP)
local drawings = {}
local function newDrawing(type, props) local d = Drawing.new(type) for k,v in pairs(props or {}) do pcall(function() d[k] = v end) end table.insert(drawings, d) return d end
local function clearDrawings() for _, d in pairs(drawings) do pcall(function() d:Remove() end) end drawings = {} end

-- 4. DETECÇÃO DE SEA
local currentSea = 1
local function detectSea()
    local lvl = 1
    pcall(function() if player.Data and player.Data:FindFirstChild("Level") then lvl = player.Data.Level.Value end end)
    if lvl <= 700 then currentSea = 1 elseif lvl <= 1500 then currentSea = 2 else currentSea = 3 end
    return currentSea
end
detectSea()

-- 5. LISTA DE NPCs DE QUEST POR SEA (NOMES REAIS)
local QUEST_NPCS = {
    [1] = {
        "Bandit Quest Giver 1", "Bandit Quest Giver", "Soldier Quest Giver", "Marine Quest Giver",
        "Desert Quest Giver", "Snow Quest Giver", "Sky Quest Giver", "Prison Quest Giver",
        "Colosseum Quest Giver", "Magma Quest Giver", "Underwater Quest Giver",
    },
    [2] = {
        "Diamond Quest Giver", "Jeremy Quest Giver", "Fudra Quest Giver", "Snow Mountain Quest Giver",
        "Forest Quest Giver", "Graveyard Quest Giver",
    },
    [3] = {
        "Port Town Quest Giver", "Hydra Quest Giver", "Dragon Quest Giver", "Castle Quest Giver",
        "Haunted Castle Quest Giver 1", "Haunted Castle Quest Giver 2", "Tiki Quest Giver",
    },
}

local function isQuestNPC(obj)
    for _, name in pairs(QUEST_NPCS[currentSea]) do
        if obj.Name == name or obj.Name:find(name) or name:find(obj.Name) then return true end
    end
    if obj:FindFirstChild("Talk") then return true end
    if obj.Name:find("Quest") or obj.Name:find("Giver") then return true end
    return false
end

local function isEnemy(obj)
    if not obj or obj == player.Character then return false end
    if isQuestNPC(obj) then return false end
    local hum = obj:FindFirstChild("Humanoid")
    if hum and hum.Health > 0 then return true end
    return false
end

-- 6. SISTEMA DE TARGET
local function getBestTarget(range)
    local best, bestScore = nil, -1
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local hum = obj:FindFirstChild("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= range then
                    local score = (1/(dist+1))*1000 + (1-hum.Health/hum.MaxHealth)*500
                    local tp = Services.Players:GetPlayerFromCharacter(obj)
                    if tp then
                        local bounty = tp.Data and tp.Data:FindFirstChild("Bounty") and tp.Data.Bounty.Value or 0
                        score = score + bounty/1000
                    end
                    if hum.MaxHealth > 10000 then score = score + 2000 end
                    if score > bestScore then bestScore = score best = obj end
                end
            end
        end
    end
    return best
end

-- 7. SISTEMA DE ESP
local ESP = {Enabled=false, Players=true, Fruits=true, Chests=true, Bosses=true, SeaBeasts=true}
function ESP.update()
    if not ESP.Enabled then clearDrawings() return end
    clearDrawings()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local head = obj:FindFirstChild("Head")
            local hum = obj:FindFirstChild("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if head and hrp then
                local pos, visible = camera:WorldToViewportPoint(hrp.Position)
                if visible and pos.Z > 0 then
                    local shouldDraw, color, name = false, Color3.fromRGB(255,255,255), obj.Name
                    if ESP.Players and Services.Players:GetPlayerFromCharacter(obj) then
                        shouldDraw = true color = Color3.fromRGB(255,50,50)
                        local p = Services.Players:GetPlayerFromCharacter(obj)
                        name = p.Name.." ["..math.floor((hrp.Position-player.Character.HumanoidRootPart.Position).Magnitude).."m]"
                        if hum then name = name.." ❤"..math.floor(hum.Health) end
                    elseif ESP.Fruits and obj.Name:find("Fruit") then
                        shouldDraw = true color = Color3.fromRGB(255,0,255)
                    elseif ESP.Chests and obj.Name:lower():find("chest") then
                        shouldDraw = true color = Color3.fromRGB(255,215,0) name = "📦 "..obj.Name
                    elseif ESP.Bosses and hum and hum.MaxHealth > 10000 then
                        shouldDraw = true color = Color3.fromRGB(255,50,50) name = "👑 "..obj.Name.." ❤"..math.floor(hum.Health)
                    elseif ESP.SeaBeasts and obj.Name:lower():find("sea") and hum then
                        shouldDraw = true color = Color3.fromRGB(0,100,255) name = "🌊 "..obj.Name.." ❤"..math.floor(hum.Health)
                    end
                    if shouldDraw then
                        local dist = (hrp.Position-player.Character.HumanoidRootPart.Position).Magnitude
                        local scale = math.clamp(200/dist, 0.5, 2)
                        local boxSize = Vector2.new(80*scale, 120*scale)
                        newDrawing("Square", {Position=Vector2.new(pos.X-boxSize.X/2, pos.Y-boxSize.Y/2), Size=boxSize, Color=color, Thickness=2, Filled=false, Transparency=0.8})
                        newDrawing("Text", {Position=Vector2.new(pos.X, pos.Y-boxSize.Y/2-20), Text=name, Size=14, Color=color, Center=true, Outline=true})
                        if hum then
                            local hp = hum.Health/hum.MaxHealth
                            newDrawing("Square", {Position=Vector2.new(pos.X-boxSize.X/2, pos.Y+boxSize.Y/2+5), Size=Vector2.new(boxSize.X, 4), Color=Color3.fromRGB(50,50,50), Filled=true})
                            newDrawing("Square", {Position=Vector2.new(pos.X-boxSize.X/2, pos.Y+boxSize.Y/2+5), Size=Vector2.new(boxSize.X*hp, 4), Color=hp>0.5 and Color3.fromRGB(0,255,0) or (hp>0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)), Filled=true})
                        end
                    end
                end
            end
        end
    end
end

-- 8. SISTEMA DE FARM (CORRIGIDO)
local Farm = {
    Enabled = false, Phase = "collect", MobsKilled = 0, MobsNeeded = 10,
    LastQuestTime = 0, BoxPart = nil, CollectedMobs = {},
    AutoQuest = true, AutoCollect = true, AutoBuy = true, GodMode = true,
}

function Farm.createBox()
    if Farm.BoxPart and Farm.BoxPart.Parent then Farm.BoxPart:Destroy() end
    local part = Instance.new("Part", Services.Workspace)
    part.Name = "NexusFarmBox" part.Size = Vector3.new(10, 5, 10)
    part.Anchored = true part.CanCollide = false part.Transparency = 1
    Farm.BoxPart = part
end

function Farm.findQuestNPC()
    local nearest, shortest = nil, 500
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if isQuestNPC(obj) then
                local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortest then shortest = dist nearest = obj end
            end
        end
    end
    return nearest
end

function Farm.collectMobs()
    if not Farm.BoxPart or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    local hrp = player.Character.HumanoidRootPart
    local boxPos = Farm.BoxPart.Position
    local count = 0
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if count >= 10 then break end
        if isEnemy(obj) then
            local mHrp = obj:FindFirstChild("HumanoidRootPart")
            if mHrp and not Farm.CollectedMobs[obj] then
                local dist = (mHrp.Position - hrp.Position).Magnitude
                if dist <= 500 then
                    mHrp.CFrame = CFrame.new(boxPos + Vector3.new(math.random(-4,4), 0, math.random(-4,4)))
                    Farm.CollectedMobs[obj] = true
                    count = count + 1
                end
            end
        end
    end
    return count
end

function Farm.attackMobs()
    if not Farm.BoxPart or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    local hrp = player.Character.HumanoidRootPart
    local alive = 0
    for obj, _ in pairs(Farm.CollectedMobs) do
        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj.Humanoid.Health > 0 then
                local mobHrp = obj.HumanoidRootPart
                if (mobHrp.Position - Farm.BoxPart.Position).Magnitude > 10 then
                    mobHrp.CFrame = CFrame.new(Farm.BoxPart.Position + Vector3.new(math.random(-3,3), 0, math.random(-3,3)))
                end
                hrp.CFrame = CFrame.new(hrp.Position, mobHrp.Position)
                Services.VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                task.wait(0.05)
                Services.VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                alive = alive + 1
            else
                Farm.CollectedMobs[obj] = nil
                Farm.MobsKilled = Farm.MobsKilled + 1
            end
        else
            Farm.CollectedMobs[obj] = nil
            Farm.MobsKilled = Farm.MobsKilled + 1
        end
    end
    return alive
end

function Farm.update()
    if not Farm.Enabled then
        if Farm.BoxPart then Farm.BoxPart:Destroy() Farm.BoxPart = nil end
        Farm.CollectedMobs = {}
        return
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = player.Character.HumanoidRootPart
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    
    if not Farm.BoxPart or not Farm.BoxPart.Parent then Farm.createBox() end
    Farm.BoxPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0))
    
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Freefall)
        if Farm.GodMode then hum.Health = hum.MaxHealth end
    end
    hrp.CFrame = CFrame.new(Farm.BoxPart.Position + Vector3.new(0, 2, 0))
    
    -- FASE: PEGAR QUEST
    if Farm.Phase == "quest" and Farm.AutoQuest and tick() - Farm.LastQuestTime > 45 then
        local npc = Farm.findQuestNPC()
        if npc then
            hrp.CFrame = CFrame.new(npc.HumanoidRootPart.Position + Vector3.new(0, 25, 0))
            task.wait(0.1)
            hrp.CFrame = CFrame.new(npc.HumanoidRootPart.Position + Vector3.new(3, 0, 0))
            task.wait(0.5)
            local r = Services.ReplicatedStorage:FindFirstChild("Remotes")
            if r and r:FindFirstChild("CommF_") then
                r.CommF_:InvokeServer("StartQuest", npc.Name)
            end
            Farm.LastQuestTime = tick()
            Farm.MobsKilled = 0
            Farm.Phase = "collect"
        end
    end
    
    -- FASE: PUXAR MOBS
    if Farm.Phase == "collect" then
        local count = Farm.collectMobs()
        if count > 0 then Farm.Phase = "attack" end
    end
    
    -- FASE: ATACAR
    if Farm.Phase == "attack" then
        local alive = Farm.attackMobs()
        if alive <= 3 then Farm.Phase = "collect" end
        if Farm.MobsKilled >= Farm.MobsNeeded then
            Farm.Phase = "quest"
            Farm.MobsKilled = 0
            Farm.CollectedMobs = {}
        end
    end
    
    -- AUTO COLLECT FRUITS
    if Farm.AutoCollect and tick() % 10 < 0.1 then
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj.Name:find("Fruit") and obj:FindFirstChild("Handle") then
                hrp.CFrame = CFrame.new(obj.Handle.Position + Vector3.new(0, 25, 0))
                task.wait(0.1)
                hrp.CFrame = CFrame.new(obj.Handle.Position)
                break
            end
        end
    end
    
    -- AUTO BUY
    if Farm.AutoBuy and tick() % 300 < 0.1 then
        local r = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then
            r.CommF_:InvokeServer("BuyItem", "Kitsune")
            r.CommF_:InvokeServer("BuyItem", "Dragon")
        end
    end
end

-- 9. SISTEMA DE MODIFICAÇÕES
local Mods = {
    WalkSpeed = {Enabled = false, Value = 100},
    JumpPower = {Enabled = false, Value = 150},
    Fly = {Enabled = false},
    NoClip = {Enabled = false},
    GodMode = {Enabled = false},
    KillAura = {Enabled = false, Range = 300},
    Aimlock = {Enabled = false, Range = 300},
}

function Mods.update()
    if not player.Character then return end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    
    if Mods.WalkSpeed.Enabled and hum then hum.WalkSpeed = Mods.WalkSpeed.Value
    elseif hum and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
    
    if Mods.JumpPower.Enabled and hum then hum.JumpPower = Mods.JumpPower.Value
    elseif hum and hum.JumpPower ~= 50 then hum.JumpPower = 50 end
    
    if Mods.Fly.Enabled and hum then
        hum:ChangeState(Enum.HumanoidStateType.Freefall)
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 10, hrp.Velocity.Z) end
    end
    
    if Mods.NoClip.Enabled then
        for _, p in pairs(player.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    
    if Mods.GodMode.Enabled and hum then hum.Health = hum.MaxHealth end
    
    if Mods.KillAura.Enabled and hrp then
        local target = getBestTarget(Mods.KillAura.Range)
        if target and target:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
            Services.VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.05)
            Services.VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        end
    end
    
    if Mods.Aimlock.Enabled and hrp then
        local target = getBestTarget(Mods.Aimlock.Range)
        if target and target:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
        end
    end
end

-- 10. LOOP PRINCIPAL
task.spawn(function()
    while true do
        pcall(function()
            detectSea()
            Farm.update()
            Mods.update()
            ESP.update()
        end)
        task.wait(0.1)
    end
end)

-- 11. UI
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()
local win = NexusUI:CreateWindow({Title = "NEXUS v7.0.9", Subtitle = "Parvus Style | Blox Fruits | Corrigido", Width = 580, Height = 500})
local tabs = {}
for _, t in pairs({{"⚔️ Combat"}, {"🚀 Farm"}, {"👀 Visuals"}, {"⚙️ Mods"}, {"🏝️ Teleports"}, {"🛑 Config"}}) do
    tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1]})
end

NexusUI:CreateSection(tabs["⚔️ Combat"], "Aimbot & Kill Aura")
NexusUI:CreateToggle(tabs["⚔️ Combat"], {Title = "🎯 Kill Aura", Callback = function(v) Mods.KillAura.Enabled = v end})
NexusUI:CreateToggle(tabs["⚔️ Combat"], {Title = "🎯 Aimlock", Callback = function(v) Mods.Aimlock.Enabled = v end})
NexusUI:CreateSlider(tabs["⚔️ Combat"], {Title = "Range", Min = 50, Max = 500, Default = 300, Callback = function(v) Mods.KillAura.Range = v Mods.Aimlock.Range = v end})

NexusUI:CreateSection(tabs["🚀 Farm"], "Auto Farm (Corrigido)")
NexusUI:CreateToggle(tabs["🚀 Farm"], {Title = "🚀 Super Farm", Callback = function(v) Farm.Enabled = v if v then Farm.Phase = "collect" end end})
NexusUI:CreateToggle(tabs["🚀 Farm"], {Title = "📋 Auto Quest", Callback = function(v) Farm.AutoQuest = v end})
NexusUI:CreateToggle(tabs["🚀 Farm"], {Title = "🍎 Auto Collect Fruits", Callback = function(v) Farm.AutoCollect = v end})
NexusUI:CreateToggle(tabs["🚀 Farm"], {Title = "🛒 Auto Buy", Callback = function(v) Farm.AutoBuy = v end})
NexusUI:CreateToggle(tabs["🚀 Farm"], {Title = "🛡️ GodMode", Callback = function(v) Farm.GodMode = v end})

NexusUI:CreateSection(tabs["👀 Visuals"], "ESP Settings")
NexusUI:CreateToggle(tabs["👀 Visuals"], {Title = "👁️ Enable ESP", Callback = function(v) ESP.Enabled = v end})
NexusUI:CreateToggle(tabs["👀 Visuals"], {Title = "👤 Players", Callback = function(v) ESP.Players = v end})
NexusUI:CreateToggle(tabs["👀 Visuals"], {Title = "🍎 Fruits", Callback = function(v) ESP.Fruits = v end})
NexusUI:CreateToggle(tabs["👀 Visuals"], {Title = "📦 Chests", Callback = function(v) ESP.Chests = v end})
NexusUI:CreateToggle(tabs["👀 Visuals"], {Title = "👑 Bosses", Callback = function(v) ESP.Bosses = v end})
NexusUI:CreateToggle(tabs["👀 Visuals"], {Title = "🌊 Sea Beasts", Callback = function(v) ESP.SeaBeasts = v end})

NexusUI:CreateSection(tabs["⚙️ Mods"], "Character Mods")
NexusUI:CreateToggle(tabs["⚙️ Mods"], {Title = "🏃 WalkSpeed", Callback = function(v) Mods.WalkSpeed.Enabled = v end})
NexusUI:CreateSlider(tabs["⚙️ Mods"], {Title = "WalkSpeed Value", Min = 16, Max = 300, Default = 100, Callback = function(v) Mods.WalkSpeed.Value = v end})
NexusUI:CreateToggle(tabs["⚙️ Mods"], {Title = "🦘 JumpPower", Callback = function(v) Mods.JumpPower.Enabled = v end})
NexusUI:CreateSlider(tabs["⚙️ Mods"], {Title = "JumpPower Value", Min = 50, Max = 500, Default = 150, Callback = function(v) Mods.JumpPower.Value = v end})
NexusUI:CreateToggle(tabs["⚙️ Mods"], {Title = "✈️ Fly", Callback = function(v) Mods.Fly.Enabled = v end})
NexusUI:CreateToggle(tabs["⚙️ Mods"], {Title = "🚫 NoClip", Callback = function(v) Mods.NoClip.Enabled = v end})

NexusUI:CreateSection(tabs["🏝️ Teleports"], "Islands")
for _, island in pairs({
    {"🏴‍☠️ Pirate Starter", Vector3.new(1289, 11, 4191)},
    {"🌴 Jungle", Vector3.new(-1250, 15, 3850)},
    {"🏜️ Desert", Vector3.new(966, 10, 1100)},
    {"❄️ Frozen Village", Vector3.new(1150, 25, 4350)},
    {"🔒 Prison", Vector3.new(-5400, 15, -1700)},
    {"☁️ Skylands", Vector3.new(-4850, 750, 1950)},
    {"🌹 Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
    {"🏯 Ice Castle", Vector3.new(7200, 100, 3500)},
    {"🐉 Hydra Island", Vector3.new(6200, 80, 2500)},
    {"🏰 Castle on the Sea", Vector3.new(4500, 50, 1200)},
}) do
    NexusUI:CreateButton(tabs["🏝️ Teleports"], {Title = island[1], Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(island[2] + Vector3.new(0, 25, 0))
            task.wait(0.1)
            hrp.CFrame = CFrame.new(island[2])
        end
    end})
end

NexusUI:CreateSection(tabs["🛑 Config"], "Settings")
NexusUI:CreateButton(tabs["🛑 Config"], {Title = "🛑 DISABLE ALL", Callback = function()
    for k, v in pairs(Mods) do if type(v) == "table" and v.Enabled ~= nil then v.Enabled = false end end
    Farm.Enabled = false ESP.Enabled = false
    notify("NEXUS", "Tudo desligado!", 3)
end})
NexusUI:CreateButton(tabs["🛑 Config"], {Title = "🚀 ENABLE ALL", Callback = function()
    Farm.Enabled = true Farm.Phase = "collect"
    ESP.Enabled = true
    Mods.GodMode.Enabled = true Mods.KillAura.Enabled = true
    notify("NEXUS", "Tudo ligado!", 3)
end})

print("NEXUS v7.0.9 - Corrigido - Loaded")
