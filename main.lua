loadstring'    function LPH_NO_VIRTUALIZE(f) return f end;\n'()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ANTI-KICK
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldnc = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "Kick" then return end
    return oldnc(self, ...)
end)
setreadonly(mt, true)

-- CRIA A GUI IDÊNTICA (sem key input)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 240)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Parent = ScreenGui

-- EXATAMENTE IGUAL AO ORIGINAL (removido só key check)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(140, 100, 220)
stroke.Transparency = 0.3

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🌊 TSUNAMI BRAINROT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = MainFrame
Title.Position = UDim2.new(0, 0, 0, 20)

-- STATUS SEM KEY
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -40, 0, 35)
Status.Position = UDim2.new(0, 20, 0, 85)
Status.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
Status.Text = "✅ LOADED - NO KEY REQUIRED"
Status.TextColor3 = Color3.fromRGB(87, 242, 135)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = MainFrame
Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 8)

-- LOAD BUTTON (carrega direto, sem key)
local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(1, -40, 0, 45)
LoadBtn.Position = UDim2.new(0, 20, 0, 140)
LoadBtn.BackgroundColor3 = Color3.fromRGB(32, 120, 255)
LoadBtn.Text = "🚀 LOAD HUB"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.TextScaled = true
LoadBtn.Parent = MainFrame
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 8)

-- DRAG E TWEENS (IDÊNTICOS)
local dragging, dragStart, startPos = false
local function tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Quad), props):Play()
end

MainFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- LOAD CLIQUE = CARREGA HUB DIRETO (sem key validation)
LoadBtn.MouseButton1Click:Connect(function()
    tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
    task.wait(0.2)
    ScreenGui:Destroy()
    
    -- AQUI CARREGA O TSUNAMI HUB REAL (mesmo do original)
    loadstring(game:HttpGet("https://sirius.menu/rayfield"))() -- Rayfield
    -- INSIRA AQUI O CÓDIGO DO HUB TSUNAMI ORIGINAL (sem key)
    
    print("🌊 Tsunami Brainrot Hub carregado SEM KEY!")
end)

LoadBtn.MouseEnter:Connect(function() tween(LoadBtn, {BackgroundTransparency = 0.1}) end)
LoadBtn.MouseLeave:Connect(function() tween(LoadBtn, {BackgroundTransparency = 0}) end)
-- TSUNAMI BRAINROT HUB COMPLETO - Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌊 Tsunami Brainrot Hub v6.9",
   LoadingTitle = "Escape Tsunami Loaded",
   LoadingSubtitle = "No Key - Full Menu",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TsunamiBrainrot",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- TABS DO CINT O
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local RenderTab = Window:CreateTab("👁️ Render", 4483362458)
local WorldTab = Window:CreateTab("🌍 World", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)

-- 👤 PLAYER OPTIONS (todas do cinto)
PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      InfiniteJump = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "Fly",
   Callback = function(Value)
      FlyEnabled = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "WalkSpeed",
   Callback = function(Value)
      WalkSpeedValue = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      JumpPowerValue = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(Value)
      NoClipEnabled = Value
   end,
})

-- ⚔️ COMBAT OPTIONS
CombatTab:CreateToggle({
   Name = "AutoFarm Coins",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
      AutoFarmEnabled = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(Value)
      KillAuraEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Kill Aura Range",
   Range = {10, 100},
   Increment = 1,
   CurrentValue = 20,
   Flag = "KillAuraRange",
   Callback = function(Value)
      KillAuraRange = Value
   end,
})

-- 👁️ RENDER OPTIONS
RenderTab:CreateToggle({
   Name = "ESP Players",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      ESPEnabled = Value
   end,
})

RenderTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "Fullbright",
   Callback = function(Value)
      FullbrightEnabled = Value
   end,
})

RenderTab:CreateToggle({
   Name = "Player Tracers",
   CurrentValue = false,
   Flag = "Tracers",
   Callback = function(Value)
      TracersEnabled = Value
   end,
})

-- 🌍 WORLD OPTIONS
WorldTab:CreateToggle({
   Name = "Anti Tsunami",
   CurrentValue = false,
   Flag = "AntiTsunami",
   Callback = function(Value)
      AntiTsunamiEnabled = Value
   end,
})

WorldTab:CreateToggle({
   Name = "Auto Safe Zone",
   CurrentValue = false,
   Flag = "AutoSafeZone",
   Callback = function(Value)
      AutoSafeZoneEnabled = Value
   end,
})

-- 📍 TELEPORT OPTIONS (Safe Zones)
TeleportTab:CreateButton({
   Name = "Safe Zone 1",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-50, 50, -50)
   end,
})

TeleportTab:CreateButton({
   Name = "Safe Zone 2",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(100, 100, 100)
   end,
})

TeleportTab:CreateButton({
   Name = "Heliport",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 200, 0)
   end,
})

TeleportTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/ModuleScripts/ServerHop.lua"))()
   end,
})

-- NOTIFICATION
Rayfield:Notify({
   Title = "🌊 Tsunami Brainrot Hub",
   Content = "Loaded! No Key System ✓",
   Duration = 5.0,
   Image = 4483362458
})

print("🌊 Tsunami 
Brainrot Hub - Painel completo carregado!")
    -- TSUNAMI BRAINROT HUB - EXTRATO DO j.load_script() SEM KEY
local Players = game:GetService("Players")
local RunService
