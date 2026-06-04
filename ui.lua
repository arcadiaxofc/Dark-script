-- ==================== NEXUS UI v7.0 - ESTILO CLÁSSICO COM MINIMIZAR ====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ==================== CORES (ESTILO CLASSICO) ====================
local Colors = {
    -- Fundos
    MainBg = Color3.fromRGB(20, 20, 25),
    SidebarBg = Color3.fromRGB(15, 15, 20),
    HeaderBg = Color3.fromRGB(25, 25, 30),
    ElementBg = Color3.fromRGB(30, 30, 38),
    ElementHover = Color3.fromRGB(40, 40, 48),
    
    -- Textos
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 170),
    Title = Color3.fromRGB(230, 70, 60),
    
    -- Botões e Estados
    Primary = Color3.fromRGB(230, 70, 60),
    Success = Color3.fromRGB(0, 180, 0),
    Danger = Color3.fromRGB(200, 50, 40),
    Warn = Color3.fromRGB(255, 180, 0),
    
    -- Bordas
    Border = Color3.fromRGB(45, 45, 55),
}

-- ==================== UI PRINCIPAL ====================
local NexusUI = {
    Windows = {},
    CurrentWindow = nil,
    Toggles = {},
    Sliders = {},
}

-- ==================== CRIAR JANELA ====================
function NexusUI:CreateWindow(config)
    config = config or {}
    
    local gui = Instance.new("ScreenGui")
    gui.Name = config.Name or "NexusUI"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    
    -- Janela principal
    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, config.Width or 520, 0, config.Height or 450)
    window.Position = UDim2.new(0.5, -(config.Width or 520)/2, 0.5, -(config.Height or 450)/2)
    window.BackgroundColor3 = Colors.MainBg
    window.BorderSizePixel = 0
    window.Parent = gui
    window.Active = true
    window.Draggable = true
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
    
    -- Sombra da janela
    local shadow = Instance.new("Frame", window)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = -1
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)
    
    -- Linha de destaque no topo
    local accentLine = Instance.new("Frame", window)
    accentLine.Size = UDim2.new(1, 0, 0, 3)
    accentLine.BackgroundColor3 = Colors.Primary
    accentLine.BorderSizePixel = 0
    Instance.new("UICorner", accentLine).CornerRadius = UDim.new(0, 8)
    
    -- ==================== CABEÇALHO ====================
    local header = Instance.new("Frame", window)
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Colors.HeaderBg
    header.BorderSizePixel = 0
    
    local headerTitle = Instance.new("TextLabel", header)
    headerTitle.Size = UDim2.new(1, -110, 1, 0)
    headerTitle.Position = UDim2.new(0, 15, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = config.Title or "NEXUS v7.0"
    headerTitle.TextColor3 = Colors.Title
    headerTitle.TextSize = 16
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local headerSub = Instance.new("TextLabel", header)
    headerSub.Size = UDim2.new(1, -110, 0, 15)
    headerSub.Position = UDim2.new(0, 15, 0, 28)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = config.Subtitle or "84 Funções | Delta Ready"
    headerSub.TextColor3 = Colors.TextDim
    headerSub.TextSize = 10
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botão minimizar
    local minimizeBtn = Instance.new("TextButton", header)
    minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    minimizeBtn.Position = UDim2.new(1, -45, 0.5, -14)
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = Colors.Text
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BackgroundColor3 = Colors.ElementBg
    minimizeBtn.BorderSizePixel = 0
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -12, 0.5, -14)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Danger
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = Colors.ElementBg
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    -- ==================== SIDEBAR ====================
    local sidebar = Instance.new("Frame", window)
    sidebar.Size = UDim2.new(0, 140, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = Colors.SidebarBg
    sidebar.BorderSizePixel = 0
    
    -- Linha separadora da sidebar
    local sidebarLine = Instance.new("Frame", sidebar)
    sidebarLine.Size = UDim2.new(0, 1, 1, 0)
    sidebarLine.Position = UDim2.new(1, -1, 0, 0)
    sidebarLine.BackgroundColor3 = Colors.Border
    sidebarLine.BorderSizePixel = 0
    
    -- Botões da sidebar
    local sidebarButtons = {}
    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local sidebarPadding = Instance.new("UIPadding", sidebar)
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    
    -- ==================== ÁREA DE CONTEÚDO ====================
    local contentArea = Instance.new("ScrollingFrame", window)
    contentArea.Size = UDim2.new(1, -145, 1, -55)
    contentArea.Position = UDim2.new(0, 145, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.ScrollBarThickness = 4
    contentArea.ScrollBarImageColor3 = Colors.Primary
    contentArea.Visible = true
    
    local contentLayout = Instance.new("UIListLayout", contentArea)
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local contentPadding = Instance.new("UIPadding", contentArea)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    
    -- Atualizar Canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- ==================== FPS ====================
    local fpsLabel = Instance.new("TextLabel", window)
    fpsLabel.Size = UDim2.new(0, 100, 0, 15)
    fpsLabel.Position = UDim2.new(0, 10, 1, -18)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Colors.TextDim
    fpsLabel.TextSize = 10
    fpsLabel.Font = Enum.Font.Gotham
    
    local frameCount, lastTime = 0, tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. frameCount
            frameCount = 0
            lastTime = now
        end
    end)
    
    -- ==================== SISTEMA DE MINIMIZAR ====================
    local minimized = false
    local originalHeight = config.Height or 450
    local originalWidth = config.Width or 520
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            -- Minimizar
            TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, originalWidth, 0, 45)
            }):Play()
            TweenService:Create(sidebar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 0, 1, -45)
            }):Play()
            contentArea.Visible = false
            minimizeBtn.Text = "□"
        else
            -- Restaurar
            TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, originalWidth, 0, originalHeight)
            }):Play()
            TweenService:Create(sidebar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 140, 1, -45)
            }):Play()
            contentArea.Visible = true
            minimizeBtn.Text = "─"
        end
    end)
    
    -- ==================== DRAG ====================
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- ==================== FECHAR ====================
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        gui:Destroy()
    end)
    
    -- ==================== ESTRUTURA ====================
    local windowData = {
        Gui = gui,
        Frame = window,
        Sidebar = sidebar,
        SidebarLayout = sidebarLayout,
        Content = contentArea,
        ContentLayout = contentLayout,
        Tabs = {},
        CurrentTab = nil,
        Minimize = function()
            if not minimized then
                minimized = true
                TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, originalWidth, 0, 45)
                }):Play()
                TweenService:Create(sidebar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 0, 1, -45)
                }):Play()
                contentArea.Visible = false
                minimizeBtn.Text = "□"
            end
        end,
        Restore = function()
            if minimized then
                minimized = false
                TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, originalWidth, 0, originalHeight)
                }):Play()
                TweenService:Create(sidebar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 140, 1, -45)
                }):Play()
                contentArea.Visible = true
                minimizeBtn.Text = "─"
            end
        end,
        IsMinimized = function() return minimized end
    }
    
    table.insert(NexusUI.Windows, windowData)
    NexusUI.CurrentWindow = windowData
    
    -- Animação de entrada
    window.Size = UDim2.new(0, 0, 0, config.Height or 450)
    TweenService:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, config.Width or 520, 0, config.Height or 450)
    }):Play()
    
    return windowData
end

-- ==================== CRIAR TAB (SIDEBAR) ====================
function NexusUI:CreateTab(window, config)
    config = config or {}
    
    -- Botão da sidebar
    local btn = Instance.new("TextButton", window.Sidebar)
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.Text = "  " .. (config.Icon or "📁") .. " " .. config.Name
    btn.TextColor3 = Colors.TextDim
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Colors.SidebarBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- Frame de conteúdo da tab
    local tabContent = Instance.new("Frame", window.Content)
    tabContent.Size = UDim2.new(1, 0, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.LayoutOrder = config.Order or #window.Tabs + 1
    
    local tabLayout = Instance.new("UIListLayout", tabContent)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabPadding = Instance.new("UIPadding", tabContent)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    
    -- Selecionar tab
    local function select()
        for _, t in pairs(window.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Colors.SidebarBg
            t.Button.TextColor3 = Colors.TextDim
        end
        tabContent.Visible = true
        btn.BackgroundColor3 = Colors.ElementBg
        btn.TextColor3 = Colors.Primary
        window.CurrentTab = config.Name
    end
    
    btn.MouseButton1Click:Connect(select)
    
    -- Atualizar altura do conteúdo
    local function updateHeight()
        tabContent.Size = UDim2.new(1, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
    
    local tabData = {
        Name = config.Name,
        Icon = config.Icon,
        Button = btn,
        Content = tabContent,
        Layout = tabLayout,
        Select = select
    }
    
    table.insert(window.Tabs, tabData)
    
    -- Selecionar primeira tab se for a primeira
    if #window.Tabs == 1 then
        select()
    end
    
    return tabData
end

-- ==================== CRIAR SEÇÃO ====================
function NexusUI:CreateSection(tab, title)
    local section = Instance.new("Frame", tab.Content)
    section.Size = UDim2.new(1, 0, 0, 38)
    section.BackgroundColor3 = Colors.ElementBg
    section.BorderSizePixel = 0
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    
    local titleLabel = Instance.new("TextLabel", section)
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Colors.Primary
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame", section)
    line.Size = UDim2.new(0, 2, 1, -10)
    line.Position = UDim2.new(0, 0, 0, 5)
    line.BackgroundColor3 = Colors.Primary
    line.BorderSizePixel = 0
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 2)
    
    return section
end

-- ==================== CRIAR TOGGLE ====================
function NexusUI:CreateToggle(tab, config)
    config = config or {}
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    -- Título
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Toggle"
    title.TextColor3 = Colors.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Descrição
    local desc = Instance.new("TextLabel", frame)
    desc.Size = UDim2.new(1, -80, 0, 16)
    desc.Position = UDim2.new(0, 12, 0, 24)
    desc.BackgroundTransparency = 1
    desc.Text = config.Desc or ""
    desc.TextColor3 = Colors.TextDim
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Botão toggle
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 55, 0, 26)
    toggle.Position = UDim2.new(1, -12, 0.5, -13)
    toggle.Text = "OFF"
    toggle.TextColor3 = Colors.Text
    toggle.TextSize = 11
    toggle.Font = Enum.Font.GothamBold
    toggle.BackgroundColor3 = Colors.Danger
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)
    
    local state = false
    local callback = config.Callback or function() end
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Colors.Success or Colors.Danger
        callback(state)
    end)
    
    return {
        Frame = frame,
        Toggle = toggle,
        Set = function(v)
            state = v
            toggle.Text = state and "ON" or "OFF"
            toggle.BackgroundColor3 = state and Colors.Success or Colors.Danger
            callback(state)
        end,
        Get = function() return state end
    }
end

-- ==================== CRIAR BOTÃO ====================
function NexusUI:CreateButton(tab, config)
    config = config or {}
    
    local btn = Instance.new("TextButton", tab.Content)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Text = config.Title or "Button"
    btn.TextColor3 = Colors.Text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Colors.ElementBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Colors.ElementHover
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Colors.ElementBg
    end)
    
    return btn
end

-- ==================== CRIAR SLIDER ====================
function NexusUI:CreateSlider(tab, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or 50
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundColor3 = Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Slider"
    title.TextColor3 = Colors.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -62, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = Colors.Primary
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Barra do slider
    local sliderBar = Instance.new("Frame", frame)
    sliderBar.Size = UDim2.new(1, -24, 0, 4)
    sliderBar.Position = UDim2.new(0, 12, 0, 40)
    sliderBar.BackgroundColor3 = Colors.Secondary
    sliderBar.BorderSizePixel = 0
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Primary
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", sliderBar)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Colors.Text
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local callback = config.Callback or function() end
    
    local function update(val)
        val = math.clamp(val, min, max)
        local percent = (val - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -6, 0.5, -6)
        valueLabel.Text = tostring(math.floor(val))
        callback(val)
        return val
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            value = update(min + percent * (max - min))
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            value = update(min + percent * (max - min))
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    update(value)
    
    return {
        Frame = frame,
        Set = function(v) value = update(v) end,
        Get = function() return value end
    }
end

-- ==================== CRIAR DROPDOWN ====================
function NexusUI:CreateDropdown(tab, config)
    config = config or {}
    local options = config.Options or {"Option 1", "Option 2"}
    local selected = config.Default or options[1]
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Dropdown"
    title.TextColor3 = Colors.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdownBtn = Instance.new("TextButton", frame)
    dropdownBtn.Size = UDim2.new(0, 120, 0, 30)
    dropdownBtn.Position = UDim2.new(1, -12, 0.5, -15)
    dropdownBtn.Text = selected
    dropdownBtn.TextColor3 = Colors.Text
    dropdownBtn.TextSize = 12
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.BackgroundColor3 = Colors.Secondary
    dropdownBtn.BorderSizePixel = 0
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6)
    
    local dropdownContent = Instance.new("Frame", tab.Content)
    dropdownContent.Size = UDim2.new(1, 0, 0, 0)
    dropdownContent.Position = UDim2.new(0, 0, 0, 42)
    dropdownContent.BackgroundColor3 = Colors.ElementBg
    dropdownContent.BorderSizePixel = 0
    dropdownContent.ClipsDescendants = true
    dropdownContent.Visible = false
    Instance.new("UICorner", dropdownContent).CornerRadius = UDim.new(0, 6)
    
    local contentLayout = Instance.new("UIListLayout", dropdownContent)
    contentLayout.Padding = UDim.new(0, 2)
    
    local callback = config.Callback or function() end
    
    for _, opt in pairs(options) do
        local optBtn = Instance.new("TextButton", dropdownContent)
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.Text = opt
        optBtn.TextColor3 = Colors.TextDim
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BackgroundColor3 = Colors.ElementBg
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        
        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundColor3 = Colors.ElementHover
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundColor3 = Colors.ElementBg
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            dropdownBtn.Text = selected
            dropdownContent.Visible = false
            dropdownContent.Size = UDim2.new(1, 0, 0, 0)
            callback(selected)
        end)
    end
    
    dropdownContent.Size = UDim2.new(1, 0, 0, #options * 32)
    
    local open = false
    dropdownBtn.MouseButton1Click:Connect(function()
        open = not open
        dropdownContent.Visible = open
    end)
    
    return {
        Frame = frame,
        Select = function(opt)
            for _, o in pairs(options) do
                if o == opt then
                    selected = opt
                    dropdownBtn.Text = selected
                    callback(selected)
                    break
                end
            end
        end,
        Get = function() return selected end
    }
end

-- ==================== CRIAR INPUT ====================
function NexusUI:CreateInput(tab, config)
    config = config or {}
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Input"
    title.TextColor3 = Colors.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0, 150, 0, 30)
    input.Position = UDim2.new(1, -12, 0.5, -15)
    input.PlaceholderText = config.Placeholder or "Digite aqui..."
    input.Text = config.Default or ""
    input.TextColor3 = Colors.Text
    input.PlaceholderColor3 = Colors.TextDim
    input.TextSize = 12
    input.Font = Enum.Font.Gotham
    input.BackgroundColor3 = Colors.Secondary
    input.BorderSizePixel = 0
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    local callback = config.Callback or function() end
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        callback(input.Text)
    end)
    
    return {
        Frame = frame,
        Set = function(v) input.Text = v end,
        Get = function() return input.Text end
    }
end

-- ==================== CRIAR LABEL ====================
function NexusUI:CreateLabel(tab, config)
    config = config or {}
    
    local label = Instance.new("TextLabel", tab.Content)
    label.Size = UDim2.new(1, 0, 0, 32)
    label.Text = config.Title or "Label"
    label.TextColor3 = Colors.TextDim
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.BackgroundColor3 = Colors.ElementBg
    label.BorderSizePixel = 0
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    
    return label
end

-- ==================== CRIAR KEYBIND ====================
function NexusUI:CreateKeybind(tab, config)
    config = config or {}
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Keybind"
    title.TextColor3 = Colors.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyBtn = Instance.new("TextButton", frame)
    keyBtn.Size = UDim2.new(0, 80, 0, 30)
    keyBtn.Position = UDim2.new(1, -12, 0.5, -15)
    keyBtn.Text = config.Default or "F"
    keyBtn.TextColor3 = Colors.Text
    keyBtn.TextSize = 12
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.BackgroundColor3 = Colors.Secondary
    keyBtn.BorderSizePixel = 0
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)
    
    local key = config.Default or "F"
    local callback = config.Callback or function() end
    local listening = false
    
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local keyName = nil
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                keyName = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyName = "Mouse1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyName = "Mouse2"
            end
            
            if keyName then
                key = keyName
                keyBtn.Text = key
                listening = false
                connection:Disconnect()
                callback(key)
            end
        end)
        
        task.wait(5)
        if listening then
            listening = false
            keyBtn.Text = key
            connection:Disconnect()
        end
    end)
    
    return {
        Frame = frame,
        Set = function(k) key = k keyBtn.Text = k end,
        Get = function() return key end
    }
end

-- ==================== EXPORTAR ====================
return NexusUI
