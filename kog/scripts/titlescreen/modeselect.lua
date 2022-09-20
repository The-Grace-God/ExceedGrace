
local Footer = require("components.footers.footer")
local Wallpaper = require("components.wallpaper")
local Background = require("components.background")
local Dim = require("common.dimensions")
local lang = require("language.call")
local util = require("common.util")

local cursorIndex = 3
local buttonHeight = 128 + 16

local SELECTOR_BAR_OFFSET_FROM_CENTER = 128

local BAR_ALPHA = 191
local HEADER_HEIGHT = 100

local crew = game.GetSkinSetting("single_idol")
local type = "/idle"

local resources = {
    images = {
        headerTitleImage = gfx.CreateSkinImage("titlescreen/title.png", 0),
        selectorBgImage = gfx.CreateSkinImage("titlescreen/selector_bg.png", 0),
        selectorArrowsImage = gfx.CreateSkinImage("titlescreen/selector_arrows.png", 0),
        unselectedButtonImage = gfx.CreateSkinImage("titlescreen/unselected_button.png", 0),
        selectedButtonBgImage = gfx.CreateSkinImage("titlescreen/selected_button_bg.png", 0),
        selectedButtonOverImage = gfx.CreateSkinImage("titlescreen/selected_button_over.png", 0)
    },
    anims = {
        idolAnimation = gfx.LoadSkinAnimation("crew/anim/"..crew..type, 1 / 30, 0, true),
    },
    audiosamples = {
        bgm = "titlescreen/bgm.wav",
        cursorChange = "titlescreen/cursor_change.wav",
        cursorSelect = "titlescreen/cursor_select.wav"
    },
    labels = {
        selectorDescriptionLabel = gfx.CreateLabel(lang.Start.desc, 22, 0),
        selectorLegendScrollLabel = gfx.CreateLabel(lang.Start.sc, 20, 0),
        selectorLegendSelectLabel = gfx.CreateLabel(lang.Start.st3, 20, 0)
    }
}

-- load audio samples
for _, path in pairs(resources.audiosamples) do
    game.LoadSkinSample(path)
end

local buttons = {
    {
        labelImage = gfx.CreateSkinImage("titlescreen/labels/skill.png", 0),
        labelWidth = 412,
        action = nil, -- Menu.Challenges,
        description = lang.Challanges.ch,
        details = lang.Challanges.ch1,
    },
	{
        labelImage = gfx.CreateSkinImage("titlescreen/labels/normal-2.png", 0),
        labelWidth = 384,
        action = nil, -- Menu.Start,
        description = lang.Start.st,
        details = lang.Start.st2,
    },
	{
        labelImage = gfx.CreateSkinImage("titlescreen/labels/normal.png", 0),
        labelWidth = 210,
        action = nil, -- Menu.Start,
        description = lang.Start.st,
        details = lang.Start.st2,
    },
    {
        labelImage = gfx.CreateSkinImage("titlescreen/labels/friend.png", 0),
        labelWidth = 169,
        action = nil, -- Menu.Multiplayer,
        description = lang.Multiplayer.mp,
        details = lang.Multiplayer.mp2,
    },
	{
        labelImage = gfx.CreateSkinImage("titlescreen/labels/settings.png", 0),
        labelWidth = 420,
        action = nil, -- Menu.Settings,
        description = lang.Settings.se,
        details = lang.Settings.se1,
    },
    {
        labelImage = gfx.CreateSkinImage("titlescreen/labels/nautica.png", 0),
        labelWidth = 370,
        action = nil, -- Menu.DLScreen,
        description = lang.Nautica.dls,
        details = lang.Nautica.dls2,
    },
    {
        labelImage = gfx.CreateSkinImage("titlescreen/labels/exit.png", 0),
        labelWidth = 225,
        action = nil, -- Menu.Exit,
        description = lang.Exit.ex,
        details = lang.Exit.ex2,
    },
}

local miscButtons = {
    upArrow = {
        x = Dim.design.width - 265,
        y = Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER - buttonHeight + 4,
        w = 64,
        h = 36
    },
    downArrow =  {
        x = Dim.design.width - 265,
        y = Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER + buttonHeight / 2 + 28,
        w = 64,
        h = 36
    },
    mainButton = {
        x = Dim.design.width - 512,
        y = Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER - buttonHeight / 2 - 28,
        w = 505,
        h = 196
    },
    upButton1 = {
        x = Dim.design.width - 512,
        y = Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER - 128 - buttonHeight,
        w = 1026 / 2,
        h = 257 / 2
    },
    upButton2 = {
        x = Dim.design.width - 512,
        y = Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER - 128 - buttonHeight * 2,
        w = 1026 / 2,
        h = 257 / 2
    },
    downButton1 = {
        x = Dim.design.width - 512,
        y = Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER + 128 + 10,
        w = 1026 / 2,
        h = 257 / 2
    },
    downButton2 = {
        x = Dim.design.width - 512,
        y = Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER + 128 + buttonHeight + 10,
        w = 1026 / 2,
        h = 257 / 2
    },
}

local scrollTransitionScale = 1 -- Goes from 0 to 1 when transition is happening, sits at 1 when it's not.
local buttonsMovementScale = 0 -- Basically same as `scrollTransitionScale` but with a +/- sign for the scroll direction and goes from 1 to 0

local idolAnimTransitionScale = 0

local oldCursorIndex = 3
local scrollingUp = false
local playedBgm = false

local triggerServiceMenu = false

local function setButtonActions()
    buttons[1].action = Menu.Challenges
    buttons[2].action = Menu.Multiplayer
    buttons[3].action = Menu.Start
    buttons[4].action = Menu.DLScreen
    buttons[5].action = Menu.Settings
    buttons[6].action = Menu.Exit
end

local function draw_button(button, x, y, selected, index)
    if (selected) then
        -- Draw button background
        gfx.BeginPath()
        gfx.ImageRect(x, y + (196 / 2 * (1 - scrollTransitionScale)), 505, 196 * scrollTransitionScale,
            resources.images.selectedButtonBgImage, 1, 0)
        -- Draw button main label
        gfx.BeginPath()
        gfx.ImageRect(x + 256 - (button.labelWidth / 2), (y + 58) + (64 / 2 * (1 - scrollTransitionScale)),
            button.labelWidth, 64 * scrollTransitionScale, button.labelImage, 1, 0)

        -- Draw description

        gfx.GlobalAlpha((scrollTransitionScale - 0.8) * 5)
        gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
        gfx.FontSize(40)
        gfx.BeginPath()
        gfx.Text(button.description, x + 256, y + 28)
        gfx.GlobalAlpha(1)

        -- Draw the glow overlay
        gfx.BeginPath()
        gfx.ImageRect(x + 2, (y - 42) + (277 / 2 * (1 - scrollTransitionScale)), 501, 277 * scrollTransitionScale,
            resources.images.selectedButtonOverImage, 1, 0)
    else
        if scrollingUp then
            if (index == 3 or index == 7) then gfx.GlobalAlpha(1 - scrollTransitionScale) end
            if (index == 2 or index == 5) then gfx.GlobalAlpha(scrollTransitionScale) end
        else
            if (index == 3 or index == 6) then gfx.GlobalAlpha(1 - scrollTransitionScale) end
            if (index == 1 or index == 4) then gfx.GlobalAlpha(scrollTransitionScale) end
        end
        -- Draw button background
        gfx.BeginPath()
        gfx.ImageRect(x, y + buttonsMovementScale * buttonHeight, 1026 / 2, 257 / 2, resources.images.unselectedButtonImage, 1, 0)

        -- Draw button main label
        gfx.BeginPath()
        gfx.ImageRect(x + 64, y + 28 + buttonsMovementScale * buttonHeight, button.labelWidth, 64, button.labelImage, 1,
            0)
        -- Draw description
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        gfx.FontSize(28)
        gfx.BeginPath()
        gfx.Text(button.description, x + 64, y + 18 + buttonsMovementScale * buttonHeight)

        gfx.GlobalAlpha(1)
    end
end

local function getCorrectedButtonIndex(from, offset)
    local buttonsNum = #buttons

    local index = from + offset

    if index < 1 then
        index = buttonsNum + (from + offset) -- this only happens if the offset is negative
    end

    if index > buttonsNum then
        index = offset - (buttonsNum - from) -- this only happens if the offset is positive
    end

    return index
end

local function draw_buttons()
    local indexes = {
        getCorrectedButtonIndex(cursorIndex, -2),
        getCorrectedButtonIndex(cursorIndex, -1),
        cursorIndex,
        getCorrectedButtonIndex(cursorIndex, 1),
        getCorrectedButtonIndex(cursorIndex, 2),
		getCorrectedButtonIndex(cursorIndex, 3),
		getCorrectedButtonIndex(cursorIndex, 4),
    }

    local yBase = Dim.design.height / 2	+ SELECTOR_BAR_OFFSET_FROM_CENTER

    local centerButtonY = yBase - buttonHeight / 2 - 28 -- to fit with the selector bg
    local marginFromDesHCenter = 128

    if scrollingUp then
        draw_button(buttons[indexes[7]], Dim.design.width - 512, yBase - marginFromDesHCenter - buttonHeight * 3, false,
            0) -- Placeholder for fadeout transition
    end

    draw_button(buttons[indexes[1]], Dim.design.width - 512, yBase - marginFromDesHCenter - buttonHeight * 2, false, 1)
    draw_button(buttons[indexes[2]], Dim.design.width - 512, yBase - marginFromDesHCenter - buttonHeight, false, 2)

    draw_button(buttons[indexes[3]], Dim.design.width - 512, centerButtonY, true) -- The main selected center button

    if scrollingUp then
        draw_button(buttons[indexes[3]], Dim.design.width - 512, yBase + marginFromDesHCenter - buttonHeight, false, 3) -- Placeholder for transition that goes to the bottom
    else
        draw_button(buttons[indexes[3]], Dim.design.width - 512, centerButtonY, false, 3) -- Placeholder for transition that goes to the top
    end

    draw_button(buttons[indexes[4]], Dim.design.width - 512, yBase + marginFromDesHCenter + 10, false, 4)
    draw_button(buttons[indexes[5]], Dim.design.width - 512, yBase + marginFromDesHCenter + buttonHeight + 10, false, 5)
	draw_button(buttons[indexes[6]], Dim.design.width - 512, yBase + marginFromDesHCenter + buttonHeight + 155, false, 6)
	draw_button(buttons[indexes[7]], Dim.design.width - 512, yBase + marginFromDesHCenter + buttonHeight + 300, false, 7)

end

local function drawTexts()

    local currentFullDescriptionText = buttons[cursorIndex].details
    gfx.BeginPath()
    gfx.UpdateLabel(resources.labels.selectorDescriptionLabel, currentFullDescriptionText, 22)

    gfx.BeginPath()
    --    gfx.UpdateLabel(resources.labels.selectorLegendScrollLabel, 'SCROLL', 20)

    -- descriptionAlpha = math.abs(selectedButtonScaleY - 0.5) * 2
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)

    -- Description
    gfx.FillColor(255, 255, 255, math.floor(scrollTransitionScale * 255))
    gfx.BeginPath()
    gfx.DrawLabel(resources.labels.selectorDescriptionLabel, 64, Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER - 52)

    -- Legend on the selector
    gfx.FillColor(217, 177, 126)

    gfx.BeginPath()
    gfx.DrawLabel(resources.labels.selectorLegendScrollLabel, 118, Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER + 56)

    gfx.BeginPath()
    gfx.DrawLabel(resources.labels.selectorLegendSelectLabel, 360, Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER + 56)

    gfx.FillColor(255, 255, 255)
end

local function drawHeader()
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, BAR_ALPHA)
    gfx.Rect(0, 0, Dim.design.width, HEADER_HEIGHT)
    gfx.Fill()
    gfx.ClosePath()

    gfx.ImageRect(Dim.design.width / 2 - 200, HEADER_HEIGHT / 2 - 20, 400, 40, resources.images.headerTitleImage, 1, 0)
end

local function draw_titlescreen(deltaTime)
    gfx.LoadSkinFont("segoeui.ttf")

    -- Draw background
    gfx.BeginPath()
    Background.draw(deltaTime)

    idolAnimTickRes = gfx.TickAnimation(resources.anims.idolAnimation, deltaTime)
    if idolAnimTickRes == 1 then
        gfx.GlobalAlpha(idolAnimTransitionScale)

        idolAnimTransitionScale = idolAnimTransitionScale + 1 / 60
        if (idolAnimTransitionScale > 1) then idolAnimTransitionScale = 1 end

        gfx.BeginPath()
        gfx.ImageRect(0, 0, Dim.design.width, Dim.design.height, resources.anims.idolAnimation, 1, 0)
        gfx.GlobalAlpha(1)
    end

    -- Draw selector background
    gfx.BeginPath()
    gfx.ImageRect(0, (Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER) - 280 / 2, 1079, 280, resources.images.selectorBgImage, 1,
        0)

    buttonY = (Dim.design.height / 2) - 2 * (257 + 5)

    draw_buttons()
    drawTexts()

    -- Draw the arrows around the selected button
    gfx.BeginPath()
    gfx.ImageRect(Dim.design.width - 512, Dim.design.height / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER - buttonHeight - 8,
        501, 300, resources.images.selectorArrowsImage, 1, 0)

    -- Draw top and bottom bars
    drawHeader()
    Footer.draw(deltaTime)
end

local function tickTransitions(deltaTime)
    scrollTransitionScale = scrollTransitionScale + deltaTime / 0.2
    if (scrollTransitionScale > 1) then scrollTransitionScale = 1 end

    if scrollingUp then
        buttonsMovementScale = 1 - scrollTransitionScale
    else
        buttonsMovementScale = -1 + scrollTransitionScale
    end
end

local function render(deltaTime)
    if not playedBgm then
        game.PlaySample(resources.audiosamples.bgm, true)
        playedBgm = true
    end

    game.SetSkinSetting("_currentScreen", "title")

    Dim.updateResolution()

    Wallpaper.render()

    Dim.transformToScreenSpace()

    tickTransitions(deltaTime)

    draw_titlescreen(deltaTime)

    if (triggerServiceMenu) then
        triggerServiceMenu = false
        return {eventType = "switch", toScreen = "service"}
    end
end

local function callButtonAction()
    if buttons[cursorIndex].action == nil then setButtonActions() end
    buttons[cursorIndex].action()
end

local function onKnobsChange(direction)
    cursorIndex = util.modIndex(cursorIndex + direction, #buttons)

    scrollTransitionScale = 0 -- Reset transitions and play them

    scrollingUp = false
    if ((cursorIndex > oldCursorIndex and not (cursorIndex == 6 and oldCursorIndex == 1)) or
        (cursorIndex == 1 and oldCursorIndex == 6)) then scrollingUp = true end

    game.PlaySample(resources.audiosamples.cursorChange)

    oldCursorIndex = cursorIndex
end

local function onButtonPressed(button)
    if button == game.BUTTON_STA then
        game.PlaySample(resources.audiosamples.cursorSelect)
        game.StopSample(resources.audiosamples.bgm)

        callButtonAction()

    elseif button == game.BUTTON_BCK then
        Menu.Exit()

    elseif button == game.BUTTON_FXR then
        triggerServiceMenu = true

    end
end

local function onMousePressed(button)
    local mousePosX, mousePosY = Dim.toViewSpace(game.GetMousePos())
    local changeIndex = 0

    if button ~= 0 then
        return
    end

    if util.areaOverlap(mousePosX, mousePosY,
        miscButtons.mainButton.x, miscButtons.mainButton.y, miscButtons.mainButton.w, miscButtons.mainButton.h) then
            game.StopSample(resources.audiosamples.bgm)
            game.PlaySample(resources.audiosamples.cursorSelect)
            callButtonAction()
            return

    elseif util.areaOverlap(mousePosX, mousePosY,
        miscButtons.upArrow.x, miscButtons.upArrow.y, miscButtons.upArrow.w, miscButtons.upArrow.h) or
        util.areaOverlap(mousePosX, mousePosY,
        miscButtons.upButton1.x, miscButtons.upButton1.y, miscButtons.upButton1.w, miscButtons.upButton1.h) then
            changeIndex = -1
            scrollTransitionScale = 0
            scrollingUp = false

    elseif util.areaOverlap(mousePosX, mousePosY,
        miscButtons.downArrow.x, miscButtons.downArrow.y, miscButtons.downArrow.w, miscButtons.downArrow.h) or
        util.areaOverlap(mousePosX, mousePosY,
        miscButtons.downButton1.x, miscButtons.downButton1.y, miscButtons.downButton1.w, miscButtons.downButton1.h) then
            changeIndex = 1
            scrollTransitionScale = 0
            scrollingUp = true

    elseif util.areaOverlap(mousePosX, mousePosY,
        miscButtons.upButton2.x, miscButtons.upButton2.y, miscButtons.upButton2.w, miscButtons.upButton2.h) then
            changeIndex = -2
            scrollTransitionScale = 0
            scrollingUp = false

    elseif util.areaOverlap(mousePosX, mousePosY,
        miscButtons.downButton2.x, miscButtons.downButton2.y, miscButtons.downButton2.w, miscButtons.downButton2.h) then
            changeIndex = 2
            scrollTransitionScale = 0
            scrollingUp = true
    end

    cursorIndex = util.modIndex(cursorIndex + changeIndex, #buttons)
    game.PlaySample(resources.audiosamples.cursorChange)

end

return {
    render = render,
    onKnobsChange = onKnobsChange,
    onButtonPressed = onButtonPressed,
    onMousePressed = onMousePressed,
}
