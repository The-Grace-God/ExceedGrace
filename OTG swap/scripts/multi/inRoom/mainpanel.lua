local roomNamePanelX = 429;
local roomNamePanelY = 1142;

local m_panel = gfx.CreateSkinImage("multi/lobby/matching_panel.png", 1);

local m_part = function()
    local jw , jh = gfx.ImageSize(m_panel);
    gfx.BeginPath();
    gfx.ImageRect(roomNamePanelX, roomNamePanelY, jw/1.175, jh/1.18, m_panel,1,0);

    gfx.FontSize(32);
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT, gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(selected_room.name,roomNamePanelX+146, roomNamePanelY+37)
end

return m_part