local Common = require("common.util")
local Charting = require('common.charting')
local Numbers = require('components.numbers')
local DiffRectangle = require("components.diff_rectangle")
local Header = require("components.headers.challengeSelectHeader")
local Footer = require("components.footers.footer")

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)
local challengeBGImage = gfx.CreateSkinImage("challenge_select/bg.png", 0)
local challengeCardBGImage = gfx.CreateSkinImage("challenge_select/small_box.png", 0)
local jacketFallback = gfx.CreateSkinImage("song_select/loading.png", 0)

--[[ will be reimplemented sometime later
local soffset = 0
local searchText = gfx.CreateLabel("", 5, 0)
local searchIndex = 1

local showGuide = game.GetSkinSetting("show_guide")
local legendTable = {
    {
        ["labelSingleLine"] = gfx.CreateLabel("SCROLL INFO", 16, 0),
        ["labelMultiLine"] = gfx.CreateLabel("SCROLL\nINFO", 16, 0),
        ["image"] = gfx.CreateSkinImage("legend/knob-left.png", 0)
    },
    {
        ["labelSingleLine"] = gfx.CreateLabel("CHALL SELECT", 16, 0),
        ["labelMultiLine"] = gfx.CreateLabel("CHALLENGE\nSELECT", 16, 0),
        ["image"] = gfx.CreateSkinImage("legend/knob-right.png", 0)
    },
    {
        ["labelSingleLine"] = gfx.CreateLabel("FILTER CHALLS", 16, 0),
        ["labelMultiLine"] = gfx.CreateLabel("FILTER\nCHALLENGES", 16, 0),
        ["image"] = gfx.CreateSkinImage("legend/FX-L.png", 0)
    },
    {
        ["labelSingleLine"] = gfx.CreateLabel("SORT CHALLS", 16, 0),
        ["labelMultiLine"] = gfx.CreateLabel("SORT\nCHALLENGES", 16, 0),
        ["image"] = gfx.CreateSkinImage("legend/FX-R.png", 0)
    },
    {
        ["labelSingleLine"] = gfx.CreateLabel("GAME SETTINGS", 16, 0),
        ["labelMultiLine"] = gfx.CreateLabel("GAME\nSETTINGS", 16, 0),
        ["image"] = gfx.CreateSkinImage("legend/FX-LR.png", 0)
    },
    {
        ["labelSingleLine"] = gfx.CreateLabel("PLAY", 16, 0),
        ["labelMultiLine"] = gfx.CreateLabel("PLAY", 16, 0),
        ["image"] = gfx.CreateSkinImage("legend/start.png", 0)
    }
}
--]]

local grades = {
    ["D"] = gfx.CreateSkinImage("common/grades/D.png", 0),
    ["C"] = gfx.CreateSkinImage("common/grades/C.png", 0),
    ["B"] = gfx.CreateSkinImage("common/grades/B.png", 0),
    ["A"] = gfx.CreateSkinImage("common/grades/A.png", 0),
    ["A+"] = gfx.CreateSkinImage("common/grades/A+.png", 0),
    ["AA"] = gfx.CreateSkinImage("common/grades/AA.png", 0),
    ["AA+"] = gfx.CreateSkinImage("common/grades/AA+.png", 0),
    ["AAA"] = gfx.CreateSkinImage("common/grades/AAA.png", 0),
    ["AAA+"] = gfx.CreateSkinImage("common/grades/AAA+.png", 0),
    ["S"] = gfx.CreateSkinImage("common/grades/S.png", 0)
}

local badges = {
    gfx.CreateSkinImage("song_select/medal/played.png", gfx.IMAGE_GENERATE_MIPMAPS),
    gfx.CreateSkinImage("song_select/medal/clear.png", gfx.IMAGE_GENERATE_MIPMAPS),
    gfx.CreateSkinImage("song_select/medal/hard.png", gfx.IMAGE_GENERATE_MIPMAPS),
    gfx.CreateSkinImage("song_select/medal/uc.png", gfx.IMAGE_GENERATE_MIPMAPS),
    gfx.CreateSkinImage("song_select/medal/puc.png", gfx.IMAGE_GENERATE_MIPMAPS)
}

local passStates = {
    gfx.CreateSkinImage("challenge_select/pass_states/not_played.png", 0),
    gfx.CreateSkinImage("challenge_select/pass_states/failed.png", 0),
    gfx.CreateSkinImage("challenge_select/pass_states/cleared.png", 0)
}

local scoreNumbers = Numbers.load_number_image("score_num")
local percentImage = gfx.CreateSkinImage("score_num/percent.png", 0)

gfx.LoadSkinFont("dfmarugoth.ttf");

game.LoadSkinSample("menu_click")
game.LoadSkinSample("woosh")

-- Wheel variables
local wheelSize = 5

local selectedIndex = 1
local challengeCache = {}
local timer = 0

-- Window variables
local desw = 1080
local desh = 1920
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

local update_cache_labels = function(challenge, titleFontSize)
    if challengeCache[challenge.id] then
        local _, fontsize = gfx.LabelSize(challengeCache[challenge.id]["title"])
        if fontsize ~= titleFontSize then
            gfx.UpdateLabel(challengeCache[challenge.id]["title"], challengeCache[challenge.id]["title_raw"], titleFontSize)
            for _, chart in ipairs(challengeCache[challenge.id]["charts"]) do
                gfx.UpdateLabel(chart["title"], chart["title_raw"], titleFontSize)
            end
        end
    end
end

local check_or_create_cache = function(challenge)
    local defaultLabelSize = 16

    if not challengeCache[challenge.id] then
        challengeCache[challenge.id] = {}
    end

    if not challengeCache[challenge.id]["title"] then
        challengeCache[challenge.id]["title"] = gfx.CreateLabel(challenge.title, defaultLabelSize, 0)
        challengeCache[challenge.id]["title_raw"] = challenge.title
    end

    if not challengeCache[challenge.id]["charts"] then
        if challenge.missing_chart then
            local missing_text = "*COULD NOT FIND ALL CHARTS!*"
            challengeCache[challenge.id]["charts"] = {
                {
                    ["title"] = gfx.CreateLabel(missing_text, defaultLabelSize, 0),
                    ["title_raw"] = missing_text,
                    ["level"] = 0,
                    ["difficulty"] = 0,
                    ["jacketPath"] = "",
                }
            }
        else -- if not challenge.missing_chart then
            local charts = {}
            for _, chart in ipairs(challenge.charts) do
                table.insert(charts, {
                    ["title"] = gfx.CreateLabel(chart.title, defaultLabelSize, 0),
                    ["title_raw"] = chart.title,
                    ["level"] = chart.level,
                    ["difficulty"] = chart.difficulty,
                    ["jacketPath"] = chart.jacketPath,
                })
            end
            challengeCache[challenge.id]["charts"] = charts
        end
    end

    if not challengeCache[challenge.id]["percent_required"] then
        local percentRequired = 100
        local reqTextWords = Common.split(challenge.requirement_text, ' ');
        for _, word in ipairs(reqTextWords) do
            if string.find(word, '%%') ~= nil then -- %% = %, because % is an escape char
                local percentNumber = tonumber(string.gsub(word, '%%', ''), 10)
                percentRequired = percentNumber;
                break
            end
        end
        challengeCache[challenge.id]["percent_required"] = percentRequired
    end

    if (not challengeCache[challenge.id]["percent"] or not challengeCache[challenge.id]["total_score"]
        or challengeCache[challenge.id]["total_score"] ~= challenge.bestScore) then
        challengeCache[challenge.id]["percent"] = math.max(0, (challenge.bestScore - 8000000) // 10000)
        challengeCache[challenge.id]["total_score"] = challenge.bestScore
    end

    local passState = math.min(challenge.topBadge, 2) + 1 -- challenge.topBadge -> [1, 3]
    if (not challengeCache[challenge.id]["pass_state"] or not challengeCache[challenge.id]["pass_state_idx"]
        or challengeCache[challenge.id]["pass_state_idx"] ~= passState) then
        challengeCache[challenge.id]["pass_state_idx"] = passState
        challengeCache[challenge.id]["pass_state"] = passStates[passState]
    end

    local lastChart = challenge.charts[#challenge.charts]
    if not challengeCache[challenge.id]["jacket"] then
        if challenge.missing_chart then
            challengeCache[challenge.id]["jacket"] = jacketFallback
        else
            challengeCache[challenge.id]["jacket"] = gfx.LoadImageJob(lastChart.jacketPath, jacketFallback, 200, 200)
        end
    elseif not challenge.missing_chart and challengeCache[challenge.id]["jacket"] == jacketFallback then
        challengeCache[challenge.id]["jacket"] = gfx.LoadImageJob(lastChart.jacketPath, jacketFallback, 200, 200)
    end
end

draw_challenge = function(challenge, x, y, w, h, selected)
    if not challenge then
        return
    end

    check_or_create_cache(challenge)

    ----------------------------------------------------------
    -- draw card bg section
    ----------------------------------------------------------
    if not selected then
        gfx.BeginPath()
        gfx.ImageRect(x, y, w, h, challengeCardBGImage, 1, 0)
    end

    ----------------------------------------------------------
    -- draw info section
    ----------------------------------------------------------
    local stateLabel = challengeCache[challenge.id]["pass_state"]
    local stateLabelWidth, stateLabelHeight = gfx.ImageSize(stateLabel)
    local stateLabelAspect = stateLabelWidth / stateLabelHeight

    local stateWidth = w / 5
    local stateHeight = stateWidth / stateLabelAspect
    local stateOffsetX = x + w / 32
    local stateOffsetY = y + h / 32

    local titleMargin = 6
    local titleFontSize = math.floor(0.11 * h) -- must be an integer
    local titleMaxWidth = 6 / 9 * w
    local titleCenterX = x + w - titleMargin - titleMaxWidth / 2 -- align right
    local titleBaselineY = y + 0.025 * h -- align baseline

    if selected then
        stateWidth = stateWidth / 0.9
        stateHeight = stateHeight / 0.9
        stateOffsetY = y + h / 16

        titleFontSize = math.floor(0.075 * h) -- must be an integer
        titleMaxWidth = 3 / 5 * w
        titleCenterX = x + w - titleMargin - titleMaxWidth / 2 -- align right
        titleBaselineY = y + 0.09 * h -- align baseline
    end

    update_cache_labels(challenge, titleFontSize)

    gfx.BeginPath()
    gfx.ImageRect(stateOffsetX, stateOffsetY, stateWidth, stateHeight, stateLabel, 1, 0)

    gfx.FontFace("divlit_custom.ttf")
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER | gfx.TEXT_ALIGN_BASELINE)
    gfx.DrawLabel(challengeCache[challenge.id]["title"], titleCenterX, titleBaselineY, titleMaxWidth)

    ----------------------------------------------------------
    -- draw jacket section
    ----------------------------------------------------------
    local size = h * 0.68
    local offsetX = x + w / 32
    local offsetY = y + h - size - h * 0.05

    if not selected then
        size = h * 0.66
        offsetX = x + w * 0.058
        offsetY = y + h - size - h * 0.066
    end

    gfx.BeginPath()
    gfx.ImageRect(offsetX, offsetY, size, size, challengeCache[challenge.id]["jacket"], 1, 0)

    ----------------------------------------------------------
    -- draw stats section
    ----------------------------------------------------------
    local textSizeCorrection = h / gfx.ImageSize(scoreNumbers[1])

    local percentOffsetX = x + 0.5 * w
    local percentOffsetY = y + 0.87 * h
    local percentSize = 0.17 * textSizeCorrection
    local percentImageWidth, percentImageHeight = gfx.ImageSize(percentImage)
    local percentImageOffsetX = percentOffsetX + 0.08 * w

    local percentRequired = challengeCache[challenge.id]["percent_required"]
    local percentBarOffsetX = x + 0.281 * w
    local percentBarOffsetY = y + 0.856 * h
    local percentBarWidth = 0.273 * w
    local percentBarHeight = 0.02 * h
    local percentBarLeftColor = {255, 0, 0}
    local percentBarRightColor = {255, 128, 0}

    local scoreUpperOffsetX = 0
    local scoreUpperOffsetY = 0
    local scoreOffsetX = x + w * 0.74
    local scoreOffsetY = y + h * 0.9
    local scoreUpperSize = 0.2 * textSizeCorrection
    local scoreSize = 0.125 * textSizeCorrection

    local badgeOffsetX = x + 0.886 * w
    local badgeOffsetY = y + 0.8 * h
    local badgeSize = 0.155 * h

    local gradeOffsetX = x + 0.933 * w
    local gradeOffsetY = y + 0.798 * h
    local gradeSize = 0.163 * h

    local percent = challengeCache[challenge.id]["percent"]
    local scoreUpper = math.floor(challengeCache[challenge.id]["total_score"] / 10000)
    local score = challengeCache[challenge.id]["total_score"]
    local badge = challenge.topBadge and badges[challenge.topBadge] or nil
    local grade = challenge.grade and grades[challenge.grade] or nil

    if selected then
        percentOffsetX = x + 11 / 24 * w
        percentOffsetY = y + 49 / 64 * h
        percentSize = 0.12 * textSizeCorrection
        percentImageOffsetX = percentOffsetX + 0.074 * w

        scoreUpperOffsetX = x + w * 0.63
        scoreUpperOffsetY = y + h * 0.82
        scoreOffsetX = x + w * 0.762
        scoreOffsetY = y + h * 0.835
        scoreUpperSize = 0.12 * textSizeCorrection
        scoreSize = 0.09 * textSizeCorrection

        badgeOffsetX = x + 0.86 * w
        badgeOffsetY = y + 0.715 * h
        badgeSize = 0.165 * h

        gradeOffsetX = x + 0.927 * w
        gradeOffsetY = y + 0.708 * h
        gradeSize = 0.175 * h
    end

    percentImageWidth = percentImageWidth * percentSize * 0.75
    percentImageHeight = percentImageHeight * percentSize * 0.75
    percentImageOffsetY = percentOffsetY - percentImageHeight * 0.25

    -- Draw percentage
    Numbers.draw_number(percentOffsetX, percentOffsetY, 1, percent, 3, scoreNumbers, true, percentSize, 1, false)
    gfx.BeginPath()
    gfx.ImageRect(percentImageOffsetX, percentImageOffsetY, percentImageWidth, percentImageHeight, percentImage, 1, 0)

    if selected then
        -- Draw percentBar
        gfx.BeginPath()
        local paint = gfx.LinearGradient(
            percentBarOffsetX, percentBarOffsetY, 
            percentBarOffsetX + percentBarWidth, percentBarOffsetY
        )
        gfx.FillPaint(paint)
        gfx.GradientColors(
            percentBarLeftColor[1], percentBarLeftColor[2], percentBarLeftColor[3], 255,
            percentBarRightColor[1], percentBarRightColor[2], percentBarRightColor[3], 255
        )
        gfx.Rect(percentBarOffsetX, percentBarOffsetY, percentBarWidth * math.min(1, percent / percentRequired), percentBarHeight)
        gfx.Fill()

        -- Draw percentBar highlight
        gfx.BeginPath()
        gfx.FillColor(255, 255, 255, 64)
        gfx.Rect(percentBarOffsetX, percentBarOffsetY, percentBarWidth * math.min(1, percent / 100), percentBarHeight * 0.5)
        gfx.Fill()

        -- Draw score
        Numbers.draw_number(
            scoreUpperOffsetX, scoreUpperOffsetY, 1, scoreUpper, 4, scoreNumbers, true, scoreUpperSize, 1
        )
        Numbers.draw_number(scoreOffsetX, scoreOffsetY, 1, score, 4, scoreNumbers, true, scoreSize, 1)
    else
        Numbers.draw_number(scoreOffsetX, scoreOffsetY, 1, score, 8, scoreNumbers, true, scoreSize, 1)
    end

    if badge then
        gfx.BeginPath()
        gfx.ImageRect(badgeOffsetX, badgeOffsetY, 93/81 * badgeSize, badgeSize, badge, 1, 0)

        gfx.BeginPath()
        gfx.ImageRect(gradeOffsetX, gradeOffsetY, gradeSize, gradeSize, grade, 1, 0)
    end

    ----------------------------------------------------------
    -- draw charts section
    ----------------------------------------------------------
    local diffIconScale = 0.0048 * h

    local paddingY = 0.18 * h
    local offsetX = x + 0.242 * w
    local offsetY = y + 0.233 * h

    local titleMargin = 6
    local titleMaxWidth = 6 / 9 * w
    local titleCenterX = x + w - titleMargin - titleMaxWidth / 2 -- align right

    if selected then
        diffIconScale = 0.0032 * h

        paddingY = 0.123 * h
        offsetX = x + 0.259 * w
        offsetY = y + 0.248 * h

        titleFontSize = math.floor(0.075 * h) -- must be an integer
        titleMaxWidth = 3 / 5 * w
        titleCenterX = x + w - titleMargin - titleMaxWidth / 2 -- align right
    end

    for i, chart in ipairs(challengeCache[challenge.id]["charts"]) do
        local ypos = offsetY + paddingY * (i - 1)
        local adjustedDiff = Charting.GetDisplayDifficulty(chart.jacketPath, chart.difficulty)
        DiffRectangle.render(timer, offsetX, ypos, diffIconScale, adjustedDiff, chart.level)

        local _, titleHeight = gfx.LabelSize(chart.title)
        gfx.TextAlign(gfx.TEXT_ALIGN_CENTER | gfx.TEXT_ALIGN_MIDDLE)
        gfx.DrawLabel(chart.title, titleCenterX, ypos + titleHeight / 2, titleMaxWidth)
    end

    gfx.ForceRender()

end

draw_selected = function(challenge, x, y, w, h)
    if not challenge then
        return
    end

    check_or_create_cache(challenge)

    draw_challenge(challenge, x, y, w, h, true)

end

draw_chalwheel = function(x, y, w, h)
    local challengeAspect = 4.367
    local selectedChallengeAspect = 3.305

    local width = math.floor(w * 0.839)
    local height = math.floor(width / challengeAspect)

    local selectedWidth = math.floor(w * 0.944)
    local selectedHeight = math.floor(selectedWidth / selectedChallengeAspect)

    local offsetX = w / 2 - width / 2 -- center
    local centerY = h / 2 - height / 2
    local selectedOffsetX = w / 2 - selectedWidth / 2
    local selectedCenterY = h / 2 - selectedHeight / 2
    local margin = h / 128
    local centerMargin = h / 100

    local imin = math.ceil(selectedIndex - wheelSize / 2)
    local imax = math.floor(selectedIndex + wheelSize / 2)
    for i = math.max(imin, 1), math.min(imax, #chalwheel.challenges) do
        local current = selectedIndex - i
        if not (current == 0) then
            local challenge = chalwheel.challenges[i]
            local xpos = x + offsetX
            -- local offsetY = current * (height - (wheelSize / 2 * (current * aspectFloat)))
            local offsetY = math.abs(current) * (height + margin) + (selectedHeight - height) / 2
            local ypos = y + centerY
            if current < 0 then
                ypos = ypos + centerMargin + offsetY
            else -- if current > 0 then
                ypos = ypos - centerMargin - offsetY
            end
            draw_challenge(challenge, xpos, ypos, width, height)
        end
    end

    -- render selected song information
    local xpos = x + selectedOffsetX
    local ypos = y + selectedCenterY
    draw_selected(chalwheel.challenges[selectedIndex], xpos, ypos, selectedWidth, selectedHeight)
end

--[[ will be reimplemented sometime later
draw_legend_pane = function(x, y, w, h, obj)
    local xpos = x + 5
    local ypos = y
    local imageSize = h

    gfx.BeginPath()
    gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_LEFT)
    gfx.ImageRect(x, y, imageSize, imageSize, obj.image, 1, 0)
    xpos = xpos + imageSize + 5
    gfx.FontSize(16);
    if h < (w - (10 + imageSize)) / 2 then
        gfx.DrawLabel(obj.labelSingleLine, xpos, y + (h / 2), w - (10 + imageSize))
    else
        gfx.DrawLabel(obj.labelMultiLine, xpos, y + (h / 2), w - (10 + imageSize))
    end
    gfx.ForceRender()
end

draw_legend = function(x, y, w, h)
    gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_LEFT);
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, 170)
    gfx.Rect(x, y, w, h)
    gfx.Fill()
    local xpos = 10;
    local legendWidth = math.floor((w - 20) / #legendTable)
    for i, v in ipairs(legendTable) do
        local xOffset = draw_legend_pane(xpos + (legendWidth * (i - 1)), y + 5, legendWidth, h - 10, legendTable[i])
    end
end
--]]

--[[ will be reimplemented sometime later
draw_search = function(x, y, w, h)
    soffset = soffset + (searchIndex) - (chalwheel.searchInputActive and 0 or 1)
    if searchIndex ~= (chalwheel.searchInputActive and 0 or 1) then
        game.PlaySample("woosh")
    end
    searchIndex = chalwheel.searchInputActive and 0 or 1

    gfx.BeginPath()
    local bgfade = 1 - (searchIndex + soffset)
    -- if not chalwheel.searchInputActive then bgfade = soffset end
    gfx.FillColor(0, 0, 0, math.floor(200 * bgfade))
    gfx.Rect(0, 0, resX, resY)
    gfx.Fill()
    gfx.ForceRender()
    local xpos = x + (searchIndex + soffset) * w
    gfx.UpdateLabel(searchText, string.format("Search: %s", chalwheel.searchText), 30)

    gfx.BeginPath()
    gfx.RoundedRect(xpos, y, w, h, h / 2)
    gfx.FillColor(30, 30, 30)
    gfx.StrokeColor(0, 128, 255)
    gfx.StrokeWidth(1)
    gfx.Fill()
    gfx.Stroke()

    gfx.BeginPath();
    gfx.LoadSkinFont("dfmarugoth.ttf");
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.DrawLabel(searchText, xpos + 10, y + (h / 2), w - 20)

end
--]]

render = function(deltaTime)
    gfx.FontFace("dfmarugoth.ttf");

    -- detect resolution change
    local resx, resy = game.GetResolution();
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    -- draw background image
    gfx.BeginPath()
    local bgImageWidth, bgImageHeight = gfx.ImageSize(backgroundImage)
    gfx.Rect(0, 0, resX, resY)
    gfx.FillPaint(gfx.ImagePattern(0, 0, bgImageWidth, bgImageHeight, 0, backgroundImage, 0.2))
    gfx.Fill()

    if chalwheel.challenges and chalwheel.challenges[1] then
        local wheelCenterX = (resX - fullX) / 2
        -- draw surface background
        gfx.BeginPath()
        gfx.ImageRect(wheelCenterX, 0, fullX, fullY, challengeBGImage, 1, 0)

        -- draw chalwheel
        gfx.BeginPath();
        draw_chalwheel(wheelCenterX, 0, fullX, fullY)

        -- Draw Legend Information
        --[[ will be reimplemented sometime later
        draw_legend(0, fullX * 14 / 15, fullX, fullY / 15)
        --]]

        -- draw text search
        --[[ will be reimplemented sometime later
        draw_search(fullX * 2 / 5, 5, fullX * 3 / 5, fullY / 25)

        soffset = soffset * 0.8
        if chalwheel.searchStatus then
            gfx.BeginPath()
            gfx.FillColor(255, 255, 255)
            gfx.FontSize(20);
            gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
            gfx.Text(chalwheel.searchStatus, 3, 3)
        end
        --]]

        gfx.Translate(wheelCenterX, 0)
        gfx.Scale(fullX / desw, fullY / desh);

        Header.draw(deltaTime)
        Footer.draw(deltaTime)

        gfx.ResetTransform()
    end
end

get_page_size = function()
    return math.floor(wheelSize / 2)
end

set_index = function(newIndex, scrollamt)
    if newIndex ~= selectedIndex then
        game.PlaySample("menu_click")
    end
    selectedIndex = newIndex
end

challenges_changed = function(withAll)

end
