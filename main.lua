-- // ╔══════════════════════════════════════════════════════════╗
-- // ║     NEXUS AUTO CLICKER - CORAÇÃO PURO                   ║
-- // ║   Apenas ataque que funciona + toggle simples           ║
-- // ╚══════════════════════════════════════════════════════════╝

-- ============================================================
-- SERVIÇOS (MÍNIMO)
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- ============================================================
-- ESPERAR
-- ============================================================
game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

-- ============================================================
-- FLAGS
-- ============================================================
_G.AutoClicker = false
_G.ClickSpeed = 0.1  -- Tempo entre cliques
_G.BringMob = true   -- Puxar inimigo
_G.Range = 300       -- Distância de detecção

-- ============================================================
-- FUNÇÃO DE ATAQUE (TODOS OS MÉTODOS)
-- ============================================================
local function Attack()
    -- Método 1: RegisterAttack (mais eficaz)
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        if modules then
            local net = modules:FindFirstChild("Net")
            if net then
                local regAttack = net:FindFirstChild("RE/RegisterAttack")
                if regAttack then
                    regAttack:FireServer(0.01)
                end
            end
        end
    end)
    
    -- Método 2: Remote
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local comm = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF")
            if comm then
                comm:InvokeServer("Attack")
            end
        end
    end)
    
    -- Método 3: VirtualInputManager
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    -- Método 4: Mouse
    pcall(function()
        local mouse = Player:GetMouse()
        if mouse then
            mouse:Button1Down()
            task.wait(0.02)
            mouse:Button1Up()
        end
    end)
end

-- ============================================================
-- ENCONTRAR INIMIGO MAIS PRÓXIMO
-- ============================================================
local function GetClosestEnemy()
    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end
    
    local closest = nil
    local closestDist = _G.Range
    
    for _, enemy in pairs(enemiesFolder:GetChildren()) do
        if enemy:IsA("Model") then
            local hum = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local dist = (hrp.Position - myPos.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = enemy
                end
            end
        end
    end
    
    return closest
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
-- LOOP PRINCIPAL DO AUTO CLICKER
-- ============================================================
task.spawn(function()
    print("[NEXUS] Auto Clicker iniciado!")
    
    while task.wait(_G.ClickSpeed) do
        if not _G.AutoClicker then
            task.wait(0.5)
            continue
        end
        
        pcall(function()
            local enemy = GetClosestEnemy()
            
            if enemy then
                local hum = enemy:FindFirstChild("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp and myPos and hum.Health > 0 then
                    -- Opção 1: Puxar inimigo para perto
                    if _G.BringMob then
                        hrp.CFrame = myPos.CFrame * CFrame.new(0, 0, -5)
                        hrp.Velocity = Vector3.zero
                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                    else
                        -- Opção 2: Teleportar até o inimigo
                        local dist = (hrp.Position - myPos.Position).Magnitude
                        if dist > 10 then
                            TP(hrp.Position)
                            task.wait(0.2)
                        end
                    end
                    
                    -- ATACAR!
                    Attack()
                end
            end
        end)
    end
end)

-- ============================================================
-- UI SIMPLES (Só um botão de toggle)
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "NexusClicker"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0.5, -100, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 100)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "NEXUS AUTO CLICKER"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 160, 0, 35)
toggleBtn.Position = UDim2.new(0.5, -80, 0.5, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
toggleBtn.Text = "INICIAR"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 6)

local isOn = false
toggleBtn.MouseButton1Click:Connect(function()
    isOn = not isOn
    _G.AutoClicker = isOn
    
    if isOn then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
        toggleBtn.Text = "PARAR"
        title.Text = "⚡ ATACANDO..."
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
        toggleBtn.Text = "INICIAR"
        title.Text = "NEXUS AUTO CLICKER"
    end
end)

-- ============================================================
-- NOTIFICAÇÃO
-- ============================================================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NEXUS AUTO CLICKER",
    Text = "Clique em INICIAR para começar!",
    Duration = 5
})

print("[NEXUS] Auto Clicker carregado!")
print("[NEXUS] Clique em INICIAR na tela!")
