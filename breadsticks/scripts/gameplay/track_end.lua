local Common = require('common.common')
local Easing = require('common.easing')

local bgImage = gfx.CreateSkinImage("gameplay/track_end/bg.png", 0)
local bgHexTopImage = gfx.CreateSkinImage("gameplay/track_end/top_hex.png", gfx.IMAGE_REPEATX)
local bgHexBottomImage = gfx.CreateSkinImage("gameplay/track_end/bottom_hex.png", gfx.IMAGE_REPEATX)

local enterFlareBlueImage = gfx.CreateSkinImage("gameplay/track_end/flares/blue_transition_flare.png", 0)
local enterFlarePinkImage = gfx.CreateSkinImage("gameplay/track_end/flares/pink_transition_flare.png", 0)

local trackCompImage = gfx.CreateSkinImage("gameplay/track_end/track_comp.png", 0)
local trackCompBlurImage = gfx.CreateSkinImage("gameplay/track_end/track_comp_blur.png", 0)
local trackCrashImage = gfx.CreateSkinImage("gameplay/track_end/track_crash.png", 0)

-- new
local particleGreenDot1Image = gfx.CreateSkinImage("gameplay/track_end/particles/green_dot_1.png", 0)
local particleGreenDot2Image = gfx.CreateSkinImage("gameplay/track_end/particles/green_dot_2.png", 0)

local particleBlueRingImage = gfx.CreateSkinImage("gameplay/track_end/particles/blue_ring.png", 0)
local particleLargeRainbowRingImage = gfx.CreateSkinImage("gameplay/track_end/particles/large_rainbow_ring.png", 0)
local particleLargeRedRingImage = gfx.CreateSkinImage("gameplay/track_end/particles/large_red_ring.png", 0)

local particleRedBallImage = gfx.CreateSkinImage("gameplay/track_end/particles/red_ball.png", 0)
local particleRedRingImage = gfx.CreateSkinImage("gameplay/track_end/particles/red_ring.png", 0)

local particleSmallYellowRing1Image = gfx.CreateSkinImage("gameplay/track_end/particles/small_yellow_ring_1.png", 0)
local particleSmallYellowRing2Image = gfx.CreateSkinImage("gameplay/track_end/particles/small_yellow_ring_2.png", 0)
local particleSmallRainbowRingImage = gfx.CreateSkinImage("gameplay/track_end/particles/small_rainbow_ring.png", 0)

local particleYellowRingImage = gfx.CreateSkinImage("gameplay/track_end/particles/yellow_ring.png", 0)

local flareCrashBlueImage = gfx.CreateSkinImage("gameplay/track_end/flares/blue_crash_flare.png", 0)
local flareCrashPinkImage = gfx.CreateSkinImage("gameplay/track_end/flares/pink_crash_flare.png", 0)
local flareCompBlueImage = gfx.CreateSkinImage("gameplay/track_end/flares/blue_end_flare.png", 0)
local flareCompPinkImage = gfx.CreateSkinImage("gameplay/track_end/flares/pink_end_flare.png", 0)

-- USC provided clear state un-magicnumber-ifier
local STATE_CRASH = 1
local STATE_COMPLETE = 2
local STATE_HARDCLEAR = 3
local STATE_UC = 4
local STATE_PUC = 5

-- bitmask for clear state (bitwise OR (| operator) them in particles.mask to set what screen they should appear on)
local STATE_MASK_CRASH = 1
local STATE_MASK_COMPLETE = 2
local STATE_MASK_HARDCLEAR = 4
local STATE_MASK_UC = 8
local STATE_MASK_PUC = 16

-- Window variables
local resX, resY = game.GetResolution()

-- Aspect Ratios
local landscapeWidescreenRatio = 16 / 9
local landscapeStandardRatio = 4 / 3
local portraitWidescreenRatio = 9 / 16

-- Portrait sizes
local fullX = portraitWidescreenRatio * resY
local fullY = resY
local desW = 1080
local desH = 1920

local function resolutionChange(x, y)
    resX = x
    resY = y
    fullX = portraitWidescreenRatio * y
    fullY = y
end

local outroTransitionScale = 0;
local outroTransitionGlobalAlpha = 0;
local outroTransitionFlareX = -1920;

local outroTransitionTextCutX = 0;
local outroTransitionTextAlpha = 1;
local outroTransitionTextBlurAlpha = 0;

local particlesStartTime = 0.25;
local particlesDuration = 0.2;

local particles = {
    {
        name = 'green_dot_one',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleGreenDot1Image,
        opacity = 1,
        startX = 1280,
        finishX = 380,
        xPos = 1280,
        yPos = 660,
        width = 235*0.5,
        height = 235*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'green_dot_two',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleGreenDot2Image,
        opacity = 1,
        startX = 1280,
        finishX = 70,
        xPos = 1280,
        yPos = 610,
        width = 128*0.5,
        height = 128*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'blue_ring',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleBlueRingImage,
        opacity = 1,
        startX = 1280,
        finishX = 65,
        xPos = 1280,
        yPos = 620,
        width = 229*0.5,
        height = 229*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    { -- TODO: scale transitions
        name = 'large_rainbow_ring',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleLargeRainbowRingImage,
        opacity = 0,
        startOpacity = 0,
        finishOpacity = 1,
        startX = (1080/2-(2160*0.675)/2),
        finishX = (1080/2-(2160*0.675)/2),
        xPos = (1080/2-(2160*0.675)/2),
        yPos = (680-(2273*0.675)/2) + 100,
        width = 2160*0.675,
        height = 2273*0.675,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'large_red_ring',
        mask = STATE_MASK_CRASH,
        texture = particleLargeRedRingImage,
        opacity = 0,
        startOpacity = 0,
        finishOpacity = 1,
        startX = (1080/2-(2160*0.675)/2),
        finishX = (1080/2-(2160*0.675)/2),
        xPos = (1080/2-(2160*0.675)/2),
        yPos = (680-(2273*0.675)/2) + 100,
        width = 2160*0.675,
        height = 2273*0.675,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'red_ball',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleRedBallImage,
        startOpacity = 0,
        finishOpacity = 1,
        opacity = 0,
        xPos = -150,
        yPos = 500,
        width = 787*0.5,
        height = 818*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'red_ring',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleRedRingImage,
        opacity = 1,
        startX = -600,
        finishX = 590,
        xPos = -600,
        yPos = 460,
        width = 1051*0.5,
        height = 1081*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'small_yellow_ring_1',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleSmallYellowRing1Image,
        opacity = 1,
        startX = 1280,
        finishX = -170,
        xPos = 1280,
        yPos = 620,
        width = 579*0.5,
        height = 557*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'small_yellow_ring_2',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleSmallYellowRing2Image,
        opacity = 1,
        startX = 1280,
        finishX = 140,
        xPos = 1280,
        yPos = 590,
        width = 436*0.5,
        height = 392*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'small_rainbow_ring',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleSmallRainbowRingImage,
        opacity = 1,
        startX = 1280,
        finishX = -380,
        xPos = 1280,
        yPos = 450,
        width = 1117*0.5,
        height = 1117*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'yellow_ring',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = particleYellowRingImage,
        opacity = 1,
        startX = -600,
        finishX = 650,
        xPos = -600,
        yPos = 370,
        width = 1401*0.5,
        height = 1398*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'blue_flare_dim',
        mask = STATE_MASK_CRASH,
        texture = flareCrashBlueImage,
        opacity = 1,
        startX = -1500,
        finishX = 0,
        xPos = -1500,
        yPos = 480,
        width = 2160*0.5,
        height = 1100*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'pink_flare_dim',
        mask = STATE_MASK_CRASH,
        texture = flareCrashPinkImage,
        opacity = 1,
        startX = 1500,
        finishX = 0,
        xPos = 1080+1500,
        yPos = 480,
        width = 2160*0.5,
        height = 1100*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'blue_flare',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = flareCompBlueImage,
        opacity = 1,
        startX = -1500,
        finishX = 0,
        xPos = -1500,
        yPos = 480,
        width = 2160*0.5,
        height = 1100*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
    {
        name = 'pink_flare',
        mask = STATE_MASK_COMPLETE | STATE_MASK_HARDCLEAR | STATE_MASK_UC | STATE_MASK_PUC,
        texture = flareCompPinkImage,
        opacity = 1,
        startX = 1500,
        finishX = 0,
        xPos = 1080+1500,
        yPos = 480,
        width = 2160*0.5,
        height = 1100*0.5,
        startTime = particlesStartTime,
        duration = particlesDuration
    },
}

-- particles for each clear state
local particlesCrash = Common.filter(particles, function (particle) return (particle.mask & STATE_MASK_CRASH) > 0 end)
local particlesComplete = Common.filter(particles, function (particle) return (particle.mask & STATE_MASK_COMPLETE) > 0 end)
local particlesHardClear = Common.filter(particles, function (particle) return (particle.mask & STATE_MASK_HARDCLEAR) > 0 end)
local particlesUC = Common.filter(particles, function (particle) return (particle.mask & STATE_MASK_UC) > 0 end)
local particlesPUC = Common.filter(particles, function (particle) return (particle.mask & STATE_MASK_PUC) > 0 end)

if (game.GetSkinSetting('audio_systemVoice')) then
    game.LoadSkinSample('gameplay/track_crash_rasis.wav');
    game.LoadSkinSample('gameplay/track_comp_rasis.wav');
else
    game.LoadSkinSample('gameplay/track_crash.wav');
    game.LoadSkinSample('gameplay/track_comp.wav');
end

local compSfxPlayed = false;

local tickTransitions = function (deltaTime)
    if outroTransitionScale < 1 then
        outroTransitionScale = outroTransitionScale + deltaTime / 3 -- transition should last for that time in seconds
    else
        outroTransitionScale = 1
    end

    outroTransitionGlobalAlpha = math.min(1, (outroTransitionScale*6))

    outroTransitionFlareX = math.min(2*1920, (
        (outroTransitionScale-0.2)/0.1* -- Last from 0.2 transition scale for 0.1 transition scale, ending at 0.3 TS
        (1920*2) -- move this amount during the transition
    )-1920); -- start off-screen

    outroTransitionTextCutX = math.min(1920, (
        (outroTransitionScale-0.25)/0.2* -- Last from 0.25 transition scale for 0.2 transition scale, ending at 0.45 TS
        (1920) -- reveal this amount during the transition (the whole width)
    )-0); -- start from 0

    local particleTransitionScale = Easing.outQuad(math.min(1,
        (outroTransitionScale-0.25)/0.2) -- Last from 0.25 transition scale for 0.2 transition scale, ending at 0.45 TS
    )

    for particleName, particle in pairs(particles) do
        local transScale = Easing.outQuad(math.min(1, (outroTransitionScale-particle.startTime)/particle.duration));

        if (particle.finishX) then -- If x position want to have anim
            if (outroTransitionScale < particle.startTime) then
                particle.xPos = particle.startX;
            elseif (outroTransitionScale >= particle.startTime + particle.duration) then
                particle.xPos = particle.finishX;
            else
                local xDiff = particle.finishX - particle.startX;
                particle.xPos = particle.startX + xDiff*transScale;
            end
        end

        if (particle.finishOpacity) then
            if (outroTransitionScale < particle.startTime) then
                particle.opacity = particle.startOpacity;
            elseif (outroTransitionScale >= particle.startTime + particle.duration) then
                particle.opacity = particle.finishOpacity;
            else
                local opacityDiff = particle.finishOpacity - particle.startOpacity;
                particle.opacity = particle.startOpacity + opacityDiff*transScale;
            end
        end
    end

   

    -- if (outroTransitionScale > 0.45 and outroTransitionScale < 0.5) then
    --     if (outroTransitionScale <= 0.475) then
    --         outroTransitionTextAlpha = 1-(0.5*((outroTransitionScale-0.45)/0.075))
    --     else
    --         outroTransitionTextAlpha = 0.5+0.5*((outroTransitionScale-0.475)/0.075)
    --     end
    -- else
    --     outroTransitionTextAlpha = 1;
    -- end
end

local drawParticles = function (particlesToDraw)
    for _, particle in ipairs(particlesToDraw) do
        gfx.BeginPath();
        gfx.ImageRect(
            particle.xPos,
            particle.yPos,
            particle.width,
            particle.height,
            particle.texture,
            particle.opacity,
            0
        );
    end
end

local handleSounds = function (clearState)
    if not compSfxPlayed then
        compSfxPlayed = true;
        local trackCrashSamplePath = "gameplay/track_crash"
        local trackCompleteSamplePath = "gameplay/track_comp"
        if (game.GetSkinSetting('audio_systemVoice')) then
            trackCrashSamplePath = trackCrashSamplePath .. "_rasis"
            trackCompleteSamplePath = trackCompleteSamplePath .. "_rasis"
        end
        trackCrashSamplePath = trackCrashSamplePath .. ".wav"
        trackCompleteSamplePath = trackCompleteSamplePath .. ".wav"

        if clearState == STATE_CRASH then
            game.PlaySample(trackCrashSamplePath);
        elseif clearState == STATE_COMPLETE then
            game.PlaySample(trackCompleteSamplePath);
        else
            game.PlaySample(trackCompleteSamplePath);
        end
    end
end

local function renderBackground()
    local bgHexW, bgHexH
    local scale

    gfx.BeginPath();
    gfx.ImageRect(0, 0, resX, resY, bgImage, 1, 0)

    gfx.BeginPath();
    bgHexW, bgHexH = gfx.ImageSize(bgHexTopImage)
    scale = (resY / 2) / bgHexH
    gfx.Rect(0, 0, resX, resY / 2)
    gfx.FillPaint(gfx.ImagePattern((resX - bgHexW * scale) / 2, 0, bgHexW * scale, bgHexH * scale, 0, bgHexTopImage, 1))
    gfx.Fill()

    gfx.BeginPath();
    bgHexW, bgHexH = gfx.ImageSize(bgHexBottomImage)
    scale = (resY / 2) / bgHexH
    gfx.Rect(0, resY / 2, resX, resY / 2)
    gfx.FillPaint(gfx.ImagePattern((resX - bgHexW * scale) / 2, resY / 2, bgHexW * scale, bgHexH * scale, 0, bgHexBottomImage, 1))
    gfx.Fill()

end

local function renderForeground(clearState)
    if clearState == STATE_CRASH then
        -- Enter flares
        gfx.BeginPath();
        gfx.ImageRect(
            outroTransitionFlareX,
            530,
            3280*0.5,
            790*0.5,
            enterFlareBlueImage,
            1,
            0
        );
        gfx.BeginPath();
        gfx.ImageRect(
            -outroTransitionFlareX, -- go from the other side of the screen
            530,
            3280*0.5,
            790*0.5,
            enterFlarePinkImage,
            1,
            0
        );

        drawParticles(particlesCrash);

        gfx.BeginPath();
        gfx.Scissor(0, 530, outroTransitionTextCutX, 1920)
        gfx.GlobalAlpha(outroTransitionTextAlpha);
        gfx.ImageRect(
            0,
            680,
            2160*0.5,
            177*0.5,
            trackCrashImage,
            0.75,
            0
        );
    elseif clearState == STATE_COMPLETE then
        -- Enter flares
        gfx.BeginPath();
        gfx.ImageRect(
            outroTransitionFlareX,
            530,
            3280*0.5,
            790*0.5,
            enterFlareBlueImage,
            1,
            0
        );
        gfx.BeginPath();
        gfx.ImageRect(
            -outroTransitionFlareX, -- go from the other side of the screen
            530,
            3280*0.5,
            790*0.5,
            enterFlarePinkImage,
            1,
            0
        );

        drawParticles(particlesComplete);

        gfx.BeginPath();
        gfx.Scissor(0, 530, outroTransitionTextCutX, 1920)
        gfx.GlobalAlpha(outroTransitionTextAlpha);
        gfx.ImageRect(
            0,
            680,
            2160*0.5,
            177*0.5,
            trackCompImage,
            1,
            0
        );
    elseif clearState == STATE_HARDCLEAR then
        -- TODO: outro screens for other clearStates
        -- WIP IMPLEMENTATION JUST SHOWS COMPLETE ASSETS
        -- Enter flares
        gfx.BeginPath();
        gfx.ImageRect(
            outroTransitionFlareX,
            530,
            3280*0.5,
            790*0.5,
            enterFlareBlueImage,
            1,
            0
        );
        gfx.BeginPath();
        gfx.ImageRect(
            -outroTransitionFlareX, -- go from the other side of the screen
            530,
            3280*0.5,
            790*0.5,
            enterFlarePinkImage,
            1,
            0
        );

        drawParticles(particlesHardClear);

        gfx.BeginPath();
        gfx.Scissor(0, 530, outroTransitionTextCutX, 1920)
        gfx.GlobalAlpha(outroTransitionTextAlpha);
        gfx.ImageRect(
            0,
            680,
            2160*0.5,
            177*0.5,
            trackCompImage,
            1,
            0
        );
    elseif clearState == STATE_UC then
        -- TODO: outro screens for other clearStates
        -- WIP IMPLEMENTATION JUST SHOWS COMPLETE ASSETS
        -- Enter flares
        gfx.BeginPath();
        gfx.ImageRect(
            outroTransitionFlareX,
            530,
            3280*0.5,
            790*0.5,
            enterFlareBlueImage,
            1,
            0
        );
        gfx.BeginPath();
        gfx.ImageRect(
            -outroTransitionFlareX, -- go from the other side of the screen
            530,
            3280*0.5,
            790*0.5,
            enterFlarePinkImage,
            1,
            0
        );

        drawParticles(particlesUC);

        gfx.BeginPath();
        gfx.Scissor(0, 530, outroTransitionTextCutX, 1920)
        gfx.GlobalAlpha(outroTransitionTextAlpha);
        gfx.ImageRect(
            0,
            680,
            2160*0.5,
            177*0.5,
            trackCompImage,
            1,
            0
        );
    elseif clearState == STATE_PUC then
        -- TODO: outro screens for other clearStates
        -- WIP IMPLEMENTATION JUST SHOWS COMPLETE ASSETS
        -- Enter flares
        gfx.BeginPath();
        gfx.ImageRect(
            outroTransitionFlareX,
            530,
            3280*0.5,
            790*0.5,
            enterFlareBlueImage,
            1,
            0
        );
        gfx.BeginPath();
        gfx.ImageRect(
            -outroTransitionFlareX, -- go from the other side of the screen
            530,
            3280*0.5,
            790*0.5,
            enterFlarePinkImage,
            1,
            0
        );

        drawParticles(particlesPUC);

        gfx.BeginPath();
        gfx.Scissor(0, 530, outroTransitionTextCutX, 1920)
        gfx.GlobalAlpha(outroTransitionTextAlpha);
        gfx.ImageRect(
            0,
            680,
            2160*0.5,
            177*0.5,
            trackCompImage,
            1,
            0
        );
    end
end

render = function (deltaTime, clearState)
    local resx, resy = game.GetResolution()
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    tickTransitions(deltaTime);
    handleSounds(clearState);
    gfx.GlobalAlpha(outroTransitionGlobalAlpha);

    renderBackground()

    local xOffset = (resX - fullX) / 2

    gfx.Translate(xOffset, 0);
    gfx.Scale(fullX / desW, fullY / desH);
    gfx.Scissor(0, 0, desW, desH);

    renderForeground(clearState)

    gfx.GlobalAlpha(outroTransitionGlobalAlpha);
    gfx.ResetScissor();

    -- Get the banner downscaled in whatever resolution it is, while maintaining the aspect ratio
    -- local tw,th = gfx.ImageSize(bannerBaseImage);
    -- BANNER_H = th * (1080/tw);

    -- gfx.BeginPath();
    -- gfx.ImageRect(
    --     0,
    --     0,
    --     BANNER_W,
    --     BANNER_H,
    --     bannerBaseImage,
    --     1,
    --     0
    -- );
end

return {
    render = render
}