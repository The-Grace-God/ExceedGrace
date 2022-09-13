require("common.class")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class InputButtonField: ServiceField
---@field button integer
local InputButtonField = {
    __tostring = function() return "InputButtonField" end,
}

---Create a new InputButtonField instance
---@param o? table # initial parameters
---@return InputButtonField
function InputButtonField.new(o)
    o = o or {}

    o.button = o.button or nil

    return CreateInstance(InputButtonField, o, ServiceField)
end

---@param obj? any # message object for the field
function InputButtonField:activate(obj) end

---@param obj? any # message object for the field
function InputButtonField:focus(obj) end

---@param obj? any # message object for the field
function InputButtonField:deactivate(obj) end

---@param deltaTime number # frametime in seconds
function InputButtonField:drawValue(deltaTime)
    gfx.Translate(self.VALUE_OFFSETX, 0)

    if not self.button then
        gfx.Text("<BUTTON NOT SET>", 0, 0)
        return
    end

    self.value = game.GetButton(self.button) and "ON" or "OFF"
    gfx.Text(self.value, 0, 0)
end

return InputButtonField
