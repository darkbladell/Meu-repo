-- ============================================
-- TB DUELS MOBILE - v2.0
-- Câmera Reta + ESP Bots + Ícone Corrigido
-- ============================================

if _G.TB_LOADED then return end
_G.TB_LOADED = true

-- ===== LOADING SCREEN =====
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "TB_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 10
loadingGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
bg.BorderSizePixel = 0
bg.Parent = loadingGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0.4, -80)
title.BackgroundTransparency = 1
title.Text = "💣 TB DUELS"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.Parent = bg

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Position = UDim2.new(0, 0, 0.4, -20)
sub.BackgroundTransparency = 1
sub.Text = "Carregando script..."
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
barFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
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

local steps = {
    "Carregando interface...",
    "Carregando Rayfield...",
    "Preparando módulos...",
    "Finalizando...",
}

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
local LP = Players.LocalPlayer

_G.TB = _G.TB or {}
local TB = _G.TB

TB.CFG = {
    AntiLag = false, FPSBoost = false,
    FOVEnabled = false, FOV = 120,
    ESP = false, Skybox = "Nenhum",
    CamShake = false, CamShakeSpeed = 8,
    WallhopTurn = false, StrafeTurn = false,
    JumpPowerEnabled = false, JumpPowerValue = 75,
    CamShakeAmp = 15,
}
TB.ORIGINAL_FOV = workspace.CurrentCamera.FieldOfView
local CFG = TB.CFG

-- ÍCONE: Vou usar um ID de ícone genérico que funciona (seta vermelha)
local Window = Rayfield:CreateWindow({
    Name = "TB Duels Mobile",
    LoadingTitle = "TB Duels",
    LoadingSubtitle = "v2.0",
    Icon = 4483362458,  -- ID genérico que funciona
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

-- ===== ANTI-LAG =====
local function applyAntiLag(on)
    CFG.AntiLag = on
    if on then
        Lighting.GlobalShadows = false
        for _, v in ipairs(Lighting:GetChildren()) do
            pcall(function()
                if v:IsA("PostEffect") or v:IsA("Atmosphere") then
                    v.Enabled = false
                end
            end)
        end
        for _, v in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail")
                   or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
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
            if d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants")
               or d:IsA("ShirtGraphic") or d:IsA("CharacterMesh") then
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
                if d:IsA("Accessory") then
                    task.wait(0.05)
                    if d and d.Parent then d:Destroy() end
                end
            end)
        end)
    else
        if fpsBoostConn then fpsBoostConn:Disconnect() fpsBoostConn = nil end
    end
end

-- ===== FOV =====
local function applyFOV(on)
    CFG.FOVEnabled = on
    local cam = workspace.CurrentCamera
    if on then cam.FieldOfView = CFG.FOV
    else cam.FieldOfView = TB.ORIGINAL_FOV end
end

-- ===== SKYBOX =====
local SKYBOXES = {
    Nenhum = nil,
    Night = {
        Bk = "rbxassetid://1233158420", Dn = "rbxassetid://1233158838",
        Ft = "rbxassetid://1233157105", Lf = "rbxassetid://1233157640",
        Rt = "rbxassetid://1233157995", Up = "rbxassetid://1233159158",
    },
    Purple = {
        Bk = "rbxassetid://6021017254", Dn = "rbxassetid://6021016390",
        Ft = "rbxassetid://6021015479", Lf = "rbxassetid://6021014807",
        Rt = "rbxassetid://6021012347", Up = "rbxassetid://6021011228",
    },
    Dragon = {
        Bk = "rbxassetid://14753804949", Dn = "rbxassetid://14753795573",
        Ft = "rbxassetid://14753807625", Lf = "rbxassetid://14753797417",
        Rt = "rbxassetid://14753799966", Up = "rbxassetid://14753810287",
    },
}

local function setSkybox(name)
    CFG.Skybox = name
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    if name == "Nenhum" or not SKYBOXES[name] then return end
    local data = SKYBOXES[name]
    local sky = Instance.new("Sky")
    sky.SkyboxBk = data.Bk
    sky.SkyboxDn = data.Dn
    sky.SkyboxFt = data.Ft
    sky.SkyboxLf = data.Lf
    sky.SkyboxRt = data.Rt
    sky.SkyboxUp = data.Up
    sky.Parent = Lighting
end

-- ===== ESP SÓ PARA BOTS =====
local espFolder, espConn, espUpdateConn

-- Função para verificar se um personagem é de um player real
local function isRealPlayer(character)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == character then
            return true
        end
    end
    return false
end

local function createESP(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    -- Só aplica ESP se NÃO for player real (ou seja, é bot)
    if isRealPlayer(character) then return end

    local hrp = character.HumanoidRootPart

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "TB_ESP_Bot"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.Size = Vector3.new(4, 6, 4)
    box.Transparency = 0.5
    box.Color3 = Color3.fromRGB(255, 100, 0)  -- Laranja (diferente dos players)
    box.Parent = espFolder

    local bb = Instance.new("BillboardGui")
    bb.Name = "TB_ESP_BotName"
    bb.Size = UDim2.new(0, 100, 0, 24)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = hrp
    bb.Parent = espFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "BOT"
    label.TextColor3 = Color3.fromRGB(255, 150, 50)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = bb
end

local function scanForBots()
    if not CFG.ESP then return end
    -- Percorre todos os personagens no Workspace
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            createESP(obj)
        end
    end
end

local function applyESP(on)
    CFG.ESP = on
    if on then
        if espFolder then espFolder:Destroy() end
        espFolder = Instance.new("Folder")
        espFolder.Name = "TB_ESP_Bots"
        espFolder.Parent = Workspace

        -- Escaneia bots existentes
        scanForBots()

        -- Monitora novos bots que aparecem
        if espConn then espConn:Disconnect() end
        espConn = Workspace.DescendantAdded:Connect(function(d)
            if not CFG.ESP then return end
            if d:IsA("Model") and d:FindFirstChild("Humanoid") then
                task.wait(0.5)
                if CFG.ESP then createESP(d) end
            end
        end)
    else
        if espFolder then espFolder:Destroy() espFolder = nil end
        if espConn then espConn:Disconnect() espConn = nil end
    end
end

-- ===== FUNÇÕES BASE =====
local function getHRP()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ===== JUMP POWER =====
local jumpConn = nil
local jumpOriginal = 50

local function startJumpPower()
    if jumpConn then return end
    CFG.JumpPowerEnabled = true
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        jumpOriginal = hum.JumpPower
        hum.JumpPower = CFG.JumpPowerValue
    end

    jumpConn = RunService.Heartbeat:Connect(function()
        if not CFG.JumpPowerEnabled then return end
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h and h.JumpPower ~= CFG.JumpPowerValue then
            h.JumpPower = CFG.JumpPowerValue
        end
    end)
end

local function stopJumpPower()
    CFG.JumpPowerEnabled = false
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = jumpOriginal end
end

-- ===== CÂMERA TREMENDO (RETA - ESQUERDA/DIREITA) =====
local camShakeConn = nil
local shakeTimer = 0

local function startCamShake()
    if camShakeConn then return end
    CFG.CamShake = true
    shakeTimer = 0

    camShakeConn = RunService.RenderStepped:Connect(function(dt)
        if not CFG.CamShake then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        shakeTimer = shakeTimer + dt
        -- Gira RETO (yaw) em vez de inclinar (roll)
        local yaw = math.sin(shakeTimer * CFG.CamShakeSpeed) * math.rad(CFG.CamShakeAmp)
        cam.CFrame = cam.CFrame * CFrame.Angles(0, yaw, 0)  -- Y = yaw (reto)
    end)
end

local function stopCamShake()
    CFG.CamShake = false
    if camShakeConn then camShakeConn:Disconnect() camShakeConn = nil end
end

-- ===== WALLHOP VIRAR =====
local wallhopConn = nil
local wallhopCooldown = false

local function startWallhopTurn()
    if wallhopConn then return end
    CFG.WallhopTurn = true

    wallhopConn = RunService.Heartbeat:Connect(function(dt)
        if not CFG.WallhopTurn then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local state = hum:GetState()
        if (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall) and not wallhopCooldown then
            wallhopCooldown = true
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(180), 0)
            task.wait(0.3)
            wallhopCooldown = false
        end
    end)
end

local function stopWallhopTurn()
    CFG.WallhopTurn = false
    if wallhopConn then wallhopConn:Disconnect() wallhopConn = nil end
    wallhopCooldown = false
end

-- ===== STRAFE VIRAR =====
local strafeTurnConn = nil
local strafeCooldown = false

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

-- ===== TAB VISUAL =====
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateToggle({
    Name = "Anti-Lag Máximo", CurrentValue = false, Flag = "AntiLag",
    Callback = function(v) applyAntiLag(v) end,
})

VisualTab:CreateToggle({
    Name = "FPS Boost Extra", CurrentValue = false, Flag = "FPSBoost",
    Callback = function(v) applyFPSBoost(v) end,
})

VisualTab:CreateToggle({
    Name = "FOV (Tela Aberta)", CurrentValue = false, Flag = "FOVEnabled",
    Callback = function(v) applyFOV(v) end,
})

VisualTab:CreateSlider({
    Name = "FOV", Range = {70, 140}, Increment = 1, Suffix = "FOV",
    CurrentValue = 120, Flag = "FOV",
    Callback = function(v)
        CFG.FOV = v
        if CFG.FOVEnabled then workspace.CurrentCamera.FieldOfView = v end
    end,
})

VisualTab:CreateDropdown({
    Name = "Skybox",
    Options = {"Nenhum", "Night", "Purple", "Dragon"},
    CurrentOption = {"Nenhum"}, Flag = "Skybox",
    Callback = function(opt) setSkybox(type(opt) == "table" and opt[1] or opt) end,
})

VisualTab:CreateSection("Câmera")

VisualTab:CreateToggle({
    Name = "Câmera Tremendo (Reto L/R)", CurrentValue = false, Flag = "CamShake",
    Callback = function(v)
        if v then startCamShake() else stopCamShake() end
    end,
})

VisualTab:CreateSlider({
    Name = "Velocidade do Tremor", Range = {1, 20}, Increment = 1, Suffix = "x",
    CurrentValue = 8, Flag = "CamShakeSpeed",
    Callback = function(v) CFG.CamShakeSpeed = v end,
})

VisualTab:CreateSlider({
    Name = "Intensidade do Tremor", Range = {5, 45}, Increment = 1, Suffix = "°",
    CurrentValue = 15, Flag = "CamShakeAmp",
    Callback = function(v) CFG.CamShakeAmp = v end,
})

-- ===== TAB MOVIMENTO =====
local MoveTab = Window:CreateTab("Movimento", 4483362458)

MoveTab:CreateSection("Pulo")

MoveTab:CreateToggle({
    Name = "Jump Power Boost", CurrentValue = false, Flag = "JumpPowerEnabled",
    Callback = function(v)
        if v then startJumpPower() else stopJumpPower() end
    end,
})

MoveTab:CreateSlider({
    Name = "Jump Power", Range = {50, 200}, Increment = 5, Suffix = "",
    CurrentValue = 75, Flag = "JumpPowerValue",
    Callback = function(v)
        CFG.JumpPowerValue = v
        if CFG.JumpPowerEnabled then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end,
})

MoveTab:CreateSection("Movimentação Bugada")

MoveTab:CreateToggle({
    Name = "Wallhop Virar (Lado Contrário)", CurrentValue = false, Flag = "WallhopTurn",
    Callback = function(v)
        if v then startWallhopTurn() else stopWallhopTurn() end
    end,
})

MoveTab:CreateToggle({
    Name = "Strafe Virar (Pra Trás)", CurrentValue = false, Flag = "StrafeTurn",
    Callback = function(v)
        if v then startStrafeTurn() else stopStrafeTurn() end
    end,
})

-- ===== TAB ESP =====
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({
    Name = "ESP Bots (só bots)", CurrentValue = false, Flag = "ESP",
    Callback = function(v) applyESP(v) end,
})

-- ===== TAB EXTRAS =====
local ExtraTab = Window:CreateTab("Extras", 4483362458)
ExtraTab:CreateButton({
    Name = "Resetar Tudo",
    Callback = function()
        stopCamShake(); stopWallhopTurn(); stopStrafeTurn()
        stopJumpPower(); applyESP(false); applyAntiLag(false)
        applyFPSBoost(false); applyFOV(false); setSkybox("Nenhum")
        print("[TB] Reset completo")
    end,
})

ExtraTab:CreateButton({
    Name = "Destruir Interface",
    Callback = function()
        Rayfield:Destroy()
        _G.TB_LOADED = false
    end,
})

Rayfield:Notify({ Title = "TB Duels v2.0", Content = "Script carregado!", Duration = 3 })
print("✅ TB Duels v2.0 carregado")
