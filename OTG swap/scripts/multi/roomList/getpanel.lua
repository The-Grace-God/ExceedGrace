local Dim = require("common.dimensions")

local desw,desh = Dim.design.width,Dim.design.height


 lobbypanelY = 376;

local l_color    =      gfx.CreateSkinImage("multi/roomselect/lobby_select_color.png", 1);
local l_load     =       gfx.CreateSkinImage("multi/roomselect/lobby_not_loaded.png",1)
local n_play_dot =       gfx.CreateSkinImage("multi/roomselect/nautica/nautica_pl_dot.png",1);

local getpanel = function()
    if screenState == "roomList" then --multi

    local jw,jh = gfx.ImageSize(l_color);

    gfx.BeginPath();
    gfx.ImageRect(desw/desw, lobbypanelY, jw/1.17, jh/1.17, l_color,1,0);

    if not loading then
        gfx.BeginPath()
        gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_BOTTOM)
        custom_button("Create new room",40+(desw/2), 530+(desh/2),l_load,"Digital-Serial-Bold.ttf",70,new_room)
        end
    end

    if screenState ~= "roomList" then --nautica
    
        local jw,jh = gfx.ImageSize(l_color);

        gfx.BeginPath();
        gfx.ImageRect(lobbypanelX,lobbypanelY, jw/1.17, jh/1.17, l_color,1,0);

        gfx.BeginPath()
        local jw,jh = gfx.ImageSize(l_load);
        gfx.BeginPath();
        gfx.ImageRect(40+(desw/2), 530+(desh/2), jw, jh, l_load,1,0);

        local jw,jh = gfx.ImageSize(n_play_dot);
    

        for i = 1, 3, 1 do
            gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
            gfx.BeginPath()
        
             gfx.FontSize(30)
            if i == 1 then
                gfx.FillColor(255,9,253)
                gfx.Text(string.upper("Not Downloaded"),desw-30, 14+680+desh/2-(40*i))
            elseif i == 2 then
                gfx.FillColor(240,246,0)
                gfx.Text(string.upper("Downloaded"),desw-30, 14+680+desh/2-(40*i))
            elseif i == 3 then
                gfx.FillColor(0,246,2)
                gfx.Text(string.upper("Preview Playing"),desw-30, 14+680+desh/2-(40*i))
            end
            gfx.FillColor(255,255,255)
        end
    end
end


return getpanel