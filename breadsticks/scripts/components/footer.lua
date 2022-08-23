
local version = require('common.version')

local resx, resy = game.GetResolution()
local desw, desh = 1080,1920;
local scale = 1;

local BAR_ALPHA = 191;

local FOOTER_HEIGHT = 128
local footerY = desh - FOOTER_HEIGHT;

-- Images
local footerRightImage = gfx.CreateSkinImage("components/bars/footer_right.png", 0);

-- Animation related
local entryTransitionScale = 0;
local entryTransitionFooterYOffset = 0;

local legend = {
    {
        control = 'START',
        text = 'Confirm selection'
    },
    {
        control = 'KNOB',
        text = 'Scroll'
    },
}

local set = function ()
    
end

function resetLayoutInformation()
    resx, resy = game.GetResolution()
    desw = 1080
    desh = 1920
    scale = resx / desw
end

local drawFooter = function ()
    gfx.BeginPath();
    gfx.FillColor(0,0,0,BAR_ALPHA);
    gfx.Rect(0,footerY,desw, FOOTER_HEIGHT);
    gfx.Fill();
    
    
    gfx.BeginPath();
    gfx.ImageRect(desw-275, footerY-25, 328*0.85, 188*0.85, footerRightImage, 1, 0);

    gfx.BeginPath();
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf");
    gfx.FontSize(20)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(255, 255, 255, 255);
    gfx.Text('EXPERIMENTALGEAR ' .. version.MAJOR .. '.' .. version.MINOR .. '.' .. version.PATCH .. '', 8, 1895);
end

local progressTransitions = function (deltaTime)
	entryTransitionScale = entryTransitionScale + deltaTime / 0.3;
	if (entryTransitionScale > 1) then
		entryTransitionScale = 1;
    end

    entryTransitionFooterYOffset = FOOTER_HEIGHT*(1-entryTransitionScale)
    footerY = desh-FOOTER_HEIGHT+entryTransitionFooterYOffset;
end

local draw = function (deltaTime, params)
    if (params) then
        if params.noEnterTransition then 
            entryTransitionScale = 1;
        end
    end

    gfx.Save()

    
    gfx.LoadSkinFont("NotoSans-Regular.ttf");

    drawFooter();

    progressTransitions(deltaTime);
    gfx.Restore()
end

return {
    set = set,
    draw = draw
};