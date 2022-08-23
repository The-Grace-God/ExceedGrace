
local bannerBaseImage = gfx.CreateSkinImage("gameplay/banner/base.png", 0)

local desw = 1080
local desh = 1920

local BANNER_W = 1080;
local BANNER_H = 368;

local drawScoreboard = function (users, currentUserId)
    if (users == nil) then
        return
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FontSize(32)

    local x = 16;
    local basey = 510;

    gfx.LoadSkinFont("Digital-Serial-Bold.ttf")

    for i, u in ipairs(users) do
        local y = basey + i*28;

        if (u.id == currentUserId) then
            gfx.FillColor(128,192,255);
        else
            gfx.FillColor(255,255,255);
        end


        gfx.FontSize(26)
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
        gfx.Text(string.format("%04d", math.floor(u.score/10000)), x, y)

        local lastFourDigits = ((u.score / 10000) - math.floor(u.score / 10000))*10000
        gfx.FontSize(22)
        gfx.Text(string.format("%04d", math.floor(lastFourDigits)), x+58, y+1)

        gfx.FontSize(26)
        gfx.Text('#' .. i .. ' ' .. u.name, x+120, y)
    end
end

local render = function (deltaTime, users, currentUserId)
    local resx, resy = game.GetResolution();

    local scale = resx / desw
    gfx.Scale(scale, scale)

    drawScoreboard(users, currentUserId); -- TODO: for now

    -- hide if landscape
    if (resx > resy) then
        return
    end

    -- Get the banner downscaled in whatever resolution it is, while maintaining the aspect ratio
    local tw,th = gfx.ImageSize(bannerBaseImage);
    BANNER_H = th * (1080/tw);

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

    gfx.ResetTransform()

end

return {
    render=render
}