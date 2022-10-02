local Dim = require("common.dimensions")

local BAR_ALPHA = 191

local FOOTER_HEIGHT = 128
local footerY = Dim.design.height - FOOTER_HEIGHT

-- Images
local footerRightImage = gfx.CreateSkinImage("components/bars/footer_right.png", 0)

-- Animation related
local entryTransitionScale = 0
local entryTransitionFooterYOffset = 0

local function drawNautica()
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, BAR_ALPHA)
    gfx.Rect(0, footerY, Dim.design.width, FOOTER_HEIGHT)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(Dim.design.width - 275, footerY - 25, 328 * 0.85, 188 * 0.85, footerRightImage, 1, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")
    gfx.FontSize(20)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(255, 255, 255, 255)
    gfx.Text("https://ksm.dev/ ", 8, 1895)
end

local function progressTransitions(deltaTime)
    entryTransitionScale = entryTransitionScale + deltaTime / 0.3
    if (entryTransitionScale > 1) then entryTransitionScale = 1 end

    entryTransitionFooterYOffset = FOOTER_HEIGHT * (1 - entryTransitionScale)
    footerY = Dim.design.height - FOOTER_HEIGHT + entryTransitionFooterYOffset
end

local function draw(deltaTime, params)
    if params and params.noEnterTransition then
        entryTransitionScale = 1
    end

    gfx.Save()

    gfx.ResetTransform()

    Dim.updateResolution()

    Dim.transformToScreenSpace()

    gfx.LoadSkinFont("NotoSans-Regular.ttf")
    
    drawNautica()
   
    progressTransitions(deltaTime)

    gfx.Restore()
end

return {draw = draw}