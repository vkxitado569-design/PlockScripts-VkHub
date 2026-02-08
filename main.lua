-- VK HUB - SCRIPT PREMIUM AZUL
-- Logo personalizada carregada!

loadstring(game:HttpGet("https://raw.githubusercontent.com/osakaTP2/OsakaTP2/main/Escape%20Tsunami%20For%20BrainrotsUFOV4"))()

-- INTERFACE VK HUB AZUL COM NOVA LOGO
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

spawn(function()
    wait(1.2)
    
    -- Renomear todas as GUIs para VK HUB
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("Osaka") or gui.Name:find("Tsunami") or gui.Name:find("Brainrot") then
            gui.Name = "VK_HUB"
        end
        
        -- Trocar todas as cores para AZUL
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
                obj.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Azul principal
            elseif obj:IsA("UIStroke") then
                obj.Color = Color3.fromRGB(0, 191, 255) -- Azul claro stroke
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if obj.TextColor3 ~= Color3.fromRGB(255,255,255) then
                    obj.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                if obj.Text:find("Osaka") or obj.Text:find("Tsunami") then
                    obj.Text = obj.Text:gsub("Osaka", "VK HUB"):gsub("Tsunami", "VK HUB"):gsub("Brainrot", "VK HUB")
                end
            elseif obj:IsA("ImageLabel") then
                obj.Image = "https://cdn.discordapp.com/attachments/1469854433990021151/1470157900315103343/63cfd33c-480e-460f-838c-44d1915702d3.png?ex=698a46bd&is=6988f53d&hm=8f9403f75cf97c0f9e3500ba94fe1b8b5c48963f67c1207e1a5c9c6d87050281&"
                obj.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
    
    -- Logo de abertura VK HUB AZUL
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VKHUB_LOGO"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Name = "LogoFrame"
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(0, 50, 150) -- Azul escuro
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.5, -160, 0.3, 0)
    Frame.Size = UDim2.new(0, 320, 0, 90)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Frame
    
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 50, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 144, 255))
    }
    UIGradient.Rotation = 45
    UIGradient.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 191, 255)
    Stroke.Thickness = 2.5
    Stroke.Parent = Frame
    
    -- LOGO PERSONALIZADA
    local Logo = Instance.new("ImageLabel")
    Logo.Name = "VKLogo"
    Logo.Parent = Frame
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0.05, 0, 0.1, 0)
    Logo.Size = UDim2.new(0, 70, 0, 70)
    Logo.Image = "https://cdn.discordapp.com/attachments/1469854433990021151/1470157900315103343/63cfd33c-480e-460f-838c-44d1915702d3.png?ex=698a46bd&is=6988f53d&hm=8f9403f75cf97c0f9e3500ba94fe1b8b5c48963f67c1207e1a5c9c6d87050281&"
    Logo.ScaleType = Enum.ScaleType.Fit
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(1, 0)
    LogoCorner.Parent = Logo
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.3, 0, 0.15, 0)
    Title.Size = UDim2.new(0.65, 0, 0.7, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "VK HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.TextStrokeTransparency = 0
    Title.TextStrokeColor3 = Color3.fromRGB(0, 191, 255)
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Parent = Frame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.3, 0, 0.75, 0)
    Subtitle.Size = UDim2.new(0.65, 0, 0.25, 0)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "v4.0 - Escape Tsunami"
    Subtitle.TextColor3 = Color3.fromRGB(173, 216, 230)
    Subtitle.TextScaled = true
    
    -- Animação entrada
    Frame.Size = UDim2.new(0, 0, 0, 0)
    local tweenIn = TweenService:Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Back), {Size = UDim2.new(0, 320, 0, 90)})
    tweenIn:Play()
    
    tweenIn.Completed:Wait()
    wait(2)
    
    -- Animação saída
    local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    ScreenGui:Destroy()
end)

print("🔵 VK HUB - Carregado com sucesso!")
print("📱 Logo personalizada aplicada!")
print("🎮 Cor azul ativada!")
