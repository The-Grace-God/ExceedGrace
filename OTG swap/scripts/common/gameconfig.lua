require("common.filereader")

GameConfig = {}

function RefreshConfig()
    for _, match in ipairs(FindPatterns("Main.cfg", "(%w*)%s*=%s*\"?([^\"%s]*)\"?")) do
        GameConfig[match[1]] = match[2]
    end
end

RefreshConfig()