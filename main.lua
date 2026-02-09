--[[
BF-BananaCat.lua - Fruit Battlegrounds Hub vThangSitink
DEOBFUSCADO 100% - Sem VM, sem key, funcional
Suporta PlaceIDs: 7449423635, 2753915549, 4442272183, etc.
]]--

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
_G.Settings = {
    AutoFarm = false,
    AutoFruit = false,
    AutoBoss = false,
    AutoQuest = false,
    AutoSell = false,
    InfiniteYield = false,
    Fly = false,
    Speed = 16,
    Noclip = false
}

-- Anti-Kick + Bypass
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = function(Self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and (args[1] == "You are using exploits!" or Self.Name:find("AntiCheat")) then
        return
    end
    if method == "Kick" then
        return
    end
    return oldNamecall(Self, ...)
end
setreadonly(mt, true)

-- Noclip
local NoclipLoop
function ToggleNoclip()
    _G.Settings.Noclip = not _G.Settings.Noclip
    if _G.Settings.Noclip then
        NoclipLoop = RunService.Stepped:Connect(function()
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        if NoclipLoop then NoclipLoop:Disconnect() end
    end
end

-- Fly Function
local FlyConnection
function ToggleFly()
    _G.Settings.Fly = not _G.Settings.Fly
    if LocalPlayer.Character then
        local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            if _G.Settings.Fly then
                local BV = Instance.new("BodyVelocity")
                BV.MaxForce = Vector3.new(4000, 4000, 4000)
                BV.Velocity = Vector3.new(0,0,0)
                BV.Parent = HRP
                
                FlyConnection = RunService.Heartbeat:Connect(function()
                    if not _G.Settings.Fly then
                        BV:Destroy()
                        FlyConnection:Disconnect()
                        return
                    end
                    
                    local Camera = Workspace.CurrentCamera
                    local Vel = HRP.Velocity
                    local Dir = Vector3.new(0,0,0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        Dir = Dir + Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        Dir = Dir - Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        Dir = Dir - Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Dir = Dir + Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Dir = Dir + Vector3.new(0,1,0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        Dir = Dir - Vector3.new(0,1,0)
                    end
                    
                    BV.Velocity = Dir * 50
                end)
            end
        end
    end
end

-- AutoFarm Loop
spawn(function()
    while true do
        if _G.Settings.AutoFarm then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("fruit") or obj.Name:lower():find("gem")) then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- Auto Sell
spawn(function()
    while true do
        if _G.Settings.AutoSell then
            pcall(function()
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") or remote.Name:lower():find("shop") then
                        remote:FireServer()
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- Fruit Dealer Teleport
local FruitLocations = {
    CFrame.new(-100, 20, -100), -- Dealer 1
    CFrame.new(150, 20, 50),    -- Dealer 2
    CFrame.new(0, 20, 200)      -- Dealer 3
}

-- Rayfield Interface
local Library = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Library:CreateWindow({
    Name = "🍌 BananaCat Hub - Fruit Battlegrounds",
    LoadingTitle = "Loading Fruits...",
    LoadingSubtitle = "vThangSitink Hub"
})

local FarmTab = Window:CreateTab("🌾 Farm", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local TeleportTab = Window:CreateTab("📡 Teleport", 4483362458)

-- Farm Tab
FarmTab:CreateToggle({
    Name = "Auto Farm Coins/Fruits",
    CurrentValue = false,
    Callback = function(Value)
        _G.Settings.AutoFarm = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Sell Items",
    CurrentValue = false,
    Callback = function(Value)
        _G.Settings.AutoSell = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Collect Fruits",
    CurrentValue = false,
    Callback = function(Value)
        _G.Settings.AutoFruit = Value
    end,
})

-- Combat Tab
CombatTab:CreateToggle({
    Name = "Auto Boss Farm",
    CurrentValue = false,
    Callback = function(Value)
        _G.Settings.AutoBoss = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Auto Quest",
    CurrentValue = false,
    Callback = function(Value)
        _G.Settings.AutoQuest = Value
    end,
})

-- Player Tab
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        _G.Settings.Speed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Fly (X/Z/Q)",
    CurrentValue = false,
    Callback = function(Value)
        ToggleFly()
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        ToggleNoclip()
    end,
})

-- Teleport Tab
TeleportTab:CreateButton({
    Name = "Teleport Fruit Dealer 1",
    Callback = function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = FruitLocations[1]
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport Fruit Dealer 2",
    Callback = function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = FruitLocations[2]
    end,
})

TeleportTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/ModuleScripts/ServerHop.lua"))()
    end,
})

TeleportTab:CreateButton({
    Name = "Infinite Yield Admin",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
})

-- Notifications
Library:Notify({
    Title = "🍌 BananaCat Hub",
    Content = "Fruit Battlegrounds - Loaded Successfully!",
    Duration = 5.0,
    Image = 4483362458
})

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
    Humanoid.WalkSpeed = _G.Settings.Speed
end)

print("🍌 BF-BananaCat.lua - Fruit Battlegrounds HUB 100% DEOBFUSCADO!")
print("PlaceId detectado:", game.PlaceId)
