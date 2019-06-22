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

local MAX_OPPONENTS_ON_SCREEN = 5

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
	minOpponentZ = perspective.maxZ / 8 --10
	maxOpponentZ = perspective.maxZ / 3 --5
end

function opponents.reset()
	opponentZ = maxOpponentZ
end

function opponents.update(playerSpeed,progress,aiCarCount,dt)
	opponentZ = opponentZ + OPPONENT_SPEED * dt - playerSpeed * dt

	if (opponentZ > maxOpponentZ) then
		-- move opponent closer to avoid long delay
		opponentZ = minOpponentZ
	elseif (opponentZ < 0) then
		if (aiCarCount < MAX_OPPONENTS_ON_SCREEN) then
			local car = entities.addCar(-1 + math.random(0,1) * 2,perspective.maxZ,false,progress)
			car.speed = car.topSpeed
			car.targetSpeed = car.topSpeed
		end
		opponentZ = math.random(minOpponentZ,maxOpponentZ)
	end
end

return opponents