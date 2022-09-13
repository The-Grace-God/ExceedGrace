require("common.class")
require("common.filereader")
local Dim = require("common.dimensions")
local Version = require("common.version")
local Page = require("components.pager.page")
local CheckUpdatePage = require("titlescreen.pages.boot.checkupdatepage")
local ServiceField = require("titlescreen.fields.service.servicefield")
local ListField = require("titlescreen.fields.service.listfield")
local SelfTestField = require("titlescreen.fields.boot.selftestfield")

---@class BootPage: Page
local BootPage = {
    __tostring = function() return "BootPage" end,
}

---Create a new BootPage instance
---@param o? table # initial parameters
---@return BootPage
function BootPage.new(o)
    o = o or {}

    local this = CreateInstance(BootPage, o, Page)

    this._networkResult = {}

    this:addField(ServiceField.new{posX = 32, posY = 32, label = Version.getLongVersion(), value = ""})
    this:addField(ServiceField.new{posX = 64, posY = 64, label = "UNNAMED SDVX CLONE STARTUP...", value = ""})

    local valueOffX = 220
    this._mainIoTestField = SelfTestField.new{label = "MAIN I/O", VALUE_OFFSETX = valueOffX}
    this._mainIoTestField.checkTask = function(obj)
        return SelfTestStatusEnum.OK
    end
    this._mainIoTestField.onStatusChange = function(status)
        if status == SelfTestStatusEnum.OK then
            this._skinConfigTestField:activate()
        end
    end

    this._skinConfigTestField = SelfTestField.new{label = "SKIN CONFIG", VALUE_OFFSETX = valueOffX}
    this._skinConfigTestField.checkTask = function(obj)
        local crewpath = "skins/" .. game.GetSkin() .. "/textures/crew/anim/" .. game.GetSkinSetting("single_idol")
        if not IsDir(crewpath) then
            return SelfTestStatusEnum.ERROR
        end
        return SelfTestStatusEnum.OK
    end
    this._skinConfigTestField.onStatusChange = function(status)
        if status == SelfTestStatusEnum.OK then
            this._networkTestField:activate()
        end
    end

    this._networkTestField = SelfTestField.new{label = "NETWORK", VALUE_OFFSETX = valueOffX}
    -- set up async network check
    this._networkTestField.checkTask = function(obj)
        local status = SelfTestStatusEnum.INPROGRESS

        if not IRData.Active then
            return SelfTestStatusEnum.PASS
        end

        while status == SelfTestStatusEnum.INPROGRESS do
            if this._networkResult.statusCode == IRData.States.Success then
                status = SelfTestStatusEnum.OK
            elseif this._networkResult.statusCode then
                status = SelfTestStatusEnum.ERROR -- there's a response, but it's not success
            end

            coroutine.yield(status)
        end

        return status
    end
    this._networkTestField.onStatusChange = function(status)
        if status == SelfTestStatusEnum.INPROGRESS then
            IR.Heartbeat(function(res) this._networkResult = res end) -- IR doesn't like being called in a coroutine
        elseif status == SelfTestStatusEnum.PASS or status == SelfTestStatusEnum.OK then
            if this.viewHandler then
                this.viewHandler:navigate(CheckUpdatePage.new())
            end
        end
    end

    local list = ListField.new{posX = 64, posY = 96}
    list:addField(this._mainIoTestField)
    list:addField(this._skinConfigTestField)
    list:addField(this._networkTestField)
    this:addField(list)

    return this
end

---@param deltaTime number # frametime in seconds
function BootPage:drawBackground(deltaTime)
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0)
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.Fill()
end

local first = true
function BootPage:render(deltaTime)
    if first then
        self._mainIoTestField:activate()
        first = false
    end
    Page.render(self, deltaTime)
end

return BootPage
