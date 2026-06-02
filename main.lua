-- ==================== NEXUS v7.0 - COMPLETO E CORRIGIDO ====================

-- Serviços
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

-- Key System
local verified = false
local isOwner = false
local keyData = nil

local demoKeys = {
    ["NEXUS-VIP-2026"] = {type = "vip", level = 3, expires = "2027-12-31"},
    ["FREE-TRIAL"] = {type = "trial", level = 1, expires = "2026-12-31"},
    ["BLOX-ADMIN"] = {type = "admin", level = 5, expires = "2027-12-31"},
    ["KITSUNE-777"] = {type = "vip", level = 4, expires = "2027-12-31"},
    ["OWNER-TEST"] = {type = "owner", level = 10, expires = "2027-12-31"}
}

-- Idiomas
local Languages = {
    pt = {
        flag = "🇧🇷", title = "NEXUS v7.0", subtitle = "DIGITE SUA CHAVE", placeholder = "XXXX-XXXX-XXXX-XXXX",
        verify = "VERIFICAR", getkey = "OBTER CHAVE", waiting = "Aguardando...", copied = "✅ COPIADO!",
        verifying = "🔄 Verificando...", verifiedText = "✅ VERIFICADO!", invalid = "❌ INVALIDA!",
        enterKey = "❌ Digite a chave!", autoVerified = "✅ AUTO-VERIFICADO",
        farm = "⚔️ AUTO FARM", godmode = "🛡️ GODMODE", esp = "👁️ ESP",
        sniper = "🍎 FRUIT SNIPER", bounty = "💰 BOUNTY HUNTER", tp = "📍 TP TO TARGET",
        on = "ON", off = "OFF", allOff = "Todas as funções desligadas!"
    },
    en = {
        flag = "🇺🇸", title = "NEXUS v7.0", subtitle = "ENTER YOUR KEY", placeholder = "XXXX-XXXX-XXXX-XXXX",
        verify = "VERIFY", getkey = "GET KEY", waiting = "Waiting...", copied = "✅ COPIED!",
        verifying = "🔄 Verifying...", verifiedText = "✅ VERIFIED!", invalid = "❌ INVALID!",
        enterKey = "❌ Enter the key!", autoVerified = "✅ AUTO-VERIFIED",
        farm = "⚔️ AUTO FARM", godmode = "🛡️ GODMODE", esp = "👁️ ESP",
        sniper = "🍎 FRUIT SNIPER", bounty = "💰 BOUNTY HUNTER", tp = "📍 TP TO TARGET",
        on = "ON", off = "OFF", allOff = "All functions disabled!"
    },
    es = {
        flag = "🇪🇸", title = "NEXUS v7.0", subtitle = "INGRESA TU LLAVE", placeholder = "XXXX-XXXX-XXXX-XXXX",
        verify = "VERIFICAR", getkey = "OBTENER", waiting = "Esperando...", copied = "✅ COPIADO!",
        verifying = "🔄 Verificando...", verifiedText = "✅ VERIFICADO!", invalid = "❌ INVALIDA!",
        enterKey = "❌ Ingresa la llave!", autoVerified = "✅ AUTO-VERIFICADO",
        farm = "⚔️ AUTO FARM", godmode = "🛡️ GODMODE", esp = "👁️ ESP",
        sniper = "🍎 FRUIT SNIPER", bounty = "💰 BOUNTY HUNTER", tp = "📍 TP TO TARGET",
        on = "ON", off = "OFF", allOff = "¡Todas las funciones apagadas!"
    }
}

local currentLang = "pt"
local Lang = Languages[currentLang]

-- Variáveis
local farmEnabled = false
local godmodeEnabled = false
local espEnabled = false
local fruitSniperEnabled = false
local bountyHunterEnabled = false
local autoRaidEnabled = false
local autoChestEnabled = false
local autoHakiEnabled = false
local autoDashEnabled = false
local autoBuyEnabled = false
local autoSkillEnabled = false
local autoHopEnabled = false
local autoBonesEnabled = false
local currentTarget = nil
local farmConfig = {Range = 300, AttackDelay = 0.3}
local espBills = {}

-- Funções de verificação
local function validateKey(key)
    if not key or type(key) ~= "string" then return false end
    return #key >= 8 and string.match(key, "^[%w%-]+$") ~= nil
end

local function checkExpiration(date)
    if not date then return true end
    local year, month, day = date:match("^(%d+)-(%d+)-(%d+)$")
    if not year then return true end
    local expireTime = os.time({year=tonumber(year), month=tonumber(month), day=tonumber(day), hour=23, min=59, sec=59})
    return os.time() <= expireTime
end

local function verifyKey(key)
    if not validateKey(key) then return false, "FORMATO_INVALIDO", nil end
    local data = demoKeys[key]
    if data then
        if not checkExpiration(data.expires) then return false, "KEY_EXPIRADA", nil end
        return true, data.type, data
    end
    return false, "KEY_INVALIDA", nil
end

-- UI de Verificação
local function createVerifyGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusVerify"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 340)
    frame.Position = UDim2.new(0.5, -200, 0.5, -170)
    frame.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
    topBar.BorderSizePixel = 0
    topBar.Parent = frame
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 3)
    accent.BackgroundColor3 = Color3.fromRGB(230, 65, 50)
    accent.BorderSizePixel = 0
    accent.Parent = topBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Position = UDim2.new(0, 15, 0.5, -10)
    titleLabel.Size = UDim2.new(1, -100, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(230, 65, 50)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🔑 " .. Lang.title
    titleLabel.Parent = topBar
    
    local langBtn = Instance.new("TextButton")
    langBtn.Size = UDim2.new(0, 60, 0, 28)
    langBtn.AnchorPoint = Vector2.new(1, 0.5)
    langBtn.Position = UDim2.new(1, -10, 0.5, 0)
    langBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
    langBtn.BorderSizePixel = 0
    langBtn.TextColor3 = Color3.fromRGB(230, 230, 236)
    langBtn.TextSize = 12
    langBtn.Font = Enum.Font.GothamBold
    langBtn.Text = Lang.flag
    langBtn.AutoButtonColor = false
    langBtn.Parent = topBar
    Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 5)
    
    langBtn.MouseButton1Click:Connect(function()
        if currentLang == "pt" then currentLang = "en"
        elseif currentLang == "en" then currentLang = "es"
        else currentLang = "pt" end
        Lang = Languages[currentLang]
        langBtn.Text = Lang.flag
        titleLabel.Text = "🔑 " .. Lang.title
        subtitleLabel.Text = Lang.subtitle
        keyBox.PlaceholderText = Lang.placeholder
        verifyBtn.Text = Lang.verify
        getKeyBtn.Text = Lang.getkey
        statusLabel.Text = Lang.waiting
    end)
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -30, 1, -55)
    content.Position = UDim2.new(0, 15, 0, 50)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Parent = frame
    
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, 0, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 0, 0, 5)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 165)
    subtitleLabel.TextSize = 13
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Text = Lang.subtitle
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    subtitleLabel.Parent = content
    
    local keyBoxFrame = Instance.new("Frame")
    keyBoxFrame.Size = UDim2.new(1, 0, 0, 40)
    keyBoxFrame.Position = UDim2.new(0, 0, 0, 35)
    keyBoxFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 31)
    keyBoxFrame.BorderSizePixel = 0
    keyBoxFrame.Parent = content
    Instance.new("UICorner", keyBoxFrame).CornerRadius = UDim.new(0, 7)
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(1, -20, 1, 0)
    keyBox.Position = UDim2.new(0, 10, 0, 0)
    keyBox.BackgroundTransparency = 1
    keyBox.BorderSizePixel = 0
    keyBox.PlaceholderText = Lang.placeholder
    keyBox.TextColor3 = Color3.fromRGB(230, 230, 236)
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    keyBox.TextSize = 14
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextXAlignment = Enum.TextXAlignment.Center
    keyBox.Parent = keyBoxFrame
    
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(1, 0, 0, 38)
    verifyBtn.Position = UDim2.new(0, 0, 0, 88)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(210, 58, 45)
    verifyBtn.BorderSizePixel = 0
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.TextSize = 14
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.Text = Lang.verify
    verifyBtn.AutoButtonColor = false
    verifyBtn.Parent = content
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 7)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 135)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = Lang.waiting
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = content
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(1, 0, 0, 33)
    getKeyBtn.Position = UDim2.new(0, 0, 0, 170)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 54)
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 236)
    getKeyBtn.TextSize = 13
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.Text = Lang.getkey
    getKeyBtn.AutoButtonColor = false
    getKeyBtn.Parent = content
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("NEXUS-VIP-2026") end)
        statusLabel.Text = Lang.copied
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(2)
        statusLabel.Text = Lang.waiting
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end)
    
    verifyBtn.MouseButton1Click:Connect(function()
        local key = keyBox.Text:gsub("%s+", ""):upper()
        if key == "" then
            statusLabel.Text = Lang.enterKey
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
        statusLabel.Text = Lang.verifying
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        verifyBtn.Enabled = false
        task.wait(0.3)
        local success, msg, data = verifyKey(key)
        if success then
            verified = true
            keyData = data
            if data.type == "owner" then isOwner = true end
            local levelText = " [" .. data.type:upper() .. "]"
            if data.level then levelText = levelText .. " Lv." .. data.level end
            statusLabel.Text = Lang.verifiedText .. levelText
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.wait(1.5)
            gui:Destroy()
        else
            local errorMsg = Lang.invalid
            if msg == "KEY_EXPIRADA" then errorMsg = "⏰ KEY EXPIRADA"
            elseif msg == "FORMATO_INVALIDO" then errorMsg = "❌ FORMATO INVALIDO" end
            statusLabel.Text = errorMsg
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            verifyBtn.Enabled = true
        end
    end)
    
    local timeout = 120
    while not verified and timeout > 0 do
        task.wait(1)
        timeout = timeout - 1
    end
    if not verified then gui:Destroy() verified = true end
end

-- Funções do Jogo
local function teleportTo(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            task.wait(0.08)
            hrp.CFrame = CFrame.new(pos)
        end
    end)
end

local function findTarget()
    local nearest, shortest = nil, farmConfig.Range
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if obj.Humanoid.Health > 0 and obj ~= player.Character then
                    local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortest then shortest = dist nearest = obj end
                end
            end
        end)
    end
    return nearest
end

local function attackTarget()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes and remotes:FindFirstChild("CommF_") then
            remotes.CommF_:InvokeServer("Click")
        end
    end)
end

local function startFarm()
    while farmEnabled do
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1) return
            end
            local target = findTarget()
            if target then
                currentTarget = target
                local dist = (player.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
                if dist > 15 then teleportTo(target.HumanoidRootPart.Position) end
                attackTarget()
            end
        end)
        task.wait(farmConfig.AttackDelay)
    end
end

local function startGodmode()
    while godmodeEnabled do
        pcall(function()
            if player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
            end
        end)
        task.wait(0.1)
    end
end

local function toggleESP(state)
    if state then
        task.spawn(function()
            while espEnabled do
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                            if obj.Humanoid.Health > 0 and obj ~= player.Character and not espBills[obj] then
                                local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if dist <= farmConfig.Range then
                                    local bill = Instance.new("BillboardGui")
                                    bill.Size = UDim2.new(0, 80, 0, 25)
                                    bill.AlwaysOnTop = true
                                    bill.MaxDistance = farmConfig.Range
                                    local label = Instance.new("TextLabel")
                                    label.Size = UDim2.new(1, 0, 1, 0)
                                    label.BackgroundTransparency = 0.7
                                    label.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    label.TextSize = 11
                                    label.Font = Enum.Font.GothamBold
                                    label.Text = obj.Name .. " ❤" .. math.floor(obj.Humanoid.Health)
                                    label.Parent = bill
                                    bill.Parent = obj.HumanoidRootPart
                                    espBills[obj] = bill
                                end
                            end
                        end
                    end
                    for obj, bill in pairs(espBills) do
                        if not obj.Parent or obj.Humanoid.Health <= 0 then
                            bill:Destroy() espBills[obj] = nil
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    else
        for obj, bill in pairs(espBills) do
            pcall(function() bill:Destroy() end) espBills[obj] = nil
        end
    end
end

local function startFruitSniper()
    local fruits = {"Kitsune-Fruit", "Dragon-Fruit", "Leopard-Fruit", "Dough-Fruit", "Spirit-Fruit", "Venom-Fruit", "Control-Fruit", "Shadow-Fruit", "Rumble-Fruit", "Buddha-Fruit"}
    while fruitSniperEnabled do
        pcall(function()
            for _, name in pairs(fruits) do
                local fruit = Workspace:FindFirstChild(name)
                if fruit and fruit:FindFirstChild("Handle") then
                    teleportTo(fruit.Handle.Position) task.wait(0.3) break
                end
            end
        end)
        task.wait(3)
    end
end

local function startBountyHunter()
    while bountyHunterEnabled do
        pcall(function()
            local best, bestBounty = nil, 0
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local bounty = p.Data and p.Data:FindFirstChild("Bounty") and p.Data.Bounty.Value or 0
                        if bounty > bestBounty then bestBounty = bounty best = p end
                    end)
                end
            end
            if best then teleportTo(best.Character.HumanoidRootPart.Position) attackTarget() end
        end)
        task.wait(5)
    end
end

local function startAutoRaid()
    while autoRaidEnabled do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:find("Raid") and obj:FindFirstChild("TouchInterest") then
                    teleportTo(obj.Position) task.wait(0.5)
                    firetouchinterest(obj, player.Character.HumanoidRootPart, 0)
                    firetouchinterest(obj, player.Character.HumanoidRootPart, 1)
                end
            end
        end)
        task.wait(30)
    end
end

local function startAutoChest()
    while autoChestEnabled do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:find("Chest") and obj:FindFirstChild("TouchInterest") then
                    teleportTo(obj:FindFirstChildOfClass("BasePart").Position) task.wait(0.3)
                    firetouchinterest(obj, player.Character.HumanoidRootPart, 0)
                    firetouchinterest(obj, player.Character.HumanoidRootPart, 1)
                end
            end
        end)
        task.wait(5)
    end
end

local function startAutoHaki()
    while autoHakiEnabled do
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes and remotes:FindFirstChild("CommF_") then
                remotes.CommF_:InvokeServer("ActivateHaki", "Ken")
                remotes.CommF_:InvokeServer("ActivateHaki", "Buso")
            end
        end)
        task.wait(30)
    end
end

local function startAutoBuy()
    while autoBuyEnabled do
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes and remotes:FindFirstChild("CommF_") then
                local items = {"Kitsune", "Dragon", "Leopard", "Dough", "Spirit", "Venom"}
                for _, item in pairs(items) do
                    remotes.CommF_:InvokeServer("BuyItem", item) task.wait(0.5)
                end
            end
        end)
        task.wait(300)
    end
end

local function startAutoHop()
    while autoHopEnabled do
        pcall(function()
            local hasRare = false
            local rareFruits = {"Kitsune-Fruit", "Dragon-Fruit", "Leopard-Fruit"}
            for _, name in pairs(rareFruits) do
                if Workspace:FindFirstChild(name) then hasRare = true break end
            end
            if not hasRare then
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=10"))
                if #servers.data > 0 then
                    TeleportService:TeleportToPlaceInstance(game.GameId, servers.data[math.random(1, #servers.data)].id, player)
                end
            end
        end)
        task.wait(60)
    end
end

local function startAutoBones()
    while autoBonesEnabled do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:find("Bone") and obj:IsA("BasePart") then
                    teleportTo(obj.Position) task.wait(0.2)
                    firetouchinterest(obj, player.Character.HumanoidRootPart, 0)
                    firetouchinterest(obj, player.Character.HumanoidRootPart, 1)
                end
            end
        end)
        task.wait(3)
    end
end

-- Menu
local function createMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusMenu"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 500)
    frame.Position = UDim2.new(0, 10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
    title.TextColor3 = Color3.fromRGB(230, 65, 50)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Text = Lang.title .. (isOwner and " 👑" or "")
    title.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -32)
    scroll.Position = UDim2.new(0, 0, 0, 32)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 900)
    scroll.Parent = frame
    
    local function btn(t, y, h)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.9, 0, 0, h)
        b.Position = UDim2.new(0.05, 0, 0, y)
        b.Text = t
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        return b
    end
    
    local y = 10
    local farmBtn = btn(Lang.farm .. ": " .. Lang.off, y, 36) y = y + 42
    local godBtn = btn(Lang.godmode .. ": " .. Lang.off, y, 36) y = y + 42
    local espBtn = btn(Lang.esp .. ": " .. Lang.off, y, 36) y = y + 42
    local sniperBtn = btn(Lang.sniper .. ": " .. Lang.off, y, 36) y = y + 42
    local bountyBtn = btn(Lang.bounty .. ": " .. Lang.off, y, 36) y = y + 42
    local raidBtn = btn("⚔️ AUTO RAID: " .. Lang.off, y, 36) y = y + 42
    local chestBtn = btn("📦 AUTO CHEST: " .. Lang.off, y, 36) y = y + 42
    local hakiBtn = btn("🔮 AUTO HAKI: " .. Lang.off, y, 36) y = y + 42
    local buyBtn = btn("🛒 AUTO BUY: " .. Lang.off, y, 36) y = y + 42
    local hopBtn = btn("🔄 AUTO HOP: " .. Lang.off, y, 36) y = y + 42
    local bonesBtn = btn("🦴 AUTO BONES: " .. Lang.off, y, 36) y = y + 42
    local tpBtn = btn(Lang.tp, y, 35)
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.9, 0, 0, 18)
    fpsLabel.Position = UDim2.new(0.05, 0, 0, y + 10)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(150, 150, 165)
    fpsLabel.TextSize = 11
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Text = "FPS: -- | TARGET: NONE"
    fpsLabel.Parent = scroll
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 40)
    
    -- Eventos
    farmBtn.MouseButton1Click:Connect(function()
        farmEnabled = not farmEnabled
        farmBtn.Text = Lang.farm .. ": " .. (farmEnabled and Lang.on or Lang.off)
        farmBtn.BackgroundColor3 = farmEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if farmEnabled then task.spawn(startFarm) end
    end)
    
    godBtn.MouseButton1Click:Connect(function()
        godmodeEnabled = not godmodeEnabled
        godBtn.Text = Lang.godmode .. ": " .. (godmodeEnabled and Lang.on or Lang.off)
        godBtn.BackgroundColor3 = godmodeEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if godmodeEnabled then task.spawn(startGodmode) end
    end)
    
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = Lang.esp .. ": " .. (espEnabled and Lang.on or Lang.off)
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        toggleESP(espEnabled)
    end)
    
    sniperBtn.MouseButton1Click:Connect(function()
        fruitSniperEnabled = not fruitSniperEnabled
        sniperBtn.Text = Lang.sniper .. ": " .. (fruitSniperEnabled and Lang.on or Lang.off)
        sniperBtn.BackgroundColor3 = fruitSniperEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if fruitSniperEnabled then task.spawn(startFruitSniper) end
    end)
    
    bountyBtn.MouseButton1Click:Connect(function()
        bountyHunterEnabled = not bountyHunterEnabled
        bountyBtn.Text = Lang.bounty .. ": " .. (bountyHunterEnabled and Lang.on or Lang.off)
        bountyBtn.BackgroundColor3 = bountyHunterEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if bountyHunterEnabled then task.spawn(startBountyHunter) end
    end)
    
    raidBtn.MouseButton1Click:Connect(function()
        autoRaidEnabled = not autoRaidEnabled
        raidBtn.Text = "⚔️ AUTO RAID: " .. (autoRaidEnabled and Lang.on or Lang.off)
        raidBtn.BackgroundColor3 = autoRaidEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoRaidEnabled then task.spawn(startAutoRaid) end
    end)
    
    chestBtn.MouseButton1Click:Connect(function()
        autoChestEnabled = not autoChestEnabled
        chestBtn.Text = "📦 AUTO CHEST: " .. (autoChestEnabled and Lang.on or Lang.off)
        chestBtn.BackgroundColor3 = autoChestEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoChestEnabled then task.spawn(startAutoChest) end
    end)
    
    hakiBtn.MouseButton1Click:Connect(function()
        autoHakiEnabled = not autoHakiEnabled
        hakiBtn.Text = "🔮 AUTO HAKI: " .. (autoHakiEnabled and Lang.on or Lang.off)
        hakiBtn.BackgroundColor3 = autoHakiEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoHakiEnabled then task.spawn(startAutoHaki) end
    end)
    
    buyBtn.MouseButton1Click:Connect(function()
        autoBuyEnabled = not autoBuyEnabled
        buyBtn.Text = "🛒 AUTO BUY: " .. (autoBuyEnabled and Lang.on or Lang.off)
        buyBtn.BackgroundColor3 = autoBuyEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoBuyEnabled then task.spawn(startAutoBuy) end
    end)
    
    hopBtn.MouseButton1Click:Connect(function()
        autoHopEnabled = not autoHopEnabled
        hopBtn.Text = "🔄 AUTO HOP: " .. (autoHopEnabled and Lang.on or Lang.off)
        hopBtn.BackgroundColor3 = autoHopEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoHopEnabled then task.spawn(startAutoHop) end
    end)
    
    bonesBtn.MouseButton1Click:Connect(function()
        autoBonesEnabled = not autoBonesEnabled
        bonesBtn.Text = "🦴 AUTO BONES: " .. (autoBonesEnabled and Lang.on or Lang.off)
        bonesBtn.BackgroundColor3 = autoBonesEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if autoBonesEnabled then task.spawn(startAutoBones) end
    end)
    
    tpBtn.MouseButton1Click:Connect(function()
        if currentTarget then teleportTo(currentTarget.HumanoidRootPart.Position) end
    end)
    
    local fc, lt = 0, tick()
    RunService.RenderStepped:Connect(function()
        fc = fc + 1
        local nw = tick()
        if nw - lt >= 1 then
            fpsLabel.Text = "FPS: " .. fc .. " | TARGET: " .. (currentTarget and currentTarget.Name or "NONE")
            fc = 0 lt = nw
        end
    end)
    
    local drag, ds, sp = false, nil, nil
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true ds = i.Position sp = frame.Position
        end
    end)
    frame.InputEnded:Connect(function() drag = false end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement and drag then
            local delta = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
end

-- Hotkey END
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.End then
        farmEnabled = false godmodeEnabled = false espEnabled = false
        fruitSniperEnabled = false bountyHunterEnabled = false
        autoRaidEnabled = false autoChestEnabled = false autoHakiEnabled = false
        autoBuyEnabled = false autoHopEnabled = false autoBonesEnabled = false
        for obj, bill in pairs(espBills) do pcall(function() bill:Destroy() end) espBills[obj] = nil end
        StarterGui:SetCore("SendNotification", {Title = "NEXUS", Text = Lang.allOff, Duration = 2})
    end
end)

-- Start
createVerifyGUI()
createMenu()
print("NEXUS v7.0 - Loaded")
