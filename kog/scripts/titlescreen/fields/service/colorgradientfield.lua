require("common.class")
local Util = require("common.util")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class ColorGradientField: ServiceField
local ColorGradientField = {
    __tostring = function() return "ColorGradientField" end,
    GRADIENT_X_OFFSET = 128,
    GRADIENT_WIDTH = 576,
    GRADIENT_STEPS = 32
}

---Create a new ColorGradientField instance
---@param o? table # initial parameters
---@return ColorGradientField
function ColorGradientField.new(o)
    o = o or {}

    o.value = o.value or {0, 0, 0, 255}

    return CreateInstance(ColorGradientField, o, ServiceField)
end

---@param obj? any # message object for the field
function ColorGradientField:activate(obj) end

---@param obj? any # message object for the field
function ColorGradientField:focus(obj) end

---@param obj? any # message object for the field
function ColorGradientField:deactivate(obj) end

---@param deltaTime number # frametime in seconds
function ColorGradientField:drawValue(deltaTime)
    local stepW = self.GRADIENT_WIDTH / self.GRADIENT_STEPS
    for i = 0, self.GRADIENT_STEPS - 1 do
        local posX = self.GRADIENT_X_OFFSET + i * stepW
        local colorA = math.ceil(Util.lerp(i, 0, 0, self.GRADIENT_STEPS - 1, self.value[4]))
        gfx.BeginPath()
        gfx.Rect(posX, 0, stepW, self.aabbH)
        gfx.FillColor(self.value[1], self.value[2], self.value[3], colorA)
        gfx.Fill()
    end
end

return ColorGradientField
