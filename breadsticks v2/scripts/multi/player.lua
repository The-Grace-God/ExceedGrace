--because we cant ask the server for these we gotta doit some other way (ourself)

local volforceWindow = require("components.volforceWindow")
local DiffRectangle = require('components.diff_rectangle');
local player_list = require("multi.list")
local username = game.GetSkinSetting("username");

local result_bottom = gfx.CreateSkinImage("result/multi_4p/base.png", 0)
local result_top = gfx.CreateSkinImage("result/multi_4p/top.png", 0)

local multi_bottom = gfx.CreateSkinImage("gameplay/banner/scoreboard/base.png", 0)
local multi_top = gfx.CreateSkinImage("result/banner/scoreboard/top.png", 0)

local inlobby_bottom = gfx.CreateSkinImage("multi/lobby/opponent_bottom_panel.png", 1);
local inlobby_top = gfx.CreateSkinImage("multi/lobby/opponent_top_panel.png", 1);
local ready_bt = gfx.CreateSkinImage("multi/lobby/READY.png", 1);

local pos = {
    gfx.CreateSkinImage("result/multi_4p/pos/1.png", 0),
    gfx.CreateSkinImage("result/multi_4p/pos/2.png", 0),
    gfx.CreateSkinImage("result/multi_4p/pos/3.png", 0),
    gfx.CreateSkinImage("result/multi_4p/pos/4.png", 0),
    gfx.CreateSkinImage("result/multi_4p/pos/5.png", 0),
    gfx.CreateSkinImage("result/multi_4p/pos/6.png", 0),
    gfx.CreateSkinImage("result/multi_4p/pos/7.png", 0),
    gfx.CreateSkinImage("result/multi_4p/pos/8.png", 0),
}


local result_playercheck = function(placement, ir_text, badgeImages, adjustedDiff)

    local spacing = placement.place

    local offset = 0

    offset = spacing * offset

    if placement.name == result.isSelf then
        offset = 0
    else
        offset = 0
    end

    if player_list[placement.name].name == placement.name then
        name_string      = player_list[placement.name].name
        msg_string       = player_list[placement.name].msg
        force_string     = player_list[placement.name].vf
        force_img_string = player_list[placement.name].vf_image
        star_type        = player_list[placement.name].star_type
        star_count       = player_list[placement.name].star_count
        img_string       = player_list[placement.name].portrait
        badge_string     = player_list[placement.name].badge
        appeal_string    = player_list[placement.name].appeal
    elseif player_list.Player.name ~= placement.name then
        name_string      = player_list.Player.name .. (spacing)
        msg_string       = player_list.Player.msg
        force_string     = player_list.Player.vf
        force_img_string = player_list.Player.vf_image
        star_type        = player_list.Player.star_type
        star_count       = player_list.Player.star_count
        img_string       = player_list.Player.portrait
        badge_string     = player_list.Player.badge
        appeal_string    = player_list.Player.appeal
    end

    if result.badge == 0 then
        badgeImage = badgeImages[1]
    elseif result.badge == 1 then
        badgeImage = badgeImages[2]
    elseif result.badge == 2 then
        badgeImage = badgeImages[3]
    elseif result.badge == 3 then
        badgeImage = badgeImages[4]
    elseif result.badge == 4 then
        badgeImage = badgeImages[5]
    elseif result.badge == 5 then
        badgeImage = badgeImages[6]
    end

    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.FontSize(26)
    local position_bottom_w, position_bottom_h = gfx.ImageSize(result_bottom)
    local position_top_w, position_top_h = gfx.ImageSize(result_top)
    local position_place_w, position_place_h = gfx.ImageSize(pos[spacing])
    local number_y = -position_top_h + 35;
    local mult_y = 16;
    local mult_x = 0;
    local half = 1.1

    -- Get Bottom Layer Image for Multi Result
    gfx.BeginPath()
    gfx.ImageRect(mult_x + offset, mult_y, position_bottom_w / half, position_bottom_h / half, result_bottom, 1, 0)

    -- Get Player Portrait
    gfx.BeginPath();
    gfx.ImageRect(mult_x + offset, mult_y + 12, position_bottom_w / 1.125, position_bottom_h / 1.35, img_string, 1, 0);

    -- Get Top Layer Image for Multi Result
    gfx.BeginPath()
    gfx.ImageRect(mult_x + offset, mult_y, position_top_w / half, position_top_h / half, result_top, 1, 0)

    -- Get AppealCard
    gfx.BeginPath();
    gfx.ImageRect(mult_x + offset + 24.5, mult_y + 80, 103 / 1.17, 132 / 1.17, appeal_string, 1, 0);

    -- Get Dan Badge
    gfx.BeginPath();
    gfx.ImageRect(mult_x + offset + 135, mult_y + 165, 107 / 1.17, 29 / 1.17, badge_string, 1, 0);

    -- Get Clear Badge you got
    gfx.BeginPath()
    gfx.ImageRect(mult_x + offset + 332.5, mult_y + 240, 79 / half / 1.5, 69 / half / 1.5, badgeImage, 1, 0)

    -- 1st,2nd,3rd... Placements
    gfx.BeginPath()
    gfx.ImageRect(mult_x + offset + 272, mult_y + 80, position_place_w / 1.18, position_place_h, pos[spacing], 1, 0)

    -- Get The Name
    gfx.BeginPath()
    gfx.Text(string.upper(name_string), mult_x + offset + 75, mult_y + 248)

    -- Get The Message
    gfx.FontSize(24)
    gfx.BeginPath()
    gfx.Text(string.upper(msg_string), mult_x + offset + 75, mult_y + 220)

    -- Volforce
    volforceWindow.render(0, mult_x + offset + 250, mult_y + 155, 42, force_string, true, false, false)

    -- Get Custom Volbadge
    gfx.BeginPath()
    gfx.ImageRect(mult_x + offset + 244.5, mult_y + 145, 42 * 1.4, 42 * 1.4, force_img_string, 1, 0)
    -- and stars
    vf_star = gfx.CreateSkinImage("volforce/stars/" .. star_type .. ".png", 1)
    for i = 1, star_count do
        divider = 0
        if star_count == 1 then
            divider = 18
            gfx.BeginPath();
            gfx.ImageRect(mult_x + offset + 250.5 + divider + (i - 1) * divider, mult_y + 190, 42 / 4, 42 / 4, vf_star, 1
                , 0);
        elseif star_count == 2 then
            divider = 13
            gfx.BeginPath();
            gfx.ImageRect(mult_x + offset + 250 + divider + (i - 1) * (divider - 2), mult_y + 190, 42 / 4, 42 / 4,
                vf_star, 1, 0);
        elseif star_count == 3 then
            divider = 8.25
            gfx.BeginPath();
            gfx.ImageRect(mult_x + offset + 250 + divider + (i - 1) * (divider + 2), mult_y + 190, 42 / 4, 42 / 4,
                vf_star, 1, 0);
        elseif star_count == 4 then
            divider = 5
            gfx.BeginPath();
            gfx.ImageRect(mult_x + offset + 250 + (divider - 1) + (i - 1) * (divider + 5), mult_y + 190, 42 / 4, 42 / 4,
                vf_star, 1, 0);
        end
    end

    -- Getting Difficulty Box, IR and Score
    DiffRectangle.render(deltaTime, mult_x + offset + 20, mult_y - number_y - 43.5, 0.84 / 1.3, adjustedDiff,
        placement.level);

    gfx.Text(ir_text, mult_x + offset + 15, mult_y + 294);
    gfx.FontSize(24)
    gfx.Text(string.format("%04d", math.floor(placement.score / 10000)), mult_x + offset + 221, mult_y + 289)
    local lastFourDigits = ((placement.score / 10000) - math.floor(placement.score / 10000)) * 10000
    gfx.Text(string.format("%04d", math.floor(lastFourDigits)), mult_x + offset + 273, mult_y + 289)

end

local multi_playercheck = function(user_info, user_id, adjustedDiff, level)

    if (user_info.id == user_id) then
        go_away = -500
    else
        go_away = 0
    end

    go_away = (go_away + user_info.place)

    if player_list[user_info.name].name == user_info.name then
        name_string      = player_list[user_info.name].name
        msg_string       = player_list[user_info.name].msg
        force_string     = player_list[user_info.name].vf
        force_img_string = player_list[user_info.name].vf_image
        star_type        = player_list[user_info.name].star_type
        star_count       = player_list[user_info.name].star_count
        img_string       = player_list[user_info.name].portrait
        badge_string     = player_list[user_info.name].badge
        appeal_string    = player_list[user_info.name].appeal
    elseif player_list.Player.name ~= user_info.name then
        name_string      = player_list.Player.name .. (user_info.place)
        msg_string       = player_list.Player.msg
        force_string     = player_list.Player.vf
        force_img_string = player_list.Player.vf_image
        star_type        = player_list.Player.star_type
        star_count       = player_list.Player.star_count
        img_string       = player_list.Player.portrait
        badge_string     = player_list.Player.badge
        appeal_string    = player_list.Player.appeal
    end

    local posUPWidth, posUPHeight = gfx.ImageSize(multi_bottom)
    numberx = posUPWidth;
    number_y = -posUPHeight + 35;

    local offset_y = 2;
    local base_x = 19;
    local offset_x = base_x + user_info.place * 2;

    local number_pos_x = 185

    -- Get Bottom Layer Image for Multi Mode
    gfx.BeginPath()
    gfx.ImageRect(offset_x + go_away, offset_y, posUPWidth, posUPHeight, multi_bottom, 1, 0)

    -- Get Player Portrait
    gfx.BeginPath();
    gfx.ImageRect(offset_x - 5 + go_away, offset_y, posUPWidth, posUPWidth / 1.825, img_string, 1, 0);

    -- Get Top Layer Image for Multi Mode
    --            local posDWWidth, posDWHeight = gfx.ImageSize(UsTop)
    --            gfx.BeginPath()
    --            gfx.ImageRect(offset_x +go_away, offset_y,posDWWidth/1.75,posDWHeight/1.75,UsTop,1,0)

    -- Get AppealCard
    gfx.BeginPath();
    gfx.ImageRect(offset_x + 20 + go_away, offset_y + 32, 103 / 1.17, 132 / 1.17, appeal_string, 1, 0);

    -- Get Dan Badge
    gfx.BeginPath();
    gfx.ImageRect(offset_x + 132 + go_away, offset_y + 118, 107 / 1.17, 29 / 1.17, badge_string, 1, 0);

    -- 1st,2nd,3rd... Placements
    local posWidth, posHeight = gfx.ImageSize(pos[user_info.place])
    gfx.BeginPath()
    gfx.ImageRect(offset_x + 220 + go_away, offset_y + 40, posWidth / 1.17, posHeight / 1.17, pos[user_info.place], 1, 0)

    -- Get The Name
    gfx.BeginPath()
    gfx.FontSize(26)
    gfx.Text(string.upper(name_string), offset_x + 52 + go_away, offset_y + 173)

    -- Volforce
    volforceWindow.render(0, offset_x + 230 + go_away, offset_y + 108, 42, force_string, true, true, true)

    -- Getting Difficulty Box and Score
    DiffRectangle.render(deltaTime, offset_x + 75 + go_away, offset_y - number_y - 24.5, 0.84 / 1.05, adjustedDiff, level);

    gfx.FontSize(26);
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FillColor(100, 100, 100)
    gfx.Text("00000000", offset_x + number_pos_x + go_away, offset_y - number_y - 11);
    gfx.FillColor(255, 255, 255)
    gfx.Text(string.format("%04d", math.floor(user_info.score / 10000)), offset_x + number_pos_x + go_away,
        offset_y - number_y - 11);

    local lastFourDigits = ((user_info.score / 10000) - math.floor(user_info.score / 10000)) * 10000
    gfx.Text(string.format("%04d", math.floor(lastFourDigits)), offset_x + number_pos_x + 56 + go_away,
        offset_y - number_y - 11);
end

local in_lobbycheck = function(player_states, user_id, ir_text, position,user_ready)

    if (player_states.id == user_id) then

        distance = 16
        -- return

    elseif position == 2 then

        distance = 16

    elseif position == 3 then

        distance = 350

    end

    if player_states.id == host then
        thing = ' (host)'
    elseif player_states.no_map then
        thing = ' (NO CHART)'
    end

    if start_game_soon then
        thing = "Game starting..."
    else
        if host == user_id then
            if selected_song == nil or not selected_song.self_picked then
                thing = "Select song"
                    missing_song = false
                    mpScreen.SelectSong()
            elseif player_states.ready and player_states.start then
                thing = "Start game"
            elseif player_states.ready and not player_states.start then
                thing = "Waiting for others"
                    missing_song = false
                    mpScreen.SelectSong()
            else
                thing = "Ready"
            end
        elseif player_states.host == nil then
            thing = "Waiting for game to end"
        elseif player_states.no_map then
            thing = "Missing Song!"
        elseif selected_song ~= nil then
            if player_states.ready then
                thing = " (Ready)"
            else
                thing = " (Cancel)"
            end
        else
            thing = "Waiting for host"
        end
    end

    gfx.Text(thing,100,100)

    if player_list[player_states.name].name == player_states.name then
        name_string      = string.upper(player_list[player_states.name].name) .. thing
        msg_string       = string.upper(player_list[player_states.name].msg)
        force_string     = player_list[player_states.name].vf
        force_img_string = player_list[player_states.name].vf_image
        star_type        = player_list[player_states.name].star_type
        star_count       = player_list[player_states.name].star_count
        img_string       = player_list[player_states.name].portrait
        badge_string     = player_list[player_states.name].badge
        appeal_string    = player_list[player_states.name].appeal
    elseif player_list.Player.name ~= player_states.name then
        name_string      = string.upper(player_list.Player.name) .. (position)
        msg_string       = string.upper(player_list.Player.msg)
        force_string     = player_list.Player.vf
        force_img_string = player_list.Player.vf_image
        star_type        = player_list.Player.star_type
        star_count       = player_list.Player.star_count
        img_string       = player_list.Player.portrait
        badge_string     = player_list.Player.badge
        appeal_string    = player_list.Player.appeal
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FillColor(255, 255, 255)

    local posUPWidth, posUPHeight = gfx.ImageSize(inlobby_bottom)
    local y = 782

    gfx.FontSize(30)
    gfx.BeginPath()
    gfx.ImageRect(distance, y, posUPWidth, posUPHeight, inlobby_bottom, 1, 0)
    gfx.BeginPath()
    gfx.ImageRect(distance, y, posUPWidth, posUPHeight, inlobby_top, 1, 0)

    -- Get AppealCard
    gfx.BeginPath();
    gfx.ImageRect(distance + 42, y + 20, 103, 132, appeal_string, 1, 0);

    -- Get Dan Badge
    local badge_w, badge_h = gfx.ImageSize(badge_string)
    gfx.BeginPath();
    gfx.ImageRect(distance + 52, y + 178, badge_w * 0.15, badge_h * 0.15, badge_string, 1, 0);

    -- Volforce
    volforceWindow.render(0, distance + 215, y + 175, 42, force_string, true, false, false) -- change this later if broken

    -- Get Custom Volbadge
    gfx.BeginPath()
    gfx.ImageRect(distance + 207.5, y + 160, 42 * 1.5, 42 * 1.5, force_img_string, 1, 0)
    -- and stars
    vf_star = gfx.CreateSkinImage("volforce/stars/" .. star_type .. ".png", 1)
    for i = 1, star_count do
        divider = 0
        if star_count == 1 then
            divider = 18
            gfx.BeginPath();
            gfx.ImageRect(distance + 216 + divider + (i - 1) * divider, y + 208, 42 / 4, 42 / 4, vf_star, 1, 0);
        elseif star_count == 2 then
            divider = 13
            gfx.BeginPath();
            gfx.ImageRect(distance + 215.5 + divider + (i - 1) * (divider - 2), y + 208, 42 / 4, 42 / 4, vf_star, 1, 0);
        elseif star_count == 3 then
            divider = 8.25
            gfx.BeginPath();
            gfx.ImageRect(distance + 215.5 + divider + (i - 1) * (divider + 2), y + 208, 42 / 4, 42 / 4, vf_star, 1, 0);
        elseif star_count == 4 then
            divider = 5
            gfx.BeginPath();
            gfx.ImageRect(distance + 215.5 + (divider - 1) + (i - 1) * (divider + 5), y + 208, 42 / 4, 42 / 4, vf_star, 1
                , 0);
        end
    end

    gfx.FontSize(30)

    gfx.Text(name_string, distance + 166, y + 58)

    gfx.Text(msg_string, distance + 166, y + 29)
    gfx.FontSize(22)
    gfx.Text(ir_text, distance + 37, y + 250)



    local image_position_w, image_position_h = gfx.ImageSize(ready_bt);

    if ready_up == true then
        gfx.BeginPath();
        gfx.ImageRect(distance + 215, y + 245.5, image_position_w / 1.18, image_position_h / 1.18
            , ready_bt, 1, 0);
    elseif ready_up == false then
        gfx.BeginPath();
        gfx.ImageRect(distance + 215, y + 245.5, image_position_w / 1.18, image_position_h / 1.18
            , ready_bt, 0, 0);
    end
end

return { result_playercheck = result_playercheck,
    multi_playercheck = multi_playercheck,
    in_lobbycheck = in_lobbycheck }
