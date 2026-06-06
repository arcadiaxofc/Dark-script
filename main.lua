-- // ╔══════════════════════════════════════════════════════════╗
-- // ║              NEXUS ULTIMATE - BLOCOS FRUTAS              ║
-- // ║         Script Completo com NexusUI                     ║
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
        Title = "NEXUS", Text = "Este script só funciona no Blox Fruits!", Duration = 5
    })
    return
end

-- // ==================== [ CARREGAMENTO DA NEXUSUI ] ====================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nexus-onix/nexus-hub/main/ui.lua"))()

-- // ==================== [ SERVIÇOS ] ====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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

-- // ==================== [ VARIÁVEIS GLOBAIS ] ====================
_G.AutoLevel = false
_G.Fast_Delay = 0.001
_G.StopTween = false
_G.CancelTween2 = false
_G.Clip2 = false

local ChooseWeapon = "Melee"
local SelectWeapon = ""
local bringmob = false
local FarmPos = nil
local MonFarm = ""

local Sea1 = false
local Sea2 = false
local Sea3 = false

local v19 = game.PlaceId
if v19 == 2753915549 then Sea1 = true
elseif v19 == 4442272183 then Sea2 = true
elseif v19 == 7449423635 then Sea3 = true end

-- // ==================== [ DADOS DO JOGO ] ====================
function CheckLevel()
    local v197 = Player.Data.Level.Value
    if Sea1 then
        if v197 == 1 or v197 <= 9 then
            Ms = "Bandit" NameQuest = "BanditQuest1" QuestLv = 1 NameMon = "Bandit"
            CFrameQ = CFrame.new(1060.9383544922, 16.455066680908, 1547.7841796875)
            CFrameMon = CFrame.new(1038.5533447266, 41.296249389648, 1576.5098876953)
        elseif v197 == 10 or v197 <= 14 then
            Ms = "Monkey" NameQuest = "JungleQuest" QuestLv = 1 NameMon = "Monkey"
            CFrameQ = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102)
            CFrameMon = CFrame.new(-1448.1446533203, 50.851993560791, 63.60718536377)
        elseif v197 == 15 or v197 <= 29 then
            Ms = "Gorilla" NameQuest = "JungleQuest" QuestLv = 2 NameMon = "Gorilla"
            CFrameQ = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102)
            CFrameMon = CFrame.new(-1142.6488037109, 40.462348937988, -515.39227294922)
        elseif v197 == 30 or v197 <= 39 then
            Ms = "Pirate" NameQuest = "BuggyQuest1" QuestLv = 1 NameMon = "Pirate"
            CFrameQ = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188)
            CFrameMon = CFrame.new(-1201.0881347656, 40.628940582275, 3857.5966796875)
        elseif v197 == 40 or v197 <= 59 then
            Ms = "Brute" NameQuest = "BuggyQuest1" QuestLv = 2 NameMon = "Brute"
            CFrameQ = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188)
            CFrameMon = CFrame.new(-1387.5324707031, 24.592035293579, 4100.9575195313)
        elseif v197 == 60 or v197 <= 74 then
            Ms = "Desert Bandit" NameQuest = "DesertQuest" QuestLv = 1 NameMon = "Desert Bandit"
            CFrameQ = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625)
            CFrameMon = CFrame.new(984.99896240234, 16.109552383423, 4417.91015625)
        elseif v197 == 75 or v197 <= 89 then
            Ms = "Desert Officer" NameQuest = "DesertQuest" QuestLv = 2 NameMon = "Desert Officer"
            CFrameQ = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625)
            CFrameMon = CFrame.new(1547.1510009766, 14.452038764954, 4381.8002929688)
        elseif v197 == 90 or v197 <= 99 then
            Ms = "Snow Bandit" NameQuest = "SnowQuest" QuestLv = 1 NameMon = "Snow Bandit"
            CFrameQ = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156)
            CFrameMon = CFrame.new(1356.3028564453, 105.76865386963, -1328.2418212891)
        elseif v197 == 100 or v197 <= 119 then
            Ms = "Snowman" NameQuest = "SnowQuest" QuestLv = 2 NameMon = "Snowman"
            CFrameQ = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156)
            CFrameMon = CFrame.new(1218.7956542969, 138.01184082031, -1488.0262451172)
        elseif v197 == 120 or v197 <= 149 then
            Ms = "Chief Petty Officer" NameQuest = "MarineQuest2" QuestLv = 1 NameMon = "Chief Petty Officer"
            CFrameQ = CFrame.new(-5035.49609375, 28.677835464478, 4324.1840820313)
            CFrameMon = CFrame.new(-4931.1552734375, 65.793113708496, 4121.8393554688)
        elseif v197 == 150 or v197 <= 174 then
            Ms = "Sky Bandit" NameQuest = "SkyQuest" QuestLv = 1 NameMon = "Sky Bandit"
            CFrameQ = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438)
            CFrameMon = CFrame.new(-4955.6411132813, 365.46365356445, -2908.1865234375)
        elseif v197 == 175 or v197 <= 189 then
            Ms = "Dark Master" NameQuest = "SkyQuest" QuestLv = 2 NameMon = "Dark Master"
            CFrameQ = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438)
            CFrameMon = CFrame.new(-5148.1650390625, 439.04571533203, -2332.9611816406)
        elseif v197 == 190 or v197 <= 209 then
            Ms = "Prisoner" NameQuest = "PrisonerQuest" QuestLv = 1 NameMon = "Prisoner"
            CFrameQ = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, 0.0175017118)
            CFrameMon = CFrame.new(4937.31885, 0.332031399, 649.574524, 0.694649816, 0, -0.719348073, 0, 1, 0, 0.719348073, 0, 0.694649816)
        elseif v197 == 210 or v197 <= 249 then
            Ms = "Dangerous Prisoner" NameQuest = "PrisonerQuest" QuestLv = 2 NameMon = "Dangerous Prisoner"
            CFrameQ = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, 0.0175017118)
            CFrameMon = CFrame.new(5099.6626, 0.351562679, 1055.7583, 0.898906827, 0, -0.438139856, 0, 1, 0, 0.438139856, 0, 0.898906827)
        elseif v197 == 250 or v197 <= 274 then
            Ms = "Toga Warrior" NameQuest = "ColosseumQuest" QuestLv = 1 NameMon = "Toga Warrior"
            CFrameQ = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188)
            CFrameMon = CFrame.new(-1872.5166015625, 49.080215454102, -2913.810546875)
        elseif v197 == 275 or v197 <= 299 then
            Ms = "Gladiator" NameQuest = "ColosseumQuest" QuestLv = 2 NameMon = "Gladiator"
            CFrameQ = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188)
            CFrameMon = CFrame.new(-1521.3740234375, 81.203170776367, -3066.3139648438)
        elseif v197 == 300 or v197 <= 324 then
            Ms = "Military Soldier" NameQuest = "MagmaQuest" QuestLv = 1 NameMon = "Military Soldier"
            CFrameQ = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625)
            CFrameMon = CFrame.new(-5369.0004882813, 61.24352645874, 8556.4921875)
        elseif v197 == 325 or v197 <= 374 then
            Ms = "Military Spy" NameQuest = "MagmaQuest" QuestLv = 2 NameMon = "Military Spy"
            CFrameQ = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625)
            CFrameMon = CFrame.new(-5787.00293, 75.8262634, 8651.69922, 0.838590562, 0, -0.544762194, 0, 1, 0, 0.544762194, 0, 0.838590562)
        elseif v197 == 375 or v197 <= 399 then
            Ms = "Fishman Warrior" NameQuest = "FishmanQuest" QuestLv = 1 NameMon = "Fishman Warrior"
            CFrameQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            CFrameMon = CFrame.new(60844.10546875, 98.462875366211, 1298.3985595703)
            if _G.AutoLevel and (CFrameMon.Position - Player.Character.HumanoidRootPart.Position).Magnitude > 3000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
            end
        elseif v197 == 400 or v197 <= 449 then
            Ms = "Fishman Commando" NameQuest = "FishmanQuest" QuestLv = 2 NameMon = "Fishman Commando"
            CFrameQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            CFrameMon = CFrame.new(61738.3984375, 64.207321166992, 1433.8375244141)
            if _G.AutoLevel and (CFrameMon.Position - Player.Character.HumanoidRootPart.Position).Magnitude > 3000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
            end
        elseif v197 == 450 or v197 <= 474 then
            Ms = "God's Guard" NameQuest = "SkyExp1Quest" QuestLv = 1 NameMon = "God's Guard"
            CFrameQ = CFrame.new(-4721.8603515625, 845.30297851563, -1953.8489990234)
            CFrameMon = CFrame.new(-4628.0498046875, 866.92877197266, -1931.2352294922)
            if _G.AutoLevel and (CFrameMon.Position - Player.Character.HumanoidRootPart.Position).Magnitude > 3000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.82275, 872.54248, -1667.55688))
            end
        elseif v197 == 475 or v197 <= 524 then
            Ms = "Shanda" NameQuest = "SkyExp1Quest" QuestLv = 2 NameMon = "Shanda"
            CFrameQ = CFrame.new(-7863.1596679688, 5545.5190429688, -378.42266845703)
            CFrameMon = CFrame.new(-7685.1474609375, 5601.0751953125, -441.38876342773)
            if _G.AutoLevel and (CFrameMon.Position - Player.Character.HumanoidRootPart.Position).Magnitude > 3000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
            end
        elseif v197 == 525 or v197 <= 549 then
            Ms = "Royal Squad" NameQuest = "SkyExp2Quest" QuestLv = 1 NameMon = "Royal Squad"
            CFrameQ = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125)
            CFrameMon = CFrame.new(-7654.2514648438, 5637.1079101563, -1407.7550048828)
        elseif v197 == 550 or v197 <= 624 then
            Ms = "Royal Soldier" NameQuest = "SkyExp2Quest" QuestLv = 2 NameMon = "Royal Soldier"
            CFrameQ = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125)
            CFrameMon = CFrame.new(-7760.4106445313, 5679.9077148438, -1884.8112792969)
        elseif v197 == 625 or v197 <= 649 then
            Ms = "Galley Pirate" NameQuest = "FountainQuest" QuestLv = 1 NameMon = "Galley Pirate"
            CFrameQ = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875)
            CFrameMon = CFrame.new(5557.1684570313, 152.32717895508, 3998.7758789063)
        elseif v197 >= 650 then
            Ms = "Galley Captain" NameQuest = "FountainQuest" QuestLv = 2 NameMon = "Galley Captain"
            CFrameQ = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875)
            CFrameMon = CFrame.new(5677.6772460938, 92.786109924316, 4966.6323242188)
        end
    end
end

-- // ==================== [ FUNÇÕES UTILITÁRIAS ] ====================
function Tween(pos)
    local distance = (pos.Position - Player.Character.HumanoidRootPart.Position).Magnitude
    local speed = 350
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(Player.Character.HumanoidRootPart, tweenInfo, {CFrame = pos})
    tween:Play()
    if _G.StopTween then tween:Cancel() end
end

function BTPZ(pos)
    Player.Character.HumanoidRootPart.CFrame = pos
    task.wait()
    Player.Character.HumanoidRootPart.CFrame = pos
end

function EquipTool(name)
    if Player.Backpack:FindFirstChild(name) then
        local tool = Player.Backpack:FindFirstChild(name)
        task.wait()
        Player.Character.Humanoid:EquipTool(tool)
    end
end

function AutoHaki()
    if not Player.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

function AttackNoCoolDown()
    local enemies = {}
    local enemyList = Workspace.Enemies:GetChildren()
    local target = nil
    
    for _, enemy in ipairs(enemyList) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local head = enemy:FindFirstChild("Head")
            if head and (Player.Character.HumanoidRootPart.Position - head.Position).Magnitude <= 60 then
                table.insert(enemies, {enemy, head})
                target = head
            end
        end
    end
    
    local tool = nil
    for _, child in ipairs(Player.Character:GetChildren()) do
        if child:IsA("Tool") then tool = child break end
    end
    if not tool then return end
    
    if #enemies > 0 then
        pcall(function()
            local remotes = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
            local registerAttack = remotes:WaitForChild("RE/RegisterAttack")
            local registerHit = remotes:WaitForChild("RE/RegisterHit")
            registerAttack:FireServer(1e-9)
            registerHit:FireServer(target, enemies)
        end)
    end
end

-- // ==================== [ SISTEMA DE ARMAS ] ====================
task.spawn(function()
    while task.wait() do
        pcall(function()
            if ChooseWeapon == "Melee" then
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item.ToolTip == "Melee" then
                        SelectWeapon = item.Name
                    end
                end
            elseif ChooseWeapon == "Sword" then
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item.ToolTip == "Sword" then
                        SelectWeapon = item.Name
                    end
                end
            elseif ChooseWeapon == "Blox Fruit" then
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item.ToolTip == "Blox Fruit" then
                        SelectWeapon = item.Name
                    end
                end
            end
        end)
    end
end)

-- // ==================== [ AUTO FARM LOOP ] ====================
spawn(function()
    while task.wait() do
        if _G.AutoLevel then
            pcall(function()
                CheckLevel()
                
                local hasQuest = false
                pcall(function()
                    if Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:find(NameMon) then
                        hasQuest = true
                    end
                end)
                
                if not hasQuest then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                    Tween(CFrameQ)
                    if (CFrameQ.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                    end
                else
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                            if enemy.Name == Ms then
                                repeat
                                    task.wait(_G.Fast_Delay)
                                    AttackNoCoolDown()
                                    bringmob = true
                                    AutoHaki()
                                    EquipTool(SelectWeapon)
                                    enemy.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0)
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    enemy.HumanoidRootPart.Transparency = 1
                                    enemy.Humanoid.JumpPower = 0
                                    enemy.Humanoid.WalkSpeed = 0
                                    enemy.HumanoidRootPart.CanCollide = false
                                    FarmPos = enemy.HumanoidRootPart.CFrame
                                    MonFarm = enemy.Name
                                until not _G.AutoLevel or not enemy.Parent or enemy.Humanoid.Health <= 0
                                bringmob = false
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- // ==================== [ NOCLIP AUTOMÁTICO ] ====================
spawn(function()
    pcall(function()
        RunService.Stepped:Connect(function()
            if _G.AutoLevel then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end)

-- // ==================== [ BODY VELOCITY ANTI-KNOCKBACK ] ====================
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoLevel then
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

-- // ==================== [ ANTI-STUN ] ====================
task.spawn(function()
    if Player.Character:FindFirstChild("Stun") then
        Player.Character.Stun.Changed:Connect(function()
            pcall(function()
                if Player.Character:FindFirstChild("Stun") then
                    Player.Character.Stun.Value = 0
                end
            end)
        end)
    end
end)

-- // ==================== [ UI ] ====================
local Window = NexusUI:CreateWindow({
    Title = "NEXUS ULTIMATE",
    Subtitle = "Auto Farm Level + Boss + ESP",
    Width = 600,
    Height = 500
})

local Tabs = {
    Main = Window:AddTab("Main", "⚔️"),
    Settings = Window:AddTab("Settings", "⚙️"),
}

-- // ==================== [ ABA MAIN ] ====================
Tabs.Main:AddSection("Auto Farm Level")

Tabs.Main:AddToggle({
    Title = "Auto Farm Level",
    Desc = "Farm automático de level com bring mob",
    Default = false,
    Callback = function(v)
        _G.AutoLevel = v
        if not v then
            task.wait()
            _G.StopTween = true
            task.wait()
            _G.StopTween = false
        end
    end
})

Tabs.Main:AddSection("Configuração de Arma")

Tabs.Main:AddDropdown({
    Title = "Arma para Farm",
    Options = {"Melee", "Sword", "Blox Fruit"},
    Default = "Melee",
    Callback = function(v)
        ChooseWeapon = v
    end
})

Tabs.Main:AddSection("Velocidade")

Tabs.Main:AddSlider({
    Title = "Delay de Ataque",
    Min = 0,
    Max = 10,
    Default = 0,
    Callback = function(v)
        _G.Fast_Delay = v == 0 and 1e-9 or v / 10
    end
})

-- // ==================== [ ABA SETTINGS ] ====================
Tabs.Settings:AddSection("Informações")

Tabs.Settings:AddButton({
    Title = "🗺️ Ver Sea Atual",
    Callback = function()
        local sea = Sea1 and "1" or Sea2 and "2" or Sea3 and "3" or "?"
        local level = Player.Data.Level.Value
        NexusUI:Notify({
            Title = "NEXUS",
            Content = "Sea: " .. sea .. " | Level: " .. level,
            Duration = 4
        })
    end
})

Tabs.Settings:AddButton({
    Title = "🛑 Parar Tudo",
    Callback = function()
        _G.AutoLevel = false
        _G.StopTween = true
        task.wait(0.5)
        _G.StopTween = false
        NexusUI:Notify({
            Title = "NEXUS",
            Content = "Todos os sistemas parados!",
            Duration = 3
        })
    end
})

-- // ==================== [ NOTIFICAÇÃO INICIAL ] ====================
NexusUI:Notify({
    Title = "NEXUS ULTIMATE",
    Content = "Script carregado com sucesso!",
    Duration = 5
})

NexusUI:Notify({
    Title = "Comandos",
    Content = "Ative o Auto Farm Level na aba Main",
    Duration = 5
})
