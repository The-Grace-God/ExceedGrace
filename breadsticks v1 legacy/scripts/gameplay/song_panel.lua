
local DiffRectangle = require('components.diff_rectangle');

local desw = 1080;
local desh = 1920;

local isLandscape = false;

local bgLeftImage = gfx.CreateSkinImage("gameplay/song_panel/bg_left.png", 0);
local bgRightImage = gfx.CreateSkinImage("gameplay/song_panel/bg_right.png", 0);

local progressDotImage = gfx.CreateSkinImage("gameplay/song_panel/dot.png", 0);

local jacketFallbackImage = gfx.CreateSkinImage("song_select/loading.png", 0);

local jacketImage;
local loadedJacketImage = false;

local loadJacketImage = function (jacketPath)
    if jacketImage == nil or jacketImage == jacketFallbackImage then
        jacketImage = gfx.LoadImageJob(jacketPath, jacketFallbackImage)
    end
end

local renderOutlinedText = function (x,y, text, outlineWidth)
    gfx.BeginPath();
    gfx.FillColor(0,0,0,255);
    gfx.Text(text, x-outlineWidth, y+outlineWidth);
    gfx.Text(text, x-outlineWidth, y-outlineWidth);
    gfx.Text(text, x+outlineWidth, y+outlineWidth);
    gfx.Text(text, x+outlineWidth, y-outlineWidth);

    gfx.FillColor(255,255,255,255);
    gfx.Text(text, x, y);
end

local tickTransitions = function (deltaTime)
    
end

local render = function (deltaTime, bpm, laneSpeed, jacketPath, diff, level, progress, songTitle, songArtist)
    gfx.Save();

    local resx, resy = game.GetResolution();
    isLandscape = resx > resy;

    if (not loadedJacketImage and jacketPath) then
        loadJacketImage(jacketPath)
    end

    tickTransitions(deltaTime)

    if (isLandscape) then
        desw = 1920;
        desh = 1080;
    else
        desw = 1080;
        desh = 1920;
    end

    local y = isLandscape and 0 or 210;

    local scale = resy / desh
    gfx.Scale(scale, scale)

    gfx.BeginPath();
    gfx.ImageRect(
        0,
        y,
        844*0.85,
        374*0.85,
        bgLeftImage,
        1,
        0
    );

    gfx.BeginPath();
    gfx.ImageRect(
        200,
        y,
        1016*0.85,
        122*0.85,
        bgRightImage,
        1,
        0
    );

    -- Draw jacket
    gfx.BeginPath();
    gfx.ImageRect(
        32,
        y+31.25, -- why does this need to be here?
        105,
        105,
        jacketImage,
        1,
        0
    );

    -- Draw diff rectangle
    DiffRectangle.render(deltaTime, 31, y+140, 0.84, diff, level);
    
    gfx.FontSize(30);
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    renderOutlinedText(25,y+247, "BPM", 2);
    renderOutlinedText(25,y+281, "LANE-SPEED", 2);

    local actualLaneSpeed = (bpm*laneSpeed)/100

    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE);
    renderOutlinedText(260,y+247, string.format("%.0f", bpm), 2);
    renderOutlinedText(260,y+281, string.format("%.2f", actualLaneSpeed), 2);

    -- Draw progress
    gfx.BeginPath()
    gfx.FillColor(244, 204, 101)
    gfx.Rect(222, y+81, 622 * progress, 3)
    gfx.Fill()

    gfx.BeginPath();
    gfx.ImageRect(
        208 + 622 * progress + ((1-progress) * 8),
        y+78.5,
        24*0.85,
        10*0.85,
        progressDotImage,
        1,
        0
    );

    -- Draw song title

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FontSize(22)
    gfx.Text(songTitle .. ' / ' .. songArtist, 385, y+60);

    gfx.ResetTransform()
    
    gfx.Restore();
end

return {
    render=render
}