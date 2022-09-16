
local leftAlertBaseImage = gfx.CreateSkinImage("gameplay/laser_alert/left/base.png", 0)
local leftAlertTopImage = gfx.CreateSkinImage("gameplay/laser_alert/left/top.png", 0)
local leftAlertTextImage = gfx.CreateSkinImage("gameplay/laser_alert/left/text.png", 0)

local rightAlertBaseImage = gfx.CreateSkinImage("gameplay/laser_alert/right/base.png", 0)
local rightAlertTopImage = gfx.CreateSkinImage("gameplay/laser_alert/right/top.png", 0)
local rightAlertTextImage = gfx.CreateSkinImage("gameplay/laser_alert/right/text.png", 0)

local TRANSITION_ALERT_ENTER_THRESHOLD = 0.075;
local TRANSITION_ALERT_LEAVE_THRESHOLD = 0.925;

local LEFT_ALERT_X_OFF = 0
local RIGHT_ALERT_X_OFF = -450*0.5

local ALERT_Y_POS = 1115

local test = -2*3.14;

local transitionLeftScale = 1;
local transitionLeftOffsetX = 0;
local transitionLeftOpacity = 0;

local transitionRightScale = 1;
local transitionRightOffsetX = 0;
local transitionRightOpacity = 0;

local desw = 1080;
local desh = 1920;

local isLandscape = false;

local renderLeftAlert = function()
    gfx.BeginPath();
    gfx.ImageRect(
        (LEFT_ALERT_X_OFF+450*0.5) + transitionLeftOffsetX,
        ALERT_Y_POS+450*0.5,
        450*0.5,
        450*0.5,
        leftAlertBaseImage,
        1,
        -3.14
    );

    gfx.BeginPath();
    gfx.ImageRect(
        (LEFT_ALERT_X_OFF+450*0.5) + transitionLeftOffsetX,
        ALERT_Y_POS+450*0.5,
        450*0.5,
        450*0.5,
        leftAlertTopImage,
        1,
        -3.14
    );

    gfx.BeginPath();
    gfx.ImageRect(
        LEFT_ALERT_X_OFF,
        ALERT_Y_POS,
        450*0.5,
        450*0.5,
        leftAlertTextImage,
        transitionLeftOpacity,
        0
    );
end

local renderRightAlert = function()
    gfx.BeginPath();
    gfx.ImageRect(
        RIGHT_ALERT_X_OFF + transitionRightOffsetX,
        ALERT_Y_POS,
        450*0.5,
        450*0.5,
        rightAlertBaseImage,
        1,
        0
    );
    
    gfx.BeginPath();
    gfx.ImageRect(
        RIGHT_ALERT_X_OFF + transitionRightOffsetX,
        ALERT_Y_POS,
        450*0.5,
        450*0.5,
        rightAlertTopImage,
        1,
        0
    );

    gfx.BeginPath();
    gfx.ImageRect(
        RIGHT_ALERT_X_OFF,
        ALERT_Y_POS,
        450*0.5,
        450*0.5,
        rightAlertTextImage,
        transitionRightOpacity,
        0
    );
end

local showLaserAlert = function(isRight)
    if (isRight) then
        if (transitionRightScale < 1) then
            transitionRightScale = TRANSITION_ALERT_ENTER_THRESHOLD -- If the laser alert is already in progress, just reset its duration
        else
            transitionRightScale = 0;
        end
    else
        if (transitionLeftScale < 1) then
            transitionLeftScale = TRANSITION_ALERT_ENTER_THRESHOLD -- If the laser alert is already in progress, just reset its duration
        else
            transitionLeftScale = 0;
        end
    end
end

local tickTransitions = function (deltaTime)
    local showScale = 0;

    -- Left
    if transitionLeftScale < 1 then
        transitionLeftScale = transitionLeftScale + deltaTime / 3 -- transition should last for that time in seconds
    else
        transitionLeftScale = 1
    end

    showScale = 0;

    if transitionLeftScale < TRANSITION_ALERT_ENTER_THRESHOLD then
        showScale = transitionLeftScale/TRANSITION_ALERT_ENTER_THRESHOLD; -- 0-0.1
    elseif transitionLeftScale > TRANSITION_ALERT_LEAVE_THRESHOLD and transitionLeftScale < 1 then
        showScale = 1-((transitionLeftScale-TRANSITION_ALERT_LEAVE_THRESHOLD)/(1-TRANSITION_ALERT_LEAVE_THRESHOLD)); 
    elseif transitionLeftScale >= 1 then
        showScale = 0;
    else
        showScale = 1;
    end

    transitionLeftOffsetX = -450*0.5*(1-showScale);
    transitionLeftOpacity = math.max(0, showScale-0.5)/0.5;

    -- Right
    if transitionRightScale < 1 then
        transitionRightScale = transitionRightScale + deltaTime / 3 -- transition should last for that time in seconds
    else
        transitionRightScale = 1
    end

    showScale = 0;

    if transitionRightScale < TRANSITION_ALERT_ENTER_THRESHOLD then
        showScale = transitionRightScale/TRANSITION_ALERT_ENTER_THRESHOLD; -- 0-0.1
    elseif transitionRightScale > TRANSITION_ALERT_LEAVE_THRESHOLD and transitionRightScale < 1 then
        showScale = 1-((transitionRightScale-TRANSITION_ALERT_LEAVE_THRESHOLD)/(1-TRANSITION_ALERT_LEAVE_THRESHOLD)); 
    elseif transitionRightScale >= 1 then
        showScale = 0;
    else
        showScale = 1;
    end

    transitionRightOffsetX = 450*0.5*(1-showScale);
    transitionRightOpacity = math.max(0, showScale-0.5)/0.5;
end

local render = function (deltaTime)    
    gfx.ResetTransform()

    local resx, resy = game.GetResolution();
    isLandscape = resx > resy;

    local scale = resy / desh

    if (isLandscape) then
        ALERT_Y_POS = (desh+150)*0.6
    else
        ALERT_Y_POS = desh*0.58
    end

    tickTransitions(deltaTime);
    
    gfx.Scale(scale, scale)
    renderLeftAlert();
    gfx.ResetTransform()

    gfx.Translate(resx, 0)
    gfx.Scale(scale, scale)
    renderRightAlert();

    test = test + deltaTime;

    gfx.ResetTransform()

    if game.GetSkinSetting('debug_showInformation') then 
        gfx.BeginPath();
        gfx.FontSize(18)
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
        gfx.Text('T_L: ' .. transitionLeftScale .. ' // T_R: ' .. transitionRightScale, 500, 500);
    end
end

return {
    show=showLaserAlert,
    render=render
}