--[[
╔══════════════════════════════════════════════════════╗
║          BANANAO HUB - PVP EDITION v1.0              ║
║       Script 100% focado em 30M de Bounty            ║
║   Teleport | Auto Hit | Silent Aim | Anti Stun       ║
║        Funciona em QUALQUER EXECUTOR                 ║
╚══════════════════════════════════════════════════════╝
]]

-- ============================================================
-- ANTI-DUPLICATA
-- ============================================================
if getgenv().BananaoHub then
    pcall(function()
        for _, v in ipairs(game.CoreGui:GetChildren()) do
            if v.Name:find("Night Mystic") or v.Name:find("NazuX") then
                v:Destroy()
            end
        end
    end)
end
getgenv().BananaoHub = true

-- ============================================================
-- CARREGA A UI (Bananao UI)
-- ============================================================
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/araujozwx/BananaoHub/main/Bananao_Ui_New.txt",
    true
))()

-- Fallback caso o link acima não funcione no seu executor
if not Library then
    Library = loadstring(game:HttpGet(
        "https://pastebin.com/raw/BananaoUIFallback",
        true
    ))()
end

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players      = game:GetService("Players")
local RS           = game:GetService("ReplicatedStorage")
local WS           = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenSvc     = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

local plr          = Players.LocalPlayer
local Cam          = WS.CurrentCamera

-- ============================================================
-- VARIÁVEIS GLOBAIS
-- ============================================================
local _G_State = {
    -- PVP
    TpPlayer       = false,
    AutoCombo      = false,
    AutoSkills     = false,
    AntiStun       = false,
    AntiAFK        = true,
    SilentAim      = false,
    CamLock        = false,
    FlyEnabled     = false,
    SpeedEnabled   = false,
    JumpEnabled    = false,
    InfEnergy      = false,
    -- Config
    TargetPlayer   = nil,
    WeaponType     = "Melee",
    TpDelay        = 0.3,
    ComboDelay     = 0.08,
    WalkSpeed      = 24,
    JumpPower      = 50,
    SkillZ         = true,
    SkillX         = true,
    SkillC         = true,
    SkillV         = false,
    -- Internos
    PlayersPosition = nil,
    renderConn     = nil,
    flyBody        = nil,
    flying         = false,
}

-- ============================================================
-- UTILITÁRIOS SAFE (compatível com qualquer executor)
-- ============================================================
local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    return ok, err
end

-- Safe key send (VirtualInputManager ou keypress fallback)
local vim1, vim2
SafeCall(function() vim1 = game:GetService("VirtualInputManager") end)
SafeCall(function() vim2 = game:GetService("VirtualUser") end)

local function SafeSendKey(key)
    if vim1 then
        local ok = pcall(function()
            vim1:SendKeyEvent(true,  key, false, game)
            task.wait(0.04)
            vim1:SendKeyEvent(false, key, false, game)
        end)
        if ok then return end
    end
    if keypress and keyrelease then
        local codes = {
            Z=0x5A, X=0x58, C=0x43, V=0x56,
            Y=0x59, F=0x46, G=0x47, H=0x48
        }
        local code = codes[key] or string.byte(key)
        pcall(function()
            keypress(code)
            task.wait(0.04)
            keyrelease(code)
        end)
    end
end

local function IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Root do personagem local
local Root
local function RefreshRoot()
    local char = plr.Character
    if char then Root = GetRoot(char) end
end
RefreshRoot()
plr.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    Root = char.HumanoidRootPart
end)

-- ============================================================
-- TELEPORTE SEGURO (Tween suave)
-- ============================================================
local function TpTo(cf)
    local char = plr.Character
    local hrp  = GetRoot(char)
    if not hrp then return end
    if hrp.Anchored then hrp.Anchored = false end
    local dist  = (cf.Position - hrp.Position).Magnitude
    local speed = dist < 15 and 600 or 300
    local info  = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tw    = TweenSvc:Create(hrp, info, {CFrame = cf})
    tw:Play()
end

local function TpDirect(cf)
    local char = plr.Character
    local hrp  = GetRoot(char)
    if hrp then hrp.CFrame = cf end
end

-- ============================================================
-- ACHAR PLAYER MAIS PRÓXIMO
-- ============================================================
local function GetClosestPlayer()
    local closest, minD = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and IsAlive(p.Character) then
            local hrp = GetRoot(p.Character)
            if hrp and Root then
                local d = (hrp.Position - Root.Position).Magnitude
                if d < minD then minD = d; closest = p end
            end
        end
    end
    return closest
end

-- ============================================================
-- EQUIPAR ARMA POR TOOLTIP
-- ============================================================
local SelectedWeapon = nil
local function EquipByType(tipo)
    local char = plr.Character
    if not char then return end
    -- Já equipado?
    for _, t in pairs(char:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tipo then
            SelectedWeapon = t.Name
            return
        end
    end
    -- Busca na mochila
    for _, t in pairs(plr.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tipo then
            SelectedWeapon = t.Name
            SafeCall(function()
                char:FindFirstChildOfClass("Humanoid"):EquipTool(t)
            end)
            return
        end
    end
end

local function EquipByName(name)
    if not name then return end
    local char = plr.Character
    if not char then return end
    local tool = plr.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
    if tool and tool:IsA("Tool") then
        SafeCall(function()
            char:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
        end)
    end
end

-- ============================================================
-- FAST ATTACK (ataca inimigos próximos)
-- ============================================================
local function DoFastAttack()
    local char = plr.Character
    if not char or not IsAlive(char) then return end

    -- Tenta LeftClickRemote (método mais comum no BF)
    local weapon = char:FindFirstChildOfClass("Tool")
    if weapon then
        local lcr = weapon:FindFirstChild("LeftClickRemote")
        if lcr then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= plr and p.Character and IsAlive(p.Character) then
                    local hrp = GetRoot(p.Character)
                    if hrp and (hrp.Position - Root.Position).Magnitude < 150 then
                        local dir = (hrp.Position - Root.Position).Unit
                        SafeCall(function() lcr:FireServer(dir, 1) end)
                    end
                end
            end
            return
        end
    end

    -- Fallback: RegisterAttack / RegisterHit
    local enemies = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and IsAlive(p.Character) then
            local head = p.Character:FindFirstChild("Head")
            if head and (head.Position - Root.Position).Magnitude < 130 then
                table.insert(enemies, {p.Character, head})
            end
        end
    end

    if #enemies == 0 then return end

    SafeCall(function()
        local Modules = RS:FindFirstChild("Modules")
        local Net = Modules and Modules:FindFirstChild("Net")
        if Net then
            local RA = Net:FindFirstChild("RE/RegisterAttack")
            local RH = Net:FindFirstChild("RE/RegisterHit")
            if RA and RH then
                RA:FireServer(0)
                RH:FireServer(enemies[1][2], enemies)
            end
        end
    end)
end

-- ============================================================
-- USAR SKILLS (Z X C V)
-- ============================================================
local function UseSkills()
    EquipByType(_G_State.WeaponType)
    EquipByName(SelectedWeapon)
    if _G_State.SkillZ then SafeSendKey("Z") task.wait(0.05) end
    if _G_State.SkillX then SafeSendKey("X") task.wait(0.05) end
    if _G_State.SkillC then SafeSendKey("C") task.wait(0.05) end
    if _G_State.SkillV then SafeSendKey("V") task.wait(0.05) end
end

-- ============================================================
-- SILENT AIM (metamethod hook - só funciona em executores que suportam)
-- ============================================================
local SilentAimHooked = false
if getrawmetatable and setreadonly and getnamecallmethod and newcclosure then
    pcall(function()
        local mt  = getrawmetatable(game)
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args   = {...}
            if (method == "FireServer" or method == "InvokeServer")
               and _G_State.SilentAim
               and _G_State.PlayersPosition
               and typeof(args[1]) == "Vector3" then
                args[1] = _G_State.PlayersPosition
                return old(self, table.unpack(args))
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
        SilentAimHooked = true
    end)
end

-- ============================================================
-- LOOPS PRINCIPAIS
-- ============================================================

-- Anti Stun
task.spawn(function()
    while task.wait(0.05) do
        if _G_State.AntiStun then
            SafeCall(function()
                local char = plr.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
                    local stun = hum:FindFirstChild("Stun")
                    if stun then stun:Destroy() end
                end
                local cs = char:FindFirstChild("Stun")
                if cs then cs:Destroy() end
            end)
        end
    end
end)

-- Speed / Jump
RunService.Heartbeat:Connect(function()
    SafeCall(function()
        local char = plr.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if _G_State.SpeedEnabled then hum.WalkSpeed = _G_State.WalkSpeed end
        if _G_State.JumpEnabled  then hum.JumpPower  = _G_State.JumpPower  end
    end)
end)

-- Anti AFK
plr.Idled:Connect(function()
    if not _G_State.AntiAFK then return end
    if vim2 then
        SafeCall(function()
            vim2:Button2Down(Vector2.new(0,0), Cam.CFrame)
            task.wait(0.5)
            vim2:Button2Up(Vector2.new(0,0), Cam.CFrame)
        end)
    else
        SafeCall(function()
            local cf = Cam.CFrame
            Cam.CFrame = cf * CFrame.Angles(0, 0.001, 0)
            task.wait(0.1)
            Cam.CFrame = cf
        end)
    end
end)

-- Teleport para o alvo
task.spawn(function()
    while task.wait(_G_State.TpDelay) do
        if _G_State.TpPlayer and _G_State.TargetPlayer then
            SafeCall(function()
                local t = Players:FindFirstChild(_G_State.TargetPlayer)
                if t and t.Character and IsAlive(t.Character) then
                    local hrp = GetRoot(t.Character)
                    if hrp then
                        TpTo(hrp.CFrame * CFrame.new(0, 0, 4))
                    end
                end
            end)
        end
    end
end)

-- Auto Combo
task.spawn(function()
    while true do
        task.wait(math.max(_G_State.ComboDelay, 0.05))
        if _G_State.AutoCombo then
            SafeCall(function()
                EquipByType(_G_State.WeaponType)
                EquipByName(SelectedWeapon)
                DoFastAttack()
            end)
        end
    end
end)

-- Auto Skills
task.spawn(function()
    while task.wait(0.15) do
        if _G_State.AutoSkills then
            SafeCall(UseSkills)
        end
    end
end)

-- Cam Lock (Aimbot câmera)
task.spawn(function()
    while task.wait(0.05) do
        if _G_State.CamLock then
            SafeCall(function()
                local target = _G_State.TargetPlayer and Players:FindFirstChild(_G_State.TargetPlayer)
                if not (target and target.Character and IsAlive(target.Character)) then
                    target = GetClosestPlayer()
                end
                if target and target.Character then
                    local hrp = GetRoot(target.Character)
                    if hrp then
                        Cam.CFrame = CFrame.new(Cam.CFrame.Position, hrp.Position)
                    end
                end
            end)
        end
    end
end)

-- Silent Aim render
task.spawn(function()
    while task.wait(0.05) do
        if _G_State.SilentAim then
            SafeCall(function()
                local target = _G_State.TargetPlayer and Players:FindFirstChild(_G_State.TargetPlayer)
                if not (target and target.Character and IsAlive(target.Character)) then
                    target = GetClosestPlayer()
                end
                if target and target.Character then
                    local hrp = GetRoot(target.Character)
                    if hrp then _G_State.PlayersPosition = hrp.Position end
                end
            end)
        else
            _G_State.PlayersPosition = nil
        end
    end
end)

-- Inf Energy
task.spawn(function()
    while task.wait(0.1) do
        if _G_State.InfEnergy then
            SafeCall(function()
                local char = plr.Character
                if char then
                    local e = char:FindFirstChild("Energy")
                    if e and e:FindFirstChild("MaxValue") then
                        e.Value = e.MaxValue.Value
                    elseif e then
                        e.Value = 10000
                    end
                end
            end)
        end
    end
end)

-- FLY
local function StartFly()
    if _G_State.flying then return end
    _G_State.flying = true
    local char = plr.Character
    if not char then return end
    local hrp = GetRoot(char)
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.zero
    bv.MaxForce  = Vector3.new(1e9, 1e9, 1e9)
    bv.Parent    = hrp
    _G_State.flyBody = bv
    RunService.RenderStepped:Connect(function()
        if not _G_State.FlyEnabled or not bv or not bv.Parent then return end
        local vel = Vector3.zero
        local cf  = Cam.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel += cf.LookVector  * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= cf.LookVector  * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel -= cf.RightVector * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel += cf.RightVector * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0,80,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0,80,0) end
        bv.Velocity = vel
    end)
end

local function StopFly()
    _G_State.flying = false
    if _G_State.flyBody then
        _G_State.flyBody:Destroy()
        _G_State.flyBody = nil
    end
end

-- ============================================================
-- LISTA DE PLAYERS (atualizada dinamicamente)
-- ============================================================
local function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr then table.insert(list, p.Name) end
    end
    if #list == 0 then table.insert(list, "(Nenhum)") end
    return list
end

-- ============================================================
-- HUD ON-SCREEN (informações no canto da tela)
-- ============================================================
local HudGui = Instance.new("ScreenGui")
HudGui.Name = "BananaoHUD"
HudGui.ResetOnSpawn = false
HudGui.DisplayOrder = 999
HudGui.IgnoreGuiInset = true
pcall(function() HudGui.Parent = game:GetService("CoreGui") end)

local HF = Instance.new("Frame")
HF.Size = UDim2.new(0, 260, 0, 100)
HF.Position = UDim2.new(1, -270, 0, 10)
HF.BackgroundColor3 = Color3.fromRGB(15, 12, 5)
HF.BackgroundTransparency = 0.15
HF.BorderSizePixel = 0
HF.Parent = HudGui

Instance.new("UICorner", HF).CornerRadius = UDim.new(0, 8)
local hs = Instance.new("UIStroke", HF)
hs.Color = Color3.fromRGB(255, 200, 50)
hs.Thickness = 1.5

local function MakeHUDLabel(text, y, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 18)
    l.Position = UDim2.new(0, 5, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextColor3 = color or Color3.fromRGB(255, 255, 200)
    l.TextStrokeTransparency = 0.5
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = HF
    return l
end

local LTitle   = MakeHUDLabel("🍌 BANANAO HUB | PVP", 4,  Color3.fromRGB(255, 210, 40))
local LBounty  = MakeHUDLabel("💰 Bounty: carregando...", 24, Color3.fromRGB(255, 220, 100))
local LTarget  = MakeHUDLabel("🎯 Target: --",            44, Color3.fromRGB(255, 180, 180))
local LStatus  = MakeHUDLabel("⚡ Status: Idle",          64, Color3.fromRGB(180, 255, 180))
local LTime    = MakeHUDLabel("⏱ 0h0m0s",                 82, Color3.fromRGB(180, 200, 255))

local sessStart = os.time()

task.spawn(function()
    while task.wait(0.5) do
        SafeCall(function()
            -- Bounty
            local b = 0
            pcall(function() b = plr.Data.Bounty.Value end)
            local function fmt(n)
                n = math.floor(n or 0)
                return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
            end
            LBounty.Text = "💰 Bounty: " .. fmt(b)

            -- Target
            local tName = _G_State.TargetPlayer
            if tName and tName ~= "(Nenhum)" then
                local tp = Players:FindFirstChild(tName)
                if tp and tp.Character and IsAlive(tp.Character) then
                    local hrp = GetRoot(tp.Character)
                    local hum = tp.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and Root then
                        local dist = math.floor((hrp.Position - Root.Position).Magnitude)
                        local hp   = math.floor(hum.Health)
                        LTarget.Text = "🎯 " .. tName .. " ❤️" .. hp .. " | " .. dist .. "m"
                    end
                else
                    LTarget.Text = "🎯 Target: offline"
                end
            else
                local cp = GetClosestPlayer()
                if cp and cp.Character and Root then
                    local hrp = GetRoot(cp.Character)
                    local hum = cp.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        local d = math.floor((hrp.Position - Root.Position).Magnitude)
                        LTarget.Text = "🎯 Próximo: " .. cp.Name .. " | " .. d .. "m"
                    end
                else
                    LTarget.Text = "🎯 Target: --"
                end
            end

            -- Status
            local status = "Idle"
            if _G_State.TpPlayer       then status = "📍 Tp to Target"
            elseif _G_State.AutoCombo  then status = "💥 Auto Combo ON"
            elseif _G_State.AutoSkills then status = "⚡ Auto Skills ON"
            elseif _G_State.SilentAim  then status = "🔇 Silent Aim ON"
            elseif _G_State.CamLock    then status = "🎯 Cam Lock ON"
            end
            LStatus.Text = "⚡ Status: " .. status

            -- Tempo
            local e = os.time() - sessStart
            LTime.Text = string.format("⏱ %dh%dm%ds", math.floor(e/3600), math.floor((e%3600)/60), e%60)
        end)
    end
end)

-- ============================================================
-- CRIAR JANELA PRINCIPAL
-- ============================================================
local Window = Library:CreateWindow({
    Title    = "🍌 Bananao Hub",
    Subtitle = "PVP Edition | Blox Fruits",
})

-- ============================================================
-- ABA 1: PVP
-- ============================================================
local PVPTab = Window:AddTab("⚔️ PVP")

-- ── SEÇÃO: TARGET ──
local SecTarget = PVPTab:AddLeftGroupbox("🎯 Selecionar Alvo")

local TargetDrop = SecTarget:AddDropdown("TargetDrop", {
    Text    = "Player Alvo",
    Values  = GetPlayerList(),
    Default = 1,
    Callback = function(v)
        _G_State.TargetPlayer = (v == "(Nenhum)") and nil or v
    end,
})

SecTarget:AddButton({
    Text = "🔄 Atualizar Lista de Players",
    Callback = function()
        local list = GetPlayerList()
        TargetDrop:GetNewList(list)
    end,
})

SecTarget:AddToggle("TpPlayer", {
    Text    = "📍 Teleport ao Alvo (Loop)",
    Default = false,
    Callback = function(v) _G_State.TpPlayer = v end,
})

SecTarget:AddSlider("TpDelay", {
    Text    = "Delay Teleport (s)",
    Min     = 0.05,
    Max     = 2,
    Default = 0.3,
    Precise = true,
    Callback = function(v) _G_State.TpDelay = v end,
})

SecTarget:AddButton({
    Text = "⚡ Tp Direto ao Alvo (1x)",
    Callback = function()
        local t = _G_State.TargetPlayer and Players:FindFirstChild(_G_State.TargetPlayer)
        if not t then t = GetClosestPlayer() end
        if t and t.Character then
            local hrp = GetRoot(t.Character)
            if hrp then TpDirect(hrp.CFrame * CFrame.new(0, 0, 4)) end
        end
    end,
})

-- ── SEÇÃO: AIMBOT ──
local SecAim = PVPTab:AddLeftGroupbox("🤖 Aimbot & Silent Aim")

SecAim:AddToggle("CamLock", {
    Text    = "🎯 Cam Lock (trava câmera no alvo)",
    Default = false,
    Callback = function(v) _G_State.CamLock = v end,
})

SecAim:AddToggle("SilentAim", {
    Text    = "🔇 Silent Aim (redireciona skills)",
    Default = false,
    Desc    = SilentAimHooked and "Ativo neste executor" or "Executor não suportado — usando modo alternativo",
    Callback = function(v) _G_State.SilentAim = v end,
})

-- ── SEÇÃO: AUTO COMBO ──
local SecCombo = PVPTab:AddRightGroupbox("💥 Auto Combo & Skills")

SecCombo:AddDropdown("WeaponType", {
    Text    = "Tipo de Arma",
    Values  = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = 1,
    Callback = function(v) _G_State.WeaponType = v end,
})

SecCombo:AddToggle("AutoCombo", {
    Text    = "💥 Auto Combo (Fast Attack)",
    Default = false,
    Callback = function(v) _G_State.AutoCombo = v end,
})

SecCombo:AddSlider("ComboDelay", {
    Text    = "Delay Combo (s)",
    Min     = 0.04,
    Max     = 0.5,
    Default = 0.08,
    Precise = true,
    Callback = function(v) _G_State.ComboDelay = v end,
})

SecCombo:AddSeperator("Skills Automáticas")

SecCombo:AddToggle("AutoSkills", {
    Text    = "⚡ Auto Usar Skills (Z X C V)",
    Default = false,
    Callback = function(v) _G_State.AutoSkills = v end,
})

SecCombo:AddToggle("SkillZ", {
    Text = "Skill Z", Default = true,
    Callback = function(v) _G_State.SkillZ = v end,
})
SecCombo:AddToggle("SkillX", {
    Text = "Skill X", Default = true,
    Callback = function(v) _G_State.SkillX = v end,
})
SecCombo:AddToggle("SkillC", {
    Text = "Skill C", Default = true,
    Callback = function(v) _G_State.SkillC = v end,
})
SecCombo:AddToggle("SkillV", {
    Text = "Skill V", Default = false,
    Callback = function(v) _G_State.SkillV = v end,
})

-- ── SEÇÃO: DEFESA ──
local SecDef = PVPTab:AddRightGroupbox("🛡️ Defesa & Utilitários")

SecDef:AddToggle("AntiStun", {
    Text    = "🛡️ Anti Stun (remove stun automático)",
    Default = false,
    Callback = function(v) _G_State.AntiStun = v end,
})

SecDef:AddToggle("AntiAFK", {
    Text    = "✅ Anti AFK",
    Default = true,
    Callback = function(v) _G_State.AntiAFK = v end,
})

SecDef:AddToggle("InfEnergy", {
    Text    = "♾️ Inf Energy (energia infinita)",
    Default = false,
    Callback = function(v) _G_State.InfEnergy = v end,
})

SecDef:AddSeperator("Speed & Jump")

SecDef:AddToggle("SpeedEnabled", {
    Text    = "⚡ WalkSpeed Customizado",
    Default = false,
    Callback = function(v) _G_State.SpeedEnabled = v end,
})

SecDef:AddSlider("WalkSpeed", {
    Text    = "WalkSpeed",
    Min     = 16,
    Max     = 300,
    Default = 24,
    Callback = function(v) _G_State.WalkSpeed = v end,
})

SecDef:AddToggle("JumpEnabled", {
    Text    = "🦘 JumpPower Customizado",
    Default = false,
    Callback = function(v) _G_State.JumpEnabled = v end,
})

SecDef:AddSlider("JumpPower", {
    Text    = "JumpPower",
    Min     = 50,
    Max     = 300,
    Default = 50,
    Callback = function(v) _G_State.JumpPower = v end,
})

SecDef:AddToggle("FlyEnabled", {
    Text    = "✈️ Fly (W/A/S/D + Space/Ctrl)",
    Default = false,
    Callback = function(v)
        _G_State.FlyEnabled = v
        if v then StartFly() else StopFly() end
    end,
})

-- ============================================================
-- ABA 2: BOUNTY HUNT
-- ============================================================
local BountyTab = Window:AddTab("💰 Bounty Hunt")

-- HUNT GLOBAL (todos os players)
local SecHunt = BountyTab:AddLeftGroupbox("🩸 Auto Hunt (30M Bounty)")

local _G_Hunt = {
    Enabled   = false,
    Delay     = 0.25,
    IgnoreTeam = false,
}

SecHunt:AddLabel("Teleporta e ataca automaticamente\ntodos os players com mais bounty primeiro.\nIdeal para acumular 30M de bounty!")

SecHunt:AddToggle("AutoHunt", {
    Text    = "🩸 Auto Bounty Hunt (Liga Tudo)",
    Default = false,
    Desc    = "Ativa Tp + Combo + Skills juntos",
    Callback = function(v)
        _G_Hunt.Enabled     = v
        _G_State.TpPlayer   = v
        _G_State.AutoCombo  = v
        _G_State.AutoSkills = v
        _G_State.AntiStun   = v
        _G_State.AntiAFK    = true
        if v then
            -- Seleciona automaticamente o alvo com maior bounty
            task.spawn(function()
                while _G_Hunt.Enabled do
                    SafeCall(function()
                        local best, bestB = nil, -1
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= plr and p.Character and IsAlive(p.Character) then
                                if _G_Hunt.IgnoreTeam or (not plr.Team) or (plr.Team ~= p.Team) then
                                    local b = 0
                                    pcall(function() b = p.Data.Bounty.Value end)
                                    if b > bestB then bestB = b; best = p end
                                end
                            end
                        end
                        if best then
                            _G_State.TargetPlayer = best.Name
                            TargetDrop:SetValue(best.Name)
                        end
                    end)
                    task.wait(2)
                end
            end)
        else
            _G_State.TpPlayer   = false
            _G_State.AutoCombo  = false
            _G_State.AutoSkills = false
        end
    end,
})

SecHunt:AddSlider("HuntDelay", {
    Text    = "Delay Hunt (s)",
    Min     = 0.1,
    Max     = 1,
    Default = 0.25,
    Precise = true,
    Callback = function(v) _G_Hunt.Delay = v end,
})

SecHunt:AddToggle("IgnoreTeam", {
    Text    = "🚫 Ignorar mesmo time",
    Default = false,
    Callback = function(v) _G_Hunt.IgnoreTeam = v end,
})

SecHunt:AddSeperator("Time")

SecHunt:AddButton({
    Text = "🏴‍☠️ Entrar Piratas",
    Callback = function()
        SafeCall(function() RS.Remotes.CommF_:InvokeServer("SetTeam", "Pirates") end)
    end,
})

SecHunt:AddButton({
    Text = "⚓ Entrar Marines",
    Callback = function()
        SafeCall(function() RS.Remotes.CommF_:InvokeServer("SetTeam", "Marines") end)
    end,
})

-- PAINEL BOUNTY INFO
local SecInfo = BountyTab:AddRightGroupbox("📊 Info de Bounty")

local BountyLabel  = SecInfo:AddLabel("💰 Seu bounty: carregando...")
local TargetBounty = SecInfo:AddLabel("🎯 Alvo: --")
local KillCount    = SecInfo:AddLabel("💀 Kills (sessão): 0")

local kills = 0
task.spawn(function()
    while task.wait(1) do
        SafeCall(function()
            local b = 0
            pcall(function() b = plr.Data.Bounty.Value end)
            local function fmt(n)
                n = math.floor(n or 0)
                return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
            end
            BountyLabel:SetText("💰 Seu bounty: " .. fmt(b))

            local tName = _G_State.TargetPlayer
            if tName then
                local tp = Players:FindFirstChild(tName)
                if tp then
                    local tb = 0
                    pcall(function() tb = tp.Data.Bounty.Value end)
                    TargetBounty:SetText("🎯 " .. tName .. ": " .. fmt(tb))
                end
            else
                TargetBounty:SetText("🎯 Alvo: nenhum selecionado")
            end

            KillCount:SetText("💀 Kills (sessão): " .. kills)
        end)
    end
end)

-- Contador de kills (detecta morte de inimigos)
task.spawn(function()
    while task.wait(0.5) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Died:Once(function()
                        if _G_Hunt.Enabled then kills += 1 end
                    end)
                end
            end
        end
    end
end)

-- ============================================================
-- ABA 3: TELEPORT
-- ============================================================
local TpTab = Window:AddTab("🌍 Teleport")

local function AddTpButton(section, name, cf)
    section:AddButton({
        Text = name,
        Callback = function() SafeCall(function() TpTo(cf) end) end,
    })
end

local SecSea1 = TpTab:AddLeftGroupbox("🌊 Sea 1")
local Sea1Places = {
    {"🏝️ Starter Island",    CFrame.new(-1264,40,1142)},
    {"⚓ Marine Starter",     CFrame.new(977,37,1121)},
    {"🌿 Jungle",             CFrame.new(-1714,40,-586)},
    {"🏴‍☠️ Pirate Village",  CFrame.new(-1012,40,-1148)},
    {"🏜️ Desert",             CFrame.new(941,40,-1391)},
    {"❄️ Frozen Village",     CFrame.new(1492,40,-520)},
    {"⚔️ Marine Fortress",    CFrame.new(1018,40,-2320)},
    {"☁️ Skylands",           CFrame.new(-3980,857,-3560)},
    {"🥊 Colosseum",          CFrame.new(-577,100,2000)},
    {"⛓️ Impel Down",         CFrame.new(17,-186,-5049)},
    {"🌊 Marineford",         CFrame.new(-4800,40,-5050)},
}
for _, v in ipairs(Sea1Places) do AddTpButton(SecSea1, v[1], v[2]) end

local SecSea2 = TpTab:AddRightGroupbox("🌊 Sea 2")
local Sea2Places = {
    {"🌹 Kingdom of Rose",    CFrame.new(-234,15,1185)},
    {"🌲 Green Zone",         CFrame.new(-2360,15,543)},
    {"💀 Graveyard",          CFrame.new(3340,15,-860)},
    {"🏔️ Snow Mountain",      CFrame.new(-2310,435,-2385)},
    {"🏯 Ice Castle",         CFrame.new(700,150,-4950)},
    {"🌴 Forgotten Island",   CFrame.new(4260,10,-4680)},
    {"☕ Cafe",                CFrame.new(-92,73,1538)},
    {"🌑 Dark Arena",         CFrame.new(-11561,917,-12423)},
    {"🔥 Hot Island",         CFrame.new(-5255,15,-3250)},
    {"🎪 Thriller Bark",      CFrame.new(-8490,10,2920)},
    {"🏴 Flamingo HQ",        CFrame.new(-11580,10,-8007)},
}
for _, v in ipairs(Sea2Places) do AddTpButton(SecSea2, v[1], v[2]) end

local SecSea3 = TpTab:AddLeftGroupbox("🌊 Sea 3")
local Sea3Places = {
    {"⚓ Port Town",           CFrame.new(-2076,50,-4491)},
    {"🐍 Hydra Island",       CFrame.new(-12390,15,-8730)},
    {"🐢 Floating Turtle",    CFrame.new(-13401,212,-5968)},
    {"🌳 Great Tree",         CFrame.new(-15468,377,-8086)},
    {"👻 Haunted Castle",     CFrame.new(-16754,70,1582)},
    {"🍬 Sea of Treats",      CFrame.new(1141,15,-19250)},
    {"🌫️ Mirage Island",     CFrame.new(-17755,15,-9421)},
    {"🦊 Kitsune Island",     CFrame.new(-19775,50,-11500)},
    {"🦕 Prehistoric Island", CFrame.new(-14790,50,-6600)},
}
for _, v in ipairs(Sea3Places) do AddTpButton(SecSea3, v[1], v[2]) end

-- ============================================================
-- ABA 4: ESP
-- ============================================================
local ESPTab = Window:AddTab("👁️ ESP")

local ESPEnabled = false
local ESPBBs     = {}

local function RemoveESP()
    for _, bb in pairs(ESPBBs) do
        pcall(function() bb:Destroy() end)
    end
    ESPBBs = {}
end

local function CreatePlayerESP(target)
    if not target.Character then return end
    local hrp = GetRoot(target.Character)
    if not hrp then return end
    if hrp:FindFirstChild("BananaoESP") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name        = "BananaoESP"
    bb.AlwaysOnTop = true
    bb.Size        = UDim2.new(0,150,0,50)
    bb.StudsOffset = Vector3.new(0,3,0)
    bb.Parent      = hrp
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,220,50)
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Text = target.Name
    lbl.Parent = bb
    table.insert(ESPBBs, bb)
    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then return end
        SafeCall(function()
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum and hrp and Root then
                local d  = math.floor((hrp.Position - Root.Position).Magnitude)
                local hp = math.floor(hum.Health)
                local mx = math.floor(hum.MaxHealth)
                lbl.Text = target.Name .. "\n❤️" .. hp .. "/" .. mx .. " | " .. d .. "m"
                lbl.TextColor3 = (hum.Health < hum.MaxHealth * 0.3)
                    and Color3.fromRGB(255,80,80)
                    or  Color3.fromRGB(255,220,50)
            end
        end)
    end)
end

local SecESP = ESPTab:AddLeftGroupbox("👁️ Player ESP")

SecESP:AddToggle("ESPPlayers", {
    Text    = "👁️ ESP Players (Nome + HP + Distância)",
    Default = false,
    Callback = function(v)
        ESPEnabled = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= plr then CreatePlayerESP(p) end
            end
            Players.PlayerAdded:Connect(function(p)
                if ESPEnabled then
                    p.CharacterAdded:Connect(function() task.wait(1); CreatePlayerESP(p) end)
                end
            end)
        else
            RemoveESP()
        end
    end,
})

SecESP:AddToggle("ESPMobs", {
    Text    = "🔴 ESP Inimigos (Enemies folder)",
    Default = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while v do
                    SafeCall(function()
                        local ef = WS:FindFirstChild("Enemies")
                        if ef then
                            for _, mob in pairs(ef:GetChildren()) do
                                local hrp = mob:FindFirstChild("HumanoidRootPart")
                                if hrp and not hrp:FindFirstChild("BananaoESP_Mob") then
                                    local bb = Instance.new("BillboardGui")
                                    bb.Name = "BananaoESP_Mob"
                                    bb.AlwaysOnTop = true
                                    bb.Size = UDim2.new(0,100,0,25)
                                    bb.StudsOffset = Vector3.new(0,2,0)
                                    bb.Parent = hrp
                                    local lb = Instance.new("TextLabel")
                                    lb.Size = UDim2.new(1,0,1,0)
                                    lb.BackgroundTransparency = 1
                                    lb.TextColor3 = Color3.fromRGB(255,100,100)
                                    lb.TextStrokeTransparency = 0
                                    lb.Font = Enum.Font.Gotham
                                    lb.TextSize = 11
                                    lb.Text = mob.Name
                                    lb.Parent = bb
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
                -- limpa
                local ef = WS:FindFirstChild("Enemies")
                if ef then
                    for _, mob in pairs(ef:GetChildren()) do
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bb = hrp:FindFirstChild("BananaoESP_Mob")
                            if bb then bb:Destroy() end
                        end
                    end
                end
            end)
        end
    end,
})

-- ============================================================
-- ABA 5: MISC
-- ============================================================
local MiscTab = Window:AddTab("⚙️ Misc")

local SecMisc = MiscTab:AddLeftGroupbox("🔧 Utilitários")

SecMisc:AddButton({
    Text = "📉 Low CPU Mode",
    Desc = "Reduz partículas, sombras e qualidade gráfica",
    Callback = function()
        SafeCall(function()
            local L = game.Lighting
            L.GlobalShadows = false
            L.FogEnd = 9e9
            L.Brightness = 1
            WS.Terrain.WaterWaveSize  = 0
            WS.Terrain.WaterWaveSpeed = 0
            settings().Rendering.QualityLevel = "Level01"
            for _, K in pairs(game:GetDescendants()) do
                pcall(function()
                    if K:IsA("ParticleEmitter") or K:IsA("Trail") then
                        K.Lifetime = NumberRange.new(0)
                    elseif K:IsA("Fire") or K:IsA("Smoke") or K:IsA("Sparkles") then
                        K.Enabled = false
                    elseif K:IsA("BlurEffect") or K:IsA("SunRaysEffect") or K:IsA("BloomEffect") then
                        K.Enabled = false
                    end
                end)
            end
        end)
    end,
})

SecMisc:AddButton({
    Text = "🔄 Rejoin (mesmo servidor)",
    Callback = function()
        SafeCall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                plr
            )
        end)
    end,
})

SecMisc:AddButton({
    Text = "💀 Reset Personagem",
    Callback = function()
        SafeCall(function()
            plr.Character:FindFirstChildOfClass("Humanoid").Health = 0
        end)
    end,
})

local SecRace = MiscTab:AddRightGroupbox("🏆 Race V3/V4")

SecRace:AddToggle("AutoV3", {
    Text    = "🔵 Auto Ativar V3",
    Default = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while v do
                    SafeCall(function()
                        RS.Remotes.CommE:FireServer("ActivateAbility")
                    end)
                    task.wait(30)
                end
            end)
        end
    end,
})

SecRace:AddToggle("AutoV4", {
    Text    = "🟡 Auto Ativar V4 (quando RaceEnergy = 1)",
    Default = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while v do
                    SafeCall(function()
                        local char = plr.Character
                        if char and char:FindFirstChild("RaceEnergy") then
                            if char.RaceEnergy.Value == 1 then
                                SafeSendKey("Y")
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end,
})

SecRace:AddButton({
    Text = "Reroll Race (3000F)",
    Callback = function()
        SafeCall(function() RS.Remotes.CommF_:InvokeServer("RerollRace", "RaceReroll") end)
    end,
})

-- ============================================================
-- NOTIFICAÇÃO FINAL
-- ============================================================
task.wait(0.5)
Library:Notify({
    Title       = "🍌 Bananao Hub",
    Description = "PVP Edition carregado!\n• Use Auto Bounty Hunt na aba 💰\n• Ativa Anti Stun + Tp + Combo juntos\n• Boa sorte nos 30M! 🏴‍☠️",
    Duration    = 8,
})
