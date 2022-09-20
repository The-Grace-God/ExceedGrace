local Common = require("common.util")
local Dim = require("common.dimensions")
local Wallpaper = require("components.wallpaper")
local Easing = require("common.easing")

local splash1BgColor = {0, 0, 0}
local splash1Logo = gfx.CreateSkinImage("titlescreen/splash/copywrong.png", 0)
local splash1LogoWidth, splash1LogoHeight = gfx.ImageSize(splash1Logo)

local splash2BgColor = {182, 0, 20}
local splash2Logo = gfx.CreateSkinImage("titlescreen/splash/konami.png", 0)
local splash2LogoWidth, splash2LogoHeight = gfx.ImageSize(splash2Logo)

local splash3BgColor = {255, 255, 255}
local splash3Logo = gfx.CreateSkinImage("titlescreen/splash/bemani.png", 0)
local splash3LogoWidth, splash3LogoHeight = gfx.ImageSize(splash3Logo)

local splash4BgColor = {255, 255, 255}
local splash4Logo = gfx.CreateSkinImage("titlescreen/splash/e-amusement.png", 0)
local splash4LogoWidth, splash4LogoHeight = gfx.ImageSize(splash4Logo)

local splash5BgColor = {255, 255, 255}
local splash5Logo = gfx.CreateSkinImage("titlescreen/splash/RSA.png", 0)
local splash5LogoWidth, splash5LogoHeight = gfx.ImageSize(splash5Logo)

local splash6BgColor = {0, 0, 0}
local splash6Logo = gfx.CreateSkinImage("titlescreen/splash/livin.png", 0)
local splash6LogoWidth, splash6LogoHeight = gfx.ImageSize(splash6Logo)

local splash7BgColor = {0, 0, 0}
local splash7Logo = gfx.CreateSkinImage("titlescreen/splash/RSA.png", 0)
local splash7LogoWidth, splash7LogoHeight = gfx.ImageSize(splash7Logo)

local splash8BgColor = {0, 0, 0}
local splash8Logo = gfx.CreateSkinImage("titlescreen/splash/RSA.png", 0)
local splash8LogoWidth, splash8LogoHeight = gfx.ImageSize(splash8Logo)

local splashState = "init"
local splashTimer = 0
local fadeDuration = 0.5
local fadeAlpha = 0
local splashInitDuration = 1
local splash1Duration = 4
local splash2Duration = 4
local splash3Duration = 4
local splash4Duration = 4
local splash5Duration = 4
local splash6Duration = 4
local splash7Duration = 4
local splash8Duration = 4


game.LoadSkinSample("titlescreen/splash/splash1.wav")
game.LoadSkinSample("titlescreen/splash/swoosh.wav")
local splash2SfxPlayed = false
local SwooshSfxPlayed = false
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

    gfx.Text("", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "splash2"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash1Duration
    end
	
	if not SwooshSfxPlayed then
        game.PlaySample("titlescreen/splash/swoosh.wav")
        SwooshSfxPlayed = true
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

    gfx.Text("", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "splash3"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash2Duration
    end
	
	if not splash2SfxPlayed then
        game.PlaySample("titlescreen/splash/splash1.wav")
        splash2SfxPlayed = true
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

    gfx.Text("", 10, Dim.design.height - 10)

     if (splashTimer < 0) then
        splashState = "splash4"
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

local function splash4(deltaTime)
    local splash4LogoXOffset = (Dim.design.width - splash4LogoWidth) / 2
    local splash4LogoYOffset = (Dim.design.height - splash4LogoHeight) / 2

    calcFade(splash4Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash4BgColor[1], splash4BgColor[2], splash4BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash4LogoXOffset, splash4LogoYOffset, splash4LogoWidth, splash4LogoHeight, splash4Logo, fadeAlpha / 255, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(0, 0, 0, fadeAlpha)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(28)

    gfx.Text("", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "splash5"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash4Duration
    end

    splashTimer = splashTimer - deltaTime
end

local function splash5(deltaTime)
    local splash5LogoXOffset = (Dim.design.width - splash5LogoWidth) / 2
    local splash5LogoYOffset = (Dim.design.height - splash5LogoHeight) / 2

    calcFade(splash5Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash5BgColor[1], splash5BgColor[2], splash5BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash5LogoXOffset, splash5LogoYOffset, splash5LogoWidth, splash5LogoHeight, splash5Logo, fadeAlpha / 255, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(0, 0, 0, fadeAlpha)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(28)

    gfx.Text("", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "splash6"
        splashTimer = 0
        return
    end


    if splashTimer == 0 then
        splashTimer = splash5Duration
    end

    splashTimer = splashTimer - deltaTime
end

local function splash6(deltaTime)
    local splash6LogoXOffset = (Dim.design.width - splash6LogoWidth) / 2
    local splash6LogoYOffset = (Dim.design.height - splash6LogoHeight) / 2

    calcFade(splash6Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash6BgColor[1], splash6BgColor[2], splash6BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash6LogoXOffset, splash6LogoYOffset, splash6LogoWidth, splash6LogoHeight, splash6Logo, fadeAlpha / 255, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(0, 0, 0, fadeAlpha)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(28)

    gfx.Text("", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "done"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash6Duration
    end

    splashTimer = splashTimer - deltaTime
end

local function splash7(deltaTime)
    local splash7LogoXOffset = (Dim.design.width - splash7LogoWidth) / 2
    local splash7LogoYOffset = (Dim.design.height - splash7LogoHeight) / 2

    calcFade(splash7Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash7BgColor[1], splash7BgColor[2], splash7BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash7LogoXOffset, splash7LogoYOffset, splash7LogoWidth, splash7LogoHeight, splash7Logo, fadeAlpha / 255, 0)

    gfx.BeginPath()
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(0, 0, 0, fadeAlpha)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(28)

    gfx.Text("", 10, Dim.design.height - 10)

    if (splashTimer < 0) then
        splashState = "done"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash7Duration
    end
	
		if not Swoosh3SfxPlayed then
        game.PlaySample("titlescreen/splash/swoosh.wav")
        Swoosh3SfxPlayed = true
    end

    splashTimer = splashTimer - deltaTime
end

local function splash8(deltaTime)
    local splash8LogoXOffset = (Dim.design.width - splash8LogoWidth) / 2
    local splash8LogoYOffset = (Dim.design.height - splash8LogoHeight) / 2

    calcFade(splash8Duration)

    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(splash8BgColor[1], splash8BgColor[2], splash8BgColor[3], fadeAlpha)
    gfx.Fill()

    gfx.BeginPath()
    gfx.ImageRect(splash8LogoXOffset, splash8LogoYOffset, splash8LogoWidth, splash8LogoHeight, splash8Logo, fadeAlpha / 255, 0)

  

    if (splashTimer < 0) then
        splashState = "done"
        splashTimer = 0
        return
    end

    if splashTimer == 0 then
        splashTimer = splash8Duration
    end
		
		if not Swoosh4SfxPlayed then
        game.PlaySample("titlescreen/splash/swoosh.wav")
        Swoosh4SfxPlayed = true
    end

    splashTimer = splashTimer - deltaTime
end

function render(deltaTime)
    if triggerSkip then
        reset()
        game.StopSample("titlescreen/splash/splash1.wav")
		game.StopSample("titlescreen/splash/swoosh.wav")
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
 elseif splashState == "splash4" then
        splash4(deltaTime)
    elseif splashState == "splash5" then
        splash5(deltaTime)
    elseif splashState == "splash6" then
        splash6(deltaTime)
	elseif splashState == "done" then
        splash6(deltaTime)
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