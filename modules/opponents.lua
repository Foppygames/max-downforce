-- Max Downforce - modules/opponents.lua
-- 2019 Foppygames

local opponents = {}

-- =========================================================
-- includes
-- =========================================================

local entities = require("modules.entities")
local perspective = require("modules.perspective")
local road = require("modules.road")
local segments = require("modules.segments")

-- =========================================================
-- constants
-- =========================================================

local OPPONENT_SPEED = 70
local MAX_OPPONENTS_ON_SCREEN = 5
local YELLOW_MIN_TRACK_LENGTHS = 0.6
local YELLOW_MAX_TRACK_LENGTHS = 2.6

-- =========================================================
-- private variables
-- =========================================================

local minOpponentZ
local maxOpponentZ
local opponentZ
local yellowFlagDistance
local yellowFlagCount
local yellowFlagSide

-- =========================================================
-- public functions
-- =========================================================

function opponents.init()
	minOpponentZ = perspective.maxZ / 8
	maxOpponentZ = perspective.maxZ / 3
end

function opponents.reset()
	opponentZ = maxOpponentZ
	opponents.resetYellowFlag()
end

function opponents.resetYellowFlag()
	yellowFlagDistance = (YELLOW_MIN_TRACK_LENGTHS + math.random() * (YELLOW_MAX_TRACK_LENGTHS - YELLOW_MIN_TRACK_LENGTHS)) * segments.totalLength
	yellowFlagCount = 0
	yellowFlagSide = -1 + math.random(0,1) * 2
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
	
	yellowFlagDistance = yellowFlagDistance - playerSpeed * dt
	if (yellowFlagDistance <= 0) then
		yellowFlagCount = yellowFlagCount + 1
		if (yellowFlagCount <= 3) then
			entities.addFlagger(yellowFlagSide * road.ROAD_WIDTH / 2.4,perspective.maxZ)
			yellowFlagDistance = yellowFlagCount * (perspective.maxZ / 5.5)
			if (yellowFlagCount == 3) then
				yellowFlagDistance = 0
			end
		else
			local car = entities.addCar(yellowFlagSide,perspective.maxZ,false,progress)
			car:breakDown(yellowFlagSide)
			opponents.resetYellowFlag()
		end
	end
end

return opponents