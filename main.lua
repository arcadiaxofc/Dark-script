-- ==================== SERVIÇOS ====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local http = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")

-- ==================== CONFIGURAÇÕES ====================
local verified = false
local isOwner = false
local OWNER_PASSWORD = "NEXUS-2026-ADMIN"
local OWNER_KEY = "NEXUS-OWNER-SUPREME"

local farmEnabled = false
local espEnabled = false
local godmodeEnabled = false
local fruitSniperEnabled = false
local mirageFinderEnabled = false
local raceV4Enabled = false
local bountyHunterEnabled = false
local raidEnabled = false
local chestFarmEnabled = false
local autoHakiEnabled = false
local autoDashEnabled = false
local autoBuyEnabled = false
local autoSkillMasteryEnabled = false
local autoHopEnabled = false
local autoBonesEnabled = false
local autoSpawnFruitEnabled = false
local autoStoreEnabled = false

local farmMode = "Level"
local currentTarget = nil
local scriptLoaded = false
local scriptRunning = false

local farmConfig = {
    Range = 300,
    AttackDelay = 0.2,
    AutoQuest = true,
    AutoStats = true,
    AutoCollect = true,
    SafeMode = true
}

local movementConfig = {
    UseSmartTeleport = true,
    SpeedMode = "Variable",
    MinSpeed = 80,
    MaxSpeed = 250,
    AltitudeVariance = true,
    RandomPauses = true,
    PauseChance = 0.2,
    ZigZagChance = 0.4,
    SwoopChance = 0.3
}

local optimizationConfig = {
    FreezeGameOnStart = true,
    FreezeDuration = 2,
    RemoveEffects = true,
    RemoveDecals = true,
    RemoveShadows = true,
    RemoveReflections = true,
    RemoveGrass = true,
    RemoveClouds = true,
    GraphicsLevel = 1,
    RenderDistance = 200,
    LowQualityTerrain = true,
    DisablePostProcessing = true,
    AutoCleanMemory = true,
    CleanInterval = 30,
    ReducePhysics = true,
    DisableWind = true,
    DisableWaterWaves = true,
}

-- ==================== UTILITÁRIOS ====================
local function humanizedWait(base, variance)
    return base + (math.random() * variance * 2) - variance
end

local function safeInvoke(remote, ...)
    local success, result = pcall(function()
        return remote:InvokeServer(...)
    end)
    if not success then
        warn("[DEBUG] Remote error:", result)
    end
    return result
end

-- ==================== BYPASS ====================
local function antiAFK()
    task.spawn(function()
        while true do
            task.wait(math.random(180, 300) / 100)
            pcall(function()
                local vu = VirtualUser
                local camera = workspace.CurrentCamera
                local rx = math.random(-2, 2)
                local ry = math.random(-2, 2)
                vu:Button2Down(Vector2.new(rx, ry), camera.CFrame)
                task.wait(0.05)
                vu:Button2Up(Vector2.new(rx, ry), camera.CFrame)
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    local hum = player.Character.Humanoid
                    if hum.MoveDirection.Magnitude < 1 then
                        local mv = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                        hum:Move(mv, true)
                        task.wait(0.1)
                        hum:Move(Vector3.zero, true)
                    end
                end
            end)
        end
    end)
end

local function antiBan()
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" then
                local blocked = {"Teleport", "LoadChunk", "DetectSpeed", "FlagPlayer"}
                for _, b in pairs(blocked) do
                    if tostring(args[1]):find(b) then return nil end
                end
            end
            if method == "Kick" then return nil end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

-- ==================== OTIMIZAÇÃO ====================
local function freezeGame(duration)
    print("❄️ Freezing game for " .. duration .. "s...")
    pcall(function()
        Workspace.PhysicsSteppingMethod = Enum.PhysicsSteppingMethod.Fixed
        Workspace:SetPhysicsThrottleEnabled(true)
    end)
    for _, s in pairs(Workspace:GetDescendants()) do
        if s:IsA("Sound") then pcall(function() s.Playing = false end) end
    end
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0
        Lighting.FogEnd = 1
    end)
    task.wait(duration)
    print("✅ Game unfrozen")
end

local function removeGameEffects()
    local count = 0
    if optimizationConfig.RemoveEffects then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false; count = count + 1 end)
            end
            if obj:IsA("Beam") or obj:IsA("Trail") then
                pcall(function() obj.Enabled = false; count = count + 1 end)
            end
        end
    end
    if optimizationConfig.RemoveDecals then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") then pcall(function() obj:Destroy(); count = count + 1 end) end
        end
    end
    if optimizationConfig.RemoveShadows then
        pcall(function() Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0 end)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then pcall(function() obj.CastShadow = false end) end
        end
    end
    if optimizationConfig.RemoveReflections then
        pcall(function()
            Lighting.Reflection = 0
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
        end)
    end
    if optimizationConfig.RemoveGrass then
        pcall(function() if Workspace.Terrain then Workspace.Terrain.GrassLength = 0 end end)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("GrassPart") or obj.Name:find("Grass") then
                pcall(function() obj:Destroy(); count = count + 1 end)
            end
        end
    end
    if optimizationConfig.RemoveClouds then
        pcall(function() if Workspace.Terrain then Workspace.Terrain.CloudsEnabled = false end end)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("Cloud") and obj:IsA("BasePart") then
                pcall(function() obj.Transparency = 1 end)
            end
        end
    end
    print("🧹 Cleaned: " .. count .. " objects")
end

local function optimizeGraphics()
    pcall(function()
        settings().Rendering.QualityLevel = optimizationConfig.GraphicsLevel
    end)
    pcall(function()
        Workspace.StreamingMinRadius = optimizationConfig.RenderDistance
        Workspace.StreamingTargetRadius = optimizationConfig.RenderDistance
    end)
    if optimizationConfig.LowQualityTerrain and Workspace.Terrain then
        pcall(function()
            Workspace.Terrain.WaterWaveSize = 0
            Workspace.Terrain.WaterWaveSpeed = 0
            Workspace.Terrain.WaterReflectance = 0
            Workspace.Terrain.WaterTransparency = 0.5
        end)
    end
    if optimizationConfig.DisablePostProcessing then
        pcall(function()
            Lighting.BloomEffect = false
            Lighting.BlurEffect = false
            Lighting.SunRaysEffect = false
            Lighting.ColorCorrectionEffect = false
        end)
    end
    pcall(function()
        Lighting.Brightness = 2
        Lighting.FogEnd = optimizationConfig.RenderDistance
        Lighting.FogStart = optimizationConfig.RenderDistance * 0.7
    end)
    print("🎨 Graphics optimized")
end

local function cleanMemory()
    local startMem = Stats:GetTotalMemoryUsageMb()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Transparency > 0.9 then
            pcall(function() obj:Destroy() end)
        end
    end
    if optimizationConfig.ReducePhysics then
        local pp = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.zero
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Position - pp).Magnitude > optimizationConfig.RenderDistance then
                pcall(function() obj.Anchored = true; obj.CanCollide = false end)
            end
        end
    end
    local endMem = Stats:GetTotalMemoryUsageMb()
    print("💾 Memory: " .. math.floor(endMem) .. "MB")
end

local function optimizePerformance()
    if optimizationConfig.DisableWind then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") and obj.Name:find("Wind") then
                pcall(function() obj.Enabled = false end)
            end
        end
    end
    if optimizationConfig.DisableWaterWaves and Workspace.Terrain then
        pcall(function()
            Workspace.Terrain.WaterWaveSize = 0
            Workspace.Terrain.WaterWaveSpeed = 0
        end)
    end
    local sc = 0
    for _, s in pairs(Workspace:GetDescendants()) do
        if s:IsA("Sound") then
            sc = sc + 1
            if sc > 30 then pcall(function() s.Volume = 0; s.Playing = false end) end
        end
    end
    if optimizationConfig.ReducePhysics then
        pcall(function() Workspace.PhysicsSteppingMethod = Enum.PhysicsSteppingMethod.Adaptive end)
    end
    print("⚡ Performance optimized")
end

local function preventMobileCrash()
    task.spawn(function()
        while true do
            local mem = Stats:GetTotalMemoryUsageMb()
            if mem > 500 then
                print("⚠️ High memory: " .. math.floor(mem) .. "MB - Cleaning")
                cleanMemory()
                local wasFarm = farmEnabled
                farmEnabled = false
                task.wait(2)
                farmEnabled = wasFarm
            end
            task.wait(10)
        end
    end)
    pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
end

local function safeLoadScript()
    if scriptLoaded then print("⚠️ Script already loaded!"); return end
    scriptLoaded = true
    
    StarterGui:SetCore("SendNotification", {
        Title = "NEXUS OPTIMIZER",
        Text = "Starting game optimization...",
        Duration = 5
    })
    
    print("=" .. string.rep("=", 50))
    print("🔧 NEXUS OPTIMIZATION SYSTEM v5.0")
    print("=" .. string.rep("=", 50))
    
    print("\n📌 Phase 1: Freezing")
    freezeGame(optimizationConfig.FreezeDuration)
    
    print("\n📌 Phase 2: Cleaning effects")
    removeGameEffects()
    
    print("\n📌 Phase 3: Graphics optimization")
    optimizeGraphics()
    
    print("\n📌 Phase 4: Performance")
    optimizePerformance()
    
    print("\n📌 Phase 5: Memory cleanup")
    cleanMemory()
    
    print("\n📌 Phase 6: Restoring lighting")
    pcall(function()
        Lighting.Brightness = 3
        Lighting.FogEnd = optimizationConfig.RenderDistance
        Lighting.ClockTime = 14
    end)
    
    if optimizationConfig.AutoCleanMemory then
        task.spawn(function()
            while true do
                task.wait(optimizationConfig.CleanInterval)
                if scriptRunning then cleanMemory() end
            end
        end)
    end
    
    scriptRunning = true
    
    print("\n" .. string.rep("=", 50))
    print("✅ OPTIMIZATION COMPLETE!")
    print("📱 Mobile optimized for max performance")
    print(string.rep("=", 50) .. "\n")
    
    StarterGui:SetCore("SendNotification", {
        Title = "NEXUS OPTIMIZER",
        Text = "✅ Optimization complete! Game running smooth.",
        Duration = 3
    })
end

-- ==================== VERIFICATION ====================
local function getHWID()
    return http:GenerateGUID(false) .. player.UserId .. player.AccountAge .. game.GameId .. tostring(workspace:GetServerTimeNow())
end

local function verifyKey(key)
    local demoKeys = {
        ["NEXUS-VIP-2026"] = true,
        ["FREE-TRIAL"] = true,
        ["BLOX-ADMIN"] = true,
        ["KITSUNE-777"] = true,
        ["OWNER-TEST"] = true
    }
    return demoKeys[key] == true
end

-- ==================== MOVEMENT SYSTEM ====================
local islandSpawnPoints = {
    ["Marine Starter"] = {safePoint = Vector3.new(1280, 15, 4180), radius = 30},
    ["Jungle"] = {safePoint = Vector3.new(-1240, 20, 3840), radius = 40},
    ["Pirate Village"] = {safePoint = Vector3.new(-380, 20, 720), radius = 25},
    ["Desert"] = {safePoint = Vector3.new(960, 15, 1090), radius = 35},
    ["Frozen Village"] = {safePoint = Vector3.new(1140, 30, 4340), radius = 30},
    ["Sky Islands"] = {safePoint = Vector3.new(-4840, 755, 1940), radius = 20},
    ["Graveyard"] = {safePoint = Vector3.new(-3550, 245, -70), radius = 35},
    ["Snow Mountain"] = {safePoint = Vector3.new(-5390, 20, -1690), radius = 30},
    ["Hot and Cold"] = {safePoint = Vector3.new(-3410, 15, -2690), radius = 25},
    ["Cafe"] = {safePoint = Vector3.new(-560, 315, -1210), radius = 20},
    ["Kingdom of Rose"] = {safePoint = Vector3.new(-1390, 15, -1390), radius = 30},
    ["Castle on the Sea"] = {safePoint = Vector3.new(4490, 55, 1190), radius = 35},
    ["Hydra Island"] = {safePoint = Vector3.new(6190, 85, 2490), radius = 30},
    ["Great Tree"] = {safePoint = Vector3.new(8490, 125, 4490), radius = 25},
    ["Port Town"] = {safePoint = Vector3.new(7190, 105, 3490), radius = 30},
    ["Tiki Outpost"] = {safePoint = Vector3.new(5490, -45, 1990), radius = 25}
}

local function findNearestSafePoint(targetPos)
    local nearest, shortestDist = nil, math.huge
    for _, data in pairs(islandSpawnPoints) do
        local dist = (data.safePoint - targetPos).Magnitude
        if dist < shortestDist then shortestDist = dist; nearest = data end
    end
    return nearest
end

local function getRandomSafePosition(safeData)
    local offset = Vector3.new(math.random(-safeData.radius, safeData.radius), 0, math.random(-safeData.radius, safeData.radius))
    return safeData.safePoint + offset
end

local function walkTo(targetPos)
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then return false end
    local humanoid = char.Humanoid
    local hrp = char.HumanoidRootPart
    local path = PathfindingService:CreatePath()
    local success = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
    if success and path.Status == Enum.PathStatus.Success then
        for _, wp in pairs(path:GetWaypoints()) do
            if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            humanoid:MoveTo(wp.Position)
            humanoid.MoveToFinished:Wait()
        end
        return true
    end
    return false
end

local function humanizedFlyToTarget(startPos, endPos)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local distance = (endPos - startPos).Magnitude
    if distance < 50 then walkTo(endPos); return end
    
    local segments = math.max(math.floor(distance / 80), 3)
    local useZigZag = math.random() < movementConfig.ZigZagChance
    local useSwoop = math.random() < movementConfig.SwoopChance
    local rightVector = (endPos - startPos).Cross(Vector3.new(0, 1, 0)).Unit
    
    for i = 1, segments do
        local alpha = i / segments
        local currentTarget = startPos:Lerp(endPos, alpha)
        
        if useZigZag and i > 2 and i < segments - 1 then
            local zigOffset = math.sin(alpha * math.pi * 3) * math.random(30, 70)
            currentTarget = currentTarget + rightVector * zigOffset
        end
        
        local heightOffset = 0
        if useSwoop then
            if alpha < 0.3 then heightOffset = alpha * 200
            elseif alpha > 0.7 then heightOffset = (1 - alpha) * 200
            else heightOffset = 60 + math.random(-20, 20) end
        else
            heightOffset = 40 + math.sin(alpha * math.pi) * math.random(30, 80)
        end
        currentTarget = currentTarget + Vector3.new(0, heightOffset, 0)
        
        local speed = movementConfig.MinSpeed + math.random() * (movementConfig.MaxSpeed - movementConfig.MinSpeed)
        local segmentDist = (currentTarget - hrp.Position).Magnitude
        local duration = math.clamp(segmentDist / speed, 0.1, 1.5)
        
        local tween = TweenService:Create(hrp, 
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {CFrame = CFrame.new(currentTarget)})
        tween:Play()
        tween.Completed:Wait()
        
        if movementConfig.RandomPauses and math.random() < movementConfig.PauseChance then
            task.wait(math.random(200, 800) / 1000)
        end
    end
    
    local finalTween = TweenService:Create(hrp,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(endPos)})
    finalTween:Play()
end

local function smartTeleport(targetPos)
    if not movementConfig.UseSmartTeleport then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        return
    end
    local safeData = findNearestSafePoint(targetPos)
    if not safeData then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        return
    end
    local spawnPos = getRandomSafePosition(safeData)
    local currentDist = (player.Character.HumanoidRootPart.Position - targetPos).Magnitude
    local safeDist = (spawnPos - targetPos).Magnitude
    if currentDist < safeDist and currentDist < 500 then
        humanizedFlyToTarget(player.Character.HumanoidRootPart.Position, targetPos)
    else
        player.Character.HumanoidRootPart.CFrame = CFrame.new(spawnPos)
        task.wait(math.random(200, 500) / 1000)
        humanizedFlyToTarget(spawnPos, targetPos)
    end
end

-- ==================== GAME DATA ====================
local fruits = {
    "Kitsune-Fruit", "Dragon-Fruit", "Leopard-Fruit", "Dough-Fruit",
    "Spirit-Fruit", "Venom-Fruit", "Control-Fruit", "Shadow-Fruit",
    "Rumble-Fruit", "Buddha-Fruit", "Portal-Fruit", "Blizzard-Fruit",
    "Sound-Fruit", "Pain-Fruit", "Love-Fruit", "Spider-Fruit",
    "Phoenix-Fruit", "Magma-Fruit", "Light-Fruit", "Ice-Fruit",
    "Flame-Fruit", "Dark-Fruit", "Sand-Fruit", "Falcon-Fruit"
}

local bosses = {
    {name = "Dough King", pos = Vector3.new(6200, 80, 2500)},
    {name = "Kitsune", pos = Vector3.new(7200, 100, 3500)},
    {name = "Rip Indra", pos = Vector3.new(8500, 120, 4500)},
    {name = "Cake Queen", pos = Vector3.new(5500, -50, 2000)},
    {name = "Tide Keeper", pos = Vector3.new(6800, 30, 3000)},
    {name = "Don Swan", pos = Vector3.new(-1400, 10, -1400)}
}

-- ==================== TARGET FINDING ====================
local function findNPCByLevel()
    local nearest, shortest = nil, farmConfig.Range
    local enemies = CollectionService:GetTagged("Enemy")
    local searchList = #enemies > 0 and enemies or Workspace:GetDescendants()
    for _, npc in pairs(searchList) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
            local dist = (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then shortest = dist; nearest = npc end
        end
    end
    return nearest
end

local function findBoss()
    local nearest, shortest = nil, farmConfig.Range
    for _, boss in pairs(bosses) do
        local bossModel = Workspace:FindFirstChild(boss.name)
        if bossModel and bossModel:FindFirstChild("Humanoid") and bossModel:FindFirstChild("HumanoidRootPart") and bossModel.Humanoid.Health > 0 then
            local dist = (bossModel.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then shortest = dist; nearest = bossModel end
        end
    end
    return nearest
end

local function findFruit()
    local nearest, shortest = nil, 500
    for _, fruitName in pairs(fruits) do
        local fruit = Workspace:FindFirstChild(fruitName)
        if fruit and fruit:FindFirstChild("Handle") then
            local dist = (fruit.Handle.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then shortest = dist; nearest = fruit end
        end
    end
    return nearest
end

local function findSeaBeast()
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name:find("Sea") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            return npc
        end
    end
    return nil
end

-- ==================== COMBAT ====================
local function attack()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(humanizedWait(0.05, 0.02))
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    task.wait(humanizedWait(farmConfig.AttackDelay, 0.1))
end

local function useSkill(skillKey)
    VirtualInputManager:SendKeyEvent(true, skillKey, false, game)
    task.wait(humanizedWait(0.1, 0.05))
    VirtualInputManager:SendKeyEvent(false, skillKey, false, game)
end

-- ==================== AUTO FARM ====================
local function autoQuest()
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and (npc:FindFirstChild("Quest") or npc:FindFirstChild("Talk")) then
            smartTeleport(npc.HumanoidRootPart.Position)
            task.wait(humanizedWait(0.5, 0.2))
            local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
            if remote then safeInvoke(remote, "StartQuest", npc.Name) end
            break
        end
    end
end

local function autoStats()
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
    if remote then safeInvoke(remote, "AddPoint", "Melee", 1) end
end

local function collectItems()
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("Tool") or item.Name:find("Chest") or item.Name:find("Drop") or item.Name:find("Bone") then
            local itemPos = nil
            if item:IsA("BasePart") then itemPos = item.Position
            elseif item:FindFirstChild("Handle") then itemPos = item.Handle.Position end
            if itemPos and (itemPos - player.Character.HumanoidRootPart.Position).Magnitude < 50 then
                smartTeleport(itemPos)
                task.wait(humanizedWait(0.2, 0.1))
            end
        end
    end
end

local function startFarm()
    while farmEnabled do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(1)
        else
            local target = nil
            if farmMode == "Level" or farmMode == "Mastery" or farmMode == "Raid" then
                target = findNPCByLevel()
            elseif farmMode == "Boss" then
                target = findBoss()
            elseif farmMode == "SeaBeast" then
                target = findSeaBeast()
            end
            if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                currentTarget = target
                local dist = (player.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
                if dist > 10 then smartTeleport(target.HumanoidRootPart.Position) end
                attack()
                useSkill("Q")
                useSkill("E")
            end
            if farmConfig.AutoQuest then autoQuest() end
            if farmConfig.AutoStats then autoStats() end
            if farmConfig.AutoCollect then collectItems() end
        end
        task.wait(humanizedWait(0.1, 0.05))
    end
end

-- ==================== ESP ====================
local espObjects = {}
local espConfig = {
    PlayerColor = Color3.fromRGB(255, 50, 50),
    FruitColor = Color3.fromRGB(255, 100, 255),
    BossColor = Color3.fromRGB(255, 50, 255)
}

local function worldToScreen(pos)
    local vec, on = workspace.CurrentCamera:WorldToViewportPoint(pos)
    return Vector2.new(vec.X, vec.Y), on
end

local function createESP(target, espType, color)
    if espObjects[target] then return end
    espObjects[target] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Type = espType,
        Color = color
    }
    local e = espObjects[target]
    e.Box.Thickness = 2; e.Box.Filled = false; e.Box.Transparency = 0.8
    e.Name.Center = true; e.Name.Outline = true
    e.Distance.Center = true; e.Distance.Outline = true
end

local function cleanESP()
    for target, e in pairs(espObjects) do
        if not target or not target.Parent then
            pcall(function() e.Box:Remove(); e.Name:Remove(); e.Distance:Remove() end)
            espObjects[target] = nil
        end
    end
end

local function updateESP()
    cleanESP()
    for target, e in pairs(espObjects) do
        if not target then
            e.Box.Visible = false; e.Name.Visible = false; e.Distance.Visible = false
        else
            local pos, onScreen, name, dist = nil, false, "", 0
            if e.Type == "Player" and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                pos, onScreen = worldToScreen(target.Character.HumanoidRootPart.Position)
                name = target.Name
                dist = (target.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            elseif e.Type == "Fruit" and target:FindFirstChild("Handle") then
                pos, onScreen = worldToScreen(target.Handle.Position)
                name = target.Name
                dist = (target.Handle.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            elseif e.Type == "Boss" and target:FindFirstChild("HumanoidRootPart") then
                pos, onScreen = worldToScreen(target.HumanoidRootPart.Position)
                name = target.Name
                dist = (target.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            end
            if not pos or not onScreen or dist > farmConfig.Range + 100 then
                e.Box.Visible = false; e.Name.Visible = false; e.Distance.Visible = false
            else
                local size = Vector2.new(150 / dist * 1.5, 200 / dist * 1.5)
                e.Box.Size = size; e.Box.Position = pos - size/2; e.Box.Color = e.Color; e.Box.Visible = true
                e.Name.Text = name; e.Name.Color = e.Color; e.Name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
                e.Name.Size = math.clamp(20 / (dist/50), 10, 25); e.Name.Visible = true
                e.Distance.Text = math.floor(dist) .. "m"; e.Distance.Color = Color3.new(1, 1, 1)
                e.Distance.Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 10)
                e.Distance.Size = math.clamp(14 / (dist/50), 8, 20); e.Distance.Visible = true
            end
        end
    end
end

-- ==================== GODMODE ====================
local function godmode()
    while godmodeEnabled do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = humanoid.MaxHealth; humanoid.BreakJointsOnDeath = false end
        end
        task.wait(humanizedWait(0.1, 0.05))
    end
end

-- ==================== FRUIT SNIPER ====================
local function fruitSniper()
    while fruitSniperEnabled do
        local fruit = findFruit()
        if fruit then smartTeleport(fruit.Handle.Position); task.wait(humanizedWait(0.3, 0.1)) end
        task.wait(humanizedWait(2, 0.5))
    end
end

-- ==================== MIRAGE FINDER ====================
local function findMirage()
    while mirageFinderEnabled do
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Position.Y > 100 then
                smartTeleport(part.Position); task.wait(humanizedWait(0.5, 0.2)); break
            end
        end
        task.wait(humanizedWait(10, 2))
    end
end

-- ==================== RACE V4 ====================
local function autoRaceV4()
    while raceV4Enabled do
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
        if remote then safeInvoke(remote, "RaceV4", "Start") end
        task.wait(humanizedWait(60, 5))
    end
end

-- ==================== BOUNTY HUNTER ====================
local function bountyHunter()
    while bountyHunterEnabled do
        local highestBounty, highestBountyValue = nil, 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local bounty = p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0
                if bounty > highestBountyValue then highestBountyValue = bounty; highestBounty = p end
            end
        end
        if highestBounty then
            smartTeleport(highestBounty.Character.HumanoidRootPart.Position)
            attack()
        end
        task.wait(humanizedWait(5, 1))
    end
end

-- ==================== EXTRA FUNCTIONS ====================
local function autoRaid()
    while raidEnabled do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("Raid") and obj:FindFirstChild("TouchInterest") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                smartTeleport(obj.Position); task.wait(0.5)
                firetouchinterest(obj, player.Character.HumanoidRootPart, 0); task.wait(0.5)
                firetouchinterest(obj, player.Character.HumanoidRootPart, 1)
            end
        end
        task.wait(30)
    end
end

local function autoFarmChest()
    while chestFarmEnabled do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("Chest") and (obj:IsA("Model") or obj:FindFirstChild("TouchInterest")) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChildOfClass("BasePart") and obj:FindFirstChildOfClass("BasePart").Position)
                if pos then
                    smartTeleport(pos); task.wait(0.3)
                    if obj:FindFirstChild("TouchInterest") then
                        firetouchinterest(obj, player.Character.HumanoidRootPart, 0)
                        firetouchinterest(obj, player.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end
        task.wait(5)
    end
end

local function autoHaki()
    while autoHakiEnabled do
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
        if remote then
            safeInvoke(remote, "ActivateHaki", "Ken")
            safeInvoke(remote, "ActivateHaki", "Buso")
        end
        task.wait(30)
    end
end

local function autoDash()
    while autoDashEnabled do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local randomDir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
            local dashPos = character.HumanoidRootPart.Position + randomDir * 15
            local tween = TweenService:Create(character.HumanoidRootPart,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad),
                {CFrame = CFrame.new(dashPos)})
            tween:Play()
        end
        task.wait(math.random(3, 8))
    end
end

local function autoBuy()
    while autoBuyEnabled do
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
        if remote then
            local items = {"Kitsune", "Dragon", "Leopard", "Dough", "Spirit", "Venom"}
            for _, item in pairs(items) do
                safeInvoke(remote, "BuyItem", item); task.wait(0.5)
            end
        end
        task.wait(300)
    end
end

local function autoSkillMastery()
    while autoSkillMasteryEnabled do
        local skills = {"Z", "X", "C", "V", "F"}
        for _, skill in pairs(skills) do
            useSkill(skill)
            task.wait(math.random(200, 500) / 1000)
        end
        task.wait(2)
    end
end

local function autoHopServer()
    while autoHopEnabled do
        local hasRare = false
        for _, fruitName in pairs(fruits) do
            local fruit = Workspace:FindFirstChild(fruitName)
            if fruit and fruit:FindFirstChild("Handle") then hasRare = true; break end
        end
        if not hasRare then
            pcall(function()
                local servers = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=10"))
                if #servers.data > 0 then
                    local randomServer = servers.data[math.random(1, #servers.data)]
                    TeleportService:TeleportToPlaceInstance(game.GameId, randomServer.id, player)
                end
            end)
        end
        task.wait(60)
    end
end

local function autoCollectBones()
    while autoBonesEnabled do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("Bone") and obj:IsA("BasePart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                smartTeleport(obj.Position); task.wait(0.2)
                firetouchinterest(obj, player.Character.HumanoidRootPart, 0)
                firetouchinterest(obj, player.Character.HumanoidRootPart, 1)
            end
        end
        task.wait(3)
    end
end

local function autoSpawnFruit()
    while autoSpawnFruitEnabled do
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
        if remote then safeInvoke(remote, "Cousin", "Buy") end
        task.wait(30)
    end
end

local function autoStoreFruits()
    while autoStoreEnabled do
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
        if remote and player.Data and player.Data:FindFirstChild("Fruit") then
            safeInvoke(remote, "StoreFruit", player.Data.Fruit.Value)
        end
        task.wait(2)
    end
end

-- ==================== OWNER ULTRA FARM ====================
local function ownerUltraFarm()
    print("👑 OWNER MODE ACTIVATED!")
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_
    if not remote then return end
    StarterGui:SetCore("SendNotification", {Title = "NEXUS | OWNER", Text = "Starting ultra farm...", Duration = 3})
    safeInvoke(remote, "SetLevel", 2600); task.wait()
    safeInvoke(remote, "AddMastery", "Melee", 600); safeInvoke(remote, "AddMastery", "Sword", 600)
    safeInvoke(remote, "AddMastery", "Fruit", 600); safeInvoke(remote, "AddMastery", "Gun", 600); task.wait()
    for i = 1, 50 do safeInvoke(remote, "AddMoney", 1000000); task.wait() end
    for i = 1, 20 do safeInvoke(remote, "AddFragments", 5000); task.wait() end
    safeInvoke(remote, "AddPoint", "Melee", 2600); safeInvoke(remote, "AddPoint", "Defense", 2600)
    safeInvoke(remote, "AddPoint", "Sword", 2600); safeInvoke(remote, "AddPoint", "Fruit", 2600)
    safeInvoke(remote, "AddPoint", "Gun", 2600); task.wait()
    local shopFruits = {"Kitsune", "Dragon", "Leopard", "Dough", "Spirit", "Venom", "Control", "Shadow", "Rumble", "Buddha"}
    for _, fruit in pairs(shopFruits) do safeInvoke(remote, "BuyItem", fruit); task.wait() end
    safeInvoke(remote, "EquipFruit", "Kitsune"); safeInvoke(remote, "EquipWeapon", "CursedDualKatana")
    safeInvoke(remote, "EquipGun", "SoulGuitar")
    local gamepasses = {"2xMoney", "2xMastery", "FastBoats", "FruitNotifier"}
    for _, gp in pairs(gamepasses) do safeInvoke(remote, "BuyGamepass", gp); task.wait() end
    StarterGui:SetCore("SendNotification", {Title = "NEXUS | OWNER", Text = "✅ Ultra farm complete!", Duration = 5})
end

-- ==================== TELEPORTS ====================
local teleportLocations = {
    {"Marine Starter", Vector3.new(1289, 11, 4191)},
    {"Jungle", Vector3.new(-1250, 15, 3850)},
    {"Pirate Village", Vector3.new(-383, 15, 727)},
    {"Desert", Vector3.new(966, 10, 1100)},
    {"Frozen Village", Vector3.new(1150, 25, 4350)},
    {"Sky Islands", Vector3.new(-4850, 750, 1950)},
    {"Graveyard", Vector3.new(-3560, 240, -80)},
    {"Snow Mountain", Vector3.new(-5400, 15, -1700)},
    {"Hot and Cold", Vector3.new(-3420, 10, -2700)},
    {"Cafe", Vector3.new(-570, 310, -1220)},
    {"Mansion", Vector3.new(-390, 45, -800)},
    {"Kingdom of Rose", Vector3.new(-1400, 10, -1400)},
    {"Castle on the Sea", Vector3.new(4500, 50, 1200)},
    {"Hydra Island", Vector3.new(6200, 80, 2500)},
    {"Great Tree", Vector3.new(8500, 120, 4500)},
    {"Port Town", Vector3.new(7200, 100, 3500)},
    {"Tiki Outpost", Vector3.new(5500, -50, 2000)}
}

-- ==================== VERIFICATION GUI ====================
local function createVerifyGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusVerify"; gui.Parent = player:WaitForChild("PlayerGui"); gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 400); frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20); frame.BackgroundTransparency = 0.05; frame.BorderSizePixel = 0; frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60); title.Text = "NEXUS v5.0 | PLATODOOST"
    title.TextColor3 = Color3.fromRGB(255, 255, 255); title.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    title.Font = Enum.Font.GothamBold; title.TextScaled = true; title.Parent = frame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25); subtitle.Position = UDim2.new(0, 0, 0, 60)
    subtitle.Text = "ENTER YOUR LICENSE KEY"; subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    subtitle.BackgroundTransparency = 1; subtitle.Font = Enum.Font.Gotham; subtitle.TextSize = 14; subtitle.Parent = frame
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.85, 0, 0, 50); keyBox.Position = UDim2.new(0.075, 0, 0, 100)
    keyBox.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"; keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40); keyBox.BorderSizePixel = 0
    keyBox.Font = Enum.Font.Gotham; keyBox.TextSize = 14; keyBox.Parent = frame
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(0.85, 0, 0, 55); verifyBtn.Position = UDim2.new(0.075, 0, 0, 165)
    verifyBtn.Text = "VERIFY LICENSE"; verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215); verifyBtn.BorderSizePixel = 0
    verifyBtn.Font = Enum.Font.GothamBold; verifyBtn.TextSize = 18; verifyBtn.Parent = frame
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.85, 0, 0, 40); status.Position = UDim2.new(0.075, 0, 0, 235)
    status.Text = "Waiting for license..."; status.TextColor3 = Color3.fromRGB(255, 200, 0)
    status.BackgroundTransparency = 1; status.Font = Enum.Font.Gotham; status.TextSize = 12; status.Parent = frame
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.4, 0, 0, 35); getKeyBtn.Position = UDim2.new(0.075, 0, 0, 285)
    getKeyBtn.Text = "GET KEY"; getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70); getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 14; getKeyBtn.Parent = frame
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)
    
    local ownerPasswordBox = Instance.new("TextBox")
    ownerPasswordBox.Size = UDim2.new(0.85, 0, 0, 40); ownerPasswordBox.Position = UDim2.new(0.075, 0, 0, 330)
    ownerPasswordBox.PlaceholderText = "🔒 OWNER PASSWORD (optional)"
    ownerPasswordBox.TextColor3 = Color3.fromRGB(255, 255, 255); ownerPasswordBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    ownerPasswordBox.BorderSizePixel = 0; ownerPasswordBox.Font = Enum.Font.Gotham; ownerPasswordBox.TextSize = 12; ownerPasswordBox.Parent = frame
    Instance.new("UICorner", ownerPasswordBox).CornerRadius = UDim.new(0, 8)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        setclipboard("NEXUS-VIP-2026")
        status.Text = "✅ KEY COPIED: NEXUS-VIP-2026"; status.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(2); status.Text = "Waiting for license..."; status.TextColor3 = Color3.fromRGB(255, 200, 0)
    end)
    
    verifyBtn.MouseButton1Click:Connect(function()
        local key = keyBox.Text
        if key == "" then
            status.Text = "❌ Enter a license key!"; status.TextColor3 = Color3.fromRGB(255, 50, 50); return
        end
        if ownerPasswordBox.Text == OWNER_PASSWORD or ownerPasswordBox.Text == OWNER_KEY then
            isOwner = true; status.Text = "👑 OWNER MODE ACTIVATED!"; status.TextColor3 = Color3.fromRGB(255, 215, 0); task.wait(1)
        end
        status.Text = "🔄 Verifying..."; status.TextColor3 = Color3.fromRGB(100, 200, 255); verifyBtn.Enabled = false
        task.wait(1)
        if verifyKey(key) then
            verified = true
            status.Text = isOwner and "👑 OWNER VERIFIED! Loading NEXUS..." or "✅ VERIFIED! Loading NEXUS..."
            status.TextColor3 = isOwner and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 255, 0)
            task.wait(1.5); gui:Destroy()
        else
            status.Text = "❌ INVALID KEY!"; status.TextColor3 = Color3.fromRGB(255, 50, 50); verifyBtn.Enabled = true
            task.wait(2); status.Text = "Waiting for license..."; status.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
    end)
    
    repeat task.wait() until verified == true
end

-- ==================== MAIN MENU ====================
local function createMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusMenu"; gui.Parent = player:WaitForChild("PlayerGui"); gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 650); frame.Position = UDim2.new(0, 10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25); frame.BackgroundTransparency = 0.05; frame.BorderSizePixel = 0; frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Text = isOwner and "NEXUS v5.0 | 👑 OWNER MODE" or "NEXUS v5.0 | BLOX FRUITS"
    title.BackgroundColor3 = isOwner and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(25, 25, 40)
    title.TextColor3 = isOwner and Color3.fromRGB(0, 0, 0) or Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold; title.TextScaled = true; title.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -45); scroll.Position = UDim2.new(0, 0, 0, 45)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1400); scroll.Parent = frame
    
    local y = 10
    local function createButton(text, yPos, height)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, height); btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.Text = text; btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end
    
    local farmBtn = createButton("⚔️ AUTO FARM: OFF", y, 45); y = y + 55
    local modeBtn = createButton("📌 MODE: " .. farmMode, y, 40); y = y + 50
    local movementBtn = createButton("🏃 MOVE: Smart Teleport", y, 40); y = y + 50
    local espBtn = createButton("👁️ ESP: OFF", y, 45); y = y + 55
    local godBtn = createButton("🛡️ GODMODE: OFF", y, 45); y = y + 55
    local sniperBtn = createButton("🍎 FRUIT SNIPER: OFF", y, 45); y = y + 55
    local mirageBtn = createButton("🏝️ MIRAGE FINDER: OFF", y, 45); y = y + 55
    local raceBtn = createButton("👑 RACE V4: OFF", y, 45); y = y + 55
    local bountyBtn = createButton("💰 BOUNTY HUNTER: OFF", y, 45); y = y + 55
    local raidBtn = createButton("⚔️ AUTO RAID: OFF", y, 40); y = y + 48
    local chestBtn = createButton("📦 AUTO CHEST FARM: OFF", y, 40); y = y + 48
    local hakiBtn = createButton("🔮 AUTO HAKI: OFF", y, 40); y = y + 48
    local dashBtn = createButton("💨 AUTO DASH: OFF", y, 40); y = y + 48
    local buyBtn = createButton("🛒 AUTO BUY ITEMS: OFF", y, 40); y = y + 48
    local skillBtn = createButton("⭐ AUTO SKILL MASTERY: OFF", y, 40); y = y + 48
    local hopBtn = createButton("🔄 AUTO HOP SERVER: OFF", y, 40); y = y + 48
    local bonesBtn = createButton("🦴 AUTO COLLECT BONES: OFF", y, 40); y = y + 48
    local spawnFruitBtn = createButton("🍎 AUTO SPAWN FRUITS: OFF", y, 40); y = y + 48
    local storeBtn = createButton("📥 AUTO STORE FRUITS: OFF", y, 40); y = y + 48
    
    if isOwner then
        local ownerBtn = createButton("👑 OWNER ULTRA FARM 👑", y, 50)
        ownerBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0); ownerBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        ownerBtn.MouseButton1Click:Connect(ownerUltraFarm)
        y = y + 60
    end
    
    local teleLabel = Instance.new("TextLabel")
    teleLabel.Size = UDim2.new(0.9, 0, 0, 25); teleLabel.Position = UDim2.new(0.05, 0, 0, y)
    teleLabel.Text = "📍 TELEPORTS"; teleLabel.BackgroundTransparency = 1
    teleLabel.TextColor3 = Color3.fromRGB(150, 150, 200); teleLabel.Font = Enum.Font.GothamBold
    teleLabel.TextSize = 12; teleLabel.Parent = scroll
    y = y + 35
    
    for i, loc in pairs(teleportLocations) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.43, 0, 0, 35)
        btn.Position = UDim2.new((i % 2 == 1 and 0.05) or 0.52, 0, 0, y)
        btn.Text = loc[1]; btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.Gotham; btn.TextSize = 11; btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() smartTeleport(loc[2]) end)
        if i % 2 == 0 then y = y + 45 end
    end
    if #teleportLocations % 2 == 1 then y = y + 45 end
    y = y + 10
    
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(0.9, 0, 0, 80); statsFrame.Position = UDim2.new(0.05, 0, 0, y)
    statsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35); statsFrame.BorderSizePixel = 0; statsFrame.Parent = scroll
    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 6)
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0, 20); fpsLabel.Position = UDim2.new(0, 5, 0, 0); fpsLabel.Text = "FPS: --"
    fpsLabel.BackgroundTransparency = 1; fpsLabel.TextColor3 = Color3.new(1, 1, 1)
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left; fpsLabel.Font = Enum.Font.Gotham; fpsLabel.TextSize = 11; fpsLabel.Parent = statsFrame
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0, 20); targetLabel.Position = UDim2.new(0, 5, 0, 20); targetLabel.Text = "TARGET: NONE"
    targetLabel.BackgroundTransparency = 1; targetLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left; targetLabel.Font = Enum.Font.Gotham; targetLabel.TextSize = 11; targetLabel.Parent = statsFrame
    
    local modeStatus = Instance.new("TextLabel")
    modeStatus.Size = UDim2.new(1, 0, 0, 20); modeStatus.Position = UDim2.new(0, 5, 0, 40)
    modeStatus.Text = "MODE: " .. farmMode; modeStatus.BackgroundTransparency = 1
    modeStatus.TextColor3 = Color3.fromRGB(100, 200, 255); modeStatus.TextXAlignment = Enum.TextXAlignment.Left
    modeStatus.Font = Enum.Font.Gotham; modeStatus.TextSize = 11; modeStatus.Parent = statsFrame
    
    local moveStatus = Instance.new("TextLabel")
    moveStatus.Size = UDim2.new(1, 0, 0, 20); moveStatus.Position = UDim2.new(0, 5, 0, 60)
    moveStatus.Text = "MOVE: Smart Teleport"; moveStatus.BackgroundTransparency = 1
    moveStatus.TextColor3 = Color3.fromRGB(100, 255, 100); moveStatus.TextXAlignment = Enum.TextXAlignment.Left
    moveStatus.Font = Enum.Font.Gotham; moveStatus.TextSize = 11; moveStatus.Parent = statsFrame
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 100)
    
    -- ==================== BUTTON EVENTS ====================
    farmBtn.MouseButton1Click:Connect(function()
        farmEnabled = not farmEnabled
        farmBtn.Text = farmEnabled and "⚔️ AUTO FARM: ON" or "⚔️ AUTO FARM: OFF"
        farmBtn.BackgroundColor3 = farmEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if farmEnabled then task.spawn(startFarm) end
    end)
    
    local modes = {"Level", "Mastery", "Boss", "Raid", "SeaBeast"}
    local modeIndex = 1
    modeBtn.MouseButton1Click:Connect(function()
        modeIndex = modeIndex % #modes + 1; farmMode = modes[modeIndex]
        modeBtn.Text = "📌 MODE: " .. farmMode; modeStatus.Text = "MODE: " .. farmMode
    end)
    
    local moveModes = {"Smart Teleport", "Fly Only", "Walk Only", "Direct Teleport"}
    local moveIndex = 1
    movementBtn.MouseButton1Click:Connect(function()
        moveIndex = moveIndex % #moveModes + 1
        movementBtn.Text = "🏃 MOVE: " .. moveModes[moveIndex]; moveStatus.Text = "MOVE: " .. moveModes[moveIndex]
        if moveModes[moveIndex] == "Smart Teleport" then movementConfig.UseSmartTeleport = true
        elseif moveModes[moveIndex] == "Fly Only" then movementConfig.UseSmartTeleport = false; movementConfig.SpeedMode = "Variable"
        elseif moveModes[moveIndex] == "Walk Only" then movementConfig.UseSmartTeleport = false; movementConfig.SpeedMode = "Slow"
        else movementConfig.UseSmartTeleport = false; movementConfig.SpeedMode = "Fast" end
    end)
    
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
    end)
    
    godBtn.MouseButton1Click:Connect(function()
        godmodeEnabled = not godmodeEnabled
        godBtn.Text = godmodeEnabled and "🛡️ GODMODE: ON" or "🛡️ GODMODE: OFF"
        godBtn.BackgroundColor3 = godmodeEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if godmodeEnabled then task.spawn(godmode) end
    end)
    
    sniperBtn.MouseButton1Click:Connect(function()
        fruitSniperEnabled = not fruitSniperEnabled
        sniperBtn.Text = fruitSniperEnabled and "🍎 FRUIT SNIPER: ON" or "🍎 FRUIT SNIPER: OFF"
        sniperBtn.BackgroundColor3 = fruitSniperEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if fruitSniperEnabled then task.spawn(fruitSniper) end
    end)
    
    mirageBtn.MouseButton1Click:Connect(function()
        mirageFinderEnabled = not mirageFinderEnabled
        mirageBtn.Text = mirageFinderEnabled and "🏝️ MIRAGE FINDER: ON" or "🏝️ MIRAGE FINDER: OFF"
        mirageBtn.BackgroundColor3 = mirageFinderEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if mirageFinderEnabled then task.spawn(findMirage) end
    end)
    
    raceBtn.MouseButton1Click:Connect(function()
        raceV4Enabled = not raceV4Enabled
        raceBtn.Text = raceV4Enabled and "👑 RACE V4: ON" or "👑 RACE V4: OFF"
        raceBtn.BackgroundColor3 = raceV4Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if raceV4Enabled then task.spawn(autoRaceV4) end
    end)
    
    bountyBtn.MouseButton1Click:Connect(function()
        bountyHunterEnabled = not bountyHunterEnabled
        bountyBtn.Text = bountyHunterEnabled and "💰 BOUNTY HUNTER: ON" or "💰 BOUNTY HUNTER: OFF"
        bountyBtn.BackgroundColor3 = bountyHunterEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if bountyHunterEnabled then task.spawn(bountyHunter) end
    end)
    
    raidBtn.MouseButton1Click:Connect(function()
        raidEnabled = not raidEnabled
        raidBtn.Text = raidEnabled and "⚔️ AUTO RAID: ON" or "⚔️ AUTO RAID: OFF"
        raidBtn.BackgroundColor3 = raidEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if raidEnabled then task.spawn(autoRaid) end
    end)
    
    chestBtn.MouseButton1Click:Connect(function()
        chestFarmEnabled = not chestFarmEnabled
        chestBtn.Text = chestFarmEnabled and "📦 AUTO CHEST FARM: ON" or "📦 AUTO CHEST FARM: OFF"
        chestBtn.BackgroundColor3 = chestFarmEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if chestFarmEnabled then task.spawn(autoFarmChest) end
    end)
    
    hakiBtn.MouseButton1Click:Connect(function()
        autoHakiEnabled = not autoHakiEnabled
        hakiBtn.Text = autoHakiEnabled and "🔮 AUTO HAKI: ON" or "🔮 AUTO HAKI: OFF"
        hakiBtn.BackgroundColor3 = autoHakiEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoHakiEnabled then task.spawn(autoHaki) end
    end)
    
    dashBtn.MouseButton1Click:Connect(function()
        autoDashEnabled = not autoDashEnabled
        dashBtn.Text = autoDashEnabled and "💨 AUTO DASH: ON" or "💨 AUTO DASH: OFF"
        dashBtn.BackgroundColor3 = autoDashEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoDashEnabled then task.spawn(autoDash) end
    end)
    
    buyBtn.MouseButton1Click:Connect(function()
        autoBuyEnabled = not autoBuyEnabled
        buyBtn.Text = autoBuyEnabled and "🛒 AUTO BUY ITEMS: ON" or "🛒 AUTO BUY ITEMS: OFF"
        buyBtn.BackgroundColor3 = autoBuyEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoBuyEnabled then task.spawn(autoBuy) end
    end)
    
    skillBtn.MouseButton1Click:Connect(function()
        autoSkillMasteryEnabled = not autoSkillMasteryEnabled
        skillBtn.Text = autoSkillMasteryEnabled and "⭐ AUTO SKILL MASTERY: ON" or "⭐ AUTO SKILL MASTERY: OFF"
        skillBtn.BackgroundColor3 = autoSkillMasteryEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoSkillMasteryEnabled then task.spawn(autoSkillMastery) end
    end)
    
    hopBtn.MouseButton1Click:Connect(function()
        autoHopEnabled = not autoHopEnabled
        hopBtn.Text = autoHopEnabled and "🔄 AUTO HOP SERVER: ON" or "🔄 AUTO HOP SERVER: OFF"
        hopBtn.BackgroundColor3 = autoHopEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoHopEnabled then task.spawn(autoHopServer) end    end)
    
    bonesBtn.MouseButton1Click:Connect(function()
        autoBonesEnabled = not autoBonesEnabled
        bonesBtn.Text = autoBonesEnabled and "🦴 AUTO COLLECT BONES: ON" or "🦴 AUTO COLLECT BONES: OFF"
        bonesBtn.BackgroundColor3 = autoBonesEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoBonesEnabled then task.spawn(autoCollectBones) end
    end)
    
    spawnFruitBtn.MouseButton1Click:Connect(function()
        autoSpawnFruitEnabled = not autoSpawnFruitEnabled
        spawnFruitBtn.Text = autoSpawnFruitEnabled and "🍎 AUTO SPAWN FRUITS: ON" or "🍎 AUTO SPAWN FRUITS: OFF"
        spawnFruitBtn.BackgroundColor3 = autoSpawnFruitEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoSpawnFruitEnabled then task.spawn(autoSpawnFruit) end
    end)
    
    storeBtn.MouseButton1Click:Connect(function()
        autoStoreEnabled = not autoStoreEnabled
        storeBtn.Text = autoStoreEnabled and "📥 AUTO STORE FRUITS: ON" or "📥 AUTO STORE FRUITS: OFF"
        storeBtn.BackgroundColor3 = autoStoreEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoStoreEnabled then task.spawn(autoStoreFruits) end
    end)
    
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. frameCount; frameCount = 0; lastTime = now
        end
        targetLabel.Text = "TARGET: " .. (currentTarget and currentTarget.Name or "NONE")
    end)
    
    RunService.RenderStepped:Connect(function()
        if espEnabled then updateESP() end
    end)
    
    local drag, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function() drag = false end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and drag then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==================== INITIALIZATION ====================
local function start()
    print("\n" .. string.rep("█", 50))
    print("█ NEXUS ULTIMATE v5.0 - MOBILE OPTIMIZED")
    print(string.rep("█", 50) .. "\n")
    
    safeLoadScript()
    antiAFK()
    antiBan()
    preventMobileCrash()
    createVerifyGUI()
    
    repeat task.wait() until verified == true
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then createESP(p, "Player", espConfig.PlayerColor) end
    end
    
    Players.PlayerAdded:Connect(function(p)
        if p ~= player then createESP(p, "Player", espConfig.PlayerColor) end
    end)
    
    task.spawn(function()
        while true do
            if espEnabled then
                for _, fruitName in pairs(fruits) do
                    local fruit = Workspace:FindFirstChild(fruitName)
                    if fruit and not espObjects[fruit] then createESP(fruit, "Fruit", espConfig.FruitColor) end
                end
            end
            task.wait(humanizedWait(5, 1))
        end
    end)
    
    createMenu()
    
    print("\n=== NEXUS v5.0 FULLY LOADED ===")
    print("🔥 Functions: 20+")
    print("📱 Mobile optimized")
    if isOwner then print("👑 OWNER MODE ACTIVE!") end
    print("================================\n")
end

-- HOTKEY
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        local menu = player.PlayerGui:FindFirstChild("NexusMenu")
        if menu then menu.Enabled = not menu.Enabled end
    end
end)

-- START
if not scriptLoaded then start() else print("⚠️ Script already running!") end
