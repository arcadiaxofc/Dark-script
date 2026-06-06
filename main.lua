-- // ╔══════════════════════════════════════════════════════════╗
-- // ║     NEXUS EXPLORER - EXPORTADOR DE CÓDIGOS              ║
-- // ║     Escaneia + Copia + Gera Links                       ║
-- // ╚══════════════════════════════════════════════════════════╝

-- // ==================== [ SERVIÇOS ] ====================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character

-- // ==================== [ DADOS EXTRAÍDOS ] ====================
local ExtractedData = {
    Remotes = {},
    Modules = {},
    URLs = {},
    Enemies = {},
    PlayerData = {},
    Timestamp = os.date("%Y-%m-%d %H:%M:%S"),
    GameVersion = game.PlaceVersion,
}

-- // ==================== [ FUNÇÕES DE SCAN ] ====================
local function ScanRemotes()
    ExtractedData.Remotes = {}
    local folder = ReplicatedStorage:FindFirstChild("Remotes")
    if folder then
        for _, obj in pairs(folder:GetDescendants()) do
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                table.insert(ExtractedData.Remotes, {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Type = obj.ClassName,
                })
            end
        end
    end
    return #ExtractedData.Remotes
end

local function ScanModules()
    ExtractedData.Modules = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            table.insert(ExtractedData.Modules, {
                Name = obj.Name,
                Path = obj:GetFullName(),
                Size = #obj.Source,
                Source = obj.Source,
            })
        end
    end
    return #ExtractedData.Modules
end

local function ScanURLs()
    ExtractedData.URLs = {}
    local seen = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        pcall(function()
            if obj:IsA("ModuleScript") then
                for url in obj.Source:gmatch('"(https?://[^"]+)"') do
                    if not seen[url] then
                        seen[url] = true
                        table.insert(ExtractedData.URLs, url)
                    end
                end
            end
        end)
    end
    return #ExtractedData.URLs
end

local function ScanEnemies()
    ExtractedData.Enemies = {}
    local folder = Workspace:FindFirstChild("Enemies")
    if folder then
        for _, obj in pairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                table.insert(ExtractedData.Enemies, {
                    Name = obj.Name,
                    Health = obj.Humanoid.Health,
                    MaxHealth = obj.Humanoid.MaxHealth,
                })
            end
        end
    end
    return #ExtractedData.Enemies
end

local function ScanPlayerData()
    ExtractedData.PlayerData = {}
    local data = Player:FindFirstChild("Data")
    if data then
        for _, child in pairs(data:GetChildren()) do
            pcall(function()
                ExtractedData.PlayerData[child.Name] = tostring(child.Value)
            end)
        end
    end
    return ExtractedData.PlayerData
end

-- // ==================== [ CRIA UI DO EXPLORER ] ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusExplorer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 750, 0, 550)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 150)
Stroke.Thickness = 2

-- Título
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local TitleFill = Instance.new("Frame", TitleBar)
TitleFill.Size = UDim2.new(1, 0, 0.5, 0)
TitleFill.Position = UDim2.new(0, 0, 0.5, 0)
TitleFill.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
TitleFill.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "🔍 NEXUS CODE EXPLORER"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Status
local StatusLabel = Instance.new("TextLabel", TitleBar)
StatusLabel.Size = UDim2.new(0, 200, 1, 0)
StatusLabel.Position = UDim2.new(1, -210, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Pronto para escanear..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Área de saída
local OutputBox = Instance.new("ScrollingFrame", MainFrame)
OutputBox.Size = UDim2.new(1, -20, 1, -100)
OutputBox.Position = UDim2.new(0, 10, 0, 50)
OutputBox.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
OutputBox.BorderSizePixel = 0
OutputBox.ScrollBarThickness = 5
OutputBox.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)

local OutputCorner = Instance.new("UICorner", OutputBox)
OutputCorner.CornerRadius = UDim.new(0, 5)

local OutputText = Instance.new("TextLabel", OutputBox)
OutputText.Size = UDim2.new(1, -20, 0, 10000)
OutputText.Position = UDim2.new(0, 10, 0, 10)
OutputText.BackgroundTransparency = 1
OutputText.Font = Enum.Font.Code
OutputText.Text = "🔍 Aguardando escaneamento...\n"
OutputText.TextColor3 = Color3.fromRGB(0, 255, 150)
OutputText.TextSize = 11
OutputText.TextXAlignment = Enum.TextXAlignment.Left
OutputText.TextYAlignment = Enum.TextYAlignment.Top
OutputText.RichText = true

-- Função para adicionar texto
local function AddOutput(text, color)
    color = color or "00ff96"
    local timestamp = os.date("%H:%M:%S")
    OutputText.Text = OutputText.Text .. string.format(
        '\n<font color="#%s">[%s] %s</font>',
        color, timestamp, text
    )
    OutputBox.CanvasSize = UDim2.new(0, 0, 0, OutputText.TextBounds.Y + 30)
    OutputBox.CanvasPosition = Vector2.new(0, OutputText.TextBounds.Y)
end

-- // ==================== [ BOTÕES ] ====================
local Buttons = {}

local function CreateButton(x, y, text, color, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 150, 0, 30)
    btn.Position = UDim2.new(0, x, 1, y)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        StatusLabel.Text = "Escaneando..."
        callback()
        StatusLabel.Text = "Pronto!"
        task.wait(2)
        StatusLabel.Text = "Pronto para escanear..."
    end)
    
    return btn
end

-- Botão: Escanear Remotes
CreateButton(10, -40, "📡 Remotes", Color3.fromRGB(0, 100, 50), function()
    local count = ScanRemotes()
    AddOutput("=", "ffff00")
    AddOutput("📡 REMOTES ENCONTRADOS: " .. count, "ffff00")
    AddOutput("=", "ffff00")
    for _, r in ipairs(ExtractedData.Remotes) do
        AddOutput(string.format("  📡 %s [%s]", r.Path, r.Type), "ff66ff")
    end
end)

-- Botão: Escanear Módulos
CreateButton(170, -40, "📦 Módulos", Color3.fromRGB(0, 80, 80), function()
    local count = ScanModules()
    AddOutput("=", "ffff00")
    AddOutput("📦 MÓDULOS ENCONTRADOS: " .. count, "ffff00")
    AddOutput("=", "ffff00")
    for _, m in ipairs(ExtractedData.Modules) do
        AddOutput(string.format("  📄 %s (%d bytes)", m.Path, m.Size), "00ffcc")
    end
end)

-- Botão: Escanear URLs
CreateButton(330, -40, "🔗 URLs", Color3.fromRGB(100, 50, 0), function()
    local count = ScanURLs()
    AddOutput("=", "ffff00")
    AddOutput("🔗 URLs ENCONTRADAS: " .. count, "ffff00")
    AddOutput("=", "ffff00")
    for _, url in ipairs(ExtractedData.URLs) do
        AddOutput("  🔗 " .. url, "ff9900")
    end
end)

-- Botão: Escanear Inimigos
CreateButton(490, -40, "👾 Inimigos", Color3.fromRGB(100, 0, 0), function()
    local count = ScanEnemies()
    AddOutput("=", "ffff00")
    AddOutput("👾 INIMIGOS ENCONTRADOS: " .. count, "ffff00")
    AddOutput("=", "ffff00")
    for _, e in ipairs(ExtractedData.Enemies) do
        AddOutput(string.format("  👾 %s (HP: %.0f/%.0f)", e.Name, e.Health, e.MaxHealth), "ff4444")
    end
end)

-- Botão: Escanear TUDO
CreateButton(10, -75, "🔍 ESCANEAR TUDO", Color3.fromRGB(0, 150, 100), function()
    AddOutput("=", "00ff00")
    AddOutput("🔍 INICIANDO ESCANEAMENTO COMPLETO...", "00ff00")
    AddOutput("=", "00ff00")
    
    local rCount = ScanRemotes()
    AddOutput("✅ Remotes: " .. rCount, "00ff00")
    
    local mCount = ScanModules()
    AddOutput("✅ Módulos: " .. mCount, "00ff00")
    
    local uCount = ScanURLs()
    AddOutput("✅ URLs: " .. uCount, "00ff00")
    
    local eCount = ScanEnemies()
    AddOutput("✅ Inimigos: " .. eCount, "00ff00")
    
    AddOutput("", "ffffff")
    AddOutput("🎉 ESCANEAMENTO COMPLETO!", "00ff00")
end)

-- Botão: COPIAR REMOTES
CreateButton(170, -75, "📋 Copiar Remotes", Color3.fromRGB(50, 50, 100), function()
    local text = "-- // REMOTES DO BLOX FRUITS\n"
    text = text .. "-- // Extraído em: " .. ExtractedData.Timestamp .. "\n\n"
    text = text .. "local Remotes = {}\n\n"
    
    for _, r in ipairs(ExtractedData.Remotes) do
        text = text .. string.format('Remotes["%s"] = "%s"\n', r.Name, r.Path)
    end
    
    text = text .. "\n-- // Função para usar:\n"
    text = text .. "local function GetRemote(name)\n"
    text = text .. "    return ReplicatedStorage:FindFirstChild('Remotes'):FindFirstChild(name)\n"
    text = text .. "end\n"
    
    setclipboard(text)
    AddOutput("📋 Código dos remotes COPIADO para o clipboard!", "00ff00")
    AddOutput("  Cole no seu script para usar os remotes atualizados!", "ffffff")
end)

-- Botão: COPIAR URLs
CreateButton(330, -75, "📋 Copiar URLs", Color3.fromRGB(100, 80, 0), function()
    local text = "-- // URLs DO BLOX FRUITS\n"
    text = text .. "-- // Extraído em: " .. ExtractedData.Timestamp .. "\n\n"
    
    for _, url in ipairs(ExtractedData.URLs) do
        text = text .. url .. "\n"
    end
    
    setclipboard(text)
    AddOutput("📋 URLs COPIADAS para o clipboard!", "00ff00")
end)

-- Botão: GERAR SCRIPT ATUALIZADO
CreateButton(490, -75, "⚡ Gerar Script", Color3.fromRGB(150, 0, 200), function()
    ScanRemotes()
    ScanURLs()
    
    local script = "-- // NEXUS SCRIPT ATUALIZADO\n"
    script = script .. "-- // Gerado em: " .. ExtractedData.Timestamp .. "\n"
    script = script .. "-- // Game Version: " .. ExtractedData.GameVersion .. "\n\n"
    
    script = script .. "local ReplicatedStorage = game:GetService('ReplicatedStorage')\n"
    script = script .. "local Remotes = ReplicatedStorage:FindFirstChild('Remotes')\n\n"
    
    script = script .. "-- // Funções de Remote\n"
    for _, r in ipairs(ExtractedData.Remotes) do
        script = script .. string.format("-- %s\n", r.Path)
    end
    
    script = script .. "\n-- // Função GetRemote\n"
    script = script .. "local function GetRemote(name)\n"
    script = script .. "    return Remotes and Remotes:FindFirstChild(name)\n"
    script = script .. "end\n\n"
    
    script = script .. "-- // Exemplo de uso:\n"
    script = script .. "local CommF = GetRemote('CommF_')\n"
    script = script .. "if CommF then\n"
    script = script .. "    CommF:InvokeServer('StartQuest', 'BanditQuest1', 1)\n"
    script = script .. "end\n"
    
    setclipboard(script)
    AddOutput("⚡ SCRIPT ATUALIZADO COPIADO!", "ff00ff")
    AddOutput("  Cole no seu executor e execute!", "ffffff")
end)

-- Botão: LIMPAR
local ClearBtn = Instance.new("TextButton", MainFrame)
ClearBtn.Size = UDim2.new(0, 80, 0, 25)
ClearBtn.Position = UDim2.new(1, -90, 1, -40)
ClearBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.Text = "🗑️ Limpar"
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.TextSize = 9

local ClearCorner = Instance.new("UICorner", ClearBtn)
ClearCorner.CornerRadius = UDim.new(0, 5)

ClearBtn.MouseButton1Click:Connect(function()
    OutputText.Text = "🔍 Console limpo!\n"
    OutputBox.CanvasSize = UDim2.new(0, 0, 0, 50)
    StatusLabel.Text = "Console limpo!"
    task.wait(1)
    StatusLabel.Text = "Pronto para escanear..."
end)

-- Fechar
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 5)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- // ==================== [ NOTIFICAÇÃO INICIAL ] ====================
StarterGui:SetCore("SendNotification", {
    Title = "NEXUS CODE EXPLORER",
    Text = "Clique em 'ESCANEAR TUDO' e depois em 'COPIAR'!",
    Duration = 8
})

AddOutput("🚀 NEXUS CODE EXPLORER INICIADO!", "00ff00")
AddOutput("", "ffffff")
AddOutput("📋 INSTRUÇÕES:", "ffff00")
AddOutput("  1. Clique em '🔍 ESCANEAR TUDO'", "ffffff")
AddOutput("  2. Depois clique em '📋 Copiar' para pegar os códigos", "ffffff")
AddOutput("  3. Cole no seu script e execute!", "ffffff")
AddOutput("", "ffffff")
AddOutput("💡 DICA: Use '⚡ Gerar Script' para criar um script atualizado!", "ff9900")
