

local volforceBadgeImage = gfx.CreateSkinImage("volforce/10.png", 0);

function render(deltatime, x, y)
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)

    local volforceAmount = game.GetSkinSetting('_volforce') or 0;

    -- Draw volforce badge
    gfx.BeginPath();
    gfx.ImageRect(x, y, 42, 42, volforceBadgeImage, 1, 0);

    -- Draw volforce label
    gfx.FontSize(11)
    gfx.Text('VOLFORCE', x + 47, y + 14);
    gfx.FontSize(18)
    gfx.Text(string.format('%.3f', volforceAmount), x + 47, y + 30);
end

return {
    render = render
}