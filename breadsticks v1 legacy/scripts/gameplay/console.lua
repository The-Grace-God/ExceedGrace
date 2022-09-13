
local consoleBaseImage = gfx.CreateSkinImage("gameplay/console/base.png", 0)

local CONSOLE_W = 1352;
local CONSOLE_H = 712;

-- Similar to crit line transforms, since the console needs to follow the lane rotation
local setUpTransforms = function (x,y,rotation)
    local resx, resy = game.GetResolution()
    local desw = 1080
    local desh = 1920
    local scale = resx / desw

    
    gfx.Translate(x, y)
    gfx.Rotate(rotation)
    gfx.Scale(scale,scale)
end


local render = function (deltaTime, critLineCenterX, critLineCenterY, critLineRotation)
    local resx, resy = game.GetResolution();
    if (resx > resy) then
        return
    end
    
    setUpTransforms(
        critLineCenterX,
        critLineCenterY,
        critLineRotation
    )

    gfx.BeginPath();
    gfx.ImageRect(
        -CONSOLE_W/2,
        -CONSOLE_H/2+350,
        CONSOLE_W,
        CONSOLE_H,
        consoleBaseImage,
        1,
        0
    );
end

return {
    render=render
}