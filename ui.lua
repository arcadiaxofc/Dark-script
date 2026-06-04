-- ==================== NEXUS UI LIBRARY v5.0 - LIMPA E ORGANIZADA ====================
local NexusUI = {}
NexusUI.__index = NexusUI

-- ==================== CORES ====================
NexusUI.Colors = {
    MainBg = Color3.fromRGB(20, 20, 25),
    SidebarBg = Color3.fromRGB(15, 15, 20),
    HeaderBg = Color3.fromRGB(25, 25, 30),
    ElementBg = Color3.fromRGB(30, 30, 38),
    ElementHover = Color3.fromRGB(40, 40, 48),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 170),
    Title = Color3.fromRGB(230, 70, 60),
    Success = Color3.fromRGB(0, 180, 0),
    Danger = Color3.fromRGB(200, 50, 40),
    Border = Color3.fromRGB(45, 45, 55),
}

-- ==================== SERVIÇOS ====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- ==================== DETECTAR DISPOSITIVO ====================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local viewport = Workspace.CurrentCamera.ViewportSize

-- ==================== AJUDA ====================
local function criarBotaoRedondo(texto, cor, pai, posX, posY, tamanho)
    local btn = Instance.new("TextButton", pai)
    btn.Size = UDim2.new(0, tamanho or 30, 0, tamanho or 30)
    btn.Position = UDim2.new(1, posX, 0.5, posY)
    btn.Text = texto
    btn.TextColor3 = NexusUI.Colors.Text
    btn.TextSize = tamanho and 16 or 14
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = cor
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function criarLabel(texto, tamanho, cor, pai, posX, posY)
    local lbl = Instance.new("TextLabel", pai)
    lbl.Size = UDim2.new(1, posX, 0, tamanho)
    lbl.Position = UDim2.new(0, posY or 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = cor
    lbl.TextSize = tamanho
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- ==================== CRIAR JANELA ====================
function NexusUI:CreateWindow(config)
    config = config or {}
    
    -- Tamanhos responsivos
    local winW = isMobile and math.min(config.Width or 560, viewport.X - 40) or (config.Width or 560)
    local winH = isMobile and math.min(config.Height or 500, viewport.Y - 100) or (config.Height or 500)
    local sideW = isMobile and 130 or 140
    
    -- GUI Principal
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusUI"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    -- Janela
    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, winW, 0, winH)
    win.Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2)
    win.BackgroundColor3 = NexusUI.Colors.MainBg
    win.BorderSizePixel = 0
    win.Parent = gui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
    
    -- Sombra
    local shadow = Instance.new("Frame", win)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = -1
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)
    
    -- Linha do topo
    local topLine = Instance.new("Frame", win)
    topLine.Size = UDim2.new(1, 0, 0, 3)
    topLine.BackgroundColor3 = NexusUI.Colors.Title
    topLine.BorderSizePixel = 0
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(0, 10)
    
    -- ==================== CABEÇALHO ====================
    local header = Instance.new("Frame", win)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = NexusUI.Colors.HeaderBg
    header.BorderSizePixel = 0
    
    -- Logo
    local logoOffset = 0
    if config.Logo then
        local logo = Instance.new("ImageLabel", header)
        logo.Size = UDim2.new(0, 32, 0, 32)
        logo.Position = UDim2.new(0, 12, 0.5, -16)
        logo.BackgroundTransparency = 1
        logo.Image = config.Logo
        Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 6)
        logoOffset = 50
    end
    
    -- Título
    local title = criarLabel(config.Title or "NEXUS v7.0", isMobile and 14 or 16, NexusUI.Colors.Title, header, -140, logoOffset + 5)
    title.Position = UDim2.new(0, logoOffset + 5, 0, 8)
    
    -- Subtítulo
    local subtitle = criarLabel(config.Subtitle or "Script Ultimate", isMobile and 9 or 10, NexusUI.Colors.TextDim, header, -140, logoOffset + 5)
    subtitle.Position = UDim2.new(0, logoOffset + 5, 0, 28)
    
    -- Botões do cabeçalho
    local minimizeBtn = criarBotaoRedondo("─", NexusUI.Colors.ElementBg, header, isMobile and -80 or -45, -15, isMobile and 32 or 30)
    local resizeBtn = criarBotaoRedondo("□", NexusUI.Colors.ElementBg, header, isMobile and -118 or -75, -15, isMobile and 32 or 30)
    local closeBtn = criarBotaoRedondo("✕", NexusUI.Colors.ElementBg, header, isMobile and -42 or -12, -15, isMobile and 32 or 30)
    closeBtn.TextColor3 = NexusUI.Colors.Danger
    
    -- ==================== SIDEBAR ====================
    local sidebar = Instance.new("ScrollingFrame", win)
    sidebar.Size = UDim2.new(0, sideW, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = NexusUI.Colors.SidebarBg
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local sidebarContent = Instance.new("Frame", sidebar)
    sidebarContent.Size = UDim2.new(1, 0, 0, 0)
    sidebarContent.BackgroundTransparency = 1
    sidebarContent.AutomaticSize = Enum.AutomaticSize.Y
    
    local sidebarLayout = Instance.new("UIListLayout", sidebarContent)
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local sidebarPadding = Instance.new("UIPadding", sidebarContent)
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingBottom = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    
    -- Linha separadora
    local separator = Instance.new("Frame", sidebar)
    separator.Size = UDim2.new(0, 1, 1, 0)
    separator.Position = UDim2.new(1, -1, 0, 0)
    separator.BackgroundColor3 = NexusUI.Colors.Border
    
    -- ==================== ÁREA DE CONTEÚDO ====================
    local contentFrame = Instance.new("Frame", win)
    contentFrame.Size = UDim2.new(1, -(sideW + 5), 1, -55)
    contentFrame.Position = UDim2.new(0, sideW + 5, 0, 55)
    contentFrame.BackgroundTransparency = 1
    
    local contentScroll = Instance.new("ScrollingFrame", contentFrame)
    contentScroll.Size = UDim2.new(1, 0, 1, 0)
    contentScroll.BackgroundTransparency = 1
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.ScrollBarThickness = isMobile and 2 or 4
    contentScroll.ScrollBarImageColor3 = NexusUI.Colors.Title
    
    local contentLayout = Instance.new("UIListLayout", contentScroll)
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local contentPadding = Instance.new("UIPadding", contentScroll)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 5)
    contentPadding.PaddingRight = UDim.new(0, 5)
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- ==================== SLIDER DE ESCALA ====================
    local scaleFrame = Instance.new("Frame", win)
    scaleFrame.Size = UDim2.new(0, 200, 0, 30)
    scaleFrame.Position = UDim2.new(0.5, -100, 1, -30)
    scaleFrame.BackgroundColor3 = NexusUI.Colors.ElementBg
    scaleFrame.BackgroundTransparency = 0.5
    scaleFrame.Visible = false
    Instance.new("UICorner", scaleFrame).CornerRadius = UDim.new(0, 6)
    
    local scaleLabel = Instance.new("TextLabel", scaleFrame)
    scaleLabel.Size = UDim2.new(0, 50, 1, 0)
    scaleLabel.Text = "100%"
    scaleLabel.TextColor3 = NexusUI.Colors.Text
    scaleLabel.TextSize = 10
    scaleLabel.Font = Enum.Font.GothamBold
    scaleLabel.BackgroundTransparency = 1
    
    local scaleBar = Instance.new("Frame", scaleFrame)
    scaleBar.Size = UDim2.new(0, 120, 0, 4)
    scaleBar.Position = UDim2.new(0, 60, 0.5, -2)
    scaleBar.BackgroundColor3 = NexusUI.Colors.Border
    Instance.new("UICorner", scaleBar).CornerRadius = UDim.new(1, 0)
    
    local scaleFill = Instance.new("Frame", scaleBar)
    scaleFill.Size = UDim2.new(1, 0, 1, 0)
    scaleFill.BackgroundColor3 = NexusUI.Colors.Title
    Instance.new("UICorner", scaleFill).CornerRadius = UDim.new(1, 0)
    
    local scaleKnob = Instance.new("Frame", scaleBar)
    scaleKnob.Size = UDim2.new(0, 10, 0, 10)
    scaleKnob.Position = UDim2.new(1, -5, 0.5, -5)
    scaleKnob.BackgroundColor3 = NexusUI.Colors.Text
    Instance.new("UICorner", scaleKnob).CornerRadius = UDim.new(1, 0)
    
    local currentScale = 1
    local minScale, maxScale = 0.6, 1.2
    
    local function atualizarEscala(escala)
        currentScale = math.clamp(escala, minScale, maxScale)
        local percent = (currentScale - minScale) / (maxScale - minScale)
        scaleFill.Size = UDim2.new(percent, 0, 1, 0)
        scaleKnob.Position = UDim2.new(percent, -5, 0.5, -5)
        scaleLabel.Text = math.floor(currentScale * 100) .. "%"
        
        local novaW = math.floor(winW * currentScale)
        local novaH = math.floor(winH * currentScale)
        local maxW = viewport.X - 40
        local maxH = viewport.Y - 100
        
        TweenService:Create(win, TweenInfo.new(0.2), {
            Size = UDim2.new(0, math.min(novaW, maxW), 0, math.min(novaH, maxH)),
            Position = UDim2.new(0.5, -math.min(novaW, maxW)/2, 0.5, -math.min(novaH, maxH)/2)
        }):Play()
        
        local novaSideW = math.floor(sideW * currentScale)
        sidebar.Size = UDim2.new(0, novaSideW, 1, -50)
        contentFrame.Size = UDim2.new(1, -(novaSideW + 5), 1, -55)
        contentFrame.Position = UDim2.new(0, novaSideW + 5, 0, 55)
    end
    
    local arrastandoEscala = false
    scaleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoEscala = true
            local perc = math.clamp((input.Position.X - scaleBar.AbsolutePosition.X) / scaleBar.AbsoluteSize.X, 0, 1)
            atualizarEscala(minScale + perc * (maxScale - minScale))
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if arrastandoEscala and input.UserInputType == Enum.UserInputType.MouseMovement then
            local perc = math.clamp((input.Position.X - scaleBar.AbsolutePosition.X) / scaleBar.AbsoluteSize.X, 0, 1)
            atualizarEscala(minScale + perc * (maxScale - minScale))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoEscala = false
        end
    end)
    
    local escalaVisivel = false
    resizeBtn.MouseButton1Click:Connect(function()
        escalaVisivel = not escalaVisivel
        scaleFrame.Visible = escalaVisivel
    end)
    
    -- ==================== FPS ====================
    local fpsLabel = Instance.new("TextLabel", win)
    fpsLabel.Size = UDim2.new(0, 180, 0, 15)
    fpsLabel.Position = UDim2.new(0, 10, 1, -18)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = NexusUI.Colors.TextDim
    fpsLabel.TextSize = 10
    fpsLabel.Font = Enum.Font.Gotham
    
    local frameCount, lastTime = 0, tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local agora = tick()
        if agora - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. frameCount
            frameCount = 0
            lastTime = agora
        end
    end)
    
    -- ==================== BOTÃO FLUTUANTE ====================
    local floating = Instance.new("TextButton", CoreGui)
    floating.Size = UDim2.new(0, isMobile and 45 or 50, 0, isMobile and 45 or 50)
    floating.Position = UDim2.new(1, isMobile and -55 or -60, 0.5, isMobile and -22 or -25)
    floating.Text = "⚡"
    floating.TextColor3 = NexusUI.Colors.Text
    floating.TextSize = isMobile and 20 or 24
    floating.Font = Enum.Font.GothamBold
    floating.BackgroundColor3 = NexusUI.Colors.Title
    floating.BorderSizePixel = 0
    floating.Visible = false
    Instance.new("UICorner", floating).CornerRadius = UDim.new(1, 0)
    
    local floatDrag = false
    floating.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then floatDrag = true end
    end)
    floating.InputEnded:Connect(function() floatDrag = false end)
    UserInputService.InputChanged:Connect(function(i)
        if floatDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math.clamp(i.Position.X - 25, 0, viewport.X - 50)
            local y = math.clamp(i.Position.Y - 25, 0, viewport.Y - 50)
            floating.Position = UDim2.new(0, x, 0, y)
        end
    end)
    
    -- ==================== MINIMIZAR/FECHAR ====================
    local minimizado = false
    local alturaOriginal = winH
    local larguraOriginal = winW
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimizado = not minimizado
        if minimizado then
            TweenService:Create(win, TweenInfo.new(0.3), {Size = UDim2.new(0, larguraOriginal, 0, 50)}):Play()
            contentFrame.Visible = false
            sidebar.Visible = false
            minimizeBtn.Text = "□"
            floating.Visible = true
        else
            TweenService:Create(win, TweenInfo.new(0.3), {Size = UDim2.new(0, larguraOriginal, 0, alturaOriginal)}):Play()
            contentFrame.Visible = true
            sidebar.Visible = true
            minimizeBtn.Text = "─"
            floating.Visible = false
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(win, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3)
        gui:Destroy()
        floating.Visible = true
    end)
    
    floating.MouseButton1Click:Connect(function()
        floating.Visible = false
        gui.Visible = true
        contentFrame.Visible = true
        sidebar.Visible = true
        minimizado = false
        minimizeBtn.Text = "─"
        TweenService:Create(win, TweenInfo.new(0.3), {Size = UDim2.new(0, larguraOriginal, 0, alturaOriginal)}):Play()
    end)
    
    -- ==================== DRAG ====================
    local arrastando, dragStart, posInicial = false
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastando = true
            dragStart = input.Position
            posInicial = win.Position
        end
    end)
    header.InputEnded:Connect(function() arrastando = false end)
    UserInputService.InputChanged:Connect(function(input)
        if arrastando and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local novaX = math.clamp(posInicial.X.Offset + delta.X, -winW/2, viewport.X - winW/2)
            local novaY = math.clamp(posInicial.Y.Offset + delta.Y, -winH/2, viewport.Y - winH/2)
            win.Position = UDim2.new(posInicial.X.Scale, novaX, posInicial.Y.Scale, novaY)
        end
    end)
    
    -- ==================== ANIMAÇÃO ====================
    win.Size = UDim2.new(0, 0, 0, winH)
    TweenService:Create(win, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, winW, 0, winH)}):Play()
    
    -- ==================== RETORNAR ====================
    return {
        Gui = gui,
        Frame = win,
        Sidebar = sidebarContent,
        Content = contentScroll,
        ContentLayout = contentLayout,
        Tabs = {},
        FloatingButton = floating,
        SetScale = function(s) atualizarEscala(s) end,
        GetScale = function() return currentScale end,
        Minimize = function()
            if not minimizado then
                minimizado = true
                TweenService:Create(win, TweenInfo.new(0.3), {Size = UDim2.new(0, larguraOriginal, 0, 50)}):Play()
                contentFrame.Visible = false
                sidebar.Visible = false
                minimizeBtn.Text = "□"
                floating.Visible = true
            end
        end,
        Restore = function()
            if minimizado then
                minimizado = false
                TweenService:Create(win, TweenInfo.new(0.3), {Size = UDim2.new(0, larguraOriginal, 0, alturaOriginal)}):Play()
                contentFrame.Visible = true
                sidebar.Visible = true
                minimizeBtn.Text = "─"
                floating.Visible = false
            end
        end,
        IsMinimized = function() return minimizado end
    }
end

-- ==================== CRIAR TAB ====================
function NexusUI:CreateTab(window, config)
    local btn = Instance.new("TextButton", window.Sidebar)
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Text = "  " .. (config.Icon or "📁") .. " " .. config.Name
    btn.TextColor3 = NexusUI.Colors.TextDim
    btn.TextSize = isMobile and 10 or 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = NexusUI.Colors.SidebarBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local content = Instance.new("ScrollingFrame", window.Content)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.ScrollBarThickness = 0
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", content)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    
    local function selecionar()
        for _, t in pairs(window.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = NexusUI.Colors.SidebarBg
            t.Button.TextColor3 = NexusUI.Colors.TextDim
        end
        content.Visible = true
        btn.BackgroundColor3 = NexusUI.Colors.ElementBg
        btn.TextColor3 = NexusUI.Colors.Title
        window.CurrentTab = config.Name
        window.Content.CanvasPosition = Vector2.new(0, 0)
    end
    
    btn.MouseButton1Click:Connect(selecionar)
    
    local tab = {
        Name = config.Name,
        Icon = config.Icon,
        Button = btn,
        Content = content,
        Select = selecionar
    }
    table.insert(window.Tabs, tab)
    if #window.Tabs == 1 then selecionar() end
    return tab
end

-- ==================== CRIAR SEÇÃO ====================
function NexusUI:CreateSection(tab, title)
    local section = Instance.new("Frame", tab.Content)
    section.Size = UDim2.new(1, 0, 0, 38)
    section.BackgroundColor3 = NexusUI.Colors.ElementBg
    section.BorderSizePixel = 0
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", section)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = NexusUI.Colors.Title
    lbl.TextSize = isMobile and 11 or 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame", section)
    line.Size = UDim2.new(0, 2, 1, -10)
    line.Position = UDim2.new(0, 0, 0, 5)
    line.BackgroundColor3 = NexusUI.Colors.Title
    line.BorderSizePixel = 0
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 2)
    
    return section
end

-- ==================== CRIAR TOGGLE ====================
function NexusUI:CreateToggle(tab, config)
    local altura = isMobile and 48 or 42
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, altura)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, isMobile and 8 or 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Toggle"
    title.TextColor3 = NexusUI.Colors.Text
    title.TextSize = isMobile and 12 or 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local desc = Instance.new("TextLabel", frame)
    desc.Size = UDim2.new(1, -80, 0, 16)
    desc.Position = UDim2.new(0, 12, 0, isMobile and 26 or 24)
    desc.BackgroundTransparency = 1
    desc.Text = config.Desc or ""
    desc.TextColor3 = NexusUI.Colors.TextDim
    desc.TextSize = isMobile and 9 or 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 55, 0, isMobile and 30 or 26)
    toggle.Position = UDim2.new(1, -12, 0.5, -15)
    toggle.Text = "OFF"
    toggle.TextColor3 = NexusUI.Colors.Text
    toggle.TextSize = 11
    toggle.Font = Enum.Font.GothamBold
    toggle.BackgroundColor3 = NexusUI.Colors.Danger
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)
    
    local estado = false
    local callback = config.Callback or function() end
    
    toggle.MouseButton1Click:Connect(function()
        estado = not estado
        toggle.Text = estado and "ON" or "OFF"
        toggle.BackgroundColor3 = estado and NexusUI.Colors.Success or NexusUI.Colors.Danger
        callback(estado)
    end)
    
    return {
        Frame = frame,
        Toggle = toggle,
        Set = function(v)
            estado = v
            toggle.Text = estado and "ON" or "OFF"
            toggle.BackgroundColor3 = estado and NexusUI.Colors.Success or NexusUI.Colors.Danger
            callback(estado)
        end,
        Get = function() return estado end
    }
end

-- ==================== CRIAR BOTÃO ====================
function NexusUI:CreateButton(tab, config)
    local btn = Instance.new("TextButton", tab.Content)
    btn.Size = UDim2.new(1, 0, 0, isMobile and 42 or 38)
    btn.Text = config.Title or "Button"
    btn.TextColor3 = NexusUI.Colors.Text
    btn.TextSize = isMobile and 12 or 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = NexusUI.Colors.ElementBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = NexusUI.Colors.ElementHover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = NexusUI.Colors.ElementBg
    end)
    
    return btn
end

-- ==================== CRIAR SLIDER ====================
function NexusUI:CreateSlider(tab, config)
    local min, max, valor = config.Min or 0, config.Max or 100, config.Default or 50
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, isMobile and 75 or 65)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Slider"
    title.TextColor3 = NexusUI.Colors.Text
    title.TextSize = isMobile and 12 or 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local valorLbl = Instance.new("TextLabel", frame)
    valorLbl.Size = UDim2.new(0, 50, 0, 20)
    valorLbl.Position = UDim2.new(1, -62, 0, 6)
    valorLbl.BackgroundTransparency = 1
    valorLbl.Text = tostring(valor)
    valorLbl.TextColor3 = NexusUI.Colors.Title
    valorLbl.TextSize = isMobile and 12 or 13
    valorLbl.Font = Enum.Font.GothamBold
    valorLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local barra = Instance.new("Frame", frame)
    barra.Size = UDim2.new(1, -24, 0, 4)
    barra.Position = UDim2.new(0, 12, 0, 45)
    barra.BackgroundColor3 = NexusUI.Colors.ElementBg
    Instance.new("UICorner", barra).CornerRadius = UDim.new(1, 0)
    
    local preenchimento = Instance.new("Frame", barra)
    preenchimento.Size = UDim2.new((valor - min) / (max - min), 0, 1, 0)
    preenchimento.BackgroundColor3 = NexusUI.Colors.Title
    Instance.new("UICorner", preenchimento).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", barra)
    knob.Size = UDim2.new(0, isMobile and 15 or 12, 0, isMobile and 15 or 12)
    knob.Position = UDim2.new((valor - min) / (max - min), isMobile and -7.5 or -6, 0.5, isMobile and -7.5 or -6)
    knob.BackgroundColor3 = NexusUI.Colors.Text
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local arrastando, callback = false, config.Callback or function() end
    
    local function atualizar(v)
        v = math.clamp(v, min, max)
        local perc = (v - min) / (max - min)
        preenchimento.Size = UDim2.new(perc, 0, 1, 0)
        knob.Position = UDim2.new(perc, isMobile and -7.5 or -6, 0.5, isMobile and -7.5 or -6)
        valorLbl.Text = tostring(math.floor(v))
        callback(v)
        return v
    end
    
    barra.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastando = true
            local perc = math.clamp((input.Position.X - barra.AbsolutePosition.X) / barra.AbsoluteSize.X, 0, 1)
            valor = atualizar(min + perc * (max - min))
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if arrastando and input.UserInputType == Enum.UserInputType.MouseMovement then
            local perc = math.clamp((input.Position.X - barra.AbsolutePosition.X) / barra.AbsoluteSize.X, 0, 1)
            valor = atualizar(min + perc * (max - min))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then arrastando = false end
    end)
    
    atualizar(valor)
    return {Frame = frame, Set = function(v) valor = atualizar(v) end, Get = function() return valor end}
end

-- ==================== CRIAR DROPDOWN ====================
function NexusUI:CreateDropdown(tab, config)
    local options = config.Options or {"Opção 1", "Opção 2"}
    local selecionado = config.Default or options[1]
    local altura = isMobile and 48 or 42
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, altura)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, isMobile and 8 or 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Dropdown"
    title.TextColor3 = NexusUI.Colors.Text
    title.TextSize = isMobile and 12 or 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, isMobile and 100 or 120, 0, isMobile and 32 or 30)
    btn.Position = UDim2.new(1, -12, 0.5, -16)
    btn.Text = selecionado
    btn.TextColor3 = NexusUI.Colors.Text
    btn.TextSize = isMobile and 11 or 12
    btn.Font = Enum.Font.Gotham
    btn.BackgroundColor3 = NexusUI.Colors.ElementBg
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local content = Instance.new("Frame", frame)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 1, 2)
    content.BackgroundColor3 = NexusUI.Colors.ElementBg
    content.ClipsDescendants = true
    content.Visible = false
    content.ZIndex = 10
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 6)
    
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 2)
    
    local callback = config.Callback or function() end
    
    for _, opt in pairs(options) do
        local optBtn = Instance.new("TextButton", content)
        optBtn.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
        optBtn.Text = opt
        optBtn.TextColor3 = NexusUI.Colors.TextDim
        optBtn.TextSize = isMobile and 11 or 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        
        optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = NexusUI.Colors.ElementHover end)
        optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = NexusUI.Colors.ElementBg end)
        optBtn.MouseButton1Click:Connect(function()
            selecionado = opt
            btn.Text = selecionado
            content.Visible = false
            content.Size = UDim2.new(1, 0, 0, 0)
            callback(selecionado)
        end)
    end
    
    content.Size = UDim2.new(1, 0, 0, #options * (isMobile and 37 or 32))
    
    local aberto = false
    btn.MouseButton1Click:Connect(function()
        aberto = not aberto
        content.Visible = aberto
    end)
    
    return {Frame = frame, Select = function(opt) for _, o in pairs(options) do if o == opt then selecionado = opt btn.Text = selecionado callback(selecionado) break end end end, Get = function() return selecionado end}
end

-- ==================== CRIAR INPUT ====================
function NexusUI:CreateInput(tab, config)
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, isMobile and 55 or 50)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, isMobile and 8 or 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Input"
    title.TextColor3 = NexusUI.Colors.Text
    title.TextSize = isMobile and 12 or 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0, isMobile and 120 or 150, 0, isMobile and 32 or 30)
    input.Position = UDim2.new(1, -12, 0.5, -16)
    input.PlaceholderText = config.Placeholder or "Digite aqui..."
    input.Text = config.Default or ""
    input.TextColor3 = NexusUI.Colors.Text
    input.PlaceholderColor3 = NexusUI.Colors.TextDim
    input.TextSize = isMobile and 11 or 12
    input.Font = Enum.Font.Gotham
    input.BackgroundColor3 = NexusUI.Colors.ElementBg
    input.BorderSizePixel = 0
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    local callback = config.Callback or function() end
    input:GetPropertyChangedSignal("Text"):Connect(function() callback(input.Text) end)
    
    return {Frame = frame, Set = function(v) input.Text = v end, Get = function() return input.Text end}
end

-- ==================== CRIAR LABEL ====================
function NexusUI:CreateLabel(tab, config)
    local label = Instance.new("TextLabel", tab.Content)
    label.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
    label.Text = config.Title or "Label"
    label.TextColor3 = NexusUI.Colors.TextDim
    label.TextSize = isMobile and 11 or 12
    label.Font = Enum.Font.Gotham
    label.BackgroundColor3 = NexusUI.Colors.ElementBg
    label.BorderSizePixel = 0
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    return label
end

-- ==================== CRIAR KEYBIND ====================
function NexusUI:CreateKeybind(tab, config)
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, isMobile and 48 or 42)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 12, 0, isMobile and 8 or 6)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Keybind"
    title.TextColor3 = NexusUI.Colors.Text
    title.TextSize = isMobile and 12 or 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyBtn = Instance.new("TextButton", frame)
    keyBtn.Size = UDim2.new(0, isMobile and 70 or 80, 0, isMobile and 32 or 30)
    keyBtn.Position = UDim2.new(1, -12, 0.5, -16)
    keyBtn.Text = config.Default or "F"
    keyBtn.TextColor3 = NexusUI.Colors.Text
    keyBtn.TextSize = isMobile and 11 or 12
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
    keyBtn.BorderSizePixel = 0
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)
    
    local tecla = config.Default or "F"
    local callback = config.Callback or function() end
    local ouvindo = false
    
    keyBtn.MouseButton1Click:Connect(function()
        if ouvindo then return end
        ouvindo = true
        keyBtn.Text = "..."
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            local nome = nil
            if input.KeyCode ~= Enum.KeyCode.Unknown then nome = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then nome = "Mouse1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then nome = "Mouse2" end
            
            if nome then
                tecla = nome
                keyBtn.Text = tecla
                ouvindo = false
                conn:Disconnect()
                callback(tecla)
            end
        end)
        
        task.wait(5)
        if ouvindo then
            ouvindo = false
            keyBtn.Text = tecla
            conn:Disconnect()
        end
    end)
    
    return {Frame = frame, Set = function(k) tecla = k keyBtn.Text = k end, Get = function() return tecla end}
end

return NexusUI
