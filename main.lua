-- // NEXUS BÁSICO - UI + AUTO FARM SIMPLES
-- // Apenas o essencial que funciona

-- ============================================================
-- UI
-- ============================================================
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

-- ============================================================
-- SERVIÇOS (APENAS 4)
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
_G.AutoFarm = false
_G.BringMob = true

-- ============================================================
-- FUNÇÕES
-- ============================================================
local function GetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then return remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF") end
    return nil
end

local function TP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

local function Attack()
    pcall(function()
        local remote = GetRemote()
        if remote then remote:InvokeServer("Attack") end
    end)
end

-- ============================================================
-- AUTO FARM SIMPLES
-- ============================================================
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoFarm then task.wait(1); continue end
        
        pcall(function()
            local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not myPos then return end
            
            local enemies = Workspace:FindFirstChild("Enemies")
            if not enemies then return end
            
            for _, enemy in pairs(enemies:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                    local hum = enemy:FindFirstChild("Humanoid")
                    
                    if hrp and hum then
                        -- Vai até o inimigo
                        local dist = (hrp.Position - myPos.Position).Magnitude
                        if dist > 10 then TP(hrp.Position); task.wait(0.3) end
                        
                        -- Puxa o inimigo
                        if _G.BringMob then
                            hrp.CFrame = myPos.CFrame * CFrame.new(0, 0, -5)
                            hrp.Velocity = Vector3.zero
                            hum.WalkSpeed = 0
                            hum.JumpPower = 0
                        end
                        
                        -- Ataca
                        Attack()
                        break
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- UI
-- ============================================================
local win = DiscordLib:Window("NEXUS BÁSICO")
local serv = win:Server("Main", "")
local ch = serv:Channel("Farm")

ch:Toggle("Auto Farm", false, function(v) _G.AutoFarm = v end)
ch:Toggle("Bring Mob", true, function(v) _G.BringMob = v end)
ch:Button("Atacar", Attack)

DiscordLib:Notification("NEXUS", "Script carregado!", "OK")
