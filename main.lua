-- VK HUB - SEM BORDAS AZUIS + LOGO PATO TROCADAS
loadstring(game:HttpGet("https://raw.githubusercontent.com/osakaTP2/OsakaTP2/main/Escape%20Tsunami%20For%20BrainrotsUFOV4"))()

-- CORREÇÕES FINAIS VK HUB
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

spawn(function()
    wait(1.8)
    
    -- MODIFICAÇÕES EXATAS SEM BORDAS
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("Osaka") or gui.Name:find("Tsunami") or gui.Name:find("Brainrot") then
            gui.Name = "VK_HUB"
        end
        
        for _, obj in pairs(gui:GetDescendants()) do
            -- TROCAR LOGO PATO POR SUA LOGO
            if obj:IsA("ImageLabel") and (obj.Image:find("pato") or obj.Image:find("Pato") or obj.Name:find("Pato")) then
                obj.Image = "https://cdn.discordapp.com/attachments/1469854433990021151/1470157900315103343/63cfd33c-480e-460f-838c-44d1915702d3.png?ex=698a46bd&is=6988f53d&hm=8f9403f75cf97c0f9e3500ba94fe1b8b5c48963f67c1207e1a5c9c6d87050281&"
                obj.ImageColor3 = Color3.fromRGB(255, 255, 255)
            elseif obj:IsA("ImageLabel") then
                obj.Image = "https://cdn.discordapp.com/attachments/1469854433990021151/1470157900315103343/63cfd33c-480e-460f-838c-44d1915702d3.png?ex=698a46bd&is=6988f53d&hm=8f9403f75cf97c0f9e3500ba94fe1b8b5c48963f67c1207e1a5c9c6d87050281&"
            end
            
            -- REMOVER TODAS AS BORDAS AZUIS
            if obj:IsA("UIStroke") then
                obj:Destroy() -- Remove completamente as bordas
            end
            
            -- NOME OSAKA → VK HUB
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                obj.TextColor3 = Color3.fromRGB(255, 255, 255)
                obj.Text = obj.Text:gsub("Osaka", "VK HUB"):gsub("pato", "VK"):gsub("Pato", "VK")
                
                -- Cor de fundo azul escuro limpo (sem bordas)
                if obj.Parent:IsA("Frame") or obj.Parent:IsA("TextButton") then
                    obj.Parent.BackgroundColor3 = Color3.fromRGB(20, 30, 60)
                end
            end
            
            -- Cores limpas azul sem bordas
            if obj:IsA("Frame") or obj:IsA("TextButton") then
                obj.BackgroundColor3 = Color3.fromRGB(20, 30, 60)
                obj.BorderSizePixel = 0
            end
            
            -- Gradientes azuis suaves (sem bordas)
            if obj:IsA("UIGradient") then
                obj.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 60, 120)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 50))
                }
            end
        end
    end
    
    -- ABERTURA FINAL SEM BORDAS
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VKHUB_FINAL"
    ScreenGui.Parent = PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Name = "FinalFrame"
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    Frame.BorderSizePixel = 0  -- SEM BORDA
    Frame.Position = UDim2.new(0.5, -175, 0.35, 0)
    Frame.Size = UDim2.new(0, 350, 0, 100)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Frame
    
    -- GRADIENT SEM BORDA
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 50, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 15, 40))
    }
    Gradient.Rotation = 45
    Gradient.Parent = Frame
    
    -- SUA LOGO (sem borda)
    local Logo = Instance.new("ImageLabel")
    Logo.Name = "VKLogo"
    Logo.Parent = Frame
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0.08, 0, 0.15, 0)
    Logo.Size = UDim2.new(0, 60, 0, 60)
    Logo.Image = "https://cdn.discordapp.com/attachments/1469854433990021151/1470157900315103343/63cfd33c-480e-460f-838c-44d1915702d3.png?ex=698a46bd&is=6988f53d&hm=8f9403f75cf97c0f9e3500ba94fe1b8b5c48963f67c1207e1a5c9c6d87050281&"
    Logo.ScaleType = Enum.ScaleType.Fit
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0.5, 0)
    LogoCorner.Parent = Logo
    
    -- Títulos limpos
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.3, 0, 0.1, 0)
    Title.Size = UDim2.new(0.68, 0, 0.4, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "VK HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.TextStrokeTransparency = 0
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = Frame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.3, 0, 0.55, 0)
    Subtitle.Size = UDim2.new(0.68, 0, 0.4, 0)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Loaded - No Borders"
    Subtitle.TextColor3 = Color3.fromRGB(180, 200, 255)
    Subtitle.TextScaled = true
    
    -- Animação
    Frame.Size = UDim2.new(0, 0, 0, 0)
    game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Back), 
    {Size = UDim2.new(0, 350, 0, 100)}):Play()
    
    wait(2.5)
    game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.5), 
    {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
    
    wait(0.6)
    ScreenGui:Destroy()
end)

print("🔵 VK HUB - Logo Pato trocada!")
print("❌ Todas bordas removidas!")
print("📝 Osaka → VK HUB!")
print("✅ Perfeito agora!")
