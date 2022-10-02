local infPanelX = 475;
local infPanelY = 1590;

local m_info_panel = gfx.CreateSkinImage("multi/lobby/button_panel.png", 1);

local Info = {
    BTs = {
        BTA  = "EXCESSIVE",
        BTB  = "MIRROR",
        BTC  = "ROTATE",
        BTD  = "LEAVE",
        ST   = "START",
        FXS  = "FX-L/FX-R TO SETTINGS",
    },
    MEME = {
        BTs = "SEX",
        FXS = "START TO EXCEED SEX",
    }
}

local m_info_part = function () -- the info panel
    local jw , jh = gfx.ImageSize(m_info_panel);
    gfx.BeginPath();
    gfx.ImageRect(infPanelX, infPanelY, jw/1.18, jh/1.18, m_info_panel,1,0);
    gfx.FontSize(24)

    draw_checkbox(Info.BTs.BTA,infPanelX+160, infPanelY+50, toggle_hard, hard_mode, not start_game_soon)
    draw_checkbox(Info.BTs.BTB,infPanelX+187, infPanelY+87.5, toggle_mirror, mirror_mode, not start_game_soon)
    draw_checkbox(Info.BTs.BTC,infPanelX+390, infPanelY+87.5, toggle_rotate, do_rotate,
                    (owner == user_id or host == user_id) and not start_game_soon)

    gfx.FillColor(255,255,255,100)
    gfx.Text(Info.BTs.BTD,infPanelX+417.5, infPanelY+49)
    gfx.Text(Info.BTs.ST,infPanelX*1.61, infPanelY+35)
    gfx.FillColor(255,255,255)
    gfx.FontSize(24)
    gfx.Text(Info.BTs.FXS,infPanelX+290.5,infPanelY+269)
--    gfx.Text(Info.MEME.FXS,infPanelX+290.5,infPanelY+269)
end

return m_info_part