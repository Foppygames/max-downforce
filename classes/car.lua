-- Max Downforce - classes/car.lua
-- 2018-2019 Foppygames

-- modules
local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")
local sound = require("modules.sound")

-- classes
require "classes.entity"

-- local constants
local WIDTH_MODIFIER = 0.85
local MAX_STEER = 40
local STEER_CHANGE = 48
local STEER_RETURN_FACTOR = 0.955
local TOP_SPEED = 90
local TOP_SPEED_IN_KMH = 360
local BRAKE = 40
local IDLE_BRAKE = 2
local MAX_DIST_BEFORE_CURB = road.ROAD_WIDTH*0.35
local MAX_DIST_BEFORE_GRASS = road.ROAD_WIDTH*0.45
local OFF_ROAD_MAX_SPEED = TOP_SPEED * 0.75
local OFF_ROAD_ACC_FACTOR = 0.5
local AI_MIN_PERFORMANCE_FRACTION = 0.65
local AI_MAX_PERFORMANCE_FRACTION = 0.92
local AI_TOP_SPEED = TOP_SPEED
local AI_TARGET_X_MARGIN = road.ROAD_WIDTH / 25 --30
local AI_MAX_STEER = MAX_STEER * 0.9
local AI_STEER_CHANGE = STEER_CHANGE * 0.9
local AI_STEER_RETURN_FACTOR = STEER_RETURN_FACTOR * 0.7

-- local variables
local imgBody = nil
local imgFrontWheel = {}
local imgRearWheel = {}
local imgDiffuser = nil
local imgWing = nil
local imgAirScoop = nil
local imgHelmet = nil
local imgShadow = nil
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
local shadowWidth = 0
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
	imgShadow = love.graphics.newImage("images/shadow.png")

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
	shadowWidth = imgShadow:getWidth()
	frontWheelLeftDx = -imgBody:getWidth()/2 + 2 - imgFrontWheel[1]:getWidth()
	frontWheelRightDx = imgBody:getWidth()/2 - 2
	frontWheelDy = -imgFrontWheel[1]:getHeight() - 4
end

function Car:new(lane,z,isPlayer,progress)
	local x = Car.getXFromLane(lane,true)
	
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.isPlayer = isPlayer
	
	o.name = "CAR"
	
	local fastCar
		
	if (not isPlayer) then
		fastCar = (math.random() > 0.9)
		if (fastCar) then
			progress = math.min(1, progress + 0.2 + math.random() * 0.3)
		else
			progress = math.min(1, progress + 0.2)
		end
		o.performanceFraction = AI_MIN_PERFORMANCE_FRACTION + (AI_MAX_PERFORMANCE_FRACTION - AI_MIN_PERFORMANCE_FRACTION) * progress
	else
		o.performanceFraction = 1
	end
	
	o.speed = 0
	o.steer = 0
	o.steerResult = 0
	o.smoothX = false
	o.sndEngineIdle = nil
	o.sndEnginePower = nil
	o.explodeCount = 0
	o.aiBlockingCarSpeed = nil
	o.pause = 2
			
	if (o.isPlayer) then
		o.color = {1,0,0}
		o.topSpeed = TOP_SPEED
		
		o.sndEngineIdle = sound.getClone(sound.ENGINE_IDLE)
		o.sndEngineIdle:setVolume(0.1) --(1)
		love.audio.play(o.sndEngineIdle)
		
		o.sndEnginePower = sound.getClone(sound.ENGINE_POWER)
		o.sndEnginePower:setVolume(0.05) --(0.5)
		love.audio.play(o.sndEnginePower)
		
		o.gears = 7
	else
		local colorChoices = {0,0.5,1}
		
		o.color = {
			colorChoices[math.random(#colorChoices)],
			colorChoices[math.random(#colorChoices)],
			colorChoices[math.random(#colorChoices)]
		}
		
		if (fastCar) then
			o.color = {1,1,1}
		end
		
		o.topSpeed = o.performanceFraction * AI_TOP_SPEED
		
		o.sndEnginePower = sound.getClone(sound.ENGINE_POWER)
		o.sndEnginePower:setVolume(0)
		love.audio.play(o.sndEnginePower)
		
		o.gears = math.random(3,8)
	end
	
	o.segmentDdx = 0
	o.outwardForce = 0
	o.accEffect = 0
	o.targetSpeed = 0
	o.targetX = x
	o.rearWheelIndex = 1
	o.rearWheelCount = 0
	o.leftBumpDy = 0
	o.rightBumpDy = 0
	o.baseScale = 2
	o.collided = false
	
	return o
end

function Car.getXFromLane(lane,random)
	if (random) then
		return lane * road.ROAD_WIDTH / (5 + math.random())
	else
		return lane * road.ROAD_WIDTH / 5
	end
end

function Car:updateOffRoad(dt)
	local offRoad = false
	
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
	
	if (self.x < -MAX_DIST_BEFORE_CURB) then
		if (self.leftBumpDy == 0) then
			self.leftBumpDy = -1
		end
		if (self.x < -MAX_DIST_BEFORE_GRASS) then
			offRoad = true
		end
	elseif (self.x > MAX_DIST_BEFORE_CURB) then
		if (self.rightBumpDy == 0) then
			self.rightBumpDy = -1
		end
		if (self.x > MAX_DIST_BEFORE_GRASS) then
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

function Car:getAcceleration()
	local standardDiff = TOP_SPEED-self.speed
	if (standardDiff < 0) then
		standardDiff = 0
	end

	local carDiff = self.topSpeed - self.speed
	
	local averagedDiff = (3*standardDiff + carDiff) / 4
	
	if (self.speed < self.topSpeed*0.96) then
		return averagedDiff / 6
	else
		return averagedDiff / 14
	end
end

function Car.getBaseTotalCarWidth()
	return (bodyWidth + frontWheelWidth * 2) * WIDTH_MODIFIER
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
	-- stay on track
	if (self.x < -MAX_DIST_BEFORE_CURB) then
		self.targetX = -road.ROAD_WIDTH/4
	elseif (self.x > MAX_DIST_BEFORE_CURB) then
		self.targetX = road.ROAD_WIDTH/4
	end

	-- steer towards target
	if (self.x > (self.targetX + AI_TARGET_X_MARGIN)) then
		self.steer = self.steer - AI_STEER_CHANGE * (1 + math.abs(self.segmentDdx)) * dt
		if (self.steer < -AI_MAX_STEER) then
			self.steer = -AI_MAX_STEER
		end
	elseif (self.x < (self.targetX - AI_TARGET_X_MARGIN)) then
		self.steer = self.steer + AI_STEER_CHANGE * (1 + math.abs(self.segmentDdx)) * dt
		if (self.steer > AI_MAX_STEER) then
			self.steer = AI_MAX_STEER
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
	if (self.pause > 0) then
		self.pause = self.pause - dt
	else
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
end

function Car:updateSpeedCPU(acc,dt)
	if (self.pause > 0) then
		self.pause = self.pause - dt
	else
		if (self.aiBlockingCarSpeed ~= nil) then
			if (self.speed > self.aiBlockingCarSpeed) then
				self.speed = self.speed - BRAKE * dt
				self.accEffect = -BRAKE
			end
			self.aiBlockingCarSpeed = nil
		elseif (self.speed < self.targetSpeed) then
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
	local steerUpdateSpeed = 20
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
	local newOutwardForce = self.segmentDdx*self.speed*self.speed*1.40
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

function Car:updateEngineSoundPlayer()
	local gear = math.floor((self.speed/self.topSpeed) / (1.0/self.gears))
	local gearSpeed = (self.speed - (gear*(self.topSpeed/self.gears))) / (self.topSpeed/self.gears)
	self.sndEngineIdle:setPitch(1 + 2.5 * (self.speed/self.topSpeed))
	self.sndEnginePower:setPitch(0.5 + gear * 0.045 + gearSpeed * 0.4)
end

function Car:updateEngineSoundCpu()
	local gear = math.floor((self.speed/self.topSpeed) / (1.0/self.gears))
	local gearSpeed = (self.speed - (gear*(self.topSpeed/self.gears))) / (self.topSpeed/self.gears)
	self.sndEnginePower:setPitch(0.5 + gear * 0.045 + gearSpeed * 0.4)
	
	local volume = 1 - (self.z - perspective.minZ) / (perspective.maxZ / 2 - perspective.minZ)
	if (volume > 1) then
		volume = 1
	end
	if (volume < 0) then
		volume = 0
	end
	self.sndEnginePower:setVolume(volume * 0.03) --0.3)
end

function Car:updateEngineSound()
	if (self.isPlayer) then
		self:updateEngineSoundPlayer()
	else
		self:updateEngineSoundCpu()
	end
end

function Car:update(dt)
	local offRoad = self:updateOffRoad(dt)
	local acc = self:getAcceleration()

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
	self:updateEngineSound()
	
	if (not self.isPlayer) then
		-- update z
		self.z = self.z + self.speed * dt
	end
	
	self:updateWheelAnimation(dt)
	
	-- apply outward force to x
	self.x = self.x - self.outwardForce
	
	-- apply steer result to x
	self.x = self.x + self.steerResult
end

function Car:scroll(playerSpeed,dt)
	local lap = false
	local delete = false
	
	if (not self.isPlayer) then
		self.z = self.z - playerSpeed * dt
		if ((self.z < perspective.minZ) or (self.z > perspective.maxZ)) then
			-- remove car
			delete = true
		end
	end
	
	return {
		lap = lap,
		delete = delete
	}
end

function Car:selectNewLane(collisionX,collisionDz,blockingCarSpeed,otherLaneResult)
	-- other lane blocked
	if (otherLaneResult.collision) then
		-- consider braking
		self.aiBlockingCarSpeed = blockingCarSpeed
	else
		if (collisionX < 0) then
			self.targetX = Car.getXFromLane(1,true)
		else
			self.targetX = Car.getXFromLane(-1,true)
		end
	end
end

function Car:setupForDraw(z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
	Entity.setupForDraw(self,z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
	self.segmentDdx = segment.ddx
	self.targetSpeed = self.topSpeed
end

function Car:draw()
	local imageScale = self:computeImageScale() * WIDTH_MODIFIER
	local newScreenX = self:computeNewScreenX()
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.setColor(1,1,1)
	
	local screenX = newScreenX/imageScale
	local screenY = self.screenY/imageScale
	local bumpDy = 0
	
	if ((self.leftBumpDy ~= 0) or (self.rightBumpDy ~= 0)) then
		bumpDy = (self.leftBumpDy + self.rightBumpDy) * 0.9
		screenY = screenY + bumpDy
	end
	
	local maxSteerPerspectiveEffect = 9
	local steerPerspectiveEffect = self.steer / MAX_STEER * maxSteerPerspectiveEffect
	local perspectiveEffect = (aspect.GAME_WIDTH/2-newScreenX)/(aspect.GAME_WIDTH/2) * 9 + steerPerspectiveEffect
	local frontWheelDy = -imgFrontWheel[1]:getHeight() - 4 * imageScale
	local accEffect = self.accEffect * 0.015
	
	-- draw shadow
	love.graphics.draw(imgShadow,screenX - shadowWidth/2 - perspectiveEffect * 0.2, screenY-6)
	
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

function Car:clean()
	if (self.sndEngineIdle ~= nil) then
		love.audio.stop(self.sndEngineIdle)
		self.sndEngineIdle = nil
	end
	if (self.sndEnginePower ~= nil) then
		love.audio.stop(self.sndEnginePower)
		self.sndEnginePower = nil
	end
end