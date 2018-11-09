-- Max Downforce - modules/blips.lua
-- 2018 Foppygames

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

function blips.addBlip(x,z,speed,aiTopSpeed,color,performanceFraction)
	local blip = {
		x = x,
		z = z,
		speed = speed,
		color = color,
		performanceFraction = performanceFraction,
		topSpeed = performanceFraction * TOP_SPEED_FACTOR * aiTopSpeed,
		new = true
	}
	table.insert(list,blip)
end

function blips.addBlips(newBlips)
	local i = 1
	while i <= #newBlips do
		local blip = newBlips[i]
		blips.addBlip(blip.x,blip.z,blip.speed,blip.aiTopSpeed,blip.color,blip.performanceFraction)
		i = i + 1
	end
end

function blips.update(playerSpeed,dt,trackLength)
	local i = 1
	while i <= #list do
		local blip = list[i]
		if (not(blip.new)) then
			local acc = entities.getAcceleration(blip.speed,blip.topSpeed) * ACC_FACTOR
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
					-- create entity
					local entity = entities.addCar(blip.x,perspective.minZ+blip.z,false,blip.performanceFraction)
					
					-- set properties
					entity.color = blip.color
					entity.speed = blip.speed
					entity.targetSpeed = entity.speed
					entity.freshFromBlip = true
					
					-- remove blip
					table.remove(list,i)
				-- blip is appearing on the horizon and will be lapped by player
				elseif (math.abs(blip.z) >= (trackLength - (perspective.maxZ - perspective.minZ))) then
					local diff = math.abs(blip.z) - (trackLength - (perspective.maxZ - perspective.minZ));
					
					-- create entity
					local entity = entities.addCar(blip.x,perspective.maxZ-diff,false,blip.performanceFraction)
					
					-- set properties
					entity.color = blip.color
					entity.speed = blip.speed
					entity.targetSpeed = entity.speed
					entity.freshFromBlip = true
					
					-- remove blip
					table.remove(list,i)
				else
					i = i + 1
				end
			-- blip is in front
			else
				-- blip is about to lap player and is appearing behind player
				if (blip.z >= (trackLength - (perspective.maxZ - perspective.minZ))) then
					local diff = blip.z - (trackLength - (perspective.maxZ - perspective.minZ));
				
					-- create entity
					local entity = entities.addCar(blip.x,perspective.minZ,false,blip.performanceFraction)
					
					-- set properties
					entity.color = blip.color
					entity.speed = blip.speed
					entity.targetSpeed = entity.speed
					entity.freshFromBlip = true
					
					-- remove blip
					table.remove(list,i)
				-- blip is appearing on the horizon
				elseif (blip.z <= 0) then
					-- create entity
					local entity = entities.addCar(blip.x,perspective.maxZ+blip.z,false,blip.performanceFraction)
					
					-- set properties
					entity.color = blip.color
					entity.speed = blip.speed
					entity.targetSpeed = entity.speed
					entity.freshFromBlip = true
					
					-- remove blip
					table.remove(list,i)
				else
					i = i + 1
				end
			end		
		else
			blip.new = false
		end
	end
end

return blips