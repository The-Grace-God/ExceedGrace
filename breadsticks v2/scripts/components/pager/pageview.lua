require("common.class")

---@class PageView
---@field pageStack Page[]
local PageView = {
    __tostring = function() return "PageView" end
}

local function pushStack(t, o)
    table.insert(t, 1, o)
end

local function popStack(t)
    return table.remove(t, 1)
end

---Create a new PageView instance
---@param rootPage Page
---@return PageView
function PageView.new(rootPage)
    local o = {}

    --set viewHandler as this instance for rootPage

    rootPage.viewHandler = o

    --set instance members

    o.pageStack = {}
    pushStack(o.pageStack, rootPage)

    return CreateInstance(PageView, o)
end

---Get page from pageStack
---@param index? integer # defaults to 1 (top of the stack)
---@return Page
function PageView:get(index)
    index = index or 1

    return self.pageStack[index]
end

---Navigate to page
---@param page Page # page to put on top of the pageStack
function PageView:navigate(page)
    page.viewHandler = self
    pushStack(self.pageStack, page)
end

---Replace the current pageStack with a new root page
---@param rootPage Page
function PageView:replace(rootPage)
    self:clear()
    self:navigate(rootPage)
end

---Navigate to the previous page
function PageView:back()
    if not self:get() then
        game.Log(self .. ":back() : pageStack empty, cannot go back", game.LOGGER_WARNING)
        return
    end

    self:get().viewHandler = nil
    popStack(self.pageStack)
end

---Clear the pageStack
function PageView:clear()
    --clear pageStack
    while self:get() do
        self:back()
    end
end

---@param deltaTime number # frametime in seconds
function PageView:render(deltaTime)
    if self:get() then
        self:get():render(deltaTime)
    end
end

return PageView
