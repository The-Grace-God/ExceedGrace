local Dim = require("common.dimensions")

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)
local bgImageWidth, bgImageHeight = gfx.ImageSize(backgroundImage)

local patternAngle = 0
local patternAlpha = 0.2

function render()
    gfx.Save()
    gfx.ResetTransform()

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.screen.width, Dim.screen.height)
    gfx.FillPaint(gfx.ImagePattern(0, 0, bgImageWidth, bgImageHeight, patternAngle, backgroundImage, patternAlpha))
    gfx.Fill()
    
    gfx.Restore()
end

return {
    render = render
}