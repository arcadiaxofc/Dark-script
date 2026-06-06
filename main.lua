-- // NEXUS EXPLORER - Versão Simples que FUNCIONA

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

-- Aguarda
game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

-- Cria a UI simples
local gui = Instance.new("ScreenGui")
gui.Name = "NexusExplorer"
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Text = "NEXUS EXPLORER"
title.TextColor3 = Color3.new(0, 1, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local output = Instance.new("TextBox", frame)
output.Size = UDim2.new(1, -20, 1, -80)
output.Position = UDim2.new(0, 10, 0, 40)
output.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
output.TextColor3 = Color3.new(0, 1, 0)
output.Font = Enum.Font.Code
output.TextSize = 10
output.Text = "Clique nos botões abaixo...\n"
output.MultiLine = true
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.ClearTextOnFocus = false

-- Função para adicionar texto
local function Add(text)
    output.Text = output.Text .. text .. "\n"
end

-- Botão 1: Ver Remotes
local btn1 = Instance.new("TextButton", frame)
btn1.Size = UDim2.new(0, 120, 0, 30)
btn1.Position = UDim2.new(0, 10, 1, -40)
btn1.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
btn1.Text = "Ver Remotes"
btn1.TextColor3 = Color3.new(1, 1, 1)
btn1.Font = Enum.Font.Gotham
btn1.TextSize = 11

btn1.MouseButton1Click:Connect(function()
    output.Text = ""
    Add("=== REMOTES ===")
    
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        for _, r in pairs(remotes:GetChildren()) do
            Add("📡 " .. r.Name .. " [" .. r.ClassName .. "]")
            for _, child in pairs(r:GetChildren()) do
                Add("  └─ " .. child.Name)
            end
        end
    else
        Add("❌ Remotes não encontrado!")
    end
    
    Add("\n✅ Copie os nomes acima!")
end)

-- Botão 2: Copiar Remotes
local btn2 = Instance.new("TextButton", frame)
btn2.Size = UDim2.new(0, 120, 0, 30)
btn2.Position = UDim2.new(0, 140, 1, -40)
btn2.BackgroundColor3 = Color3.fromRGB(0, 0, 100)
btn2.Text = "Copiar Remotes"
btn2.TextColor3 = Color3.new(1, 1, 1)
btn2.Font = Enum.Font.Gotham
btn2.TextSize = 11

btn2.MouseButton1Click:Connect(function()
    local text = ""
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        for _, r in pairs(remotes:GetChildren()) do
            text = text .. r.Name .. "\n"
        end
    end
    
    if text ~= "" then
        setclipboard(text)
        Add("📋 Remotes copiados!")
    else
        Add("❌ Nada para copiar!")
    end
end)

-- Botão 3: Ver Módulos
local btn3 = Instance.new("TextButton", frame)
btn3.Size = UDim2.new(0, 120, 0, 30)
btn3.Position = UDim2.new(0, 270, 1, -40)
btn3.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
btn3.Text = "Ver Módulos"
btn3.TextColor3 = Color3.new(1, 1, 1)
btn3.Font = Enum.Font.Gotham
btn3.TextSize = 11

btn3.MouseButton1Click:Connect(function()
    output.Text = ""
    Add("=== MÓDULOS ===")
    
    local count = 0
    for _, m in pairs(ReplicatedStorage:GetDescendants()) do
        if m:IsA("ModuleScript") and count < 20 then
            Add("📦 " .. m.Name .. " (" .. #m.Source .. " bytes)")
            count = count + 1
        end
    end
    
    Add("\n✅ Mostrando " .. count .. " módulos")
end)

-- Notificação
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NEXUS EXPLORER",
    Text = "Explorer carregado! Clique nos botões.",
    Duration = 5
})

print("NEXUS EXPLORER - Pronto!")
