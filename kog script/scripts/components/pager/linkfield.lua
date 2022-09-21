require("common.class")
local Field = require("components.pager.field")

---@class LinkField: Field
---@field link Page
local LinkField = {
    __tostring = function() return "LinkField" end
}

---Create a new LinkField instance
---@param o? table # initial parameters
---@return LinkField
function LinkField.new(o)
    o = o or {}

    o.link = o.link or nil

    return CreateInstance(LinkField, o, Field)
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
---@return boolean # true if further button input processing should be stopped, otherwise false
function LinkField:handleButtonInput(button)
    if not self.link then
        game.Log(tostring(self) .. " does not have a valid link", game.LOGGER_ERROR)
        return false
    end

    if button == game.BUTTON_STA then
        local parentPage = self:getParentPage()
        if parentPage and parentPage.viewHandler then
            game.Log(tostring(self) .. " viewHandler:navigate(" .. tostring(self.link) .. ") called", game.LOGGER_INFO)
            parentPage.viewHandler:navigate(self.link)
            return true
        else
            local target = (parentPage and parentPage.viewHandler or "PageView")
            game.Log(tostring(self) .. " can't access " .. tostring(target) .. " instance", game.LOGGER_ERROR)
        end
    end

    return false
end

return LinkField
