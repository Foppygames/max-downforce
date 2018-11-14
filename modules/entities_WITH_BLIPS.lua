-- Max Downforce - modules/entities.lua
-- 2017-2018 Foppygames

local entities = {}

-- =========================================================
-- includes
-- =========================================================

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")
local utils = require("modules.utils")

-- =========================================================
-- constants
-- =========================================================

entities.TYPE_BUILDING = "building"
entities.TYPE_BANNER_START = "banner_start"
entities.TYPE_CAR = "car"
entities.TYPE_TREE = "tree"
entities.TYPE_SIGN = "sign"
entities.TYPE_STADIUM = "stadium"

local MAX_STEER = 30
local STEER_CHANGE = 45
local STEER_RETURN_FACTOR = 0.96
local TOP_SPEED = 80
local TOP_SPEED_IN_KMH = 360
local BRAKE = 30
local IDLE_BRAKE = 2
local OFF_ROAD_MAX_SPEED = TOP_SPEED * 0.75
local OFF_ROAD_ACC_FACTOR = 0.5

local AI_MIN_PERFORMANCE_FRACTION = 0.3
local AI_MAX_PERFORMANCE_FRACTION = 1.0
local AI_TOP_SPEED = TOP_SPEED * 1.01
local AI_CURVE_SLOWDOWN_FACTOR = 0.05
local AI_BLIP_TOP_SPEED_FACTOR = 0.99
local AI_BLIP_ACC_FACTOR = 0.01
local AI_TARGET_X_MARGIN = road.ROAD_WIDTH / 20

-- =========================================================
-- private variables
-- =========================================================

local list = {}

local images = {}
local baseScale = {}
local blips = {}
local index = nil
local signIndex = 1

local imgBody = nil
local imgFrontWheel = {}
local imgRearWheel = {}
local imgDiffuser = nil
local imgWing = nil
local imgAirScoop = nil
local imgHelmet = nil

local bodyWidth = 0
local bodyHeight = 0
local frontWheelWidth = 0
local frontWheelHeight = 0
local rearWheelWidth = 0
local rearWheelHeight = 0
local wingWidth = 0
local wingHeight = 0
local diffuserWidth = 0
local diffuserHeight = 0
local airScoopWidth = 0
local airScoopHeight = 0
local helmetWidth = 0
local helmetHeight = 0

local frontWheelLeftDx = 0	
local frontWheelRightDx = 0	
local frontWheelDy = 0	
	
-- =========================================================
-- public functions
-- =========================================================

function entities.init()
	images[entities.TYPE_BUILDING] = love.graphics.newImage("images/building.png")
	images[entities.TYPE_BANNER_START] = love.graphics.newImage("images/banner_start.png")
	images[entities.TYPE_CAR] = nil
	images[entities.TYPE_TREE] = {
		love.graphics.newImage("images/tree2.png"),
		love.graphics.newImage("images/tree3.png")
	}
	images[entities.TYPE_SIGN] =  {
		love.graphics.newImage("images/sign1.png"),
		love.graphics.newImage("images/sign2.png"),
		love.graphics.newImage("images/sign3.png")
	}
	images[entities.TYPE_STADIUM] = {
		love.graphics.newImage("images/stadium_left.png"),
		love.graphics.newImage("images/stadium_right.png")
	}
	
	baseScale[entities.TYPE_BUILDING] = 7
	baseScale[entities.TYPE_BANNER_START] = 8
	baseScale[entities.TYPE_CAR] = 2
	baseScale[entities.TYPE_TREE] = 8 --6
	baseScale[entities.TYPE_SIGN] = 12
	baseScale[entities.TYPE_STADIUM] = 14
	
	list = {}
	blips = {}
	
	imgBody = love.graphics.newImage("images/car_body.png")
	for i = 1,4 do
		imgFrontWheel[i] = love.graphics.newImage("images/car_front_wheel_"..i..".png")
		imgRearWheel[i] = love.graphics.newImage("images/car_rear_wheel_"..i..".png")
	end
	imgDiffuser = love.graphics.newImage("images/car_diffuser.png")
	imgWing = love.graphics.newImage("images/car_wing.png")
	imgAirScoop = love.graphics.newImage("images/car_air_scoop.png")
	imgHelmet = love.graphics.newImage("images/car_helmet.png")
	
	bodyWidth = imgBody:getWidth()
	bodyHeight = imgBody:getHeight()
	frontWheelWidth = imgFrontWheel[1]:getWidth()
	frontWheelHeight = imgFrontWheel[1]:getHeight()
	rearWheelWidth = imgRearWheel[1]:getWidth()
	rearWheelHeight = imgRearWheel[1]:getHeight()
	wingWidth = imgWing:getWidth()
	wingHeight = imgWing:getHeight()
	diffuserWidth = imgDiffuser:getWidth()
	diffuserHeight = imgDiffuser:getHeight()
	airScoopWidth = imgAirScoop:getWidth()
	airScoopHeight = imgAirScoop:getHeight()
	helmetWidth = imgHelmet:getWidth()
	helmetHeight = imgHelmet:getHeight()
	
	frontWheelLeftDx = -imgBody:getWidth()/2 + 2 - imgFrontWheel[1]:getWidth()
	frontWheelRightDx = imgBody:getWidth()/2 - 2
	frontWheelDy = -imgFrontWheel[1]:getHeight() - 4
end

function entities.reset()
	list = {}
	blips = {}
end

-- add entity in correct order of increasing z
function entities.add(entityType,x,z)
	local entity = {
		entityType = entityType,
		x = x,
		z = z,
		storedScreenX = -1,
		baseScale = baseScale[entityType],
		scale = 0,
		roadX = 0,
		smoothX = false,
		isBanner = false,
		solid = true
	}
	
	if (entityType ~= entities.TYPE_CAR) then
		if (entityType == entities.TYPE_TREE) then
			entity.image = images[entityType][math.random(2)]
		elseif (entityType == entities.TYPE_STADIUM) then
			if (x < 0) then
				entity.image = images[entityType][1]
			else
				entity.image = images[entityType][2]
			end
		elseif (entityType == entities.TYPE_SIGN) then
			entity.image = images[entityType][signIndex]
			signIndex = signIndex + 1
			if (signIndex > #images[entityType]) then
				signIndex = 1
			end
		else
			entity.image = images[entityType]
		end
		entity.width = entity.image:getWidth()
		entity.height = entity.image:getHeight()
	end
	
	if (entityType == entities.TYPE_BUILDING) then
		entity.smoothX = true
	end
	
	if (entityType == entities.TYPE_TREE) then
		entity.smoothX = true
		entity.x = entity.x + math.random(-aspect.GAME_WIDTH/2,aspect.GAME_WIDTH/2)
	end
	
	if (entityType == entities.TYPE_SIGN) then
		entity.smoothX = true
	end
	
	if (entityType == entities.TYPE_STADIUM) then
		entity.smoothX = true
	end
	
	if (entityType == entities.TYPE_BANNER_START) then
		entity.solid = false
	end

	-- insert at end since most items introduced at horizon (max z)
	table.insert(list,entity)
	
	return entity
end

-- Note: y is unscaled height of banner
function entities.addBanner(entityType,x,y,z)
	local entity = entities.add(entityType,x,z)
	
	entity.isBanner = true
	entity.y = y
	
	return entity
end

function entities.addCar(x,z,isPlayer,aiPerformanceFraction,posToPlayer)
	local entity = entities.add(entities.TYPE_CAR,x,z)
	
	entity.isPlayer = isPlayer
	entity.speed = 0
	entity.steer = 0
	entity.steerResult = 0
	entity.smoothX = false
	entity.posToPlayer = posToPlayer
	
	if (isPlayer) then
		entity.topSpeed = TOP_SPEED
	else
		entity.performanceFraction = aiPerformanceFraction
		entity.topSpeed = entity.performanceFraction * AI_TOP_SPEED
	end
	
	local colorChoices = {0, 0.5, 1}
	entity.color = {
		colorChoices[love.math.random(#colorChoices)],
		colorChoices[love.math.random(#colorChoices)],
		colorChoices[love.math.random(#colorChoices)]
	}
	
	if (isPlayer) then
		entity.color = {
			1,0,0
		}
	end
	
	entity.segmentDdx = 0
	entity.outwardForce = 0
	entity.accEffect = 0
	entity.targetSpeed = 0
	entity.targetX = x
	entity.freshFromBlip = false
	entity.rearWheelIndex = 1
	entity.rearWheelCount = 0
	entity.leftBumpDy = 0
	entity.rightBumpDy = 0
	
	entity.pause = 0
	if (not(isPlayer)) then
		entity.pause = 0 --1000 --300
	end
	
	if (isPlayer) then
		--[[
		entity.sndEngineIdle = love.audio.newSource("sounds/engine_idle.wav","static")
		entity.sndEngineIdle:setLooping(true)
		love.audio.play(entity.sndEngineIdle)
		
		entity.sndEnginePower = love.audio.newSource("sounds/power3.ogg","static")
		entity.sndEnginePower:setLooping(true)
		love.audio.play(entity.sndEnginePower)
		--]]
	end
	
	return entity
end

function entities.addAiCar(x,z,aiNumber,aiTotal,aheadOfPlayer)
	local performanceFraction = AI_MIN_PERFORMANCE_FRACTION + (AI_MAX_PERFORMANCE_FRACTION - AI_MIN_PERFORMANCE_FRACTION) * (aiNumber / aiTotal)
	local posToPlayer
	
	if (aheadOfPlayer) then
		posToPlayer = 1
	else
		posToPlayer = -1
	end
	
	return entities.addCar(x,z,false,performanceFraction,posToPlayer)
end

function entities.addTree(x,z,color)
	local entity = entities.add(entities.TYPE_TREE,x,z)
	
	entity.color = color
	
	return entity
end

local function updateSteerPlayer(entity,dt)
	local steerBackHardFactor = 1
	if love.keyboard.isDown("left") then
		if (entity.steer > 0) then
			steerBackHardFactor = 1 + (2 * entity.steer/MAX_STEER)
		end
		entity.steer = entity.steer - STEER_CHANGE * steerBackHardFactor * dt
		if (entity.steer < -MAX_STEER) then
			entity.steer = -MAX_STEER
		end
	elseif love.keyboard.isDown("right") then
		if (entity.steer < 0) then
			steerBackHardFactor = 1 + math.abs(entity.steer)/MAX_STEER
		end
		entity.steer = entity.steer + STEER_CHANGE * steerBackHardFactor * dt
		if (entity.steer > MAX_STEER) then
			entity.steer = MAX_STEER
		end
	elseif (entity.steer ~= 0) then
		entity.steer = entity.steer * STEER_RETURN_FACTOR
	end
end

local function updateSteerCpu(entity,dt)
	if (entity.x > (entity.targetX + AI_TARGET_X_MARGIN)) then
		entity.steer = entity.steer - STEER_CHANGE * (1 + math.abs(entity.segmentDdx)) * dt
		if (entity.steer < -MAX_STEER) then
			entity.steer = -MAX_STEER
		end
	elseif (entity.x < (entity.targetX - AI_TARGET_X_MARGIN)) then
		entity.steer = entity.steer + STEER_CHANGE * (1 + math.abs(entity.segmentDdx)) * dt
		if (entity.steer > MAX_STEER) then
			entity.steer = MAX_STEER
		end
	elseif (entity.steer ~= 0) then
		entity.steer = entity.steer * STEER_RETURN_FACTOR
	end
end

local function updateSpeedPlayer(entity,acc,dt)
	if love.keyboard.isDown("up") then
		entity.speed = entity.speed + acc * dt
		entity.accEffect = acc
		if (entity.speed > entity.topSpeed) then
			entity.speed = entity.topSpeed
			entity.accEffect = 0
		end
	else
		if (entity.speed > 0) then
			if love.keyboard.isDown("down") then
				entity.speed = entity.speed - BRAKE * dt
				entity.accEffect = -BRAKE
			else
				entity.speed = entity.speed - IDLE_BRAKE * dt
				entity.accEffect = entity.accEffect * 0.9
			end
		end
		if (entity.speed <= 0) then
			entity.speed = 0
			entity.steer = 0
			entity.accEffect = entity.accEffect * 0.6
		end
	end
end

local function updateSpeedCpu(entity,acc,dt)
	if (entity.pause > 0) then
		entity.pause = entity.pause - 1
	else
		if (entity.speed < entity.targetSpeed) then
			entity.speed = entity.speed + acc * dt
			entity.accEffect = acc
			if (entity.speed > entity.topSpeed) then
				entity.speed = entity.topSpeed
				entity.accEffect = 0
			end
		else
			if (entity.speed > 0) then
				--if love.keyboard.isDown("down") then
				entity.speed = entity.speed - BRAKE * dt
				entity.accEffect = -BRAKE
				--else
				--entity.speed = entity.speed - IDLE_BRAKE * dt
				--entity.accEffect = entity.accEffect * 0.9
				--end
			end
			if (entity.speed <= 0) then
				entity.speed = 0
				entity.steer = 0
				entity.accEffect = entity.accEffect * 0.6
			end
		end
	end
end

local function updateSteerResultPlayer(entity)
	local steerUpdateSpeed = 5 --10
	if (entity.steerResult < entity.steer) then
		entity.steerResult = entity.steerResult + steerUpdateSpeed
		if (entity.steerResult > entity.steer) then
			entity.steerResult = entity.steer
		end
	elseif (entity.steerResult > entity.steer) then
		entity.steerResult = entity.steerResult - steerUpdateSpeed
		if (entity.steerResult < entity.steer) then
			entity.steerResult = entity.steer
		end
	end
end

local function updateSteerResultCpu(entity)
	local steerUpdateSpeed = 15
	if (entity.steerResult < entity.steer) then
		entity.steerResult = entity.steerResult + steerUpdateSpeed
		if (entity.steerResult > entity.steer) then
			entity.steerResult = entity.steer
		end
	elseif (entity.steerResult > entity.steer) then
		entity.steerResult = entity.steerResult - steerUpdateSpeed
		if (entity.steerResult < entity.steer) then
			entity.steerResult = entity.steer
		end
	end
end

local function updateOutwardForcePlayer(entity)
	local newOutwardForce = entity.segmentDdx*entity.speed*entity.speed*1.55
	if (math.abs(newOutwardForce) < math.abs(entity.outwardForce)) then
		entity.outwardForce = newOutwardForce
	else
		entity.outwardForce = (14*entity.outwardForce + 1*newOutwardForce) / 15
	end	
end

local function updateOutwardForceCpu(entity)
	local newOutwardForce = entity.segmentDdx*entity.speed*entity.speed*0.9
	if (math.abs(newOutwardForce) < math.abs(entity.outwardForce)) then
		entity.outwardForce = newOutwardForce
	else
		entity.outwardForce = (9*entity.outwardForce + 1*newOutwardForce) / 10
	end	
end

local function getAcceleration(speed,topSpeed)
	if (speed < topSpeed*0.96) then
		return (topSpeed-speed)/6
	else
		return (topSpeed-speed)/14
	end
end

local function updateEngineSoundPlayer(entity)
	--[[
	local gears = 6
	
	local gear = math.floor((entity.speed/entity.topSpeed) / (1.0/gears))
	local gearSpeed = (entity.speed - (gear*(entity.topSpeed/gears))) / (entity.topSpeed/gears)
	
	local steerRateDx = 0.05 * math.abs(entity.steer) / MAX_STEER
	
	local rate = (0.4 + (gear+1) * 2.0  / 12 + gearSpeed * 0.8) * 0.5 + math.random() / 35
	
	entity.sndEngineIdle:setPitch(rate*3)
	entity.sndEnginePower:setPitch(rate)
	--]]
end

local function updateOffRoad(entity,dt)
	local offRoad = false
	local maxDistBeforeCurb = road.ROAD_WIDTH*0.30
	local maxDistBeforeGrass = road.ROAD_WIDTH*0.40
	
	if (entity.leftBumpDy < 0) then
		entity.leftBumpDy = entity.leftBumpDy + entity.speed/2 * dt
		if (entity.leftBumpDy > 0) then
			entity.leftBumpDy = 0
		end
	end
	
	if (entity.rightBumpDy < 0) then
		entity.rightBumpDy = entity.rightBumpDy + entity.speed/2 * dt
		if (entity.rightBumpDy > 0) then
			entity.rightBumpDy = 0
		end
	end
	
	if (entity.x < -maxDistBeforeCurb) then
		if (entity.leftBumpDy == 0) then
			entity.leftBumpDy = -1
		end
		if (entity.x < -maxDistBeforeGrass) then
			offRoad = true
		end
	elseif (entity.x > maxDistBeforeCurb) then
		if (entity.rightBumpDy == 0) then
			entity.rightBumpDy = -1
		end
		if (entity.x > maxDistBeforeGrass) then
			offRoad = true
		end
	end
	
	if (offRoad) then
		if (entity.speed > OFF_ROAD_MAX_SPEED) then
			entity.speed = entity.speed - BRAKE * dt
		end
	end
	
	return offRoad
end

local function checkCarCollisions(entity,player,dt)
	local carLength = perspective.maxZ / 50
	local i = 1
	while i <= #list do
		local other = list[i]
		
		-- other is not entity
		if (other ~= entity) then
		
			-- other is not car
			if (other.entityType ~= entities.TYPE_CAR) then
		
				-- other is solid
				if (other.solid) then
		
					-- collision on z
					if ((entity.z < other.z) and ((entity.z + carLength) >= other.z)) then
					
						local dX = math.abs(other.x - entity.x)
						
						local totalCarWidth = (bodyWidth + frontWheelWidth * 2) * entity.baseScale
						
						-- collision on x
						if (dX < (other.width * other.baseScale / 2 + totalCarWidth / 2)) then 
							entity.speed = 0
							entity.acc = 0
							
							return true
						end
						
					end
				
				end
				
			end
			
		end
		
		i = i + 1
	end	
	
	return false
end

local function updateCar(entity,player,dt)
	local steerSpeed = aspect.GAME_WIDTH
	
	local offRoad = updateOffRoad(entity,dt)
		
	local acc = getAcceleration(entity.speed,entity.topSpeed)

	if (offRoad) then
		acc = acc * OFF_ROAD_ACC_FACTOR
	end
	
	local collided = checkCarCollisions(entity,player,dt)
	
	if (entity == player) then
		updateSteerPlayer(entity,dt)
		if (not collided) then
			updateSpeedPlayer(entity,acc,dt)
		end
		updateSteerResultPlayer(entity)
		updateOutwardForcePlayer(entity)
		updateEngineSoundPlayer(entity)
	else
		updateSteerCpu(entity,dt)
		updateSpeedCpu(entity,acc,dt)
		updateSteerResultCpu(entity)
		updateOutwardForceCpu(entity)
		
		entity.z = entity.z + entity.speed * dt
	end
	
	-- update wheel animation
	if (entity.speed > 0) then
		entity.rearWheelCount = entity.rearWheelCount + entity.speed * dt
		if (entity.rearWheelCount > 1.1) then
			entity.rearWheelCount = 0
			entity.rearWheelIndex = entity.rearWheelIndex + 1
			if (entity.rearWheelIndex > 4) then
				entity.rearWheelIndex = 1
			end
		end
	end
	
	-- apply outward force to x
	entity.x = entity.x - entity.outwardForce
	
	-- apply steer result to x
	entity.x = entity.x + entity.steerResult
end

local function update(entity,player,dt)
	if (entity.entityType == entities.TYPE_CAR) then
		updateCar(entity,player,dt)
		--checkCarCollisions(entity,player,dt)
	end
end

local function addBlip(x,z,speed,color,performanceFraction)
	local blip = {
		x = x,
		z = z,
		speed = speed,
		color = color,
		performanceFraction = performanceFraction,
		topSpeed = performanceFraction * AI_BLIP_TOP_SPEED_FACTOR * AI_TOP_SPEED,
		new = true
	}
	table.insert(blips,blip)
end

function entities.update(playerSpeed,dt,player,trackLength)
	local lap = false
	
	-- update entities
	local i = 1
	while i <= #list do
		local entity = list[i]
		
		-- update
		update(entity,player,dt)
		
		-- scroll based on player speed
		if (entity ~= player) then
			entity.z = entity.z - playerSpeed * dt
			if ((entity.z < perspective.minZ) or (entity.z > perspective.maxZ)) then
				if (entity.entityType == entities.TYPE_CAR) then
					-- create blip
					if (entity.z < perspective.minZ) then
						addBlip(entity.x,entity.z-perspective.minZ,entity.speed,entity.color,entity.performanceFraction)
					else
						addBlip(entity.x,entity.z-perspective.maxZ,entity.speed,entity.color,entity.performanceFraction)
					end
				end
				
				-- entity is start finish banner; count lap
				if (entity.entityType == entities.TYPE_BANNER_START) then
					lap = true
				end
				
				-- remove entity
				table.remove(list,i)
			else
				i = i + 1
			end
		else
			i = i + 1
		end
	end
	
	-- update blips
	i = 1
	while i <= #blips do
		local blip = blips[i]
		if (not(blip.new)) then
			local acc = getAcceleration(blip.speed,blip.topSpeed) * AI_BLIP_ACC_FACTOR
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
					table.remove(blips,i)
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
					table.remove(blips,i)
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
					table.remove(blips,i)
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
					table.remove(blips,i)
				else
					i = i + 1
				end
			end		
		else
			blip.new = false
		end
	end
	
	-- sort all entities on increasing z
	table.sort(list,function(a,b) return a.z < b.z end)
	
	return lap
end

function entities.resetForDraw()
	index = 1
end

function entities.setupForDraw(z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
	while (index <= #list) and (list[index].z <= z) do
		local fractionTowardsZ = (list[index].z - previousZ) / (z - previousZ)
		local fractionRemaining = 1 - fractionTowardsZ
		list[index].roadX = fractionTowardsZ * roadX + fractionRemaining * previousRoadX
		list[index].screenY = fractionTowardsZ * screenY + fractionRemaining * previousScreenY
		list[index].scale = fractionTowardsZ * scale + fractionRemaining * previousScale
		if (list[index].entityType == entities.TYPE_CAR) then
			list[index].segmentDdx = segment.ddx
			list[index].targetSpeed = list[index].topSpeed - (math.abs(segment.ddxFraction) * list[index].topSpeed * AI_CURVE_SLOWDOWN_FACTOR)
			if (list[index].freshFromBlip) then
				list[index].freshFromBlip = false
				if (list[index].speed > list[index].targetSpeed) then
					list[index].speed = list[index].targetSpeed
				end
			end
		end
		index = index + 1
	end
end

local function drawCar(entity,newScreenX,imageScale)
	local screenX = newScreenX/imageScale
	local screenY = entity.screenY/imageScale
	local bumpDy = 0
	
	if ((entity.leftBumpDy ~= 0) or (entity.rightBumpDy ~= 0)) then
		bumpDy = (entity.leftBumpDy + entity.rightBumpDy) * 0.3
		screenY = screenY + bumpDy
	end
	
	local maxSteerPerspectiveEffect = 7
	local steerPerspectiveEffect = entity.steer / MAX_STEER * maxSteerPerspectiveEffect
	
	--local perspectiveEffect = (aspect.GAME_WIDTH/2-newScreenX)/(aspect.GAME_WIDTH/2) * 7 + steerPerspectiveEffect
	local perspectiveEffect = (aspect.GAME_WIDTH/2-newScreenX)/(aspect.GAME_WIDTH/2) * 9 + steerPerspectiveEffect
	
	local testDy = -imgFrontWheel[1]:getHeight() - 4 * imageScale
	
	local accEffect = entity.accEffect * 0.01
	
	-- draw front wheels
	love.graphics.draw(imgFrontWheel[entity.rearWheelIndex],screenX + frontWheelLeftDx + perspectiveEffect,screenY + testDy - accEffect*2 + entity.leftBumpDy) --frontWheelDy)
	love.graphics.draw(imgFrontWheel[entity.rearWheelIndex],screenX + frontWheelRightDx + perspectiveEffect,screenY + testDy - accEffect*2 + entity.rightBumpDy) --frontWheelDy)
	
	love.graphics.setColor(entity.color)
	
	-- draw body
	love.graphics.draw(imgBody,screenX - bodyWidth/2 - perspectiveEffect * 0.2,screenY - bodyHeight + accEffect)
	
	love.graphics.setColor(1,1,1)
	
	-- draw helmet
	love.graphics.draw(imgHelmet,screenX - helmetWidth/2  - perspectiveEffect * 0.2,screenY - bodyHeight - helmetHeight + accEffect)
	
	love.graphics.setColor(entity.color)
	
	-- draw air scoop
	love.graphics.draw(imgAirScoop,screenX - airScoopWidth/2  - perspectiveEffect * 0.6,screenY - bodyHeight - airScoopHeight + accEffect)
	
	love.graphics.setColor(1,1,1)
	
	-- draw rear wheels
	love.graphics.draw(imgRearWheel[entity.rearWheelIndex],screenX - bodyWidth/2 - rearWheelWidth - perspectiveEffect,screenY - rearWheelHeight + entity.leftBumpDy)
	love.graphics.draw(imgRearWheel[entity.rearWheelIndex],screenX + bodyWidth/2 - perspectiveEffect,screenY - rearWheelHeight + entity.rightBumpDy)
	
	-- draw rear wing
	love.graphics.draw(imgWing,screenX - wingWidth/2  - perspectiveEffect * 1.2,screenY - bodyHeight + 4 - wingHeight + accEffect*2.5 + bumpDy)
	
	-- draw engine
	-- ...
	
	-- draw difuser
	love.graphics.draw(imgDiffuser,screenX - diffuserWidth/2  - perspectiveEffect,screenY - diffuserHeight + accEffect*3)
end

local function drawBanner(entity,newScreenX,imageScale)
	local bannerX = newScreenX/imageScale - entity.width/2
	local bannerY = entity.screenY/imageScale - entity.y
	love.graphics.draw(entity.image,bannerX,bannerY)
	love.graphics.setColor(1,1,1)
	local width = 1
	local x1 = bannerX - width
	love.graphics.rectangle("fill",x1,bannerY,width,entity.y)
	love.graphics.rectangle("fill",x1+entity.width+width,bannerY,width,entity.y)
end

function entities.draw()
	for i = #list,1,-1 do
		local entity = list[i]
		local imageScale = entity.baseScale * entity.scale
		local newScreenX = entity.roadX + entity.x * entity.scale
		if (entity.smoothX) then
			--if (entity.screenY < 170) then
				if (entity.storedScreenX ~= -1) then
					--newScreenX = (newScreenX + entity.storedScreenX * 3) / 4
					newScreenX = (newScreenX + entity.storedScreenX * 1) / 2
				end
			--end
		end
		love.graphics.push()
		love.graphics.scale(imageScale,imageScale)
		if (entity.entityType == entities.TYPE_TREE) then
			love.graphics.setColor(entity.color,entity.color,entity.color)
		else
			love.graphics.setColor(1,1,1)
		end
		if (entity.entityType == entities.TYPE_CAR) then
			drawCar(entity,newScreenX,imageScale)
		elseif (entity.isBanner) then
			drawBanner(entity,newScreenX,imageScale)
		else
			love.graphics.draw(entity.image,newScreenX/imageScale - entity.width/2,entity.screenY/imageScale - entity.height)
		end
		love.graphics.pop()
		entity.storedScreenX = newScreenX
	end
end

-- Note: currently ai top speed same as player top speed in kmh even though actual ai top speed is lower
function entities.getSpeedAsKMH(entity)
	return math.floor(entity.speed / entity.topSpeed * TOP_SPEED_IN_KMH)
end

return entities