gfx.LoadSkinFont("segoeui.ttf")

-- Memo class
-------------
Memo = {}
Memo.new = function()
  local this = {
    cache = {}
  }
  setmetatable(this, {__index = Memo})
  return this
end

Memo.memoize = function(this, key, generator)
  local value = this.cache[key]
  if not value then
    value = generator()
    this.cache[key] = value
  end
  return value
end


-- Image class
--------------
Image = {
  ANCHOR_LEFT = 1,
  ANCHOR_CENTER = 2,
  ANCHOR_RIGHT = 4,
  ANCHOR_TOP = 8,
  ANCHOR_BOTTOM = 16
}
Image.skin = function(filename, imageFlags)
  imageFlags = imageFlags or 0
  local image = gfx.CreateSkinImage(filename, imageFlags)
  return Image.wrap(image)
end
Image.wrap = function(image)
  local this = {
    image = image
  }
  local w, h = gfx.ImageSize(this.image)
  this.w = w
  this.h = h
  setmetatable(this, {__index = Image})
  return this
end

Image.draw = function(this, params)
  local x = params.x
  local y = params.y
  local w = params.w or this.w
  local h = params.h or this.h
  local alpha = params.alpha or 1
  local angle = params.angle or 0
  local anchor_h = params.anchor_h or Image.ANCHOR_CENTER
  local anchor_v = params.anchor_v or Image.ANCHOR_CENTER
  local scale = params.scale or 1;
  
  w = w * scale;
  h = h * scale;

  if anchor_h == Image.ANCHOR_CENTER then
    x = x - w / 2
  elseif anchor_h == Image.ANCHOR_RIGHT then
    x = x - w
  end

  if anchor_v == Image.ANCHOR_CENTER then
    y = y - h / 2
  elseif anchor_v == Image.ANCHOR_BOTTOM then
    y = y - h
  end

  gfx.BeginPath()
  gfx.ImageRect(x, y, w, h, this.image, alpha, angle)
end


-- ImageFont class
------------------
ImageFont = {}
ImageFont.new = function(path, chars)
  local this = {
    images = {}
  }
  -- load character images
  for i = 1, chars:len() do
    local c = chars:sub(i, i)
    local n = c
    if c == "." then
        n = "dot"
    end
    local image = Image.skin(string.format("%s/%s.png", path, n), 0)
    this.images[c] = image
  end
  -- use size of first char as font size
  local w, h = gfx.ImageSize(this.images[chars:sub(1, 1)].image)
  this.w = w
  this.h = h

  setmetatable(this, {__index = ImageFont})
  return this
end
ImageFont.draw = function(this, text, x, y, alpha, hFlag, vFlag)
  local totalW = text:len() * this.w

  -- adjust horizontal alignment
  if hFlag == gfx.TEXT_ALIGN_CENTER then
    x = x - totalW / 2
  elseif hFlag == gfx.TEXT_ALIGN_RIGHT then
    x = x - totalW
  end

  -- adjust vertical alignment
  if vFlag == gfx.TEXT_ALIGN_MIDDLE then
    y = y - this.h / 2
  elseif vFlag == gfx.TEXT_ALIGN_BOTTOM then
    y = y - this.h
  end

  for i = 1, text:len() do
    local c = text:sub(i, i)
    local image = this.images[c]
    if image ~= nil then
      gfx.BeginPath()
      gfx.ImageRect(x, y, this.w, this.h, image.image, alpha, 0)
    end
    x = x + this.w
  end
end

function GetDisplayDifficulty(jacketPath, difficulty)
  local strippedPath = string.match(jacketPath:lower(), "[/\\][^\\/]+$")
  if difficulty == 3 and strippedPath then
        if string.find(strippedPath, "inf") ~= nil then
            return 5
    elseif string.find(strippedPath, "grv") ~= nil then
            return 6
    elseif string.find(strippedPath, "hvn") ~= nil then
            return 7
    elseif string.find(strippedPath, "vvd") ~= nil  then
            return 8
        end
  end

  return difficulty+1
end

function split(s, delimiter)
  result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(result, match);
  end
  return result;
end