-- ============================================
-- TB DUELS MOBILE - SCRIPT PRINCIPAL
-- Carregado via: loadstring(game:HttpGet("..."))()
-- ============================================

-- Verifica se já carregou
if _G.TB_LOADED then
    warn("[TB] Script já está rodando. Feche o Roblox pra recarregar.")
    return
end
_G.TB_LOADED = true

-- ===== CARREGA RAYFIELD =====
local Rayfield
local sucesso, erro = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not sucesso or not Rayfield then
    warn("[TB] Falha ao carregar Rayfield: " .. tostring(erro))
    _G.TB_LOADED = false
    return
end

-- ===== SERVIÇOS =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- ===== CONFIG GLOBAL =====
_G.TB = _G.TB or {}
local TB = _G.TB

TB.CFG = {
    AntiLag = false,
    FPSBoost = false,
    Stretched = false,
    FOV = 120,
    ESP = false,
    BugMove = false,
    MoveMode = "Ir e Voltar",
    BugSpeed = 8,
    BugDistance = 6,
    Recording = false,
    Playing = false,
}

TB.recordBuffer = {}
TB.MAX_RECORD_TIME = 15
TB.ORIGINAL_FOV = workspace.CurrentCamera.FieldOfView

local CFG = TB.CFG

-- ===== JANELA RAYFIELD =====
local Window = Rayfield:CreateWindow({
    Name = "TB Duels Mobile",
    LoadingTitle = "Carregando TB Duels...",
    LoadingSubtitle = "v1.0.0",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

-- ===== FUNÇÕES =====
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
        for _, v in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds") then
                    v.Parent = nil
                end
            end)
        end
    else
        if fpsBoostConn then fpsBoostConn:Disconnect() fpsBoostConn = nil end
    end
end

local function applyStretched(on)
    CFG.Stretched = on
    local cam = workspace.CurrentCamera
    if on then cam.FieldOfView = CFG.FOV
    else cam.FieldOfView = TB.ORIGINAL_FOV end
end

-- ===== ESP =====
local espConn, espFolder

local function createESP(plr)
    if plr == LP then return end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = plr.Character.HumanoidRootPart

    local hl = Instance.new("Highlight")
    hl.Name = "TB_ESP"
    hl.Adornee = plr.Character
    hl.FillColor = Color3.fromRGB(255, 60, 60)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TB_Name"
    billboard.Size = UDim2.new(0, 80, 0, 22)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = hrp
    billboard.Parent = espFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.Parent = billboard
end

local function applyESP(on)
    CFG.ESP = on
    if on then
        if espFolder then espFolder:Destroy() end
        espFolder = Instance.new("Folder")
        espFolder.Name = "TB_ESP_Folder"
        espFolder.Parent = Workspace

        for _, plr in ipairs(Players:GetPlayers()) do createESP(plr) end

        if espConn then espConn:Disconnect() end
        espConn = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                if CFG.ESP then createESP(plr) end
            end)
        end)
        for _, plr in ipairs(Players:GetPlayers()) do
            plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                if CFG.ESP then createESP(plr) end
            end)
        end
    else
        if espFolder then espFolder:Destroy() espFolder = nil end
        if espConn then espConn:Disconnect() espConn = nil end
    end
end

-- ===== MOVIMENTOS =====
local bugMoveConn, moveOrigin, moveT, playbackConn, recordConn

local function getHRP()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function startBugMove()
    if CFG.BugMove then return end
    CFG.BugMove = true
    local hrp = getHRP()
    if not hrp then CFG.BugMove = false return end
    moveOrigin = hrp.CFrame
    moveT = 0

    bugMoveConn = RunService.Heartbeat:Connect(function(dt)
        if not CFG.BugMove then return end
        local h = getHRP()
        if not h then return end
        moveT = moveT + dt
        local mode = CFG.MoveMode or "Ir e Voltar"
        local speed = CFG.BugSpeed or 8
        local dist = CFG.BugDistance or 6
        local offset = Vector3.zero

        if mode == "Ir e Voltar" then
            offset = Vector3.new(0, 0, -dist * math.sin(moveT * speed))
        elseif mode == "Zigue-Zague" then
            local s = math.sin(moveT * speed)
            local c = math.cos(moveT * speed * 0.5)
            offset = Vector3.new(dist * s, 0, -dist * 0.5 * c)
        elseif mode == "Círculo" then
            local a = moveT * speed
            offset = Vector3.new(math.cos(a) * dist, 0, math.sin(a) * dist)
        elseif mode == "Teleporte" then
            local s = math.sin(moveT * speed * 3)
            offset = Vector3.new(0, 0, -dist * (s > 0 and 1 or 0))
        elseif mode == "Loop Aéreo" then
            local s = math.sin(moveT * speed)
            offset = Vector3.new(0, dist * s * 0.7, -dist * s)
        end

        h.CFrame = moveOrigin * CFrame.new(offset)
        h.Velocity = Vector3.zero
    end)
end

local function stopBugMove()
    CFG.BugMove = false
    if bugMoveConn then bugMoveConn:Disconnect() bugMoveConn = nil end
end

local function startRecording()
    if CFG.Playing then return end
    TB.recordBuffer = {}
    local recordStart = tick()
    CFG.Recording = true
    if not getHRP() then CFG.Recording = false return end

    recordConn = RunService.Heartbeat:Connect(function()
        if not CFG.Recording then return end
        local now = tick()
        if now - recordStart > TB.MAX_RECORD_TIME then
            CFG.Recording = false
            if recordConn then recordConn:Disconnect() recordConn = nil end
            return
        end
        local h = getHRP()
        if h then
            table.insert(TB.recordBuffer, { t = now - recordStart, cf = h.CFrame })
        end
    end)
end

local function stopRecording()
    CFG.Recording = false
    if recordConn then recordConn:Disconnect() recordConn = nil end
end

local function startPlayback()
    if #TB.recordBuffer == 0 then return end
    CFG.Playing = true
    if not getHRP() then CFG.Playing = false return end
    local startT = tick()

    playbackConn = RunService.Heartbeat:Connect(function()
        if not CFG.Playing then return end
        local h = getHRP()
        if not h then return end
        local elapsed = tick() - startT
        if elapsed > TB.recordBuffer[#TB.recordBuffer].t then
            startT = tick()
            elapsed = 0
        end
        for i = #TB.recordBuffer, 1, -1 do
            if TB.recordBuffer[i].t <= elapsed then
                h.CFrame = TB.recordBuffer[i].cf
                h.Velocity = Vector3.zero
                break
            end
        end
    end)
end

local function stopPlayback()
    CFG.Playing = false
    if playbackConn then playbackConn:Disconnect() playbackConn = nil end
end

-- ===== TAB VISUAL =====
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateToggle({
    Name = "Anti-Lag Máximo",
    CurrentValue = false,
    Flag = "AntiLag",
    Callback = function(v) applyAntiLag(v) end,
})

VisualTab:CreateToggle({
    Name = "FPS Boost Extra",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(v) applyFPSBoost(v) end,
})

VisualTab:CreateToggle({
    Name = "Tela Esticada",
    CurrentValue = false,
    Flag = "Stretched",
    Callback = function(v) applyStretched(v) end,
})

VisualTab:CreateSlider({
    Name = "FOV",
    Range = {70, 140},
    Increment = 1,
    Suffix = "FOV",
    CurrentValue = 120,
    Flag = "FOV",
    Callback = function(v)
        CFG.FOV = v
        if CFG.Stretched then workspace.CurrentCamera.FieldOfView = v end
    end,
})

-- ===== TAB MOVIMENTO =====
local MoveTab = Window:CreateTab("Movimento", 4483362458)

MoveTab:CreateDropdown({
    Name = "Modo de Movimento",
    Options = {"Ir e Voltar", "Zigue-Zague", "Círculo", "Teleporte", "Loop Aéreo"},
    CurrentOption = {"Ir e Voltar"},
    Flag = "MoveMode",
    Callback = function(opt)
        CFG.MoveMode = type(opt) == "table" and opt[1] or opt
        local h = getHRP()
        if h then moveOrigin = h.CFrame end
    end,
})

MoveTab:CreateSlider({
    Name = "Velocidade",
    Range = {1, 20},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 8,
    Flag = "BugSpeed",
    Callback = function(v) CFG.BugSpeed = v end,
})

MoveTab:CreateSlider({
    Name = "Distância",
    Range = {1, 20},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 6,
    Flag = "BugDistance",
    Callback = function(v) CFG.BugDistance = v end,
})

MoveTab:CreateToggle({
    Name = "Movimento Bugado",
    CurrentValue = false,
    Flag = "BugMove",
    Callback = function(v)
        if v then startBugMove() else stopBugMove() end
    end,
})

MoveTab:CreateSection("Gravação")

MoveTab:CreateToggle({
    Name = "Gravar Movimento",
    CurrentValue = false,
    Flag = "Recording",
    Callback = function(v)
        if v then startRecording() else stopRecording() end
    end,
})

MoveTab:CreateToggle({
    Name = "Repetir Movimento",
    CurrentValue = false,
    Flag = "Playing",
    Callback = function(v)
        if v then startPlayback() else stopPlayback() end
    end,
})

-- ===== TAB ESP =====
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v) applyESP(v) end,
})

-- ===== TAB EXTRAS =====
local ExtraTab = Window:CreateTab("Extras", 4483362458)

ExtraTab:CreateButton({
    Name = "Resetar Tudo",
    Callback = function()
        stopBugMove()
        stopRecording()
        stopPlayback()
        applyAntiLag(false)
        applyFPSBoost(false)
        applyStretched(false)
        applyESP(false)
        TB.recordBuffer = {}
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

-- ===== NOTIFY =====
Rayfield:Notify({
    Title = "TB Duels",
    Content = "Script carregado com sucesso!",
    Duration = 3,
})

print("✅ TB Duels carregado via loadstring")
