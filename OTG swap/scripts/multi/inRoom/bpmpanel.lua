local bpmPanelX = 0;
local bpmPanelY = 1692;

local m_bpm_panel = gfx.CreateSkinImage("multi/lobby/lane_speed_panel.png", 1);

local Info = {
    Bpm = {
        HasBpm  = "BPM",
        NoBpm   = "BPM    ?",
    },
    LN = {
        HasLN   = "LANE-SPEED",
        NoLV    = "LANE-SPEED    ?",
    }
}

local m_bpm_part = function ()
    local jw , jh = gfx.ImageSize(m_bpm_panel);
    gfx.BeginPath();
    gfx.ImageRect(bpmPanelX, bpmPanelY, jw/1.18, jh/1.18, m_bpm_panel,1,0);

    gfx.FontSize(32)
    if selected_song == nil then
        if host == user_id then
            gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
                gfx.FontSize(32)
                    gfx.Text(Info.Bpm.NoBpm,bpmPanelX+76, bpmPanelY + 96)
                    gfx.Text(Info.LN.NoLV,bpmPanelX+76, bpmPanelY + 140)
        else
            if missing_song then
                gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
                gfx.FontSize(32)
                    gfx.Text(Info.Bpm.NoBpm,bpmPanelX+76, bpmPanelY + 96)
                    gfx.Text(Info.LN.NoLV,bpmPanelX+76, bpmPanelY + 140)
            else
                gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
                gfx.FontSize(32)
                    gfx.Text(Info.Bpm.NoBpm,bpmPanelX+76, bpmPanelY + 96)
                    gfx.Text(Info.LN.NoLV,bpmPanelX+76, bpmPanelY + 140)
            end
        end
    end
    if selected_song ~= nil then
        gfx.FillColor(255,255,255)
        gfx.FontSize(32);
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)

        if selected_song.min_bpm ~= selected_song.max_bpm then
            
            gfx.Text(Info.Bpm.HasBpm,bpmPanelX+76, bpmPanelY + 96)
            gfx.Text(string.format("%.0f - %.0f",
                selected_song.min_bpm, selected_song.max_bpm),
                bpmPanelX+ 76 + 75, bpmPanelY + 96)
           
            gfx.Text(Info.LN.HasLN,bpmPanelX+76, bpmPanelY + 140)
            gfx.Text(string.format("%.2f = %.0f",
                selected_song.hispeed, selected_song.speed_bpm * selected_song.hispeed),
                bpmPanelX +76 + 175, bpmPanelY + 140)
        else

            gfx.FontSize(32);
            gfx.Text(Info.Bpm.HasBpm,bpmPanelX+76, bpmPanelY + 96)
            gfx.Text(string.format("%.0f",
                selected_song.min_bpm),
                bpmPanelX+ 76 + 75, bpmPanelY + 96)

            gfx.Text(Info.LN.HasLN,bpmPanelX+76, bpmPanelY + 140)
            gfx.Text(string.format("%.2f = %.0f",
                selected_song.hispeed, selected_song.speed_bpm * selected_song.hispeed),
                bpmPanelX + 76 + 175, bpmPanelY + 140)
        end
    end
end

return m_bpm_part