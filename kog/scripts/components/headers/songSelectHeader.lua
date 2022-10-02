local Dim = require("common.dimensions")

local BAR_ALPHA = 191

local HEADER_HEIGHT = 100

local animationHeaderGlowScale = 0
local animationHeaderGlowAlpha = 0

-- Images
local headerTitleImage = gfx.CreateSkinImage("song_select/header/title.png", 1)
local headerGlowTitleImage = gfx.CreateSkinImage("song_select/header/title_glow.png", 1)

local drawHeader = function()
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, BAR_ALPHA)
    gfx.Rect(0, 0, Dim.design.width, HEADER_HEIGHT)
    gfx.Fill()
    gfx.ClosePath()

    gfx.ImageRect(42, 14, 423 * 0.85, 80 * 0.85, headerTitleImage, 1, 0)
    gfx.ImageRect(42, 14, 423 * 0.85, 80 * 0.85, headerGlowTitleImage, animationHeaderGlowAlpha, 0)
end

local progressTransitions = function(deltatime)
    -- HEADER GLOW ANIMATION
    if animationHeaderGlowScale < 1 then
        animationHeaderGlowScale = animationHeaderGlowScale + deltatime / 1 -- transition should last for that time in seconds
    else
        animationHeaderGlowScale = 0
    end

    if animationHeaderGlowScale < 0.5 then
        animationHeaderGlowAlpha = animationHeaderGlowScale * 2
    else
        animationHeaderGlowAlpha = 1 - ((animationHeaderGlowScale - 0.5) * 2)
    end
    animationHeaderGlowAlpha = animationHeaderGlowAlpha * 0.4
end

local draw = function(deltatime)
    gfx.Save()

    gfx.ResetTransform()

    Dim.updateResolution()

    Dim.transformToScreenSpace()

    gfx.LoadSkinFont("NotoSans-Regular.ttf")

    drawHeader()

    progressTransitions(deltatime)

    gfx.Restore()
end

return {draw = draw}
