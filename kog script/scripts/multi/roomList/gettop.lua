
 lobbypanelX = 0; 
 lobbypanelY = (1080/2.5)-56;

local l_base_panel = gfx.CreateSkinImage("multi/roomselect/lobby_select.png",1);
local n_name = gfx.CreateSkinImage("multi/roomselect/nautica/nautica_station.png",1);



local gettop = function(x,y)

    local jw,jh = gfx.ImageSize(l_base_panel);
    gfx.BeginPath();
    gfx.SetImageTint(255,255,255,50)
    gfx.ImageRect(x/x, y/y+376, jw/1.17, jh/1.17, l_base_panel,1,0);

    local jw,jh = gfx.ImageSize(n_name);
    gfx.ImageRect(x/2.5, y/2-585, jw,jh,n_name,1,0)


end

return gettop