--[[
╔══════════════════════════════════════════╗
║         VKontakte Hub - PVP Edition      ║
║    Anti Stun | Auto Farm Bounty          ║
║    Auto Combo | Auto V3/V4 | Teleport    ║
╚══════════════════════════════════════════╝
]]

-- ============================================================
-- RAYFIELD UI
-- ============================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ============================================================
-- SERVIÇOS
-- ============================================================
local ply          = game:GetService("Players")
local plr          = ply.LocalPlayer
local RS           = game:GetService("ReplicatedStorage")
local WS           = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TW           = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local vim1         = game:GetService("VirtualInputManager")
local vim2         = game:GetService("VirtualUser")
local replicated   = RS

-- ============================================================
-- VARIÁVEIS GLOBAIS
-- ============================================================
local Sec          = 0.1
local Root         = nil
local C            = nil
local shouldTween  = false
local PosMon       = nil
local _B           = false
local G            = {}
local Useskills    = nil
local EquipWeapon  = nil
local weaponSc     = nil
local GetBP        = nil
local GetConnectionEnemies = nil

getgenv().TweenSpeedFar  = 300
getgenv().TweenSpeedNear = 600
_G.MobHeight             = 3
_G.MaxBringMobs          = 5
_G.BringRange            = 200
_G.SelectWeapon          = nil
_G.ChooseWP              = "Melee"

-- World Detection
local placeId = game.PlaceId
local World1, World2, World3
if placeId == 2753915549 or placeId == 85211729168715 then World1 = true
elseif placeId == 4442272183 or placeId == 79091703265657 then World2 = true
elseif placeId == 7449423635 or placeId == 100117331123089 then World3 = true
end

-- Aguarda personagem
repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
Root = plr.Character.HumanoidRootPart
C    = Root

plr.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    Root = char.HumanoidRootPart
    C    = Root
end)

-- ============================================================
-- SAVE / LOAD
-- ============================================================
_G.SaveData = {}
local function SaveSettings()
    pcall(function()
        writefile("VKontakte.json", game:GetService("HttpService"):JSONEncode(_G.SaveData))
    end)
end
local function LoadSettings()
    local ok, d = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile("VKontakte.json"))
    end)
    if ok and d then _G.SaveData = d end
end
local function GetSetting(name, default)
    LoadSettings()
    return _G.SaveData[name] ~= nil and _G.SaveData[name] or default
end
LoadSettings()

-- ============================================================
-- TELEPORTE TWEEN
-- ============================================================
local function _tp(I)
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local HRP = char.HumanoidRootPart
    shouldTween = true
    if HRP.Anchored then HRP.Anchored = false; task.wait() end
    local dist  = (I.Position - HRP.Position).Magnitude
    local speed = dist <= 15 and (getgenv().TweenSpeedNear or 600) or (getgenv().TweenSpeedFar or 300)
    local info  = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TW:Create(HRP, info, {CFrame = I})
    if char.Humanoid.Sit then HRP.CFrame = CFrame.new(HRP.Position.X, I.Y, HRP.Position.Z) end
    tween:Play()
    task.spawn(function()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not shouldTween then tween:Cancel(); break end
            task.wait(.1)
        end
        shouldTween = false
    end)
end

local function notween(I)
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = I
    end
end

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function IsAlive(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

GetBP = function(name)
    return plr.Backpack:FindFirstChild(name) or plr.Character:FindFirstChild(name)
end

GetConnectionEnemies = function(name)
    for _, K in pairs(WS.Enemies:GetChildren()) do
        if K:IsA("Model") and K.Name == name and K:FindFirstChild("Humanoid") and K.Humanoid.Health > 0 then
            return K
        end
    end
    for _, K in pairs(replicated:GetChildren()) do
        if K:IsA("Model") and K.Name == name and K:FindFirstChild("Humanoid") and K.Humanoid.Health > 0 then
            return K
        end
    end
end

weaponSc = function(tipo)
    for _, tool in pairs(plr.Backpack:GetChildren()) do
        if tool.ToolTip == tipo then
            _G.SelectWeapon = tool.Name
            plr.Character.Humanoid:EquipTool(tool)
            return
        end
    end
    for _, tool in pairs(plr.Character:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == tipo then
            _G.SelectWeapon = tool.Name
            return
        end
    end
end

EquipWeapon = function(name)
    if not name then return end
    pcall(function()
        local tool = plr.Backpack:FindFirstChild(name) or plr.Character:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            plr.Character.Humanoid:EquipTool(tool)
        end
    end)
end

Useskills = function(tipo, tecla)
    if tipo == "Melee"      then weaponSc("Melee")
    elseif tipo == "Sword"  then weaponSc("Sword")
    elseif tipo == "Blox Fruit" then weaponSc("Blox Fruit")
    elseif tipo == "Gun"    then weaponSc("Gun")
    end
    pcall(function()
        vim1:SendKeyEvent(true,  tecla, false, game)
        vim1:SendKeyEvent(false, tecla, false, game)
    end)
end

-- ============================================================
-- BRING ENEMY (puxa mob para perto)
-- ============================================================
local TweenInfoBring = TweenInfo.new(0.3, Enum.EasingStyle.Linear)

local function BringEnemy()
    if not _B then return end
    local char = plr.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() sethiddenproperty(plr, "SimulationRadius", math.huge) end)
    local targetPos = PosMon or hrp.Position
    local count = 0
    local enemies = WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, mob in ipairs(enemies:GetChildren()) do
        if count >= (_G.MaxBringMobs or 5) then break end
        local hum  = mob:FindFirstChild("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 then
            local dist = (root.Position - targetPos).Magnitude
            if dist <= (_G.BringRange or 200) and not root:GetAttribute("Tweening") then
                count += 1
                root:SetAttribute("Tweening", true)
                local t = TW:Create(root, TweenInfoBring, {CFrame = CFrame.new(targetPos)})
                t:Play()
                t.Completed:Once(function() if root then root:SetAttribute("Tweening", false) end end)
            end
        end
    end
end

-- G.Kill: vai ao mob e ataca
G.Kill = function(mob, enabled)
    if not (mob and enabled) then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not mob:GetAttribute("Locked") then mob:SetAttribute("Locked", hrp.CFrame) end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    EquipWeapon(_G.SelectWeapon)
    _tp(hrp.CFrame * CFrame.new(0, _G.MobHeight or 3, 0))
end

-- ============================================================
-- FAST ATTACK (Auto Combo)
-- ============================================================
local RegisterAttack, RegisterHit
pcall(function()
    local Modules = RS:WaitForChild("Modules", 5)
    local Net     = Modules and Modules:WaitForChild("Net", 5)
    if Net then
        RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
        RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
    end
end)

local function DoFastAttack()
    local char = plr.Character
    if not char or not IsAlive(char) then return end
    local enemies  = {}
    local basePart = nil
    for _, folder in ipairs({WS:FindFirstChild("Enemies"), WS:FindFirstChild("Characters")}) do
        if folder then
            for _, e in ipairs(folder:GetChildren()) do
                local head = e:FindFirstChild("Head")
                if head and IsAlive(e) and plr:DistanceFromCharacter(head.Position) < 130 and e ~= char then
                    table.insert(enemies, {e, head})
                    basePart = head
                end
            end
        end
    end
    if #enemies == 0 then return end
    local weapon = char:FindFirstChildOfClass("Tool")
    if weapon and weapon:FindFirstChild("LeftClickRemote") then
        for _, data in ipairs(enemies) do
            local e = data[1]
            if e:FindFirstChild("HumanoidRootPart") then
                local dir = (e.HumanoidRootPart.Position - char:GetPivot().Position).Unit
                pcall(function() weapon.LeftClickRemote:FireServer(dir, 1) end)
            end
        end
    elseif basePart and RegisterAttack and RegisterHit then
        pcall(function()
            RegisterAttack:FireServer(0)
            RegisterHit:FireServer(basePart, enemies)
        end)
    end
    -- Usar skills de todas as armas
    pcall(function()
        local tipo = _G.ChooseWP or "Melee"
        for _, k in ipairs({"Z","X","C","V"}) do
            Useskills(tipo, k)
        end
    end)
end

-- ============================================================
-- SILENT AIM (metamethod)
-- ============================================================
local SilentAimEnabled = false
local PlayersPosition  = nil
local renderConn       = nil

local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, p in pairs(ply:GetPlayers()) do
        if p ~= plr and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local d = (hrp.Position - Root.Position).Magnitude
                if d < dist then dist = d; closest = p end
            end
        end
    end
    return closest
end

pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}
        if (method == "FireServer" or method == "InvokeServer")
            and SilentAimEnabled and PlayersPosition
            and typeof(args[1]) == "Vector3" then
            args[1] = PlayersPosition
            return old(self, unpack(args))
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ============================================================
-- RAYFIELD WINDOW
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name            = "VKontakte Hub",
    LoadingTitle    = "VKontakte Hub",
    LoadingSubtitle = "PVP Edition | Blox Fruits",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "VKontakte",
        FileName   = "VK_Config"
    },
    Discord = {
        Enabled       = true,
        Invite        = "BUtspHxrj",
        RememberJoins = true
    },
    KeySystem = false
})

-- ============================================================
-- ══════════════ ABA 1: PVP ══════════════
-- ============================================================
local PVPTab = Window:CreateTab("⚔️ PVP", "swords")

-- ── Selecionar Target ──
PVPTab:CreateSection("🎯 Target")

local playerList = {}
for _, p in pairs(ply:GetPlayers()) do
    if p ~= plr then table.insert(playerList, p.Name) end
end

local TargetPlayer = nil
local TargetDropdown = PVPTab:CreateDropdown({
    Name          = "Selecionar Player Alvo",
    Options       = #playerList > 0 and playerList or {"(Nenhum)"},
    CurrentOption = "(Nenhum)",
    Flag          = "TargetPlayer",
    Callback      = function(v) TargetPlayer = v end
})

PVPTab:CreateButton({
    Name     = "🔄 Atualizar Lista de Players",
    Callback = function()
        local list = {}
        for _, p in pairs(ply:GetPlayers()) do
            if p ~= plr then table.insert(list, p.Name) end
        end
        TargetDropdown:Set(#list > 0 and list[1] or "(Nenhum)")
        Rayfield:Notify({Title="VKontakte", Content="Lista atualizada!", Duration=2})
    end
})

-- ── Teleport to Player ──
local TpPlayerEnabled = false
PVPTab:CreateToggle({
    Name         = "📍 Teleport ao Player Alvo",
    CurrentValue = false,
    Flag         = "TpPlayer",
    Callback     = function(v)
        TpPlayerEnabled = v
        if v then
            task.spawn(function()
                while TpPlayerEnabled do
                    pcall(function()
                        if TargetPlayer and TargetPlayer ~= "(Nenhum)" then
                            local t = ply:FindFirstChild(TargetPlayer)
                            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                                _tp(t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,5))
                            end
                        end
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

-- ── Cam Lock Aimbot ──
PVPTab:CreateSection("🤖 Aimbot")

local AimCamEnabled = false
PVPTab:CreateToggle({
    Name         = "🎯 Cam Lock (Aimbot)",
    CurrentValue = false,
    Flag         = "AimCam",
    Callback     = function(v) AimCamEnabled = v end
})

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not AimCamEnabled then return end
            local cam     = WS.CurrentCamera
            local closest = getClosestPlayer()
            if closest and closest.Character then
                local hrp = closest.Character:FindFirstChild("HumanoidRootPart")
                if hrp then cam.CFrame = CFrame.new(cam.CFrame.Position, hrp.Position) end
            end
        end)
    end
end)

-- ── Silent Aim ──
PVPTab:CreateToggle({
    Name         = "🔇 Silent Aim (Skills)",
    CurrentValue = false,
    Flag         = "SilentAim",
    Callback     = function(v)
        SilentAimEnabled = v
        if v then
            if renderConn then return end
            renderConn = RunService.RenderStepped:Connect(function()
                if not SilentAimEnabled then return end
                local t = getClosestPlayer()
                if t and t.Character then
                    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then PlayersPosition = hrp.Position end
                end
            end)
        else
            if renderConn then renderConn:Disconnect(); renderConn = nil end
            PlayersPosition = nil
        end
    end
})

PVPTab:CreateSlider({
    Name         = "Alcance Silent Aim (studs)",
    Range        = {50, 2000},
    Increment    = 50,
    Suffix       = "m",
    CurrentValue = 1000,
    Flag         = "SilentAimRange",
    Callback     = function(v) end
})

-- ── Anti Stun ──
PVPTab:CreateSection("🛡️ Defesa")

local AntiStunEnabled = false
PVPTab:CreateToggle({
    Name         = "🛡️ Anti Stun",
    CurrentValue = false,
    Flag         = "AntiStun",
    Callback     = function(v) AntiStunEnabled = v end
})

task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if not AntiStunEnabled then return end
            local char = plr.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
                if hum:FindFirstChild("Stun") then hum.Stun:Destroy() end
            end
            if char:FindFirstChild("Stun") then char.Stun:Destroy() end
        end)
    end
end)

local AntiAFK = true
PVPTab:CreateToggle({
    Name         = "✅ Anti AFK",
    CurrentValue = true,
    Flag         = "AntiAFK",
    Callback     = function(v) AntiAFK = v end
})

plr.Idled:Connect(function()
    if AntiAFK then
        pcall(function()
            vim2:Button2Down(Vector2.new(0,0), WS.CurrentCamera.CFrame)
            task.wait(1)
            vim2:Button2Up(Vector2.new(0,0), WS.CurrentCamera.CFrame)
        end)
    end
end)

-- ── Auto Combo / Fast Attack ──
PVPTab:CreateSection("💥 Auto Combo")

local AutoComboEnabled = false
local ComboDelay       = 0.08

PVPTab:CreateToggle({
    Name         = "💥 Auto Combo (Fast Attack)",
    CurrentValue = false,
    Flag         = "AutoCombo",
    Callback     = function(v) AutoComboEnabled = v end
})

PVPTab:CreateSlider({
    Name         = "Delay Combo (s)",
    Range        = {0, 0.5},
    Increment    = 0.01,
    Suffix       = "s",
    CurrentValue = 0.08,
    Flag         = "ComboDelay",
    Callback     = function(v) ComboDelay = v end
})

PVPTab:CreateDropdown({
    Name          = "Tipo de Arma Combo",
    Options       = {"Melee", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = GetSetting("ChooseWP_Save", "Melee"),
    Flag          = "WeaponTypeCombo",
    Callback      = function(v)
        _G.ChooseWP = v
        _G.SaveData["ChooseWP_Save"] = v
        SaveSettings()
    end
})

task.spawn(function()
    while true do
        task.wait(ComboDelay > 0 and ComboDelay or 0.08)
        if AutoComboEnabled then
            pcall(function()
                weaponSc(_G.ChooseWP or "Melee")
                DoFastAttack()
            end)
        end
    end
end)

-- ── Skills Auto ──
PVPTab:CreateSection("⚡ Auto Skills")

local AutoSkillsEnabled = false
local SkillKeys = {Z=true, X=true, C=true, V=false}

PVPTab:CreateToggle({
    Name         = "⚡ Auto Usar Skills",
    CurrentValue = false,
    Flag         = "AutoSkills",
    Callback     = function(v) AutoSkillsEnabled = v end
})
PVPTab:CreateToggle({Name="Skill Z", CurrentValue=true,  Flag="SkillZ", Callback=function(v) SkillKeys.Z=v end})
PVPTab:CreateToggle({Name="Skill X", CurrentValue=true,  Flag="SkillX", Callback=function(v) SkillKeys.X=v end})
PVPTab:CreateToggle({Name="Skill C", CurrentValue=true,  Flag="SkillC", Callback=function(v) SkillKeys.C=v end})
PVPTab:CreateToggle({Name="Skill V", CurrentValue=false, Flag="SkillV", Callback=function(v) SkillKeys.V=v end})

task.spawn(function()
    while task.wait(0.15) do
        if AutoSkillsEnabled then
            pcall(function()
                local tipo = _G.ChooseWP or "Melee"
                weaponSc(tipo)
                for k, enabled in pairs(SkillKeys) do
                    if enabled then
                        vim1:SendKeyEvent(true,  k, false, game)
                        vim1:SendKeyEvent(false, k, false, game)
                        task.wait(0.05)
                    end
                end
            end)
        end
    end
end)

-- ── Speed/Jump ──
PVPTab:CreateSection("🏃 Movimento")

local SpeedEnabled = false
local JumpEnabled  = false
local desiredSpeed = 16
local desiredJump  = 50

RunService.Heartbeat:Connect(function()
    pcall(function()
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if SpeedEnabled and hum.WalkSpeed ~= desiredSpeed then hum.WalkSpeed = desiredSpeed end
        if JumpEnabled  and hum.JumpPower  ~= desiredJump  then hum.JumpPower  = desiredJump  end
    end)
end)

PVPTab:CreateToggle({
    Name="⚡ WalkSpeed Custom", CurrentValue=false, Flag="SpeedEnabled",
    Callback=function(v) SpeedEnabled=v end
})
PVPTab:CreateSlider({
    Name="WalkSpeed", Range={16,500}, Increment=1, CurrentValue=16, Suffix="spd", Flag="SpeedVal",
    Callback=function(v) desiredSpeed=v end
})
PVPTab:CreateToggle({
    Name="🦘 JumpPower Custom", CurrentValue=false, Flag="JumpEnabled",
    Callback=function(v) JumpEnabled=v end
})
PVPTab:CreateSlider({
    Name="JumpPower", Range={50,500}, Increment=1, CurrentValue=50, Suffix="jp", Flag="JumpVal",
    Callback=function(v) desiredJump=v end
})

-- ── Inf Skills ──
PVPTab:CreateSection("♾️ Infinitos PVP")

PVPTab:CreateToggle({
    Name="♾️ Inf Energy", CurrentValue=false, Flag="InfEnergy",
    Callback=function(v)
        if v then
            task.spawn(function()
                while v do
                    pcall(function()
                        local char = plr.Character
                        if char and char:FindFirstChild("Energy") then
                            char.Energy.Value = char.Energy.MaxValue
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

PVPTab:CreateToggle({
    Name="♾️ Inf Mink V3 (Agility)", CurrentValue=false, Flag="InfMink",
    Callback=function(v)
        if v then
            task.spawn(function()
                while v do
                    pcall(function()
                        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and not hrp:FindFirstChild("Agility") then
                            local ag = RS.FX.Agility:Clone()
                            ag.Name = "Agility"; ag.Parent = hrp
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

PVPTab:CreateToggle({
    Name="♾️ Inf Soru", CurrentValue=false, Flag="InfSoru",
    Callback=function(v)
        _G.InfSoru = v
        if v then
            task.spawn(function()
                for _, K in next, getgc() do
                    if typeof(K) == "function" then
                        pcall(function()
                            if (getfenv(K)).script == plr.Character:FindFirstChild("Soru") then
                                for _, up in next, getupvalues(K) do
                                    if typeof(up) == "table" and up.LastUse ~= nil then
                                        repeat task.wait(Sec); up.LastUse = 0 until not _G.InfSoru end
                                    end
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end
})

-- ============================================================
-- ══════════════ ABA 2: AUTO FARM BOUNTY ══════════════
-- ============================================================
local BountyTab = Window:CreateTab("💰 Bounty Farm", "trophy")

-- ── Arma ──
BountyTab:CreateSection("⚙️ Configuração")

BountyTab:CreateDropdown({
    Name          = "Arma para Bounty Farm",
    Options       = {"Melee", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = GetSetting("BountyWP_Save", "Melee"),
    Flag          = "BountyWeapon",
    Callback      = function(v)
        _G.ChooseWP = v
        _G.SaveData["BountyWP_Save"] = v
        SaveSettings()
    end
})

-- ── Auto Bounty Hunt GLOBAL (qualquer ilha) ──
BountyTab:CreateSection("💰 Auto Bounty Hunt (Qualquer Ilha)")

_G.AutoBounty  = false
_G.Defeating   = false
_G.BountyMinHP = 0    -- mínimo de HP do target para atacar
_G.BountyDelay = 0.3  -- delay entre cada kill

BountyTab:CreateToggle({
    Name         = "💰 Auto Bounty Hunt (Mundo Inteiro)",
    CurrentValue = false,
    Flag         = "AutoBounty",
    Callback     = function(v)
        _G.AutoBounty = v
        _G.Defeating  = v
    end
})

BountyTab:CreateSlider({
    Name         = "Delay entre kills (s)",
    Range        = {0.05, 2},
    Increment    = 0.05,
    Suffix       = "s",
    CurrentValue = 0.3,
    Flag         = "BountyDelay",
    Callback     = function(v) _G.BountyDelay = v end
})

BountyTab:CreateToggle({
    Name         = "🚫 Ignorar Same Team",
    CurrentValue = false,
    Flag         = "BountyIgnoreTeam",
    Callback     = function(v) _G.BountyIgnoreTeam = v end
})

--[[
    LÓGICA: Varre TODOS os players no servidor (ply:GetPlayers)
    independente de distância — teleporta até eles e mata.
    Prioridade: player com maior bounty primeiro.
]]
task.spawn(function()
    while task.wait(_G.BountyDelay or 0.3) do
        pcall(function()
            if not _G.AutoBounty then return end
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            pcall(function() sethiddenproperty(plr, "SimulationRadius", math.huge) end)

            -- Coleta todos os players vivos com bounty
            local targets = {}
            for _, p in pairs(ply:GetPlayers()) do
                if p ~= plr and p.Character and IsAlive(p.Character) then
                    -- Ignora mesmo time se toggle ativo
                    if _G.BountyIgnoreTeam and plr.Team and p.Team and plr.Team == p.Team then
                        -- skip
                    else
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Tenta pegar bounty do player para ordenar por maior
                            local bountyVal = 0
                            pcall(function() bountyVal = p.Data.Bounty.Value end)
                            table.insert(targets, {player=p, hrp=hrp, bounty=bountyVal})
                        end
                    end
                end
            end

            if #targets == 0 then return end

            -- Ordena por maior bounty primeiro
            table.sort(targets, function(a, b) return a.bounty > b.bounty end)

            -- Ataca o primeiro (maior bounty)
            local best = targets[1]
            local tp   = best.player
            local hrp  = best.hrp

            if not hrp or not hrp.Parent then return end

            -- Equipa arma
            weaponSc(_G.ChooseWP or "Melee")
            EquipWeapon(_G.SelectWeapon)

            -- Teleporta para cima do player (qualquer ilha)
            _tp(hrp.CFrame * CFrame.new(0, 3, 0))
            task.wait(0.05)

            -- Fast Attack
            DoFastAttack()

            -- Usar skills
            pcall(function()
                local tipo = _G.ChooseWP or "Melee"
                for _, k in ipairs({"Z","X","C","V"}) do
                    Useskills(tipo, k)
                    task.wait(0.03)
                end
            end)
        end)
    end
end)

-- ── Bounty Farm Boss ──
BountyTab:CreateSection("👹 Auto Farm Boss (Bounty)")

_G.AutoFarmBoss = false
_G.SelectedBoss = "Darkbeard"

-- Lista de bosses com localização conhecida
local BossLocations = {
    ["Darkbeard"]       = CFrame.new(1175, 600, -9999),  -- Frostborn Cove
    ["Order"]           = CFrame.new(-11561, 917, -12423),
    ["Saber Expert"]    = CFrame.new(-11580, 10, -8007),
    ["rip_indra"]       = CFrame.new(-16754, 70, 1582),
    ["Stone"]           = CFrame.new(-4800, 40, -5050),
    ["Cake Prince"]     = CFrame.new(1141, 15, -19250),
    ["Hydra"]           = CFrame.new(-12390, 15, -8730),
    ["Leviathan"]       = CFrame.new(-13401, 212, -5968),
    ["Wandering Pirate"]= CFrame.new(-15468, 377, -8086),
    ["Boss Mais Próximo"] = nil,  -- busca automática
}

local bossOptions = {}
for k in pairs(BossLocations) do table.insert(bossOptions, k) end
table.sort(bossOptions)

BountyTab:CreateDropdown({
    Name          = "Selecionar Boss",
    Options       = bossOptions,
    CurrentOption = "Boss Mais Próximo",
    Flag          = "SelectedBoss",
    Callback      = function(v) _G.SelectedBoss = v end
})

BountyTab:CreateToggle({
    Name         = "👹 Auto Farm Boss Selecionado",
    CurrentValue = false,
    Flag         = "AutoFarmBoss",
    Callback     = function(v) _G.AutoFarmBoss = v end
})

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoFarmBoss then return end

            -- Tenta achar boss pelo nome no Enemies/Workspace
            local bossName   = _G.SelectedBoss or "Boss Mais Próximo"
            local bossTarget = nil

            if bossName == "Boss Mais Próximo" then
                -- Busca qualquer mob com IsBoss = true
                for _, folder in ipairs({WS:FindFirstChild("Enemies"), WS}) do
                    if folder then
                        for _, mob in pairs(folder:GetDescendants()) do
                            if mob:IsA("Model") and mob:GetAttribute("IsBoss") == true
                                and IsAlive(mob) then
                                bossTarget = mob
                                break
                            end
                        end
                    end
                    if bossTarget then break end
                end
                -- Fallback: busca pelo nome genérico
                if not bossTarget then
                    local keywords = {"Boss","Admiral","King","Dragon","Lord","Warden","Prince"}
                    local ef = WS:FindFirstChild("Enemies")
                    if ef then
                        for _, mob in pairs(ef:GetChildren()) do
                            for _, kw in ipairs(keywords) do
                                if mob.Name:find(kw) and IsAlive(mob) then
                                    bossTarget = mob; break
                                end
                            end
                            if bossTarget then break end
                        end
                    end
                end
            else
                -- Busca pelo nome exato
                bossTarget = GetConnectionEnemies(bossName)
                -- Se não achou, vai até a localização conhecida
                if not bossTarget and BossLocations[bossName] then
                    _tp(BossLocations[bossName])
                    task.wait(1)
                    bossTarget = GetConnectionEnemies(bossName)
                end
            end

            if bossTarget then
                G.Kill(bossTarget, true)
                DoFastAttack()
            end
        end)
    end
end)

BountyTab:CreateSection("🏴‍☠️ Team")
BountyTab:CreateButton({
    Name="Entrar Piratas",
    Callback=function()
        pcall(function() RS.Remotes.CommF_:InvokeServer("SetTeam","Pirates") end)
        Rayfield:Notify({Title="VKontakte",Content="Time: Piratas!",Duration=3})
    end
})
BountyTab:CreateButton({
    Name="Entrar Marines",
    Callback=function()
        pcall(function() RS.Remotes.CommF_:InvokeServer("SetTeam","Marines") end)
        Rayfield:Notify({Title="VKontakte",Content="Time: Marines!",Duration=3})
    end
})

-- ============================================================
-- ══════════════ ABA 3: AUTO FARM MOB ══════════════
-- ============================================================
local FarmTab = Window:CreateTab("🌾 Auto Farm", "sprout")

FarmTab:CreateSection("⚡ Auto Farm Level")

_G.StartFarm    = false
_G.Level        = false

FarmTab:CreateDropdown({
    Name          = "Tipo de Arma Farm",
    Options       = {"Melee","Sword","Blox Fruit","Gun"},
    CurrentOption = GetSetting("FarmWP_Save","Melee"),
    Flag          = "FarmWeapon",
    Callback      = function(v)
        _G.ChooseWP = v
        _G.SaveData["FarmWP_Save"] = v
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    Name         = "🌾 Iniciar Auto Farm",
    CurrentValue = GetSetting("StartFarm_Save",false),
    Flag         = "StartFarm",
    Callback     = function(v)
        _G.StartFarm = v
        _G.Level     = v
        _G.SaveData["StartFarm_Save"] = v
        SaveSettings()
    end
})

FarmTab:CreateSlider({
    Name="Altura Mob (MobHeight)", Range={0,20}, Increment=1, CurrentValue=3, Suffix="st", Flag="MobHeight",
    Callback=function(v) _G.MobHeight=v end
})

-- Farm loop (mobs normais)
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not (_G.StartFarm and _G.Level) then return end
            -- Seleciona arma
            for _, tool in pairs(plr.Backpack:GetChildren()) do
                if tool.ToolTip == _G.ChooseWP then
                    _G.SelectWeapon = tool.Name; break
                end
            end
            -- Encontra mob mais próximo
            local closest, minD = nil, math.huge
            local enemiesFolder = WS:FindFirstChild("Enemies")
            if enemiesFolder then
                for _, e in pairs(enemiesFolder:GetChildren()) do
                    local hum = e:FindFirstChild("Humanoid")
                    local hrp = e:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 then
                        local d = (hrp.Position - Root.Position).Magnitude
                        if d < minD then minD=d; closest=e end
                    end
                end
            end
            if closest then G.Kill(closest, true) end
        end)
    end
end)

FarmTab:CreateSection("👹 Auto Farm Boss")

_G.FarmBoss         = false
_G.FarmBossSelected = "Qualquer Boss"

local FarmBossOptions = {
    "Qualquer Boss",
    "Darkbeard", "Order", "Saber Expert", "rip_indra",
    "Stone", "Cake Prince", "Sea Beast", "Hydra",
    "Wandering Pirate", "Terrorshark", "Leviathan",
    "Island Empress", "Kitsune", "T-Rex", "Mammoth",
}

FarmTab:CreateDropdown({
    Name          = "Boss Alvo",
    Options       = FarmBossOptions,
    CurrentOption = "Qualquer Boss",
    Flag          = "FarmBossTarget",
    Callback      = function(v) _G.FarmBossSelected = v end
})

FarmTab:CreateToggle({
    Name         = "👹 Auto Farm Boss",
    CurrentValue = false,
    Flag         = "FarmBoss",
    Callback     = function(v) _G.FarmBoss = v end
})

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.FarmBoss then return end

            -- Seleciona arma
            for _, tool in pairs(plr.Backpack:GetChildren()) do
                if tool.ToolTip == _G.ChooseWP then
                    _G.SelectWeapon = tool.Name; break
                end
            end

            local boss = nil
            local sel  = _G.FarmBossSelected or "Qualquer Boss"

            if sel == "Qualquer Boss" then
                -- Acha qualquer mob com atributo IsBoss ou HP alto
                local ef = WS:FindFirstChild("Enemies")
                if ef then
                    for _, mob in pairs(ef:GetChildren()) do
                        if IsAlive(mob) and (
                            mob:GetAttribute("IsBoss") == true or
                            (mob:FindFirstChild("Humanoid") and mob.Humanoid.MaxHealth >= 50000)
                        ) then
                            boss = mob; break
                        end
                    end
                end
                -- Fallback: busca por palavras-chave de boss
                if not boss and ef then
                    local kws = {"Admiral","King","Expert","Indra","Stone","Beast","Hydra","Dragon","Empress","Kitsune","Mammoth","Tyrant"}
                    for _, mob in pairs(ef:GetChildren()) do
                        for _, kw in ipairs(kws) do
                            if mob.Name:find(kw) and IsAlive(mob) then
                                boss = mob; break
                            end
                        end
                        if boss then break end
                    end
                end
            else
                boss = GetConnectionEnemies(sel)
            end

            if boss then
                G.Kill(boss, true)
                DoFastAttack()
            end
        end)
    end
end)

FarmTab:CreateSection("🦴 Drops Especiais")

_G.AutoFarm_Bone = false
FarmTab:CreateToggle({
    Name="🦴 Auto Farm Bones",CurrentValue=false,Flag="FarmBones",
    Callback=function(v)
        _G.AutoFarm_Bone = v
        _G.SaveData["FarmBones_Save"] = v
        SaveSettings()
    end
})

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoFarm_Bone then return end
            local bone = WS:FindFirstChild("DinoBone") or GetConnectionEnemies("Bone Collector")
            if bone and bone:FindFirstChild("HumanoidRootPart") then
                G.Kill(bone, true)
            end
        end)
    end
end)

-- ============================================================
-- ══════════════ ABA 4: RACE V3/V4 ══════════════
-- ============================================================
local RaceTab = Window:CreateTab("🏆 Race V3/V4", "star")

RaceTab:CreateSection("🏆 Auto Race Activation")

_G.RaceClickAutov3 = false
_G.RaceClickAutov4 = false

RaceTab:CreateToggle({
    Name         = "🔵 Auto Ativar V3 (Race)",
    CurrentValue = GetSetting("AutoV3_Save",false),
    Flag         = "AutoV3",
    Callback     = function(v)
        _G.RaceClickAutov3 = v
        _G.SaveData["AutoV3_Save"] = v
        SaveSettings()
        if v then
            task.spawn(function()
                repeat
                    pcall(function() replicated.Remotes.CommE:FireServer("ActivateAbility") end)
                    task.wait(30)
                until not _G.RaceClickAutov3
            end)
        end
    end
})

RaceTab:CreateToggle({
    Name         = "🟡 Auto Ativar V4 (Race Energy = 1)",
    CurrentValue = GetSetting("AutoV4_Save",false),
    Flag         = "AutoV4",
    Callback     = function(v)
        _G.RaceClickAutov4 = v
        _G.SaveData["AutoV4_Save"] = v
        SaveSettings()
    end
})

-- V4 loop (só ativa quando RaceEnergy == 1)
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not _G.RaceClickAutov4 then return end
            local char = plr.Character
            if char and char:FindFirstChild("RaceEnergy") then
                if char.RaceEnergy.Value == 1 then
                    Useskills("nil","Y")
                end
            end
        end)
    end
end)

RaceTab:CreateSection("🧬 Auto Upgrade Race")

RaceTab:CreateButton({
    Name="Comprar Reroll Race (3000 Fragments)",
    Callback=function()
        pcall(function()
            replicated.Remotes.CommF_:InvokeServer("RerollRace", "RaceReroll")
        end)
        Rayfield:Notify({Title="VKontakte",Content="Reroll Race enviado!",Duration=3})
    end
})

RaceTab:CreateButton({
    Name="Comprar Raça Ghoul",
    Callback=function()
        pcall(function()
            replicated.Remotes.CommF_:InvokeServer("BuyGhoulRace")
        end)
    end
})

RaceTab:CreateButton({
    Name="Comprar Raça Cyborg (2500F)",
    Callback=function()
        pcall(function()
            replicated.Remotes.CommF_:InvokeServer("BuyCyborgRace")
        end)
    end
})

RaceTab:CreateSection("🐾 Auto Upgrade Races")

local function autoRaceQuest(raceName, flagName, mobList)
    _G[flagName] = false
    RaceTab:CreateToggle({
        Name         = "Auto " .. raceName .. " V2/V3",
        CurrentValue = false,
        Flag         = flagName,
        Callback     = function(v)
            _G[flagName] = v
            if v then
                task.spawn(function()
                    while _G[flagName] do
                        pcall(function()
                            for _, mobName in ipairs(mobList) do
                                local mob = GetConnectionEnemies(mobName)
                                if mob then G.Kill(mob, _G[flagName]) end
                            end
                        end)
                        task.wait(Sec)
                    end
                end)
            end
        end
    })
end

autoRaceQuest("Mink",  "Auto_Mink",  {"Forest Pirate","Swan Pirate"})
autoRaceQuest("Human", "Auto_Human", {"Punk Hazard","Marine Lieutenant"})
autoRaceQuest("Fish",  "Auto_Fish",  {"Fishman Warrior","Fishman Lord"})
autoRaceQuest("Sky",   "Auto_Skypiea", {"Sky Bandits","Shanda"})

-- ============================================================
-- ══════════════ ABA 5: FIGHTING STYLES ══════════════
-- ============================================================
local FightTab = Window:CreateTab("🥊 Fighting Styles", "zap")

FightTab:CreateSection("🥊 Auto Treinar Fighting Styles")

local function autoFightStyle(name, flagName, mobList)
    _G[flagName] = false
    FightTab:CreateToggle({
        Name     = "Auto " .. name,
        CurrentValue = false,
        Flag     = flagName,
        Callback = function(v)
            _G[flagName] = v
            if v then
                task.spawn(function()
                    while _G[flagName] do
                        pcall(function()
                            for _, mobName in ipairs(mobList) do
                                local mob = GetConnectionEnemies(mobName)
                                if mob then G.Kill(mob, _G[flagName]) end
                            end
                        end)
                        task.wait(Sec)
                    end
                end)
            end
        end
    })
end

autoFightStyle("SuperHuman",       "Auto_SuperHuman",      {"Galley Pirates","Punk Hazard"})
autoFightStyle("Death Step",       "AutoDeathStep",        {"Ice Admiral","Snow Lurker"})
autoFightStyle("Electric Claw",    "Auto_Electric_Claw",   {"Thunderstruck Pirate"})
autoFightStyle("Dragon Talon",     "AutoDragonTalon",      {"Dragon Crew"})
autoFightStyle("Sharkman Karate",  "Auto_SharkMan_Karate", {"Sea Soldier","Fishman Lord"})
autoFightStyle("God Human",        "Auto_God_Human",       {"Demonic Soul","Soul Reaper"})
autoFightStyle("Dark Coat",        "Auto_Def_DarkCoat",    {"Dark Pirate","Longma"})

FightTab:CreateSection("⚔️ Auto Treinar Swords")

FightTab:CreateToggle({
    Name     = "Auto Ken V2 (Observation Haki)",
    CurrentValue = false,
    Flag     = "AutoKenV2",
    Callback = function(v)
        _G.AutoKenVTWO = v
        if v then
            task.spawn(function()
                while _G.AutoKenVTWO do
                    pcall(function()
                        local targets = {"Forest Pirate","Captain Elephant","Jeremy","Mob Leader"}
                        for _, name in ipairs(targets) do
                            local mob = GetConnectionEnemies(name)
                            if mob then
                                G.Kill(mob, _G.AutoKenVTWO)
                                repeat
                                    task.wait()
                                    G.Kill(mob, _G.AutoKenVTWO)
                                until not _G.AutoKenVTWO or mob.Humanoid.Health <= 0 or not mob.Parent
                            end
                        end
                    end)
                    task.wait(Sec)
                end
            end)
        end
    end
})

-- ============================================================
-- ══════════════ ABA 6: TELEPORT ══════════════
-- ============================================================
local TpTab = Window:CreateTab("🌍 Teleport", "map-pin")

TpTab:CreateSection("🌊 Sea 1 - Ilhas")
local Sea1 = {
    ["🏝️ Starter Island"]   = CFrame.new(-1264.8,40,1142.1),
    ["⚓ Marine Starter"]    = CFrame.new(977,37,1121),
    ["🌿 Jungle"]            = CFrame.new(-1714,40,-586),
    ["🏴‍☠️ Pirate Village"]  = CFrame.new(-1012,40,-1148),
    ["🏜️ Desert"]            = CFrame.new(941,40,-1391),
    ["❄️ Frozen Village"]    = CFrame.new(1492,40,-520),
    ["⚔️ Marine Fortress"]   = CFrame.new(1018,40,-2320),
    ["☁️ Skylands"]          = CFrame.new(-3980,857,-3560),
    ["🥊 Colosseum"]         = CFrame.new(-577,100,2000),
    ["⛓️ Impel Down"]        = CFrame.new(17,-186,-5049),
    ["🌊 Marineford"]        = CFrame.new(-4800,40,-5050),
}
for name, cf in pairs(Sea1) do
    local n, c = name, cf
    TpTab:CreateButton({Name=n, Callback=function() pcall(function() _tp(c) end) end})
end

TpTab:CreateSection("🌊 Sea 2 - Ilhas")
local Sea2 = {
    ["🌹 Kingdom of Rose"]   = CFrame.new(-234,15,1185),
    ["🌲 Green Zone"]        = CFrame.new(-2360,15,543),
    ["💀 Graveyard"]         = CFrame.new(3340,15,-860),
    ["🏔️ Snow Mountain"]     = CFrame.new(-2310,435,-2385),
    ["🏯 Ice Castle"]        = CFrame.new(700,150,-4950),
    ["🌴 Forgotten Island"]  = CFrame.new(4260,10,-4680),
    ["☕ Cafe"]               = CFrame.new(-92,73.8,1538),
    ["🌑 Dark Arena"]        = CFrame.new(-11561,917,-12423),
    ["🔥 Hot Island"]        = CFrame.new(-5255,15,-3250),
    ["🎪 Thriller Bark"]     = CFrame.new(-8490,10,2920),
    ["🏴 Flamingo HQ"]       = CFrame.new(-11580,10,-8007),
    ["🫧 Bubble Island"]     = CFrame.new(-12021,400,-7230),
}
for name, cf in pairs(Sea2) do
    local n, c = name, cf
    TpTab:CreateButton({Name=n, Callback=function() pcall(function() _tp(c) end) end})
end

TpTab:CreateSection("🌊 Sea 3 - Ilhas")
local Sea3 = {
    ["⚓ Port Town"]          = CFrame.new(-2076,50,-4491),
    ["🐍 Hydra Island"]      = CFrame.new(-12390,15,-8730),
    ["🐢 Floating Turtle"]   = CFrame.new(-13401,212,-5968),
    ["🌳 Great Tree"]        = CFrame.new(-15468,377,-8086),
    ["👻 Haunted Castle"]    = CFrame.new(-16754,70,1582),
    ["🍬 Sea of Treats"]     = CFrame.new(1141,15,-19250),
    ["🌫️ Mirage Island"]    = CFrame.new(-17755,15,-9421),
    ["🌴 Tiki Outpost"]      = CFrame.new(-14516,50,-10038),
    ["🦊 Kitsune Island"]    = CFrame.new(-19775,50,-11500),
    ["🦕 Prehistoric Island"]= CFrame.new(-14790,50,-6600),
}
for name, cf in pairs(Sea3) do
    local n, c = name, cf
    TpTab:CreateButton({Name=n, Callback=function() pcall(function() _tp(c) end) end})
end

-- ============================================================
-- ══════════════ ABA 7: ESP ══════════════
-- ============================================================
local ESPTab = Window:CreateTab("👁️ ESP", "eye")

local ESPEnabled   = false
local ESPBoxes     = {}
local ESPConns     = {}

local function removeAllESP()
    for _, v in pairs(ESPBoxes) do pcall(function() v:Destroy() end) end
    ESPBoxes = {}
    for _, c in pairs(ESPConns) do pcall(function() c:Disconnect() end) end
    ESPConns = {}
end

local function createPlayerESP(target)
    if not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bb = Instance.new("BillboardGui")
    bb.Name         = "VK_ESP"
    bb.AlwaysOnTop  = true
    bb.Size         = UDim2.new(0,150,0,50)
    bb.StudsOffset  = Vector3.new(0,3,0)
    bb.Parent       = hrp
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,220,50)
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Text = target.Name
    lbl.Parent = bb
    table.insert(ESPBoxes, bb)
    local conn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not ESPEnabled then return end
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum and hrp then
                local d   = math.floor((hrp.Position - Root.Position).Magnitude)
                local hp  = math.floor(hum.Health)
                local max = math.floor(hum.MaxHealth)
                lbl.Text = target.Name .. "\n❤️ "..hp.."/"..max.." | "..d.."m"
                lbl.TextColor3 = hum.Health < hum.MaxHealth * 0.3
                    and Color3.fromRGB(255,80,80)
                    or Color3.fromRGB(255,220,50)
            end
        end)
    end)
    table.insert(ESPConns, conn)
end

ESPTab:CreateSection("👁️ Player ESP")
ESPTab:CreateToggle({
    Name="👁️ ESP Players (Nome + HP + Distância)",CurrentValue=false,Flag="ESPPlayers",
    Callback=function(v)
        ESPEnabled = v
        if v then
            for _, p in pairs(ply:GetPlayers()) do
                if p ~= plr then createPlayerESP(p) end
            end
        else
            removeAllESP()
        end
    end
})

ESPTab:CreateToggle({
    Name="🔴 ESP Mobs (Enemies)",CurrentValue=false,Flag="ESPMobs",
    Callback=function(v)
        if v then
            task.spawn(function()
                while v do
                    pcall(function()
                        local ef = WS:FindFirstChild("Enemies")
                        if ef then
                            for _, mob in pairs(ef:GetChildren()) do
                                if not mob:FindFirstChild("VK_ESP") then
                                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local bb = Instance.new("BillboardGui")
                                        bb.Name="VK_ESP"; bb.AlwaysOnTop=true
                                        bb.Size=UDim2.new(0,120,0,30); bb.StudsOffset=Vector3.new(0,2,0)
                                        bb.Parent=hrp
                                        local lb = Instance.new("TextLabel")
                                        lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
                                        lb.TextColor3=Color3.fromRGB(255,100,100)
                                        lb.TextStrokeTransparency=0; lb.Font=Enum.Font.Gotham
                                        lb.TextSize=12; lb.Text=mob.Name; lb.Parent=bb
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        else
            local ef = WS:FindFirstChild("Enemies")
            if ef then
                for _, mob in pairs(ef:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bb = hrp:FindFirstChild("VK_ESP")
                        if bb then bb:Destroy() end
                    end
                end
            end
        end
    end
})

-- ============================================================
-- ══════════════ ABA 8: MISC / SETTINGS ══════════════
-- ============================================================
local MiscTab = Window:CreateTab("⚙️ Misc", "settings")

MiscTab:CreateSection("✈️ Fly")

local FlyEnabled = false
local flying     = false
local flyBody    = nil

local function startFly()
    if flying then return end
    flying = true
    local char = plr.Character
    if not char then return end
    flyBody = Instance.new("BodyVelocity")
    flyBody.Velocity  = Vector3.zero
    flyBody.MaxForce  = Vector3.new(math.huge, math.huge, math.huge)
    flyBody.Parent    = char:FindFirstChild("HumanoidRootPart")
    RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not flyBody or not flyBody.Parent then return end
        local cf  = WS.CurrentCamera.CFrame
        local vel = Vector3.zero
        local UIS = game:GetService("UserInputService")
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector  * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector  * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector * 80 end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,80,0) end
        flyBody.Velocity = vel
    end)
end

MiscTab:CreateToggle({
    Name="✈️ Fly",CurrentValue=false,Flag="Fly",
    Callback=function(v)
        FlyEnabled = v
        if v then startFly() else
            flying = false
            if flyBody then flyBody:Destroy(); flyBody = nil end
        end
    end
})

MiscTab:CreateSection("📉 Low CPU")

MiscTab:CreateButton({
    Name="📉 Ativar Low CPU Mode",
    Callback=function()
        pcall(function()
            local L = game.Lighting
            L.GlobalShadows = false; L.FogEnd = 9e9; L.Brightness = 1
            WS.Terrain.WaterWaveSize  = 0; WS.Terrain.WaterWaveSpeed = 0
            WS.Terrain.WaterReflectance = 0; WS.Terrain.WaterTransparency = 0
            settings().Rendering.QualityLevel = "Level01"
            for _, K in pairs(game:GetDescendants()) do
                pcall(function()
                    if K:IsA("ParticleEmitter") or K:IsA("Trail") then K.Lifetime = NumberRange.new(0)
                    elseif K:IsA("Fire") or K:IsA("Smoke") or K:IsA("Sparkles") then K.Enabled = false
                    elseif K:IsA("BlurEffect") or K:IsA("SunRaysEffect") or K:IsA("BloomEffect") then K.Enabled = false
                    end
                end)
            end
        end)
        Rayfield:Notify({Title="VKontakte",Content="Low CPU ativado!",Duration=3})
    end
})

MiscTab:CreateSection("💾 Configurações")

MiscTab:CreateButton({
    Name="💾 Salvar Tudo",
    Callback=function()
        SaveSettings()
        Rayfield:Notify({Title="VKontakte",Content="Configurações salvas!",Duration=3})
    end
})

MiscTab:CreateButton({
    Name="📂 Carregar Configurações",
    Callback=function()
        LoadSettings()
        Rayfield:Notify({Title="VKontakte",Content="Configurações carregadas!",Duration=3})
    end
})

MiscTab:CreateSection("ℹ️ Info")
MiscTab:CreateLabel("VKontakte Hub | discord.gg/BUtspHxrj")
MiscTab:CreateLabel("PVP Edition — Anti Stun | Auto Combo | V3/V4")

-- ============================================================
-- HUD ON-SCREEN
-- ============================================================
local HudGui = Instance.new("ScreenGui")
HudGui.Name="VK_HUD"; HudGui.ResetOnSpawn=false; HudGui.DisplayOrder=999; HudGui.IgnoreGuiInset=true
pcall(function() HudGui.Parent = game:GetService("CoreGui") end)

local HF = Instance.new("Frame")
HF.Size=UDim2.new(0,300,0,115); HF.Position=UDim2.new(0,10,0.5,-57)
HF.BackgroundColor3=Color3.fromRGB(8,8,12); HF.BackgroundTransparency=0.2
HF.BorderSizePixel=0; HF.Parent=HudGui

local HC = Instance.new("UICorner"); HC.CornerRadius=UDim.new(0,10); HC.Parent=HF
local HS = Instance.new("UIStroke"); HS.Color=Color3.fromRGB(255,200,40); HS.Thickness=1.5; HS.Parent=HF

local function newHUDLabel(text, y, color)
    local l = Instance.new("TextLabel")
    l.Size=UDim2.new(1,-10,0,18); l.Position=UDim2.new(0,5,0,y)
    l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamBold
    l.TextSize=13; l.TextColor3=color or Color3.fromRGB(255,255,255)
    l.TextStrokeTransparency=0.5; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=HF; return l
end

local LTitle   = newHUDLabel("⚔️ VKontakte Hub", 4,  Color3.fromRGB(255,210,40))
local LTime    = newHUDLabel("⏱ Time: 0s",       26, Color3.fromRGB(200,200,255))
local LBounty  = newHUDLabel("💰 Bounty: --",     46, Color3.fromRGB(255,210,40))
local LStatus  = newHUDLabel("🎯 Status: Idle",   66, Color3.fromRGB(180,255,180))
local LTarget  = newHUDLabel("👤 Target: --",     86, Color3.fromRGB(255,180,180))

-- Draggable HUD
do
    local drag, ds, sp
    HF.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=HF.Position
        end
    end)
    HF.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local delta = i.Position - ds
            HF.Position = UDim2.new(sp.X.Scale, sp.X.Offset+delta.X, sp.Y.Scale, sp.Y.Offset+delta.Y)
        end
    end)
end

local function fmtNum(n)
    local s = tostring(math.floor(n or 0))
    return s:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end

local sessionStart = os.time()

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Tempo
            local e = os.time()-sessionStart
            LTime.Text = "⏱ Time: "..math.floor(e/3600).."h"..math.floor((e%3600)/60).."m"..(e%60).."s"
            -- Bounty
            local b = 0
            pcall(function() b = plr.Data.Bounty.Value end)
            LBounty.Text = "💰 Bounty: "..fmtNum(b)
            -- Status
            local status = "Idle"
            if _G.AutoBounty or _G.Defeating then status = "🩸 Hunting Players"
            elseif _G.StartFarm and _G.Level   then status = "🌾 Farming Level"
            elseif AutoComboEnabled             then status = "💥 Auto Combo"
            elseif SilentAimEnabled             then status = "🔇 Silent Aim ON"
            end
            LStatus.Text = "🎯 Status: "..status
            -- Target
            if TargetPlayer and TargetPlayer ~= "(Nenhum)" then
                local tp = ply:FindFirstChild(TargetPlayer)
                if tp and tp.Character then
                    local hrp = tp.Character:FindFirstChild("HumanoidRootPart")
                    local hum = tp.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        local dist = math.floor((hrp.Position-Root.Position).Magnitude)
                        local hp   = math.floor(hum.Health)
                        LTarget.Text = "👤 "..tp.Name.." ❤️"..hp.." | "..dist.."m"
                    end
                end
            else
                local c = getClosestPlayer()
                if c and c.Character then
                    local hrp = c.Character:FindFirstChild("HumanoidRootPart")
                    local hum = c.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        local dist = math.floor((hrp.Position-Root.Position).Magnitude)
                        LTarget.Text = "👤 Near: "..c.Name.." | "..dist.."m"
                    end
                else
                    LTarget.Text = "👤 Target: --"
                end
            end
        end)
    end
end)

-- ============================================================
-- NOTIFICAÇÃO FINAL
-- ============================================================
Rayfield:Notify({
    Title    = "VKontakte Hub",
    Content  = "✅ Script carregado! PVP Edition",
    Duration = 6,
    Image    = "rbxassetid://103324203833614"
})
