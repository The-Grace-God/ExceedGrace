require("common.globals")
require("common.class")

---@class Page
---@field content Field[]
---@field viewHandler nil|PageView
local Page = {
    __tostring = function() return "Page" end,
}

---Create a new Page instance
---@param o? table # initial parameters
---@return Page
function Page.new(o)
    o = o or {}

    --set instance members

    o.content = o.content or {}
    o.viewHandler = o.viewHandler or nil

    return CreateInstance(Page, o)
end

---Add field to page
---@param field Field
function Page:addField(field)
    field.parent = self
    table.insert(self.content, field)
end

---Refresh content values
function Page:refreshFields()
    for _, field in ipairs(self.content) do
        field.parent = self
    end
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
function Page:handleButtonInput(button)
    if button == game.BUTTON_BCK then
        if self.viewHandler then
            self.viewHandler:back()
        end
    end
end

---@param knob integer # `0` = Left, `1` = Right
---@param delta number # in radians, `-2*pi` to `0` (turning CCW) and `0` to `2*pi` (turning CW)
function Page:handleKnobInput(knob, delta) end

---@param deltaTime number # frametime in seconds
function Page:drawBackground(deltaTime) end

---@param deltaTime number # frametime in seconds
function Page:drawContent(deltaTime)
    for _, child in ipairs(self.content) do
        child:render(deltaTime)
    end
end

---@param deltaTime number # frametime in seconds
function Page:drawForeground(deltaTime) end

---@param deltaTime number # frametime in seconds
function Page:render(deltaTime)
    self:drawBackground(deltaTime)
    self:drawContent(deltaTime)
    self:drawForeground(deltaTime)
end

return Page
