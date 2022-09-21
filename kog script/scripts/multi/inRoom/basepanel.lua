local bottomPanelX = 1; 
local bottomPanelY = 1250;

local m_base_panel = gfx.CreateSkinImage("multi/lobby/multi_base_panel.png", 1);
local m_anim = gfx.CreateSkinImage("multi/lobby/panel_laser.png", 1);

local m_base_part = function()
    local jw , jh = gfx.ImageSize(m_base_panel);
    gfx.BeginPath();
    gfx.ImageRect(bottomPanelX, bottomPanelY, jw/1.17, jh/1.18, m_base_panel,1,0);
    gfx.BeginPath();
    gfx.ImageRect(bottomPanelX, bottomPanelY, jw/1.17, jh/1.18, m_anim,1,0);

    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.FillColor(255,255,255)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT, gfx.TEXT_ALIGN_LEFT)
    gfx.FontSize(24)
end

return m_base_part