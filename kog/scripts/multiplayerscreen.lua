local json = require("common.json")

local common = require('common.util');
local Sound = require("common.sound")
local Dim = require("common.dimensions")
local Wallpaper = require("components.wallpaper")
local Background = require('components.background');
local difbar = require("components.diff_rectangle");
local playercheck = require("multi.player")

local creww = game.GetSkinSetting("single_idol")

-- inRoom components
local songjacket = require("multi.inRoom.songjacket")
local m_own_info = require("multi.inRoom.owninfo")
local m_base_part = require("multi.inRoom.basepanel")
local m_part = require("multi.inRoom.mainpanel")
local m_s_part = require("multi.inRoom.songinfo")
local m_bpm_part = require("multi.inRoom.bpmpanel")
local m_info_part = require("multi.inRoom.infopanel")

-- roomList components
local getpanel     = require("multi.roomList.getpanel")
local getroom      = require("multi.roomList.getroom")
local draw_room    = require("multi.roomList.drawroom")
local l_grad       = gfx.CreateSkinImage("multi/roomselect/lobby_select_gradiant.png", 1);
local l_base_panel = gfx.CreateSkinImage("multi/roomselect/lobby_select.png", 1);

local headerMatchingImage = gfx.CreateSkinImage("titlescreen/entry.png", 1);

local m_4pb_panels_bottom = gfx.CreateSkinImage("multi/lobby/opponent_bottom_panel.png", 1);
local m_4pb_panels_top = gfx.CreateSkinImage("multi/lobby/opponent_top_panel.png", 1);
local ready_bt = gfx.CreateSkinImage("multi/lobby/READY.png", 1);

local bg = gfx.CreateSkinImage("multi/lobby/bg.png", 1);
local bg_graid1 = gfx.CreateSkinImage("multi/lobby/gradient_bottom.png", 1);
local bg_graid2 = gfx.CreateSkinImage("multi/lobby/gradient_top.png", 1);

local idle = "/idle"
local idolAnimation = gfx.LoadSkinAnimation('crew/anim/' .. creww .. idle, 1 / 30, 0, true);
local idolAnimTransitionScale = 0;

local leftPanelX = 575;
local leftPanelY = 1472;

local desw, desh = Dim.design.width, Dim.design.height

local mposx = 0;
local mposy = 0;
local hovered = nil;
local buttonWidth = desw * (3 / 4);
local buttonHeight = 75;
local buttonBorder = 2;
local portrait
local jacket_size;

local BAR_ALPHA = 191;
local HEADER_HEIGHT = 100


local scale;

game.LoadSkinSample("click-02")
game.LoadSkinSample("click-01")
game.LoadSkinSample("menu_click")

local loading = true;
local rooms = {};
local lobby_users = {};
selected_room = nil;
local user_id = nil;
local all_ready;
local user_ready;
local go;
local hard_mode = false;
local rotate_host = false;
local start_game_soon = false;
local host = nil;
local owner = nil;
local missing_song = false;
local did_exit = false;

local irHeartbeatRequested = false;
irText = ''

local grades = {
    { ["max"] = 6900000, ["image"] = gfx.CreateSkinImage("common/grades/D.png", 0) },
    { ["max"] = 7900000, ["image"] = gfx.CreateSkinImage("common/grades/C.png", 0) },
    { ["max"] = 8600000, ["image"] = gfx.CreateSkinImage("common/grades/B.png", 0) },
    { ["max"] = 8900000, ["image"] = gfx.CreateSkinImage("common/grades/A.png", 0) },
    { ["max"] = 9200000, ["image"] = gfx.CreateSkinImage("common/grades/A+.png", 0) },
    { ["max"] = 9400000, ["image"] = gfx.CreateSkinImage("common/grades/AA.png", 0) },
    { ["max"] = 9600000, ["image"] = gfx.CreateSkinImage("common/grades/AA+.png", 0) },
    { ["max"] = 9700000, ["image"] = gfx.CreateSkinImage("common/grades/AAA.png", 0) },
    { ["max"] = 9800000, ["image"] = gfx.CreateSkinImage("common/grades/AAA+.png", 0) },
    { ["max"] = 9900000, ["image"] = gfx.CreateSkinImage("common/grades/S.png", 0) }
}

local badges = {
    gfx.CreateSkinImage("badges/played.png", 0),
    gfx.CreateSkinImage("badges/clear.png", 0),
    gfx.CreateSkinImage("badges/hard-clear.png", 0),
    gfx.CreateSkinImage("badges/full-combo.png", 0),
    gfx.CreateSkinImage("badges/perfect.png", 0)
}

local user_name_key = game.GetSkinSetting('multi.user_name_key')
if user_name_key == nil then
    user_name_key = 'nick'
end
local name = game.GetSkinSetting(user_name_key)
if name == nil or name == '' then
    name = 'Guest'
end

local normal_font = game.GetSkinSetting('multi.normal_font')
if normal_font == nil then
    normal_font = 'NotoSans-Regular.ttf'
end
local mono_font = game.GetSkinSetting('multi.mono_font')
if mono_font == nil then
    mono_font = 'NovaMono.ttf'
end

local SERVER = game.GetSkinSetting("multi.server")

local drawIdol = function(deltaTime)
    local idolAnimTickRes = gfx.TickAnimation(idolAnimation, deltaTime);
    if idolAnimTickRes == 1 then
        gfx.GlobalAlpha(idolAnimTransitionScale);

        idolAnimTransitionScale = idolAnimTransitionScale + 1 / 60;
        if (idolAnimTransitionScale > 1) then
            idolAnimTransitionScale = 1;
        end

        gfx.ImageRect(0, 0, Dim.design.width, Dim.design.height, idolAnimation, 1, 0);
        gfx.GlobalAlpha(1);
    end
end

function getCorrectedIndex(from, offset)
    total = #songwheel.songs

    if (math.abs(offset) > total) then
        if (offset < 0) then
            offset = offset + total * math.floor(math.abs(offset) / total)
        else
            offset = offset - total * math.floor(math.abs(offset) / total)
        end
    end

    index = from + offset

    if index < 1 then
        index = total + (from + offset) -- this only happens if the offset is negative
    end

    if index > total then
        indexesUntilEnd = total - from
        index = offset - indexesUntilEnd -- this only happens if the offset is positive
    end

    return index
end

user_setup = function() -- (semi new) user layering

    for i, user in ipairs(lobby_users) do

        buttonY = 1142 - 360 / 1.2

        player_states={}

        player_states.name = user.name
        player_states.id = user.id
        player_states.ready = user_ready
        player_states.no_map = user.missing_map
        player_states.host = host
        player_states.owner = owner
        player_states.start = all_ready

            local order = i
            local showthing = false
 --           if owner == user_id and user.id ~= user_id then
 --               draw_button("K", 525 + distance, buttonY, 100, function()
 --                   kick_user(user);
 --               end)
 --           end
 --           if (owner == user_id or host == user_id) and user.id ~= host then
 --               draw_button("H", 16, buttonY + 250, 50, function()
 --                   change_host(user);
 --               end)
 --           end

            playercheck.in_lobbycheck(player_states,user_id,irText,order,showthing)
        
    end
end

function drawHeader()
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, BAR_ALPHA)
    gfx.Rect(0, 0, desw, HEADER_HEIGHT)
    gfx.Fill()
    gfx.ClosePath()

    gfx.ImageRect(desw / 2 - 200, HEADER_HEIGHT / 2 - 20, 400, 40, headerMatchingImage, 1, 0)
end

mouse_clipped = function(x, y, w, h)
    return mposx > x and mposy > y and mposx < x + w and mposy < y + h;
end;

custom_button = function(name, x, y, image, font, font_size, hoverindex)
    local jw, jh = gfx.ImageSize(image);
    gfx.BeginPath();
    gfx.ImageRect(x, y, jw, jh, image, 1, 0);
    gfx.BeginPath();
    gfx.FillColor(255, 255, 255);
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
    gfx.LoadSkinFont(font)
    gfx.FontSize(font_size);
    gfx.Text(name, x + (jw / 2) + 5, y + (jh / 2.25));
end

draw_button = function(name, x, y, buttonWidth, hoverindex)
    draw_button_color(name, x, y, buttonWidth, hoverindex, 40, 40, 40, 0, 128, 255)
end

draw_button_color = function(name, x, y, buttonWidth, hoverindex, r, g, b, olr, olg, olb)
    local rx = x - (buttonWidth / 2);
    local ty = y - (buttonHeight / 2);
    gfx.BeginPath();
    gfx.FillColor(olr, olg, olb);
    if mouse_clipped(rx, ty, buttonWidth, buttonHeight) then
        hovered = hoverindex;
        gfx.FillColor(255, 128, 0);
    end
    gfx.Rect(rx - buttonBorder,
        ty - buttonBorder,
        buttonWidth + (buttonBorder * 2),
        buttonHeight + (buttonBorder * 2));
    gfx.Fill();
    gfx.BeginPath();
    gfx.FillColor(r, g, b);
    gfx.Rect(rx, ty, buttonWidth, buttonHeight);
    gfx.Fill();
    gfx.BeginPath();
    gfx.FillColor(255, 255, 255);
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FontSize(40);
    gfx.Text(name, x, y);
end;

draw_checkbox = function(text, x, y, hoverindex, current, can_click)
    gfx.BeginPath();

    if can_click then
        gfx.FillColor(255, 255, 255, 100);
    else
        gfx.FillColor(100, 100, 100, 100);
    end
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
    gfx.Text(text, x, y)

    local xmin, ymin, xmax, ymax = gfx.TextBounds(x, y, text);

    local sx = xmin - 40;
    local sy = y - 15;

    if can_click and mouse_clipped(xmin - 10, ymin, xmax - xmin, ymax - ymin) then
        hovered = hoverindex;
    end

    if current then
        -- Draw checkmark
        gfx.BeginPath();
        gfx.FillColor(0, 236, 0, 100);
        gfx.Text(text, x, y)
    end
end;

function render_loading()
    if not loading then return end
    gfx.Save()
    gfx.ResetTransform()
    gfx.BeginPath()
    gfx.MoveTo(desw, desh)
    gfx.LineTo(desw - 350, desh)
    gfx.LineTo(desw - 300, desh - 50)
    gfx.LineTo(desw, desh - 50)
    gfx.ClosePath()
    gfx.FillColor(33, 33, 33)
    gfx.Fill()
    gfx.FillColor(255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT, gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(70)
    gfx.Text("LOADING...", desw - 20, desh - 3)
    gfx.Restore()
end

function render_info()

    if searchStatus then
        gfx.BeginPath()
        gfx.FillColor(255, 255, 255)
        gfx.FontSize(20);
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
        gfx.Text(searchStatus, 3, 3)
    end

end

draw_diff_icon = function(diff, x, y, w, h)
    difbar.render(deltaTime, x, y, 1, diff.difficulty + 1, diff.level);
end

local doffset = 0;
local timer = 0;

local possy = 1095;
local possx = 150;

draw_diffs = function(diffs, x, y, w, h, selectedDiff)
    local diffWidth = w / 2
    local diffHeight = w / 2
    local diffCount = #diffs
    gfx.Scissor(x + 84 + possx, y + possy, w / 2.451, h)
    for i = math.max(selectedDiff - 2, 1), math.max(selectedDiff - 1, 1) do
        local diff = diffs[i]
        local xpos = x + ((w / 2 - diffWidth / 2) + (selectedDiff - i + doffset) * (-0.8 * diffWidth))
        if i ~= selectedDiff then
            draw_diff_icon(diff, xpos + possx, y + possy, diffWidth, diffHeight, false)
        end
    end
    --after selected
    for i = math.min(selectedDiff + 2, diffCount), selectedDiff + 1, -1 do
        local diff = diffs[i]
        local xpos = x + ((w / 2 - diffWidth / 2) + (selectedDiff - i + doffset) * (-0.8 * diffWidth))
        if i ~= selectedDiff then
            draw_diff_icon(diff, xpos + possx, y + possy, diffWidth, diffHeight, false)
        end
    end

    local diff = diffs[selectedDiff]
    local xpos = x + ((w / 2 - diffWidth / 2) + (doffset) * (-0.8 * diffWidth))
    draw_diff_icon(diff, xpos + possx, y + possy, diffWidth, diffHeight, true)
    gfx.ResetScissor()
end

set_diff = function(oldDiff, newDiff)
    game.PlaySample("click-02")
    doffset = doffset + oldDiff - newDiff
end;

local selected_room_index = 1;
local ioffset = 0;

function draw_rooms(y, h)
    if #rooms == 0 then
        return
    end

    local num_rooms_visible = math.floor(h / (buttonHeight + 10))

    local first_half_rooms = math.floor(num_rooms_visible / 2)
    local second_half_rooms = math.ceil(num_rooms_visible / 2) - 1

    local start_offset = math.max(selected_room_index - first_half_rooms, 1);
    local end_offset = math.min(selected_room_index + second_half_rooms + 2, #rooms);

    local start_index_offset = 1;

    -- If our selection is near the start or end we have to offset
    if selected_room_index <= first_half_rooms then
        start_index_offset = 0;
        end_offset = math.min(#rooms, num_rooms_visible + 1)
    end
    if selected_room_index >= #rooms - second_half_rooms then
        start_offset = math.max(1, #rooms - num_rooms_visible)
        end_offset = #rooms
    end

    for i = start_offset, end_offset do
        local room = rooms[i];
        -- if selected room < halfvis then we start at 1
        -- if sel > #rooms - halfvis then we start at -halfvis
        local offset_index = (start_offset + first_half_rooms) - i + start_index_offset

        local offsetY = (offset_index + ioffset) * (buttonHeight + 10);
        local ypos = y + (h / 2) - offsetY;
        local status = room.current .. '/' .. room.max
        if room.current == room.max then
            statusST = status
            statusF = " <FULL>"
        else
            statusST = status
            statusF = " <NOT FULL>"
        end
        if room.ingame then
            statusM = ' <IN MATCH>'
        end
        if room.password then
            statusPW = ' <LOCKED>'
        else
            statusPW = '   <OPEN>'
        end
        stats = { statusST, statusF, statusM, statusPW }

        draw_room(room.name, desw / 2, ypos, stats, i == selected_room_index, function()
            join_room(room)
        end)
    end
end

change_selected_room = function(off)

    local new_index = selected_room_index + off;
    --selected_room_index = 2;
    if new_index < 1 or new_index > #rooms then
        return;
    end

    local h = desh - 290;

    local num_rooms_visible = math.floor(h / (buttonHeight + 10))

    local first_half_rooms = math.floor(num_rooms_visible / 2)
    local second_half_rooms = math.ceil(num_rooms_visible / 2) - 1

    if off > 0 and (selected_room_index < first_half_rooms or selected_room_index >= #rooms - second_half_rooms - 1) then
    elseif off < 0 and (selected_room_index <= first_half_rooms or selected_room_index >= #rooms - second_half_rooms) then
    else
        ioffset = ioffset - new_index + selected_room_index;
    end

    game.PlaySample("menu_click")

    selected_room_index = new_index;
end

local IR_HeartbeatResponse = function(res)
    if res.statusCode == IRData.States.Success then
        irText = res.body.serverName .. ' ' .. res.body.irVersion;
    else
        game.Log("Can't connect to IR!", game.LOGGER_WARNING)
    end
end

local IR_Handle = function()
    if not irHeartbeatRequested then
        IR.Heartbeat(IR_HeartbeatResponse)
        irHeartbeatRequested = true;
    end
end

function render_lobby(deltaTime)
    gfx.BeginPath();
    gfx.ImageRect(0, 0, desw, desh, bg, 1, 0);
    drawIdol(deltaTime)
    gfx.BeginPath();
    gfx.ImageRect(0, 0, desw, desh, bg_graid1, 1, 0);
    gfx.ImageRect(0, 0, desw, desh, bg_graid2, 1, 0);
    gfx.BeginPath();

    m_base_part()

    m_own_info()
    user_setup()

    m_info_part()
    m_part()
    m_s_part()
    m_bpm_part()
    songjacket()
end

function render_room_list(deltaTime)

    Background.draw(deltaTime)
    getpanel()
    station = "Multi Station"
    local jw, jh = gfx.ImageSize(l_grad);

    -- the list
    getroom()
    --

    gfx.BeginPath();
    gfx.ImageRect(desw / desw, lobbypanelY, jw, jh, l_grad, 1, 0);

    gfx.BeginPath();
    gfx.ImageRect(desw / desw, lobbypanelY, jw, jh, l_base_panel, 1, 0);

    gfx.BeginPath();
    gfx.FontSize(40)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_CENTER)
    gfx.LoadSkinFont("Digital-Serial-Bold.ttf");
    gfx.FillColor(243, 217, 175, 255)
    gfx.Fill()
    gfx.Text(string.upper(station), desw / 2, desh / 2 - 546)
    gfx.FillColor(255, 255, 255, 50)
    gfx.Text(string.upper(station), desw / 2, desh / 2 - 546)
    gfx.Fill()

end

passwordErrorOffset = 0;
function render_password_screen(deltaTime)
    gfx.FillColor(255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(70)
    gfx.Text("Joining " .. selected_room.name .. "...", desw / 2, desh / 4)

    gfx.FillColor(50, 50, 50)
    gfx.BeginPath()
    gfx.Rect(0, desh / 2 - 10, desw, 40)
    gfx.Fill();

    gfx.FillColor(255, 255, 255)
    gfx.Text("Please enter room password:", desw / 2, desh / 2 - 40)
    gfx.Text(string.rep("*", #textInput.text), desw / 2, desh / 2 + 40)
    if passwordError then

        gfx.FillColor(255, 50, 50)
        gfx.FontSize(60 + math.floor(passwordErrorOffset * 20))
        gfx.Text("Invalid password", desw / 2, desh / 2 + 80)
    end
    draw_button("Join", desw / 2, desh * 3 / 4, desw / 2, mpScreen.JoinWithPassword);
end

function render_new_room_password(deltaTime)
    gfx.FillColor(255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(70)
    gfx.Text("Create New Room", desw / 2, desh / 4)

    -- make something here

    gfx.FillColor(255, 255, 255)
    gfx.Text("Enter room password:", desw / 2, desh / 2 - 40)
    gfx.Text(string.rep("*", #textInput.text), desw / 2, desh / 2 + 40)
    draw_button("Create Room", desw / 2, desh * 3 / 4, desw / 2, mpScreen.NewRoomStep);
end

function render_new_room_name(deltaTime)
    gfx.BeginPath();
    gfx.LoadSkinFont("segoeui.ttf")
    gfx.FillColor(255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(70)
    gfx.Text("Create New Room", desw / 2, desh / 4)

    gfx.Rect(0, desh / 2 - 10, desw / 2, 60)


    gfx.Text("Please enter room name:", desw / 2, desh / 2 - 40)
    gfx.Text(textInput.text, desw / 2, desh / 2 + 40)
    draw_button("Next", desw / 2, desh * 3 / 4, desw / 2, mpScreen.NewRoomStep);
end

function render_set_username(deltaTime)
    gfx.FillColor(255, 255, 255)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_BOTTOM)
    gfx.FontSize(70)
    gfx.Text("First things first...", desw / 2, desh / 4)

    gfx.FillColor(50, 50, 50)
    gfx.BeginPath()
    gfx.Rect(0, desh / 2 - 10, desw, 60)
    gfx.Fill();

    gfx.FillColor(255, 255, 255)
    gfx.Text("Enter a display name:", desw / 2, desh / 2 - 40)
    gfx.Text(textInput.text, desw / 2, desh / 2 + 40)
    draw_button("Join Multiplayer", desw / 2, desh * 3 / 4, desw / 2, function()
        loading = true;
        mpScreen.SaveUsername()
    end);

end

render = function(deltaTime)
    IR_Handle()
    Dim.updateResolution()
    Wallpaper.render()

    Dim.transformToScreenSpace()

    mposx, mposy = game.GetMousePos();

    Sound.stopMusic();

    doffset = doffset * 0.9
    ioffset = ioffset * 0.9
    passwordErrorOffset = passwordErrorOffset * 0.9
    timer = (timer + deltaTime)
    timer = timer % 2

    hovered = nil;

    gfx.LoadSkinFont(normal_font);

    do_sounds(deltaTime);
    -- Room Listing View
    if screenState == "inRoom" then
        render_lobby(deltaTime);
    elseif screenState == "roomList" then
        render_room_list(deltaTime);
        drawHeader()
    elseif screenState == "passwordScreen" then
        Background.draw(deltaTime)
        render_password_screen(deltaTime);
        drawHeader()
    elseif screenState == "newRoomName" then
        Background.draw(deltaTime)
        render_new_room_name()
        drawHeader()
    elseif screenState == "newRoomPassword" then
        Background.draw(deltaTime)
        render_new_room_password()
        drawHeader()
    elseif screenState == "setUsername" then
        Background.draw(deltaTime)
        loading = false;
        render_set_username()
        drawHeader()
    end
    render_loading();
    render_info();
    
end

-- Ready up to play
function ready_up()
    Tcp.SendLine(json.encode({ topic = "user.ready.toggle" }))
end

-- Toggle hard gauage
function toggle_hard()
    Tcp.SendLine(json.encode({ topic = "user.hard.toggle" }))
end

-- Toggle hard gauage
function toggle_mirror()
    Tcp.SendLine(json.encode({ topic = "user.mirror.toggle" }))
end

function new_room()
    host = user_id
    owner = user_id
    mpScreen.NewRoomStep()
end

-- Toggle host rotation
function toggle_rotate()
    Tcp.SendLine(json.encode({ topic = "room.option.rotation.toggle" }))
end

-- Change lobby host
function change_host(user)
    Tcp.SendLine(json.encode({ topic = "room.host.set", host = user.id }))
end

-- Kick user
function kick_user(user)
    Tcp.SendLine(json.encode({ topic = "room.kick", id = user.id }))
end

-- Tell the server to start the game
function start_game()
    selected_song.self_picked = false
    if (selected_song == nil) then
        return
    end
    if (start_game_soon) then
        return
    end

    Tcp.SendLine(json.encode({ topic = "room.game.start" }))
end

-- Join a given room
function join_room(room)
    host = user_id
    selected_room = room;
    if room.password then
        mpScreen.JoinWithPassword(room.id)
    else
        mpScreen.JoinWithoutPassword(room.id)
    end
end

-- Handle button presses to advance the UI
button_pressed = function(button)

    if button == game.BUTTON_STA then
        if start_game_soon then
            return
        end
        if screenState == "roomList" then
            if #rooms == 0 then
                new_room()
            else
                -- TODO navigate room selection
                join_room(rooms[selected_room_index])
            end
        elseif screenState == "inRoom" then
            if host == user_id then
                if selected_song and selected_song.self_picked then
                    if all_ready then
                        start_game()
                    else
                        missing_song = false
                        mpScreen.SelectSong()
                    end
                else
                    missing_song = false
                    mpScreen.SelectSong()
                end
            else
                ready_up()
            end
        end
    end

    if button == game.BUTTON_BTA then
        toggle_hard();
    end
    if button == game.BUTTON_BTB then
        toggle_mirror();
    end
    if button == game.BUTTON_BTC then
        toggle_rotate();
    end
    if button == game.BUTTON_BTD then
        new_room()
        for i, user in ipairs(lobby_users) do
            if lobby_users[i] == user then
                kick_user(user);
            end
        end
    end
end

-- Handle the escape key around the UI
function key_pressed(key)
    if key == 27 then --escape pressed
        if screenState == "roomList" then
            did_exit = true;
            mpScreen.Exit();
            return
        end

        -- Reset room data
        screenState = "roomList" -- have to update here
        selected_room = nil;
        rooms = {};
        selected_song = nil
        selected_song_index = 1;
        jacket = 0;
    end

end

-- Handle mouse clicks in the UI
mouse_pressed = function(button)
    if hovered then
        hovered()
    end
    return 0
end

function init_tcp()
    Tcp.SetTopicHandler("server.info", function(data)
        loading = false
        user_id = data.userid
    end)
    -- Update the list of rooms as well as get user_id for the client
    Tcp.SetTopicHandler("server.rooms", function(data)

        rooms = {}
        for i, room in ipairs(data.rooms) do
            table.insert(rooms, room)
        end
    end)

    Tcp.SetTopicHandler("server.room.joined", function(data)
        selected_room = data.room
    end)

    local sound_time = 0;
    local sound_clip = nil;
    local sounds_left = 0;
    local sound_interval = 0;

    function repeat_sound(clip, times, interval)
        sound_clip = clip;
        sound_time = 0;
        sounds_left = times - 1;
        sound_interval = interval;
        game.PlaySample(clip)
    end

    function do_sounds(deltaTime)
        if sound_clip == nil then
            return
        end

        sound_time = sound_time + deltaTime;
        if sound_time > sound_interval then
            sound_time = sound_time - sound_interval;
            game.PlaySample(sound_clip);
            sounds_left = sounds_left - 1
            if sounds_left <= 0 then
                sound_clip = nil
            end
        end
    end

    local last_song = nil

    -- Update the current lobby
    Tcp.SetTopicHandler("room.update", function(data)
        -- Update the users in the lobby
        lobby_users = {}
        local prev_all_ready = all_ready;
        all_ready = true
        for i, user in ipairs(data.users) do
            table.insert(lobby_users, user)
            if user.id == user_id then
                user_ready = user.ready
            end
            if not user.ready then
                all_ready = false
            end
        end

        if user_id == host and #data.users > 1 and all_ready and not prev_all_ready then
            repeat_sound("click-02", 3, .1)
        end

        if data.host == user_id and host ~= user_id then
            repeat_sound("click-02", 3, .1)
        end

        if data.song ~= nil and last_song ~= data.song then
            game.PlaySample("menu_click")
            last_song = data.song
        end
        host = data.host
        if data.owner then
            owner = data.owner
        else
            owner = host
        end
        hard_mode = data.hard_mode
        mirror_mode = data.mirror_mode
        do_rotate = data.do_rotate
        if data.start_soon and not start_game_soon then
            repeat_sound("click-01", 5, 1)
        end
        start_game_soon = data.start_soon

    end)
end
