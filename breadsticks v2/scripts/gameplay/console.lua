
local Dimensions = require 'common.dimensions'

local consoleBaseImage = gfx.CreateSkinImage("gameplay/console/base.png", 0)

local CONSOLE_W = 1352;
local CONSOLE_H = 712;

local render = function (deltaTime, critLineCenterX, critLineCenterY, critLineRotation)
    local resx, resy = game.GetResolution();
    if (resx > resy) then
        return
    end

    Dimensions.setUpTransforms(
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