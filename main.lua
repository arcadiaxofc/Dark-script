-- // ╔══════════════════════════════════════════════════════════╗
-- // ║     NEXUS SUPREMO - API NATIVA DO ROBLOX               ║
-- // ║   Usando APENAS comandos nativos do Roblox             ║
-- // ╚══════════════════════════════════════════════════════════╝

-- ============================================================
-- API NATIVA DO ROBLOX (Comandos que FUNCIONAM)
-- ============================================================
-- game:GetService()           → Pega serviços
-- ReplicatedStorage          → Comunicação com servidor
-- Workspace                  → Mundo do jogo
-- Players                    → Jogadores
-- VirtualInputManager        → Cliques virtuais
-- UserInputService           → Input do teclado
-- RunService                 → Loops otimizados
-- TweenService               → Animações suaves
-- Camera                     → Controle de câmera
-- Instance.new()             → Criar objetos
-- :FindFirstChild()          → Encontrar objetos
-- :WaitForChild()            → Esperar objeto
-- :GetChildren()             → Listar filhos
-- :IsA()                     → Verificar tipo
-- task.wait()                → Esperar
-- task.spawn()               → Criar thread
-- pcall()                    → Proteger erros
-- CFrame.new()               → Posição 3D
-- Vector3.new()              → Vetor 3D
-- Color3.fromRGB()           → Cor
-- UDim2.new()                → Tamanho UI

-- ============================================================
-- VERIFICAÇÃO DE JOGO
-- ============================================================
local PlaceId = game.PlaceId
local BloxFruitsIDs = {2753915549, 4442272183, 7449423635}
local permitido = false
for _, id in BloxFruitsIDs do
    if PlaceId == id then permitido = true break end
end
if not permitido then return end

-- ============================================================
-- UI (DiscordLib carregada via game:HttpGet)
-- ============================================================
local uiCode = game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")
local DiscordLib = loadstring(uiCode)()

-- ============================================================
-- SERVIÇOS NATIVOS DO ROBLOX
-- ============================================================
local Jogadores = game:GetService("Players")
local Mundo = game:GetService("Workspace")
local Storage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Tween = game:GetService("TweenService")
local Luz = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Jogador = Jogadores.LocalPlayer
local Camera = Mundo.CurrentCamera

-- ============================================================
-- ESPERAR CARREGAR (Comandos nativos)
-- ============================================================
game.Loaded:Wait()
repeat task.wait(0.3) until Jogador.Character
task.wait(1)

-- ============================================================
-- OTIMIZAÇÕES (Comandos nativos)
-- ============================================================
pcall(function() settings().Rendering.QualityLevel = 1 end)
Luz.GlobalShadows = false
Luz.Brightness = 1.5
Luz.FogEnd = 5000

-- ============================================================
-- FLAGS
-- ============================================================
_G.LigarFarm = false
_G.PuxarMob = true
_G.Distancia = 300
_G.VelocidadeClick = 0.05

-- ============================================================
-- SISTEMA DE COMUNICAÇÃO (Remotes nativos)
-- ============================================================
local function PegarRemote(nome)
    local pasta = Storage:FindFirstChild("Remotes")
    if pasta then
        return pasta:FindFirstChild(nome)
    end
    return nil
end

local function Comando(nome, ...)
    pcall(function()
        local remote = PegarRemote("CommF_") or PegarRemote("CommF")
        if remote then
            remote:InvokeServer(nome, ...)
        end
    end)
end

-- ============================================================
-- SISTEMA DE TELEPORTE (CFrame nativo)
-- ============================================================
local function Teleportar(posicao)
    local personagem = Jogador.Character
    if not personagem then return end
    
    local raiz = personagem:FindFirstChild("HumanoidRootPart")
    if not raiz then return end
    
    -- Usa CFrame (comando nativo do Roblox)
    local destino = CFrame.new(posicao + Vector3.new(0, 3, 0))
    raiz.CFrame = destino
end

-- ============================================================
-- SISTEMA DE MIRA (Camera nativa)
-- ============================================================
local function MirarNoAlvo(posicaoAlvo)
    local minhaPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.new(minhaPos, posicaoAlvo)
end

-- ============================================================
-- SISTEMA DE ATAQUE (VirtualInputManager nativo)
-- ============================================================
local function Atacar()
    -- Método 1: Remote do jogo
    Comando("Attack")
    
    -- Método 2: API de ataque rápido
    pcall(function()
        local modulos = Storage:FindFirstChild("Modules")
        if modulos then
            local net = modulos:FindFirstChild("Net")
            if net then
                local ataque = net:FindFirstChild("RE/RegisterAttack")
                if ataque then
                    ataque:FireServer(1e-9)
                end
            end
        end
    end)
    
    -- Método 3: VirtualInputManager (NATIVO DO ROBLOX)
    pcall(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(_G.VelocidadeClick)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- ============================================================
-- SISTEMA DE EQUIPAMENTO (Humanoid nativo)
-- ============================================================
local function EquiparArma(tipo)
    pcall(function()
        local mochila = Jogador.Backpack
        local personagem = Jogador.Character
        if not mochila or not personagem then return end
        
        local humanoide = personagem:FindFirstChildOfClass("Humanoid")
        if not humanoide then return end
        
        for _, ferramenta in mochila:GetChildren() do
            if ferramenta:IsA("Tool") then
                if tipo == "Melee" and ferramenta.ToolTip == "Melee" then
                    humanoide:EquipTool(ferramenta)
                    break
                elseif tipo == "Sword" and ferramenta.ToolTip == "Sword" then
                    humanoide:EquipTool(ferramenta)
                    break
                elseif tipo == "Blox Fruit" and ferramenta.ToolTip == "Blox Fruit" then
                    humanoide:EquipTool(ferramenta)
                    break
                end
            end
        end
    end)
end

-- ============================================================
-- SISTEMA DE HAKI
-- ============================================================
local function AtivarHaki()
    Comando("Buso")
end

-- ============================================================
-- SISTEMA DE ENCONTRAR INIMIGOS (FindFirstChild nativo)
-- ============================================================
local function EncontrarInimigoMaisProximo()
    local personagem = Jogador.Character
    if not personagem then return nil end
    
    local minhaRaiz = personagem:FindFirstChild("HumanoidRootPart")
    if not minhaRaiz then return nil end
    
    local pastaInimigos = Mundo:FindFirstChild("Enemies")
    if not pastaInimigos then return nil end
    
    local maisProximo = nil
    local menorDistancia = _G.Distancia
    
    for _, inimigo in pastaInimigos:GetChildren() do
        if inimigo:IsA("Model") then
            local humanoide = inimigo:FindFirstChild("Humanoid")
            local raiz = inimigo:FindFirstChild("HumanoidRootPart")
            
            if humanoide and raiz and humanoide.Health > 0 then
                local distancia = (raiz.Position - minhaRaiz.Position).Magnitude
                if distancia < menorDistancia then
                    menorDistancia = distancia
                    maisProximo = inimigo
                end
            end
        end
    end
    
    return maisProximo
end

-- ============================================================
-- SISTEMA DE BRING MOB (CFrame + Velocity nativos)
-- ============================================================
local function PuxarInimigo(inimigo)
    local personagem = Jogador.Character
    if not personagem then return end
    
    local minhaRaiz = personagem:FindFirstChild("HumanoidRootPart")
    local raizInimigo = inimigo:FindFirstChild("HumanoidRootPart")
    local humanoide = inimigo:FindFirstChild("Humanoid")
    
    if not minhaRaiz or not raizInimigo or not humanoide then return end
    
    -- Posiciona o inimigo na frente do jogador
    local posicaoFrente = minhaRaiz.CFrame * CFrame.new(0, 0, -5)
    raizInimigo.CFrame = posicaoFrente
    
    -- Zera a velocidade
    raizInimigo.Velocity = Vector3.new(0, 0, 0)
    raizInimigo.RotVelocity = Vector3.new(0, 0, 0)
    
    -- Trava o inimigo
    humanoide.WalkSpeed = 0
    humanoide.JumpPower = 0
end

-- ============================================================
-- LOOP PRINCIPAL DE FARM (RunService nativo)
-- ============================================================
local function IniciarFarm()
    task.spawn(function()
        while task.wait(0.05) do
            if not _G.LigarFarm then continue end
            
            pcall(function()
                EquiparArma("Melee")
                AtivarHaki()
                
                local inimigo = EncontrarInimigoMaisProximo()
                
                if inimigo then
                    local raizInimigo = inimigo:FindFirstChild("HumanoidRootPart")
                    local humanoide = inimigo:FindFirstChild("Humanoid")
                    
                    if raizInimigo and humanoide and humanoide.Health > 0 then
                        -- Vai até o inimigo
                        local minhaRaiz = Jogador.Character:FindFirstChild("HumanoidRootPart")
                        if minhaRaiz then
                            local distancia = (raizInimigo.Position - minhaRaiz.Position).Magnitude
                            if distancia > 10 then
                                Teleportar(raizInimigo.Position)
                                task.wait(0.3)
                            end
                        end
                        
                        -- Mira no inimigo
                        MirarNoAlvo(raizInimigo.Position)
                        
                        -- Primeiro hit
                        Atacar()
                        task.wait(0.2)
                        
                        -- Puxa o inimigo
                        if _G.PuxarMob then
                            PuxarInimigo(inimigo)
                        end
                        
                        -- Ataca continuamente
                        for i = 1, 50 do
                            if not _G.LigarFarm then break end
                            if not humanoide or humanoide.Health <= 0 then break end
                            if not raizInimigo or not raizInimigo.Parent then break end
                            
                            -- Mantém o inimigo na frente
                            if _G.PuxarMob then
                                PuxarInimigo(inimigo)
                            end
                            
                            -- Mira e ataca
                            MirarNoAlvo(raizInimigo.Position)
                            Atacar()
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end)
end

-- ============================================================
-- GOD MODE (Humanoid nativo)
-- ============================================================
task.spawn(function()
    while task.wait(0.3) do
        if not _G.LigarFarm then continue end
        pcall(function()
            local humanoide = Jogador.Character and Jogador.Character:FindFirstChildOfClass("Humanoid")
            if humanoide and humanoide.Health > 0 then
                humanoide.Health = humanoide.MaxHealth
            end
        end)
    end
end)

-- ============================================================
-- UI (Instância nativa)
-- ============================================================
local janela = DiscordLib:Window("NEXUS SUPREMO")
local servidor = janela:Server("Blox Fruits", "")
local canal = servidor:Channel("⚔️ Auto Farm")

canal:Toggle("Auto Farm", false, function(ligado)
    _G.LigarFarm = ligado
    if ligado then IniciarFarm() end
end)

canal:Toggle("Puxar Mob", true, function(ligado)
    _G.PuxarMob = ligado
end)

canal:Slider("Distância", 50, 500, 300, function(valor)
    _G.Distancia = valor
end)

canal:Button("Atacar (Teste)", function()
    Atacar()
end)

-- ============================================================
-- NOTIFICAÇÃO
-- ============================================================
DiscordLib:Notification("NEXUS SUPREMO", "Script carregado!\nUsando API nativa do Roblox", "OK")

print("✅ NEXUS SUPREMO - PRONTO!")
print("📋 Usando comandos nativos do Roblox")
