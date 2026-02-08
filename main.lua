-- VK HUB Tsunami Brainrot v4.0 | DELTA FIX
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🔴 VK HUB - Tsunami Brainrot", "DarkTheme")

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local Config = {AutoFarm=false, AutoCollect=false, LuckBlock=false, Brainrot=false, EventCoins=false, Speed=16, Jump=50, Radius=50}

local Items = {
    Coins={"Coin","GoldCoin","MoneyBag"},
    Gems={"Gem","Diamond","Crystal"},
    LuckBlock={"LuckBlock","LuckyBlock"},
    Brainrot={"BrainrotToken","BrainToken"},
    EventCoins={"EventCoin","SpecialCoin","LimitedCoin"}
}

-- COLETA TAB
local CollectTab = Window:NewTab("🎯 Coleta")
CollectTab:NewToggle("💰 Auto Moedas", "Coleta moedas", function(s)
    Config.AutoCollect = s
    spawn(function()
        while Config.AutoCollect do
            for _,o in pairs(game.Workspace:GetChildren()) do
                if table.find(Items.Coins, o.Name) then
                    local char = Player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local d = (o.Position-char.HumanoidRootPart.Position).Magnitude
                        if d <= Config.Radius then
                            firetouchinterest(char.HumanoidRootPart, o, 0)
                            wait()
                            firetouchinterest(char.HumanoidRootPart, o, 1)
                        end
                    end
                end
            end
            wait(0.1)
        end
    end)
end)

-- LUCK BLOCK
CollectTab:NewToggle("🎲 Luck Block", "Coleta Luck Blocks", function(s)
    Config.LuckBlock = s
    spawn(function()
        while Config.LuckBlock do
            for _,o in pairs(game.Workspace:GetChildren()) do
                if table.find(Items.LuckBlock, o.Name) then
                    local char = Player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local d = (o.Position-char.HumanoidRootPart.Position).Magnitude
                        if d <= 60 then
                            char.HumanoidRootPart.CFrame = o.CFrame + Vector3.new(0,5,0)
                            firetouchinterest(char.HumanoidRootPart, o, 0)
                            wait(0.2)
                            firetouchinterest(char.HumanoidRootPart, o, 1)
                        end
                    end
                end
            end
            wait(0.2)
        end
    end)
end)

-- BRAINROT
CollectTab:NewToggle("🧠 Brainrot", "Coleta Brainrot", function(s)
    Config.Brainrot = s
    spawn(function()
        while Config.Brainrot do
            for _,o in pairs(game.Workspace:GetChildren()) do
                if table.find(Items.Brainrot, o.Name) or string.find(string.lower(o.Name), "brain") then
                    local char = Player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local d = (o.Position-char.HumanoidRootPart.Position).Magnitude
                        if d <= Config.Radius then
                            firetouchinterest(char.HumanoidRootPart, o, 0)
                            wait()
                            firetouchinterest(char.HumanoidRootPart, o, 1)
                        end
                    end
                end
            end
            wait(0.15)
        end
    end)
end)

-- EVENT COINS
CollectTab:NewToggle("⭐ Event Coins", "Coleta eventos", function(s)
    Config.EventCoins = s
    spawn(function()
        while Config.EventCoins do
            for _,o in pairs(game.Workspace:GetChildren()) do
                if table.find(Items.EventCoins, o.Name) or string.find(string.lower(o.Name), "event") then
                    local char = Player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local d = (o.Position-char.HumanoidRootPart.Position).Magnitude
                        if d <= 70 then
                            char.HumanoidRootPart.CFrame = o.CFrame + Vector3.new(0,5,0)
                            firetouchinterest(char.HumanoidRootPart, o, 0)
                            wait()
                            firetouchinterest(char.HumanoidRootPart, o, 1)
                        end
                    end
                end
            end
            wait(0.1)
        end
    end)
end)

-- FARM TAB
local FarmTab = Window:NewTab("⚡ Farm")
FarmTab:NewToggle("🚀 Auto Farm Tudo", "Tudo automatico", function(s)
    Config.AutoFarm = s
    spawn(function()
        while Config.AutoFarm do
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local allItems = {}
                for _,cat in pairs(Items) do
                    for _,name in pairs(cat) do
                        table.insert(allItems, name)
                    end
                end
                for _,o in pairs(game.Workspace:GetChildren()) do
                    if table.find(allItems, o.Name) then
                        local d = (o.Position-char.HumanoidRootPart.Position).Magnitude
                        if d <= 80 then
                            TweenService:Create(char.HumanoidRootPart, TweenInfo.new(0.3), {CFrame=o.CFrame+Vector3.new(0,5,0)}):Play()
                            firetouchinterest(char.HumanoidRootPart, o, 0)
                            wait(0.1)
                            firetouchinterest(char.HumanoidRootPart, o, 1)
                        end
                    end
                end
            end
            wait(0.05)
        end
    end)
end)

-- PLAYER TAB
local PlayerTab = Window:NewTab("👤 Player")
PlayerTab:NewSlider("WalkSpeed", "Velocidade", 200, 16, function(v)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
end)

PlayerTab:NewSlider("JumpPower", "Pulo", 150, 50, function(v)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = v
    end
end)

PlayerTab:NewButton("🏠 Spawn", "Teleport spawn", function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and workspace:FindFirstChild("SpawnLocation") then
        char.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0,5,0)
    end
end)

-- STATS
local StatsTab = Window:NewTab("📊 Stats")
local CoinsL = StatsTab:NewLabel("Moedas: 0")
local GemsL = StatsTab:NewLabel("Gems: 0")

spawn(function()
    while wait(1) do
        local ls = Player:FindFirstChild("leaderstats")
        if ls then
            local coins = ls:FindFirstChild("Coins")
            local gems = ls:FindFirstChild("Gems")
            CoinsL:SetText("Moedas: "..(coins and coins.Value or 0))
            GemsL:SetText("Gems: "..(gems and gems.Value or 0))
        end
    end
end)

Library:Notify("🔴 VK HUB v4.0 DELTA OK!", 5)

Player.CharacterAdded:Connect(function()
    wait(1)
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 50
    end
end)
