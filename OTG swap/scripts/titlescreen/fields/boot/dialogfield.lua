require("common.class")
local ContainerField = require("components.pager.containerfield")

---@class DialogField: ContainerField
---@field _symbolMargin number
---@field _symbolSize number
local DialogField = {
    __tostring = function() return "ContainerField" end,
    BGCOLOR = {0, 0, 0, 255}, --{r, g, b, a}
    DEFAULT_WIDTH = 400,
    DEFAULT_HEIGHT = 200,
    FONT_SIZE = 16,
    FONT_FACE = "dfmarugoth.ttf",
    FONT_COLOR = {255, 255, 255, 255},
    BORDERCOLOR = {255, 255, 255, 255},
    BORDERRADII = 12,
    BORDERWIDTH = 2,
    HEADER = {
        title = "Title",
        code = "0-0000-0000"
    },
    TEXT = {
        "Top text,",
        "Sample text,",
        "Bottom text."
    },
    LEGEND = {
        {
            label = "BUTTON",
            text = "DESCRIPTION"
        },
    },
}

---Create a new DialogField instance
---
---Inherits from ContainerField
---@param o ContainerField
---@return DialogField
function DialogField.new(o)
    o = o or {}

    o.aabbW = o.aabbW or DialogField.DEFAULT_WIDTH
    o.aabbH = o.aabbH or DialogField.DEFAULT_HEIGHT

    local this = CreateInstance(DialogField, o, ContainerField)

    this._symbolMargin = 8
    this._symbolSize = 48

    return this
end

---Draw the dialog symbol
---
---Default implementation is a yellow triangle with an exclamation mark
---@param deltaTime number # frametime in seconds
function DialogField:drawSymbol(deltaTime)
    local symbolColor = {255, 255, 0, 255}
    gfx.Save()
    gfx.Translate(self._symbolMargin, self._symbolMargin)
    gfx.FillColor(table.unpack(symbolColor))
    gfx.BeginPath()
    local symbolBottomY = math.sqrt(3) / 2 * self._symbolSize
    gfx.MoveTo(0, symbolBottomY)
    gfx.LineTo(self._symbolSize / 2, 0)
    gfx.LineTo(self._symbolSize, symbolBottomY)
    gfx.Fill()
    -- exclamation mark
    local excTopMargin = 10
    local excBottomMargin = 4
    local excThickness = 5
    local excColor = {0, 0, 0, 255}
    gfx.FillColor(table.unpack(excColor))
    gfx.BeginPath()
    gfx.Rect(
        self._symbolSize / 2 - excThickness / 2, -- x
        excTopMargin, -- y
        excThickness, -- w
        symbolBottomY - excTopMargin - excBottomMargin - 3 / 2 * excThickness -- h
    )
    gfx.Rect(
        self._symbolSize / 2 - excThickness / 2, -- x
        symbolBottomY - excBottomMargin - excThickness, -- y
        excThickness, excThickness -- w, h
    )
    gfx.Fill()
    gfx.Restore()
end

---@param deltaTime number # frametime in seconds
function DialogField:drawBackground(deltaTime)
    local textMargin = 4
    -- border
    local borderH = self.aabbH - #self.LEGEND * self.FONT_SIZE - textMargin
    gfx.BeginPath()
    gfx.StrokeColor(table.unpack(self.BORDERCOLOR))
    gfx.StrokeWidth(self.BORDERWIDTH)
    gfx.FillColor(table.unpack(self.BGCOLOR))
    gfx.RoundedRect(0, 0, self.aabbW, borderH, self.BORDERRADII)
    gfx.Fill()
    gfx.Stroke()

    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)

    -- draw symbol
    self:drawSymbol(deltaTime)

    -- legend
    local legendX = 0
    local legendY = borderH + textMargin
    gfx.TextAlign(gfx.TEXT_ALIGN_TOP | gfx.TEXT_ALIGN_LEFT)
    gfx.FillColor(table.unpack(self.FONT_COLOR))
    for _, legend in ipairs(self.LEGEND) do
        gfx.Text(legend.label .. " = " .. legend.text, legendX, legendY)
        legendY = legendY + self.FONT_SIZE
    end

    -- header
    local headerX = self._symbolSize + self._symbolMargin + 16
    local headerY = self._symbolMargin
    gfx.Save()
    gfx.Translate(headerX, headerY)
    gfx.Text(self.HEADER.title, 0, 0)
    local separatorY = self.FONT_SIZE + textMargin
    local separatorThickness = 1
    gfx.StrokeWidth(separatorThickness)
    gfx.BeginPath()
    gfx.MoveTo(0, separatorY)
    gfx.LineTo(self.aabbW - headerX - self._symbolMargin, separatorY)
    gfx.Stroke()
    local codeY = separatorY + textMargin
    gfx.Text(self.HEADER.code, 0, codeY)
    gfx.Restore()
end

---@param deltaTime number # frametime in seconds
function DialogField:drawForeground(deltaTime)
    local textX = 12
    local textY = 64
    local lineHeight = self.FONT_SIZE + 4
    for _, line in ipairs(self.TEXT) do
        gfx.Text(line, textX, textY)
        textY = textY + lineHeight
    end
end

return DialogField
