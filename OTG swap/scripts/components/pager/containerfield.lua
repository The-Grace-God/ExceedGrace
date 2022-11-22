require("common.class")
local Field = require("components.pager.field")

---@class ContainerField: Field
---@field content Field[]
local ContainerField = {
    __tostring = function() return "ContainerField" end,
}

---Create a new ContainerField instance
---@param o? table # initial parameters
---@return ContainerField
function ContainerField.new(o)
    o = o or {}

    --set instance members

    o.content = o.content or {}

    local this = CreateInstance(ContainerField, o, Field)

    this:refreshFields()

    return this
end

---Add content to container
---@param field Field
function ContainerField:addField(field)
    field.parent = self
    table.insert(self.content, field)
end

---Refresh content parameters
function ContainerField:refreshFields()
    for _, child in ipairs(self.content) do
        child.parent = self
    end
end

---@param deltaTime number # frametime in seconds
function ContainerField:drawBackground(deltaTime) end

---@param deltaTime number # frametime in seconds
function ContainerField:drawContent(deltaTime)
    for _, child in ipairs(self.content) do
        child:render(deltaTime)
    end
end

---@param deltaTime number # frametime in seconds
function ContainerField:drawForeground(deltaTime) end

---@param deltaTime number # frametime in seconds
function ContainerField:render(deltaTime)
    gfx.Save()

    gfx.Translate(self.posX, self.posY)
    gfx.Scissor(0, 0, self.aabbW, self.aabbH)

    self:drawBackground(deltaTime)
    self:drawContent(deltaTime)
    self:drawForeground(deltaTime)

    gfx.Restore()
end

return ContainerField
