require("common.globals")
local Common = require("common.util")

local bootScreen = require('titlescreen.boot')
local splashScreen = require('titlescreen.splash')
local titleScreen = require('titlescreen.title')
local modeSelectScreen = require('titlescreen.modeselect')
local serviceScreen = require('titlescreen.service')

local screens = {
    boot = {
        screen = bootScreen
    },
    splash = {
        screen = splashScreen
    },
    title = {
        screen = titleScreen
    },
    mode_select = {
        screen = modeSelectScreen
    },
    service = {
        screen = serviceScreen
    }
}

local currentScreen = game.GetSkinSetting("animations_skipIntro") and screens.title or screens.boot -- show boot screen if skipIntro is not set

local function deltaKnob(delta)
    if math.abs(delta) > 1.5 * math.pi then
        return delta + 2 * math.pi * Common.sign(delta) * -1
    end
    return delta
end

local lastKnobs = nil
local knobProgress = 0
local function handleKnobs()
    if not currentScreen.screen.onKnobsChange then
        return
    end

    if lastKnobs == nil then
        lastKnobs = {game.GetKnob(0), game.GetKnob(1)}
    else
        local newKnobs = {game.GetKnob(0), game.GetKnob(1)}

        knobProgress = knobProgress - deltaKnob(lastKnobs[1] - newKnobs[1]) * 1.2
        knobProgress = knobProgress - deltaKnob(lastKnobs[2] - newKnobs[2]) * 1.2

        lastKnobs = newKnobs

        if math.abs(knobProgress) > 1 then
            if (knobProgress < 0) then
                -- Negative
                currentScreen.screen.onKnobsChange(-1)
            else
                -- Positive
                currentScreen.screen.onKnobsChange(1)
            end
            knobProgress = knobProgress - Common.roundToZero(knobProgress)
        end
    end
end

local function handleScreenResponse(res)
    if res and res.eventType == 'switch' then
        if not screens[res.toScreen] then
            game.Log('Undefined screen ' .. res.toScreen, game.LOGGER_ERROR)
            return
        end
        currentScreen = screens[res.toScreen]
        if currentScreen.screen.reset then
            currentScreen.screen.reset()
        end
    end
end

function render(deltaTime)
    handleKnobs()

    handleScreenResponse(currentScreen.screen.render(deltaTime))
end

function mouse_pressed(button)
    if (currentScreen.screen.onMousePressed) then
        currentScreen.screen.onMousePressed(button)
    end
    return 0
end

function button_pressed(button)
    if (currentScreen.screen.onButtonPressed) then
        currentScreen.screen.onButtonPressed(button)
    end
end
