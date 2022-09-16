local Numbers = require('components.numbers')

local bgImage = gfx.CreateSkinImage("gameplay/score_panel/bg.png", 0)

local desw = 1080;
local desh = 1920;

local isLandscape = false;

local scoreNumbers = Numbers.load_number_image("score_num")

local tickTransitions = function (deltaTime)
    
end

local render = function (deltaTime, score, maxChain)
    gfx.Save();
    
    local resx, resy = game.GetResolution();
    isLandscape = resx > resy;

    if (isLandscape) then
        desw = 1920;
        desh = 1080;
    else
        desw = 1080;
        desh = 1920;
    end

    tickTransitions(deltaTime)

    local scale = resy / desh
    local x = resx;
    local y = isLandscape and 5 or 330;

    gfx.Translate(x, 0);
    x = 0

    gfx.Scale(scale, scale)

    gfx.BeginPath();
    gfx.ImageRect(
        x-740*0.61, -- WHY IS THERE DIFFERENT SCALING FOR THIS TOO????
        y,
        740*0.61,
        320*0.61,
        bgImage,
        1,
        0
    );

    Numbers.draw_number(x-309.4, y + 83, 1.0, score/10000, 4, scoreNumbers, true, 0.38, 1.12)
    Numbers.draw_number(x-113.4, y + 90, 1.0, score, 4, scoreNumbers, true, 0.28, 1.12)

    -- Draw max chain
    gfx.BeginPath();
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FontSize(30);

    gfx.FillColor(255,255,255,255);
    gfx.Text(string.format("%04d", maxChain), x-281.4, y+155);

    gfx.ResetTransform()

    gfx.Restore();
end

return {
    render=render
}