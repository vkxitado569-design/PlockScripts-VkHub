-- VK HUB Tsunami Brainrot v5.0 | OSAKA STYLE + RARIDADES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- UI PRINCIPAL (Osaka Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VKHUB"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- LOGO + MINIMIZE (Osaka Style)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -60, 1, 0)
Logo.Position = UDim2.new(0, 15, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "🔴 VK HUB - Tsunami Brainrot v5.0"
Logo.TextColor3 = Color3.fromRGB(255, 50, 50)
Logo.TextScaled = true
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -50, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = MinimizeBtn

-- CONTENT FRAME
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 60)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 6
Content.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = Content

-- CONFIG
local Config = {
    AutoCollect=false, LuckBlock=false, Brainrot=false, EventCoins=false,
    Rarity="All", EventType="All", Speed=16, Jump=50, Radius=60
}

local Items = {
    Coins={"Coin","GoldCoin","MoneyBag"},
    LuckBlock={"LuckBlock","LuckyBlock"},
    Brainrot={"BrainrotToken","BrainToken"},
    EventCoins={"EventCoin","SpecialCoin","LimitedCoin"}
}

local Rarities = {"Common", "Rare", "Epic", "Legendary", "Mythic", "All"}

-- FUNÇÃO COLETA
local function CollectItem(itemName, tpFunc)
    spawn(function()
        while Config[itemName] do
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), string.lower(itemName:lower())) or 
                       table.find(Items[itemName], obj.Name) then
                        local dist = (obj.Position - char.HumanoidRootPart.Position).Magnitude
                        if dist <= Config.Radius then
                            if tpFunc then tpFunc(obj) end
                            firetouchinterest(char.HumanoidRootPart, obj, 0)
                            wait(0.1)
                            firetouchinterest(char.HumanoidRootPart, obj, 1)
                        end
                    end
                end
            end
            wait(0.15)
        end
    end)
end

-- TOGGLE FUNCTION
local function CreateToggle(name, desc, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.Parent = Content
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 8)
    TCorner.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -10, 0.5, -15)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextScaled = true
    ToggleBtn.Parent = ToggleFrame
    local BtnC = Instance.new("UICorner")
    BtnC.CornerRadius = UDim.new(0, 6)
    BtnC.Parent = ToggleBtn

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name .. "\n" .. desc
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local toggled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        ToggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = toggled and "ON" or "OFF"
        callback(toggled)
    end)
end

-- SLIDER FUNCTION
local function CreateSlider(name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SliderFrame.Parent = Content
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 8)
    SCorner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -120, 0.5, 0)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamBold
    Label.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 100, 0.5, 0)
    ValueLabel.Position = UDim2.new(1, -115, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    ValueLabel.TextScaled = true
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -30, 0, 6)
    SliderBar.Position = UDim2.new(0, 15, 1, -15)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.Parent = SliderFrame
    local SBarCorner = Instance.new("UICorner")
    SBarCorner.CornerRadius = UDim.new(0, 3)
    SBarCorner.Parent = SliderBar

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = SliderFill

    local dragging = false
    SliderFill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    SliderFill.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

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

-- DROPDOWN FUNCTION (Eventos)
local function CreateDropdown(name, options, default, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, 0, 0, 40)
    DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DropFrame.Parent = Content
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(0, 8)
    DCorner.Parent = DropFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 200, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamBold
    Label.Parent = DropFrame

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(1, -30, 1, 0)
    DropBtn.Position = UDim2.new(0, 220, 0, 0)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropBtn.Text = default .. " ▼"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.Gotham
    DropBtn.TextScaled = true
    DropBtn.Parent = DropFrame
    local DBtnCorner = Instance.new("UICorner")
    DBtnCorner.CornerRadius = UDim.new(0, 6)
    DBtnCorner.Parent = DropBtn

    local dropdownOpen = false
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, -30, 0, 0)
    DropdownList.Position = UDim2.new(0, 220, 1, 5)
    DropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DropdownList.Visible = false
    DropdownList.Parent = DropFrame
    local DListCorner = Instance.new("UICorner")
    DListCorner.CornerRadius = UDim.new(0, 6)
    DListCorner.Parent = DropdownList

    local DListLayout = Instance.new("UIListLayout")
    DListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DListLayout.Padding = UDim.new(0, 2)
    DListLayout.Parent = DropdownList

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextScaled = true
        OptBtn.Parent = DropdownList
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = opt .. " ▼"
            Config[name:gsub(" ", ""):gsub("-", "")] = opt
            callback(opt)
            dropdownOpen = false
            DropdownList.Visible = false
        end)
    end

    DropBtn.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        DropdownList.Visible = dropdownOpen
        DropdownList.Size = UDim2.new(1, 0, 0, #options * 32)
    end)
end

-- MINIMIZE LOGIC
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    MinimizeBtn.Text = minimized and "+" or "−"
    if minimized then
        MainFrame.Size = UDim2.new(0, 420, 0, 50)
    else
        MainFrame.Size = UDim2.new(0, 420, 0, 380)
    end
end)

-- TOGGLES
CreateToggle("💰 Auto Moedas", "Coleta todas moedas", function(state)
    Config.AutoCollect = state
    CollectItem("Coins")
end)

CreateToggle("🎲 Luck Block", "Coleta por raridade", function(state)
    Config.LuckBlock = state
    CollectItem("LuckBlock", function(obj)
        -- Teleport para luck blocks
        local char = Player.Character
        if char then char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0,5,0) end
    end)
end)

CreateToggle("🧠 Brainrot", "Coleta tokens brainrot", function(state)
    Config.Brainrot = state
    CollectItem("Brainrot")
end)

CreateToggle("⭐ Event Coins", "Coleta por evento", function(state)
    Config.EventCoins = state
    CollectItem("EventCoins")
end)

-- DROPDOWNS
CreateDropdown("Luck Rarity", Rarities, "All", function(value)
    Config.Rarity = value
    print("Luck Rarity:", value)
end)

local Events = {"Summer", "Halloween", "Christmas", "NewYear", "All"}
CreateDropdown("Event Type", Events, "All", function(value)
    Config.EventType = value
    print("Event Type:", value)
end)

-- SLIDERS
CreateSlider("WalkSpeed", 16, 200, 50, function(v)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
end)

CreateSlider("JumpPower", 50, 150, 50, function(v)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = v
    end
end)

CreateSlider("Collect Radius", 30, 100, 60, function(v)
    Config.Radius = v
end)

-- TP BUTTON
local TPFrame = Instance.new("TextButton")
TPFrame.Size = UDim2.new(1, 0, 0, 35)
TPFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
TPFrame.Text = "🏠 Teleport Spawn"
TPFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
TPFrame.Font = Enum.Font.GothamBold
TPFrame.TextScaled = true
TPFrame.Parent = Content
local TPCorner = Instance.new("UICorner")
TPCorner.CornerRadius = UDim.new(0, 8)
TPCorner.Parent = TPFrame

TPFrame.MouseButton1Click:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and workspace:FindFirstChild("SpawnLocation") then
        char.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0,5,0)
    end
end)

-- AUTO RESPAWN FIX
Player.CharacterAdded:Connect(function()
    wait(2)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = Config.Speed
        char.Humanoid.JumpPower = Config.Jump
    end
end)

print("🔴 VK HUB v5.0 OSAKA STYLE CARREGADO!")
