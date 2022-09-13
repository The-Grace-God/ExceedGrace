require("common.globals")
--file reader utility functions

---Get game path
---@return string, string
local function getGamePath()
    return debug.getinfo(1,"S").source:sub(2):match("(.*)([\\/])skins") -- this is very hacky :)
end

local function readBytes(_file)
    local out = {}
    repeat
        local buffer = _file:read(4*1024)
        for c in (buffer or ''):gmatch(".") do
            table.insert(out, c:byte())
        end
    until not buffer
    return out
end

---Read a file in the game folder by lines
---@param path string relative path to game file
---@param mode? openmode default "r"
---@return nil|string[]
function ReadGameFileLines(path, mode)
    mode = mode or "r"

    local gamepath, sep = getGamePath()

    local lines = {}

    local f = io.open(gamepath .. sep .. path, mode)
    if not f then return nil end

    for line in f:lines("l") do
        table.insert(lines, line)
    end
    f:close()

    return lines
end

---Read a file in the game folder
---@param path string # relative path to game file
---@param mode? openmode # default "r"
---@return nil|string|integer[]
function ReadGameFile(path, mode)
    mode = mode or "r"

    local gamepath, sep = getGamePath()
    local out

    local f = io.open(gamepath .. sep .. path, mode)
    if not f then return nil end

    if mode:match(".*b") then
        out = readBytes(f)
    else
        out = f:read("a")
    end
    f:close()

    return out
end

---Find patterns in file
---@param path string # relative path to game file
---@param pattern string # search pattern
---@return table # {{group1, group2, ...}, ...}
function FindPatterns(path, pattern)
    local matches = {}
    for _, line in ipairs(ReadGameFileLines(path, "r")) do
        if line:match(pattern) then
            table.insert(matches, {line:match(pattern)})
        end
    end
    return matches
end

--- Check if a file or directory exists in this path
---@param file string # relative path to game file
---@return boolean # file exists
---@return string # error message
function IsFileExists(file)
    local gamepath, sep = getGamePath()
    file = gamepath .. sep .. file

    local ok, err, code = os.rename(file, file)
    if not ok then
        game.Log("err: "..err..", code: "..code, game.LOGGER_DEBUG)
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

--- Check if a directory exists in this path
---@param path string # relative path to game directory
---@return boolean # directory exists
function IsDir(path)
   -- "/" works on both Unix and Windows
   return IsFileExists(path .. "/")
end
