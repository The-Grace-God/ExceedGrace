require("common.class")
local Util = require("common.util")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class CheckUpdateField: ServiceField
---@field onUpdateAvailable nil|fun(url: string, version: string)
---@field _timer number
local CheckUpdateField = {
    __tostring = function() return "CheckUpdateField" end,
    PROGRESS_FREQ = 1 / 5, -- 5Hz
    CHECK_UPDATE_TIMEOUT = 5, -- seconds
}

---Create a new CheckUpdateField instance
---@param o? table # initial parameters
---@return CheckUpdateField
function CheckUpdateField.new(o)
    o = o or {}

    o._timer = o._timer or 0
    o.onUpdateAvailable = o.onUpdateAvailable or nil

    local this = CreateInstance(CheckUpdateField, o, ServiceField)

    this._url = nil
    this._version = nil
    this._onUpdateAvailableFired = false

    return this
end

function CheckUpdateField:drawLabel(deltaTime)
    local text = self.label
    local progress = math.ceil(Util.lerp(self._timer % self.PROGRESS_FREQ,
        0, 0, self.PROGRESS_FREQ, 4
    ))
    text = text .. string.rep(".", progress)

    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT | gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(table.unpack(self.FONT_COLOR))
    gfx.Text(text, 0, 0)
end

function CheckUpdateField:drawValue(deltaTime)

end

function CheckUpdateField:tick(deltaTime)
    if not self._onUpdateAvailableFired then
        if self._timer > self.CHECK_UPDATE_TIMEOUT then
            self._url, self._version = game.UpdateAvailable()
            -- self._url = "" -- debug code to force onUpdateAvailable()
            if self._url then
                self.onUpdateAvailable(self._url, self._version)
                self._onUpdateAvailableFired = true
            else
                self:getParentPage().viewHandler:clear() -- Exit out of bootscreen
            end
        end
    end
    self._timer = self._timer + deltaTime
end

function CheckUpdateField:render(deltaTime)
    self:tick(deltaTime)
    ServiceField.render(self, deltaTime)
end

return CheckUpdateField
