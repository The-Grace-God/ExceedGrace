require("common.class")
local Util = require("common.util")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class SelfTestStatusEnum
SelfTestStatusEnum = {
    IDLE = 1,
    INPROGRESS = 2,
    OK = 3,
    PASS = 4,
    ERROR = 5
}

local function statusToString(status) 
    local statusName = {"IDLE", "INPROGRESS", "OK", "PASS", "ERROR"}
    return statusName[status]
end

---@class SelfTestField: ServiceField
---@field checkTask nil|fun(obj: any): SelfTestStatusEnum # a function that will run asynchronously on activating the Field
---@field status SelfTestStatusEnum
---@field onStatusChange nil|fun(status) # a callback function on finishing the checkTask
---@field _thread thread
---@field _timer number
local SelfTestField = {
    __tostring = function () return "SelfTestField" end,
    COLOR_INPROGRESS = {255, 255, 255, 255},
    COLOR_OK = {0, 255, 0, 255},
    COLOR_PASS = {255, 255, 0, 255},
    COLOR_ERROR = {255, 0, 0, 255},
    INPROGRESS_FREQ = 1 / 20, --20Hz
}

---Create a new SelfTestField instance
---@param o? table
---@return SelfTestField
function SelfTestField.new(o)
    o = o or {}

    o.status = o.status or SelfTestStatusEnum.IDLE
    o._timer = 0
    o._thread = nil

    assert((not o.onStatusChange) or (o.checkTask and o.onStatusChange),
        "Failed to construct SelfTestField, checkTask is mandatory when onStatusChange is defined!\n" .. debug.traceback()
    )

    return CreateInstance(SelfTestField, o, ServiceField)
end

function SelfTestField:_closeThread()
    if self._thread and coroutine.status(self._thread) ~= "dead" then
        coroutine.close(self._thread)
    end
end

function SelfTestField:_resumeThread()
    if self._thread and coroutine.status(self._thread) == "suspended" then
        local success, status = coroutine.resume(self._thread)
        game.Log(self.label .. ": success: " .. tostring(success) .. 
            ", status: " .. status .. " (" .. statusToString(status) .. ")",
            game.LOGGER_DEBUG
        )
        if success and status ~= self.status then
            self.status = status
            if self.onStatusChange then
                game.Log("SKIN CONFIG: onStatusChange(" .. status .. ") (" ..
                    statusToString(status) .. ")",
                    game.LOGGER_DEBUG
                )
                self.onStatusChange(status)
            end
        end
    end
end

function SelfTestField:activate(obj)
    self:_closeThread()

    if self.checkTask then
        self._thread = coroutine.create(self.checkTask)
        self:_resumeThread()
    end
end

function SelfTestField:deactivate(obj)
    self:_closeThread()
end

function SelfTestField:tick(deltaTime)
    self:_resumeThread()

    self._timer = self._timer + deltaTime
end

function SelfTestField:drawValue(deltaTime)
    gfx.Translate(self.VALUE_OFFSETX, 0)

    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT | gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(table.unpack(self.FONT_COLOR))
    gfx.Text(": ", 0, 0)

    local color, text
    if self.status == SelfTestStatusEnum.IDLE then
        color = self.FONT_COLOR
        text = ""
    elseif self.status == SelfTestStatusEnum.INPROGRESS then
        local progress = math.ceil(Util.lerp(self._timer % self.INPROGRESS_FREQ,
            0, 0, self.INPROGRESS_FREQ, 4
        ))
        color = self.COLOR_INPROGRESS
        text = string.rep(".", progress)
    elseif self.status == SelfTestStatusEnum.OK then
        color = self.COLOR_OK
        text = "OK"
    elseif self.status == SelfTestStatusEnum.PASS then
        color = self.COLOR_PASS
        text = "PASS"
    elseif self.status == SelfTestStatusEnum.ERROR then
        color = self.COLOR_ERROR
        text = "ERROR"
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT | gfx.TEXT_ALIGN_TOP)
    gfx.FillColor(table.unpack(color))
    gfx.Text(text, 0, 0)
end

function SelfTestField:render(deltaTime)
    self:tick(deltaTime)
    ServiceField.render(self, deltaTime)
end

return SelfTestField