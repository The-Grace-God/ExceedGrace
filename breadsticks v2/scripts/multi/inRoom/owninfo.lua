local ownPanelX = 0;
local ownPanelY = 1310;

 msg = game.GetSkinSetting("MSG");
 username = game.GetSkinSetting("username")

local m_host_panel = gfx.CreateSkinImage("multi/lobby/user_panel.png", 1);
local ready_bt = gfx.CreateSkinImage("multi/lobby/READY.png", 1);

local m_own_info = function()

    gfx.BeginPath();
    gfx.FontSize(40)
    gfx.ImageRect(ownPanelX, ownPanelY, 343/1.18, 361/1.18,m_host_panel,1,0)
    gfx.Text(string.upper(username), ownPanelX+20, ownPanelY+78)
    gfx.FontSize(22)
    gfx.Text(string.upper(msg),ownPanelX+20, ownPanelY+37)
    gfx.Text(string.upper(irText), ownPanelX+20, ownPanelY+288);

end

return m_own_info