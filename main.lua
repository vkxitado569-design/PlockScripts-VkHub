-- VK HUB Tsunami v6.0 | ROXO AUTO + CELESTIAL + WAVE SKIP
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- UI ROXA GIGANTE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VKHUB_ROXO"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)  -- MAIOR!
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(80, 20, 120)  -- ROXO!
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Glow = Instance.new("UIGradient")
Glow.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 40, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 10, 100))
}
Glow.Rotation = 45
Glow.Parent = MainFrame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainFrame

-- HEADER ROXO
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(100, 30, 160)
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -70, 1, 0)
Logo.Position = UDim2.new(0, 20, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "🔴 VK HUB v6.0 | AUTO CELESTIAL + ROXO"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextScaled = true
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 45, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -55, 0.5, -17.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = MinimizeBtn

-- CONTENT SCROLL ROXO
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -80)
Content.Position = UDim2.new(0, 10, 0, 70)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 8
Content.ScrollBarImageColor3 = Color3.fromRGB(150, 50, 200)
Content.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.Parent = Content

-- CONFIG AUTO
local Config = {
    AutoCollect=false, AutoLuck=false, AutoBrainrot=false, AutoEvent=false,
    AutoWave=false, Radius=80, Speed=80
}

-- ITENS AUTO DETECT (CELESTIAL + RARIDADES)
local CelestialItems = {"Celestial", "Legendary", "Mythic", "Godly", "Divine"}
local NormalItems = {"Coin", "GoldCoin", "Gem", "Diamond", "EventCoin"}

-- LOOP PRINCIPAL AUTO
local Loops = {}
local function StartLoop(name, func)
    if Loops[name] then Loops[name]:Disconnect() end
    Loops[name] = RunService.Heartbeat:Connect(function()
        if Config[name] then func() end
    end)
end

-- AUTO COLETA CELESTIAL
local function AutoCollectAll()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, obj in pairs(workspace:GetChildren()) do
        local objName = obj.Name:lower()
        local dist = (obj.Position - char.HumanoidRootPart.Position).Magnitude
        
        -- DETECT CELESTIAL/LUCK/BRAINROT AUTO
        local isCelestial = false
        for _, cel in ipairs(CelestialItems) do
            if string.find(objName, cel:lower()) then isCelestial = true break end
        end
        
        local isCollect = table.find(NormalItems, obj.Name) or 
                         string.find(objName, "coin") or string.find(objName, "gem") or
                         string.find(objName, "luck") or string.find(objName, "block") or
                         string.find(objName, "brain") or string.find(objName, "token")
        
        if (isCelestial or isCollect) and dist <= Config.Radius then
            -- TP + TOUCH AUTO
            char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 8, 0)
            firetouchinterest(char.HumanoidRootPart, obj, 0)
            task.wait(0.05)
            firetouchinterest(char.HumanoidRootPart, obj, 1)
        end
    end
end

-- AUTO WAVE SKIP
local function AutoWaveSkip()
    local char = Player.Character
    if not char then return end
    
    -- PROCURA BOTÃO NEXT WAVE OU SIMILAR
    for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local name = gui.Name:lower()
            if string.find(name, "next") or string.find(name, "wave") or 
               string.find(name, "skip") or string.find(name, "advance") then
                fireclickdetector(gui:FindFirstChildOfClass("ClickDetector") or gui.Parent:FindFirstChildOfClass("ClickDetector"))
                gui:Activate()
            end
        end
    end
    
    -- TELEPORTA PRA FRENTE (onda)
    local hrp = char.HumanoidRootPart
    TweenService:Create(hrp, TweenInfo.new(0.5), {
        CFrame = hrp.CFrame + hrp.CFrame.LookVector * 100
    }):Play()
end

-- TOGGLE ROXO AUTO
local function CreateToggle(name, emoji, autoFunc)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(90, 30, 140)
    ToggleFrame.Parent = Content
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 12)
    TCorner.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 35)
    ToggleBtn.Position = UDim2.new(1, -10, 0.5, -17.5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextScaled = true
    ToggleBtn.Parent = ToggleFrame
    local BtnC = Instance.new("UICorner")
    BtnC.CornerRadius = UDim.new(0, 8)
    BtnC.Parent = ToggleBtn

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 20, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = emoji .. " " .. name .. "\n(Automático Celestial)"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local active = false
    ToggleBtn.MouseButton1Click:Connect(function()
        active = not active
        ToggleBtn.BackgroundColor3 = active and Color3.fromRGB(50, 255, 150) or Color3.fromRGB(200, 50, 200)
        ToggleBtn.Text = active and "ON " .. emoji or "OFF"
        Config[name:gsub(" ", "")] = active
        
        if active then
            StartLoop(name:gsub(" ", ""), autoFunc)
        else
            if Loops[name:gsub(" ", "")] then 
                Loops[name:gsub(" ", "")]:Disconnect() 
            end
        end
    end)
end

-- SLIDER ROXO
local function CreateSlider(name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(90, 30, 140)
    SliderFrame.Parent = Content
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 12)
    SCorner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -140, 0.4, 0)
    Label.Position = UDim2.new(0, 20, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamBold
    Label.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 120, 0.4, 0)
    ValueLabel.Position = UDim2.new(1, -140, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
    ValueLabel.TextScaled = true
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -40, 0, 8)
    SliderBar.Position = UDim2.new(0, 20, 1, -18)
    SliderBar.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
    SliderBar.Parent = SliderFrame
    local SBarCorner = Instance.new("UICorner")
    SBarCorner.CornerRadius = UDim.new(0, 4)
    SBarCorner.Parent = SliderBar

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(150, 255, 200)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = SliderFill

    -- DRAG SLIDER
    local dragging = false
    SliderFill.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    SliderFill.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)
end

-- MINIMIZE
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    MinimizeBtn.Text = minimized and "+" or "−"
    MainFrame.Size = minimized and UDim2.new(0, 500, 0, 60) or UDim2.new(0, 500, 0, 450)
end)

-- TOGGLES AUTO
CreateToggle("Auto Farm Tudo", "🌟", AutoCollectAll)
CreateToggle("Auto Wave Skip", "🌊", AutoWaveSkip)
CreateToggle("Auto Celestial", "⭐", AutoCollectAll)  -- MESMA FUNC MAS PRIORIDADE CELESTIAL

-- SLIDERS
CreateSlider("Velocidade", 16, 200, 80, function(v)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = v end
end)

CreateSlider("Raio Coleta", 40, 150, 80, function(v) Config.Radius = v end)

-- TP BUTTON ROXO
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(1, 0, 0, 45)
TPBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
TPBtn.Text = "🚀 SPAWN + FARM BOOST"
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.Font = Enum.Font.GothamBold
TPBtn.TextScaled = true
TPBtn.Parent = Content
local TPC = Instance.new("UICorner")
TPC.CornerRadius = UDim.new(0, 12)
TPC.Parent = TPBtn

TPBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    if char and char.HumanoidRootPart and workspace:FindFirstChild("SpawnLocation") then
        char.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0,10,0)
        Config.AutoCollect = true
        StartLoop("AutoCollect", AutoCollectAll)
    end
end)

-- RESPAWN AUTO FIX
Player.CharacterAdded:Connect(function()
    task.wait(1.5)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 80
    end
end)

print("🔴 VK HUB v6.0 ROXO AUTO CELESTIAL CARREGADO! 🌟")
