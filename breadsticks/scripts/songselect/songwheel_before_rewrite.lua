-- game.Log("Something went wrong!", game.LOGGER_ERROR)

--Horizontal alignment
TEXT_ALIGN_LEFT 	= 1
TEXT_ALIGN_CENTER 	= 2
TEXT_ALIGN_RIGHT 	= 4
--Vertical alignment
TEXT_ALIGN_TOP 		= 8
TEXT_ALIGN_MIDDLE	= 16
TEXT_ALIGN_BOTTOM	= 32
TEXT_ALIGN_BASELINE	= 64

local jacket = nil;
local selectedIndex = 1
local selectedDiff = 1
local songCache = {}
local ioffset = 0
local doffset = 0
local soffset = 0
local diffColors = {{0,0,255}, {0,255,0}, {255,0,0}, {255, 0, 255}}
local timer = 0
local effector = 0
local searchText = gfx.CreateLabel("",5,0)
local searchIndex = 1
local jacketFallback = gfx.CreateSkinImage("song_select/loading.png", 0)
local showGuide = game.GetSkinSetting("show_guide")
local legendTable = {
  {["labelSingleLine"] =  gfx.CreateLabel("DIFFICULTY SELECT",16, 0), ["labelMultiLine"] =  gfx.CreateLabel("DIFFICULTY\nSELECT",16, 0), ["image"] = gfx.CreateSkinImage("legend/knob-left.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("MUSIC SELECT",16, 0),      ["labelMultiLine"] =  gfx.CreateLabel("MUSIC\nSELECT",16, 0),      ["image"] = gfx.CreateSkinImage("legend/knob-right.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("FILTER MUSIC",16, 0),      ["labelMultiLine"] =  gfx.CreateLabel("FILTER\nMUSIC",16, 0),      ["image"] = gfx.CreateSkinImage("legend/FX-L.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("SORT MUSIC",16, 0),        ["labelMultiLine"] =  gfx.CreateLabel("SORT\nMUSIC",16, 0),        ["image"] = gfx.CreateSkinImage("legend/FX-R.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("MUSIC MODS",16, 0),        ["labelMultiLine"] =  gfx.CreateLabel("MUSIC\nMODS",16, 0),        ["image"] = gfx.CreateSkinImage("legend/FX-LR.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("PLAY",16, 0),              ["labelMultiLine"] =  gfx.CreateLabel("PLAY",16, 0),               ["image"] = gfx.CreateSkinImage("legend/start.png", 0)}
}
local grades = {
  {["max"] = 6999999, ["image"] = gfx.CreateSkinImage("common/grades/D.png", 0)},
  {["max"] = 7999999, ["image"] = gfx.CreateSkinImage("common/grades/C.png", 0)},
  {["max"] = 8699999, ["image"] = gfx.CreateSkinImage("common/grades/B.png", 0)},
  {["max"] = 8999999, ["image"] = gfx.CreateSkinImage("common/grades/A.png", 0)},
  {["max"] = 9299999, ["image"] = gfx.CreateSkinImage("common/grades/A+.png", 0)},
  {["max"] = 9499999, ["image"] = gfx.CreateSkinImage("common/grades/AA.png", 0)},
  {["max"] = 9699999, ["image"] = gfx.CreateSkinImage("common/grades/AA+.png", 0)},
  {["max"] = 9799999, ["image"] = gfx.CreateSkinImage("common/grades/AAA.png", 0)},
  {["max"] = 9899999, ["image"] = gfx.CreateSkinImage("common/grades/AAA+.png", 0)},
  {["max"] = 99999999, ["image"] = gfx.CreateSkinImage("common/grades/S.png", 0)}
}

local badges = {
  gfx.CreateSkinImage("badges/played.png", 0),
  gfx.CreateSkinImage("badges/clear.png", 0),
  gfx.CreateSkinImage("badges/hard-clear.png", 0),
  gfx.CreateSkinImage("badges/full-combo.png", 0),
  gfx.CreateSkinImage("badges/perfect.png", 0)
}

local difficultyNumbers = {
  [0] = gfx.CreateSkinImage("diff_num/0.png", 0),
  [1] = gfx.CreateSkinImage("diff_num/1.png", 0),
  [2] = gfx.CreateSkinImage("diff_num/2.png", 0),
  [3] = gfx.CreateSkinImage("diff_num/3.png", 0),
  [4] = gfx.CreateSkinImage("diff_num/4.png", 0),
  [5] = gfx.CreateSkinImage("diff_num/5.png", 0),
  [6] = gfx.CreateSkinImage("diff_num/6.png", 0),
  [7] = gfx.CreateSkinImage("diff_num/7.png", 0),
  [8] = gfx.CreateSkinImage("diff_num/8.png", 0),
  [9] = gfx.CreateSkinImage("diff_num/9.png", 0),
};

local difficultyNameOverlays = {
  [0] = gfx.CreateSkinImage("song_select/level/novice.png", 0),
  [1] = gfx.CreateSkinImage("song_select/level/advanced.png", 0),
  [2] = gfx.CreateSkinImage("song_select/level/exhaust.png", 0),
  [3] = gfx.CreateSkinImage("song_select/level/maximum.png", 0),
  [4] = gfx.CreateSkinImage("song_select/level/maximum.png", 0),
  [5] = gfx.CreateSkinImage("song_select/level/maximum.png", 0),
  [6] = gfx.CreateSkinImage("song_select/level/maximum.png", 0),
  [7] = gfx.CreateSkinImage("song_select/level/maximum.png", 0),
}

local difficultyLevelCursor = gfx.CreateSkinImage("song_select/level_cursor.png", 0);

local foreground = gfx.CreateSkinImage("song_select/fg.png", 0);

local datapanel = gfx.CreateSkinImage("song_select/data_bg.png", 0);

local recordCache = {}

gfx.LoadSkinFont("dfmarugoth.ttf");

game.LoadSkinSample("menu_click")
game.LoadSkinSample("click-02")
game.LoadSkinSample("woosh")

local wheelSize = 12

get_page_size = function()
    return math.floor(wheelSize/2)
end

-- Responsive UI variables
-- Aspect Ratios
local aspectFloat = 1.850
local aspectRatio = "widescreen"
local landscapeWidescreenRatio = 1.850
local landscapeStandardRatio = 1.500
local portraitWidescreenRatio = 0.5

-- Responsive sizes
local fifthX = 0
local fourthX= 0
local thirdX = 0
local halfX  = 0
local fullX  = 0

local fifthY = 0
local fourthY= 0
local thirdY = 0
local halfY  = 0
local fullY  = 0


adjustScreen = function(x,y)
  local a = x/y;
  if x >= y and a <= landscapeStandardRatio then
    aspectRatio = "landscapeStandard"
    aspectFloat = 1.1
  elseif x >= y and landscapeStandardRatio <= a and a <= landscapeWidescreenRatio then
    aspectRatio = "landscapeWidescreen"
    aspectFloat = 1.2
  elseif x <= y and portraitWidescreenRatio <= a and a < landscapeStandardRatio then
    aspectRatio = "PortraitWidescreen"
    aspectFloat = 0.5
  else
    aspectRatio = "landscapeWidescreen"
    aspectFloat = 1.0
  end
  fifthX = x/5
  fourthX= x/4
  thirdX = x/3
  halfX  = x/2
  fullX  = x

  fifthY = y/5
  fourthY= y/4
  thirdY = y/3
  halfY  = y/2
  fullY  = y
end


check_or_create_cache = function(song, loadJacket)
    if not songCache[song.id] then songCache[song.id] = {} end

    if not songCache[song.id]["title"] then
        songCache[song.id]["title"] = gfx.CreateLabel(song.title, 14, 0)
    end

    if not songCache[song.id]["artist"] then
        songCache[song.id]["artist"] = gfx.CreateLabel(song.artist, 14, 0)
    end

    if not songCache[song.id]["bpm"] then
        songCache[song.id]["bpm"] = gfx.CreateLabel(string.format("%s",song.bpm), 12, 0)
    end

   	if not songCache[song.id]["effector"] then
        songCache[song.id]["effector"] = gfx.CreateLabel(string.format("BPM: %s",song.bpm), 20, 0)
    end

    if not songCache[song.id]["jacket"] then
        songCache[song.id]["jacket"] = { }
    end

    for i = 1, #song.difficulties do
        songCache[song.id]["jacket"][i] = gfx.LoadImageJob(song.difficulties[i].jacketPath, jacketFallback, 400, 400)
    end
end

function record_handler_factory(hash)
    return (function(res)
        if res.statusCode == 42 then
            recordCache[hash] = {good=false, reason="Untracked"}
        elseif res.statusCode == 20 and res.body ~= nil then
            recordCache[hash] = {good=true, record=res.body.record}
        elseif res.statusCode == 44 then
            recordCache[hash] = {good=true, record=nil}
        else
            recordCache[hash] = {good=false, reason="Failed"}
        end
    end)
end

function get_record(hash)
    if recordCache[hash] then return recordCache[hash] end

    recordCache[hash] = {good=false, reason="Loading..."}

    IR.Record(hash, record_handler_factory(hash))

    return recordCache[hash]
end

function log_table(table)
    str = "{"
    for k, v in pairs(table) do
        str = str .. k .. ": "

        t = type(v)

        if t == "table" then
            str = str .. log_table(v)
        elseif t == "string" then
            str = str .. "\"" .. v .. "\""
        elseif t == "boolean" then
            if v then
                str = str .. "true"
            else
                str = str .. "false"
            end
        else
            str = str .. v
        end

        str = str .. ", "
    end

    return str .. "}"
end

draw_scores_ir = function(difficulty, x, y, w, h)
    -- draw the top score for this difficulty
    local xOffset = 5
    local height = h/3 - 10
    local ySpacing = h/3
    local yOffset = h/3
    gfx.FontSize(30);
    gfx.TextAlign(gfx.TEXT_ALIGN_BOTTOM + gfx.TEXT_ALIGN_CENTER);

    gfx.FastText("HIGH SCORE", x +(w/4), y+(h/2))
    gfx.FastText("IR RECORD", x + (3/4 * w), y + (h/2))

    gfx.BeginPath()
    gfx.Rect(x+xOffset,y+h/2,w/2-(xOffset*2),h/2)
    gfx.FillColor(30,30,30,10)
    gfx.StrokeColor(0,128,255)
    gfx.StrokeWidth(1)
    gfx.Fill()
    gfx.Stroke()

    gfx.BeginPath()
    gfx.Rect(x + xOffset + w/2,y+h/2,w/2-(xOffset*2),h/2)
    gfx.FillColor(30,30,30,10)
    gfx.StrokeColor(0,128,255)
    gfx.StrokeWidth(1)
    gfx.Fill()
    gfx.Stroke()

    if difficulty.scores[1] ~= nil then
		local highScore = difficulty.scores[1]
        scoreLabel = gfx.CreateLabel(string.format("%08d",highScore.score), 40, 0)
        for i,v in ipairs(grades) do
            if v.max > highScore.score then
                gfx.BeginPath()
                iw,ih = gfx.ImageSize(v.image)
                iarr = ih / iw
                oldheight = h/2 - 10
                newheight =  iarr * (h/2-10)
                centreoffset = (oldheight - newheight)/2 + 3 -- +3 is stupid but ehhh
                gfx.ImageRect(x+xOffset, y+h/2 + centreoffset, oldheight,  newheight, v.image, 1, 0) --this is nasty but it works for me
                break
            end
        end
        if difficulty.topBadge ~= 0 then
            gfx.BeginPath()
            gfx.ImageRect(x+xOffset+w/2-h/2, y+h/2 +5, (h/2-10), h/2-10, badges[difficulty.topBadge], 1, 0)
        end

        gfx.FillColor(255,255,255)
    	gfx.FontSize(40);
        gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_CENTER);
    	gfx.DrawLabel(scoreLabel, x+(w/4),y+(h/4)*3,w/2)
	end

    irRecord = get_record(difficulty.hash)

    if not irRecord.good then
        recordLabel = gfx.CreateLabel(irRecord.reason, 40, 0)
        gfx.FillColor(255, 255, 255)
        gfx.FontSize(40)
        gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_CENTER);
    	gfx.DrawLabel(recordLabel, x+(w * 3/4),y+(h/4)*3,w/2)
    elseif irRecord.record == nil then --record not set, but can be tracked
        recordLabel = gfx.CreateLabel(string.format("%08d", 0), 40, 0)
        gfx.FillColor(170, 170, 170)
        gfx.FontSize(40)
        gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_CENTER);
        gfx.DrawLabel(recordLabel, x+(w * 3/4),y+(h/4)*3,w/2)
    else

        recordScoreLabel = gfx.CreateLabel(string.format("%08d", irRecord.record.score), 26, 0)
        recordPlayerLabel = gfx.CreateLabel(irRecord.record.username, 26, 0)

        if irRecord.record.lamp ~= 0 then
            gfx.BeginPath()
            gfx.ImageRect(x+xOffset+w-h/2, y+h/2 +5, (h/2-10), h/2-10, badges[irRecord.record.lamp], 1, 0)
        end

        for i,v in ipairs(grades) do
            if v.max > irRecord.record.score then
                gfx.BeginPath()
                iw,ih = gfx.ImageSize(v.image)
                iarr = ih / iw
                oldheight = h/2 - 10
                newheight =  iarr * (h/2-10)
                centreoffset = (oldheight - newheight)/2 + 3 -- +3 is stupid but ehhh
                gfx.ImageRect(x+xOffset+w/2, y+h/2 + centreoffset, oldheight,  newheight, v.image, 1, 0) --this is nasty but it works for me
                break
            end
        end

        gfx.FillColor(255, 255, 255)
        gfx.FontSize(40)
        gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_CENTER);
    	gfx.DrawLabel(recordPlayerLabel, x+(w * 3/4),y+(h/4)*2.55,w/2)
        gfx.DrawLabel(recordScoreLabel, x+(w * 3/4),y+(h/4)*3.45,w/2)
    end
end

draw_scores = function(difficulty, x, y, w, h)
    if IRData.Active then return draw_scores_ir(difficulty, x, y, w, h) end

  -- draw the top score for this difficulty
	local xOffset = 5
  local height = h/3 - 10
  local ySpacing = h/3
	local yOffset = h/3
  gfx.FontSize(30);
  gfx.TextAlign(gfx.TEXT_ALIGN_BOTTOM + gfx.TEXT_ALIGN_CENTER);
  gfx.BeginPath()
  gfx.FillColor(30,30,30,10)
  gfx.StrokeColor(0,128,255)
  gfx.StrokeWidth(1)
  gfx.Fill()
  gfx.Stroke()
	if difficulty.scores[1] ~= nil then
		local highScore = difficulty.scores[1]
    scoreLabel = gfx.CreateLabel(string.format("%08d",highScore.score), 40, 0)
    for i,v in ipairs(grades) do
      if v.max > highScore.score then
        gfx.BeginPath()
        iw,ih = gfx.ImageSize(v.image)
        iar = iw / ih;
        --gfx.ImageRect(x+xOffset,y+h/2 +5, iar * (h/2-10),h/2-10, v.image, 1, 0)
        break
      end
    end
    if difficulty.topBadge ~= 0 then
        gfx.BeginPath()
        --gfx.ImageRect(x+xOffset+w-h/2, y+h/2 +5, (h/2-10), h/2-10, badges[difficulty.topBadge], 1, 0)
    end
    gfx.FillColor(255,255,255)
		gfx.FontSize(40);
    gfx.TextAlign(gfx.TEXT_ALIGN_BOTTOM + gfx.TEXT_ALIGN_LEFT);
		gfx.DrawLabel(scoreLabel, x/11,y/1.48,w*2)
	end
end

function deep_to_string(t)
  local tType = type(t);
  if (tType ~= "table") then
    return tostring(t);
  end
  
  local result = "{";

  for k, v in next, t do
    local kType = type(k);
    local vType = type(v);

    local keyString = deep_to_string(k);
    local valueString = deep_to_string(v);

    if (#result > 1) then
      result = result .. ";";
    end

    result = result .. keyString .. "=" .. valueString;
  end

  return result .. "}";
end

draw_song = function(song, x, y, w, h, selected)
  -- game.Log("draw_song", game.LOGGER_ERROR);

  local diffIndex = math.min(selectedDiff, #song.difficulties)
  local difficulty = song.difficulties[diffIndex]
  local clearLampR = 255
  local clearLampG = 255
  local clearLampB = 255
  local clearLampA = 100

  if difficulty ~= nil then
    -- game.Log(deep_to_string(difficulty), game.LOGGER_ERROR);
    if difficulty.scores[1] ~= nil then
      if difficulty.topBadge == 1 then -- fail/played
        clearLampR = 255
        clearLampG = 25
        clearLampB = 25
        clearLampA = 200
      end
      if difficulty.topBadge == 2 then -- clear
        clearLampR = 25
        clearLampG = 255
        clearLampB = 25
        clearLampA = 200
      end
      if difficulty.topBadge == 3 then -- hard clear
        clearLampR = 255
        clearLampG = 25
        clearLampB = 255
        clearLampA = 200
      end
      if difficulty.topBadge == 4 then -- full combo
        clearLampR = 255
        clearLampG = 100
        clearLampB = 25
        clearLampA = 200
      end
      if difficulty.topBadge == 5 then -- perfect
        clearLampR = 255
        clearLampG = 255
        clearLampB = 25
        clearLampA = 200
      end
    end
  end
  -- game.Log("  past difficulty check", game.LOGGER_ERROR);

  check_or_create_cache(song)
  gfx.BeginPath()
  gfx.Rect(x+1,y+1, w-2, h-2)
  gfx.FillColor(220,220,220)
  gfx.StrokeColor(0,8,0)
  gfx.StrokeWidth(2)
  gfx.Fill()
  gfx.Stroke()
  gfx.FillColor(255,255,255)
  if songCache[song.id]["jacket"][diffIndex] then
      gfx.BeginPath()
      gfx.ImageRect(x+2, y+2, h-4, h-4, songCache[song.id]["jacket"][diffIndex], 1, 0)
  end

  -- Song title
  gfx.BeginPath()
  gfx.Rect(x+1, y + h - h/4 - 1, w-2, h/4)
  gfx.FillColor(0,0,0,200)
  gfx.Fill()

  gfx.BeginPath()
  gfx.FillColor(255,255,255)
  gfx.TextAlign(gfx.TEXT_ALIGN_BOTTOM + gfx.TEXT_ALIGN_LEFT)
  gfx.DrawLabel(songCache[song.id]["title"], (x)+h/2 + 4, y + h - 7, -1)
  --gfx.DrawLabel(songCache[song.id]["artist"], x+10, y + 50, w-10)

  -- Song difficulty
  gfx.BeginPath()
  gfx.Rect(x - 1, y + h-h/2 - 4, h/2, h/2)
  gfx.FillColor(0,0,0,200)
  gfx.Fill()

  gfx.FillColor(255,255,255)
  gfx.LoadSkinFont("commext.ttf")
  gfx.FontSize(28)
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_BOTTOM)

  if (song.difficulties[selectedDiff] ~= nil) then
    gfx.FastText(song.difficulties[selectedDiff].level, x + h/4, y + h - 10)
  else
    --gfx.FastText(song.difficulties[selectedDiff - 1].level, x + h/4, y + h - 10)
  end

  -- CLEAN THIS SHIT UP
  local diff_long = ""
  local diff_short = ""
  if (song.difficulties[selectedDiff] ~= nil) then
    if (song.difficulties[selectedDiff].difficulty == 0) then
      diff_long = "NOVICE"
      diff_short = "NOV"
    elseif (song.difficulties[selectedDiff].difficulty == 1) then
      diff_long = "ADVANCED"
      diff_short = "ADV"
    elseif (song.difficulties[selectedDiff].difficulty == 2) then
      diff_long = "EXHAUST"
      diff_short = "EXH"
    elseif (song.difficulties[selectedDiff].difficulty == 3) then
      diff_long = "MAXIMUM"
      diff_short = "MXM"
    else
      diff_long = "UNKNOWN"
      diff_short = "???"
    end
  end

  gfx.FontSize(8)
  gfx.LoadSkinFont("dfmarugoth.ttf")
  gfx.FastText(diff_long, x + h/4, y + h - 7)

  if (false) then

    local seldiff = nil
    if song.difficulties[selectedDiff] ~= nil then
      seldiff = selectedDiff
    else
      seldiff = selectedDiff
    end

    if song.difficulties[seldiff].topBadge ~= 0 then
      if song.difficulties[seldiff].scores[1] ~= nil then
        local highScore = song.difficulties[seldiff].scores[1]
        for i,v in ipairs(grades) do
          if v.max > highScore.score then
            gfx.BeginPath()
            iw,ih = gfx.ImageSize(v.image)
            iar = iw / ih;
            gfx.ImageRect(x + w/1.45, y + h/8 + 2, (h/1.5-14), h/1.5-14, v.image, 1, 0)
            break
          end
        end
      end
      gfx.BeginPath()
      gfx.ImageRect(x + w/2, y + h/8, (h/1.5-10), h/1.5-10, badges[song.difficulties[seldiff].topBadge], 1, 0)
    end

  end
end

draw_diff_icon = function(diff, x, y, w, h, selected)
  local difficultyIndex = diff.difficulty;
  
  local image = difficultyNameOverlays[difficultyIndex];

  local imgx, imgy = gfx.ImageSize(image);
  local aspect = imgx / imgy;

  h = h * 98 / 112;

  local wa = h * aspect;

  gfx.BeginPath();
  gfx.ImageRect(x - wa / 2, y - h / 2, wa, h, image, 1, 0);
  
  local level = diff.level;

  local firstDigit = difficultyNumbers[math.max(0, math.floor(level / 10))];
  local secondDigit = difficultyNumbers[level % 10];
  
  h = h * 0.475;

  imgx, imgy = gfx.ImageSize(firstDigit);
  aspect = imgx / imgy;

  wa = h * aspect;

  gfx.BeginPath();
  gfx.ImageRect(x - wa, y - h / 2, wa, h, firstDigit, 1, 0);

  gfx.BeginPath();
  gfx.ImageRect(x, y - h / 2, wa, h, secondDigit, 1, 0);
end

draw_cursor = function(x, y, h)
  local imgx, imgy = gfx.ImageSize(difficultyLevelCursor);
  local aspect = imgx / imgy;

  local w = h * aspect;

  gfx.BeginPath();
  gfx.ImageRect(x - w / 2, y - h / 2, w, h, difficultyLevelCursor, 1, 0);
end

draw_diffs = function(diffs, x, y, w, h)
  local diffWidth = w / 5
  local diffHeight = diffWidth

  for i = 1, #diffs do
    local diff = diffs[i]

    local xPos = x + w * (i - 0.5) / 4;
    local yPos = y + h / 2;

    if (i == selectedDiff) then
      draw_cursor(xPos, yPos, diffHeight);
    end

    draw_diff_icon(diff, xPos, yPos, diffWidth, diffHeight, i == selectedDiff);
  end
end

draw_selected = function(song, x, y, w, h)
    check_or_create_cache(song)
    -- set up padding and margins
    local xPadding = math.floor(w/16)
    local yPadding =  math.floor(h/32)
    local xMargin = math.floor(w/16)
    local yMargin =  math.floor(h/32)
    local width = (w-(xMargin*2))
    local height = (h-(yMargin*2))
    local xpos = x+xMargin
    local ypos = y+yMargin
    if aspectRatio == "PortraitWidescreen" then
      xPadding = math.floor(w/32)
      yPadding =  math.floor(h/32)
      xMargin = math.floor(w/34)
      yMargin =  math.floor(h/32)
      width = ((w/2)-(xMargin))
      height = (h-(yMargin*2))
      xpos = x+xMargin/2
      ypos = y+yMargin
    end
    --Border
    local diff = song.difficulties[selectedDiff]
    gfx.BeginPath()
    --gfx.RoundedRectVarying(xpos,ypos,width,height,yPadding,yPadding,yPadding,yPadding)
    gfx.FillColor(30,30,30,100)
    gfx.StrokeColor(0,128,255)
    gfx.StrokeWidth(1)
    gfx.Fill()
    gfx.Stroke()

    -- jacket should take up 1/3 of height, always be square, and be centered
    local imageSize = math.floor(height/3)
    local imageXPos = ((width/2) - (imageSize/2)) + x+xMargin
    if aspectRatio == "PortraitWidescreen" then
      --Unless its portrait widesreen..
      imageSize = math.floor((height/8)*1.58)
      imageXPos = (x+w)/16+(xMargin*0.8)
    end
    if not songCache[song.id][selectedDiff] or songCache[song.id][selectedDiff] ==  jacketFallback then
        songCache[song.id][selectedDiff] = gfx.LoadImageJob(diff.jacketPath, jacketFallback, 200,200)
    end

    if songCache[song.id][selectedDiff] then
        gfx.BeginPath()
        gfx.ImageRect(imageXPos, y+yMargin*4.45+yPadding, imageSize, imageSize, songCache[song.id][selectedDiff], 1, 0)
    end
    -- difficulty should take up 1/6 of height, full width, and be centered
    gfx.LoadSkinFont("commext.ttf")
    if aspectRatio == "PortraitWidescreen" then
      --difficulty wheel should be right below the jacketImage, and the same width as
      --the jacketImage
      local diffPanelWidth = w * 0.4275;
      local diffPanelHeight = diffPanelWidth / 4;
      draw_diffs(song.difficulties, (w / 2 - diffPanelWidth) / 2, y + 0.5687583444592 * h - diffPanelHeight / 2, diffPanelWidth, diffPanelHeight)
    else
      -- difficulty should take up 1/6 of height, full width, and be centered
      draw_diffs(song.difficulties,(w/2)-(imageSize/2),(ypos+yPadding+imageSize),imageSize,math.floor(height/6))
    end
    -- effector / bpm should take up 1/3 of height, full width
    gfx.LoadSkinFont("dfmarugoth.ttf")
    if aspectRatio == "PortraitWidescreen" then
      gfx.FontSize(40)
      gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_LEFT)
      gfx.DrawLabel(songCache[song.id]["title"], xpos+xPadding/2, y+yMargin*15+yPadding, width)
      gfx.FontSize(40)
      gfx.DrawLabel(songCache[song.id]["artist"], xpos+xPadding/2, y+yMargin*15.8+yPadding, width)
      gfx.FontSize(10)
      gfx.DrawLabel(songCache[song.id]["bpm"], xpos+xPadding*2, y+yMargin*14.42+yPadding, width-imageSize)
      gfx.FastText(string.format("%s", diff.effector), xpos+xPadding*7.5, y+yMargin*18.87+yPadding)
    else
      gfx.FontSize(40)
      gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_LEFT)
      gfx.DrawLabel(songCache[song.id]["title"], xpos+10, (height/10)*6, width-20)
      gfx.FontSize(30)
      gfx.DrawLabel(songCache[song.id]["artist"], xpos+10, (height/10)*6 + 45, width-20)
      gfx.FillColor(255,255,255)
      gfx.FontSize(20)
      gfx.DrawLabel(songCache[song.id]["bpm"], xpos+10, (height/10)*6 + 85)
      gfx.FastText(string.format("%s", diff.effector),xpos+10, (height/10)*6 + 115)
    end
    if aspectRatio == "PortraitWidescreen" then
      draw_scores(diff, xpos+xPadding+imageSize+3,  (height/3)*2, width-imageSize-20, (height/3)-yPadding)
    else
      draw_scores(diff, xpos, (height/6)*5, width, (height/6))
    end
    gfx.ForceRender()
end

draw_songwheel = function(x,y,w,h)
  local offsetX = fifthX/2
  local width = math.floor((w/5)*4)
  if aspectRatio == "landscapeWidescreen" then
    wheelSize = 12
    offsetX = 80
  elseif aspectRatio == "landscapeStandard" then
    wheelSize = 10
    offsetX = 40
  elseif aspectRatio == "PortraitWidescreen" then
    wheelSize = 20
    offsetX = 20
    width = w/2
  end
  local height = math.floor((h/wheelSize)*1.75)

  for i = math.max(selectedIndex - wheelSize/2, 1), math.max(selectedIndex - 1,0) do
      local song = songwheel.songs[i]
      local xpos = x + width
      local offsetY = (selectedIndex - i + ioffset/2) * ( height * 1.0)
      local ypos = y+((h/2 - height/2) - offsetY)
      draw_song(song, xpos, ypos, width, height)
  end

  --after selected
  for i = math.min(selectedIndex + wheelSize/2, #songwheel.songs), selectedIndex + 1,-1 do
      local song = songwheel.songs[i]
      local xpos = x + width
      local offsetY = (selectedIndex - i + ioffset/2) * ( height * 1.0)
      local ypos = y+((h/2 - height/2) - (selectedIndex - i) - offsetY)
      local alpha = 255 - (selectedIndex - i + ioffset) * 31
      draw_song(song, xpos, ypos, width, height)
  end
  -- draw selected
  local xpos = x + width
  local offsetY = (ioffset/2) * ( height - (wheelSize/2*((1)*aspectFloat)))
  local ypos = y+((h/2 - height/2) - (ioffset) - offsetY)
  draw_song(songwheel.songs[selectedIndex], xpos, ypos, width, height, true)
  -- cursor
  gfx.BeginPath()
  local ypos = y+((h/2 - height/2))
  gfx.Rect(xpos, ypos, width, height)
  gfx.FillColor(0,0,0,0)
  gfx.StrokeColor(255,128,0)
  gfx.StrokeWidth(3)
  gfx.Fill()
  gfx.Stroke()

  return songwheel.songs[selectedIndex]
end
draw_legend_pane = function(x,y,w,h,obj)
  local xpos = x+5
  local ypos = y
  local imageSize = h
  gfx.BeginPath()
  gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_LEFT)
  gfx.ImageRect(x, y, imageSize, imageSize, obj.image, 1, 0)
  xpos = xpos + imageSize + 5
  gfx.FontSize(16);
  if h < (w-(10+imageSize))/2 then
    gfx.DrawLabel(obj.labelSingleLine, xpos, y+(h/2), w-(10+imageSize))
  else
    gfx.DrawLabel(obj.labelMultiLine, xpos, y+(h/2), w-(10+imageSize))
  end
  gfx.ForceRender()
end

draw_legend = function(x,y,w,h)
  gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_LEFT);
  gfx.BeginPath()
  gfx.FillColor(0,0,0,170)
  gfx.Rect(x,y,w,h)
  gfx.Fill()
  local xpos = 10;
  local legendWidth = math.floor((w-20)/#legendTable)
  for i,v in ipairs(legendTable) do
    local xOffset = draw_legend_pane(xpos+(legendWidth*(i-1)), y+5,legendWidth,h-10,legendTable[i])
  end
end

draw_search = function(x,y,w,h)
  soffset = soffset + (searchIndex) - (songwheel.searchInputActive and 0 or 1)
  if searchIndex ~= (songwheel.searchInputActive and 0 or 1) then
      game.PlaySample("woosh")
  end
  searchIndex = songwheel.searchInputActive and 0 or 1

  gfx.BeginPath()
  local bgfade = 1 - (searchIndex + soffset)
  --if not songwheel.searchInputActive then bgfade = soffset end
  gfx.FillColor(0,0,0,math.floor(200 * bgfade))
  gfx.Rect(0,0,resx,resy)
  gfx.Fill()
  gfx.ForceRender()
  local xpos = x + (searchIndex + soffset)*w
  gfx.UpdateLabel(searchText ,string.format("Search: %s",songwheel.searchText), 30, 0)
  gfx.BeginPath()
  gfx.RoundedRect(xpos,y,w,h,h/2)
  gfx.FillColor(30,30,30)
  gfx.StrokeColor(0,128,255)
  gfx.StrokeWidth(1)
  gfx.Fill()
  gfx.Stroke()
  gfx.BeginPath();
  gfx.LoadSkinFont("NotoSans-Regular.ttf");
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.DrawLabel(searchText, xpos+10,y+(h/2), w-20)

end

render = function(deltaTime)
  gfx.ResetTransform()
    timer = (timer + deltaTime)
    timer = timer % 2
    resx,resy = game.GetResolution();
    -- game.Log("res :: " .. resx .. "," .. resy, game.LOGGER_ERROR);
    adjustScreen(resx,resy);
    gfx.BeginPath();
    gfx.LoadSkinFont("dfmarugoth.ttf");
    gfx.FontSize(40);
    gfx.FillColor(255,255,255);
	gfx.ImageRect(0, 0, resx, resy, datapanel, 1, 0);
    if songwheel.songs[1] ~= nil then
      --draw songwheel and get selected song
      if aspectRatio == "PortraitWidescreen" then
        local song = draw_songwheel(0,0,fullX,fullY)
        --render selected song information
        draw_selected(song, 0,0,fullX,resy)
      else
        local song = draw_songwheel(0,0,fullX,fullY)
        --render selected song information
        draw_selected(song, 0,0,fullX,resy)
      end
    end
    --Draw Legend Information
	-- if showGuide then
	-- 	if aspectRatio == "PortraitWidescreen" then
	-- 		draw_legend(0,(fifthY/3)*14, fullX, (fifthY/3)*1)
	-- 	else
	-- 		draw_legend(0,(fifthY/2)*9, fullX, (fifthY/2))
	-- 	end
	-- end
    gfx.BeginPath();
    gfx.TextAlign(TEXT_ALIGN_CENTER + TEXT_ALIGN_MIDDLE);
    gfx.ImageRect(0, 0, resx, resy, foreground, 1, 0);

    --draw text search
    if aspectRatio == "PortraitWidescreen" then
      draw_search(fifthX*2,5,fifthX*3,fifthY/5)
    else
      draw_search(fifthX*2,5,fifthX*3,fifthY/3)
    end

    ioffset = ioffset * 0.9
    doffset = doffset * 0.9
    soffset = soffset * 0.8
	if songwheel.searchStatus then
		gfx.BeginPath()
		gfx.FillColor(255,255,255)
		gfx.FontSize(20);
		gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
		gfx.Text(songwheel.searchStatus, 3, 3)
	end
	if totalForce then
		gfx.BeginPath()
		gfx.FillColor(255,255,255)
		gfx.FontSize(20);
		gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM)
		local forceText = string.format("Force: %.2f", totalForce)
		gfx.Text(forceText, 0, fullY)
	end
    gfx.LoadSkinFont("NotoSans-Regular.ttf");
    gfx.ResetTransform()
    gfx.ForceRender()
end

set_index = function(newIndex)
    if newIndex ~= selectedIndex then
        game.PlaySample("menu_click")
    end
    ioffset = ioffset + selectedIndex - newIndex
    selectedIndex = newIndex
end;

set_diff = function(newDiff)
    if newDiff ~= selectedDiff then
        game.PlaySample("click-02")
    end
    doffset = doffset + selectedDiff - newDiff
    selectedDiff = newDiff
end;

-- force calculation
--------------------
totalForce = nil

local badgeRates = {
	0.5,  -- Played
	1.0,  -- Cleared
	1.02, -- Hard clear
	1.04, -- UC
	1.1   -- PUC
}

local gradeRates = {
	{["min"] = 9900000, ["rate"] = 1.05}, -- S
	{["min"] = 9800000, ["rate"] = 1.02}, -- AAA+
	{["min"] = 9700000, ["rate"] = 1},    -- AAA
	{["min"] = 9500000, ["rate"] = 0.97}, -- AA+
	{["min"] = 9300000, ["rate"] = 0.94}, -- AA
	{["min"] = 9000000, ["rate"] = 0.91}, -- A+
	{["min"] = 8700000, ["rate"] = 0.88}, -- A
	{["min"] = 7500000, ["rate"] = 0.85}, -- B
	{["min"] = 6500000, ["rate"] = 0.82}, -- C
	{["min"] =       0, ["rate"] = 0.8}   -- D
}

calculate_force = function(diff)
	if #diff.scores < 1 then
		return 0
	end
	local score = diff.scores[1]
	local badgeRate = badgeRates[diff.topBadge]
	local gradeRate
    for i, v in ipairs(gradeRates) do
      if score.score >= v.min then
        gradeRate = v.rate
		break
      end
    end
	return math.floor((diff.level * 2) * (score.score / 10000000) * gradeRate * badgeRate) / 100
end

songs_changed = function(withAll)
	if not withAll then return end

    recordCache = {}

	local diffs = {}
	for i = 1, #songwheel.allSongs do
		local song = songwheel.allSongs[i]
		for j = 1, #song.difficulties do
			local diff = song.difficulties[j]
			diff.force = calculate_force(diff)
			table.insert(diffs, diff)
		end
	end
	table.sort(diffs, function (l, r)
		return l.force > r.force
	end)
	totalForce = 0
	for i = 1, 50 do
		if diffs[i] then
			totalForce = totalForce + diffs[i].force
		end
	end
end
