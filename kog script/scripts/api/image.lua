
require "common.class"

require "api.graphics"

---@class ImageParams
---@field width number
---@field height number
---@field x number?
---@field y number?
---@field scaleX number?
---@field scaleY number?
---@field centered boolean?
---@field blendOp integer?
---@field color number[]?
---@field alpha number?
---@field stroke StrokeParams?

---@class Image
---@field handle integer
---@field width number
---@field height number
---@field x number?
---@field y number?
---@field scaleX number?
---@field scaleY number?
---@field centered boolean?
---@field blendOp integer?
---@field color number[]?
---@field alpha number?
---@field stroke StrokeParams?
local Image = { };

---Image constructor
---@param imagePath string # The path to the skin image to load
---@return Image
function Image.new(imagePath, noFallback)
    local handle = gfx.CreateSkinImage(imagePath or '', 0);
    if (not handle) then
        game.Log('Failed to load image "' .. imagePath .. '"', game.LOGGER_ERROR);

        if (noFallback) then return nil; end

        handle = gfx.CreateSkinImage('missing.png', 0);
        if (not handle) then
            game.Log('Failed to load fallback image "missing.png"', game.LOGGER_ERROR);
        end
    end

    local width, height = 64, 64;
    if (handle) then
        width, height = gfx.ImageSize(handle);
    end

    local instance = {
        handle = handle,
        width = width,
        height = height,
    };

    return CreateInstance(Image, instance);
end

---Set the width and height of this Image.
---@param width number
---@param height number
---@return Image # Returns self for method chaining
function Image:setSize(width, height)
    if (type(width)  ~= "number") then width  = 0; end
    if (type(height) ~= "number") then height = 0; end

    self.width = width;
    self.height = height;

    return self;
end

---Set the stored position for this Image.
---If the position of this Image will not change frequently,
---using this method allows you to cache the render position
---instead of passing it to the render method on each invocation.
---@param x number
---@param y number
---@return Image # Returns self for method chaining
function Image:setPosition(x, y)
    if (type(x) ~= "number") then x = 0; end
    if (type(y) ~= "number") then y = 0; end

    self.x = x;
    self.y = y;

    return self;
end

---Renders this Image, applying any of the given ImageParams,
---then any of the cached Image fields, then any default values.
---@param params? ImageParams
function Image:render(params)
    params = params or { };

    local sx = params.scaleX or self.scaleX or 1;
    local sy = params.scaleY or self.scaleY or 1;

    local x = params.x or self.x or 0;
    local y = params.y or self.y or 0;

    local w = (params.width  or self.width ) * sx;
    local h = (params.height or self.height) * sy;

    if (params.centered or self.centered) then
        x = x - w / 2;
        y = y - h / 2;
    end

    local blendOp = params.blendOp or self.blendOp or gfx.BLEND_OP_SOURCE_OVER;

    local r = 255;
    local g = 255;
    local b = 255;

    if (params.color) then
        r = params.color[1];
        g = params.color[2];
        b = params.color[3];
    elseif (self.color) then
        r = self.color[1];
        g = self.color[2];
        b = self.color[3];
    end

    local a = params.alpha or self.alpha or 1;

    gfx.BeginPath();
    gfx.GlobalCompositeOperation(blendOp);

    if (not self.handle) then
        gfx.FillColor(r, g, b, a);
        gfx.Rect(x, y, w, h);
        gfx.FillColor(255, 255, 255, 255);
    else
        gfx.SetImageTint(r, g, b);
        gfx.ImageRect(x, y, w, h, self.handle, a, 0);
        gfx.SetImageTint(255, 255, 255);
    end

    if (params.stroke or self.stroke) then
        r = 255;
        g = 255;
        b = 255;

        if (params.stroke.color) then
            r = params.stroke.color[1];
            g = params.stroke.color[2];
            b = params.stroke.color[3];
        elseif (self.stroke and self.stroke.color) then
            r = self.stroke.color[1];
            g = self.stroke.color[2];
            b = self.stroke.color[3];
        end

        a = params.stroke.alpha or (self.stroke and self.stroke.alpha) or 255;

        local size = params.stroke.size or (self.stroke and self.stroke.size) or 1;

        gfx.StrokeColor(r, g, b, a);
        gfx.StrokeWidth(size);
        gfx.Stroke();
    end
end

return Image;
