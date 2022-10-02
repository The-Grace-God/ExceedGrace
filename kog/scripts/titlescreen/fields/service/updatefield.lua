require("common.class")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class UpdateField: ServiceField
---@field _timer number
local UpdateField = {
    __tostring = function() return "UpdateField" end,
    UPDATE_FLICKER_TIME = 0.5,
    UPDATE_FLICKER_COLORS = {
        {255, 0, 0, 255},
        {255, 255, 0, 255}
    }
}

---Create a new UpdateField instance
---@param o? table # initial parameters
---@return UpdateField
function UpdateField.new(o)
    o = o or {}

    o._timer = 0

    return CreateInstance(UpdateField, o, ServiceField)
end

---@param obj? any # message object for the field
function UpdateField:activate(obj) end

---@param obj? any # message object for the field
function UpdateField:focus(obj) end

---@param obj? any # message object for the field
function UpdateField:deactivate(obj) end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
---@return boolean # true if further button input processing should be stopped, otherwise false
function UpdateField:handleButtonInput(button)
    local url, _ = game.UpdateAvailable()

    if button == game.BUTTON_STA and url then
        Menu.Update()
        return true
    end

    return false
end

---@param deltaTime number # frametime in seconds
function UpdateField:drawValue(deltaTime)
    self._timer = self._timer + deltaTime
    local url, version = game.UpdateAvailable()

    gfx.Translate(self.VALUE_OFFSETX, 0)

    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT | gfx.TEXT_ALIGN_TOP)
    if url then
        if (self._timer % self.UPDATE_FLICKER_TIME) < self.UPDATE_FLICKER_TIME / 2 then
            gfx.FillColor(table.unpack(self.UPDATE_FLICKER_COLORS[1]))
        else
            gfx.FillColor(table.unpack(self.UPDATE_FLICKER_COLORS[2]))
        end
        gfx.Text("*UPDATE AVAILABLE (" .. version .. ")*", 0, 0)
    else
        gfx.FillColor(table.unpack(self.FONT_COLOR))
        gfx.Text(self.value or "<VERSION STRING NOT AVAILABLE>", 0, 0)
    end
end

return UpdateField
