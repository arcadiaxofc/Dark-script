-- ============================================================
-- NEXUS ULTIMATE - MAIN.LUA COMPLETO
-- ============================================================

-- 1. CARREGAR UI
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/arcadiaxofc/Dark-script/refs/heads/main/ui.lua"))()
if not NexusUI then return end

-- 2. ESPERAR JOGO
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait(0.5) until game.Players.LocalPlayer.Character
task.wait(2)

-- 3. SERVIÇOS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- 4. BYPASS + OTIMIZADOR
pcall(function()
    local mt = getrawmetatable(game)
    local oi, on = mt.__index, mt.__newindex
    mt.__index = function(s,k) if k == "BusyLock" or k == "Busy" then return nil end return oi(s,k) end
    mt.__newindex = function(s,k,v) if k == "BusyLock" or k == "Busy" then return end return on(s,k,v) end
end)
pcall(function() settings().Rendering.QualityLevel = 1 Lighting.GlobalShadows = false Lighting.Brightness = 2 Lighting.FogEnd = 99999 end)

-- 5. NOTIFICAÇÃO
local function Notify(t, txt, d)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "NEXUS", Text = txt or "", Duration = d or 3}) end)
end

-- 6. FLAGS
local Flags = {
    AutoFarm = false, AutoQuest = true, KillAura = false, GodMode = false,
    AutoBoss = false, AllBosses = false, BossName = "",
    AutoHaki = false, AutoStats = false, AutoV4 = false, AutoRace = false,
    AutoStore = false, AutoRoll = false, AutoSpawn = false,
    FruitSniper = false, FragmentFarm = false, BonesFarm = false, BountyHunt = false,
    ESP_Players = false, ESP_Fruits = false, ESP_Chests = false, ESP_Bosses = false,
    Aimlock = false, Walkspeed = false, Jumpspeed = false, NoClip = false, Fly = false,
    StatsToUpgrade = "Melee", StatsAmount = 3,
    WalkspeedValue = 100, JumpspeedValue = 150,
    Range = 300, Kills = 0, Level = 1, Sea = 1,
}

-- 7. FUNÇÕES UTILITÁRIAS
local function SafeCall(f, r) r = r or 2 for i = 1, r do local s, res = pcall(f) if s then return res end task.wait(0.2) end return nil end
local function WaitMob(m) if not m or not m.Parent then return false end if not m:IsA("Model") then return false end local h = m:FindFirstChild("Humanoid") if not h then task.wait(0.15) h = m:FindFirstChild("Humanoid") end local hrp = m:FindFirstChild("HumanoidRootPart") if not hrp then task.wait(0.15) hrp = m:FindFirstChild("HumanoidRootPart") end return h and hrp and h.Health > 0 end
local function GetRemote() local rs = ReplicatedStorage:FindFirstChild("Remotes") if rs then return rs:FindFirstChild("CommF") or rs:FindFirstChild("CommF_") end return nil end
local function TP(pos) SafeCall(function() local c = Player.Character if not c then return end local h = c:FindFirstChild("HumanoidRootPart") if not h then return end h.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end) end
local function Attack() SafeCall(function() VirtualUser:CaptureController() VirtualUser:Button1Down(Vector2.new(0,0)) task.wait(0.02) VirtualUser:Button1Up(Vector2.new(0,0)) Flags.Kills = Flags.Kills + 1 end) end
local function GetEnemies(dist) local e = {} local c = Player.Character if not c then return e end local m = c:FindFirstChild("HumanoidRootPart") if not m then return e end local f = Workspace:FindFirstChild("Enemies") if not f then return e end for _, o in pairs(f:GetChildren()) do if #e >= 10 then break end if WaitMob(o) then local d = (o.HumanoidRootPart.Position - m.Position).Magnitude if d <= dist then table.insert(e, {M = o, H = o.HumanoidRootPart, D = d}) end end end table.sort(e, function(a,b) return a.D < b.D end) return e end
local function FindBoss(n) for _, fn in ipairs({"Bosses","Enemies"}) do local f = Workspace:FindFirstChild(fn) if f then for _, m in pairs(f:GetChildren()) do if m:IsA("Model") and m.Name:find(n) and WaitMob(m) then return m end end end end return nil end
local function GetNPC() local f = Workspace:FindFirstChild("NPCs") if f then for _, m in pairs(f:GetChildren()) do if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then if m:FindFirstChild("Talk") or m.Name:find("Quest") then return m end end end end return nil end
local function OpenShop(t) SafeCall(function() local r = GetRemote() if r then r:InvokeServer("OpenShop",t) Notify("🛍️",t,2) end end) end

-- 8. DADOS DO JOGO (SEA 1-4)
local GameData = {
    {Sea=1,MinLevel=0,MaxLevel=700,
     Islands={{"Pirate Starter",Vector3.new(1289,11,4191)},{"Jungle",Vector3.new(-1250,15,3850)},{"Desert",Vector3.new(966,10,1100)},{"Frozen Village",Vector3.new(1150,25,4350)},{"Marine Fortress",Vector3.new(-1500,10,5300)},{"Skylands",Vector3.new(-4850,750,1950)},{"Prison",Vector3.new(-5400,15,-1700)},{"Colosseum",Vector3.new(-3560,240,-80)},{"Magma Village",Vector3.new(-3420,10,-2700)},{"Underwater City",Vector3.new(5500,-50,2000)},{"Fountain City",Vector3.new(4500,50,1200)}},
     Bosses={"Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Warden","Chief Warden","Saber Expert","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral"},
     Mobs={{L=0,M="Bandit [Lv. 5]",Q="BanditQuest1",QL=1,N=CFrame.new(1062.64,16.51,1546.55)},{L=10,M="Monkey [Lv. 14]",Q="JungleQuest",QL=1,N=CFrame.new(-1615.18,36.85,150.80)},{L=20,M="Gorilla [Lv. 20]",Q="JungleQuest",QL=2,N=CFrame.new(-1615.18,36.85,150.80)},{L=30,M="Pirate [Lv. 35]",Q="BuggyQuest1",QL=1,N=CFrame.new(-1146.42,4.75,3818.50)},{L=40,M="Brute [Lv. 45]",Q="BuggyQuest1",QL=2,N=CFrame.new(-1146.42,4.75,3818.50)},{L=60,M="Desert Bandit [Lv. 60]",Q="DesertQuest",QL=1,N=CFrame.new(1094.32,6.56,4231.63)},{L=80,M="Desert Officer [Lv. 70]",Q="DesertQuest",QL=2,N=CFrame.new(1094.32,6.56,4231.63)},{L=100,M="Snow Bandit [Lv. 100]",Q="SnowQuest",QL=1,N=CFrame.new(1100.36,5.29,-1151.54)},{L=120,M="Snowman [Lv. 120]",Q="SnowQuest",QL=2,N=CFrame.new(1100.36,5.29,-1151.54)},{L=150,M="Chief Petty Officer [Lv. 150]",Q="MarineQuest2",QL=1,N=CFrame.new(-2896.68,41.48,2009.27)},{L=175,M="Sky Bandit [Lv. 175]",Q="SkyQuest",QL=1,N=CFrame.new(-4967.83,717.67,-2623.84)},{L=225,M="Toga Warrior [Lv. 225]",Q="ColosseumQuest",QL=1,N=CFrame.new(-1541.08,7.38,-2987.40)},{L=300,M="Military Soldier [Lv. 300]",Q="MagmaQuest",QL=1,N=CFrame.new(-5248.27,8.69,8452.89)},{L=375,M="Fishman Warrior [Lv. 375]",Q="FishmanQuest",QL=1,N=CFrame.new(61135.29,18.47,1597.68)},{L=450,M="Fishman Commando [Lv. 450]",Q="FishmanQuest",QL=2,N=CFrame.new(61135.29,18.47,1597.68)},{L=525,M="Fishman Lord [Lv. 525]",Q="FishmanQuest",QL=3,N=CFrame.new(61135.29,18.47,1597.68)},{L=600,M="Pirate [Lv. 600]",Q="PiratePortQuest",QL=1,N=CFrame.new(-3000,20,4000)}}},
    {Sea=2,MinLevel=700,MaxLevel=1500,
     Islands={{"Kingdom of Rose",Vector3.new(-1400,10,-1400)},{"Green Zone",Vector3.new(6200,80,2500)},{"Ice Castle",Vector3.new(7200,100,3500)},{"Forgotten Island",Vector3.new(8500,120,4500)},{"Cafe",Vector3.new(-570,310,-1220)}},
     Bosses={"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper"},
     Mobs={{L=700,M="Pirate Millionaire [Lv. 700]",Q="PiratePortQuest",QL=2,N=CFrame.new(-3000,20,4000)},{L=800,M="Pistol Billionaire [Lv. 800]",Q="PiratePortQuest",QL=3,N=CFrame.new(-3000,20,4000)},{L=875,M="Dragon Crew Warrior [Lv. 875]",Q="DragonCrewQuest",QL=1,N=CFrame.new(-5000,50,-2000)},{L=950,M="Dragon Crew Archer [Lv. 950]",Q="DragonCrewQuest",QL=2,N=CFrame.new(-5000,50,-2000)},{L=1050,M="Marine Lieutenant [Lv. 1050]",Q="MarineTreeQuest",QL=1,N=CFrame.new(-2500,30,-3500)},{L=1150,M="Marine Captain [Lv. 1150]",Q="MarineTreeQuest",QL=2,N=CFrame.new(-2500,30,-3500)},{L=1250,M="Lab Subordinate [Lv. 1250]",Q="LabQuest",QL=1,N=CFrame.new(-6000,20,-4000)},{L=1350,M="Horned Warrior [Lv. 1350]",Q="LabQuest",QL=2,N=CFrame.new(-6000,20,-4000)},{L=1450,M="Arctic Warrior [Lv. 1450]",Q="IceCastleQuest",QL=1,N=CFrame.new(7200,100,3500)}}},
    {Sea=3,MinLevel=1500,MaxLevel=2600,
     Islands={{"Port Town",Vector3.new(7200,100,3500)},{"Hydra Island",Vector3.new(6200,80,2500)},{"Great Tree",Vector3.new(8500,120,4500)},{"Castle on the Sea",Vector3.new(4500,50,1200)},{"Haunted Castle",Vector3.new(9800,60,5500)},{"Dark Arena",Vector3.new(10500,100,6000)},{"Floating Turtle",Vector3.new(11200,90,6500)}},
     Bosses={"Cake Prince","Dough King","Soul Reaper","Rip Indra","Darkbeard","Stone","Island Empress","Hydra","Leviathan"},
     Mobs={{L=1500,M="Snow Lurker [Lv. 1550]",Q="IceCastleQuest",QL=2,N=CFrame.new(7200,100,3500)},{L=1650,M="Turtle Guardian [Lv. 1650]",Q="TurtleQuest",QL=1,N=CFrame.new(11200,90,6500)},{L=1750,M="Turtle Soldier [Lv. 1750]",Q="TurtleQuest",QL=2,N=CFrame.new(11200,90,6500)},{L=1850,M="Forest Pirate [Lv. 1850]",Q="ForestQuest",QL=1,N=CFrame.new(-8500,50,-5000)},{L=1950,M="Mythological Pirate [Lv. 1950]",Q="ForestQuest",QL=2,N=CFrame.new(-8500,50,-5000)},{L=2050,M="Jungle Pirate [Lv. 2050]",Q="JungleQuest3",QL=1,N=CFrame.new(-7000,30,-6000)},{L=2150,M="Muscle Pirate [Lv. 2150]",Q="JungleQuest3",QL=2,N=CFrame.new(-7000,30,-6000)},{L=2250,M="Demon Pirate [Lv. 2250]",Q="DemonQuest",QL=1,N=CFrame.new(-9000,40,-7000)},{L=2350,M="Dragon Pirate [Lv. 2350]",Q="DragonQuest",QL=1,N=CFrame.new(-10000,50,-8000)},{L=2450,M="God Pirate [Lv. 2450]",Q="GodQuest",QL=1,N=CFrame.new(-11000,60,-9000)}}},
    {Sea=4,MinLevel=2600,MaxLevel=9999,Islands={},Bosses={},Mobs={}},
}

-- 9. SISTEMA DE SEA
local function UpdateSea()
    SafeCall(function()
        local d = Player:FindFirstChild("Data")
        if d and d:FindFirstChild("Level") then
            Flags.Level = d.Level.Value
            if Flags.Level <= 700 then Flags.Sea = 1
            elseif Flags.Level <= 1500 then Flags.Sea = 2
            elseif Flags.Level <= 2600 then Flags.Sea = 3
            else Flags.Sea = 4 end
        end
    end)
end
local function GetSea() for _,s in ipairs(GameData) do if s.Sea==Flags.Sea then return s end end return GameData[1] end
local function GetMob() local s=GetSea() local m=s.Mobs[1] UpdateSea() for _,v in ipairs(s.Mobs) do if Flags.Level>=v.L then m=v end end return m end

-- 10. AUTO FARM (COM QUEST)
task.spawn(function() while task.wait(0.4) do if not Flags.AutoFarm then continue end SafeCall(function() UpdateSea() local mob=GetMob()
    if Flags.AutoQuest then local npc=GetNPC() if npc then local q=Player.PlayerGui:FindFirstChild("Main") if q then q=q:FindFirstChild("Quest") if q and not q.Visible then local hrp=npc:FindFirstChild("HumanoidRootPart") if hrp then TP(hrp.Position) task.wait(0.5) local r=GetRemote() if r then r:InvokeServer("StartQuest",mob.Q,mob.QL) end end end end end end
    local enemies=GetEnemies(Flags.Range) if #enemies>0 then local t=enemies[1] if t.D>15 then TP(t.H.Position) end task.wait(0.1) Attack() end end) end end)

-- 11. AUTO BOSS
task.spawn(function() while task.wait(1.5) do if not Flags.AutoBoss then continue end SafeCall(function() UpdateSea() local s=GetSea() local bosses={} if Flags.AllBosses then bosses=s.Bosses elseif Flags.BossName~="" then bosses={Flags.BossName} end for _,bn in ipairs(bosses) do local boss=FindBoss(bn) if boss then local h=boss:FindFirstChild("HumanoidRootPart") if h then TP(h.Position) task.wait(0.2) for _=1,8 do Attack() task.wait(0.1) end end end end end) end end)

-- 12. OUTROS SISTEMAS (COMPACTADOS)
task.spawn(function() while task.wait(0.15) do if Flags.KillAura and #GetEnemies(20)>0 then Attack() end end end)
task.spawn(function() while task.wait(0.3) do if Flags.GodMode then SafeCall(function() local c=Player.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h and h.Health>0 then h.Health=h.MaxHealth end end end) end end end)
task.spawn(function() while task.wait(0.5) do if Flags.Walkspeed then SafeCall(function() local c=Player.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=Flags.WalkspeedValue end end end) end end end)
task.spawn(function() while task.wait(0.5) do if Flags.Jumpspeed then SafeCall(function() local c=Player.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=Flags.JumpspeedValue end end end) end end end)
task.spawn(function() while task.wait(0.5) do if Flags.NoClip then SafeCall(function() local c=Player.Character if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end end end)
task.spawn(function() while task.wait(1) do if Flags.Fly then SafeCall(function() local c=Player.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end end) end end end)
task.spawn(function() while task.wait(4) do if Flags.FruitSniper then SafeCall(function() for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("BasePart") and o.Name:find("Fruit") and o.Parent and o.Parent:FindFirstChild("Handle") then TP(o.Position) task.wait(0.3) break end end end) end end end)
task.spawn(function() while task.wait(5) do if Flags.AutoStore then SafeCall(function() local d=Player:FindFirstChild("Data") if d and d:FindFirstChild("Fruit") then local f=d.Fruit.Value if f and f~="" then local r=GetRemote() if r then r:InvokeServer("StoreFruit",f) end end end end) end end end)
task.spawn(function() while task.wait(15) do if Flags.AutoRoll then SafeCall(function() local r=GetRemote() if r then r:InvokeServer("FruitGacha","Roll") end end) end end end)
task.spawn(function() while task.wait(60) do if Flags.AutoSpawn then SafeCall(function() local r=GetRemote() if r then r:InvokeServer("Cousin","Buy") end end) end end end)
task.spawn(function() while task.wait(60) do if Flags.FragmentFarm then SafeCall(function() local r=GetRemote() if r then r:InvokeServer("AddFragments",500) end end) end end end)
task.spawn(function() while task.wait(30) do if Flags.BonesFarm then SafeCall(function() local r=GetRemote() if r then r:InvokeServer("AddBones",50) end end) end end end)
task.spawn(function() while task.wait(120) do if Flags.AutoHaki then SafeCall(function() local r=GetRemote() if r then r:InvokeServer("ActivateHaki","Ken") task.wait(0.3) r:InvokeServer("ActivateHaki","Observation") end end) end end end)
task.spawn(function() while task.wait(30) do if Flags.AutoStats then SafeCall(function() local r=GetRemote() if r then for _=1,Flags.StatsAmount do r:InvokeServer("AddPoint",Flags.StatsToUpgrade,1) end end end) end end end)
task.spawn(function() while task.wait(180) do if Flags.AutoV4 then SafeCall(function() local r=GetRemote() if r then r:InvokeServer("RaceV4","Start") end end) end end end)
task.spawn(function() while task.wait(180) do if Flags.AutoRace then SafeCall(function() local r=GetRemote() if r then r:InvokeServer("RaceAwakening","Start") end end) end end end)
task.spawn(function() while task.wait(5) do if Flags.BountyHunt then SafeCall(function() local best,bd=nil,math.huge local c=Player.Character if not c then return end local m=c:FindFirstChild("HumanoidRootPart") if not m then return end for _,p in pairs(Players:GetPlayers()) do if p~=Player and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart") if h then local d=(h.Position-m.Position).Magnitude if d<Flags.Range and d<bd then bd=d best=p end end end end if best and best.Character then local h=best.Character:FindFirstChild("HumanoidRootPart") if h then TP(h.Position) task.wait(0.2) for _=1,5 do Attack() task.wait(0.08) end end end end) end end end)
task.spawn(function() local esp={} while task.wait(2) do for _,o in ipairs(esp) do SafeCall(function() if o and o.Parent then o:Destroy() end end) end esp={} if not(Flags.ESP_Players or Flags.ESP_Fruits or Flags.ESP_Chests or Flags.ESP_Bosses) then continue end SafeCall(function() local c=0 for _,o in pairs(Workspace:GetDescendants()) do if c>=15 then break end if o:IsA("Model") and o:FindFirstChild("Head") then local s,cl=false,Color3.fromRGB(255,255,255) if Flags.ESP_Players then local p=Players:GetPlayerFromCharacter(o) if p and p~=Player then s=true cl=Color3.fromRGB(255,0,0) end end if Flags.ESP_Fruits and o.Name:lower():find("fruit") then s=true cl=Color3.fromRGB(255,0,255) end if Flags.ESP_Chests and o.Name:lower():find("chest") then s=true cl=Color3.fromRGB(255,215,0) end if Flags.ESP_Bosses then local h=o:FindFirstChild("Humanoid") if h and h.MaxHealth>5000 then s=true cl=Color3.fromRGB(255,50,50) end end if s then SafeCall(function() local b=Instance.new("BillboardGui") b.Adornee=o.Head b.Size=UDim2.new(0,70,0,16) b.AlwaysOnTop=true b.MaxDistance=Flags.Range b.Parent=CoreGui local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=0.7 l.BackgroundColor3=cl l.TextColor3=Color3.new(1,1,1) l.TextSize=7 l.Font=Enum.Font.GothamBold l.Text=o.Name table.insert(esp,b) c=c+1 task.delay(3,function() SafeCall(function() if b and b.Parent then b:Destroy() end end) end) end) end end end end) end end)
task.spawn(function() while task.wait(0.05) do if Flags.Aimlock then SafeCall(function() local e=GetEnemies(Flags.Range) if #e>0 then Camera.CFrame=CFrame.new(Camera.CFrame.Position,e[1].H.Position) end end) end end end)

-- 28. ANTI-AFK
Player.Idled:Connect(function() SafeCall(function() VirtualUser:CaptureController() VirtualUser:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.1) VirtualUser:Button2Up(Vector2.new(0,0),Camera.CFrame) end) end)

-- ============================================================
-- 29. CRIAR UI
-- ============================================================
local win = NexusUI:CreateWindow({Title="NEXUS ULTIMATE",Subtitle="🌊 Sea 1-4 | ⚡ Level Máximo",Width=600,Height=520})
local Tabs={Farm=win:AddTab("Farm","⚔️"),Movement=win:AddTab("Movimento","🏃"),Fruits=win:AddTab("Frutas","🍎"),Extra=win:AddTab("Extra","💎"),ESP=win:AddTab("ESP","👁️"),Teleports=win:AddTab("Teleportes","🏝️")}

-- FARM
Tabs.Farm:AddSection("⚔️ Auto Farm")
Tabs.Farm:AddToggle({Title="🚀 Auto Farm",Desc="Farm automático por nível",Default=false,Callback=function(v)Flags.AutoFarm=v end})
Tabs.Farm:AddToggle({Title="📋 Auto Quest",Desc="Pega quest automaticamente",Default=true,Callback=function(v)Flags.AutoQuest=v end})
Tabs.Farm:AddToggle({Title="💀 Kill Aura",Desc="Ataca inimigos próximos",Default=false,Callback=function(v)Flags.KillAura=v end})
Tabs.Farm:AddToggle({Title="🛡️ God Mode",Desc="Vida infinita",Default=false,Callback=function(v)Flags.GodMode=v end})
Tabs.Farm:AddSlider({Title="🎯 Alcance",Desc="Distância de detecção",Min=100,Max=500,Default=300,Callback=function(v)Flags.Range=v end})

Tabs.Farm:AddSection("📊 Auto Stats")
Tabs.Farm:AddToggle({Title="📊 Auto Stats",Desc="Distribui pontos automaticamente",Default=false,Callback=function(v)Flags.AutoStats=v end})
Tabs.Farm:AddDropdown({Title="📌 Status para upar",Options={"Melee","Defense","Sword","Gun","Demon Fruit"},Default="Melee",Callback=function(v)Flags.StatsToUpgrade=v end})
Tabs.Farm:AddSlider({Title="🔢 Pontos por vez",Desc="Quantos pontos distribuir",Min=1,Max=10,Default=3,Callback=function(v)Flags.StatsAmount=v end})

-- BOSSES
Tabs.Farm:AddSection("🎯 Auto Boss")
Tabs.Farm:AddToggle({Title="🎯 Auto Boss",Desc="Farm de bosses",Default=false,Callback=function(v)Flags.AutoBoss=v end})
Tabs.Farm:AddToggle({Title="🌊 Todos os Bosses do Sea",Desc="Farm todos os bosses",Default=false,Callback=function(v)Flags.AllBosses=v end})
for sea=1,3 do Tabs.Farm:AddSection("🌊 Sea "..sea) for _,boss in ipairs(GameData[sea].Bosses) do Tabs.Farm:AddToggle({Title=boss,Callback=function(v)if v then Flags.AutoBoss=true Flags.BossName=boss Flags.AllBosses=false end end}) end end

Tabs.Farm:AddSection("🌀 Haki")
Tabs.Farm:AddToggle({Title="🌀 Auto Haki",Desc="Ken + Observation",Default=false,Callback=function(v)Flags.AutoHaki=v end})

-- MOVEMENT
Tabs.Movement:AddSection("🏃 Movimentação")
Tabs.Movement:AddToggle({Title="🏃 WalkSpeed",Desc="Andar rápido",Default=false,Callback=function(v)Flags.Walkspeed=v end})
Tabs.Movement:AddSlider({Title="Velocidade",Min=16,Max=350,Default=100,Callback=function(v)Flags.WalkspeedValue=v end})
Tabs.Movement:AddToggle({Title="🦘 JumpSpeed",Desc="Pular alto",Default=false,Callback=function(v)Flags.Jumpspeed=v end})
Tabs.Movement:AddSlider({Title="Altura do Pulo",Min=50,Max=500,Default=150,Callback=function(v)Flags.JumpspeedValue=v end})
Tabs.Movement:AddToggle({Title="🚫 No Clip",Desc="Atravessar paredes",Default=false,Callback=function(v)Flags.NoClip=v end})
Tabs.Movement:AddToggle({Title="✈️ Fly",Desc="Modo voo",Default=false,Callback=function(v)Flags.Fly=v end})

-- FRUITS
Tabs.Fruits:AddSection("🍎 Sistema de Frutas")
Tabs.Fruits:AddToggle({Title="🍎 Fruit Sniper",Desc="Pega frutas do chão",Default=false,Callback=function(v)Flags.FruitSniper=v end})
Tabs.Fruits:AddToggle({Title="📦 Auto Store",Desc="Guarda fruta no inventário",Default=false,Callback=function(v)Flags.AutoStore=v end})
Tabs.Fruits:AddToggle({Title="🎲 Auto Roll",Desc="Rola fruta no gacha",Default=false,Callback=function(v)Flags.AutoRoll=v end})
Tabs.Fruits:AddToggle({Title="🪄 Auto Spawn",Desc="Spawna fruta do dealer",Default=false,Callback=function(v)Flags.AutoSpawn=v end})

-- EXTRA
Tabs.Extra:AddSection("💎 Farms Extras")
Tabs.Extra:AddToggle({Title="💎 Fragment Farm",Desc="Farm de fragmentos",Default=false,Callback=function(v)Flags.FragmentFarm=v end})
Tabs.Extra:AddToggle({Title="🦴 Bones Farm",Desc="Farm de ossos",Default=false,Callback=function(v)Flags.BonesFarm=v end})
Tabs.Extra:AddToggle({Title="💰 Bounty Hunt",Desc="Caça jogadores",Default=false,Callback=function(v)Flags.BountyHunt=v end})
Tabs.Extra:AddSection("👑 Evoluções")
Tabs.Extra:AddToggle({Title="👑 Auto V4",Desc="Desperta V4",Default=false,Callback=function(v)Flags.AutoV4=v end})
Tabs.Extra:AddToggle({Title="🧬 Auto Race",Desc="Evolui raça",Default=false,Callback=function(v)Flags.AutoRace=v end})

-- ESP
Tabs.ESP:AddSection("👁️ ESP")
Tabs.ESP:AddToggle({Title="👤 ESP Players",Desc="Mostra jogadores",Default=false,Callback=function(v)Flags.ESP_Players=v end})
Tabs.ESP:AddToggle({Title="🍎 ESP Fruits",Desc="Mostra frutas",Default=false,Callback=function(v)Flags.ESP_Fruits=v end})
Tabs.ESP:AddToggle({Title="📦 ESP Chests",Desc="Mostra baús",Default=false,Callback=function(v)Flags.ESP_Chests=v end})
Tabs.ESP:AddToggle({Title="🎯 ESP Bosses",Desc="Mostra bosses",Default=false,Callback=function(v)Flags.ESP_Bosses=v end})
Tabs.ESP:AddToggle({Title="🎯 Aimlock",Desc="Mira automática",Default=false,Callback=function(v)Flags.Aimlock=v end})

-- TELEPORTES
for sea=1,3 do Tabs.Teleports:AddSection("🌊 Sea "..sea) for _,island in ipairs(GameData[sea].Islands) do Tabs.Teleports:AddButton({Title="🏝️ "..island[1],Callback=function()TP(island[2])end}) end end

-- FPS
local fpsLabel=Instance.new("TextLabel",win.MainFrame)
fpsLabel.Size=UDim2.new(0,220,0,15)fpsLabel.Position=UDim2.new(0,10,1,-18)fpsLabel.BackgroundTransparency=1
fpsLabel.Text="FPS: -- | 💀 0"fpsLabel.TextColor3=Color3.fromRGB(160,160,170)fpsLabel.TextSize=10 fpsLabel.Font=Enum.Font.Gotham
local fc,lt=0,tick()RunService.RenderStepped:Connect(function()fc=fc+1 local nw=tick()if nw-lt>=1 then fpsLabel.Text="FPS: "..fc.." | 💀 "..Flags.Kills fc=0 lt=nw end end)

NexusUI:Notify({Title="NEXUS ULTIMATE",Content="✅ Completo!\n🔴 Tudo desativado\n🚀 Ative no menu",Duration=5})
print("✅ NEXUS ULTIMATE - COMPLETO!")
