local resx, resy = game.GetResolution()
local desw, desh = 1080,1920;
local scale = 1;

local BAR_ALPHA = 191;

local FOOTER_HEIGHT = 128
local footerY = desh - FOOTER_HEIGHT;

-- Images
local bgBaseImage = gfx.CreateSkinImage("components/background/bg.png", 0);
local dotsOverlayImage = gfx.CreateSkinImage("components/background/dots.png", 0);

local valkRasisImage = gfx.CreateSkinImage("components/background/rasis_panel.png", 0);
local valkGraceImage = gfx.CreateSkinImage("components/background/grace_panel.png", 0);

local mainRingImage = gfx.CreateSkinImage("components/background/main_ring.png", 0);

local blueFlareImage = gfx.CreateSkinImage("components/background/blue_flare.png", 0);
local pinkFlareImage = gfx.CreateSkinImage("components/background/pink_flare.png", 0);

local hexagonImages = {
    gfx.CreateSkinImage("components/background/hex1.png", 0),
    gfx.CreateSkinImage("components/background/hex2.png", 0),
    gfx.CreateSkinImage("components/background/hex3.png", 0)
}

-- Animation related
local transitionRotateScale = 0;


function resetLayoutInformation()
    resx, resy = game.GetResolution()
    desw = 1080
    desh = 1920
    scale = resx / desw
end

local drawValkyrie = function (spinProgressionScale, valkImage)
    gfx.Save()
    gfx.BeginPath()

    local w = 1390*0.7;
    local h = 3356*0.7
    local piProgression = spinProgressionScale*2*math.pi

    local distanceScaleMultiplier = 0.3 + 0.7*((1+math.sin(piProgression))/2)


    local xScale = math.sin(piProgression)*distanceScaleMultiplier;
    local yScale = 1*distanceScaleMultiplier
    
    gfx.Translate(math.sin(piProgression+2)*0.6*desw+0.3*desw, (1-distanceScaleMultiplier)*desh*0.4)  -- -math.sin(piProgression+2)*0.1*desh+desh*0.1
	-- gfx.Scale(xScale, yScale)
	gfx.SkewY(
        (
            1 +
            math.sin(
                piProgression +
                0.5 *
                math.pi
            )
        ) / 2
    * -0.3)
    --gfx.SkewX(-math.sin(piProgression)*0.2)

    gfx.ImageRect(0, 0, w*xScale, h*yScale, valkImage, 0.5, 0);
    gfx.Restore()


    -- ===================== Draw the inner one
    gfx.Save()
    gfx.BeginPath()

    local w = 1390*0.7;
    local h = 3356*0.7
    local piProgression = spinProgressionScale*2*math.pi

    local distanceScaleMultiplier = 0.3 + 0.7*((1+math.sin(piProgression))/2)


    local xScale = math.sin(piProgression)*distanceScaleMultiplier;
    local yScale = 1*distanceScaleMultiplier
    
    gfx.Translate(math.sin(piProgression+2)*0.57*desw+0.3*desw, (1-distanceScaleMultiplier)*desh*0.4)  -- -math.sin(piProgression+2)*0.1*desh+desh*0.1
	-- gfx.Scale(xScale, yScale)
	gfx.SkewY(
        (
            1 +
            math.sin(
                piProgression +
                0.5 *
                math.pi
            )
        ) / 2
    * -0.3)
    --gfx.SkewX(-math.sin(piProgression)*0.2)

    gfx.ImageRect(0, 0, w*xScale, h*yScale, valkImage, 0.5, 0);
    gfx.Restore()

end

local drawValkyries = function ()
    gfx.Save()
    gfx.BeginPath()

    local piProgression = transitionRotateScale*2*math.pi
    gfx.Rotate(-0.3)

    drawValkyrie(transitionRotateScale, valkRasisImage)

    drawValkyrie(transitionRotateScale+0.25, valkGraceImage)
    drawValkyrie(transitionRotateScale+0.5, valkRasisImage)
    drawValkyrie(transitionRotateScale+0.75, valkGraceImage)
    gfx.Restore()
end

local drawRings = function ()
    gfx.Save()
    gfx.BeginPath()

    gfx.SkewX(-0.95)
    gfx.Translate(675,225)

    gfx.Rotate(-transitionRotateScale*2*math.pi);
    gfx.Translate(-200,-200)

    gfx.ImageRect(0, 0, 400, 400, mainRingImage, 0.5, 0);
    gfx.Restore()
end

local drawHexagons = function ()
    gfx.BeginPath()
    gfx.ImageRect(0, 0, desw, desh, hexagonImages[1], 1, 0);
    gfx.ImageRect(0, 0, desw, desh, hexagonImages[2], 1, 0);
    gfx.ImageRect(0, 0, desw, desh, hexagonImages[3], 1, 0);
end
local drawFlares = function ()
    gfx.BeginPath()
    gfx.ImageRect(0, 0, desw, desh, blueFlareImage, 1, 0);
    gfx.ImageRect(0, 0, desw, desh, pinkFlareImage, 1, 0);
end

local drawBackground = function ()
    gfx.BeginPath();
    gfx.ImageRect(0, 0, desw, desh, bgBaseImage, 1, 0);

    drawRings();
    drawHexagons();
    drawFlares();

    drawValkyries();

    gfx.BeginPath();
    gfx.ImageRect(0, 0, desw, desh, dotsOverlayImage, 1, 0);
end

local progressTransitions = function (deltaTime)
    transitionRotateScale = transitionRotateScale + deltaTime / 20;
	if (transitionRotateScale > 1) then
		transitionRotateScale = 0;
    end
end

local draw = function (deltaTime)
    gfx.Save()
    -- resetLayoutInformation()
    -- gfx.Scale(scale, scale)

    drawBackground();

    progressTransitions(deltaTime);
    gfx.Restore()
end

return {
    draw = draw
};