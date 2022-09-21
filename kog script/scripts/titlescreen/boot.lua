local Dim = require("common.dimensions")
local Wallpaper = require("components.wallpaper")
local BootPage = require("titlescreen.pages.boot.bootpage")
local PageView = require("components.pager.pageview")

local bootpage = BootPage.new()
local pageview = PageView.new(bootpage)

local function render(deltaTime)
    Dim.updateResolution()

    Wallpaper.render()

    Dim.transformToScreenSpace()

    pageview:render(deltaTime)

    --pageview will be empty when you `back()` out of the root page
    if not pageview:get() then
        return {eventType = "switch", toScreen = "splash"}
    end
end

local function onButtonPressed(button)
    pageview:get():handleButtonInput(button)
end

return {render = render, onButtonPressed = onButtonPressed}