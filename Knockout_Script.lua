--[[
    VKontakte Knockout Hub v5
    Delta Mobile | Anti-KB real | Knockback forte | ESP mira
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris           = game:GetService("Debris")
local LP               = Players.LocalPlayer
local PlayerGui        = LP:WaitForChild("PlayerGui")

-- ========================
--  CONFIG
-- ========================
local CFG = {
    esp           = true,
    speed         = false, speedVal  = 50,
    jumpPower     = false, jumpVal   = 100,
    infJump       = false,
    knockback     = false, kbPower   = 300,
    autoKill      = false, akRange   = 22,
    antiKnockback = false,
    noclip        = false,
}

-- ========================
--  HELPERS
-- ========================
local function chr()  return LP.Character end
local function root()
    local c = chr(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function hum()
    local c = chr(); return c and c:FindFirstChildOfClass("Humanoid")
end

-- ========================
--  ANTI KNOCKBACK
--  Trava CFrame X/Z a cada RenderStepped
--  Detecta knockback por velocidade alta e restaura posicao
-- ========================
local akConn       = nil
local lockedCF     = nil
local lastSafePos  = nil

local function startAntiKB()
    if akConn then akConn:Disconnect() akConn = nil end

    -- Salva posicao inicial
    local r = root()
    if r then
        lockedCF    = r.CFrame
        lastSafePos = r.Position
    end

    akConn = RunService.RenderStepped:Connect(function()
        if not CFG.antiKnockback then
            akConn:Disconnect(); akConn = nil
            lockedCF = nil; lastSafePos = nil
            return
        end

        local r2 = root()
        if not r2 then return end

        local curPos = r2.Position
        local curCF  = r2.CFrame

        -- Detecta se foi empurrado (deslocamento > 1.5 studs em 1 frame)
        if lastSafePos then
            local moved = Vector2.new(
                curPos.X - lastSafePos.X,
                curPos.Z - lastSafePos.Z
            ).Magnitude

            if moved > 1.5 then
                -- Restaura posicao segura (mantendo Y para nao travar no chao)
                local safe = Vector3.new(
                    lastSafePos.X,
                    curPos.Y,
                    lastSafePos.Z
                )
                pcall(function()
                    r2.CFrame = CFrame.new(safe) * (curCF - curCF.Position)
                end)
                -- Zera velocidade horizontal
                pcall(function()
                    r2.AssemblyLinearVelocity = Vector3.new(
                        0,
                        r2.AssemblyLinearVelocity.Y,
                        0
                    )
                end)
                return -- nao atualiza lastSafePos para manter posicao
            end
        end

        -- Movimento normal: atualiza posicao segura
        lastSafePos = curPos
        lockedCF    = curCF
    end)
end

local function stopAntiKB()
    if akConn then akConn:Disconnect(); akConn = nil end
    lockedCF = nil; lastSafePos = nil
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if CFG.antiKnockback then startAntiKB() end
end)

-- ========================
--  KNOCKBACK
--  Tenta 3 metodos ao mesmo tempo
-- ========================
local function pushTarget(tr, mr)
    local dir  = (tr.Position - mr.Position).Unit
    local vel  = dir * CFG.kbPower + Vector3.new(0, CFG.kbPower * 0.55, 0)

    -- Metodo 1: BodyVelocity (mais forte)
    pcall(function()
        for _, bv in ipairs(tr:GetChildren()) do
            if bv:IsA("BodyVelocity") then bv:Destroy() end
        end
        local bv    = Instance.new("BodyVelocity")
        bv.Velocity = vel
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.P        = 1e9
        bv.Parent   = tr
        Debris:AddItem(bv, 0.2)
    end)

    -- Metodo 2: Assembly
    pcall(function()
        tr.AssemblyLinearVelocity = vel
    end)

    -- Metodo 3: LinearVelocity (novo engine)
    pcall(function()
        for _, lv in ipairs(tr:GetChildren()) do
            if lv:IsA("LinearVelocity") then lv:Destroy() end
        end
        local att = Instance.new("Attachment", tr)
        local lv  = Instance.new("LinearVelocity")
        lv.Attachment0        = att
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.MaxForce           = 1e9
        lv.RelativeTo         = Enum.ActuatorRelativeTo.World
        lv.VectorVelocity     = vel
        lv.Parent             = tr
        Debris:AddItem(lv,  0.2)
        Debris:AddItem(att, 0.25)
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
-- ========================
task.spawn(function()
    while true do
        task.wait(0.1)
        local mr = root()
        if mr and (CFG.autoKill or CFG.knockback) then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    local c = p.Character
                    if c then
                        local r = c:FindFirstChild("HumanoidRootPart")
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if r and h and h.Health > 0 then
                            local d = (mr.Position - r.Position).Magnitude
                            if CFG.autoKill and d <= CFG.akRange then
                                pushTarget(r, mr)
                            elseif CFG.knockback and not CFG.autoKill and d <= 5 then
                                pushTarget(r, mr)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ========================
--  ESP + MIRA
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
    cleanESP(player.Name)

    -- BillboardGui
    local bb = Instance.new("BillboardGui", espFolder)
    bb.Name        = "BB_" .. player.Name
    bb.AlwaysOnTop = true
    bb.Size        = UDim2.new(0, 220, 0, 90)
    bb.StudsOffset = Vector3.new(0, 5.5, 0)

    -- Nome
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
    dL.Position   = UDim2.new(0, 0, 0, 22)
    dL.Font       = Enum.Font.Gotham
    dL.TextSize   = 11
    dL.TextColor3 = Color3.fromRGB(220, 220, 220)
    dL.TextStrokeTransparency = 0
    dL.Text       = "0m"

    -- Status mira
    local aL = Instance.new("TextLabel", bb)
    aL.BackgroundTransparency = 1
    aL.Size       = UDim2.new(1, 0, 0, 20)
    aL.Position   = UDim2.new(0, 0, 0, 40)
    aL.Font       = Enum.Font.GothamBold
    aL.TextSize   = 12
    aL.TextStrokeTransparency = 0
    aL.Text       = "Mira: livre"
    aL.TextColor3 = Color3.fromRGB(100, 230, 100)

    -- Seta de direcao do olhar
    local arL = Instance.new("TextLabel", bb)
    arL.BackgroundTransparency = 1
    arL.Size       = UDim2.new(0, 30, 0, 30)
    arL.Position   = UDim2.new(0.5, -15, 0, -34)
    arL.Font       = Enum.Font.GothamBold
    arL.TextSize   = 26
    arL.TextStrokeTransparency = 0.3
    arL.Text       = "▲"
    arL.TextColor3 = Color3.fromRGB(255, 215, 0)

    -- SelectionBox
    local sel = Instance.new("SelectionBox", espFolder)
    sel.Name                = "SEL_" .. player.Name
    sel.LineThickness       = 0.06
    sel.Color3              = Color3.fromRGB(255, 215, 0)
    sel.SurfaceTransparency = 1

    -- Linha neon 3D
    local beam = Instance.new("Part", workspace)
    beam.Name        = "AIM_" .. player.Name
    beam.Anchored    = true
    beam.CanCollide  = false
    beam.CastShadow  = false
    beam.Transparency = 0.15
    beam.BrickColor  = BrickColor.new("Bright red")
    beam.Material    = Enum.Material.Neon
    beam.Size        = Vector3.new(0.08, 0.08, 16)

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not bb or not bb.Parent then
            conn:Disconnect()
            pcall(function() beam:Destroy() end)
            pcall(function() sel:Destroy() end)
            return
        end

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

        bb.Adornee  = pr
        bb.Enabled  = true
        sel.Adornee = c
        dL.Text     = math.floor((mr.Position - pr.Position).Magnitude) .. "m"

        -- Direcao do olhar
        local look  = pr.CFrame.LookVector
        local tip   = pr.Position + look * 50

        -- Detecta alvo da mira
        local target     = nil
        local targetDist = 12
        for _, op in ipairs(Players:GetPlayers()) do
            if op ~= player then
                local oc = op.Character
                if oc then
                    local or2 = oc:FindFirstChild("HumanoidRootPart")
                    if or2 then
                        local d = (tip - or2.Position).Magnitude
                        if d < targetDist then
                            targetDist = d
                            target     = op
                        end
                    end
                end
            end
        end

        -- Visual por estado
        local t = math.sin(tick() * 10) > 0
        if target == LP then
            aL.Text        = t and ">> MIRANDO EM VOCE <<" or "!! CUIDADO !!"
            aL.TextColor3  = Color3.fromRGB(255, 30, 30)
            arL.TextColor3 = Color3.fromRGB(255, 30, 30)
            sel.Color3     = Color3.fromRGB(255, 30, 30)
            beam.BrickColor = BrickColor.new("Bright red")
        elseif target then
            aL.Text        = "Mira: " .. target.Name
            aL.TextColor3  = Color3.fromRGB(255, 160, 30)
            arL.TextColor3 = Color3.fromRGB(255, 160, 30)
            sel.Color3     = Color3.fromRGB(255, 160, 30)
            beam.BrickColor = BrickColor.new("Neon orange")
        else
            aL.Text        = "Mira: livre"
            aL.TextColor3  = Color3.fromRGB(100, 230, 100)
            arL.TextColor3 = Color3.fromRGB(255, 215, 0)
            sel.Color3     = Color3.fromRGB(255, 215, 0)
            beam.BrickColor = BrickColor.new("Bright red")
        end

        -- Rotacao da seta conforme direcao do olhar projetada na camera
        local camCF = workspace.CurrentCamera.CFrame
        local angle = math.deg(math.atan2(
            look:Dot(camCF.RightVector),
            look:Dot(camCF.LookVector)
        ))
        arL.Rotation = angle

        -- Posiciona linha neon 3D
        beam.Parent = workspace
        beam.CFrame = CFrame.new(pr.Position + look * 8, pr.Position + look * 16)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do task.spawn(makeESP, p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) task.spawn(makeESP, p) end)
Players.PlayerRemoving:Connect(function(p) cleanESP(p.Name) end)

-- ========================
--  TP OBBY
-- ========================
local cachedEnd = nil
local endSearched = false

local function findEnd()
    local keys = {"finish","final","reward","rainbow","prize","goal","win","complete","obbyend"}
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

local function doTP()
    local r = root(); if not r then return false end
    local dest = getEnd()
    if not dest then
        endSearched = false; cachedEnd = nil
        dest = getEnd()
    end
    if dest then
        r.CFrame = CFrame.new(dest.Position + Vector3.new(0, 5, 0))
        return true
    end
    return false
end

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
local st = Instance.new("UIStroke", MF)
st.Color = Color3.fromRGB(255, 210, 0); st.Thickness = 2

-- Header
local HD = Instance.new("Frame", MF)
HD.Size             = UDim2.new(1, 0, 0, 52)
HD.BackgroundColor3 = Color3.fromRGB(24, 19, 0)
HD.BorderSizePixel  = 0
HD.ZIndex           = 101
Instance.new("UICorner", HD).CornerRadius = UDim.new(0, 10)

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
tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left
tl.ZIndex = 102

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
SF.BorderSizePixel = 0; SF.ZIndex = 101
SF.ScrollingDirection = Enum.ScrollingDirection.Y
Instance.new("UIListLayout", SF).Padding = UDim.new(0,5)
local pd = Instance.new("UIPadding", SF)
pd.PaddingTop = UDim.new(0,5); pd.PaddingLeft = UDim.new(0,5); pd.PaddingRight = UDim.new(0,5)

-- Minimizar duplo toque
local lastTap = 0
local minimized = false
HD.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTap < 0.35 then
            minimized = not minimized
            SF.Visible = not minimized
            MF.Size = minimized and UDim2.new(0,288,0,52) or UDim2.new(0,288,0,600)
        end
        lastTap = now
    elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
        minimized = not minimized
        SF.Visible = not minimized
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

-- Toggles
newToggle("ESP + Mira",      "Nome, dist, seta e status de mira",
    function() return CFG.esp end,          function(v) CFG.esp = v end)
newToggle("Speed Hack",      "Velocidade 50 studs/s",
    function() return CFG.speed end,        function(v) CFG.speed = v end)
newToggle("Jump Power",      "Pulo muito mais alto",
    function() return CFG.jumpPower end,    function(v) CFG.jumpPower = v end)
newToggle("Infinite Jump",   "Pula infinitamente no ar",
    function() return CFG.infJump end,      function(v) CFG.infJump = v end)
newToggle("Knockback Boost", "Empurra forte ao encostar (<=5 studs)",
    function() return CFG.knockback end,    function(v) CFG.knockback = v end)
newToggle("Auto Kill",       "Empurra todos no range automaticamente",
    function() return CFG.autoKill end,     function(v) CFG.autoKill = v end)
newToggle("Anti Knockback",  "Nao se move quando batem em voce",
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

-- Painel TP
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
scBtn.BorderSizePixel = 0; scBtn.Text = "Scanear"; scBtn.TextColor3 = Color3.fromRGB(255,255,255)
scBtn.TextSize = 12; scBtn.Font = Enum.Font.GothamBold; scBtn.ZIndex = 104
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
    task.wait(0.2)
    local f = getEnd()
    if f then tpSt.Text = "Achado: "..f.Name; tpSt.TextColor3 = Color3.fromRGB(100,220,100)
    else tpSt.Text = "Nao encontrado"; tpSt.TextColor3 = Color3.fromRGB(220,80,80) end
end)

tpBt.MouseButton1Click:Connect(function()
    if doTP() then tpSt.Text = "Teleportado!"; tpSt.TextColor3 = Color3.fromRGB(100,220,100)
    else tpSt.Text = "Falhou! Scan primeiro"; tpSt.TextColor3 = Color3.fromRGB(220,80,80) end
end)

task.spawn(function()
    task.wait(3)
    local f = getEnd()
    if f then tpSt.Text = "Detectado: "..f.Name; tpSt.TextColor3 = Color3.fromRGB(100,220,100)
    else tpSt.Text = "Clique em Scanear"; tpSt.TextColor3 = Color3.fromRGB(200,150,40) end
end)

local tip = Instance.new("TextLabel", SF)
tip.Size = UDim2.new(1,0,0,22); tip.BackgroundTransparency = 1
tip.Text = "Duplo toque no titulo = minimizar  |  Arraste para mover"
tip.TextColor3 = Color3.fromRGB(88,75,18); tip.TextSize = 9
tip.Font = Enum.Font.Gotham; tip.TextWrapped = true; tip.ZIndex = 102

print("VKontakte Knockout Hub v5 - OK!")
