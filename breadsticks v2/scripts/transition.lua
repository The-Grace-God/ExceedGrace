
local common = require('common.util');
local Sound = require("common.sound")

local transitionEnterAnimation;
local transitionLeaveAnimation;

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)

-- Window variables
local resX, resY = game.GetResolution()

-- Aspect Ratios
local landscapeWidescreenRatio = 16 / 9
local landscapeStandardRatio = 4 / 3
local portraitWidescreenRatio = 9 / 16

-- Portrait sizes
local fullX = portraitWidescreenRatio * resY
local fullY = resY

local timer = 0;
local outTimer = 0;

local wasEnterSfxPlayed = false;
local wasLeaveSfxPlayed = false;

game.LoadSkinSample('transition_screen/transition_enter.wav');
game.LoadSkinSample('transition_screen/transition_leave.wav');

function loadAnimations()
    transitionEnterAnimation = gfx.LoadSkinAnimation('transition/transition_frames/enter', 1/60, 1, false);
    transitionLeaveAnimation = gfx.LoadSkinAnimation('transition/transition_frames/leave', 1/60, 1, false);
end

function drawBackground()
    gfx.BeginPath()
    local bgImageWidth, bgImageHeight = gfx.ImageSize(backgroundImage)
    gfx.Rect(0, 0, resX, resY)
    gfx.FillPaint(gfx.ImagePattern(0, 0, bgImageWidth, bgImageHeight, 0, backgroundImage, 0.2))
    gfx.Fill()
end

function render(deltaTime)
    local x_offset = (resX - fullX) / 2
    local y_offset = 0

    gfx.BeginPath()

    Sound.stopMusic();
    
    if not transitionEnterAnimation then
        loadAnimations()
    end

    local enterAnimTickRes = gfx.TickAnimation(transitionEnterAnimation, deltaTime);
    
    if enterAnimTickRes == 0 then
        gfx.GlobalAlpha(0);
    else
        if not wasEnterSfxPlayed then 
            game.PlaySample('transition_screen/transition_enter.wav');
            wasEnterSfxPlayed = true;
        end
        gfx.BeginPath();
        gfx.ImageRect(x_offset, y_offset, fullX, fullY, transitionEnterAnimation, 1, 0);
        gfx.GlobalAlpha(1);
        
        -- debug
        if game.GetSkinSetting('debug_showInformation') then 
            gfx.Text('DELTA: ' .. deltaTime .. ' // TIMER: ' .. timer .. ' // TIMER_OUT: ' .. outTimer, 255,255);
        end
        timer = timer + (deltaTime / 3);
    end
    

    if timer >= 1 then return true end;
end

function render_out(deltaTime)
    local leaveAnimeTickRes = gfx.TickAnimation(transitionLeaveAnimation, deltaTime);
    local x_offset = (resX - fullX) / 2
    local y_offset = 0

    gfx.BeginPath()

    if leaveAnimeTickRes == 0 then
        gfx.BeginPath();
	    gfx.ImageRect(x_offset, y_offset, fullX, fullY, transitionEnterAnimation, 1, 0);
    else
        if not wasLeaveSfxPlayed then 
            game.PlaySample('transition_screen/transition_leave.wav');
            wasLeaveSfxPlayed = true;
        end

        gfx.BeginPath();
        gfx.ImageRect(x_offset, y_offset, fullX, fullY, transitionLeaveAnimation, 1, 0);
        outTimer = outTimer + (1/60) / 0.5
    end


    if outTimer >= 1 then
        return true;
    end

end

function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end


function reset()
    resX, resY = game.GetResolution();
    fullX = portraitWidescreenRatio * resY
    fullY = resY
    timer = 0;
    outTimer = 0;

    transitionEnterAnimation = nil;
    transitionLeaveAnimation = nil;

    wasEnterSfxPlayed = false;
    wasLeaveSfxPlayed = false;
end