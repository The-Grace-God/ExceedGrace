---Member lookup helper function
---@param key string
---@param bases any
---@return any
local function search(key, bases)
    for _, base in ipairs(bases) do
        local v = base[key]     -- try `i'-th superclass
        if v then return v end
    end
end

---Create polimorphic class
---@generic BaseT, T
---@param cls T # class metatable
---@param o? table # initial parameters
---@param ... BaseT # base class metatables (if any)
---@return T # class instance
function CreateInstance(cls, o, ...)
    o = o or {}
    local nargs = select("#", ...)
    local vargs = { select(1, ...) }
    cls.__index = cls
    if nargs == 1 then
        -- single inheritance
        local base = vargs[1]
        setmetatable(cls, {__index = base})
        o = base.new(o)
    elseif nargs > 1 then
        -- multiple inheritance (note: slow(er) member lookup)
        setmetatable(cls, {__index = function(t, k) return search(k, vargs) end})
        for _, base in ipairs(vargs) do
            o = base.new(o)
        end
    end
    setmetatable(o, cls)
    return o
end
