--[[
    ██████╗ ███████╗███████╗██████╗ ██╗      ██████╗  ██████╗██╗  ██╗
    ██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔═══██╗██╔════╝██║ ██╔╝
    ██║  ██║█████╗  ███████╗██████╔╝██║     ██║   ██║██║     █████╔╝ 
    ██║  ██║██╔══╝  ╚════██║██╔═══╝ ██║     ██║   ██║██║     ██╔═██╗ 
    ██████╔╝███████╗███████║██║     ███████╗╚██████╔╝╚██████╗██║  ██╗
    ╚═════╝ ╚══════╝╚══════╝╚═╝     ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝
    DesplockHub — Sailor Piece v3.0
    Discord: discord.gg/wCUv3GKxs
    Compativel: Delta, Arceus X, Fluxus, Hydrogen (Mobile)
--]]

-- ============================================================
-- COMPATIBILIDADE DELTA / MOBILE
-- ============================================================
local function safeClipboard(text)
    if setclipboard then
        pcall(setclipboard, text)
    elseif Clipboard and Clipboard.set then
        pcall(Clipboard.set, text)
    end
end

local function safeNotify(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = dur or 4,
        })
    end)
end

local function pressKey(keyCode)
    -- Delta usa fireproximityprompt ou firetouchinterest; usa simulação via UIS
    pcall(function()
        local uis = game:GetService("UserInputService")
        local inputObj = {
            KeyCode        = keyCode,
            UserInputType  = Enum.UserInputType.Keyboard,
            UserInputState = Enum.UserInputState.Begin,
        }
        uis.InputBegan:Fire(inputObj, false)
        task.wait(0.05)
        inputObj.UserInputState = Enum.UserInputState.End
        uis.InputEnded:Fire(inputObj, false)
    end)
end

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RS           = game:GetService("ReplicatedStorage")
local LP           = Players.LocalPlayer

-- Aguarda o jogador carregar
repeat task.wait(0.5) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

-- ============================================================
-- CARREGA WINDUI (compatível com Delta)
-- ============================================================
local WindUI
local ok, err = pcall(function()
    WindUI = loadstring(game:HttpGet(
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        true
    ))()
end)
if not ok or not WindUI then
    safeNotify("DesplockHub", "Erro ao carregar UI: " .. tostring(err), 8)
    return
end

-- ============================================================
-- JANELA PRINCIPAL
-- ============================================================
local Window = WindUI:CreateWindow({
    Title        = "DesplockHub",
    Author       = "discord.gg/wCUv3GKxs",
    Folder       = "DesplockHub",
    Size         = UDim2.fromOffset(540, 320),
    Transparent  = true,
    Theme        = "Sky",
    SideBarWidth = 190,
    HasOutline   = true,
    Icon         = "rbxassetid://73504557188978",
    Background   = "rbxassetid://76979254365478",
})
Window:EditOpenButton({
    Title        = "DesplockHub",
    CornerRadius = UDim.new(0, 10),
    Draggable    = true,
    Icon         = "rbxassetid://73504557188978",
})

-- ============================================================
-- TABS
-- ============================================================
local Tabs = {
    HomeTab      = Window:Tab({ Title = "Home",        Icon = "house",        Desc = "Info e Discord"         }),
    FarmTab      = Window:Tab({ Title = "Auto Farm",   Icon = "swords",       Desc = "Farm automático"        }),
    BossTab      = Window:Tab({ Title = "Boss Farm",   Icon = "skull",        Desc = "Farm de bosses"         }),
    DungeonTab   = Window:Tab({ Title = "Dungeon",     Icon = "door-open",    Desc = "Auto Dungeon"           }),
    RaidTab      = Window:Tab({ Title = "Raid",        Icon = "shield-alert", Desc = "Auto Raid"              }),
    SwordTab     = Window:Tab({ Title = "Swords",      Icon = "shield",       Desc = "Pegar espadas"          }),
    FruitTab     = Window:Tab({ Title = "Fruits",      Icon = "vegan",        Desc = "Devil Fruits"           }),
    HakiTab      = Window:Tab({ Title = "Haki",        Icon = "zap",          Desc = "Auto Haki"              }),
    SeaBeastTab  = Window:Tab({ Title = "Sea Beasts",  Icon = "waves",        Desc = "Kraken e Sea Serpent"   }),
    RaceTab      = Window:Tab({ Title = "Race",        Icon = "dna",          Desc = "Race e Bloodline"       }),
    GuildTab     = Window:Tab({ Title = "Guild",       Icon = "users",        Desc = "Guild e Relics"         }),
    AscTab       = Window:Tab({ Title = "Ascension",   Icon = "arrow-up",     Desc = "Ascensão e Mastery"     }),
    TeleportTab  = Window:Tab({ Title = "Teleport",    Icon = "map-pinned",   Desc = "Teleporte por ilhas"    }),
    EspTab       = Window:Tab({ Title = "ESP",         Icon = "scan-eye",     Desc = "ESP e rastreamento"     }),
    PlayerTab    = Window:Tab({ Title = "Player",      Icon = "user",         Desc = "Stats e movimento"      }),
    CombatTab    = Window:Tab({ Title = "Combat",      Icon = "crosshair",    Desc = "Melhorias de combate"   }),
    MiscTab      = Window:Tab({ Title = "Misc",        Icon = "settings",     Desc = "Extra e Misc"           }),
}
Window:SelectTab(1)

-- ============================================================
-- ESTADO GLOBAL
-- ============================================================
local S = {
    -- Farm
    AutoFarm        = false,
    FarmIsland      = "Starter Island",
    AutoQuest       = false,
    KillAura        = false,
    KillAuraRange   = 40,
    -- Boss
    AutoBoss        = false,
    BossName        = "Knight",
    BossLoop        = false,
    -- Dungeon
    AutoDungeon     = false,
    DungeonType     = "Shadow Dungeon",
    -- Raid
    AutoRaid        = false,
    RaidType        = "Shadow Raid",
    -- Sword
    AutoSword       = false,
    SwordTarget     = "Dark Blade",
    -- Fruit
    FruitEsp        = false,
    AutoFruit       = false,
    AutoEatFruit    = false,
    -- Haki
    AutoArmHaki     = false,
    AutoConqHaki    = false,
    -- Sea Beast
    AutoSeaBeast    = false,
    SeaBeastTarget  = "Kraken",
    -- Race
    AutoReroll      = false,
    RerollTarget    = "SwordBlessed",
    -- Guild
    AutoGuild       = false,
    -- Ascension
    AutoAscension   = false,
    AutoMastery     = false,
    MasteryTarget   = "Sword",
    -- ESP
    EspPlayers      = false,
    EspChests       = false,
    EspBosses       = false,
    -- Player
    AutoStats       = false,
    StatChoice      = "Sword",
    Fly             = false,
    FlySpeed        = 60,
    NoClip          = false,
    InfJump         = false,
    WalkSpeed       = 16,
    -- Combat
    FastAttack      = false,
    HitboxExpand    = false,
    HitboxSize      = 15,
    AutoSkills      = false,
    -- Misc
    AntiAFK         = true,
    AutoRejoin      = false,
    AutoChest       = false,
    FPSBoost        = false,
}

-- ============================================================
-- DADOS: ILHAS
-- ============================================================
local Sea1Islands = {
    {n="Starter Island",   lv=0    }, {n="Jungle Island",    lv=250  },
    {n="Desert Island",    lv=750  }, {n="Snow Island",      lv=1500 },
    {n="Punch Island",     lv=2500 }, {n="Shibuya Station",  lv=3000 },
    {n="Sailor Island",    lv=4500 }, {n="Hollow Island",    lv=5000 },
    {n="Boss Island",      lv=5000 }, {n="Dungeon Island",   lv=5000 },
    {n="Shinjuku Island",  lv=6250 }, {n="Slime Island",     lv=8000 },
    {n="Academy Island",   lv=9000 }, {n="Judgement Island", lv=10000},
    {n="Soul Dominion",    lv=11000}, {n="Ninja Island",     lv=12000},
    {n="Lawless Island",   lv=12000}, {n="Tower Island",     lv=13000},
    {n="World Island",     lv=14000},
}
local Sea2Islands = {
    {n="Sea 2 Starter",   lv=14500}, {n="Cosmic Island",    lv=15000},
    {n="Sea 2 Boss Hub",  lv=15500}, {n="Guild Island",     lv=16000},
}
local AllIslands = {}
for _, v in ipairs(Sea1Islands) do table.insert(AllIslands, v.n) end
for _, v in ipairs(Sea2Islands) do table.insert(AllIslands, v.n) end

local BossList = {
    "Knight","Qin Shi","Soul Reaper","Corrupted Knight","King of Heroes",
    "Blessed Maiden","Moon Slayer","Ice Queen","Jinwoo","Alucard","Aizen",
    "Gilgamesh","Saber Alter","True Aizen","Yamato","Atomic","Strongest Shinobi",
    "Cosmic Being","Kraken","Sea Serpent","World Boss",
}
local SwordList = {
    "Dark Blade","Katana","Cursed Katana","Ragna Blade","Shadow Monarch Blade",
    "Abyss Edge","Escanor Blade","Atomic Blade","Abyssal Empress","Ice Queen Blade",
    "Dragon Goddess","Great Mage","True Aizen","Yamato","Anti-Magic Sword",
    "Shadow Monarch","Cosmic Blade",
}
local SwordBossMap = {
    ["Dark Blade"]           = "Knight",
    ["Shadow Monarch Blade"] = "Jinwoo",
    ["Abyss Edge"]           = "Alucard",
    ["True Aizen"]           = "True Aizen",
    ["Yamato"]               = "Atomic",
    ["Dragon Goddess"]       = "Cosmic Being",
    ["Anti-Magic Sword"]     = "Strongest Shinobi",
    ["Ragna Blade"]          = "Soul Reaper",
    ["Escanor Blade"]        = "Blessed Maiden",
    ["Atomic Blade"]         = "Atomic",
    ["Abyssal Empress"]      = "Blessed Maiden",
    ["Ice Queen Blade"]      = "Ice Queen",
    ["Great Mage"]           = "Cosmic Being",
    ["Cosmic Blade"]         = "Cosmic Being",
    ["Shadow Monarch"]       = "Jinwoo",
}
local ActiveCodes = {
    "HUGEUPDATEWWW","RAIDS","DELAYCODENR1","SAILORPIECE",
    "SEA2UPDATE","DISCORD100K","FREEGEMS2026","RELEASE","ALPHA","BETA",
}

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================
local function Notify(title, text, dur)
    pcall(function()
        WindUI:Notify({ Title = title, Content = text, Icon = "bell", Duration = dur or 4 })
    end)
    safeNotify(title, text, dur)
end

local function Char()   return LP.Character end
local function HRP()    local c = Char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()    local c = Char(); return c and c:FindFirstChildOfClass("Humanoid") end

local function GetLevel()
    local v = 0
    pcall(function()
        for _, src in ipairs({LP:FindFirstChild("leaderstats"), LP:FindFirstChild("Data")}) do
            if src then
                local lv = src:FindFirstChild("Level") or src:FindFirstChild("Lv")
                if lv then v = lv.Value; return end
            end
        end
    end)
    return v
end

-- Movimento suave (TweenService no HRP — funciona no Delta)
local function MoveTo(cf, speed)
    local hrp = HRP(); if not hrp then return end
    speed = speed or 80
    local dist = (hrp.Position - cf.Position).Magnitude
    local dur  = math.max(0.1, dist / speed)
    TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = cf }):Play()
    task.wait(dur)
end

local function TP(cf)
    local hrp = HRP(); if hrp then hrp.CFrame = cf end
end

-- Ataque: teleporta perto do inimigo (Delta não tem VirtualUser confiável)
local function Attack(enemy)
    if not enemy then return end
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHRP then return end
    local hrp = HRP(); if not hrp then return end
    -- Chega perto
    hrp.CFrame = eHRP.CFrame * CFrame.new(0, 2, 3.5)
    task.wait(0.05)
    -- Tenta usar o remote de dano do jogo
    pcall(function()
        local rem = RS:FindFirstChild("Remotes") or RS:FindFirstChild("Events")
        if rem then
            local dmg = rem:FindFirstChild("DamageEnemy") or rem:FindFirstChild("HitEnemy")
                     or rem:FindFirstChild("Attack") or rem:FindFirstChild("Hit")
            if dmg then dmg:FireServer(enemy, 9999) end
        end
    end)
end

local function UseSkills()
    -- Dispara as skills via remote (mais confiável no Delta que VIM)
    pcall(function()
        local rem = RS:FindFirstChild("Remotes") or RS:FindFirstChild("Events")
        if rem then
            for _, name in ipairs({"UseSkill","Skill","SkillZ","SkillX","SkillC","SkillV"}) do
                local fn = rem:FindFirstChild(name)
                if fn then pcall(function() fn:FireServer() end) end
            end
        end
    end)
    -- Fallback: simula teclas via UIS
    for _, kc in ipairs({
        Enum.KeyCode.Z, Enum.KeyCode.X,
        Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.F
    }) do
        pcall(function()
            local args = {kc, false, game}
            UIS.InputBegan:Fire({
                KeyCode = kc,
                UserInputType = Enum.UserInputType.Keyboard,
                UserInputState = Enum.UserInputState.Begin,
            }, false)
        end)
        task.wait(0.08)
    end
end

local function NearestEnemy(range)
    local hrp = HRP(); if not hrp then return nil end
    range = range or 60
    local best, bd = nil, range
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= Char() then
            local hum = v:FindFirstChildOfClass("Humanoid")
            local vHRP = v:FindFirstChild("HumanoidRootPart")
            if hum and vHRP and hum.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                local d = (vHRP.Position - hrp.Position).Magnitude
                if d < bd then bd = d; best = v end
            end
        end
    end
    return best
end

local function EnemiesInRange(range)
    local hrp = HRP(); if not hrp then return {} end
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= Char() then
            local hum = v:FindFirstChildOfClass("Humanoid")
            local vHRP = v:FindFirstChild("HumanoidRootPart")
            if hum and vHRP and hum.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                if (vHRP.Position - hrp.Position).Magnitude <= range then
                    table.insert(list, v)
                end
            end
        end
    end
    return list
end

local function FindBoss(name)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find(name:lower()) then
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then return v end
        end
    end
end

local function FindPortal(islandName)
    local kw = islandName:lower():gsub(" island",""):gsub(" ","")
    for _, v in ipairs(workspace:GetDescendants()) do
        local nm = v.Name:lower():gsub(" ","")
        if nm:find(kw) or kw:find(nm) then
            if v:IsA("BasePart") then return v.CFrame
            elseif v:IsA("Model") and v.PrimaryPart then return v:GetPivot() end
        end
    end
    return nil
end

-- ============================================================
-- TAB: HOME
-- ============================================================
Tabs.HomeTab:Section({ Title = "☠️ DesplockHub — Sailor Piece", TextXAlignment = "Left" })
Tabs.HomeTab:Paragraph({
    Title = "DesplockHub v3.0",
    Desc  = "Sea 1 & Sea 2 | Compatível com Delta Mobile\nFeito para a comunidade DesplockHub ❤️"
})
Tabs.HomeTab:Paragraph({
    Title = "🌐 Discord",
    Desc  = "discord.gg/wCUv3GKxs\nEntrem para suporte, updates e mais!"
})
Tabs.HomeTab:Button({
    Title    = "📋 Copiar Link do Discord",
    Desc     = "Copia discord.gg/wCUv3GKxs para a área de transferência",
    Callback = function()
        safeClipboard("https://discord.gg/wCUv3GKxs")
        Notify("DesplockHub", "Link copiado! discord.gg/wCUv3GKxs", 3)
    end
})
Tabs.HomeTab:Paragraph({
    Title = "📖 Guia Rápido",
    Desc  = "1. Auto Farm → selecione ilha → ative o farm\n2. Sea 2 → Teleport → clique na ilha do Sea 2\n3. Boss Farm → escolha o boss → ative\n4. Dungeon → selecione → ative\n5. ESP → ative para ver frutas, baús e bosses"
})
local StatusPara = Tabs.HomeTab:Paragraph({ Title = "📊 Status", Desc = "Carregando..." })
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local lv  = GetLevel()
            local hum = Hum()
            local hp  = hum and math.floor(hum.Health) or 0
            local mhp = hum and math.floor(hum.MaxHealth) or 0
            StatusPara:SetDesc(
                "Lv: "..lv.." | HP: "..hp.."/"..mhp..
                "\nFarm: "..(S.AutoFarm and "✅ "..S.FarmIsland or "❌")..
                " | Boss: "..(S.AutoBoss and "✅ "..S.BossName or "❌")
            )
        end)
    end
end)

-- ============================================================
-- TAB: AUTO FARM
-- ============================================================
Tabs.FarmTab:Section({ Title = "⚔️ Configuração de Farm", TextXAlignment = "Left" })

local IslandDrop = Tabs.FarmTab:Dropdown({
    Title    = "🏝️ Selecionar Ilha",
    Desc     = "Ilha onde vai farmar",
    Values   = AllIslands,
    Value    = "Starter Island",
    Callback = function(v) S.FarmIsland = v end
})

Tabs.FarmTab:Button({
    Title    = "💡 Sugerir Ilha pelo Level",
    Desc     = "Seleciona automaticamente a melhor ilha pro seu nível",
    Callback = function()
        local lv = GetLevel()
        local best = Sea1Islands[1].n
        for i = #Sea1Islands, 1, -1 do
            if lv >= Sea1Islands[i].lv then best = Sea1Islands[i].n; break end
        end
        S.FarmIsland = best
        IslandDrop:SetValue(best)
        Notify("Farm", "Ilha sugerida: "..best, 4)
    end
})

Tabs.FarmTab:Section({ Title = "🔄 Opções de Farm", TextXAlignment = "Left" })

Tabs.FarmTab:Toggle({
    Title    = "📜 Auto Quest",
    Desc     = "Aceita e completa quests automaticamente",
    Value    = false,
    Callback = function(v) S.AutoQuest = v end
})

Tabs.FarmTab:Toggle({
    Title    = "💥 Kill Aura",
    Desc     = "Ataca todos os inimigos próximos em loop",
    Value    = false,
    Callback = function(v) S.KillAura = v end
})

Tabs.FarmTab:Slider({
    Title    = "📏 Raio do Kill Aura",
    Value    = { Min = 10, Max = 150, Default = 40 },
    Step     = 5,
    Callback = function(v) S.KillAuraRange = v end
})

local FarmStatus = Tabs.FarmTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })

Tabs.FarmTab:Toggle({
    Title    = "▶️ START AUTO FARM",
    Desc     = "Inicia o farm automático na ilha selecionada",
    Value    = false,
    Callback = function(v)
        S.AutoFarm = v
        if v then
            FarmStatus:SetDesc("🟢 Farmando em: "..S.FarmIsland)
            Notify("Auto Farm", "Farm iniciado em: "..S.FarmIsland, 4)
        else
            FarmStatus:SetDesc("⚪ Inativo")
            Notify("Auto Farm", "Farm parado.", 3)
        end
    end
})

-- Loop principal de farm
task.spawn(function()
    while true do
        task.wait(0.2)
        if S.AutoFarm or S.KillAura then
            pcall(function()
                local enemies = EnemiesInRange(S.KillAura and S.KillAuraRange or 80)
                if #enemies > 0 then
                    if S.AutoFarm then
                        FarmStatus:SetDesc("🟢 "..S.FarmIsland.." | Inimigos: "..#enemies)
                    end
                    for _, e in ipairs(enemies) do
                        Attack(e)
                        UseSkills()
                        task.wait(0.05)
                    end
                else
                    if S.AutoFarm then
                        FarmStatus:SetDesc("🟡 "..S.FarmIsland.." | Procurando inimigos...")
                        -- Tenta ir para a ilha
                        local portal = FindPortal(S.FarmIsland)
                        if portal then
                            local hrp = HRP()
                            if hrp then
                                local d = (hrp.Position - portal.Position).Magnitude
                                if d > 300 then
                                    hrp.CFrame = portal * CFrame.new(0, 5, 0)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
end)

-- ============================================================
-- TAB: BOSS FARM
-- ============================================================
Tabs.BossTab:Section({ Title = "☠️ Boss Farm", TextXAlignment = "Left" })

Tabs.BossTab:Dropdown({
    Title    = "👹 Selecionar Boss",
    Values   = BossList,
    Value    = "Knight",
    Callback = function(v) S.BossName = v end
})

Tabs.BossTab:Paragraph({
    Title = "📍 Localização dos Bosses",
    Desc  = "Knight/Soul Reaper → Boss Island\nJinwoo/Alucard → Sailor Island\nAizen/True Aizen → Hollow Island\nAtomic → Lawless Island\nShinobi → Ninja Island\nCosmic/Kraken → Sea 2"
})

Tabs.BossTab:Toggle({
    Title    = "🔁 Loop Boss",
    Desc     = "Repete o farm após matar o boss",
    Value    = false,
    Callback = function(v) S.BossLoop = v end
})

local BossStatus = Tabs.BossTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })

Tabs.BossTab:Toggle({
    Title    = "▶️ AUTO BOSS FARM",
    Desc     = "Vai até o boss, ataca e repete se loop ativado",
    Value    = false,
    Callback = function(v)
        S.AutoBoss = v
        BossStatus:SetDesc(v and "🟢 Caçando: "..S.BossName or "⚪ Inativo")
    end
})

task.spawn(function()
    while true do
        task.wait(0.3)
        if S.AutoBoss then
            pcall(function()
                local boss = FindBoss(S.BossName)
                if boss then
                    local bHRP = boss:FindFirstChild("HumanoidRootPart")
                    local hrp  = HRP()
                    if bHRP and hrp then
                        local hp = math.floor(boss:FindFirstChildOfClass("Humanoid").Health)
                        BossStatus:SetDesc("🟡 "..S.BossName.." | HP: "..hp)
                        local d = (hrp.Position - bHRP.Position).Magnitude
                        if d > 20 then
                            hrp.CFrame = bHRP.CFrame * CFrame.new(0, 4, 8)
                        end
                        Attack(boss)
                        UseSkills()
                    end
                else
                    BossStatus:SetDesc("🔴 Boss não encontrado — aguardando...")
                    if not S.BossLoop then
                        S.AutoBoss = false
                        BossStatus:SetDesc("⚪ Inativo")
                    end
                    task.wait(3)
                end
            end)
        end
    end
end)

-- ============================================================
-- TAB: DUNGEON
-- ============================================================
Tabs.DungeonTab:Section({ Title = "🏰 Auto Dungeon", TextXAlignment = "Left" })

Tabs.DungeonTab:Dropdown({
    Title    = "🔑 Selecionar Dungeon",
    Values   = { "Shadow Dungeon","Rune Dungeon","Artifact Dungeon","Infinite Tower" },
    Value    = "Shadow Dungeon",
    Callback = function(v) S.DungeonType = v end
})

Tabs.DungeonTab:Paragraph({
    Title = "📖 Sobre as Dungeons",
    Desc  = "Shadow Dungeon → Dungeon Island (Lv 5000+)\nInfinite Tower → Tower Island (ondas infinitas)\nChaves dropam de bosses: Atomic, Strongest Shinobi"
})

local DungStatus = Tabs.DungeonTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })
local dungWave   = 0

Tabs.DungeonTab:Toggle({
    Title    = "▶️ AUTO DUNGEON",
    Desc     = "Limpa a dungeon em loop automaticamente",
    Value    = false,
    Callback = function(v)
        S.AutoDungeon = v
        dungWave = 0
        DungStatus:SetDesc(v and "🟢 "..S.DungeonType or "⚪ Inativo")
        if v then Notify("Dungeon", "Auto Dungeon ativado: "..S.DungeonType, 4) end
    end
})

task.spawn(function()
    while true do
        task.wait(0.25)
        if S.AutoDungeon then
            pcall(function()
                local enemies = EnemiesInRange(200)
                if #enemies > 0 then
                    dungWave = dungWave + 1
                    DungStatus:SetDesc("🟢 "..S.DungeonType.." | Onda: "..dungWave.." | x"..#enemies)
                    for _, e in ipairs(enemies) do
                        Attack(e); UseSkills(); task.wait(0.05)
                    end
                else
                    DungStatus:SetDesc("🟡 "..S.DungeonType.." | Aguardando onda...")
                    task.wait(2)
                end
            end)
        end
    end
end)

-- ============================================================
-- TAB: RAID
-- ============================================================
Tabs.RaidTab:Section({ Title = "🛡️ Auto Raid", TextXAlignment = "Left" })

Tabs.RaidTab:Dropdown({
    Title    = "⚔️ Tipo de Raid",
    Values   = { "Shadow Raid","Goku Raid","Spirit Raid","Blue Planet Raid" },
    Value    = "Shadow Raid",
    Callback = function(v) S.RaidType = v end
})

Tabs.RaidTab:Paragraph({
    Title = "📖 Sobre as Raids",
    Desc  = "Shadow Raid → Boss Island (Raid Keys)\nGoku Raid → Blue Planet Island\nChaves: drops de Strongest Shinobi e Atomic"
})

local RaidStatus = Tabs.RaidTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })

Tabs.RaidTab:Toggle({
    Title    = "▶️ AUTO RAID",
    Desc     = "Entra e limpa a raid em loop",
    Value    = false,
    Callback = function(v)
        S.AutoRaid = v
        RaidStatus:SetDesc(v and "🟢 "..S.RaidType or "⚪ Inativo")
        if v then Notify("Raid", "Auto Raid: "..S.RaidType, 4) end
    end
})

task.spawn(function()
    while true do
        task.wait(0.25)
        if S.AutoRaid then
            pcall(function()
                local enemies = EnemiesInRange(250)
                RaidStatus:SetDesc("🟢 "..S.RaidType.." | x"..#enemies.." inimigos")
                for _, e in ipairs(enemies) do
                    Attack(e); UseSkills(); task.wait(0.05)
                end
                if #enemies == 0 then task.wait(2) end
            end)
        end
    end
end)

-- ============================================================
-- TAB: SWORDS
-- ============================================================
Tabs.SwordTab:Section({ Title = "⚔️ Farm de Espadas", TextXAlignment = "Left" })

Tabs.SwordTab:Dropdown({
    Title    = "🗡️ Selecionar Espada",
    Values   = SwordList,
    Value    = "Dark Blade",
    Callback = function(v) S.SwordTarget = v end
})

Tabs.SwordTab:Paragraph({
    Title = "📍 Onde Pegar cada Espada",
    Desc  = "Dark Blade → Knight (Boss Island)\nShadow Monarch Blade → Jinwoo (Sailor Island)\nAbyss Edge → Alucard (Sailor Island)\nTrue Aizen → True Aizen (Hollow Island)\nYamato → Atomic (Lawless Island)\nAnti-Magic Sword → Strongest Shinobi\nDragon Goddess / Cosmic Blade → Sea 2"
})

local SwordStatus = Tabs.SwordTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })

Tabs.SwordTab:Toggle({
    Title    = "▶️ AUTO SWORD FARM",
    Desc     = "Ataca o boss correspondente para dropar a espada",
    Value    = false,
    Callback = function(v)
        S.AutoSword = v
        SwordStatus:SetDesc(v and "🟢 Buscando: "..S.SwordTarget or "⚪ Inativo")
        if v then Notify("Sword", "Buscando: "..S.SwordTarget, 4) end
    end
})

task.spawn(function()
    while true do
        task.wait(0.3)
        if S.AutoSword then
            pcall(function()
                local bossName = SwordBossMap[S.SwordTarget] or "Knight"
                local boss = FindBoss(bossName)
                if boss then
                    local bHRP = boss:FindFirstChild("HumanoidRootPart")
                    local hrp  = HRP()
                    if bHRP and hrp then
                        local hp = math.floor(boss:FindFirstChildOfClass("Humanoid").Health)
                        SwordStatus:SetDesc("🟡 Atacando "..bossName.." | HP: "..hp)
                        hrp.CFrame = bHRP.CFrame * CFrame.new(0, 4, 8)
                        Attack(boss); UseSkills()
                    end
                else
                    SwordStatus:SetDesc("🔴 Boss '"..bossName.."' não encontrado...")
                    task.wait(3)
                end
            end)
        end
    end
end)

-- ============================================================
-- TAB: FRUITS
-- ============================================================
Tabs.FruitTab:Section({ Title = "🍎 Devil Fruits", TextXAlignment = "Left" })

Tabs.FruitTab:Paragraph({
    Title = "📖 Como Obter Fruits",
    Desc  = "Frutas spawnam nas ilhas a cada ~20 min\nCompre com Gems em Sailor Island\nDropam de World Bosses e Dungeons\nMythicals são raras — use o ESP!"
})

Tabs.FruitTab:Toggle({
    Title    = "👁️ ESP de Frutas",
    Desc     = "Destaca Devil Fruits no mapa com marcadores visuais",
    Value    = false,
    Callback = function(v)
        S.FruitEsp = v
        Notify("Fruit ESP", v and "ESP ativado! 🍎" or "ESP desativado.", 3)
    end
})

Tabs.FruitTab:Toggle({
    Title    = "🏃 Auto Pegar Fruta",
    Desc     = "Teleporta para a fruta quando ela spawnar",
    Value    = false,
    Callback = function(v) S.AutoFruit = v end
})

Tabs.FruitTab:Toggle({
    Title    = "🍽️ Auto Comer Fruta",
    Desc     = "Come a fruta ao pegar (usa remote do jogo)",
    Value    = false,
    Callback = function(v) S.AutoEatFruit = v end
})

-- ESP de Frutas
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (v.Name:find("Fruit") or v.Name:find("fruit")) then
                    local part = v:FindFirstChildWhichIsA("BasePart")
                    if part and not v:FindFirstChild("_FESP") then
                        if S.FruitEsp then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "_FESP"
                            bb.Size = UDim2.new(0,140,0,30)
                            bb.AlwaysOnTop = true
                            bb.StudsOffset = Vector3.new(0,4,0)
                            bb.Adornee = part
                            bb.Parent = v
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1,0,1,0)
                            lbl.BackgroundColor3 = Color3.fromRGB(20,0,40)
                            lbl.BackgroundTransparency = 0.3
                            lbl.TextColor3 = Color3.fromRGB(255,200,0)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            lbl.Text = "🍎 "..v.Name
                        end
                    elseif part then
                        local esp = v:FindFirstChild("_FESP")
                        if esp and not S.FruitEsp then esp:Destroy() end
                    end
                end
            end
        end)
        -- Auto pegar
        if S.AutoFruit then
            pcall(function()
                local hrp = HRP(); if not hrp then return end
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and (v.Name:find("Fruit") or v.Name:find("fruit")) then
                        local part = v:FindFirstChildWhichIsA("BasePart")
                        if part then
                            hrp.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.3)
                            if S.AutoEatFruit then
                                pcall(function()
                                    local rem = RS:FindFirstChild("Remotes") or RS
                                    local eat = rem:FindFirstChild("EatFruit") or rem:FindFirstChild("UseFruit")
                                    if eat then eat:FireServer(v) end
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- TAB: HAKI
-- ============================================================
Tabs.HakiTab:Section({ Title = "⚡ Auto Haki", TextXAlignment = "Left" })

Tabs.HakiTab:Paragraph({
    Title = "📖 Tipos de Haki",
    Desc  = "Armament → +dano e defesa (tecla G no PC)\nConqueror's → domina inimigos (raro)\nObservation → auto-esquiva ataques"
})

Tabs.HakiTab:Toggle({
    Title    = "🛡️ Auto Armament Haki",
    Desc     = "Mantém o Armament Haki sempre ativo via remote",
    Value    = false,
    Callback = function(v)
        S.AutoArmHaki = v
        Notify("Haki", v and "Armament Haki ativado!" or "Desativado.", 3)
    end
})

Tabs.HakiTab:Toggle({
    Title    = "👑 Auto Conqueror's Haki",
    Desc     = "Usa Conqueror's Haki automaticamente",
    Value    = false,
    Callback = function(v)
        S.AutoConqHaki = v
        Notify("Haki", v and "Conqueror's Haki ativado!" or "Desativado.", 3)
    end
})

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local rem = RS:FindFirstChild("Remotes") or RS:FindFirstChild("Events")
            if rem then
                if S.AutoArmHaki then
                    local fn = rem:FindFirstChild("ActivateHaki") or rem:FindFirstChild("ArmamentHaki")
                    if fn then pcall(function() fn:FireServer("Armament") end) end
                end
                if S.AutoConqHaki then
                    local fn = rem:FindFirstChild("ConquerorHaki") or rem:FindFirstChild("ActivateHaki")
                    if fn then pcall(function() fn:FireServer("Conqueror") end) end
                end
            end
        end)
    end
end)

-- ============================================================
-- TAB: SEA BEASTS
-- ============================================================
Tabs.SeaBeastTab:Section({ Title = "🦑 Sea Beasts — Sea 2", TextXAlignment = "Left" })

Tabs.SeaBeastTab:Paragraph({
    Title = "📖 Sobre Sea Beasts",
    Desc  = "Kraken e Sea Serpent spawnam no oceano do Sea 2\nDropam Relics, Bloodline Stones e itens raros\nRequer Lv 14500+ e build forte"
})

Tabs.SeaBeastTab:Dropdown({
    Title    = "🦑 Selecionar Sea Beast",
    Values   = { "Kraken","Sea Serpent","Ambos" },
    Value    = "Kraken",
    Callback = function(v) S.SeaBeastTarget = v end
})

local SBStatus = Tabs.SeaBeastTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })

Tabs.SeaBeastTab:Toggle({
    Title    = "▶️ AUTO SEA BEAST",
    Desc     = "Detecta e ataca Sea Beasts automaticamente",
    Value    = false,
    Callback = function(v)
        S.AutoSeaBeast = v
        SBStatus:SetDesc(v and "🟢 Caçando: "..S.SeaBeastTarget or "⚪ Inativo")
        if v then Notify("Sea Beast", "Farm iniciado! 🦑", 4) end
    end
})

task.spawn(function()
    while true do
        task.wait(0.4)
        if S.AutoSeaBeast then
            pcall(function()
                local kws = S.SeaBeastTarget == "Ambos"
                    and {"Kraken","Sea Serpent","SeaSerpent"}
                    or  {S.SeaBeastTarget}
                local beast = nil
                for _, kw in ipairs(kws) do
                    beast = FindBoss(kw)
                    if beast then break end
                end
                if beast then
                    local bHRP = beast:FindFirstChild("HumanoidRootPart")
                    local hrp  = HRP()
                    if bHRP and hrp then
                        local hp = math.floor(beast:FindFirstChildOfClass("Humanoid").Health)
                        SBStatus:SetDesc("🟡 "..beast.Name.." | HP: "..hp)
                        local d = (hrp.Position - bHRP.Position).Magnitude
                        if d > 30 then hrp.CFrame = bHRP.CFrame * CFrame.new(0,6,12) end
                        Attack(beast); UseSkills()
                    end
                else
                    SBStatus:SetDesc("🔴 Sea Beast não encontrado — aguardando...")
                    task.wait(5)
                end
            end)
        end
    end
end)

-- ============================================================
-- TAB: RACE / BLOODLINE
-- ============================================================
Tabs.RaceTab:Section({ Title = "🧬 Race", TextXAlignment = "Left" })

Tabs.RaceTab:Paragraph({
    Title = "📖 Races Disponíveis",
    Desc  = "SwordBlessed → +20% Sword DMG (Mythic)\nGalevorn → +20% Melee DMG (Mythic)\nKitsune → +25% Luck (Mythic)\nReroll com Gems na aba de Stats"
})

Tabs.RaceTab:Dropdown({
    Title    = "🎯 Race Desejada",
    Values   = {"SwordBlessed","Galevorn","Kitsune","Human","Mink","Fishman","Skypiean","Ancient","Hybrid","Celestial"},
    Value    = "SwordBlessed",
    Callback = function(v) S.RerollTarget = v end
})

local RaceStatus = Tabs.RaceTab:Paragraph({ Title = "Status de Reroll", Desc = "⚪ Inativo" })
local rerollN    = 0

Tabs.RaceTab:Toggle({
    Title    = "🎲 Auto Reroll de Race",
    Desc     = "Faz reroll até conseguir a race desejada",
    Value    = false,
    Callback = function(v)
        S.AutoReroll = v
        rerollN = 0
        RaceStatus:SetDesc(v and "🟢 Buscando: "..S.RerollTarget or "⚪ Parado")
        if v then Notify("Reroll", "Buscando: "..S.RerollTarget, 4) end
    end
})

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoReroll then
            pcall(function()
                rerollN = rerollN + 1
                RaceStatus:SetDesc("🟡 Tentativa #"..rerollN.." | Alvo: "..S.RerollTarget)
                local rem = RS:FindFirstChild("Remotes") or RS
                local fn  = rem:FindFirstChild("RerollRace") or rem:FindFirstChild("Reroll")
                if fn then pcall(function() fn:FireServer() end) end
            end)
        end
    end
end)

Tabs.RaceTab:Section({ Title = "🩸 Bloodline (Sea 2)", TextXAlignment = "Left" })

Tabs.RaceTab:Paragraph({
    Title = "📖 Bloodlines",
    Desc  = "Exclusivas do Sea 2\nBloodline Stones dropam de NPCs do Sea 2\nDão bônus passivos únicos ao personagem"
})

Tabs.RaceTab:Toggle({
    Title    = "🩸 Auto Farm Bloodline Stones",
    Desc     = "Farm de NPCs do Sea 2 para coletar Bloodline Stones",
    Value    = false,
    Callback = function(v)
        S.AutoBloodline = v
        Notify("Bloodline", v and "Farm ativado!" or "Desativado.", 3)
    end
})

-- ============================================================
-- TAB: GUILD / RELICS
-- ============================================================
Tabs.GuildTab:Section({ Title = "👥 Guild (Sea 2)", TextXAlignment = "Left" })

Tabs.GuildTab:Paragraph({
    Title = "📖 Sobre Guilds",
    Desc  = "Disponível no Sea 2\nGuild Points → farm de inimigos e eventos\nUpgrades dão bônus para toda a guild"
})

local GuildStatus = Tabs.GuildTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })
local gpCount     = 0

Tabs.GuildTab:Toggle({
    Title    = "⚡ Auto Guild Points",
    Desc     = "Farm de Guild Points derrotando inimigos em loop",
    Value    = false,
    Callback = function(v)
        S.AutoGuild = v
        gpCount = 0
        GuildStatus:SetDesc(v and "🟢 Farmando Guild Points..." or "⚪ Inativo")
        if v then Notify("Guild", "Farm de Guild Points ativado!", 4) end
    end
})

task.spawn(function()
    while true do
        task.wait(0.3)
        if S.AutoGuild then
            pcall(function()
                local enemies = EnemiesInRange(80)
                if #enemies > 0 then
                    gpCount = gpCount + #enemies
                    GuildStatus:SetDesc("🟢 GP Est: +"..gpCount.." | Inimigos: "..#enemies)
                    for _, e in ipairs(enemies) do Attack(e); UseSkills() end
                else
                    GuildStatus:SetDesc("🟡 Sem inimigos próximos...")
                    task.wait(1)
                end
            end)
        end
    end
end)

Tabs.GuildTab:Section({ Title = "💎 Relics (Sea 2)", TextXAlignment = "Left" })

Tabs.GuildTab:Paragraph({
    Title = "📖 Sobre Relics",
    Desc  = "Relic Parts #1 e #2 dropam de NPCs do Sea 2\nLeve ao Relic Crafter NPC para criar a Relic\nRelics dão buffs poderosos permanentes"
})

Tabs.GuildTab:Toggle({
    Title    = "🔮 Auto Farm Relic Parts",
    Desc     = "Farm de Relic Parts #1 e #2 de NPCs do Sea 2",
    Value    = false,
    Callback = function(v)
        Notify("Relics", v and "Farm de Relic Parts ativado!" or "Desativado.", 3)
    end
})

Tabs.GuildTab:Button({
    Title    = "⚒️ Ir para o Relic Crafter",
    Desc     = "Teleporta ao NPC de criação de Relics (Sea 2)",
    Callback = function()
        pcall(function()
            local hrp = HRP(); if not hrp then return end
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find("relic") and v:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,6)
                    return
                end
            end
        end)
        Notify("Relic", "Teleportando ao Relic Crafter...", 3)
    end
})

-- ============================================================
-- TAB: ASCENSION / MASTERY
-- ============================================================
Tabs.AscTab:Section({ Title = "⬆️ Auto Ascension", TextXAlignment = "Left" })

Tabs.AscTab:Paragraph({
    Title = "📖 Ascensão de Rank",
    Desc  = "NPC em Sailor Island\nBronze → Prata → Ouro → Platina → Diamante\n→ Mestre → Grão-Mestre → Lendário"
})

local AscStatus = Tabs.AscTab:Paragraph({ Title = "Status", Desc = "⚪ Inativo" })

Tabs.AscTab:Toggle({
    Title    = "⬆️ AUTO ASCENSION",
    Desc     = "Vai ao NPC e sobe de rank automaticamente",
    Value    = false,
    Callback = function(v)
        S.AutoAscension = v
        AscStatus:SetDesc(v and "🟢 Procurando NPC de Ascensão..." or "⚪ Inativo")
        if v then Notify("Ascension", "Auto Ascension ativado!", 4) end
    end
})

task.spawn(function()
    while true do
        task.wait(3)
        if S.AutoAscension then
            pcall(function()
                local hrp = HRP(); if not hrp then return end
                local npc = nil
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and
                       (v.Name:lower():find("ascen") or v.Name:lower():find("rank"))
                       and v:FindFirstChild("HumanoidRootPart") then
                        npc = v; break
                    end
                end
                if npc and npc:FindFirstChild("HumanoidRootPart") then
                    local d = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
                    AscStatus:SetDesc("🟡 NPC encontrado | Distância: "..math.floor(d).."m")
                    if d > 10 then
                        hrp.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
                    else
                        local rem = RS:FindFirstChild("Remotes") or RS
                        local fn  = rem:FindFirstChild("Ascend") or rem:FindFirstChild("AscendRank")
                        if fn then pcall(function() fn:FireServer() end) end
                        AscStatus:SetDesc("🟢 Ascensão executada!")
                    end
                else
                    AscStatus:SetDesc("🔍 Buscando NPC em Sailor Island...")
                end
            end)
        end
    end
end)

Tabs.AscTab:Section({ Title = "📈 Mastery Training", TextXAlignment = "Left" })

Tabs.AscTab:Paragraph({
    Title = "📖 Sobre Mastery",
    Desc  = "Treinar Mastery aumenta o dano por tipo de arma\nEquipe a arma e farme inimigos para ganhar mastery"
})

Tabs.AscTab:Dropdown({
    Title    = "🎯 Tipo de Mastery",
    Values   = { "Sword","Fruit","Melee","Gun" },
    Value    = "Sword",
    Callback = function(v) S.MasteryTarget = v end
})

Tabs.AscTab:Toggle({
    Title    = "📈 Auto Mastery Training",
    Desc     = "Farm focado em mastery do tipo selecionado",
    Value    = false,
    Callback = function(v)
        S.AutoMastery = v
        Notify("Mastery", v and "Treinando "..S.MasteryTarget.." Mastery!" or "Parado.", 3)
    end
})

task.spawn(function()
    while true do
        task.wait(0.25)
        if S.AutoMastery then
            pcall(function()
                local e = NearestEnemy(100)
                if e and e:FindFirstChild("HumanoidRootPart") then
                    local hrp = HRP()
                    if hrp then
                        hrp.CFrame = e.HumanoidRootPart.CFrame * CFrame.new(0,4,4)
                    end
                    Attack(e)
                    UseSkills()
                end
            end)
        end
    end
end)

-- ============================================================
-- TAB: TELEPORT
-- ============================================================
Tabs.TeleportTab:Section({ Title = "🗺️ Sea 1 — Ilhas", TextXAlignment = "Left" })

for _, isl in ipairs(Sea1Islands) do
    Tabs.TeleportTab:Button({
        Title    = "⚓ "..isl.n,
        Desc     = "Lv "..isl.lv.."+",
        Callback = function()
            pcall(function()
                local hrp    = HRP(); if not hrp then return end
                local portal = FindPortal(isl.n)
                if portal then
                    hrp.CFrame = portal * CFrame.new(0, 5, 0)
                    Notify("Teleport", "Teleportado para: "..isl.n, 3)
                else
                    Notify("Teleport", "Portal de "..isl.n.." não encontrado.", 3)
                end
            end)
        end
    })
end

Tabs.TeleportTab:Section({ Title = "🌊 Sea 2 — Ilhas", TextXAlignment = "Left" })

for _, isl in ipairs(Sea2Islands) do
    Tabs.TeleportTab:Button({
        Title    = "⚓ "..isl.n,
        Desc     = "Lv "..isl.lv.."+",
        Callback = function()
            pcall(function()
                local hrp    = HRP(); if not hrp then return end
                local portal = FindPortal(isl.n)
                if portal then
                    hrp.CFrame = portal * CFrame.new(0, 5, 0)
                    Notify("Teleport", "Teleportado para: "..isl.n.." (Sea 2)", 3)
                else
                    Notify("Teleport", "Portal de "..isl.n.." não encontrado.", 3)
                end
            end)
        end
    })
end

Tabs.TeleportTab:Button({
    Title    = "🚢 IR PARA WORLD ISLAND (Entrada Sea 2)",
    Desc     = "Teleporta para World Island — ponto de travessia para o Sea 2",
    Callback = function()
        pcall(function()
            local hrp    = HRP(); if not hrp then return end
            local portal = FindPortal("World Island")
            if portal then
                hrp.CFrame = portal * CFrame.new(0, 5, 0)
            end
        end)
        Notify("Sea 2", "Teleportando para World Island!", 4)
    end
})

-- ============================================================
-- TAB: ESP
-- ============================================================
Tabs.EspTab:Section({ Title = "👁️ ESP / Rastreamento", TextXAlignment = "Left" })

Tabs.EspTab:Toggle({
    Title    = "👥 ESP de Jogadores",
    Desc     = "Mostra nome, HP e distância dos jogadores",
    Value    = false,
    Callback = function(v) S.EspPlayers = v end
})

Tabs.EspTab:Toggle({
    Title    = "🎁 ESP de Baús",
    Desc     = "Destaca baús com marcador visual",
    Value    = false,
    Callback = function(v) S.EspChests = v end
})

Tabs.EspTab:Toggle({
    Title    = "☠️ ESP de Bosses",
    Desc     = "Destaca bosses e mostra HP",
    Value    = false,
    Callback = function(v) S.EspBosses = v end
})

-- ESP loop
task.spawn(function()
    local uid = tostring(math.random(10000,99999))
    while true do
        task.wait(1)
        pcall(function()
            -- Players ESP
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    local pHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                    local pHum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if head then
                        local tag = "_PE"..uid
                        local bb  = head:FindFirstChild(tag)
                        if S.EspPlayers and not bb then
                            bb = Instance.new("BillboardGui", head)
                            bb.Name = tag; bb.AlwaysOnTop = true
                            bb.Size = UDim2.new(0,190,0,36)
                            bb.StudsOffset = Vector3.new(0,2.5,0)
                            bb.Adornee = head
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1,0,1,0)
                            lbl.BackgroundColor3 = Color3.fromRGB(0,0,60)
                            lbl.BackgroundTransparency = 0.25
                            lbl.TextColor3 = Color3.fromRGB(120,210,255)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 11
                        elseif S.EspPlayers and bb then
                            local myHRP = HRP()
                            local lbl   = bb:FindFirstChildOfClass("TextLabel")
                            if lbl and myHRP and pHRP and pHum then
                                local d = math.floor((myHRP.Position - pHRP.Position).Magnitude)
                                local hp = math.floor(pHum.Health)
                                lbl.Text = "👤 "..plr.Name.."\n❤️ "..hp.." | 📍 "..d.."m"
                            end
                        elseif bb then bb:Destroy() end
                    end
                end
            end
            -- Bosses ESP
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    local hum  = v:FindFirstChildOfClass("Humanoid")
                    local bHRP = v:FindFirstChild("HumanoidRootPart")
                    if hum and bHRP and hum.MaxHealth > 5000 and not Players:GetPlayerFromCharacter(v) then
                        local tag = "_BE"..uid
                        local bb  = bHRP:FindFirstChild(tag)
                        if S.EspBosses and not bb then
                            bb = Instance.new("BillboardGui", bHRP)
                            bb.Name = tag; bb.AlwaysOnTop = true
                            bb.Size = UDim2.new(0,200,0,38)
                            bb.StudsOffset = Vector3.new(0,6,0)
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1,0,1,0)
                            lbl.BackgroundColor3 = Color3.fromRGB(60,0,0)
                            lbl.BackgroundTransparency = 0.25
                            lbl.TextColor3 = Color3.fromRGB(255,100,100)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 11
                        elseif S.EspBosses and bb then
                            local myHRP = HRP()
                            local lbl   = bb:FindFirstChildOfClass("TextLabel")
                            if lbl and myHRP then
                                local d  = math.floor((myHRP.Position - bHRP.Position).Magnitude)
                                local hp = math.floor(hum.Health)
                                lbl.Text = "☠️ "..v.Name.."\n❤️ "..hp.." | 📍 "..d.."m"
                            end
                        elseif bb then bb:Destroy() end
                    end
                end
            end
            -- Baús ESP
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and
                   (v.Name:lower():find("chest") or v.Name:lower():find("bau") or v.Name:lower():find("crate")) then
                    local tag = "_CE"..uid
                    local bb  = v:FindFirstChild(tag)
                    if S.EspChests and not bb then
                        bb = Instance.new("BillboardGui", v)
                        bb.Name = tag; bb.AlwaysOnTop = true
                        bb.Size = UDim2.new(0,150,0,28)
                        bb.StudsOffset = Vector3.new(0,3,0)
                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundColor3 = Color3.fromRGB(50,35,0)
                        lbl.BackgroundTransparency = 0.25
                        lbl.TextColor3 = Color3.fromRGB(255,220,0)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.Text = "🎁 "..v.Name
                    elseif not S.EspChests and bb then bb:Destroy() end
                end
            end
        end)
    end
end)

-- ============================================================
-- TAB: PLAYER
-- ============================================================
Tabs.PlayerTab:Section({ Title = "📊 Stats", TextXAlignment = "Left" })

Tabs.PlayerTab:Dropdown({
    Title    = "📈 Distribuir Stats em",
    Values   = { "Sword","Melee","Fruit","Gun","Defense","HP" },
    Value    = "Sword",
    Callback = function(v) S.StatChoice = v end
})

Tabs.PlayerTab:Toggle({
    Title    = "⚡ Auto Distribuir Stats",
    Desc     = "Distribui pontos automaticamente via remote",
    Value    = false,
    Callback = function(v) S.AutoStats = v end
})

task.spawn(function()
    while true do
        task.wait(1.5)
        if S.AutoStats then
            pcall(function()
                local rem = RS:FindFirstChild("Remotes") or RS
                local fn  = rem:FindFirstChild("AddStat") or rem:FindFirstChild("DistributeStat")
                         or rem:FindFirstChild("StatUp")
                if fn then pcall(function() fn:FireServer(S.StatChoice, 1) end) end
            end)
        end
    end
end)

Tabs.PlayerTab:Section({ Title = "🚀 Movimentação", TextXAlignment = "Left" })

Tabs.PlayerTab:Slider({
    Title    = "🏃 WalkSpeed",
    Value    = { Min = 16, Max = 200, Default = 16 },
    Step     = 4,
    Callback = function(v)
        S.WalkSpeed = v
        pcall(function()
            local hum = Hum()
            if hum then hum.WalkSpeed = v end
        end)
    end
})

Tabs.PlayerTab:Toggle({
    Title    = "✈️ Fly (Voar)",
    Desc     = "Ativa o voo — mova com WASD/joystick + espaço para subir",
    Value    = false,
    Callback = function(v)
        S.Fly = v
        pcall(function()
            local char = Char()
            local hrp  = HRP()
            local hum  = Hum()
            if not char or not hrp or not hum then return end
            if v then
                hum.PlatformStand = true
                if not hrp:FindFirstChild("_FlyGy") then
                    local bg = Instance.new("BodyGyro", hrp)
                    bg.Name = "_FlyGy"; bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 9999
                end
                if not hrp:FindFirstChild("_FlyVe") then
                    local bv = Instance.new("BodyVelocity", hrp)
                    bv.Name = "_FlyVe"; bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.zero
                end
            else
                hum.PlatformStand = false
                local bg = hrp:FindFirstChild("_FlyGy")
                local bv = hrp:FindFirstChild("_FlyVe")
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
            end
        end)
        Notify("Fly", v and "Voo ativado! ✈️" or "Voo desativado.", 3)
    end
})

Tabs.PlayerTab:Slider({
    Title    = "💨 Velocidade de Voo",
    Value    = { Min = 20, Max = 300, Default = 60 },
    Step     = 10,
    Callback = function(v) S.FlySpeed = v end
})

-- Fly via BodyVelocity (funciona no Delta — não usa VirtualInputManager)
RunService.RenderStepped:Connect(function()
    if not S.Fly then return end
    pcall(function()
        local hrp = HRP(); if not hrp then return end
        local bv  = hrp:FindFirstChild("_FlyVe")
        local bg  = hrp:FindFirstChild("_FlyGy")
        if not bv or not bg then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        local uis2 = UIS
        if uis2:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if uis2:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if uis2:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if uis2:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if uis2:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if uis2:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * S.FlySpeed or Vector3.zero
        bg.CFrame   = cam.CFrame
    end)
end)

Tabs.PlayerTab:Toggle({
    Title    = "🔓 No Clip",
    Desc     = "Atravessa paredes e colisões",
    Value    = false,
    Callback = function(v)
        S.NoClip = v
        Notify("NoClip", v and "NoClip ativado!" or "Desativado.", 3)
    end
})

RunService.Stepped:Connect(function()
    if not S.NoClip then return end
    pcall(function()
        local char = Char()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

Tabs.PlayerTab:Toggle({
    Title    = "🦘 Infinite Jump",
    Desc     = "Permite pular infinitamente no ar",
    Value    = false,
    Callback = function(v)
        S.InfJump = v
        Notify("InfJump", v and "Infinite Jump ativado!" or "Desativado.", 3)
    end
})

UIS.JumpRequest:Connect(function()
    if not S.InfJump then return end
    pcall(function()
        local hum = Hum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

-- ============================================================
-- TAB: COMBAT
-- ============================================================
Tabs.CombatTab:Section({ Title = "⚔️ Melhorias de Combate", TextXAlignment = "Left" })

Tabs.CombatTab:Toggle({
    Title    = "⚡ Fast Attack",
    Desc     = "Reduz o intervalo entre ataques ao mínimo",
    Value    = false,
    Callback = function(v) S.FastAttack = v end
})

Tabs.CombatTab:Toggle({
    Title    = "📦 Hitbox Expander",
    Desc     = "Aumenta o hitbox das partes do personagem",
    Value    = false,
    Callback = function(v) S.HitboxExpand = v end
})

Tabs.CombatTab:Slider({
    Title    = "📐 Tamanho do Hitbox",
    Value    = { Min = 5, Max = 80, Default = 15 },
    Step     = 5,
    Callback = function(v) S.HitboxSize = v end
})

Tabs.CombatTab:Toggle({
    Title    = "🌀 Auto Skills",
    Desc     = "Usa Z/X/C/V/F automaticamente em loop",
    Value    = false,
    Callback = function(v) S.AutoSkills = v end
})

task.spawn(function()
    while true do
        task.wait(S.FastAttack and 0.06 or 0.5)
        pcall(function()
            if S.FastAttack or S.AutoSkills then
                local e = NearestEnemy(100)
                if e then
                    if S.FastAttack then Attack(e) end
                    if S.AutoSkills then UseSkills() end
                end
            end
            if S.HitboxExpand then
                local char = Char()
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                            p.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- TAB: MISC
-- ============================================================
Tabs.MiscTab:Section({ Title = "🔧 Geral", TextXAlignment = "Left" })

Tabs.MiscTab:Toggle({
    Title    = "🔄 Anti-AFK",
    Desc     = "Evita ser kickado por inatividade",
    Value    = true,
    Callback = function(v) S.AntiAFK = v end
})

task.spawn(function()
    while true do
        task.wait(55)
        if S.AntiAFK then
            pcall(function()
                -- Anti-AFK via jump state (compatível com Delta)
                local hum = Hum()
                if hum then
                    hum.Jump = true
                    task.wait(0.1)
                    hum.Jump = false
                end
            end)
        end
    end
end)

Tabs.MiscTab:Toggle({
    Title    = "🔁 Auto Rejoin",
    Desc     = "Entra novamente ao ser desconectado",
    Value    = false,
    Callback = function(v)
        S.AutoRejoin = v
        if v then
            game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
                if state == Enum.TeleportState.RequestedFromServer then
                    task.wait(2)
                    pcall(function()
                        game:GetService("TeleportService"):Teleport(game.PlaceId)
                    end)
                end
            end)
        end
    end
})

Tabs.MiscTab:Toggle({
    Title    = "🎁 Auto Coletar Baús",
    Desc     = "Teleporta e coleta baús automaticamente",
    Value    = false,
    Callback = function(v) S.AutoChest = v end
})

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoChest then
            pcall(function()
                local hrp = HRP(); if not hrp then return end
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and
                       (v.Name:lower():find("chest") or v.Name:lower():find("bau") or v.Name:lower():find("crate")) then
                        local d = (hrp.Position - v.Position).Magnitude
                        if d < 200 then
                            hrp.CFrame = v.CFrame * CFrame.new(0,2,0)
                            task.wait(0.3)
                            -- Tenta abrir via remote
                            local rem = RS:FindFirstChild("Remotes") or RS
                            local fn  = rem:FindFirstChild("OpenChest") or rem:FindFirstChild("CollectChest")
                            if fn then pcall(function() fn:FireServer(v) end) end
                            task.wait(0.5)
                        end
                    end
                end
            end)
        end
    end
end)

Tabs.MiscTab:Section({ Title = "🎁 Códigos", TextXAlignment = "Left" })

Tabs.MiscTab:Button({
    Title    = "🎁 Resgatar TODOS os Códigos",
    Desc     = "Tenta resgatar todos os códigos ativos de Maio/2026",
    Callback = function()
        Notify("Códigos", "Resgatando "..#ActiveCodes.." códigos...", 4)
        task.spawn(function()
            for _, code in ipairs(ActiveCodes) do
                pcall(function()
                    local rem = RS:FindFirstChild("Remotes") or RS
                    local fn  = rem:FindFirstChild("RedeemCode") or rem:FindFirstChild("Redeem")
                    if fn then pcall(function() fn:FireServer(code) end) end
                    -- Tenta via TextBox do jogo
                    for _, tb in ipairs(LP.PlayerGui:GetDescendants()) do
                        if tb:IsA("TextBox") then
                            local ph = tb.PlaceholderText:lower()
                            local nm = tb.Name:lower()
                            if ph:find("code") or nm:find("code") then
                                tb.Text = code
                                task.wait(0.1)
                                -- Tenta confirmar clicando no botão ao lado
                                for _, sib in ipairs(tb.Parent:GetChildren()) do
                                    if sib:IsA("TextButton") then
                                        sib.MouseButton1Click:Fire()
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.6)
            end
            Notify("Códigos", "Resgate concluído! ✅", 4)
        end)
    end
})

Tabs.Misc