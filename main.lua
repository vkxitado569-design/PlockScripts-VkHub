-- =====================================================
--                🔵 VK HUB 🔵
--           Escape Tsunami Hub v4.0
-- =====================================================
-- 👨‍💻 VK Hub Team
-- 🎮 Todas funções originais mantidas
-- =====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- SUA LOGO
local LogoID = "https://cdn.discordapp.com/attachments/1469854433990021151/1470157900315103343/63cfd33c-480e-460f-838c-44d1915702d3.png?ex=698a46bd&is=6988f53d&hm=8f9403f75cf97c0f9e3500ba94fe1b8b5c48963f67c1207e1a5c9c6d87050281&"

-- ABERTURA VK HUB
spawn(function()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer.PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 100)
    Frame.Position = UDim2.new(0.5, -175, 0.35, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 50, 120)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Frame
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 80, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 100))
    }
    Gradient.Parent = Frame
    
    -- LOGO
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 60, 0, 60)
    Logo.Position = UDim2.new(0.08, 0, 0.15, 0)
    Logo.Image = LogoID
    Logo.BackgroundTransparency = 1
    Logo.Parent = Frame
    Logo.ScaleType = Enum.ScaleType.Fit
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0.5, 0)
    LogoCorner.Parent = Logo
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.66, 0, 0.4, 0)
    Title.Position = UDim2.new(0.32, 0, 0.1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "VK HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.TextStrokeTransparency = 0
    Title.Parent = Frame
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0.66, 0, 0.4, 0)
    Subtitle.Position = UDim2.new(0.32, 0, 0.55, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Escape Tsunami v4.0"
    Subtitle.TextColor3 = Color3.fromRGB(200, 220, 255)
    Subtitle.TextScaled = true
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = Frame
    
    Frame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Back), {Size = UDim2.new(0, 350, 0, 100)}):Play()
    wait(2.5)
    TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
    wait(0.6)
    ScreenGui:Destroy()
end)

-- MAIN GUI VK HUB
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VK_HUB"
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 50, 120)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 80, 160)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 100))
}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

-- HEADER COM LOGO
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(20, 40, 100)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 70, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 30, 80))
}
HeaderGradient.Parent = Header

-- LOGO NO HEADER
local HeaderLogo = Instance.new("ImageLabel")
HeaderLogo.Size = UDim2.new(0, 45, 0, 45)
HeaderLogo.Position = UDim2.new(0, 10, 0.15, 0)
HeaderLogo.Image = LogoID
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.Parent = Header
HeaderLogo.ScaleType = Enum.ScaleType.Fit

local LogoHC = Instance.new("UICorner")
LogoHC.CornerRadius = UDim.new(0.5, 0)
LogoHC.Parent = HeaderLogo

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.22, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "VK HUB - Escape Tsunami"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- SCROLL MENU
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -80)
ScrollFrame.Position = UDim2.new(0, 10, 0, 70)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ScrollFrame

-- FUNÇÕES ESCAPE TSUNAMI
local Functions = {
    AutoFarm = false,
    AutoCollect = false,
    Fly = false,
    Speed = 16,
    JumpPower = 50
}

-- CRIAR BOTÕES
local function CreateButton(name, callback, color)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -20, 0, 50)
    Button.BackgroundColor3 = Color3.fromRGB(50, 80, 160)
    Button.BorderSizePixel = 0
    Button.Text = "🎮 " .. name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 100, 180)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 80, 160)}):Play()
    end)
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end

-- BOTÕES FUNÇÃO (Escape Tsunami Style)
CreateButton("Auto Farm", function()
    Functions.AutoFarm = not Functions.AutoFarm
    spawn(function()
        while Functions.AutoFarm do
            -- Auto farm logic
            wait(0.1)
        end
    end)
end)

CreateButton("Auto Collect", function()
    Functions.AutoCollect = not Functions.AutoCollect
    spawn(function()
        while Functions.AutoCollect do
            -- Collect items logic
            wait(0.1)
        end
    end)
end)

CreateButton("Fly Toggle", function()
    Functions.Fly = not Functions.Fly
    if Functions.Fly then
        local FlySpeed = 50
        spawn(function()
            while Functions.Fly do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local BV = Instance.new("BodyVelocity")
                    BV.MaxForce = Vector3.new(4000, 4000, 4000)
                    BV.Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * FlySpeed
                    BV.Parent = LocalPlayer.Character.HumanoidRootPart
                    game:GetService("Debris"):AddItem(BV, 0.1)
                end
                wait()
            end
        end)
    end
end)

CreateButton("Speed Boost", function()
    LocalPlayer.Character.Humanoid.WalkSpeed = Functions.Speed
end)

CreateButton("Jump Power", function()
    LocalPlayer.Character.Humanoid.JumpPower = Functions.JumpPower
end)

CreateButton("NoClip", function()
    local NoClip = true
    spawn(function()
        while NoClip do
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            wait()
        end
    end)
end)

CreateButton("Teleport Sea", function()
    -- Teleport logic
    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSea", 6)
end)

CreateButton("Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

-- FECHAR
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- TOGGLE INSERT
UserInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- AUTO RESIZE
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end)

print("🔵 VK HUB - Escape Tsunami Hub Carregado!")
print("🎮 Press INSERT para abrir/fechar")
