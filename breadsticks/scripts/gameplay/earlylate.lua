
local desw = 1080;
local desh = 1920;

local transitionExistScale = 0;

local tickTransitions = function (deltaTime)
    
    if transitionExistScale < 1 then
        transitionExistScale = transitionExistScale + deltaTime / 2 -- transition should last for that time in seconds
    end
end

local render = function (deltaTime, comboState, combo, critLineCenterX, critLineCenterY)
    tickTransitions(deltaTime)

    if (transitionExistScale >= 1) then
        return;
    end


end

local trigger = function ()
    
end

return {
    render=render
}