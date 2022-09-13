
local VolforceWindow = require('components.volforceWindow');

local desw = 1080;
local desh = 1920;

local isLandscape = false;

local bgImage = gfx.CreateSkinImage("gameplay/user_panel/bg.png", 0);

local appealCardImage = gfx.CreateSkinImage("crew/appeal_card.png", 0);
local danBadgeImage = gfx.CreateSkinImage("dan.png", 0);
local idolFrameImage = gfx.CreateSkinImage("crew/frame.png", 0);


local username  = game.GetSkinSetting('username') or '';

local drawBestDiff = function (deltaTime, score, bestReplay, y)
    if not bestReplay then return end

    -- Calculate the difference between current and best play
    local difference = score - bestReplay.currentScore
    local prefix = "=" -- used to properly display negative values
    
    gfx.BeginPath()
    gfx.FontSize(26)
    
    gfx.FillColor(255, 255, 255)
    if difference < 0 then
        -- If we're behind the best score, separate the minus sign and change the color
        gfx.FillColor(255, 90, 70)
        difference = math.abs(difference)
        prefix = "-"
        
    elseif difference > 0 then
        gfx.FillColor(120, 146, 218)
        difference = math.abs(difference)
        prefix = "+"
    end 
    
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")
    gfx.FontSize(26)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(prefix, 130, y+177)
    gfx.Text(string.format("%04d", math.floor(difference/10000)), 150, y+177)

    local lastFourDigits = ((difference / 10000) - math.floor(difference / 10000))*10000
    gfx.FontSize(22)
    gfx.Text(string.format("%04d", math.floor(lastFourDigits)), 208, y+178)
end

local tickTransitions = function (deltaTime)
    
end

local render = function (deltaTime, score, bestReplay)
    gfx.ResetTransform()
    
    local resx, resy = game.GetResolution();
    isLandscape = resx > resy;

    if (isLandscape) then
        desw = 1920;
        desh = 1080;
    else
        desw = 1080;
        desh = 1920;
    end

    local x = 0;
    local y = desh*0.35; -- Approx. pos of the user panel against the height of the screen is 0.35

    tickTransitions(deltaTime)

    local scale = resy / desh
    gfx.Scale(scale, scale)

    gfx.BeginPath();
    gfx.ImageRect(
        0,
        y,
        449*0.85,
        336*0.85,
        idolFrameImage,
        1,
        0
    );

    gfx.BeginPath();
    gfx.ImageRect(
        0,
        y,
        449*0.85,
        336*0.85,
        bgImage,
        1,
        0
    );

    -- Draw appeal card
    gfx.BeginPath();
    gfx.ImageRect(
        10,
        y+117,
        150*0.62,
        192*0.62,
        appealCardImage,
        1,
        0
    );

    -- Draw username
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FontSize(26)
    gfx.Text(username, 150, y+152);

    -- Draw best score diff
    drawBestDiff(deltaTime, score, bestReplay, y);

    -- Draw dan badge & volforce
    gfx.BeginPath();
    gfx.ImageRect(
        117,
        y+206,
        294*0.32, -- what are these whacky measurements
        84*0.32,
        danBadgeImage,
        1,
        0
    );

    VolforceWindow.render(deltaTime, 220, y+197)

    gfx.ResetTransform()
    
end

return {
    render=render
}