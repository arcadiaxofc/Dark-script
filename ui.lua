-- ==================== NEXUS UI LIBRARY v4.1 - CORRIGIDA ====================
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
    Warn = Color3.fromRGB(255, 180, 0),
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
local viewportSize = Workspace.CurrentCamera.ViewportSize
local maxWidth = isMobile and math.min(viewportSize.X - 40, 400) or 560
local maxHeight = isMobile and math.min(viewportSize.Y - 100, 480) or 500

-- ==================== CRIAR JANELA ====================
function NexusUI:CreateWindow(config)
    config = config or {}
    
    -- Ajustes para mobile
    local windowWidth = isMobile and math.min(config.Width or maxWidth, maxWidth) or (config.Width or 560)
    local windowHeight = isMobile and math.min(config.Height or maxHeight, maxHeight) or (config.Height or 500)
    local sidebarWidth = isMobile and 130 or 140
    
    local gui = Instance.new("ScreenGui")
    gui.Name = config.Name or "NexusUI"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    
    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    window.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    window.BackgroundColor3 = NexusUI.Colors.MainBg
    window.BorderSizePixel = 0
    window.Parent = gui
    window.Active = true
    window.Draggable = true
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 10)
    
    -- Sombra
    local shadow = Instance.new("Frame", window)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = -1
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)
    
    -- Linha de destaque
    local accentLine = Instance.new("Frame", window)
    accentLine.Size = UDim2.new(1, 0, 0, 3)
    accentLine.BackgroundColor3 = NexusUI.Colors.Title
    accentLine.BorderSizePixel = 0
    Instance.new("UICorner", accentLine).CornerRadius = UDim.new(0, 10)
    
    -- ==================== CABEÇALHO ====================
    local header = Instance.new("Frame", window)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = NexusUI.Colors.HeaderBg
    header.BorderSizePixel = 0
    
    -- LOGO (CORRIGIDA)
    local headerTitle, headerSub
    if config.Logo then
        local logo = Instance.new("ImageLabel", header)
        local logoSize = config.LogoSize or (isMobile and 28 or 32)
        logo.Size = UDim2.new(0, logoSize, 0, logoSize)
        logo.Position = UDim2.new(0, 12, 0.5, -logoSize/2)
        logo.BackgroundTransparency = 1
        logo.Image = config.Logo
        Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 6)
        
        headerTitle = Instance.new("TextLabel", header)
        headerTitle.Size = UDim2.new(1, -140, 0, 25)
        headerTitle.Position = UDim2.new(0, logoSize + 15, 0, 8)
        headerTitle.BackgroundTransparency = 1
        headerTitle.Text = config.Title or "NEXUS v7.0"
        headerTitle.TextColor3 = NexusUI.Colors.Title
        headerTitle.TextSize = isMobile and 14 or 16
        headerTitle.Font = Enum.Font.GothamBold
        headerTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        headerSub = Instance.new("TextLabel", header)
        headerSub.Size = UDim2.new(1, -140, 0, 15)
        headerSub.Position = UDim2.new(0, logoSize + 15, 0, 28)
        headerSub.BackgroundTransparency = 1
        headerSub.Text = config.Subtitle or "Script Ultimate"
        headerSub.TextColor3 = NexusUI.Colors.TextDim
        headerSub.TextSize = 9
        headerSub.Font = Enum.Font.Gotham
        headerSub.TextXAlignment = Enum.TextXAlignment.Left
    else
        headerTitle = Instance.new("TextLabel", header)
        headerTitle.Size = UDim2.new(1, -110, 0, 25)
        headerTitle.Position = UDim2.new(0, 12, 0, 8)
        headerTitle.BackgroundTransparency = 1
        headerTitle.Text = config.Title or "NEXUS v7.0"
        headerTitle.TextColor3 = NexusUI.Colors.Title
        headerTitle.TextSize = isMobile and 14 or 16
        headerTitle.Font = Enum.Font.GothamBold
        headerTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        headerSub = Instance.new("TextLabel", header)
        headerSub.Size = UDim2.new(1, -110, 0, 15)
        headerSub.Position = UDim2.new(0, 12, 0, 28)
        headerSub.BackgroundTransparency = 1
        headerSub.Text = config.Subtitle or "Script Ultimate"
        headerSub.TextColor3 = NexusUI.Colors.TextDim
        headerSub.TextSize = 9
        headerSub.Font = Enum.Font.Gotham
        headerSub.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    -- Botão minimizar
    local minimizeBtn = Instance.new("TextButton", header)
    minimizeBtn.Size = UDim2.new(0, isMobile and 32 or 30, 0, isMobile and 32 or 30)
    minimizeBtn.Position = UDim2.new(1, isMobile and -80 or -45, 0.5, -15)
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = NexusUI.Colors.Text
    minimizeBtn.TextSize = isMobile and 16 or 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
    minimizeBtn.BorderSizePixel = 0
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, isMobile and 32 or 30, 0, isMobile and 32 or 30)
    closeBtn.Position = UDim2.new(1, isMobile and -42 or -12, 0.5, -15)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = NexusUI.Colors.Danger
    closeBtn.TextSize = isMobile and 14 or 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    -- Botão de redimensionar
    local resizeBtn = Instance.new("TextButton", header)
    resizeBtn.Size = UDim2.new(0, isMobile and 32 or 30, 0, isMobile and 32 or 30)
    resizeBtn.Position = UDim2.new(1, isMobile and -118 or -75, 0.5, -15)
    resizeBtn.Text = "□"
    resizeBtn.TextColor3 = NexusUI.Colors.Text
    resizeBtn.TextSize = isMobile and 16 or 18
    resizeBtn.Font = Enum.Font.GothamBold
    resizeBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
    resizeBtn.BorderSizePixel = 0
    Instance.new("UICorner", resizeBtn).CornerRadius = UDim.new(0, 6)
    
    -- ==================== SIDEBAR ====================
    local sidebar = Instance.new("ScrollingFrame", window)
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -50)
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
    
    local sidebarLine = Instance.new("Frame", sidebar)
    sidebarLine.Size = UDim2.new(0, 1, 1, 0)
    sidebarLine.Position = UDim2.new(1, -1, 0, 0)
    sidebarLine.BackgroundColor3 = NexusUI.Colors.Border
    sidebarLine.BorderSizePixel = 0
    
    -- ==================== ÁREA DE CONTEÚDO ====================
    local contentContainer = Instance.new("Frame", window)
    contentContainer.Size = UDim2.new(1, -(sidebarWidth + 5), 1, -55)
    contentContainer.Position = UDim2.new(0, sidebarWidth + 5, 0, 55)
    contentContainer.BackgroundTransparency = 1
    
    local contentArea = Instance.new("ScrollingFrame", contentContainer)
    contentArea.Size = UDim2.new(1, 0, 1, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.ScrollBarThickness = isMobile and 2 or 4
    contentArea.ScrollBarImageColor3 = NexusUI.Colors.Title
    
    local contentLayout = Instance.new("UIListLayout", contentArea)
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    
    local contentPadding = Instance.new("UIPadding", contentArea)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 5)
    contentPadding.PaddingRight = UDim.new(0, 5)
    
    local function updateCanvas()
        contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    
    -- ==================== SLIDER DE ESCALA ====================
    local scaleFrame = Instance.new("Frame", window)
    scaleFrame.Size = UDim2.new(0, 200, 0, 30)
    scaleFrame.Position = UDim2.new(0.5, -100, 1, -25)
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
    
    local scaleSlider = Instance.new("Frame", scaleFrame)
    scaleSlider.Size = UDim2.new(0, 120, 0, 4)
    scaleSlider.Position = UDim2.new(0, 60, 0.5, -2)
    scaleSlider.BackgroundColor3 = NexusUI.Colors.Border
    Instance.new("UICorner", scaleSlider).CornerRadius = UDim.new(1, 0)
    
    local scaleFill = Instance.new("Frame", scaleSlider)
    scaleFill.Size = UDim2.new(1, 0, 1, 0)
    scaleFill.BackgroundColor3 = NexusUI.Colors.Title
    Instance.new("UICorner", scaleFill).CornerRadius = UDim.new(1, 0)
    
    local scaleKnob = Instance.new("Frame", scaleSlider)
    scaleKnob.Size = UDim2.new(0, 10, 0, 10)
    scaleKnob.Position = UDim2.new(1, -5, 0.5, -5)
    scaleKnob.BackgroundColor3 = NexusUI.Colors.Text
    Instance.new("UICorner", scaleKnob).CornerRadius = UDim.new(1, 0)
    
    local currentScale = 1
    local minScale = 0.6
    local maxScale = 1.2
    
    local function updateScale(scale)
        currentScale = math.clamp(scale, minScale, maxScale)
        local percent = (currentScale - minScale) / (maxScale - minScale)
        scaleFill.Size = UDim2.new(percent, 0, 1, 0)
        scaleKnob.Position = UDim2.new(percent, -5, 0.5, -5)
        scaleLabel.Text = math.floor(currentScale * 100) .. "%"
        
        local newWidth = math.floor(windowWidth * currentScale)
        local newHeight = math.floor(windowHeight * currentScale)
        
        local maxWidthScreen = viewportSize.X - 40
        local maxHeightScreen = viewportSize.Y - 100
        
        newWidth = math.min(newWidth, maxWidthScreen)
        newHeight = math.min(newHeight, maxHeightScreen)
        
        TweenService:Create(window, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, newWidth, 0, newHeight),
            Position = UDim2.new(0.5, -newWidth/2, 0.5, -newHeight/2)
        }):Play()
        
        local newSidebarWidth = math.floor(sidebarWidth * currentScale)
        sidebar.Size = UDim2.new(0, newSidebarWidth, 1, -50)
        contentContainer.Size = UDim2.new(1, -(newSidebarWidth + 5), 1, -55)
        contentContainer.Position = UDim2.new(0, newSidebarWidth + 5, 0, 55)
    end
    
    local draggingScale = false
    scaleSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingScale = true
            local percent = math.clamp((input.Position.X - scaleSlider.AbsolutePosition.X) / scaleSlider.AbsoluteSize.X, 0, 1)
            updateScale(minScale + percent * (maxScale - minScale))
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingScale and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - scaleSlider.AbsolutePosition.X) / scaleSlider.AbsoluteSize.X, 0, 1)
            updateScale(minScale + percent * (maxScale - minScale))
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingScale = false
        end
    end)
    
    local scaleVisible = false
    resizeBtn.MouseButton1Click:Connect(function()
        scaleVisible = not scaleVisible
        scaleFrame.Visible = scaleVisible
    end)
    
    -- ==================== FPS ====================
    local fpsLabel = Instance.new("TextLabel", window)
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
        local now = tick()
        if now - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. frameCount
            frameCount = 0
            lastTime = now
        end
    end)
    
    -- ==================== SISTEMA DE MINIMIZAR ====================
    local minimized = false
    local originalHeight = windowHeight
    local originalWidth = windowWidth
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, originalWidth, 0, 50)
            }):Play()
            contentContainer.Visible = false
            sidebar.Visible = false
            scaleFrame.Visible = false
            minimizeBtn.Text = "□"
        else
            TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, originalWidth, 0, originalHeight)
            }):Play()
            contentContainer.Visible = true
            sidebar.Visible = true
            minimizeBtn.Text = "─"
        end
    end)
    
    -- ==================== BOTÃO FLUTUANTE (CORRIGIDO) ====================
    local floatingBtn = Instance.new("TextButton", CoreGui)
    floatingBtn.Size = UDim2.new(0, isMobile and 45 or 50, 0, isMobile and 45 or 50)
    floatingBtn.Position = UDim2.new(1, isMobile and -55 or -60, 0.5, isMobile and -22 or -25)
    floatingBtn.Text = config.FloatingIcon or "⚡"
    floatingBtn.TextColor3 = NexusUI.Colors.Text
    floatingBtn.TextSize = isMobile and 20 or 24
    floatingBtn.Font = Enum.Font.GothamBold
    floatingBtn.BackgroundColor3 = NexusUI.Colors.Title
    floatingBtn.BorderSizePixel = 0
    floatingBtn.Visible = true  -- Começa visível
    floatingBtn.ZIndex = 999
    Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(1, 0)
    
    -- Sombra da bolinha
    local floatShadow = Instance.new("Frame", floatingBtn)
    floatShadow.Size = UDim2.new(1, 10, 1, 10)
    floatShadow.Position = UDim2.new(0.5, -5, 0.5, -5)
    floatShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    floatShadow.BackgroundTransparency = 0.5
    floatShadow.ZIndex = -1
    Instance.new("UICorner", floatShadow).CornerRadius = UDim.new(1, 0)
    
    -- Arrastar bolinha
    local dragFloat = false
    floatingBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragFloat = true
        end
    end)
    floatingBtn.InputEnded:Connect(function()
        dragFloat = false
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragFloat and i.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math.clamp(i.Position.X - 25, 0, viewportSize.X - 50)
            local y = math.clamp(i.Position.Y - 25, 0, viewportSize.Y - 50)
            floatingBtn.Position = UDim2.new(0, x, 0, y)
        end
    end)
    
    -- Efeito hover na bolinha
    floatingBtn.MouseEnter:Connect(function()
        TweenService:Create(floatingBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, isMobile and 50 or 55, 0, isMobile and 50 or 55)
        }):Play()
    end)
    floatingBtn.MouseLeave:Connect(function()
        TweenService:Create(floatingBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, isMobile and 45 or 50, 0, isMobile and 45 or 50)
        }):Play()
    end)
    
    -- FECHAR: mostra bolinha
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        gui:Destroy()
        floatingBtn.Visible = true
    end)
    
    -- MINIMIZAR: mostra bolinha
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, originalWidth, 0, 50)
            }):Play()
            contentContainer.Visible = false
            sidebar.Visible = false
            minimizeBtn.Text = "□"
            floatingBtn.Visible = true
        else
            TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, originalWidth, 0, originalHeight)
            }):Play()
            contentContainer.Visible = true
            sidebar.Visible = true
            minimizeBtn.Text = "─"
            floatingBtn.Visible = false
        end
    end)
    
    -- CLICAR NA BOLINHA: abre a janela
    floatingBtn.MouseButton1Click:Connect(function()
        floatingBtn.Visible = false
        window.Visible = true
        gui.Visible = true
        contentContainer.Visible = true
        sidebar.Visible = true
        minimized = false
        minimizeBtn.Text = "─"
        TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, originalWidth, 0, originalHeight)
        }):Play()
    end)
    
    -- ==================== DRAG ====================
    local dragging, dragStart, startPos = false, nil, nil
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
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            newX = math.clamp(newX, -windowWidth/2, viewportSize.X - windowWidth/2)
            newY = math.clamp(newY, -windowHeight/2, viewportSize.Y - windowHeight/2)
            window.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
    
    -- ==================== ANIMAÇÃO ====================
    window.Size = UDim2.new(0, 0, 0, windowHeight)
    TweenService:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, windowWidth, 0, windowHeight)
    }):Play()
    
    -- Oculta a bolinha quando a janela está aberta
    floatingBtn.Visible = false
    
    -- ==================== RETORNAR ====================
    local windowData = {
        Gui = gui,
        Frame = window,
        Sidebar = sidebarContent,
        SidebarLayout = sidebarLayout,
        ContentContainer = contentContainer,
        Content = contentArea,
        ContentLayout = contentLayout,
        Tabs = {},
        CurrentTab = nil,
        FloatingButton = floatingBtn,
        SetScale = function(scale) updateScale(scale) end,
        GetScale = function() return currentScale end,
        Minimize = function()
            if not minimized then
                minimized = true
                TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, originalWidth, 0, 50)
                }):Play()
                contentContainer.Visible = false
                sidebar.Visible = false
                minimizeBtn.Text = "□"
                floatingBtn.Visible = true
            end
        end,
        Restore = function()
            if minimized then
                minimized = false
                TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, originalWidth, 0, originalHeight)
                }):Play()
                contentContainer.Visible = true
                sidebar.Visible = true
                minimizeBtn.Text = "─"
                floatingBtn.Visible = false
            end
        end,
        IsMinimized = function() return minimized end
    }
    
    return windowData
end

-- ==================== CRIAR TAB ====================
function NexusUI:CreateTab(window, config)
    config = config or {}
    
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
    
    local tabContent = Instance.new("ScrollingFrame", window.Content)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.Visible = false
    tabContent.ScrollBarThickness = 0
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local tabLayout = Instance.new("UIListLayout", tabContent)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    
    local tabPadding = Instance.new("UIPadding", tabContent)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingBottom = UDim.new(0, 5)
    
    local function select()
        for _, t in pairs(window.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = NexusUI.Colors.SidebarBg
            t.Button.TextColor3 = NexusUI.Colors.TextDim
        end
        tabContent.Visible = true
        btn.BackgroundColor3 = NexusUI.Colors.ElementBg
        btn.TextColor3 = NexusUI.Colors.Title
        window.CurrentTab = config.Name
        
        window.ContentContainer.Parent.Content.CanvasPosition = Vector2.new(0, 0)
    end
    
    btn.MouseButton1Click:Connect(select)
    
    local tabData = {
        Name = config.Name,
        Icon = config.Icon,
        Button = btn,
        Content = tabContent,
        Layout = tabLayout,
        Select = select
    }
    
    table.insert(window.Tabs, tabData)
    
    if #window.Tabs == 1 then
        select()
    end
    
    return tabData
end

-- ==================== CRIAR SEÇÃO ====================
function NexusUI:CreateSection(tab, title)
    local section = Instance.new("Frame", tab.Content)
    section.Size = UDim2.new(1, 0, 0, 38)
    section.BackgroundColor3 = NexusUI.Colors.ElementBg
    section.BorderSizePixel = 0
    section.AutomaticSize = Enum.AutomaticSize.None
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    
    local titleLabel = Instance.new("TextLabel", section)
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = NexusUI.Colors.Title
    titleLabel.TextSize = isMobile and 11 or 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
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
    config = config or {}
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, isMobile and 48 or 42)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.None
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
    
    local state = false
    local callback = config.Callback or function() end
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and NexusUI.Colors.Success or NexusUI.Colors.Danger
        callback(state)
    end)
    
    return {
        Frame = frame,
        Toggle = toggle,
        Set = function(v)
            state = v
            toggle.Text = state and "ON" or "OFF"
            toggle.BackgroundColor3 = state and NexusUI.Colors.Success or NexusUI.Colors.Danger
            callback(state)
        end,
        Get = function() return state end
    }
end

-- ==================== CRIAR BOTÃO ====================
function NexusUI:CreateButton(tab, config)
    config = config or {}
    
    local btn = Instance.new("TextButton", tab.Content)
    btn.Size = UDim2.new(1, 0, 0, isMobile and 42 or 38)
    btn.Text = config.Title or "Button"
    btn.TextColor3 = NexusUI.Colors.Text
    btn.TextSize = isMobile and 12 or 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = NexusUI.Colors.ElementBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.AutomaticSize = Enum.AutomaticSize.None
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
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or 50
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, isMobile and 75 or 65)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.None
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
    
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -62, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = NexusUI.Colors.Title
    valueLabel.TextSize = isMobile and 12 or 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBar = Instance.new("Frame", frame)
    sliderBar.Size = UDim2.new(1, -24, 0, 4)
    sliderBar.Position = UDim2.new(0, 12, 0, 45)
    sliderBar.BackgroundColor3 = NexusUI.Colors.ElementBg
    sliderBar.BorderSizePixel = 0
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = NexusUI.Colors.Title
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", sliderBar)
    knob.Size = UDim2.new(0, isMobile and 15 or 12, 0, isMobile and 15 or 12)
    knob.Position = UDim2.new((value - min) / (max - min), isMobile and -7.5 or -6, 0.5, isMobile and -7.5 or -6)
    knob.BackgroundColor3 = NexusUI.Colors.Text
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local callback = config.Callback or function() end
    
    local function update(val)
        val = math.clamp(val, min, max)
        local percent = (val - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, isMobile and -7.5 or -6, 0.5, isMobile and -7.5 or -6)
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
    local options = config.Options or {"Opção 1", "Opção 2"}
    local selected = config.Default or options[1]
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, isMobile and 48 or 42)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.None
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
    
    local dropdownBtn = Instance.new("TextButton", frame)
    dropdownBtn.Size = UDim2.new(0, isMobile and 100 or 120, 0, isMobile and 32 or 30)
    dropdownBtn.Position = UDim2.new(1, -12, 0.5, -16)
    dropdownBtn.Text = selected
    dropdownBtn.TextColor3 = NexusUI.Colors.Text
    dropdownBtn.TextSize = isMobile and 11 or 12
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
    dropdownBtn.BorderSizePixel = 0
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6)
    
    local dropdownContent = Instance.new("Frame", frame)
    dropdownContent.Size = UDim2.new(1, 0, 0, 0)
    dropdownContent.Position = UDim2.new(0, 0, 1, 2)
    dropdownContent.BackgroundColor3 = NexusUI.Colors.ElementBg
    dropdownContent.BorderSizePixel = 0
    dropdownContent.ClipsDescendants = true
    dropdownContent.Visible = false
    dropdownContent.ZIndex = 10
    Instance.new("UICorner", dropdownContent).CornerRadius = UDim.new(0, 6)
    
    local contentLayout = Instance.new("UIListLayout", dropdownContent)
    contentLayout.Padding = UDim.new(0, 2)
    
    local callback = config.Callback or function() end
    
    for _, opt in pairs(options) do
        local optBtn = Instance.new("TextButton", dropdownContent)
        optBtn.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
        optBtn.Text = opt
        optBtn.TextColor3 = NexusUI.Colors.TextDim
        optBtn.TextSize = isMobile and 11 or 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        
        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundColor3 = NexusUI.Colors.ElementHover
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundColor3 = NexusUI.Colors.ElementBg
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            dropdownBtn.Text = selected
            dropdownContent.Visible = false
            dropdownContent.Size = UDim2.new(1, 0, 0, 0)
            callback(selected)
        end)
    end
    
    dropdownContent.Size = UDim2.new(1, 0, 0, #options * (isMobile and 37 or 32))
    
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
    frame.Size = UDim2.new(1, 0, 0, isMobile and 55 or 50)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.None
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
    label.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
    label.Text = config.Title or "Label"
    label.TextColor3 = NexusUI.Colors.TextDim
    label.TextSize = isMobile and 11 or 12
    label.Font = Enum.Font.Gotham
    label.BackgroundColor3 = NexusUI.Colors.ElementBg
    label.BorderSizePixel = 0
    label.AutomaticSize = Enum.AutomaticSize.None
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    
    return label
end

-- ==================== CRIAR KEYBIND ====================
function NexusUI:CreateKeybind(tab, config)
    config = config or {}
    
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, 0, 0, isMobile and 48 or 42)
    frame.BackgroundColor3 = NexusUI.Colors.ElementBg
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.None
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
