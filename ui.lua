-- ============================================================
-- NEXUS v11.0 - UI CRIADA DO ZERO
-- Baseada no estilo WindUI, mas 100% nossa
-- ============================================================

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

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
    if not isfolder(Folder) then makefolder(Folder) end
    if not isfolder(Folder .. "/settings") then makefolder(Folder .. "/settings") end
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
    local Path = self.Folder .. "/settings/" .. Name .. ".json"
    writefile(Path, HttpService:JSONEncode(Data))
    return true
end

function SaveManager:Load(Name)
    local Path = self.Folder .. "/settings/" .. Name .. ".json"
    if not isfile(Path) then return false end
    local Data = HttpService:JSONDecode(readfile(Path))
    for Key, Value in pairs(Data) do
        if self.Options[Key] then
            self.Options[Key].Value = Value
            if self.Options[Key].Callback then
                self.Options[Key].Callback(Value)
            end
        end
    end
    return true
end

function SaveManager:RefreshList()
    local List = {}
    for _, File in pairs(listfiles(self.Folder .. "/settings")) do
        local Name = File:match("([^/\\]+)%.json$")
        if Name then table.insert(List, Name) end
    end
    return List
end

SaveManager:SetFolder("NexusSettings")

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

-- Função para criar animação suave
local function Tween(Object, Properties, Time)
    TweenService:Create(Object, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Properties):Play()
end

-- Criar janela principal
function NexusUI:CreateWindow(Config)
    Config = Config or {}
    local Window = {}
    Window.Title = Config.Title or "NEXUS"
    Window.Subtitle = Config.Subtitle or "Script Hub"
    Window.Width = Config.Width or 580
    Window.Height = Config.Height or 520
    Window.Tabs = {}
    Window.Elements = {}
    Window.CurrentTab = nil
    Window.Dragging = false
    
    -- Criar ScreenGui
    Window.ScreenGui = Instance.new("ScreenGui")
    Window.ScreenGui.Name = "NexusUI"
    Window.ScreenGui.Parent = CoreGui
    Window.ScreenGui.ResetOnSpawn = false
    
    -- Frame principal
    Window.MainFrame = Instance.new("Frame")
    Window.MainFrame.Size = UDim2.new(0, Window.Width, 0, Window.Height)
    Window.MainFrame.Position = UDim2.new(0.5, -Window.Width/2, 0.5, -Window.Height/2)
    Window.MainFrame.BackgroundColor3 = Theme.Background
    Window.MainFrame.BackgroundTransparency = 0.05
    Window.MainFrame.BorderSizePixel = 0
    Window.MainFrame.Parent = Window.ScreenGui
    
    -- Cantos arredondados
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Window.MainFrame
    
    -- Sombra
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.Parent = Window.MainFrame
    
    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.BackgroundTransparency = 0.3
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window.MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Título
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
    
    -- Subtítulo
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
    
    -- Botão minimizar
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
    
    -- Botão fechar
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
    
    -- Container das abas (sidebar)
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Size = UDim2.new(0, 160, 1, -48)
    Window.TabContainer.Position = UDim2.new(0, 0, 0, 48)
    Window.TabContainer.BackgroundColor3 = Theme.Secondary
    Window.TabContainer.BackgroundTransparency = 0.2
    Window.TabContainer.BorderSizePixel = 0
    Window.TabContainer.Parent = Window.MainFrame
    
    -- Container do conteúdo
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
    
    -- Função para mover a janela
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
    
    -- Funções da janela
    function Window:AddTab(TabName, Icon)
        local Tab = {}
        Tab.Name = TabName
        Tab.Icon = Icon or "📁"
        Tab.Visible = false
        Tab.YPosition = (#Window.Tabs) * 45 + 5
        
        -- Botão da aba
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
        
        -- Container da aba
        Tab.Container = Instance.new("Frame")
        Tab.Container.Size = UDim2.new(1, -20, 1, -20)
        Tab.Container.Position = UDim2.new(0, 10, 0, 10)
        Tab.Container.BackgroundTransparency = 1
        Tab.Container.Visible = false
        Tab.Container.Parent = Window.ContentContainer
        
        -- Layout da aba
        Tab.UIListLayout = Instance.new("UIListLayout")
        Tab.UIListLayout.Padding = UDim.new(0, 8)
        Tab.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Tab.UIListLayout.Parent = Tab.Container
        
        Tab.Elements = {}
        Tab.CurrentY = 10
        
        -- Função para mostrar a aba
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
        
        -- Função para criar seção
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
        
        -- Função para criar toggle
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
        
        -- Função para criar slider
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
        
        -- Função para criar botão
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
        
        -- Função para criar dropdown
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
        
        -- Auto mostrar primeira aba
        if #Window.Tabs == 0 then
            Tab:Show()
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    -- Função para atualizar canvas
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
    
    -- Botões
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

-- ============================================================
-- NOTIFICAÇÃO
-- ============================================================
function NexusUI:Notify(Config)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
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
    Height = 520,
})

-- ============================================================
-- CRIAR ABAS
-- ============================================================
local Tabs = {
    Farm = Nexus:AddTab("Farm", "⚔️"),
    Movement = Nexus:AddTab("Movimento", "🏃"),
    Fruits = Nexus:AddTab("Frutas", "🍎"),
    Extra = Nexus:AddTab("Extra", "💎"),
    ESP = Nexus:AddTab("ESP", "👁️"),
    Teleports = Nexus:AddTab("Teleportes", "🏝️"),
}

-- ============================================================
-- ABA FARM
-- ============================================================
local FarmSection = Tabs.Farm:AddSection("⚔️ Auto Farm")

Tabs.Farm:AddToggle({
    Title = "🚀 Auto Farm",
    Desc = "Farm automático de mobs por nível",
    Default = false,
    Callback = function(v)
        Flags.AutoFarm = v
        NexusUI:Notify({ Title = "Auto Farm", Content = v and "Ativado ✅" or "Desativado ❌", Duration = 2 })
    end
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
            local Char = Player.Character
            if Char and Char:FindFirstChild("HumanoidRootPart") then
                Char.HumanoidRootPart.CFrame = CFrame.new(Island[2])
                NexusUI:Notify({ Title = "Teleporte", Content = Island[1], Duration = 2 })
            end
        end
    })
end

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
RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nt = tick()
    if nt - lt >= 1 then
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
