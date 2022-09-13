local Common = require("common.util")
local Dim = require("common.dimensions")
local Wallpaper = require("components.wallpaper")
local Easing = require("common.easing")

local splash1BgColor = {182, 0, 20}
local splash1Logo = gfx.CreateSkinImage("titlescreen/splash/ksm.png", 0)
local splash1LogoWidth, splash1LogoHeight = gfx.ImageSize(splash1Logo)

local splash2BgColor = {255, 255, 255}
local splash2Logo = gfx.CreateSkinImage("titlescreen/splash/usc2.png", 0)
local splash2LogoWidth, splash2LogoHeight = gfx.ImageSize(splash2Logo)

local splash3BgColor = {255, 255, 255}
local splash3Logo = gfx.CreateSkinImage("titlescreen/splash/team-exceed.png", 0)
local splash3LogoWidth, splash3LogoHeight = gfx.ImageSize(splash3Logo)

local splashState = "init"
local splashTimer = 0
local fadeDuration = 0.5
local fadeAlpha = 0
local splashInitDuration = 1
local splash1Duration = 4
local splash2Duration = 4
local splash3Duration = 4

game.LoadSkinSample("titlescreen/splash/splash1.wav")
local splash1SfxPlayed = false

local triggerSkip = false

local function calcFade(splashDuration)
    local t = splashDuration - splashTimer
    if t < fadeDuration then
        fadeAlpha = Easing.linear(t, 0, 255, fadeDuration) -- fade in
    elseif splashTimer < fadeDuration then
        fadeAlpha = Easing.linear(splashTimer, 0, 255, fadeDuration) -- fade out
    else
        --fadeAlpha = 255
    end
    fadeAlpha = Common.round(Common.clamp(fadeAlpha, 0, 255))
end

local function initSplash(deltaTime)
    if (splashTimer < 0) then
        splashState = "splash1"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splashInitDuration
    end

    splashTimer = splashTimer - deltaTime
end

local function splash1(deltaTime)
    local splash1LogoXOffset = (Dim.design.width - splash1LogoWidth) / 2
    local splash1LogoYOffset = (Dim.design.height - splash1LogoHeight) / 2

    calcFade(splash1Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash1BgColor[1], splash1BgColor[2], splash1BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash1LogoXOffset, splash1LogoYOffset, splash1LogoWidth, splash1LogoHeight, splash1Logo, fadeAlpha / 255, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(255, 255, 255, fadeAlpha)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(28)

    gfx.Text("Press START to skip...", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "splash2"
        splash1SfxPlayed = false
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash1Duration
    end

    if not splash1SfxPlayed then
        game.PlaySample("titlescreen/splash/splash1.wav")
        splash1SfxPlayed = true
    end

    splashTimer = splashTimer - deltaTime
end

local function splash2(deltaTime)
    local splash2LogoXOffset = (Dim.design.width - splash2LogoWidth) / 2
    local splash2LogoYOffset = (Dim.design.height - splash2LogoHeight) / 2

    calcFade(splash2Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash2BgColor[1], splash2BgColor[2], splash2BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash2LogoXOffset, splash2LogoYOffset, splash2LogoWidth, splash2LogoHeight, splash2Logo, fadeAlpha / 255, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(0, 0, 0, fadeAlpha)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(28)

    gfx.Text("Press START to skip...", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "splash3"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash2Duration
    end

    splashTimer = splashTimer - deltaTime
end

local function splash3(deltaTime)
    local splash3LogoXOffset = (Dim.design.width - splash3LogoWidth) / 2
    local splash3LogoYOffset = (Dim.design.height - splash3LogoHeight) / 2

    calcFade(splash3Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash3BgColor[1], splash3BgColor[2], splash3BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash3LogoXOffset, splash3LogoYOffset, splash3LogoWidth, splash3LogoHeight, splash3Logo, fadeAlpha / 255, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(0, 0, 0, fadeAlpha)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(28)

    gfx.Text("Press START to skip...", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "done"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash3Duration
    end

    splashTimer = splashTimer - deltaTime
end

local function reset()
    triggerSkip = false
    splashState = "init"
    splashTimer = 0
    splash1SfxPlayed = false
end

function render(deltaTime)
    if triggerSkip then
        reset()
        game.StopSample("titlescreen/splash/splash1.wav")
        return {
            eventType = "switch",
            toScreen = "title"
        }
    end

    Dim.updateResolution()

    Wallpaper.render()

    Dim.transformToScreenSpace()

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(255, 255, 255)
    gfx.Fill()

    if splashState == "init" then
        initSplash(deltaTime)
    elseif splashState == "splash1" then
        splash1(deltaTime)
    elseif splashState == "splash2" then
        splash2(deltaTime)
    elseif splashState == "splash3" then
        splash3(deltaTime)
    elseif splashState == "done" then
        reset()
        return {
            eventType = "switch",
            toScreen = "title"
        }
    else
        game.Log("Splash screen state error, splashState: " .. splashState, game.LOGGER_ERROR)
        splashState = "done"
    end
end

local function onButtonPressed(button)
    if button == game.BUTTON_STA then
        triggerSkip = true
    end
end

return {
    render = render,
    onButtonPressed = onButtonPressed
}