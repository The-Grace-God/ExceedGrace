require("common.class")
local ServicePage = require("titlescreen.pages.service.servicepage")
local InputCheckPage = require("titlescreen.pages.service.inputcheckpage")
local ScreenCheckPage = require("titlescreen.pages.service.screencheckpage")
local ColorCheckPage = require("titlescreen.pages.service.colorcheckpage")
local VersionInfoPage = require("titlescreen.pages.service.versioninfopage")
local ServiceLinkField = require("titlescreen.fields.service.servicelinkfield")
local ListField = require("titlescreen.fields.service.listfield")

---@class MainMenuPage: ServicePage
local MainMenuPage = {
    __tostring = function() return "MainMenuPage" end,
}

---Create a new MainMenuPage instance
---@param o? table # initial parameters
---@return MainMenuPage
function MainMenuPage.new(o)
    o = o or {}

    o.title = o.title or "MAIN MENU"

    local this = CreateInstance(MainMenuPage, o, ServicePage)

    local list = ListField.new()
    list:addField(ServiceLinkField.new{label = "INPUT CHECK", link = InputCheckPage.new()})
    list:addField(ServiceLinkField.new{label = "SCREEN CHECK", link = ScreenCheckPage.new()})
    list:addField(ServiceLinkField.new{label = "COLOR CHECK", link = ColorCheckPage.new()})
    list:addField(ServiceLinkField.new{label = "VERSION INFORMATION", link = VersionInfoPage.new()})
    list:refreshFields()

    this:addField(list)
    this:refreshFields()

    return this
end

return MainMenuPage
