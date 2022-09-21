local badges = game.GetSkinSetting("badges")

local none = gfx.CreateSkinImage("dan/none.png",1)

dan = {
        gfx.CreateSkinImage("dan/SKILLED.png",1),
        gfx.CreateSkinImage("dan/EXPERT.png",1),
        gfx.CreateSkinImage("dan/EXPERT (MASTERY).png",1),
        gfx.CreateSkinImage("dan/LOWER PRO.png",1),
        gfx.CreateSkinImage("dan/LOWER PRO (MASTERY).png",1),
        gfx.CreateSkinImage("dan/UPPER PRO.png",1),
        gfx.CreateSkinImage("dan/UPPER PRO (MASTERY).png",1),
        gfx.CreateSkinImage("dan/LOWER MASTER.png",1),
        gfx.CreateSkinImage("dan/LOWER MASTER (MASTERY).png",1),
        gfx.CreateSkinImage("dan/UPPER MASTER.png",1),
        gfx.CreateSkinImage("dan/UPPER MASTER (MASTERY).png",1),
        gfx.CreateSkinImage("dan/GRANDMASTER.png",1),
        gfx.CreateSkinImage("dan/GRANDMASTER+.png",1),
}

local badger = function (yes)
    if badges == "NONE" or yes == true then
        danbadge = none

elseif badges == "SKILLED" then
        danbadge = dan[1]

elseif badges == "EXPERT" then
        danbadge = dan[2]

elseif badges == "EXPERT (MASTERY)" then
        danbadge = dan[3]

elseif badges == "LOWER PRO" then
        danbadge = dan[4]

elseif badges == "LOWER PRO (MASTERY)" then
        danbadge = dan[5]

elseif badges == "UPPER PRO" then
        danbadge = dan[6]

elseif badges == "UPPER PRO (MASTERY)" then
        danbadge = dan[7]

elseif badges == "LOWER MASTER" then
        danbadge = dan[8]

elseif badges == "LOWER MASTER (MASTERY)" then
        danbadge = dan[9]

elseif badges == "UPPER MASTER" then
        danbadge = dan[10]
 
elseif badges == "UPPER MASTER (MASTERY)" then
        danbadge = dan[11]

elseif badges == "GRANDMASTER" then
        danbadge = dan[12]

elseif badges == "GRANDMASTER+" then
        danbadge = dan[13]

    end
    return danbadge
end



return badger