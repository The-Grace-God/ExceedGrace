require("common.class")
local ServicePage = require("titlescreen.pages.service.servicepage")
local ListField = require("titlescreen.fields.service.listfield")
local ColorGradientField = require("titlescreen.fields.service.colorgradientfield")

---@class ColorCheckPage: ServicePage
local ColorCheckPage = {
    __tostring = function() return "ColorCheckPage" end,

    PADDING = {56, 120, 0, 56}, --{left, top, right, bottom}

    GRADIENT_SPACING = 32,
    SEPARATOR_LINE_COLOR = {255, 255, 255, 255},
    SEPARATOR_LINE_WIDTH = 4,

    SEPARATOR_ARROW_SIZE = 16,
    SEPARATOR_ARROW_MARGIN = 2,
    SEPARATOR_ARROW_LINE_WIDTH = 1
}

---Create a new ColorCheckPage instance
---@param o? table # initial parameters
---@return ColorCheckPage
function ColorCheckPage.new(o)
    o = o or {}

    o.title = o.title or "COLOR CHECK"
    o.footer = o.footer or {
        "START BUTTON = EXIT",
        "BACK BUTTON = EXIT"
    }

    local this = CreateInstance(ColorCheckPage, o, ServicePage)

    local height = ColorCheckPage.GRADIENT_SPACING
    local list = ListField.new()
    list:addField(ColorGradientField.new{label = "RED", value = {255, 0, 0, 255}, aabbH = height})
    list:addField(ColorGradientField.new{label = "YELLOW", value = {255, 255, 0, 255}, aabbH = height})
    list:addField(ColorGradientField.new{label = "GREEN", value = {0, 255, 0, 255}, aabbH = height})
    list:addField(ColorGradientField.new{label = "CYAN", value = {0, 255, 255, 255}, aabbH = height})
    list:addField(ColorGradientField.new{label = "BLUE", value = {0, 0, 255, 255}, aabbH = height})
    list:addField(ColorGradientField.new{label = "MAGENTA", value = {255, 0, 255, 255}, aabbH = height})
    list:addField(ColorGradientField.new{label = "WHITE", value = {255, 255, 255, 255}, aabbH = height})
    list:refreshFields()

    this:addField(list)
    this:refreshFields()

    return this
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
function ColorCheckPage:handleButtonInput(button)
    if button == game.BUTTON_BCK or button == game.BUTTON_STA then
        if self.viewHandler then
            self.viewHandler:back()
        end
    end
end

---@param deltaTime number # frametime in seconds
function ColorCheckPage:_drawSeparator(deltaTime)
    gfx.BeginPath()
    gfx.Rect(ColorGradientField.GRADIENT_X_OFFSET, 0,
        ColorGradientField.GRADIENT_WIDTH, self.SEPARATOR_LINE_WIDTH)
    gfx.FillColor(table.unpack(self.SEPARATOR_LINE_COLOR))
    gfx.Fill()
end

---@param deltaTime number # frametime in seconds
function ColorCheckPage:_drawArrows(deltaTime)
    local stepW = ColorGradientField.GRADIENT_WIDTH / ColorGradientField.GRADIENT_STEPS
    gfx.BeginPath()
    for i = 0, 3 do
        local posX = ColorGradientField.GRADIENT_X_OFFSET + i * stepW
        gfx.MoveTo(posX + self.SEPARATOR_ARROW_MARGIN, self.SEPARATOR_ARROW_SIZE - self.SEPARATOR_ARROW_MARGIN)
        gfx.LineTo(posX + stepW / 2, self.SEPARATOR_ARROW_MARGIN)
        gfx.LineTo(posX + stepW - self.SEPARATOR_ARROW_MARGIN, self.SEPARATOR_ARROW_SIZE - self.SEPARATOR_ARROW_MARGIN)
    end
    gfx.StrokeColor(table.unpack(self.SEPARATOR_LINE_COLOR))
    gfx.StrokeWidth(self.SEPARATOR_ARROW_LINE_WIDTH)
    gfx.Stroke()
end

---@param deltaTime number # frametime in seconds
function ColorCheckPage:_drawArrowText(deltaTime)
    local stepW = ColorGradientField.GRADIENT_WIDTH / ColorGradientField.GRADIENT_STEPS
    local textCenterX = ColorGradientField.GRADIENT_X_OFFSET + 2 * stepW
    gfx.BeginPath()
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER | gfx.TEXT_ALIGN_TOP)
    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)
    gfx.FillColor(table.unpack(self.FONT_COLOR))
    gfx.Text("COLORLESS", textCenterX, 0)
end

---@param deltaTime number # frametime in seconds
function ColorCheckPage:drawBackground(deltaTime)
    ServicePage.drawBackground(self, deltaTime)
    gfx.Save()
    gfx.Translate(self.PADDING[1], self.PADDING[2])

    local list = self.content[1]
    local posX = list.posX
    local posY = list.posY + list.aabbH
    gfx.Translate(posX, posY)
    self:_drawSeparator(deltaTime)
    gfx.Translate(0, self.SEPARATOR_LINE_WIDTH)
    self:_drawArrows(deltaTime)
    gfx.Translate(0, self.SEPARATOR_ARROW_SIZE)
    self:_drawArrowText(deltaTime)

    gfx.Restore()
end

return ColorCheckPage
