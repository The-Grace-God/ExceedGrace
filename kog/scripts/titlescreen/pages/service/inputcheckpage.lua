require("common.class")
local ServicePage = require("titlescreen.pages.service.servicepage")
local InputButtonField = require("titlescreen.fields.service.inputbuttonfield")
local InputKnobField = require("titlescreen.fields.service.inputknobfield")
local ListField = require("titlescreen.fields.service.listfield")

---@class InputCheckPage: ServicePage
local InputCheckPage = {
    __tostring = function() return "InputCheckPage" end,
}

---Create a new InputCheckPage instance
---@param o? table # initial parameters
---@return InputCheckPage
function InputCheckPage.new(o)
    o = o or {}

    o.title = o.title or "INPUT CHECK"
    o.footer = o.footer or "BACK BUTTON = EXIT"

    local this = CreateInstance(InputCheckPage, o, ServicePage)

    local list = ListField.new()
    list:addField(InputButtonField.new{label="START BUTTON", button=game.BUTTON_STA})
    list:addField(InputButtonField.new{label="A BUTTON", button=game.BUTTON_BTA})
    list:addField(InputButtonField.new{label="B BUTTON", button=game.BUTTON_BTB})
    list:addField(InputButtonField.new{label="C BUTTON", button=game.BUTTON_BTC})
    list:addField(InputButtonField.new{label="D BUTTON", button=game.BUTTON_BTD})
    list:addField(InputButtonField.new{label="FX L BUTTON", button=game.BUTTON_FXL})
    list:addField(InputButtonField.new{label="FX R BUTTON", button=game.BUTTON_FXR})
    list:addField(InputKnobField.new{label="ANALOG VOLUME L", knob=0})
    list:addField(InputKnobField.new{label="ANALOG VOLUME R", knob=1})
    list:refreshFields()

    this:addField(list)
    this:refreshFields()

    return this
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
function InputCheckPage:handleButtonInput(button)
    local field = self.content[self.selectedIndex]
    if field and field.handleButtonInput then
        if field:handleButtonInput(button) then
            return
        end
    end

    -- default behaviour
    if button == game.BUTTON_BCK then
        if self.viewHandler then
            self.viewHandler:back()
        end
        return
    end
end

return InputCheckPage
