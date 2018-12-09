-- Max Downforce - modules/blips.lua
-- 2018 Foppygames

require "classes.car"

local blips = {}

-- =========================================================
-- includes
-- =========================================================

local entities = require("modules.entities")
local perspective = require("modules.perspective")

-- =========================================================
-- constants
-- =========================================================

local TOP_SPEED_FACTOR = 0.99
local ACC_FACTOR = 0.01

-- =========================================================
-- private variables
-- =========================================================

local list = {}

-- =========================================================
-- public functions
-- =========================================================

function blips.init()
	list = {}
end

function blips.reset()
	list = {}
end

function blips.addBlip(x,z,speed,aiTopSpeed,color,performanceFraction,posToPlayer)
	local blip = {
		x = x,
		z = z,
		speed = speed,
		color = color,
		performanceFraction = performanceFraction,
		posToPlayer = posToPlayer,
		topSpeed = performanceFraction * TOP_SPEED_FACTOR * aiTopSpeed,
		new = true
	}
	table.insert(list,blip)
end

function blips.addBlips(newBlips)
	local i = 1
	while i <= #newBlips do
		local blip = newBlips[i]
		blips.addBlip(blip.x,blip.z,blip.speed,blip.aiTopSpeed,blip.color,blip.performanceFraction,blip.posToPlayer)
		i = i + 1
	end
end

function blips.update(playerSpeed,dt,trackLength)
	local carsInFrontOfPlayer = 0
	local i = 1
	while i <= #list do
		local blip = list[i]
		local deleted = false
		if (not(blip.new)) then
			local acc = Car.getAcceleration(blip.speed,blip.topSpeed) * ACC_FACTOR
			if (blip.speed > blip.topSpeed) then
				blip.speed = blip.speed - acc
				if (blip.speed < blip.topSpeed) then
					blip.speed = blip.topSpeed
				end
			elseif (blip.speed < blip.topSpeed) then
				blip.speed = blip.speed + acc
				if (blip.speed > blip.topSpeed) then
					blip.speed = blip.topSpeed
				end
			end
			
			local oldZ = blip.z
			blip.z = blip.z - playerSpeed * dt
			blip.z = blip.z + blip.speed * dt
			
			-- blip is behind
			if (oldZ < 0) then
				-- blip has caught up and is appearing behind player
				if (blip.z >= 0) then
					-- create car
					local car = entities.addCar(blip.x,perspective.minZ+blip.z,false,blip.performanceFraction)
					
					-- set properties
					car.color = blip.color
					car.speed = blip.speed
					car.targetSpeed = car.speed
					car.freshFromBlip = true
					car.posToPlayer = blip.posToPlayer - 1
					
					-- remove blip
					table.remove(list,i)
					deleted = true
				-- blip is appearing on the horizon and will be lapped by player
				elseif (math.abs(blip.z) >= (trackLength - (perspective.maxZ - perspective.minZ))) then
					local diff = math.abs(blip.z) - (trackLength - (perspective.maxZ - perspective.minZ));
					
					-- create car
					local car = entities.addCar(blip.x,perspective.maxZ-diff,false,blip.performanceFraction)
					
					-- set properties
					car.color = blip.color
					car.speed = blip.speed
					car.targetSpeed = car.speed
					car.freshFromBlip = true
					car.posToPlayer = blip.posToPlayer + 1
					
					-- remove blip
					table.remove(list,i)
					deleted = true
				else
					i = i + 1
				end
			-- blip is in front
			else
				-- blip is about to lap player and is appearing behind player
				if (blip.z >= (trackLength - (perspective.maxZ - perspective.minZ))) then
					local diff = blip.z - (trackLength - (perspective.maxZ - perspective.minZ));
				
					-- create car
					local car = entities.addCar(blip.x,perspective.minZ,false,blip.performanceFraction)
					
					-- set properties
					car.color = blip.color
					car.speed = blip.speed
					car.targetSpeed = car.speed
					car.freshFromBlip = true
					car.posToPlayer = blip.posToPlayer - 1
					
					-- remove blip
					table.remove(list,i)
					deleted = true
				-- blip is appearing on the horizon
				elseif (blip.z <= 0) then
					-- create car
					local car = entities.addCar(blip.x,perspective.maxZ+blip.z,false,blip.performanceFraction)
					
					-- set properties
					car.color = blip.color
					car.speed = blip.speed
					car.targetSpeed = car.speed
					car.freshFromBlip = true
					car.posToPlayer = blip.posToPlayer + 1
					
					-- remove blip
					table.remove(list,i)
					deleted = true
				else
					i = i + 1
				end
			end	
		else
			blip.new = false
		end
		
		if (blip.posToPlayer < 0) then
			carsInFrontOfPlayer = carsInFrontOfPlayer + 1
		end
	end
	
	return {
		carsInFrontOfPlayer = carsInFrontOfPlayer
	}
end

return blips