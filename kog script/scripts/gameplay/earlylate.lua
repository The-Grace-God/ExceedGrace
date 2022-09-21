local Dimensions = require "common.dimensions"

-- Used for comparing button_hit()'s delta parameter with the
-- gameplay_earlyLateFor/gameplay_msDisplay skin settings values.
-- If the number is <= delta then the EarlyLate/ms should be shown
local compare = {
    ["ALL"] = 2,
    ["CRITICAL (or worse)"] = 2,
    ["NEAR (or worse)"] = 1,
    ["NONE"] = -1,
    ["OFF"] = -1
}

local portraitHeightFractions = {
    ["UPPER+"] = 2.4,
    ["UPPER"] = 3,
    ["STANDARD"] = 4.2,
    ["LOWER"] = 5.3,
}

local landscapeHeightFractions = {
    ["UPPER+"] = 1.5,
    ["UPPER"] = 2.7,
    ["STANDARD"] = 4.1,
    ["LOWER"] = 6.7,
}

local earlyLateFor = compare[game.GetSkinSetting("gameplay_earlyLateFor")]
local msFor = compare[game.GetSkinSetting("gameplay_msFor")]
local earlyLatePosition = game.GetSkinSetting("gameplay_earlyLatePosition")

local EarlyLate = {
    timer = 0,
    color = {},
    earlyLateText = "",
    millisecText = ""
}

function EarlyLate.render(deltaTime)
    if EarlyLate.timer <= 0 then
        return
    end

    EarlyLate.timer = EarlyLate.timer - deltaTime * 100

    local screenW, screenH = Dimensions.screen.width, Dimensions.screen.height
    local screenCenterX = screenW / 2

    local desh, fractionTable

    if screenH > screenW then
        desh = 1600
        fractionTable = portraitHeightFractions
    else
        desh = 1080
        fractionTable = landscapeHeightFractions
    end

    local scale = screenH / desh
    local y = screenH / 8 * fractionTable[earlyLatePosition]

    gfx.BeginPath()
    gfx.LoadSkinFont("Digital-Serial-ExtraBold.ttf")
    gfx.FontSize(20 * scale)

    local color = EarlyLate.color
    gfx.FillColor(color[1], color[2], color[3])
    
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)

    gfx.FastText(EarlyLate.earlyLateText, screenCenterX - 100 * scale, y)
    gfx.FastText(EarlyLate.millisecText, screenCenterX + 100 * scale, y)
end

function EarlyLate.TriggerAnimation(rating, millisec)
    local showEarlyLate = rating <= earlyLateFor
    local showMillisec = rating <= msFor
    local isEarly = millisec < 0

    if millisec == 0 then return end
    if not showEarlyLate and not showMillisec then return end

    if showEarlyLate then
        EarlyLate.earlyLateText = isEarly and "EARLY" or "LATE"
    else
        EarlyLate.earlyLateText = ""
    end

    if showMillisec then
        local millisecText = string.format("%dms", millisec)

        -- prepend + sign for lates
        millisecText = isEarly and millisecText or "+"..millisecText

        EarlyLate.millisecText = millisecText
    else
        EarlyLate.millisecText = ""
    end

    if isEarly then
        EarlyLate.color = {206, 94, 135}
    else
        EarlyLate.color = {53, 102, 197}
    end

    EarlyLate.timer = 120
end

return EarlyLate