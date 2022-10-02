 

local l_grad =       gfx.CreateSkinImage("multi/roomselect/lobby_select_gradiant.png", 1);

local getgradient = function(x,y)

    gfx.Save()
    local jw,jh = gfx.ImageSize(l_grad);
    gfx.BeginPath();
    gfx.ImageRect(x/x, y/y+376, jw, jh, l_grad,1,0);

    gfx.Restore()

end


return getgradient