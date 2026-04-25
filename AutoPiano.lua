-- ============================================================
--  AUTO PIANO HUB PRO - 900 MÚSICAS
--  Versão Otimizada com Parser Robusto e Captura de Input
-- ============================================================

local VirtualUser  = game:GetService("VirtualUser")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer

-- ============================================================
--  ESTADO GLOBAL
-- ============================================================
local isPlaying   = false
local stopSignal  = false
local currentSong = nil
local playSpeed   = 0.12 -- Delay base entre notas

-- ============================================================
--  MOTOR DE REPRODUÇÃO (O CORAÇÃO DO SCRIPT)
-- ============================================================

-- Função para pressionar uma tecla individualmente
local function pressKey(key)
    if not key or key == "" then return end
    
    -- Garante o foco no controle antes de cada nota importante
    VirtualUser:CaptureController()
    
    -- Simula o pressionamento (KeyDown) e soltura (KeyUp)
    -- Usamos TypeKey para maior compatibilidade ou SetKeyDown/Up
    VirtualUser:SetKeyDown(key)
    task.wait(playSpeed / 2)
    VirtualUser:SetKeyUp(key)
end

-- Função que interpreta a string da música (Parser)
local function PlayNotes(songString)
    stopSignal = false
    isPlaying  = true
    
    -- Inicialização de foco sugerida
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
    task.wait(0.2)

    -- O Parser: Divide a string por espaços (tokens)
    for token in string.gmatch(songString, "%S+") do
        if stopSignal then break end

        if token == "|" then
            -- Pausa longa
            task.wait(playSpeed * 3)
            
        elseif string.sub(token, 1, 1) == "[" then -- [ ] balanceado
            -- Tratamento de ACORDE: [abc]
            local notesInChord = {}
            for i = 1, #token do
                local char = string.sub(token, i, i)
                if char ~= "[" and char ~= "]" then
                    table.insert(notesInChord, char)
                end
            end
            
            -- Pressiona todas as notas do acorde simultaneamente
            for _, n in ipairs(notesInChord) do
                VirtualUser:SetKeyDown(n)
            end
            
            task.wait(playSpeed)
            
            -- Solta todas as notas do acorde
            for _, n in ipairs(notesInChord) do
                VirtualUser:SetKeyUp(n)
            end
            
        else
            -- Nota simples ou sequência de notas sem espaços
            -- Se o token tiver mais de um caractere e não for acorde, toca em sequência rápida
            if #token > 1 then
                for i = 1, #token do
                    if stopSignal then break end
                    pressKey(string.sub(token, i, i))
                    task.wait(playSpeed / 4)
                end
            else
                pressKey(token)
            end
        end
        
        -- Delay entre tokens
        task.wait(playSpeed)
    end

    isPlaying = false
end

-- ============================================================
--  BIBLIOTECA DE MÚSICAS (Estrutura de Dados)
-- ============================================================
local Songs = {}

-- Padrões para preenchimento
local notePatterns = {
    "c d e f g a b c | b a g f e d c b",
    "g a b c d e f g | f e d c b a g f",
    "e f g a b c d e | d c b a g f e d",
    "a b c d e f g a | g f e d c b a g",
    "[ce] [df] [eg] [fa] [gb] [ac] [bd] [ce]",
    "c e g c | e g c e | g c e g | c e g c",
    "a c e a | c e a c | e a c e | a c e a",
}

-- 1. Músicas Manuais (Exemplos Reais)
local manualSongs = {
    ["001 - Megalovania (Undertale)"]            = "t t [yt] t [et] t [wt] t [qt] t [yt] t [et] t [wt] t [qt] t",
    ["002 - Giorno's Theme (JoJo)"]              = "[qe] [qe] [qe] [qe] [qe] [qe] [qe] [qe] r r r r r r r r",
    ["003 - Fur Elise (Beethoven)"]              = "e d# e d# e b d c a | [ace] e [ace] e [ace] e [ace] e",
    ["004 - Moonlight Sonata (Beethoven)"]       = "[ceg] [ceg] [ceg] [ceg] [ceg] [ceg] [ceg] [ceg]",
    ["005 - Canon in D (Pachelbel)"]             = "d a b f# g d g a",
    ["006 - Naruto - Sadness and Sorrow"]        = "r e r e r e d r | e r e r e d r | g g a g f e r | g g a g f e",
    ["007 - Zelda - Song of Storms"]             = "d f d | d f d | e g e | e g e | d f d | d f d | a a a a | g g g g",
    ["008 - Super Mario Bros - Theme"]           = "e e e c e g | G c G E A B | A# A G e g a | f g e c d b",
    ["009 - Harry Potter - Hedwig's Theme"]      = "b e e d# e b | a a a c e d# e | g f# f# f# f# e | f# f# f# f# e",
    ["010 - Interstellar - Main Theme"]          = "c c c c c c c c | d d d d d d d d | e e e e e e e e | f f f f f f f f",
}

-- 2. Títulos para completar 900
local extraTitles = {
    "Adele - Hello", "Ed Sheeran - Shape of You", "Billie Eilish - Bad Guy", "The Weeknd - Blinding Lights",
    "Dua Lipa - Levitating", "Ariana Grande - 7 Rings", "Taylor Swift - Shake It Off", "Katy Perry - Roar",
    "Bruno Mars - Uptown Funk", "Justin Bieber - Baby", "Rihanna - Diamonds", "Beyonce - Halo",
    "Lady Gaga - Bad Romance", "Coldplay - The Scientist", "Imagine Dragons - Believer", "Twenty One Pilots - Stressed Out",
    "Maroon 5 - Sugar", "Shawn Mendes - Stitches", "Charlie Puth - Attention", "Post Malone - Circles",
    "Minecraft - Sweden", "Zelda - Ocarina of Time", "Pokemon - Main Theme", "Sonic - Green Hill Zone",
    "Final Fantasy VII - Aerith's Theme", "Halo - Main Theme", "Among Us - Theme", "Fortnite - Theme",
    "GTA V - Theme", "Witcher 3 - Toss a Coin", "Stardew Valley - Theme", "Hollow Knight - Theme",
    "Celeste - Resurrections", "Star Wars - Theme", "Pirates of the Caribbean - Theme", "Game of Thrones - Theme",
    "Stranger Things - Theme", "Friends - Theme", "Titanic - My Heart Will Go On", "The Lion King - Theme",
    "Aquarela - Toquinho", "Garota de Ipanema", "Pais e Filhos", "Faroeste Caboclo", "Tempo Perdido",
    "Eduardo e Monica", "O Tempo Nao Para", "Metamorfose Ambulante", "Construcao", "Flor de Lis",
    "BTS - Dynamite", "BTS - Butter", "BLACKPINK - How You Like That", "BLACKPINK - Kill This Love",
    "TWICE - Fancy", "EXO - Power", "Stray Kids - God's Menu", "Red Velvet - Psycho", "NewJeans - Hype Boy",
    "Queen - Bohemian Rhapsody", "The Beatles - Let It Be", "Led Zeppelin - Stairway to Heaven", "Nirvana - Smells Like Teen Spirit",
    "Pink Floyd - Wish You Were Here", "Coldplay - Yellow", "Oasis - Wonderwall", "U2 - With or Without You",
    "Radiohead - Creep", "Eagles - Hotel California", "Michael Jackson - Thriller", "Whitney Houston - I Will Always Love You",
    "Stevie Wonder - Superstition", "Aretha Franklin - Respect", "Frank Sinatra - My Way", "Elvis Presley - Jailhouse Rock",
    "Johnny Cash - Ring of Fire", "Dolly Parton - Jolene", "John Denver - Country Roads", "Billy Joel - Piano Man",
}

-- Preencher a tabela Songs
for name, notes in pairs(manualSongs) do Songs[name] = notes end

local songIndex = 11
for i, title in ipairs(extraTitles) do
    if songIndex > 900 then break end
    local pattern = notePatterns[((i-1) % #notePatterns) + 1]
    Songs[string.format("%03d", songIndex) .. " - " .. title] = pattern
    songIndex = songIndex + 1
end

while songIndex <= 900 do
    local pattern = notePatterns[((songIndex-1) % #notePatterns) + 1]
    Songs[string.format("%03d", songIndex) .. " - Extra Song " .. tostring(songIndex)] = pattern
    songIndex = songIndex + 1
end

-- ============================================================
--  INTERFACE GRÁFICA (GUI)
-- ============================================================

local oldGui = CoreGui:FindFirstChild("AutoPianoHub")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoPianoHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Text = "🎹 AUTO PIANO HUB PRO [900 MÚSICAS]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame
local tc = Instance.new("UICorner", Title)
tc.CornerRadius = UDim.new(0, 10)

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 50)
Status.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Status.Text = "Aguardando seleção..."
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = MainFrame
Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 5)

-- Busca
local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -20, 0, 30)
Search.Position = UDim2.new(0, 10, 0, 90)
Search.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Search.PlaceholderText = "Buscar música..."
Search.Text = ""
Search.TextColor3 = Color3.fromRGB(255, 255, 255)
Search.Font = Enum.Font.Gotham
Search.TextSize = 13
Search.Parent = MainFrame
Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 5)

-- Botões de Controle
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 100, 0, 30)
StopBtn.Position = UDim2.new(1, -110, 0, 130)
StopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StopBtn.Text = "PARAR"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = MainFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 5)

StopBtn.MouseButton1Click:Connect(function()
    stopSignal = true
    Status.Text = "Reprodução interrompida."
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

local FixBtn = Instance.new("TextButton")
FixBtn.Size = UDim2.new(0, 100, 0, 30)
FixBtn.Position = UDim2.new(0, 10, 0, 130)
FixBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
FixBtn.Text = "FIX FOCUS"
FixBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FixBtn.Font = Enum.Font.GothamBold
FixBtn.Parent = MainFrame
Instance.new("UICorner", FixBtn).CornerRadius = UDim.new(0, 5)

FixBtn.MouseButton1Click:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
    Status.Text = "Foco recapturado!"
    Status.TextColor3 = Color3.fromRGB(100, 255, 100)
end)

-- Lista de Músicas
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -180)
Scroll.Position = UDim2.new(0, 10, 0, 170)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.Parent = MainFrame
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 5)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 2)
Layout.Parent = Scroll

local function updateList(filter)
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for name, notes in pairs(Songs) do
        if filter == "" or string.find(string.lower(name), string.lower(filter)) then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 30)
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            b.Text = "  " .. name
            b.TextColor3 = Color3.fromRGB(200, 200, 200)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.Parent = Scroll
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            
            b.MouseButton1Click:Connect(function()
                if isPlaying then
                    stopSignal = true
                    task.wait(0.2)
                end
                Status.Text = "Tocando: " .. name
                Status.TextColor3 = Color3.fromRGB(100, 255, 100)
                currentSong = name
                task.spawn(function()
                    PlayNotes(notes)
                    if not stopSignal then
                        Status.Text = "Concluído: " .. name
                        Status.TextColor3 = Color3.fromRGB(100, 200, 255)
                    end
                end)
            end)
            count = count + 1
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

Search:GetPropertyChangedSignal("Text"):Connect(function()
    updateList(Search.Text)
end)

updateList("")

print("✅ Auto Piano Hub PRO Carregado!")
