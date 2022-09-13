local call = nil

local EN = require("language.EN")
local DE = require("language.DE")
local SK = require("language.SK")
local HU = require("language.HU")
local test2 = require("language.test2")

if game.GetSkinSetting('words') == "EN" then
    call = EN
elseif game.GetSkinSetting('words') == "DE" then
    call = DE
elseif game.GetSkinSetting('words') == "SK" then
    call = SK
elseif game.GetSkinSetting('words') == "HU" then
    call = HU
elseif game.GetSkinSetting('words') == "test2" then
    call = test2
end


return call