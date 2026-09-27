-- ============================================
-- TB DUELS MOBILE - v1.2
-- FOV + FPS Boost + Skybox + Movimento Bugado
-- ============================================

if _G.TB_LOADED then return end
_G.TB_LOADED = true

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
    ESP = false, BugMove = false,
    BugDistance = 3, Skybox = "Nenhum",
    Recording = false, Playing = false,
}
TB.recordBuffer = {}
TB.ORIGINAL_FOV = workspace.CurrentCamera.FieldOfView
local CFG = TB.CFG

local Window = Rayfield:CreateWindow({
    Name = "TB Duels Mobile",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "v1.2",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

-- ===== ANTI-LAG =====
local function applyAntiLag(on)
    CFG.AntiLag = on
    if on then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6
        for _, v in ipairs(Lighting:GetChildren()) do
            pcall(function()
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
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
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
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

-- ===== FOV (simula tela esticada) =====
local function applyFOV(on)
    CFG.FOVEnabled = on
    local cam = workspace.CurrentCamera
    if on then cam.FieldOfView = CFG.FOV
    else cam.FieldOfView = TB.ORIGINAL_FOV end
end

-- ===== SKYBOX =====
local function setSkybox(name)
    CFG.Skybox = name
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    if name == "Nenhum" then return end

    local sky = Instance.new("Sky")
    sky.Parent = Lighting

    if name == "Purple" then
        sky.SkyboxBk = "rbxassetid://6021017254"
        sky.SkyboxDn = "rbxassetid://6021016390"
        sky.SkyboxFt = "rbxassetid://6021011228"
        sky.SkyboxLf = "rbxassetid://6021011228"
        sky.SkyboxRt = "rbxassetid://6021011228"
        sky.SkyboxUp = "rbxassetid://6021011228"
    elseif name == "Night" then
        sky.SkyboxBk = "rbxassetid://6021017254"
        sky.SkyboxDn = "rbxassetid://6021016390"
        sky.SkyboxFt = "rbxassetid://6021011228"
        sky.SkyboxLf = "rbxassetid://6021011228"
        sky.SkyboxRt = "rbxassetid://6021011228"
        sky.SkyboxUp = "rbxassetid://6021011228"
        sky.StarCount = 5000
    elseif name == "Dragon" then
        -- IDs de exemplo (troque pelos corretos do catálogo)
        sky.SkyboxBk = "rbxassetid://92767799"
        sky.SkyboxDn = "rbxassetid://92767799"
        sky.SkyboxFt = "rbxassetid://92767799"
        sky.SkyboxLf = "rbxassetid://92767799"
        sky.SkyboxRt = "rbxassetid://92767799"
        sky.SkyboxUp = "rbxassetid://92767799"
    end
end

-- ===== MOVIMENTO BUGADO (BASEADO EM ESTADO) =====
local bugConn, originalCF = nil, nil

local function getHRP()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function startBugMove()
    if bugConn then return end
    CFG.BugMove = true

    bugConn = RunService.Heartbeat:Connect(function()
        if not CFG.BugMove then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local state = hum:GetState()
        -- Detecta pulo ou escalada
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Climbing then
            if not originalCF then originalCF = hrp.CFrame end
            local fwd = hrp.CFrame.LookVector
            local dist = CFG.BugDistance * 0.1
            -- Alterna frente/trás a cada frame
            hrp.CFrame = hrp.CFrame + (math.random() > 0.5 and fwd or -fwd) * dist
        else
            if originalCF then
                hrp.CFrame = hrp.CFrame:Lerp(originalCF, 0.5)
                originalCF = nil
            end
        end
    end)
end

local function stopBugMove()
    CFG.BugMove = false
    if bugConn then bugConn:Disconnect() bugConn = nil end
    originalCF = nil
end

-- ===== ESP =====
local espConn, espFolder

local function createESP(plr)
    if plr == LP then return end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = plr.Character
    hl.FillColor = Color3.fromRGB(255, 60, 60)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espFolder

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 80, 0, 22)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = plr.Character.HumanoidRootPart
    bb.Parent = espFolder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = plr.Name
    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.Parent = bb
end

local function applyESP(on)
    CFG.ESP = on
    if on then
        if espFolder then espFolder:Destroy() end
        espFolder = Instance.new("Folder")
        espFolder.Name = "TB_ESP"
        espFolder.Parent = Workspace
        for _, plr in ipairs(Players:GetPlayers()) do createESP(plr) end
        if espConn then espConn:Disconnect() end
        espConn = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                if CFG.ESP then createESP(plr) end
            end)
        end)
    else
        if espFolder then espFolder:Destroy() espFolder = nil end
        if espConn then espConn:Disconnect() espConn = nil end
    end
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
    Options = {"Nenhum", "Purple", "Night", "Dragon"},
    CurrentOption = {"Nenhum"}, Flag = "Skybox",
    Callback = function(opt)
        setSkybox(type(opt) == "table" and opt[1] or opt)
    end,
})

-- ===== TAB MOVIMENTO =====
local MoveTab = Window:CreateTab("Movimento", 4483362458)

MoveTab:CreateToggle({
    Name = "Movimento Bugado (Pulo/Escalada)", CurrentValue = false, Flag = "BugMove",
    Callback = function(v)
        if v then startBugMove() else stopBugMove() end
    end,
})

MoveTab:CreateSlider({
    Name = "Força do Bug", Range = {1, 8}, Increment = 1, Suffix = "x",
    CurrentValue = 3, Flag = "BugDistance",
    Callback = function(v) CFG.BugDistance = v end,
})

-- ===== TAB ESP =====
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({
    Name = "ESP Players", CurrentValue = false, Flag = "ESP",
    Callback = function(v) applyESP(v) end,
})

-- ===== TAB EXTRAS =====
local ExtraTab = Window:CreateTab("Extras", 4483362458)
ExtraTab:CreateButton({
    Name = "Resetar Tudo",
    Callback = function()
        stopBugMove(); applyESP(false); applyAntiLag(false)
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

Rayfield:Notify({ Title = "TB Duels v1.2", Content = "Script carregado!", Duration = 3 })
print("✅ TB Duels v1.2 carregado")
