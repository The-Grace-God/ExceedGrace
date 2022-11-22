local dimtable = {
    design = {width = 1080, height = 1920},
    screen = {width = nil, height = nil},
    view = {width = nil, height = nil},
    ratio = {landscapeUW = 21 / 9, landscapeWide = 16 / 9, landscapeStd = 4 / 3, portrait = 9 / 16},
}

dimtable.transformToScreenSpace = function()
    gfx.Translate((dimtable.screen.width - dimtable.view.width) / 2, 0);
    gfx.Scale(dimtable.view.width / dimtable.design.width, dimtable.view.height / dimtable.design.height);
    gfx.Scissor(0, 0, dimtable.design.width, dimtable.design.height);
end

dimtable.updateResolution = function(ratio)
    if not ratio then ratio = dimtable.ratio.portrait end

    local screenWidth, screenHeight = game.GetResolution()
    if screenWidth ~= dimtable.screen.width or screenHeight ~= dimtable.screen.height then
        dimtable.screen.width, dimtable.screen.height = screenWidth, screenHeight
        dimtable.view.width, dimtable.view.height = ratio * dimtable.screen.height, dimtable.screen.height
    end
end

---Convert screenspace coordinates to viewspace coordinates
---@param screenX number
---@param screenY number
---@param offsetX? number Viewport offset from the left side (defaults to the portrait viewport offset)
---@param offsetY? number Viewport offset from the top side (defaults to 0)
---@return number, number
dimtable.toViewSpace = function(screenX, screenY, offsetX, offsetY)
    offsetX = offsetX or (dimtable.screen.width - dimtable.view.width) / 2
    offsetY = offsetY or 0

    local viewX, viewY, scaleX, scaleY

    scaleX = dimtable.design.width / dimtable.view.width
    scaleY = dimtable.design.height / dimtable.view.height

    viewX = (screenX - offsetX) * scaleX
    viewY = (screenY - offsetY) * scaleY

    return viewX, viewY
end

---Set's up scaled transforms based on the current resolution.
---@param x number
---@param y number
---@param rotation number
---@return number, boolean # The scale applied to the transform and the current landscape state
function dimtable.setUpTransforms(x, y, rotation)
    local scale = dimtable.screen.width / dimtable.view.width;
    local isLandscape = dimtable.view.width > dimtable.view.height;

    gfx.ResetTransform();
    gfx.Translate(x, y);
    gfx.Rotate(rotation);
    gfx.Scale(scale, scale);

    return scale, isLandscape;
end

return dimtable
