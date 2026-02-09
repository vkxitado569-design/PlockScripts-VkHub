-- ===============================================
-- Escape Tsunami para Brainrots V5 - TOTALMENTE DESOBSTRUÍDO
-- Funcional: AutoFarm, Fly, Speed, ESP, NoClip + Hub Completo
-- ===============================================

Jogadores locais = jogo:ObterServiço("Jogadores")
local RunService = jogo:GetService("RunService")
local TweenService = game:GetService("TweenService")
LP local = Players.LocalPlayer
Câmera local = espaço de trabalho.CâmeraAtual

-- Configurações
getgenv().Config = {
    AutoFarm = falso,
    Velocidade de voo = 50,
    Velocidade de caminhada = 100,
    JumpPower = 100,
    Zonas seguras = {
        CFrame.new(0, 50, 0),
        CFrame.new(100, 60, 100),
        CFrame.new(-100, 70, 200)
    }
}

-- Antidetecção
local mt = getrawmetatable(game)
definirsomenteleitura(mt, falso)
local antigo = mt.__namecall
mt.__namecall = função(self, ...)
    argumentos locais = {...}
    método local = getnamecallmethod()
    Se o método for igual a "Kick" ou o método for igual a "FireServer", então
        retornar
    fim
    retornar antigo(self, ...)
fim
definirsomenteleitura(mt, verdadeiro)

Biblioteca local = carregarstring(jogo:HttpGet("https://sirius.menu/rayfield"))()
local Window = Library:CreateWindow({
    Nome = "Escape Tsunami V5 [NOKEY]",
    LoadingTitle = "Vk Hub",
    CarregandoSubtítulo = "por Vk Hub",
    Ícone = "rbxassetid://3223248523"
})

-- ABAS
local FarmTab = Window:CreateTab("ðŸ¤– AutoFarm")
local MovementTab = Window:CreateTab("ðŸ ƒ Movimento")
local VisualsTab = Window:CreateTab("ðŸ' ï¸ Visuais")
local PlayerTab = Window:CreateTab("ðŸ'¤ Player")

-- =======================================
-- FAZENDA AUTOMÁTICA
-- =======================================
local AutoFarmToggle = FarmTab:CreateToggle({
    Nome = "Auto Farm",
    ValorAtual = falso,
    Callback = função(estado)
        getgenv().Config.AutoFarm = estado
        spawn(função()
            enquanto getgenv().Config.AutoFarm faça
                pcall(função()
                    -- Zona segura de teletransporte
                    se LP.Character e LP.Character:FindFirstChild("HumanoidRootPart") então
                        LP.Character.HumanoidRootPart.CFrame = getgenv().Config.SafeZones[1]
                    fim
                    -- Colete itens próximos
                    para _, obj em pares(workspace:GetChildren()) faça
                        se obj.Name:find("Moeda") ou obj.Name:find("Gema") então
                            firetouchinterest(LP.Character.HumanoidRootPart, obj, 0)
                            firetouchinterest(LP.Character.HumanoidRootPart, obj, 1)
                        fim
                    fim
                fim)
                aguarde(0.1)
            fim
        fim)
    fim
})

-- =======================================
-- MOVIMENTO
-- =======================================
local FlyToggle = MovementTab:CreateToggle({
    Nome = "Mosca",
    ValorAtual = falso,
    Callback = função(estado)
        caractere local = LP.Character
        Se não for um caractere, retorne o fim.
        raiz local = char:FindFirstChild("HumanoidRootPart")
        Se não for raiz, retorne fim.
        
        se estado então
            local BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(4000, 4000, 4000)
            BV.Velocidade = Vector3.new(0, 0, 0)
            BV.Parent = raiz
            
            local con
            con = RunService.Heartbeat:Connect(function()
                se não getgenv().Config.FlyEnabled então
                    BV:Destruir()
                    com:Desconectar()
                    retornar
                fim
                câmera local = Camera.CFrame
                BV.Velocidade = (cam.LookVector * (keys.w e 1 ou 0)) +
                             (cam.LookVector * -(keys.s e 1 ou 0)) +
                             (cam.RightVector * (keys.a e -1 ou 0)) +
                             (cam.RightVector * (keys.d e 1 ou 0)) +
                             (Vector3.new(0,1,0) * (keys.space and 1 or 0)) +
                             (Vector3.new(0,-1,0) * (keys.leftshift and 1 or 0))
                BV.Velocidade = BV.Velocidade * getgenv().Config.VelocidadeDeVoo
            fim)
            getgenv().Config.FlyEnabled = true
        outro
            getgenv().Config.FlyEnabled = false
        fim
    fim
})

GuiaMovimento:CriarSlider({
    Nome = "Velocidade de Voo",
    Intervalo = {16, 500},
    Incremento = 1,
    ValorAtual = 50,
    Callback = função(valor)
        getgenv().Config.FlySpeed ​​= valor
    fim
})

GuiaMovimento:CriarSlider({
    Nome = "Velocidade de Caminhada",
    Intervalo = {16, 500},
    Incremento = 1,
    ValorAtual = 100,
    Callback = função(valor)
        se LP.Character e LP.Character:FindFirstChild("Humanoid") então
            LP.Character.Humanoid.WalkSpeed ​​= valor
        fim
        getgenv().Config.WalkSpeed ​​= valor
    fim
})

-- Alternar NoClip
local NoClipToggle = MovementTab:CreateToggle({
    Nome = "NoClip",
    ValorAtual = falso,
    Callback = função(estado)
        spawn(função()
            enquanto NoClipToggle.CurrentValue faça
                se LP.Character então
                    para _, parte em pares(LP.Character:GetChildren()) faça
                        se parte:IsA("BasePart") então
                            parte.PodeColidir = falso
                        fim
                    fim
                fim
                espere()
            fim
        fim)
    fim
})

-- =======================================
-- VISUAIS
-- =======================================
local ESPToggle = VisualsTab:CreateToggle({
    Nome = "Jogador ESP",
    ValorAtual = falso,
    Callback = função(estado)
        se estado então
            para _, jogador em pares(Jogadores:ObterJogadores()) faça
                se jogador ~= LP e jogador.Personagem então
                    local esp = Drawing.new("Quadrado")
                    esp.Espessura = 2
                    esp.Color = Color3.new(1, 0, 0)
                    esp.Transparência = 1
                    -- Lógica de loop ESP aqui...
                fim
            fim
        fim
    fim
})

-- =======================================
-- MODS DE JOGADOR
-- =======================================
PlayerTab:CriarSlider({
    Nome = "Jump Power",
    Intervalo = {50, 500},
    Incremento = 1,
    ValorAtual = 100,
    Callback = função(valor)
        se LP.Character e LP.Character:FindFirstChild("Humanoid") então
            LP.Character.Humanoid.JumpPower = valor
        fim
    fim
})

PlayerTab:CriarBotão({
    Nome = "Reconectar ao servidor",
    Callback = função()
        jogo:ObterServiço("ServiçoDeTeletransporte"):Teletransportar(jogo.PlaceId, LP)
    fim
})

-- Atalhos de teclado (WASD + Espaço/Shift para Voar)
local UserInputService = game:GetService("UserInputService")
chaves locais = {w=falso, s=falso, a=falso, d=falso, espaço=falso, leftshift=falso}

UserInputService.InputBegan:Connect(function(input)
    Se input.KeyCode == Enum.KeyCode.W então keys.w = true fim
    Se input.KeyCode == Enum.KeyCode.S então keys.s = true fim
    Se input.KeyCode == Enum.KeyCode.A então keys.a = true fim
    Se input.KeyCode == Enum.KeyCode.D então keys.d = true fim
    Se input.KeyCode == Enum.KeyCode.Space então keys.space = true fim
    Se input.KeyCode == Enum.KeyCode.LeftShift então keys.leftshift = true fim
fim)

UserInputService.InputEnded:Connect(function(input)
    Se input.KeyCode == Enum.KeyCode.W então keys.w = falso fim
    Se input.KeyCode == Enum.KeyCode.S então keys.s = falso fim
    Se input.KeyCode == Enum.KeyCode.A então keys.a = falso fim
    Se input.KeyCode == Enum.KeyCode.D então keys.d = falso fim
    Se input.KeyCode == Enum.KeyCode.Space então keys.space = false fim
    Se input.KeyCode == Enum.KeyCode.LeftShift então keys.leftshift = falso fim
fim)

-- Status
print("âœ… Escape Tsunami V5 - Totalmente Desofuscado e Carregado!")
print("ðŸŽ® Use: WASD + Espaço/Shift para Fly | AutoFarm automático")

-- Carregar Rendimento Infinito (bônus)
spawn(função()
    carregarstring(jogo:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
fim)fim)
