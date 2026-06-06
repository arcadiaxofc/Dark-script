-- // ╔══════════════════════════════════════════════════════════╗
-- // ║     NEXUS - 99 NOITES NA FLORESTA (COMPLETO)            ║
-- // ║   Auto Madeira | Comida | Gemas | Fogueira | Defesa     ║
-- // ╚══════════════════════════════════════════════════════════╝

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- ESPERAR CARREGAR
-- ============================================================
game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

-- ============================================================
-- FLAGS
-- ============================================================
_G.AutoWood = false
_G.AutoFood = false
_G.AutoGems = false
_G.AutoFire = false
_G.AutoCollect = false
_G.AutoDefense = false
_G.Range = 50

-- ============================================================
-- FUNÇÕES DE TOQUE (MOBILE)
-- ============================================================
local function TapScreen(x, y)
    x = x or 200
    y = y or 300
    pcall(function()
        UIS.TouchStarted:Fire({
            UserInputType = Enum.UserInputType.Touch,
            UserInputState = Enum.UserInputState.Begin,
            Position = Vector3.new(x, y, 0),
        }, false)
        task.wait(0.05)
        UIS.TouchEnded:Fire({
            UserInputType = Enum.UserInputType.Touch,
            UserInputState = Enum.UserInputState.End,
            Position = Vector3.new(x, y, 0),
        }, false)
    end)
end

local function HoldTap(duration, x, y)
    x = x or 200
    y = y or 300
    pcall(function()
        UIS.TouchStarted:Fire({
            UserInputType = Enum.UserInputType.Touch,
            UserInputState = Enum.UserInputState.Begin,
            Position = Vector3.new(x, y, 0),
        }, false)
        task.wait(duration or 3)
        UIS.TouchEnded:Fire({
            UserInputType = Enum.UserInputType.Touch,
            UserInputState = Enum.UserInputState.End,
            Position = Vector3.new(x, y, 0),
        }, false)
    end)
end

-- ============================================================
-- TELEPORTE
-- ============================================================
local function TP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

-- ============================================================
-- ENCONTRAR OBJETOS
-- ============================================================
local function FindNearest(keywords)
    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    
    local closest = nil
    local closestDist = _G.Range
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            local found = false
            
            for _, kw in ipairs(keywords) do
                if name:find(kw:lower()) then
                    found = true
                    break
                end
            end
            
            if found then
                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                if pos then
                    local dist = (pos - myPos.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = obj
                    end
                end
            end
        end
    end
    
    return closest
end

-- ============================================================
-- 🌳 AUTO FARM MADEIRA
-- ============================================================
task.spawn(function()
    print("[99 NOITES] Farm Madeira iniciado")
    while task.wait(0.3) do
        if not _G.AutoWood then continue end
        
        pcall(function()
            local tree = FindNearest({"tree", "wood", "árvore", "madeira", "log", "tronco", "pine", "oak", "birch"})
            if tree then
                local pos = tree:IsA("Model") and tree:GetPivot().Position or tree.Position
                if pos then
                    TP(pos)
                    task.wait(0.5)
                    HoldTap(3) -- Segura 3s para quebrar árvore
                end
            end
        end)
    end
end)

-- ============================================================
-- 🍖 AUTO FARM COMIDA (CAÇA)
-- ============================================================
task.spawn(function()
    print("[99 NOITES] Farm Comida iniciado")
    while task.wait(0.5) do
        if not _G.AutoFood then continue end
        
        pcall(function()
            local animal = FindNearest({"deer", "boar", "rabbit", "bird", "wolf", "bear", "veado", "coelho", "porco", "lobo", "urso", "animal"})
            if animal then
                local pos = animal:IsA("Model") and animal:GetPivot().Position or animal.Position
                if pos then
                    TP(pos)
                    task.wait(0.3)
                    -- Ataca várias vezes para matar
                    for i = 1, 5 do
                        TapScreen()
                        task.wait(0.2)
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- 💎 AUTO FARM GEMAS
-- ============================================================
task.spawn(function()
    print("[99 NOITES] Farm Gemas iniciado")
    while task.wait(0.5) do
        if not _G.AutoGems then continue end
        
        pcall(function()
            local gem = FindNearest({"gem", "diamond", "crystal", "gema", "diamante", "ruby", "emerald", "sapphire"})
            if gem then
                local pos = gem:IsA("Model") and gem:GetPivot().Position or gem.Position
                if pos then
                    TP(pos)
                    task.wait(0.3)
                    HoldTap(2) -- Segura para minerar
                end
            end
        end)
    end
end)

-- ============================================================
-- 📦 AUTO COLETAR ITENS
-- ============================================================
task.spawn(function()
    print("[99 NOITES] Auto Coleta iniciado")
    while task.wait(1) do
        if not _G.AutoCollect then continue end
        
        pcall(function()
            local loot = FindNearest({"drop", "item", "meat", "wood", "gem", "carne", "madeira", "skin", "leather", "stick", "stone"})
            if loot then
                local pos = loot:IsA("Model") and loot:GetPivot().Position or loot.Position
                if pos then
                    TP(pos)
                    task.wait(0.3)
                    TapScreen()
                end
            end
        end)
    end
end)

-- ============================================================
-- 🔥 AUTO ALIMENTAR FOGUEIRA
-- ============================================================
task.spawn(function()
    print("[99 NOITES] Auto Fogueira iniciado")
    while task.wait(5) do
        if not _G.AutoFire then continue end
        
        pcall(function()
            local fire = FindNearest({"fire", "campfire", "fogueira", "bonfire", "camp", "base"})
            if fire then
                local pos = fire:IsA("Model") and fire:GetPivot().Position or fire.Position
                if pos then
                    TP(pos)
                    task.wait(0.5)
                    TapScreen()
                    task.wait(0.5)
                    TapScreen()
                end
            end
        end)
    end
end)

-- ============================================================
-- 🛡️ AUTO DEFESA (CONTRA INIMIGOS)
-- ============================================================
task.spawn(function()
    print("[99 NOITES] Auto Defesa iniciado")
    while task.wait(0.5) do
        if not _G.AutoDefense then continue end
        
        pcall(function()
            local enemy = FindNearest({"night", "deer", "wolf", "bear", "spirit", "monster", "cervo", "lobo", "urso", "espírito"})
            if enemy then
                local pos = enemy:IsA("Model") and enemy:GetPivot().Position or enemy.Position
                if pos then
                    local myPos = Player.Character.HumanoidRootPart.Position
                    local dist = (pos - myPos).Magnitude
                    
                    if dist < 20 then
                        -- Inimigo está perto! Atacar!
                        for i = 1, 8 do
                            TapScreen()
                            task.wait(0.15)
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- UI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "Nexus99"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 220)
frame.Position = UDim2.new(0.5, -120, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 200, 100)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Text = "🌳 NEXUS - 99 NOITES"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 10)

local function CreateToggle(y, text, flag, emoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 26)
    btn.Position = UDim2.new(0.5, -100, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    btn.Text = emoji .. " " .. text .. " (OFF)"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        _G[flag] = on
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 100, 30) or Color3.fromRGB(50, 30, 30)
        btn.Text = emoji .. " " .. text .. (on and " (ON)" or " (OFF)")
    end)
end

CreateToggle(32, "Madeira", "AutoWood", "🌳")
CreateToggle(62, "Comida/Caça", "AutoFood", "🍖")
CreateToggle(92, "Gemas", "AutoGems", "💎")
CreateToggle(122, "Coletar Itens", "AutoCollect", "📦")
CreateToggle(152, "Alimentar Fogueira", "AutoFire", "🔥")
CreateToggle(182, "Defesa (Inimigos)", "AutoDefense", "🛡️")

-- Botão Parar Tudo
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 200, 0, 22)
stopBtn.Position = UDim2.new(0.5, -100, 0, 212)
stopBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
stopBtn.Text = "🛑 PARAR TUDO"
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 10
stopBtn.BorderSizePixel = 0
stopBtn.Parent = frame

local stopCorner = Instance.new("UICorner", stopBtn)
stopCorner.CornerRadius = UDim.new(0, 5)

stopBtn.MouseButton1Click:Connect(function()
    _G.AutoWood = false
    _G.AutoFood = false
    _G.AutoGems = false
    _G.AutoCollect = false
    _G.AutoFire = false
    _G.AutoDefense = false
end)

-- ============================================================
-- NOTIFICAÇÃO
-- ============================================================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NEXUS 99 NOITES",
    Text = "🌳 Script carregado!\nAtive as funções nos botões!",
    Duration = 5
})

print("[99 NOITES] Script completo carregado!")
print("[99 NOITES] Use os botões na tela para ativar!")
