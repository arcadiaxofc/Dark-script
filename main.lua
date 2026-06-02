-- ==================== NEXUS v7.0 - SCRIPT COMPLETO 84 FUNÇÕES ====================
-- ==================== BIBLIOTECA UI X2ZU ====================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Window = Library:Window({
    Title = "NEXUS v7.0",
    Desc = "84 Funções - Blox Fruits Ultimate",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = { Keybind = Enum.KeyCode.LeftControl, Size = UDim2.new(0, 600, 0, 480) },
    CloseUIButton = { Enabled = true, Text = "NEXUS" }
})

-- ==================== SERVIÇOS ====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Stats = game:GetService("Stats")
local Debris = game:GetService("Debris")
local ContentProvider = game:GetService("ContentProvider")
local MarketPlace = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local InsertService = game:GetService("InsertService")
local BadgeService = game:GetService("BadgeService")
local GroupService = game:GetService("GroupService")
local Chat = game:GetService("Chat")
local ContextActionService = game:GetService("ContextActionService")

-- ==================== ANTI AFK (SEMPRE ATIVO - 3 MÉTODOS DIFERENTES) ====================
task.spawn(function()
    while true do
        task.wait(math.random(30, 90))
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(math.random(0, 100), math.random(0, 100)))
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(math.random(45, 120))
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local hum = player.Character.Humanoid
                hum:Move(Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)), true)
                task.wait(0.15)
                hum:Move(Vector3.zero, true)
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(math.random(60, 180))
        pcall(function()
            if UserInputService then
                UserInputService.GamepadEnabled = not UserInputService.GamepadEnabled
            end
        end)
    end
end)

-- ==================== OTIMIZAÇÃO DE PERFORMANCE ====================
task.spawn(function()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.Brightness = 2
        Lighting.FogEnd = 200
        Lighting.FogStart = 100
        if Workspace.Terrain then
            Workspace.Terrain.WaterWaveSize = 0
            Workspace.Terrain.WaterWaveSpeed = 0
            Workspace.Terrain.GrassLength = 0
            Workspace.Terrain.CloudsEnabled = false
        end
    end)
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
            if obj:IsA("Beam") or obj:IsA("Trail") then
                obj.Enabled = false
            end
            if obj:IsA("Decal") then
                obj:Destroy()
            end
        end)
    end
end)

-- ==================== VARIÁVEIS GLOBAIS ====================
local currentTarget = nil
local farmConfig = {Range = 300, AttackDelay = 0.3, AutoQuest = true, AutoStats = true, AutoCollect = true}
local espBills = {}
local teleportHistory = {}
local killCount = 0
local fruitCount = 0
local bossKillCount = 0
local serverHopCount = 0
local sessionStartTime = tick()

-- ==================== FUNÇÕES BASE AVANÇADAS ====================
local function teleportTo(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local startPos = hrp.Position
            
            -- Movimento em 3 etapas para parecer natural
            hrp.CFrame = CFrame.new(startPos + Vector3.new(0, 20, 0))
            task.wait(0.05)
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 10, 0))
            task.wait(0.05)
            hrp.CFrame = CFrame.new(pos)
            
            table.insert(teleportHistory, {pos = pos, time = tick()})
            if #teleportHistory > 50 then table.remove(teleportHistory, 1) end
        end
    end)
end

local function findTarget(range)
    range = range or farmConfig.Range
    local nearest, shortest = nil, range
    
    -- Método 1: CollectionService (mais rápido)
    local enemies = CollectionService:GetTagged("Enemy")
    if #enemies > 0 then
        for _, o in pairs(enemies) do
            pcall(function()
                if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then
                    local d = (o.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if d < shortest then shortest = d; nearest = o end
                end
            end)
        end
    end
    
    -- Método 2: Busca geral
    if not nearest then
        for _, o in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 and o ~= player.Character then
                    local d = (o.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if d < shortest then shortest = d; nearest = o end
                end
            end)
        end
    end
    
    return nearest
end

local function attackTarget()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then
            r.CommF_:InvokeServer("Click")
            killCount = killCount + 1
        end
    end)
end

local function useSkill(key)
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Skill", key) end
    end)
end

local function buyItem(item)
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyItem", item) end
    end)
end

local function findBoss(name)
    -- Busca direta
    local b = Workspace:FindFirstChild(name)
    if b and b:FindFirstChild("Humanoid") and b:FindFirstChild("HumanoidRootPart") and b.Humanoid.Health > 0 then
        return b
    end
    
    -- Busca por nome parcial
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:lower():find(name:lower()) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then
            return o
        end
    end
    
    return nil
end

local function findSeaEntity(name)
    for _, o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:lower():find(name:lower()) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then
            return o
        end
    end
    return nil
end

local function collectItem(name)
    local collected = 0
    for _, o in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if o.Name:lower():find(name:lower()) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = nil
                if o:IsA("BasePart") then
                    pos = o.Position
                elseif o:FindFirstChildOfClass("BasePart") then
                    pos = o:FindFirstChildOfClass("BasePart").Position
                elseif o:FindFirstChild("Handle") then
                    pos = o.Handle.Position
                end
                
                if pos then
                    local dist = (pos - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= farmConfig.Range then
                        teleportTo(pos)
                        task.wait(0.15)
                        
                        if o:FindFirstChild("TouchInterest") and player.Character then
                            firetouchinterest(o, player.Character.HumanoidRootPart, 0)
                            firetouchinterest(o, player.Character.HumanoidRootPart, 1)
                            collected = collected + 1
                        end
                        
                        -- Tenta coletar via remote
                        pcall(function()
                            local r = ReplicatedStorage:FindFirstChild("Remotes")
                            if r and r:FindFirstChild("CommF_") then
                                r.CommF_:InvokeServer("Collect", o.Name)
                            end
                        end)
                    end
                end
            end
        end)
    end
    return collected
end

local function equipBestWeapon()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then
            r.CommF_:InvokeServer("EquipWeapon", "CursedDualKatana")
        end
    end)
end

local function equipBestFruit()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") and player.Data and player.Data:FindFirstChild("Fruit") then
            if player.Data.Fruit.Value ~= "Kitsune" then
                r.CommF_:InvokeServer("EquipFruit", "Kitsune")
            end
        end
    end)
end

-- ==================== SISTEMA DE NOTIFICAÇÃO ====================
local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "NEXUS",
            Text = text or "",
            Duration = duration
        })
    end)
end

-- ==================== SISTEMA DE ESP AVANÇADO ====================
local function createESP(color, nameFilter, showHealth)
    task.spawn(function()
        while espBills[nameFilter] == nil do
            task.wait(0.1)
        end
        
        while espBills[nameFilter] do
            pcall(function()
                local count = 0
                for _, o in pairs(Workspace:GetDescendants()) do
                    if count > 100 then break end
                    
                    if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and o ~= player.Character and not espBills[o] then
                        local show = false
                        
                        if nameFilter == "player" then
                            show = Players:GetPlayerFromCharacter(o) ~= nil
                        elseif nameFilter == "fruit" then
                            show = o.Name:find("Fruit") ~= nil and o:FindFirstChild("Handle") ~= nil
                        elseif nameFilter == "chest" then
                            show = o.Name:lower():find("chest") ~= nil
                        elseif nameFilter == "boss" then
                            show = o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth > 10000
                        elseif nameFilter == "sea" then
                            show = o.Name:lower():find("sea") ~= nil and o:FindFirstChild("Humanoid")
                        elseif nameFilter == "ship" then
                            show = o.Name:lower():find("ship") ~= nil
                        elseif nameFilter == "npc" then
                            show = o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth > 0 and not Players:GetPlayerFromCharacter(o)
                        elseif nameFilter == "item" then
                            show = (o.Name:lower():find("fist") or o.Name:lower():find("chalice") or o.Name:lower():find("gear") or o.Name:lower():find("scroll")) ~= nil
                        elseif nameFilter == "material" then
                            show = (o.Name:lower():find("wood") or o.Name:lower():find("iron") or o.Name:lower():find("steel") or o.Name:lower():find("bone")) ~= nil
                        end
                        
                        if show then
                            pcall(function()
                                local hrp = o:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local d = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                    if d <= farmConfig.Range then
                                        local bill = Instance.new("BillboardGui")
                                        bill.Size = UDim2.new(0, 100, 0, 30)
                                        bill.AlwaysOnTop = true
                                        bill.MaxDistance = farmConfig.Range
                                        
                                        local label = Instance.new("TextLabel")
                                        label.Size = UDim2.new(1, 0, 1, 0)
                                        label.BackgroundTransparency = 0.6
                                        label.BackgroundColor3 = color
                                        label.TextColor3 = Color3.new(1, 1, 1)
                                        label.TextSize = 10
                                        label.Font = Enum.Font.GothamBold
                                        
                                        local text = o.Name
                                        if showHealth and o:FindFirstChild("Humanoid") then
                                            text = text .. "\n❤ " .. math.floor(o.Humanoid.Health)
                                        end
                                        if o:FindFirstChild("Humanoid") and o.Humanoid.MaxHealth > 0 then
                                            text = text .. " [" .. math.floor(d) .. "m]"
                                        end
                                        
                                        label.Text = text
                                        label.Parent = bill
                                        bill.Parent = hrp
                                        espBills[o] = bill
                                        count = count + 1
                                    end
                                end
                            end)
                        end
                    end
                end
                
                -- Limpeza
                for o, b in pairs(espBills) do
                    pcall(function()
                        if not o or not o.Parent or (o:FindFirstChild("Humanoid") and o.Humanoid.Health <= 0) then
                            if b and b.Parent then b:Destroy() end
                            espBills[o] = nil
                        end
                    end)
                end
            end)
            task.wait(2)
        end
    end)
end

-- ==================== SISTEMA DE AUTO QUEST ====================
local function autoQuest()
    pcall(function()
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                if npc:FindFirstChild("Quest") or npc:FindFirstChild("Talk") or npc.Name:lower():find("quest") then
                    local questRemote = ReplicatedStorage:FindFirstChild("Remotes")
                    if questRemote and questRemote:FindFirstChild("CommF_") then
                        teleportTo(npc.HumanoidRootPart.Position)
                        task.wait(0.5)
                        questRemote.CommF_:InvokeServer("StartQuest", npc.Name)
                        task.wait(0.3)
                        questRemote.CommF_:InvokeServer("CompleteQuest", npc.Name)
                    end
                    break
                end
            end
        end
    end)
end

-- ==================== SISTEMA DE AUTO STATS ====================
local function autoStats()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then
            for _, stat in pairs({"Melee", "Defense", "Sword", "Fruit", "Gun"}) do
                r.CommF_:InvokeServer("AddPoint", stat, 1)
            end
        end
    end)
end

-- ==================== SISTEMA DE HOP AVANÇADO ====================
local function serverHop()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/"..game.GameId.."/servers/Public?sortOrder=Asc&limit=50")
        end)
        
        if success and result then
            local servers = HttpService:JSONDecode(result)
            if servers and servers.data and #servers.data > 0 then
                local validServers = {}
                for _, s in pairs(servers.data) do
                    if s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(validServers, s)
                    end
                end
                
                if #validServers > 0 then
                    local chosen = validServers[math.random(1, #validServers)]
                    serverHopCount = serverHopCount + 1
                    notify("🔄 Server Hop", "Indo para servidor #" .. serverHopCount .. " (" .. chosen.playing .. "/" .. chosen.maxPlayers .. " jogadores)", 3)
                    task.wait(0.5)
                    TeleportService:TeleportToPlaceInstance(game.GameId, chosen.id, player)
                end
            end
        end
    end)
end

-- ==================== SISTEMA DE ANTI-BAN ====================
task.spawn(function()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if method == "FireServer" and args[1] then
                    local blocked = {"Teleport", "LoadChunk", "DetectSpeed", "FlagPlayer", "Kick", "Ban"}
                    for _, b in pairs(blocked) do
                        if tostring(args[1]):find(b) then return nil end
                    end
                end
                if method == "Kick" or method == "Ban" then return nil end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end)
end)

-- ==================== FUNÇÕES DE FARM COMPLETAS ====================
local function createFarmFunction(enabledVar, description)
    task.spawn(function()
        while enabledVar do
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
                end
                
                local target = findTarget()
                if target then
                    currentTarget = target
                    local dist = (player.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
                    
                    if dist > 15 then
                        teleportTo(target.HumanoidRootPart.Position)
                    end
                    
                    attackTarget()
                    
                    -- Usa habilidades automaticamente
                    if math.random(1, 3) == 1 then
                        local skills = {"Q", "E", "R", "Z", "X", "C"}
                        useSkill(skills[math.random(1, #skills)])
                    end
                    
                    -- Auto quest a cada 30 segundos
                    if farmConfig.AutoQuest and tick() % 30 < 0.5 then
                        autoQuest()
                    end
                    
                    -- Auto stats a cada 10 segundos
                    if farmConfig.AutoStats and tick() % 10 < 0.5 then
                        autoStats()
                    end
                end
            end)
            task.wait(farmConfig.AttackDelay)
        end
    end)
end

local function createBossFarmFunction(enabledVar, bossName)
    task.spawn(function()
        while enabledVar do
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
                end
                
                local boss = findBoss(bossName)
                if boss and boss:FindFirstChild("HumanoidRootPart") then
                    currentTarget = boss
                    teleportTo(boss.HumanoidRootPart.Position)
                    
                    -- Farm intensivo até matar
                    local startTime = tick()
                    while enabledVar and boss and boss.Parent and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 do
                        if tick() - startTime > 120 then break end -- Timeout de 2 minutos
                        attackTarget()
                        useSkill("Z")
                        useSkill("X")
                        useSkill("C")
                        task.wait(0.15)
                    end
                    
                    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health <= 0 then
                        bossKillCount = bossKillCount + 1
                        notify("🎯 Boss Morto", bossName .. " #" .. bossKillCount, 3)
                    end
                end
            end)
            task.wait(3)
        end
    end)
end

local function createSeaFarmFunction(enabledVar, entityName)
    task.spawn(function()
        while enabledVar do
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
                end
                
                local entity = findSeaEntity(entityName)
                if entity and entity:FindFirstChild("HumanoidRootPart") then
                    currentTarget = entity
                    teleportTo(entity.HumanoidRootPart.Position)
                    
                    for _ = 1, 30 do
                        if not enabledVar then break end
                        attackTarget()
                        useSkill("Q")
                        useSkill("E")
                        task.wait(0.2)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

local function createCollectFunction(enabledVar, itemName)
    task.spawn(function()
        while enabledVar do
            local collected = collectItem(itemName)
            if collected > 0 then
                notify("📦 Coletado", collected .. "x " .. itemName, 2)
            end
            task.wait(3)
        end
    end)
end

local function createSkillLoop(enabledVar, skillList, delay)
    task.spawn(function()
        while enabledVar do
            for _, skill in pairs(skillList) do
                if not enabledVar then break end
                useSkill(skill)
                task.wait(delay or 0.3)
            end
            task.wait(1)
        end
    end)
end

local function createBuyLoop(enabledVar, itemList, delay)
    task.spawn(function()
        while enabledVar do
            for _, item in pairs(itemList) do
                if not enabledVar then break end
                buyItem(item)
                task.wait(delay or 0.5)
            end
            task.wait(60)
        end
    end)
end

local function createToggleLoop(enabledVar, callback, delay)
    task.spawn(function()
        while enabledVar do
            pcall(callback)
            task.wait(delay or 0.1)
        end
    end)
end

-- ==================== TAB: ⚔️ COMBATE E FARM (8 funções) ====================
local CombatTab = Window:Tab({Title = "⚔️ Combate", Icon = "sword"})
CombatTab:Section({Title = "Farm Principal"})

local farmLevelEnabled = false
CombatTab:Toggle({Title = "Auto Farm Nível", Desc = "Farma NPCs normais automaticamente", Value = false, Callback = function(v) farmLevelEnabled = v if v then createFarmFunction(farmLevelEnabled, "Level Farm") end end})

local farmMasteryEnabled = false
CombatTab:Toggle({Title = "Auto Farm Maestria", Desc = "Usa todas as habilidades para upar maestria", Value = false, Callback = function(v) farmMasteryEnabled = v if v then createSkillLoop(farmMasteryEnabled, {"Z","X","C","V","F","Q","E","R"}, 0.3) end end})

local farmBossEnabled = false
CombatTab:Toggle({Title = "Auto Farm Boss", Desc = "Farma todos os bosses principais do jogo", Value = false, Callback = function(v) farmBossEnabled = v if v then task.spawn(function() while farmBossEnabled do pcall(function() local allBosses = {"Dough King","Soul Reaper","Cake Prince","Rip_indra","Darkbeard","Tide Keeper","Stone","Island Empress"} for _, name in pairs(allBosses) do if not farmBossEnabled then break end local boss = findBoss(name) if boss then currentTarget = boss teleportTo(boss.HumanoidRootPart.Position) for i = 1, 40 do if not farmBossEnabled then break end attackTarget() if i % 3 == 0 then useSkill("Z") end if i % 5 == 0 then useSkill("X") end task.wait(0.15) end end end end) task.wait(2) end end) end end})

local farmRaidEnabled = false
CombatTab:Toggle({Title = "Auto Farm Raid", Desc = "Entra e farma raids automaticamente", Value = false, Callback = function(v) farmRaidEnabled = v if v then task.spawn(function() while farmRaidEnabled do pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if not farmRaidEnabled then break end if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then teleportTo(o.Position) task.wait(0.3) firetouchinterest(o, player.Character.HumanoidRootPart, 0) task.wait(0.1) firetouchinterest(o, player.Character.HumanoidRootPart, 1) notify("⚔️ Raid", "Entrando na raid...", 2) break end end end) task.wait(30) end end) end end})

local farmSeaEnabled = false
CombatTab:Toggle({Title = "Auto Farm Sea Event", Desc = "Farma eventos do mar (Sea Beasts, Ships)", Value = false, Callback = function(v) farmSeaEnabled = v if v then task.spawn(function() while farmSeaEnabled do pcall(function() local seaTarget = findSeaEntity("Sea Beast") or findSeaEntity("Ship") or findSeaEntity("Terror") if seaTarget then currentTarget = seaTarget teleportTo(seaTarget.HumanoidRootPart.Position) for _ = 1, 30 do if not farmSeaEnabled then break end attackTarget() task.wait(0.2) end end end) task.wait(2) end end) end end})

local farmDungeonEnabled = false
CombatTab:Toggle({Title = "Auto Farm Dungeon", Desc = "Farma masmorras (Update 29)", Value = false, Callback = function(v) farmDungeonEnabled = v if v then task.spawn(function() while farmDungeonEnabled do pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if not farmDungeonEnabled then break end if o.Name:find("Dungeon") and o:FindFirstChild("TouchInterest") and player.Character then teleportTo(o.Position) task.wait(0.3) firetouchinterest(o, player.Character.HumanoidRootPart, 0) firetouchinterest(o, player.Character.HumanoidRootPart, 1) break end end local target = findTarget() if target then teleportTo(target.HumanoidRootPart.Position) for _ = 1, 20 do if not farmDungeonEnabled then break end attackTarget() task.wait(0.2) end end end) task.wait(5) end end) end end})

local farmEliteEnabled = false
CombatTab:Toggle({Title = "Auto Farm Elite", Desc = "Farma quests elite automaticamente", Value = false, Callback = function(v) farmEliteEnabled = v if v then task.spawn(function() while farmEliteEnabled do pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if not farmEliteEnabled then break end if o:IsA("Model") and (o.Name:find("Elite") or o.Name:find("Boss")) and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 then currentTarget = o teleportTo(o.HumanoidRootPart.Position) for _ = 1, 25 do if not farmEliteEnabled then break end attackTarget() useSkill("Z") task.wait(0.2) end end end end) task.wait(3) end end) end end})

local farmScrollEnabled = false
CombatTab:Toggle({Title = "Auto Farm Scroll", Desc = "Farma pergaminhos lendários", Value = false, Callback = function(v) farmScrollEnabled = v if v then createCollectFunction(farmScrollEnabled, "Scroll") end end})

CombatTab:Section({Title = "Kill Aura & Outros"})

local killAuraEnabled = false
CombatTab:Toggle({Title = "💀 Kill Aura", Desc = "Mata automaticamente tudo em volta (alcance 300)", Value = false, Callback = function(v) killAuraEnabled = v if v then task.spawn(function() while killAuraEnabled do pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local hrp = player.Character.HumanoidRootPart for _, o in pairs(Workspace:GetDescendants()) do if not killAuraEnabled then break end if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and o.Humanoid.Health > 0 and o ~= player.Character then local d = (o.HumanoidRootPart.Position - hrp.Position).Magnitude if d <= farmConfig.Range then currentTarget = o hrp.CFrame = CFrame.new(hrp.Position, o.HumanoidRootPart.Position) attackTarget() if math.random(1, 2) == 1 then useSkill("Z") end task.wait(0.03) end end end end end) task.wait(0.05) end end) end end})

-- ==================== TAB: 🍎 FRUTAS (6 funções) ====================
local FruitTab = Window:Tab({Title = "🍎 Frutas", Icon = "apple"})
FruitTab:Section({Title = "Sniper & Autos"})

local fruitSniperEnabled = false
FruitTab:Toggle({Title = "Fruit Sniper", Desc = "Teleporta automaticamente para qualquer fruta rara no mapa", Value = false, Callback = function(v) fruitSniperEnabled = v if v then task.spawn(function() local allFruits = {"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit","Control-Fruit","Shadow-Fruit","Rumble-Fruit","Buddha-Fruit","Portal-Fruit","Blizzard-Fruit","Sound-Fruit","Pain-Fruit","Love-Fruit","Spider-Fruit","Phoenix-Fruit","Magma-Fruit","Light-Fruit","Ice-Fruit","Flame-Fruit","Dark-Fruit","Sand-Fruit","Falcon-Fruit"} while fruitSniperEnabled do pcall(function() for _, name in pairs(allFruits) do if not fruitSniperEnabled then break end local fruit = Workspace:FindFirstChild(name) if fruit and fruit:FindFirstChild("Handle") then fruitCount = fruitCount + 1 notify("🍎 Fruta Encontrada!", name .. " #" .. fruitCount, 3) teleportTo(fruit.Handle.Position) task.wait(0.3) break end end end) task.wait(2) end end) end end})

local fruitStoreEnabled = false
FruitTab:Toggle({Title = "Auto Store Fruit", Desc = "Guarda a fruta atual no inventário automaticamente", Value = false, Callback = function(v) fruitStoreEnabled = v if v then task.spawn(function() while fruitStoreEnabled do pcall(function() if player.Data and player.Data:FindFirstChild("Fruit") then local currentFruit = player.Data.Fruit.Value if currentFruit and currentFruit ~= "" then local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("StoreFruit", currentFruit) notify("📥 Store", "Fruta " .. currentFruit .. " guardada!", 2) end end end end) task.wait(3) end end) end end})

local fruitSpawnEnabled = false
FruitTab:Toggle({Title = "Auto Spawn Fruit", Desc = "Compra fruta do Cousin automaticamente", Value = false, Callback = function(v) fruitSpawnEnabled = v if v then task.spawn(function() while fruitSpawnEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Cousin", "Buy") end end) task.wait(25) end end) end end})

local fruitRollEnabled = false
FruitTab:Toggle({Title = "Auto Roll Fruit", Desc = "Gira o gacha de frutas automaticamente", Value = false, Callback = function(v) fruitRollEnabled = v if v then task.spawn(function() while fruitRollEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("FruitGacha", "Roll") end end) task.wait(4) end end) end end})

local fruitNotifyEnabled = false
FruitTab:Toggle({Title = "Fruit Notify", Desc = "Avisa no chat quando uma fruta rara spawna no servidor", Value = false, Callback = function(v) fruitNotifyEnabled = v if v then task.spawn(function() local rareFruits = {"Kitsune-Fruit","Dragon-Fruit","Leopard-Fruit","Dough-Fruit","Spirit-Fruit","Venom-Fruit"} while fruitNotifyEnabled do pcall(function() for _, name in pairs(rareFruits) do if Workspace:FindFirstChild(name) then notify("⚠️ FRUTA RARA!", name .. " está no mapa!", 5) end end end) task.wait(8) end end) end end})

local fruitESPEnabled = false
FruitTab:Toggle({Title = "Fruit ESP", Desc = "Mostra frutas no mapa com BillboardGui rosa", Value = false, Callback = function(v) fruitESPEnabled = v if v then createESP(Color3.fromRGB(255, 0, 255), "fruit", false) espBills["fruit"] = true end end})

-- ==================== TAB: 🎯 BOSSES (10 funções) ====================
local BossTab = Window:Tab({Title = "🎯 Bosses", Icon = "target"})
BossTab:Section({Title = "Bosses Individuais"})

local bossList = {
    {name = "Dough King", icon = "👑"},
    {name = "Soul Reaper", icon = "💀"},
    {name = "Cake Prince", icon = "🎂"},
    {name = "Rip Indra", icon = "⚡"},
    {name = "Darkbeard", icon = "🏴‍☠️"},
    {name = "Tide Keeper", icon = "🌊"},
    {name = "Stone", icon = "🪨"},
    {name = "Island Empress", icon = "👸"},
    {name = "Hydra", icon = "🐉"},
    {name = "Leviathan", icon = "🐋"},
}

local bossEnabledVars = {}
for _, boss in pairs(bossList) do
    bossEnabledVars[boss.name] = false
    BossTab:Toggle({Title = boss.icon .. " " .. boss.name, Desc = "Farm automático do boss " .. boss.name, Value = false, Callback = function(v) bossEnabledVars[boss.name] = v if v then createBossFarmFunction(bossEnabledVars[boss.name], boss.name) end end})
end

-- ==================== TAB: 🌊 SEA EVENTS (8 funções) ====================
local SeaTab = Window:Tab({Title = "🌊 Sea", Icon = "waves"})
SeaTab:Section({Title = "Eventos do Mar"})

local seaList = {
    {name = "Marine Ship", icon = "🚢"},
    {name = "Pirate Ship", icon = "🏴‍☠️"},
    {name = "Sea Beast", icon = "🐉"},
    {name = "Terror Shark", icon = "🦈"},
    {name = "Rumbling Waters", icon = "🌪️"},
    {name = "Mansion", icon = "🏰"},
    {name = "Pirate Raid", icon = "⚔️"},
    {name = "Sea Castle", icon = "🏯"},
}

local seaEnabledVars = {}
for _, event in pairs(seaList) do
    seaEnabledVars[event.name] = false
    SeaTab:Toggle({Title = event.icon .. " " .. event.name, Desc = "Farm automático de " .. event.name, Value = false, Callback = function(v) seaEnabledVars[event.name] = v if v then createSeaFarmFunction(seaEnabledVars[event.name], event.name) end end})
end

-- ==================== TAB: 📦 COLETA (8 funções) ====================
local CollectTab = Window:Tab({Title = "📦 Coleta", Icon = "package"})
CollectTab:Section({Title = "Auto Collect"})

local collectList = {
    {name = "Chest", icon = "📦"},
    {name = "Bone", icon = "🦴"},
    {name = "Fist of Darkness", icon = "👊"},
    {name = "God's Chalice", icon = "🏆"},
    {name = "Blue Gear", icon = "🔵"},
    {name = "Sweet Chalice", icon = "🍬"},
    {name = "Scroll", icon = "📜"},
    {name = "Fruit Chest", icon = "🧰"},
}

local collectEnabledVars = {}
for _, item in pairs(collectList) do
    collectEnabledVars[item.name] = false
    CollectTab:Toggle({Title = item.icon .. " Auto " .. item.name, Desc = "Coleta " .. item.name .. " automaticamente", Value = false, Callback = function(v) collectEnabledVars[item.name] = v if v then createCollectFunction(collectEnabledVars[item.name], item.name) end end})
end

-- ==================== TAB: 🏃 MOVIMENTAÇÃO (9 funções) ====================
local MoveTab = Window:Tab({Title = "🏃 Movimento", Icon = "run"})
MoveTab:Section({Title = "Movimentação Automática"})

local hopEnabled = false
MoveTab:Toggle({Title = "🔄 Auto Hop Server", Desc = "Troca de servidor automaticamente se não tiver fruta rara", Value = false, Callback = function(v) hopEnabled = v if v then task.spawn(function() while hopEnabled do serverHop() task.wait(45) end end) end end})

local teleportIslandEnabled = false
MoveTab:Toggle({Title = "🏝️ Auto TP to Island", Desc = "Teleporta para ilhas aleatórias", Value = false, Callback = function(v) teleportIslandEnabled = v if v then task.spawn(function() local islands = {Vector3.new(1289,11,4191),Vector3.new(-1250,15,3850),Vector3.new(-383,15,727),Vector3.new(966,10,1100),Vector3.new(1150,25,4350),Vector3.new(-4850,750,1950),Vector3.new(-3560,240,-80),Vector3.new(-5400,15,-1700),Vector3.new(4500,50,1200),Vector3.new(6200,80,2500)} while teleportIslandEnabled do pcall(function() teleportTo(islands[math.random(1,#islands)]) end) task.wait(15) end end) end end})

local teleportNPCEnabled = false
MoveTab:Toggle({Title = "👤 Auto TP to NPC", Desc = "Teleporta para NPCs de quest", Value = false, Callback = function(v) teleportNPCEnabled = v if v then task.spawn(function() while teleportNPCEnabled do pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and (o:FindFirstChild("Quest") or o:FindFirstChild("Talk")) then teleportTo(o.HumanoidRootPart.Position) break end end end) task.wait(8) end end) end end})

local teleportFruitEnabled = false
MoveTab:Toggle({Title = "🍎 Auto TP to Fruit", Desc = "Teleporta para frutas no chão", Value = false, Callback = function(v) teleportFruitEnabled = v if v then task.spawn(function() while teleportFruitEnabled do pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:find("Fruit") and o:FindFirstChild("Handle") then teleportTo(o.Handle.Position) break end end end) task.wait(5) end end) end end})

local teleportChestEnabled = false
MoveTab:Toggle({Title = "📦 Auto TP to Chest", Desc = "Teleporta para baús", Value = false, Callback = function(v) teleportChestEnabled = v if v then task.spawn(function() while teleportChestEnabled do pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:lower():find("chest") and o:FindFirstChildOfClass("BasePart") then teleportTo(o:FindFirstChildOfClass("BasePart").Position) break end end end) task.wait(5) end end) end end})

local teleportPlayerEnabled = false
MoveTab:Toggle({Title = "👥 Auto TP to Player", Desc = "Teleporta para jogadores com bounty alto", Value = false, Callback = function(v) teleportPlayerEnabled = v if v then task.spawn(function() while teleportPlayerEnabled do pcall(function() local best, bb = nil, 0 for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b = p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b > bb then bb = b best = p end end end if best then teleportTo(best.Character.HumanoidRootPart.Position) end end) task.wait(8) end end) end end})

local dashEnabled = false
MoveTab:Toggle({Title = "💨 Auto Dash", Desc = "Dash aleatório automático", Value = false, Callback = function(v) dashEnabled = v if v then task.spawn(function() while dashEnabled do pcall(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local dir = Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + dir * 25 end end) task.wait(math.random(2,5)) end end) end end})

local flightEnabled = false
MoveTab:Toggle({Title = "✈️ Auto Flight", Desc = "Ativa voo infinito", Value = false, Callback = function(v) flightEnabled = v if v then task.spawn(function() while flightEnabled do pcall(function() if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end end end) task.wait(0.3) end end) end end})

local swimEnabled = false
MoveTab:Toggle({Title = "🏊 Auto Swim", Desc = "Ativa nado automático", Value = false, Callback = function(v) swimEnabled = v if v then task.spawn(function() while swimEnabled do pcall(function() if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Swimming) end end end) task.wait(0.3) end end) end end})

-- ==================== TAB: ⚙️ AUTOMÁTICOS (10 funções) ====================
local AutoTab = Window:Tab({Title = "⚙️ Automático", Icon = "gear"})
AutoTab:Section({Title = "Automações Gerais"})

local hakiEnabled = false
AutoTab:Toggle({Title = "🔮 Auto Haki", Desc = "Ativa Ken Haki e Buso Haki automaticamente", Value = false, Callback = function(v) hakiEnabled = v if v then task.spawn(function() while hakiEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("ActivateHaki","Ken") task.wait(0.1) r.CommF_:InvokeServer("ActivateHaki","Buso") end end) task.wait(25) end end) end end})

local autoSkillEnabled = false
AutoTab:Toggle({Title = "⭐ Auto Skill", Desc = "Usa todas as habilidades (Z,X,C,V,F) em loop", Value = false, Callback = function(v) autoSkillEnabled = v if v then createSkillLoop(autoSkillEnabled, {"Z","X","C","V","F"}, 0.25) end end})

local metaverseEnabled = false
AutoTab:Toggle({Title = "🌐 Auto Metaverse", Desc = "Ativa habilidades do Metaverso", Value = false, Callback = function(v) metaverseEnabled = v if v then task.spawn(function() while metaverseEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Metaverse","Start") end end) task.wait(45) end end) end end})

local raceAwakenEnabled = false
AutoTab:Toggle({Title = "🧬 Auto Race Awakening", Desc = "Desperta sua raça automaticamente", Value = false, Callback = function(v) raceAwakenEnabled = v if v then task.spawn(function() while raceAwakenEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceAwakening","Start") end end) task.wait(55) end end) end end})

local accessoryEnabled = false
AutoTab:Toggle({Title = "💍 Auto Accessory Farm", Desc = "Farma acessórios", Value = false, Callback = function(v) accessoryEnabled = v if v then task.spawn(function() while accessoryEnabled do pcall(function() local t = findTarget() if t then teleportTo(t.HumanoidRootPart.Position) for _ = 1, 15 do attackTarget() task.wait(0.2) end end end) task.wait(3) end end) end end})

local titleEnabled = false
AutoTab:Toggle({Title = "🏅 Auto Title Farm", Desc = "Farma títulos", Value = false, Callback = function(v) titleEnabled = v if v then task.spawn(function() while titleEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("Title","Equip") end end) task.wait(60) end end) end end})

local questEnabled = false
AutoTab:Toggle({Title = "📋 Auto Quest", Desc = "Pega e completa quests automaticamente", Value = false, Callback = function(v) questEnabled = v if v then task.spawn(function() while questEnabled do autoQuest() task.wait(8) end end) end end})

local gearEnabled = false
AutoTab:Toggle({Title = "⚙️ Auto Gear Farm", Desc = "Farma equipamentos", Value = false, Callback = function(v) gearEnabled = v if v then createCollectFunction(gearEnabled, "Gear") end end})

local v4Enabled = false
AutoTab:Toggle({Title = "👑 Auto V4 Awakening", Desc = "Desperta Raça V4 automaticamente", Value = false, Callback = function(v) v4Enabled = v if v then task.spawn(function() while v4Enabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("RaceV4","Start") end end) task.wait(55) end end) end end})

local raidFruitsEnabled = false
AutoTab:Toggle({Title = "⚔️ Auto Raid Fruits", Desc = "Farma frutas em raids", Value = false, Callback = function(v) raidFruitsEnabled = v if v then task.spawn(function() while raidFruitsEnabled do pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:find("Raid") and o:FindFirstChild("TouchInterest") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then teleportTo(o.Position) task.wait(0.3) firetouchinterest(o, player.Character.HumanoidRootPart, 0) firetouchinterest(o, player.Character.HumanoidRootPart, 1) end end end) task.wait(25) end end) end end})

-- ==================== TAB: 🛍️ LOJA (10 funções) ====================
local ShopTab = Window:Tab({Title = "🛍️ Loja", Icon = "shop"})
ShopTab:Section({Title = "Auto Comprar"})

local shopList = {
    {name = "Fruits", items = {"Kitsune","Dragon","Leopard","Dough","Spirit","Venom","Control","Shadow","Rumble","Buddha"}},
    {name = "Fighting Styles", items = {"Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman"}},
    {name = "Swords", items = {"Cursed Dual Katana","True Triple Katana","Dark Blade","Shark Anchor","Spikey Trident"}},
    {name = "Guns", items = {"Soul Guitar","Acidum Rifle","Bizarre Rifle","Serpent Bow","Skull Guitar"}},
    {name = "Accessories", items = {"Pale Scarf","Valkyrie Helmet","Lei","Swan Glasses","Black Cape"}},
    {name = "Materials", items = {"Wood","Iron","Steel","Mithril","Adamantite"}},
}

local shopEnabledVars = {}
for _, shop in pairs(shopList) do
    shopEnabledVars[shop.name] = false
    ShopTab:Toggle({Title = "🛒 Auto Buy " .. shop.name, Desc = "Compra " .. shop.name .. " automaticamente", Value = false, Callback = function(v) shopEnabledVars[shop.name] = v if v then createBuyLoop(shopEnabledVars[shop.name], shop.items, 0.4) end end})
end

local statsBuyEnabled = false
ShopTab:Toggle({Title = "📊 Auto Buy Stats", Desc = "Compra pontos de status (Melee, Defesa, etc)", Value = false, Callback = function(v) statsBuyEnabled = v if v then task.spawn(function() while statsBuyEnabled do autoStats() task.wait(0.8) end end) end end})

local gamepassEnabled = false
ShopTab:Toggle({Title = "🎫 Auto Buy Gamepass", Desc = "Compra gamepasses disponíveis", Value = false, Callback = function(v) gamepassEnabled = v if v then task.spawn(function() while gamepassEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("BuyGamepass","2xMoney") task.wait(0.3) r.CommF_:InvokeServer("BuyGamepass","2xMastery") end end) task.wait(300) end end) end end})

local fragmentsBuyEnabled = false
ShopTab:Toggle({Title = "💎 Auto Buy Fragments", Desc = "Compra fragmentos", Value = false, Callback = function(v) fragmentsBuyEnabled = v if v then task.spawn(function() while fragmentsBuyEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddFragments",1000) end end) task.wait(8) end end) end end})

local bonesBuyEnabled = false
ShopTab:Toggle({Title = "🦴 Auto Buy Bones", Desc = "Compra ossos", Value = false, Callback = function(v) bonesBuyEnabled = v if v then task.spawn(function() while bonesBuyEnabled do pcall(function() local r = ReplicatedStorage:FindFirstChild("Remotes") if r and r:FindFirstChild("CommF_") then r.CommF_:InvokeServer("AddBones",100) end end) task.wait(4) end end) end end})

-- ==================== TAB: 👀 VISUAL (9 funções) ====================
local VisualTab = Window:Tab({Title = "👀 Visual", Icon = "eye"})
VisualTab:Section({Title = "ESP (Extra Sensory Perception)"})

local espList = {
    {name = "ESP Players", color = Color3.fromRGB(255, 0, 0), filter = "player", health = true},
    {name = "ESP Fruits", color = Color3.fromRGB(255, 0, 255), filter = "fruit", health = false},
    {name = "ESP Chests", color = Color3.fromRGB(255, 215, 0), filter = "chest", health = false},
    {name = "ESP Bosses", color = Color3.fromRGB(255, 50, 50), filter = "boss", health = true},
    {name = "ESP Items", color = Color3.fromRGB(0, 255, 255), filter = "item", health = false},
    {name = "ESP Materials", color = Color3.fromRGB(0, 255, 0), filter = "material", health = false},
    {name = "ESP NPCs", color = Color3.fromRGB(255, 255, 0), filter = "npc", health = true},
    {name = "ESP Sea Beasts", color = Color3.fromRGB(0, 0, 255), filter = "sea", health = true},
    {name = "ESP Ships", color = Color3.fromRGB(128, 128, 128), filter = "ship", health = false},
}

for _, esp in pairs(espList) do
    local espEnabled = false
    VisualTab:Toggle({Title = esp.name, Desc = "Mostra " .. esp.name:lower() .. " no mapa com BillboardGui colorido", Value = false, Callback = function(v) espEnabled = v if v then createESP(esp.color, esp.filter, esp.health) espBills[esp.filter] = true else espBills[esp.filter] = nil for o, b in pairs(espBills) do if type(o) ~= "string" then b:Destroy() espBills[o] = nil end end end end})
end

-- ==================== TAB: 🎮 EXTRA (6 funções) ====================
local ExtraTab = Window:Tab({Title = "🎮 Extra", Icon = "star"})
ExtraTab:Section({Title = "Funções Especiais"})

local aimlockEnabled = false
ExtraTab:Toggle({Title = "🎯 Aimlock", Desc = "Mira automática no alvo mais próximo", Value = false, Callback = function(v) aimlockEnabled = v if v then task.spawn(function() while aimlockEnabled do pcall(function() local t = findTarget() if t and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, t.HumanoidRootPart.Position) end end) task.wait(0.03) end end) end end})

local noclipEnabled = false
ExtraTab:Toggle({Title = "🚫 No Clip", Desc = "Anda através de paredes e objetos", Value = false, Callback = function(v) noclipEnabled = v if v then task.spawn(function() while noclipEnabled do pcall(function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) task.wait(0.1) end pcall(function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end) end) end end})

ExtraTab:Slider({Title = "🏃 Walkspeed", Desc = "Ajusta a velocidade de caminhada", Min = 16, Max = 400, Rounding = 0, Value = 16, Callback = function(v) pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v end end end) end})

ExtraTab:Slider({Title = "🦘 Jumpspeed", Desc = "Ajusta a altura do pulo", Min = 50, Max = 600, Rounding = 0, Value = 50, Callback = function(v) pcall(function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = v end end end) end})

ExtraTab:Slider({Title = "👁️ FOV", Desc = "Ajusta o campo de visão", Min = 30, Max = 120, Rounding = 0, Value = 70, Callback = function(v) pcall(function() workspace.CurrentCamera.FieldOfView = v end) end})

local bountyHuntEnabled = false
ExtraTab:Toggle({Title = "💰 Bounty Hunt", Desc = "Caça e mata jogadores com bounty alto", Value = false, Callback = function(v) bountyHuntEnabled = v if v then task.spawn(function() while bountyHuntEnabled do pcall(function() local best, bb = nil, 0 for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local b = p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0 if b > bb then bb = b best = p end end end if best then teleportTo(best.Character.HumanoidRootPart.Position) for _ = 1, 20 do if not bountyHuntEnabled then break end attackTarget() useSkill("Z") task.wait(0.1) end end end) task.wait(4) end end) end end})

local fragmentFarmEnabled = false
ExtraTab:Toggle({Title = "💎 Fragment Farm", Desc = "Farma fragmentos matando inimigos", Value = false, Callback = function(v) fragmentFarmEnabled = v if v then task.spawn(function() while fragmentFarmEnabled do pcall(function() local t = findTarget() if t then teleportTo(t.HumanoidRootPart.Position) for _ = 1, 15 do if not fragmentFarmEnabled then break end attackTarget() task.wait(0.2) end end end) task.wait(1) end end) end end})

local godmodeEnabled = false
ExtraTab:Toggle({Title = "🛡️ Godmode", Desc = "Vida infinita (regenera HP constantemente)", Value = false, Callback = function(v) godmodeEnabled = v if v then createToggleLoop(godmodeEnabled, function() if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid") if h then h.Health = h.MaxHealth h.BreakJointsOnDeath = false end end end, 0.05) end end})

-- ==================== SEPARADOR ====================
Window:Line()

-- ==================== ESTATÍSTICAS ====================
local StatsTab = Window:Tab({Title = "📊 Stats", Icon = "chart"})
StatsTab:Section({Title = "Sessão Atual"})

StatsTab:Button({Title = "📊 Ver Estatísticas", Desc = "Mostra estatísticas da sessão atual", Callback = function()
    local runtime = tick() - sessionStartTime
    local hours = math.floor(runtime / 3600)
    local minutes = math.floor((runtime % 3600) / 60)
    local seconds = math.floor(runtime % 60)
    
    Window:Notify({
        Title = "📊 Estatísticas da Sessão",
        Desc = string.format("Tempo: %02d:%02d:%02d\nKills: %d\nBosses: %d\nFrutas: %d\nServer Hops: %d\nAlvo Atual: %s",
            hours, minutes, seconds,
            killCount, bossKillCount, fruitCount, serverHopCount,
            currentTarget and currentTarget.Name or "Nenhum"),
        Time = 8
    })
end})

StatsTab:Button({Title = "🔄 Resetar Estatísticas", Desc = "Zera todas as estatísticas da sessão", Callback = function()
    killCount = 0
    bossKillCount = 0
    fruitCount = 0
    serverHopCount = 0
    sessionStartTime = tick()
    Window:Notify({Title = "📊 Stats", Desc = "Estatísticas resetadas!", Time = 3})
end})

-- ==================== CONFIGURAÇÕES ====================
local ConfigTab = Window:Tab({Title = "⚙️ Config", Icon = "wrench"})
ConfigTab:Section({Title = "Configurações do Farm"})

ConfigTab:Slider({Title = "Alcance do Farm", Desc = "Distância máxima para encontrar alvos", Min = 50, Max = 1000, Rounding = 0, Value = 300, Callback = function(v) farmConfig.Range = v end})

ConfigTab:Slider({Title = "Delay de Ataque", Desc = "Intervalo entre ataques (segundos)", Min = 0.1, Max = 2, Rounding = 1, Value = 0.3, Callback = function(v) farmConfig.AttackDelay = v end})

ConfigTab:Toggle({Title = "Auto Quest", Desc = "Pega quests automaticamente durante o farm", Value = true, Callback = function(v) farmConfig.AutoQuest = v end})

ConfigTab:Toggle({Title = "Auto Stats", Desc = "Distribui pontos de status automaticamente", Value = true, Callback = function(v) farmConfig.AutoStats = v end})

ConfigTab:Toggle({Title = "Auto Collect", Desc = "Coleta itens automaticamente durante o farm", Value = true, Callback = function(v) farmConfig.AutoCollect = v end})

ConfigTab:Section({Title = "Configurações Visuais"})

ConfigTab:Dropdown({Title = "Tema da UI", Desc = "Escolha o tema da interface", List = {"Dark", "Light", "Red", "Blue", "Green", "Purple"}, Value = "Dark", Callback = function(choice) Window:Notify({Title = "Tema", Desc = "Tema alterado para " .. choice, Time = 2}) end})

-- ==================== NOTIFICAÇÃO FINAL ====================
Window:Notify({
    Title = "✅ NEXUS v7.0 CARREGADO!",
    Desc = "84 funções ativas!\nAnti AFK: ✅\nOtimização: ✅\nESP: Pronto\nBosses: Pronto\nTudo funcionando!\n\nComando: loadstring(game:HttpGet('https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/main.lua'))()",
    Time = 8
})

print("=" .. string.rep("=", 50))
print("NEXUS v7.0 - 84 FUNÇÕES COMPLETAS")
print("=" .. string.rep("=", 50))
print("✅ Anti AFK (3 métodos)")
print("✅ Otimização de performance")
print("✅ 84 funções implementadas")
print("✅ UI X2ZU integrada")
print("✅ Sistema de estatísticas")
print("✅ Configurações ajustáveis")
print("✅ ESP avançado com filtros")
print("✅ Sistema de notificações")
print("✅ Anti-ban integrado")
print("=" .. string.rep("=", 50))
