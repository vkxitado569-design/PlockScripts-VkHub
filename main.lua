-- VK HUB Blade Ball Native v1.0 | Auto Farm + Ball Lock
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

-- UI ROXA (mesmo style VK HUB)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BladeBallHub"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(80, 20, 120)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 40, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 10, 100))
}
Gradient.Parent = MainFrame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(100, 30, 160)
Header.Parent = MainFrame
local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 16)
HCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔴 VK HUB Blade Ball v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

-- Config
local Config = {
    BallLock = false,
    AutoParry = false,
    KillAura = false,
    Speed = 50,
    Jump = 100,
    AutoBuy = false
}

-- Ball tracking
local Ball = nil
local NearestPlayer = nil
local Connections = {}

-- FIND BALL
local function FindBall()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "ball" or string.find(obj.Name:lower(), "ball") then
            return obj
        end
    end
    return nil
end

-- FIND NEAREST ENEMY
local function FindNearestEnemy()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if distance < dist then
                closest = player
                dist = distance
            end
        end
    end
    return closest
end

-- BALL LOCK (auto mira)
local function BallLock()
    Ball = FindBall()
    if Ball and Config.BallLock then
        -- Predict trajectory
        local ballVelocity = Ball.Velocity
        local predictPos = Ball.Position + (ballVelocity * 0.2)
        
        -- Lock camera
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictPos)
        
        -- Hit ball
        local distance = (Ball.Position - HumanoidRootPart.Position).Magnitude
        if distance < 50 then
            local hitDirection = (Ball.Position - HumanoidRootPart.Position).Unit
            HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, Ball.Position)
            
            -- Fire hit remote
            local hitRemote = ReplicatedStorage:FindFirstChild("HitBall") or 
                            ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Hit")
            if hitRemote then
                hitRemote:FireServer(Ball)
            end
        end
    end
end

-- AUTO PARRY
local function AutoParry()
    Ball = FindBall()
    if Ball and Config.AutoParry then
        local ballToPlayer = (Ball.Position - HumanoidRootPart.Position).Magnitude
        local velocityToPlayer = Ball.Velocity:Dot((HumanoidRootPart.Position - Ball.Position).Unit)
        
        -- Parry when ball coming fast
        if ballToPlayer < 30 and velocityToPlayer > 50 then
            HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, Ball.Position)
            
            -- Parry remote
            local parryRemote = ReplicatedStorage:FindFirstChild("Parry") or 
                              ReplicatedStorage.Remotes:FindFirstChild("ParryBall")
            if parryRemote then
                parryRemote:FireServer()
            end
        end
    end
end

-- KILL AURA
local function KillAura()
    NearestPlayer = FindNearestEnemy()
    if NearestPlayer and Config.KillAura and NearestPlayer.Character then
        local targetPos = NearestPlayer.Character.HumanoidRootPart.Position
        HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, targetPos)
        
        -- Attack remote
        local attackRemote = ReplicatedStorage:FindFirstChild("Attack") or 
                           ReplicatedStorage.Remotes:FindFirstChild("Damage")
        if attackRemote then
            attackRemote:FireServer(NearestPlayer)
        end
    end
end

-- AUTO BUY
spawn(function()
    while Config.AutoBuy do
        wait(2)
        local buyRemote = ReplicatedStorage:FindFirstChild("Buy") or 
                        ReplicatedStorage.Shop:FindFirstChild("Purchase")
        if buyRemote then
            buyRemote:FireServer("BestSword") -- ou "BestShield"
        end
    end
end)

-- TOGGLES
local function CreateToggle(name, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(90, 30, 140)
    Frame.Parent = Instance.new("ScrollingFrame", MainFrame)
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 12)
    FCorner.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 35)
    Btn.Position = UDim2.new(1, -10, 0.5, -17.5)
    Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
    Btn.Text = "OFF"
    Btn.Parent = Frame
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamSemibold
    Label.Parent = Frame
    
    local toggled = false
    Btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        Btn.BackgroundColor3 = toggled and Color3.fromRGB(50, 255, 150) or Color3.fromRGB(200, 50, 200)
        Btn.Text = toggled and "ON" or "OFF"
        callback(toggled)
    end)
end

-- ScrollFrame setup
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -75)
Scroll.Position = UDim2.new(0, 10, 0, 65)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 8
Scroll.Parent = MainFrame
local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Scroll

-- Create toggles
CreateToggle("🎯 Ball Lock + Auto Hit", function(state) Config.BallLock = state end)
CreateToggle("🛡️ Auto Parry", function(state) Config.AutoParry = state end)
CreateToggle("⚔️ Kill Aura", function(state) Config.KillAura = state end)
CreateToggle("🛒 Auto Buy Best", function(state) Config.AutoBuy = state end)

-- Speed/Jump sliders (simplified)
local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(1, 0, 0, 40)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(90, 30, 140)
SpeedSlider.Text = "🚀 Speed: 50"
SpeedSlider.Parent = Scroll
local SSCorner = Instance.new("UICorner")
SSCorner.CornerRadius = UDim.new(0, 12)
SSCorner.Parent = SpeedSlider

SpeedSlider.MouseButton1Click:Connect(function()
    Config.Speed = Config.Speed + 20
    if Config.Speed > 200 then Config.Speed = 16 end
    SpeedSlider.Text = "🚀 Speed: " .. Config.Speed
    if Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = Config.Speed
    end
end)

-- MAIN LOOP
Connections.Main = RunService.Heartbeat:Connect(function()
    BallLock()
    AutoParry()
    KillAura()
end)

-- Character respawn
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = Config.Speed
    end
end)

print("🔴 Blade Ball Hub carregado! Ball Lock + Parry ativo!")
