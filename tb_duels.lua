-- ============================================
-- TD XITERS v3.7 - PARTE 1/2
-- Loading + Funções + Blur Massinha
-- ============================================

if _G.TDX_LOADED then return end
_G.TDX_LOADED = true

-- ===== LOADING SCREEN =====
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "TDX_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 10
loadingGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
bg.BorderSizePixel = 0
bg.Parent = loadingGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0.4, -80)
title.BackgroundTransparency = 1
title.Text = "⚡ TD XITERS"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 36
title.Parent = bg

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Position = UDim2.new(0, 0, 0.4, -20)
sub.BackgroundTransparency = 1
sub.Text = "Carregando..."
sub.TextColor3 = Color3.fromRGB(200, 200, 220)
sub.Font = Enum.Font.Gotham
sub.TextSize = 16
sub.Parent = bg

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 300, 0, 8)
barBg.Position = UDim2.new(0.5, -150, 0.5, 40)
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
barBg.BorderSizePixel = 0
barBg.Parent = bg

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = barFill

local pct = Instance.new("TextLabel")
pct.Size = UDim2.new(1, 0, 0, 20)
pct.Position = UDim2.new(0, 0, 0.5, 60)
pct.BackgroundTransparency = 1
pct.Text = "0%"
pct.TextColor3 = Color3.fromRGB(255, 255, 255)
pct.Font = Enum.Font.GothamBold
pct.TextSize = 14
pct.Parent = bg

local steps = {"Carregando interface...", "Carregando Rayfield...", "Preparando módulos...", "Finalizando..."}

task.spawn(function()
    for i = 1, #steps do
        sub.Text = steps[i]
        for p = 0, 100, 5 do
            barFill.Size = UDim2.new(p / 100, 0, 1, 0)
            pct.Text = math.floor(((i - 1) * 25) + (p / 4)) .. "%"
            task.wait(0.02)
        end
    end
    task.wait(0.3)
    loadingGui:Destroy()
end)

-- ===== CARREGA RAYFIELD =====
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

_G.TDX = _G.TDX or {}
local TDX = _G.TDX

TDX.CFG = {
    AntiLag = false, FPSBoost = false,
    FOVEnabled = false, FOV = 120,
    ESP = false, ESPPlayers = false, Skybox = "Nenhum",
    JumpPowerEnabled = false, JumpPowerValue = 75,
    Fullbright = false,
    BlurMassinha = false, BlurSize = 24,
    BugMove = false, BugMoveSpeed = 15, BugMoveAmp = 0.5,
    StrafeTurn = false,
    CamBug = false,
}
TDX.ORIGINAL_FOV = workspace.CurrentCamera.FieldOfView
TDX.Rayfield = Rayfield
local CFG = TDX.CFG

local Window = Rayfield:CreateWindow({
    Name = "TD XITERS",
    LoadingTitle = "TD Xiters",
    LoadingSubtitle = "v3.7 • Timebomb Duels",
    Icon = 4483362458,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})
TDX.Window = Window

local function notify(title, content)
    Rayfield:Notify({
        Title = title or "TD XITERS",
        Content = content or "",
        Duration = 2
    })
end

-- ============================================
-- ANTI-LAG
-- ============================================
local function applyAntiLag(on)
    CFG.AntiLag = on
    if on then
        Lighting.GlobalShadows = false
        for _, v in ipairs(Lighting:GetChildren()) do
            pcall(function()
                if v:IsA("PostEffect") or v:IsA("Atmosphere") then v.Enabled = false end
            end)
        end
        for _, v in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end)
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = true
    end
end

-- ===== FPS BOOST =====
local fpsBoostConn = nil
local function cleanChar(char)
    if not char or char == LP.Character then return end
    for _, d in ipairs(char:GetDescendants()) do
        pcall(function()
            if d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("CharacterMesh") then
                d:Destroy()
            end
        end)
    end
end

local function applyFPSBoost(on)
    CFG.FPSBoost = on
    if on then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then cleanChar(plr.Character) end
        end
        if fpsBoostConn then fpsBoostConn:Disconnect() end
        fpsBoostConn = Workspace.DescendantAdded:Connect(function(d)
            if not CFG.FPSBoost then return end
            pcall(function()
                if d:IsA("Accessory") then task.wait(0.05); if d and d.Parent then d:Destroy() end end
            end)
        end)
    else
        if fpsBoostConn then fpsBoostConn:Disconnect() fpsBoostConn = nil end
    end
end

-- ===== FULLBRIGHT =====
local function applyFullbright(on)
    CFG.Fullbright = on
    if on then
        Lighting.Brightness = 3; Lighting.ClockTime = 14
        Lighting.FogEnd = 100000; Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(70, 70, 70)
    end
end

-- ===== FOV =====
local function applyFOV(on)
    CFG.FOVEnabled = on
    local cam = workspace.CurrentCamera
    if on then cam.FieldOfView = CFG.FOV
    else cam.FieldOfView = TDX.ORIGINAL_FOV end
end

-- ===== GRÁFICO MASSINHA (BLUR) =====
local function applyBlurMassinha(on, size)
    CFG.BlurMassinha = on
    if size then CFG.BlurSize = size end

    local blur = Lighting:FindFirstChild("TDX_BlurMassinha")

    if on then
        if not blur then
            blur = Instance.new("BlurEffect")
            blur.Name = "TDX_BlurMassinha"
            blur.Parent = Lighting
        end
        blur.Size = CFG.BlurSize
    else
        if blur then blur:Destroy() end
    end
end

-- ===== SKYBOX =====
local SKYBOXES = {
    Nenhum = nil,
    Night = { Bk = "rbxassetid://1233158420", Dn = "rbxassetid://1233158838", Ft = "rbxassetid://1233157105", Lf = "rbxassetid://1233157640", Rt = "rbxassetid://1233157995", Up = "rbxassetid://1233159158" },
    Purple = { Bk = "rbxassetid://6021017254", Dn = "rbxassetid://6021016390", Ft = "rbxassetid://6021015479", Lf = "rbxassetid://6021014807", Rt = "rbxassetid://6021012347", Up = "rbxassetid://6021011228" },
    Dragon = { Bk = "rbxassetid://14753804949", Dn = "rbxassetid://14753795573", Ft = "rbxassetid://14753807625", Lf = "rbxassetid://14753797417", Rt = "rbxassetid://14753799966", Up = "rbxassetid://14753810287" },
}

local function setSkybox(name)
    CFG.Skybox = name
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    if name == "Nenhum" or not SKYBOXES[name] then return end
    local data = SKYBOXES[name]
    local sky = Instance.new("Sky")
    sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = data.Bk, data.Dn, data.Ft
    sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = data.Lf, data.Rt, data.Up
    sky.Parent = Lighting
end

-- ============================================
-- BUG DA CÂMERA (GRUDA NO TORSO)
-- ============================================
local camBugConn = nil

local function startCamBug()
    if camBugConn then return end
    CFG.CamBug = true

    camBugConn = RunService.RenderStepped:Connect(function()
        if not CFG.CamBug then return end
        local char = LP.Character
        if not char then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local torso = char:FindFirstChild("Torso")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("HumanoidRootPart")
        if not torso then return end

        local offset = torso.CFrame * CFrame.new(0, 1.5, 8)
        cam.CFrame = CFrame.new(offset.Position, torso.Position + torso.CFrame.LookVector * 5)
        cam.CameraType = Enum.CameraType.Scriptable
    end)
end

local function stopCamBug()
    CFG.CamBug = false
    if camBugConn then camBugConn:Disconnect() camBugConn = nil end
    local cam = workspace.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Custom end
end

-- ===== PERSONAGEM BUGADO =====
local bugMoveConn, bugMoveTimer = nil, 0
local function startBugMove()
    if bugMoveConn then return end
    CFG.BugMove = true
    bugMoveTimer = 0
    bugMoveConn = RunService.Heartbeat:Connect(function(dt)
        if not CFG.BugMove then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        bugMoveTimer = bugMoveTimer + dt
        local speed = CFG.BugMoveSpeed
        local amp = CFG.BugMoveAmp
        local offsetX = math.sin(bugMoveTimer * speed) * amp
        local offsetY = math.cos(bugMoveTimer * speed * 1.7) * (amp * 0.3)
        local offsetZ = math.sin(bugMoveTimer * speed * 2.3) * amp
        hrp.CFrame = hrp.CFrame * CFrame.new(offsetX, offsetY, offsetZ)
    end)
end
local function stopBugMove()
    CFG.BugMove = false
    if bugMoveConn then bugMoveConn:Disconnect() bugMoveConn = nil end
end

-- ===== STRAFE VIRAR =====
local strafeTurnConn, strafeCooldown = nil, false
local function startStrafeTurn()
    if strafeTurnConn then return end
    CFG.StrafeTurn = true
    strafeTurnConn = RunService.Heartbeat:Connect(function(dt)
        if not CFG.StrafeTurn then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local state = hum:GetState()
        if (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall) and not strafeCooldown then
            if hum.MoveDirection.Magnitude > 0.1 then
                strafeCooldown = true
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(180), 0)
                task.wait(0.4)
                strafeCooldown = false
            end
        end
    end)
end
local function stopStrafeTurn()
    CFG.StrafeTurn = false
    if strafeTurnConn then strafeTurnConn:Disconnect() strafeTurnConn = nil end
    strafeCooldown = false
end

-- ===== JUMP POWER =====
local jumpConn, jumpOriginal = nil, 50
local function startJumpPower()
    if jumpConn then return end
    CFG.JumpPowerEnabled = true
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then jumpOriginal = hum.JumpPower; hum.JumpPower = CFG.JumpPowerValue end
    jumpConn = RunService.Heartbeat:Connect(function()
        if not CFG.JumpPowerEnabled then return end
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h and h.JumpPower ~= CFG.JumpPowerValue then h.JumpPower = CFG.JumpPowerValue end
    end)
end
local function stopJumpPower()
    CFG.JumpPowerEnabled = false
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = jumpOriginal end
end

-- ===== ESP =====
local espFolder, espConn
local function isRealPlayer(character)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == character then return true end
    end
    return false
end
local function createESP(character, isBot)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    local color = isBot and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(255, 50, 50)
    local label = isBot and "BOT" or (character.Name or "Player")
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "TDX_ESP_Box"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.Size = Vector3.new(4, 6, 4)
    box.Transparency = 0.5
    box.Color3 = color
    box.Parent = espFolder
    local bb = Instance.new("BillboardGui")
    bb.Name = "TDX_ESP_Name"
    bb.Size = UDim2.new(0, 100, 0, 24)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = hrp
    bb.Parent = espFolder
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = label
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = bb
end
local function applyESP(on)
    CFG.ESP = on
    if on then
        if espFolder then espFolder:Destroy() end
        espFolder = Instance.new("Folder")
        espFolder.Name = "TDX_ESP"
        espFolder.Parent = Workspace
        for _, plr in ipairs(Players:GetChildren()) do
            if plr ~= LP and plr.Character then
                if isRealPlayer(plr.Character) then
                    if CFG.ESPPlayers then createESP(plr.Character, false) end
                else
                    createESP(plr.Character, true)
                end
            end
        end
        if espConn then espConn:Disconnect() end
        espConn = Players.ChildAdded:Connect(function(obj)
            if not CFG.ESP then return end
            obj.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if CFG.ESP and char ~= LP.Character then
                    if isRealPlayer(char) then
                        if CFG.ESPPlayers then createESP(char, false) end
                    else
                        createESP(char, true)
                    end
                end
            end)
        end)
    else
        if espFolder then espFolder:Destroy() espFolder = nil end
        if espConn then espConn:Disconnect() espConn = nil end
    end
end

-- Guarda global
TDX.applyAntiLag = applyAntiLag
TDX.applyFPSBoost = applyFPSBoost
TDX.applyFullbright = applyFullbright
TDX.applyFOV = applyFOV
TDX.applyBlurMassinha = applyBlurMassinha
TDX.setSkybox = setSkybox
TDX.startBugMove = startBugMove
TDX.stopBugMove = stopBugMove
TDX.startStrafeTurn = startStrafeTurn
TDX.stopStrafeTurn = stopStrafeTurn
TDX.startJumpPower = startJumpPower
TDX.stopJumpPower = stopJumpPower
TDX.applyESP = applyESP
TDX.startCamBug = startCamBug
TDX.stopCamBug = stopCamBug
TDX.notify = notify

print("✅ Parte 1 carregada")
-- ============================================
-- TD XITERS v3.7 - PARTE 2/2
-- Menus com notificações
-- ============================================

local LP = game:GetService("Players").LocalPlayer
local TDX = _G.TDX
local CFG = TDX.CFG
local Window = TDX.Window
local notify = TDX.notify

-- ===== TAB COMBATE =====
local CombatTab = Window:CreateTab("Combate", 4483362458)

CombatTab:CreateSection("Movimento Bugado")
CombatTab:CreateToggle({
    Name = "Strafe Virar (Gira no Pulo)", CurrentValue = false, Flag = "StrafeTurn",
    Callback = function(v)
        if v then TDX.startStrafeTurn() else TDX.stopStrafeTurn() end
        notify("Strafe Virar", v and "Ativado" or "Desativado")
    end
})

CombatTab:CreateSection("Personagem Bugado")
CombatTab:CreateToggle({
    Name = "Personagem Bugado (Seta)", CurrentValue = false, Flag = "BugMove",
    Callback = function(v)
        if v then TDX.startBugMove() else TDX.stopBugMove() end
        notify("Personagem Bugado", v and "Ativado" or "Desativado")
    end
})
CombatTab:CreateSlider({
    Name = "Velocidade do Bug", Range = {5, 40}, Increment = 1, Suffix = "x",
    CurrentValue = 15, Flag = "BugMoveSpeed",
    Callback = function(v) CFG.BugMoveSpeed = v end
})
CombatTab:CreateSlider({
    Name = "Amplitude do Bug", Range = {0.1, 2}, Increment = 0.1, Suffix = "",
    CurrentValue = 0.5, Flag = "BugMoveAmp",
    Callback = function(v) CFG.BugMoveAmp = v end
})

CombatTab:CreateSection("Pulo")
CombatTab:CreateToggle({
    Name = "Jump Power Custom", CurrentValue = false, Flag = "JumpPower",
    Callback = function(v)
        if v then TDX.startJumpPower() else TDX.stopJumpPower() end
        notify("Jump Power", v and "Ativado" or "Desativado")
    end
})
CombatTab:CreateSlider({
    Name = "Força do Pulo", Range = {50, 300}, Increment = 5, Suffix = "",
    CurrentValue = 75, Flag = "JumpPowerValue",
    Callback = function(v) CFG.JumpPowerValue = v end
})

CombatTab:CreateSection("Câmera")
CombatTab:CreateToggle({
    Name = "Bug da Câmera (Gruda no Torso)", CurrentValue = false, Flag = "CamBug",
    Callback = function(v)
        if v then TDX.startCamBug() else TDX.stopCamBug() end
        notify("Bug da Câmera", v and "Ativado" or "Desativado")
    end
})

-- ===== TAB VISUAL =====
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateSection("Gráfico Massinha")
VisualTab:CreateToggle({
    Name = "Gráfico Massinha (Blur)", CurrentValue = false, Flag = "BlurMassinha",
    Callback = function(v)
        TDX.applyBlurMassinha(v, CFG.BlurSize)
        notify("Gráfico Massinha", v and "Ativado" or "Desativado")
    end
})
VisualTab:CreateSlider({
    Name = "Intensidade do Blur", Range = {5, 50}, Increment = 1, Suffix = "",
    CurrentValue = 24, Flag = "BlurSize",
    Callback = function(v)
        CFG.BlurSize = v
        if CFG.BlurMassinha then
            TDX.applyBlurMassinha(true, v)
        end
    end
})

VisualTab:CreateSection("Iluminação")
VisualTab:CreateToggle({
    Name = "Fullbright", CurrentValue = false, Flag = "Fullbright",
    Callback = function(v)
        TDX.applyFullbright(v)
        notify("Fullbright", v and "Ativado" or "Desativado")
    end
})

VisualTab:CreateSection("Skybox")
VisualTab:CreateDropdown({
    Name = "Skybox", Options = {"Nenhum", "Night", "Purple", "Dragon"},
    CurrentOption = {"Nenhum"}, Flag = "Skybox",
    Callback = function(opt)
        local escolha = type(opt) == "table" and opt[1] or opt
        TDX.setSkybox(escolha)
        notify("Skybox", escolha)
    end
})

VisualTab:CreateSection("Câmera")
VisualTab:CreateToggle({
    Name = "FOV Custom", CurrentValue = false, Flag = "FOV",
    Callback = function(v)
        TDX.applyFOV(v)
        notify("FOV", v and "Ativado" or "Desativado")
    end
})
VisualTab:CreateSlider({
    Name = "FOV", Range = {70, 160}, Increment = 5, Suffix = "",
    CurrentValue = 120, Flag = "FOVValue",
    Callback = function(v)
        CFG.FOV = v
        if CFG.FOVEnabled then
            workspace.CurrentCamera.FieldOfView = v
        end
    end
})

-- ===== TAB ESP =====
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateSection("Jogadores")
ESPTab:CreateToggle({
    Name = "ESP Bots", CurrentValue = false, Flag = "ESP",
    Callback = function(v)
        TDX.applyESP(v)
        notify("ESP", v and "Ativado" or "Desativado")
    end
})

ESPTab:CreateToggle({
    Name = "Mostrar Jogadores Reais", CurrentValue = false, Flag = "ESPPlayers",
    Callback = function(v)
        CFG.ESPPlayers = v
        if CFG.ESP then
            TDX.applyESP(false)
            task.wait(0.1)
            TDX.applyESP(true)
        end
        notify("ESP Players", v and "Ativado" or "Desativado")
    end
})

-- ===== TAB PERFORMANCE =====
local PerfTab = Window:CreateTab("Performance", 4483362458)

PerfTab:CreateSection("Otimização")
PerfTab:CreateToggle({
    Name = "Anti-Lag", CurrentValue = false, Flag = "AntiLag",
    Callback = function(v)
        TDX.applyAntiLag(v)
        notify("Anti-Lag", v and "Ativado" or "Desativado")
    end
})

PerfTab:CreateToggle({
    Name = "FPS Boost (Remove acessórios)", CurrentValue = false, Flag = "FPSBoost",
    Callback = function(v)
        TDX.applyFPSBoost(v)
        notify("FPS Boost", v and "Ativado" or "Desativado")
    end
})

print("✅ Parte 2 carregada: TD XITERS v3.7 completo")
notify("TD XITERS", "Script carregado com sucesso!")
