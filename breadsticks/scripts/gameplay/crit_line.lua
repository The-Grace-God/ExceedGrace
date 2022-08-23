
local baseImage = gfx.CreateSkinImage("gameplay/crit_line/base.png", 0)
local baseImageLandscape = gfx.CreateSkinImage("gameplay/crit_line/base_landscape.png", 0)
local textImage = gfx.CreateSkinImage("gameplay/crit_line/text.png", 0)

local cursorImage = gfx.CreateSkinImage("gameplay/crit_line/cursor.png", 0);
local cursorTopImage = gfx.CreateSkinImage("gameplay/crit_line/cursor_top.png", 0);
local cursorGlowBottomImages = {
    gfx.CreateSkinImage("gameplay/crit_line/cursor_glow_bottom_left.png", 0),
    gfx.CreateSkinImage("gameplay/crit_line/cursor_glow_bottom_right.png", 0),
}
local cursorGlowTopImages = {
    gfx.CreateSkinImage("gameplay/crit_line/cursor_glow_top_left.png", 0),
    gfx.CreateSkinImage("gameplay/crit_line/cursor_glow_top_right.png", 0),
}

local CRITBAR_W = 1496
local CRITBAR_H = 348

local scale;

local isLandscape = false;

local setUpTransforms = function (x,y,rotation)
    local resx, resy = game.GetResolution();
    isLandscape = resx > resy;

    local desw, desh;

    if (isLandscape) then
        desw = 1920;
        desh = 1080;
    else
        desw = 1080;
        desh = 1920;
    end

    scale = resx / desw

    gfx.Translate(x, y)
    gfx.Rotate(rotation)
    gfx.Scale(scale,scale)
end

local drawCursors = function (centerX, centerY,cursors)
    local cursorW = 598*0.2;
    local cursorH = 673*0.2;
    for i = 0, 1, 1 do
        gfx.Save();
        local cursor = cursors[i];
        gfx.BeginPath();
        gfx.SkewX(cursor.skew)

        local cursorX = (cursor.pos *(1/scale) - cursorW/2);
        local cursorY = (-cursorH/2);

        gfx.ImageRect(
            cursorX,
            cursorY,
            cursorW,
            cursorH,
            cursorImage,
            cursor.alpha,
            0
        );

        gfx.ImageRect(
            cursorX,
            cursorY,
            cursorW,
            cursorH,
            cursorGlowBottomImages[i+1],
            cursor.alpha,
            0
        );

        gfx.ImageRect(
            cursorX,
            cursorY,
            cursorW,
            cursorH,
            cursorTopImage,
            cursor.alpha,
            0
        );

        gfx.ImageRect(
            cursorX,
            cursorY,
            cursorW,
            cursorH,
            cursorGlowTopImages[i+1],
            cursor.alpha,
            0
        );
        
        gfx.Restore();
    end
end

local renderBase = function (deltaTime, centerX, centerY, rotation, cursors)
    setUpTransforms(centerX, centerY, rotation)

    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, 192)
    gfx.Rect(-1080/2, 0, 1080, 1080)
    gfx.Fill()

    gfx.BeginPath();
    if (isLandscape) then
        gfx.ImageRect(-CRITBAR_W/2, -CRITBAR_H/2, CRITBAR_W, CRITBAR_H, baseImageLandscape, 1, 0);
    else
        gfx.ImageRect(-CRITBAR_W/2, -CRITBAR_H/2, CRITBAR_W, CRITBAR_H, baseImage, 1, 0);
    end

    drawCursors(centerX, centerY, cursors)
    
    gfx.ResetTransform()
end

local renderOverlay = function (deltaTime)
    
end

return {
    renderBase=renderBase,
    renderOverlay=renderOverlay
}