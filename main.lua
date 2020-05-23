-- Max Downforce - main.lua
-- 2017-2020 Foppygames

-- =========================================================
-- includes
-- =========================================================

local states = require("modules.states")

-- =========================================================
-- constants
-- =========================================================

local VERSION = "1.2.0"
local TITLE = "Max Downforce"

-- =========================================================
-- functions
-- =========================================================

function love.load()
	states.init(VERSION,TITLE)
end

function love.update(dt)
	states.update(dt)
end

function love.keypressed(key)
	states.updateKeyPressed(key)
end

function love.gamepadpressed(joystick,button)
	states.updateGamepadPressed(joystick,button)
end

function love.joystickadded(joystick)
	states.updateSelectedJoystick()
end

function love.joystickremoved(joystick)
	states.updateSelectedJoystick()
end

function love.draw()
	states.draw()
end