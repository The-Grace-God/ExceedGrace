json = require "common.json"
local header = {}
header["user-agent"] = "unnamed_sdvx_clone"

local Dim = require("common.dimensions");
local Wallpaper = require("components.wallpaper");
local Background = require('components.background');
local foot = require("components.footers.nautica");
local Easing = require("common.easing")
local getpanel = require("multi.roomList.getpanel");
local getroom = require("multi.roomList.getroom");
local getgrad = require("multi.roomList.getgradient");
local gettop = require("multi.roomList.gettop");

local curser = gfx.CreateSkinImage("multi/roomselect/room_panel_glow.png", 1)

local jacketFallback = gfx.CreateSkinImage("song_select/loading.png", 0)

local entryW = 770
local entryH = 320 / 2
local resX, resY = Dim.design.width, Dim.design.height
local xCount = math.max(1, math.floor(resX / entryW) / 2)
local yCount = math.max(1, math.floor(resY / entryH) / 2.2)
local xOffset = (resX - xCount * entryW) / 3
local cursorPos = 0
local cursorPosX = 0
local cursorPosY = 0
local displayCursorPosX = 0
local displayCursorPosY = 0
local nextUrl = "https://ksm.dev/app/songs"
local screenState = 0 --0 = normal, 1 = level, 2 = sorting
local loading = true
local downloaded = {}
local songs = {}
local filters = {}
local selectedLevels = {}
local soffset = 0
local selectedSorting = "Uploaded"
local lastPlaying = nil
for i = 1, 20 do
    selectedLevels[i] = false
end
local searchText = gfx.CreateLabel("", 5, 0)
local searchIndex = 1
local searchInputActive = false


local cachepath = path.Absolute("skins/" .. game.GetSkin() .. "/nautica.json")
local levelcursor = 0
local sortingcursor = 0
local sortingOptions = { "Uploaded", "Oldest" }
local needsReload = false

local yOffset = 0

local headerMatchingImage = gfx.CreateSkinImage("titlescreen/title.png", 1);

local BAR_ALPHA = 191;
local HEADER_HEIGHT = 100

function drawHeader()
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, BAR_ALPHA)
    gfx.Rect(0, 0, resX, HEADER_HEIGHT)
    gfx.Fill()
    gfx.ClosePath()

    gfx.ImageRect(resX / 2 - 200, HEADER_HEIGHT / 2 - 20, 400, 40, headerMatchingImage, 1, 0)

end

local badgeLinesAnimScale = 0
local transitionEnterScale = 0

local tickTransitions = function(deltaTime)

    if transitionEnterScale < 1 then
        transitionEnterScale = transitionEnterScale + deltaTime / 0.66 -- transition should last for that time in seconds
    else
        transitionEnterScale = 1
    end

    if badgeLinesAnimScale < 1 then
        badgeLinesAnimScale = badgeLinesAnimScale + deltaTime / 0.5 -- transition should last for that time in seconds
    else
        badgeLinesAnimScale = 0
    end
    badgeLinesAnimOffsetX = 16 * (1 - badgeLinesAnimScale);
end

function addsong(song)
    if song.jacket_url ~= nil then
        song.jacket = gfx.LoadWebImageJob(song.jacket_url, jacketFallback, 250, 250)
    else
        song.jacket = jacketFallback
    end
    if downloaded[song.id] then
        song.status = "Downloaded"
    end
    table.insert(songs, song)
end

dlcache = io.open(cachepath, "r")
if dlcache then
    downloaded = json.decode(dlcache:read("*all"))
    dlcache:close()
end
function encodeURI(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])",
            function(c)
                local dontChange = "-/_:."
                for i = 1, #dontChange do
                    if c == dontChange:sub(i, i) then return c end
                end
                return string.format("%%%02X", string.byte(c))
            end)
        str = string.gsub(str, " ", "%%20")
    end
    return str
end

function gotSongsCallback(response)
    if response.status ~= 200 then
        error()
        return
    end
    local jsondata = json.decode(response.text)
    for i, song in ipairs(jsondata.data) do
        addsong(song)
    end
    nextUrl = jsondata.links.next
    loading = false
end

Http.GetAsync(nextUrl, header, gotSongsCallback)

function render_song(song, x, y)

    gfx.Save()
    gfx.Translate(x, y)
    if song.jacket_url ~= nil and song.jacket == jacketFallback then
        song.jacket = gfx.LoadWebImageJob(song.jacket_url, jacketFallback, 250, 250)
    end

    getroom(song, x, y, downloaded)
    gfx.Restore()

end

function load_more()
    if nextUrl ~= nil and not loading then
        Http.GetAsync(nextUrl, header, gotSongsCallback)
        loading = true
    end
end

function render_cursor()
    local x = displayCursorPosX * entryW
    local y = displayCursorPosY * entryH
    jw, jh = gfx.ImageSize(curser);
    gfx.BeginPath();
    gfx.SetImageTint(255, 195, 0) -- orange
    gfx.ImageRect(x, y, jw, jh, curser, 1, 0)
end

function render_loading()
    if not loading then return end

    gfx.FillColor(255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FontSize(32)
    gfx.Text("LOADING...", resX / resX + 10, resY - 390)

end

function render_hotkeys()

    gfx.FontSize(32)

    spacer = 370

    for i = 1, 2, 1 do
        gfx.FillColor(255, 255, 255)
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        if i == 1 then
            gfx.Text("FXR: Sorting", resX / resX + 10, resY - spacer + (i * 20))
        elseif i == 2 then
            gfx.Text("FXL: LV", resX / resX + 10, resY - spacer + 10 + (i * 20))
        end
    end

end

function render(deltaTime)
    tickTransitions(deltaTime)
    Dim.updateResolution()
    Wallpaper.render()

    Dim.transformToScreenSpace()

    Background.draw(deltaTime)
    drawHeader()
    getpanel()

    gfx.Scissor(resX / resX, (resX / 2.5) - 40 + 39, resX, 1020)
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf");
    displayCursorPosX = displayCursorPosX - (displayCursorPosX - cursorPosX) * deltaTime * 10
    displayCursorPosY = displayCursorPosY - (displayCursorPosY - cursorPosY) * deltaTime * 10
    if displayCursorPosY - yOffset > yCount - 1 then --scrolling down
        yOffset = yOffset - (yOffset - displayCursorPosY) - yCount + 1
    elseif displayCursorPosY - yOffset < 0 then
        yOffset = yOffset - (yOffset - displayCursorPosY)
    end

    gfx.Translate(xOffset, 500 - yOffset * entryH)

    for i, song in ipairs(songs) do
        if math.abs(cursorPos - i) <= xCount * yCount * 1.5 + xCount then
            i = i - 1
            local x = entryW * (i % xCount)
            local y = math.floor(i / xCount) * entryH / 2
            render_song(song, x, y)
            if math.abs(#songs - i) < 50 then load_more() end
        end
    end
    gfx.ResetScissor()
    render_cursor()
    gfx.ResetTransform()

    Dim.updateResolution()
    Dim.transformToScreenSpace()

    getgrad(resX, resY)
    gettop(resX, resY)

    foot.draw(deltaTime)

    if needsReload then reload_songs() end
    if screenState == 1 then render_level_filters()
    end

    render_sorting_selection()
    render_loading()
    render_hotkeys()


    soffset = soffset * 0.8
    draw_search(10, 150, -(resX + 1000), 100)
    gfx.ResetScissor()
end

function archive_callback(entries, id)
    game.Log("Listing entries for " .. id, 0)
    local songsfolder = dlScreen.GetSongsPath()
    res = {}
    folders = { songsfolder .. "/nautica/" }
    local hasFolder = false
    for i, entry in ipairs(entries) do
        for j = 1, #entry do
            if entry:sub(j, j) == '/' then
                hasFolder = true
                table.insert(folders, songsfolder .. "/nautica/" .. entry:sub(1, j))
            end
        end
        game.Log(entry, 0)
        res[entry] = songsfolder .. "/nautica/" .. entry
    end

    if not hasFolder then
        for i, entry in ipairs(entries) do
            res[entry] = songsfolder .. "/nautica/" .. id .. "/" .. entry
        end
        table.insert(folders, songsfolder .. "/nautica/" .. id .. "/")
    end
    downloaded[id] = "Downloaded"
    res[".folders"] = table.concat(folders, "|")
    return res
end

local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w _%%%-%.~])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end

function reload_songs()
    needsReload = true
    if loading then return end
    local useLevels = false
    local levelarr = {}

    for i, value in ipairs(selectedLevels) do
        if value then
            useLevels = true
            table.insert(levelarr, i)
        end
    end
    if filters.levels ~= nil then
        for i, value in ipairs(filters.levels) do
            useLevels = true
            table.insert(levelarr, value)
        end
    end
    nextUrl = string.format("https://ksm.dev/app/songs?sort=%s", selectedSorting:lower())
    if useLevels then
        nextUrl = nextUrl .. "&levels=" .. table.concat(levelarr, ",")
    end
    if filters.effector ~= nil then
        nextUrl = nextUrl .. "&effector=" .. urlencode(filters.effector)
    end
    if filters.uploader ~= nil then
        nextUrl = nextUrl .. "&uploader=" .. urlencode(filters.uploader)
    end
    if filters.query ~= nil then
        nextUrl = nextUrl .. "&q=" .. urlencode(filters.query)
    end

    songs = {}
    cursorPos = 0
    cursorPosX = 0
    cursorPosY = 0
    displayCursorPosX = 0
    displayCursorPosY = 0
    load_more()
    game.Log(nextUrl, 0)
    needsReload = false
end

function button_pressed(button)
    if button == game.BUTTON_STA then
        if screenState == 0 then
            local song = songs[cursorPos + 1]
            if song == nil then return end
            dlScreen.DownloadArchive(encodeURI(song.cdn_download_url), header, song.id, archive_callback)
            downloaded[song.id] = "Downloading"
        elseif screenState == 1 then
            if selectedLevels[levelcursor + 1] then
                selectedLevels[levelcursor + 1] = false
            else
                selectedLevels[levelcursor + 1] = true
            end
            reload_songs()
        elseif screenState == 2 then
            selectedSorting = sortingOptions[sortingcursor + 1]
            reload_songs()
        end
    elseif button == game.BUTTON_BTA then
        if screenState == 0 then
            local song = songs[cursorPos + 1]
            if song == nil then return end
            dlScreen.PlayPreview(encodeURI(song.preview_url), header, song.id)
            song.status = "Playing"
            if lastPlaying ~= nil then
                song.status = "Playing"
                lastPlaying.status = nil
            end
            lastPlaying = song
        end

    elseif button == game.BUTTON_FXL then
        if screenState ~= 1 then
            screenState = 1
        else
            screenState = 0
        end
    elseif button == game.BUTTON_FXR then
        if screenState ~= 2 then
            screenState = 2
        else
            screenState = 0
        end
    elseif button == game.BUTTON_BCK then
        dlcache = io.open(cachepath, "w")
        dlcache:write(json.encode(downloaded))
        dlcache:close()
        dlScreen.Exit()
    end
end

function key_pressed(key)
    if key == 27 then --escape pressed
        dlcache = io.open(cachepath, "w")
        dlcache:write(json.encode(downloaded))
        dlcache:close()
        dlScreen.Exit()
    end
end

function advance_selection(steps)
    if screenState == 0 and #songs > 0 then
        cursorPos = (cursorPos + steps) % #songs
        cursorPosX = cursorPos % xCount
        cursorPosY = math.floor(cursorPos / xCount)
        if cursorPos > #songs - 6 then
            load_more()
        end
    elseif screenState == 1 then
        levelcursor = (levelcursor + steps) % 20
    elseif screenState == 2 then
        sortingcursor = (sortingcursor + steps) % #sortingOptions
    end
end

function render_level_filters()
    gfx.BeginPath()
    gfx.FontSize(40)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)

    -- 1 - 20
    for i = 1, 20 do
        x = (resX / resX)
        y = (resY / resY) + (i - 1) * 50
        if selectedLevels[i] then gfx.FillColor(255, 255, 0) else gfx.FillColor(255, 255, 255) end
        gfx.Text(tostring(i), x + 30, y + 460)
        if i == 1 then
            diff_box_render_x = x + 9
            diff_box_render_y = y + 435 + (levelcursor * 50)
        end
    end
    --box
    gfx.BeginPath()
    gfx.Rect(diff_box_render_x, diff_box_render_y, 44, 44)
    gfx.StrokeColor(0, 204, 255)
    gfx.StrokeWidth(2)
    gfx.Stroke()

end

function render_sorting_selection()
    gfx.BeginPath()
    gfx.FillColor(255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.FontSize(30)
    gfx.Text("Sorting method:", resX / resX + 50, 250)
    gfx.FontSize(25)
    this = 285
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Scissor(resX / resX + 125, this, 400, 20)
    for i, opt in ipairs(sortingOptions) do
        y = this - 10 + (i - sortingcursor) * 20
        if selectedSorting == opt then gfx.FillColor(255, 255, 255) else gfx.FillColor(127, 127, 127) end
        gfx.Text(string.upper(opt), resX / resX + 175, y)
    end
    gfx.ResetScissor()
end

function update_search_text(active, text)
    searchInputActive = active
    gfx.UpdateLabel(searchText, string.format("Search: %s", text), 30, 0)
end

function update_search_filters(new_filters)
    filters = new_filters
    reload_songs()
end

local searchIndex = 1
function draw_search(x, y, w, h)
    soffset = soffset + (searchIndex) - (searchInputActive and 0 or 1)
    if searchIndex ~= (searchInputActive and 0 or 1) then
        game.PlaySample("woosh")
    end
    searchIndex = searchInputActive and 0 or 1

    gfx.BeginPath()
    local xpos = x + (searchIndex + soffset) * w
    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.DrawLabel(searchText, xpos, y + (h / 2), w - 20)

end
