
local Dimensions = require 'common.dimensions'

local blackGradientImage = gfx.CreateSkinImage('gameplay/crit_line/black_gradient.png', 0)

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
local cursorTailImages = {
    gfx.CreateSkinImage("gameplay/crit_line/cursor_tail_l.png", 0),
    gfx.CreateSkinImage("gameplay/crit_line/cursor_tail_r.png", 0),
}

local CRITBAR_W = 1080
local CRITBAR_H = 251

local scale = 1;
local isLandscape = false;

local drawCursors = function (centerX, centerY,cursors, laserActive)
    local cursorW = 598 * 0.165;
    local cursorH = 673 * 0.14;

    local tailW = cursorW * 9
    local tailH = cursorH * 9

    for i = 0, 1, 1 do
        local luaIndex = i + 1
        local cursor = cursors[i];

        gfx.Save();
        gfx.BeginPath();

        local skew = cursor.pos * 0.001;
        gfx.SkewX(skew);

        local cursorX = cursor.pos * (1 / scale) - cursorW / 2;
        local cursorY = -cursorH / 2;

        if laserActive[luaIndex] then        
            gfx.ImageRect(
                cursor.pos - tailW / 2,
                - tailH / 2,
                tailW,
                tailH,
                cursorTailImages[luaIndex],
                cursor.alpha / 2,
                0
            )
        end

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
            cursorGlowBottomImages[luaIndex],
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
            cursorGlowTopImages[luaIndex],
            cursor.alpha,
            0
        );
        
        gfx.Restore();
    end
end

local renderBase = function (deltaTime, centerX, centerY, rotation)
    scale, isLandscape = Dimensions.setUpTransforms(centerX, centerY, rotation)

    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, 192)
    gfx.Rect(-9999, 0, 9999 * 2, 1080)
    gfx.Fill()

    if (isLandscape) then
        gfx.BeginPath();
        gfx.ImageRect(-9999, -CRITBAR_H/2, 9999 * 2, CRITBAR_H, baseImageLandscape, 1, 0);
    else
        gfx.BeginPath();
        gfx.ImageRect(-CRITBAR_W/2, -CRITBAR_H/2, CRITBAR_W, CRITBAR_H, baseImage, 1, 0);
    end

    gfx.ResetTransform()
end

local renderOverlay = function (deltaTime, centerX, centerY, rotation, cursors, laserActive)
    scale, isLandscape = Dimensions.setUpTransforms(centerX, centerY, rotation)

    drawCursors(centerX, centerY, cursors, laserActive)

    gfx.ResetTransform()
end

return {
    renderBase=renderBase,
    renderOverlay=renderOverlay
}