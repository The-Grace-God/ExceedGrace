local Version = require('common.version')
local Dim = require("common.dimensions")

local Wallpaper = require("components.wallpaper")

local splash1Image = gfx.CreateSkinImage('titlescreen/title/background.png', 0)

local triggerModeSelect = false
local triggerServiceMenu = false

local versionString = Version.getLongVersion()

local function render(deltaTime)
    Dim.updateResolution()

    Wallpaper.render()

    Dim.transformToScreenSpace()

    gfx.BeginPath()
    gfx.ImageRect(0, 0, Dim.design.width, Dim.design.height, splash1Image, 1, 0)

    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(255, 255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.FontSize(28)

    gfx.Text(versionString, 10, 10)

    if (triggerModeSelect) then
        triggerModeSelect = false
        return {
            eventType = 'switch',
            toScreen = 'mode_select'
        }
    end

    if (triggerServiceMenu) then
        triggerServiceMenu = false
        return {
            eventType = 'switch',
            toScreen = 'service'
        }
    end
end

local function onButtonPressed(button)
    if button == game.BUTTON_FXR and game.GetButton(game.BUTTON_FXL) or
        button == game.BUTTON_FXL and game.GetButton(game.BUTTON_FXR) then
        triggerServiceMenu = true
    end

    if button == game.BUTTON_STA then
        triggerModeSelect = true
    end
end

return {
    render = render,
    onButtonPressed = onButtonPressed
}