-- add your name and friends in here but keep the default!!! --
-- all the "*" comments will be noted up here in order

--[[
    0* = !!ALLWAYS!! the same Name as the Name from "1*"
    1* = You/You're Friends Name belongs in the section (pls limit to 8 Characters otherwise it look weird)
    2* = You/You're Friends Message belongs in the section (same Characters limit then "1*")
    3* = You/You're Friends VolForce amount (pls be accurate to what You/Friends VolForce amount is to make the next steps look weird)
    4* = Volforce Rank as a number is put in the bracket of vorce[ ] (from 1 to 10)
    5* = Number value is either 1 ="silver" or 2 = "gold" depending on 4*
    6* = from 1 to 4 put the number of stars depending on 3*(the LINK on it helps)
    7* = same as you did with 4* but with range (1 to 13) if not wantint to use any badge set it to dan.none
    8* = the only thing that needs to be changed is the "default" to the name according name from 0*/1*
    9* = same as 8*
]]

-- !!!! if 0* IS MISSPELLED the game wont like it and goes FALLBACK and or CRASHES !!!! --

-- You can copie this into " local name = {} in line "69" after the default one " --
--[[
    CustomName = {                                                               
        name       = "CustomName", -- This will be asked in the code so keep the same as the line above
        msg        = "CustomMeassge",
        vf         = 0.000,
        vf_image   = vorce[1],
        star_type  = 1,
        star_count = 1,
        badge      = dan["none"],
        portrait   = gfx.CreateSkinImage(player_folder_path .. "CustomName" .. portait, 1),
        appeal     = gfx.CreateSkinImage(player_folder_path .. "CustomName" .. appeal, 1)
    },
]]

local player_folder_path = "multi/players/"
local portait = "/portrait.png"
local appeal = "/appeal_card.png"

local vorce = {
    gfx.CreateSkinImage("volforce/1.png", 0),
    gfx.CreateSkinImage("volforce/2.png", 0),
    gfx.CreateSkinImage("volforce/3.png", 0),
    gfx.CreateSkinImage("volforce/4.png", 0),
    gfx.CreateSkinImage("volforce/5.png", 0),
    gfx.CreateSkinImage("volforce/6.png", 0),
    gfx.CreateSkinImage("volforce/7.png", 0),
    gfx.CreateSkinImage("volforce/8.png", 0),
    gfx.CreateSkinImage("volforce/9.png", 0),
    gfx.CreateSkinImage("volforce/10.png", 0),
}

local dan = {
    none = gfx.CreateSkinImage("dan/none.png", 1),
    gfx.CreateSkinImage("dan/SKILLED.png", 1),
    gfx.CreateSkinImage("dan/EXPERT.png", 1),
    gfx.CreateSkinImage("dan/EXPERT (MASTERY).png", 1),
    gfx.CreateSkinImage("dan/LOWER PRO.png", 1),
    gfx.CreateSkinImage("dan/LOWER PRO (MASTERY).png", 1),
    gfx.CreateSkinImage("dan/UPPER PRO.png", 1),
    gfx.CreateSkinImage("dan/UPPER PRO (MASTERY).png", 1),
    gfx.CreateSkinImage("dan/LOWER MASTER.png", 1),
    gfx.CreateSkinImage("dan/LOWER MASTER (MASTERY).png", 1),
    gfx.CreateSkinImage("dan/UPPER MASTER.png", 1),
    gfx.CreateSkinImage("dan/UPPER MASTER (MASTERY).png", 1),
    gfx.CreateSkinImage("dan/GRANDMASTER.png", 1),
    gfx.CreateSkinImage("dan/GRANDMASTER+.png", 1),
}

local list = {
    Player = {
        name       = "Player",
        msg        = "",
        vf         = 0.000,
        vf_image   = vorce[1],
        star_type  = 1,
        star_count = 1,
        badge      = dan["none"],
        portrait   = gfx.CreateSkinImage(player_folder_path .. "Player" .. portait, 1),
        appeal     = gfx.CreateSkinImage(player_folder_path .. "Player" .. appeal, 1)
    },
    RealFD = {
        name       = "RealFD",
        msg        = "SkinDev",
        vf         = 17.089,
        vf_image   = vorce[7],
        star_type  = 2,
        star_count = 1,
        badge      = dan[3],
        portrait   = gfx.CreateSkinImage(player_folder_path .. "RealFD" .. portait, 1),
        appeal     = gfx.CreateSkinImage(player_folder_path .. "RealFD" .. appeal, 1)
    },

}

return list
