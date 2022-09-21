require("common.class")
local Dim = require("common.dimensions")
local Util = require("common.util")
local Page = require("components.pager.page")
local ServiceField = require("titlescreen.fields.service.servicefield")

---@class ServicePage: Page
---@field title string|string[]
---@field selectedIndex integer
---@field footer string[]
---@field content ServiceField[]
---@field FONT_SIZE number
---@field FONT_FACE string
---@field FONT_COLOR integer[] # {r, g, b, a}
---@field PADDING number[] # {left, top, right, bottom}
---@field PAGE_PADDING number[] # {left, top, right, bottom}
---@field FOOTER string|string[]
---@field FOOTER_SPACING number
local ServicePage = {
    __tostring = function() return "ServicePage" end,
    FONT_SIZE = ServiceField.FONT_SIZE,
    FONT_FACE = ServiceField.FONT_FACE,
    FONT_COLOR = ServiceField.FONT_COLOR, --{r, g, b, a}
    PADDING = {100, 128, 0, 56}, --{left, top, right, bottom}
    PAGE_PADDING = {16, 16, 16, 16}, --{left, top, right, bottom}
    FOOTER = {
        "A/B BUTTON = SELECT ITEM",
        "START BUTTON = EXECUTE",
        "BACK BUTTON = EXIT"
    },
    FOOTER_SPACING = ServiceField.FONT_SIZE
        + ServiceField.MARGIN[2]
        + ServiceField.MARGIN[4],
}

---Create a new ServicePage instance
---@param o? table # initial parameters
---@return ServicePage
function ServicePage.new(o)
    o = o or {}

    o.title = o.title or ""
    o.selectedIndex = o.selectedIndex or 1
    o.footer = o.footer or ServicePage.FOOTER

    return CreateInstance(ServicePage, o, Page)
end

---Refresh content values
function ServicePage:refreshFields()
    for index, field in ipairs(self.content) do
        if index == self.selectedIndex then
            field:focus()
        else
            field:deactivate()
        end
    end
    Page.refreshFields(self)
end

---@param button integer # options are under the `game` table prefixed with `BUTTON`
function ServicePage:handleButtonInput(button)
    local field = self.content[self.selectedIndex]
    -- if the field indicates that the button input has been handled in a
    -- way that requires no further processing, return from this function
    if field:handleButtonInput(button) then
        return
    end

    -- default behaviour:

    local direction = 0

    if button == game.BUTTON_BCK then
        if self.viewHandler then
            self.viewHandler:back()
        end
        return
    elseif button == game.BUTTON_BTA then
        direction = -1
    elseif button == game.BUTTON_BTB then
        direction = 1
    end

    if direction ~= 0 then
        field:deactivate()

        self.selectedIndex = Util.modIndex(self.selectedIndex + direction, #self.content)

        field = self.content[self.selectedIndex]
        field:focus({direction = direction}) -- send direction as the message
    end
end

---@param knob integer # `0` = Left, `1` = Right
---@param delta number # in radians, `-2*pi` to `0` (turning CCW) and `0` to `2*pi` (turning CW)
function ServicePage:handleKnobInput(knob, delta)
    if self.content[self.selectedIndex] and self.content[self.selectedIndex].handleKnobInput then
        self.content[self.selectedIndex].handleKnobInput(knob, delta)
    end
end

---@param deltaTime number # frametime in seconds
function ServicePage:drawBackground(deltaTime)
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0)
    gfx.Rect(0, 0, Dim.design.width, Dim.design.height)
    gfx.Fill()
end

---@param deltaTime number # frametime in seconds
function ServicePage:drawContent(deltaTime)
    gfx.Save()
    gfx.Translate(self.PADDING[1], self.PADDING[2])
    local contentW = Dim.design.width - self.PADDING[1] - self.PADDING[3]
    local contentH = Dim.design.height - self.PADDING[2] - self.PADDING[4]
    gfx.Scissor(0, 0, contentW, contentH)
    Page.drawContent(self, deltaTime)
    gfx.Restore()
end

---@param deltaTime number # frametime in seconds
function ServicePage:drawHeader(deltaTime)
    local lineHeight = self.FOOTER_SPACING
    gfx.BeginPath()
    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)
    gfx.FillColor(table.unpack(self.FONT_COLOR))
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER | gfx.TEXT_ALIGN_TOP)
    if type(self.title) == "table" then
        for index, line in ipairs(self.title) do
            gfx.Text(line, Dim.design.width / 2, (index-1) * lineHeight)
        end
    elseif type(self.title) == "string" then
        gfx.Text(self.title, Dim.design.width / 2, 0)
    end
end

---@param deltaTime number # frametime in seconds
function ServicePage:drawFooter(deltaTime)
    local footer = self.content[self.selectedIndex] and self.content[self.selectedIndex].footer or self.footer

    local lineHeight = self.FOOTER_SPACING
    gfx.BeginPath()
    gfx.FontSize(self.FONT_SIZE)
    gfx.LoadSkinFont(self.FONT_FACE)
    gfx.FillColor(table.unpack(self.FONT_COLOR))
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER | gfx.TEXT_ALIGN_BOTTOM)
    if type(footer) == "table" then
        local yFooterBase = -#footer * lineHeight
        for index, line in ipairs(footer) do
            gfx.Text(line, Dim.design.width / 2, yFooterBase + (index-1) * lineHeight)
        end
    elseif type(footer) == "string" then
        gfx.Text(footer, Dim.design.width / 2, 0)
    end
end

---@param deltaTime number # frametime in seconds
function ServicePage:drawForeground(deltaTime)
    gfx.Save()
    gfx.Translate(0, self.PAGE_PADDING[2])
    self:drawHeader(deltaTime)
    gfx.Restore()

    gfx.Save()
    gfx.Translate(0, Dim.design.height - self.PAGE_PADDING[4])
    self:drawFooter(deltaTime)
    gfx.Restore()
end

return ServicePage
