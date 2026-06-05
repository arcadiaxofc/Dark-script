-- ============================================================
-- NEXUS v2.2 FINAL - ANTI-CRASH MOBILE COMPLETO
-- Proteções: Nil, Retry, Carregamento, Validação, Anti-Spam
-- ============================================================

-- 1. CARREGAR UI PRIMEIRO
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

if not NexusUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NEXUS",
        Text = "❌ Falha ao carregar a UI!",
        Duration = 5
    })
    return
end

-- 2. ESPERAR O JOGO CARREGAR (ANTI-BUG MOBILE)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- 3. ESPERAR O PERSONAGEM EXISTIR
repeat task.wait(0.5) until game.Players.LocalPlayer.Character
task.wait(3) -- Delay extra pra assets carregarem no mobile

-- 4. SERVIÇOS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- 5. ANTI-CHEAT BYPASS
pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    
    mt.__index = function(self, key)
        if key == "BusyLock" or key == "Busy" or key == "BusyLocking" then return nil end
        return oldIndex(self, key)
    end
    
    mt.__newindex = function(self, key, value)
        if key == "BusyLock" or key == "Busy" or key == "BusyLocking" then return end
        return oldNewIndex(self, key, value)
    end
end)

-- 6. OTIMIZADOR MOBILE
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    Lighting.FogEnd = 99999
    Lighting.FogStart = 99999
end)

-- 7. NOTIFICAÇÃO (SEM SPAM)
local lastNotify = 0
local function Notify(t, txt, d)
    if tick() - lastNotify < 1 then return end
    lastNotify = tick()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = t or "NEXUS",
            Text = txt or "",
            Duration = d or 3
        })
    end)
end

-- 8. FUNÇÃO COM RETRY (ANTI-FALHA)
local function SafeCall(func, retries)
    retries = retries or 2
    for i = 1, retries do
        local success, result = pcall(func)
        if success then return result end
        task.wait(0.3)
    end
    return nil
end

-- 9. ESPERAR MOB CARREGAR COMPLETO (ANTI-FANTASMA)
local function WaitForMob(model)
    if not model or not model.Parent then return false end
    if not model:IsA("Model") then return false end
    
    local hum = model:FindFirstChild("Humanoid")
    if not hum then
        task.wait(0.2)
        hum = model:FindFirstChild("Humanoid")
    end
    
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then
        task.wait(0.2)
        hrp = model:FindFirstChild("HumanoidRootPart")
    end
    
    if not hum or not hrp then return false end
    if hum.Health <= 0 then return false end
    
    return true
end

-- 10. FLAGS (TUDO DESATIVADO)
local Flags = {
    AutoFarm = false, AutoQuest = false, KillAura = false,
    AutoBoss = false, BossName = "",
    Range = 300, Kills = 0,
    AutoSkill = false,
    LastTP = 0, TPCooldown = 0.5,
    LastAttack = 0, AttackCooldown = 0.12,
    
    FruitSniper = false, AutoStore = false, AutoRoll = false, AutoSpawn = false,
    FragmentFarm = false, BonesFarm = false, BountyHunt = false,
    AutoHaki = false, AutoStats = false, AutoV4 = false, AutoRace = false,
    StatsToUpgrade = "Melee", StatsAmount = 3,
    ESP_Players = false, ESP_Fruits = false, ESP_Chests = false, ESP_Bosses = false,
    Aimlock = false,
}

-- 11. FUNÇÕES BÁSICAS

local function GetRemote()
    local rs = ReplicatedStorage:FindFirstChild("Remotes")
    if rs then
        return rs:FindFirstChild("CommF") or rs:FindFirstChild("CommF_")
    end
    return nil
end

local function TP(pos)
    if tick() - Flags.LastTP < Flags.TPCooldown then return end
    Flags.LastTP = tick()
    
    SafeCall(function()
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end)
end

local function Attack()
    if tick() - Flags.LastAttack < Flags.AttackCooldown then return end
    Flags.LastAttack = tick()
    
    SafeCall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0))
        task.wait(0.02)
        VirtualUser:Button1Up(Vector2.new(0, 0))
        Flags.Kills = Flags.Kills + 1
    end)
end

local function IsValidEnemy(model)
    if not model or model == Player.Character then return false end
    if not model:IsA("Model") then return false end
    if not model.Name or model.Name == "" then return false end
    if not model.Parent then return false end
    
    -- Ignora NPCs de quest
    local ignoreNames = {"Quest", "Giver", "Trainer", "Dealer", "Adventurer"}
    for _, name in ipairs(ignoreNames) do
        if model.Name:find(name) then return false end
    end
    
    return WaitForMob(model)
end

local function GetNearbyEnemies(maxDist)
    local enemies = {}
    local char = Player.Character
    if not char then return enemies end
    
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return enemies end
    
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return enemies end
    
    for _, model in pairs(enemiesFolder:GetChildren()) do
        if #enemies >= 10 then break end
        if IsValidEnemy(model) then
            local dist = (model.HumanoidRootPart.Position - myHRP.Position).Magnitude
            if dist <= maxDist then
                table.insert(enemies, {
                    Model = model,
                    HRP = model.HumanoidRootPart,
                    Distance = dist
                })
            end
        end
    end
    
    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    return enemies
end

local function FindBoss(name)
    local folders = {"Bosses", "Enemies"}
    for _, folderName in ipairs(folders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, model in pairs(folder:GetChildren()) do
                if model:IsA("Model") and model.Name:find(name) then
                    if IsValidEnemy(model) then
                        return model
                    end
                end
            end
        end
    end
    return nil
end

local function GetQuestNPC()
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, model in pairs(npcFolder:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                if model:FindFirstChild("Talk") or model.Name:find("Quest") then
                    return model
                end
            end
        end
    end
    return nil
end

local function OpenShop(shopType)
    SafeCall(function()
        local remote = GetRemote()
        if remote then
            remote:InvokeServer("OpenShop", shopType)
            Notify("🛍️ Loja", shopType .. " aberta!", 2)
        end
    end)
end

-- ============================================================
-- 12. SISTEMAS PRINCIPAIS
-- ============================================================

-- AUTO FARM
task.spawn(function()
    while true do
        if Flags.AutoFarm then
            SafeCall(function()
                -- Auto Quest
                if Flags.AutoQuest then
                    local npc = GetQuestNPC()
                    if npc then
                        local q = Player.PlayerGui:FindFirstChild("Main")
                        if q then
                            q = q:FindFirstChild("Quest")
                            if q and not q.Visible then
                                local hrp = npc:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    TP(hrp.Position)
                                    task.wait(0.5)
                                    local remote = GetRemote()
                                    if remote then
                                        remote:InvokeServer("StartQuest", "BanditQuest1", 1)
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Atacar inimigos
                local enemies = GetNearbyEnemies(Flags.Range)
                if #enemies > 0 then
                    local target = enemies[1]
                    if target.Distance > 15 then
                        TP(target.HRP.Position)
                    end
                    task.wait(0.1)
                    Attack()
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- AUTO BOSS
task.spawn(function()
    while true do
        if Flags.AutoBoss and Flags.BossName ~= "" then
            SafeCall(function()
                local boss = FindBoss(Flags.BossName)
                if boss then
                    local hrp = boss:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        TP(hrp.Position)
                        task.wait(0.2)
                        for _ = 1, 8 do Attack() task.wait(0.08) end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- KILL AURA
task.spawn(function()
    while true do
        if Flags.KillAura then
            SafeCall(function()
                local enemies = GetNearbyEnemies(20)
                if #enemies > 0 then
                    Attack()
                end
            end)
        end
        task.wait(0.12)
    end
end)

-- FRUIT SNIPER
task.spawn(function()
    while true do
        if Flags.FruitSniper then
            SafeCall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:find("Fruit") then
                        if obj.Parent and obj.Parent:FindFirstChild("Handle") then
                            TP(obj.Position)
                            Notify("🍎 Fruta", "Encontrada!", 2)
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- AUTO STORE
task.spawn(function()
    while true do
        if Flags.AutoStore then
            SafeCall(function()
                local data = Player:FindFirstChild("Data")
                if data and data:FindFirstChild("Fruit") then
                    local fruit = data.Fruit.Value
                    if fruit and fruit ~= "" then
                        local remote = GetRemote()
                        if remote then remote:InvokeServer("StoreFruit", fruit) end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- AUTO ROLL
task.spawn(function()
    while true do
        if Flags.AutoRoll then
            SafeCall(function()
                local remote = GetRemote()
                if remote then remote:InvokeServer("FruitGacha", "Roll") end
            end)
        end
        task.wait(15)
    end
end)

-- AUTO SPAWN
task.spawn(function()
    while true do
        if Flags.AutoSpawn then
            SafeCall(function()
                local remote = GetRemote()
                if remote then remote:InvokeServer("Cousin", "Buy") end
            end)
        end
        task.wait(60)
    end
end)

-- FRAGMENT FARM
task.spawn(function()
    while true do
        if Flags.FragmentFarm then
            SafeCall(function()
                local remote = GetRemote()
                if remote then remote:InvokeServer("AddFragments", 500) end
            end)
        end
        task.wait(60)
    end
end)

-- BONES FARM
task.spawn(function()
    while true do
        if Flags.BonesFarm then
            SafeCall(function()
                local remote = GetRemote()
                if remote then remote:InvokeServer("AddBones", 50) end
            end)
        end
        task.wait(30)
    end
end)

-- BOUNTY HUNT
task.spawn(function()
    while true do
        if Flags.BountyHunt then
            SafeCall(function()
                local best, bestDist = nil, math.huge
                local char = Player.Character
                if not char then return end
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                if not myHRP then return end
                
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= Player and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - myHRP.Position).Magnitude
                            if dist < Flags.Range and dist < bestDist then
                                bestDist = dist
                                best = plr
                            end
                        end
                    end
                end
                
                if best and best.Character then
                    local hrp = best.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        TP(hrp.Position)
                        task.wait(0.2)
                        for _ = 1, 8 do Attack() task.wait(0.05) end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- AUTO HAKI
task.spawn(function()
    while true do
        if Flags.AutoHaki then
            SafeCall(function()
                local remote = GetRemote()
                if remote then
                    remote:InvokeServer("ActivateHaki", "Ken")
                    task.wait(0.3)
                    remote:InvokeServer("ActivateHaki", "Observation")
                end
            end)
        end
        task.wait(120)
    end
end)

-- AUTO STATS
task.spawn(function()
    while true do
        if Flags.AutoStats then
            SafeCall(function()
                local remote = GetRemote()
                if remote then
                    for _ = 1, Flags.StatsAmount do
                        remote:InvokeServer("AddPoint", Flags.StatsToUpgrade, 1)
                    end
                end
            end)
        end
        task.wait(30)
    end
end)

-- AUTO V4
task.spawn(function()
    while true do
        if Flags.AutoV4 then
            SafeCall(function()
                local remote = GetRemote()
                if remote then remote:InvokeServer("RaceV4", "Start") end
            end)
        end
        task.wait(180)
    end
end)

-- AUTO RACE
task.spawn(function()
    while true do
        if Flags.AutoRace then
            SafeCall(function()
                local remote = GetRemote()
                if remote then remote:InvokeServer("RaceAwakening", "Start") end
            end)
        end
        task.wait(180)
    end
end)

-- ESP (COM LIMPEZA E LIMITE)
task.spawn(function()
    local espObjects = {}
    while true do
        -- Limpa ESP antigo
        for _, obj in ipairs(espObjects) do
            SafeCall(function() if obj and obj.Parent then obj:Destroy() end end)
        end
        espObjects = {}
        
        if Flags.ESP_Players or Flags.ESP_Fruits or Flags.ESP_Chests or Flags.ESP_Bosses then
            SafeCall(function()
                local count = 0
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if count >= 20 then break end
                    if obj:IsA("Model") and obj:FindFirstChild("Head") then
                        local show, color = false, Color3.fromRGB(255,255,255)
                        
                        if Flags.ESP_Players then
                            local plr = Players:GetPlayerFromCharacter(obj)
                            if plr and plr ~= Player then
                                show = true
                                color = Color3.fromRGB(255,0,0)
                            end
                        end
                        
                        if Flags.ESP_Fruits and obj.Name:lower():find("fruit") then
                            show = true
                            color = Color3.fromRGB(255,0,255)
                        end
                        
                        if Flags.ESP_Chests and obj.Name:lower():find("chest") then
                            show = true
                            color = Color3.fromRGB(255,215,0)
                        end
                        
                        if Flags.ESP_Bosses then
                            local hum = obj:FindFirstChild("Humanoid")
                            if hum and hum.MaxHealth > 5000 then
                                show = true
                                color = Color3.fromRGB(255,50,50)
                            end
                        end
                        
                        if show then
                            SafeCall(function()
                                local bill = Instance.new("BillboardGui")
                                bill.Adornee = obj.Head
                                bill.Size = UDim2.new(0, 70, 0, 16)
                                bill.AlwaysOnTop = true
                                bill.MaxDistance = Flags.Range
                                bill.Parent = CoreGui
                                
                                local label = Instance.new("TextLabel", bill)
                                label.Size = UDim2.new(1,0,1,0)
                                label.BackgroundTransparency = 0.7
                                label.BackgroundColor3 = color
                                label.TextColor3 = Color3.new(1,1,1)
                                label.TextSize = 7
                                label.Font = Enum.Font.GothamBold
                                label.Text = obj.Name
                                
                                table.insert(espObjects, bill)
                                count = count + 1
                                
                                task.delay(3, function()
                                    SafeCall(function() if bill and bill.Parent then bill:Destroy() end end)
                                end)
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- AIMLOCK
task.spawn(function()
    while true do
        if Flags.Aimlock then
            SafeCall(function()
                local enemies = GetNearbyEnemies(Flags.Range)
                if #enemies > 0 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, enemies[1].HRP.Position)
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- ANTI-AFK
Player.Idled:Connect(function()
    SafeCall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ============================================================
-- 13. CRIAR UI
-- ============================================================
local win = NexusUI:CreateWindow({
    Title = "NEXUS v2.2",
    Subtitle = "🛡️ Anti-Crash Mobile | ⚡ Estável",
    Width = 580,
    Height = 500
})

local tabs = {}
for _, t in pairs({
    {"⚔️ Farm", "⚔️"}, {"🎯 Bosses", "🎯"}, {"🍎 Frutas", "🍎"},
    {"⚙️ Auto", "⚙️"}, {"📊 Stats", "📊"}, {"🛍️ Loja", "🛍️"},
    {"👀 ESP", "👀"}, {"🏝️ Ilhas", "🏝️"}
}) do
    tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1], Icon = t[2]})
end

-- ⚔️ FARM
NexusUI:CreateSection(tabs["⚔️ Farm"], "🚀 Auto Farm")
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🚀 Auto Farm", Callback = function(v) Flags.AutoFarm = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "📋 Auto Quest", Callback = function(v) Flags.AutoQuest = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "💀 Kill Aura", Callback = function(v) Flags.KillAura = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "⭐ Auto Skill", Callback = function(v) Flags.AutoSkill = v end})
NexusUI:CreateSlider(tabs["⚔️ Farm"], {Title = "🎯 Alcance", Min = 100, Max = 500, Default = 300, Callback = function(v) Flags.Range = v end})

-- 🎯 BOSSES
NexusUI:CreateSection(tabs["🎯 Bosses"], "🎯 Boss Farm")
NexusUI:CreateToggle(tabs["🎯 Bosses"], {Title = "🎯 Auto Boss", Callback = function(v) Flags.AutoBoss = v end})
local bosses = {"Gorilla King", "Yeti", "Vice Admiral", "Saber Expert", "Swan", "Magma Admiral", "Fishman Lord", "Diamond", "Jeremy", "Don Swan", "Tide Keeper", "Cake Prince", "Dough King", "Rip Indra", "Darkbeard"}
for _, boss in ipairs(bosses) do
    NexusUI:CreateToggle(tabs["🎯 Bosses"], {Title = boss, Callback = function(v) if v then Flags.AutoBoss = true Flags.BossName = boss end end})
end

-- 🍎 FRUTAS
NexusUI:CreateSection(tabs["🍎 Frutas"], "🍎 Frutas")
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🍎 Fruit Sniper", Callback = function(v) Flags.FruitSniper = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "📦 Auto Store", Callback = function(v) Flags.AutoStore = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🎲 Auto Roll", Callback = function(v) Flags.AutoRoll = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🪄 Auto Spawn", Callback = function(v) Flags.AutoSpawn = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "💎 Fragment Farm", Callback = function(v) Flags.FragmentFarm = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🦴 Bones Farm", Callback = function(v) Flags.BonesFarm = v end})

-- ⚙️ AUTO
NexusUI:CreateSection(tabs["⚙️ Auto"], "⚙️ Automações")
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🌀 Auto Haki", Callback = function(v) Flags.AutoHaki = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "👑 Auto V4", Callback = function(v) Flags.AutoV4 = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🧬 Auto Race", Callback = function(v) Flags.AutoRace = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "💰 Bounty Hunt", Callback = function(v) Flags.BountyHunt = v end})

-- 📊 STATS
NexusUI:CreateSection(tabs["📊 Stats"], "📊 Configurar Stats")
NexusUI:CreateToggle(tabs["📊 Stats"], {Title = "📊 Auto Stats", Callback = function(v) Flags.AutoStats = v end})
NexusUI:CreateDropdown(tabs["📊 Stats"], {Title = "📌 Status", Options = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, Default = "Melee", Callback = function(v) Flags.StatsToUpgrade = v end})
NexusUI:CreateSlider(tabs["📊 Stats"], {Title = "🔢 Pontos", Min = 1, Max = 10, Default = 3, Callback = function(v) Flags.StatsAmount = v end})

-- 🛍️ LOJA
NexusUI:CreateSection(tabs["🛍️ Loja"], "🛍️ Abrir Lojas")
NexusUI:CreateButton(tabs["🛍️ Loja"], {Title = "🍎 Frutas", Callback = function() OpenShop("FruitShop") end})
NexusUI:CreateButton(tabs["🛍️ Loja"], {Title = "⚔️ Espadas", Callback = function() OpenShop("SwordShop") end})
NexusUI:CreateButton(tabs["🛍️ Loja"], {Title = "🔫 Armas", Callback = function() OpenShop("GunShop") end})
NexusUI:CreateButton(tabs["🛍️ Loja"], {Title = "👊 Estilos", Callback = function() OpenShop("FightingStyleShop") end})
NexusUI:CreateButton(tabs["🛍️ Loja"], {Title = "💍 Acessórios", Callback = function() OpenShop("AccessoryShop") end})

-- 👀 ESP
NexusUI:CreateSection(tabs["👀 ESP"], "👀 ESP")
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "👤 ESP Players", Callback = function(v) Flags.ESP_Players = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🍎 ESP Fruits", Callback = function(v) Flags.ESP_Fruits = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "📦 ESP Chests", Callback = function(v) Flags.ESP_Chests = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🎯 ESP Bosses", Callback = function(v) Flags.ESP_Bosses = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🎯 Aimlock", Callback = function(v) Flags.Aimlock = v end})

-- 🏝️ ILHAS
NexusUI:CreateSection(tabs["🏝️ Ilhas"], "🏝️ Teleportes")
local islands = {
    {"Pirate Starter", Vector3.new(1289, 11, 4191)},
    {"Jungle", Vector3.new(-1250, 15, 3850)},
    {"Desert", Vector3.new(966, 10, 1100)},
    {"Frozen Village", Vector3.new(1150, 25, 4350)},
    {"Marine Fortress", Vector3.new(-1500, 10, 5300)},
    {"Skylands", Vector3.new(-4850, 750, 1950)},
    {"Prison", Vector3.new(-5400, 15, -1700)},
    {"Colosseum", Vector3.new(-3560, 240, -80)},
    {"Magma Village", Vector3.new(-3420, 10, -2700)},
    {"Underwater City", Vector3.new(5500, -50, 2000)},
    {"Fountain City", Vector3.new(4500, 50, 1200)},
    {"Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
    {"Green Zone", Vector3.new(6200, 80, 2500)},
    {"Ice Castle", Vector3.new(7200, 100, 3500)},
    {"Port Town", Vector3.new(7200, 100, 3500)},
    {"Hydra Island", Vector3.new(6200, 80, 2500)},
    {"Great Tree", Vector3.new(8500, 120, 4500)},
    {"Floating Turtle", Vector3.new(11200, 90, 6500)},
}
for _, island in ipairs(islands) do
    NexusUI:CreateButton(tabs["🏝️ Ilhas"], {
        Title = "🏝️ " .. island[1],
        Callback = function() TP(island[2]) end
    })
end

-- FPS COUNTER
local fpsLabel = Instance.new("TextLabel", win.Frame)
fpsLabel.Size = UDim2.new(0, 200, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: -- | 💀 0"
fpsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham

local fc, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nw = tick()
    if nw - lt >= 1 then
        fpsLabel.Text = "FPS: " .. fc .. " | 💀 " .. Flags.Kills
        fc = 0
        lt = nw
    end
end)

Notify("NEXUS v2.2", "✅ Pronto!\n🛡️ Anti-Crash Mobile\n🔴 Tudo desativado", 5)
print("✅ NEXUS v2.2 - ANTI-CRASH MOBILE CARREGADO!")
