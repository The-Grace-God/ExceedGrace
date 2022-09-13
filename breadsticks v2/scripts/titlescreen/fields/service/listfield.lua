require("common.class")
local ContainerField = require("components.pager.containerfield")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class ListField: ContainerField, ServiceField
---@field selectedIndex integer
---@field locked boolean
---@field PADDING number[]
local ListField = {
    __tostring = function() return "ListField" end,
    MARGIN = {0, 0, 0, 0}, --{left, top, right, bottom}
    PADDING = {0, 0, 0, 0}, --{left, top, right, bottom}
}

---Create a new ListField instance
---@param o? table # initial parameters
---@return ListField
function ListField.new(o)
    o = o or {}

    --set instance members
    o.selectedIndex = o.selectedIndex or 1
    o.locked = o.locked or false

    local this = CreateInstance(ListField, o, ContainerField, ServiceField)

    local minW = this.MARGIN[1] + this.PADDING[1] + this.PADDING[3] + this.MARGIN[3]
    local minH = this.MARGIN[2] + this.PADDING[2] + this.PADDING[4] + this.MARGIN[4]
    this.aabbW = math.max(this.aabbW, minW)
    this.aabbH = math.max(this.aabbH, minH)

    return this
end

---@param obj? any # message object for the field
function ListField:focus(obj)
    if self._state == ServiceFieldState.ACTIVE then
        return
    end

    -- if obj message received about direction of cursor movement
    if obj and obj.direction then
        if obj.direction > 0 then
            self.selectedIndex = 1
        elseif obj.direction < 0 then
            self.selectedIndex = #self.content
        end
    end

    -- else try to figure out by comparing current selected index
    if self.selectedIndex < 1 then
        self.selectedIndex = 1
    elseif self.selectedIndex > #self.content then
        self.selectedIndex = #self.content
    end

    local field = self.content[self.selectedIndex]
    if field and field.focus then
        field:focus()
    end

    ServiceField.focus(self)
end

---Add field to list container
---@param field Field
function ListField:addField(field)
    --update size
    self.aabbH = self.aabbH + field.aabbH
    local fieldAabbW = self.PADDING[1] + field.aabbW + self.PADDING[3]
    if self.aabbW < fieldAabbW then
        self.aabbW = fieldAabbW
    end

    --add field to container
    ContainerField.addField(self, field)
end

---Refresh content parameters
function ListField:refreshFields()
    local aabbH = self.MARGIN[2] + self.PADDING[2] + self.PADDING[4] + self.MARGIN[4]
    for _, child in ipairs(self.content) do
        --update size
        aabbH = aabbH + child.aabbH
        local fieldAabbW = self.PADDING[1] + child.aabbW + self.PADDING[3]
        if self.aabbW < fieldAabbW then
            self.aabbW = fieldAabbW
        end
    end
    self.aabbH = aabbH

    ContainerField.refreshFields(self)
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
---@return boolean # true if further button input processing should be stopped, otherwise false
function ListField:handleButtonInput(button)
    local field = self.content[self.selectedIndex]
    if field:handleButtonInput(button) then
        return true
    end

    if button == game.BUTTON_BCK then
        local viewHandler = self:getParentPage().viewHandler
        if viewHandler then
            viewHandler:back()
        end
        return true
    end

    if self.locked then
        return true
    end

    local direction = 0

    if button == game.BUTTON_BTA then
        direction = -1
    elseif button == game.BUTTON_BTB then
        direction = 1
    end

    if direction ~= 0 then
        field:deactivate()

        self.selectedIndex = self.selectedIndex + direction

        if self.selectedIndex < 1 or self.selectedIndex > #self.content then
            return false
        end

        field = self.content[self.selectedIndex]
        field:focus()
    end

    return true
end

---@param deltaTime number # frametime in seconds
function ListField:drawContent(deltaTime)
    gfx.Translate(self.PADDING[1] + self.MARGIN[1], self.PADDING[2] + self.MARGIN[2])
    for _, child in ipairs(self.content) do
        child:render(deltaTime)
        gfx.Translate(0, child.aabbH)
    end
end

return ListField
