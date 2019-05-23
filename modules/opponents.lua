-- Max Downforce - modules/opponents.lua
-- 2019 Foppygames

local opponents = {}

-- =========================================================
-- includes
-- =========================================================

local entities = require("modules.entities")
local perspective = require("modules.perspective")
local road = require("modules.road")

-- =========================================================
-- constants
-- =========================================================

local OPPONENT_SPEED = 70

-- =========================================================
-- private variables
-- =========================================================

local minOpponentZ
local maxOpponentZ
local opponentZ

-- =========================================================
-- public functions
-- =========================================================

function opponents.init()
	minOpponentZ = perspective.maxZ / 20
	maxOpponentZ = perspective.maxZ / 4
end

function opponents.reset()
	opponentZ = maxOpponentZ
end

function opponents.update(playerSpeed,progress,dt)
	opponentZ = opponentZ + OPPONENT_SPEED * dt - playerSpeed * dt

	if (opponentZ > maxOpponentZ) then
		opponentZ = maxOpponentZ
	elseif (opponentZ < 0) then
		local car = entities.addCar(-1 + math.random(0,1) * 2,perspective.maxZ,false,progress)
		car.speed = car.topSpeed * 0.95
		car.targetSpeed = car.topSpeed
		opponentZ = math.random(minOpponentZ,maxOpponentZ)
	end
end

return opponents