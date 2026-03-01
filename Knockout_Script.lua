-- VKontakte Knockout Hub
-- Versao compativel com todos os executores

local ok, err = pcall(function()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local LP               = Players.LocalPlayer

-- Config
local CFG = {
    esp           = true,
    speed         = false, speedVal = 50,
    jumpPower     = false, jumpVal  = 100,
    infJump       = false,
    knockback     = false, kbPower  = 150,
    autoKill      = false, akRange  = 20,
    antiKnockback = false,
    noclip        = false,
}

-- Helpers
local function chr()  return LP.Character end
local function root() local c=chr() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()  local c=chr() return c and c:FindFirstChildOfClass("Humanoid") end

local function setVel(part, v)
    pcall(function() part.AssemblyLinearVelocity = v end)
end

-- Limpa GUI antiga
pcall(function()
    local old = CoreGui:FindFirstChild("VK_Hub")
    if old then old:Destroy() end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name          = "VK_Hub"
gui.ResetOnSpawn  = false
gui.Parent        = CoreGui

local main = Instance.new("Frame", gui)
main.Size             = UDim2.new(0, 290, 0, 560)
main.Position         = UDim2.new(0, 20, 0.5, -280)
main.BackgroundColor3 = Color3.fromRGB(18, 15, 5)
main.BorderSizePixel  = 0
main.Active           = true
main.Draggable        = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Color     = Color3.fromRGB(255, 210, 0)
stroke.Thickness = 2

-- Header
local header = Instance.new("Frame", main)
header.Size             = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(25, 20, 0)
header.BorderSizePixel  = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local accent = Instance.new("Frame", header)
accent.Size             = UDim2.new(1, 0, 0, 2)
accent.Position         = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3 = Color3.fromRGB(255, 210, 0)
accent.BorderSizePixel  = 0

local logo = Instance.new("ImageLabel", header)
logo.Size                  = UDim2.new(0, 34, 0, 34)
logo.Position              = UDim2.new(0, 8, 0.5, -17)
logo.BackgroundTransparency = 1
logo.Image                 = "rbxassetid://103324203833614"
logo.ScaleType             = Enum.ScaleType.Fit

local title = Instance.new("TextLabel", header)
title.Size               = UDim2.new(1, -52, 1, 0)
title.Position           = UDim2.new(0, 48, 0, 0)
title.BackgroundTransparency = 1
title.Text               = "VKontakte Knockout Hub"
title.TextColor3         = Color3.fromRGB(255, 210, 0)
title.TextSize           = 13
title.Font               = Enum.Font.GothamBold
title.TextXAlignment     = Enum.TextXAlignment.Left

-- Scroll
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size                 = UDim2.new(1, -8, 1, -56)
scroll.Position             = UDim2.new(0, 4, 0, 54)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness   = 3
scroll.CanvasSize           = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
scroll.BorderSizePixel      = 0

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 5)

local pad = Instance.new("UIPadding", scroll)
pad.PaddingTop   = UDim.new(0, 4)
pad.PaddingLeft  = UDim.new(0, 4)
pad.PaddingRight = UDim.new(0, 4)

-- Toggle factory
local function newToggle(labelTxt, descTxt, getState, setState)
    local row = Instance.new("Frame", scroll)
    row.Size             = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(28, 24, 8)
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(1, -68, 0, 20)
    lbl.Position           = UDim2.new(0, 10, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Text               = labelTxt
    lbl.TextColor3         = Color3.fromRGB(230, 230, 230)
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", row)
    sub.Size               = UDim2.new(1, -68, 0, 16)
    sub.Position           = UDim2.new(0, 10, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text               = descTxt
    sub.TextColor3         = Color3.fromRGB(140, 120, 60)
    sub.TextSize           = 10
    sub.Font               = Enum.Font.Gotham
    sub.TextXAlignment     = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", row)
    bg.Size             = UDim2.new(0, 44, 0, 22)
    bg.Position         = UDim2.new(1, -54, 0.5, -11)
    bg.BorderSizePixel  = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", bg)
    dot.Size             = UDim2.new(0, 16, 0, 16)
    dot.BorderSizePixel  = 0
    dot.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local on = getState()
        bg.BackgroundColor3 = on and Color3.fromRGB(220, 170, 0) or Color3.fromRGB(55, 50, 25)
        dot.Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    end
    refresh()

    local btn = Instance.new("TextButton", row)
    btn.Size               = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.ZIndex             = 5

    btn.MouseButton1Click:Connect(function()
        setState(not getState())
        refresh()
    end)
end

-- Criar toggles
newToggle("ESP",            "Ve jogadores atraves das paredes",
    function() return CFG.esp end,
    function(v) CFG.esp = v end)

newToggle("Speed Hack",     "Velocidade 50 studs/s",
    function() return CFG.speed end,
    function(v) CFG.speed = v end)

newToggle("Jump Power",     "Pulo mais alto",
    function() return CFG.jumpPower end,
    function(v) CFG.jumpPower = v end)

newToggle("Infinite Jump",  "Pula infinitamente no ar",
    function() return CFG.infJump end,
    function(v) CFG.infJump = v end)

newToggle("Knockback Boost","Empurra inimigos com forca",
    function() return CFG.knockback end,
    function(v) CFG.knockback = v end)

newToggle("Auto Kill",      "Knockback automatico em inimigos proximos",
    function() return CFG.autoKill end,
    function(v) CFG.autoKill = v end)

newToggle("Anti Knockback", "Bloqueia empurroes recebidos",
    function() return CFG.antiKnockback end,
    function(v) CFG.antiKnockback = v end)

newToggle("Noclip",         "Atravessa paredes",
    function() return CFG.noclip end,
    function(v) CFG.noclip = v end)

-- Separador
local sep = Instance.new("Frame", scroll)
sep.Size             = UDim2.new(1, 0, 0, 1)
sep.BackgroundColor3 = Color3.fromRGB(80, 65, 0)
sep.BorderSizePixel  = 0

-- Painel TP
local tpPanel = Instance.new("Frame", scroll)
tpPanel.Size             = UDim2.new(1, 0, 0, 72)
tpPanel.BackgroundColor3 = Color3.fromRGB(28, 22, 0)
tpPanel.BorderSizePixel  = 0
Instance.new("UICorner", tpPanel).CornerRadius = UDim.new(0, 8)

local tpTitle = Instance.new("TextLabel", tpPanel)
tpTitle.Size               = UDim2.new(1, -10, 0, 20)
tpTitle.Position           = UDim2.new(0, 10, 0, 5)
tpTitle.BackgroundTransparency = 1
tpTitle.Text               = "Teleporte ao Fim do Obby"
tpTitle.TextColor3         = Color3.fromRGB(255, 210, 0)
tpTitle.TextSize           = 12
tpTitle.Font               = Enum.Font.GothamBold
tpTitle.TextXAlignment     = Enum.TextXAlignment.Left

local tpStatus = Instance.new("TextLabel", tpPanel)
tpStatus.Size               = UDim2.new(1, -10, 0, 13)
tpStatus.Position           = UDim2.new(0, 10, 0, 24)
tpStatus.BackgroundTransparency = 1
tpStatus.Text               = "Aguardando scan..."
tpStatus.TextColor3         = Color3.fromRGB(160, 140, 60)
tpStatus.TextSize           = 10
tpStatus.Font               = Enum.Font.Gotham
tpStatus.TextXAlignment     = Enum.TextXAlignment.Left

local btnBox = Instance.new("Frame", tpPanel)
btnBox.Size               = UDim2.new(1, -16, 0, 24)
btnBox.Position           = UDim2.new(0, 8, 0, 42)
btnBox.BackgroundTransparency = 1

local scanBtn = Instance.new("TextButton", btnBox)
scanBtn.Size             = UDim2.new(0.48, 0, 1, 0)
scanBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 0)
scanBtn.BorderSizePixel  = 0
scanBtn.Text             = "Scanear"
scanBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize         = 11
scanBtn.Font             = Enum.Font.GothamBold
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 5)

local tpBtn = Instance.new("TextButton", btnBox)
tpBtn.Size             = UDim2.new(0.48, 0, 1, 0)
tpBtn.Position         = UDim2.new(0.52, 0, 0, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 55)
tpBtn.BorderSizePixel  = 0
tpBtn.Text             = "Teleportar"
tpBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
tpBtn.TextSize         = 11
tpBtn.Font             = Enum.Font.GothamBold
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

-- Dica
local tip = Instance.new("TextLabel", scroll)
tip.Size               = UDim2.new(1, 0, 0, 18)
tip.BackgroundTransparency = 1
tip.Text               = "Tecla T = TP rapido  |  Botao direito no titulo = minimizar"
tip.TextColor3         = Color3.fromRGB(90, 78, 18)
tip.TextSize           = 9
tip.Font               = Enum.Font.Gotham
tip.TextWrapped        = true

-- Minimizar
local minimized = false
header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        minimized = not minimized
        scroll.Visible = not minimized
        main.Size = minimized and UDim2.new(0, 290, 0, 50) or UDim2.new(0, 290, 0, 560)
    end
end)

-- ========================
-- LOGICA
-- ========================

-- ESP
local espFolder = Instance.new("Folder")
espFolder.Name   = "VK_ESP_Folder"
espFolder.Parent = CoreGui

local function makeESP(player)
    if player == LP then return end
    local old = espFolder:FindFirstChild(player.Name)
    if old then old:Destroy() end

    local bb = Instance.new("BillboardGui", espFolder)
    bb.Name        = player.Name
    bb.AlwaysOnTop = true
    bb.Size        = UDim2.new(0, 150, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)

    local n = Instance.new("TextLabel", bb)
    n.BackgroundTransparency = 1
    n.Size       = UDim2.new(1, 0, 0.55, 0)
    n.Font       = Enum.Font.GothamBold
    n.TextSize   = 13
    n.TextColor3 = Color3.fromRGB(255, 215, 0)
    n.TextStrokeTransparency = 0
    n.Text       = player.Name

    local d = Instance.new("TextLabel", bb)
    d.BackgroundTransparency = 1
    d.Size       = UDim2.new(1, 0, 0.45, 0)
    d.Position   = UDim2.new(0, 0, 0.55, 0)
    d.Font       = Enum.Font.Gotham
    d.TextSize   = 11
    d.TextColor3 = Color3.fromRGB(255, 255, 255)
    d.TextStrokeTransparency = 0
    d.Text       = "0m"

    RunService.RenderStepped:Connect(function()
        if not bb or not bb.Parent then return end
        if not CFG.esp then bb.Enabled = false return end
        local c = player.Character
        if not c then bb.Enabled = false return end
        local pr = c:FindFirstChild("HumanoidRootPart")
        local mr = root()
        if not pr or not mr then bb.Enabled = false return end
        bb.Adornee = pr
        bb.Enabled = true
        d.Text = math.floor((mr.Position - pr.Position).Magnitude) .. "m"
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(makeESP, p)
end
Players.PlayerAdded:Connect(function(p) task.wait(1) task.spawn(makeESP, p) end)
Players.PlayerRemoving:Connect(function(p)
    local b = espFolder:FindFirstChild(p.Name)
    if b then b:Destroy() end
end)

-- Speed / Jump
RunService.Heartbeat:Connect(function()
    local h = hum()
    if not h then return end
    h.WalkSpeed = CFG.speed     and CFG.speedVal  or 16
    h.JumpPower = CFG.jumpPower and CFG.jumpVal   or 50
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not CFG.infJump then return end
    local h = hum()
    if h and h.FloorMaterial == Enum.Material.Air then
        h:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti Knockback
RunService.Heartbeat:Connect(function()
    if not CFG.antiKnockback then return end
    local r = root()
    if not r then return end
    local y = 0
    pcall(function() y = r.AssemblyLinearVelocity.Y end)
    setVel(r, Vector3.new(0, y, 0))
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c = chr()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- Knockback / Auto Kill
local function doKnockback(targetRoot, myRoot)
    local dir = (targetRoot.Position - myRoot.Position).Unit
    setVel(targetRoot, Vector3.new(
        dir.X * CFG.kbPower,
        CFG.kbPower * 0.4,
        dir.Z * CFG.kbPower
    ))
end

task.spawn(function()
    while true do
        task.wait(0.35)
        if CFG.autoKill then
            local mr = root()
            if mr then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP then
                        local c = p.Character
                        if c then
                            local r = c:FindFirstChild("HumanoidRootPart")
                            local h = c:FindFirstChildOfClass("Humanoid")
                            if r and h and h.Health > 0 then
                                if (mr.Position - r.Position).Magnitude <= CFG.akRange then
                                    doKnockback(r, mr)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- TP Obby
local cachedEnd    = nil
local endSearched  = false

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
    local r = root()
    if not r then return false end
    local dest = getEnd()
    if not dest then
        endSearched = false
        cachedEnd   = nil
        dest = getEnd()
    end
    if dest then
        r.CFrame = CFrame.new(dest.Position + Vector3.new(0, 5, 0))
        return true
    end
    return false
end

scanBtn.MouseButton1Click:Connect(function()
    endSearched = false
    cachedEnd   = nil
    tpStatus.Text       = "Escaneando..."
    tpStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
    task.wait(0.2)
    local f = getEnd()
    if f then
        tpStatus.Text       = "Achado: " .. f.Name
        tpStatus.TextColor3 = Color3.fromRGB(100, 220, 100)
    else
        tpStatus.Text       = "Nao encontrado"
        tpStatus.TextColor3 = Color3.fromRGB(220, 80, 80)
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    if doTP() then
        tpStatus.Text       = "Teleportado!"
        tpStatus.TextColor3 = Color3.fromRGB(100, 220, 100)
    else
        tpStatus.Text       = "Falhou! Faca scan primeiro"
        tpStatus.TextColor3 = Color3.fromRGB(220, 80, 80)
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.T then doTP() end
end)

task.spawn(function()
    task.wait(3)
    local f = getEnd()
    if f then
        tpStatus.Text       = "Detectado: " .. f.Name
        tpStatus.TextColor3 = Color3.fromRGB(100, 220, 100)
    else
        tpStatus.Text       = "Clique em Scanear"
        tpStatus.TextColor3 = Color3.fromRGB(200, 150, 40)
    end
end)

end) -- fim do pcall

if not ok then
    warn("VKontakte Knockout Hub - ERRO: " .. tostring(err))
end
