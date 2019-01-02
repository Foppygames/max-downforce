-- Max Downforce - classes/car.lua
-- 2018 Foppygames

-- modules
local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")

-- classes
require "classes.entity"

-- local constants
local MAX_STEER = 30
local STEER_CHANGE = 45
local STEER_RETURN_FACTOR = 0.96
local TOP_SPEED = 80
local TOP_SPEED_IN_KMH = 360
local BRAKE = 30
local IDLE_BRAKE = 2
local OFF_ROAD_MAX_SPEED = TOP_SPEED * 0.75
local OFF_ROAD_ACC_FACTOR = 0.5
local AI_MIN_PERFORMANCE_FRACTION = 0.40
local AI_MAX_PERFORMANCE_FRACTION = 0.95
local AI_PERFORMANCE_FRACTION_RANDOM_RANGE = 0.10
local AI_TOP_SPEED = TOP_SPEED * 1.01
local AI_CURVE_SLOWDOWN_FACTOR = 0.05
local AI_TARGET_X_MARGIN = road.ROAD_WIDTH / 20
local AI_STEER_RETURN_FACTOR = STEER_RETURN_FACTOR * 0.90

-- local variables
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

-- car is based on entity
Car = Entity:new()

function Car.init()
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

function Car.getAiPerformanceFraction(aiNumber,aiTotal)
	local standard = AI_MIN_PERFORMANCE_FRACTION + (AI_MAX_PERFORMANCE_FRACTION - AI_MIN_PERFORMANCE_FRACTION) * (aiNumber / aiTotal)
	local randomized = standard - AI_PERFORMANCE_FRACTION_RANDOM_RANGE/2 + math.random() * AI_PERFORMANCE_FRACTION_RANDOM_RANGE
	
	if (randomized < AI_MIN_PERFORMANCE_FRACTION) then
		randomized = AI_MIN_PERFORMANCE_FRACTION
	end

	if (randomized > AI_MAX_PERFORMANCE_FRACTION) then
		randomized = AI_MAX_PERFORMANCE_FRACTION
	end
	
	return randomized
end

function Car:new(x,z,isPlayer,performanceFraction)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.isPlayer = isPlayer
	o.performanceFraction = performanceFraction

	o.speed = 0
	o.steer = 0
	o.steerResult = 0
	o.smoothX = false
	o.sndEngineIdle = nil
	o.sndEnginePower = nil
	o.explodeCount = 0
	o.posToPlayer = 0
		
	if (o.isPlayer) then
		o.color = {1,0,0}
		o.pause = 0
		o.topSpeed = TOP_SPEED
		
		o.sndEngineIdle = love.audio.newSource("sounds/engine_idle.wav","static")
		o.sndEngineIdle:setLooping(true)
		o.sndEngineIdle:setVolume(1)
		love.audio.play(o.sndEngineIdle)
		
		o.sndEnginePower = love.audio.newSource("sounds/power3.ogg","static")
		o.sndEnginePower:setLooping(true)
		o.sndEnginePower:setVolume(0.5)
		love.audio.play(o.sndEnginePower)
	else
		local colorChoices = {0, 0.5, 1}
		o.color = {
			colorChoices[love.math.random(#colorChoices)],
			colorChoices[love.math.random(#colorChoices)],
			colorChoices[love.math.random(#colorChoices)]
		}
		o.pause = 2
		o.topSpeed = o.performanceFraction * AI_TOP_SPEED
	end
	
	o.segmentDdx = 0
	o.outwardForce = 0
	o.accEffect = 0
	o.targetSpeed = 0
	o.targetX = x
	o.freshFromBlip = false
	o.rearWheelIndex = 1
	o.rearWheelCount = 0
	o.leftBumpDy = 0
	o.rightBumpDy = 0
	o.baseScale = 2
	o.collided = false
	
	return o
end

function Car:updateOffRoad(dt)
	local offRoad = false
	local maxDistBeforeCurb = road.ROAD_WIDTH*0.30
	local maxDistBeforeGrass = road.ROAD_WIDTH*0.40
	
	if (self.leftBumpDy < 0) then
		self.leftBumpDy = self.leftBumpDy + self.speed/2 * dt
		if (self.leftBumpDy > 0) then
			self.leftBumpDy = 0
		end
	end
	
	if (self.rightBumpDy < 0) then
		self.rightBumpDy = self.rightBumpDy + self.speed/2 * dt
		if (self.rightBumpDy > 0) then
			self.rightBumpDy = 0
		end
	end
	
	if (self.x < -maxDistBeforeCurb) then
		if (self.leftBumpDy == 0) then
			self.leftBumpDy = -1
		end
		if (self.x < -maxDistBeforeGrass) then
			offRoad = true
		end
	elseif (self.x > maxDistBeforeCurb) then
		if (self.rightBumpDy == 0) then
			self.rightBumpDy = -1
		end
		if (self.x > maxDistBeforeGrass) then
			offRoad = true
		end
	end
	
	if (offRoad) then
		if (self.speed > OFF_ROAD_MAX_SPEED) then
			self.speed = self.speed - BRAKE * dt
		end
	end
	
	return offRoad
end

-- Note: static function that is also used by blips
function Car.getAcceleration(speed,topSpeed)
	local standardDiff = TOP_SPEED-speed
	if (standardDiff < 0) then
		standardDiff = 0
	end

	local carDiff = topSpeed-speed
	
	local averagedDiff = (3*standardDiff + carDiff) / 4
	
	if (speed < topSpeed*0.96) then
		return averagedDiff / 6
	else
		return averagedDiff / 14
	end
end

function Car.getBaseTotalCarWidth()
	return (bodyWidth + frontWheelWidth * 2)
end

function Car:updateSteerPlayer(dt)
	local steerBackHardFactor = 1
	if love.keyboard.isDown("left") then
		if (self.steer > 0) then
			steerBackHardFactor = 1 + (2 * self.steer/MAX_STEER)
		end
		self.steer = self.steer - STEER_CHANGE * steerBackHardFactor * dt
		if (self.steer < -MAX_STEER) then
			self.steer = -MAX_STEER
		end
	elseif love.keyboard.isDown("right") then
		if (self.steer < 0) then
			steerBackHardFactor = 1 + math.abs(self.steer)/MAX_STEER
		end
		self.steer = self.steer + STEER_CHANGE * steerBackHardFactor * dt
		if (self.steer > MAX_STEER) then
			self.steer = MAX_STEER
		end
	elseif (self.steer ~= 0) then
		self.steer = self.steer * STEER_RETURN_FACTOR
	end
end

function Car:updateSteerCpu(dt)
	if (self.x > (self.targetX + AI_TARGET_X_MARGIN)) then
		self.steer = self.steer - STEER_CHANGE * (1 + math.abs(self.segmentDdx)) * dt
		if (self.steer < -MAX_STEER) then
			self.steer = -MAX_STEER
		end
	elseif (self.x < (self.targetX - AI_TARGET_X_MARGIN)) then
		self.steer = self.steer + STEER_CHANGE * (1 + math.abs(self.segmentDdx)) * dt
		if (self.steer > MAX_STEER) then
			self.steer = MAX_STEER
		end
	elseif (self.steer ~= 0) then
		self.steer = self.steer * AI_STEER_RETURN_FACTOR
	end
end

function Car:updateSteer(dt)
	if (self.isPlayer) then
		self:updateSteerPlayer(dt)
	else
		self:updateSteerCpu(dt)
	end
end

function Car:updateSpeedPlayer(acc,dt)
	if love.keyboard.isDown("up") then
		self.speed = self.speed + acc * dt
		self.accEffect = acc
		if (self.speed > self.topSpeed) then
			self.speed = self.topSpeed
			self.accEffect = 0
		end
	else
		if (self.speed > 0) then
			if love.keyboard.isDown("down") then
				self.speed = self.speed - BRAKE * dt
				self.accEffect = -BRAKE
			else
				self.speed = self.speed - IDLE_BRAKE * dt
				self.accEffect = self.accEffect * 0.9
			end
		end
		if (self.speed <= 0) then
			self.speed = 0
			self.steer = 0
			self.accEffect = self.accEffect * 0.6
		end
	end
end

function Car:updateSpeedCPU(acc,dt)
	if (self.pause > 0) then
		self.pause = self.pause - 1 * dt
	else
		if (self.speed < self.targetSpeed) then
			self.speed = self.speed + acc * dt
			self.accEffect = acc
			if (self.speed > self.topSpeed) then
				self.speed = self.topSpeed
				self.accEffect = 0
			end
		else
			if (self.speed > 0) then
				self.speed = self.speed - BRAKE * dt
				self.accEffect = -BRAKE
			end
			if (self.speed <= 0) then
				self.speed = 0
				self.steer = 0
				self.accEffect = self.accEffect * 0.6
			end
		end
	end
end

function Car:updateSpeed(acc,dt)
	if (self.isPlayer) then
		self:updateSpeedPlayer(acc,dt)
	else
		self:updateSpeedCPU(acc,dt)
	end
end

function Car:updateWheelAnimation(dt)
	if (self.speed > 0) then
		self.rearWheelCount = self.rearWheelCount + self.speed * dt
		if (self.rearWheelCount > 1.1) then
			self.rearWheelCount = 0
			self.rearWheelIndex = self.rearWheelIndex + 1
			if (self.rearWheelIndex > 4) then
				self.rearWheelIndex = 1
			end
		end
	end
end

function Car:updateSteerResultPlayer()
	local steerUpdateSpeed = 5 --10
	if (self.steerResult < self.steer) then
		self.steerResult = self.steerResult + steerUpdateSpeed
		if (self.steerResult > self.steer) then
			self.steerResult = self.steer
		end
	elseif (self.steerResult > self.steer) then
		self.steerResult = self.steerResult - steerUpdateSpeed
		if (self.steerResult < self.steer) then
			self.steerResult = self.steer
		end
	end
end

function Car:updateSteerResultCpu()
	local steerUpdateSpeed = 15
	if (self.steerResult < self.steer) then
		self.steerResult = self.steerResult + steerUpdateSpeed
		if (self.steerResult > self.steer) then
			self.steerResult = self.steer
		end
	elseif (self.steerResult > self.steer) then
		self.steerResult = self.steerResult - steerUpdateSpeed
		if (self.steerResult < self.steer) then
			self.steerResult = self.steer
		end
	end
end

function Car:updateSteerResult()
	if (self.isPlayer) then
		self:updateSteerResultPlayer()
	else
		self:updateSteerResultCpu()
	end
end

function Car:updateOutwardForcePlayer()
	local newOutwardForce = self.segmentDdx*self.speed*self.speed*1.55
	if (math.abs(newOutwardForce) < math.abs(self.outwardForce)) then
		self.outwardForce = newOutwardForce
	else
		self.outwardForce = (14*self.outwardForce + 1*newOutwardForce) / 15
	end	
end

function Car:updateOutwardForceCpu()
	local newOutwardForce = self.segmentDdx*self.speed*self.speed*0.9
	if (math.abs(newOutwardForce) < math.abs(self.outwardForce)) then
		self.outwardForce = newOutwardForce
	else
		self.outwardForce = (9*self.outwardForce + 1*newOutwardForce) / 10
	end	
end

function Car:updateOutwardForce()
	if (self.isPlayer) then
		self:updateOutwardForcePlayer()
	else
		self:updateOutwardForceCpu()
	end
end

function Car:updateEngineSound()
	local gears = 7
	local gear = math.floor((self.speed/self.topSpeed) / (1.0/gears))
	local gearSpeed = (self.speed - (gear*(self.topSpeed/gears))) / (self.topSpeed/gears)
	local steerRateDx = 0.05 * math.abs(self.steer) / MAX_STEER
	local ratePower = (0.4 + (gear+1) * 2.0  / 12 + gearSpeed * 0.8) * 0.5 + math.random() / 35
	local rateIdle = 1 + 1.5 * (self.speed/self.topSpeed) + math.random() / 10
	self.sndEngineIdle:setPitch(rateIdle)
	self.sndEnginePower:setPitch(ratePower)
end

function Car:update(dt)
	local offRoad = self:updateOffRoad(dt)
	local acc = Car.getAcceleration(self.speed,self.topSpeed)

	if (offRoad) then
		acc = acc * OFF_ROAD_ACC_FACTOR
	end
	
	self:updateSteer(dt)
	
	-- collided is managed by entities module
	if (not self.collided) then
		self:updateSpeed(acc,dt)
	end
	
	self:updateSteerResult()
	self:updateOutwardForce()
	
	if (self.isPlayer) then
		self:updateEngineSound()
	else
		self.z = self.z + self.speed * dt
	end
	
	self:updateWheelAnimation(dt)
	
	-- apply outward force to x
	self.x = self.x - self.outwardForce
	
	-- apply steer result to x
	self.x = self.x + self.steerResult
end

function Car:scroll(playerSpeed,dt)
	local blip = nil
	local lap = false
	local delete = false
	
	if (not self.isPlayer) then
		self.z = self.z - playerSpeed * dt
		if ((self.z < perspective.minZ) or (self.z > perspective.maxZ)) then
			-- create blip
			if (self.z < perspective.minZ) then
				blip = {
					x = self.x,
					z = self.z-perspective.minZ,
					speed = self.speed,
					aiTopSpeed = AI_TOP_SPEED,
					color = self.color,
					performanceFraction = self.performanceFraction,
					posToPlayer = self.posToPlayer + 1,
					pause = self.pause
				}
			else
				blip = {
					x = self.x,
					z = self.z-perspective.maxZ,
					speed = self.speed,
					aiTopSpeed = AI_TOP_SPEED,
					color = self.color,
					performanceFraction = self.performanceFraction,
					posToPlayer = self.posToPlayer - 1,
					pause = self.pause
				}
			end
			
			-- remove car
			delete = true
		end
	end
	
	return {
		blip = blip,
		lap = lap,
		delete = delete
	}
end

function Car:selectNewLane(collisionX)
	if (collisionX < 0) then
		self.targetX = road.ROAD_WIDTH/4
	else
		self.targetX = -road.ROAD_WIDTH/4
	end
end

function Car:setupForDraw(z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
	Entity.setupForDraw(self,z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
	
	self.segmentDdx = segment.ddx
	self.targetSpeed = self.topSpeed - (math.abs(segment.ddxFraction) * self.topSpeed * AI_CURVE_SLOWDOWN_FACTOR)
	if (self.freshFromBlip) then
		self.freshFromBlip = false
		if (self.speed > self.targetSpeed) then
			self.speed = self.targetSpeed
		end
	end
end

function Car:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.setColor(1,1,1)
	
	local screenX = newScreenX/imageScale
	local screenY = self.screenY/imageScale
	local bumpDy = 0
	
	if ((self.leftBumpDy ~= 0) or (self.rightBumpDy ~= 0)) then
		bumpDy = (self.leftBumpDy + self.rightBumpDy) * 0.3
		screenY = screenY + bumpDy
	end
	
	local maxSteerPerspectiveEffect = 7
	local steerPerspectiveEffect = self.steer / MAX_STEER * maxSteerPerspectiveEffect
	local perspectiveEffect = (aspect.GAME_WIDTH/2-newScreenX)/(aspect.GAME_WIDTH/2) * 9 + steerPerspectiveEffect
	local frontWheelDy = -imgFrontWheel[1]:getHeight() - 4 * imageScale
	local accEffect = self.accEffect * 0.01
	
	-- draw front wheels
	love.graphics.draw(imgFrontWheel[self.rearWheelIndex],screenX + frontWheelLeftDx + perspectiveEffect,screenY + frontWheelDy - accEffect*2 + self.leftBumpDy) --frontWheelDy)
	love.graphics.draw(imgFrontWheel[self.rearWheelIndex],screenX + frontWheelRightDx + perspectiveEffect,screenY + frontWheelDy - accEffect*2 + self.rightBumpDy) --frontWheelDy)
	
	-- draw body
	love.graphics.setColor(self.color)
	love.graphics.draw(imgBody,screenX - bodyWidth/2 - perspectiveEffect * 0.2,screenY - bodyHeight + accEffect)
	
	-- draw helmet
	love.graphics.setColor(1,1,1)
	love.graphics.draw(imgHelmet,screenX - helmetWidth/2  - perspectiveEffect * 0.2,screenY - bodyHeight - helmetHeight + accEffect)
	
	-- draw air scoop
	love.graphics.setColor(self.color)
	love.graphics.draw(imgAirScoop,screenX - airScoopWidth/2  - perspectiveEffect * 0.6,screenY - bodyHeight - airScoopHeight + accEffect)
	
	-- draw rear wheels
	love.graphics.setColor(1,1,1)
	love.graphics.draw(imgRearWheel[self.rearWheelIndex],screenX - bodyWidth/2 - rearWheelWidth - perspectiveEffect,screenY - rearWheelHeight + self.leftBumpDy)
	love.graphics.draw(imgRearWheel[self.rearWheelIndex],screenX + bodyWidth/2 - perspectiveEffect,screenY - rearWheelHeight + self.rightBumpDy)
	
	-- draw rear wing
	love.graphics.draw(imgWing,screenX - wingWidth/2  - perspectiveEffect * 1.2,screenY - bodyHeight + 4 - wingHeight + accEffect*2.5 + bumpDy)
	
	-- draw diffuser
	love.graphics.draw(imgDiffuser,screenX - diffuserWidth/2  - perspectiveEffect,screenY - diffuserHeight + accEffect*3)
	
	love.graphics.pop()
	self.storedScreenX = newScreenX
end

-- Note: currently ai top speed same as player top speed in kmh even though actual ai top speed may be lower
function Car:getSpeedAsKMH()
	return math.floor(self.speed / self.topSpeed * TOP_SPEED_IN_KMH)
end

-- used to turn player into cpu car after finish
function Car:setIsPlayer(isPlayer)
	self.isPlayer = isPlayer
end

function Car:isCar()
	return true
end
