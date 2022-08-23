require('common')
local Easing = require('common.easing');

local resx, resy = game.GetResolution()
local desw, desh = 1080, 1920

-- AUDIO
game.LoadSkinSample('sort_wheel/enter.wav');
game.LoadSkinSample('sort_wheel/leave.wav');

-- IMAGES
local panelBgImage = gfx.CreateSkinImage('song_select/sort_wheel/bg.png', 0)
local activeItemBgImage = gfx.CreateSkinImage(
                              'song_select/sort_wheel/active_bg.png', 0)
local titleTextImage =
    gfx.CreateSkinImage('song_select/sort_wheel/title.png', 0)

local selection = 1;
local renderedButtonLabels = {}

local FONT_SIZE = 32;
local MARGIN = 16;
local SUB_FONT_SIZE = 26;
local SUB_MARGIN = 8;

local SORT_ORDER_LABEL_TEXTS = {
    {
        label = 'Title',
        asc = '# to A to Z to かな to 漢字',
        dsc = '漢字 to かな to Z to A to #'
    }, {label = 'Score', asc = 'Worst to best', dsc = 'Best to worst'},
    {label = 'Date', asc = 'Oldest to newest', dsc = 'Newest to oldest'},
    {label = 'Badge', asc = 'None to D to S', dsc = 'S to D to None'}, {
        label = 'Artist',
        asc = '# to A to Z to かな to 漢字',
        dsc = '漢字 to かな to Z to A to #'
    }, {
        label = 'Effector',
        asc = '# to A to Z to かな to 漢字',
        dsc = '漢字 to かな to Z to A to #'
    }
}

local transitionEnterReverse = false;
local transitionEnterScale = 0;
local transitionEnterOffsetX = 0;

local previousActiveState = false;

-- Window variables
local resX, resY

-- Aspect Ratios
local landscapeWidescreenRatio = 16 / 9
local landscapeStandardRatio = 4 / 3
local portraitWidescreenRatio = 9 / 16 --+ 0.0035

-- Portrait sizes
local fullX, fullY

local resolutionChange = function(x, y)
    resX = x
    resY = y
    fullX = portraitWidescreenRatio * y
    fullY = y

    game.Log('resX:' .. resX .. ' // resY:' .. resY .. ' // fullX:' .. fullX .. ' // fullY:' .. fullY, game.LOGGER_ERROR);
end

function tableContains(table, value)
    for i, v in ipairs(table) do if v == value then return true end end

    return false;
end

function drawButton(i, f, x, y)
    local spaceAfter = (FONT_SIZE + MARGIN)

    local sortOrder = 'asc';
    if (string.find(f, 'v')) then sortOrder = 'dsc' end

    local label = f:gsub(' ^', '')
    label = label:gsub(' v', '')

    if (string.find(sorts[selection], label) and sorts[selection] ~= f) then
        -- If there is a button active with the same label, but different sort order, don't render this one
        return 0;
    else
        -- If there is no active button with this label, if one with a label was already rendered, don't render this one
        if (tableContains(renderedButtonLabels, label)) then return 0; end
        table.insert(renderedButtonLabels, label);
    end

    if (i == selection) then
        local ascLabelText = 'Ascending'
        local dscLabelText = 'Descending'

        for i, obj in ipairs(SORT_ORDER_LABEL_TEXTS) do
            if (obj.label == label) then
                ascLabelText = obj.asc;
                dscLabelText = obj.dsc;
            end
        end

        gfx.BeginPath()
        gfx.ImageRect(x - 182, y - 38, 365, 82, activeItemBgImage, 1, 0)

        gfx.BeginPath()
        if sortOrder == 'asc' then
            gfx.ImageRect(x - 150, y + FONT_SIZE + SUB_MARGIN * 2 - 31, 300, 67,
                          activeItemBgImage, 1, 0)
        elseif sortOrder == 'dsc' then
            gfx.ImageRect(x - 150, y + FONT_SIZE + SUB_MARGIN * 2 +
                              SUB_FONT_SIZE + SUB_MARGIN - 31, 300, 67,
                          activeItemBgImage, 1, 0)
        end

        gfx.Save()
        gfx.FontSize(SUB_FONT_SIZE)
        gfx.Text(ascLabelText, x, y + FONT_SIZE + SUB_MARGIN * 2);
        gfx.Text(dscLabelText, x,
                 y + FONT_SIZE + SUB_MARGIN * 2 + SUB_FONT_SIZE + SUB_MARGIN);
        gfx.Restore()

        spaceAfter = spaceAfter + SUB_FONT_SIZE * 2 + SUB_MARGIN * 4;
    end

    gfx.BeginPath();
    gfx.Text(label, x, y);

    return spaceAfter;
end

function tickTransitions(deltaTime)
    -- ENTRY TRANSITION
    if transitionEnterReverse then
        if transitionEnterScale > 0 then
            transitionEnterScale = transitionEnterScale - deltaTime / 0.25 -- transition should last for that time in seconds
        else
            transitionEnterScale = 0
        end
    else
        if transitionEnterScale < 1 then
            transitionEnterScale = transitionEnterScale + deltaTime / 0.25 -- transition should last for that time in seconds
        else
            transitionEnterScale = 1
        end
    end

    transitionEnterOffsetX = Easing.inOutQuad(1 - transitionEnterScale) * 416
end

local drawSortWheel = function (x,y,w,h, deltaTime)
    gfx.Scissor(x,y,w,h);
    gfx.Translate(x,y);
    gfx.Scale(w/1080, h/1920);
    gfx.Scissor(0,0,1080,1920);

    -- Draw the dark overlay above song wheel
    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, math.floor(transitionEnterScale * 192));
    gfx.Rect(0, 0, 1080, 1920);
    gfx.Fill();

    -- Draw the panel background
    gfx.BeginPath()
    gfx.ImageRect(desw - 416 + transitionEnterOffsetX, 0, 416, desh,
                  panelBgImage, 1, 0)

    gfx.LoadSkinFont("Digital-Serial-Bold.ttf");
    gfx.FontSize(FONT_SIZE);
    gfx.FillColor(255, 255, 255, 255);
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);

    gfx.GlobalAlpha(transitionEnterScale)

    -- Starting position of the first sort option
    local x = 889 + transitionEnterOffsetX;
    local y = desh / 2 - -- Center point
    (#sorts / 2 / 2) * (FONT_SIZE + MARGIN) - -- Space taken up by half the sort options (we remove the duplicate one)
                  ((SUB_FONT_SIZE * 2 + SUB_MARGIN * 4) / 2); -- Space for taken by order options

    -- Draw the title image
    gfx.BeginPath()
    gfx.ImageRect(x - 72, y - 27, 144, 54, titleTextImage, 1, 0)
    y = y + (54 + MARGIN)

    -- Draw all the sorting options
    for i, f in ipairs(sorts) do
        local spaceAfter = drawButton(i, f, x, y);
        y = y + spaceAfter;
    end
end

function setSkinSetting()
    for i, f in ipairs(sorts) do
        if i == selection then 
            local label = f:gsub(' ^', '')
            label = label:gsub(' v', '')
            
            game.SetSkinSetting('_songWheelActiveSortOptionLabel', label);
        end
    end
end

function render(deltaTime, shown)
    gfx.Save()
    gfx.ResetTransform()
    renderedButtonLabels = {};


    if (shown ~= previousActiveState) then
        if (shown) then
            game.PlaySample('sort_wheel/enter.wav');
        else
            game.PlaySample('sort_wheel/leave.wav');
        end

        previousActiveState = shown;
    end

    -- detect resolution change
    local resx, resy = game.GetResolution();
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    gfx.GlobalAlpha(1)

    if not shown then
        transitionEnterReverse = true
        if (transitionEnterScale > 0) then drawSortWheel((resX - fullX) / 2, 0, fullX, fullY, deltaTime) end
    else
        transitionEnterReverse = false
        drawSortWheel((resX - fullX) / 2, 0, fullX, fullY, deltaTime)
    end
    tickTransitions(deltaTime)
    setSkinSetting();

    gfx.Restore()
end

function set_selection(index) selection = index end
