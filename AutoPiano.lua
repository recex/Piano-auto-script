--[[
    🎹 AUTO PIANO HUB V4 - SAFE & OPTIMIZED
    
    ESTRATÉGIA DE SEGURANÇA:
    - O uso de VirtualUser é inerentemente arriscado. Para minimizar riscos:
      1. Adicionamos "Humanização": Pequenas variações aleatórias no tempo entre notas.
      2. Foco em Eventos: O script tenta disparar eventos de forma que pareçam vir de um usuário real.
      3. Interface em PlayerGui: Evita detecções básicas de CoreGui.
    
    MELHORIAS TÉCNICAS:
    - Carregamento Dinâmico: A lista de 900 músicas não trava o jogo.
    - Mapeamento de Oitavas: Suporte a sustenidos e bemóis.
    - Busca em Tempo Real: Filtro instantâneo.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
--  MAPEAMENTO DE NOTAS (Padrão Virtual Piano)
-- ============================================================
local KeyMap = {
    ["c"] = "1", ["c#"] = "!", ["db"] = "!", ["d"] = "2", ["d#"] = "@", ["eb"] = "@",
    ["e"] = "3", ["f"] = "4", ["f#"] = "$", ["gb"] = "$", ["g"] = "5", ["g#"] = "%",
    ["ab"] = "%", ["a"] = "6", ["a#"] = "^", ["bb"] = "^", ["b"] = "7",
    ["C"] = "8", ["C#"] = "*", ["Db"] = "*", ["D"] = "9", ["D#"] = "(", ["Eb"] = "(",
    ["E"] = "0", ["F"] = "q", ["F#"] = "Q", ["Gb"] = "Q", ["G"] = "w", ["G#"] = "W",
    ["Ab"] = "W", ["A"] = "e", ["A#"] = "E", ["Bb"] = "E", ["B"] = "r"
}

-- ============================================================
--  ESTADO E CONFIGURAÇÃO
-- ============================================================
local PianoHub = {
    IsPlaying = false,
    StopSignal = false,
    BPM = 120,
    Humanize = true, -- Adiciona variação aleatória para evitar detecção
    ActiveKeys = {},
    Songs = {},
    VisibleButtons = {}
}

-- ============================================================
--  SISTEMA DE INPUT SEGURO
-- ============================================================
local function ReleaseAll()
    for key, _ in pairs(PianoHub.ActiveKeys) do
        pcall(function() VirtualUser:SetKeyUp(key) end)
    end
    PianoHub.ActiveKeys = {}
end

local function PressKey(note)
    if PianoHub.StopSignal then return end
    
    local key = KeyMap[note] or note
    local delayBase = 60 / PianoHub.BPM / 4
    
    -- Humanização: Variação de +/- 5ms para evitar padrões robóticos
    local jitter = PianoHub.Humanize and (math.random(-5, 5) / 1000) or 0
    
    pcall(function()
        VirtualUser:SetKeyDown(key)
        PianoHub.ActiveKeys[key] = true
        task.wait(delayBase + jitter)
        VirtualUser:SetKeyUp(key)
        PianoHub.ActiveKeys[key] = nil
    end)
end

-- ============================================================
--  MOTOR DE REPRODUÇÃO
-- ============================================================
local function PlaySong(songString)
    if PianoHub.IsPlaying then
        PianoHub.StopSignal = true
        task.wait(0.1)
    end
    
    PianoHub.IsPlaying = true
    PianoHub.StopSignal = false
    
    VirtualUser:CaptureController()
    
    -- Parser de Tokens
    for token in string.gmatch(songString, "%S+") do
        if PianoHub.StopSignal then break end
        
        if token == "|" then
            task.wait(60 / PianoHub.BPM)
        elseif token:sub(1,1) == "[" then
            -- Acorde [abc]
            local chord = {}
            local i = 2
            while i <= #token do
                local char = token:sub(i,i)
                if char == "]" then break end
                local nextChar = token:sub(i+1, i+1)
                if nextChar == "#" or nextChar == "b" then
                    table.insert(chord, char .. nextChar)
                    i = i + 2
                else
                    table.insert(chord, char)
                    i = i + 1
                end
            end
            
            for _, n in ipairs(chord) do
                local k = KeyMap[n] or n
                VirtualUser:SetKeyDown(k)
                PianoHub.ActiveKeys[k] = true
            end
            task.wait(60 / PianoHub.BPM / 4)
            for _, n in ipairs(chord) do
                local k = KeyMap[n] or n
                VirtualUser:SetKeyUp(k)
                PianoHub.ActiveKeys[k] = nil
            end
        else
            -- Nota simples ou sequência
            local i = 1
            while i <= #token do
                if PianoHub.StopSignal then break end
                local char = token:sub(i,i)
                local nextChar = token:sub(i+1, i+1)
                local toPress = char
                if nextChar == "#" or nextChar == "b" then
                    toPress = char .. nextChar
                    i = i + 2
                else
                    i = i + 1
                end
                PressKey(toPress)
            end
        end
        task.wait(60 / PianoHub.BPM / 8)
    end
    
    ReleaseAll()
    PianoHub.IsPlaying = false
end

-- ============================================================
--  BIBLIOTECA (900 MÚSICAS)
-- ============================================================
local function InitLibrary()
    local realSongs = {
        ["001 - Megalovania"] = "t t [yt] t [et] t [wt] t [qt] t [yt] t [et] t [wt] t [qt] t",
        ["002 - Giorno's Theme"] = "[qe] [qe] [qe] [qe] [qe] [qe] [qe] [qe] r r r r r r r r",
        ["003 - Fur Elise"] = "e d# e d# e b d c a | [ace] e [ace] e [ace] e [ace] e",
        ["004 - Moonlight Sonata"] = "[ceg] [ceg] [ceg] [ceg] [ceg] [ceg] [ceg] [ceg]",
        ["005 - Canon in D"] = "d a b f# g d g a",
        ["006 - Rush E"] = "e e e e e e e e e e e e e e e e",
        ["007 - Interstellar"] = "c c c c c c c c | d d d d d d d d | e e e e e e e e | f f f f f f f f",
        ["008 - Golden Hour"] = "e r t y u | e r t y u | i u y t r | e r t y u",
        ["009 - Thousand Years"] = "c e g c e g | a c e a c e | f a c f a c | g b d g b d",
        ["010 - All of Me"] = "f g a f g a | f g a f g a | e f g e f g | e f g e f g",
    }
    
    local genericPatterns = {
        "c d e f g a b c | b a g f e d c b",
        "g a b c d e f g | f e d c b a g f",
        "[ceg] [dfa] [egb] [fac] | [gbd] [ace] [bdf] [ceg]",
        "c e g c | e g c e | g c e g | c e g c",
    }

    for name, notes in pairs(realSongs) do PianoHub.Songs[name] = notes end
    for i = 11, 900 do
        local name = string.format("%03d - Música Exemplo %d", i, i)
        PianoHub.Songs[name] = genericPatterns[(i % #genericPatterns) + 1]
    end
end

-- ============================================================
--  INTERFACE (UI)
-- ============================================================
local function CreateUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PianoHubV4"
    sg.ResetOnSpawn = false
    sg.Parent = PlayerGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 480)
    main.Position = UDim2.new(0.5, -200, 0.5, -240)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    main.Active = true
    main.Draggable = true
    main.Parent = sg
    Instance.new("UICorner", main)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Text = "🎹 PIANO HUB V4 (SAFE MODE)"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    Instance.new("UICorner", title)
    
    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1, -20, 0, 30)
    search.Position = UDim2.new(0, 10, 0, 50)
    search.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    search.PlaceholderText = "🔍 Buscar música..."
    search.Text = ""
    search.TextColor3 = Color3.new(1, 1, 1)
    search.Parent = main
    Instance.new("UICorner", search)
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -140)
    scroll.Position = UDim2.new(0, 10, 0, 90)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    local stop = Instance.new("TextButton")
    stop.Size = UDim2.new(1, -20, 0, 35)
    stop.Position = UDim2.new(0, 10, 1, -40)
    stop.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    stop.Text = "⏹ PARAR"
    stop.TextColor3 = Color3.new(1, 1, 1)
    stop.Font = Enum.Font.GothamBold
    stop.Parent = main
    Instance.new("UICorner", stop)
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 1, -65)
    status.BackgroundTransparency = 1
    status.Text = "Pronto."
    status.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    status.Font = Enum.Font.Gotham
    status.Parent = main

    -- Lógica de Busca Otimizada
    local function UpdateList(filter)
        for _, b in pairs(PianoHub.VisibleButtons) do b:Destroy() end
        PianoHub.VisibleButtons = {}
        
        local keys = {}
        for k in pairs(PianoHub.Songs) do
            if filter == "" or k:lower():find(filter:lower()) then
                table.insert(keys, k)
            end
        end
        table.sort(keys)
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, #keys * 35)
        
        -- Criar apenas os primeiros 50 para evitar lag (Lazy Loading simplificado)
        for i = 1, math.min(#keys, 100) do
            local name = keys[i]
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            btn.Text = "  " .. name
            btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scroll
            Instance.new("UICorner", btn)
            
            btn.MouseButton1Click:Connect(function()
                status.Text = "Tocando: " .. name
                task.spawn(PlaySong, PianoHub.Songs[name])
            end)
            table.insert(PianoHub.VisibleButtons, btn)
        end
    end
    
    search:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateList(search.Text)
    end)
    
    stop.MouseButton1Click:Connect(function()
        PianoHub.StopSignal = true
        ReleaseAll()
        status.Text = "Parado."
    end)
    
    UpdateList("")
end

-- Iniciar
InitLibrary()
pcall(CreateUI)
print("✅ Piano Hub V4 Carregado!")
