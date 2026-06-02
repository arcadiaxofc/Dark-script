-- ==================== PLATOBOOST LIBRARY (OFICIAL) ====================
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
local lEncode, lDecode, lDigest = a3, aw, Z;

-- ==================== CONFIGURAÇÃO PLATOBOOST ====================
local service = 25665;
local secret = "c0bd6633-0e6b-4b49-824f-d1837f1f14c1";
local useNonce = true;
local onMessage = function(message) end;

local requestSending = false;
local fSetClipboard = setclipboard or toclipboard;
local fRequest = request or http_request or syn_request or function(url) return game:HttpGet(url.Url) end;
local fStringChar, fToString, fStringSub = string.char, tostring, string.sub;
local fOsTime, fMathRandom, fMathFloor = os.time, math.random, math.floor;
local fGetHwid = function() 
    local success, result = pcall(function() return game:GetService("Players").LocalPlayer.UserId end)
    if success then return result else return "HWID_" .. math.random(100000, 999999) end
end;
local cachedLink, cachedTime = "", 0;

local host = "https://api.platoboost.com";

function cacheLink()
    pcall(function()
        if cachedTime + (10*60) < fOsTime() then
            local response = fRequest({
                Url = host .. "/public/start",
                Method = "POST",
                Body = lEncode({service = service, identifier = lDigest(fGetHwid())}),
                Headers = {["Content-Type"] = "application/json"}
            });
            if type(response) == "string" then
                local decoded = lDecode(response);
                if decoded.success == true then
                    cachedLink = decoded.data.url;
                    cachedTime = fOsTime();
                end
            end
        end
    end)
end

cacheLink();

local generateNonce = function()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end

local copyLink = function()
    cacheLink();
    if cachedLink ~= "" then 
        pcall(function() fSetClipboard(cachedLink) end)
    else
        pcall(function() fSetClipboard("NEXUS-VIP-2026") end)
    end
end

local verifyKeyPlatoboost = function(key)
    -- Fallback para chaves demo
    local demoKeys = {
        ["NEXUS-VIP-2026"] = true,
        ["FREE-TRIAL"] = true,
        ["BLOX-ADMIN"] = true,
        ["KITSUNE-777"] = true,
        ["OWNER-TEST"] = true
    }
    if demoKeys[key] then return true end
    
    -- Tenta verificação online
    local success = pcall(function()
        if requestSending then return false end
        requestSending = true;
        local nonce = generateNonce();
        local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key;
        if useNonce then endpoint = endpoint .. "&nonce=" .. nonce end
        local response = fRequest({Url = endpoint, Method = "GET"});
        requestSending = false;
        if type(response) == "string" then
            local decoded = lDecode(response);
            if decoded.success and decoded.data.valid then
                return true;
            end
        end
        return false;
    end)
    
    if success then return success end
    return false;
end

-- ==================== SERVIÇOS ROBLOX ====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- ==================== IDIOMAS ====================
local Languages = {
    pt = {flag = "🇧🇷", name = "Português", title = "NEXUS v5.0", subtitle = "DIGITE SUA CHAVE", placeholder = "XXXX-XXXX-XXXX-XXXX", verifyBtn = "VERIFICAR", getKeyBtn = "OBTER CHAVE", waiting = "Aguardando...", copied = "✅ COPIADO!", verifying = "🔄 Verificando...", verified = "✅ VERIFICADO!", invalid = "❌ INVALIDA!", enterKey = "❌ Digite a chave!"},
    en = {flag = "🇺🇸", name = "English", title = "NEXUS v5.0", subtitle = "ENTER YOUR KEY", placeholder = "XXXX-XXXX-XXXX-XXXX", verifyBtn = "VERIFY", getKeyBtn = "GET KEY", waiting = "Waiting...", copied = "✅ COPIED!", verifying = "🔄 Verifying...", verified = "✅ VERIFIED!", invalid = "❌ INVALID!", enterKey = "❌ Enter the key!"},
    es = {flag = "🇪🇸", name = "Español", title = "NEXUS v5.0", subtitle = "INGRESA TU LLAVE", placeholder = "XXXX-XXXX-XXXX-XXXX", verifyBtn = "VERIFICAR", getKeyBtn = "OBTENER", waiting = "Esperando...", copied = "✅ COPIADO!", verifying = "🔄 Verificando...", verified = "✅ VERIFICADO!", invalid = "❌ INVALIDA!", enterKey = "❌ Ingresa la llave!"}
}

local currentLang = "pt"
local Lang = Languages[currentLang]

-- ==================== VARIÁVEIS ====================
local verified = false
local isOwner = false
local OWNER_PASSWORD = "NEXUS-2026-ADMIN"

local farmEnabled = false
local espEnabled = false
local godmodeEnabled = false
local fruitSniperEnabled = false
local bountyHunterEnabled = false
local farmMode = "Level"
local currentTarget = nil

local farmConfig = {Range = 300, AttackDelay = 0.3}

-- ==================== UI DE VERIFICAÇÃO ====================
local function createVerifyGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusVerify"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 380)
    frame.Position = UDim2.new(0.5, -200, 0.5, -190)
    frame.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(210, 60, 48)
    
    -- Topo
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
    topBar.BorderSizePixel = 0
    topBar.Parent = frame
    
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
    
    -- Botão idioma
    local langBtn = Instance.new("TextButton")
    langBtn.Size = UDim2.new(0, 70, 0, 30)
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
        verifyBtn.Text = Lang.verifyBtn
        getKeyBtn.Text = Lang.getKeyBtn
        statusLabel.Text = Lang.waiting
    end)
    
    -- Conteúdo
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -30, 1, -60)
    content.Position = UDim2.new(0, 15, 0, 55)
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
    
    -- Key box
    local keyBoxFrame = Instance.new("Frame")
    keyBoxFrame.Size = UDim2.new(1, 0, 0, 42)
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
    
    -- Botão verificar
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(1, 0, 0, 40)
    verifyBtn.Position = UDim2.new(0, 0, 0, 90)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(210, 58, 45)
    verifyBtn.BorderSizePixel = 0
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.TextSize = 14
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.Text = Lang.verifyBtn
    verifyBtn.AutoButtonColor = false
    verifyBtn.Parent = content
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 7)
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 140)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = Lang.waiting
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = content
    
    -- Botão get key
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.48, 0, 0, 35)
    getKeyBtn.Position = UDim2.new(0, 0, 0, 175)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 54)
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 236)
    getKeyBtn.TextSize = 13
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.Text = Lang.getKeyBtn
    getKeyBtn.AutoButtonColor = false
    getKeyBtn.Parent = content
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)
    
    -- Owner box
    local ownerBox = Instance.new("TextBox")
    ownerBox.Size = UDim2.new(0.48, 0, 0, 35)
    ownerBox.Position = UDim2.new(0.52, 0, 0, 175)
    ownerBox.BackgroundColor3 = Color3.fromRGB(21, 21, 31)
    ownerBox.BorderSizePixel = 0
    ownerBox.PlaceholderText = "🔒 OWNER"
    ownerBox.TextColor3 = Color3.fromRGB(230, 230, 236)
    ownerBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    ownerBox.TextSize = 12
    ownerBox.Font = Enum.Font.Gotham
    ownerBox.TextXAlignment = Enum.TextXAlignment.Center
    ownerBox.Parent = content
    Instance.new("UICorner", ownerBox).CornerRadius = UDim.new(0, 6)
    
    -- Eventos
    getKeyBtn.MouseButton1Click:Connect(function()
        copyLink()
        statusLabel.Text = Lang.copied
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(2)
        statusLabel.Text = Lang.waiting
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end)
    
    verifyBtn.MouseButton1Click:Connect(function()
        local key = keyBox.Text
        if key == "" then
            statusLabel.Text = Lang.enterKey
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
        
        if ownerBox.Text == OWNER_PASSWORD then
            isOwner = true
            statusLabel.Text = "👑 OWNER!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            task.wait(1)
        end
        
        statusLabel.Text = Lang.verifying
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        verifyBtn.Enabled = false
        
        task.wait(0.5)
        
        if verifyKeyPlatoboost(key) then
            verified = true
            statusLabel.Text = Lang.verified
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.wait(1)
            gui:Destroy()
        else
            statusLabel.Text = Lang.invalid
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            verifyBtn.Enabled = true
        end
    end)
    
    repeat task.wait() until verified == true
end

-- ==================== FUNÇÕES DO JOGO ====================
local function teleportTo(pos)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
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
                    if dist < shortest then
                        shortest = dist
                        nearest = obj
                    end
                end
            end
        end)
    end
    return nearest
end

local function startFarm()
    while farmEnabled do
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
                    teleportTo(target.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                end
                
                -- Ataque via remotes
                pcall(function()
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("CommF_") then
                        remotes.CommF_:InvokeServer("Click")
                    end
                end)
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
                if hum then
                    hum.Health = hum.MaxHealth
                end
            end
        end)
        task.wait(0.1)
    end
end

-- ==================== MENU ====================
local function createMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusMenu"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 400)
    frame.Position = UDim2.new(0, 10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
    title.TextColor3 = Color3.fromRGB(230, 65, 50)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Text = "NEXUS v5.0"
    title.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -35)
    scroll.Position = UDim2.new(0, 0, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.Parent = frame
    
    local y = 10
    
    local function createBtn(text, yPos, height)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, height)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end
    
    local farmBtn = createBtn("⚔️ AUTO FARM: OFF", y, 40)
    y = y + 48
    local modeBtn = createBtn("📌 MODO: Level", y, 35)
    y = y + 43
    local espBtn = createBtn("👁️ ESP: OFF", y, 40)
    y = y + 48
    local godBtn = createBtn("🛡️ GODMODE: OFF", y, 40)
    y = y + 48
    local sniperBtn = createBtn("🍎 FRUIT SNIPER: OFF", y, 40)
    y = y + 48
    local bountyBtn = createBtn("💰 BOUNTY HUNTER: OFF", y, 40)
    
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
        farmBtn.Text = farmEnabled and "⚔️ AUTO FARM: ON" or "⚔️ AUTO FARM: OFF"
        farmBtn.BackgroundColor3 = farmEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(35, 35, 45)
        if farmEnabled then task.spawn(startFarm) end
    end)
    
    local modes = {"Level", "Mastery", "Boss", "Raid", "SeaBeast"}
    local modeIndex = 1
    modeBtn.MouseButton1Click:Connect(function()
        modeIndex = modeIndex % #modes + 1
        farmMode = modes[modeIndex]
        modeBtn.Text = "📌 MODO: " .. farmMode
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
        if godmodeEnabled then task.spawn(startGodmode) end
    end)
    
    -- FPS
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. frameCount .. " | TARGET: " .. (currentTarget and currentTarget.Name or "NONE")
            frameCount = 0
            lastTime = now
        end
    end)
    
    -- Drag
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

-- ==================== INICIALIZAÇÃO ====================
local function start()
    print("NEXUS v5.0 - Platoboost + Delta Compatible")
    createVerifyGUI()
    createMenu()
    print("✅ Carregado!")
end

start()
