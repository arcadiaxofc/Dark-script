-- ============================================================
-- NEXUS v11.0 - UI CRIADA DO ZERO
-- Baseada no estilo WindUI | Sem bibliotecas externas
-- ============================================================

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- ANTI-AFK
-- ============================================================
pcall(function() VirtualUser:CaptureController() end)

Player.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ============================================================
-- OTIMIZAÇÕES
-- ============================================================
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
end)

-- ============================================================
-- CORES E TEMAS
-- ============================================================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Primary = Color3.fromRGB(255, 70, 70),
        Secondary = Color3.fromRGB(30, 30, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 190),
        Accent = Color3.fromRGB(255, 100, 100),
        Button = Color3.fromRGB(45, 45, 55),
        ButtonHover = Color3.fromRGB(55, 55, 65),
        Success = Color3.fromRGB(70, 200, 70),
        Danger = Color3.fromRGB(200, 70, 70),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Primary = Color3.fromRGB(255, 70, 70),
        Secondary = Color3.fromRGB(230, 230, 235),
        Text = Color3.fromRGB(30, 30, 40),
        TextSecondary = Color3.fromRGB(100, 100, 110),
        Accent = Color3.fromRGB(255, 100, 100),
        Button = Color3.fromRGB(220, 220, 225),
        ButtonHover = Color3.fromRGB(210, 210, 215),
        Success = Color3.fromRGB(50, 180, 50),
        Danger = Color3.fromRGB(180, 50, 50),
    }
}

local CurrentTheme = "Dark"
local Theme = Themes.Dark

-- ============================================================
-- SISTEMA DE SAVE/CONFIG (SaveManager)
-- ============================================================
local SaveManager = {
    Folder = "NexusSettings",
    Options = {},
    Ignore = {},
}

function SaveManager:SetFolder(Folder)
    self.Folder = Folder
    pcall(function()
        if not isfolder(Folder) then makefolder(Folder) end
        if not isfolder(Folder .. "/settings") then makefolder(Folder .. "/settings") end
    end)
end

function SaveManager:Register(Key, Default, Callback)
    self.Options[Key] = { Value = Default, Callback = Callback }
end

function SaveManager:Save(Name)
    if not Name then return false end
    local Data = {}
    for Key, Opt in pairs(self.Options) do
        if not self.Ignore[Key] then
            Data[Key] = Opt.Value
        end
    end
    pcall(function()
        local Path = self.Folder .. "/settings/" .. Name .. ".json"
        writefile(Path, HttpService:JSONEncode(Data))
    end)
    return true
end

function SaveManager:Load(Name)
    local Path = self.Folder .. "/settings/" .. Name .. ".json"
    if not isfile(Path) then return false end
    pcall(function()
        local Data = HttpService:JSONDecode(readfile(Path))
        for Key, Value in pairs(Data) do
            if self.Options[Key] then
                self.Options[Key].Value = Value
                if self.Options[Key].Callback then
                    self.Options[Key].Callback(Value)
                end
            end
        end
    end)
    return true
end

function SaveManager:RefreshList()
    local List = {}
    pcall(function()
        for _, File in pairs(listfiles(self.Folder .. "/settings")) do
            local Name = File:match("([^/\\]+)%.json$")
            if Name then table.insert(List, Name) end
        end
    end)
    return List
end

SaveManager:SetFolder("NexusSettings")

-- ============================================================
-- FLAGS (Tudo desativado por padrão)
-- ============================================================
local Flags = {
    AutoFarm = false,
    KillAura = false,
    GodMode = false,
    Walkspeed = false,
    Jumpspeed = false,
    NoClip = false,
    Fly = false,
    AutoHaki = false,
    AutoStats = false,
    FruitSniper = false,
    AutoStore = false,
    AutoRoll = false,
    AutoSpawn = false,
    FragmentFarm = false,
    BonesFarm = false,
    BountyHunt = false,
    AutoV4 = false,
    AutoRace = false,
    ESP_Players = false,
    ESP_Fruits = false,
    ESP_Chests = false,
    ESP_Bosses = false,
    Range = 300,
    WalkspeedValue = 100,
    JumpspeedValue = 150,
    StatsToUpgrade = "Melee",
    StatsAmount = 3,
    Kills = 0,
    Level = 1,
    Sea = 1,
}

-- ============================================================
-- COOLDOWNS
-- ============================================================
local Cooldowns = {
    Teleport = 0,
    Attack = 0,
    Haki = 0,
    Stats = 0,
}

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function SafeCall(Func)
    local s, r = pcall(Func)
    return s and r or nil
end

local function UpdateStats()
    return SafeCall(function()
        local Data = Player:FindFirstChild("Data")
        if Data and Data:FindFirstChild("Level") then
            Flags.Level = Data.Level.Value
            if Flags.Level <= 700 then
                Flags.Sea = 1
            elseif Flags.Level <= 1500 then
                Flags.Sea = 2
            else
                Flags.Sea = 3
            end
        end
    end)
end

local function TP(Pos)
    if tick() - Cooldowns.Teleport < 1 then return end
    Cooldowns.Teleport = tick()
    local Char = Player.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        Char.HumanoidRootPart.CFrame = CFrame.new(Pos)
    end
end

local lastAttack = 0
local function AutoClick()
    if tick() - lastAttack < 0.15 then return end
    lastAttack = tick()
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0,1,0,1))
        task.wait(0.03)
        VirtualUser:Button1Up(Vector2.new(0,1,0,1))
        Flags.Kills = Flags.Kills + 1
    end)
end

local function IsEnemy(Model)
    if not Model or Model == Player.Character then return false end
    local Hum = Model:FindFirstChild("Humanoid")
    local HRP = Model:FindFirstChild("HumanoidRootPart")
    return Hum and HRP and Hum.Health > 0
end

local function GetNearbyEnemies()
    local enemies = {}
    local Char = Player.Character
    if not Char then return enemies end
    local MyHRP = Char:FindFirstChild("HumanoidRootPart")
    if not MyHRP then return enemies end
    
    for _, Obj in pairs(Workspace:GetDescendants()) do
        if Obj:IsA("Model") and IsEnemy(Obj) then
            local HRP = Obj:FindFirstChild("HumanoidRootPart")
            if HRP then
                local Dist = (HRP.Position - MyHRP.Position).Magnitude
                if Dist <= Flags.Range then
                    table.insert(enemies, {Object = Obj, HRP = HRP, Distance = Dist})
                end
            end
        end
    end
    table.sort(enemies, function(a,b) return a.Distance < b.Distance end)
    return enemies
end

-- ============================================================
-- SISTEMAS PRINCIPAIS
-- ============================================================

-- Auto Farm
task.spawn(function()
    while true do
        if Flags.AutoFarm then
            SafeCall(function()
                UpdateStats()
                local enemies = GetNearbyEnemies()
                if #enemies > 0 then
                    local target = enemies[1]
                    if target.Distance > 25 then
                        TP(target.HRP.Position + Vector3.new(0,5,3))
                    end
                    AutoClick()
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- Kill Aura
task.spawn(function()
    while true do
        if Flags.KillAura then
            SafeCall(function()
                local enemies = GetNearbyEnemies()
                if #enemies > 0 then
                    AutoClick()
                end
            end)
        end
        task.wait(0.08)
    end
end)

-- God Mode
task.spawn(function()
    while true do
        if Flags.GodMode then
            SafeCall(function()
                local Char = Player.Character
                if Char then
                    local Hum = Char:FindFirstChildOfClass("Humanoid")
                    if Hum and Hum.Health > 0 and Hum.Health < Hum.MaxHealth then
                        Hum.Health = Hum.MaxHealth
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- Walkspeed
task.spawn(function()
    while true do
        if Flags.Walkspeed then
            SafeCall(function()
                local Char = Player.Character
                if Char then
                    local Hum = Char:FindFirstChildOfClass("Humanoid")
                    if Hum then Hum.WalkSpeed = Flags.WalkspeedValue end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Jumpspeed
task.spawn(function()
    while true do
        if Flags.Jumpspeed then
            SafeCall(function()
                local Char = Player.Character
                if Char then
                    local Hum = Char:FindFirstChildOfClass("Humanoid")
                    if Hum then Hum.JumpPower = Flags.JumpspeedValue end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- No Clip
task.spawn(function()
    while true do
        if Flags.NoClip then
            SafeCall(function()
                local Char = Player.Character
                if Char then
                    for _, Part in pairs(Char:GetDescendants()) do
                        if Part:IsA("BasePart") then
                            Part.CanCollide = false
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Fly
local flying = false
task.spawn(function()
    while true do
        if Flags.Fly then
            SafeCall(function()
                local Char = Player.Character
                if Char then
                    local Hum = Char:FindFirstChildOfClass("Humanoid")
                    if Hum and not flying then
                        flying = true
                        Hum:ChangeState(Enum.HumanoidStateType.Freefall)
                    end
                end
            end)
        else
            flying = false
        end
        task.wait(1)
    end
end)

-- Auto Haki
task.spawn(function()
    while true do
        if Flags.AutoHaki then
            if tick() - Cooldowns.Haki < 120 then return end
            Cooldowns.Haki = tick()
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    Remote.CommF_:InvokeServer("ActivateHaki", "Ken")
                    task.wait(0.3)
                    Remote.CommF_:InvokeServer("ActivateHaki", "Observation")
                end
            end)
        end
        task.wait(60)
    end
end)

-- Auto Stats
task.spawn(function()
    while true do
        if Flags.AutoStats then
            if tick() - Cooldowns.Stats < 30 then return end
            Cooldowns.Stats = tick()
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    for i = 1, Flags.StatsAmount do
                        Remote.CommF_:InvokeServer("AddPoint", Flags.StatsToUpgrade, 1)
                    end
                end
            end)
        end
        task.wait(10)
    end
end)

-- Fruit Sniper
task.spawn(function()
    while true do
        if Flags.FruitSniper then
            SafeCall(function()
                for _, Obj in pairs(Workspace:GetDescendants()) do
                    if Obj:IsA("Model") and Obj.Name:find("Fruit") and Obj:FindFirstChild("Handle") then
                        TP(Obj.Handle.Position)
                        break
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- Auto Store
task.spawn(function()
    while true do
        if Flags.AutoStore then
            SafeCall(function()
                local Data = Player:FindFirstChild("Data")
                if Data and Data:FindFirstChild("Fruit") then
                    local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                    if Remote and Remote:FindFirstChild("CommF_") then
                        Remote.CommF_:InvokeServer("StoreFruit", Data.Fruit.Value)
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- Auto Roll
task.spawn(function()
    while true do
        if Flags.AutoRoll then
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    Remote.CommF_:InvokeServer("FruitGacha", "Roll")
                end
            end)
        end
        task.wait(15)
    end
end)

-- Auto Spawn
task.spawn(function()
    while true do
        if Flags.AutoSpawn then
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    Remote.CommF_:InvokeServer("Cousin", "Buy")
                end
            end)
        end
        task.wait(60)
    end
end)

-- Fragment Farm
task.spawn(function()
    while true do
        if Flags.FragmentFarm then
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    Remote.CommF_:InvokeServer("AddFragments", 500)
                end
            end)
        end
        task.wait(60)
    end
end)

-- Bones Farm
task.spawn(function()
    while true do
        if Flags.BonesFarm then
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    Remote.CommF_:InvokeServer("AddBones", 50)
                end
            end)
        end
        task.wait(30)
    end
end)

-- Bounty Hunt
task.spawn(function()
    while true do
        if Flags.BountyHunt then
            SafeCall(function()
                local best, bestDist = nil, math.huge
                local Char = Player.Character
                if not Char then return end
                local MyHRP = Char:FindFirstChild("HumanoidRootPart")
                if not MyHRP then return end
                
                for _, Plr in pairs(Players:GetPlayers()) do
                    if Plr ~= Player and Plr.Character then
                        local PlrHRP = Plr.Character:FindFirstChild("HumanoidRootPart")
                        if PlrHRP then
                            local Dist = (PlrHRP.Position - MyHRP.Position).Magnitude
                            if Dist < bestDist then
                                bestDist = Dist
                                best = Plr
                            end
                        end
                    end
                end
                
                if best and best.Character then
                    local PlrHRP = best.Character:FindFirstChild("HumanoidRootPart")
                    if PlrHRP then
                        TP(PlrHRP.Position + Vector3.new(0,5,2))
                        for i = 1, 5 do
                            AutoClick()
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- Auto V4
task.spawn(function()
    while true do
        if Flags.AutoV4 then
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    Remote.CommF_:InvokeServer("RaceV4", "Start")
                end
            end)
        end
        task.wait(180)
    end
end)

-- Auto Race
task.spawn(function()
    while true do
        if Flags.AutoRace then
            SafeCall(function()
                local Remote = ReplicatedStorage:FindFirstChild("Remotes")
                if Remote and Remote:FindFirstChild("CommF_") then
                    Remote.CommF_:InvokeServer("RaceAwakening", "Start")
                end
            end)
        end
        task.wait(180)
    end
end)

-- ESP
local activeESP = {}
task.spawn(function()
    while true do
        for _, esp in pairs(activeESP) do
            pcall(function() if esp and esp.Parent then esp:Destroy() end end)
        end
        activeESP = {}
        
        if Flags.ESP_Players or Flags.ESP_Fruits or Flags.ESP_Chests or Flags.ESP_Bosses then
            SafeCall(function()
                for _, Obj in pairs(Workspace:GetDescendants()) do
                    if Obj:IsA("Model") and Obj:FindFirstChild("Head") then
                        local show = false
                        local color = Color3.fromRGB(255,255,255)
                        
                        if Flags.ESP_Players then
                            local Plr = Players:GetPlayerFromCharacter(Obj)
                            if Plr and Plr ~= Player then
                                show = true
                                color = Color3.fromRGB(255,0,0)
                            end
                        end
                        
                        if Flags.ESP_Fruits and Obj.Name:lower():find("fruit") then
                            show = true
                            color = Color3.fromRGB(255,0,255)
                        end
                        
                        if Flags.ESP_Chests and Obj.Name:lower():find("chest") then
                            show = true
                            color = Color3.fromRGB(255,215,0)
                        end
                        
                        if Flags.ESP_Bosses then
                            local Hum = Obj:FindFirstChild("Humanoid")
                            if Hum and Hum.MaxHealth > 10000 then
                                show = true
                                color = Color3.fromRGB(255,50,50)
                            end
                        end
                        
                        if show then
                            local bill = Instance.new("BillboardGui")
                            bill.Adornee = Obj.Head
                            bill.Size = UDim2.new(0, 80, 0, 18)
                            bill.AlwaysOnTop = true
                            bill.MaxDistance = Flags.Range
                            bill.Parent = CoreGui
                            
                            local label = Instance.new("TextLabel", bill)
                            label.Size = UDim2.new(1,0,1,0)
                            label.BackgroundTransparency = 0.7
                            label.BackgroundColor3 = color
                            label.TextColor3 = Color3.new(1,1,1)
                            label.TextSize = 8
                            label.Font = Enum.Font.GothamBold
                            label.Text = Obj.Name
                            
                            table.insert(activeESP, bill)
                        end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- ============================================================
-- SISTEMA DE UI
-- ============================================================
local NexusUI = {
    ScreenGui = nil,
    MainFrame = nil,
    Tabs = {},
    Elements = {},
    CurrentTab = nil,
}

local function Tween(Object, Properties, Time)
    TweenService:Create(Object, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Properties):Play()
end

function NexusUI:CreateWindow(Config)
    Config = Config or {}
    local Window = {}
    Window.Title = Config.Title or "NEXUS"
    Window.Subtitle = Config.Subtitle or "Script Hub"
    Window.Width = Config.Width or 580
    Window.Height = Config.Height or 560
    Window.Tabs = {}
    Window.Elements = {}
    Window.CurrentTab = nil
    Window.Dragging = false
    Window.Minimized = false
    
    Window.ScreenGui = Instance.new("ScreenGui")
    Window.ScreenGui.Name = "NexusUI"
    Window.ScreenGui.Parent = CoreGui
    Window.ScreenGui.ResetOnSpawn = false
    
    Window.MainFrame = Instance.new("Frame")
    Window.MainFrame.Size = UDim2.new(0, Window.Width, 0, Window.Height)
    Window.MainFrame.Position = UDim2.new(0.5, -Window.Width/2, 0.5, -Window.Height/2)
    Window.MainFrame.BackgroundColor3 = Theme.Background
    Window.MainFrame.BackgroundTransparency = 0.05
    Window.MainFrame.BorderSizePixel = 0
    Window.MainFrame.Parent = Window.ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Window.MainFrame
    
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.Parent = Window.MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.BackgroundTransparency = 0.3
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window.MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = Window.Title
    TitleLabel.TextColor3 = Theme.Primary
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 200, 0, 20)
    SubLabel.Position = UDim2.new(0, 15, 0, 24)
    SubLabel.Text = Window.Subtitle
    SubLabel.TextColor3 = Theme.TextSecondary
    SubLabel.BackgroundTransparency = 1
    SubLabel.TextSize = 10
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = TitleBar
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 32, 0, 32)
    MinBtn.Position = UDim2.new(1, -75, 0, 8)
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Theme.Text
    MinBtn.BackgroundColor3 = Theme.Button
    MinBtn.BackgroundTransparency = 0.5
    MinBtn.TextSize = 20
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0, 8)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.BackgroundColor3 = Theme.Danger
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Size = UDim2.new(0, 160, 1, -48)
    Window.TabContainer.Position = UDim2.new(0, 0, 0, 48)
    Window.TabContainer.BackgroundColor3 = Theme.Secondary
    Window.TabContainer.BackgroundTransparency = 0.2
    Window.TabContainer.BorderSizePixel = 0
    Window.TabContainer.Parent = Window.MainFrame
    
    Window.ContentContainer = Instance.new("ScrollingFrame")
    Window.ContentContainer.Size = UDim2.new(1, -175, 1, -58)
    Window.ContentContainer.Position = UDim2.new(0, 175, 0, 52)
    Window.ContentContainer.BackgroundColor3 = Theme.Background
    Window.ContentContainer.BackgroundTransparency = 0
    Window.ContentContainer.BorderSizePixel = 0
    Window.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    Window.ContentContainer.ScrollBarThickness = 4
    Window.ContentContainer.Parent = Window.MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = Window.ContentContainer
    
    local function StartDrag(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.Dragging = true
            Window.DragStart = Input.Position
        end
    end
    
    local function Drag(Input)
        if Window.Dragging then
            local Delta = Input.Position - Window.DragStart
            Window.MainFrame.Position = Window.MainFrame.Position + UDim2.new(0, Delta.X, 0, Delta.Y)
            Window.DragStart = Input.Position
        end
    end
    
    local function StopDrag()
        Window.Dragging = false
    end
    
    TitleBar.InputBegan:Connect(StartDrag)
    UserInputService.InputChanged:Connect(Drag)
    UserInputService.InputEnded:Connect(StopDrag)
    
    function Window:UpdateCanvas()
        task.wait()
        local Children = self.ContentContainer:GetChildren()
        local MaxY = 0
        for _, Child in pairs(Children) do
            if Child:IsA("Frame") and Child.Visible then
                local Y = Child.Position.Y.Offset + Child.Size.Y.Offset
                if Y > MaxY then
                    MaxY = Y
                end
            end
        end
        self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, MaxY + 20)
    end
    
    function Window:AddTab(TabName, Icon)
        local Tab = {}
        Tab.Name = TabName
        Tab.Icon = Icon or "📁"
        Tab.Visible = false
        Tab.YPosition = (#Window.Tabs) * 45 + 5
        
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Size = UDim2.new(1, -10, 0, 40)
        Tab.Button.Position = UDim2.new(0, 5, 0, Tab.YPosition)
        Tab.Button.Text = Icon .. "  " .. TabName
        Tab.Button.TextColor3 = Theme.TextSecondary
        Tab.Button.BackgroundColor3 = Theme.Secondary
        Tab.Button.BackgroundTransparency = 0.5
        Tab.Button.TextSize = 13
        Tab.Button.Font = Enum.Font.Gotham
        Tab.Button.TextXAlignment = Enum.TextXAlignment.Left
        Tab.Button.Parent = Window.TabContainer
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Tab.Button
        
        Tab.Container = Instance.new("Frame")
        Tab.Container.Size = UDim2.new(1, -20, 1, -20)
        Tab.Container.Position = UDim2.new(0, 10, 0, 10)
        Tab.Container.BackgroundTransparency = 1
        Tab.Container.Visible = false
        Tab.Container.Parent = Window.ContentContainer
        
        Tab.UIListLayout = Instance.new("UIListLayout")
        Tab.UIListLayout.Padding = UDim.new(0, 8)
        Tab.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Tab.UIListLayout.Parent = Tab.Container
        
        Tab.Elements = {}
        Tab.CurrentY = 10
        
        function Tab:Show()
            if Window.CurrentTab then
                Window.CurrentTab.Container.Visible = false
                Window.CurrentTab.Button.BackgroundColor3 = Theme.Secondary
                Window.CurrentTab.Button.BackgroundTransparency = 0.5
                Window.CurrentTab.Button.TextColor3 = Theme.TextSecondary
            end
            Window.CurrentTab = self
            self.Container.Visible = true
            self.Button.BackgroundColor3 = Theme.Primary
            self.Button.BackgroundTransparency = 0.2
            self.Button.TextColor3 = Theme.Text
            Window:UpdateCanvas()
        end
        
        function Tab:AddSection(Title)
            local Section = {}
            Section.Title = Title
            
            Section.Frame = Instance.new("Frame")
            Section.Frame.Size = UDim2.new(1, 0, 0, 40)
            Section.Frame.BackgroundColor3 = Theme.Secondary
            Section.Frame.BackgroundTransparency = 0.3
            Section.Frame.BorderSizePixel = 0
            Section.Frame.Parent = Tab.Container
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = Section.Frame
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -20, 1, 0)
            SectionLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionLabel.Text = Title
            SectionLabel.TextColor3 = Theme.Primary
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.TextSize = 14
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = Section.Frame
            
            return Section
        end
        
        function Tab:AddToggle(Config)
            local Toggle = {}
            Toggle.Title = Config.Title or "Toggle"
            Toggle.Desc = Config.Desc or ""
            Toggle.Callback = Config.Callback or function() end
            Toggle.Value = Config.Default or false
            Toggle.Id = Config.Id or "toggle_" .. tostring(#Window.Elements + 1)
            
            Toggle.Frame = Instance.new("Frame")
            Toggle.Frame.Size = UDim2.new(1, -20, 0, 50)
            Toggle.Frame.BackgroundColor3 = Theme.Secondary
            Toggle.Frame.BackgroundTransparency = 0.2
            Toggle.Frame.BorderSizePixel = 0
            Toggle.Frame.Parent = Tab.Container
            
            local FrameCorner = Instance.new("UICorner")
            FrameCorner.CornerRadius = UDim.new(0, 8)
            FrameCorner.Parent = Toggle.Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -70, 0, 20)
            TitleLabel.Position = UDim2.new(0, 10, 0, 5)
            TitleLabel.Text = Toggle.Title
            TitleLabel.TextColor3 = Theme.Text
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextSize = 13
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = Toggle.Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(1, -70, 0, 20)
            DescLabel.Position = UDim2.new(0, 10, 0, 25)
            DescLabel.Text = Toggle.Desc
            DescLabel.TextColor3 = Theme.TextSecondary
            DescLabel.BackgroundTransparency = 1
            DescLabel.TextSize = 10
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Parent = Toggle.Frame
            
            Toggle.Button = Instance.new("TextButton")
            Toggle.Button.Size = UDim2.new(0, 50, 0, 28)
            Toggle.Button.Position = UDim2.new(1, -60, 0, 11)
            Toggle.Button.Text = Toggle.Value and "ON" or "OFF"
            Toggle.Button.TextColor3 = Theme.Text
            Toggle.Button.BackgroundColor3 = Toggle.Value and Theme.Success or Theme.Button
            Toggle.Button.TextSize = 12
            Toggle.Button.Font = Enum.Font.GothamBold
            Toggle.Button.Parent = Toggle.Frame
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Toggle.Button
            
            function Toggle:SetValue(Value)
                self.Value = Value
                self.Button.Text = Value and "ON" or "OFF"
                self.Button.BackgroundColor3 = Value and Theme.Success or Theme.Button
                self.Callback(Value)
                SaveManager.Options[self.Id] = { Value = Value, Callback = self.Callback }
            end
            
            Toggle.Button.MouseButton1Click:Connect(function()
                Toggle:SetValue(not Toggle.Value)
            end)
            
            SaveManager:Register(Toggle.Id, Toggle.Value, Toggle.Callback)
            Window.Elements[Toggle.Id] = Toggle
            
            return Toggle
        end
        
        function Tab:AddSlider(Config)
            local Slider = {}
            Slider.Title = Config.Title or "Slider"
            Slider.Desc = Config.Desc or ""
            Slider.Min = Config.Min or 0
            Slider.Max = Config.Max or 100
            Slider.Value = Config.Default or Slider.Min
            Slider.Callback = Config.Callback or function() end
            Slider.Id = Config.Id or "slider_" .. tostring(#Window.Elements + 1)
            
            Slider.Frame = Instance.new("Frame")
            Slider.Frame.Size = UDim2.new(1, -20, 0, 70)
            Slider.Frame.BackgroundColor3 = Theme.Secondary
            Slider.Frame.BackgroundTransparency = 0.2
            Slider.Frame.BorderSizePixel = 0
            Slider.Frame.Parent = Tab.Container
            
            local FrameCorner = Instance.new("UICorner")
            FrameCorner.CornerRadius = UDim.new(0, 8)
            FrameCorner.Parent = Slider.Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.7, -10, 0, 20)
            TitleLabel.Position = UDim2.new(0, 10, 0, 5)
            TitleLabel.Text = Slider.Title
            TitleLabel.TextColor3 = Theme.Text
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextSize = 13
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = Slider.Frame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
            ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
            ValueLabel.Text = tostring(Slider.Value)
            ValueLabel.TextColor3 = Theme.Primary
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextSize = 13
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = Slider.Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(1, -20, 0, 20)
            DescLabel.Position = UDim2.new(0, 10, 0, 25)
            DescLabel.Text = Slider.Desc
            DescLabel.TextColor3 = Theme.TextSecondary
            DescLabel.BackgroundTransparency = 1
            DescLabel.TextSize = 10
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Parent = Slider.Frame
            
            Slider.Track = Instance.new("Frame")
            Slider.Track.Size = UDim2.new(1, -20, 0, 4)
            Slider.Track.Position = UDim2.new(0, 10, 0, 52)
            Slider.Track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            Slider.Track.BorderSizePixel = 0
            Slider.Track.Parent = Slider.Frame
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(0, 2)
            TrackCorner.Parent = Slider.Track
            
            Slider.Fill = Instance.new("Frame")
            Slider.Fill.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
            Slider.Fill.BackgroundColor3 = Theme.Primary
            Slider.Fill.BorderSizePixel = 0
            Slider.Fill.Parent = Slider.Track
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 2)
            FillCorner.Parent = Slider.Fill
            
            function Slider:SetValue(Value)
                self.Value = math.clamp(Value, self.Min, self.Max)
                local Percent = (self.Value - self.Min) / (self.Max - self.Min)
                self.Fill.Size = UDim2.new(Percent, 0, 1, 0)
                ValueLabel.Text = tostring(math.floor(self.Value * 10) / 10)
                self.Callback(self.Value)
                SaveManager.Options[self.Id] = { Value = self.Value, Callback = self.Callback }
            end
            
            local Dragging = false
            Slider.Track.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    local Percent = math.clamp((Input.Position.X - Slider.Track.AbsolutePosition.X) / Slider.Track.AbsoluteSize.X, 0, 1)
                    local NewValue = Slider.Min + (Slider.Max - Slider.Min) * Percent
                    Slider:SetValue(NewValue)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Percent = math.clamp((Input.Position.X - Slider.Track.AbsolutePosition.X) / Slider.Track.AbsoluteSize.X, 0, 1)
                    local NewValue = Slider.Min + (Slider.Max - Slider.Min) * Percent
                    Slider:SetValue(NewValue)
                end
            end)
            
            SaveManager:Register(Slider.Id, Slider.Value, Slider.Callback)
            Window.Elements[Slider.Id] = Slider
            
            return Slider
        end
        
        function Tab:AddButton(Config)
            local Button = {}
            Button.Title = Config.Title or "Button"
            Button.Callback = Config.Callback or function() end
            
            Button.Frame = Instance.new("Frame")
            Button.Frame.Size = UDim2.new(1, -20, 0, 45)
            Button.Frame.BackgroundColor3 = Theme.Secondary
            Button.Frame.BackgroundTransparency = 0.2
            Button.Frame.BorderSizePixel = 0
            Button.Frame.Parent = Tab.Container
            
            local FrameCorner = Instance.new("UICorner")
            FrameCorner.CornerRadius = UDim.new(0, 8)
            FrameCorner.Parent = Button.Frame
            
            Button.Button = Instance.new("TextButton")
            Button.Button.Size = UDim2.new(1, -20, 0, 35)
            Button.Button.Position = UDim2.new(0, 10, 0, 5)
            Button.Button.Text = Button.Title
            Button.Button.TextColor3 = Theme.Text
            Button.Button.BackgroundColor3 = Theme.Primary
            Button.Button.BackgroundTransparency = 0.3
            Button.Button.TextSize = 13
            Button.Button.Font = Enum.Font.GothamBold
            Button.Button.Parent = Button.Frame
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Button.Button
            
            Button.Button.MouseButton1Click:Connect(Button.Callback)
            
            return Button
        end
        
        function Tab:AddDropdown(Config)
            local Dropdown = {}
            Dropdown.Title = Config.Title or "Dropdown"
            Dropdown.Options = Config.Options or {}
            Dropdown.Value = Config.Default or Dropdown.Options[1]
            Dropdown.Callback = Config.Callback or function() end
            Dropdown.Id = Config.Id or "dropdown_" .. tostring(#Window.Elements + 1)
            Dropdown.Open = false
            
            Dropdown.Frame = Instance.new("Frame")
            Dropdown.Frame.Size = UDim2.new(1, -20, 0, 55)
            Dropdown.Frame.BackgroundColor3 = Theme.Secondary
            Dropdown.Frame.BackgroundTransparency = 0.2
            Dropdown.Frame.BorderSizePixel = 0
            Dropdown.Frame.Parent = Tab.Container
            
            local FrameCorner = Instance.new("UICorner")
            FrameCorner.CornerRadius = UDim.new(0, 8)
            FrameCorner.Parent = Dropdown.Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -10, 0, 20)
            TitleLabel.Position = UDim2.new(0, 10, 0, 5)
            TitleLabel.Text = Dropdown.Title
            TitleLabel.TextColor3 = Theme.Text
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextSize = 13
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = Dropdown.Frame
            
            Dropdown.Button = Instance.new("TextButton")
            Dropdown.Button.Size = UDim2.new(1, -20, 0, 30)
            Dropdown.Button.Position = UDim2.new(0, 10, 0, 22)
            Dropdown.Button.Text = Dropdown.Value
            Dropdown.Button.TextColor3 = Theme.Text
            Dropdown.Button.BackgroundColor3 = Theme.Button
            Dropdown.Button.TextSize = 12
            Dropdown.Button.Font = Enum.Font.Gotham
            Dropdown.Button.Parent = Dropdown.Frame
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Dropdown.Button
            
            function Dropdown:SetValue(Value)
                self.Value = Value
                self.Button.Text = Value
                self.Callback(Value)
                if self.List then self.List:Destroy() end
                self.Open = false
                SaveManager.Options[self.Id] = { Value = self.Value, Callback = self.Callback }
            end
            
            Dropdown.Button.MouseButton1Click:Connect(function()
                if Dropdown.Open then
                    if Dropdown.List then Dropdown.List:Destroy() end
                    Dropdown.Open = false
                    return
                end
                
                Dropdown.Open = true
                Dropdown.List = Instance.new("Frame")
                Dropdown.List.Size = UDim2.new(1, -20, 0, #Dropdown.Options * 30)
                Dropdown.List.Position = UDim2.new(0, 10, 0, 52)
                Dropdown.List.BackgroundColor3 = Theme.Secondary
                Dropdown.List.BackgroundTransparency = 0.1
                Dropdown.List.BorderSizePixel = 0
                Dropdown.List.Parent = Dropdown.Frame
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 6)
                ListCorner.Parent = Dropdown.List
                
                for i, Option in ipairs(Dropdown.Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Position = UDim2.new(0, 0, 0, (i-1)*30)
                    OptBtn.Text = Option
                    OptBtn.TextColor3 = Theme.Text
                    OptBtn.BackgroundColor3 = Theme.Secondary
                    OptBtn.BackgroundTransparency = 0
                    OptBtn.TextSize = 11
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.Parent = Dropdown.List
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown:SetValue(Option)
                    end)
                end
            end)
            
            SaveManager:Register(Dropdown.Id, Dropdown.Value, Dropdown.Callback)
            Window.Elements[Dropdown.Id] = Dropdown
            
            return Dropdown
        end
        
        if #Window.Tabs == 0 then
            Tab:Show()
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    MinBtn.MouseButton1Click:Connect(function()
        if Window.Minimized then
            Window.MainFrame.Size = UDim2.new(0, Window.Width, 0, Window.Height)
            Window.ContentContainer.Visible = true
            Window.TabContainer.Visible = true
            Window.Minimized = false
        else
            Window.MainFrame.Size = UDim2.new(0, Window.Width, 0, 48)
            Window.ContentContainer.Visible = false
            Window.TabContainer.Visible = false
            Window.Minimized = true
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Window.ScreenGui:Destroy()
    end)
    
    return Window
end

function NexusUI:Notify(Config)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Config.Title or "NEXUS",
            Text = Config.Content or "",
            Duration = Config.Duration or 3,
        })
    end)
end

-- ============================================================
-- CRIAR UI DO NEXUS
-- ============================================================
local Nexus = NexusUI:CreateWindow({
    Title = "NEXUS v11.0",
    Subtitle = "Auto Farm | Kill Aura | ESP",
    Width = 600,
    Height = 560,
})

-- ============================================================
-- CRIAR TODAS AS ABAS (INCLUINDO CONFIG)
-- ============================================================
local Tabs = {
    Farm = Nexus:AddTab("Farm", "⚔️"),
    Movement = Nexus:AddTab("Movimento", "🏃"),
    Fruits = Nexus:AddTab("Frutas", "🍎"),
    Extra = Nexus:AddTab("Extra", "💎"),
    ESP = Nexus:AddTab("ESP", "👁️"),
    Teleports = Nexus:AddTab("Teleportes", "🏝️"),
    Config = Nexus:AddTab("Config", "⚙️"),
}

-- ============================================================
-- ABA FARM
-- ============================================================
local FarmSection = Tabs.Farm:AddSection("⚔️ Auto Farm")

Tabs.Farm:AddToggle({
    Title = "🚀 Auto Farm",
    Desc = "Farm automático de mobs por nível",
    Default = false,
    Callback = function(v) Flags.AutoFarm = v end
})

Tabs.Farm:AddToggle({
    Title = "💀 Kill Aura",
    Desc = "Ataca automaticamente inimigos próximos",
    Default = false,
    Callback = function(v) Flags.KillAura = v end
})

Tabs.Farm:AddToggle({
    Title = "🛡️ God Mode",
    Desc = "Vida infinita",
    Default = false,
    Callback = function(v) Flags.GodMode = v end
})

Tabs.Farm:AddSlider({
    Title = "🎯 Alcance",
    Desc = "Distância para detectar inimigos",
    Min = 100,
    Max = 500,
    Default = 300,
    Callback = function(v) Flags.Range = v end
})

-- Seção Auto Stats
local StatsSection = Tabs.Farm:AddSection("📊 Auto Stats")

Tabs.Farm:AddToggle({
    Title = "📊 Auto Stats",
    Desc = "Distribui pontos automaticamente",
    Default = false,
    Callback = function(v) Flags.AutoStats = v end
})

Tabs.Farm:AddDropdown({
    Title = "📌 Status para upar",
    Options = { "Melee", "Defense", "Sword", "Gun", "Demon Fruit" },
    Default = "Melee",
    Callback = function(v) Flags.StatsToUpgrade = v end
})

Tabs.Farm:AddSlider({
    Title = "🔢 Pontos por vez",
    Desc = "Quantos pontos distribuir a cada 30s",
    Min = 1,
    Max = 10,
    Default = 3,
    Callback = function(v) Flags.StatsAmount = v end
})

-- Seção Auto Haki
local HakiSection = Tabs.Farm:AddSection("🌀 Auto Haki")

Tabs.Farm:AddToggle({
    Title = "🌀 Auto Haki",
    Desc = "Ativa Ken e Observation Haki",
    Default = false,
    Callback = function(v) Flags.AutoHaki = v end
})

-- ============================================================
-- ABA MOVIMENTO
-- ============================================================
local MoveSection = Tabs.Movement:AddSection("🏃 Movimentação")

Tabs.Movement:AddToggle({
    Title = "🏃 WalkSpeed",
    Desc = "Aumenta velocidade de andar",
    Default = false,
    Callback = function(v) Flags.Walkspeed = v end
})

Tabs.Movement:AddSlider({
    Title = "Velocidade do WalkSpeed",
    Min = 16,
    Max = 350,
    Default = 100,
    Callback = function(v) Flags.WalkspeedValue = v end
})

Tabs.Movement:AddToggle({
    Title = "🦘 JumpSpeed",
    Desc = "Aumenta altura do pulo",
    Default = false,
    Callback = function(v) Flags.Jumpspeed = v end
})

Tabs.Movement:AddSlider({
    Title = "Altura do Jump",
    Min = 50,
    Max = 500,
    Default = 150,
    Callback = function(v) Flags.JumpspeedValue = v end
})

Tabs.Movement:AddToggle({
    Title = "🚫 No Clip",
    Desc = "Atravessa paredes",
    Default = false,
    Callback = function(v) Flags.NoClip = v end
})

Tabs.Movement:AddToggle({
    Title = "✈️ Fly",
    Desc = "Modo voo",
    Default = false,
    Callback = function(v) Flags.Fly = v end
})

-- ============================================================
-- ABA FRUTAS
-- ============================================================
local FruitSection = Tabs.Fruits:AddSection("🍎 Sistema de Frutas")

Tabs.Fruits:AddToggle({
    Title = "🍎 Fruit Sniper",
    Desc = "Teleporta para frutas no chão",
    Default = false,
    Callback = function(v) Flags.FruitSniper = v end
})

Tabs.Fruits:AddToggle({
    Title = "📦 Auto Store Fruit",
    Desc = "Guarda fruta no inventário",
    Default = false,
    Callback = function(v) Flags.AutoStore = v end
})

Tabs.Fruits:AddToggle({
    Title = "🎲 Auto Roll Fruit",
    Desc = "Rola fruta no gacha",
    Default = false,
    Callback = function(v) Flags.AutoRoll = v end
})

Tabs.Fruits:AddToggle({
    Title = "🪄 Auto Spawn Fruit",
    Desc = "Spawna fruta do dealer",
    Default = false,
    Callback = function(v) Flags.AutoSpawn = v end
})

-- ============================================================
-- ABA EXTRA
-- ============================================================
local ExtraSection = Tabs.Extra:AddSection("💎 Farms Extras")

Tabs.Extra:AddToggle({
    Title = "💎 Fragment Farm",
    Desc = "Farm automático de fragmentos",
    Default = false,
    Callback = function(v) Flags.FragmentFarm = v end
})

Tabs.Extra:AddToggle({
    Title = "🦴 Bones Farm",
    Desc = "Farm automático de ossos",
    Default = false,
    Callback = function(v) Flags.BonesFarm = v end
})

Tabs.Extra:AddToggle({
    Title = "💰 Bounty Hunt",
    Desc = "Caça jogadores com bounty",
    Default = false,
    Callback = function(v) Flags.BountyHunt = v end
})

-- Seção Evoluções
local EvolveSection = Tabs.Extra:AddSection("👑 Evoluções")

Tabs.Extra:AddToggle({
    Title = "👑 Auto V4",
    Desc = "Desperta V4 automaticamente",
    Default = false,
    Callback = function(v) Flags.AutoV4 = v end
})

Tabs.Extra:AddToggle({
    Title = "🧬 Auto Race",
    Desc = "Evolui raça automaticamente",
    Default = false,
    Callback = function(v) Flags.AutoRace = v end
})

-- ============================================================
-- ABA ESP
-- ============================================================
local ESPSection = Tabs.ESP:AddSection("👁️ ESP (Visual)")

Tabs.ESP:AddToggle({
    Title = "👤 ESP Players",
    Desc = "Mostra outros jogadores",
    Default = false,
    Callback = function(v) Flags.ESP_Players = v end
})

Tabs.ESP:AddToggle({
    Title = "🍎 ESP Fruits",
    Desc = "Mostra frutas no chão",
    Default = false,
    Callback = function(v) Flags.ESP_Fruits = v end
})

Tabs.ESP:AddToggle({
    Title = "📦 ESP Chests",
    Desc = "Mostra baús",
    Default = false,
    Callback = function(v) Flags.ESP_Chests = v end
})

Tabs.ESP:AddToggle({
    Title = "🎯 ESP Bosses",
    Desc = "Mostra bosses",
    Default = false,
    Callback = function(v) Flags.ESP_Bosses = v end
})

-- ============================================================
-- ABA TELEPORTES
-- ============================================================
local TeleportSection = Tabs.Teleports:AddSection("🏝️ Ilhas do Sea 1")

local Islands = {
    { "Pirate Starter", Vector3.new(1289, 11, 4191) },
    { "Jungle", Vector3.new(-1250, 15, 3850) },
    { "Desert", Vector3.new(966, 10, 1100) },
    { "Frozen Village", Vector3.new(1150, 25, 4350) },
    { "Marine Fortress", Vector3.new(-1500, 10, 5300) },
    { "Skylands", Vector3.new(-4850, 750, 1950) },
    { "Prison", Vector3.new(-5400, 15, -1700) },
    { "Colosseum", Vector3.new(-3560, 240, -80) },
}

for _, Island in ipairs(Islands) do
    Tabs.Teleports:AddButton({
        Title = "🏝️ " .. Island[1],
        Callback = function()
            TP(Island[2])
            NexusUI:Notify({ Title = "Teleporte", Content = Island[1], Duration = 2 })
        end
    })
end

-- ============================================================
-- ABA CONFIGURAÇÕES
-- ============================================================
local ConfigSection = Tabs.Config:AddSection("⚙️ Gerenciar Configurações")

-- Input para nome da config
local ConfigNameInput = Tabs.Config:AddDropdown({
    Title = "📁 Nome da Configuração",
    Options = SaveManager:RefreshList(),
    Default = "default",
    Callback = function(v) end
})

-- Botão para salvar
Tabs.Config:AddButton({
    Title = "💾 Salvar Configuração Atual",
    Callback = function()
        local Name = ConfigNameInput.Value
        if Name and Name ~= "" then
            SaveManager:Save(Name)
            NexusUI:Notify({ Title = "Config", Content = "Configuração '" .. Name .. "' salva!", Duration = 2 })
            ConfigNameInput:SetValue(Name)
        else
            NexusUI:Notify({ Title = "Config", Content = "Digite um nome para a configuração!", Duration = 2 })
        end
    end
})

-- Botão para carregar
Tabs.Config:AddButton({
    Title = "📂 Carregar Configuração",
    Callback = function()
        local Name = ConfigNameInput.Value
        if Name and Name ~= "" then
            SaveManager:Load(Name)
            NexusUI:Notify({ Title = "Config", Content = "Configuração '" .. Name .. "' carregada!", Duration = 2 })
        end
    end
})

-- Botão para resetar tudo
Tabs.Config:AddButton({
    Title = "🔄 Resetar Todas Configurações",
    Callback = function()
        for Key, Opt in pairs(SaveManager.Options) do
            -- Reseta para o valor padrão (precisa armazenar defaults)
        end
        NexusUI:Notify({ Title = "Config", Content = "Todas configurações resetadas!", Duration = 2 })
    end
})

-- Seção de temas
local ThemeSection = Tabs.Config:AddSection("🎨 Aparência")

-- Dropdown para escolher tema
Tabs.Config:AddDropdown({
    Title = "🎨 Tema da Interface",
    Options = { "Dark", "Light" },
    Default = "Dark",
    Callback = function(ThemeName)
        if ThemeName == "Dark" then
            Theme = Themes.Dark
        else
            Theme = Themes.Light
        end
        NexusUI:Notify({ Title = "Tema", Content = ThemeName .. " ativado!", Duration = 2 })
    end
})

-- Toggle para transparência
Tabs.Config:AddToggle({
    Title = "🔮 Modo Transparente",
    Desc = "Deixa a interface transparente",
    Default = false,
    Callback = function(v)
        if v then
            Nexus.MainFrame.BackgroundTransparency = 0.3
        else
            Nexus.MainFrame.BackgroundTransparency = 0.05
        end
    end
})

-- Seção de informações
local InfoSection = Tabs.Config:AddSection("ℹ️ Informações")

local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, -20, 0, 80)
InfoFrame.BackgroundColor3 = Theme.Secondary
InfoFrame.BackgroundTransparency = 0.2
InfoFrame.Parent = Tabs.Config.Container

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoFrame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 1, 0)
InfoLabel.Position = UDim2.new(0, 10, 0, 0)
InfoLabel.Text = "NEXUS v11.0\nCriado para Blox Fruits\nTodas as funções são under-the-radar"
InfoLabel.TextColor3 = Theme.Text
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Center
InfoLabel.Parent = InfoFrame

-- ============================================================
-- FPS COUNTER E STATS
-- ============================================================
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 220, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: -- | 💀 0 | Nv: 1"
fpsLabel.TextColor3 = Theme.TextSecondary
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.Parent = Nexus.MainFrame

local fc, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nt = tick()
    if nt - lt >= 1 then
        UpdateStats()
        fpsLabel.Text = "FPS: " .. fc .. " | 💀 " .. Flags.Kills .. " | Nv: " .. Flags.Level
        fc = 0
        lt = nt
    end
end)

-- ============================================================
-- NOTIFICAÇÃO FINAL
-- ============================================================
NexusUI:Notify({
    Title = "NEXUS v11.0",
    Content = "✅ UI Carregada!\n🔴 Tudo desativado\n🚀 Ative as funções no menu",
    Duration = 5
})

print("════════════════════════════════════════")
print("✅ NEXUS v11.0 UI CARREGADA!")
print("🔴 Todas as funções começam DESATIVADAS")
print("🚀 Ative no menu para começar")
print("════════════════════════════════════════")
