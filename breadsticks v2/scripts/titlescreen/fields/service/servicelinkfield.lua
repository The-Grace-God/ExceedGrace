require("common.class")
local LinkField = require("components.pager.linkfield")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class ServiceLinkField: LinkField, ServiceField
local ServiceLinkField = {
    __tostring = function() return "ServiceLinkField" end,
}

---Create a new ServiceLinkField instance
---@param o? table # initial parameters
---@return ServiceLinkField
function ServiceLinkField.new(o)
    o = o or {}

    return CreateInstance(ServiceLinkField, o, ServiceField, LinkField)
end

---@param deltaTime number # frametime in seconds
function ServiceLinkField:drawValue(deltaTime) end

function ServiceLinkField:handleButtonInput(button)
    return LinkField.handleButtonInput(self, button)
end

return ServiceLinkField
