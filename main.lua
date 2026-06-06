-- // ╔══════════════════════════════════════════════════════════╗
-- // ║              NEXUS SUPREMO v1.0                          ║
-- // ║   O melhor de todos os scripts em um só lugar           ║
-- // ╚══════════════════════════════════════════════════════════╝

-- // ==================== [ VERIFICAÇÕES INICIAIS ] ====================
local PlaceId = game.PlaceId
local ValidPlaces = {2753915549, 4442272183, 7449423635}
local IsValid = false
for _, id in ipairs(ValidPlaces) do
    if PlaceId == id then IsValid = true break end
end
if not IsValid then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NEXUS SUPREMO", Text = "Script exclusivo para Blox Fruits!", Duration = 5
    })
    return
end

-- // ==================== [ CARREGAMENTO DA UI ] ====================
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()
local win = DiscordLib:Window("NEXUS SUPREMO")
local serv = win:Server("Blox Fruits", "http://www.roblox.com/asset/?id=6031075938")

-- // ==================== [ SERVIÇOS ] ====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- // ==================== [ OTIMIZAÇÕES ] ====================
game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

pcall(function() settings().Rendering.QualityLevel = 1 end)
pcall(function() Lighting.GlobalShadows = false end)
pcall(function() Lighting.Brightness = 1.5 end)
pcall(function() Lighting.FogEnd = 5000 end)

-- // ==================== [ ANTI-AFK ] ====================
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
end)

-- // ==================== [ VARIAVEIS GLOBAIS ] ====================
_G.AutoFarm = false
_G.AutoQuest = true
_G.AutoBoss = false
_G.AutoHaki = false
_G.GodMode = false
_G.BringMob = true
_G.FastAttack = false
_G.AutoStats = false
_G.FruitSniper = false
_G.AutoStore = false
_G.AutoRoll = false
_G.SelectBoss = ""
_G.SelectWeapon = "Melee"
_G.Fast_Delay = 0.001
_G.StopTween = false
_G.Clip2 = false
_G.Range = 300

-- // ==================== [ SCANNER DE REMOTES ] ====================
local function GetRemote(name)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        for _, r in pairs(remotes:GetDescendants()) do
            if r.Name == name or r.Name:find(name) then
                return r
            end
        end
    end
    return nil
end

-- // ==================== [ SCANNER DE MODULOS ] ====================
local function RequireModule(name)
    for _, mod in pairs(getmodules()) do
        if mod.Name == name then
            return require(mod)
        end
    end
end

-- // ==================== [ HOOK SYSTEM ] ====================
local function HookFunction(moduleName, funcName, hook)
    local mod = RequireModule(moduleName)
    if not mod or not mod[funcName] then return end
    local old = mod[funcName]
    mod[funcName] = function(...)
        return hook(old, ...)
    end
end

-- // ==================== [ SISTEMA DE TELEPORTE ] ====================
local function TP(pos)
    local char, hrp = Player.Character, Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local target = pos + Vector3.new(math.random(-2, 2), 3, math.random(-2, 2))
    hrp.CFrame = CFrame.new(target)
end

local function TweenTP(pos)
    local _, hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local distance = (pos.Position - hrp.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(distance / 350), {CFrame = pos})
    tween:Play()
    if _G.StopTween then tween:Cancel() end
end

-- // ==================== [ SISTEMA DE ATAQUE ] ====================
local function Attack()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(0, 0))
    task.wait(0.05)
    VirtualUser:Button1Up(Vector2.new(0, 0))
end

local function FastAttack()
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
        local registerAttack = remotes:WaitForChild("RE/RegisterAttack")
        local registerHit = remotes:WaitForChild("RE/RegisterHit")
        registerAttack:FireServer(1e-9)
        
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local head = enemy:FindFirstChild("Head")
                if head and (Player.Character.HumanoidRootPart.Position - head.Position).Magnitude <= 60 then
                    registerHit:FireServer(head, {{enemy, head}})
                end
            end
        end
    end)
end

-- // ==================== [ SISTEMA DE DETECÇÃO ] ====================
local function GetEnemies(dist)
    local enemies = {}
    local _, myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return enemies end
    
    local folder = Workspace:FindFirstChild("Enemies")
    if not folder then return enemies end
    
    for _, obj in ipairs(folder:GetChildren()) do
        if #enemies >= 5 then break end
        if not obj:IsA("Model") then continue end
        
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local hum = obj:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local d = (hrp.Position - myHrp.Position).Magnitude
        if d <= dist then
            table.insert(enemies, {Mob = obj, HRP = hrp, Distance = d})
        end
    end
    
    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    return enemies
end

local function FindBoss(name)
    for _, folderName in ipairs({"Bosses", "Enemies"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob.Name:lower():find(name:lower(), 1, true) then
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        return mob
                    end
                end
            end
        end
    end
end

-- // ==================== [ DADOS DO JOGO ] ====================
local Sea1, Sea2, Sea3 = false, false, false
if game.PlaceId == 2753915549 then Sea1 = true
elseif game.PlaceId == 4442272183 then Sea2 = true
elseif game.PlaceId == 7449423635 then Sea3 = true end

function CheckLevel()
    local lv = Player.Data.Level.Value
    if Sea1 then
        if lv <= 9 then
            Ms, NameQuest, QuestLv, NameMon = "Bandit", "BanditQuest1", 1, "Bandit"
            CFrameQ = CFrame.new(1060.94, 16.46, 1547.78)
            CFrameMon = CFrame.new(1038.55, 41.30, 1576.51)
        elseif lv <= 14 then
            Ms, NameQuest, QuestLv, NameMon = "Monkey", "JungleQuest", 1, "Monkey"
            CFrameQ = CFrame.new(-1601.66, 36.85, 153.39)
            CFrameMon = CFrame.new(-1448.14, 50.85, 63.61)
        elseif lv <= 29 then
            Ms, NameQuest, QuestLv, NameMon = "Gorilla", "JungleQuest", 2, "Gorilla"
            CFrameQ = CFrame.new(-1601.66, 36.85, 153.39)
            CFrameMon = CFrame.new(-1142.65, 40.46, -515.39)
        elseif lv <= 39 then
            Ms, NameQuest, QuestLv, NameMon = "Pirate", "BuggyQuest1", 1, "Pirate"
            CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41)
            CFrameMon = CFrame.new(-1201.09, 40.63, 3857.60)
        elseif lv <= 59 then
            Ms, NameQuest, QuestLv, NameMon = "Brute", "BuggyQuest1", 2, "Brute"
            CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41)
            CFrameMon = CFrame.new(-1387.53, 24.59, 4100.96)
        elseif lv <= 74 then
            Ms, NameQuest, QuestLv, NameMon = "Desert Bandit", "DesertQuest", 1, "Desert Bandit"
            CFrameQ = CFrame.new(896.52, 6.44, 4390.15)
            CFrameMon = CFrame.new(985.00, 16.11, 4417.91)
        elseif lv <= 89 then
            Ms, NameQuest, QuestLv, NameMon = "Desert Officer", "DesertQuest", 2, "Desert Officer"
            CFrameQ = CFrame.new(896.52, 6.44, 4390.15)
            CFrameMon = CFrame.new(1547.15, 14.45, 4381.80)
        elseif lv <= 99 then
            Ms, NameQuest, QuestLv, NameMon = "Snow Bandit", "SnowQuest", 1, "Snow Bandit"
            CFrameQ = CFrame.new(1386.81, 87.27, -1298.36)
            CFrameMon = CFrame.new(1356.30, 105.77, -1328.24)
        elseif lv <= 119 then
            Ms, NameQuest, QuestLv, NameMon = "Snowman", "SnowQuest", 2, "Snowman"
            CFrameQ = CFrame.new(1386.81, 87.27, -1298.36)
            CFrameMon = CFrame.new(1218.80, 138.01, -1488.03)
        elseif lv <= 149 then
            Ms, NameQuest, QuestLv, NameMon = "Chief Petty Officer", "MarineQuest2", 1, "Chief Petty Officer"
            CFrameQ = CFrame.new(-5035.50, 28.68, 4324.18)
            CFrameMon = CFrame.new(-4931.16, 65.79, 4121.84)
        elseif lv <= 174 then
            Ms, NameQuest, QuestLv, NameMon = "Sky Bandit", "SkyQuest", 1, "Sky Bandit"
            CFrameQ = CFrame.new(-4842.14, 717.70, -2623.05)
            CFrameMon = CFrame.new(-4955.64, 365.46, -2908.19)
        elseif lv <= 209 then
            Ms, NameQuest, QuestLv, NameMon = "Prisoner", "PrisonerQuest", 1, "Prisoner"
            CFrameQ = CFrame.new(5310.61, 0.35, 474.95)
            CFrameMon = CFrame.new(4937.32, 0.33, 649.57)
        elseif lv <= 249 then
            Ms, NameQuest, QuestLv, NameMon = "Dangerous Prisoner", "PrisonerQuest", 2, "Dangerous Prisoner"
            CFrameQ = CFrame.new(5310.61, 0.35, 474.95)
            CFrameMon = CFrame.new(5099.66, 0.35, 1055.76)
        elseif lv <= 274 then
            Ms, NameQuest, QuestLv, NameMon = "Toga Warrior", "ColosseumQuest", 1, "Toga Warrior"
            CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48)
            CFrameMon = CFrame.new(-1872.52, 49.08, -2913.81)
        elseif lv <= 299 then
            Ms, NameQuest, QuestLv, NameMon = "Gladiator", "ColosseumQuest", 2, "Gladiator"
            CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48)
            CFrameMon = CFrame.new(-1521.37, 81.20, -3066.31)
        elseif lv <= 324 then
            Ms, NameQuest, QuestLv, NameMon = "Military Soldier", "MagmaQuest", 1, "Military Soldier"
            CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00)
            CFrameMon = CFrame.new(-5369.00, 61.24, 8556.49)
        elseif lv <= 374 then
            Ms, NameQuest, QuestLv, NameMon = "Military Spy", "MagmaQuest", 2, "Military Spy"
            CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00)
            CFrameMon = CFrame.new(-5787.00, 75.83, 8651.70)
        elseif lv <= 399 then
            Ms, NameQuest, QuestLv, NameMon = "Fishman Warrior", "FishmanQuest", 1, "Fishman Warrior"
            CFrameQ = CFrame.new(61122.65, 18.50, 1569.40)
            CFrameMon = CFrame.new(60844.11, 98.46, 1298.40)
        elseif lv <= 449 then
            Ms, NameQuest, QuestLv, NameMon = "Fishman Commando", "FishmanQuest", 2, "Fishman Commando"
            CFrameQ = CFrame.new(61122.65, 18.50, 1569.40)
            CFrameMon = CFrame.new(61738.40, 64.21, 1433.84)
        elseif lv <= 474 then
            Ms, NameQuest, QuestLv, NameMon = "God's Guard", "SkyExp1Quest", 1, "God's Guard"
            CFrameQ = CFrame.new(-4721.86, 845.30, -1953.85)
            CFrameMon = CFrame.new(-4628.05, 866.93, -1931.24)
        elseif lv <= 524 then
            Ms, NameQuest, QuestLv, NameMon = "Shanda", "SkyExp1Quest", 2, "Shanda"
            CFrameQ = CFrame.new(-7863.16, 5545.52, -378.42)
            CFrameMon = CFrame.new(-7685.15, 5601.08, -441.39)
        elseif lv <= 549 then
            Ms, NameQuest, QuestLv, NameMon = "Royal Squad", "SkyExp2Quest", 1, "Royal Squad"
            CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92)
            CFrameMon = CFrame.new(-7654.25, 5637.11, -1407.76)
        elseif lv <= 624 then
            Ms, NameQuest, QuestLv, NameMon = "Royal Soldier", "SkyExp2Quest", 2, "Royal Soldier"
            CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92)
            CFrameMon = CFrame.new(-7760.41, 5679.91, -1884.81)
        elseif lv <= 649 then
            Ms, NameQuest, QuestLv, NameMon = "Galley Pirate", "FountainQuest", 1, "Galley Pirate"
            CFrameQ = CFrame.new(5258.28, 38.53, 4050.04)
            CFrameMon = CFrame.new(5557.17, 152.33, 3998.78)
        else
            Ms, NameQuest, QuestLv, NameMon = "Galley Captain", "FountainQuest", 2, "Galley Captain"
            CFrameQ = CFrame.new(5258.28, 38.53, 4050.04)
            CFrameMon = CFrame.new(5677.68, 92.79, 4966.63)
        end
    end
end

-- // ==================== [ AUTO FARM ] ====================
local AutoFarmConnection = nil

local function StartAutoFarm()
    if AutoFarmConnection then AutoFarmConnection:Disconnect() end
    
    AutoFarmConnection = RunService.RenderStepped:Connect(function()
        if not _G.AutoFarm then return end
        
        pcall(function()
            CheckLevel()
            
            -- Verifica quest
            local hasQuest = false
            pcall(function()
                if Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:find(NameMon) then
                    hasQuest = true
                end
            end)
            
            if not hasQuest and _G.AutoQuest then
                GetRemote("CommF_"):InvokeServer("AbandonQuest")
                TweenTP(CFrameQ)
                if (CFrameQ.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                    GetRemote("CommF_"):InvokeServer("StartQuest", NameQuest, QuestLv)
                end
                return
            end
            
            -- Ataca inimigos
            if hasQuest or not _G.AutoQuest then
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy.Name == Ms and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        if _G.AutoHaki and not Player.Character:FindFirstChild("HasBuso") then
                            GetRemote("CommF_"):InvokeServer("Buso")
                        end
                        
                        if _G.BringMob then
                            enemy.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                            enemy.HumanoidRootPart.CanCollide = false
                            enemy.Humanoid.WalkSpeed = 0
                            enemy.Humanoid.JumpPower = 0
                        else
                            if (enemy.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude > 15 then
                                TP(enemy.HumanoidRootPart.Position)
                            end
                        end
                        
                        if _G.FastAttack then
                            FastAttack()
                        else
                            Attack()
                        end
                        
                        break
                    end
                end
            end
        end)
    end)
end

-- // ==================== [ AUTO BOSS ] ====================
local AutoBossConnection = nil

local function StartAutoBoss()
    if AutoBossConnection then AutoBossConnection:Disconnect() end
    
    AutoBossConnection = RunService.RenderStepped:Connect(function()
        if not _G.AutoBoss or _G.SelectBoss == "" then return end
        if _G.AutoFarm then return end -- Prioridade para AutoFarm
        
        pcall(function()
            local boss = FindBoss(_G.SelectBoss)
            if boss then
                local bossHrp = boss:FindFirstChild("HumanoidRootPart")
                if bossHrp then
                    if (bossHrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude > 15 then
                        TP(bossHrp.Position)
                    end
                    
                    if _G.AutoHaki and not Player.Character:FindFirstChild("HasBuso") then
                        GetRemote("CommF_"):InvokeServer("Buso")
                    end
                    
                    if _G.FastAttack then
                        FastAttack()
                    else
                        Attack()
                    end
                end
            end
        end)
    end)
end

-- // ==================== [ GOD MODE ] ====================
task.spawn(function()
    while task.wait(0.3) do
        if not _G.GodMode then continue end
        
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                hum.Health = hum.MaxHealth
            end
        end)
    end
end)

-- // ==================== [ AUTO STATS ] ====================
task.spawn(function()
    while task.wait(60) do
        if not _G.AutoStats then continue end
        
        pcall(function()
            local remote = GetRemote("CommF_")
            if remote then
                for _ = 1, 3 do
                    remote:InvokeServer("AddPoint", "Melee", 1)
                end
            end
        end)
    end
end)

-- // ==================== [ FRUIT SNIPER ] ====================
task.spawn(function()
    while task.wait(3) do
        if not _G.FruitSniper then continue end
        
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("fruit", 1, true) then
                    if obj.Parent and obj.Parent:FindFirstChild("Handle") then
                        TP(obj.Position)
                        task.wait(0.5)
                        break
                    end
                end
            end
        end)
    end
end)

-- // ==================== [ AUTO STORE ] ====================
task.spawn(function()
    while task.wait(10) do
        if not _G.AutoStore then continue end
        
        pcall(function()
            local data = Player:FindFirstChild("Data")
            if data then
                local fruit = data:FindFirstChild("Fruit")
                if fruit and fruit.Value ~= "" then
                    GetRemote("CommF_"):InvokeServer("StoreFruit", fruit.Value)
                end
            end
        end)
    end
end)

-- // ==================== [ AUTO ROLL ] ====================
task.spawn(function()
    while task.wait(30) do
        if not _G.AutoRoll then continue end
        
        pcall(function()
            GetRemote("CommF_"):InvokeServer("FruitGacha", "Roll")
        end)
    end
end)

-- // ==================== [ NOCLIP AUTOMATICO ] ====================
task.spawn(function()
    RunService.Stepped:Connect(function()
        if not _G.AutoFarm and not _G.AutoBoss then return end
        
        pcall(function()
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end)
end)

-- // ==================== [ BODY VELOCITY ANTI-KNOCKBACK ] ====================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.AutoFarm or _G.AutoBoss then
                if not Player.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "BodyClip"
                    bv.Parent = Player.Character.HumanoidRootPart
                    bv.MaxForce = Vector3.new(100000, 100000, 100000)
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            elseif Player.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                Player.Character.HumanoidRootPart.BodyClip:Destroy()
            end
        end)
    end
end)

-- // ==================== [ UI - CANAIS ] ====================
local farmChannel = serv:Channel("⚔️ Auto Farm")
local bossChannel = serv:Channel("💀 Auto Boss")
local fruitChannel = serv:Channel("🍎 Frutas")
local otherChannel = serv:Channel("⚙️ Outros")
local infoChannel = serv:Channel("ℹ️ Informações")

-- // ==================== [ AUTO FARM UI ] ====================
farmChannel:Toggle("Auto Farm Level", false, function(v)
    _G.AutoFarm = v
    if v then StartAutoFarm() end
end)

farmChannel:Toggle("Auto Quest", true, function(v)
    _G.AutoQuest = v
end)

farmChannel:Toggle("Bring Mob", true, function(v)
    _G.BringMob = v
end)

farmChannel:Toggle("Fast Attack", false, function(v)
    _G.FastAttack = v
end)

farmChannel:Toggle("Auto Haki", false, function(v)
    _G.AutoHaki = v
end)

farmChannel:Toggle("God Mode", false, function(v)
    _G.GodMode = v
end)

farmChannel:Slider("Range", 50, 500, 300, function(v)
    _G.Range = v
end)

-- // ==================== [ AUTO BOSS UI ] ====================
bossChannel:Toggle("Auto Boss", false, function(v)
    _G.AutoBoss = v
    if v then StartAutoBoss() end
end)

bossChannel:Dropdown("Selecionar Boss", {
    "Gorilla King", "Bobby", "Yeti", "Mob Leader",
    "Vice Admiral", "Warden", "Chief Warden", "Saber Expert",
    "Swan", "Magma Admiral", "Fishman Lord",
    "Diamond", "Jeremy", "Don Swan",
    "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper",
    "Cake Prince", "Dough King", "Soul Reaper", "Rip Indra",
    "Darkbeard", "Stone", "Island Empress"
}, function(v)
    _G.SelectBoss = v
end)

-- // ==================== [ FRUTAS UI ] ====================
fruitChannel:Toggle("Fruit Sniper", false, function(v)
    _G.FruitSniper = v
end)

fruitChannel:Toggle("Auto Store", false, function(v)
    _G.AutoStore = v
end)

fruitChannel:Toggle("Auto Roll", false, function(v)
    _G.AutoRoll = v
end)

-- // ==================== [ OUTROS UI ] ====================
otherChannel:Toggle("Auto Stats", false, function(v)
    _G.AutoStats = v
end)

otherChannel:Slider("Delay de Ataque", 0, 10, 0, function(v)
    _G.Fast_Delay = v == 0 and 1e-9 or v / 10
end)

-- // ==================== [ INFORMAÇÕES UI ] ====================
infoChannel:Button("🔄 Atualizar Dados", function()
    local level = Player.Data.Level.Value
    local sea = Sea1 and "1" or Sea2 and "2" or Sea3 and "3" or "?"
    DiscordLib:Notification("NEXUS SUPREMO", "Sea: " .. sea .. " | Level: " .. level, "OK")
end)

infoChannel:Button("🛑 Parar Tudo", function()
    _G.AutoFarm = false
    _G.AutoBoss = false
    _G.GodMode = false
    _G.FruitSniper = false
    _G.AutoStore = false
    _G.AutoRoll = false
    _G.AutoStats = false
    _G.StopTween = true
    task.wait(0.5)
    _G.StopTween = false
    if AutoFarmConnection then AutoFarmConnection:Disconnect() end
    if AutoBossConnection then AutoBossConnection:Disconnect() end
    DiscordLib:Notification("NEXUS SUPREMO", "Todos os sistemas foram PARADOS!", "OK")
end)

infoChannel:Label("NEXUS SUPREMO v1.0")
infoChannel:Label("Criado com o melhor de todos os scripts")
infoChannel:Label("DiscordLib + HohoHub + Parvus + Fluent")

-- // ==================== [ INICIA AUTO FARM ] ====================
StartAutoFarm()

-- // ==================== [ NOTIFICAÇÃO INICIAL ] ====================
DiscordLib:Notification("NEXUS SUPREMO", "Script carregado com sucesso!\n\n⚔️ Auto Farm\n💀 Auto Boss\n🍎 Frutas\n⚙️ Outros", "VAMOS LÁ!")
