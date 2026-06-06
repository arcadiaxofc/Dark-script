-- ============================================================
-- NEXUS 99 NOITES - CORE (Sistemas)
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

game.Loaded:Wait()
repeat task.wait(0.3) until Player.Character
task.wait(1)

local GameRemotes = {}
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        GameRemotes[obj.Name] = obj
    end
end

local DamageRemote = GameRemotes["DamagePlayer"] or GameRemotes["DamageEnemy"] or GameRemotes["DamageEvent"]

local function Tap()
    pcall(function()
        UIS.TouchStarted:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.Begin, Position = Vector3.new(200, 300, 0)}, false)
        task.wait(0.05)
        UIS.TouchEnded:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.End, Position = Vector3.new(200, 300, 0)}, false)
    end)
end

local function Hold(d)
    pcall(function()
        UIS.TouchStarted:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.Begin, Position = Vector3.new(200, 300, 0)}, false)
        task.wait(d or 3)
        UIS.TouchEnded:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.End, Position = Vector3.new(200, 300, 0)}, false)
    end)
end

local function TP(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

local function FindNearest(keywords)
    local myPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    local closest = nil
    local closestDist = _G.Range or 50
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            local found = false
            for _, kw in ipairs(keywords) do
                if name:find(kw:lower()) then found = true break end
            end
            if found then
                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                if pos then
                    local dist = (pos - myPos.Position).Magnitude
                    if dist < closestDist then closestDist = dist; closest = obj end
                end
            end
        end
    end
    return closest
end

local function RemoteAttack()
    if DamageRemote then
        pcall(function() DamageRemote:FireServer(-math.huge) end)
    end
end

-- ESP
local ESPObjects = {}
task.spawn(function()
    while task.wait(2) do
        for _, obj in ipairs(ESPObjects) do pcall(function() if obj and obj.Parent then obj:Destroy() end end) end
        ESPObjects = {}
        if not (_G.ESP_Enabled or false) then continue end
        pcall(function()
            local count = 0
            if _G.ESP_Players then
                for _, p in ipairs(Players:GetPlayers()) do
                    if count >= 15 then break end
                    if p == Player then continue end
                    local char = p.Character; if not char then continue end
                    local head = char:FindFirstChild("Head"); if not head then continue end
                    local bg = Instance.new("BillboardGui"); bg.Adornee = head; bg.Size = UDim2.new(0, 80, 0, 16); bg.AlwaysOnTop = true
                    bg.MaxDistance = _G.ESP_Range or 200; bg.StudsOffset = Vector3.new(0, 2, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255, 0, 0); label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = p.DisplayName
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
            if _G.ESP_Items then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if count >= 15 then break end
                    if not obj:IsA("BasePart") then continue end
                    local name = obj.Name:lower()
                    local isItem = name:find("meat") or name:find("wood") or name:find("gem") or name:find("carne") or name:find("madeira") or name:find("gema") or name:find("drop") or name:find("item") or name:find("carrot") or name:find("cenoura") or name:find("skin") or name:find("leather")
                    if not isItem then continue end
                    local bg = Instance.new("BillboardGui"); bg.Adornee = obj; bg.Size = UDim2.new(0, 60, 0, 14); bg.AlwaysOnTop = true
                    bg.MaxDistance = _G.ESP_Range or 200; bg.StudsOffset = Vector3.new(0, 2, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255, 200, 0); label.TextColor3 = Color3.new(0, 0, 0)
                    label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = obj.Name
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
            if _G.ESP_Enemies then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if count >= 15 then break end
                    if not obj:IsA("Model") then continue end
                    local name = obj.Name:lower()
                    local isEnemy = name:find("night") or name:find("deer") or name:find("wolf") or name:find("bear") or name:find("spirit") or name:find("monster") or name:find("cervo") or name:find("lobo") or name:find("urso")
                    if not isEnemy then continue end
                    local head = obj:FindFirstChild("Head"); if not head then continue end
                    local bg = Instance.new("BillboardGui"); bg.Adornee = head; bg.Size = UDim2.new(0, 80, 0, 16); bg.AlwaysOnTop = true
                    bg.MaxDistance = _G.ESP_Range or 200; bg.StudsOffset = Vector3.new(0, 3, 0); bg.Parent = CoreGui
                    local label = Instance.new("TextLabel", bg); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(255, 50, 50); label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextSize = 8; label.Font = Enum.Font.GothamBold; label.Text = obj.Name
                    table.insert(ESPObjects, bg); count = count + 1
                end
            end
        end)
    end
end)

-- AUTO WOOD
task.spawn(function()
    while task.wait(0.3) do
        if not (_G.AutoWood or false) then continue end
        pcall(function()
            local tree = FindNearest({"tree", "wood", "arvore", "madeira", "log", "tronco"})
            if tree then
                local pos = tree:IsA("Model") and tree:GetPivot().Position or tree.Position
                if pos then TP(pos); task.wait(0.5); Hold(3) end
            end
        end)
    end
end)

-- AUTO FOOD
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoFood or false) then continue end
        pcall(function()
            local animal = FindNearest({"deer", "boar", "rabbit", "bird", "animal", "veado", "coelho"})
            if animal then
                local pos = animal:IsA("Model") and animal:GetPivot().Position or animal.Position
                if pos then TP(pos); task.wait(0.3); for i = 1, 5 do Tap(); task.wait(0.2) end end
            end
        end)
    end
end)

-- AUTO GEMS
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoGems or false) then continue end
        pcall(function()
            local gem = FindNearest({"gem", "diamond", "crystal", "gema", "diamante"})
            if gem then
                local pos = gem:IsA("Model") and gem:GetPivot().Position or gem.Position
                if pos then TP(pos); task.wait(0.3); Hold(2) end
            end
        end)
    end
end)

-- AUTO COLLECT
task.spawn(function()
    while task.wait(1) do
        if not (_G.AutoCollect or false) then continue end
        pcall(function()
            local loot = FindNearest({"drop", "item", "meat", "wood", "gem", "carne", "madeira", "carrot", "cenoura"})
            if loot then
                local pos = loot:IsA("Model") and loot:GetPivot().Position or loot.Position
                if pos then TP(pos); task.wait(0.3); Tap() end
            end
        end)
    end
end)

-- AUTO FIRE
task.spawn(function()
    while task.wait(5) do
        if not (_G.AutoFire or false) then continue end
        pcall(function()
            local fire = FindNearest({"fire", "campfire", "fogueira", "bonfire"})
            if fire then
                local pos = fire:IsA("Model") and fire:GetPivot().Position or fire.Position
                if pos then TP(pos); task.wait(0.5); Tap(); task.wait(0.5); Tap() end
            end
        end)
    end
end)

-- AUTO DEFENSE
task.spawn(function()
    while task.wait(0.3) do
        if not (_G.AutoDefense or false) then continue end
        pcall(function()
            local enemy = FindNearest({"night", "deer", "wolf", "bear", "spirit", "monster", "cervo", "lobo", "urso"})
            if enemy then
                local pos = enemy:IsA("Model") and enemy:GetPivot().Position or enemy.Position
                if pos then
                    local myPos = Player.Character.HumanoidRootPart.Position
                    local dist = (pos - myPos).Magnitude
                    if dist < 30 then RemoteAttack(); for i = 1, 5 do Tap(); task.wait(0.1) end end
                end
            end
        end)
    end
end)

-- AUTO KILL
task.spawn(function()
    while task.wait(0.2) do
        if not (_G.AutoKill or false) then continue end
        pcall(function()
            local enemy = FindNearest({"deer", "wolf", "bear", "animal", "veado", "lobo", "urso", "player"})
            if enemy then
                local pos = enemy:IsA("Model") and enemy:GetPivot().Position or enemy.Position
                if pos then TP(pos); task.wait(0.2); RemoteAttack(); for i = 1, 10 do Tap(); task.wait(0.08) end end
            end
        end)
    end
end)

-- SMART NIGHT
task.spawn(function()
    while task.wait(1) do
        if not (_G.SmartNight or false) then continue end
        local hour = Lighting.ClockTime
        local isNight = hour > 18 or hour < 6
        if isNight then
            local fire = FindNearest({"fire", "campfire", "fogueira", "bonfire"})
            if fire then
                local firePos = fire:IsA("Model") and fire:GetPivot().Position or fire.Position
                local myPos = Player.Character.HumanoidRootPart.Position
                if (firePos - myPos).Magnitude > 20 then TP(firePos) end
            end
        end
    end
end)
