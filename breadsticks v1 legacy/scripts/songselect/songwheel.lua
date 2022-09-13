require('common')
local Easing = require('common.easing')
local Background = require('components.background')
local common     = require('common.common')
local Numbers = require('common.numbers')

local VolforceCalc = require('components.volforceCalc')

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)

local dataPanelImage = gfx.CreateSkinImage("song_select/data_bg_overlay.png", 1)
local dataGlowOverlayImage = gfx.CreateSkinImage("song_select/data_panel/data_glow_overlay.png", 1)
local gradeBgImage = gfx.CreateSkinImage("song_select/data_panel/grade_bg.png", 1)
local badgeBgImage = gfx.CreateSkinImage("song_select/data_panel/clear_badge_bg.png", 1)
local effectedBgImage = gfx.CreateSkinImage("song_select/data_panel/effected_bg.png", 1)
local illustratedBgImage = gfx.CreateSkinImage("song_select/data_panel/illust_bg.png", 1)
local songPlateBg = gfx.CreateSkinImage("song_select/plate/bg.png", 1)
local songPlateBottomBarOverlayImage = gfx.CreateSkinImage("song_select/plate/bottom_bar_overlay.png", 1)
local scoreBoardBarBgImage = gfx.CreateSkinImage("song_select/textboard.png", 1)
local crownImage = gfx.CreateSkinImage("song_select/crown.png", 1)

local laserAnimBaseImage =  gfx.CreateSkinImage("song_select/laser_anim.png", 1)

local top50OverlayImage = gfx.CreateSkinImage("song_select/top50.png", 1)
local top50JacketOverlayImage = gfx.CreateSkinImage("song_select/top50_jacket.png", 1)

local diffCursorImage = gfx.CreateSkinImage("song_select/level_cursor.png", 1)

local filterInfoBgImage = gfx.CreateSkinImage("song_select/filter_info_bg.png", 1)
local sortInfoBgImage = gfx.CreateSkinImage("song_select/sort_info_bg.png", 1)

local searchBgImage = gfx.CreateSkinImage("song_select/search_bg.png", 1)

local defaultJacketImage = gfx.CreateSkinImage("song_select/loading.png", 0)

local difficultyLabelImages = {
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/novice.png", 1),
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/advanced.png", 1),
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/exhaust.png", 1),
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/maximum.png", 1),
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/infinite.png", 1),
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/gravity.png", 1),
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/heavenly.png", 1),
    gfx.CreateSkinImage("song_select/plate/difficulty_labels/vivid.png", 1),
}

local badgeImages = {
    gfx.CreateSkinImage("song_select/medal/nomedal.png", 1),
    gfx.CreateSkinImage("song_select/medal/played.png", 1),
    gfx.CreateSkinImage("song_select/medal/clear.png", 1),
    gfx.CreateSkinImage("song_select/medal/hard.png", 1),
    gfx.CreateSkinImage("song_select/medal/uc.png", 1),
    gfx.CreateSkinImage("song_select/medal/puc.png", 1),
}

local cursorImages = {
    gfx.CreateSkinImage("song_select/cursor.png", 1), -- Effective rate or fallback
    gfx.CreateSkinImage("song_select/cursor_exc.png", 1), -- Excessive rate
    gfx.CreateSkinImage("song_select/cursor_perm.png", 1), -- Premissive rate
    gfx.CreateSkinImage("song_select/cursor_blast.png", 1), -- Blastive rate
}
local gradeCutoffs = {
    D =     0000000,
    C =     7000000,
    B =     8000000,
    A =     8700000,
    A_P =   9000000,
    AA =    9300000,
    AA_P =  9500000,
    AAA =   9700000,
    AAA_P = 9800000,
    S =     9900000,
}

local gradeImages = {
    S = gfx.CreateSkinImage("common/grades/S.png", 0),
    AAA_P = gfx.CreateSkinImage("common/grades/AAA+.png", 0),
    AAA = gfx.CreateSkinImage("common/grades/AAA.png", 0),
    AA_P = gfx.CreateSkinImage("common/grades/AA+.png", 0),
    AA = gfx.CreateSkinImage("common/grades/AA.png", 0),
    A_P = gfx.CreateSkinImage("common/grades/A+.png", 0),
    A = gfx.CreateSkinImage("common/grades/A.png", 0),
    B = gfx.CreateSkinImage("common/grades/B.png", 0),
    C = gfx.CreateSkinImage("common/grades/C.png", 0),
    D = gfx.CreateSkinImage("common/grades/D.png", 0),
    none = gfx.CreateSkinImage("common/grades/none.png", 0),
}

local difficultyLabelUnderImages = {
    gfx.CreateSkinImage("songtransition/difficulty_labels/nov.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/adv.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/exh.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/mxm.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/inf.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/grv.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/hvn.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/vvd.png", 0),
}

game.LoadSkinSample('song_wheel/cursor_change.wav');
game.LoadSkinSample('song_wheel/diff_change.wav');

local scoreNumbers = Numbers.load_number_image("score_num")
local difficultyNumbers = Numbers.load_number_image("diff_num")

local LEADERBOARD_PLACE_NAMES = {
    '1st',
    '2nd',
    '3rd',
    '4th',
}

local songPlateHeight = 172;

local selectedIndex = 1;
local selectedDifficulty = 1;

local jacketCache = {}

local top50diffs = {}

local irRequestStatus = 1; -- 0=unused, 1=not requested, 2=loading, others are status codes
local irRequestTimeout = 2
local irLeaderboard = {}
local irLeaderboardsCache = {}

local transitionScrollScale = 0;
local transitionScrollOffsetY = 0;
local scrollingUp = false;

local transitionAfterscrollScale = 0;
local transitionAfterscrollDataOverlayAlpha = 0;
local transitionAfterscrollGradeAlpha = 0;
local transitionAfterscrollBadgeAlpha = 0;
local transitionAfterscrollTextSongTitle = 0;
local transitionAfterscrollTextSongArtist = 0;
local transitionAfterscrollDifficultiesAlpha = 0;

local transitionJacketBgScrollScale = 0;
local transitionJacketBgScrollAlpha = 0;
local transitionJacketBgScrollPosX = 0;

local transitionLaserScale = 0;
local transitionLaserY = 0;

-- Flash transition (animation)
-- Used for flashing the badges
-- 0 = minimum brightness; 0.5 = maximum brightness; 1 = minimum brightness again
local transitionFlashScale = 0;
local transitionFlashAlpha = 1;

local isFilterWheelActive = false;
local transitionLeaveScale = 0;
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
local desw = 1080
local desh = 1920

local resolutionChange = function(x, y)
    resX = x
    resY = y
    fullX = portraitWidescreenRatio * y
    fullY = y

    game.Log('resX:' .. resX .. ' // resY:' .. resY .. ' // fullX:' .. fullX .. ' // fullY:' .. fullY, game.LOGGER_ERROR);
end

function getCorrectedIndex(from, offset) 
	total = #songwheel.songs;

    if (math.abs(offset) > total) then
        if (offset < 0) then 
            offset = offset + total*math.floor(math.abs(offset)/total);
        else
            offset = offset - total*math.floor(math.abs(offset)/total);
        end
    end

	index = from + offset;

	if index < 1 then
		index = total + (from+offset) -- this only happens if the offset is negative
	end;

	if index > total then
		indexesUntilEnd = total - from;
		index = offset - indexesUntilEnd -- this only happens if the offset is positive
	end;

	return index;
end;

function getJacketImage(song)
    if not jacketCache[song.id] or jacketCache[song.id]==defaultJacketImage then
        jacketCache[song.id] = gfx.LoadImageJob(song.difficulties[
            math.min(selectedDifficulty, #song.difficulties)
        ].jacketPath, defaultJacketImage, 500, 500);
    end

    return jacketCache[song.id];
end

function getGradeImageForScore(score)
    local gradeImage = gradeImages.none;
    local bestGradeCutoff = 0;
    for gradeName, scoreCutoff in pairs(gradeCutoffs) do
        if scoreCutoff <= score then
            if scoreCutoff > bestGradeCutoff then 
                gradeImage = gradeImages[gradeName];
                bestGradeCutoff = scoreCutoff;
            end
        end
    end

    return gradeImage;
end

function drawLaserAnim()
    gfx.Save();
    gfx.BeginPath()
    
    gfx.Scissor(0, transitionLaserY, desw, 100);
    
    gfx.ImageRect(0, 0, desw, desh, laserAnimBaseImage, 1, 0)
    
    gfx.Restore();
end

function drawBackground(deltaTime)
    Background.draw(deltaTime)
    
    local song = songwheel.songs[selectedIndex];
    local diff = song and song.difficulties[selectedDifficulty] or false;

    if (not isFilterWheelActive and transitionLeaveReappearTimer == 0) then
        -- If the score for song exists
        if song and diff then 
            local jacketImage = getJacketImage(song);
            gfx.BeginPath()
            gfx.ImageRect(transitionJacketBgScrollPosX, 0, 900, 900, jacketImage or defaultJacketImage, transitionJacketBgScrollAlpha, 0)

            
            gfx.BeginPath();
            gfx.FillColor(0,0,0,math.floor(transitionJacketBgScrollAlpha*64));
            gfx.Rect(0,0,900,900);
            gfx.Fill();
            gfx.ClosePath();
        end
    end

    gfx.BeginPath();
    gfx.ImageRect(0, 0, desw, desh, dataPanelImage, 1, 0)

    drawLaserAnim()

    if song and diff and (not isFilterWheelActive and transitionLeaveReappearTimer == 0) then 
        gfx.BeginPath()
        gfx.ImageRect(0, 0, desw, desh, dataGlowOverlayImage, transitionAfterscrollDataOverlayAlpha, 0)
        gfx.BeginPath()

        gfx.ImageRect(341, 754, 85, 85, gradeBgImage, transitionAfterscrollDataOverlayAlpha, 0)
        gfx.BeginPath()
        gfx.ImageRect(391, 687, 180*0.85, 226*0.85, badgeBgImage, transitionAfterscrollDataOverlayAlpha, 0)
        gfx.BeginPath()

        gfx.ImageRect(95, 1165, 433, 30, effectedBgImage, transitionAfterscrollDataOverlayAlpha, 0)
        gfx.BeginPath()
        gfx.ImageRect(95, 1195, 433, 30, illustratedBgImage, transitionAfterscrollDataOverlayAlpha, 0)
    end

end

function drawSong(song, y)
    if (not song) then return end;

    local songX = desw/2+28
    local selectedSongDifficulty = song.difficulties[math.min(selectedDifficulty, #song.difficulties)] -- Limit selecting difficulty that is above the number that the song has

    if not selectedSongDifficulty then
        return;
    end

    local bestScore;
    if selectedSongDifficulty.scores then 
        bestScore = selectedSongDifficulty.scores[1];
    end

    -- Draw the bg for the song plate
    gfx.BeginPath()
    gfx.ImageRect(songX, y, 515, 172, songPlateBg, 1, 0)
    
    -- Draw jacket
    local jacketImage = getJacketImage(song);
    gfx.BeginPath()
    gfx.ImageRect(songX+4, y+4, 163, 163, jacketImage or defaultJacketImage, 1, 0)

    -- Draw the overlay for the song plate (that bottom black bar)
    gfx.BeginPath()
    gfx.ImageRect(songX, y, 515, 172, songPlateBottomBarOverlayImage, 1, 0)
    
    -- Draw the difficulty notch background
    gfx.BeginPath()
    local diffIndex = GetDisplayDifficulty(selectedSongDifficulty.jacketPath, selectedSongDifficulty.difficulty)
    gfx.ImageRect(songX, y+95, 83, 74, difficultyLabelImages[diffIndex], 1, 0)

    -- Draw the difficulty level number
    gfx.BeginPath()
    Numbers.draw_number(songX+30, y+125, 1.0, selectedSongDifficulty.level, 2, difficultyNumbers, false, 0.65, 1)

    -- Draw song title
    gfx.FontSize(24)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(song.title, songX+90, y+155);

    -- Draw score badge
    local badgeImage = badgeImages[1];
    if selectedSongDifficulty.topBadge then
        badgeImage = badgeImages[selectedSongDifficulty.topBadge+1];
    end
    
    local badgeAlpha = 1;
    if (selectedSongDifficulty.topBadge >= 3) then
        badgeAlpha = transitionFlashAlpha; -- If hard clear or above, flash the badge
    end

    gfx.BeginPath()
    gfx.ImageRect(songX+282, y+44, 79, 69, badgeImage, badgeAlpha, 0)

    -- Draw grade
    local gradeImage = gradeImages.none;
    local gradeAlpha = 1;

    if bestScore then 
        gradeImage = getGradeImageForScore(bestScore.score)

        if (bestScore.score >= gradeCutoffs.S) then
            gradeAlpha = transitionFlashAlpha; -- If S, flash the badge
        end
    end

    gfx.BeginPath();
    gfx.ImageRect(songX+391, y+47, 60, 60, gradeImage, gradeAlpha, 0);

    -- Draw top 50 label if applicable
    if (top50diffs[selectedSongDifficulty.id]) then
        gfx.BeginPath();
        gfx.ImageRect(songX+82, y+109, 506*0.85, 26*0.85, top50OverlayImage, 1, 0);
    end
end

function drawSongList()
    gfx.GlobalAlpha(1-transitionLeaveScale);

    local numOfSongsAround = 7; -- How many songs should be up and how many should be down of the selected one

    local yOffset = transitionScrollOffsetY;

    local i=1;
    while (i <= numOfSongsAround) do
        local songIndex = getCorrectedIndex(selectedIndex, -i)
        drawSong(songwheel.songs[songIndex], desh/2-songPlateHeight/2-songPlateHeight*i + yOffset)
        i=i+1;
    end;
    
    -- Draw the selected song
    drawSong(songwheel.songs[selectedIndex], desh/2-songPlateHeight/2 + yOffset)

    i=1;
    while (i <= numOfSongsAround) do
        local songIndex = getCorrectedIndex(selectedIndex, i)
        drawSong(songwheel.songs[songIndex], desh/2-songPlateHeight/2+songPlateHeight*i + yOffset)
        i=i+1;
    end;

    gfx.GlobalAlpha(1);
end

function drawData() -- Draws the song data on the left panel

    if isFilterWheelActive or transitionLeaveReappearTimer ~= 0 then return false end;

    local song = songwheel.songs[selectedIndex];
    local diff = song and song.difficulties[selectedDifficulty] or false;
    local bestScore = diff and diff.scores[1];

    if not song then return false end

    local jacketImage = getJacketImage(song);
    gfx.BeginPath()
    gfx.ImageRect(96, 324, 348, 348, jacketImage or defaultJacketImage, 1, 0)
    
    if (top50diffs[diff.id]) then
        gfx.BeginPath()
        gfx.ImageRect(96, 529, 410*0.85, 168*0.85, top50JacketOverlayImage, 1, 0)
    end

    gfx.Save()
    -- Draw best score
    gfx.BeginPath()

    local scoreNumber = 0;
    if bestScore then 
        scoreNumber = bestScore.score
    end

    Numbers.draw_number(100, 793, 1.0, math.floor(scoreNumber / 10000), 4, scoreNumbers, true, 0.3, 1.12)
    Numbers.draw_number(253, 798, 1.0, scoreNumber, 4, scoreNumbers, true, 0.22, 1.12)

    -- Draw grade
    local gradeImage = gradeImages.none;
    local gradeAlpha = transitionAfterscrollGradeAlpha;
    if bestScore then 
        gradeImage = getGradeImageForScore(bestScore.score)

        if (transitionAfterscrollGradeAlpha == 1 and bestScore.score >= gradeCutoffs.S) then
            gradeAlpha = transitionFlashAlpha; -- If S, flash the badge
        end
    end

    gfx.BeginPath();
    gfx.ImageRect(360, 773, 45, 45, gradeImage, gradeAlpha, 0);

    -- Draw badge
    badgeImage = badgeImages[diff.topBadge+1];

    local badgeAlpha = transitionAfterscrollBadgeAlpha;
    if (transitionAfterscrollBadgeAlpha == 1 and diff.topBadge >= 3) then
        badgeAlpha = transitionFlashAlpha; -- If hard clear or above, flash the badge, but only after the initial transition
    end

    gfx.BeginPath()
    gfx.ImageRect(425, 724, 93/1.1, 81/1.1, badgeImage, badgeAlpha, 0)

    gfx.Restore()

    -- Draw BPM
    gfx.BeginPath();
    gfx.FontSize(24)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Save()
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.GlobalAlpha(transitionAfterscrollDataOverlayAlpha) -- TODO: split this out
    gfx.Text(song.bpm, 85, 920);
    gfx.Restore()
    
    -- Draw song title
    gfx.FontSize(28)
    gfx.GlobalAlpha(transitionAfterscrollTextSongTitle);
    gfx.Text(song.title, 30+(1-transitionAfterscrollTextSongTitle)*20, 955);
    
    -- Draw artist
    gfx.GlobalAlpha(transitionAfterscrollTextSongArtist);
    gfx.Text(song.artist, 30+(1-transitionAfterscrollTextSongArtist)*30, 997);

    gfx.GlobalAlpha(1);

    -- Draw difficulties
    local DIFF_X_START = 98.5
    local DIFF_GAP = 114.8;
    gfx.GlobalAlpha(transitionAfterscrollDifficultiesAlpha);
    for i, diff in ipairs(song.difficulties) do
        gfx.BeginPath()

        local index = diff.difficulty+1

        if i == selectedDifficulty then
            gfx.ImageRect(DIFF_X_START+(index-1)*DIFF_GAP-(163*0.8)/2, 1028, 163*0.8, 163*0.8, diffCursorImage, 1, 0)
        end

        Numbers.draw_number(85+(index-1)*DIFF_GAP, 1085, 1.0, diff.level, 2, difficultyNumbers, false, 0.8, 1)
        
        local diffLabelImage = difficultyLabelUnderImages[
            GetDisplayDifficulty(diff.jacketPath, diff.difficulty)
        ];
        local tw, th = gfx.ImageSize(diffLabelImage)
        tw=tw*0.9
        th=th*0.9
        gfx.BeginPath()
        gfx.ImageRect(DIFF_X_START+(index-1)*DIFF_GAP-tw/2, 1050, tw, th, diffLabelImage, 1, 0)
    end
    gfx.GlobalAlpha(1);
    

    -- Scoreboard

    drawLocalLeaderboard(diff)
    drawIrLeaderboard()

    gfx.FontSize(22)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.GlobalAlpha(transitionAfterscrollDataOverlayAlpha);
    gfx.Text(diff.effector, 270, 1180); -- effected by
    gfx.Text(diff.illustrator, 270, 1210); -- illustrated by
    gfx.GlobalAlpha(1);

end

function drawLocalLeaderboard(diff)
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.FontSize(26)

    local scoreBoardX = 75;
    local scoreBoardY = 1250;

    local sbBarWidth = 336*1.2;
    local sbBarHeight = 33;

    local sbBarContentLeftX = scoreBoardX + 80;
    local sbBarContentRightX = scoreBoardX + sbBarWidth/2 + 30;

    -- Draw the header
    gfx.BeginPath();
    gfx.ImageRect(scoreBoardX, scoreBoardY, sbBarWidth, sbBarHeight, scoreBoardBarBgImage, 1, 0);

    gfx.BeginPath();
    gfx.ImageRect(205, 1252.5, 800*0.045, 600*0.045, crownImage, 1, 0);

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.BeginPath();
    gfx.Text("LOCAL TOP", sbBarContentRightX, scoreBoardY + sbBarHeight/2);

    for i = 1, 5, 1 do
        gfx.BeginPath();
        gfx.ImageRect(scoreBoardX, scoreBoardY + i*sbBarHeight, sbBarWidth, sbBarHeight, scoreBoardBarBgImage, 1, 0);

        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        gfx.BeginPath();
        gfx.Text(game.GetSkinSetting("username"), sbBarContentLeftX, scoreBoardY + sbBarHeight/2 + i*sbBarHeight);

        gfx.BeginPath();
        gfx.Text((diff.scores[i]) and diff.scores[i].score or "- - - - - - - -", sbBarContentRightX, scoreBoardY + sbBarHeight/2 + i*sbBarHeight);
    end
end

function drawIrLeaderboard()
    if not IRData.Active then
        return;
    end

    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.FontSize(26)
    
    local scoreBoardX = 75;
    local scoreBoardY = 1500;
    
    local sbBarWidth = 336*1.2;
    local sbBarHeight = 33;
    
    local sbBarContentLeftX = scoreBoardX + 80;
    local sbBarContentRightX = scoreBoardX + sbBarWidth/2 + 30;

    -- Draw the header
    gfx.BeginPath();
    gfx.ImageRect(scoreBoardX, scoreBoardY, sbBarWidth, sbBarHeight, scoreBoardBarBgImage, 1, 0);
    
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    gfx.BeginPath();

    if irRequestStatus == 1 or irRequestStatus == 2 then
        gfx.Text("Loading ranking...", scoreBoardX + (sbBarWidth / 2), scoreBoardY + sbBarHeight/2);
        return;
    end

    if irRequestStatus == IRData.States.ChartRefused then
        gfx.Text("This chart is blacklisted", scoreBoardX + (sbBarWidth / 2), scoreBoardY + sbBarHeight/2);
        return;
    end

    if irRequestStatus == IRData.States.NotFound then
        gfx.Text("This chart is not tracked", scoreBoardX + (sbBarWidth / 2), scoreBoardY + sbBarHeight/2);
        return;
    end

    if #irLeaderboard == 0 then
        gfx.Text("This chart has no scores", scoreBoardX + (sbBarWidth / 2), scoreBoardY + sbBarHeight/2);
        return;
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    gfx.BeginPath();
    gfx.Text("IR TOP", scoreBoardX + (sbBarWidth / 2), scoreBoardY + sbBarHeight/2);

    for i = 1, 4, 1 do
        gfx.BeginPath();
        gfx.ImageRect(scoreBoardX, scoreBoardY + i*sbBarHeight, sbBarWidth, sbBarHeight, scoreBoardBarBgImage, 1, 0);
    end

    -- Becuase the scores are in "random order", we have to do this
    for index, irScore in ipairs(irLeaderboard) do
        -- local irScore = irLeaderboard[i];
        
        if irScore then 
            local rank = index;
            gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
            gfx.BeginPath();
            gfx.Text(LEADERBOARD_PLACE_NAMES[rank], sbBarContentLeftX-40, scoreBoardY + sbBarHeight/2 + rank*sbBarHeight);

            gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
            gfx.BeginPath();
            gfx.Text(string.upper(irScore.username), sbBarContentLeftX, scoreBoardY + sbBarHeight/2 + rank*sbBarHeight);
            
            gfx.BeginPath();
            gfx.Text(string.format("%d", irScore.score), sbBarContentRightX, scoreBoardY + sbBarHeight/2 + rank*sbBarHeight);

            local badgeImage = badgeImages[irScore.lamp+1];
            gfx.BeginPath()
            gfx.ImageRect(scoreBoardX + sbBarWidth - 50, scoreBoardY + sbBarHeight/2 + rank*sbBarHeight - 12.5, 31.6, 27.6, badgeImage, 1, 0)
        end
    end
end

function drawFilterInfo(deltatime)
    gfx.LoadSkinFont('NotoSans-Regular.ttf')

    if (songwheel.searchInputActive) then
        return;
    end

    gfx.BeginPath()
    gfx.ImageRect(5, 95, 417*0.85, 163*0.85, filterInfoBgImage, 1, 0)
    
    local folderLabel = game.GetSkinSetting('_songWheelActiveFolderLabel')
    local subFolderLabel = game.GetSkinSetting('_songWheelActiveSubFolderLabel')
    local sortOptionLabel = game.GetSkinSetting('_songWheelActiveSortOptionLabel')
    
    gfx.FontSize(24)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    
    gfx.BeginPath()
    gfx.Text(folderLabel or '', 167, 131);
    
    gfx.BeginPath()
    gfx.Text(subFolderLabel or '', 195, 166);

    gfx.BeginPath()
    gfx.ImageRect(desw - 310 - 5, 108, 310, 75, sortInfoBgImage, 1, 0)

    gfx.BeginPath()
    gfx.Text(sortOptionLabel or '', desw-150, 130);
end

function drawCursor()
    if isFilterWheelActive or transitionLeaveScale ~= 0 then return false end

    gfx.BeginPath()

    local cursorImageIndex = game.GetSkinSetting('_gaugeType')
    local cursorImage = cursorImages[cursorImageIndex or 1];

    gfx.ImageRect(desw / 2 - 14, desh / 2 - 213 / 2, 555, 213, cursorImage, 1, 0)
end

function drawSearch()
    if (not songwheel.searchInputActive) then
        return;
    end

    
    gfx.BeginPath();
    local tw, th = gfx.ImageSize(searchBgImage)
    local xPos = desw-tw/2;
    local yPos = 90;

    gfx.ImageRect(xPos, yPos, tw/2, th/2, searchBgImage, 1, 0)

    gfx.FontSize(32);
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(songwheel.searchText, xPos+100, yPos+52);
end

function refreshIrLeaderboard(deltaTime)
    if not IRData.Active then
        return;
    end

    if irRequestStatus ~= 1 then -- Only continue if the leaderboard is requesteded, but not loading or loaded.
        return
    end
    irLeaderboard = {}

    local song = songwheel.songs[selectedIndex];
    local diff = song and song.difficulties[selectedDifficulty] or false;

    if (not diff) then
        return;
    end

    if (irLeaderboardsCache[diff.hash]) then
        irLeaderboard = irLeaderboardsCache[diff.hash];
        irRequestStatus = 20;
        return;
    end

    if (irRequestTimeout > 0) then
        irRequestTimeout = irRequestTimeout - deltaTime
        return;
    end

    irRequestStatus = 2; -- Loading
    -- onIrLeaderboardFetched({
    --     statusCode = 20,
    --     body = {}
    -- })
    IR.Leaderboard(diff.hash, 'best', 4, onIrLeaderboardFetched)
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function onIrLeaderboardFetched(res)
    irRequestStatus = res.statusCode;

    local song = songwheel.songs[selectedIndex];
    local diff = song and song.difficulties[selectedDifficulty] or false;
    game.Log(diff.hash, game.LOGGER_ERROR)
    
    if res.statusCode == IRData.States.Success then
        game.Log('Raw IR reposonse: ' .. dump(res.body), game.LOGGER_ERROR)
        local tempIrLB = res.body;

        table.sort(tempIrLB, function (a,b)
            -- game.Log(a.score .. ' ?? ' .. b.score, game.LOGGER_ERROR)
            return a.score > b.score
        end)

        -- for i, tempScore in ipairs(tempIrLeaderboard) do
        --     irLeaderboard[tempScore.ranking] = tempScore
        -- end

        irLeaderboard = tempIrLB;
        irLeaderboardsCache[diff.hash] = irLeaderboard;

        game.Log(dump(irLeaderboard), game.LOGGER_ERROR)
    else
        game.Log("IR error " .. res.statusCode, game.LOGGER_ERROR)
    end
end

function tickTransitions(deltaTime)
    if transitionScrollScale < 1 then
        transitionScrollScale = transitionScrollScale + deltaTime / 0.1 -- transition should last for that time in seconds
    else
        transitionScrollScale = 1
    end

    if transitionAfterscrollScale < 1 then
        if transitionScrollScale == 1 then
            -- Only start the after scroll transition when the scroll transition is finished
            transitionAfterscrollScale = transitionAfterscrollScale + deltaTime / 15
        end
    else
        transitionAfterscrollScale = 1;
    end

    if scrollingUp then 
        transitionScrollOffsetY = Easing.inQuad(1-transitionScrollScale) * songPlateHeight;
    else
        transitionScrollOffsetY = Easing.inQuad(1-transitionScrollScale) * -songPlateHeight;
    end

    if transitionAfterscrollScale < 0.02 then
        transitionAfterscrollDataOverlayAlpha = math.min(1, transitionAfterscrollScale / 0.02)
    else
        transitionAfterscrollDataOverlayAlpha = 1;
    end

    -- Grade alpha
    if transitionAfterscrollScale >= 0.03 and transitionAfterscrollScale < 0.033 then
        transitionAfterscrollGradeAlpha = 0.5;
    elseif transitionAfterscrollScale >= 0.04 then
        transitionAfterscrollGradeAlpha = 1;
    else
        transitionAfterscrollGradeAlpha = 0;
    end
    
    -- Badge alpha
    if transitionAfterscrollScale >= 0.032 and transitionAfterscrollScale < 0.035 then
        transitionAfterscrollBadgeAlpha = 0.5;
    elseif transitionAfterscrollScale >= 0.042 then
        transitionAfterscrollBadgeAlpha = 1;
    else
        transitionAfterscrollBadgeAlpha = 0;
    end

    -- Song title alpha and pos
    if transitionAfterscrollScale < 0.025 then
        transitionAfterscrollTextSongTitle = Easing.outQuad(math.min(1, (transitionAfterscrollScale) / 0.025));
    else
        transitionAfterscrollTextSongTitle = 1
    end
    -- Song artist alpha and pos
    if transitionAfterscrollScale < 0.025 then
        transitionAfterscrollTextSongArtist = Easing.outQuad(math.min(1, (transitionAfterscrollScale) / 0.025));
    else
        transitionAfterscrollTextSongArtist = 1
    end
    
    -- Difficulties alpha
    if transitionAfterscrollScale < 0.025 then
        transitionAfterscrollDifficultiesAlpha = math.min(1, transitionAfterscrollScale / 0.025)
    else
        transitionAfterscrollDifficultiesAlpha = 1;
    end

    -- Jacket bg animation
    if transitionJacketBgScrollScale < 1 then
        transitionJacketBgScrollScale = transitionJacketBgScrollScale + deltaTime / 20 -- transition should last for that time in seconds
    else
        transitionJacketBgScrollScale = 0
    end

    if transitionJacketBgScrollScale < 0.05 or transitionJacketBgScrollScale >= 1 then
        transitionJacketBgScrollAlpha = 0;
    elseif transitionJacketBgScrollScale >= 0.05 and transitionJacketBgScrollScale < 0.1 then
        transitionJacketBgScrollAlpha = math.min(1, (transitionJacketBgScrollScale-0.05) / 0.05);
    elseif transitionJacketBgScrollScale >= 0.8 and transitionJacketBgScrollScale < 1 then
        transitionJacketBgScrollAlpha = math.max(0, 
            math.min(1, 1-((transitionJacketBgScrollScale-0.8) / 0.05))
        );
    else
        transitionJacketBgScrollAlpha = 1;
    end

    transitionJacketBgScrollPosX = 0+(transitionJacketBgScrollScale*(0.8/1))*-300;

    -- Laser anim
    if transitionLaserScale < 1 then
        transitionLaserScale = transitionLaserScale + deltaTime / 2 -- transition should last for that time in seconds
    else
        transitionLaserScale = 0
    end

    transitionLaserY = desh - math.min(transitionLaserScale * 2 * desh, desh);
    
    -- Flash transition
    if transitionFlashScale < 1 then
        local songBpm = 120;
        if (songwheel.songs[selectedIndex] and game.GetSkinSetting('animations_affectWithBPM')) then
            songBpm = songwheel.songs[selectedIndex].bpm;

            -- Is a variable BPM
            if (type(songBpm) == "string") then
                local s = split(songBpm, '-');
                songBpm = tonumber(s[1]); -- Lowest bpm value
            end
        end

        -- If the original songBpm is "2021.04.01" for example, the above code can produce `nil` in the songBpm
        -- since it cannot parse the number out of that string. Here we implement a fallback, to not crash
        -- USC on whacky charts. Whacky charters, quit using batshit insane bpm values. It makes me angery >:(
        if (songBpm == nil) then
            songBpm = 120;
        end

        transitionFlashScale = transitionFlashScale + deltaTime / (60/songBpm) -- transition should last for that time in seconds
    else
        transitionFlashScale = 0
    end

    if transitionFlashScale < 0.5 then
        transitionFlashAlpha = transitionFlashScale * 2;
    else
        transitionFlashAlpha = 1-((transitionFlashScale-0.5) * 2);
    end
    transitionFlashAlpha = 1+transitionFlashAlpha*0.5

    -- Leave transition
    if (isFilterWheelActive) then
        if transitionLeaveScale < 1 then
            transitionLeaveScale = transitionLeaveScale + deltaTime / TRANSITION_LEAVE_DURATION -- transition should last for that time in seconds
        else
            transitionLeaveScale = 1
        end
        transitionLeaveReappearTimer = 1;
        transitionAfterscrollScale = 0; -- Keep songwheel in the "afterscroll" state while the filterwheel is active
        transitionJacketBgScrollScale = 0; -- Same thing here, just with the jacket bg
    else
        if (transitionLeaveReappearTimer ~= 0) then
            transitionAfterscrollScale = 0; -- Keep songwheel in the "afterscroll" state while we're waiting on filter wheel to fade out
            transitionJacketBgScrollScale = 0; -- Same thing here, just with the jacket bg
        end

        transitionLeaveReappearTimer = transitionLeaveReappearTimer - deltaTime / (TRANSITION_LEAVE_DURATION + 0.05) -- 0.05s is a few frames between the completetion of the fade out and songs reappearing in the AC

        if (transitionLeaveReappearTimer <= 0) then
            transitionLeaveScale = 0;
            transitionLeaveReappearTimer = 0;
        end
    end
end

draw_songwheel = function(x,y,w,h, deltaTime)
    
    gfx.Translate(x,y);
    gfx.Scale(w/1080, h/1920);
    gfx.Scissor(0,0,1080,1920);
    

    drawBackground(deltaTime);

    drawSongList()

    isFilterWheelActive = game.GetSkinSetting('_songWheelOverlayActive') == 1;

    drawData()
    drawCursor()

    drawFilterInfo(deltaTime)

    drawSearch();

    gfx.BeginPath();
    gfx.FontSize(18)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    local debugScrollingUp= "FALSE"
    if scrollingUp then debugScrollingUp = "TRUE" end;

    if game.GetSkinSetting('debug_showInformation') then 
        gfx.Text('S_I: ' .. selectedIndex .. ' // S_D: ' .. selectedDifficulty .. ' // S_UP: ' .. debugScrollingUp .. ' // AC_TS: ' .. transitionAfterscrollScale .. ' // L_TS: ' .. transitionLeaveScale .. ' // IR_CODE: ' .. irRequestStatus .. ' // IR_T: ' .. irRequestTimeout, 8, 8);
    end

    gfx.ResetTransform();
end

render = function (deltaTime)
    tickTransitions(deltaTime);

    game.SetSkinSetting('_currentScreen', 'songwheel')

    common.stopMusic();

    -- detect resolution change
    local resx, resy = game.GetResolution();
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    gfx.BeginPath()
    bgImageWidth, bgImageHeight = gfx.ImageSize(backgroundImage)
    gfx.Rect(0, 0, resX, resY)
    gfx.FillPaint(gfx.ImagePattern(0, 0, bgImageWidth, bgImageHeight, 0, backgroundImage, 0.2))
    gfx.Fill()

    draw_songwheel((resX - fullX) / 2, 0, fullX, fullY, deltaTime);

    refreshIrLeaderboard(deltaTime);
end

songs_changed = function (withAll)

    irLeaderboardsCache = {} -- Reset LB cache

    if not withAll then return end

    game.SetSkinSetting('_songWheelScrollbarTotal', #songwheel.songs)
    game.SetSkinSetting('_songWheelScrollbarIndex', selectedIndex)

	local diffs = {}
	for i = 1, #songwheel.allSongs do
		local song = songwheel.allSongs[i]
		for j = 1, #song.difficulties do
			local diff = song.difficulties[j]
			diff.force = VolforceCalc.calc(diff)
			table.insert(diffs, diff)
		end
	end
	table.sort(diffs, function (l, r)
		return l.force > r.force
	end)
	totalForce = 0
	for i = 1, 50 do
		if diffs[i] then
            top50diffs[diffs[i].id] = true;
			totalForce = totalForce + diffs[i].force
		end
	end

    game.SetSkinSetting('_volforce', totalForce)
end

set_index = function(newIndex)
    transitionScrollScale = 0;
    transitionAfterscrollScale = 0;
    transitionJacketBgScrollScale = 0;


    game.SetSkinSetting('_songWheelScrollbarTotal', #songwheel.songs)
    game.SetSkinSetting('_songWheelScrollbarIndex', newIndex)

	scrollingUp = false;
	if ((newIndex > selectedIndex and not (newIndex == #songwheel.songs and selectedIndex == 1)) or (newIndex == 1 and selectedIndex == #songwheel.songs)) then
		scrollingUp = true;
	end;

	game.PlaySample('song_wheel/cursor_change.wav');

    selectedIndex = newIndex;
end;

set_diff = function(newDiff)
    if newDiff ~= selectedDifficulty then 
        jacketCache = {}; -- Clear the jacket cache for the new diff jackets

        game.PlaySample('song_wheel/diff_change.wav');
    end

    selectedDifficulty = newDiff;
    irLeaderboard = {}
    irRequestStatus = 1;
    irRequestTimeout = 2
end;