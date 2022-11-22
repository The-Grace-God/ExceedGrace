require("common.class")
local Dim = require("common.dimensions")
local Page = require("components.pager.page")
local CheckUpdateField = require("titlescreen.fields.boot.checkupdatefield")
local DialogField = require("titlescreen.fields.boot.dialogfield")

---@class CheckUpdatePage: Page
---@field _focusedField CheckUpdateField
local CheckUpdatePage = {
    __tostring = function() return "CheckUpdatePage" end,
}

---Create a new CheckUpdatePage instance
---@param o? table # initial parameters
---@return CheckUpdatePage
function CheckUpdatePage.new(o)
    local this = CreateInstance(CheckUpdatePage, o, Page)

    local width = DialogField.DEFAULT_WIDTH
    local height = DialogField.DEFAULT_HEIGHT
    local posX = (Dim.design.width - width) / 2
    local posY = (Dim.design.height - height) / 2
    this._updateDialogField = DialogField.new{
        posX = posX,
        posY = posY,
        aabbW = width,
        aabbH = height,
        HEADER = {
            title = "Updates found",
            code = "0-1000-0000"
        },
        TEXT = {
            "An update is available to Unnamed SDVX Clone,",
            "please update to receive the latest features."
        },
        LEGEND = {
            {
                label = "BACK BUTTON",
                text = "ABORT UPDATE/START GAME"
            },
            {
                label = "START BUTTON",
                text = "GO TO SERVICE PAGE"
            }
        }
    }
    this._updateDialogField.handleButtonInput = function (self, button)
        if not this.viewHandler then
            return false
        end

        if button == game.BUTTON_BCK then
            this.viewHandler:clear() -- Cancel update, close screen
            return true
        elseif button == game.BUTTON_STA then
            -- NOTE: this is a huge ass hack, please rethink
            local MainMenuPage = require("titlescreen.pages.service.mainmenupage")
            this.viewHandler:replace(MainMenuPage.new())
            return true
        end

        return false
    end

    this._checkUpdateField = CheckUpdateField.new{posX = 32, posY = 64, label = "update check"}
    this._checkUpdateField.onUpdateAvailable = function(url, version)
        this:addField(this._updateDialogField)
        this._focusedField = this._updateDialogField
    end

    this:addField(this._checkUpdateField)

    this._focusedField = this._checkUpdateField

    return this
end

function CheckUpdatePage:handleButtonInput(button)
    if self._focusedField and self._focusedField:handleButtonInput(button) then
        return -- stop processing input
    end

    if button == game.BUTTON_BCK then
        self.viewHandler:back()
    end
end

---@param deltaTime number # frametime in seconds
function CheckUpdatePage:drawBackground(deltaTime)
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0)
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.Fill()
end

return CheckUpdatePage
