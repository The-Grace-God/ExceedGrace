
require 'common.globals'

local Dimensions = require 'common.dimensions'

local Animation = require 'api.animation'

local Animations = {
    Crit = Animation.new('gameplay/hit_animation_frames/critical_taps', {
        centered = true,
    }),

    Near = Animation.new('gameplay/hit_animation_frames/near_taps', {
        centered = true,
    }),

    HoldCrit = Animation.new('gameplay/hit_animation_frames/hold_critical', {
        centered = true,
        loop = true,
    }),

    HoldDome = Animation.new('gameplay/hit_animation_frames/hold_dome', {
        centered = true,
        loop = true,
        loopPoint = 10
    }),

    HoldEnd = Animation.new('gameplay/hit_animation_frames/hold_end', {
        centered = true,
    }),

    HoldInner = Animation.new('gameplay/hit_animation_frames/hold_inner', {
        centered = true,
        loop = true,
    }),

    LaserCrit = Animation.new('gameplay/hit_animation_frames/laser_critical', {
        loop = true,
    }),

    LaserDome = Animation.new('gameplay/hit_animation_frames/laser_dome', {
        loop = true,
    }),

    LaserEndOuter = Animation.new('gameplay/hit_animation_frames/laser_end_outer', {}),

    LaserEndLeft = Animation.new('gameplay/hit_animation_frames/laser_end_l_inner', {}),

    LaserEndRight = Animation.new('gameplay/hit_animation_frames/laser_end_r_inner', {}),
};

---@class LaserStateTable
---@field Crit AnimationState
---@field Dome AnimationState
---@field EndInner AnimationState
---@field EndOuter AnimationState

---@type LaserStateTable[]
local laserStateTables = {
    {
        Crit = Animations.LaserCrit:createState(),
        Dome = Animations.LaserDome:createState(),
        EndInner = Animations.LaserEndLeft:createState(),
        EndOuter = Animations.LaserEndOuter:createState()
    },
    {
        Crit = Animations.LaserCrit:createState(),
        Dome = Animations.LaserDome:createState(),
        EndInner = Animations.LaserEndRight:createState(),
        EndOuter = Animations.LaserEndOuter:createState()
    }
}

---@class HoldStateTable
---@field Crit AnimationState
---@field Dome AnimationState
---@field End AnimationState
---@field Inner AnimationState

---@type HoldStateTable[]
local holdStateTables = {}

for i = 1, 6 do
    holdStateTables[i] = {
        Crit = Animations.HoldCrit:createState(),
        Dome = Animations.HoldDome:createState(),
        End = Animations.HoldEnd:createState(),
        Inner = Animations.HoldInner:createState()
    }
end

---@type AnimationState[]
local tapStates = {}

local HitFX = { };

local function setUpTransform(critCenterX, critCenterY, critRotation, xScalar)
    local critLine = gameplay.critLine
    local x = critCenterX + (critLine.line.x2 - critLine.line.x1) * xScalar
    local y = critCenterY + (critLine.line.y2 - critLine.line.y1) * xScalar

    Dimensions.setUpTransforms(x, y, critRotation)
end

function HitFX.renderLasers(deltaTime, critCenterX, critCenterY, critRotation, cursors)
    local hitSize = 406

    -- Lasers
    for laser = 1, 2 do
        -- Update
        local isActive = gameplay.laserActive[laser]
        local laserState = laserStateTables[laser]
        local isAnimationPlaying = laserState.Dome.running

        if isActive and not isAnimationPlaying then
            laserState.Crit:restart()
            laserState.Dome:restart()
        end

        if not isActive and isAnimationPlaying then
            laserState.Crit:stop()
            laserState.Dome:stop()

            laserState.EndInner:restart()
            laserState.EndOuter:restart()
        end

        -- Render
        local laserColor = {game.GetLaserColor(laser - 1)}
        local x = cursors[laser - 1].pos

        Dimensions.setUpTransforms(critCenterX, critCenterY, critRotation)

        laserState.Dome:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize,
            color = laserColor,
            x = x,
        })

        laserState.Crit:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize,
            x = x,
        })
        laserState.EndInner:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize,
            x = x,
        })
        laserState.EndOuter:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize,
            color = laserColor,
            x = x,
        })
    end
end

function HitFX.renderButtons(deltaTime, critCenterX, critCenterY, critRotation)
    --local baseHitSize = 325;
    local hitSize = 406

    -- BT + FX
    for i = 1, 6 do
        --[[
        local hitSize = baseHitSize;
        if (i > 4) then
            hitSize = hitSize * 1.5;
        end
        ]]

        local laneWidth = (track.GetCurrentLaneXPos(2) - track.GetCurrentLaneXPos(1)) * (i <= 4 and 1 or 2);
        local lanePosition = track.GetCurrentLaneXPos(i) + laneWidth / 2
        if (i == 5) then
            lanePosition = -track.GetCurrentLaneXPos(6) - laneWidth / 2
        end

        -- Update Holds
        local isHeld = gameplay.noteHeld[i]
        local holdStates = holdStateTables[i]
        local isAnimationPlaying = holdStates.Dome.running

        if isHeld and not isAnimationPlaying then
            holdStates.Crit:restart()
            holdStates.Dome:restart()
            holdStates.Inner:restart()
        end

        if not isHeld and isAnimationPlaying then
            holdStates.Crit:stop()
            holdStates.Dome:stop()
            holdStates.Inner:stop()

            holdStates.End:restart()
        end

        -- Render holds
        setUpTransform(critCenterX, critCenterY, critRotation, lanePosition)

        holdStates.Inner:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize
        })
        holdStates.Dome:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize
        })
        holdStates.Crit:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize
        })
        holdStates.End:render(deltaTime, {
            centered = true,
            width = hitSize,
            height = hitSize
        })

        -- Render Taps
        local tapState = tapStates[i]

        if tapState then
            tapState:render(deltaTime, {
                centered = true,
                width = hitSize,
                height = hitSize,
            });
        end
    end

    gfx.ResetTransform()
end

function HitFX.TriggerAnimation(name, lane)
    tapStates[lane] = Animations[name]:start();
end

return HitFX;
