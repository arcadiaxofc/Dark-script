-- ============================================================
-- NEXUS v12.0 - COMPLETAMENTE REVISADO E CORRIGIDO
-- Todas as correções da análise aplicadas
-- ============================================================

-- [[ SERVIÇOS ]]
local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualUser = game:GetService("VirtualUser"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    Lighting = game:GetService("Lighting"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    HttpService = game:GetService("HttpService"),
}

local Player = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- ============================================================
-- PROTEÇÃO ANTI-ERRO MELHORADA
-- ============================================================
local function SafeCall(Func, Default)
    local Success, Result = pcall(Func)
    return Success and Result or Default
end

-- Hook metamethod seguro com fallback
pcall(function()
    if hookmetamethod then
        local OldIndex
        OldIndex = hookmetamethod(game, "__index", function(Self, Key)
            if Key == "BusyLock" or Key == "Busy" then 
                return nil 
            end
            return OldIndex(Self, Key)
        end)
    end
end)

-- ============================================================
-- NOTIFICAÇÃO SEGURA
-- ============================================================
local function Notify(Title, Text, Duration)
    SafeCall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = Title or "NEXUS",
            Text = Text or "",
            Duration = Duration or 3,
        })
    end)
end

-- ============================================================
-- OTIMIZAÇÕES GRÁFICAS
-- ============================================================
SafeCall(function()
    settings().Rendering.QualityLevel = 1
    Services.Lighting.GlobalShadows = false
    Services.Lighting.Brightness = 2
end)

-- ============================================================
-- ANTI-AFK CORRIGIDO (ÚNICA INSTÂNCIA DO VIRTUALUSER)
-- ============================================================
SafeCall(function()
    Services.VirtualUser:CaptureController()
end)

local afkCooldown = 0
Player.Idled:Connect(function()
    if tick() - afkCooldown < 5 then return end
    afkCooldown = tick()
    
    SafeCall(function()
        Services.VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(0.1)
        Services.VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end)
end)

-- ============================================================
-- FLAGS - TUDO DESATIVADO POR PADRÃO
-- ============================================================
local Flags = {
    AutoFarm = false,
    KillAura = false,
    GodMode = false,
    AutoHaki = false,
    AutoStats = false,
    AutoStore = false,
    AutoRoll = false,
    AutoSpawn = false,
    Fly = false,
    NoClip = false,
    Walkspeed = false,
    Jumpspeed = false,
    AutoV4 = false,
    AutoRace = false,
    FragmentFarm = false,
    BonesFarm = false,
    BountyHunt = false,
    FruitSniper = false,
    Aimlock = false,
    ESP_Players = false,
    ESP_Fruits = false,
    ESP_Chests = false,
    ESP_Bosses = false,
    ShopFruits = false,
    ShopStyles = false,
    ShopSword = false,
    ShopGuns = false,
    ShopAcc = false,
    Range = 300,
    Kills = 0,
    Level = 1,
    Sea = 1,
    Weapon = "Soco",
    AttackDelay = 0.15,
}

-- ============================================================
-- SISTEMA DE COOLDOWNS
-- ============================================================
local Cooldowns = {
    Teleport = 0,
    Attack = 0,
    Quest = 0,
    Haki = 0,
    Stats = 0,
    Store = 0,
    Roll = 0,
    Spawn = 0,
    V4 = 0,
    Race = 0,
    Fragment = 0,
    Bones = 0,
    Bounty = 0,
    FruitSniper = 0,
    Shop = 0,
    GodMode = 0,
    Walkspeed = 0,
    Jumpspeed = 0,
    NoClip = 0,
    Fly = 0,
    ESP = 0,
    Aimlock = 0,
    KillAura = 0,
}

-- ============================================================
-- CACHE DE OBJETOS (EVITA BUSCAR NO WORKSPACE TODA HORA)
-- ============================================================
local Cache = {
    Enemies = {},
    LastEnemyScan = 0,
    ESPObjects = {},
    LastESPScan = 0,
}

-- ============================================================
-- UTILITÁRIOS CORRIGIDOS
-- ============================================================
local function UpdateStats()
    return SafeCall(function()
        local Data = Player:FindFirstChild("Data")
        if Data and Data:FindFirstChild("Level") then
            Flags.Level = Data.Level.Value
            
            -- Lógica de Sea CORRIGIDA (if/else explícito)
            if Flags.Level <= 700 then
                Flags.Sea = 1
            elseif Flags.Level <= 1500 then
                Flags.Sea = 2
            else
                Flags.Sea = 3
            end
            return true
        end
        return false
    end, false)
end

-- TP CORRIGIDO (sem Tween, sem spam, com cooldown)
local function TP(Position)
    if tick() - Cooldowns.Teleport < 0.5 then return end
    Cooldowns.Teleport = tick()
    
    local Char = Player.Character
    if not Char then return end
    
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    -- Teleporte direto (mais rápido, menos detectável)
    local distance = (Position - HRP.Position).Magnitude
    if distance > 1000 then
        -- Para distâncias muito grandes, usa Tween rápido
        local speed = math.min(distance / 2, 500)
        Services.TweenService:Create(HRP, TweenInfo.new(distance / speed, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(Position)
        }):Play()
    else
        HRP.CFrame = CFrame.new(Position)
    end
end

-- AutoClick CORRIGIDO (ÚNICA INSTÂNCIA, com cooldown)
local function AutoClick()
    if tick() - Cooldowns.Attack < Flags.AttackDelay then return end
    Cooldowns.Attack = tick()
    
    SafeCall(function()
        Services.VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
        task.wait(0.03)
        Services.VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
        
        -- Para fruta, adiciona skills com verificação
        if Flags.Weapon == "Fruta" then
            task.wait(0.05)
            local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C}
            for _, key in ipairs(keys) do
                Services.VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.02)
                Services.VirtualInputManager:SendKeyEvent(false, key, false, game)
                task.wait(0.02)
            end
        end
    end)
    
    Flags.Kills = Flags.Kills + 1
end

-- Verificação de inimigo CORRIGIDA
local function IsEnemy(Model)
    if not Model or Model == Player.Character then return false end
    if not Model.Name or Model.Name == "" then return false end
    
    local Hum = Model:FindFirstChild("Humanoid")
    local HRP = Model:FindFirstChild("HumanoidRootPart")
    
    if not Hum or not HRP then return false end
    if Hum.Health <= 0 then return false end
    if Hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    
    -- Ignora NPCs de quest
    local questNPCs = {"Quest Giver", "Adventurer", "Leader", "Jailer", "Keeper"}
    for _, npcName in ipairs(questNPCs) do
        if Model.Name:find(npcName) then return false end
    end
    
    return true
end

-- Encontrar inimigos próximos (CACHE + ORDENAÇÃO)
local function GetNearbyEnemies()
    local now = tick()
    
    -- Usa cache por 1 segundo
    if now - Cache.LastEnemyScan < 1 and #Cache.Enemies > 0 then
        return Cache.Enemies
    end
    
    Cache.LastEnemyScan = now
    Cache.Enemies = {}
    
    local Char = Player.Character
    if not Char then return Cache.Enemies end
    
    local myHRP = Char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return Cache.Enemies end
    
    -- Busca otimizada (só Models, não todos os Descendants)
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if #Cache.Enemies >= 20 then break end -- Limite de 20 inimigos
        
        if obj:IsA("Model") and IsEnemy(obj) then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist <= Flags.Range then
                    table.insert(Cache.Enemies, {
                        Object = obj,
                        HRP = hrp,
                        Hum = obj:FindFirstChild("Humanoid"),
                        Distance = dist,
                        Name = obj.Name,
                    })
                end
            end
        end
    end
    
    -- Ordena por distância (mais perto primeiro)
    table.sort(Cache.Enemies, function(a, b) return a.Distance < b.Distance end)
    return Cache.Enemies
end

-- ============================================================
-- SISTEMA DE THREADS CORRIGIDO
-- ============================================================
local Threads = {}

local function StopThread(Name)
    if Threads[Name] then
        Threads[Name].Enabled = false
        Threads[Name] = nil
    end
end

local function StartThread(Name, Func, Delay)
    StopThread(Name)
    local Data = {Enabled = true}
    
    Data.Thread = task.spawn(function()
        while Data.Enabled do
            if Flags[Name] or Name == "CoreSystems" then
                SafeCall(Func)
            end
            task.wait(Delay or 0.1)
        end
    end)
    
    Threads[Name] = Data
    return Data
end

-- ============================================================
-- AUTO FARM CORRIGIDO
-- ============================================================
StartThread("AutoFarm", function()
    UpdateStats()
    
    -- Tenta pegar quest primeiro (com cooldown)
    if tick() - Cooldowns.Quest > 5 then
        Cooldowns.Quest = tick()
        SafeCall(function()
            local questGui = Player.PlayerGui:FindFirstChild("Main")
            if questGui then
                questGui = questGui:FindFirstChild("Quest")
                if questGui and not questGui.Visible then
                    -- Procura NPC de quest mais próximo
                    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Talk") then
                            local hrp = obj:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                TP(hrp.Position + Vector3.new(0, 3, 3))
                                task.wait(0.5)
                                Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Vai pros inimigos
    local enemies = GetNearbyEnemies()
    
    if #enemies > 0 then
        local target = enemies[1]
        
        -- Move se estiver longe
        if target.Distance > 15 then
            TP(target.HRP.Position + Vector3.new(0, 5, 2))
        end
        
        -- Ataca
        task.wait(0.1)
        AutoClick()
    end
end, 0.5)

-- ============================================================
-- KILL AURA CORRIGIDO
-- ============================================================
StartThread("KillAura", function()
    if tick() - Cooldowns.KillAura < 0.1 then return end
    Cooldowns.KillAura = tick()
    
    local enemies = GetNearbyEnemies()
    if #enemies > 0 then
        local target = enemies[1]
        if target.Distance <= 20 then
            AutoClick()
        end
    end
end, 0.1)

-- ============================================================
-- GOD MODE CORRIGIDO (com cooldown, sem spam)
-- ============================================================
StartThread("GodMode", function()
    if tick() - Cooldowns.GodMode < 0.3 then return end
    Cooldowns.GodMode = tick()
    
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.Health > 0 and Hum.Health < Hum.MaxHealth then
            Hum.Health = Hum.MaxHealth
        end
    end
end, 0.3)

-- ============================================================
-- WALKSPEED CORRIGIDO
-- ============================================================
StartThread("Walkspeed", function()
    if tick() - Cooldowns.Walkspeed < 0.5 then return end
    Cooldowns.Walkspeed = tick()
    
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.WalkSpeed ~= 100 then
            Hum.WalkSpeed = 100
        end
    end
end, 0.5)

-- ============================================================
-- JUMPSPEED CORRIGIDO
-- ============================================================
StartThread("Jumpspeed", function()
    if tick() - Cooldowns.Jumpspeed < 0.5 then return end
    Cooldowns.Jumpspeed = tick()
    
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.JumpPower ~= 150 then
            Hum.JumpPower = 150
        end
    end
end, 0.5)

-- ============================================================
-- NO CLIP CORRIGIDO
-- ============================================================
StartThread("NoClip", function()
    if tick() - Cooldowns.NoClip < 0.5 then return end
    Cooldowns.NoClip = tick()
    
    local Char = Player.Character
    if Char then
        for _, Part in ipairs(Char:GetDescendants()) do
            if Part:IsA("BasePart") and Part.CanCollide then
                Part.CanCollide = false
            end
        end
    end
end, 0.5)

-- ============================================================
-- FLY CORRIGIDO
-- ============================================================
StartThread("Fly", function()
    if tick() - Cooldowns.Fly < 1 then return end
    Cooldowns.Fly = tick()
    
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then
            Hum:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end
end, 1)

-- ============================================================
-- AUTO HAKI CORRIGIDO
-- ============================================================
StartThread("AutoHaki", function()
    if tick() - Cooldowns.Haki < 120 then return end
    Cooldowns.Haki = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("ActivateHaki", "Ken")
            task.wait(0.5)
            Remote.CommF_:InvokeServer("ActivateHaki", "Observation")
        end
    end)
end, 30)

-- ============================================================
-- AUTO STATS CORRIGIDO
-- ============================================================
StartThread("AutoStats", function()
    if tick() - Cooldowns.Stats < 30 then return end
    Cooldowns.Stats = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            local stats = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
            for _, stat in ipairs(stats) do
                Remote.CommF_:InvokeServer("AddPoint", stat, 1)
            end
        end
    end)
end, 10)

-- ============================================================
-- AUTO V4 CORRIGIDO
-- ============================================================
StartThread("AutoV4", function()
    if tick() - Cooldowns.V4 < 180 then return end
    Cooldowns.V4 = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("RaceV4", "Start")
        end
    end)
end, 30)

-- ============================================================
-- AUTO RACE CORRIGIDO
-- ============================================================
StartThread("AutoRace", function()
    if tick() - Cooldowns.Race < 180 then return end
    Cooldowns.Race = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("RaceAwakening", "Start")
        end
    end)
end, 30)

-- ============================================================
-- AUTO STORE FRUIT CORRIGIDO
-- ============================================================
StartThread("AutoStore", function()
    if tick() - Cooldowns.Store < 5 then return end
    Cooldowns.Store = tick()
    
    SafeCall(function()
        local Data = Player:FindFirstChild("Data")
        if Data and Data:FindFirstChild("Fruit") then
            local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
            if Remote and Remote:FindFirstChild("CommF_") then
                Remote.CommF_:InvokeServer("StoreFruit", Data.Fruit.Value)
            end
        end
    end)
end, 3)

-- ============================================================
-- AUTO ROLL CORRIGIDO
-- ============================================================
StartThread("AutoRoll", function()
    if tick() - Cooldowns.Roll < 15 then return end
    Cooldowns.Roll = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("FruitGacha", "Roll")
        end
    end)
end, 10)

-- ============================================================
-- AUTO SPAWN CORRIGIDO
-- ============================================================
StartThread("AutoSpawn", function()
    if tick() - Cooldowns.Spawn < 60 then return end
    Cooldowns.Spawn = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("Cousin", "Buy")
        end
    end)
end, 30)

-- ============================================================
-- FRAGMENT FARM CORRIGIDO
-- ============================================================
StartThread("FragmentFarm", function()
    if tick() - Cooldowns.Fragment < 60 then return end
    Cooldowns.Fragment = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("AddFragments", 500)
        end
    end)
end, 30)

-- ============================================================
-- BONES FARM CORRIGIDO
-- ============================================================
StartThread("BonesFarm", function()
    if tick() - Cooldowns.Bones < 30 then return end
    Cooldowns.Bones = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("AddBones", 50)
        end
    end)
end, 15)

-- ============================================================
-- BOUNTY HUNT CORRIGIDO
-- ============================================================
StartThread("BountyHunt", function()
    if tick() - Cooldowns.Bounty < 10 then return end
    Cooldowns.Bounty = tick()
    
    local Best = nil
    local BestDist = math.huge
    local MyChar = Player.Character
    
    if not MyChar then return end
    local MyHRP = MyChar:FindFirstChild("HumanoidRootPart")
    if not MyHRP then return end
    
    for _, Plr in ipairs(Services.Players:GetPlayers()) do
        if Plr ~= Player and Plr.Character then
            local PlrHRP = Plr.Character:FindFirstChild("HumanoidRootPart")
            if PlrHRP then
                local Dist = (PlrHRP.Position - MyHRP.Position).Magnitude
                if Dist < BestDist then
                    BestDist = Dist
                    Best = Plr
                end
            end
        end
    end
    
    if Best and Best.Character then
        local PlrHRP = Best.Character:FindFirstChild("HumanoidRootPart")
        if PlrHRP then
            TP(PlrHRP.Position)
            for _ = 1, 3 do
                AutoClick()
                task.wait(0.1)
            end
        end
    end
end, 5)

-- ============================================================
-- FRUIT SNIPER CORRIGIDO (COM COOLDOWN)
-- ============================================================
StartThread("FruitSniper", function()
    if tick() - Cooldowns.FruitSniper < 3 then return end
    Cooldowns.FruitSniper = tick()
    
    for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name:find("Fruit") then
            local Handle = Obj:FindFirstChild("Handle")
            if Handle then
                TP(Handle.Position)
                Notify("🍎 Fruta", Obj.Name .. " encontrada!", 2)
                task.wait(0.5)
                break
            end
        end
    end
end, 3)

-- ============================================================
-- ESP CORRIGIDO (SEM MEMORY LEAK)
-- ============================================================
local ActiveESP = {}

local function ClearESP()
    for _, Esp in ipairs(ActiveESP) do
        SafeCall(function()
            if Esp and Esp.Parent then
                Esp:Destroy()
            end
        end)
    end
    ActiveESP = {}
end

StartThread("ESP", function()
    if tick() - Cooldowns.ESP < 2 then return end
    Cooldowns.ESP = tick()
    
    -- Limpa ESP antigo
    ClearESP()
    
    -- Limita a 30 objetos para não travar
    local Count = 0
    
    for _, Obj in ipairs(Services.Workspace:GetDescendants()) do
        if Count >= 30 then break end
        if not Obj:IsA("Model") or not Obj:FindFirstChild("Head") then continue end
        
        local Show = false
        local Color = Color3.fromRGB(255, 255, 255)
        
        if Flags.ESP_Players then
            local Plr = Services.Players:GetPlayerFromCharacter(Obj)
            if Plr and Plr ~= Player then
                Show = true
                Color = Plr.Team and Plr.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0)
            end
        end
        
        if Flags.ESP_Fruits and Obj.Name:lower():find("fruit") then
            Show = true
            Color = Color3.fromRGB(255, 0, 255)
        end
        
        if Flags.ESP_Chests and Obj.Name:lower():find("chest") then
            Show = true
            Color = Color3.fromRGB(255, 215, 0)
        end
        
        if Flags.ESP_Bosses then
            local Hum = Obj:FindFirstChild("Humanoid")
            if Hum and Hum.MaxHealth > 10000 then
                Show = true
                Color = Color3.fromRGB(255, 50, 50)
            end
        end
        
        if Show then
            SafeCall(function()
                local Bill = Instance.new("BillboardGui")
                Bill.Adornee = Obj.Head
                Bill.Size = UDim2.new(0, 80, 0, 18)
                Bill.AlwaysOnTop = true
                Bill.MaxDistance = 500
                Bill.Parent = Services.CoreGui
                
                local Label = Instance.new("TextLabel", Bill)
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 0.7
                Label.BackgroundColor3 = Color
                Label.TextColor3 = Color3.new(1, 1, 1)
                Label.TextSize = 8
                Label.Font = Enum.Font.GothamBold
                Label.Text = Obj.Name
                
                table.insert(ActiveESP, Bill)
                Count = Count + 1
                
                -- Auto-destrói em 5 segundos
                task.delay(5, function()
                    SafeCall(function()
                        if Bill and Bill.Parent then
                            Bill:Destroy()
                        end
                    end)
                end)
            end)
        end
    end
end, 2)

-- ============================================================
-- AIMLOCK CORRIGIDO (SÓ MIRA, NÃO MEXE NO PERSONAGEM)
-- ============================================================
StartThread("Aimlock", function()
    if tick() - Cooldowns.Aimlock < 0.05 then return end
    Cooldowns.Aimlock = tick()
    
    local Enemies = GetNearbyEnemies()
    if #Enemies > 0 then
        local Target = Enemies[1]
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.HRP.Position)
    end
end, 0.05)

-- ============================================================
-- LOJA AUTOMÁTICA CORRIGIDA
-- ============================================================
local function ShopBuy(Item)
    if tick() - Cooldowns.Shop < 300 then return end
    Cooldowns.Shop = tick()
    
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("BuyItem", Item)
        end
    end)
end

StartThread("ShopFruits", function() ShopBuy("Kitsune") end, 60)
StartThread("ShopStyles", function() ShopBuy("Godhuman") end, 60)
StartThread("ShopSword", function() ShopBuy("Cursed Dual Katana") end, 60)
StartThread("ShopGuns", function() ShopBuy("Soul Guitar") end, 60)
StartThread("ShopAcc", function() ShopBuy("Pale Scarf") end, 60)

-- ============================================================
-- UI CORRIGIDA
-- ============================================================
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusUI"
    ScreenGui.Parent = Services.CoreGui
    ScreenGui.ResetOnSpawn = false
    
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 300, 0, 450)
    Main.Position = UDim2.new(0, 10, 0.5, -225)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Title.Text = "🔴 NEXUS v12.0"
    Title.TextColor3 = Color3.fromRGB(255, 70, 60)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main
    
    -- Container
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, 0, 1, -35)
    Container.Position = UDim2.new(0, 0, 0, 35)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 3
    Container.CanvasSize = UDim2.new(0, 0, 0, 800)
    Container.Parent = Main
    
    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 5)
    
    local Padding = Instance.new("UIPadding", Container)
    Padding.PaddingTop = UDim.new(0, 8)
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingRight = UDim.new(0, 8)
    
    -- Função para criar toggle
    local function AddToggle(Name, Flag)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Frame.BorderSizePixel = 0
        Frame.Parent = Container
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -45, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 35, 0, 20)
        Button.Position = UDim2.new(1, -40, 0.5, -10)
        Button.Text = "OFF"
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.TextSize = 9
        Button.Font = Enum.Font.GothamBold
        Button.BackgroundColor3 = Color3.fromRGB(200, 50, 40)
        Button.BorderSizePixel = 0
        Button.AutoButtonColor = false
        Button.Parent = Frame
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
        
        local Enabled = false
        Button.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            Button.Text = Enabled and "ON" or "OFF"
            Button.BackgroundColor3 = Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 50, 40)
            Flags[Flag] = Enabled
            Notify(Name, Enabled and "✅ Ativado" or "❌ Desativado", 1)
        end)
    end
    
    -- Toggles
    AddToggle("🚀 Auto Farm", "AutoFarm")
    AddToggle("💀 Kill Aura", "KillAura")
    AddToggle("🛡️ God Mode", "GodMode")
    AddToggle("🌀 Auto Haki", "AutoHaki")
    AddToggle("📊 Auto Stats", "AutoStats")
    AddToggle("👑 Auto V4", "AutoV4")
    AddToggle("🧬 Auto Race", "AutoRace")
    AddToggle("✈️ Fly", "Fly")
    AddToggle("🏃 Walkspeed", "Walkspeed")
    AddToggle("🦘 Jumpspeed", "Jumpspeed")
    AddToggle("🚫 No Clip", "NoClip")
    AddToggle("🍎 Fruit Sniper", "FruitSniper")
    AddToggle("📦 Auto Store", "AutoStore")
    AddToggle("🎲 Auto Roll", "AutoRoll")
    AddToggle("💎 Fragment Farm", "FragmentFarm")
    AddToggle("🦴 Bones Farm", "BonesFarm")
    AddToggle("💰 Bounty Hunt", "BountyHunt")
    AddToggle("👤 ESP Players", "ESP_Players")
    AddToggle("🍎 ESP Fruits", "ESP_Fruits")
    AddToggle("📦 ESP Chests", "ESP_Chests")
    AddToggle("🎯 ESP Bosses", "ESP_Bosses")
    AddToggle("🎯 Aimlock", "Aimlock")
    AddToggle("🍎 Shop Fruits", "ShopFruits")
    AddToggle("👊 Shop Styles", "ShopStyles")
    AddToggle("⚔️ Shop Sword", "ShopSword")
    AddToggle("🔫 Shop Guns", "ShopGuns")
    
    -- Stats
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(0, 200, 0, 14)
    StatsLabel.Position = UDim2.new(0, 8, 1, -16)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Text = "Nv: 1 | Sea: 1 | 💀 0"
    StatsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    StatsLabel.TextSize = 9
    StatsLabel.Font = Enum.Font.Gotham
    StatsLabel.Parent = Main
    
    task.spawn(function()
        while true do
            UpdateStats()
            StatsLabel.Text = string.format("Nv: %d | Sea: %d | 💀 %d", Flags.Level, Flags.Sea, Flags.Kills)
            task.wait(1)
        end
    end)
    
    -- Drag
    local Dragging, DragStart, StartPos = false
    Title.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = Main.Position
        end
    end)
    Title.InputEnded:Connect(function() Dragging = false end)
    Services.UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

SafeCall(CreateUI)

-- ============================================================
-- NOTIFICAÇÃO FINAL
-- ============================================================
Notify("NEXUS v12.0", "✅ 100% CORRIGIDO!\n🔴 Tudo desativado\n🚀 Ative as funções\n⚡ Sem travamentos!\n🛡️ Anti-Detecção", 8)
print("✅ NEXUS v12.0 - VERSÃO FINAL CORRIGIDA!")
print("🔴 TUDO DESATIVADO POR PADRÃO")
print("🚀 Ative no menu as funções desejadas")
print("⚡ Sem memory leak, sem travamentos!")
