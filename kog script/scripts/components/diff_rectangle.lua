
local difficultyLabelImages = {
    gfx.CreateSkinImage("diff/1 novice.png", 0),
    gfx.CreateSkinImage("diff/2 advanced.png", 0),
    gfx.CreateSkinImage("diff/3 exhaust.png", 0),
    gfx.CreateSkinImage("diff/4 maximum.png", 0),
    gfx.CreateSkinImage("diff/5 infinite.png", 0),
    gfx.CreateSkinImage("diff/6 gravity.png", 0),
    gfx.CreateSkinImage("diff/7 heavenly.png", 0),
    gfx.CreateSkinImage("diff/8 vivid.png", 0),
    gfx.CreateSkinImage("diff/9 exceed.png", 0)
}

local difficultyLabelTexts = {
    "NOV",
    "ADV",
    "EXH",
    "MXM",
    "INF",
    "GRV",
    "HVN",
    "VVD",
    "XCD"
}

function render(deltatime, x, y, scale, diff, level)
    gfx.Save()
    gfx.Translate(x,y);
    gfx.Scale(scale,scale)

    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')

    gfx.BeginPath();
    gfx.ImageRect(0, 0, 140, 31 ,
                  difficultyLabelImages[diff] or
                      difficultyLabelImages[4], 1, 0);

                      
    gfx.FontSize(24)
    gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
    
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(level, 120, 16);
    
    gfx.FontSize(22)
    gfx.Scale(1.2,1); -- Make the diff text more W I D E
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text(difficultyLabelTexts[diff], 18, 17);



    -- -- Draw volforce badge
    -- gfx.BeginPath();
    -- gfx.ImageRect(x, y, 42, 42, volforceBadgeImage, 1, 0);

    -- -- Draw volforce label
    -- gfx.FontSize(11)
    -- gfx.Text('VOLFORCE', x + 47, y + 14);

    gfx.ResetTransform()
    gfx.Restore()
end

return {
    render = render
}