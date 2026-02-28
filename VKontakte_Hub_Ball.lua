-- ================================================
--        VKONTAKTE HUB BALL - Delta Mobile
--     Usa o remote REAL do Blade Ball: ParryButtonPress
--     Detecta bola REAL: workspace.Balls + realBall attr
-- ================================================

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")

pcall(function()
    lp.PlayerGui:FindFirstChild("VKHUB") and lp.PlayerGui.VKHUB:Destroy()
end)

local cfg = {parry=true, skill=true, speed=false, esp=true, spd=28}

-- ===== ESTRUTURA REAL DO BLADE BALL =====
-- workspace.Balls         → pasta com as bolas
-- Remotes.ParryButtonPress → remote do parry
-- Remotes.Skill (ou similar) → remote da skill
-- Highlight no personagem → indica que você é o alvo

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 10)
    or game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")

local ParryRemote = nil
local SkillRemote = nil

if Remotes then
    ParryRemote = Remotes:FindFirstChild("ParryButtonPress")
    -- Tenta achar skill remote
    for _, v in pairs(Remotes:GetChildren()) do
        local n = v.Name:lower()
        if n:find("skill") or n:find("ability") or n:find("power") then
            SkillRemote = v
        end
    end
end

-- Fallback: procura em todo ReplicatedStorage
if not ParryRemote then
    ParryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ParryButtonPress", true)
end

-- ===== BOLA REAL =====
local BallsFolder = workspace:FindFirstChild("Balls")

local function getRealBalls()
    local t = {}
    -- Método 1: pasta Balls com atributo realBall
    if BallsFolder then
        for _, ball in pairs(BallsFolder:GetChildren()) do
            if ball:IsA("BasePart") and ball:GetAttribute("realBall") == true then
                table.insert(t, ball)
            end
        end
    end
    -- Fallback: qualquer BasePart com velocidade alta no workspace
    if #t == 0 then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored then
                local bv = v:FindFirstChildOfClass("BodyVelocity")
                        or v:FindFirstChildOfClass("LinearVelocity")
                if bv then
                    local vel = bv:IsA("BodyVelocity") and bv.Velocity or bv.VectorVelocity
                    if vel.Magnitude > 20 then
                        table.insert(t, v)
                    end
                end
            end
        end
    end
    return t
end

-- Verifica se o PLAYER é o alvo atual (tem Highlight)
local function isTarget()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Highlight") ~= nil
end

local function getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getNearestBall()
    local root = getRoot()
    if not root then return nil, 999 end
    local best, bestD = nil, math.huge
    for _, ball in pairs(getRealBalls()) do
        local d = (ball.Position - root.Position).Magnitude
        if d < bestD then best = ball; bestD = d end
    end
    return best, bestD
end

-- ===== GUI =====
local sg = Instance.new("ScreenGui")
sg.Name = "VKHUB"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
sg.Parent = lp.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0,260,0,340)
main.Position = UDim2.new(0,8,0,55)
main.BackgroundColor3 = Color3.fromRGB(10,10,16)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg
Instance.new("UICorner",main).CornerRadius = UDim.new(0,14)
local sk = Instance.new("UIStroke",main)
sk.Color = ParryRemote and Color3.fromRGB(0,200,80) or Color3.fromRGB(210,20,20)
sk.Thickness = 2

local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1,0,0,44)
hdr.BackgroundColor3 = Color3.fromRGB(185,15,15)
hdr.BorderSizePixel = 0
hdr.Parent = main
Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,14)

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1,-50,1,0)
ttl.Position = UDim2.new(0,10,0,0)
ttl.BackgroundTransparency = 1
ttl.Text = "⚔️ VKONTAKTE HUB"
ttl.TextColor3 = Color3.new(1,1,1)
ttl.Font = Enum.Font.GothamBold
ttl.TextSize = 14
ttl.TextXAlignment = Enum.TextXAlignment.Left
ttl.Parent = hdr

local minB = Instance.new("TextButton")
minB.Size = UDim2.new(0,32,0,26)
minB.Position = UDim2.new(1,-38,0,9)
minB.BackgroundColor3 = Color3.fromRGB(130,8,8)
minB.Text = "—"
minB.TextColor3 = Color3.new(1,1,1)
minB.Font = Enum.Font.GothamBold
minB.TextSize = 13
minB.BorderSizePixel = 0
minB.Parent = hdr
Instance.new("UICorner",minB).CornerRadius = UDim.new(0,6)

local cont = Instance.new("Frame")
cont.Size = UDim2.new(1,-14,1,-50)
cont.Position = UDim2.new(0,7,0,48)
cont.BackgroundTransparency = 1
cont.Parent = main
local ul = Instance.new("UIListLayout",cont)
ul.Padding = UDim.new(0,6)

local mini = false
minB.MouseButton1Click:Connect(function()
    mini = not mini
    cont.Visible = not mini
    main.Size = mini and UDim2.new(0,260,0,48) or UDim2.new(0,260,0,340)
    minB.Text = mini and "▲" or "—"
end)

-- Status do remote
local remSt = Instance.new("Frame")
remSt.Size = UDim2.new(1,0,0,32)
remSt.BackgroundColor3 = ParryRemote and Color3.fromRGB(10,35,12) or Color3.fromRGB(35,10,10)
remSt.BorderSizePixel = 0
remSt.Parent = cont
Instance.new("UICorner",remSt).CornerRadius = UDim.new(0,8)
local remTx = Instance.new("TextLabel")
remTx.Size = UDim2.new(1,0,1,0)
remTx.BackgroundTransparency = 1
remTx.Text = ParryRemote
    and "✅ ParryButtonPress encontrado!"
    or  "⚠️ Remote não encontrado ainda..."
remTx.TextColor3 = ParryRemote
    and Color3.fromRGB(80,255,100)
    or  Color3.fromRGB(255,200,0)
remTx.Font = Enum.Font.GothamBold
remTx.TextSize = 11
remTx.Parent = remSt

-- Toggles
local function tog(icon, txt, key)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,40)
    f.BackgroundColor3 = Color3.fromRGB(18,18,28)
    f.BorderSizePixel = 0
    f.Parent = cont
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,9)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.68,0,1,0)
    lb.Position = UDim2.new(0,10,0,0)
    lb.BackgroundTransparency = 1
    lb.Text = icon.."  "..txt
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 13
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = f
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,52,0,26)
    b.Position = UDim2.new(1,-60,0.5,-13)
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = f
    Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0,20,0,20)
    c.BackgroundColor3 = Color3.new(1,1,1)
    c.BorderSizePixel = 0
    c.Parent = b
    Instance.new("UICorner",c).CornerRadius = UDim.new(1,0)
    local function upd()
        local on = cfg[key]
        b.BackgroundColor3 = on and Color3.fromRGB(205,20,20) or Color3.fromRGB(50,50,62)
        c.Position = on and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
        lb.TextColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(140,140,145)
    end
    upd()
    b.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        upd()
    end)
end

tog("🛡️","Auto Parry","parry")
tog("✨","Auto Skill","skill")
tog("🚀","Speed Hack","speed")
tog("👁️","ESP Bolas","esp")

local stLb = Instance.new("TextLabel")
stLb.Size = UDim2.new(1,0,0,20)
stLb.BackgroundTransparency = 1
stLb.Text = "✅ Aguardando..."
stLb.TextColor3 = Color3.fromRGB(80,220,80)
stLb.Font = Enum.Font.GothamBold
stLb.TextSize = 12
stLb.Parent = cont

local cntLb = Instance.new("TextLabel")
cntLb.Size = UDim2.new(1,0,0,16)
cntLb.BackgroundTransparency = 1
cntLb.Text = "Parries: 0"
cntLb.TextColor3 = Color3.fromRGB(80,80,95)
cntLb.Font = Enum.Font.Gotham
cntLb.TextSize = 10
cntLb.Parent = cont

-- ===== ESP =====
local ef = Instance.new("Folder", workspace)
ef.Name = "VK_ESP"
local lastESP = 0
local function updateESP()
    ef:ClearAllChildren()
    if not cfg.esp then return end
    local root = getRoot()
    for _, ball in pairs(getRealBalls()) do
        pcall(function()
            local bb = Instance.new("BillboardGui")
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0,90,0,22)
            bb.StudsOffset = Vector3.new(0,5,0)
            bb.Adornee = ball
            bb.Parent = ef
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1,0,1,0)
            tl.BackgroundTransparency = 1
            local d = root and math.floor((ball.Position-root.Position).Magnitude) or 0
            tl.Text = "⚡ BALL " .. d .. "m"
            tl.TextColor3 = Color3.fromRGB(255,80,80)
            tl.TextStrokeTransparency = 0
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 12
            tl.Parent = bb
        end)
    end
end

-- ===== AUTO PARRY PRINCIPAL =====
-- Usa ChildAdded na pasta Balls para reagir IMEDIATAMENTE quando bola aparece
-- E monitora Position para dar parry no momento certo

local parryCount = 0
local activeConnections = {}

local function setupBallParry(ball)
    -- Limpa conexão antiga dessa bola se existir
    if activeConnections[ball] then
        activeConnections[ball]:Disconnect()
        activeConnections[ball] = nil
    end

    local conn
    conn = ball:GetPropertyChangedSignal("Position"):Connect(function()
        if not cfg.parry then return end
        -- Só age se VOCÊ for o alvo
        if not isTarget() then return end

        local root = getRoot()
        if not root then return end

        local dist = (ball.Position - root.Position).Magnitude

        -- Dá parry quando bola está perto o suficiente
        if dist <= 25 then
            if ParryRemote then
                pcall(function() ParryRemote:FireServer() end)
            end
            parryCount = parryCount + 1
            stLb.Text = "🛡️ PARRY #"..parryCount.." | "..math.floor(dist).."m"
            stLb.TextColor3 = Color3.fromRGB(100,255,100)
            cntLb.Text = "Parries: "..parryCount
        end
    end)

    activeConnections[ball] = conn
end

-- Conecta nas bolas que já existem
if BallsFolder then
    for _, ball in pairs(BallsFolder:GetChildren()) do
        if ball:IsA("BasePart") and ball:GetAttribute("realBall") == true then
            setupBallParry(ball)
        end
    end

    -- Conecta em bolas novas
    BallsFolder.ChildAdded:Connect(function(ball)
        task.wait() -- espera atributos carregarem
        if ball:IsA("BasePart") and ball:GetAttribute("realBall") == true then
            setupBallParry(ball)
        end
    end)

    BallsFolder.ChildRemoved:Connect(function(ball)
        if activeConnections[ball] then
            activeConnections[ball]:Disconnect()
            activeConnections[ball] = nil
        end
    end)
else
    -- Fallback: se não achou pasta Balls, monitora workspace
    workspace.DescendantAdded:Connect(function(v)
        task.wait()
        if v:IsA("BasePart") and v:GetAttribute("realBall") == true then
            setupBallParry(v)
        end
    end)
end

-- Tenta achar remote se não encontrou ainda
local lastRemoteScan = 0
local ls = 0

rs.Heartbeat:Connect(function()
    local now = tick()

    -- Speed
    pcall(function()
        local h = getHum()
        if h then h.WalkSpeed = cfg.speed and cfg.spd or 16 end
    end)

    -- Tenta achar remote a cada 3s se ainda não encontrou
    if not ParryRemote and now - lastRemoteScan > 3 then
        lastRemoteScan = now
        pcall(function()
            local rem = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if rem then
                local pr = rem:FindFirstChild("ParryButtonPress")
                if pr then
                    ParryRemote = pr
                    remTx.Text = "✅ ParryButtonPress encontrado!"
                    remTx.TextColor3 = Color3.fromRGB(80,255,100)
                    remSt.BackgroundColor3 = Color3.fromRGB(10,35,12)
                    sk.Color = Color3.fromRGB(0,200,80)
                    -- Reconecta bolas com o remote agora disponível
                    if BallsFolder then
                        for _, ball in pairs(BallsFolder:GetChildren()) do
                            if ball:IsA("BasePart") then
                                setupBallParry(ball)
                            end
                        end
                    end
                end
            end
        end)
    end

    -- ESP
    if now - lastESP > 0.25 then
        lastESP = now
        pcall(updateESP)
    end

    -- Status quando não é alvo
    if not isTarget() then
        stLb.Text = "✅ Aguardando ser alvo..."
        stLb.TextColor3 = Color3.fromRGB(80,220,80)
    end

    -- Skill
    if cfg.skill and now - ls > 1.2 then
        pcall(function()
            if isTarget() and SkillRemote then
                ls = now
                pcall(function() SkillRemote:FireServer() end)
            end
        end)
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(1)
    -- Reconecta bolas ao respawnar
    if BallsFolder then
        for _, ball in pairs(BallsFolder:GetChildren()) do
            if ball:IsA("BasePart") then
                pcall(function() setupBallParry(ball) end)
            end
        end
    end
end)

print("[VKontakte Hub Ball] Carregado!")
print("Remote: " .. (ParryRemote and "✅ ParryButtonPress" or "⚠️ aguardando..."))
print("Balls folder: " .. (BallsFolder and "✅ encontrada" or "⚠️ não encontrada"))
