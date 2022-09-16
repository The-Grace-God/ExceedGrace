local vfBrackets = { 0, 10, 12, 14, 15, 16, 17, 18, 19, 20, 24 }

local star_type = 1

if not volforceAmount then
  volforceAmount = -1
end

local function handleForce(vf)
  volforceAmount = vf
  for i = 1, 10 do
    local top = vfBrackets[i + 1]
    local down = vfBrackets[i]
    if vf < top or i == 10 then
      volforce_number = i
      local range = top - down
      for b = 1, 4 do
        if vf < (down + b * 0.25 * range) or b == 4 then
          stars_count = b
          break
        end
      end
      break
    end
    if i < 7 then
      star_type = 2
    else
      star_type = 1
    end
  end
end

handleForce(volforceAmount)

volforceBadgeImage = gfx.CreateSkinImage("volforce/" .. volforce_number .. ".png", 1)
vfStar = gfx.CreateSkinImage("volforce/stars/" .. star_type .. ".png", 1)

function render(deltatime, x, y, size, amount, only_txt, only_img, with_stars)

  volforceAmount = amount

  gfx.LoadSkinFont('Digital-Serial-Bold.ttf')
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
  -- Draw volforce badge
  if only_img then
    gfx.BeginPath();
    gfx.ImageRect(x - 8, y - 16, size * 1.5, size * 1.5, volforceBadgeImage, 1, 0);
  end
  if with_stars then
    for i = 1, stars_count do
      divider = 0
      if stars_count == 1 then
        divider = 18
        gfx.BeginPath();
        gfx.ImageRect(x + divider + (i - 1) * divider, y + 32.5, size / 4, size / 4, vfStar, 1, 0);
      elseif stars_count == 2 then
        divider = 13
        gfx.BeginPath();
        gfx.ImageRect(x + divider + (i - 1) * (divider - 2), y + 32.5, size / 4, size / 4, vfStar, 1, 0);
      elseif stars_count == 3 then
        divider = 8.25
        gfx.BeginPath();
        gfx.ImageRect(x + divider + (i - 1) * (divider + 2), y + 32.5, size / 4, size / 4, vfStar, 1, 0);
      elseif stars_count == 4 then
        divider = 5
        gfx.BeginPath();
        gfx.ImageRect(x + (divider - 1) + (i - 1) * (divider + 5), y + 32.5, size / 4, size / 4, vfStar, 1, 0);
      end
    end
  end
  if only_txt then
    -- Draw volforce label
    gfx.FontSize(11)
    gfx.Text('VOLFORCE', x + 47, y + 14);
    gfx.FontSize(18)
    if amount == nil then
      gfx.Text("0.000", x + 47, y + 30)
    else
      gfx.Text(string.format('%.3f', amount), x + 47, y + 30);
    end
  end
end

return {
  render = render
}