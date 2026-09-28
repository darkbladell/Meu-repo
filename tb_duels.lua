-- ============================================
-- TD XITERS v2.8 - PARTE 1/2
-- Funções base + Auto Seguir (Personagem) + Flick
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
local LP = Players.LocalPlayer

_G.TDX = _G.TDX or {}
local TDX = _G.TDX

TDX.CFG = {
    AntiLag = false, FPSBoost = false,
    FOVEnabled = false, FOV = 120,
    ESP = false, ESPPlayers = false, Skybox = "Nenhum",
    StrafeTurn = false, WallStick = false,
    CharShake = false, CharShakeSpeed = 10, CharShakeAmp = 0.15,
    JumpPowerEnabled = false, JumpPowerValue = 75,
    HitboxEnabled = false, HitboxSize = 10,
    Fullbright = false,
    AutoFollow = false, FollowSpeed = 30,
    FollowShake = true, FollowShakeAmp = 30, FollowShakeSpeed = 8,
    FlickB = false, FlickAmount = 180,
}
TDX.ORIGINAL_FOV = workspace.CurrentCamera.FieldOfView
local CFG = TDX.CFG

local Window = Rayfield:CreateWindow({
    Name = "TD XITERS",
    LoadingTitle = "TD Xiters",
    LoadingSubtitle = "v2.8 • Timebomb Duels",
    Icon = 4483362458,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})
TDX.Window = Window

-- ===== ANTI-LAG =====
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

-- ===== HITBOX =====
local hitboxConn = nil
local function startHitbox()
    if hitboxConn then return end
    CFG.HitboxEnabled = true
    hitboxConn = RunService.Heartbeat:Connect(function()
        if not CFG.HitboxEnabled then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
                    hrp.CanCollide = false
                end
            end
        end
    end)
end
local function stopHitbox()
    CFG.HitboxEnabled = false
    if hitboxConn then hitboxConn:Disconnect() hitboxConn = nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(2, 2, 1) end
        end
    end
end

-- ===== WALL STICK =====
local wallStickConn = nil
local function startWallStick()
    if wallStickConn then return end
    CFG.WallStick = true
    wallStickConn = RunService.Heartbeat:Connect(function()
        if not CFG.WallStick then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}
        local ray = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, rayParams)
        if ray and math.abs(ray.Normal.Y) < 0.3 then
            local forward = -ray.Normal
            local up = Vector3.new(0, 1, 0)
            local right = forward:Cross(up)
            up = right:Cross(forward)
            local wallCF = CFrame.fromMatrix(hrp.Position, right, up)
            hrp.CFrame = hrp.CFrame:Lerp(wallCF, 0.2)
            hum.JumpPower = CFG.JumpPowerValue or 75
        end
    end)
end
local function stopWallStick()
    CFG.WallStick = false
    if wallStickConn then wallStickConn:Disconnect() wallStickConn = nil end
end

-- ===== TREMOR L/R =====
local charShakeConn, charShakeTimer = nil, 0
local function startCharShake()
    if charShakeConn then return end
    CFG.CharShake = true
    charShakeTimer = 0
    charShakeConn = RunService.Heartbeat:Connect(function(dt)
        if not CFG.CharShake then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        charShakeTimer = charShakeTimer + dt
        local offsetX = math.sin(charShakeTimer * CFG.CharShakeSpeed) * CFG.CharShakeAmp
        hrp.CFrame = hrp.CFrame * CFrame.new(offsetX, 0, 0)
    end)
end
local function stopCharShake()
    CFG.CharShake = false
    if charShakeConn then charShakeConn:Disconnect() charShakeConn = nil end
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

-- ===== AUTO SEGUIR BUGADO (PERSONAGEM TREME, CÂMERA PARADA) =====
local followConn, followShakeTimer = nil, 0

local function startAutoFollow()
    if followConn then return end
    CFG.AutoFollow = true
    followShakeTimer = 0

    followConn = RunService.Heartbeat:Connect(function(dt)
        if not CFG.AutoFollow then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local target, minDist = nil, math.huge
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj ~= char then
                local tHrp = obj:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local dist = (hrp.Position - tHrp.Position).Magnitude
                    if dist < minDist and dist < 200 then
                        minDist = dist
                        target = obj
                    end
                end
            end
        end

        if target then
            local tHrp = target:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local dir = (tHrp.Position - hrp.Position)
                dir = Vector3.new(dir.X, 0, dir.Z)
                if dir.Magnitude > 1 then
                    hum:Move(dir.Unit * CFG.FollowSpeed, false)
                end
                -- Tremor no PERSONAGEM (câmera intacta)
                if CFG.FollowShake then
                    followShakeTimer = followShakeTimer + dt
                    local offsetX = math.sin(followShakeTimer * CFG.FollowShakeSpeed) * (CFG.FollowShakeAmp / 100)
                    local offsetZ = math.cos(followShakeTimer * CFG.FollowShakeSpeed * 1.3) * (CFG.FollowShakeAmp / 100)
                    hrp.CFrame = hrp.CFrame * CFrame.new(offsetX, 0, offsetZ)
                end
            end
        end
    end)
end
local function stopAutoFollow()
    CFG.AutoFollow = false
    if followConn then followConn:Disconnect() followConn = nil end
end

-- ===== FLICK (PERSONAGEM GIRA NO PULO) =====
local flickConn, flickCooldown = nil, false

local function startFlick()
    if flickConn then return end
    CFG.FlickB = true
    flickConn = RunService.Heartbeat:Connect(function()
        if not CFG.FlickB then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local state = hum:GetState()
        if (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall) and not flickCooldown then
            flickCooldown = true
            -- Gira o PERSONAGEM (não a câmera)
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(CFG.FlickAmount), 0)
            task.wait(0.15)
            flickCooldown = false
        end
    end)
end
local function stopFlick()
    CFG.FlickB = false
    if flickConn then flickConn:Disconnect() flickConn = nil end
    flickCooldown = false
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
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                if isRealPlayer(obj) then
                    if CFG.ESPPlayers then createESP(obj, false) end
                else
                    createESP(obj, true)
                end
            end
        end
        if espConn then espConn:Disconnect() end
        espConn = Workspace.DescendantAdded:Connect(function(d)
            if not CFG.ESP then return end
            if d:IsA("Model") and d:FindFirstChild("Humanoid") then
                task.wait(0.5)
                if CFG.ESP then
                    if isRealPlayer(d) then
                        if CFG.ESPPlayers then createESP(d, false) end
                    else
                        createESP(d, true)
                    end
                end
            end
        end)
    else
        if espFolder then espFolder:Destroy() espFolder = nil end
        if espConn then espConn:Disconnect() espConn = nil end
    end
end

-- Guarda funções global
TDX.applyAntiLag = applyAntiLag
TDX.applyFPSBoost = applyFPSBoost
TDX.applyFullbright = applyFullbright
TDX.applyFOV = applyFOV
TDX.setSkybox = setSkybox
TDX.startHitbox = startHitbox
TDX.stopHitbox = stopHitbox
TDX.startWallStick = startWallStick
TDX.stopWallStick = stopWallStick
TDX.startCharShake = startCharShake
TDX.stopCharShake = stopCharShake
TDX.startJumpPower = startJumpPower
TDX.stopJumpPower = stopJumpPower
TDX.startStrafeTurn = startStrafeTurn
TDX.stopStrafeTurn = stopStrafeTurn
TDX.startAutoFollow = startAutoFollow
TDX.stopAutoFollow = stopAutoFollow
TDX.startFlick = startFlick
TDX.stopFlick = stopFlick
TDX.applyESP = applyESP

print("✅ Parte 1 carregada")
-- ============================================
-- TD XITERS v2.8 - PARTE 2/2
-- Menus das abas
-- ============================================

local LP = game:GetService("Players").LocalPlayer
local TDX = _G.TDX
local CFG = TDX.CFG
local Window = TDX.Window

-- ===== TAB COMBATE =====
local CombatTab = Window:CreateTab("Combate", 4483362458)

CombatTab:CreateSection("Auto Seguir")
CombatTab:CreateToggle({
    Name = "Auto Seguir Bugado (Personagem)", CurrentValue = false, Flag = "AutoFollow",
    Callback = function(v) if v then TDX.startAutoFollow() else TDX.stopAutoFollow() end end
})
CombatTab:CreateSlider({
    Name = "Velocidade do Seguir", Range = {10, 80}, Increment = 5, Suffix = "",
    CurrentValue = 30, Flag = "FollowSpeed",
    Callback = function(v) CFG.FollowSpeed = v end
})
CombatTab:CreateToggle({
    Name = "Tremor no Personagem", CurrentValue = true, Flag = "FollowShake",
    Callback = function(v) CFG.FollowShake = v end
})
CombatTab:CreateSlider({
    Name = "Intensidade do Tremor", Range = {10, 60}, Increment = 1, Suffix = "",
    CurrentValue = 30, Flag = "FollowShakeAmp",
    Callback = function(v) CFG.FollowShakeAmp = v end
})
CombatTab:CreateSlider({
    Name = "Velocidade do Tremor", Range = {1, 20}, Increment = 1, Suffix = "x",
    CurrentValue = 8, Flag = "FollowShakeSpeed",
    Callback = function(v) CFG.FollowShakeSpeed = v end
})

CombatTab:CreateSection("Flick")
CombatTab:CreateToggle({
    Name = "Flick B (Personagem Gira no Pulo)", CurrentValue = false, Flag = "FlickB",
    Callback = function(v) if v then TDX.startFlick() else TDX.stopFlick() end end
})
CombatTab:CreateSlider({
    Name = "Ângulo do Flick", Range = {90, 360}, Increment = 15, Suffix = "°",
    CurrentValue = 180, Flag = "FlickAmount",
    Callback = function(v) CFG.FlickAmount = v end
})

CombatTab:CreateSection("Hitbox")
CombatTab:CreateToggle({
    Name = "Hitbox Expander", CurrentValue = false, Flag = "HitboxEnabled",
    Callback = function(v) if v then TDX.startHitbox() else TDX.stopHitbox() end end
})
CombatTab:CreateSlider({
    Name = "Tamanho da Hitbox", Range = {5, 30}, Increment = 1, Suffix = "x",
    CurrentValue = 10, Flag = "HitboxSize",
    Callback = function(v) CFG.HitboxSize = v end
})

CombatTab:CreateSection("Movimento")
CombatTab:CreateToggle({
    Name = "Wall Stick (Grudar na Parede)", CurrentValue = false, Flag = "WallStick",
    Callback = function(v) if v then TDX.startWallStick() else TDX.stopWallStick() end end
})
CombatTab:CreateToggle({
    Name = "Jump Power Boost", CurrentValue = false, Flag = "JumpPowerEnabled",
    Callback = function(v) if v then TDX.startJumpPower() else TDX.stopJumpPower() end end
})
CombatTab:CreateSlider({
    Name = "Jump Power", Range = {50, 150}, Increment = 5, Suffix = "",
    CurrentValue = 75, Flag = "JumpPowerValue",
    Callback = function(v)
        CFG.JumpPowerValue = v
        if CFG.JumpPowerEnabled then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end
})
CombatTab:CreateToggle({
    Name = "Strafe Virar (Pra Trás)", CurrentValue = false, Flag = "StrafeTurn",
    Callback = function(v) if v then TDX.startStrafeTurn() else TDX.stopStrafeTurn() end end
})

-- ===== TAB VISUAL =====
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateToggle({ Name = "Anti-Lag Máximo", CurrentValue = false, Flag = "AntiLag", Callback = function(v) TDX.applyAntiLag(v) end })
VisualTab:CreateToggle({ Name = "FPS Boost Extra", CurrentValue = false, Flag = "FPSBoost", Callback = function(v) TDX.applyFPSBoost(v) end })
VisualTab:CreateToggle({ Name = "Fullbright (Tudo Claro)", CurrentValue = false, Flag = "Fullbright", Callback = function(v) TDX.applyFullbright(v) end })
VisualTab:CreateToggle({ Name = "FOV (Tela Aberta)", CurrentValue = false, Flag = "FOVEnabled", Callback = function(v) TDX.applyFOV(v) end })
VisualTab:CreateSlider({
    Name = "FOV", Range = {70, 140}, Increment = 1, Suffix = "FOV", CurrentValue = 120, Flag = "FOV",
    Callback = function(v) CFG.FOV = v; if CFG.FOVEnabled then workspace.CurrentCamera.FieldOfView = v end end
})
VisualTab:CreateDropdown({
    Name = "Skybox", Options = {"Nenhum", "Night", "Purple", "Dragon"}, CurrentOption = {"Nenhum"}, Flag = "Skybox",
    Callback = function(opt) TDX.setSkybox(type(opt) == "table" and opt[1] or opt) end
})
VisualTab:CreateSection("Tremor")
VisualTab:CreateToggle({ Name = "Tremor no Personagem (L/R)", CurrentValue = false, Flag = "CharShake", Callback = function(v) if v then TDX.startCharShake() else TDX.stopCharShake() end end })
VisualTab:CreateSlider({ Name = "Velocidade do Tremor", Range = {1, 30}, Increment = 1, Suffix = "x", CurrentValue = 10, Flag = "CharShakeSpeed", Callback = function(v) CFG.CharShakeSpeed = v end })
VisualTab:CreateSlider({ Name = "Intensidade do Tremor", Range = {1, 30}, Increment = 1, Suffix = "", CurrentValue = 15, Flag = "CharShakeAmp", Callback = function(v) CFG.CharShakeAmp = v / 100 end })

-- ===== TAB ESP =====
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({ Name = "ESP Bots", CurrentValue = false, Flag = "ESP", Callback = function(v) CFG.ESP = v; TDX.applyESP(v) end })
ESPTab:CreateToggle({
    Name = "ESP Players (além dos bots)", CurrentValue = false, Flag = "ESPPlayers",
    Callback = function(v) CFG.ESPPlayers = v; if CFG.ESP then TDX.applyESP(true) end end
})

-- ===== TAB EXTRAS =====
local ExtraTab = Window:CreateTab("Extras", 4483362458)
ExtraTab:CreateButton({
    Name = "Resetar Tudo",
    Callback = function()
        TDX.stopStrafeTurn(); TDX.stopWallStick(); TDX.stopCharShake()
        TDX.stopJumpPower(); TDX.stopHitbox(); TDX.stopAutoFollow(); TDX.stopFlick()
        TDX.applyESP(false); TDX.applyAntiLag(false); TDX.applyFPSBoost(false)
        TDX.applyFOV(false); TDX.applyFullbright(false); TDX.setSkybox("Nenhum")
        print("[TDX] Reset completo")
    end
})
ExtraTab:CreateButton({
    Name = "Ressuscitar (Respawn)",
    Callback = function()
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end
})
ExtraTab:CreateButton({
    Name = "Rejoin Servidor",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end
})
ExtraTab:CreateButton({
    Name = "Destruir Interface",
    Callback = function()
        Rayfield:Destroy()
        _G.TDX_LOADED = false
    end
})

Rayfield:Notify({ Title = "TD XITERS v2.8", Content = "Script carregado!", Duration = 4 })
print("✅ TD XITERS v2.8 carregado")
