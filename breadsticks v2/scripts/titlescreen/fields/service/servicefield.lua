require("common.class")
local Dim = require("common.dimensions")
local Field = require("components.pager.field")

---@class ServiceFieldState
ServiceFieldState = {
    INACTIVE = 0,
    FOCUSED = 1,
    ACTIVE = 2
}

---@class ServiceField: Field
---@field label string
---@field value any
---@field footer string|string[]
---@field _state ServiceFieldState
---@field FONT_SIZE number
---@field FONT_FACE string
---@field FONT_COLOR integer[] # {r, g, b, a}
---@field FONT_ACTIVE_COLOR integer[] # {r, g, b, a}
---@field FONT_FOCUSED_COLOR integer[]  # {r, g, b, a}
---@field MARGIN number[] # {left, top, right, bottom}
---@field VALUE_OFFSETX number
local ServiceField = {
    __tostring = function() return "ServiceField" end,
    FONT_SIZE = 24,
    FONT_FACE = "dfmarugoth.ttf",
    FONT_COLOR = {255, 255, 255, 255},
    FONT_ACTIVE_COLOR = {0, 255, 0, 255},
    FONT_FOCUSED_COLOR = {255, 0, 0, 255},
    MARGIN = {0, 0, 0, 0},
    VALUE_OFFSETX = 500
}

---Create a new ServiceField instance
---@param o? table # initial parameters
---@return ServiceField
function ServiceField.new(o)
    o = o or {}

    local h = ServiceField.FONT_SIZE + ServiceField.MARGIN[2] + ServiceField.MARGIN[4]

    o.aabbH = o.aabbH or h
    o.aabbW = o.aabbW or Dim.design.width --:shrug:

    o.label = o.label or "<UNDEFINED>"
    o.value = o.value or nil
    o.footer = o.footer or nil

    o._state = ServiceFieldState.INACTIVE

    local this = CreateInstance(ServiceField, o, Field)

    if this.aabbH < h then
        this.aabbH = h
    end

    return this
end

---@param obj? any # message object for the field
function ServiceField:activate(obj)
    self._state = ServiceFieldState.ACTIVE
end

---@param obj? any # message object for the field
function ServiceField:focus(obj)
    self._state = ServiceFieldState.FOCUSED
end

---@param obj? any # message object for the field
function ServiceField:deactivate(obj)
    self._state = ServiceFieldState.INACTIVE
end

---@param deltaTime number # frametime in seconds
function ServiceField:drawLabel(deltaTime)
    local color
    if self._state == ServiceFieldState.FOCUSED then
        color = self.FONT_FOCUSED_COLOR
    else
        color = self.FONT_COLOR
    end

    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT | gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(table.unpack(color))
    gfx.Text(string.upper(self.label), 0, 0)
end

---@param deltaTime number # frametime in seconds
function ServiceField:drawValue(deltaTime)
    local text
    if type(self.value) == "string" then
        text = string.upper(self.value)
    else
        text = "N/A"
    end

    gfx.Translate(self.VALUE_OFFSETX, 0)
    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT | gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(table.unpack(self.FONT_COLOR))
    gfx.Text(text, 0, 0)
end

---@param deltaTime number # frametime in seconds
function ServiceField:drawContent(deltaTime)
    gfx.Translate(self.MARGIN[1], self.MARGIN[2])

    self:drawLabel(deltaTime)
    self:drawValue(deltaTime)
end

return ServiceField
