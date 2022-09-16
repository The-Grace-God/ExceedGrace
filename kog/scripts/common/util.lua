local function split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
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

local function clamp(x, min, max)
    if x < min then
        x = min
    end
    if x > max then
        x = max
    end

    return x
end

local function round(num)
    return num + (2^52 + 2^51) - (2^52 + 2^51)
end

local function sign(x)
    return (
        (x > 0) and 1
        or
        (x < 0) and -1
        or
        0
    )
end

local function roundToZero(x)
    if x < 0 then
        return math.ceil(x)
    elseif x > 0 then
        return math.floor(x)
    else
        return 0
    end
end

local function areaOverlap(x, y, areaX, areaY, areaW, areaH)
    return x > areaX and y > areaY and x < areaX + areaW and y < areaY + areaH
end

local function lerp(x, x0, y0, x1, y1)
    return y0 + (x - x0) * (y1 - y0) / (x1 - x0)
end

--modulo operation for index value
local function modIndex(index, mod)
    return (index - 1) % mod + 1
end

local function firstAlphaNum(s)
  for i = 1, string.len(s) do
    local byte = string.byte(s, i);
    if ((byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) or (byte >= 48 and byte <= 57)) then
      return string.sub(s, i, i);
    end
  end

  return '';
end

return {
    split = split,
    filter = filter,
    clamp = clamp,
    round = round,
    sign = sign,
    roundToZero = roundToZero,
    areaOverlap = areaOverlap,
    lerp = lerp,
    modIndex = modIndex,
    firstAlphaNum = firstAlphaNum,
}
