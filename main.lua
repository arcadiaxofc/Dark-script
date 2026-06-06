-- ============================================================
-- NEXUS - MAIN (So carrega UI e injeta o CORE)
-- ============================================================

-- Variaveis globais
_G.AutoWood = false
_G.AutoFood = false
_G.AutoGems = false
_G.AutoFire = false
_G.AutoCollect = false
_G.AutoDefense = false
_G.AutoKill = false
_G.SmartNight = false
_G.Range = 50
_G.ESP_Enabled = false
_G.ESP_Players = false
_G.ESP_Items = false
_G.ESP_Enemies = false
_G.ESP_Range = 200

-- Carregar UI
pcall(function()
    local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()
    if DiscordLib then
        local win = DiscordLib:Window("NEXUS 99 NOITES")
        local serv = win:Server("99 Noites", "")
        
        local farmCh = serv:Channel("Farm")
        farmCh:Toggle("Madeira", false, function(v) _G.AutoWood = v end)
        farmCh:Toggle("Comida", false, function(v) _G.AutoFood = v end)
        farmCh:Toggle("Gemas", false, function(v) _G.AutoGems = v end)
        farmCh:Toggle("Coletar", false, function(v) _G.AutoCollect = v end)
        farmCh:Toggle("Fogueira", false, function(v) _G.AutoFire = v end)
        farmCh:Toggle("Defesa", false, function(v) _G.AutoDefense = v end)
        farmCh:Toggle("Mata Tudo", false, function(v) _G.AutoKill = v end)
        farmCh:Toggle("Noite Segura", false, function(v) _G.SmartNight = v end)
        
        local espCh = serv:Channel("ESP")
        espCh:Toggle("ESP Ligado", false, function(v) _G.ESP_Enabled = v end)
        espCh:Toggle("ESP Players", false, function(v) _G.ESP_Players = v end)
        espCh:Toggle("ESP Itens", false, function(v) _G.ESP_Items = v end)
        espCh:Toggle("ESP Inimigos", false, function(v) _G.ESP_Enemies = v end)
        
        local stopCh = serv:Channel("Controle")
        stopCh:Button("PARAR TUDO", function()
            _G.AutoWood = false; _G.AutoFood = false; _G.AutoGems = false
            _G.AutoCollect = false; _G.AutoFire = false; _G.AutoDefense = false
            _G.AutoKill = false; _G.SmartNight = false; _G.ESP_Enabled = false
            DiscordLib:Notification("NEXUS", "Tudo parado!", "OK")
        end)
        
        DiscordLib:Notification("NEXUS 99 NOITES", "Script carregado!", "OK")
    end
end)

-- Carregar CORE do GitHub
local coreCode = game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/core99.lua")
if coreCode then
    local folder = Instance.new("Folder")
    folder.Name = "NexusCore"
    folder.Parent = game:GetService("Workspace")
    
    local script = Instance.new("LocalScript")
    script.Name = "CoreHandler"
    script.Source = coreCode
    script.Parent = folder
    script.Enabled = true
    
    print("[NEXUS] Core injetado!")
end
