require('common')
local Easing = require('common.easing');
local SongSelectHeader = require('components.headers.songSelectHeader')
local Footer = require('components.footer');

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)

local defaultFolderBgImage = gfx.CreateSkinImage('song_select/filter_wheel/bg.png', 0)
local collectionFolderBgImage = gfx.CreateSkinImage('song_select/filter_wheel/col_bg.png', 0)
local subFolderBgImage = gfx.CreateSkinImage('song_select/filter_wheel/sub_bg.png', 0)

local scrollbarBgImage =  gfx.CreateSkinImage("song_select/scrollbar/bg.png", 1)
local scrollbarFillImage =  gfx.CreateSkinImage("song_select/scrollbar/fill.png", 1)

local cursorImages = {
    gfx.CreateSkinImage("song_select/cursor.png", 1), -- Effective rate or fallback
    gfx.CreateSkinImage("song_select/cursor_exc.png", 1), -- Excessive rate
    gfx.CreateSkinImage("song_select/cursor_perm.png", 1), -- Premissive rate
    gfx.CreateSkinImage("song_select/cursor_blast.png", 1), -- Blastive rate
}

local ITEM_HEIGHT = 172;

local specialFolders = {
    {
        keys = {
            'SOUND VOLTEX BOOTH', 'SDVX BOOTH', 'SOUND VOLTEX I', 'SDVX I',
            'SOUND VOLTEX 1', 'SDVX 1', 'SDVX I BOOTH'
        },
        folderBg = gfx.CreateSkinImage(
            'song_select/filter_wheel/special_folder_bgs/Booth.png', 0)
    }, {
        keys = {
            'SOUND VOLTEX INFINITE INFECTION', 'SDVX INFINITE INFECTION',
            'SOUND VOLTEX II', 'SDVX II', 'SOUND VOLTEX 2', 'SDVX 2', 'SDVX II INFINITE INFECTION'
        },
        folderBg = gfx.CreateSkinImage(
            'song_select/filter_wheel/special_folder_bgs/Infinite Infection.png',
            0)
    },
    {
        keys = {
            'SOUND VOLTEX GRAVITY WARS',
            'SDVX GRAVITY WARS',
            'SOUND VOLTEX III',
            'SDVX III',
            'SOUND VOLTEX 3',
            'SDVX 3',
            'SDVX III GRAVITY WARS',
        },
        folderBg = gfx.CreateSkinImage('song_select/filter_wheel/special_folder_bgs/Gravity Wars.png', 0)
    },
    {
        keys = {
            'SOUND VOLTEX HEAVENLY HAVEN', 'SDVX HEAVENLY HAVEN',
            'SOUND VOLTEX IV', 'SDVX IV', 'SOUND VOLTEX 4', 'SDVX 4', 'SDVX IV HEAVENLY HAVEN'
        },
        folderBg = gfx.CreateSkinImage(
            'song_select/filter_wheel/special_folder_bgs/Heavenly Haven.png', 0)
    }, {
        keys = {
            'SOUND VOLTEX VIVID WAVE', 'SDVX VIVID WAVE', 'SOUND VOLTEX V',
            'SDVX V', 'SOUND VOLTEX 5', 'SDVX 5', 'SDVX V VIVID WAVE'
        },
        folderBg = gfx.CreateSkinImage(
            'song_select/filter_wheel/special_folder_bgs/Vivid Wave.png', 0)
    }, {
        keys = {
            'SOUND VOLTEX EXCEED GEAR', 'SDVX EXCEED GEAR', 'SOUND VOLTEX VI',
            'SDVX VI', 'SOUND VOLTEX 6', 'SDVX 6', 'SDVX VI EXCEED GEAR'
        },
        folderBg = gfx.CreateSkinImage(
            'song_select/filter_wheel/special_folder_bgs/Exceed Gear.png', 0)
    }, {
        keys = {
            'NAUTICA',
        },
        folderBg = gfx.CreateSkinImage(
            'song_select/filter_wheel/special_folder_bgs/Nautica.png', 0)
    }, {
        keys = {
            'KSHOOTMANIA', 'K-SHOOT MANIA', "K SHOOT MANIA"
        },  
        folderBg = gfx.CreateSkinImage(
            'song_select/filter_wheel/special_folder_bgs/KShootMania.png', 0)
    },
}

-- AUDIO
game.LoadSkinSample('song_wheel/cursor_change.wav');
game.LoadSkinSample('filter_wheel/open_close.wav');

local resx, resy = game.GetResolution()
local desw, desh = 1080, 1920
local scale = 1;

local isFilterWheelActive = false;
local previousActiveState = false; -- for open/close sounds

local selectionMode = 'folders';
local selectedFolder = 1;
local selectedLevel = 1;

local transitionScrollScale = 0;
local transitionScrollOffsetY = 0;
local scrollingUp = false;

local transitionLeaveScale = 1;
local transitionLeaveReappearTimer = 0;
local TRANSITION_LEAVE_DURATION = 0.1;

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
    scale = resx / desw
end

function getCorrectedIndex(from, offset)
    local total = 1;
    if selectionMode == 'folders' then
        total = #filters.folder;
    else
        total = #filters.level;
    end

    index = from + offset;

    if index < 1 then
        index = total + (from + offset) -- this only happens if the offset is negative
    end

    if index > total then
        indexesUntilEnd = total - from;
        index = offset - indexesUntilEnd -- this only happens if the offset is positive
    end

    return index;
end

function getFolderData(folderLabel)
    local folderType = 'unknown';
    local isSpecial = false;
    local folderBgImage = defaultFolderBgImage;

    if not folderLabel then
        return {
            type = folderType,
            label = 'UNKNOWN',
            bgImage = folderBgImage,
            isSpecial = isSpecial
        }
    end


    if selectionMode == 'levels' then
        folderBgImage = subFolderBgImage
    end
    

    if (string.find(folderLabel, 'Folder: ')) then
        folderType = 'folder';
        folderLabel = folderLabel:gsub('Folder: ', '') -- Delete default prefix
    elseif (string.find(folderLabel, 'Collection: ')) then
        folderType = 'collection';
        folderLabel = folderLabel:gsub('Collection: ', '') -- Delete default prefix
        folderBgImage = collectionFolderBgImage;
    elseif (string.find(folderLabel, 'Level: ')) then
        folderType = 'level';
        folderLabel = folderLabel:gsub('Level: ', '') -- Delete default prefix
        folderLabel = 'LEVEL ' .. folderLabel;
    end

    local labelMatcherString = string.upper(folderLabel)

    for i, specialFolder in ipairs(specialFolders) do
        for i, specialFolderKey in ipairs(specialFolder.keys) do
            if (specialFolderKey == labelMatcherString) then
                folderBgImage = specialFolder.folderBg;
                isSpecial = true;
            end
        end
    end

    return {
        type = folderType,
        label = folderLabel,
        bgImage = folderBgImage,
        isSpecial = isSpecial
    }
end

function drawFolder(label, y)
    if (not label) then return end

    gfx.LoadSkinFont('NotoSans-Regular.ttf')

    local x = desw / 2 + 0

    local folderData = getFolderData(label)

    -- Draw the bg
    gfx.BeginPath()
    gfx.ImageRect(x, y, 630 * 0.86, 200 * 0.86, folderData.bgImage, 1, 0)

    -- Draw the folder label, but only if the folder is not special
    if (not folderData.isSpecial) then
        gfx.BeginPath();
        gfx.FontSize(38)
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        gfx.FillColor(255, 255, 255, 255);
        gfx.Text(folderData.label, x + 18, y + 72);
    end
end

function drawFolderList()
    gfx.GlobalAlpha(1-transitionLeaveScale)

    local numOfItemsAround = 7;
    local selectedIndex = 1;
    local folderList = filters.folder;

    if selectionMode == 'folders' then
        selectedIndex = selectedFolder
        folderList = filters.folder;
    else
        selectedIndex = selectedLevel
        folderList = filters.level;
    end

    local yOffset = transitionScrollOffsetY;

    local i = 1;
    while (i <= numOfItemsAround) do
        local index = getCorrectedIndex(selectedIndex, -i)
        drawFolder(folderList[index],
                   desh / 2 - ITEM_HEIGHT / 2 - ITEM_HEIGHT * i + yOffset)
        i = i + 1;
    end

    -- Draw the selected song
    drawFolder(folderList[selectedIndex], desh / 2 - ITEM_HEIGHT / 2 + yOffset)

    i = 1;
    while (i <= numOfItemsAround) do
        local index = getCorrectedIndex(selectedIndex, i)
        drawFolder(folderList[index],
                   desh / 2 - ITEM_HEIGHT / 2 + ITEM_HEIGHT * i + yOffset)
        i = i + 1;
    end

    gfx.GlobalAlpha(1);
end

function drawCursor()
    if not isFilterWheelActive or transitionLeaveScale ~= 0 then return end

    gfx.BeginPath()

    local cursorImageIndex = game.GetSkinSetting('_gaugeType')
    local cursorImage = cursorImages[cursorImageIndex or 1];

    gfx.ImageRect(desw / 2 - 14, desh / 2 - 213 / 2, 555, 213, cursorImage, 1, 0)
end

function drawScrollbar()
    if not isFilterWheelActive or transitionLeaveScale ~= 0 then return end

    gfx.BeginPath()
    local bgW = 13*0.85;
    local bgH = 1282*0.85;
    local scrollPosX = desw-20
    local scrollPosY = desh/2-bgH/2

    gfx.ImageRect(scrollPosX, scrollPosY, bgW, bgH, scrollbarBgImage, 1, 0)

    local total = game.GetSkinSetting('_songWheelScrollbarTotal')
    local index = game.GetSkinSetting('_songWheelScrollbarIndex')

    if (index == nil) then return end;

    gfx.BeginPath()
    local fillW = 27*0.85
    local fillH = 65*0.85
    local fillPosOffsetY = (bgH-fillH)*(
        (index-1) /
        math.max(1,total-1)
    )

    gfx.ImageRect(scrollPosX-6, scrollPosY+fillPosOffsetY, fillW, fillH, scrollbarFillImage, 1, 0)
end

function tickTransitions(deltaTime)
    if transitionScrollScale < 1 then
        transitionScrollScale = transitionScrollScale + deltaTime / 0.1 -- transition should last for that time in seconds
    else
        transitionScrollScale = 1
    end

    if scrollingUp then
        transitionScrollOffsetY = Easing.inQuad(1 - transitionScrollScale) *
                                      ITEM_HEIGHT;
    else
        transitionScrollOffsetY = Easing.inQuad(1 - transitionScrollScale) *
                                      -ITEM_HEIGHT;
    end

    -- LEAVE TRANSITION
    if (not isFilterWheelActive) then
        if transitionLeaveScale < 1 then
            transitionLeaveScale = transitionLeaveScale + deltaTime / TRANSITION_LEAVE_DURATION -- transition should last for that time in seconds
        else
            transitionLeaveScale = 1
        end
        transitionLeaveReappearTimer = 1;
    else
        if (transitionLeaveReappearTimer == 1) then
            -- This stuff happens right after filterwheel is deactivated
        end

        transitionLeaveReappearTimer = transitionLeaveReappearTimer - deltaTime / (TRANSITION_LEAVE_DURATION + 0.05) -- same reasoning as in the songwheel

        if (transitionLeaveReappearTimer <= 0) then
            transitionLeaveScale = 0;
            transitionLeaveReappearTimer = 0;
        end
    end
end

function drawFilterWheelContent(deltatime)
    tickTransitions(deltatime);
    drawFolderList()
end

local drawFilterWheel = function (x,y,w,h, deltaTime)
    gfx.Translate(x,y);
    gfx.Scale(w/1080, h/1920);

    drawFilterWheelContent(deltaTime)
    drawCursor()
    drawScrollbar()
    
    if (game.GetSkinSetting('_currentScreen') == 'songwheel') then
        SongSelectHeader.draw(deltaTime);
        Footer.draw(deltaTime);
    end

    if (isFilterWheelActive ~= previousActiveState) then 
        game.PlaySample('filter_wheel/open_close.wav');
        previousActiveState = isFilterWheelActive;
    end

    -- Debug text
    gfx.BeginPath();
    gfx.FontSize(18)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(255, 255, 255, 255);
    if game.GetSkinSetting('debug_showInformation') then 
        gfx.Text('S_M: ' .. selectionMode .. ' // S_F: ' .. selectedFolder ..
                 ' // S_L: ' .. selectedLevel .. ' // L_TS: ' ..
                 transitionLeaveScale .. ' // L_TRT: ' .. transitionLeaveReappearTimer, 8, 1870);
    end
end

render = function(deltaTime, shown)
    isFilterWheelActive = shown;

    if not shown then
        game.SetSkinSetting('_songWheelOverlayActive', 0);
    else
        game.SetSkinSetting('_songWheelOverlayActive', 1);
    end
    
    game.SetSkinSetting('_songWheelActiveFolderLabel', getFolderData(filters.folder[selectedFolder]).label);
    game.SetSkinSetting('_songWheelActiveSubFolderLabel', getFolderData(filters.level[selectedLevel]).label);

    -- detect resolution change
    local resx, resy = game.GetResolution();
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    gfx.GlobalAlpha(1)

    drawFilterWheel((resX - fullX) / 2, 0, fullX, fullY, deltaTime);
end

set_selection = function(newIndex, isFolder)
    local oldIndex = 1;
    local total = 1;
    if isFolder then
        oldIndex = selectedFolder
        selectedFolder = newIndex
        total = #filters.folder;
    else
        oldIndex = selectedLevel
        selectedLevel = newIndex
        total = #filters.level;
    end

    transitionScrollScale = 0;

    scrollingUp = false;
    if ((newIndex > oldIndex and not (newIndex == total and oldIndex == 1)) or
        (newIndex == 1 and oldIndex == total)) then scrollingUp = true; end

    game.PlaySample('song_wheel/cursor_change.wav');
end

set_mode = function(isFolder)
    if isFolder then
        selectionMode = 'folders'
    else
        selectionMode = 'levels'
    end
end
