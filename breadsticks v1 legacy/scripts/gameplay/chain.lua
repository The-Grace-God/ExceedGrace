local Numbers = require('common.numbers')

local chainLabel = gfx.CreateSkinImage("gameplay/chain/label.png", 0)

local desw = 1080;
local desh = 1920;

local isLandscape = false;

local transitionShakeScale = 0;
local transitionShakePosOffset = 0;
local shakeTimer = 0;

local chainNumbersReg = Numbers.load_number_image('gameplay/chain/reg')
local chainNumbersUC = Numbers.load_number_image('gameplay/chain/uc')
local chainNumbersPUC = Numbers.load_number_image('gameplay/chain/puc')

local tickTransitions = function (deltaTime)
    
    if transitionShakeScale < 1 then
        transitionShakeScale = transitionShakeScale + deltaTime / 0.075 -- transition should last for that time in seconds
    else
        transitionShakeScale = 0
    end

    if (transitionShakeScale < 1/3) then
        transitionShakePosOffset = 0;
    elseif (transitionShakeScale > 2/3) then
        transitionShakePosOffset = -1;
    else
        transitionShakePosOffset = 1;
    end
end

local onNewCombo = function ()
    shakeTimer = 0.25;
end

local render = function (deltaTime, comboState, combo, critLineCenterX, critLineCenterY)
    gfx.Save();
    
    local resx, resy = game.GetResolution();
    isLandscape = resx > resy;

    if (isLandscape) then
        desw = 1920;
        desh = 1080;
    else
        desw = 1080;
        desh = 1920;
    end

    tickTransitions(deltaTime)

    if shakeTimer > 0 then
        shakeTimer = shakeTimer - deltaTime;
    else
        transitionShakePosOffset = 0;
    end

    if combo == 0 then return end

    local bottomOffsetMultiplier = 0.333;
    if (isLandscape) then
        bottomOffsetMultiplier = 0.25
    end

    local scale = resy / desh
    if scale == 0 then
        scale = 1
    end
    local posx = (resx / 2 + transitionShakePosOffset) / scale; -- counteract scaling
    local posy = desh - (desh*bottomOffsetMultiplier) + transitionShakePosOffset;

    local chainNumbers = chainNumbersReg --regular
    if comboState == 2 then
        chainNumbers = chainNumbersPUC --puc
    elseif comboState == 1 then
        chainNumbers = chainNumbersUC --uc

        if (not game.GetSkinSetting('gameplay_ucDifferentColor')) then
            chainNumbers = chainNumbersPUC -- force the PUC numbers in case the setting is turned off
        end
    end

    gfx.Scale(scale, scale)

    -- \_ chain _/
    local tw, th
    tw, th = gfx.ImageSize(chainLabel)
    gfx.BeginPath()
    gfx.ImageRect(posx - tw * 0.85 / 2, posy - 220, tw * 0.85, th * 0.85, chainLabel, 1, 0)

    tw, th = gfx.ImageSize(chainNumbers[1])
    posy = posy - th + 32

    local comboScale = 0.45;
    Numbers.draw_number(posx - (tw*4*comboScale)/2+(tw*comboScale*1.5)+10, posy - th / 2, 1.0, combo, 4, chainNumbers, true, comboScale, 1.12)

    gfx.ResetTransform()

    gfx.Restore();
end

return {
    onNewCombo=onNewCombo,
    render=render
}