-- The following code slightly simplifies the render/update code, making it easier to explain in the comments
-- It replaces a few of the functions built into USC and changes behaviour slightly
-- Ideally, this should be in the common.lua file, but the rest of the skin does not support it
-- I'll be further refactoring and documenting the default skin and making it more easy to
--  modify for those who either don't know how to skin well or just want to change a few images
--  or behaviours of the default to better suit them.
-- Skinning should be easy and fun!

local VolforceWindow = require('components.volforceWindow')

local RECT_FILL = "fill"
local RECT_STROKE = "stroke"
local RECT_FILL_STROKE = RECT_FILL .. RECT_STROKE

gfx._ImageAlpha = 1

gfx._FillColor = gfx.FillColor
gfx._StrokeColor = gfx.StrokeColor
gfx._SetImageTint = gfx.SetImageTint

-- we aren't even gonna overwrite it here, it's just dead to us
gfx.SetImageTint = nil

function gfx.FillColor(r, g, b, a)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)
    a = math.floor(a or 255)

    gfx._ImageAlpha = a / 255
    gfx._FillColor(r, g, b, a)
    gfx._SetImageTint(r, g, b)
end

function gfx.StrokeColor(r, g, b)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)

    gfx._StrokeColor(r, g, b)
end

function gfx.DrawRect(kind, x, y, w, h)
    local doFill = kind == RECT_FILL or kind == RECT_FILL_STROKE
    local doStroke = kind == RECT_STROKE or kind == RECT_FILL_STROKE

    local doImage = not (doFill or doStroke)

    gfx.BeginPath()

    if doImage then
        gfx.ImageRect(x, y, w, h, kind, gfx._ImageAlpha, 0)
    else
        gfx.Rect(x, y, w, h)
        if doFill then gfx.Fill() end
        if doStroke then gfx.Stroke() end
    end
end

local buttonStates = { }
local buttonsInOrder = {
    game.BUTTON_BTA,
    game.BUTTON_BTB,
    game.BUTTON_BTC,
    game.BUTTON_BTD,

    game.BUTTON_FXL,
    game.BUTTON_FXR,

    game.BUTTON_STA,
}

function UpdateButtonStatesAfterProcessed()
    for i = 1, 6 do
        local button = buttonsInOrder[i]
        buttonStates[button] = game.GetButton(button)
    end
end

function game.GetButtonPressed(button)
    return game.GetButton(button) and not buttonStates[button]
end
-- -------------------------------------------------------------------------- --
-- game.IsUserInputActive:                                                    --
-- Used to determine if (valid) controller input is happening.                --
-- Valid meaning that laser motion will not return true unless the laser is   --
--  active in gameplay as well.                                               --
-- This restriction is not applied to buttons.                                --
-- The player may press their buttons whenever and the function returns true. --
-- Lane starts at 1 and ends with 8.                                          --
function game.IsUserInputActive(lane)
    if lane < 7 then
        return game.GetButton(buttonsInOrder[lane])
    end
    return gameplay.IsLaserHeld(lane - 7)
end
-- -------------------------------------------------------------------------- --
-- gfx.FillLaserColor:                                                        --
-- Sets the current fill color to the laser color of the given index.         --
-- An optional alpha value may be given as well.                              --
-- Index may be 1 or 2.                                                       --
function gfx.FillLaserColor(index, alpha)
    alpha = math.floor(alpha or 255)
    local r, g, b = game.GetLaserColor(index - 1)
    gfx.FillColor(r, g, b, alpha)
end
-- -------------------------------------------------------------------------- --
function load_number_image(path)
    local images = {}
    for i = 0, 9 do
        images[i + 1] = gfx.CreateSkinImage(string.format("%s/%d.png", path, i), 0)
    end
    return images
end
-- -------------------------------------------------------------------------- --
function draw_number(x, y, alpha, num, digits, images, is_dim, scale, kern)
    scale = scale or 1;
	kern = kern or 1;
	local tw, th = gfx.ImageSize(images[1])
	tw = tw * scale;
	th = th * scale;
    x = x + (tw * (digits - 1)) / 2
    y = y - th / 2
    for i = 1, digits do
        local mul = 10 ^ (i - 1)
        local digit = math.floor(num / mul) % 10
        local a = alpha
        if is_dim and num < mul then
            a = 0.4
        end
        gfx.BeginPath()
        gfx.ImageRect(x, y, tw, th, images[digit + 1], a, 0)
        x = x - (tw * kern)
    end
end

-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
--                  The actual gameplay script starts here!                   --
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Global data used by many things:                                           --
local resx, resy -- The resolution of the window
local portrait -- whether the window is in portrait orientation
local desw, desh -- The resolution of the deisign
local scale -- the scale to get from design to actual units
-- -------------------------------------------------------------------------- --
-- All images used by the script:                                             --
local jacketFallback = gfx.CreateSkinImage("song_select/loading.png", 0)
local bottomFill = gfx.CreateSkinImage("console/console.png", 0)
local topFill = gfx.CreateSkinImage("fill_top.png", 0)
local critAnim = gfx.CreateSkinImage("crit_anim.png", 0)
local critBar = gfx.CreateSkinImage("crit_bar.png", 0)
local critConsole = gfx.CreateSkinImage("console/crit_console.png", 0)
local laserTail = gfx.CreateSkinImage("laser_tail.png", 0)
local laserCursor = gfx.CreateSkinImage("pointer.png", 0)
local laserCursorText = gfx.CreateSkinImage("pointer_bottom.png", 0)
local laserCursorOverlay = gfx.CreateSkinImage("pointer_overlay.png", 0)
local laserCursorGlow = gfx.CreateSkinImage("pointer_glow.png", 0)
local laserCursorShine = gfx.CreateSkinImage("pointer_shine.png", 0)
local laserTopWave = gfx.CreateSkinImage("laser_top_wave.png", 0)
local scoreEarly = gfx.CreateSkinImage("score_early.png", 0)
local scoreLate = gfx.CreateSkinImage("score_late.png", 0)
local numberImages = load_number_image("number")

local prevGaugeType = nil
local gaugeTransition = nil

--Skin Settings info
local username = game.GetSkinSetting('username') or '';

local ioConsoleDetails = {
    gfx.CreateSkinImage("console/detail_left.png", 0),
    gfx.CreateSkinImage("console/detail_right.png", 0),
}

local consoleAnimImages = {
    gfx.CreateSkinImage("console/glow_bta.png", 0),
    gfx.CreateSkinImage("console/glow_btb.png", 0),
    gfx.CreateSkinImage("console/glow_btc.png", 0),
    gfx.CreateSkinImage("console/glow_btd.png", 0),

    gfx.CreateSkinImage("console/glow_fxl.png", 0),
    gfx.CreateSkinImage("console/glow_fxr.png", 0),

    gfx.CreateSkinImage("console/glow_voll.png", 0),
    gfx.CreateSkinImage("console/glow_volr.png", 0),
}
-- -------------------------------------------------------------------------- --
-- Timers, used for animations:                                               --
local introTimer = 2
local outroTimer = 0

local earlateTimer = 0
local critAnimTimer = 0

local consoleAnimSpeed = 10
local consoleAnimTimers = { 0, 0, 0, 0, 0, 0, 0, 0 }
-- -------------------------------------------------------------------------- --
-- Miscelaneous, currently unsorted:                                          --
local score = 0
local jacket = nil
local critLinePos = { 0.95, 0.75 };
local late = false
local clearTexts = {"TRACK FAILED", "TRACK COMPLETE", "TRACK COMPLETE", "FULL COMBO", "PERFECT" }
-- -------------------------------------------------------------------------- --
-- ResetLayoutInformation:                                                    --
-- Resets the layout values used by the skin.                                 --
function ResetLayoutInformation()
    resx, resy = game.GetResolution()
    portrait = resy > resx
    desw = portrait and 1080 or 1920
    desh = desw * (resy / resx)
    scale = resx / desw
end
-- -------------------------------------------------------------------------- --
-- render:                                                                    --
-- The primary & final render call.                                           --
-- Use this to render basically anything that isn't the crit line or the      --
--  intro/outro transitions.                                                  --
function render(deltaTime)
    -- make sure that our transform is cleared, clean working space
    -- TODO: this shouldn't be necessary!!!
    gfx.ResetTransform()
    gfx.Scale(scale, scale)

    local yshift = 0

    -- In portrait, we draw a banner across the top
    -- The rest of the UI needs to be drawn below that banner
    -- TODO: this isn't how it'll work in the long run, I don't think
    if portrait then yshift = draw_banner(deltaTime) end

    -- gfx.Translate(0, yshift - 150 * math.max(introTimer - 1, 0))
    gfx.Translate(0, yshift)
    draw_song_info(deltaTime)
    draw_score(deltaTime)
    -- gfx.Translate(0, -yshift + 150 * math.max(introTimer - 1, 0))
    gfx.Translate(0, -yshift)
    draw_status(deltaTime)
    draw_gauge(deltaTime)
    draw_earlate(deltaTime)
    draw_combo(deltaTime)
    draw_alerts(deltaTime)
end
-- -------------------------------------------------------------------------- --
-- SetUpCritTransform:                                                        --
-- Utility function which aligns the graphics transform to the center of the  --
--  crit line on screen, rotation include.                                    --
-- This function resets the graphics transform, it's up to the caller to      --
--  save the transform if needed.                                             --
function SetUpCritTransform()
    -- start us with a clean empty transform
    gfx.ResetTransform()
    -- translate and rotate accordingly
    gfx.Translate(gameplay.critLine.x, gameplay.critLine.y)
    gfx.Rotate(-gameplay.critLine.rotation)
end
-- -------------------------------------------------------------------------- --
-- GetCritLineCenteringOffset:                                                --
-- Utility function which returns the magnitude of an offset to center the    --
--  crit line on the screen based on its position and rotation.               --
function GetCritLineCenteringOffset()
    local distFromCenter = resx / 2 - gameplay.critLine.x
    local dvx = math.cos(gameplay.critLine.rotation)
    local dvy = math.sin(gameplay.critLine.rotation)
    return math.sqrt(dvx * dvx + dvy * dvy) * distFromCenter
end
-- -------------------------------------------------------------------------- --
-- render_crit_base:                                                          --
-- Called after rendering the highway and playable objects, but before        --
--  the built-in hit effects.                                                 --
-- This is the first render function to be called each frame.                 --
-- This call resets the graphics transform, it's up to the caller to          --
--  save the transform if needed.                                             --
function render_crit_base(deltaTime)
    -- Kind of a hack, but here (since this is the first render function
    --  that gets called per frame) we update the layout information.
    -- This means that the player can resize their window and
    --  not break everything
    ResetLayoutInformation()

    critAnimTimer = critAnimTimer + deltaTime
    SetUpCritTransform()

    -- Figure out how to offset the center of the crit line to remain
    --  centered on the players screen
    local xOffset = GetCritLineCenteringOffset()
    gfx.Translate(xOffset, 0)

    -- Draw a transparent black overlay below the crit line
    -- This darkens the play area as it passes
    gfx.FillColor(0, 0, 0, 200)
    gfx.DrawRect(RECT_FILL, -resx, 0, resx * 2, resy)
    gfx.FillColor(255, 255, 255)

    -- The absolute width of the crit line itself
    -- we check to see if we're playing in portrait mode and
    --  change the width accordingly
    local critWidth = resx * (portrait and 1.25 or 0.8)

    -- get the scaled dimensions of the crit line pieces
    local clw, clh = gfx.ImageSize(critAnim)
    local critAnimHeight = 12 * scale
    local critAnimWidth = critAnimHeight * (clw / clh)

    local cbw, cbh = gfx.ImageSize(critBar)
    local critBarHeight = critAnimHeight * (cbh / clh)
    local critBarWidth = critBarHeight * (cbw / cbh)

    -- render the core of the crit line
    do
        -- The crit line is made up of many small pieces scrolling outward
        -- Calculate how many pieces, starting at what offset, are require to
        --  completely fill the space with no gaps from edge to center
        local animWidth = critWidth * 0.65
        local numPieces = 1 + math.ceil(animWidth / (critAnimWidth * 2))
        local startOffset = critAnimWidth * ((critAnimTimer * 0.15) % 1)

        -- left side
        -- Use a scissor to limit the drawable area to only what should be visible
        gfx.Scissor(-animWidth / 2, -critAnimHeight / 2, animWidth / 2, critAnimHeight)
        for i = 1, numPieces do
            gfx.DrawRect(critAnim, -startOffset - critAnimWidth * (i - 1), -critAnimHeight / 2, critAnimWidth, critAnimHeight)
        end
        gfx.ResetScissor()

        -- right side
        -- exactly the same, but in reverse
        gfx.Scissor(0, -critAnimHeight / 2, animWidth / 2, critAnimHeight)
        for i = 1, numPieces do
            gfx.DrawRect(critAnim, -critAnimWidth + startOffset + critAnimWidth * (i - 1), -critAnimHeight / 2, critAnimWidth, critAnimHeight)
        end
        gfx.ResetScissor()
    end

    -- Draw the critical bar
    gfx.DrawRect(critBar, -critWidth / 2, -critBarHeight / 2 - 5 * scale + 24, critWidth, critBarHeight)

    -- Draw back portion of the console
    if portrait then
        local ccw, cch = gfx.ImageSize(critConsole)
        local critConsoleHeight = 190 * scale
        local critConsoleWidth = critConsoleHeight * (ccw / cch)

        local critConsoleY = 180 * scale
        gfx.DrawRect(critConsole, -critConsoleWidth / 2, -critConsoleHeight / 2 + critConsoleY, critConsoleWidth, critConsoleHeight)
    end

    -- we're done, reset graphics stuffs
    gfx.FillColor(255, 255, 255)
    gfx.ResetTransform()
end
-- -------------------------------------------------------------------------- --
-- render_crit_overlay:                                                       --
-- Called after rendering built-int crit line effects.                        --
-- Use this to render laser cursors or an IO Console in portrait mode!        --
-- This call resets the graphics transform, it's up to the caller to          --
--  save the transform if needed.                                             --
function render_crit_overlay(deltaTime)
    SetUpCritTransform()

    -- Figure out how to offset the center of the crit line to remain
    --  centered on the players screen.
    local xOffset = GetCritLineCenteringOffset()

    -- When in portrait, we can draw the console at the bottom
    if portrait then
        -- We're going to make temporary modifications to the transform
        gfx.Save()
        gfx.Translate(xOffset * 0.5, -45)

        local bfw, bfh = gfx.ImageSize(bottomFill)

        local distBetweenKnobs = 0.446
        local distCritVertical = -0.125

        local ioFillTx = bfw / 2
        local ioFillTy = bfh * distCritVertical -- 0.098

        -- The total dimensions for the console image
        local io_x, io_y, io_w, io_h = -ioFillTx, -ioFillTy, bfw, bfh

        -- Adjust the transform accordingly first
        local consoleFillScale = (resx * 0.550) / (bfw * distBetweenKnobs)
        gfx.Scale(consoleFillScale, consoleFillScale);

        -- Actually draw the fill
        gfx.FillColor(255, 255, 255)
        gfx.DrawRect(bottomFill, io_x, io_y, io_w, io_h)

        -- Then draw the details which need to be colored to match the lasers
        -- for i = 1, 2 do
        --     gfx.FillLaserColor(i)
        --     gfx.DrawRect(ioConsoleDetails[i], io_x, io_y, io_w, io_h)
        -- end

        -- Draw the button press animations by overlaying transparent images
        gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
        for i = 1, 6 do
            -- While a button is held, increment a timer
            -- If not held, that timer is set back to 0
            if game.GetButton(buttonsInOrder[i]) then
                consoleAnimTimers[i] = consoleAnimTimers[i] + deltaTime * consoleAnimSpeed * 3.14 * 2
            else
                consoleAnimTimers[i] = 0
            end

            -- If the timer is active, flash based on a sin wave
            local timer = consoleAnimTimers[i]
            if timer ~= 0 then
                local image = consoleAnimImages[i]
                local alpha = (math.sin(timer) * 0.5 + 0.5) * 0.5 + 0.25
                gfx.FillColor(255, 255, 255, alpha * 255);
                gfx.DrawRect(image, io_x, io_y, io_w, io_h)
            end
        end
        gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)

        -- Undo those modifications
        gfx.Restore();
    end

    local cw, ch = gfx.ImageSize(laserCursor)
    local cursorWidth = 60 * scale
    local cursorHeight = cursorWidth * (ch / cw)

    -- draw each laser cursor
    for i = 1, 2 do
        local cursor = gameplay.critLine.cursors[i - 1]
        local pos, skew = cursor.pos, cursor.skew

        gfx.Save();
        -- Add a kinda-perspective effect with a horizontal skew
        gfx.SkewX(skew)

        --Add the tail, only active in critical zone
        if (gameplay.laserActive[i]) then
		  gfx.FillLaserColor(i, cursor.alpha * 255)
		  gfx.DrawRect(laserTail, pos - cursorWidth / 2 - 64, -cursorHeight / 2 - 5, cursorWidth * 5, cursorHeight * 5)
		end
		
		-- Draw the SDVX Icon eye and tails below the overlay
        gfx.FillColor(255, 255, 255, cursor.alpha * 255)
        gfx.DrawRect(laserCursorText, pos - cursorWidth / 2 - 18, -cursorHeight / 2 - 18, cursorWidth * 2, cursorHeight * 2)
        -- Draw the colored background with the appropriate laser color
        gfx.FillLaserColor(i, cursor.alpha * 130)
        gfx.DrawRect(laserCursor, pos - cursorWidth / 2 - 18, -cursorHeight / 2 - 18, cursorWidth * 2, cursorHeight * 2)
		
		--Add the top wave effect, only active in critical zone
        if (gameplay.laserActive[i]) then
		  gfx.FillLaserColor(i, cursor.alpha * 180)
		  gfx.DrawRect(laserTopWave, pos - cursorWidth / 2 - 80, -cursorHeight / 2 - 24, cursorWidth * 6, cursorHeight * 6)
		end
		
        -- Draw the uncolored overlay on top of the color
        gfx.FillColor(255, 255, 255, cursor.alpha * 255)
        gfx.DrawRect(laserCursorOverlay, pos - cursorWidth / 2 - 18, -cursorHeight / 2 - 18, cursorWidth * 2, cursorHeight * 2)
		-- Draw the colored glow on top of the pointer
		gfx.FillLaserColor(i, cursor.alpha * 160)
        gfx.DrawRect(laserCursorGlow, pos - cursorWidth / 2 - 18, -cursorHeight / 2 - 20, cursorWidth * 2, cursorHeight * 2)
		-- Draw the uncolored overlay on top of the color
        gfx.FillColor(255, 255, 255, cursor.alpha * 150)
        gfx.DrawRect(laserCursorShine, pos - cursorWidth / 2 - 18, -cursorHeight / 2 - 20, cursorWidth * 2, cursorHeight * 2)

	    
        -- Un-skew
        gfx.SkewX(-skew)
		gfx.Restore();
    end

    -- We're done, reset graphics stuffs
    gfx.FillColor(255, 255, 255)
    gfx.ResetTransform()
end
-- -------------------------------------------------------------------------- --
-- draw_banner:                                                               --
-- Renders the banner across the top of the screen in portrait.               --
-- This function expects no graphics transform except the design scale.       --
function draw_banner(deltaTime)
    local bannerWidth, bannerHeight = gfx.ImageSize(topFill)
    local actualHeight = desw * (bannerHeight / bannerWidth)

    gfx.FillColor(255, 255, 255)
    gfx.DrawRect(topFill, 0, 0, desw, actualHeight)

    return actualHeight
end
-- -------------------------------------------------------------------------- --
-- draw_stat:                                                                 --
-- Draws a formatted name + value combination at x, y over w, h area.         --
function draw_stat(x, y, w, h, name, value, format, r, g, b)
    gfx.Save()

    -- Translate from the parent transform, wherever that may be
    gfx.Translate(x, y)

    -- Draw the `name` top-left aligned at `h` size
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.FontSize(h)
    gfx.Text(name .. ":", 0, 0) -- 0, 0, is x, y after translation

    -- Realign the text and draw the value, formatted
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP)
    gfx.Text(string.format(format, value), w, 0)
    -- This draws an underline beneath the text
    -- The line goes from 0, h to w, h
    gfx.BeginPath()
    gfx.MoveTo(0, h)
    gfx.LineTo(w, h) -- only defines the line, does NOT draw it yet

    -- If a color is provided, set it
    if r then gfx.StrokeColor(r, g, b)
    -- otherwise, default to a light grey
    else gfx.StrokeColor(200, 200, 200) end

    -- Stroke out the line
    gfx.StrokeWidth(1)
    gfx.Stroke()
    -- Undo our transform changes
    gfx.Restore()

    -- Return the next `y` position, for easier vertical stacking
    return y + h + 5
end
-- -------------------------------------------------------------------------- --
-- draw_song_info:                                                            --
-- Draws current song information at the top left of the screen.              --
-- This function expects no graphics transform except the design scale.       --
local songBack = gfx.CreateSkinImage("song_back.png", 0)
local numberDot = gfx.CreateSkinImage("number/dot.png", 0)
local diffImages = {
    gfx.CreateSkinImage("diff/1 novice.png", 0),
    gfx.CreateSkinImage("diff/2 advanced.png", 0),
    gfx.CreateSkinImage("diff/3 exhaust.png", 0),
	gfx.CreateSkinImage("diff/4 maximum.png", 0),
	gfx.CreateSkinImage("diff/5 infinite.png", 0),
    gfx.CreateSkinImage("diff/6 gravity.png", 0),
	gfx.CreateSkinImage("diff/7 heavenly.png", 0),
	gfx.CreateSkinImage("diff/8 vivid.png", 0)
}
local memo = Memo.new()

function draw_song_info(deltaTime)
    local jacketWidth = 105

    -- Check to see if there's a jacket to draw, and attempt to load one if not
    if jacket == nil or jacket == jacketFallback then
        jacket = gfx.LoadImageJob(gameplay.jacketPath, jacketFallback)
    end
    gfx.Save()

    if not portrait then
        gfx.Translate(0, 112)
    end

    -- Ensure the font has been loaded
    gfx.LoadSkinFont("segoeui.ttf")

    -- Draw the background
    local tw, th = gfx.ImageSize(songBack)
    gfx.FillColor(255,255,255)
    gfx.BeginPath()
    gfx.ImageRect(-2, -71, tw * 0.855, th * 0.855, songBack, 1, 0)

    -- Draw the jacket
    gfx.BeginPath()
    gfx.ImageRect(31, -39, jacketWidth, jacketWidth, jacket, 1, 0)

    -- Draw level name
    local diffIdx = GetDisplayDifficulty(gameplay.jacketPath, gameplay.difficulty)
    gfx.BeginPath()
    tw, th = gfx.ImageSize(diffImages[diffIdx])
    gfx.ImageRect(28, 71, tw * 0.85, th * 0.85, diffImages[diffIdx], 1, 0)

    -- Draw level number
    draw_number(110, 84, 1.0, gameplay.level, 2, numberImages, false)

    -- Draw the song title, scaled to fit as best as possible
    local title = memo:memoize("title", function ()
        local titleText = gameplay.title .. " / " .. gameplay.artist
        local titleWidth = 520
        gfx.LoadSkinFont("rounded-mplus-1c-bold.ttf")
        return gfx.CreateLabel(titleText, 18, 0)
    end)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)
    gfx.FillColor(255, 255, 255, 255)
    gfx.DrawLabel(title, desw / 2.77, portrait and -23 or -90, 470)

    -- Draw the BPM
    gfx.FillColor(255,255,255)
    draw_number(220, 178, 1.0, gameplay.bpm, 3, numberImages, false)

    -- Draw the hi-speed
    gfx.FontSize(16)
    draw_number(213 + 20, 212, 1.0, math.floor((gameplay.hispeed + 0.05) * 10) % 10, 1, numberImages, false)
    tw, th = gfx.ImageSize(numberDot)
    gfx.BeginPath()
    gfx.ImageRect(213 + 5, 206, tw, th, numberDot, 1, 0)
    draw_number(213, 212, 1.0, math.floor(gameplay.hispeed), 1, numberImages, false)
    -- gfx.Text(string.format("%.1f", gameplay.hispeed), 208, 9)

    -- Fill the progress bar
    gfx.BeginPath()
    gfx.FillColor(244, 204, 101)
    gfx.Rect(233, 11, 625 * gameplay.progress, 3)
    gfx.Fill()

    -- When the player is holding Start, the hispeed can be changed
    -- Shows the current hispeed values
    if game.GetButton(game.BUTTON_STA) then
      gfx.BeginPath()
      gfx.FillColor(255,255,255)
      gfx.Text(string.format("HiSpeed: %.0f x %.1f = %.0f",
      gameplay.bpm, gameplay.hispeed, gameplay.bpm * gameplay.hispeed),
      0, 115)
    end
    gfx.Restore()
end
-- -------------------------------------------------------------------------- --
-- draw_best_diff:                                                            --
-- If there are other saved scores, this displays the difference between      --
--  the current play and your best.                                           --
function draw_best_diff(deltaTime, x, y)
    -- Don't do anything if there's nothing to do
    if not gameplay.scoreReplays[1] then return end

    -- Calculate the difference between current and best play
    local difference = score - gameplay.scoreReplays[1].currentScore
    local prefix = "" -- used to properly display negative values

    gfx.BeginPath()
    gfx.FontSize(26)

    gfx.FillColor(255, 255, 255)
    if difference < 0 then
        -- If we're behind the best score, separate the minus sign and change the color
        gfx.FillColor(255, 90, 70)
        difference = math.abs(difference)
        prefix = "- "
	
    elseif difference > 0 then
        -- If we're behind the best score, separate the minus sign and change the color
        gfx.FillColor(120, 146, 218)
        difference = math.abs(difference)
        prefix = "+ "
	end 

    -- %08d formats a number to 8 characters
    -- This includes the minus sign, so we do that separately
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")
    gfx.FontSize(26)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.Text(string.format("%s%08d", prefix, difference), x, y)
end

function draw_username(deltaTime, x, y)
  gfx.BeginPath()  
  gfx.FillColor(255, 255, 255)
  gfx.LoadSkinFont("Digital-Serial-Bold.ttf")
  gfx.FontSize(26)
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
  gfx.Text(string.sub(username, 1, 8), x, y)
end

-- -------------------------------------------------------------------------- --
-- draw_score:                                                                --
local scoreBack = gfx.CreateSkinImage("score_back.png", 0)
local scoreNumber = load_number_image("score_num")
local maxCombo = 0
function draw_score(deltaTime)
    local tw, th = gfx.ImageSize(scoreBack)
    gfx.FillColor(255, 255, 255)
    gfx.BeginPath()
	tw = tw * 0.61;
	th = th * 0.61;
    gfx.ImageRect(desw - tw + 12, portrait and 50 or 0, tw, th, scoreBack, 1, 0)

    gfx.FillColor(255, 255, 255)
    draw_number(desw - 305, portrait and 132 or 64, 1.0, math.floor(score / 10000), 4, scoreNumber, true, 0.38, 1.12)
    draw_number(desw - 110, portrait and 137 or 68, 1.0, score, 4, scoreNumber, true, 0.28, 1.12)

    -- Draw max combo
    gfx.FillColor(255, 255, 255)
    draw_number(desw - 300, portrait and 207 or 110, 1.0, maxCombo, 4, numberImages, true)
end
-- -------------------------------------------------------------------------- --
-- draw_gauge:                                                                --
local gaugeMarkerBgImage = gfx.CreateSkinImage("gameplay/gauges/marker_bg.png", 0)

local gaugeWarnTransitionScale = 0;

local gaugeEffBgImage = gfx.CreateSkinImage("gameplay/gauges/effective/gauge_back.png", 0)
local gaugeEffFailFillImage = gfx.CreateSkinImage("gameplay/gauges/effective/gauge_fill_fail.png", 0)
local gaugeEffPassFillImage = gfx.CreateSkinImage("gameplay/gauges/effective/gauge_fill_pass.png", 0)

local gaugeExcBgImage = gfx.CreateSkinImage("gameplay/gauges/excessive/gauge_back.png", 0)
local gaugeExcFillImage = gfx.CreateSkinImage("gameplay/gauges/excessive/gauge_fill.png", 0)

local gaugeExcArsBgImage = gfx.CreateSkinImage("gameplay/gauges/excessive_ars/gauge_back.png", 0)
local gaugeExcArsFillImage = gfx.CreateSkinImage("gameplay/gauges/excessive_ars/gauge_fill.png", 0)

local gaugePermBgImage = gfx.CreateSkinImage("gameplay/gauges/permissive/gauge_back.png", 0)
local gaugePermFillImage = gfx.CreateSkinImage("gameplay/gauges/permissive/gauge_fill.png", 0)

local gaugeBlastiveBgImage = gfx.CreateSkinImage("gameplay/gauges/blastive/gauge_back.png", 0)
local gaugeBlastiveFillImage = gfx.CreateSkinImage("gameplay/gauges/blastive/gauge_fill.png", 0)


function draw_gauge(deltaTime)
    -- fallbacks in case of unsupported type
    local gaugeFillAlpha = 1;
    local gaugeBgImage = gaugeEffBgImage;
    local gaugeFillImage = gaugeEffPassFillImage;
    local gaugeBreakpoint = 0;

    if gameplay.gauge.type == 0 then
        gaugeBgImage = gaugeEffBgImage;
        gaugeBreakpoint = 0.7;

        if gameplay.gauge.value <= 0.7 then
            gaugeFillImage = gaugeEffFailFillImage;
        else
            gaugeFillImage = gaugeEffPassFillImage;
        end

    elseif gameplay.gauge.type == 1 then
        gaugeBgImage = gaugeExcBgImage;
        gaugeFillImage = gaugeExcFillImage;

        if (game.GetSkinSetting('_gaugeARS') == 1) then
            gaugeBgImage = gaugeExcArsBgImage
            gaugeFillImage = gaugeExcArsFillImage
        end

        gaugeBreakpoint = 0.3;

        if gameplay.gauge.value < 0.3 then
            gaugeFillAlpha = 1 - math.abs(gaugeWarnTransitionScale - 0.25); -- 100 -> 20 -> 100
            
            gaugeWarnTransitionScale = gaugeWarnTransitionScale + deltaTime*10;
            if gaugeWarnTransitionScale > 1 then
                gaugeWarnTransitionScale = 0;
            end
        end 
    elseif gameplay.gauge.type == 2 then
        gaugeBgImage = gaugePermBgImage;
        gaugeFillImage = gaugePermFillImage;

        if gameplay.gauge.value < 0.3 then
            gaugeFillAlpha = 1 - math.abs(gaugeWarnTransitionScale - 0.25); -- 100 -> 52 -> 100
            
            gaugeWarnTransitionScale = gaugeWarnTransitionScale + deltaTime*10;
            if gaugeWarnTransitionScale > 1 then
                gaugeWarnTransitionScale = 0;
            end
        end 
    elseif gameplay.gauge.type == 3 then -- BLASTIVE RATE
        gaugeBgImage = gaugeBlastiveBgImage;
        gaugeFillImage = gaugeBlastiveFillImage;

        if gameplay.gauge.value < 0.3 then
            gaugeFillAlpha = 1 - math.abs(gaugeWarnTransitionScale - 0.25); -- 100 -> 20 -> 100
            
            gaugeWarnTransitionScale = gaugeWarnTransitionScale + deltaTime*10;
            if gaugeWarnTransitionScale > 1 then
                gaugeWarnTransitionScale = 0;
            end
        end 
    end
    
    
    local BgW, BgH = gfx.ImageSize(gaugeBgImage);
    local FillW, FillH = gfx.ImageSize(gaugeFillImage);
    local gaugePosX = 1080 - BgW - 110;
    local gaugePosY = 1920/2 - BgH/2 - 95;

    -- gfx.Text('RESX: ' .. resx .. ' // RESY: ' .. resy .. ' // GPX: ' .. gaugePosX, 255,1200);

    gfx.BeginPath()
    gfx.ImageRect(gaugePosX, gaugePosY, BgW, BgH, gaugeBgImage, 1, 0)
    
    gfx.GlobalAlpha(gaugeFillAlpha);
    gfx.BeginPath()
    gfx.Scissor(gaugePosX+18, gaugePosY+9+(FillH-(FillH*(gameplay.gauge.value))), FillW, FillH*(gameplay.gauge.value))
    gfx.ImageRect(gaugePosX+18, gaugePosY+9, FillW, FillH, gaugeFillImage, 1, 0)
    gfx.ResetScissor();
    gfx.GlobalAlpha(1);
    
    -- Draw the breakpoint line if needed
    if (gaugeBreakpoint > 0) then
        gfx.Save()
	    gfx.BeginPath()
        gfx.GlobalAlpha(0.75);

        local lineY = gaugePosY+6+(FillH-(FillH*(gaugeBreakpoint)))
	
	    gfx.MoveTo(gaugePosX+18, lineY)
	    gfx.LineTo(gaugePosX+36, lineY)

	    gfx.StrokeWidth(2)
	    gfx.StrokeColor(255,255,255)
	    gfx.Stroke()

        gfx.ClosePath()
	    gfx.Restore()
    end

	-- Draw gauge % label
    local gaugeMarkerY = gaugePosY-6+(FillH-(FillH*(gameplay.gauge.value)))

    gfx.BeginPath()
    gfx.ImageRect(gaugePosX-64, gaugeMarkerY, 83*0.85, 37*0.85, gaugeMarkerBgImage, 1, 0)

    gfx.BeginPath()  
    gfx.FillColor(255, 255, 255)
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")
    gfx.FontSize(22)
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(math.floor(gameplay.gauge.value * 100), gaugePosX-16, gaugeMarkerY+17)

    gfx.FontSize(16)
    gfx.Text('%', gaugePosX-4, gaugeMarkerY+17)
end
-- -------------------------------------------------------------------------- --
-- draw_combo:                                                                --
local comboBottom = gfx.CreateSkinImage("chain/chain.png", 0)
local comboPUC = load_number_image("chain/puc")
local comboUC = load_number_image("chain/uc")
local comboREG = load_number_image("chain/reg")
local comboTimer = 0
local combo = 0
local comboCurrent
function draw_combo(deltaTime)
    if combo == 0 then return end
    comboTimer = comboTimer + deltaTime
    local posx = desw / 2 + 5
    local posy = desh * critLinePos[1] - 100
    if portrait then posy = desh * critLinePos[2] - 150 end
    if gameplay.comboState == 2 then
        comboCurrent = comboPUC --puc
    elseif gameplay.comboState == 1 then
        comboCurrent = comboUC --uc
    else
        comboCurrent = comboREG --regular
    end
    local alpha = math.floor(comboTimer * 20) % 2
    alpha = (alpha * 100 + 155) / 255

    -- \_ chain _/
    local tw, th
    tw, th = gfx.ImageSize(comboBottom)
    gfx.BeginPath()
    gfx.ImageRect(posx - tw / 2 + 10, posy - th / 4 - 210, tw * 0.85, th * 0.85, comboBottom, alpha, 0)

    tw, th = gfx.ImageSize(comboCurrent[1])
    posy = posy - th + 32

    local comboScale = 0.45;
    draw_number(desw/2 - (tw*4*comboScale)/2+(tw*comboScale*1.5)+10, posy - th / 2, 1.0, combo, 4, comboCurrent, true, comboScale, 1.12)
end
-- -------------------------------------------------------------------------- --
-- draw_earlate:                                                              --
function draw_earlate(deltaTime)
    earlateTimer = math.max(earlateTimer - deltaTime,0)
    if earlateTimer == 0 then return nil end
    local alpha = math.floor(earlateTimer * 20) % 2
    alpha = (alpha * 100 + 155) / 255
    gfx.BeginPath()

    local xpos = desw / 2
    local ypos = desh * critLinePos[1] - 220
    if portrait then ypos = desh * critLinePos[2] - 240 end
    local tw, th
    if late then
        tw, th = gfx.ImageSize(scoreLate)
        gfx.ImageRect(xpos - tw / 2, ypos - th / 2, tw, th, scoreLate, alpha, 0)
    else
        tw, th = gfx.ImageSize(scoreEarly)
        gfx.ImageRect(xpos - tw / 2, ypos - th / 2, tw, th, scoreEarly, alpha, 0)
    end
end
-- -------------------------------------------------------------------------- --
-- draw_alerts:                                                               --
local alertTimers = {-2,-2}
local alertBgR = Image.skin("alert_bg.png")
local alertBgL = Image.skin("alert_bg2.png")
local alertL = Image.skin("alert_l.png")
local alertR = Image.skin("alert_r.png")

function draw_alerts(deltaTime)
    alertTimers[1] = math.max(alertTimers[1] - deltaTime,-2)
    alertTimers[2] = math.max(alertTimers[2] - deltaTime,-2)
    if alertTimers[1] > 0 then --draw left alert
        gfx.Save()
        local posx = desw / 2 - 220
        local posy = desh * critLinePos[1] - 135
        if portrait then
            posy = desh * critLinePos[2] - 240
            posx = 105
        end
        gfx.Translate(posx,posy)
        local r,g,b = game.GetLaserColor(0)
        local alertScale = (-(alertTimers[1] ^ 2.0) + (1.5 * alertTimers[1])) * 5.0
        alertScale = math.min(alertScale, 1)
        gfx.Scale(1, alertScale)
        gfx.FillColor(r, g, b)
        alertBgL:draw({ x = 0, y = 0 })
        gfx.FillColor(255, 255, 255)
        alertL:draw({ x = 0, y = 0 })
        gfx.Restore()
    end
    if alertTimers[2] > 0 then --draw right alert
        gfx.Save()
        local posx = desw / 2 + 220
        local posy = desh * critLinePos[1] - 40
        if portrait then
            posy = desh * critLinePos[2] - 240
            posx = desw - 105
        end
        gfx.Translate(posx,posy)
        local r,g,b = game.GetLaserColor(1)
        local alertScale = (-(alertTimers[2] ^ 2.0) + (1.5 * alertTimers[2])) * 5.0
        alertScale = math.min(alertScale, 1)
        gfx.Scale(1, alertScale)
        gfx.FillColor(r, g, b)
        alertBgR:draw({ x = 0, y = 0 })
        gfx.FillColor(255, 255, 255)
        alertR:draw({ x = 0, y = 0 })
        gfx.Restore()
    end
end
-- -------------------------------------------------------------------------- --
-- draw_status:                                                               --
local statusBack = Image.skin("status_back.png")
local apealCard = Image.skin("crew/appeal_card.png")
local dan = Image.skin("dan.png")

function draw_status(deltaTime)
    -- Draw the background
    gfx.FillColor(255, 255, 255)
    statusBack:draw({ x = 0, y = desh / 2 - 195, w = statusBack.w * 0.85, h = statusBack.h * 0.85, anchor_h = Image.ANCHOR_LEFT })

    -- Draw the apeal card
    apealCard:draw({ x = 12, y = desh / 2 - 220, w = apealCard.w * 0.62, h = apealCard.h * 0.62, anchor_h = Image.ANCHOR_LEFT, anchor_v = Image.ANCHOR_TOP })

    -- Draw the dan
    dan:draw({ x = 164, y = desh / 2 - 117, w = dan.w * 0.32, h = dan.h * 0.32 })
	
	-- Draw the Volforce
    VolforceWindow.render(deltaTime, 220, desh / 2 - 140);
	
    -- Draw the best difference
    draw_best_diff(deltaTime, 145, desh / 2 - 174)
	
	-- Draw the username
	draw_username(deltatime, 145, desh / 2 - 198)
end

-- -------------------------------------------------------------------------- --
-- render_intro:                                                              --
function render_intro(deltaTime)
    if not game.GetButton(game.BUTTON_STA) then
        introTimer = introTimer - deltaTime
    end
    introTimer = math.max(introTimer, 0)
    return introTimer <= 0
end
-- -------------------------------------------------------------------------- --
-- render_outro:                                                              --
function render_outro(deltaTime, clearState)
    if clearState == 0 then return true end
    gfx.ResetTransform()
    gfx.BeginPath()
    gfx.Rect(0,0,resx,resy)
    gfx.FillColor(0,0,0, math.floor(127 * math.min(outroTimer, 1)))
    gfx.Fill()
    gfx.Scale(scale,scale)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FillColor(255,255,255, math.floor(255 * math.min(outroTimer, 1)))
    gfx.LoadSkinFont("NovaMono.ttf")
    gfx.FontSize(70)
    gfx.Text(clearTexts[clearState], desw / 2, desh / 2)
    outroTimer = outroTimer + deltaTime
    return outroTimer > 2, 1 - outroTimer
end
-- -------------------------------------------------------------------------- --
-- update_score:                                                              --
function update_score(newScore)
    score = newScore
end
-- -------------------------------------------------------------------------- --
-- update_combo:                                                              --
function update_combo(newCombo)
    combo = newCombo
    if combo > maxCombo then
        maxCombo = combo
    end
end
-- -------------------------------------------------------------------------- --
-- near_hit:                                                                  --
function near_hit(wasLate) --for updating early/late display
    late = wasLate
    earlateTimer = 0.75
end
-- -------------------------------------------------------------------------- --
-- laser_alert:                                                               --
function laser_alert(isRight) --for starting laser alert animations
    if isRight and alertTimers[2] < -1.5 then
        alertTimers[2] = 1.5
    elseif alertTimers[1] < -1.5 then
        alertTimers[1] = 1.5
    end
end