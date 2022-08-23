local stopMusic = function ()
    local musicPlaying = game.GetSkinSetting('_musicPlaying');
    if musicPlaying and musicPlaying ~= '' then
        game.StopSample(musicPlaying);
        game.SetSkinSetting("_musicPlaying", "")
    end
end

local function splitString(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

local function filter(tableIn, predicate)
    local out = {}
    for _, val in ipairs(tableIn) do
        if predicate(val) then
            table.insert(out, val)
        end
    end
    return out
end

return {
    stopMusic = stopMusic,
    splitString = splitString,
    filter = filter
}