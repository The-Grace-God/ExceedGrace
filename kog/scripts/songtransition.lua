
local common = require('common.util');
local Sound = require("common.sound")
local Numbers = require('components.numbers')

game.LoadSkinSample('song_transition_screen/transition_enter.wav');

local backgroundImage = gfx.CreateSkinImage("bg_pattern.png", gfx.IMAGE_REPEATX | gfx.IMAGE_REPEATY)

local bgImage = gfx.CreateSkinImage("songtransition/bg.png", 0)
local glowOverlayImage = gfx.CreateSkinImage("songtransition/glowy.png", 0)
local frameOverlayImage = gfx.CreateSkinImage("songtransition/frames.png", 0)

local albumBgImage = gfx.CreateSkinImage("songtransition/album_crop.png", 0)
local infoOverlayPanel = gfx.CreateSkinImage("songtransition/info_panels_crop.png", 0)

local linkedHexagonsImage = gfx.CreateSkinImage("songtransition/linked_hexagons_crop.png", 0)
local hexagonImages = {
    gfx.CreateSkinImage("songtransition/hex1.png", 0),
    gfx.CreateSkinImage("songtransition/hex2.png", 0)
} 

local difficultyNumbers;

local difficultyLabelImages = {
    gfx.CreateSkinImage("songtransition/difficulty_labels/nov.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/adv.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/exh.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/mxm.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/inf.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/grv.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/hvn.png", 0),
    gfx.CreateSkinImage("songtransition/difficulty_labels/vvd.png", 0),
}

local timer = 0
local transitionProgress = 0;
local outProgress = 0

local flickerTime = 0.050 --seconds (50ms)

-- Window variables
local resX, resY = game.GetResolution()

-- Aspect Ratios
local landscapeWidescreenRatio = 16 / 9
local landscapeStandardRatio = 4 / 3
local portraitWidescreenRatio = 9 / 16

-- Portrait sizes
local fullX, fullY
local desw = 1080
local desh = 1920

local noJacket = gfx.CreateSkinImage("song_select/loading.png", 0)

local wasEnterSfxPlayed = false;

function resetLayoutInformation()
    resx, resy = game.GetResolution()
    scale = resx / desw
end

function render(deltaTime)
    if not wasEnterSfxPlayed then 
        Sound.stopMusic();
        game.PlaySample('song_transition_screen/transition_enter.wav');
        wasEnterSfxPlayed = true;
    end
    if not difficultyNumbers then
        difficultyNumbers = Numbers.load_number_image('diff_num')
    end

    local x_offset = (resX - fullX) / 2
    local y_offset = 0

    gfx.BeginPath()
    local bgImageWidth, bgImageHeight = gfx.ImageSize(backgroundImage)
    gfx.Rect(0, 0, resX, resY)
    gfx.FillPaint(gfx.ImagePattern(0, 0, bgImageWidth, bgImageHeight, 0, backgroundImage, 0.2))
    gfx.Fill()

    gfx.Translate(x_offset, y_offset);
    gfx.Scale(fullX / 1080, fullY / 1920);
    gfx.Scissor(0, 0, 1080, 1920);

    render_screen();

    transitionProgress = transitionProgress + deltaTime * 0.2
    transitionProgress = math.min(transitionProgress,1)

    if transitionProgress < 0.25 then
        local whiteAlpha = math.max(0, (1-transitionProgress/0.25))

        gfx.BeginPath();
        gfx.FillColor(255,255,255,math.floor(255*whiteAlpha));
        gfx.Rect(0,0,desw,desh);
        gfx.Fill();
        gfx.ClosePath();
    end

    if transitionProgress > 0.85 then
        local blackAlpha = math.min(1, ((transitionProgress-0.85)/0.15))

        gfx.BeginPath();
        gfx.FillColor(0,0,0,math.floor(255*blackAlpha));
        gfx.Rect(0,0,desw,desh);
        gfx.Fill();
        gfx.ClosePath();
    end

    timer = timer + deltaTime
    return transitionProgress >= 1
end

function render_out(deltaTime)
    outProgress = outProgress + deltaTime * 0.2
    outProgress = math.min(outProgress, 1)

    timer = timer + deltaTime
    return outProgress >= 1;
end

function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function render_screen()
    gfx.BeginPath()
    gfx.ImageRect(0, 0, 1080, 1920, bgImage,1,0);

    if transitionProgress < 0.35 then
        local hex1alpha = math.max(0, (1-transitionProgress/0.35))
        local hex2alpha = math.max(0, (1-transitionProgress/0.3))

        gfx.BeginPath()
        gfx.ImageRect(0,0, desw, desh, hexagonImages[1], hex1alpha, 0)

        gfx.BeginPath()
        gfx.ImageRect(0,0, desw, desh, hexagonImages[2], hex2alpha, 0)
    end

    gfx.BeginPath()
    gfx.ImageRect(0,0,1080,1920,frameOverlayImage,1,0);
    gfx.BeginPath()
    gfx.ImageRect(0, 0, 1080, 1920, glowOverlayImage,1,0);
    gfx.BeginPath()
    gfx.ImageRect(37.5, 1074, 1180*0.85, 343*0.85, infoOverlayPanel, 1, 0);

    if (timer % flickerTime) < (flickerTime / 2) then --flicker with 20Hz (50ms), 50% duty cycle
        gfx.BeginPath()
        gfx.ImageRect(37.5, 1074, 1180*0.85, 189*0.85, linkedHexagonsImage, 0.1, 0);
    end

    gfx.BeginPath()
    gfx.ImageRect(10, 195.5, 1060, 1015, albumBgImage,1,0);

    local jacket = song.jacket == 0 and noJacket or song.jacket
    gfx.BeginPath();
    gfx.ImageRect(235, 385, 608, 608, jacket, 1, 0)
    gfx.ClosePath();

	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    
    gfx.FontSize(55)
    gfx.Text(song.title,desw/2, 1114)
    
    gfx.FontSize(30)
    gfx.Text(song.artist, desw/2 , 1182)
    
    
    local EFFECTOR_LABEL_Y = 1288
    local ILLUSTRATOR_LABEL_Y = 1347
    
    gfx.FontSize(22)

    gfx.Text(song.effector, desw/2+70 , EFFECTOR_LABEL_Y-1)
    gfx.Text(song.illustrator, desw/2+70 , ILLUSTRATOR_LABEL_Y-3)

    -- Draw song diff level
    gfx.BeginPath();
    Numbers.draw_number(933, 1140, 1.0, song.level, 2, difficultyNumbers, false, 1, 1)

    -- Draw song diff label (NOV/ADV/EXH/MXM/etc.)
    gfx.BeginPath();
    local diffLabelImage = difficultyLabelImages[song.difficulty+1];
    local diffLabelW, diffLabelH = gfx.ImageSize(diffLabelImage);
    gfx.ImageRect(952-diffLabelW/2, 1154-diffLabelH/2, diffLabelW, diffLabelH, diffLabelImage,1,0);
    gfx.ClosePath();

    gfx.Save();
    gfx.FontSize(24)
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    gfx.BeginPath();

    gfx.Text('BPM', 127, 1140)
    gfx.Text(song.bpm, 127, 1167)

    -- temp ref overlay
    -- gfx.BeginPath()
    -- gfx.ImageRect(0, 0, 1080, 1920, refBgImage,0.5,0);
    
    gfx.ClosePath();
    gfx.Restore();
end

function reset()
    transitionProgress = 0
    resX, resY = game.GetResolution()
    fullX = portraitWidescreenRatio * resY
    fullY = resY
    outProgress = 0
    wasEnterSfxPlayed = false;
end