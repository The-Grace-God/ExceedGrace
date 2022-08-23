
local VolforceWindow = require('components.volforceWindow')

local Banner = require('gameplay.banner')
local CritLine = require('gameplay.crit_line')
local Console = require('gameplay.console')
local UserPanel = require('gameplay.user_panel')
local SongPanel = require('gameplay.song_panel')
local ScorePanel = require('gameplay.score_panel')
local Gauge = require('gameplay.gauge')
local Chain = require('gameplay.chain')
local LaserAlert = require('gameplay.laser_alert')

local TrackEnd = require('gameplay.track_end')

local json = require "json"

-- Window variables
local resX, resY

-- Aspect Ratios
local landscapeWidescreenRatio = 16 / 9
local landscapeStandardRatio = 4 / 3
local portraitWidescreenRatio = 9 / 16

-- Portrait sizes
local fullX, fullY
local desw = 1080
local desh = 1920

local resolutionChange = function(x, y)
    resX = x
    resY = y
    fullX = portraitWidescreenRatio * y
    fullY = y

    game.Log('resX:' .. resX .. ' // resY:' .. resY .. ' // fullX:' .. fullX .. ' // fullY:' .. fullY, game.LOGGER_ERROR);
end

local users = nil

local maxChain = 0;
local chain = 0;
local score = 0;

function render(deltaTime)
    -- detect resolution change
    local resx, resy = game.GetResolution();
    if resx ~= resX or resy ~= resY then
        resolutionChange(resx, resy)
    end

    Banner.render(deltaTime, users, gameplay.user_id);

    UserPanel.render(deltaTime, score, gameplay.scoreReplays[1]);
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
end

function render_crit_base(deltaTime)
    CritLine.renderBase(deltaTime, gameplay.critLine.x, gameplay.critLine.y, -gameplay.critLine.rotation, gameplay.critLine.cursors);
    Console.render(deltaTime, gameplay.critLine.x, gameplay.critLine.y, -gameplay.critLine.rotation);
end

function render_crit_overlay(deltaTime)

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

end

function laser_slam_hit(slamLength, startPos, endPost, index)

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
