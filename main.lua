-- ============================================================
-- NEXUS FINAL v13.0 - COMPLETO + OTIMIZADOR CELULAR FRACO
-- Tudo em um só script: Farm, Boss, Fruta, ESP, Loja, Bypass
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
-- OTIMIZADOR PARA CELULAR FRACO
-- ============================================================
local OptimizationConfig = {
    Enabled = true,
    GraphicsQuality = 1,
    Shadows = false,
    Textures = false,
    Particles = false,
    AntiAliasing = false,
    RenderDistance = 100,
    LowMemoryMode = true,
    RemoveWaterEffects = true,
    RemoveFog = true,
    RemoveSkyboxes = true,
    RemoveDecals = true,
}

local function ApplyOptimizations()
    pcall(function()
        settings().Rendering.QualityLevel = OptimizationConfig.GraphicsQuality
        Services.Lighting.GlobalShadows = OptimizationConfig.Shadows
        Services.Lighting.Brightness = 1
        
        if OptimizationConfig.RemoveFog then
            Services.Lighting.FogEnd = 99999
            Services.Lighting.FogStart = 99999
        end
        
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level1
        settings().Rendering.LimitDataRate = true
        
        if OptimizationConfig.RemoveWaterEffects then
            local Terrain = Services.Workspace:FindFirstChildOfClass("Terrain")
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0.5
            end
        end
        
        if OptimizationConfig.RemoveSkyboxes then
            for _, child in pairs(Services.Lighting:GetChildren()) do
                if child:IsA("Sky") then child:Destroy() end
            end
        end
        
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            pcall(function()
                if OptimizationConfig.Particles then
                    if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") then
                        obj.Enabled = false
                    end
                end
                if OptimizationConfig.RemoveDecals then
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        obj:Destroy()
                    end
                end
            end)
        end
    end)
end

ApplyOptimizations()
print("✅ OTIMIZADOR ATIVADO - MODO CELULAR FRACO")

-- ============================================================
-- BYPASS ANTI-CHEAT
-- ============================================================
pcall(function()
    local OldIndex = hookmetamethod(game, "__index", function(Self, Key)
        if Key == "BusyLock" or Key == "Busy" then return nil end
        if Key == "Value" and tostring(Self):find("FruitClient") then return nil end
        return OldIndex(Self, Key)
    end)
    
    local OldNewIndex = hookmetamethod(game, "__newindex", function(Self, Key, Value)
        if Key == "BusyLock" or Key == "Busy" then return end
        return OldNewIndex(Self, Key, Value)
    end)
    
    local OldError = error
    error = function(msg, level)
        if tostring(msg):find("BusyLock") or tostring(msg):find("FruitClient") or tostring(msg):find("NPCManager") then
            return
        end
        return OldError(msg, level or 2)
    end
end)

print("✅ ANTI-CHEAT BYPASSADO!")

-- ============================================================
-- PROTEÇÃO ANTI-ERRO
-- ============================================================
local function SafeCall(Func, Default)
    local Success, Result = pcall(Func)
    return Success and Result or Default
end

-- ============================================================
-- NOTIFICAÇÃO
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
-- ANTI-AFK
-- ============================================================
SafeCall(function()
    Services.VirtualUser:CaptureController()
end)

Player.Idled:Connect(function()
    SafeCall(function()
        Services.VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(0.1)
        Services.VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end)
end)

-- ============================================================
-- FLAGS - TUDO DESATIVADO
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
    Optimizer = OptimizationConfig.Enabled,
    Range = 300,
    Kills = 0,
    Level = 1,
    Sea = 1,
    AttackDelay = 0.15,
}

-- ============================================================
-- COOLDOWNS
-- ============================================================
local Cooldowns = {
    Teleport = 0, Attack = 0, Quest = 0, Haki = 0, Stats = 0,
    Store = 0, Roll = 0, Spawn = 0, V4 = 0, Race = 0,
    Fragment = 0, Bones = 0, Bounty = 0, FruitSniper = 0, Shop = 0,
    GodMode = 0, Walkspeed = 0, Jumpspeed = 0, NoClip = 0, Fly = 0, ESP = 0,
}

-- ============================================================
-- CACHE
-- ============================================================
local Cache = { Enemies = {}, LastEnemyScan = 0 }

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function UpdateStats()
    return SafeCall(function()
        local Data = Player:FindFirstChild("Data")
        if Data and Data:FindFirstChild("Level") then
            Flags.Level = Data.Level.Value
            if Flags.Level <= 700 then Flags.Sea = 1
            elseif Flags.Level <= 1500 then Flags.Sea = 2
            else Flags.Sea = 3 end
            return true
        end
        return false
    end, false)
end

local function TP(Position)
    if tick() - Cooldowns.Teleport < 0.5 then return end
    Cooldowns.Teleport = tick()
    local Char = Player.Character
    if not Char then return end
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    local Distance = (Position - HRP.Position).Magnitude
    if Distance > 1000 then
        local Speed = math.min(Distance / 2, 500)
        Services.TweenService:Create(HRP, TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(Position)
        }):Play()
    else
        HRP.CFrame = CFrame.new(Position)
    end
end

local function Attack()
    if tick() - Cooldowns.Attack < Flags.AttackDelay then return end
    Cooldowns.Attack = tick()
    SafeCall(function()
        Services.VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
        task.wait(0.03)
        Services.VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
    end)
    Flags.Kills = Flags.Kills + 1
end

local function IsEnemy(Model)
    if not Model or Model == Player.Character then return false end
    if not Model.Name or Model.Name == "" then return false end
    local Hum = Model:FindFirstChild("Humanoid")
    local HRP = Model:FindFirstChild("HumanoidRootPart")
    if not Hum or not HRP then return false end
    if Hum.Health <= 0 then return false end
    return true
end

local function GetNearbyEnemies()
    local now = tick()
    if now - Cache.LastEnemyScan < 1 and #Cache.Enemies > 0 then return Cache.Enemies end
    Cache.LastEnemyScan = now
    Cache.Enemies = {}
    local Char = Player.Character
    if not Char then return Cache.Enemies end
    local MyHRP = Char:FindFirstChild("HumanoidRootPart")
    if not MyHRP then return Cache.Enemies end
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if #Cache.Enemies >= 15 then break end
        if obj:IsA("Model") and IsEnemy(obj) then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - MyHRP.Position).Magnitude
                if dist <= Flags.Range then
                    table.insert(Cache.Enemies, {Object = obj, HRP = hrp, Distance = dist, Name = obj.Name})
                end
            end
        end
    end
    table.sort(Cache.Enemies, function(a, b) return a.Distance < b.Distance end)
    return Cache.Enemies
end

-- ============================================================
-- SISTEMA DE THREADS
-- ============================================================
local Threads = {}

local function StartThread(Name, Func, Delay)
    if Threads[Name] then Threads[Name].Enabled = false end
    local Data = {Enabled = true}
    Data.Thread = task.spawn(function()
        while Data.Enabled do
            if Flags[Name] or Name == "Core" then SafeCall(Func) end
            task.wait(Delay or 0.1)
        end
    end)
    Threads[Name] = Data
end

-- ============================================================
-- AUTO FARM
-- ============================================================
StartThread("AutoFarm", function()
    UpdateStats()
    local enemies = GetNearbyEnemies()
    if #enemies > 0 then
        local target = enemies[1]
        if target.Distance > 15 then TP(target.HRP.Position + Vector3.new(0, 5, 2)) end
        task.wait(0.1)
        Attack()
    end
end, 0.5)

-- ============================================================
-- KILL AURA
-- ============================================================
StartThread("KillAura", function()
    local enemies = GetNearbyEnemies()
    if #enemies > 0 and enemies[1].Distance <= 20 then Attack() end
end, 0.1)

-- ============================================================
-- GOD MODE
-- ============================================================
StartThread("GodMode", function()
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.Health > 0 and Hum.Health < Hum.MaxHealth then
            Hum.Health = Hum.MaxHealth
        end
    end
end, 0.3)

-- ============================================================
-- MOVIMENTO
-- ============================================================
StartThread("Walkspeed", function()
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.WalkSpeed ~= 100 then Hum.WalkSpeed = 100 end
    end
end, 0.5)

StartThread("Jumpspeed", function()
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.JumpPower ~= 150 then Hum.JumpPower = 150 end
    end
end, 0.5)

StartThread("NoClip", function()
    local Char = Player.Character
    if Char then
        for _, Part in ipairs(Char:GetDescendants()) do
            if Part:IsA("BasePart") and Part.CanCollide then Part.CanCollide = false end
        end
    end
end, 0.5)

StartThread("Fly", function()
    local Char = Player.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then Hum:ChangeState(Enum.HumanoidStateType.Freefall) end
    end
end, 1)

-- ============================================================
-- AUTO SISTEMAS
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

StartThread("AutoStats", function()
    if tick() - Cooldowns.Stats < 30 then return end
    Cooldowns.Stats = tick()
    SafeCall(function()
        local Remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if Remote and Remote:FindFirstChild("CommF_") then
            Remote.CommF_:InvokeServer("AddPoint", "Melee", 3)
        end
    end)
end, 10)

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
-- FRUTAS
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

StartThread("FruitSniper", function()
    if tick() - Cooldowns.FruitSniper < 3 then return end
    Cooldowns.FruitSniper = tick()
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Fruit") and obj:FindFirstChild("Handle") then
            TP(obj.Handle.Position)
            Notify("🍎 Fruta", obj.Name, 2)
            task.wait(0.5)
            break
        end
    end
end, 3)

-- ============================================================
-- FARMS EXTRAS
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

StartThread("BountyHunt", function()
    if tick() - Cooldowns.Bounty < 10 then return end
    Cooldowns.Bounty = tick()
    local Best, BestDist = nil, math.huge
    local MyChar = Player.Character
    if not MyChar then return end
    local MyHRP = MyChar:FindFirstChild("HumanoidRootPart")
    if not MyHRP then return end
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local plrHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if plrHRP then
                local dist = (plrHRP.Position - MyHRP.Position).Magnitude
                if dist < BestDist then BestDist = dist Best = plr end
            end
        end
    end
    if Best and Best.Character then
        local plrHRP = Best.Character:FindFirstChild("HumanoidRootPart")
        if plrHRP then
            TP(plrHRP.Position)
            for _ = 1, 3 do Attack() task.wait(0.1) end
        end
    end
end, 5)

-- ============================================================
-- ESP
-- ============================================================
local ActiveESP = {}

StartThread("ESP", function()
    if tick() - Cooldowns.ESP < 2 then return end
    Cooldowns.ESP = tick()
    
    for _, esp in ipairs(ActiveESP) do
        SafeCall(function() if esp and esp.Parent then esp:Destroy() end end)
    end
    ActiveESP = {}
    
    local Count = 0
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if Count >= 20 then break end
        if not obj:IsA("Model") or not obj:FindFirstChild("Head") then continue end
        
        local Show, Color = false, Color3.fromRGB(255, 255, 255)
        
        if Flags.ESP_Players then
            local plr = Services.Players:GetPlayerFromCharacter(obj)
            if plr and plr ~= Player then Show = true Color = Color3.fromRGB(255, 0, 0) end
        end
        if Flags.ESP_Fruits and obj.Name:lower():find("fruit") then Show = true Color = Color3.fromRGB(255, 0, 255) end
        if Flags.ESP_Chests and obj.Name:lower():find("chest") then Show = true Color = Color3.fromRGB(255, 215, 0) end
        if Flags.ESP_Bosses then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.MaxHealth > 10000 then Show = true Color = Color3.fromRGB(255, 50, 50) end
        end
        
        if Show then
            SafeCall(function()
                local Bill = Instance.new("BillboardGui")
                Bill.Adornee = obj.Head
                Bill.Size = UDim2.new(0, 60, 0, 16)
                Bill.AlwaysOnTop = true
                Bill.MaxDistance = 300
                Bill.Parent = Services.CoreGui
                
                local Label = Instance.new("TextLabel", Bill)
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 0.7
                Label.BackgroundColor3 = Color
                Label.TextColor3 = Color3.new(1, 1, 1)
                Label.TextSize = 7
                Label.Font = Enum.Font.GothamBold
                Label.Text = obj.Name
                
                table.insert(ActiveESP, Bill)
                Count = Count + 1
                
                task.delay(5, function()
                    SafeCall(function() if Bill and Bill.Parent then Bill:Destroy() end end)
                end)
            end)
        end
    end
end, 2)

-- ============================================================
-- AIMLOCK
-- ============================================================
StartThread("Aimlock", function()
    local enemies = GetNearbyEnemies()
    if #enemies > 0 then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, enemies[1].HRP.Position)
    end
end, 0.05)

-- ============================================================
-- LOJA AUTOMÁTICA
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
-- CARREGAR UI DO LINK
-- ============================================================
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()

local win = NexusUI:CreateWindow({
    Title = "NEXUS v13.0",
    Subtitle = "Mobile Otimizado | Delta",
    Width = 580,
    Height = 500
})

local tabs = {}
for _, t in pairs({
    {"⚔️ Farm", "⚔️"}, {"🎯 Bosses", "🎯"}, {"🍎 Frutas", "🍎"}, {"💎 Farms", "💎"},
    {"🏃 Move", "🏃"}, {"⚙️ Auto", "⚙️"}, {"🛍️ Loja", "🛍️"}, {"👀 ESP", "👀"},
    {"🎮 Extra", "🎮"}, {"🏝️ Ilhas", "🏝️"}
}) do
    tabs[t[1]] = NexusUI:CreateTab(win, {Name = t[1], Icon = t[2]})
end

-- ⚔️ FARM
NexusUI:CreateSection(tabs["⚔️ Farm"], "Super Farm")
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🚀 Auto Farm", Callback = function(v) Flags.AutoFarm = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "💀 Kill Aura", Callback = function(v) Flags.KillAura = v end})
NexusUI:CreateToggle(tabs["⚔️ Farm"], {Title = "🛡️ Godmode", Callback = function(v) Flags.GodMode = v end})
NexusUI:CreateSlider(tabs["⚔️ Farm"], {Title = "🎯 Alcance", Min = 100, Max = 500, Default = 300, Callback = function(v) Flags.Range = v end})

-- 🍎 FRUTAS
NexusUI:CreateSection(tabs["🍎 Frutas"], "Sniper & Autos")
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🍎 Fruit Sniper", Callback = function(v) Flags.FruitSniper = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "📦 Auto Store Fruit", Callback = function(v) Flags.AutoStore = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🎲 Auto Roll Fruit", Callback = function(v) Flags.AutoRoll = v end})
NexusUI:CreateToggle(tabs["🍎 Frutas"], {Title = "🪄 Auto Spawn Fruit", Callback = function(v) Flags.AutoSpawn = v end})

-- 💎 FARMS
NexusUI:CreateSection(tabs["💎 Farms"], "Farms Extras")
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "💎 Fragment Farm", Callback = function(v) Flags.FragmentFarm = v end})
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "🦴 Bones Farm", Callback = function(v) Flags.BonesFarm = v end})
NexusUI:CreateToggle(tabs["💎 Farms"], {Title = "💰 Bounty Hunt", Callback = function(v) Flags.BountyHunt = v end})

-- 🏃 MOVE
NexusUI:CreateSection(tabs["🏃 Move"], "Movimentação")
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "✈️ Fly", Callback = function(v) Flags.Fly = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🏃 Walkspeed", Callback = function(v) Flags.Walkspeed = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🦘 Jumpspeed", Callback = function(v) Flags.Jumpspeed = v end})
NexusUI:CreateToggle(tabs["🏃 Move"], {Title = "🚫 No Clip", Callback = function(v) Flags.NoClip = v end})

-- ⚙️ AUTO
NexusUI:CreateSection(tabs["⚙️ Auto"], "Automações")
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🌀 Auto Haki", Callback = function(v) Flags.AutoHaki = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "👑 Auto V4", Callback = function(v) Flags.AutoV4 = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "🧬 Auto Race", Callback = function(v) Flags.AutoRace = v end})
NexusUI:CreateToggle(tabs["⚙️ Auto"], {Title = "📊 Auto Stats", Callback = function(v) Flags.AutoStats = v end})

-- 🛍️ LOJA
NexusUI:CreateSection(tabs["🛍️ Loja"], "Compras Automáticas")
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🍎 Buy Fruits", Callback = function(v) Flags.ShopFruits = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "👊 Buy Styles", Callback = function(v) Flags.ShopStyles = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "⚔️ Buy Swords", Callback = function(v) Flags.ShopSword = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "🔫 Buy Guns", Callback = function(v) Flags.ShopGuns = v end})
NexusUI:CreateToggle(tabs["🛍️ Loja"], {Title = "💍 Buy Accessories", Callback = function(v) Flags.ShopAcc = v end})

-- 👀 ESP
NexusUI:CreateSection(tabs["👀 ESP"], "ESP")
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "👤 ESP Players", Callback = function(v) Flags.ESP_Players = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🍎 ESP Fruits", Callback = function(v) Flags.ESP_Fruits = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "📦 ESP Chests", Callback = function(v) Flags.ESP_Chests = v end})
NexusUI:CreateToggle(tabs["👀 ESP"], {Title = "🎯 ESP Bosses", Callback = function(v) Flags.ESP_Bosses = v end})

-- 🎮 EXTRA
NexusUI:CreateSection(tabs["🎮 Extra"], "Funções Especiais")
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "🎯 Aimlock", Callback = function(v) Flags.Aimlock = v end})
NexusUI:CreateToggle(tabs["🎮 Extra"], {Title = "⚡ Otimizador Mobile", Callback = function(v) 
    Flags.Optimizer = v
    if v then ApplyOptimizations() Notify("⚡", "Otimizador ativado!", 2) end
end})

-- FPS COUNTER
local fpsLabel = Instance.new("TextLabel", win.Frame)
fpsLabel.Size = UDim2.new(0, 220, 0, 15)
fpsLabel.Position = UDim2.new(0, 10, 1, -18)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fpsLabel.TextSize = 10
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.Text = "FPS: -- | 💀 0"

local fc, lt = 0, tick()
Services.RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local nw = tick()
    if nw - lt >= 1 then
        fpsLabel.Text = "FPS: " .. fc .. " | 💀 " .. Flags.Kills
        fc = 0
        lt = nw
    end
end)

-- NOTIFICAÇÃO FINAL
Notify("NEXUS v13.0", "✅ COMPLETO!\n📱 Otimizado p/ Celular Fraco\n🔴 Tudo Desativado\n🚀 Ative Auto Farm\n⚡ Bypass Anti-Cheat Ativo", 8)
print("✅ NEXUS v13.0 - COMPLETO + OTIMIZADO!")
print("📱 Modo Celular Fraco - ATIVO!")
print("🔴 TUDO DESATIVADO - Ative no menu!")
print("🛡️ Anti-Cheat Bypass - ATIVO!")
