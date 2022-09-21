local jacketPanelX = 333;
local jacketPanelY = 1284;

local jacket = 0;
local m_jacket = gfx.CreateSkinImage("multi/lobby/multi_jacket.png", 1);
local placeholderJacket = gfx.CreateSkinImage("song_select/loading.png", 0)

local songjacket = function()

    if selected_song == nil then
        if jacket == 0 then
            jacket = placeholderJacket
        end
    else
        if selected_song.jacket == nil or selected_song.jacket == placeholderJacket then
            selected_song.jacket = gfx.LoadImageJob(selected_song.jacketPath, placeholderJacket)
            jacket = selected_song.jacket
        end
    end

    local jw , jh = gfx.ImageSize(m_jacket);
    gfx.BeginPath();
    gfx.ImageRect(jacketPanelX, jacketPanelY, jw/1.18, jh/1.18, m_jacket,1,0);

    gfx.BeginPath()
    gfx.ImageRect(jacketPanelX+12, jacketPanelY+19,jw/1.269,jh/1.35,jacket,1,0)

    if mouse_clipped(jacketPanelX+12, jacketPanelY+19,jw/1.269,jh/1.35) and host == user_id then
        hovered = function() 
            missing_song = false
            mpScreen.SelectSong()
        end
    end

end

return songjacket