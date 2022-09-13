require("common.class")
require("common.filereader")
require("common.gameconfig")
local Version = require("common.version")
local ServicePage = require("titlescreen.pages.service.servicepage")
local ServiceField = require("titlescreen.fields.service.servicefield")
local UpdateField = require("titlescreen.fields.service.updatefield")
local ListField = require("titlescreen.fields.service.listfield")

local function getGameLogValue(prefix, str)
    local pattern = prefix .. ":%s*([^\r\n]*)"
    return str:match(pattern)
end

---@class VersionInfoPage: ServicePage
local VersionInfoPage = {
    __tostring = function() return "VersionInfoPage" end,
}

---Create a new VersionInfoPage instance
---@param o? table # initial parameters
---@return VersionInfoPage
function VersionInfoPage.new(o)
    o = o or {}

    o.title = o.title or "SYSTEM INFORMATION"
    o.footer = o.footer or {
        "START BUTTON = UPDATE",
        "BACK BUTTON = EXIT"
    }
    o.selectedIndex = o.selectedIndex or 1

    local this = CreateInstance(VersionInfoPage, o, ServicePage)

    local logStr = ReadGameFile("log_usc-game.exe.txt") or ReadGameFile("log_usc-game.txt")

    local list = ListField.new{selectedIndex = 2, locked = true}
    list:addField(ServiceField.new{label = "SKIN ID CODE", value = Version.getLongVersion(), MARGIN = {0, 0, 0, 24}})
    list:addField(UpdateField.new{label = "USC VERSION", value = getGameLogValue("Version", logStr)})
    list:addField(ServiceField.new{label = "USC BRANCH", value = GameConfig["UpdateChannel"]})
    list:addField(ServiceField.new{label = "USC GIT COMMIT", value = getGameLogValue("Git commit", logStr), MARGIN = {0, 0, 0, 24}})
    list:addField(ServiceField.new{label = "GL VERSION", value = getGameLogValue("OpenGL Version", logStr)})
    list:addField(ServiceField.new{label = "GLSL VERSION", value = getGameLogValue("OpenGL Shading Language Version", logStr)})
    list:addField(ServiceField.new{label = "GL RENDERER", value = getGameLogValue("OpenGL Renderer", logStr)})
    list:addField(ServiceField.new{label = "GL VENDOR", value = getGameLogValue("OpenGL Vendor", logStr)})
    list:refreshFields()

    this:addField(list)
    this:refreshFields()

    return this
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
function VersionInfoPage:handleButtonInput(button)
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
    end
end

return VersionInfoPage
