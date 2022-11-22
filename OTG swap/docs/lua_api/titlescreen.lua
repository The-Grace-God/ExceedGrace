local function Exit() end

local function Settings() end

local function Start() end

local function DLScreen() end

local function Update() end

local function Multiplayer() end

local function Challenges() end

Menu = {
    Exit = Exit,
    Settings = Settings,
    Start = Start,
    DLScreen = DLScreen,
    Update = Update,
    Multiplayer = Multiplayer,
    Challenges = Challenges
}

--- Render frame for titlescreen 
---@param deltaTime number Elapsed frametime since last frame
function render(deltaTime) end

--- Button event handler for titlescreen
---@param buttonCode integer Corresponds to game.Button_*
function button_pressed(buttonCode) end

--- Mouse event handler for titlescreen
---@param button integer
function mouse_pressed(button) end