
require "common.class"

require "api.graphics"

local Image = require "api.image"

---@class AnimationParams
---@field fps number?
---@field loop boolean?
---@field loopPoint integer?
---@field width number?
---@field height number?
---@field x number?
---@field y number?
---@field scaleX number?
---@field scaleY number?
---@field centered boolean?
---@field blendOp integer?
---@field color number[]?
---@field alpha number?
---@field stroke StrokeParams?

---@class Animation
---@field frames Image[]
---@field frameCount integer
---@field frameTime number
---@field loop boolean
---@field loopPoint integer
---@field width number?
---@field height number?
---@field x number?
---@field y number?
---@field scaleX number?
---@field scaleY number?
---@field centered boolean?
---@field blendOp integer?
---@field color number[]?
---@field alpha number?
---@field stroke StrokeParams?
local Animation = { };

---@class AnimationState
---@field animation Animation # The animation data this state is playing through
---@field frameIndex integer # Current frame in the animation
---@field timer number # Timer used to determine when to change to the next frame
---@field running boolean # Is the animation currently running and accepting updates?
---@field callback function? # Called when the animation completes
local AnimationState = { };

local function loadSequentialAnimationFrames(animPath)
    local frames = { };
    local count = 0;

    local detectedFormat = nil;

    while (true) do
        local frame = nil;
        if (detectedFormat) then
            frame = Image.new(detectedFormat:format(animPath, count + 1), true);
        else
            for i = 1, 4 do
                local format = '%s/%0' .. i .. 'd.png';
                frame = Image.new(format:format(animPath, count + 1), true);

                if (frame) then
                    detectedFormat = format;
                    break;
                end
            end
        end

        if (not frame) then
            break;
        end

        count = count + 1;
        frames[count] = frame;
    end

    return frames, count;
end

---Animation constructor
---@param animPath string
---@param params AnimationParams
---@return Animation
function Animation.new(animPath, params)
    local frames, frameCount = loadSequentialAnimationFrames(animPath);

    local instance = {
        frames = frames,
        frameCount = frameCount,

        frameTime = 1 / (params.fps or 30),
        loop = params.loop or false,
        loopPoint = params.loopPoint or 1,
    };

    if (params.width ~= nil) then instance.width = params.width; end
    if (params.height ~= nil) then instance.height = params.height; end
    if (params.x ~= nil) then instance.x = params.x; end
    if (params.y ~= nil) then instance.y = params.y; end
    if (params.scaleX ~= nil) then instance.scaleX = params.scaleX; end
    if (params.scaleY ~= nil) then instance.scaleY = params.scaleY; end
    if (params.centered ~= nil) then instance.centered = params.centered; end
    if (params.blendOp ~= nil) then instance.blendOp = params.blendOp; end
    if (params.color ~= nil) then instance.color = params.color; end
    if (params.alpha ~= nil) then instance.alpha = params.alpha; end
    if (params.stroke ~= nil) then instance.stroke = params.stroke; end

    return CreateInstance(Animation, instance);
end

---Create an AnimationState to play this animation.
---The AnimationState is not started.
---@param callback function?
---@return AnimationState
function Animation:createState(callback)
    ---@type AnimationState
    local state = { animation = self, callback = callback, frameIndex = 1, timer = 0, running = false };
    return CreateInstance(AnimationState, state);
end

---Create an AnimationState to play this animation and start it.
---@param callback function?
---@return AnimationState
function Animation:start(callback)
    local state = self:createState(callback);
    state:start();

    return state;
end

---Start this AnimationState.
---Does nothing if it's already running.
function AnimationState:start()
    self.running = true;
end

---Restart this AnimationState.
---The frame index is reset to 1.
function AnimationState:restart()
    self.running = true;
    self.frameIndex = 1;
    self.timer = 0;
end

---Stop this AnimationState.
function AnimationState:stop()
    self.running = false;
end

---Updates this AnimationState and then rendersit, passing on the given ImageParams to each frame.
---@param deltaTime number
---@param params? ImageParams
function AnimationState:render(deltaTime, params)
    if (not self.running) then return; end;

    self.timer = self.timer + deltaTime;

    while (self.timer > self.animation.frameTime) do
        self.timer = self.timer - self.animation.frameTime;
        self.frameIndex = self.frameIndex + 1;

        if (self.frameIndex > self.animation.frameCount) then
            if (self.animation.loop) then
                self.frameIndex = self.animation.loopPoint;
            else
                self.running = false;

                if (self.callback) then
                    self.callback();
                end

                return;
            end
        end
    end

    if (params) then
        if (params.width == nil) then params.width = self.animation.width; end
        if (params.height == nil) then params.height = self.animation.height; end
        if (params.x == nil) then params.x = self.animation.x; end
        if (params.y == nil) then params.y = self.animation.y; end
        if (params.scaleX == nil) then params.scaleX = self.animation.scaleX; end
        if (params.scaleY == nil) then params.scaleY = self.animation.scaleY; end
        if (params.centered == nil) then params.centered = self.animation.centered; end
        if (params.blendOp == nil) then params.blendOp = self.animation.blendOp; end
        if (params.alpha == nil) then params.alpha = self.animation.alpha; end
        if (params.stroke == nil) then params.stroke = self.animation.stroke; end
    end

    local frame = self.animation.frames[self.frameIndex];
    if (not frame) then
        -- TODO(local): what do
    else
        frame:render(params);
    end
end

return Animation;
