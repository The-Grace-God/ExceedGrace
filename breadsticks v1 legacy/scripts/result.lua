local Numbers = require('common.numbers')
local Easing = require('common.easing');
local Background = require('components.background');
local Footer = require('components.footer');
local DiffRectangle = require('components.diff_rectangle');
local lang = require("language.call")

local creww = game.GetSkinSetting("single_idol")

local VolforceWindow = require('components.volforceWindow')

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

local function resolutionChange(x, y)
    resX = x
    resY = y
    fullX = portraitWidescreenRatio * y
    fullY = y
end

local bgSfxPlayed = false;

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)

local topBarImage = gfx.CreateSkinImage("result/top_bar.png", 0);
local jacketPanelImage = gfx.CreateSkinImage("result/panels/jacket.png", 0);
local rightPanelImage = gfx.CreateSkinImage("result/panels/right.png", 0);
local bottomPanelImage = gfx.CreateSkinImage("result/panels/bottom.png", 0);
local cMOD = gfx.CreateSkinImage("result/panels/cmod.png",0);
local warn = gfx.CreateSkinImage("result/panels/warning.png",0);
local warntxt = gfx.CreateSkinImage("result/warnings/AUTOPLAY.png",0);

local defaultJacketImage = gfx.CreateSkinImage("result/default_jacket.png", 0);

local bestScoreBadgeImage = gfx.CreateSkinImage("result/best.png", 0);

local appealCardImage = gfx.CreateSkinImage("crew/appeal_card.png", 0);
local danBadgeImage = gfx.CreateSkinImage("dan/inf.png", 0);

local badgeLines = gfx.CreateSkinImage("result/badge_lines.png", 0);
local badgeGrade = gfx.CreateSkinImage("result/badge_gradient.png", 0);

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
    D = gfx.CreateSkinImage("common/grades/D.png", 0)
}

local gaugeTypeBadgeImages = {
    gfx.CreateSkinImage("result/gauge_type_badges/effective.png", 0),
    gfx.CreateSkinImage("result/gauge_type_badges/excessive.png", 0),
    gfx.CreateSkinImage("result/gauge_type_badges/permissive.png", 0),
    gfx.CreateSkinImage("result/gauge_type_badges/blastive.png", 0),
    gfx.CreateSkinImage("result/gauge_type_badges/effective.png", 0), -- placeholders in case other types get added
    gfx.CreateSkinImage("result/gauge_type_badges/effective.png", 0)
}

local gaugeEffFailFillImage = gfx.CreateSkinImage(
                                  "gameplay/gauges/effective/gauge_fill_fail.png",
                                  0)
local gaugeEffPassFillImage = gfx.CreateSkinImage(
                                  "gameplay/gauges/effective/gauge_fill_pass.png",
                                  0)
local gaugeExcFillImage = gfx.CreateSkinImage(
                              "gameplay/gauges/excessive/gauge_result_fill.png", 0)
local gaugePermFillImage = gfx.CreateSkinImage(
                               "gameplay/gauges/permissive/gauge_fill.png", 0)
local gaugeBlastiveFillImage = gfx.CreateSkinImage(
                                   "gameplay/gauges/blastive/gauge_fill.png", 0)

local difficultyLabelImages = {
    gfx.CreateSkinImage("diff/1 novice.png", 0),
    gfx.CreateSkinImage("diff/2 advanced.png", 0),
    gfx.CreateSkinImage("diff/3 exhaust.png", 0),
    gfx.CreateSkinImage("diff/4 maximum.png", 0),
    gfx.CreateSkinImage("diff/5 infinite.png", 0),
    gfx.CreateSkinImage("diff/6 gravity.png", 0),
    gfx.CreateSkinImage("diff/7 heavenly.png", 0),
    gfx.CreateSkinImage("diff/8 vivid.png", 0)
}

local clearBadgeImages = {
    {
        image = gfx.CreateSkinImage("result/clears/CRASH.png", 0),
        xPos = 970
    },
    {
        image = gfx.CreateSkinImage("result/clears/CRASH.png", 0),
        xPos = 970
    },
    {
        image = gfx.CreateSkinImage("result/clears/COMPLETE.png", 0),
        xPos = 1090
    },
    {
        image = gfx.CreateSkinImage("result/clears/COMPLETE.png", 0),
        xPos = 1090
    },
    {
        image = gfx.CreateSkinImage("result/clears/UC.png", 0),
        xPos = 1150
    },
    {
        image = gfx.CreateSkinImage("result/clears/PUC.png", 0),
        xPos = 1080
    },
    {
        image = gfx.CreateSkinImage("result/clears/AUTOPLAY.png", 0),
        xPos = 1100
    },
}

-- ANIMS
local idolAnimation = gfx.LoadSkinAnimation('crew/anim/'..creww, 1 / 30, 0, true);

local transitionEnterScale = 0;
local idolAnimTransitionScale = 0;

local badgeLinesAnimScale = 0;
local badgeLinesAnimOffsetX = 0;

local rightPanelX = 0;
local rightPanelY = 910;

local bottomPanelX = 0;
local bottomPanelY = 1170;

local jacketPanelX = 0;
local jacketPanelY = 880;

local AutoPosiX = 260;

local JACKET_PANEL_TRANSTION_ENTER_OFFSET = -256;
local RIGHT_PANEL_TRANSTION_ENTER_OFFSET = 256;
local BOTTOM_PANEL_TRANSTION_ENTER_OFFSET = 256;

local highScore;

local username = game.GetSkinSetting('username');
local msg = game.GetSkinSetting("MSG");

local earlyLateBarsStats = {
    earlyErrors = 0,
    earlyNears = 0,
    criticals = 0,
    lateNears = 0,
    lateErrors = 0
};
local objectTypeTimingStats = {
    chip = {criticals = 0, nears = 0, errors = 0},
    long = {criticals = 0, errors = 0},
    vol = {criticals = 0, errors = 0}
}

local irHeartbeatRequested = false;
local irText = ''

game.LoadSkinSample("result")
game.LoadSkinSample("shutter")

local handleSfx = function()
    if not bgSfxPlayed then
        game.PlaySample("result", true)
        bgSfxPlayed = true
        game.SetSkinSetting('_musicPlaying', 'result');
    end
end

function drawTimingBar(y, value, max, type)
    gfx.BeginPath();

    if type == 'crit' then
        gfx.FillColor(255, 255, 84, 255);
    elseif type == 'early' then
        gfx.FillColor(255, 16, 94, 255);
    elseif type == 'late' then
        gfx.FillColor(16, 225, 255, 255);
    end

    gfx.Rect(rightPanelX + 696, rightPanelY + y, 293 * (value / max), 8);
    gfx.Fill();
    gfx.ClosePath();
end

local drawIdol = function(deltaTime)
    local idolAnimTickRes = gfx.TickAnimation(idolAnimation, deltaTime);
    if idolAnimTickRes == 1 then
        gfx.GlobalAlpha(idolAnimTransitionScale);

        idolAnimTransitionScale = idolAnimTransitionScale + 1 / 60;
        if (idolAnimTransitionScale > 1) then
            idolAnimTransitionScale = 1;
        end

        gfx.ImageRect(0, 0, desw, desh, idolAnimation, 1, 0);
        gfx.GlobalAlpha(1);
    end
end

local drawbgrade = function()
    gfx.BeginPath();
    gfx.ImageRect(rightPanelX + 1080 - 531, rightPanelY + 2, 531, 85, badgeGrade, 1, 0);
end

local drawRightBarAni = function(deltaTime)
    -- badgeLines
    gfx.BeginPath();
    gfx.ImageRect(rightPanelX + 1080 - 531 + badgeLinesAnimOffsetX, rightPanelY + 2, 531, 85, badgeLines, 1, 0);
end

local drawmod = function ()
    if result.speedModType == 2 then
    gfx.BeginPath();
    gfx.ImageRect(rightPanelX + 1080 - 250, rightPanelY-35, 254, 35, cMOD, 1, 0);
    end
end

local drawarn = function ()
    if (result.autoplay) then
    gfx.BeginPath();
    gfx.ImageRect(bottomPanelX+30 , bottomPanelY+495, 541*0.85, 136*0.85, warn, 1, 0);
    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FontSize(20)
    gfx.Text(lang.Result.re,bottomPanelX + AutoPosiX + 30, bottomPanelY+534);
    gfx.Text(lang.Result.re1,bottomPanelX + AutoPosiX, bottomPanelY+564);
    gfx.Text(lang.Result.re2,bottomPanelX + AutoPosiX, bottomPanelY+584);
    end
end

local drawTopBar = function()
    gfx.BeginPath();
    local tw, th = gfx.ImageSize(topBarImage);
    th = (desw / tw) * th; -- recalculate the height of the bar to scale it down

    gfx.ImageRect(0, -th * (1 - Easing.outQuad(transitionEnterScale)), desw, th,
                  topBarImage, 1, 0);
end

local drawRightPanel = function()
    gfx.BeginPath();
    local tw, th = gfx.ImageSize(rightPanelImage);

    gfx.ImageRect(rightPanelX, rightPanelY, tw, th, rightPanelImage, 1, 0);
end

local scoreNumber = Numbers.load_number_image("score_num");

local drawRightPanelContent = function()
    local highScoreScore = 0;
    if highScore then highScoreScore = highScore.score end

    local highScoreDelta = result.score - highScoreScore

    -- Draw clear badge
    local badgeData = clearBadgeImages[result.badge + 1] or clearBadgeImages[1]
    if (result.autoplay) then
        badgeData = clearBadgeImages[7]; -- Display AUTOPLAY badge
    end

    local tw, th = gfx.ImageSize(badgeData.image);
    gfx.BeginPath();
    gfx.ImageRect(rightPanelX + badgeData.xPos - tw, rightPanelY - 10, tw * 0.85,
                      th * 0.85, badgeData.image, 1, 0);

    -- Draw song name and artist
    gfx.FontSize(28)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(result.realTitle, rightPanelX + 435, rightPanelY + 108);
    gfx.Text(result.artist, rightPanelX + 435, rightPanelY + 143);

    -- Draw score
    Numbers.draw_number(rightPanelX + 580, rightPanelY + 192, 1.0,
                math.floor(result.score / 10000), 4, scoreNumber, true, 0.40,
                1.12)
    Numbers.draw_number(rightPanelX + 775, rightPanelY + 200, 1.0, result.score, 4,
                scoreNumber, true, 0.25, 1.12)

    -- If this is the highscore, draw over the glowing best badge
    if highScoreDelta > 0 then
        gfx.BeginPath();
        gfx.ImageRect(rightPanelX + 364, rightPanelY + 167, 97, 53,
                      bestScoreBadgeImage, 1, 0);
    end

    -- Draw grade
    local gradeImageKey = string.gsub(result.grade, '+', '_P');
    local gradeImage = gradeImages[gradeImageKey] or gradeImages.D
    gfx.BeginPath();
    gfx.ImageRect(rightPanelX + 890, rightPanelY + 130, 85, 85, gradeImage, 1, 0);

    -- Draw best score
    gfx.FontSize(20)
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')

    local deltaPrefix = '-'
    if highScoreDelta > 0 then deltaPrefix = '+' end
    highScoreDelta = math.abs(highScoreDelta);

    gfx.Text(string.format("%08d", highScoreScore), rightPanelX + 962,
             rightPanelY + 239);
    gfx.Text(deltaPrefix .. string.format("%08d", highScoreDelta),
             rightPanelX + 962, rightPanelY + 259);

    -- Draw gauge type badge
    gfx.BeginPath();
    gfx.ImageRect(rightPanelX + 722, rightPanelY + 273, 211, 40,
                  gaugeTypeBadgeImages[result.gauge_type + 1], 1, 0);

    -- Draw gauge %
    gfx.FontSize(24)

    if result.gauge == 1 then
        gfx.Text('100%', rightPanelX + 987,
                 rightPanelY + 294);
    else
        gfx.Text(math.floor(result.gauge * 100) .. '.', rightPanelX + 964, rightPanelY + 294);

        gfx.FontSize(18)
        local decimalPortion = math.floor(
            (
                result.gauge * 100 -
                math.floor(result.gauge * 100)
            ) * 10
        );
        gfx.Text(decimalPortion .. '%', rightPanelX + 988, rightPanelY + 296);
                 
                 
        -- gfx.FontSize(24)
        -- gfx.Text('%', rightPanelX + 988, rightPanelY + 294);
    end

    gfx.FontSize(24)

    -- Draw gauge fill
    local gaugeFillImage = gaugeEffPassFillImage;
    local gaugeBreakpoint = 0;

    if result.gauge_type == 0 then
        gaugeBreakpoint = 0.7;

        if result.gauge <= 0.7 then
            gaugeFillImage = gaugeEffFailFillImage;
        else
            gaugeFillImage = gaugeEffPassFillImage;
        end

    elseif result.gauge_type == 1 then
        gaugeFillImage = gaugeExcFillImage;
    elseif result.gauge_type == 2 then
        gaugeFillImage = gaugePermFillImage;
    elseif result.gauge_type == 3 then -- BLASTIVE RATE
        gaugeFillImage = gaugeBlastiveFillImage;
    end

    local gaugePosX = rightPanelX + 1027;
    local gaugePosY = rightPanelY + 309;
    local FillW, FillH = 9.5, 236;

    gfx.BeginPath();
    gfx.Scissor(gaugePosX, gaugePosY + (FillH - (FillH * (result.gauge))),
                FillW, FillH * (result.gauge))
    gfx.ImageRect(gaugePosX, gaugePosY, FillW, FillH, gaugeFillImage, 1, 0);
    gfx.ResetScissor();

    -- Draw the breakpoint line if needed
    if (gaugeBreakpoint > 0) then
        gfx.Save()
        gfx.BeginPath()
        gfx.GlobalAlpha(0.75);

        local lineY = gaugePosY + (FillH - (FillH * (gaugeBreakpoint)))

        gfx.MoveTo(gaugePosX, lineY)
        gfx.LineTo(gaugePosX + 10, lineY)

        gfx.StrokeWidth(2)
        gfx.StrokeColor(255, 255, 255)
        gfx.Stroke()

        gfx.ClosePath()
        gfx.Restore()
    end

    -- Draw err/early/critical/late/err texts

    gfx.Text(earlyLateBarsStats.earlyErrors, rightPanelX + 683,
             rightPanelY + 370);
    gfx.Text(earlyLateBarsStats.earlyNears, rightPanelX + 683, rightPanelY + 401);
    gfx.Text(earlyLateBarsStats.criticals, rightPanelX + 683, rightPanelY + 432);
    gfx.Text(earlyLateBarsStats.lateNears, rightPanelX + 683, rightPanelY + 463);
    gfx.Text(earlyLateBarsStats.lateErrors, rightPanelX + 683, rightPanelY + 494);

    -- Draw hit timing bars
    local totalHits = earlyLateBarsStats.earlyErrors +
                          earlyLateBarsStats.earlyNears +
                          earlyLateBarsStats.criticals +
                          earlyLateBarsStats.lateNears +
                          earlyLateBarsStats.lateErrors

    gfx.Save()
    drawTimingBar(365, earlyLateBarsStats.earlyErrors, totalHits, 'early')
    drawTimingBar(396, earlyLateBarsStats.earlyNears, totalHits, 'early')
    drawTimingBar(427, earlyLateBarsStats.criticals, totalHits, 'crit')
    drawTimingBar(458, earlyLateBarsStats.lateNears, totalHits, 'late')
    drawTimingBar(489, earlyLateBarsStats.lateErrors, totalHits, 'late')
    gfx.Restore()
    -- Draw hit stats based on objects
    -- CHIP
    gfx.Text(objectTypeTimingStats.chip.criticals, rightPanelX + 255,
             rightPanelY + 365);
    gfx.Text(objectTypeTimingStats.chip.nears, rightPanelX + 255,
             rightPanelY + 395);
    gfx.Text(objectTypeTimingStats.chip.errors, rightPanelX + 255,
             rightPanelY + 425);
    -- LONG
    gfx.Text(objectTypeTimingStats.long.criticals, rightPanelX + 333,
             rightPanelY + 365);
    gfx.Text('-', rightPanelX + 333, rightPanelY + 395);
    gfx.Text(objectTypeTimingStats.long.errors, rightPanelX + 333,
             rightPanelY + 425);
    -- VOL
    gfx.Text(objectTypeTimingStats.vol.criticals, rightPanelX + 411,
             rightPanelY + 365);
    gfx.Text('-', rightPanelX + 411, rightPanelY + 395);
    gfx.Text(objectTypeTimingStats.vol.errors, rightPanelX + 411,
             rightPanelY + 425);

    -- Draw max combo
    gfx.Text(result.maxCombo, rightPanelX + 371, rightPanelY + 466);
end

local drawBottomPanel = function()
    gfx.BeginPath();
    local tw, th = gfx.ImageSize(bottomPanelImage);

    gfx.ImageRect(bottomPanelX, bottomPanelY, tw, th, bottomPanelImage, 1, 0);
end

local drawBottomPanelContent = function(deltatime)
    -- Draw appeal card
    gfx.BeginPath();
    gfx.ImageRect(bottomPanelX + 58, bottomPanelY + 277, 103, 132,
                  appealCardImage, 1, 0);

    -- Draw description
    gfx.FontSize(22)
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(msg, bottomPanelX + 190, bottomPanelY + 282);

    -- Draw username
    gfx.FontSize(28)
    gfx.Text(username, bottomPanelX + 190, bottomPanelY + 314);

    -- Draw dan badge
    gfx.BeginPath();
    gfx.ImageRect(bottomPanelX + 187, bottomPanelY + 362, 107, 29,
                  danBadgeImage, 1, 0);

    -- Draw volforce
    VolforceWindow.render(0, bottomPanelX + 310, bottomPanelY + 355)

    -- Draw IR text
    gfx.FontSize(22)
    gfx.Text(irText, bottomPanelX + 80, bottomPanelY + 461);

    -- Draw median and mean hit delta
    local leftX = bottomPanelX + 600
    local rightX = bottomPanelX + 1010
    local baseY = bottomPanelY + 440
    local detailTextMargin = 25

    gfx.FontSize(20)
    gfx.Text('Median hit delta', leftX, baseY);
    gfx.Text('Mean hit delta', leftX, baseY + detailTextMargin);

    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(result.medianHitDelta.." ms", rightX, baseY);
    gfx.Text(math.floor(result.meanHitDelta).." ms", rightX, baseY + detailTextMargin);
end

local drawJacketPanel = function()
    gfx.BeginPath();
    local tw, th = gfx.ImageSize(jacketPanelImage);

    gfx.ImageRect(jacketPanelX, jacketPanelY, tw, th, jacketPanelImage, 1, 0);
end

local drawJacketPanelContent = function(deltaTime)
    gfx.BeginPath();
    gfx.ImageRect(jacketPanelX + 13, jacketPanelY + 28, 265, 265,
                  jacketImage or defaultJacketImage, 1, 0);

    DiffRectangle.render(deltaTime, jacketPanelX+183, jacketPanelY+2.5, 0.67, result.difficulty, result.level);

    -- gfx.BeginPath();
    -- gfx.ImageRect(jacketPanelX + 183, jacketPanelY + 2.5, 140 / 1.5, 31 / 1.5,
    --               difficultyLabelImages[result.difficulty + 1] or
    --                   difficultyLabelImages[4], 1, 0);

    -- gfx.FontSize(17)
    -- gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    -- gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
    -- gfx.Text(result.level, jacketPanelX + 265, jacketPanelY + 13.5);
end

local IR_HeartbeatResponse = function(res)
    if res.statusCode == IRData.States.Success then
        irText = res.body.serverName .. ' ' .. res.body.irVersion;
    else
        game.Log("Can't connect to IR!", game.LOGGER_WARNING)
    end
end

local IR_Handle = function()
    if not irHeartbeatRequested then
        IR.Heartbeat(IR_HeartbeatResponse)
        irHeartbeatRequested = true;
    end
end

local tickTransitions = function(deltaTime)

    if transitionEnterScale < 1 then
        transitionEnterScale = transitionEnterScale + deltaTime / 0.66 -- transition should last for that time in seconds
    else
        transitionEnterScale = 1
    end

    rightPanelX = 0 +
                      (RIGHT_PANEL_TRANSTION_ENTER_OFFSET *
                          (1 - Easing.outQuad(transitionEnterScale)))

    bottomPanelY = 1170 + (BOTTOM_PANEL_TRANSTION_ENTER_OFFSET *
                       (1 - Easing.outQuad(transitionEnterScale)))

    jacketPanelX = 40 + (JACKET_PANEL_TRANSTION_ENTER_OFFSET *
                       (1 - Easing.outQuad(transitionEnterScale)))


    if badgeLinesAnimScale < 1 then
        badgeLinesAnimScale = badgeLinesAnimScale + deltaTime / 0.5 -- transition should last for that time in seconds
    else
        badgeLinesAnimScale = 0
    end
    badgeLinesAnimOffsetX = 16 * (1-badgeLinesAnimScale);
end

result_set = function()
    if result.jacketPath ~= nil and result.jacketPath ~= "" then
        jacketImage = gfx.CreateImage(result.jacketPath, 0)
    end

    -- Reset stats
    earlyLateBarsStats = {
        earlyErrors = 0,
        earlyNears = 0,
        criticals = 0,
        lateNears = 0,
        lateErrors = 0
    };
    objectTypeTimingStats = {
        chip = {criticals = 0, nears = 0, errors = 0},
        long = {criticals = 0, errors = 0},
        vol = {criticals = 0, errors = 0}
    }

    -- Store the highest score so we can use it later for delta and stuff
    highScore = result.highScores[1];

    -- This check is to prevent errors when these are not available
    if (result.noteHitStats and result.holdHitStats and result.laserHitStats) then
        -- "CHIP" objects
        for hitStatIndex = 1, #result.noteHitStats do
            local hitStat = result.noteHitStats[hitStatIndex];

            if (hitStat.rating == 0) then -- Errors
                objectTypeTimingStats.chip.errors =
                    objectTypeTimingStats.chip.errors + 1;

                if hitStat.delta < 0 then
                    earlyLateBarsStats.earlyErrors =
                        earlyLateBarsStats.earlyErrors + 1;
                else
                    earlyLateBarsStats.lateErrors =
                        earlyLateBarsStats.lateErrors + 1;
                end
            elseif hitStat.rating == 1 then -- Nears
                objectTypeTimingStats.chip.nears =
                    objectTypeTimingStats.chip.nears + 1;

                if hitStat.delta < 0 then
                    earlyLateBarsStats.earlyNears =
                        earlyLateBarsStats.earlyNears + 1;
                else
                    earlyLateBarsStats.lateNears =
                        earlyLateBarsStats.lateNears + 1;
                end
            else -- Criticals
                objectTypeTimingStats.chip.criticals =
                    objectTypeTimingStats.chip.criticals + 1;
            end
        end

        -- "LONG" objects
        for hitStatIndex = 1, #result.holdHitStats do
            local hitStat = result.holdHitStats[hitStatIndex];

            if (hitStat.rating == 0) then -- Errors
                objectTypeTimingStats.long.errors =
                    objectTypeTimingStats.long.errors + 1;
                earlyLateBarsStats.lateErrors =
                    earlyLateBarsStats.lateErrors + 1;
            else -- Criticals
                objectTypeTimingStats.long.criticals =
                    objectTypeTimingStats.long.criticals + 1;
            end
        end

        -- "VOL" a.k.a laser objects
        for hitStatIndex = 1, #result.laserHitStats do
            local hitStat = result.laserHitStats[hitStatIndex];

            if (hitStat.rating == 0) then -- Errors
                objectTypeTimingStats.vol.errors =
                    objectTypeTimingStats.vol.errors + 1;
                earlyLateBarsStats.lateErrors =
                    earlyLateBarsStats.lateErrors + 1;
            else -- Criticals
                objectTypeTimingStats.vol.criticals =
                    objectTypeTimingStats.vol.criticals + 1;
            end
        end

    else
        objectTypeTimingStats = {
            chip = {criticals = 'N/A', nears = 'N/A', errors = 'N/A'},
            long = {criticals = 'N/A', errors = 'N/A'},
            vol = {criticals = 'N/A', errors = 'N/A'}
        }
    end

    earlyLateBarsStats.criticals = result.perfects -- Criticals are for all objects
end

drawResultScreen = function (x, y, w, h, deltaTime)
    gfx.BeginPath()

    gfx.Translate(x, y);
    gfx.Scale(w / 1080, h / 1920);
    gfx.Scissor(0, 0, 1080, 1920);
    Background.draw(deltaTime)

    drawIdol(deltaTime)

    drawTopBar()

    gfx.GlobalAlpha(Easing.outQuad(transitionEnterScale))

    drawBottomPanel()
    drawBottomPanelContent(deltaTime)

    drawRightPanel()
    drawRightBarAni(deltaTime)
    drawbgrade()
    drawmod()
    drawRightPanelContent()

    drawJacketPanel()
    drawJacketPanelContent(deltaTime)
    drawarn()
    gfx.GlobalAlpha(1)

    Footer.draw(deltaTime);

    handleSfx();
    IR_Handle();

    gfx.ResetTransform()
end

render = function(deltaTime, showStats)
    -- detect resolution change
    local resx, resy = game.GetResolution()
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    gfx.BeginPath()
    local bgImageWidth, bgImageHeight = gfx.ImageSize(backgroundImage)
    gfx.Rect(0, 0, resX, resY)
    gfx.FillPaint(gfx.ImagePattern(0, 0, bgImageWidth, bgImageHeight, 0, backgroundImage, 0.2))
    gfx.Fill()

    drawResultScreen((resX - fullX) / 2, 0, fullX, fullY, deltaTime)

    -- debug
    gfx.FontSize(18)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)

    if game.GetSkinSetting('debug_showInformation') then 
        gfx.Text('DELTA: ' .. deltaTime .. ' // TRANSITION_ENTER_SCALE: ' ..
        transitionEnterScale .. ' // EASING_OUT_QUAD: ' ..
        Easing.outQuad(transitionEnterScale), 8, 8);
    end

    tickTransitions(deltaTime)
end

get_capture_rect = function ()
    return (resX - fullX) / 2, 0, fullX, fullY
end

screenshot_captured = function(path)
    game.PlaySample("shutter")
  end