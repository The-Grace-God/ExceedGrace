
local VolforceWindow = require('components.volforceWindow')
local Dimensions = require 'common.dimensions';

do
    local resx, resy = game.GetResolution();
    Dimensions.updateResolution(resx / resy);
end

local Banner = require('gameplay.banner')
local CritLine = require('gameplay.crit_line')
local Console = require('gameplay.console')
local UserPanel = require('gameplay.user_panel')
local SongPanel = require('gameplay.song_panel')
local ScorePanel = require('gameplay.score_panel')
local Gauge = require('gameplay.gauge')
local Chain = require('gameplay.chain')
local LaserAlert = require('gameplay.laser_alert')

local HitFX = require 'gameplay.hitfx'
local EarlyLate = require 'gameplay.earlylate'

local TrackEnd = require('gameplay.track_end')

local json = require("common.json")

local showHitAnims = true;

local users = nil

local maxChain = 0;
local chain = 0;
local score = 0;

function render(deltaTime)
    local resx, resy = game.GetResolution();
    Dimensions.updateResolution(resx / resy);

    Banner.render(deltaTime, users, gameplay.user_id, gameplay.difficulty, gameplay.level);

    UserPanel.render(deltaTime, score, gameplay.scoreReplays[1],users);
    SongPanel.render(deltaTime,
        gameplay.bpm,
        gameplay.hispeed,
        gameplay.jacketPath,
        gameplay.difficulty,
        gameplay.level,
        gameplay.progress,
        gameplay.title,
        gameplay.artist
    );
    ScorePanel.render(deltaTime, score, maxChain)

    Gauge.render(
        deltaTime,
        gameplay.gauge.type,
        gameplay.gauge.value,
        (game.GetSkinSetting('_gaugeARS') == 1)
    );
    Chain.render(deltaTime, gameplay.comboState, chain, gameplay.critLine.x, gameplay.critLine.y);

    LaserAlert.render(deltaTime);

    EarlyLate.render(deltaTime)
end

function render_crit_base(deltaTime)
    local cl = gameplay.critLine

    CritLine.renderBase(deltaTime, cl.x, cl.y, -cl.rotation);
    Console.render(deltaTime, cl.x, cl.y, -cl.rotation);
end

function render_crit_overlay(deltaTime)
    local cl = gameplay.critLine
    local centerX = cl.x
    local centerY = cl.y
    local rot = -cl.rotation

    HitFX.renderButtons(deltaTime, centerX, centerY, rot);
    HitFX.renderLasers(deltaTime, centerX, centerY, rot, cl.cursors);
    CritLine.renderOverlay(deltaTime, centerX, centerY, rot, cl.cursors, gameplay.laserActive)
end

function render_intro(deltaTime)
    return true
end

local outroTimer = 0;
function render_outro(deltaTime, clearState)
    if (clearState == 0) then
        return true, 0; -- Exit right away if user manually exited gameplay
    end

    TrackEnd.render(deltaTime, clearState);

    outroTimer = outroTimer + deltaTime
    return outroTimer > 4, 1 - outroTimer
end

function update_score(newScore)
    score = newScore
    if (score == 0) then
        maxChain = 0;
    end
end

function update_combo(newCombo)
    chain = newCombo
    Chain.onNewCombo();
    if (chain > maxChain) then
        maxChain = chain;
    end
end

function near_hit(wasLate)

end

function button_hit(button, rating, delta)
    if (showHitAnims) then
        if (rating == 1) then
            HitFX.TriggerAnimation("Near", button + 1)
        elseif (rating == 2) then
            HitFX.TriggerAnimation("Crit", button + 1)
        end
    end

    if 0 < rating and rating < 3 then
        EarlyLate.TriggerAnimation(rating, delta)
    end
end

function laser_slam_hit(slamLength, startPos, endPost, index)
    if (showHitAnims) then
    end
end

function laser_alert(isRight)
    LaserAlert.show(isRight)
end

function practice_start(mission_type, mission_threshold, mission_description)

end

function practice_end_run(playCount, successCount, isSuccessful, scoring)

end

function practice_end(playCount, successCount)

end


function init_tcp()
    Tcp.SetTopicHandler("game.scoreboard", function(data)
        users = {}
        for i, u in ipairs(data.users) do
            table.insert(users, u)
        end
    end)
end

-- Update the users in the scoreboard
function score_callback(response)
    if response.status ~= 200 then
        error()
        return
    end
    local jsondata = json.decode(response.text)
    users = {}
    for i, u in ipairs(jsondata.users) do
        table.insert(users, u)
    end
end
