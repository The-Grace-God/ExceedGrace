local desw = 1080;
local desh = 1920;
local scale = 1;

local BAR_ALPHA = 191;

local HEADER_HEIGHT = 100
local headerY = 0;

local animationHeaderGlowScale = 0;
local animationHeaderGlowAlpha = 0;

-- Images
local headerTitleImage = gfx.CreateSkinImage("challenge_select/skill_analyzer.png", gfx.IMAGE_GENERATE_MIPMAPS)

local drawHeader = function ()
    gfx.BeginPath();
    gfx.FillColor(0,0,0,BAR_ALPHA);
    gfx.Rect(0,0,desw, HEADER_HEIGHT);
    gfx.Fill();
    gfx.ClosePath()

    local headerImageWidth, headerImageHeight = gfx.ImageSize(headerTitleImage)
    gfx.ImageRect(
        (desw - headerImageWidth) / 2, (HEADER_HEIGHT - headerImageHeight) / 2 - 12, -- asset png is not centered on the y axis
        headerImageWidth, headerImageHeight,
        headerTitleImage, 1, 0
    )
end

local progressTransitions = function (deltatime)
    -- HEADER GLOW ANIMATION
    if animationHeaderGlowScale < 1 then
        animationHeaderGlowScale = animationHeaderGlowScale + deltatime / 1 -- transition should last for that time in seconds
    else
        animationHeaderGlowScale = 0
    end

    if animationHeaderGlowScale < 0.5 then
        animationHeaderGlowAlpha = animationHeaderGlowScale * 2;
    else
        animationHeaderGlowAlpha = 1-((animationHeaderGlowScale-0.5) * 2);
    end
    animationHeaderGlowAlpha = animationHeaderGlowAlpha*0.4
end

local draw = function (deltatime)
    gfx.Save()
    
    gfx.LoadSkinFont("NotoSans-Regular.ttf");

    drawHeader();

    --progressTransitions(deltatime);
    gfx.Restore()
end

return {
    draw = draw
};