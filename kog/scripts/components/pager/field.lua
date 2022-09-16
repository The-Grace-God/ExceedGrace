require("common.class")

---@class Field
---@field parent Page|ContainerField
---@field posX number
---@field posY number
---@field aabbW number
---@field aabbH number
local Field = {
    __tostring = function() return "Field" end,
}

---Create a new Field instance
---@param o? table # initial parameters
---@return Field
function Field.new(o)
    o = o or {}

    --set instance members

    o.parent = o.parent or nil
    o.posX = o.posX or 0
    o.posY = o.posY or 0
    o.aabbW = o.aabbW or 0
    o.aabbH = o.aabbH or 0

    return CreateInstance(Field, o)
end

---Get the containing top-level parent page
---@return Field|Page
function Field:getParentPage()
    if self.parent and self.parent.getParentPage then
        return self.parent:getParentPage()
    else
        return self.parent
    end
end

---@param obj? any # message object for the field
function Field:activate(obj) end

---@param obj? any # message object for the field
function Field:focus(obj) end

---@param obj? any # message object for the field
function Field:deactivate(obj) end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
---@return boolean # true if further button input processing should be stopped, otherwise false
function Field:handleButtonInput(button)
    return false
end

---@param knob integer # `0` = Left, `1` = Right
---@param delta number # in radians, `-2*pi` to `0` (turning CCW) and `0` to `2*pi` (turning CW)
---@return boolean # true if further button input processing should be stopped, otherwise false
function Field:handleKnobInput(knob, delta)
    return false
end

---@param deltaTime number # frametime in seconds
function Field:drawContent(deltaTime)
    -- dummy field content

    gfx.ResetScissor()

    local offX = -50
    local offY = -50
    local aabbW = 100
    local aabbH = 100

    gfx.BeginPath()
    gfx.FillColor(255, 0, 128, 192)
    gfx.StrokeColor(0, 0, 0)
    gfx.StrokeWidth(2)
    gfx.Rect(offX, offY, aabbW, aabbH)
    gfx.Fill()
    gfx.Stroke()

    gfx.BeginPath()
    gfx.MoveTo(offX, 0)
    gfx.LineTo(offX + aabbW, 0)
    gfx.MoveTo(0, offY)
    gfx.LineTo(0, offY + aabbH)
    gfx.StrokeColor(0, 0, 0, 64)
    gfx.StrokeWidth(2)
    gfx.Stroke()

    local fontSize = 18
    local fontMargin = 4
    gfx.BeginPath()
    gfx.FontSize(fontSize)
    gfx.LoadSkinFont("dfmarugoth.ttf")
    gfx.FillColor(0, 0, 0)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER | gfx.TEXT_ALIGN_MIDDLE)
    gfx.Text("TEXTURE", 0, -fontSize / 2 - fontMargin)
    gfx.Text("MISSING", 0, fontSize / 2 + fontMargin)
end

---@param deltaTime number # frametime in seconds
function Field:render(deltaTime)
    gfx.Save()

    gfx.Translate(self.posX, self.posY)
    gfx.Scissor(0, 0, self.aabbW, self.aabbH)

    self:drawContent(deltaTime)

    gfx.Restore()
end

return Field
