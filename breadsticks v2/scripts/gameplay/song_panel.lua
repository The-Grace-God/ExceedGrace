
local Charting = require('common.charting');
local DiffRectangle = require('components.diff_rectangle');
local Easing = require('common.easing');

local desw = 1080;
local desh = 1920;

local isLandscape = false;

local bgLeftImage = gfx.CreateSkinImage("gameplay/song_panel/bg_left.png", 0);
local bgRightImage = gfx.CreateSkinImage("gameplay/song_panel/bg_right.png", 0);
local notify = gfx.CreateSkinImage("gameplay/song_panel/notice.png", 0)

local demopanel = gfx.CreateSkinImage("multi/lobby/multi_jacket.png",0)
local progressDotImage = gfx.CreateSkinImage("gameplay/song_panel/dot.png", 0);

local jacketFallbackImage = gfx.CreateSkinImage("song_select/loading.png", 0);

local jacketImage;
local loadedJacketImage = false;

speedYin = 0
speedYoff = 25

local transitionEnterScale = 0


local loadJacketImage = function (jacketPath)
    if jacketImage == nil or jacketImage == jacketFallbackImage then
        jacketImage = gfx.LoadImageJob(jacketPath, jacketFallbackImage)
    end
end

local renderOutlinedText = function (x,y, text, outlineWidth,r,g,b)
    gfx.BeginPath();
    gfx.FillColor(0,0,0,255);
    gfx.Text(text, x-outlineWidth, y+outlineWidth);
    gfx.Text(text, x-outlineWidth, y-outlineWidth);
    gfx.Text(text, x+outlineWidth, y+outlineWidth);
    gfx.Text(text, x+outlineWidth, y-outlineWidth);

    gfx.FillColor(r,g,b,255);
    gfx.Text(text, x, y);
end

local tickTransitions = function (deltaTime)
    if transitionEnterScale < 1 then
        transitionEnterScale = transitionEnterScale + deltaTime / 0.66 -- transition should last for that time in seconds
    else
        transitionEnterScale = 1
    end
end

local demoMode = function (songTitle,songArtist)

    gfx.BeginPath();
    local tw, th = gfx.ImageSize(demopanel);
    th = (desw / tw) * th;
    gfx.BeginPath();
    gfx.FillColor(50,80,120,100)
    gfx.Rect((desw/4)-29, th+62, desw/1.75, th/1.64);
--    gfx.ImageRect((desw/4)-29,th+62,desw/1.75,th/1.64,demopanel,1,0)
    gfx.Fill()
    gfx.BeginPath();
    gfx.FontSize(38)
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    renderOutlinedText(desw/4+12,th+90, "DEMO MODE", 2,255,255,255);
    gfx.BeginPath();

    gfx.ImageRect((desw/4)+15,th+129,desw/2.12,th/2.25,jacketImage,1,0)

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    renderOutlinedText(desw/2,th+685, songTitle, 2,255,255,255);
    renderOutlinedText(desw/2,th+725, songArtist, 2,255,255,255);
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
    local adjustedDiff = Charting.GetDisplayDifficulty(gameplay.jacketPath, diff)
    DiffRectangle.render(deltaTime, 31, y+140, 0.84, adjustedDiff, level);
    
    gfx.FontSize(30);
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    renderOutlinedText(25,y+247, "BPM", 2,255,255,255);
    renderOutlinedText(25,y+281, "LANE-SPEED", 2,255,255,255);

    local actualLaneSpeed = (bpm*laneSpeed)/100

    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE);
    renderOutlinedText(260,y+247, string.format("%.0f", bpm), 2,255,255,255);
    renderOutlinedText(260,y+281, string.format("%.2f", actualLaneSpeed), 2,255,255,255);
    
    move = 0

    if game.GetButton(game.BUTTON_STA) then
        move = 25
        renderOutlinedText(130,y+315, "HI-SPEED", 2,255,255,255)
        renderOutlinedText(255,y+315,string.format("%.1f",laneSpeed), 2,0,255,0)
    end

    if gameplay.hitWindow.type ~= nil and gameplay.hitWindow.type == 0 then
        symbolthing = "-"
    elseif gameplay.hitWindow.type == 1 then
        symbolthing = ""
    elseif gameplay.hitWindow.type == 2 then
        symbolthing = "+"
    end

    gfx.FontSize(20);
    gfx.FillColor(255,255,0)
    gfx.Text(string.upper("Judge:")..symbolthing..gameplay.hitWindow.type,80,y+315+move);
    gfx.FillColor(255,255,255)
    gfx.FontSize(18);

    if not isLandscape then -- notify thingy
        theY = {350;394.5}
    else
        theY = {640;684.5}
    end

    if gameplay.autoplay and not gameplay.demoMode and gameplay.practice_setup == nil then

        gfx.BeginPath();
        gfx.ImageRect(0,y+theY[1],245,67,notify,1,0);
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        renderOutlinedText(30,y+theY[2], "AUTOPLAY IS ENABLED", 1.5,255,255,255);

    elseif gameplay.demoMode and gameplay.practice_setup == nil then

        gfx.BeginPath();
        if (isLandscape) then
            
            gfx.ImageRect(0,y+theY[1],245,67,notify,1,0);
            gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
            renderOutlinedText(30,y+theY[2], "DEMO MODE IS ENABLED", 1.5,255,255,255);
        else
            gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
            demoMode(songTitle,songArtist)
        end
        
--    elseif gameplay.scoreReplays and not gameplay.autoplay and not gameplay.demoMode and gameplay.practice_setup == nil then

-- untile its been clear how to set the flag

--       gfx.BeginPath();
--       gfx.ImageRect(0,y+310,245,67,notify,1,0);
--      gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
--      renderOutlinedText(30,y+354.5, "REPLAY MODE IS ENABLED", 1.5);
    
    elseif gameplay.practice_setup then

        gfx.BeginPath();
        gfx.ImageRect(0,y+theY[1],245,67,notify,1,0);
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        renderOutlinedText(30,y+theY[2], "PRACTICE MODE IS ENABLED", 1.5,255,255,255);

    end

    gfx.FontSize(30);
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