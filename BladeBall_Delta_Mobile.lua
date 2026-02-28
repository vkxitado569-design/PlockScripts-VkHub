-- ================================================
--        VKONTAKTE HUB BALL - DELTA MOBILE v3.0
--          Auto Parry REAL | Delta Mobile
-- ================================================

local ok, err = pcall(function()

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService  = game:GetService("TweenService")

local LP   = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

-- ============= CONFIGS =============
local cfg = {
    AutoParry  = true,
    AutoSkill  = true,
    SpeedHack  = false,
    ESP        = true,
    Speed      = 28,
    ParryDelay = 0,
    ParryDist  = 100,
}

-- ============= HELPERS =============
local function getRoot()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ============= DETECTAR REMOTES =============
local allRemotes = {}

local function scanAll()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            allRemotes[v.Name] = v
        end
    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            allRemotes[v.Name] = v
        end
    end
end

scanAll()

ReplicatedStorage.DescendantAdded:Connect(function(v)
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        allRemotes[v.Name] = v
    end
end)

local parryNames = {
    "Parry","parry","Block","block","Deflect","deflect",
    "ParryBall","parryball","DoParry","doparry",
    "BallParry","ballparry","Reflect","reflect",
    "ParryEvent","BlockEvent","SwingEvent",
    "SwingSword","Swing","Attack","Hit"
}
local skillNames = {
    "Skill","skill","Ability","ability","UseSkill","useskill",
    "UseAbility","useability","Special","special","Power","power",
    "ActivateSkill","activateskill"
}

local function findRemote(names)
    for _, n in ipairs(names) do
        if allRemotes[n] then return allRemotes[n] end
    end
    return nil
end

-- ============= DETECTAR BOLA =============
local function getBalls()
    local t = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if (n == "ball" or n:find("ball") or n:find("proj") or n:find("blade")) then
                local bv = v:FindFirstChildOfClass("BodyVelocity")
                    or v:FindFirstChildOfClass("LinearVelocity")
                    or v:FindFirstChildOfClass("AlignPosition")
                if bv then
                    table.insert(t, v)
                end
            end
        end
    end
    return t
end

local function getNearestBall()
    local root = getRoot()
    if not root then return nil, 999 end
    local best, bestD = nil, math.huge
    for _, b in ipairs(getBalls()) do
        local d = (b.Position - root.Position).Magnitude
        if d < bestD then best = b; bestD = d end
    end
    return best, bestD
end

local function isComing(ball)
    local root = getRoot()
    if not root or not ball then return false end
    local bv = ball:FindFirstChildOfClass("BodyVelocity")
        or ball:FindFirstChildOfClass("LinearVelocity")
    if not bv then return false end
    local vel = bv:IsA("BodyVelocity") and bv.Velocity or bv.VectorVelocity
    if vel.Magnitude < 0.5 then return false end
    return (root.Position - ball.Position).Unit:Dot(vel.Unit) > 0.45
end

-- ============= AUTO PARRY =============
local lastParry = 0

local function doParry()
    if not cfg.AutoParry then return end
    local now = tick()
    if now - lastParry < 0.3 then return end

    local ball, dist = getNearestBall()
    if not ball or dist > cfg.ParryDist then return end
    if not isComing(ball) then return end

    lastParry = now

    task.delay(cfg.ParryDelay, function()
        local pr = findRemote(parryNames)
        if pr then
            pcall(function() pr:FireServer() end)
            pcall(function() pr:FireServer(true) end)
            pcall(function() pr:FireServer(ball) end)
            pcall(function() pr:FireServer(ball.Position) end)
        end

        local char = LP.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
                for _, s in pairs(tool:GetDescendants()) do
                    if s:IsA("RemoteEvent") then
                        pcall(function() s:FireServer() end)
                    end
                end
            end
        end

        for name, remote in pairs(allRemotes) do
            local nl = name:lower()
            if nl:find("parry") or nl:find("block") or nl:find("swing")
               or nl:find("reflect") or nl:find("deflect") then
                pcall(function() remote:FireServer() end)
            end
        end
    end)
end

-- ============= AUTO SKILL =============
local lastSkill = 0

local function doSkill()
    if not cfg.AutoSkill then return end
    local now = tick()
    if now - lastSkill < 1.5 then return end

    local ball, dist = getNearestBall()
    if not ball or dist > 60 then return end
    if not isComing(ball) then return end

    lastSkill = now

    local sr = findRemote(skillNames)
    if sr then
        pcall(function() sr:FireServer() end)
    end

    for name, remote in pairs(allRemotes) do
        local nl = name:lower()
        if nl:find("skill") or nl:find("ability") or nl:find("special") then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- ============= SPEED =============
local function applySpeed()
    local hum = getHum()
    if not hum then return end
    hum.WalkSpeed = cfg.SpeedHack and cfg.Speed or 16
end

-- ============= ESP =============
local espFolder = Instance.new("Folder")
espFolder.Name = "VK_ESP"
espFolder.Parent = workspace

local function updateESP()
    espFolder:ClearAllChildren()
    if not cfg.ESP then return end
    local root = getRoot()
    for _, ball in ipairs(getBalls()) do
        pcall(function()
            local bb = Instance.new("BillboardGui")
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 80, 0, 24)
            bb.StudsOffset = Vector3.new(0, 4, 0)
            bb.Adornee = ball
            bb.Parent = espFolder

            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1,0,1,0)
            tl.BackgroundTransparency = 1
            local d = root and math.floor((ball.Position - root.Position).Magnitude) or 0
            local coming = isComing(ball)
            tl.Text = (coming and "⚠️ " or "🔴 ") .. "BALL " .. d .. "m"
            tl.TextColor3 = coming and Color3.fromRGB(255,220,0) or Color3.fromRGB(255,60,60)
            tl.TextStrokeTransparency = 0
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 13
            tl.Parent = bb
        end)
    end
end

-- ============= GUI =============
for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "VK_HUB_GUI" then v:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "VK_HUB_GUI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
sg.Parent = LP.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 270, 0, 340)
main.Position = UDim2.new(0, 8, 0, 55)
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

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,44)
header.BackgroundColor3 = Color3.fromRGB(190, 20, 20)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-55,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "⚔️ VKONTAKTE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,34,0,28)
minBtn.Position = UDim2.new(1,-42,0,8)
minBtn.BackgroundColor3 = Color3.fromRGB(140,10,10)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,6)

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-16,1,-52)
content.Position = UDim2.new(0,8,0,50)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,7)
layout.Parent = content

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main.Size = minimized and UDim2.new(0,270,0,48) or UDim2.new(0,270,0,340)
    minBtn.Text = minimized and "▲" or "—"
end)

local function makeToggle(icon, labelText, key, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,42)
    row.BackgroundColor3 = Color3.fromRGB(18,18,28)
    row.BorderSizePixel = 0
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.72,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = icon .. "  " .. labelText
    lbl.TextColor3 = Color3.fromRGB(215,215,215)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,56,0,28)
    btn.Position = UDim2.new(1,-64,0.5,-14)
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
        btn.BackgroundColor3 = on
            and Color3.fromRGB(210,25,25)
            or  Color3.fromRGB(55,55,68)
        circle.Position = on
            and UDim2.new(1,-24,0.5,-11)
            or  UDim2.new(0,2,0.5,-11)
        lbl.TextColor3 = on
            and Color3.fromRGB(255,255,255)
            or  Color3.fromRGB(150,150,155)
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        refresh()
        if onChange then onChange(cfg[key]) end
    end)
end

makeToggle("🛡️", "Auto Parry",  "AutoParry")
makeToggle("✨", "Auto Skill",  "AutoSkill")
makeToggle("🚀", "Speed Hack",  "SpeedHack", function() applySpeed() end)
makeToggle("👁️", "ESP Bolas",   "ESP")

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1,0,0,20)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "⏱  Delay: " .. cfg.ParryDelay .. "s  |  Dist: " .. cfg.ParryDist .. "  |  v3.0"
infoLbl.TextColor3 = Color3.fromRGB(120,120,130)
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 11
infoLbl.Parent = content

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1,0,0,22)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "✅ Aguardando bola..."
statusLbl.TextColor3 = Color3.fromRGB(80,220,80)
statusLbl.Font = Enum.Font.GothamBold
statusLbl.TextSize = 13
statusLbl.Parent = content

local remoteLbl = Instance.new("TextLabel")
remoteLbl.Size = UDim2.new(1,0,0,18)
remoteLbl.BackgroundTransparency = 1
local rc = 0; for _ in pairs(allRemotes) do rc = rc + 1 end
remoteLbl.Text = "Remotes: " .. rc
remoteLbl.TextColor3 = Color3.fromRGB(90,90,100)
remoteLbl.Font = Enum.Font.Gotham
remoteLbl.TextSize = 10
remoteLbl.Parent = content

-- ============= MAIN LOOP =============
local lastESP    = 0
local lastScan   = 0
local lastStatus = 0

RunService.Heartbeat:Connect(function()
    local now = tick()

    if now - lastScan > 5 then
        lastScan = now
        pcall(scanAll)
        local c = 0; for _ in pairs(allRemotes) do c = c + 1 end
        remoteLbl.Text = "Remotes encontrados: " .. c
    end

    if cfg.AutoParry then pcall(doParry) end
    if cfg.AutoSkill  then pcall(doSkill) end
    pcall(applySpeed)

    if now - lastESP > 0.25 then
        lastESP = now
        pcall(updateESP)
    end

    if now - lastStatus > 0.1 then
        lastStatus = now
        pcall(function()
            local ball, dist = getNearestBall()
            if ball and dist < cfg.ParryDist then
                local coming = isComing(ball)
                if coming then
                    statusLbl.Text = "⚠️ BOLA VINDO! " .. math.floor(dist) .. "m"
                    statusLbl.TextColor3 = Color3.fromRGB(255,80,80)
                else
                    statusLbl.Text = "🔴 Bola próxima: " .. math.floor(dist) .. "m"
                    statusLbl.TextColor3 = Color3.fromRGB(255,180,0)
                end
            else
                statusLbl.Text = "✅ Aguardando bola..."
                statusLbl.TextColor3 = Color3.fromRGB(80,220,80)
            end
        end)
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    pcall(scanAll)
    pcall(applySpeed)
end)

print("[VKontakte Hub Ball v3.0] Carregado!")

end)

if not ok then
    print("[VK HUB] ERRO: " .. tostring(err))
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.IgnoreGuiInset = true
        sg.Parent = game.Players.LocalPlayer.PlayerGui
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0,300,0,60)
        f.Position = UDim2.new(0.5,-150,0,10)
        f.BackgroundColor3 = Color3.fromRGB(180,20,20)
        f.Parent = sg
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1,0,1,0)
        t.BackgroundTransparency = 1
        t.Text = "VK HUB ERRO:\n"..tostring(err):sub(1,100)
        t.TextColor3 = Color3.new(1,1,1)
        t.Font = Enum.Font.Gotham
        t.TextSize = 10
        t.TextWrapped = true
        t.Parent = f
        task.delay(8, function() sg:Destroy() end)
    end)
end
