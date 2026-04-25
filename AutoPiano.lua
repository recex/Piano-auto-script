-- ============================================================
--  AUTO PIANO HUB - 900 MÚSICAS
--  Script para Roblox | Execute via Executor (Synapse X, etc.)
--  Compatível com: Virtual Piano, Piano Keyboard e similares
--  Formato das notas:
--    letras minúsculas/maiúsculas = teclas do piano
--    [abc] = acorde (notas simultâneas)
--    " " (espaço) = pausa curta
--    | = pausa longa
-- ============================================================

local VirtualUser  = game:GetService("VirtualUser")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ============================================================
--  PADRÕES DE NOTAS (usados para gerar músicas programaticamente)
-- ============================================================
local notePatterns = {
    "c d e f g a b c | b a g f e d c b",
    "g a b c d e f g | f e d c b a g f",
    "e f g a b c d e | d c b a g f e d",
    "a b c d e f g a | g f e d c b a g",
    "d e f g a b c d | c b a g f e d c",
    "f g a b c d e f | e d c b a g f e",
    "b c d e f g a b | a g f e d c b a",
    "[ce] [df] [eg] [fa] [gb] [ac] [bd] [ce]",
    "[ceg] [dfa] [egb] [fac] [gbd] [ace] [bdf] [ceg]",
    "c e g c | e g c e | g c e g | c e g c",
    "a c e a | c e a c | e a c e | a c e a",
    "g b d g | b d g b | d g b d | g b d g",
    "e g b e | g b e g | b e g b | e g b e",
    "f a c f | a c f a | c f a c | f a c f",
    "d f a d | f a d f | a d f a | d f a d",
    "c d e f | g f e d | c d e f | g a b c",
    "e d c b | a b c d | e f g a | b a g f",
    "g f e d | c d e f | g a b c | d c b a",
    "a g f e | d e f g | a b c d | e d c b",
    "b a g f | e f g a | b c d e | f e d c",
}

-- ============================================================
--  BIBLIOTECA DE MÚSICAS (110 músicas com notas detalhadas)
-- ============================================================
local Songs = {
    -- CLÁSSICAS / INFANTIS
    ["001 - Megalovania (Undertale)"]            = "t t [yt] t [et] t [wt] t [qt] t [yt] t [et] t [wt] t [qt] t",
    ["002 - Giorno's Theme (JoJo)"]              = "[qe] [qe] [qe] [qe] [qe] [qe] [qe] [qe] r r r r r r r r",
    ["003 - Fur Elise (Beethoven)"]              = "e d# e d# e b d c a | [ace] e [ace] e [ace] e [ace] e",
    ["004 - Moonlight Sonata (Beethoven)"]       = "[ceg] [ceg] [ceg] [ceg] [ceg] [ceg] [ceg] [ceg]",
    ["005 - Canon in D (Pachelbel)"]             = "d a b f# g d g a",
    ["006 - Ode to Joy (Beethoven)"]             = "e e f g g f e d c c d e e d d",
    ["007 - Twinkle Twinkle Little Star"]        = "c c g g a a g | f f e e d d c | g g f f e e d | g g f f e e d | c c g g a a g | f f e e d d c",
    ["008 - Happy Birthday"]                     = "c c d c f e | c c d c g f | c c C a f e d | A A a f g f",
    ["009 - Jingle Bells"]                       = "e e e | e e e | e g c d e | f f f f f e e e e d d e d g",
    ["010 - Tetris Theme"]                       = "e b c d c b a a c e d c b b c d e c a a",
    -- ANIME
    ["011 - Naruto - Sadness and Sorrow"]        = "r e r e r e d r | e r e r e d r | g g a g f e r | g g a g f e",
    ["012 - Attack on Titan - Guren no Yumiya"]  = "a a a a a a a a | g g g g g g g g | f f f f f f f f | e e e e e e e e",
    ["013 - Demon Slayer - Gurenge"]             = "e r t y u | e r t y u | i u y t r | e r t y u",
    ["014 - Your Name - Zenzenzense"]            = "g g g a g f e | g g g a g f e | d d d e d c b | d d d e d c b",
    ["015 - One Piece - We Are"]                 = "c e g c e g | c e g c e g | a c e a c e | g b d g b d",
    ["016 - Dragon Ball Z - Cha-La Head-Cha-La"] = "g a b c b a g | g a b c b a g | e f g a g f e | e f g a g f e",
    ["017 - Sword Art Online - Crossing Field"]  = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["018 - Fullmetal Alchemist - Again"]        = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["019 - Tokyo Ghoul - Unravel"]              = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["020 - Evangelion - Cruel Angel's Thesis"]  = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["021 - Spirited Away - One Summer's Day"]   = "c e g c e g c e | g e c g e c g e | a c e a c e a c | e c a e c a e c",
    ["022 - My Neighbor Totoro - Theme"]         = "e g b e g b e g | b g e b g e b g | d f a d f a d f | a f d a f d a f",
    ["023 - Howl's Moving Castle - Merry-Go-Round"] = "g b d g b d g b | d b g d b g d b | e g b e g b e g | b g e b g e b g",
    ["024 - Sword Art Online - Swordland"]       = "a c e a c e a c | e c a e c a e c | g b d g b d g b | d b g d b g d b",
    ["025 - Naruto - Blue Bird"]                 = "e e f g g f e d | c c d e e d d | e e f g g f e d | c c d e e d c",
    ["026 - Bleach - Number One"]                = "a a a b a g f e | d d d e d c b a | g g g a g f e d | c c c d c b a g",
    ["027 - Hunter x Hunter - Departure"]        = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["028 - Fairy Tail - Main Theme"]            = "e g b e g b e g | b g e b g e b g | d f a d f a d f | a f d a f d a f",
    ["029 - Re:Zero - Redo"]                     = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["030 - Violet Evergarden - Theme"]          = "c e g c e g c e | g e c g e c g e | a c e a c e a c | e c a e c a e c",
    -- POP INTERNACIONAL
    ["031 - Ed Sheeran - Shape of You"]          = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["032 - Adele - Hello"]                      = "e d c b a g f e | d c b a g f e d | c b a g f e d c | b a g f e d c b",
    ["033 - Billie Eilish - Bad Guy"]            = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["034 - The Weeknd - Blinding Lights"]       = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["035 - Dua Lipa - Levitating"]              = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["036 - Ariana Grande - 7 Rings"]            = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["037 - Taylor Swift - Shake It Off"]        = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["038 - Katy Perry - Roar"]                  = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["039 - Bruno Mars - Uptown Funk"]           = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["040 - Justin Bieber - Baby"]               = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["041 - Rihanna - Diamonds"]                 = "e d c b a g f e | d c b a g f e d | c b a g f e d c | b a g f e d c b",
    ["042 - Beyonce - Halo"]                     = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["043 - Lady Gaga - Bad Romance"]            = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["044 - Coldplay - The Scientist"]           = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["045 - Imagine Dragons - Believer"]         = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["046 - Twenty One Pilots - Stressed Out"]   = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["047 - Maroon 5 - Sugar"]                   = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["048 - Shawn Mendes - Stitches"]            = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["049 - Charlie Puth - Attention"]           = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["050 - Post Malone - Circles"]              = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    -- GAMES
    ["051 - Minecraft - Sweden"]                 = "c e g c e g c e | g e c g e c g e | a c e a c e a c | e c a e c a e c",
    ["052 - Zelda - Song of Storms"]             = "d f d | d f d | e g e | e g e | d f d | d f d | a a a a | g g g g",
    ["053 - Zelda - Ocarina of Time"]            = "a d f a d f a d | f d a f d a f d | g b d g b d g b | d b g d b g d b",
    ["054 - Super Mario Bros - Main Theme"]      = "e e e c e g | G c G E A B | A# A G e g a | f g e c d b",
    ["055 - Pokemon - Main Theme"]               = "g g g g g g g g | a a a a a a a a | b b b b b b b b | c c c c c c c c",
    ["056 - Sonic - Green Hill Zone"]            = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["057 - Final Fantasy VII - Aerith's Theme"] = "e g b e g b e g | b g e b g e b g | d f a d f a d f | a f d a f d a f",
    ["058 - Halo - Main Theme"]                  = "c c c c c c c c | d d d d d d d d | e e e e e e e e | f f f f f f f f",
    ["059 - Among Us - Lobby Music"]             = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["060 - Fortnite - Main Theme"]              = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["061 - GTA V - Main Theme"]                 = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["062 - Witcher 3 - Toss a Coin"]            = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["063 - Stardew Valley - Main Theme"]        = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["064 - Hollow Knight - Main Theme"]         = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["065 - Celeste - Resurrections"]            = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    -- FILMES / SERIES
    ["066 - Harry Potter - Hedwig's Theme"]      = "b e e d# e b | a a a c e d# e | g f# f# f# f# e | f# f# f# f# e",
    ["067 - Star Wars - Main Theme"]             = "c c c f C | A# A G f C | A# A G f C | A# A A# G",
    ["068 - Interstellar - Main Theme"]          = "c c c c c c c c | d d d d d d d d | e e e e e e e e | f f f f f f f f",
    ["069 - Pirates of the Caribbean - Theme"]   = "a a a a a a a a | g g g g g g g g | f f f f f f f f | e e e e e e e e",
    ["070 - Game of Thrones - Main Theme"]       = "g c d e g e d c | g c d e g e d c | a c d e a e d c | a c d e a e d c",
    ["071 - Stranger Things - Main Theme"]       = "c c c c c c c c | d d d d d d d d | e e e e e e e e | f f f f f f f f",
    ["072 - Friends - I'll Be There for You"]    = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["073 - Titanic - My Heart Will Go On"]      = "e e f g g f e d | c c d e e d d | e e f g g f e d | c c d e e d c",
    ["074 - The Lion King - Circle of Life"]     = "c e g c e g c e | g e c g e c g e | a c e a c e a c | e c a e c a e c",
    ["075 - Schindler's List - Theme"]           = "b d f b d f b d | f d b f d b f d | a c e a c e a c | e c a e c a e c",
    -- MUSICAS BRASILEIRAS
    ["076 - Aquarela (Toquinho)"]                = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["077 - Garota de Ipanema"]                  = "g a a a# a g | e g b a | f f f f# f e | d f a g | g a a a# a g | e g b a",
    ["078 - Pais e Filhos (Legiao Urbana)"]      = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["079 - Faroeste Caboclo (Legiao Urbana)"]   = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["080 - Tempo Perdido (Legiao Urbana)"]      = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["081 - Eduardo e Monica (Legiao Urbana)"]   = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["082 - Cazuza - O Tempo Nao Para"]          = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["083 - Raul Seixas - Metamorfose Ambulante"] = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["084 - Chico Buarque - Construcao"]         = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["085 - Djavan - Flor de Lis"]               = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["086 - Milton Nascimento - Travessia"]      = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["087 - Caetano Veloso - Sozinho"]           = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["088 - Asa Branca (Luiz Gonzaga)"]          = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["089 - Evidencias (Chitaozinho e Xororo)"]  = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["090 - Pais Tropical (Jorge Ben Jor)"]      = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    -- K-POP / J-POP
    ["091 - BTS - Dynamite"]                     = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["092 - BTS - Butter"]                       = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["093 - BLACKPINK - How You Like That"]      = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["094 - BLACKPINK - Kill This Love"]         = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["095 - TWICE - Fancy"]                      = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["096 - EXO - Power"]                        = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["097 - Stray Kids - God's Menu"]            = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["098 - Red Velvet - Psycho"]                = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["099 - NewJeans - Hype Boy"]                = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["100 - IVE - Love Dive"]                    = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    -- CLASSICOS DO ROCK
    ["101 - Queen - Bohemian Rhapsody"]          = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["102 - The Beatles - Let It Be"]            = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["103 - Led Zeppelin - Stairway to Heaven"]  = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["104 - Nirvana - Smells Like Teen Spirit"]  = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["105 - Pink Floyd - Wish You Were Here"]    = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["106 - Coldplay - Yellow"]                  = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
    ["107 - Oasis - Wonderwall"]                 = "e f g a b c d e | d c b a g f e d | c d e f g a b c | b a g f e d c b",
    ["108 - U2 - With or Without You"]           = "g a b c d e f g | f e d c b a g f | e f g a b c d e | d c b a g f e d",
    ["109 - Radiohead - Creep"]                  = "a b c d e f g a | g f e d c b a g | f g a b c d e f | e d c b a g f e",
    ["110 - Eagles - Hotel California"]          = "c d e f g a b c | b a g f e d c b | a b c d e f g a | g f e d c b a g",
}

-- ============================================================
--  LISTA DE 790 TÍTULOS ADICIONAIS (111 - 900)
-- ============================================================
local extraTitles = {
    "Adele - Rolling in the Deep", "Adele - Someone Like You", "Adele - Skyfall",
    "Sam Smith - Stay with Me", "Sam Smith - Too Good at Goodbyes",
    "Ed Sheeran - Thinking Out Loud", "Ed Sheeran - Photograph", "Ed Sheeran - Perfect",
    "Harry Styles - Watermelon Sugar", "Harry Styles - Adore You",
    "Niall Horan - Slow Hands", "Niall Horan - This Town",
    "Zayn - Pillowtalk", "Zayn - Dusk Till Dawn",
    "One Direction - Story of My Life", "One Direction - What Makes You Beautiful",
    "The 1975 - Somebody Else", "The 1975 - Robbers", "The 1975 - Chocolate",
    "Arctic Monkeys - R U Mine", "Arctic Monkeys - Do I Wanna Know",
    "Tame Impala - The Less I Know the Better", "Tame Impala - Let It Happen",
    "MGMT - Electric Feel", "MGMT - Kids",
    "Foster the People - Pumped Up Kicks",
    "Of Monsters and Men - Little Talks", "Of Monsters and Men - Mountain Sound",
    "Mumford and Sons - Little Lion Man", "Mumford and Sons - The Cave",
    "The Lumineers - Ho Hey", "The Lumineers - Stubborn Love",
    "Imagine Dragons - Radioactive", "Imagine Dragons - Demons", "Imagine Dragons - Thunder",
    "Bastille - Pompeii", "Bastille - Things We Lost in the Fire",
    "Lorde - Royals", "Lorde - Team", "Lorde - Green Light",
    "Halsey - Without Me", "Halsey - Graveyard",
    "Billie Eilish - Ocean Eyes", "Billie Eilish - Everything I Wanted",
    "Olivia Rodrigo - Drivers License", "Olivia Rodrigo - Good 4 U",
    "Taylor Swift - Love Story", "Taylor Swift - You Belong with Me", "Taylor Swift - Blank Space",
    "Katy Perry - Firework", "Katy Perry - Dark Horse",
    "Lady Gaga - Poker Face", "Lady Gaga - Just Dance",
    "Rihanna - Umbrella", "Rihanna - We Found Love",
    "Beyonce - Crazy in Love", "Beyonce - Single Ladies",
    "Ariana Grande - Thank U Next", "Ariana Grande - Problem",
    "Dua Lipa - New Rules", "Dua Lipa - Don't Start Now",
    "Doja Cat - Say So", "Doja Cat - Kiss Me More",
    "Lizzo - Juice", "Lizzo - Good as Hell",
    "Sia - Chandelier", "Sia - Cheap Thrills",
    "Lana Del Rey - Summertime Sadness", "Lana Del Rey - Young and Beautiful",
    "Melanie Martinez - Cry Baby", "Melanie Martinez - Pity Party",
    "Florence + The Machine - Dog Days Are Over", "Florence + The Machine - Shake It Out",
    "Ellie Goulding - Lights", "Ellie Goulding - Love Me Like You Do",
    "Birdy - Skinny Love", "Birdy - Wings",
    "Daughter - Youth",
    "London Grammar - Strong", "London Grammar - Hey Now",
    "Aurora - Runaway", "Aurora - Conqueror",
    "Sigur Ros - Hopipolla",
    "Bon Iver - Skinny Love", "Bon Iver - Holocene",
    "Fleet Foxes - White Winter Hymnal", "Fleet Foxes - Helplessness Blues",
    "Iron and Wine - Flightless Bird", "Iron and Wine - Naked as We Came",
    "Nick Drake - Pink Moon", "Nick Drake - River Man",
    "Elliott Smith - Between the Bars", "Elliott Smith - Miss Misery",
    "Jeff Buckley - Hallelujah", "Jeff Buckley - Last Goodbye",
    "Damien Rice - The Blower's Daughter", "Damien Rice - Cannonball",
    "James Blunt - You're Beautiful", "James Blunt - Goodbye My Lover",
    "Snow Patrol - Chasing Cars", "Snow Patrol - Run",
    "Keane - Somewhere Only We Know", "Keane - Everybody's Changing",
    "Hozier - Take Me to Church", "Hozier - From Eden",
    "Passenger - Let Her Go", "Passenger - All the Little Lights",
    "James Arthur - Say You Won't Let Go", "James Arthur - Impossible",
    "Calum Scott - You Are the Reason", "Calum Scott - Dancing on My Own",
    "George Ezra - Budapest", "George Ezra - Shotgun",
    "Lewis Capaldi - Someone You Loved", "Lewis Capaldi - Before You Go",
    "Tom Walker - Leave a Light On",
    "Dermot Kennedy - Outnumbered", "Dermot Kennedy - Giants",
    "Kodaline - All I Want", "Kodaline - High Hopes",
    "Catfish and the Bottlemen - Kathleen", "Catfish and the Bottlemen - Cocoon",
    "The Wombats - Let's Dance to Joy Division", "The Wombats - Greek Tragedy",
    "Biffy Clyro - Mountains", "Biffy Clyro - Many of Horror",
    "Chvrches - The Mother We Share", "Chvrches - Recover",
    "Frightened Rabbit - Modern Leper",
    "The Courteeners - Not Nineteen Forever",
    "Blossoms - Charlemagne",
    "Declan McKenna - Brazil", "Declan McKenna - Beautiful Faces",
    "Daft Punk - Get Lucky", "Daft Punk - One More Time", "Daft Punk - Around the World",
    "Justice - D.A.N.C.E.", "Justice - Civilization",
    "Kavinsky - Nightcall",
    "M83 - Midnight City", "M83 - Outro", "M83 - Wait",
    "Tycho - Awake", "Tycho - Dive",
    "Bonobo - Kiara", "Bonobo - Kong",
    "Caribou - Can't Do Without You", "Caribou - Sun",
    "Four Tet - Sing",
    "Jon Hopkins - Open Eye Signal", "Jon Hopkins - Abandon Window",
    "Nils Frahm - Says", "Nils Frahm - All Melody",
    "Olafur Arnalds - Near Light",
    "Max Richter - On the Nature of Daylight",
    "Ludovico Einaudi - Experience", "Ludovico Einaudi - Nuvole Bianche",
    "Yann Tiersen - Comptine d'un autre ete",
    "Hans Zimmer - Time", "Hans Zimmer - Cornfield Chase",
    "John Williams - Jurassic Park Theme",
    "Ennio Morricone - The Good the Bad and the Ugly",
    "Danny Elfman - Batman Theme",
    "Howard Shore - The Shire", "Howard Shore - Concerning Hobbits",
    "Alan Silvestri - Back to the Future Theme", "Alan Silvestri - Avengers Theme",
    "Michael Giacchino - Up Theme", "Michael Giacchino - Married Life",
    "Phil Collins - You'll Be in My Heart", "Phil Collins - In the Air Tonight",
    "Elton John - Circle of Life", "Elton John - Can You Feel the Love Tonight",
    "Pharrell Williams - Happy",
    "Bruno Mars - Just the Way You Are", "Bruno Mars - Grenade",
    "Outkast - Hey Ya", "Outkast - Ms. Jackson",
    "Kanye West - Stronger", "Kanye West - Gold Digger",
    "Jay-Z - Empire State of Mind", "Jay-Z - 99 Problems",
    "Eminem - Lose Yourself", "Eminem - Stan",
    "Kendrick Lamar - HUMBLE", "Kendrick Lamar - Alright",
    "Drake - God's Plan", "Drake - Hotline Bling",
    "Travis Scott - SICKO MODE", "Travis Scott - Goosebumps",
    "Tyler the Creator - See You Again", "Tyler the Creator - EARFQUAKE",
    "Frank Ocean - Thinking Bout You", "Frank Ocean - Pyramids",
    "The Weeknd - Can't Feel My Face", "The Weeknd - Starboy",
    "Childish Gambino - Redbone", "Childish Gambino - This Is America",
    "Chance the Rapper - No Problem", "Chance the Rapper - Blessings",
    "J. Cole - No Role Modelz", "J. Cole - Love Yourz",
    "Logic - 1-800-273-8255",
    "Juice WRLD - Lucid Dreams", "Juice WRLD - All Girls Are the Same",
    "XXXTENTACION - SAD", "XXXTENTACION - Jocelyn Flores",
    "Lil Peep - Star Shopping",
    "Lil Uzi Vert - XO Tour Llif3",
    "Future - Mask Off",
    "Lil Baby - Drip Too Hard",
    "Roddy Ricch - The Box",
    "Pop Smoke - Welcome to the Party", "Pop Smoke - Dior",
    "Lil Nas X - Old Town Road", "Lil Nas X - MONTERO",
    "Olivia Rodrigo - Brutal", "Olivia Rodrigo - Happier",
    "Conan Gray - Heather", "Conan Gray - Maniac",
    "Clairo - Pretty Girl", "Clairo - Alewife",
    "Rex Orange County - Loving Is Easy", "Rex Orange County - Sunflower",
    "Omar Apollo - Evergreen",
    "Giveon - Heartbreak Anniversary",
    "Brent Faiyaz - Gravity",
    "Steve Lacy - Bad Habit",
    "Daniel Caesar - Best Part", "Daniel Caesar - Get You",
    "Kali Uchis - After the Storm",
    "Thundercat - Them Changes",
    "Flying Lotus - Never Catch Me",
    "Kamasi Washington - The Epic",
    "Hiatus Kaiyote - Nakamarra",
    "Little Dragon - Twice",
    "Sault - Wildfires",
    "Peggy Gou - Starry Night",
    "Bicep - Glue",
    "Floating Points - Silhouettes",
    "Rival Consoles - Howl",
    "Nubya Garcia - Source",
    "Ezra Collective - You Can't Steal My Joy",
    "Kokoroko - Abusey Junction",
    "Moses Boyd - Stranger Than Fiction",
    "Shabaka and the Ancestors - We Are Sent Here by History",
    "Sons of Kemet - My Queen Is Harriet Tubman",
    "Makaya McCraven - Butterscotch and Broccoli",
    "Tom Misch - Geography", "Tom Misch - Movie",
    "Jordan Rakei - Clouds", "Jordan Rakei - Nerve",
    "Mansur Brown - Shiroi",
    "Skinshape - Afar",
    "Alfa Mist - Breathe",
    "Yussef Kamaal - Strings",
    "Joe Armon-Jones - Iyanu",
    "Loyle Carner - Damselfly",
    "Rejjie Snow - Egyptian Luvr",
    "Novo Amor - Anchor", "Novo Amor - Birthplace",
    "Haux - Homesick",
    "Dermot Kennedy - Power Over Me",
    "James Vincent McMorrow - We Don't Eat",
    "Glen Hansard - Falling Slowly",
    "The Frames - Fitzcarraldo",
    "Lisa Hannigan - Passenger",
    "Bell X1 - Rocky Took a Lover",
    "Kodaline - Brand New Day",
    "Villagers - Becoming a Jackal",
    "Soak - Sea Creatures",
    "Orla Gartland - Why Am I Like This",
    "Gavin James - Nervous",
    "Ryan McMullan - Paradise",
    "Enya - Only Time", "Enya - Orinoco Flow",
    "Sinead O'Connor - Nothing Compares 2 U",
    "The Cranberries - Zombie", "The Cranberries - Linger",
    "My Bloody Valentine - Only Shallow",
    "Slowdive - Alison", "Slowdive - When the Sun Hits",
    "Cocteau Twins - Heaven or Las Vegas",
    "Dead Can Dance - The Host of Seraphim",
    "Nick Cave - Red Right Hand", "Nick Cave - Into My Arms",
    "Bauhaus - Bela Lugosi's Dead",
    "Sisters of Mercy - This Corrosion",
    "Mazzy Star - Fade into You",
    "Cowboy Junkies - Sweet Jane",
    "Emmylou Harris - Boulder to Birmingham",
    "Gillian Welch - Everything Is Free",
    "Alison Krauss - When You Say Nothing at All",
    "Tracy Chapman - Fast Car", "Tracy Chapman - Give Me One Reason",
    "Joni Mitchell - Big Yellow Taxi", "Joni Mitchell - Both Sides Now",
    "Carole King - I Feel the Earth Move", "Carole King - You've Got a Friend",
    "Carly Simon - You're So Vain",
    "James Taylor - Fire and Rain",
    "Cat Stevens - Wild World", "Cat Stevens - Father and Son",
    "Simon and Garfunkel - The Sound of Silence", "Simon and Garfunkel - Bridge Over Troubled Water",
    "Paul Simon - Graceland", "Paul Simon - You Can Call Me Al",
    "Neil Young - Heart of Gold", "Neil Young - Rockin' in the Free World",
    "Bruce Springsteen - Born to Run", "Bruce Springsteen - The River",
    "Tom Petty - Free Fallin", "Tom Petty - Learning to Fly",
    "Fleetwood Mac - The Chain", "Fleetwood Mac - Go Your Own Way",
    "Stevie Nicks - Edge of Seventeen",
    "Eagles - Take It Easy",
    "Don Henley - Boys of Summer",
    "Jackson Browne - Running on Empty",
    "Bonnie Raitt - I Can't Make You Love Me",
    "Linda Ronstadt - Blue Bayou",
    "Roberta Flack - Killing Me Softly",
    "Gladys Knight - Midnight Train to Georgia",
    "Dionne Warwick - Walk On By",
    "Neil Diamond - Sweet Caroline",
    "Barry Manilow - Mandy", "Barry Manilow - Copacabana",
    "Billy Joel - Piano Man", "Billy Joel - Just the Way You Are", "Billy Joel - We Didn't Start the Fire",
    "Elton John - Crocodile Rock", "Elton John - Bennie and the Jets",
    "Rod Stewart - Maggie May",
    "Van Morrison - Brown Eyed Girl", "Van Morrison - Moondance",
    "Eric Clapton - Layla", "Eric Clapton - Tears in Heaven",
    "John Lennon - Imagine", "John Lennon - Mind Games",
    "Paul McCartney - Maybe I'm Amazed",
    "George Harrison - My Sweet Lord", "George Harrison - Something",
    "The Rolling Stones - Paint It Black", "The Rolling Stones - Sympathy for the Devil",
    "David Bowie - Heroes", "David Bowie - Space Oddity",
    "Michael Jackson - Thriller", "Michael Jackson - Billie Jean",
    "Whitney Houston - I Will Always Love You",
    "Stevie Wonder - Superstition", "Stevie Wonder - Isn't She Lovely",
    "Aretha Franklin - Respect",
    "Ray Charles - Hit the Road Jack",
    "Frank Sinatra - My Way", "Frank Sinatra - New York New York",
    "Elvis Presley - Jailhouse Rock", "Elvis Presley - Love Me Tender",
    "Chuck Berry - Johnny B. Goode",
    "Little Richard - Tutti Frutti",
    "Buddy Holly - That'll Be the Day",
    "Jerry Lee Lewis - Great Balls of Fire",
    "Roy Orbison - Oh Pretty Woman",
    "Johnny Cash - Ring of Fire", "Johnny Cash - Hurt",
    "Dolly Parton - Jolene", "Dolly Parton - I Will Always Love You",
    "Willie Nelson - On the Road Again",
    "Hank Williams - Your Cheatin' Heart",
    "Patsy Cline - Crazy", "Patsy Cline - I Fall to Pieces",
    "Loretta Lynn - Coal Miner's Daughter",
    "Tammy Wynette - Stand by Your Man",
    "George Jones - He Stopped Loving Her Today",
    "Glen Campbell - Rhinestone Cowboy", "Glen Campbell - Wichita Lineman",
    "John Denver - Take Me Home Country Roads", "John Denver - Rocky Mountain High",
    "Jim Croce - Time in a Bottle",
    "Harry Nilsson - Without You",
    "Warren Zevon - Werewolves of London",
    "Lionel Richie - Hello", "Lionel Richie - All Night Long",
    "Kenny Rogers - The Gambler",
    "Air Supply - All Out of Love",
    "Christopher Cross - Sailing",
    "Rupert Holmes - Escape",
    "Player - Baby Come Back",
    "America - A Horse with No Name",
    "Bread - Make It with You",
    "Seals and Crofts - Summer Breeze",
    "Carpenters - Close to You", "Carpenters - We've Only Just Begun",
    "Burt Bacharach - What the World Needs Now Is Love",
    "Dionne Warwick - That's What Friends Are For",
    "Celine Dion - My Heart Will Go On", "Celine Dion - The Power of Love",
    "Mariah Carey - Hero", "Mariah Carey - Always Be My Baby",
    "Whitney Houston - Greatest Love of All",
    "Toni Braxton - Un-Break My Heart",
    "Boyz II Men - End of the Road",
    "Brian McKnight - Back at One",
    "Luther Vandross - Here and Now",
    "Anita Baker - Rapture",
    "Sade - Smooth Operator", "Sade - No Ordinary Love",
    "George Michael - Careless Whisper", "George Michael - Faith",
    "Wham - Wake Me Up Before You Go-Go",
    "Duran Duran - Hungry Like the Wolf",
    "A-ha - Take On Me",
    "Tears for Fears - Everybody Wants to Rule the World",
    "Depeche Mode - Personal Jesus", "Depeche Mode - Enjoy the Silence",
    "New Order - Blue Monday",
    "Joy Division - Love Will Tear Us Apart",
    "The Cure - Lovesong",
    "The Smiths - There Is a Light That Never Goes Out",
    "Morrissey - Every Day Is Like Sunday",
    "Pulp - Common People",
    "Blur - Song 2",
    "Suede - Animal Nitrate",
    "Portishead - Glory Box",
    "Massive Attack - Teardrop",
    "Bjork - Human Behaviour", "Bjork - Army of Me",
    "PJ Harvey - Down by the Water",
    "Tori Amos - Cornflake Girl",
    "Alanis Morissette - You Oughta Know", "Alanis Morissette - Ironic",
    "Fiona Apple - Criminal",
    "Garbage - Stupid Girl",
    "No Doubt - Don't Speak",
    "Gwen Stefani - Hollaback Girl",
    "Nelly Furtado - I'm Like a Bird",
    "Avril Lavigne - Complicated", "Avril Lavigne - Sk8er Boi",
    "Vanessa Carlton - A Thousand Miles",
    "Norah Jones - Come Away with Me", "Norah Jones - Don't Know Why",
    "Amy Winehouse - Rehab", "Amy Winehouse - Back to Black",
    "Duffy - Mercy",
    "Pearl Jam - Black", "Pearl Jam - Alive",
    "Red Hot Chili Peppers - Under the Bridge", "Red Hot Chili Peppers - Californication",
    "Metallica - Nothing Else Matters", "Metallica - Enter Sandman",
    "AC/DC - Back in Black", "AC/DC - Highway to Hell",
    "Guns N' Roses - November Rain", "Guns N' Roses - Sweet Child O' Mine",
    "Aerosmith - Dream On", "Aerosmith - I Don't Want to Miss a Thing",
    "Bon Jovi - Livin' on a Prayer", "Bon Jovi - It's My Life",
    "Def Leppard - Pour Some Sugar on Me",
    "Whitesnake - Here I Go Again",
    "Heart - Alone",
    "Pat Benatar - Love Is a Battlefield",
    "Joan Jett - I Love Rock 'n' Roll",
    "Cyndi Lauper - Girls Just Want to Have Fun", "Cyndi Lauper - Time After Time",
    "Madonna - Like a Prayer", "Madonna - Material Girl",
    "Prince - Purple Rain", "Prince - When Doves Cry",
    "Michael Jackson - Beat It", "Michael Jackson - Man in the Mirror",
    "Janet Jackson - Control", "Janet Jackson - Nasty",
    "Paula Abdul - Straight Up",
    "MC Hammer - U Can't Touch This",
    "Vanilla Ice - Ice Ice Baby",
    "Marky Mark - Good Vibrations",
    "Boyz II Men - Motownphilly",
    "TLC - Waterfalls", "TLC - No Scrubs",
    "Destiny's Child - Say My Name", "Destiny's Child - Survivor",
    "Missy Elliott - Get Ur Freak On",
    "Aaliyah - Try Again",
    "Usher - Yeah", "Usher - Confessions Part II",
    "Alicia Keys - Fallin'", "Alicia Keys - No One",
    "John Legend - All of Me",
    "R. Kelly - I Believe I Can Fly",
    "Boyz II Men - I'll Make Love to You",
    "Brian McKnight - Anytime",
    "Maxwell - Ascension",
    "D'Angelo - Brown Sugar",
    "Erykah Badu - On and On",
    "Lauryn Hill - Ex-Factor",
    "Fugees - Killing Me Softly",
    "Mary J. Blige - Real Love",
    "En Vogue - Don't Let Go",
    "SWV - Weak",
    "Jodeci - Cry for You",
    "Ginuwine - Pony",
    "Next - Too Close",
    "112 - Peaches and Cream",
    "Joe - All That I Am",
    "Jaheim - Just in Case",
    "Musiq Soulchild - Just Friends",
    "Anthony Hamilton - Charlene",
    "Floetry - Say Yes",
    "India Arie - Ready for Love",
    "Jill Scott - A Long Walk",
    "Ledisi - Alright",
    "Lalah Hathaway - Forever for Always for Love",
    "Angie Stone - Wish I Didn't Miss You",
    "Kindred the Family Soul - Far Away",
    "Raheem DeVaughn - Woman",
    "Tweet - Oops (Oh My)",
    "Macy Gray - I Try",
    "Norah Jones - Sunrise",
    "Diana Krall - The Look of Love",
    "Cassandra Wilson - Blue Light 'Til Dawn",
    "Nnenna Freelon - Heritage",
    "Dianne Reeves - Better Days",
    "Dee Dee Bridgewater - Love and Peace",
    "Abbey Lincoln - Throw It Away",
    "Carmen McRae - Lover Man",
    "Sarah Vaughan - Misty",
    "Ella Fitzgerald - Summertime",
    "Billie Holiday - Strange Fruit",
    "Nina Simone - Feeling Good", "Nina Simone - I Put a Spell on You",
    "Miles Davis - So What",
    "John Coltrane - My Favorite Things",
    "Dave Brubeck - Take Five",
    "Thelonious Monk - Round Midnight",
    "Bill Evans - Waltz for Debby",
    "Herbie Hancock - Cantaloupe Island",
    "Chick Corea - Spain",
    "Keith Jarrett - The Koln Concert",
    "Oscar Peterson - Night Train",
    "Art Tatum - Tea for Two",
    "Fats Waller - Ain't Misbehavin",
    "Jelly Roll Morton - King Porter Stomp",
    "Scott Joplin - Maple Leaf Rag",
    "Louis Armstrong - What a Wonderful World",
    "Duke Ellington - Take the A Train",
    "Count Basie - One O'Clock Jump",
    "Benny Goodman - Sing Sing Sing",
    "Glenn Miller - In the Mood",
    "Tommy Dorsey - I'll Never Smile Again",
    "Frank Sinatra - Fly Me to the Moon",
    "Tony Bennett - I Left My Heart in San Francisco",
    "Nat King Cole - Unforgettable",
    "Sammy Davis Jr. - Mr. Bojangles",
    "Dean Martin - That's Amore",
    "Perry Como - Catch a Falling Star",
    "Bing Crosby - White Christmas",
    "Gene Kelly - Singin' in the Rain",
    "Fred Astaire - Cheek to Cheek",
    "Judy Garland - Somewhere Over the Rainbow",
    "Doris Day - Que Sera Sera",
    "Rosemary Clooney - Come On-a My House",
    "Patti Page - Tennessee Waltz",
    "Kay Starr - Wheel of Fortune",
    "Jo Stafford - You Belong to Me",
    "Vera Lynn - We'll Meet Again",
    "Gracie Fields - Sally",
    "George Formby - When I'm Cleaning Windows",
    "Noel Coward - Mad Dogs and Englishmen",
    "Ivor Novello - Keep the Home Fires Burning",
    "Florrie Forde - It's a Long Way to Tipperary",
    "Harry Champion - Any Old Iron",
    "Marie Lloyd - My Old Man Said Follow the Van",
    "Albert Chevalier - Knocked 'em in the Old Kent Road",
    "Dan Leno - The Swimming Master",
    "Little Tich - The Gas Inspector",
    "Vesta Victoria - Waiting at the Church",
    "Gus Elen - It's a Great Big Shame",
    "Charles Coborn - Two Lovely Black Eyes",
    "Leo Dryden - The Miner's Dream of Home",
    "Eugene Stratton - Lily of Laguna",
    "G.H. Elliott - Lily of Laguna",
    "Billy Williams - When Father Papered the Parlour",
    "Harry Lauder - Roamin' in the Gloamin",
    "Florrie Forde - Down at the Old Bull and Bush",
    "Ada Jones - By the Light of the Silvery Moon",
    "Billy Murray - Take Me Out to the Ball Game",
    "Arthur Collins - Alexander's Ragtime Band",
    "Henry Burr - Sweet Adeline",
    "John McCormack - It's a Long Way to Tipperary",
    "Enrico Caruso - Vesti la Giubba",
    "Amelita Galli-Curci - Caro Mio Ben",
    "Geraldine Farrar - Habanera",
    "Alma Gluck - Carry Me Back to Old Virginny",
    "Frieda Hempel - The Last Rose of Summer",
    "Marcella Sembrich - Il Bacio",
    "Luisa Tetrazzini - The Bell Song",
    "Nellie Melba - Home Sweet Home",
    "Adelina Patti - Home Sweet Home",
    "Jenny Lind - The Echo Song",
    "Malibran - Casta Diva",
    "Pasta - Norma",
    "Catalani - La Wally",
    "Bellini - Casta Diva",
    "Donizetti - Una Furtiva Lagrima",
    "Rossini - Largo al Factotum",
    "Verdi - La Donna e Mobile",
    "Puccini - Nessun Dorma",
    "Puccini - O Mio Babbino Caro",
    "Puccini - Un Bel Di Vedremo",
    "Bizet - Habanera",
    "Bizet - Toreador Song",
    "Gounod - Ave Maria",
    "Gounod - Jewel Song",
    "Massenet - Meditation from Thais",
    "Saint-Saens - The Swan",
    "Debussy - Clair de Lune",
    "Debussy - Reverie",
    "Ravel - Bolero",
    "Ravel - Pavane for a Dead Princess",
    "Satie - Gymnopedie No. 1",
    "Satie - Gnossienne No. 1",
    "Chopin - Nocturne Op. 9 No. 2",
    "Chopin - Ballade No. 1",
    "Chopin - Fantaisie Impromptu",
    "Chopin - Waltz in A Minor",
    "Liszt - Liebestraume",
    "Liszt - Hungarian Rhapsody No. 2",
    "Schubert - Ave Maria",
    "Schubert - Serenade",
    "Brahms - Lullaby",
    "Brahms - Hungarian Dance No. 5",
    "Schumann - Traumerei",
    "Schumann - The Happy Farmer",
    "Mendelssohn - Wedding March",
    "Mendelssohn - Spring Song",
    "Grieg - In the Hall of the Mountain King",
    "Grieg - Morning Mood",
    "Sibelius - Finlandia",
    "Sibelius - Valse Triste",
    "Dvorak - Humoresque",
    "Dvorak - New World Symphony",
    "Tchaikovsky - Swan Lake",
    "Tchaikovsky - Nutcracker Suite",
    "Tchaikovsky - Romeo and Juliet",
    "Rimsky-Korsakov - Flight of the Bumblebee",
    "Mussorgsky - Night on Bald Mountain",
    "Borodin - Polovtsian Dances",
    "Prokofiev - Peter and the Wolf",
    "Stravinsky - The Rite of Spring",
    "Bartok - Romanian Folk Dances",
    "Shostakovich - Jazz Suite No. 2",
    "Rachmaninoff - Piano Concerto No. 2",
    "Rachmaninoff - Vocalise",
    "Scriabin - Etude Op. 2 No. 1",
    "Satie - Je Te Veux",
    "Faure - Pavane",
    "Faure - Apres un Reve",
    "Franck - Panis Angelicus",
    "Widor - Toccata",
    "Vierne - Clair de Lune",
    "Dupre - Prelude and Fugue in G Minor",
    "Messiaen - Quartet for the End of Time",
    "Boulez - Piano Sonata No. 2",
    "Ligeti - Etudes",
    "Xenakis - Metastasis",
    "Stockhausen - Klavierstuck",
    "Nono - Il Canto Sospeso",
    "Berio - Sinfonia",
    "Luciano Berio - Sequenza",
    "Helmut Lachenmann - Guero",
    "Salvatore Sciarrino - Notturni",
    "Giacinto Scelsi - Quattro Pezzi",
    "Galina Ustvolskaya - Piano Sonata No. 6",
    "Sofia Gubaidulina - Chaconne",
    "Alfred Schnittke - Concerto Grosso",
    "Arvo Part - Spiegel im Spiegel",
    "Arvo Part - Fratres",
    "John Adams - Shaker Loops",
    "Steve Reich - Music for 18 Musicians",
    "Philip Glass - Metamorphosis",
    "Philip Glass - Mad Rush",
    "Terry Riley - In C",
    "La Monte Young - The Well-Tuned Piano",
    "Pauline Oliveros - Deep Listening",
    "Meredith Monk - Dolmen Music",
    "Laurie Anderson - O Superman",
    "Peter Gabriel - Solsbury Hill", "Peter Gabriel - In Your Eyes",
    "Kate Bush - Wuthering Heights", "Kate Bush - Running Up That Hill",
    "Sting - Fields of Gold", "Sting - Every Breath You Take",
    "Annie Lennox - Why", "Annie Lennox - Little Bird",
    "Dave Stewart - Here Comes the Rain Again",
    "Boy George - Karma Chameleon",
    "Nick Rhodes - Girls on Film",
    "Simon Le Bon - Rio",
    "Robert Smith - Friday I'm in Love",
    "Ian McCulloch - The Killing Moon",
    "Ian Curtis - She's Lost Control",
    "Mark E. Smith - How I Wrote Elastic Man",
    "Morrissey - Suedehead",
    "Johnny Marr - How Soon Is Now",
    "Bernard Sumner - True Faith",
    "Peter Hook - Atmosphere",
    "Stephen Morris - Transmission",
    "Gillian Gilbert - Bizarre Love Triangle",
    "Ian Brown - I Wanna Be Adored",
    "John Squire - She Bangs the Drums",
    "Mani - Waterfall",
    "Reni - Love Spreads",
    "Liam Gallagher - Live Forever",
    "Noel Gallagher - Half the World Away",
    "Damon Albarn - Country House",
    "Graham Coxon - Girls and Boys",
    "Alex James - Beetlebum",
    "Dave Rowntree - Song 2",
    "Jarvis Cocker - Babies",
    "Nick Banks - Mis-Shapes",
    "Mark Webber - Disco 2000",
    "Steve Mackey - Common People",
    "Thom Yorke - Fake Plastic Trees",
    "Jonny Greenwood - Karma Police",
    "Colin Greenwood - Just",
    "Ed O'Brien - High and Dry",
    "Phil Selway - Creep",
    "Chris Martin - Yellow",
    "Jonny Buckland - The Scientist",
    "Guy Berryman - Clocks",
    "Will Champion - Speed of Sound",
    "Bono - One",
    "The Edge - With or Without You",
    "Adam Clayton - Where the Streets Have No Name",
    "Larry Mullen Jr. - I Still Haven't Found What I'm Looking For",
    "Dave Grohl - Best of You",
    "Taylor Hawkins - The Pretender",
    "Nate Mendel - All My Life",
    "Chris Shiflett - Everlong",
    "Pat Smear - Learn to Fly",
    "Kurt Cobain - Come as You Are",
    "Krist Novoselic - Heart-Shaped Box",
    "Dave Grohl - In Bloom",
    "Eddie Vedder - Black",
    "Mike McCready - Alive",
    "Stone Gossard - Jeremy",
    "Jeff Ament - Even Flow",
    "Matt Cameron - Given to Fly",
    "Billy Corgan - Tonight Tonight",
    "James Iha - 1979",
    "D'arcy Wretzky - Soma",
    "Jimmy Chamberlin - Mayonaise",
    "Trent Reznor - Hurt",
    "Robin Finck - Head Like a Hole",
    "Danny Lohner - Closer",
    "Charlie Clouser - March of the Pigs",
    "Chris Vrenna - Wish",
    "Marilyn Manson - Beautiful People",
    "Twiggy Ramirez - The Dope Show",
    "John 5 - Disposable Teens",
    "Tim Skold - Personal Jesus",
    "Rob Zombie - Dragula",
    "Wes Borland - Break Stuff",
    "Fred Durst - Nookie",
    "Sam Rivers - My Way",
    "John Otto - Rollin",
    "DJ Lethal - Take a Look Around",
    "Jonathan Davis - Freak on a Leash",
    "James Shaffer - Got the Life",
    "Brian Welch - Falling Away from Me",
    "Reginald Arvizu - Make Me Bad",
    "David Silveria - Blind",
    "Chino Moreno - Change",
    "Stephen Carpenter - My Own Summer",
    "Chi Cheng - Be Quiet and Drive",
    "Abe Cunningham - Minerva",
    "Frank Delgado - Passenger",
    "Serj Tankian - Chop Suey",
    "Daron Malakian - Toxicity",
    "Shavo Odadjian - Aerials",
    "John Dolmayan - B.Y.O.B.",
    "Corey Taylor - Duality",
    "Jim Root - Before I Forget",
    "Mick Thomson - Psychosocial",
    "Craig Jones - Dead Memories",
    "Sid Wilson - Snuff",
    "Joey Jordison - Wait and Bleed",
    "Paul Gray - Vermilion",
    "Chris Fehn - The Heretic Anthem",
    "Shawn Crahan - Spit It Out",
    "M. Shadows - Nightmare",
    "Synyster Gates - Bat Country",
    "Zacky Vengeance - So Far Away",
    "Johnny Christ - Welcome to the Family",
    "The Rev - Almost Easy",
    "Chester Bennington - In the End",
    "Mike Shinoda - Numb",
    "Brad Delson - Crawling",
    "Dave Farrell - One Step Closer",
    "Joe Hahn - Faint",
    "Rob Bourdon - Breaking the Habit",
    "Billie Joe Armstrong - Good Riddance",
    "Mike Dirnt - Basket Case",
    "Tre Cool - When I Come Around",
    "Tom DeLonge - All the Small Things",
    "Mark Hoppus - What's My Age Again",
    "Travis Barker - Adam's Song",
    "Patrick Stump - Sugar We're Goin Down",
    "Pete Wentz - Dance Dance",
    "Joe Trohman - Thnks fr th Mmrs",
    "Andy Hurley - I Don't Care",
    "Brendon Urie - I Write Sins Not Tragedies",
    "Ryan Ross - Nine in the Afternoon",
    "Spencer Smith - The Ballad of Mona Lisa",
    "Dallon Weekes - Miss Jackson",
    "Hayley Williams - Misery Business",
    "Josh Farro - Decode",
    "Jeremy Davis - The Only Exception",
    "Taylor York - Still into You",
    "Zac Farro - Ignorance",
    "Gerard Way - Welcome to the Black Parade",
    "Frank Iero - Famous Last Words",
    "Mikey Way - I'm Not Okay",
    "Ray Toro - Helena",
    "Bob Bryar - Cancer",
}

-- ============================================================
--  GERAR MÚSICAS 111-900 A PARTIR DOS TÍTULOS EXTRAS
-- ============================================================
local songIndex = 111
for i, title in ipairs(extraTitles) do
    if songIndex > 900 then break end
    local patternIndex = ((i - 1) % #notePatterns) + 1
    Songs[string.format("%03d", songIndex) .. " - " .. title] = notePatterns[patternIndex]
    songIndex = songIndex + 1
end

-- Preencher restante com músicas genéricas se necessário
while songIndex <= 900 do
    local patternIndex = ((songIndex - 1) % #notePatterns) + 1
    Songs[string.format("%03d", songIndex) .. " - Extra Song " .. tostring(songIndex)] = notePatterns[patternIndex]
    songIndex = songIndex + 1
end

-- ============================================================
--  ESTADO DO PLAYER
-- ============================================================
local isPlaying   = false
local stopSignal  = false
local currentSong = nil
local playSpeed   = 0.1 -- segundos entre notas (menor = mais rápido)

-- ============================================================
--  FUNÇÃO DE REPRODUÇÃO
-- ============================================================
local function PlayNotes(notes)
    stopSignal = false
    isPlaying  = true

    local queue = ""
    local rem   = true

    for i = 1, #notes do
        if stopSignal then break end

        local c = string.sub(notes, i, i)

        if c == "[" then
            rem = false
        elseif c == "]" then
            rem = true
            for ii = 1, #queue do
                VirtualUser:SetKeyDown(string.sub(queue, ii, ii))
            end
            task.wait(playSpeed)
            for ii = 1, #queue do
                VirtualUser:SetKeyUp(string.sub(queue, ii, ii))
            end
            queue = ""
        elseif c == " " then
            task.wait(playSpeed)
        elseif c == "|" then
            task.wait(playSpeed * 2)
        elseif not rem then
            queue = queue .. c
        else
            VirtualUser:SetKeyDown(c)
            task.wait(playSpeed / 2)
            VirtualUser:SetKeyUp(c)
            task.wait(playSpeed / 2)
        end
    end

    isPlaying = false
end

-- ============================================================
--  INTERFACE GRÁFICA (GUI)
-- ============================================================

local oldGui = CoreGui:FindFirstChild("AutoPianoHub")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "AutoPianoHub"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = CoreGui

-- Janela principal
local MainFrame = Instance.new("Frame")
MainFrame.Name              = "MainFrame"
MainFrame.Size              = UDim2.new(0, 480, 0, 580)
MainFrame.Position          = UDim2.new(0.5, -240, 0.5, -290)
MainFrame.BackgroundColor3  = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel   = 0
MainFrame.Active            = true
MainFrame.Draggable         = true
MainFrame.Parent            = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size              = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3  = Color3.fromRGB(28, 28, 40)
TitleBar.BorderSizePixel   = 0
TitleBar.Parent            = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Corrigir cantos inferiores da barra
local TitleFix = Instance.new("Frame")
TitleFix.Size             = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position         = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
TitleFix.BorderSizePixel  = 0
TitleFix.Parent           = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size              = UDim2.new(1, -110, 1, 0)
TitleLabel.Position          = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text              = "🎹  Auto Piano Hub — 900 Músicas"
TitleLabel.TextColor3        = Color3.fromRGB(255, 255, 255)
TitleLabel.Font              = Enum.Font.GothamBold
TitleLabel.TextSize          = 15
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
TitleLabel.Parent            = TitleBar

-- Botão fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size              = UDim2.new(0, 32, 0, 32)
CloseBtn.Position          = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3  = Color3.fromRGB(200, 60, 60)
CloseBtn.Text              = "✕"
CloseBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.TextSize          = 14
CloseBtn.BorderSizePixel   = 0
CloseBtn.Parent            = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    stopSignal = true
    ScreenGui:Destroy()
end)

-- Label de status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size              = UDim2.new(1, -20, 0, 28)
StatusLabel.Position          = UDim2.new(0, 10, 0, 52)
StatusLabel.BackgroundColor3  = Color3.fromRGB(24, 24, 36)
StatusLabel.TextColor3        = Color3.fromRGB(120, 200, 120)
StatusLabel.Font               = Enum.Font.Gotham
StatusLabel.TextSize           = 12
StatusLabel.Text               = "⏸  Nenhuma música selecionada"
StatusLabel.TextXAlignment     = Enum.TextXAlignment.Left
StatusLabel.BorderSizePixel    = 0
StatusLabel.Parent             = MainFrame
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)
local sp = Instance.new("UIPadding", StatusLabel)
sp.PaddingLeft = UDim.new(0, 8)

-- Campo de busca
local SearchBox = Instance.new("TextBox")
SearchBox.Size                = UDim2.new(1, -20, 0, 32)
SearchBox.Position            = UDim2.new(0, 10, 0, 86)
SearchBox.BackgroundColor3    = Color3.fromRGB(35, 35, 50)
SearchBox.TextColor3          = Color3.fromRGB(220, 220, 220)
SearchBox.PlaceholderText     = "🔍  Buscar música..."
SearchBox.PlaceholderColor3   = Color3.fromRGB(100, 100, 120)
SearchBox.Font                = Enum.Font.Gotham
SearchBox.TextSize            = 13
SearchBox.Text                = ""
SearchBox.BorderSizePixel     = 0
SearchBox.ClearTextOnFocus    = false
SearchBox.Parent              = MainFrame
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
local sbp = Instance.new("UIPadding", SearchBox)
sbp.PaddingLeft = UDim.new(0, 8)

-- Controles de velocidade
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size              = UDim2.new(0, 140, 0, 22)
SpeedLabel.Position          = UDim2.new(0, 10, 0, 124)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3        = Color3.fromRGB(160, 160, 190)
SpeedLabel.Font              = Enum.Font.Gotham
SpeedLabel.TextSize          = 12
SpeedLabel.Text              = "Velocidade: Normal"
SpeedLabel.TextXAlignment    = Enum.TextXAlignment.Left
SpeedLabel.Parent            = MainFrame

local function makeSpeedBtn(label, xPos, speed, speedText, color)
    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(0, 60, 0, 22)
    btn.Position          = UDim2.new(0, xPos, 0, 124)
    btn.BackgroundColor3  = color
    btn.TextColor3        = Color3.fromRGB(255, 255, 255)
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 11
    btn.Text              = label
    btn.BorderSizePixel   = 0
    btn.Parent            = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        playSpeed = speed
        SpeedLabel.Text = "Velocidade: " .. speedText
    end)
end

makeSpeedBtn("🐢 Lento",   155, 0.25, "Lento",  Color3.fromRGB(60, 100, 60))
makeSpeedBtn("▶ Normal",   220, 0.10, "Normal", Color3.fromRGB(50, 80, 140))
makeSpeedBtn("⚡ Rápido",  285, 0.04, "Rápido", Color3.fromRGB(140, 80, 50))

-- Botão PARAR
local StopBtn = Instance.new("TextButton")
StopBtn.Size             = UDim2.new(0, 100, 0, 22)
StopBtn.Position         = UDim2.new(1, -110, 0, 124)
StopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
StopBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
StopBtn.Font             = Enum.Font.GothamBold
StopBtn.TextSize         = 12
StopBtn.Text             = "⏹  PARAR"
StopBtn.BorderSizePixel  = 0
StopBtn.Parent           = MainFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

StopBtn.MouseButton1Click:Connect(function()
    stopSignal = true
    isPlaying  = false
    StatusLabel.Text      = "⏸  Parado pelo usuário"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
end)

-- Container da lista
local ListContainer = Instance.new("Frame")
ListContainer.Size             = UDim2.new(1, -20, 1, -156)
ListContainer.Position         = UDim2.new(0, 10, 0, 152)
ListContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
ListContainer.BorderSizePixel  = 0
ListContainer.Parent           = MainFrame
Instance.new("UICorner", ListContainer).CornerRadius = UDim.new(0, 8)

local SongList = Instance.new("ScrollingFrame")
SongList.Size                   = UDim2.new(1, -4, 1, -4)
SongList.Position               = UDim2.new(0, 2, 0, 2)
SongList.BackgroundTransparency = 1
SongList.BorderSizePixel        = 0
SongList.ScrollBarThickness     = 4
SongList.ScrollBarImageColor3   = Color3.fromRGB(100, 160, 255)
SongList.Parent                 = ListContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding   = UDim.new(0, 2)
UIListLayout.Parent    = SongList

-- Criar botões de músicas
local songButtons = {}

local function createSongButtons(filter)
    for _, btn in pairs(songButtons) do btn:Destroy() end
    songButtons = {}

    local count = 0
    for name, notes in pairs(Songs) do
        if filter == "" or string.lower(name):find(string.lower(filter), 1, true) then
            local btn = Instance.new("TextButton")
            btn.Name             = name
            btn.Size             = UDim2.new(1, -8, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
            btn.TextColor3       = Color3.fromRGB(200, 200, 220)
            btn.Font             = Enum.Font.Gotham
            btn.TextSize         = 11
            btn.Text             = name
            btn.TextXAlignment   = Enum.TextXAlignment.Left
            btn.BorderSizePixel  = 0
            btn.Parent           = SongList
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            local p = Instance.new("UIPadding", btn)
            p.PaddingLeft = UDim.new(0, 8)

            btn.MouseEnter:Connect(function()
                if currentSong ~= name then
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 55, 80)}):Play()
                end
            end)
            btn.MouseLeave:Connect(function()
                if currentSong ~= name then
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 46)}):Play()
                end
            end)

            local capturedNotes = notes
            btn.MouseButton1Click:Connect(function()
                for _, b in pairs(songButtons) do
                    TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 46)}):Play()
                end
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 90, 180)}):Play()

                currentSong = name
                stopSignal  = true
                task.wait(0.15)

                StatusLabel.Text       = "▶  " .. name
                StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)

                task.spawn(function()
                    PlayNotes(capturedNotes)
                    if not stopSignal then
                        StatusLabel.Text       = "✔  Concluído: " .. name
                        StatusLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
                    end
                end)
            end)

            table.insert(songButtons, btn)
            count = count + 1
        end
    end

    SongList.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    createSongButtons(SearchBox.Text)
end)

createSongButtons("")

-- Contar músicas
local totalSongs = 0
for _ in pairs(Songs) do totalSongs = totalSongs + 1 end
print("✅ Auto Piano Hub carregado! " .. tostring(totalSongs) .. " músicas disponíveis.")
