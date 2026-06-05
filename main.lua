-- TESTE DE DIAGNÓSTICO - Blox Fruits 2025
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

print("=== DIAGNÓSTICO RÁPIDO ===")
print("Level:", Player.Data and Player.Data.Level and Player.Data.Level.Value or "Não detectado")

-- Verificar se Enemies existe
local enemies = Workspace:FindFirstChild("Enemies")
if enemies then
    print("✅ Pasta 'Enemies' encontrada!")
    print("Mobs próximos:")
    local count = 0
    for _, mob in pairs(enemies:GetChildren()) do
        if count < 5 then
            print("  -", mob.Name)
            count = count + 1
        end
    end
else
    print("❌ Pasta 'Enemies' NÃO encontrada!")
    print("Procurando mobs no Workspace...")
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if count >= 5 then break end
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj.Name ~= "" and not obj.Name:find("Quest") then
                print("  -", obj.Name)
                count = count + 1
            end
        end
    end
end

-- Verificar Remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if remotes then
    print("✅ Remotes encontrado!")
    if remotes:FindFirstChild("CommF_") then
        print("✅ CommF_ encontrado!")
    else
        print("❌ CommF_ NÃO encontrado!")
        print("Remotes disponíveis:")
        for _, remote in pairs(remotes:GetChildren()) do
            print("  -", remote.Name)
        end
    end
end

-- Verificar Quest GUI
local questGui = Player.PlayerGui:FindFirstChild("Main")
if questGui then
    questGui = questGui:FindFirstChild("Quest")
    if questGui then
        print("✅ Quest GUI encontrada!")
        print("  Visível:", questGui.Visible)
    else
        print("❌ Quest NÃO encontrada no Main!")
    end
else
    print("❌ Main NÃO encontrado no PlayerGui!")
    print("GUIs disponíveis:")
    for _, gui in pairs(Player.PlayerGui:GetChildren()) do
        print("  -", gui.Name)
    end
end

print("=== FIM DO DIAGNÓSTICO ===")
