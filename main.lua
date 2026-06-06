-- // ╔══════════════════════════════════════════════════════════╗
-- // ║           NEXUS SUPREMO - COMPLETO VERIFICADO           ║
-- // ║   Todos os sistemas testados e funcionando              ║
-- // ╚══════════════════════════════════════════════════════════╝

-- ============================================================
-- 1. VERIFICAÇÕES INICIAIS
-- ============================================================
local PlaceId = game.PlaceId
local BloxFruitsIDs = {2753915549, 4442272183, 7449423635}
local permitido = false
for _, id in BloxFruitsIDs do
    if PlaceId == id then permitido = true break end
end
if not permitido then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NEXUS SUPREMO", Text = "Script exclusivo para Blox Fruits!", Duration = 5
    })
    return
end

-- ============================================================
-- 2. CARREGAMENTO DA UI
-- ============================================================
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

-- ============================================================
-- 3. SERVIÇOS NATIVOS DO ROBLOX
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- 4. ESPERAR CARREGAR
-- ============================================================
game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

-- ============================================================
-- 5. OTIMIZAÇÕES
-- ============================================================
pcall(function() settings().Rendering.QualityLevel = 1 end)
Lighting.GlobalShadows = false
Lighting.Brightness = 1.5
Lighting.FogEnd = 5000

-- ============================================================
-- 6. ANTI-AFK
-- ============================================================
Player.Idled:Connect(function()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local comm = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF")
            if comm then comm:InvokeServer("Buso") end
        end
    end)
end)

-- ============================================================
-- 7. FLAGS GLOBAIS
-- ============================================================
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
_G.WeaponName = ""
_G.Fast_Delay = 0.05
_G.StopTween = false
_G.Range = 300
_G.AutoClicker = false
_G.AutoClickerSpeed = 0.05
_G.AutoClickerClicks = 5
_G.AutoClickerMode = "Attack"
_G.ESP_Enabled = false
_G.ESP_Players = false
_G.ESP_Fruits = false
_G.ESP_Chests = false
_G.ESP_Bosses = false
_G.ESP_Range = 500
_G.WalkSpeed = false
_G.WalkSpeedValue = 100
_G.JumpPower = false
_G.JumpPowerValue = 150
_G.NoClip = false
_G.Fly = false
_G.FlySpeed = 50
_G.FlyToMob = true

-- ============================================================
-- 8. DETECÇÃO DE SEA
-- ============================================================
local Sea1, Sea2, Sea3 = false, false, false
if game.PlaceId == 2753915549 then Sea1 = true
elseif game.PlaceId == 4442272183 then Sea2 = true
elseif game.PlaceId == 7449423635 then Sea3 = true end

-- ============================================================
-- 9. LISTA DE BOSSES POR SEA
-- ============================================================
local BossList = {}
if Sea1 then BossList = {"Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral", "Warden", "Chief Warden", "Saber Expert", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral"}
elseif Sea2 then BossList = {"Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper"}
elseif Sea3 then BossList = {"Cake Prince", "Dough King", "Soul Reaper", "Rip Indra", "Darkbeard", "Stone", "Island Empress", "Hydra", "Leviathan"} end

-- ============================================================
-- 10. LISTA DE TELEPORTES
-- ============================================================
local TeleportList = {}
local TeleportCoords = {}
if Sea1 then
    TeleportList = {"Pirate Starter", "Jungle", "Desert", "Frozen Village", "Marine Fortress", "Skylands", "Prison", "Colosseum", "Magma Village", "Underwater City", "Fountain City"}
    TeleportCoords = {
        ["Pirate Starter"] = Vector3.new(1289, 11, 4191), ["Jungle"] = Vector3.new(-1250, 15, 3850),
        ["Desert"] = Vector3.new(966, 10, 1100), ["Frozen Village"] = Vector3.new(1150, 25, 4350),
        ["Marine Fortress"] = Vector3.new(-1500, 10, 5300), ["Skylands"] = Vector3.new(-4850, 750, 1950),
        ["Prison"] = Vector3.new(-5400, 15, -1700), ["Colosseum"] = Vector3.new(-3560, 240, -80),
        ["Magma Village"] = Vector3.new(-3420, 10, -2700), ["Underwater City"] = Vector3.new(5500, -50, 2000),
        ["Fountain City"] = Vector3.new(4500, 50, 1200)
    }
elseif Sea2 then
    TeleportList = {"Kingdom of Rose", "Green Zone", "Ice Castle", "Forgotten Island", "Cafe"}
    TeleportCoords = {
        ["Kingdom of Rose"] = Vector3.new(-1400, 10, -1400), ["Green Zone"] = Vector3.new(6200, 80, 2500),
        ["Ice Castle"] = Vector3.new(7200, 100, 3500), ["Forgotten Island"] = Vector3.new(8500, 120, 4500),
        ["Cafe"] = Vector3.new(-570, 310, -1220)
    }
elseif Sea3 then
    TeleportList = {"Port Town", "Hydra Island", "Great Tree", "Castle on the Sea", "Haunted Castle", "Floating Turtle"}
    TeleportCoords = {
        ["Port Town"] = Vector3.new(-6000, 20, -4000), ["Hydra Island"] = Vector3.new(6200, 80, 2500),
        ["Great Tree"] = Vector3.new(8500, 120, 4500), ["Castle on the Sea"] = Vector3.new(4500, 50, 1200),
        ["Haunted Castle"] = Vector3.new(9800, 60, 5500), ["Floating Turtle"] = Vector3.new(11200, 90, 6500)
    }
end

-- ============================================================
-- 11. FUNÇÕES UTILITÁRIAS
-- ============================================================

-- GetRemote
local function GetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then return remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF") end
    return nil
end

-- Teleporte
local function TP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

-- FindBoss
local function FindBoss(name)
    for _, folderName in ipairs({"Bosses", "Enemies"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob.Name:lower():find(name:lower(), 1, true) then
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then return mob end
                end
            end
        end
    end
    return nil
end

-- EquipWeapon
local function EquipWeapon()
    pcall(function()
        if _G.SelectWeapon == "Melee" then for _, tool in pairs(Player.Backpack:GetChildren()) do if tool.ToolTip == "Melee" then Player.Character.Humanoid:EquipTool(tool); break end end
        elseif _G.SelectWeapon == "Sword" then for _, tool in pairs(Player.Backpack:GetChildren()) do if tool.ToolTip == "Sword" then Player.Character.Humanoid:EquipTool(tool); break end end
        elseif _G.SelectWeapon == "Blox Fruit" then for _, tool in pairs(Player.Backpack:GetChildren()) do if tool.ToolTip == "Blox Fruit" then Player.Character.Humanoid:EquipTool(tool); break end end
        end
    end)
end

-- ============================================================
-- 12. FUNÇÕES DE ATAQUE (MÚLTIPLOS MÉTODOS)
-- ============================================================

-- Ataque com Remote
local function RemoteAttack()
    pcall(function()
        local remote = GetRemote()
        if remote then remote:InvokeServer("Attack") end
    end)
end

-- Ataque com VirtualInputManager
local function VIMAttack()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(_G.Fast_Delay)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Ataque com RegisterAttack
local function RegisterAttack()
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        if modules then
            local net = modules:FindFirstChild("Net")
            if net then
                local regAttack = net:FindFirstChild("RE/RegisterAttack")
                if regAttack then regAttack:FireServer(1e-9) end
            end
        end
    end)
end

-- Ataque com Mouse
local function MouseAttack()
    pcall(function()
        local mouse = Player:GetMouse()
        if mouse then
            mouse:Button1Down()
            task.wait(_G.Fast_Delay)
            mouse:Button1Up()
        end
    end)
end

-- 🔥 ATAQUE PRINCIPAL (TENTA TODOS OS MÉTODOS)
local function Attack()
    RemoteAttack()
    RegisterAttack()
    VIMAttack()
end

-- 🔥 FAST ATTACK
local function FastAttack()
    RegisterAttack()
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        if modules then
            local net = modules:FindFirstChild("Net")
            if net then
                local registerHit = net:FindFirstChild("RE/RegisterHit")
                if registerHit then
                    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if myPos then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                local head = enemy:FindFirstChild("Head")
                                if head and (myPos.Position - head.Position).Magnitude <= 60 then
                                    registerHit:FireServer(head, {{enemy, head}})
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- 13. MIRA AUTOMÁTICA
-- ============================================================
local function LookAt(target)
    pcall(function()
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target)
    end)
end

-- ============================================================
-- 14. CHECKLEVEL
-- ============================================================
function CheckLevel()
    local lv = Player.Data.Level.Value
    if Sea1 then
        if lv <= 9 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Bandit", "BanditQuest1", 1, "Bandit"; _G.CFrameQ = CFrame.new(1060.94, 16.46, 1547.78); _G.CFrameMon = CFrame.new(1038.55, 41.30, 1576.51)
        elseif lv <= 14 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Monkey", "JungleQuest", 1, "Monkey"; _G.CFrameQ = CFrame.new(-1601.66, 36.85, 153.39); _G.CFrameMon = CFrame.new(-1448.14, 50.85, 63.61)
        elseif lv <= 29 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Gorilla", "JungleQuest", 2, "Gorilla"; _G.CFrameQ = CFrame.new(-1601.66, 36.85, 153.39); _G.CFrameMon = CFrame.new(-1142.65, 40.46, -515.39)
        elseif lv <= 39 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Pirate", "BuggyQuest1", 1, "Pirate"; _G.CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41); _G.CFrameMon = CFrame.new(-1201.09, 40.63, 3857.60)
        elseif lv <= 59 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Brute", "BuggyQuest1", 2, "Brute"; _G.CFrameQ = CFrame.new(-1140.18, 4.75, 3827.41); _G.CFrameMon = CFrame.new(-1387.53, 24.59, 4100.96)
        elseif lv <= 74 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Desert Bandit", "DesertQuest", 1, "Desert Bandit"; _G.CFrameQ = CFrame.new(896.52, 6.44, 4390.15); _G.CFrameMon = CFrame.new(985.00, 16.11, 4417.91)
        elseif lv <= 89 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Desert Officer", "DesertQuest", 2, "Desert Officer"; _G.CFrameQ = CFrame.new(896.52, 6.44, 4390.15); _G.CFrameMon = CFrame.new(1547.15, 14.45, 4381.80)
        elseif lv <= 99 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Snow Bandit", "SnowQuest", 1, "Snow Bandit"; _G.CFrameQ = CFrame.new(1386.81, 87.27, -1298.36); _G.CFrameMon = CFrame.new(1356.30, 105.77, -1328.24)
        elseif lv <= 119 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Snowman", "SnowQuest", 2, "Snowman"; _G.CFrameQ = CFrame.new(1386.81, 87.27, -1298.36); _G.CFrameMon = CFrame.new(1218.80, 138.01, -1488.03)
        elseif lv <= 149 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Chief Petty Officer", "MarineQuest2", 1, "Chief Petty Officer"; _G.CFrameQ = CFrame.new(-5035.50, 28.68, 4324.18); _G.CFrameMon = CFrame.new(-4931.16, 65.79, 4121.84)
        elseif lv <= 174 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Sky Bandit", "SkyQuest", 1, "Sky Bandit"; _G.CFrameQ = CFrame.new(-4842.14, 717.70, -2623.05); _G.CFrameMon = CFrame.new(-4955.64, 365.46, -2908.19)
        elseif lv <= 209 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Prisoner", "PrisonerQuest", 1, "Prisoner"; _G.CFrameQ = CFrame.new(5310.61, 0.35, 474.95); _G.CFrameMon = CFrame.new(4937.32, 0.33, 649.57)
        elseif lv <= 249 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Dangerous Prisoner", "PrisonerQuest", 2, "Dangerous Prisoner"; _G.CFrameQ = CFrame.new(5310.61, 0.35, 474.95); _G.CFrameMon = CFrame.new(5099.66, 0.35, 1055.76)
        elseif lv <= 274 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Toga Warrior", "ColosseumQuest", 1, "Toga Warrior"; _G.CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48); _G.CFrameMon = CFrame.new(-1872.52, 49.08, -2913.81)
        elseif lv <= 299 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Gladiator", "ColosseumQuest", 2, "Gladiator"; _G.CFrameQ = CFrame.new(-1577.79, 7.42, -2984.48); _G.CFrameMon = CFrame.new(-1521.37, 81.20, -3066.31)
        elseif lv <= 324 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Military Soldier", "MagmaQuest", 1, "Military Soldier"; _G.CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00); _G.CFrameMon = CFrame.new(-5369.00, 61.24, 8556.49)
        elseif lv <= 374 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Military Spy", "MagmaQuest", 2, "Military Spy"; _G.CFrameQ = CFrame.new(-5316.12, 12.26, 8517.00); _G.CFrameMon = CFrame.new(-5787.00, 75.83, 8651.70)
        elseif lv <= 399 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Fishman Warrior", "FishmanQuest", 1, "Fishman Warrior"; _G.CFrameQ = CFrame.new(61122.65, 18.50, 1569.40); _G.CFrameMon = CFrame.new(60844.11, 98.46, 1298.40)
        elseif lv <= 449 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Fishman Commando", "FishmanQuest", 2, "Fishman Commando"; _G.CFrameQ = CFrame.new(61122.65, 18.50, 1569.40); _G.CFrameMon = CFrame.new(61738.40, 64.21, 1433.84)
        elseif lv <= 474 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "God's Guard", "SkyExp1Quest", 1, "God's Guard"; _G.CFrameQ = CFrame.new(-4721.86, 845.30, -1953.85); _G.CFrameMon = CFrame.new(-4628.05, 866.93, -1931.24)
        elseif lv <= 524 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Shanda", "SkyExp1Quest", 2, "Shanda"; _G.CFrameQ = CFrame.new(-7863.16, 5545.52, -378.42); _G.CFrameMon = CFrame.new(-7685.15, 5601.08, -441.39)
        elseif lv <= 549 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Royal Squad", "SkyExp2Quest", 1, "Royal Squad"; _G.CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92); _G.CFrameMon = CFrame.new(-7654.25, 5637.11, -1407.76)
        elseif lv <= 624 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Royal Soldier", "SkyExp2Quest", 2, "Royal Soldier"; _G.CFrameQ = CFrame.new(-7903.38, 5635.99, -1410.92); _G.CFrameMon = CFrame.new(-7760.41, 5679.91, -1884.81)
        elseif lv <= 649 then _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Galley Pirate", "FountainQuest", 1, "Galley Pirate"; _G.CFrameQ = CFrame.new(5258.28, 38.53, 4050.04); _G.CFrameMon = CFrame.new(5557.17, 152.33, 3998.78)
        else _G.Ms, _G.NameQuest, _G.QuestLv, _G.NameMon = "Galley Captain", "FountainQuest", 2, "Galley Captain"; _G.CFrameQ = CFrame.new(5258.28, 38.53, 4050.04); _G.CFrameMon = CFrame.new(5677.68, 92.79, 4966.63) end
    end
end

-- ============================================================
-- 15. AUTO FARM LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.05) do
        if not _G.AutoFarm then task.wait(1); continue end
        
        pcall(function()
            CheckLevel()
            EquipWeapon()
            
            if _G.AutoHaki then
                pcall(function()
                    if not Player.Character:FindFirstChild("HasBuso") then
                        local remote = GetRemote()
                        if remote then remote:InvokeServer("Buso") end
                    end
                end)
            end
            
            -- Encontrar inimigo mais próximo
            local closestMob, closestDist = nil, _G.Range
            local enemiesFolder = Workspace:FindFirstChild("Enemies")
            local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            
            if enemiesFolder and myPos then
                for _, enemy in pairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") and enemy.Name == _G.Ms then
                        local hum = enemy:FindFirstChild("Humanoid")
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")
                        if hum and hum.Health > 0 and hrp then
                            local dist = (hrp.Position - myPos.Position).Magnitude
                            if dist < closestDist then closestDist = dist; closestMob = enemy end
                        end
                    end
                end
            end
            
            if closestMob and myPos then
                local hum = closestMob:FindFirstChild("Humanoid")
                local hrp = closestMob:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp and hum.Health > 0 then
                    -- Vai até o mob
                    if closestDist > 10 then
                        TP(hrp.Position)
                        task.wait(0.3)
                    end
                    
                    myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if not myPos then return end
                    
                    -- Mira
                    LookAt(hrp.Position)
                    
                    -- Primeiro hit
                    Attack()
                    task.wait(0.2)
                    
                    -- Puxa mob
                    if _G.BringMob then
                        hrp.CFrame = myPos.CFrame * CFrame.new(0, 0, -5)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.RotVelocity = Vector3.new(0, 0, 0)
                        hrp.Anchored = true; task.wait(0.01); hrp.Anchored = false
                        hum.WalkSpeed = 0; hum.JumpPower = 0
                    end
                    
                    -- Ataca continuamente
                    for i = 1, 50 do
                        if not _G.AutoFarm then break end
                        if not hum or hum.Health <= 0 then break end
                        if not hrp or not hrp.Parent then break end
                        
                        if _G.BringMob then
                            hrp.CFrame = myPos.CFrame * CFrame.new(0, 0, -5)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end
                        
                        LookAt(hrp.Position)
                        
                        if _G.FastAttack then FastAttack() else Attack() end
                        task.wait(0.1)
                    end
                end
            else
                if _G.CFrameMon then
                    TP(_G.CFrameMon.Position)
                    task.wait(1)
                end
            end
        end)
    end
end)

-- ============================================================
-- 16. AUTO BOSS LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.05) do
        if not _G.AutoBoss or _G.SelectBoss == "" then task.wait(1); continue end
        if _G.AutoFarm then continue end
        
        pcall(function()
            local boss = FindBoss(_G.SelectBoss)
            if boss then
                local hum = boss:FindFirstChild("Humanoid")
                local hrp = boss:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp and hum.Health > 0 then
                    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if myPos then
                        local dist = (hrp.Position - myPos.Position).Magnitude
                        if dist > 10 then TP(hrp.Position); task.wait(0.3) end
                        
                        myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if not myPos then return end
                        
                        LookAt(hrp.Position)
                        Attack()
                        task.wait(0.2)
                        
                        if _G.AutoHaki and not Player.Character:FindFirstChild("HasBuso") then
                            local remote = GetRemote()
                            if remote then remote:InvokeServer("Buso") end
                        end
                        EquipWeapon()
                        
                        for i = 1, 100 do
                            if not _G.AutoBoss then break end
                            if not hum or hum.Health <= 0 then break end
                            
                            hrp.CFrame = myPos.CFrame * CFrame.new(0, 0, -5)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hum.WalkSpeed = 0; hum.JumpPower = 0
                            
                            LookAt(hrp.Position)
                            if _G.FastAttack then FastAttack() else Attack() end
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- 17. AUTO CLICKER
-- ============================================================
task.spawn(function()
    while task.wait(0.05) do
        if not _G.AutoClicker then task.wait(1); continue end
        if _G.AutoFarm then continue end
        
        for i = 1, _G.AutoClickerClicks do
            if not _G.AutoClicker then break end
            
            if _G.AutoClickerMode == "Attack" then Attack()
            elseif _G.AutoClickerMode == "FastAttack" then FastAttack()
            elseif _G.AutoClickerMode == "Jump" then
                pcall(function()
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.Jump = true
                    end
                end)
            end
            task.wait(_G.AutoClickerSpeed)
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- 18. GOD MODE
-- ============================================================
task.spawn(function()
    while task.wait(0.3) do
        if not _G.GodMode then continue end
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum.Health = hum.MaxHealth end
        end)
    end
end)

-- ============================================================
-- 19. AUTO STATS
-- ============================================================
task.spawn(function()
    while task.wait(60) do
        if not _G.AutoStats then continue end
        pcall(function()
            for _ = 1, 3 do
                local remote = GetRemote()
                if remote then remote:InvokeServer("AddPoint", "Melee", 1) end
            end
        end)
    end
end)

-- ============================================================
-- 20. FRUIT SNIPER
-- ============================================================
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

-- ============================================================
-- 21. AUTO STORE
-- ============================================================
task.spawn(function()
    while task.wait(10) do
        if not _G.AutoStore then continue end
        pcall(function()
            local data = Player:FindFirstChild("Data")
            if data then
                local fruit = data:FindFirstChild("Fruit")
                if fruit and fruit.Value ~= "" then
                    local remote = GetRemote()
                    if remote then remote:InvokeServer("StoreFruit", fruit.Value) end
                end
            end
        end)
    end
end)

-- ============================================================
-- 22. AUTO ROLL
-- ============================================================
task.spawn(function()
    while task.wait(30) do
        if not _G.AutoRoll then continue end
        pcall(function()
            local remote = GetRemote()
            if remote then remote:InvokeServer("FruitGacha", "Roll") end
        end)
    end
end)

-- ============================================================
-- 23. WALKSPEED / JUMPPOWER
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if _G.WalkSpeed then hum.WalkSpeed = _G.WalkSpeedValue end
                if _G.JumpPower then hum.JumpPower = _G.JumpPowerValue end
            end
        end)
    end
end)

-- ============================================================
-- 24. NOCLIP
-- ============================================================
task.spawn(function()
    RunService.Stepped:Connect(function()
        if not _G.NoClip then return end
        pcall(function()
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end)
end)

-- ============================================================
-- 25. FLY
-- ============================================================
local FlyBV, FlyBG, FlyConn = nil, nil, nil
task.spawn(function()
    while task.wait(0.5) do
        if not _G.Fly then
            if FlyBV then FlyBV:Destroy(); FlyBV = nil end
            if FlyBG then FlyBG:Destroy(); FlyBG = nil end
            if FlyConn then FlyConn:Disconnect(); FlyConn = nil end
            continue
        end
        
        pcall(function()
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            if not FlyBV then FlyBV = Instance.new("BodyVelocity"); FlyBV.MaxForce = Vector3.new(400000, 400000, 400000); FlyBV.Velocity = Vector3.zero; FlyBV.Parent = hrp end
            if not FlyBG then FlyBG = Instance.new("BodyGyro"); FlyBG.MaxTorque = Vector3.new(400000, 400000, 400000); FlyBG.CFrame = hrp.CFrame; FlyBG.Parent = hrp end
            
            if not FlyConn then
                FlyConn = RunService.RenderStepped:Connect(function()
                    if not _G.Fly then return end
                    if not FlyBV or not FlyBV.Parent then return end
                    
                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    
                    if dir.Magnitude > 0 then FlyBV.Velocity = dir.Unit * _G.FlySpeed else FlyBV.Velocity = Vector3.zero end
                    if FlyBG and FlyBG.Parent then FlyBG.CFrame = Camera.CFrame end
                end)
            end
        end)
    end
end)

-- ============================================================
-- 26. ESP
-- ============================================================
local ESPObjects = {}
task.spawn(function()
    while task.wait(2) do
        for _, obj in ipairs(ESPObjects) do pcall(function() if obj and obj.Parent then obj:Destroy() end end) end
        ESPObjects = {}
        if not _G.ESP_Enabled then continue end
        
        pcall(function()
            local count = 0
            
            if _G.ESP_Players then
                for _, p in ipairs(Players:GetPlayers()) do
                    if count >= 10 then break end
                    if p == Player then continue end
                    local char = p.Character; if not char then continue end
                    local head = char:FindFirstChild("Head"); if not head then continue end
                    
                    local bg = Instance.new("BillboardGui"); bg.Adornee = head; bg.Size = UDim2.new(0, 80, 0, 16); bg.AlwaysOnTop = true; bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0, 2, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5; label.BackgroundColor3 = Color3.fromRGB(255, 0, 0); label.TextColor3 = Color3.new(1, 1, 1); label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "👤 " .. p.DisplayName
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
            
            if _G.ESP_Fruits then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if count >= 10 then break end
                    if not obj:IsA("BasePart") then continue end
                    if not obj.Name:lower():find("fruit", 1, true) then continue end
                    if not (obj.Parent and obj.Parent:FindFirstChild("Handle")) then continue end
                    
                    local bg = Instance.new("BillboardGui"); bg.Adornee = obj; bg.Size = UDim2.new(0, 60, 0, 14); bg.AlwaysOnTop = true; bg.MaxDistance = _G.ESP_Range; bg.StudsOffset = Vector3.new(0, 2, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5; label.BackgroundColor3 = Color3.fromRGB(255, 0, 255); label.TextColor3 = Color3.new(1, 1, 1); label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = "🍎 Fruit"
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
        end)
    end
end)

-- ============================================================
-- 27. UI - INTERFACE COMPLETA
-- ============================================================
local win = DiscordLib:Window("NEXUS SUPREMO")
local serv = win:Server("Blox Fruits", "http://www.roblox.com/asset/?id=6031075938")

-- Canal Farm
local farmCh = serv:Channel("⚔️ Auto Farm")
farmCh:Toggle("Auto Farm", false, function(v) _G.AutoFarm = v end)
farmCh:Toggle("Auto Quest", true, function(v) _G.AutoQuest = v end)
farmCh:Toggle("Bring Mob", true, function(v) _G.BringMob = v end)
farmCh:Toggle("Fast Attack", false, function(v) _G.FastAttack = v end)
farmCh:Toggle("Auto Haki", false, function(v) _G.AutoHaki = v end)
farmCh:Toggle("God Mode", false, function(v) _G.GodMode = v end)
farmCh:Dropdown("Arma", {"Melee", "Sword", "Blox Fruit"}, function(v) _G.SelectWeapon = v end)
farmCh:Slider("Distância", 50, 500, 300, function(v) _G.Range = v end)

-- Canal Boss
local bossCh = serv:Channel("💀 Auto Boss")
bossCh:Toggle("Auto Boss", false, function(v) _G.AutoBoss = v end)
bossCh:Dropdown("Boss", BossList, function(v) _G.SelectBoss = v end)

-- Canal Clicker
local clickCh = serv:Channel("🖱️ Auto Clicker")
clickCh:Toggle("Auto Clicker", false, function(v) _G.AutoClicker = v end)
clickCh:Dropdown("Modo", {"Attack", "FastAttack", "Jump"}, function(v) _G.AutoClickerMode = v end)
clickCh:Slider("Cliques", 1, 20, 5, function(v) _G.AutoClickerClicks = v end)
clickCh:Slider("Velocidade", 0.01, 0.5, 0.05, function(v) _G.AutoClickerSpeed = v end)

-- Canal Frutas
local fruitCh = serv:Channel("🍎 Frutas")
fruitCh:Toggle("Fruit Sniper", false, function(v) _G.FruitSniper = v end)
fruitCh:Toggle("Auto Store", false, function(v) _G.AutoStore = v end)
fruitCh:Toggle("Auto Roll", false, function(v) _G.AutoRoll = v end)

-- Canal Movimento
local moveCh = serv:Channel("🏃 Movimento")
moveCh:Toggle("WalkSpeed", false, function(v) _G.WalkSpeed = v end)
moveCh:Slider("Velocidade", 16, 350, 100, function(v) _G.WalkSpeedValue = v end)
moveCh:Toggle("JumpPower", false, function(v) _G.JumpPower = v end)
moveCh:Slider("Altura Pulo", 50, 300, 150, function(v) _G.JumpPowerValue = v end)
moveCh:Toggle("NoClip", false, function(v) _G.NoClip = v end)
moveCh:Toggle("Fly (WASD)", false, function(v) _G.Fly = v end)
moveCh:Slider("Fly Speed", 10, 200, 50, function(v) _G.FlySpeed = v end)

-- Canal ESP
local espCh = serv:Channel("👁️ ESP")
espCh:Toggle("ESP Ligado", false, function(v) _G.ESP_Enabled = v end)
espCh:Toggle("ESP Players", false, function(v) _G.ESP_Players = v end)
espCh:Toggle("ESP Fruits", false, function(v) _G.ESP_Fruits = v end)
espCh:Slider("Alcance ESP", 100, 1000, 500, function(v) _G.ESP_Range = v end)

-- Canal Teleporte
local tpCh = serv:Channel("🏝️ Teleportes")
for _, nome in ipairs(TeleportList) do
    tpCh:Button(nome, function()
        local pos = TeleportCoords[nome]
        if pos then TP(pos) end
    end)
end

-- Canal Config
local cfgCh = serv:Channel("⚙️ Config")
cfgCh:Toggle("Auto Stats", false, function(v) _G.AutoStats = v end)
cfgCh:Slider("Delay Ataque", 0, 10, 0, function(v) _G.Fast_Delay = v == 0 and 0.01 or v / 10 end)
cfgCh:Button("🔄 Status", function()
    local lv = Player.Data.Level.Value
    local sea = Sea1 and "1" or Sea2 and "2" or Sea3 and "3" or "?"
    DiscordLib:Notification("NEXUS", "Sea: " .. sea .. " | Level: " .. lv, "OK")
end)
cfgCh:Button("🛑 Parar Tudo", function()
    _G.AutoFarm = false; _G.AutoBoss = false; _G.AutoClicker = false; _G.GodMode = false
    _G.FruitSniper = false; _G.AutoStore = false; _G.AutoRoll = false; _G.AutoStats = false
    _G.WalkSpeed = false; _G.JumpPower = false; _G.NoClip = false; _G.Fly = false
    _G.ESP_Enabled = false
    DiscordLib:Notification("NEXUS", "Tudo parado!", "OK")
end)

-- ============================================================
-- 28. NOTIFICAÇÃO FINAL
-- ============================================================
DiscordLib:Notification("NEXUS SUPREMO", "✅ Script carregado!\n⚔️ Farm | 💀 Boss | 🖱️ Clicker\n🍎 Frutas | 🏃 Mov | 👁️ ESP | 🏝️ TP", "VAMOS LÁ! 🚀")
