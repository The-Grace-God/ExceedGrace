local Easing = require("common.easing");
local Footer = require("components.footers.footer");
local DiffRectangle = require('components.diff_rectangle');
local common = require('common.util');
local Sound = require("common.sound")

local Numbers = require('components.numbers')
local dancheck = require("components.dancheck");

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

local BAR_ALPHA = 191;
local HEADER_HEIGHT = 100

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)
local resultBgImage = gfx.CreateSkinImage("challenge_result/bg.png", 0);
local playerInfoOverlayBgImage = gfx.CreateSkinImage("challenge_result/player_info_overlay_bg.png", 0);

local headerTitleImage = gfx.CreateSkinImage("challenge_result/header/title.png", 0);

local username = game.GetSkinSetting("username");
local msg = game.GetSkinSetting("MSG");
local appealCardImage = gfx.CreateSkinImage("crew/appeal_card.png", 0);
local danBadgeImage = gfx.CreateSkinImage("dan/inf.png", 0);
local crewImage = gfx.CreateSkinImage("crew/portrait.png", 0);

local notchesImage = gfx.CreateSkinImage("challenge_result/notches.png", 0);
local trackBarsImage = gfx.CreateSkinImage("challenge_result/track_bars.png", 0);

local completionFailImage = gfx.CreateSkinImage("challenge_result/pass_states/fail.png", 0);
local completionPassImage = gfx.CreateSkinImage("challenge_result/pass_states/pass.png", 0);

local irHeartbeatRequested = false;
local IRserverName = "";
local badgeImages = {
    gfx.CreateSkinImage("song_select/medal/nomedal.png", 1),
    gfx.CreateSkinImage("song_select/medal/played.png", 1),
    gfx.CreateSkinImage("song_select/medal/clear.png", 1),
    gfx.CreateSkinImage("song_select/medal/hard.png", 1),
    gfx.CreateSkinImage("song_select/medal/uc.png", 1),
    gfx.CreateSkinImage("song_select/medal/puc.png", 1),
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

local percRequired = nil;
local percGet = nil;

-- AUDIO
game.LoadSkinSample("challenge_result.wav")

function resetLayoutInformation()
    resx, resy = game.GetResolution()
    desw = 1080
    desh = 1920
    scale = resx / desw
end

local function handleSfx()
    if not bgSfxPlayed then
        Sound.stopMusic();
        game.PlaySample("challenge_result.wav", true)
        bgSfxPlayed = true
    end
    if game.GetButton(game.BUTTON_STA) then
        game.StopSample("challenge_result.wav")
    end
    if game.GetButton(game.BUTTON_BCK) then
        game.StopSample("challenge_result.wav")
    end
end

function drawBackground()
    gfx.BeginPath()
    gfx.ImageRect(0, 0, desw, desh, resultBgImage, 1, 0);
end

function drawHeader()
    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, BAR_ALPHA);
    gfx.Rect(0, 0, desw, HEADER_HEIGHT);
    gfx.Fill();
    gfx.ClosePath()

    gfx.ImageRect(desw / 2 - 209, HEADER_HEIGHT / 2 - 52, 419, 105, headerTitleImage, 1, 0)
end

function drawPlayerInfo()
    -- Draw crew
    gfx.BeginPath()
    gfx.ImageRect(460, 215, 522, 362, crewImage, 1, 0);

    -- Draw the info bg
    gfx.BeginPath()
    gfx.ImageRect(300, 352, 374 * 0.85, 222 * 0.85, playerInfoOverlayBgImage, 1, 0);

    -- Draw appeal card
    gfx.BeginPath();
    gfx.ImageRect(145, 364, 103 * 1.25, 132 * 1.25, appealCardImage, 1, 0);

    -- Draw description
    gfx.FontSize(28)
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(msg, 310, 370);

    -- Draw username
    gfx.FontSize(40)
    gfx.Text(string.upper(username), 310, 413);

    -- Draw IR server name
    gfx.FontSize(28)
    gfx.Text(IRserverName, 310, 453);

    -- Draw dan badge
    gfx.BeginPath();
    gfx.ImageRect(311, 490, 107 * 1.25, 29 * 1.25, dancheck(false), 1, 0);
end

local scoreNumber = Numbers.load_number_image("score_num");

function drawChartResult(deltaTime, x, y, chartResult)
    gfx.Save()
    gfx.LoadSkinFont('NotoSans-Regular.ttf')

    gfx.FontSize(28)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.BeginPath()
    gfx.GlobalAlpha(1);
    gfx.Text(chartResult.title, x+160,y+32);

    DiffRectangle.render(deltaTime, x+287.5, y+67, 0.85, chartResult.difficulty+1, chartResult.level)

    local score = chartResult.score or 0;

    Numbers.draw_number(x + 500, y+80, 1.0, math.floor(score / 10000), 4, scoreNumber, true, 0.30, 1.12)
    Numbers.draw_number(x + 655, y+85, 1.0, score, 4, scoreNumber, true, 0.22, 1.12)


    local gradeImageKey = string.gsub(chartResult.grade, '+', '_P');
    local gradeImage = gradeImages[gradeImageKey] or gradeImages.D
    gfx.BeginPath()
    gfx.ImageRect(x+800, y+12, 79, 79, gradeImage, 1, 0)


    if chartResult.badge then
        local badgeImage = badgeImages[chartResult.badge+1];
        gfx.BeginPath()
        gfx.ImageRect(x+900, y+16, 79*1.05, 69*1.05, badgeImage, 1, 0)
    end


    gfx.Restore()
end

function drawScorePanelContent(deltaTime)
    -- game.Log("Drawing scores...", game.LOGGER_INFO) -- debug
    for i, chart in ipairs(info.charts) do
        -- if chart.score == nil then
        --     game.Log("Score does not exist? Quitting loop...", game.LOGGER_WARNING)
        --     break
        -- end
        
        drawChartResult(deltaTime, 0, 836+(165*(i-1)), chart);
    end

end

function drawDecorations()
    gfx.BeginPath()
    gfx.ImageRect(118, 846.5, 43*0.855, 429*0.855, notchesImage, 1, 0)
    
    gfx.BeginPath()
    gfx.ImageRect(400, 807, 367*0.857, 429*0.857, trackBarsImage, 1, 0)
end

function drawCompletion()
    local completitionImage = completionFailImage;
    if info.passed then
        completitionImage = completionPassImage;
    end

    gfx.BeginPath()
    gfx.ImageRect(63, 1331, 766*0.85, 130*0.85, completitionImage, 1, 0)

    if (percRequired == nil) then
        return
    end

    Numbers.draw_number(925, 1370, 1.0, percGet, 3, scoreNumber, true, 0.3, 1.12)


    gfx.BeginPath();
    gfx.Rect(741, 1402, 278*math.min(1, percGet / percRequired), 6);
    gfx.FillColor(255, 128, 0, 255);
    gfx.Fill()
end

function result_set()
    if (info.requirement_text == nil) then
        return
    end

    local reqTextWords = common.split(info.requirement_text, ' ');


    for index, word in ipairs(reqTextWords) do
        if string.find(word, '%%') ~= nil then -- %% = %, because % is an escape char
            local percNumber = tonumber(string.gsub(word, '%%', ''), 10)
            percRequired = percNumber;
        end
    end

    if (percRequired == nil) then
        return
    end


    game.Log(percRequired, game.LOGGER_ERROR);

    local a = 0;
    for i, chart in ipairs(info.charts) do
        a = a + chart.percent;
        game.Log('#' .. i .. ' got ' .. chart.percent .. '% // ACC at ' .. a, game.LOGGER_ERROR);
    end
    percGet = a / #info.charts;
end


local IR_HeartbeatResponse = function(res)
    if res.statusCode == IRData.States.Success then
        IRserverName = res.body.serverName .. " " .. res.body.irVersion;
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

local function drawResultScreen(x, y, w, h, deltaTime)
    gfx.BeginPath()

    gfx.Translate(x, y);
    gfx.Scale(w / 1080, h / 1920);
    gfx.Scissor(0, 0, 1080, 1920);

    handleSfx()
    IR_Handle()

    drawBackground()

    drawDecorations()

    drawPlayerInfo()

    drawScorePanelContent(deltaTime)

    drawCompletion()

    drawHeader()
    Footer.draw(deltaTime);

    gfx.ResetTransform()
end

function render(deltaTime)
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
end
