local rightPanelX = 283;
local rightPanelY = 1187;

local m_s_panel = gfx.CreateSkinImage("multi/lobby/song_panel.png", 1);

local Info = {
    Song = {
        NoSong   = "NO SONG",
        MisSong  = "MISSING SONG!!!!"
    },
    Artist = {
        NoArt    = "NO ARTIST",
        MisArt   = "MISSING ARTIST!!!!"
    },
    Effect = {
        NoEfc   = "NO EFFECTOR",
        MisEfc   = "MISSING EFFECTOR!!!!"
    },
    Illustrator = {
        NoIlt   = "NO ILLUSTRATOR",
        MisIlt   = "MISSING ILLUSTRATOR!!!!"
    },
    Bpm = {
        HasBpm  = "BPM",
        NoBpm   = "BPM    ?",
    },
}

local m_s_part = function ()
    local jw , jh = gfx.ImageSize(m_s_panel);
    gfx.BeginPath();
    gfx.ImageRect(rightPanelX, rightPanelY, jw/1.175, jh/1.18, m_s_panel,1,0);

    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_LEFT);
    gfx.FillColor(255,255,255)
    
    gfx.FontSize(32)
    if selected_song == nil then
        if host == user_id then
                    gfx.Text(Info.Song.NoSong, rightPanelX+245, rightPanelY+50)
                    gfx.Text(Info.Artist.NoArt, rightPanelX+245, rightPanelY+88)
                gfx.FontSize(24)
                    gfx.Text(Info.Effect.NoEfc, rightPanelX+463, rightPanelY+191)
                    gfx.Text(Info.Illustrator.NoIlt, rightPanelX+463, rightPanelY+219)
                gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
                    gfx.FontSize(22)
                    gfx.Text(Info.Bpm.NoBpm,rightPanelX+497, rightPanelY+118)
        else
            if missing_song then
                    gfx.Text(Info.Song.MisSong, rightPanelX+245, rightPanelY+50)
                    gfx.Text(Info.Artist.MisArt, rightPanelX+245, rightPanelY+88)
                gfx.FontSize(24)
                    gfx.Text(Info.Effect.MisEfc, rightPanelX+463, rightPanelY+191)
                    gfx.Text(Info.Illustrator.MisIlt, rightPanelX+463, rightPanelY+219)
            end
            --[[           
                else
                    gfx.Text("HOST IS SELECTING SONG", rightPanelX+245, rightPanelY+50)
                    gfx.Text(" ", rightPanelX+245, rightPanelY+88)
                gfx.FontSize(24)
                    gfx.Text(" ", rightPanelX+463, rightPanelY+191)
                    gfx.Text(" ", rightPanelX+463, rightPanelY+219)
                gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
                    gfx.FontSize(22)
                    gfx.Text("BPM    ?",rightPanelX+497, rightPanelY+118)]]
        end
    else
        if selected_song.min_bpm ~= selected_song.max_bpm then
            gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
            gfx.FontSize(22);  
            gfx.Text(Info.Bpm.HasBpm,rightPanelX+497, rightPanelY+118)
            gfx.FontSize(26);
            gfx.Text(string.format("%.0f - %.0f",
                selected_song.min_bpm, selected_song.max_bpm),
                rightPanelX+497 + 77, rightPanelY+118)
        else
            gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
            gfx.FontSize(22);
            gfx.Text(Info.Bpm.HasBpm,rightPanelX+497, rightPanelY+118)
            gfx.Text(string.format("%.0f",
                selected_song.min_bpm),
                rightPanelX+497 + 77, rightPanelY+118)
        end
        gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_LEFT);
        gfx.FontSize(32);
        gfx.Text(selected_song.title, rightPanelX+245, rightPanelY+50)
        gfx.Text(selected_song.artist, rightPanelX+245, rightPanelY+88)
        gfx.FontSize(24)
        gfx.Text(selected_song.effector, rightPanelX+463, rightPanelY+191)
        gfx.Text(selected_song.illustrator, rightPanelX+463, rightPanelY+219)
        draw_diffs(selected_song.all_difficulties, 395, 205, 300, 100, selected_song.diff_index+1)
    end
end

return m_s_part