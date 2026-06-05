-- ============================================================
-- NEXUS UI SYSTEM v2.0
-- Sistema de Interface completo para NEXUS
-- ============================================================

local NexusUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ============================================================
-- CORES E TEMAS
-- ============================================================
NexusUI.Themes = {
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
        Warning = Color3.fromRGB(255, 170, 50),
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
        Warning = Color3.fromRGB(230, 150, 30),
    },
    Blue = {
        Background = Color3.fromRGB(15, 25, 45),
        Primary = Color3.fromRGB(70, 130, 255),
        Secondary = Color3.fromRGB(25, 40, 65),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 190, 220),
        Accent = Color3.fromRGB(100, 150, 255),
        Button = Color3.fromRGB(35, 55, 85),
        ButtonHover = Color3.fromRGB(45, 70, 105),
        Success = Color3.fromRGB(50, 180, 50),
        Danger = Color3.fromRGB(200, 70, 70),
        Warning = Color3.fromRGB(255, 170, 50),
    },
    Purple = {
        Background = Color3.fromRGB(25, 15, 40),
        Primary = Color3.fromRGB(170, 70, 255),
        Secondary = Color3.fromRGB(35, 25, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 170, 240),
        Accent = Color3.fromRGB(190, 100, 255),
        Button = Color3.fromRGB(45, 35, 65),
        ButtonHover = Color3.fromRGB(55, 45, 80),
        Success = Color3.fromRGB(50, 180, 50),
        Danger = Color3.fromRGB(200, 70, 70),
        Warning = Color3.fromRGB(255, 170, 50),
    }
}

NexusUI.CurrentTheme = "Dark"
NexusUI.Theme = NexusUI.Themes.Dark

-- ============================================================
-- FUNÇÃO PARA CRIAR JANELA PRINCIPAL
-- ============================================================
function NexusUI:CreateWindow(config)
    local window = {}
    window.Config = config or {}
    window.Title = window.Config.Title or "NEXUS"
    window.Subtitle = window.Config.Subtitle or "Script Hub"
    window.Width = window.Config.Width or 550
    window.Height = window.Config.Height or 500
    window.Tabs = {}
    window.CurrentTab = nil
    window.Dragging = false
    window.DragStart = nil
    window.Minimized = false
    
    -- Criar ScreenGui
    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Name = "NexusUI"
    window.ScreenGui.Parent = CoreGui
    window.ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    window.MainFrame = Instance.new("Frame")
    window.MainFrame.Size = UDim2.new(0, window.Width, 0, window.Height)
    window.MainFrame.Position = UDim2.new(0.5, -window.Width/2, 0.5, -window.Height/2)
    window.MainFrame.BackgroundColor3 = self.Theme.Background
    window.MainFrame.BackgroundTransparency = 0.05
    window.MainFrame.BorderSizePixel = 0
    window.MainFrame.ClipsDescendants = true
    window.MainFrame.Parent = window.ScreenGui
    
    -- Sombra
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.Parent = window.MainFrame
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = window.MainFrame
    
    -- Barra de Título
    window.TitleBar = Instance.new("Frame")
    window.TitleBar.Size = UDim2.new(1, 0, 0, 45)
    window.TitleBar.BackgroundColor3 = self.Theme.Secondary
    window.TitleBar.BackgroundTransparency = 0.3
    window.TitleBar.BorderSizePixel = 0
    window.TitleBar.Parent = window.MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = window.TitleBar
    
    -- Título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = window.Title
    TitleLabel.TextColor3 = self.Theme.Primary
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = window.TitleBar
    
    -- Subtítulo
    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(0, 200, 0, 20)
    SubtitleLabel.Position = UDim2.new(0, 15, 0, 22)
    SubtitleLabel.Text = window.Subtitle
    SubtitleLabel.TextColor3 = self.Theme.TextSecondary
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.TextSize = 10
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = window.TitleBar
    
    -- Botão Minimizar
    window.MinimizeBtn = Instance.new("TextButton")
    window.MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    window.MinimizeBtn.Position = UDim2.new(1, -75, 0, 6)
    window.MinimizeBtn.Text = "−"
    window.MinimizeBtn.TextColor3 = self.Theme.Text
    window.MinimizeBtn.BackgroundColor3 = self.Theme.Button
    window.MinimizeBtn.BackgroundTransparency = 0.5
    window.MinimizeBtn.TextSize = 20
    window.MinimizeBtn.Font = Enum.Font.GothamBold
    window.MinimizeBtn.AutoButtonColor = false
    window.MinimizeBtn.Parent = window.TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = window.MinimizeBtn
    
    window.MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(window.MinimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    window.MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(window.MinimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)
    
    window.MinimizeBtn.MouseButton1Click:Connect(function()
        window:ToggleMinimize()
    end)
    
    -- Botão Fechar
    window.CloseBtn = Instance.new("TextButton")
    window.CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    window.CloseBtn.Position = UDim2.new(1, -40, 0, 6)
    window.CloseBtn.Text = "✕"
    window.CloseBtn.TextColor3 = self.Theme.Text
    window.CloseBtn.BackgroundColor3 = self.Theme.Danger
    window.CloseBtn.BackgroundTransparency = 0.3
    window.CloseBtn.TextSize = 16
    window.CloseBtn.Font = Enum.Font.GothamBold
    window.CloseBtn.AutoButtonColor = false
    window.CloseBtn.Parent = window.TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = window.CloseBtn
    
    window.CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(window.CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    window.CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(window.CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    window.CloseBtn.MouseButton1Click:Connect(function()
        window.ScreenGui:Destroy()
    end)
    
    -- Container de Abas
    window.TabContainer = Instance.new("Frame")
    window.TabContainer.Size = UDim2.new(0, 160, 1, -45)
    window.TabContainer.Position = UDim2.new(0, 0, 0, 45)
    window.TabContainer.BackgroundColor3 = self.Theme.Secondary
    window.TabContainer.BackgroundTransparency = 0.2
    window.TabContainer.BorderSizePixel = 0
    window.TabContainer.Parent = window.MainFrame
    
    -- Container de Conteúdo
    window.ContentContainer = Instance.new("ScrollingFrame")
    window.ContentContainer.Size = UDim2.new(1, -175, 1, -55)
    window.ContentContainer.Position = UDim2.new(0, 170, 0, 50)
    window.ContentContainer.BackgroundColor3 = self.Theme.Background
    window.ContentContainer.BackgroundTransparency = 0
    window.ContentContainer.BorderSizePixel = 0
    window.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    window.ContentContainer.ScrollBarThickness = 4
    window.ContentContainer.ScrollBarImageColor3 = self.Theme.Primary
    window.ContentContainer.Parent = window.MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = window.ContentContainer
    
    -- Função para mover a janela
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = true
            window.DragStart = input.Position
        end
    end
    
    local function drag(input)
        if window.Dragging then
            local delta = input.Position - window.DragStart
            window.MainFrame.Position = window.MainFrame.Position + UDim2.new(0, delta.X, 0, delta.Y)
            window.DragStart = input.Position
        end
    end
    
    local function stopDrag()
        window.Dragging = false
    end
    
    window.TitleBar.InputBegan:Connect(startDrag)
    UserInputService.InputChanged:Connect(drag)
    UserInputService.InputEnded:Connect(stopDrag)
    
    -- Funções da janela
    function window:ToggleMinimize()
        self.Minimized = not self.Minimized
        if self.Minimized then
            self.ContentContainer.Visible = false
            self.TabContainer.Visible = false
            self.MainFrame.Size = UDim2.new(0, self.Width, 0, 45)
        else
            self.ContentContainer.Visible = true
            self.TabContainer.Visible = true
            self.MainFrame.Size = UDim2.new(0, self.Width, 0, self.Height)
        end
    end
    
    function window:UpdateCanvas()
        task.wait()
        local children = self.ContentContainer:GetChildren()
        local maxY = 0
        for _, child in ipairs(children) do
            if child:IsA("Frame") and child.Visible then
                local posY = child.Position.Y.Offset + child.Size.Y.Offset
                if posY > maxY then
                    maxY = posY
                end
            end
        end
        self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
    end
    
    return window
end

-- ============================================================
-- FUNÇÃO PARA CRIAR ABA
-- ============================================================
function NexusUI:CreateTab(window, config)
    local tab = {}
    tab.Window = window
    tab.Name = config.Name or "Tab"
    tab.Icon = config.Icon or "📁"
    tab.Visible = false
    tab.Buttons = {}
    tab.CurrentY = 10
    
    -- Criar botão da aba
    tab.Button = Instance.new("TextButton")
    tab.Button.Size = UDim2.new(1, -10, 0, 40)
    tab.Button.Position = UDim2.new(0, 5, 0, (#window.Tabs) * 45 + 5)
    tab.Button.Text = tab.Icon .. "  " .. tab.Name
    tab.Button.TextColor3 = NexusUI.Theme.TextSecondary
    tab.Button.BackgroundColor3 = NexusUI.Theme.Secondary
    tab.Button.BackgroundTransparency = 0.5
    tab.Button.TextSize = 13
    tab.Button.Font = Enum.Font.Gotham
    tab.Button.TextXAlignment = Enum.TextXAlignment.Left
    tab.Button.AutoButtonColor = false
    tab.Button.Parent = window.TabContainer
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = tab.Button
    
    tab.Button.MouseEnter:Connect(function()
        if not tab.Visible then
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if not tab.Visible then
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        end
    end)
    
    -- Container do conteúdo da aba
    tab.Container = Instance.new("Frame")
    tab.Container.Size = UDim2.new(1, -20, 1, -20)
    tab.Container.Position = UDim2.new(0, 10, 0, 10)
    tab.Container.BackgroundTransparency = 1
    tab.Container.Visible = false
    tab.Container.Parent = window.ContentContainer
    
    -- Função para mostrar a aba
    function tab:Show()
        if window.CurrentTab then
            window.CurrentTab.Container.Visible = false
            window.CurrentTab.Button.BackgroundColor3 = NexusUI.Theme.Secondary
            window.CurrentTab.Button.BackgroundTransparency = 0.5
            window.CurrentTab.Button.TextColor3 = NexusUI.Theme.TextSecondary
        end
        
        window.CurrentTab = self
        self.Container.Visible = true
        self.Button.BackgroundColor3 = NexusUI.Theme.Primary
        self.Button.BackgroundTransparency = 0.2
        self.Button.TextColor3 = NexusUI.Theme.Text
        
        window:UpdateCanvas()
    end
    
    -- Auto mostrar se for a primeira aba
    if #window.Tabs == 0 then
        tab:Show()
    end
    
    tab.Button.MouseButton1Click:Connect(function()
        tab:Show()
    end)
    
    table.insert(window.Tabs, tab)
    
    return tab
end

-- ============================================================
-- FUNÇÃO PARA CRIAR SEÇÃO
-- ============================================================
function NexusUI:CreateSection(tab, title)
    local section = {}
    section.Tab = tab
    section.Title = title
    
    section.Frame = Instance.new("Frame")
    section.Frame.Size = UDim2.new(1, 0, 0, 40)
    section.Frame.Position = UDim2.new(0, 0, 0, tab.CurrentY)
    section.Frame.BackgroundColor3 = NexusUI.Theme.Secondary
    section.Frame.BackgroundTransparency = 0.3
    section.Frame.BorderSizePixel = 0
    section.Frame.Parent = tab.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = section.Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = title
    Label.TextColor3 = NexusUI.Theme.Primary
    Label.BackgroundTransparency = 1
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = section.Frame
    
    tab.CurrentY = tab.CurrentY + 50
    
    return section
end

-- ============================================================
-- FUNÇÃO PARA CRIAR TOGGLE
-- ============================================================
function NexusUI:CreateToggle(tab, config)
    local toggle = {}
    toggle.Tab = tab
    toggle.Title = config.Title or "Toggle"
    toggle.Desc = config.Desc or ""
    toggle.Callback = config.Callback or function() end
    toggle.Value = config.Default or false
    
    toggle.Frame = Instance.new("Frame")
    toggle.Frame.Size = UDim2.new(1, 0, 0, 50)
    toggle.Frame.Position = UDim2.new(0, 0, 0, tab.CurrentY)
    toggle.Frame.BackgroundColor3 = NexusUI.Theme.Secondary
    toggle.Frame.BackgroundTransparency = 0.2
    toggle.Frame.BorderSizePixel = 0
    toggle.Frame.Parent = tab.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = toggle.Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.Text = toggle.Title
    Label.TextColor3 = NexusUI.Theme.Text
    Label.BackgroundTransparency = 1
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = toggle.Frame
    
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -70, 0, 20)
    DescLabel.Position = UDim2.new(0, 10, 0, 25)
    DescLabel.Text = toggle.Desc
    DescLabel.TextColor3 = NexusUI.Theme.TextSecondary
    DescLabel.BackgroundTransparency = 1
    DescLabel.TextSize = 10
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = toggle.Frame
    
    toggle.Button = Instance.new("TextButton")
    toggle.Button.Size = UDim2.new(0, 50, 0, 28)
    toggle.Button.Position = UDim2.new(1, -60, 0, 11)
    toggle.Button.Text = toggle.Value and "ON" or "OFF"
    toggle.Button.TextColor3 = NexusUI.Theme.Text
    toggle.Button.BackgroundColor3 = toggle.Value and NexusUI.Theme.Success or NexusUI.Theme.Button
    toggle.Button.TextSize = 12
    toggle.Button.Font = Enum.Font.GothamBold
    toggle.Button.AutoButtonColor = false
    toggle.Button.Parent = toggle.Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = toggle.Button
    
    function toggle:SetValue(value)
        self.Value = value
        self.Button.Text = value and "ON" or "OFF"
        self.Button.BackgroundColor3 = value and NexusUI.Theme.Success or NexusUI.Theme.Button
        self.Callback(value)
    end
    
    toggle.Button.MouseButton1Click:Connect(function()
        toggle:SetValue(not toggle.Value)
    end)
    
    tab.CurrentY = tab.CurrentY + 60
    
    return toggle
end

-- ============================================================
-- FUNÇÃO PARA CRIAR SLIDER
-- ============================================================
function NexusUI:CreateSlider(tab, config)
    local slider = {}
    slider.Tab = tab
    slider.Title = config.Title or "Slider"
    slider.Desc = config.Desc or ""
    slider.Min = config.Min or 0
    slider.Max = config.Max or 100
    slider.Value = config.Default or slider.Min
    slider.Callback = config.Callback or function() end
    
    slider.Frame = Instance.new("Frame")
    slider.Frame.Size = UDim2.new(1, 0, 0, 70)
    slider.Frame.Position = UDim2.new(0, 0, 0, tab.CurrentY)
    slider.Frame.BackgroundColor3 = NexusUI.Theme.Secondary
    slider.Frame.BackgroundTransparency = 0.2
    slider.Frame.BorderSizePixel = 0
    slider.Frame.Parent = tab.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = slider.Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.Text = slider.Title
    Label.TextColor3 = NexusUI.Theme.Text
    Label.BackgroundTransparency = 1
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = slider.Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    ValueLabel.Text = tostring(slider.Value)
    ValueLabel.TextColor3 = NexusUI.Theme.Primary
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = slider.Frame
    
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -20, 0, 20)
    DescLabel.Position = UDim2.new(0, 10, 0, 25)
    DescLabel.Text = slider.Desc
    DescLabel.TextColor3 = NexusUI.Theme.TextSecondary
    DescLabel.BackgroundTransparency = 1
    DescLabel.TextSize = 10
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = slider.Frame
    
    slider.SliderFrame = Instance.new("Frame")
    slider.SliderFrame.Size = UDim2.new(1, -20, 0, 4)
    slider.SliderFrame.Position = UDim2.new(0, 10, 0, 50)
    slider.SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    slider.SliderFrame.BorderSizePixel = 0
    slider.SliderFrame.Parent = slider.Frame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 2)
    SliderCorner.Parent = slider.SliderFrame
    
    slider.Fill = Instance.new("Frame")
    slider.Fill.Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0)
    slider.Fill.BackgroundColor3 = NexusUI.Theme.Primary
    slider.Fill.BorderSizePixel = 0
    slider.Fill.Parent = slider.SliderFrame
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 2)
    FillCorner.Parent = slider.Fill
    
    function slider:SetValue(value)
        self.Value = math.clamp(value, self.Min, self.Max)
        local percent = (self.Value - self.Min) / (self.Max - self.Min)
        self.Fill.Size = UDim2.new(percent, 0, 1, 0)
        ValueLabel.Text = tostring(math.floor(self.Value * 10) / 10)
        self.Callback(self.Value)
    end
    
    local dragging = false
    slider.SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - slider.SliderFrame.AbsolutePosition.X) / slider.SliderFrame.AbsoluteSize.X, 0, 1)
            local newValue = slider.Min + (slider.Max - slider.Min) * percent
            slider:SetValue(newValue)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - slider.SliderFrame.AbsolutePosition.X) / slider.SliderFrame.AbsoluteSize.X, 0, 1)
            local newValue = slider.Min + (slider.Max - slider.Min) * percent
            slider:SetValue(newValue)
        end
    end)
    
    tab.CurrentY = tab.CurrentY + 80
    
    return slider
end

-- ============================================================
-- FUNÇÃO PARA CRIAR BUTTON
-- ============================================================
function NexusUI:CreateButton(tab, config)
    local button = {}
    button.Tab = tab
    button.Title = config.Title or "Button"
    button.Callback = config.Callback or function() end
    
    button.Frame = Instance.new("Frame")
    button.Frame.Size = UDim2.new(1, 0, 0, 45)
    button.Frame.Position = UDim2.new(0, 0, 0, tab.CurrentY)
    button.Frame.BackgroundColor3 = NexusUI.Theme.Secondary
    button.Frame.BackgroundTransparency = 0.2
    button.Frame.BorderSizePixel = 0
    button.Frame.Parent = tab.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = button.Frame
    
    button.Button = Instance.new("TextButton")
    button.Button.Size = UDim2.new(1, -20, 0, 35)
    button.Button.Position = UDim2.new(0, 10, 0, 5)
    button.Button.Text = button.Title
    button.Button.TextColor3 = NexusUI.Theme.Text
    button.Button.BackgroundColor3 = NexusUI.Theme.Primary
    button.Button.BackgroundTransparency = 0.3
    button.Button.TextSize = 13
    button.Button.Font = Enum.Font.GothamBold
    button.Button.AutoButtonColor = false
    button.Button.Parent = button.Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = button.Button
    
    button.Button.MouseEnter:Connect(function()
        TweenService:Create(button.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    button.Button.MouseLeave:Connect(function()
        TweenService:Create(button.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    button.Button.MouseButton1Click:Connect(function()
        button.Callback()
    end)
    
    tab.CurrentY = tab.CurrentY + 55
    
    return button
end

-- ============================================================
-- FUNÇÃO PARA CRIAR DROPDOWN
-- ============================================================
function NexusUI:CreateDropdown(tab, config)
    local dropdown = {}
    dropdown.Tab = tab
    dropdown.Title = config.Title or "Dropdown"
    dropdown.Options = config.Options or {}
    dropdown.Default = config.Default or dropdown.Options[1]
    dropdown.Value = dropdown.Default
    dropdown.Callback = config.Callback or function() end
    dropdown.Open = false
    
    dropdown.Frame = Instance.new("Frame")
    dropdown.Frame.Size = UDim2.new(1, 0, 0, 50)
    dropdown.Frame.Position = UDim2.new(0, 0, 0, tab.CurrentY)
    dropdown.Frame.BackgroundColor3 = NexusUI.Theme.Secondary
    dropdown.Frame.BackgroundTransparency = 0.2
    dropdown.Frame.BorderSizePixel = 0
    dropdown.Frame.Parent = tab.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = dropdown.Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.Text = dropdown.Title
    Label.TextColor3 = NexusUI.Theme.Text
    Label.BackgroundTransparency = 1
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = dropdown.Frame
    
    dropdown.Button = Instance.new("TextButton")
    dropdown.Button.Size = UDim2.new(1, -20, 0, 25)
    dropdown.Button.Position = UDim2.new(0, 10, 0, 20)
    dropdown.Button.Text = dropdown.Value
    dropdown.Button.TextColor3 = NexusUI.Theme.Text
    dropdown.Button.BackgroundColor3 = NexusUI.Theme.Button
    dropdown.Button.TextSize = 12
    dropdown.Button.Font = Enum.Font.Gotham
    dropdown.Button.AutoButtonColor = false
    dropdown.Button.Parent = dropdown.Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = dropdown.Button
    
    function dropdown:SetValue(value)
        self.Value = value
        self.Button.Text = value
        self.Callback(value)
        if self.List then
            self.List:Destroy()
            self.Open = false
        end
    end
    
    dropdown.Button.MouseButton1Click:Connect(function()
        if dropdown.Open then
            if dropdown.List then dropdown.List:Destroy() end
            dropdown.Open = false
            return
        end
        
        dropdown.Open = true
        dropdown.List = Instance.new("Frame")
        dropdown.List.Size = UDim2.new(1, -20, 0, #dropdown.Options * 30)
        dropdown.List.Position = UDim2.new(0, 10, 0, 45)
        dropdown.List.BackgroundColor3 = NexusUI.Theme.Secondary
        dropdown.List.BackgroundTransparency = 0.1
        dropdown.List.BorderSizePixel = 0
        dropdown.List.Parent = dropdown.Frame
        
        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 6)
        ListCorner.Parent = dropdown.List
        
        for i, option in ipairs(dropdown.Options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1)*30)
            optBtn.Text = option
            optBtn.TextColor3 = NexusUI.Theme.Text
            optBtn.BackgroundColor3 = NexusUI.Theme.Secondary
            optBtn.BackgroundTransparency = 0
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.Gotham
            optBtn.AutoButtonColor = false
            optBtn.Parent = dropdown.List
            
            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
            end)
            
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                dropdown:SetValue(option)
            end)
        end
    end)
    
    tab.CurrentY = tab.CurrentY + 60
    
    return dropdown
end

-- ============================================================
-- FUNÇÃO PARA NOTIFICAÇÃO
-- ============================================================
function NexusUI:Notify(config)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = config.Title or "NEXUS",
            Text = config.Content or "",
            Duration = config.Duration or 3,
            Icon = "rbxassetid://4483362458"
        })
    end)
end

-- ============================================================
-- FUNÇÃO PARA MUDAR TEMA
-- ============================================================
function NexusUI:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = themeName
        self.Theme = self.Themes[themeName]
        
        -- Atualizar todas as cores da UI (implementar se necessário)
    end
end

-- ============================================================
-- RETORNAR O MÓDULO
-- ============================================================
return NexusUI
