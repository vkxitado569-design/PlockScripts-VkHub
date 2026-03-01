--[[
    VKontakte Knockout Hub v6
    Delta Mobile
    Fixes: Anti-KB real | Knockback forte | ESP mira | Bug TP pos-partida
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris           = game:GetService("Debris")
local TweenService     = game:GetService("TweenService")
local LP               = Players.LocalPlayer
local PlayerGui        = LP:WaitForChild("PlayerGui")

-- ========================
--  CONFIG
-- ========================
local CFG = {
    esp           = true,
    speed         = false, speedVal = 50,
    jumpPower     = false, jumpVal  = 100,
    infJump       = false,
    knockback     = false, kbPower  = 300,
    autoKill      = false, akRange  = 22,
    antiKnockback = false,
    noclip        = false,
}

-- ========================
--  HELPERS
-- ========================
local function chr()  return LP.Character end
local function root()
    local c = chr()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function hum()
    local c = chr()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- Verifica se o personagem esta num mapa valido (nao fora dos limites)
local function isInMap()
    local r = root()
    if not r then return false end
    local y = r.Position.Y
    -- Se Y for muito baixo (caiu fora) ou muito alto (bug de TP), retorna false
    return y > -200 and y < 10000
end

-- ========================
--  ANTI KNOCKBACK v3
--  Detecta velocidade horizontal alta = knockback
--  Zera velocidade E restaura posicao no mesmo frame
-- ========================
local akActive   = false
local akLastPos  = nil
local akConn     = nil

local function startAntiKB()
    if akConn then akConn:Disconnect() akConn = nil end
    akActive  = true
    akLastPos = nil

    akConn = RunService.RenderStepped:Connect(function()
        if not akActive then
            akConn:Disconnect(); akConn = nil
            return
        end

        local r = root()
        if not r then return end

        local pos = r.Position
        local vel = Vector3.zero
        pcall(function() vel = r.AssemblyLinearVelocity end)

        -- Velocidade horizontal = knockback se > 25 studs/s
        local hSpeed = Vector2.new(vel.X, vel.Z).Magnitude

        if hSpeed > 25 then
            -- Zera velocidade horizontal imediatamente
            pcall(function()
                r.AssemblyLinearVelocity = Vector3.new(0, math.min(vel.Y, 30), 0)
            end)
            -- Restaura posicao anterior segura
            if akLastPos then
                pcall(function()
                    r.CFrame = CFrame.new(
                        akLastPos.X, pos.Y, akLastPos.Z
                    ) * (r.CFrame - r.CFrame.Position)
                end)
            end
        else
            -- Velocidade normal: atualiza posicao segura
            akLastPos = Vector3.new(pos.X, pos.Y, pos.Z)
        end
    end)
end

local function stopAntiKB()
    akActive  = false
    akLastPos = nil
    if akConn then akConn:Disconnect(); akConn = nil end
end

-- Reinicia anti-KB a cada respawn
LP.CharacterAdded:Connect(function()
    akLastPos = nil
    task.wait(1)
    if CFG.antiKnockback then startAntiKB() end
end)

-- ========================
--  KNOCKBACK FORTE
--  3 metodos + loop rapido + remove BV antiga
-- ========================
local function pushTarget(tr, mr)
    if not tr or not mr then return end
    local dir = (tr.Position - mr.Position).Unit
    local spd = CFG.kbPower
    local vel = Vector3.new(dir.X * spd, spd * 0.5, dir.Z * spd)

    -- Remove forcas antigas
    pcall(function()
        for _, v in ipairs(tr:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then
                v:Destroy()
            end
        end
    end)

    -- Metodo 1: BodyVelocity
    pcall(function()
        local bv    = Instance.new("BodyVelocity")
        bv.Velocity = vel
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.P        = 1e9
        bv.Parent   = tr
        Debris:AddItem(bv, 0.18)
    end)

    -- Metodo 2: Assembly
    pcall(function()
        tr.AssemblyLinearVelocity = vel
    end)

    -- Metodo 3: LinearVelocity (engine novo)
    pcall(function()
        local att = Instance.new("Attachment", tr)
        local lv  = Instance.new("LinearVelocity")
        lv.Attachment0            = att
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.MaxForce               = 1e9
        lv.RelativeTo             = Enum.ActuatorRelativeTo.World
        lv.VectorVelocity         = vel
        lv.Parent                 = tr
        Debris:AddItem(lv,  0.18)
        Debris:AddItem(att, 0.22)
    end)
end

-- ========================
--  SPEED / JUMP
-- ========================
RunService.Heartbeat:Connect(function()
    local h = hum(); if not h then return end
    h.WalkSpeed = CFG.speed     and CFG.speedVal or 16
    h.JumpPower = CFG.jumpPower and CFG.jumpVal  or 50
end)

-- ========================
--  INFINITE JUMP
-- ========================
UserInputService.JumpRequest:Connect(function()
    if not CFG.infJump then return end
    local h = hum()
    if h and h.FloorMaterial == Enum.Material.Air then
        h:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ========================
--  NOCLIP
-- ========================
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c = chr(); if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ========================
--  AUTO KILL / KNOCKBACK BOOST
--  Loop rapido, verifica se esta no mapa antes de atacar
-- ========================
task.spawn(function()
    while true do
        task.wait(0.1)
        if not (CFG.autoKill or CFG.knockback) then continue end
        if not isInMap() then continue end -- nao ataca se estiver bugado fora do mapa

        local mr = root()
        if not mr then continue end

        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local c = p.Character
            if not c then continue end
            local r = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not r or not h or h.Health <= 0 then continue end

            local dist = (mr.Position - r.Position).Magnitude
            if CFG.autoKill and dist <= CFG.akRange then
                pushTarget(r, mr)
            elseif CFG.knockback and not CFG.autoKill and dist <= 5 then
                pushTarget(r, mr)
            end
        end
    end
end)

-- ========================
--  TP OBBY
--  Fix bug pos-partida: valida destino antes de teleportar
--  e cancela TP se personagem nao estiver no mapa
-- ========================
local cachedEnd   = nil
local endSearched = false

local function findEnd()
    local keys = {
        "finish","final","reward","rainbow","prize",
        "goal","win","complete","obbyend","end"
    }
    local found = {}
    local function scan(par, d)
        if d > 6 then return end
        local ok, kids = pcall(function() return par:GetChildren() end)
        if not ok then return end
        for _, obj in ipairs(kids) do
            local low = obj.Name:lower()
            for _, k in ipairs(keys) do
                if low:find(k, 1, true) then
                    if obj:IsA("BasePart") then
                        table.insert(found, obj)
                    elseif obj:IsA("Model") then
                        local pp = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if pp then table.insert(found, pp) end
                    end
                    break
                end
            end
            scan(obj, d + 1)
        end
    end
    scan(workspace, 0)
    if #found == 0 then return nil end
    table.sort(found, function(a, b) return a.Position.Y > b.Position.Y end)
    return found[1]
end

local function getEnd()
    if not endSearched then
        endSearched = true
        cachedEnd   = findEnd()
    end
    return cachedEnd
end

local function doTP(tpStatus)
    local r = root()
    if not r then
        if tpStatus then tpStatus.Text = "Sem personagem"; tpStatus.TextColor3 = Color3.fromRGB(220,80,80) end
        return false
    end

    local dest = getEnd()
    if not dest then
        endSearched = false; cachedEnd = nil
        dest = getEnd()
    end

    if not dest then
        if tpStatus then tpStatus.Text = "Nao encontrado"; tpStatus.TextColor3 = Color3.fromRGB(220,80,80) end
        return false
    end

    -- Valida destino: nao teleporta se a parte nao existir mais no workspace
    if not dest:IsDescendantOf(workspace) then
        endSearched = false; cachedEnd = nil
        if tpStatus then tpStatus.Text = "Destino invalido, rescan"; tpStatus.TextColor3 = Color3.fromRGB(220,80,80) end
        return false
    end

    local targetPos = dest.Position + Vector3.new(0, 5, 0)

    -- Nao teleporta para posicoes absurdas (bug pos-partida)
    if targetPos.Y > 5000 or targetPos.Y < -100 then
        endSearched = false; cachedEnd = nil
        if tpStatus then tpStatus.Text = "Posicao invalida"; tpStatus.TextColor3 = Color3.fromRGB(220,80,80) end
        return false
    end

    r.CFrame = CFrame.new(targetPos)
    return true
end

-- Reseta cache do obby quando mapa muda (pos-partida)
-- Detecta mudanca de mapa monitorando filhos do workspace
workspace.ChildRemoved:Connect(function()
    task.wait(2)
    endSearched = false
    cachedEnd   = nil
end)
workspace.ChildAdded:Connect(function()
    task.wait(2)
    endSearched = false
    cachedEnd   = nil
end)

-- ========================
--  ESP + MIRA
--  Usa posicao da cabeca + LookVector do HRP
--  Detecta alvo por raio ao redor do ponto projetado
-- ========================
local espFolder = Instance.new("Folder")
espFolder.Name   = "VK_ESP"
espFolder.Parent = PlayerGui

local function cleanESP(name)
    local bb  = espFolder:FindFirstChild("BB_"  .. name)
    local sel = espFolder:FindFirstChild("SEL_" .. name)
    local aim = workspace:FindFirstChild("AIM_" .. name)
    if bb  then bb:Destroy()  end
    if sel then sel:Destroy() end
    if aim then aim:Destroy() end
end

local function makeESP(player)
    if player == LP then return end
    task.wait(0.5)
    cleanESP(player.Name)

    -- BillboardGui acima do personagem
    local bb = Instance.new("BillboardGui", espFolder)
    bb.Name        = "BB_" .. player.Name
    bb.AlwaysOnTop = true
    bb.Size        = UDim2.new(0, 220, 0, 90)
    bb.StudsOffset = Vector3.new(0, 5.5, 0)
    bb.Enabled     = false

    -- Nome do jogador
    local nL = Instance.new("TextLabel", bb)
    nL.BackgroundTransparency = 1
    nL.Size       = UDim2.new(1, 0, 0, 22)
    nL.Font       = Enum.Font.GothamBold
    nL.TextSize   = 14
    nL.TextColor3 = Color3.fromRGB(255, 215, 0)
    nL.TextStrokeTransparency = 0
    nL.Text       = player.Name

    -- Distancia
    local dL = Instance.new("TextLabel", bb)
    dL.BackgroundTransparency = 1
    dL.Size       = UDim2.new(1, 0, 0, 18)
    dL.Position   = UDim2.new(0, 0, 0, 23)
    dL.Font       = Enum.Font.Gotham
    dL.TextSize   = 11
    dL.TextColor3 = Color3.fromRGB(220, 220, 220)
    dL.TextStrokeTransparency = 0
    dL.Text       = "0m"

    -- Status de mira (onde ele esta olhando)
    local aL = Instance.new("TextLabel", bb)
    aL.BackgroundTransparency = 1
    aL.Size       = UDim2.new(1, 0, 0, 20)
    aL.Position   = UDim2.new(0, 0, 0, 42)
    aL.Font       = Enum.Font.GothamBold
    aL.TextSize   = 12
    aL.TextStrokeTransparency = 0
    aL.Text       = "Mira: livre"
    aL.TextColor3 = Color3.fromRGB(100, 230, 100)

    -- Seta indicando direcao do olhar
    local arL = Instance.new("TextLabel", bb)
    arL.BackgroundTransparency = 1
    arL.Size       = UDim2.new(0, 30, 0, 30)
    arL.Position   = UDim2.new(0.5, -15, 0, -36)
    arL.Font       = Enum.Font.GothamBold
    arL.TextSize   = 28
    arL.TextStrokeTransparency = 0.3
    arL.Text       = "▲"
    arL.TextColor3 = Color3.fromRGB(255, 215, 0)

    -- SelectionBox para destacar personagem
    local sel = Instance.new("SelectionBox", espFolder)
    sel.Name                = "SEL_" .. player.Name
    sel.LineThickness       = 0.06
    sel.Color3              = Color3.fromRGB(255, 215, 0)
    sel.SurfaceTransparency = 1

    -- Linha neon 3D mostrando direcao do olhar
    local beam = Instance.new("Part", workspace)
    beam.Name         = "AIM_" .. player.Name
    beam.Anchored     = true
    beam.CanCollide   = false
    beam.CastShadow   = false
    beam.Transparency = 0.15
    beam.BrickColor   = BrickColor.new("Bright red")
    beam.Material     = Enum.Material.Neon
    beam.Size         = Vector3.new(0.08, 0.08, 16)
    beam.Parent       = nil -- comeca escondida

    local conn
    conn = RunService.RenderStepped:Connect(function()
        -- Limpa se billboard foi destruida
        if not bb or not bb.Parent then
            conn:Disconnect()
            pcall(function() beam:Destroy() end)
            pcall(function() sel:Destroy()  end)
            return
        end

        -- Esconde tudo se ESP desligado
        if not CFG.esp then
            bb.Enabled  = false
            beam.Parent = nil
            sel.Adornee = nil
            return
        end

        local c  = player.Character
        local pr = c and c:FindFirstChild("HumanoidRootPart")
        local mr = root()

        if not c or not pr or not mr then
            bb.Enabled  = false
            beam.Parent = nil
            sel.Adornee = nil
            return
        end

        -- Atualiza billboard
        bb.Adornee = pr
        bb.Enabled = true
        sel.Adornee = c

        local dist = (mr.Position - pr.Position).Magnitude
        dL.Text = math.floor(dist) .. "m"
        nL.Text = player.Name

        -- Calcula direcao do olhar usando HumanoidRootPart
        local look = pr.CFrame.LookVector

        -- Projeta 40 studs na frente para achar alvo da mira
        local aimTip = pr.Position + look * 40

        -- Acha quem esta no cone de mira (raio 10 studs do ponto projetado)
        local target     = nil
        local bestDist   = 10
        for _, op in ipairs(Players:GetPlayers()) do
            if op ~= player then
                local oc = op.Character
                if oc then
                    local or2 = oc:FindFirstChild("HumanoidRootPart")
                    if or2 then
                        local d = (aimTip - or2.Position).Magnitude
                        if d < bestDist then
                            bestDist = d
                            target   = op
                        end
                    end
                end
            end
        end

        -- Atualiza visual baseado em quem o inimigo mira
        local blink = math.sin(tick() * 10) > 0

        if target == LP then
            -- PERIGO: mirando em voce
            aL.Text        = blink and ">> MIRANDO EM VOCE <<" or "!! CUIDADO !!"
            aL.TextColor3  = Color3.fromRGB(255, 30, 30)
            arL.TextColor3 = Color3.fromRGB(255, 30, 30)
            sel.Color3     = Color3.fromRGB(255, 30, 30)
            beam.BrickColor = BrickColor.new("Bright red")
        elseif target then
            -- Mirando em outro jogador
            aL.Text        = "Mira: " .. target.Name
            aL.TextColor3  = Color3.fromRGB(255, 160, 30)
            arL.TextColor3 = Color3.fromRGB(255, 160, 30)
            sel.Color3     = Color3.fromRGB(255, 160, 30)
            beam.BrickColor = BrickColor.new("Neon orange")
        else
            -- Mira livre
            aL.Text        = "Mira: livre"
            aL.TextColor3  = Color3.fromRGB(100, 230, 100)
            arL.TextColor3 = Color3.fromRGB(255, 215, 0)
            sel.Color3     = Color3.fromRGB(255, 215, 0)
            beam.BrickColor = BrickColor.new("Bright red")
        end

        -- Rotaciona seta 2D para apontar direcao do olhar
        local camCF = workspace.CurrentCamera.CFrame
        local angle = math.deg(math.atan2(
            look:Dot(camCF.RightVector),
            look:Dot(camCF.LookVector)
        ))
        arL.Rotation = angle

        -- Posiciona linha neon 3D na direcao do olhar
        beam.Parent = workspace
        local origin = pr.Position + Vector3.new(0, 1, 0)
        beam.CFrame  = CFrame.new(origin + look * 8, origin + look * 16)
    end)
end

-- Inicializa ESP para todos
for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(makeESP, p)
end
Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    task.spawn(makeESP, p)
end)
Players.PlayerRemoving:Connect(function(p)
    cleanESP(p.Name)
end)

-- ========================
--  GUI
-- ========================
pcall(function()
    local old = PlayerGui:FindFirstChild("VK_HubGui")
    if old then old:Destroy() end
end)

local SG = Instance.new("ScreenGui")
SG.Name           = "VK_HubGui"
SG.ResetOnSpawn   = false
SG.IgnoreGuiInset = true
SG.DisplayOrder   = 9999
SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
SG.Parent         = PlayerGui

local MF = Instance.new("Frame", SG)
MF.Name             = "Main"
MF.Size             = UDim2.new(0, 288, 0, 600)
MF.Position         = UDim2.new(0, 14, 0.06, 0)
MF.BackgroundColor3 = Color3.fromRGB(16, 13, 4)
MF.BorderSizePixel  = 0
MF.ZIndex           = 100
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", MF)
stroke.Color = Color3.fromRGB(255, 210, 0); stroke.Thickness = 2

-- Header
local HD = Instance.new("Frame", MF)
HD.Size = UDim2.new(1,0,0,52); HD.BackgroundColor3 = Color3.fromRGB(24,19,0)
HD.BorderSizePixel = 0; HD.ZIndex = 101
Instance.new("UICorner", HD).CornerRadius = UDim.new(0,10)

local ac = Instance.new("Frame", HD)
ac.Size = UDim2.new(1,0,0,2); ac.Position = UDim2.new(0,0,1,-2)
ac.BackgroundColor3 = Color3.fromRGB(255,210,0); ac.BorderSizePixel = 0; ac.ZIndex = 102

local lg = Instance.new("ImageLabel", HD)
lg.Size = UDim2.new(0,34,0,34); lg.Position = UDim2.new(0,8,0.5,-17)
lg.BackgroundTransparency = 1; lg.Image = "rbxassetid://103324203833614"
lg.ScaleType = Enum.ScaleType.Fit; lg.ZIndex = 102

local tl = Instance.new("TextLabel", HD)
tl.Size = UDim2.new(1,-52,1,0); tl.Position = UDim2.new(0,48,0,0)
tl.BackgroundTransparency = 1; tl.Text = "VKontakte Knockout Hub"
tl.TextColor3 = Color3.fromRGB(255,210,0); tl.TextSize = 12
tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 102

-- Drag touch
local dragging, dragStart, startPos = false, nil, nil
HD.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = MF.Position
    end
end)
HD.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMoved then
        local d = i.Position - dragStart
        MF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                 startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ScrollFrame
local SF = Instance.new("ScrollingFrame", MF)
SF.Size = UDim2.new(1,-8,1,-58); SF.Position = UDim2.new(0,4,0,56)
SF.BackgroundTransparency = 1; SF.ScrollBarThickness = 5
SF.ScrollBarImageColor3 = Color3.fromRGB(255,210,0)
SF.CanvasSize = UDim2.new(0,0,0,0); SF.AutomaticCanvasSize = Enum.AutomaticSize.Y
SF.BorderSizePixel = 0; SF.ZIndex = 101; SF.ScrollingDirection = Enum.ScrollingDirection.Y
Instance.new("UIListLayout", SF).Padding = UDim.new(0,5)
local pd = Instance.new("UIPadding", SF)
pd.PaddingTop = UDim.new(0,5); pd.PaddingLeft = UDim.new(0,5); pd.PaddingRight = UDim.new(0,5)

-- Minimizar duplo toque / botao direito
local lastTap = 0; local minimized = false
HD.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTap < 0.35 then
            minimized = not minimized; SF.Visible = not minimized
            MF.Size = minimized and UDim2.new(0,288,0,52) or UDim2.new(0,288,0,600)
        end
        lastTap = now
    elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
        minimized = not minimized; SF.Visible = not minimized
        MF.Size = minimized and UDim2.new(0,288,0,52) or UDim2.new(0,288,0,600)
    end
end)

-- Toggle factory
local function newToggle(label, desc, getState, onSet)
    local row = Instance.new("Frame", SF)
    row.Size = UDim2.new(1,0,0,56); row.BackgroundColor3 = Color3.fromRGB(26,22,7)
    row.BorderSizePixel = 0; row.ZIndex = 102
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local nl = Instance.new("TextLabel", row)
    nl.Size = UDim2.new(1,-72,0,22); nl.Position = UDim2.new(0,10,0,7)
    nl.BackgroundTransparency = 1; nl.Text = label
    nl.TextColor3 = Color3.fromRGB(235,235,235); nl.TextSize = 13
    nl.Font = Enum.Font.GothamBold; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.ZIndex = 103

    local dl = Instance.new("TextLabel", row)
    dl.Size = UDim2.new(1,-72,0,16); dl.Position = UDim2.new(0,10,0,31)
    dl.BackgroundTransparency = 1; dl.Text = desc
    dl.TextColor3 = Color3.fromRGB(130,110,50); dl.TextSize = 10
    dl.Font = Enum.Font.Gotham; dl.TextXAlignment = Enum.TextXAlignment.Left; dl.ZIndex = 103

    local bg = Instance.new("Frame", row)
    bg.Size = UDim2.new(0,50,0,28); bg.Position = UDim2.new(1,-60,0.5,-14)
    bg.BorderSizePixel = 0; bg.ZIndex = 103
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

    local dot = Instance.new("Frame", bg)
    dot.Size = UDim2.new(0,22,0,22); dot.BorderSizePixel = 0
    dot.BackgroundColor3 = Color3.fromRGB(215,215,215); dot.ZIndex = 104
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local function refresh()
        local on = getState()
        bg.BackgroundColor3 = on and Color3.fromRGB(220,170,0) or Color3.fromRGB(50,45,18)
        dot.Position = on and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11)
    end
    refresh()

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 105
    btn.MouseButton1Click:Connect(function()
        onSet(not getState()); refresh()
    end)
end

-- Criar toggles
newToggle("ESP + Mira",      "Nome, dist, seta e alerta de mira",
    function() return CFG.esp end,          function(v) CFG.esp = v end)
newToggle("Speed Hack",      "Velocidade 50 studs/s",
    function() return CFG.speed end,        function(v) CFG.speed = v end)
newToggle("Jump Power",      "Pulo muito mais alto",
    function() return CFG.jumpPower end,    function(v) CFG.jumpPower = v end)
newToggle("Infinite Jump",   "Pula infinitamente no ar",
    function() return CFG.infJump end,      function(v) CFG.infJump = v end)
newToggle("Knockback Boost", "Empurra forte ao encostar",
    function() return CFG.knockback end,    function(v) CFG.knockback = v end)
newToggle("Auto Kill",       "Empurra todos no range auto",
    function() return CFG.autoKill end,     function(v) CFG.autoKill = v end)
newToggle("Anti Knockback",  "Nao sai do lugar quando batem",
    function() return CFG.antiKnockback end,
    function(v)
        CFG.antiKnockback = v
        if v then startAntiKB() else stopAntiKB() end
    end)
newToggle("Noclip",          "Atravessa paredes",
    function() return CFG.noclip end,       function(v) CFG.noclip = v end)

-- Separador
local sep = Instance.new("Frame", SF)
sep.Size = UDim2.new(1,0,0,1); sep.BackgroundColor3 = Color3.fromRGB(80,65,0)
sep.BorderSizePixel = 0; sep.ZIndex = 102

-- Painel TP Obby
local tpRow = Instance.new("Frame", SF)
tpRow.Size = UDim2.new(1,0,0,76); tpRow.BackgroundColor3 = Color3.fromRGB(26,20,0)
tpRow.BorderSizePixel = 0; tpRow.ZIndex = 102
Instance.new("UICorner", tpRow).CornerRadius = UDim.new(0,8)

local tpH = Instance.new("TextLabel", tpRow)
tpH.Size = UDim2.new(1,-10,0,22); tpH.Position = UDim2.new(0,10,0,5)
tpH.BackgroundTransparency = 1; tpH.Text = "Teleporte ao Fim do Obby"
tpH.TextColor3 = Color3.fromRGB(255,210,0); tpH.TextSize = 12
tpH.Font = Enum.Font.GothamBold; tpH.TextXAlignment = Enum.TextXAlignment.Left; tpH.ZIndex = 103

local tpSt = Instance.new("TextLabel", tpRow)
tpSt.Size = UDim2.new(1,-10,0,14); tpSt.Position = UDim2.new(0,10,0,26)
tpSt.BackgroundTransparency = 1; tpSt.Text = "Aguardando..."
tpSt.TextColor3 = Color3.fromRGB(160,140,60); tpSt.TextSize = 10
tpSt.Font = Enum.Font.Gotham; tpSt.TextXAlignment = Enum.TextXAlignment.Left; tpSt.ZIndex = 103

local bBox = Instance.new("Frame", tpRow)
bBox.Size = UDim2.new(1,-16,0,28); bBox.Position = UDim2.new(0,8,0,44)
bBox.BackgroundTransparency = 1; bBox.ZIndex = 103

local scBtn = Instance.new("TextButton", bBox)
scBtn.Size = UDim2.new(0.48,0,1,0); scBtn.BackgroundColor3 = Color3.fromRGB(115,88,0)
scBtn.BorderSizePixel = 0; scBtn.Text = "Scanear"
scBtn.TextColor3 = Color3.fromRGB(255,255,255); scBtn.TextSize = 12
scBtn.Font = Enum.Font.GothamBold; scBtn.ZIndex = 104
Instance.new("UICorner", scBtn).CornerRadius = UDim.new(0,6)

local tpBt = Instance.new("TextButton", bBox)
tpBt.Size = UDim2.new(0.48,0,1,0); tpBt.Position = UDim2.new(0.52,0,0,0)
tpBt.BackgroundColor3 = Color3.fromRGB(45,118,50); tpBt.BorderSizePixel = 0
tpBt.Text = "Teleportar"; tpBt.TextColor3 = Color3.fromRGB(255,255,255)
tpBt.TextSize = 12; tpBt.Font = Enum.Font.GothamBold; tpBt.ZIndex = 104
Instance.new("UICorner", tpBt).CornerRadius = UDim.new(0,6)

scBtn.MouseButton1Click:Connect(function()
    endSearched = false; cachedEnd = nil
    tpSt.Text = "Escaneando..."; tpSt.TextColor3 = Color3.fromRGB(255,200,50)
    task.wait(0.3)
    local f = getEnd()
    if f then
        tpSt.Text = "Achado: " .. f.Name
        tpSt.TextColor3 = Color3.fromRGB(100,220,100)
    else
        tpSt.Text = "Nao encontrado"
        tpSt.TextColor3 = Color3.fromRGB(220,80,80)
    end
end)

tpBt.MouseButton1Click:Connect(function()
    local ok = doTP(tpSt)
    if ok then
        tpSt.Text = "Teleportado!"
        tpSt.TextColor3 = Color3.fromRGB(100,220,100)
    end
end)

task.spawn(function()
    task.wait(3)
    local f = getEnd()
    if f then
        tpSt.Text = "Detectado: " .. f.Name
        tpSt.TextColor3 = Color3.fromRGB(100,220,100)
    else
        tpSt.Text = "Clique em Scanear"
        tpSt.TextColor3 = Color3.fromRGB(200,150,40)
    end
end)

local tip = Instance.new("TextLabel", SF)
tip.Size = UDim2.new(1,0,0,22); tip.BackgroundTransparency = 1
tip.Text = "Duplo toque no titulo = minimizar  |  Arraste para mover"
tip.TextColor3 = Color3.fromRGB(88,75,18); tip.TextSize = 9
tip.Font = Enum.Font.Gotham; tip.TextWrapped = true; tip.ZIndex = 102

print("VKontakte Knockout Hub v6 - OK!")
