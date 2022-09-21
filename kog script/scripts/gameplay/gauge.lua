local gaugeMarkerBgImage = gfx.CreateSkinImage("gameplay/gauges/marker_bg.png", 0)

local gaugeWarnTransitionScale = 0;


local desw = 1080;
local desh = 1920;

local isLandscape = false;

local gauges = {
    { -- Effective
        bg = gfx.CreateSkinImage("gameplay/gauges/effective/gauge_back.png", 0),
        fill = gfx.CreateSkinImage("gameplay/gauges/effective/gauge_fill_fail.png", 0),
        fillPass = gfx.CreateSkinImage("gameplay/gauges/effective/gauge_fill_pass.png", 0),
        gaugeBreakpoint = 0.7,
        gaugePass = 0.7
    },
    { -- Excessive
        bg = gfx.CreateSkinImage("gameplay/gauges/excessive/gauge_back.png", 0),
        bgArs = gfx.CreateSkinImage("gameplay/gauges/excessive/gauge_back_ars.png", 0),
        fill = gfx.CreateSkinImage("gameplay/gauges/excessive/gauge_fill.png", 0),
        gaugeBreakpoint = 0.3,
        gaugeWarn = 0.3
    },
    { -- Permissive
        bg = gfx.CreateSkinImage("gameplay/gauges/permissive/gauge_back.png", 0),
        fill = gfx.CreateSkinImage("gameplay/gauges/permissive/gauge_fill.png", 0),
        gaugeWarn = 0.3
    },
    { -- Blastive
        bg = gfx.CreateSkinImage("gameplay/gauges/blastive/gauge_back.png", 0),
        fill = gfx.CreateSkinImage("gameplay/gauges/blastive/gauge_fill.png", 0),
        gaugeWarn = 0.3
    }
}

local render = function (deltaTime, gaugeType, gaugeValue, isArsEnabled)
    gfx.Save();
    
    local resx, resy = game.GetResolution();
    isLandscape = resx > resy;

    if (isLandscape) then
        desw = 1920;
        desh = 1080;
    else
        desw = 1080;
        desh = 1920;
    end

    gfx.Translate(resx, 0);

    local scale = resy / desh
    gfx.Scale(scale, scale)

    local gaugeIndex = math.min(gaugeType+1, 4) -- Any gauge type above blastive will be blastive as a fallback
    local currentGauge = gauges[gaugeIndex]


    local gaugeFillAlpha = 1;
    local gaugeBgImage = currentGauge.bg;
    local gaugeFillImage = currentGauge.fill;

    -- If the gauge has a specia bg for ARS, show it is ARS is enabled
    if (currentGauge.bgArs and isArsEnabled) then
        gaugeBgImage = currentGauge.bgArs
    end

    -- If the pass threshold is defined
    if (currentGauge.gaugePass) then
        if (gaugeValue >= currentGauge.gaugePass) then
            gaugeFillImage = currentGauge.fillPass
        end
    end

    -- If the warning threshold is defined
    if (currentGauge.gaugeWarn) then
        if gaugeValue < 0.3 then
            gaugeFillAlpha = 1 - math.abs(gaugeWarnTransitionScale - 0.25); -- 100 -> 20 -> 100
            
            gaugeWarnTransitionScale = gaugeWarnTransitionScale + deltaTime*10;
            if gaugeWarnTransitionScale > 1 then
                gaugeWarnTransitionScale = 0;
            end
        end 
    end    
    
    local BgW, BgH = gfx.ImageSize(gaugeBgImage);
    local FillW, FillH = gfx.ImageSize(gaugeFillImage);
    local landscapeXCorrection = resx / desw
    local gaugePosX = - BgW - (isLandscape and 400 * landscapeXCorrection or 110);
    local gaugePosY = desh/2 - BgH/2 - (isLandscape and 0 or 95);

    gfx.BeginPath()
    gfx.ImageRect(gaugePosX, gaugePosY, BgW, BgH, gaugeBgImage, 1, 0)
    
    gfx.GlobalAlpha(gaugeFillAlpha);
    gfx.BeginPath()
    gfx.Scissor(gaugePosX+18, gaugePosY+9+(FillH-(FillH*(gameplay.gauge.value))), FillW, FillH*(gameplay.gauge.value))
    gfx.ImageRect(gaugePosX+18, gaugePosY+9, FillW, FillH, gaugeFillImage, 1, 0)
    gfx.ResetScissor();
    gfx.GlobalAlpha(1);
    
    -- Draw the breakpoint line if needed
    if (currentGauge.gaugeBreakpoint) then
        gfx.Save()
	    gfx.BeginPath()
        gfx.GlobalAlpha(0.75);

        local lineY = gaugePosY+6+(FillH-(FillH*(currentGauge.gaugeBreakpoint)))
	
	    gfx.MoveTo(gaugePosX+18, lineY)
	    gfx.LineTo(gaugePosX+36, lineY)

	    gfx.StrokeWidth(2)
	    gfx.StrokeColor(255,255,255)
	    gfx.Stroke()

        gfx.ClosePath()
	    gfx.Restore()
    end

	-- Draw gauge % label
    local gaugeMarkerY = gaugePosY-6+(FillH-(FillH*(gaugeValue)))

    gfx.BeginPath()
    gfx.ImageRect(gaugePosX-64, gaugeMarkerY, 83*0.85, 37*0.85, gaugeMarkerBgImage, 1, 0)

    gfx.BeginPath()  
    gfx.FillColor(255, 255, 255)
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")

    -- The big number
    local gaugePercent = gaugeValue * 100;
    local bigNumber = 0;
    local smallNumber = 0;
    local smallNumberX = gaugePosX-38;
    if (gaugePercent < 10) then
        bigNumber = math.floor(gaugePercent) .. '.';

        local decimalPortion = math.floor(
            (
                gaugePercent -
                math.floor(gaugePercent)
            ) * 100
        );
        smallNumber = string.format('%02d', decimalPortion);
        smallNumberX = gaugePosX-38;
    elseif (gaugePercent < 100) then
        bigNumber = math.floor(gaugePercent) .. '.';

        local decimalPortion = math.floor(
            (
                gaugePercent -
                math.floor(gaugePercent)
            ) * 10
        );
        smallNumber = decimalPortion;
        smallNumberX = gaugePosX-26;
    else
        bigNumber = '100';
        smallNumber = '';
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    
    -- big text
    gfx.FontSize(22)
    gfx.Text(bigNumber, gaugePosX-56, gaugeMarkerY+16.5)

    -- small text
    gfx.FontSize(18)
    gfx.Text(smallNumber, smallNumberX, gaugeMarkerY+17.5)

    -- %
    gfx.FontSize(16)
    gfx.Text('%', gaugePosX-15, gaugeMarkerY+16.5)

    gfx.ResetTransform()

    gfx.Restore();
end

return {
    render=render
}