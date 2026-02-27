-- ================================================
--        VKONTAKTE HUB BALL - DELTA MOBILE v2.0
--          Otimizado para executores mobile
-- ================================================

local success, err = pcall(function()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============= CONFIGS =============
local cfg = {
    AutoParry   = true,
    ParryDelay  = 0.05,   -- 0 = instantâneo
    ParryDist   = 80,
    AutoSkill   = true,
    SpeedHack   = false,
    Speed       = 24,
    ESP         = true,
}

-- ============= FUNÇÕES UTILITÁRIAS =============

local function getChar()
    return LocalPlayer.Character
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- Encontra bolas no workspace
local function getBalls()
    local balls = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n == "ball" or n:find("ball") or n:find("proj") then
                if v:FindFirstChildOfClass("BodyVelocity") or v:FindFirstChildOfClass("LinearVelocity") then
                    table.insert(balls, v)
                end
            end
        end
    end
    return balls
end

-- Pega bola mais próxima e distância
local function getNearestBall()
    local root = getRoot()
    if not root then return nil, 999 end
    local nearest, nearDist = nil, math.huge
    for _, b in pairs(getBalls()) do
        local d = (b.Position - root.Position).Magnitude
        if d < nearDist then
            nearest = b
            nearDist = d
        end
    end
    return nearest, nearDist
end

-- Checa se bola está vindo em direção ao player
local function ballComingToMe(ball)
    local root = getRoot()
    if not root or not ball then return false end
    local bv = ball:FindFirstChildOfClass("BodyVelocity") or ball:FindFirstChildOfClass("LinearVelocity")
    if not bv then return false end
    local vel = bv:IsA("BodyVelocity") and bv.Velocity or bv.VectorVelocity
    if vel.Magnitude < 1 then return false end
    local dir = (root.Position - ball.Position).Unit
    return dir:Dot(vel.Unit) > 0.5
end

-- ============= ENCONTRAR REMOTES =============

local remotes = {}

local function scanRemotes()
    remotes = {}
    local function scan(parent)
        for _, v in pairs(parent:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                remotes[n] = v
            end
        end
    end
    scan(ReplicatedStorage)
    scan(workspace)
end

-- Escaneia remotes ao carregar
task.spawn(scanRemotes)

-- Também monitora novos remotes
ReplicatedStorage.DescendantAdded:Connect(function(v)
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        remotes[v.Name:lower()] = v
    end
end)

-- ============= AUTO PARRY =============

local lastParry = 0
local parryKeys = {"parry","block","deflect","reflect","defend","clash"}

local function doParry()
    local now = tick()
    if now - lastParry < 0.25 then return end

    local ball, dist = getNearestBall()
    if not ball then return end
    if dist > cfg.ParryDist then return end
    if not ballComingToMe(ball) then return end

    lastParry = now

    task.delay(cfg.ParryDelay, function()
        -- Tenta todos os remotes relacionados a parry
        for key, remote in pairs(remotes) do
            for _, k in pairs(parryKeys) do
                if key:find(k) then
                    pcall(function() remote:FireServer() end)
                    pcall(function() remote:FireServer(true) end)
                    pcall(function() remote:FireServer(ball) end)
                end
            end
        end

        -- Tenta via tool do personagem
        local char = getChar()
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                -- Simula ativação da tool
                local act = tool:FindFirstChild("Activate")
                if act and act:IsA("RemoteEvent") then
                    pcall(function() act:FireServer() end)
                end
                -- Tenta via script local da tool
                pcall(function()
                    tool:Activate()
                end)
            end
        end
    end)
end

-- ============= AUTO SKILL =============

local lastSkill = 0
local skillKeys = {"skill","ability","power","ultimate","ult","dash","q","e","f"}

local function doSkill()
    local now = tick()
    if now - lastSkill < 1 then return end

    local ball, dist = getNearestBall()
    if not ball or dist > 50 then return end
    if not ballComingToMe(ball) then return end

    lastSkill = now

    for key, remote in pairs(remotes) do
        for _, k in pairs(skillKeys) do
            if key:find(k) then
                pcall(function() remote:FireServer() end)
            end
        end
    end
end

-- ============= SPEED HACK =============

local function applySpeed()
    local hum = getHum()
    if not hum then return end
    if cfg.SpeedHack then
        hum.WalkSpeed = cfg.Speed
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end
end

-- ============= ESP =============

local espFolder = Instance.new("Folder")
espFolder.Name = "BB_ESP"
espFolder.Parent = workspace

local function clearESP()
    espFolder:ClearAllChildren()
end

local function makeESP(part, label, color)
    if not part or not part.Parent then return end
    pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 70, 0, 22)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Adornee = part
        bb.Parent = espFolder

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,0,1,0)
        tl.BackgroundTransparency = 1
        tl.Text = label
        tl.TextColor3 = color or Color3.new(1,0,0)
        tl.TextStrokeTransparency = 0
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13
        tl.Parent = bb
    end)
end

local function updateESP()
    if not cfg.ESP then clearESP() return end
    clearESP()
    for _, ball in pairs(getBalls()) do
        local root = getRoot()
        if root then
            local d = math.floor((ball.Position - root.Position).Magnitude)
            makeESP(ball, "🔴 BALL " .. d .. "m", Color3.fromRGB(255,60,60))
        end
    end
end

-- ============= GUI MOBILE =============

-- Remove GUI antiga
for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
    if v.Name == "VK_HUB_GUI" then v:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "VK_HUB_GUI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = LocalPlayer.PlayerGui

-- Frame principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 310)
main.Position = UDim2.new(0, 8, 0, 60)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(220, 30, 30)
stroke.Thickness = 2
stroke.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,42)
header.BackgroundColor3 = Color3.fromRGB(190, 20, 20)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "⚔️ VKONTAKTE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Minimizar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,32,0,28)
minBtn.Position = UDim2.new(1,-40,0,7)
minBtn.BackgroundColor3 = Color3.fromRGB(160,15,15)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,6)

-- Área de conteúdo
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-16,1,-50)
content.Position = UDim2.new(0,8,0,48)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,7)
layout.Parent = content

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main.Size = minimized and UDim2.new(0,260,0,46) or UDim2.new(0,260,0,310)
    minBtn.Text = minimized and "▲" or "—"
end)

-- Toggle factory
local function makeToggle(labelText, key)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,40)
    row.BackgroundColor3 = Color3.fromRGB(18,18,28)
    row.BorderSizePixel = 0
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210,210,210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,54,0,26)
    btn.Position = UDim2.new(1,-62,0.5,-13)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,22,0,22)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    circle.BorderSizePixel = 0
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    local function refresh()
        local on = cfg[key]
        btn.BackgroundColor3 = on and Color3.fromRGB(210,25,25) or Color3.fromRGB(55,55,65)
        circle.Position = on and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11)
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        refresh()
        if key == "SpeedHack" then applySpeed() end
    end)
end

makeToggle("🛡️  Auto Parry",  "AutoParry")
makeToggle("✨  Auto Skill",   "AutoSkill")
makeToggle("🚀  Speed Hack",   "SpeedHack")
makeToggle("👁️  ESP Bolas",    "ESP")

-- Delay label
local delayLbl = Instance.new("TextLabel")
delayLbl.Size = UDim2.new(1,0,0,22)
delayLbl.BackgroundTransparency = 1
delayLbl.Text = "⏱  Parry Delay: " .. cfg.ParryDelay .. "s  |  Dist: " .. cfg.ParryDist
delayLbl.TextColor3 = Color3.fromRGB(160,160,160)
delayLbl.Font = Enum.Font.Gotham
delayLbl.TextSize = 11
delayLbl.Parent = content

-- Status
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1,0,0,22)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "⚡ Status: Aguardando bola..."
statusLbl.TextColor3 = Color3.fromRGB(100,220,100)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.Parent = content

-- ============= MAIN LOOP =============

local lastESP = 0

RunService.Heartbeat:Connect(function()
    -- Parry
    if cfg.AutoParry then
        pcall(doParry)
    end

    -- Skill
    if cfg.AutoSkill then
        pcall(doSkill)
    end

    -- Speed
    pcall(applySpeed)

    -- ESP (a cada 0.3s pra não travar mobile)
    local now = tick()
    if now - lastESP > 0.3 then
        lastESP = now
        pcall(updateESP)
    end

    -- Atualiza status
    pcall(function()
        local ball, dist = getNearestBall()
        if ball and dist < cfg.ParryDist then
            local coming = ballComingToMe(ball)
            statusLbl.Text = "🔴 Bola: " .. math.floor(dist) .. "m " .. (coming and "⚠️ VINDO!" or "↗️ longe")
            statusLbl.TextColor3 = coming and Color3.fromRGB(255,80,80) or Color3.fromRGB(100,220,100)
        else
            statusLbl.Text = "✅ Aguardando bola..."
            statusLbl.TextColor3 = Color3.fromRGB(100,220,100)
        end
    end)
end)

-- Respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    scanRemotes()
    applySpeed()
end)

print("[VKontakte Hub Ball] Carregado! Delta Mobile OK")

end) -- fim do pcall

if not success then
    print("[VKontakte Hub Ball] Erro: " .. tostring(err))
    -- Tenta notificar via GUI simples mesmo com erro
    pcall(function()
        local sg2 = Instance.new("ScreenGui")
        sg2.Parent = game.Players.LocalPlayer.PlayerGui
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0,300,0,50)
        lbl.Position = UDim2.new(0.5,-150,0,10)
        lbl.BackgroundColor3 = Color3.fromRGB(180,20,20)
        lbl.Text = "Erro ao carregar script:\n" .. tostring(err):sub(1,80)
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextWrapped = true
        lbl.Parent = sg2
        Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,8)
        task.delay(6, function() sg2:Destroy() end)
    end)
end
