-- VK HUB - Tsunami Brainrot v3.0 | PlockScripts
-- Carregado via: loadstring(game:HttpGet("https://raw.githubusercontent.com/PlockScripts/VkHub/refs/heads/main/main.luau"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🔴 VK HUB - Tsunami Brainrot", "DarkTheme")

local Player = game.Players.LocalPlayer
local TS = game:GetService("TweenService")

local Config = {
    AutoFarm = false, AutoCollect = false, AutoSell = false,
    LuckBlock = false, Brainrot = false, EventCoins = false,
    Speed = 16, Jump = 50, Radius = 50
}

local Items = {
    Coins = {"Coin","GoldCoin","MoneyBag"},
    Gems = {"Gem","Diamond","Crystal"},
    Boosts = {"SpeedBoost","JumpBoost","CoinBoost"},
    LuckBlock = {"LuckBlock","LuckyBlock"},
    Brainrot = {"BrainrotToken","BrainToken"},
    EventCoins = {"EventCoin","SpecialCoin","LimitedCoin"}
}

-- 🎯 COLETA TAB
local CollectTab = Window:NewTab("🎯 Coleta")
local Sec1 = CollectTab:NewSection("Coleta Rápida")

CollectTab:NewToggle("💰 Auto Moedas", "Coleta moedas", function(s)
    Config.AutoCollect = s
    task.spawn(function()
        while Config.AutoCollect do
            for _,o in workspace:GetChildren() do
                if table.find(Items.Coins, o.Name) then
                    local d = (o.Position-Player.Character.HumanoidRootPart.Position).Magnitude
                    if d <= Config.Radius then 
                        firetouchinterest(Player.Character.HumanoidRootPart,o,0) 
                        task.wait() 
                        firetouchinterest(Player.Character.HumanoidRootPart,o,1) 
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- 🎲 LUCK BLOCK
CollectTab:NewToggle("🎲 Luck Block", "Coleta Luck Blocks", function(s)
    Config.LuckBlock = s
    task.spawn(function()
        while Config.LuckBlock do
            for _,o in workspace:GetChildren() do
                if table.find(Items.LuckBlock, o.Name) then
                    local d = (o.Position-Player.Character.HumanoidRootPart.Position).Magnitude
                    if d <= 60 then
                        Player.Character.HumanoidRootPart.CFrame = o.CFrame + Vector3.new(0,5,0)
                        firetouchinterest(Player.Character.HumanoidRootPart,o,0) 
                        task.wait(0.2) 
                        firetouchinterest(Player.Character.HumanoidRootPart,o,1)
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end)

-- 🧠 BRAINROT
CollectTab:NewToggle("🧠 Brainrot Tokens", "Coleta tokens brainrot", function(s)
    Config.Brainrot = s
    task.spawn(function()
        while Config.Brainrot do
            for _,o in workspace:GetChildren() do
                if table.find(Items.Brainrot, o.Name) or o.Name:lower():find("brain") then
                    local d = (o.Position-Player.Character.HumanoidRootPart.Position).Magnitude
                    if d <= Config.Radius then 
                        firetouchinterest(Player.Character.HumanoidRootPart,o,0) 
                        task.wait() 
                        firetouchinterest(Player.Character.HumanoidRootPart,o,1) 
                    end
                end
            end
            task.wait(0.15)
        end
    end)
end)

-- ⭐ EVENT COINS
CollectTab:NewToggle("⭐ Event Coins", "Moedas de eventos", function(s)
    Config.EventCoins = s
    task.spawn(function()
        while Config.EventCoins do
            for _,o in workspace:GetChildren() do
                if table.find(Items.EventCoins, o.Name) or o.Name:lower():find("event") then
                    local d = (o.Position-Player.Character.HumanoidRootPart.Position).Magnitude
                    if d <= 70 then
                        Player.Character.HumanoidRootPart.CFrame = o.CFrame + Vector3.new(0,5,0)
                        firetouchinterest(Player.Character.HumanoidRootPart,o,0) 
                        task.wait() 
                        firetouchinterest(Player.Character.HumanoidRootPart,o,1)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- ⚡ FARM TAB
local FarmTab = Window:NewTab("⚡ Farm")
FarmTab:NewToggle("🚀 Auto Farm Tudo", "Farma tudo", function(s)
    Config.AutoFarm = s
    task.spawn(function()
        while Config.AutoFarm do
            for _,o in workspace:GetChildren() do
                local names = {}
                for _,v in pairs(Items) do 
                    for _,n in pairs(v) do 
                        table.insert(names,n) 
                    end 
                end
                if table.find(names, o.Name) then
                    local d = (o.Position-Player.Character.HumanoidRootPart.Position).Magnitude
                    if d <= 80 then
                        TS:Create(Player.Character.HumanoidRootPart,TweenInfo.new(0.3),{CFrame=o.CFrame+Vector3.new(0,5,0)}):Play()
                        firetouchinterest(Player.Character.HumanoidRootPart,o,0) 
                        task.wait(0.1) 
                        firetouchinterest(Player.Character.HumanoidRootPart,o,1)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- 👤 PLAYER TAB
local PlayerTab = Window:NewTab("👤 Player")
PlayerTab:NewSlider("WalkSpeed", "Velocidade", 200, 16, function(v) 
    if Player.Character?.Humanoid then 
        Player.Character.Humanoid.WalkSpeed = v 
    end 
end)
PlayerTab:NewSlider("JumpPower", "Pulo", 150, 50, function(v) 
    if Player.Character?.Humanoid then 
        Player.Character.Humanoid.JumpPower = v 
    end 
end)
PlayerTab:NewButton("🏠 Teleport Spawn", "Volta spawn", function()
    Player.Character.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0,5,0)
end)

-- 📊 STATS
local StatsTab = Window:NewTab("📊 Stats")
local CoinsL = StatsTab:NewLabel("Moedas: 0")
local GemsL = StatsTab:NewLabel("Gems: 0")

task.spawn(function()
    while task.wait(1) do
        local ls = Player:FindFirstChild("leaderstats")
        if ls then
            CoinsL:SetText("Moedas: "..(ls:FindFirstChild("Coins")?.Value or 0))
            GemsL:SetText("Gems: "..(ls:FindFirstChild("Gems")?.Value or 0))
        end
    end
end)

Library:Notify("🔴 VK HUB Tsunami carregado via GitHub!", 5)
Player.CharacterAdded:Connect(function() 
    task.wait(1) 
    Player.Character.Humanoid.WalkSpeed = 50 
end)
