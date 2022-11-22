require("common.class")
local Dim = require("common.dimensions")
local ServicePage = require("titlescreen.pages.service.servicepage")

---@class ScreenCheckPage: ServicePage
local ScreenCheckPage = {
    __tostring = function() return "ScreenCheckPage" end,

    BG_COLOR = {255, 255, 255, 255},
    STROKE_COLOR = {255, 0, 0, 255},
    SQUARE_BG_COLOR = {128, 128, 128, 255},
    SQUARE_STROKE_COLOR = {0, 0, 0, 255},

    STROKE_WIDTH = 6,

    SQUARE_COUNT = {18, 32}
}

---Create a new ScreenCheckPage instance
---@param o? table # initial parameters
---@return ScreenCheckPage
function ScreenCheckPage.new(o)
    o = o or {}

    o.title = o.title or "SCREEN CHECK"
    o.footer = o.footer or {
        "START BUTTON = EXIT",
        "BACK BUTTON = EXIT"
    }

    return CreateInstance(ScreenCheckPage, o, ServicePage)
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
function ScreenCheckPage:handleButtonInput(button)
    if button == game.BUTTON_BCK or button == game.BUTTON_STA then
        if self.viewHandler then
            self.viewHandler:back()
        end
    end
end

---@param deltaTime number # frametime in seconds
function ScreenCheckPage:drawBackground(deltaTime)
    --background fill
    gfx.BeginPath()
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.FillColor(table.unpack(self.BG_COLOR))
    gfx.Fill()

    --draw square array
    gfx.BeginPath()
    local squareSize = Dim.design.width / self.SQUARE_COUNT[1] - 2 * self.STROKE_WIDTH
    local squareSpacing = 2 * self.STROKE_WIDTH
    for j = 0, self.SQUARE_COUNT[2] - 1 do
        local posY = self.STROKE_WIDTH + j * (squareSize + squareSpacing)
        for i = 0, self.SQUARE_COUNT[1] - 1 do
            local posX = self.STROKE_WIDTH + i * (squareSize + squareSpacing)
            gfx.Rect(posX, posY, squareSize, squareSize)
        end
    end
    gfx.FillColor(table.unpack(self.SQUARE_BG_COLOR))
    gfx.StrokeColor(table.unpack(self.SQUARE_STROKE_COLOR))
    gfx.StrokeWidth(self.STROKE_WIDTH)
    gfx.Fill()
    gfx.Stroke()

    --draw crosshairs
    gfx.BeginPath()
    --frame
    gfx.Rect(self.STROKE_WIDTH / 2, self.STROKE_WIDTH / 2,
        Dim.design.width - self.STROKE_WIDTH, Dim.design.height - self.STROKE_WIDTH)
    --center lines
    gfx.MoveTo(Dim.design.width / 2, 0)
    gfx.LineTo(Dim.design.width / 2, Dim.design.height)
    gfx.MoveTo(0, Dim.design.height / 2)
    gfx.LineTo(Dim.design.width, Dim.design.height / 2)
    --corners
    local cornerW = Dim.design.width * 4 / 18
    local cornerH = Dim.design.height * 4 / 32
    gfx.MoveTo(0, cornerH)
    gfx.LineTo(cornerW, cornerH)
    gfx.LineTo(cornerW, 0)
    gfx.MoveTo(Dim.design.width - cornerW, 0)
    gfx.LineTo(Dim.design.width - cornerW, cornerH)
    gfx.LineTo(Dim.design.width, cornerH)
    gfx.MoveTo(0, Dim.design.height - cornerH)
    gfx.LineTo(cornerW, Dim.design.height - cornerH)
    gfx.LineTo(cornerW, Dim.design.height)
    gfx.MoveTo(Dim.design.width - cornerW, Dim.design.height)
    gfx.LineTo(Dim.design.width - cornerW, Dim.design.height - cornerH)
    gfx.LineTo(Dim.design.width, Dim.design.height - cornerH)
    --center square
    local centerX = Dim.design.width * 4 / 18
    local centerY = Dim.design.height * 11 / 32
    local centerW = Dim.design.width * 10 / 18
    local centerH = Dim.design.height * 10 / 32
    gfx.Rect(centerX, centerY, centerW, centerH)
    gfx.StrokeColor(table.unpack(self.STROKE_COLOR))
    gfx.StrokeWidth(self.STROKE_WIDTH)
    gfx.Stroke()
end

return ScreenCheckPage
