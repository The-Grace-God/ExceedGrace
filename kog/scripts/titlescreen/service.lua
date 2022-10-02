local Dim = require("common.dimensions")
local Wallpaper = require("components.wallpaper")

local PageView = require("components.pager.pageview")
local MainMenuPage = require("titlescreen.pages.service.mainmenupage")

--[[ WIP: REIMPLEMENTATION

local rootMenu = {
    {label = "IDOLS", children = {{label = "GRACEv6"}, {label = "NEARNOAHv6"}, {label = "IDKv6"}}},
    {
        label = "LASER COLORS",
        children = {
            {
                label = "LEFT LASER",
                children = {
                    {label = "BLUE", color = {0, 128, 255}},
                    {label = "PINK", color = {255, 0, 255}},
                    {label = "GREEN", color = {0, 255, 0}},
                    {label = "YELLOW", color = {255, 255, 0}},
                },
            },
            {
                label = "RIGHT LASER",
                children = {{label = "BLUE"}, {label = "PINK"}, {label = "GREEN"}, {label = "YELLOW"}},
            },
        },
    },
}

]]

local currentpage = MainMenuPage.new()

local pageview = PageView.new(currentpage)

local function reset()
    pageview = PageView.new(currentpage)
end

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

return {reset = reset, render = render, onButtonPressed = onButtonPressed}
