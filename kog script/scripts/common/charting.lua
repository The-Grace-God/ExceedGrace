local Charting = { };

function Charting.GetDisplayDifficulty(jacketPath, difficulty)
    if jacketPath == nil then
      return difficulty
    end

    local strippedPath = string.match(jacketPath:lower(), "[/\\][^\\/]+$")
    if difficulty == 3 and strippedPath then
        if string.find(strippedPath, "inf") ~= nil then
            return 5
        elseif string.find(strippedPath, "grv") ~= nil then
            return 6
        elseif string.find(strippedPath, "hvn") ~= nil then
            return 7
        elseif string.find(strippedPath, "vvd") ~= nil then
            return 8
        elseif string.find(strippedPath, "xcd") ~= nil then
            return 9
        end
    end

    return difficulty + 1
end

return Charting;
