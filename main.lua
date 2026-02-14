-- DesplockHub - Blade Ball Script
-- Logo: https://cdn.discordapp.com/icons/1436832766716018821/83e814783ecd86b218ad17b3b3388c17.png?size=2048

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variáveis do jogo
local Ball = Workspace:WaitForChild("Ball")
local Camera = Workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Configurações padrão
local Config = {
    AutoParry = false,
    AutoHit = false,
    ESP = false,
    KillAura = false,
    NoClip = false,
    Speed = 16,
    JumpPower = 50,
    FOVRadius = 150,
    VisibleFOV = false,
    Notifications = true
}

-- Criar GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local Logo = Instance.new("ImageLabel")
local Title = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")
local ContentFrame = Instance.new("ScrollingFrame")
local CombatSection = Instance.new("Frame")
local CombatTitle = Instance.new("TextLabel")
local AutoParryBtn = Instance.new("TextButton")
local AutoHitBtn = Instance.new("TextButton")
local KillAuraBtn = Instance.new("TextButton")
local VisualsSection = Instance.new("Frame")
local VisualsTitle = Instance.new("TextLabel")
local ESPBtn = Instance.new("TextButton")
local FOVBtn = Instance.new("TextButton")
local MovementSection = Instance.new("Frame")
local MovementTitle = Instance.new("TextLabel")
local SpeedSlider = Instance.new("TextButton")
local JumpSlider = Instance.new("TextButton")
local NoClipBtn = Instance.new("TextButton")

-- Configurar GUI
ScreenGui.Name = "DesplockHub"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

-- Corner arredondado
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Stroke
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(100, 150, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 50)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

Logo.Name = "Logo"
Logo.Parent = TitleBar
Logo.BackgroundTransparency = 1
Logo.Position = UDim2.new(0, 10, 0, 5)
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Image = "https://cdn.discordapp.com/icons/1436832766716018821/83e814783ecd86b218ad17b3b3388c17.png?size=2048"
Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 8)
LogoCorner.Parent = Logo

Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 60, 0, 0)
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "DesplockHub - Blade Ball"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = TitleBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Position = UDim2.new(1, -70, 0, 10)
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Font = Enum.Font.Gotham
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeBtn

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.ScrollBarThickness = 6
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)

-- Seções
local function createSection(parent, titleText, yPos)
    local section = Instance.new("Frame")
    section.Name = titleText .. "Section"
    section.Parent = parent
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    section.BorderSizePixel = 0
    section.Position = UDim2.new(0, 0, 0, yPos)
    section.Size = UDim2.new(1, -10, 0, 120)
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "Title"
    sectionTitle.Parent = section
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Position = UDim2.new(0, 15, 0, 10)
    sectionTitle.Size = UDim2.new(1, -30, 0, 25)
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.Text = titleText
    sectionTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
    sectionTitle.TextSize = 14
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    return section, sectionTitle
end

CombatSection, CombatTitle = createSection(ContentFrame, "⚔️ COMBAT", 10)
VisualsSection, VisualsTitle = createSection(ContentFrame, "👁️ VISUALS", 140)
MovementSection, MovementTitle = createSection(ContentFrame, "🚀 MOVEMENT", 270)

-- Botões Combat
local function createToggleButton(parent, text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text .. "Btn"
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.BorderSizePixel = 0
    btn.Position = pos
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Font = Enum.Font.Gotham
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(60, 60, 70)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    
    return btn
end

AutoParryBtn = createToggleButton(CombatSection, "Auto Parry", UDim2.new(0, 15, 0, 45), function(btn)
    Config.AutoParry = not Config.AutoParry
    btn.Text = "Auto Parry: " .. (Config.AutoParry and "ON" or "OFF")
    btn.TextColor3 = Config.AutoParry and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
end)

AutoHitBtn = createToggleButton(CombatSection, "Auto Hit", UDim2.new(0, 235, 0, 45), function(btn)
    Config.AutoHit = not Config.AutoHit
    btn.Text = "Auto Hit: " .. (Config.AutoHit and "ON" or "OFF")
    btn.TextColor3 = Config.AutoHit and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
end)

KillAuraBtn = createToggleButton(CombatSection, "Kill Aura", UDim2.new(0, 15, 0, 85), function(btn)
    Config.KillAura = not Config.KillAura
    btn.Text = "Kill Aura: " .. (Config.KillAura and "ON" or "OFF")
    btn.TextColor3 = Config.KillAura and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
end)

-- Botões Visuals
ESPBtn = createToggleButton(VisualsSection, "Player ESP", UDim2.new(0, 15, 0, 45), function(btn)
    Config.ESP = not Config.ESP
    btn.Text = "Player ESP: " .. (Config.ESP and "ON" or "OFF")
    btn.TextColor3 = Config.ESP and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
end)

FOVBtn = createToggleButton(VisualsSection, "Visible FOV", UDim2.new(0, 235, 0, 45), function(btn)
    Config.VisibleFOV = not Config.VisibleFOV
    btn.Text = "Visible FOV: " .. (Config.VisibleFOV and "ON" or "OFF")
    btn.TextColor3 = Config.VisibleFOV and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
end)

-- Botões Movement
NoClipBtn = createToggleButton(MovementSection, "NoClip", UDim2.new(0, 15, 0, 45), function(btn)
    Config.NoClip = not Config.NoClip
    btn.Text = "NoClip: " .. (Config.NoClip and "ON" or "OFF")
    btn.TextColor3 = Config.NoClip and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
end)

-- Sliders simples
local function createSlider(parent, text, pos, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = text .. "Slider"
    sliderFrame.Parent = parent
    sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Position = pos
    sliderFrame.Size = UDim2.new(0, 200, 0, 35)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = sliderFrame
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Parent = sliderFrame
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Size = UDim2.new(1, 0, 0.6, 0)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Text = text .. ": " .. defaultValue
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.TextSize = 12
    
    return sliderFrame, sliderLabel
end

SpeedSlider, SpeedLabel = createSlider(MovementSection, "Speed", UDim2.new(0, 15, 0, 85), Config.Speed, function(value)
    Config.Speed = value
end)

JumpSlider, JumpLabel = createSlider(MovementSection, "Jump Power", UDim2.new(0, 235, 0, 85), Config.JumpPower, function(value)
    Config.JumpPower = value
end)

-- Funcionalidades do jogo
local ESPConnections = {}
local FOVCircle = nil

-- Auto Parry
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- ESP System
local function createESP(player)
    if ESPConnections[player] then return end
    
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP"
    esp.Parent = player.Character.HumanoidRootPart
    esp.Size = UDim2.new(0, 100, 0, 50)
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.AlwaysOnTop = true
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = esp
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    ESPConnections[player] = esp
end

-- FOV Circle
local function createFOVCircle()
    if FOVCircle then FOVCircle:Destroy() end
    
    FOVCircle = Instance.new("ImageLabel")
    FOVCircle.Parent = Camera
    FOVCircle.Name = "FOVCircle"
    FOVCircle.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
    FOVCircle.Position = UDim2.new(0.5, -Config.FOVRadius, 0.5, -Config.FOVRadius)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    FOVCircle.ImageColor3 = Color3.fromRGB(100, 150, 255)
    FOVCircle.ImageTransparency = 0.7
    FOVCircle.ZIndex = -1
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- NoClip
    if Config.NoClip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Speed
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = Config.Speed
        character.Humanoid.JumpPower = Config.JumpPower
    end
    
    -- Auto Parry
    if Config.AutoParry and Ball.Parent then
        local distanceToBall = (Ball.Position - character.HumanoidRootPart.Position).Magnitude
        if distanceToBall < 25 then
            fireclickdetector(Ball:FindFirstChildOfClass("ClickDetector"))
        end
    end
    
    -- Kill Aura
    if Config.KillAura then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (closestPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
            if distance < 20 then
                fireclickdetector(closestPlayer.Character:FindFirstChildOfClass("ClickDetector"))
            end
        end
    end
    
    -- FOV Circle
    if Config.VisibleFOV and FOVCircle then
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end)

-- ESP Toggle
ESPBtn.MouseButton1Click:Connect(function()
    Config.ESP = not Config.ESP
    
    if Config.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createESP(player)
            end
        end
    else
        for player, esp in pairs(ESPConnections) do
            if esp then esp:Destroy() end
        end
        ESPConnections = {}
    end
end)

-- FOV Toggle
FOVBtn.MouseButton1Click:Connect(function()
    Config.VisibleFOV = not Config.VisibleFOV
    if Config.VisibleFOV then
        createFOVCircle()
    elseif FOVCircle then
        FOVCircle:Destroy()
        FOVCircle = nil
    end
end)

-- Botões da TitleBar
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 450, 0, 50), "Out", "Quad", 0.3)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Player Added/Removing
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Config.ESP then
            wait(1)
            createESP(player)
        end
    end)
end)

-- Notificação de carregamento
if Config.Notifications then
    game.StarterGui:SetCore("SendNotification", {
        Title = "DesplockHub";
        Text = "Blade Ball Script carregado com sucesso!";
        Duration = 3;
    })
end

print("DesplockHub carregado com sucesso!")
