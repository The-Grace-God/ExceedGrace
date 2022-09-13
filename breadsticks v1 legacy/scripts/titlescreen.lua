
require('common')
local Footer = require('components.footer');
local Background = require('components.background');

local lang = require("language.call")

local cursorIndex = 3;
local buttonHeight = 128 + 16;

local SELECTOR_BAR_OFFSET_FROM_CENTER = 128;

local BAR_ALPHA = 191;
local HEADER_HEIGHT = 100

local buttons = nil
local resx, resy = game.GetResolution()
local desw = 1080
local desh = 1920
local scale;

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", 0)
local headerTitleImage = gfx.CreateSkinImage('titlescreen/title.png', 0);
local selectorBgImage = gfx.CreateSkinImage('titlescreen/selector_bg.png', 0);
local selectorArrowsImage = gfx.CreateSkinImage(
                                'titlescreen/selector_arrows.png', 0);

local unselectedButtonImage = gfx.CreateSkinImage(
                                  'titlescreen/unselected_button.png', 0);

local selectedButtonBgImage = gfx.CreateSkinImage(
                                  'titlescreen/selected_button_bg.png', 0);
local selectedButtonOverImage = gfx.CreateSkinImage(
                                    'titlescreen/selected_button_over.png', 0);

local skillLabelImage = gfx.CreateSkinImage('titlescreen/labels/skill.png', 0);
local friendLabelImage = gfx.CreateSkinImage('titlescreen/labels/friend.png', 0);
local normalLabelImage = gfx.CreateSkinImage('titlescreen/labels/normal.png', 0);
local nauticaLabelImage = gfx.CreateSkinImage('titlescreen/labels/nautica.png',
                                              0);
local settingsLabelImage = gfx.CreateSkinImage(
                               'titlescreen/labels/settings.png', 0);
local exitLabelImage = gfx.CreateSkinImage('titlescreen/labels/exit.png', 0);

local creww = game.GetSkinSetting("single_idol")

-- ANIMS
local idolAnimation = gfx.LoadSkinAnimation('crew/anim/'..creww, 1 / 30, 0, true);

-- AUDIO
game.LoadSkinSample('titlescreen/bgm.wav');
game.LoadSkinSample('titlescreen/cursor_change.wav');
game.LoadSkinSample('titlescreen/cursor_select.wav');

local selectorDescriptionLabel = gfx.CreateLabel(lang.Start.desc , 22, 0);

local selectorLegendScrollLabel = gfx.CreateLabel(lang.Start.sc , 20, 0);
local selectorLegendSelectLabel = gfx.CreateLabel(lang.Start.st3 , 20, 0);

local scrollTransitionScale = 1; -- Goes from 0 to 1 when transition is happening, sits at 1 when it's not.
local buttonsMovementScale = 0; -- Basically same as `scrollTransitionScale` but with a +/- sign for the scroll direction and goes from 1 to 0

local idolAnimTransitionScale = 0;

local oldCursorIndex = 3;
local scrollingUp = false;
local playedBgm = false;

-- Window variables
local resX, resY

-- Aspect Ratios
local landscapeWidescreenRatio = 16 / 9
local landscapeStandardRatio = 4 / 3
local portraitWidescreenRatio = 9 / 16

-- Portrait sizes
local fullX, fullY

local resolutionChange = function(x, y)
    resX = x
    resY = y
    fullX = portraitWidescreenRatio * y
    fullY = y
end

function resetLayoutInformation()
    resx, resy = game.GetResolution()
    desw = 1080
    desh = 1920
    scale = resx / desw
end

draw_button = function(button, x, y, selected, index)
    local labelImage = button[1];
    local labelWidth = button[2];
    local descriptionText = button[4];

    if (selected) then
        -- Draw button background
        gfx.BeginPath();
        gfx.ImageRect(x, y + (196 / 2 * (1 - scrollTransitionScale)), 505,
                      196 * scrollTransitionScale, selectedButtonBgImage, 1, 0);
        -- Draw button main label
        gfx.BeginPath();
        gfx.ImageRect(x + 256 - (labelWidth / 2),
                      (y + 58) + (64 / 2 * (1 - scrollTransitionScale)),
                      labelWidth, 64 * scrollTransitionScale, labelImage, 1, 0);

        -- Draw description

        gfx.GlobalAlpha((scrollTransitionScale - 0.8) * 5)
        gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
        gfx.FontSize(40);
        gfx.BeginPath();
        gfx.Text(descriptionText, x + 256, y + 28);
        gfx.GlobalAlpha(1)

        -- Draw the glow overlay
        gfx.BeginPath();
        gfx.ImageRect(x + 2, (y - 42) + (277 / 2 * (1 - scrollTransitionScale)),
                      501, 277 * scrollTransitionScale, selectedButtonOverImage,
                      1, 0);
    else
        if scrollingUp then
            if (index == 3 or index == 0) then
                gfx.GlobalAlpha(1 - scrollTransitionScale);
            end
            if (index == 2 or index == 5) then
                gfx.GlobalAlpha(scrollTransitionScale);
            end
        else
            if (index == 3 or index == 6) then
                gfx.GlobalAlpha(1 - scrollTransitionScale);
            end
            if (index == 1 or index == 4) then
                gfx.GlobalAlpha(scrollTransitionScale);
            end
        end
        -- Draw button background
        gfx.BeginPath();
        gfx.ImageRect(x, y + buttonsMovementScale * buttonHeight, 1026 / 2,
                      257 / 2, unselectedButtonImage, 1, 0);

        -- Draw button main label
        gfx.BeginPath();
        gfx.ImageRect(x + 64, y + 28 + buttonsMovementScale * buttonHeight,
                      labelWidth, 64, labelImage, 1, 0);
        -- Draw description
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        gfx.FontSize(28);
        gfx.BeginPath();
        gfx.Text(descriptionText, x + 64,
                 y + 18 + buttonsMovementScale * buttonHeight);

        gfx.GlobalAlpha(1)
    end
end;

draw_buttons = function()
    indexes = {
        getCorrectedButtonIndex(cursorIndex, -2),
        getCorrectedButtonIndex(cursorIndex, -1), cursorIndex,
        getCorrectedButtonIndex(cursorIndex, 1),
        getCorrectedButtonIndex(cursorIndex, 2)
    }

    local yBase = desh / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER;

    centerButtonY = yBase - buttonHeight / 2 - 28; -- to fit with the selector bg
    marginFromDesHCenter = 128;

    if scrollingUp then
        draw_button(buttons[indexes[5]], desw - 512,
                    yBase - marginFromDesHCenter - buttonHeight * 3, false, 0); -- Placeholder for fadeout transition
    end

    draw_button(buttons[indexes[1]], desw - 512,
                yBase - marginFromDesHCenter - buttonHeight * 2, false, 1);
    draw_button(buttons[indexes[2]], desw - 512,
                yBase - marginFromDesHCenter - buttonHeight, false, 2);

    draw_button(buttons[indexes[3]], desw - 512, centerButtonY, true); -- The main selected center button

    if scrollingUp then
        draw_button(buttons[indexes[3]], desw - 512,
                    yBase + marginFromDesHCenter - buttonHeight, false, 3); -- Placeholder for transition that goes to the bottom
    else
        draw_button(buttons[indexes[3]], desw - 512, centerButtonY, false, 3); -- Placeholder for transition that goes to the top
    end

    draw_button(buttons[indexes[4]], desw - 512,
                yBase + marginFromDesHCenter + 10, false, 4);
    draw_button(buttons[indexes[5]], desw - 512,
                yBase + marginFromDesHCenter + buttonHeight + 10, false, 5);

    if not scrollingUp then
        draw_button(buttons[indexes[1]], desw - 512,
                    yBase + marginFromDesHCenter + buttonHeight * 2, false, 6);
    end
end;

function getCorrectedButtonIndex(from, offset)
    buttonsNum = #buttons;

    index = from + offset;

    if index < 1 then
        index = buttonsNum + (from + offset) -- this only happens if the offset is negative
    end

    if index > buttonsNum then
        indexesUntilEnd = buttonsNum - from;
        index = offset - indexesUntilEnd -- this only happens if the offset is positive
    end

    return index;
end

function drawTexts()

    currentFullDescriptionText = buttons[cursorIndex][5];
    gfx.BeginPath();
    gfx.UpdateLabel(selectorDescriptionLabel, currentFullDescriptionText, 22)

    gfx.BeginPath();
--    gfx.UpdateLabel(selectorLegendScrollLabel, 'SCROLL', 20);

    -- descriptionAlpha = math.abs(selectedButtonScaleY - 0.5) * 2;
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);

    -- Description
    gfx.FillColor(255, 255, 255, math.floor(scrollTransitionScale * 255));
    gfx.BeginPath();
    gfx.DrawLabel(selectorDescriptionLabel, 64,
                  desh / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER - 52);

    -- Legend on the selector
    gfx.FillColor(217, 177, 126);

    gfx.BeginPath();
    gfx.DrawLabel(selectorLegendScrollLabel, 118,
                  desh / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER + 56);

    gfx.BeginPath();
    gfx.DrawLabel(selectorLegendSelectLabel, 360,
                  desh / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER + 56);

    gfx.FillColor(255, 255, 255);
end

function setButtons()
    if buttons == nil then
        buttons = {}
        buttons[1] = {
            skillLabelImage, 412, Menu.Challenges,
            lang.Challanges.ch,  lang.Challanges.ch1
        }
        buttons[2] = {
            friendLabelImage, 169, Menu.Multiplayer,
            lang.Multiplayer.mp, lang.Multiplayer.mp2
        }
        buttons[3] = {
            normalLabelImage, 210, Menu.Start,
            lang.Start.st, lang.Start.st2
        }
        buttons[4] = {
            nauticaLabelImage, 230, Menu.DLScreen,
            lang.Nautica.dls, lang.Nautica.dls2
        }
        buttons[5] = {
            settingsLabelImage, 247, Menu.Settings,
            lang.Settings.se, lang.Settings.se1
        }
        buttons[6] = {
            exitLabelImage, 110, Menu.Exit,
            lang.Exit.ex, lang.Exit.ex2
        }
    end
end

function drawHeader()
    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, BAR_ALPHA);
    gfx.Rect(0, 0, desw, HEADER_HEIGHT);
    gfx.Fill();
    gfx.ClosePath()

    gfx.ImageRect(desw/2 - 200, HEADER_HEIGHT/2 - 20, 400, 40, headerTitleImage, 1, 0)
end

function sign(x) return x > 0 and 1 or x < 0 and -1 or 0 end

function roundToZero(x)
    if x < 0 then
        return math.ceil(x)
    elseif x > 0 then
        return math.floor(x)
    else
        return 0
    end
end

function deltaKnob(delta)
    if math.abs(delta) > 1.5 * math.pi then
        return delta + 2 * math.pi * sign(delta) * -1
    end
    return delta
end

local lastKnobs = nil
local knobProgress = 0
function handle_controller()
    if lastKnobs == nil then
        lastKnobs = {game.GetKnob(0), game.GetKnob(1)}
    else
        local newKnobs = {game.GetKnob(0), game.GetKnob(1)}

        knobProgress = knobProgress - deltaKnob(lastKnobs[1] - newKnobs[1]) *
                           1.2
        knobProgress = knobProgress - deltaKnob(lastKnobs[2] - newKnobs[2]) *
                           1.2

        lastKnobs = newKnobs

        if math.abs(knobProgress) > 1 then
            cursorIndex = (((cursorIndex - 1) + roundToZero(knobProgress)) %
                              #buttons) + 1

            scrollTransitionScale = 0; -- Reset transitions and play them

            scrollingUp = false;
            if ((cursorIndex > oldCursorIndex and
                not (cursorIndex == 6 and oldCursorIndex == 1)) or
                (cursorIndex == 1 and oldCursorIndex == 6)) then
                scrollingUp = true;
            end

            game.PlaySample('titlescreen/cursor_change.wav');

            oldCursorIndex = cursorIndex;

            knobProgress = knobProgress - roundToZero(knobProgress)
        end
    end
end

draw_titlescreen = function (x, y, w, h, deltaTime)
    gfx.Scissor(x,y,w,h);
    gfx.Translate(x,y);
    gfx.Scale(w/1080, h/1920);

    gfx.LoadSkinFont("segoeui.ttf")

    -- Draw background
    gfx.BeginPath();
    Background.draw(deltaTime)

    local idolAnimTickRes = gfx.TickAnimation(idolAnimation, deltaTime);
    if idolAnimTickRes == 1 then
        gfx.GlobalAlpha(idolAnimTransitionScale);

        idolAnimTransitionScale = idolAnimTransitionScale + 1 / 60;
        if (idolAnimTransitionScale > 1) then
            idolAnimTransitionScale = 1;
        end

        gfx.BeginPath();
        gfx.ImageRect(0, 0, desw, desh, idolAnimation, 1, 0);
        gfx.GlobalAlpha(1);
    end

    -- Draw selector background
    gfx.BeginPath();
    gfx.ImageRect(0, (desh / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER) - 280 / 2,
                  1079, 280, selectorBgImage, 1, 0);

    setButtons()

    buttonY = (desh / 2) - 2 * (257 + 5);

    draw_buttons();
    drawTexts();

    -- Draw the arrows around the selected button
    gfx.BeginPath();
    gfx.ImageRect(desw - 512, desh / 2 + SELECTOR_BAR_OFFSET_FROM_CENTER -
                      buttonHeight - 8, 501, 300, selectorArrowsImage, 1, 0);

    -- Draw top and bottom bars
    drawHeader();
    Footer.draw(deltaTime);

    gfx.ResetTransform();
end

render = function(deltaTime)
    if not playedBgm then
        game.PlaySample('titlescreen/bgm.wav', true);
        playedBgm = true;
    end

    game.SetSkinSetting('_currentScreen', 'title')

    -- detect resolution change
    local resx, resy = game.GetResolution();
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    gfx.BeginPath()
   

    draw_titlescreen((resX - fullX) / 2, 0, fullX, fullY, deltaTime);

    handle_controller()

    scrollTransitionScale = scrollTransitionScale + 1 / 60 * 5;
    if (scrollTransitionScale > 1) then scrollTransitionScale = 1; end

    if scrollingUp then
        buttonsMovementScale = 1 - scrollTransitionScale
    else
        buttonsMovementScale = -1 + scrollTransitionScale
    end

    gfx.BeginPath();
end;

mouse_pressed = function(button) return 0 end

function button_pressed(button)
    if button == game.BUTTON_STA then
        game.PlaySample('titlescreen/cursor_select.wav');
        game.StopSample('titlescreen/bgm.wav');
        buttons[cursorIndex][3]()
    elseif button == game.BUTTON_BCK then
        Menu.Exit()
    end
end

-- the thing is... titlescreen script does not have a call to reset function... WHYYYYY
function reset() playedBgm = false; end
