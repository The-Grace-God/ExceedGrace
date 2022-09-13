local Charting = require('common.charting');
local DiffRectangle = require('components.diff_rectangle');
local playercheck = require("multi.player")
local bannerBaseImage = gfx.CreateSkinImage("gameplay/banner/base.png", 0)
local landscape_panel = gfx.CreateSkinImage("gameplay/banner/scoreboard/base.png", 0) -- change this when jake made new

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

local desw = 1080
local desh = 1920

local BANNER_W = 1080;
local BANNER_H = 368;

local draw_landscape_board = function(users, currentUserId, diff, level)
    if (users == nil) then
        return
    end

    adjustedDiff = Charting.GetDisplayDifficulty(gameplay.jacketPath, diff)

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FontSize(32)

    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")

    for i, u in ipairs(users) do
        
        if (u.id == currentUserId) then
            go_away = -500
        else
            go_away = 0
        end
    
        local x = 16;
        local basey = 510;
        local y = basey + i * 2;

        gfx.FontSize(13);
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
        gfx.Text(string.format("%04d", math.floor(u.score / 10000)), x + go_away, y);

        local lastFourDigits = ((u.score / 10000) - math.floor(u.score / 10000)) * 10000
        gfx.FontSize(11);
        gfx.Text(string.format("%04d", math.floor(lastFourDigits)), x + 58 / 2 + go_away, y + 0.5);

        gfx.FontSize(13);
        gfx.Scissor(x + 90, y - 10, 49, 20);
        gfx.Text(string.upper(u.name), x + 90 + go_away, y);
        gfx.ResetScissor();
        DiffRectangle.render(deltaTime, x + 145 + go_away, y - 7.5, 0.84 / 2, adjustedDiff, level);
        gfx.BeginPath();
        local posWidth, posHeight = gfx.ImageSize(pos[i]);
        gfx.BeginPath();
        gfx.ImageRect(x + 55 + go_away, y - 10, (posWidth / 2.5) / 2, (posHeight / 2.5) / 2, pos[i], 1, 0);
    end

end

local draw_portrait_board = function(users, currentUserId, diff, level)
    if (users == nil) then
        return
    end

    adjustedDiff = Charting.GetDisplayDifficulty(gameplay.jacketPath, diff)

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FontSize(32)

    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")

    for i, u in ipairs(users) do

        user_info = {}
        user_info.place = i
        user_info.id = u.id
        user_info.name  = u.name
        user_info.score = u.score

        playercheck.multi_playercheck(user_info, currentUserId, adjustedDiff,level)
    end
end

local render = function(deltaTime, users, currentUserId, current_dif, current_level)
    local resx, resy = game.GetResolution();

    local scale = resx / desw
    gfx.Scale(scale, scale)

    draw_landscape_board(users, currentUserId, current_dif, current_level); -- TODO: for now

    -- hide if landscape
    if (resx > resy) then
        return
    end

    -- Get the banner downscaled in whatever resolution it is, while maintaining the aspect ratio
    local tw, th = gfx.ImageSize(bannerBaseImage);
    BANNER_H = th * (1080 / tw);

    gfx.BeginPath();
    gfx.ImageRect(
        0,
        0,
        BANNER_W,
        BANNER_H,
        bannerBaseImage,
        1,
        0
    );

    draw_portrait_board(users, currentUserId, current_dif, current_level); -- TODO: for now

    gfx.ResetTransform()

end

return {
    render = render
}
