require("common.class")
local Util = require("common.util")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class InputKnobField: ServiceField
---@field knob integer
local InputKnobField = {
    __tostring = function() return "InputKnobField" end,
    SLIDER_SIZE = {200, 16}, --{w, h}
    SLIDER_BGCOLOR = {255, 0, 0, 255},
    SLIDER_FRAME_COLOR = ServiceField.FONT_COLOR,
    SLIDER_FRAME_WIDTH = 1,
    SLIDER_OFFSETX = 64,
    SLIDER_INDICATOR_COLOR = {0, 255, 0, 255},
    SLIDER_INDICATOR_WIDTH = 4
}

---Create a new InputKnobField instance
---@param o? table # initial parameters
---@return InputKnobField
function InputKnobField.new(o)
    o = o or {}

    o.knob = o.knob or nil

    return CreateInstance(InputKnobField, o, ServiceField)
end

---@param obj? any # message object for the field
function InputKnobField:activate(obj) end

---@param obj? any # message object for the field
function InputKnobField:focus(obj) end

---@param obj? any # message object for the field
function InputKnobField:deactivate(obj) end

---@param deltaTime number # frametime in seconds
function InputKnobField:drawValue(deltaTime)
    gfx.Translate(self.VALUE_OFFSETX, 0)

    if not self.knob then
        gfx.Text("<KNOB NOT SET>", 0, 0)
        return
    end

    local knobAngle = game.GetKnob(self.knob)
    local sliderWidth = self.SLIDER_SIZE[1]
    local sliderHeight = self.SLIDER_SIZE[2]
    local sliderBgColor = self.SLIDER_BGCOLOR
    local sliderFrameColor = self.SLIDER_FRAME_COLOR
    local sliderFrameWidth = self.SLIDER_FRAME_WIDTH

    local maxValue = 1024
    self.value = math.floor(Util.lerp(knobAngle,0, 0, 2 * math.pi, maxValue)) % maxValue

    --draw value
    gfx.Text(self.value, 0, 0)

    --draw slider
    gfx.Translate(self.SLIDER_OFFSETX, 0)
    gfx.BeginPath()
    gfx.Rect(0, 0, sliderWidth, sliderHeight)
    gfx.FillColor(table.unpack(sliderBgColor))
    gfx.StrokeColor(table.unpack(sliderFrameColor))
    gfx.StrokeWidth(sliderFrameWidth)
    gfx.Fill()
    gfx.Stroke()

    local sliderIndicatorX = Util.lerp(self.value, 0, 0, maxValue, sliderWidth)
    local sliderIndicatorWidth = self.SLIDER_INDICATOR_WIDTH
    local sliderIndicatorColor = self.SLIDER_INDICATOR_COLOR
    --draw indicator
    gfx.BeginPath()
    gfx.Rect(sliderIndicatorX, sliderFrameWidth, sliderIndicatorWidth, sliderHeight - 2 * sliderFrameWidth)
    gfx.FillColor(table.unpack(sliderIndicatorColor))
    gfx.Fill()
end

return InputKnobField
