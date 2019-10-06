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
local MAX_DIST_BEFORE_CURB_OTHER_WHEEL = road.ROAD_WIDTH*0.50
local MAX_DIST_BEFORE_TUNNEL_WALL = road.ROAD_WIDTH*0.40
local MAX_DIST_BEFORE_GRASS = road.ROAD_WIDTH*0.45
local MAX_DIST_BEFORE_GRASS_OTHER_WHEEL = road.ROAD_WIDTH*0.60
local HIT_TUNNEL_WALL_MAX_SPEED = TOP_SPEED * 0.85
local OFF_ROAD_MAX_SPEED = TOP_SPEED * 0.75
local OFF_ROAD_ACC_FACTOR = 0.5
local AI_MIN_PERFORMANCE_FRACTION = 0.65
local AI_MAX_PERFORMANCE_FRACTION = 0.92
local AI_TOP_SPEED = TOP_SPEED
local AI_TARGET_X_MARGIN = road.ROAD_WIDTH / 25
local AI_MAX_STEER = MAX_STEER * 0.9
local AI_STEER_CHANGE = STEER_CHANGE * 0.9
local AI_STEER_RETURN_FACTOR = STEER_RETURN_FACTOR * 0.7
local MAX_WHEEL_SCALE_CHANGE = 0.05
local MAX_BODY_DEGREES_CHANGE = 2
local EXPLOSION_SCALE = 4
local EXPLOSION_TIME = 0.4
local EXPLOSION_WAIT = 0.4
local PLAYER_ENGINE_SOUND_POWER_VOLUME = 0.8
local PLAYER_ENGINE_SOUND_IDLE_VOLUME = 0.8
local AI_ENGINE_SOUND_POWER_VOLUME = 0.65

-- local variables
local colors = {}
local imgBody = nil
local imgFrontWheel = {}
local imgRearWheel = {}
local imgDiffuser = nil
local imgWing = nil
local imgAirScoop = nil
local imgHelmet = nil
local imgShadow = nil
local imgExplosion = {}
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
	colors = {
		{1,0,0}, -- red
		{0.5,0,0}, -- dark red
		{0,1,0}, -- green
		{0,0.5,0}, -- dark green
		{0,0,1}, -- blue
		{0,0,0.5}, -- dark blue
		{1,1,0}, -- yellow
		{0,0,0}, -- black
		{0.5,0.5,0.5}, -- grey
		{0.2,0.2,0.2}, -- dark grey
		{1,1,1}, -- white
		{0.5,0,1}, -- purple
		{1,0,0.5}, -- pink
		{0,1,1}, -- cyan
		{1,0.3,0}, -- orange
		{0.75,1,0.25} -- olive
	}

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
	for i = 1,6 do
		table.insert(imgExplosion, love.graphics.newImage("images/explosion"..i..".png"))
	end
	
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

function Car:new(lane,z,isPlayer,progress,pause)
	local x = Car.getXFromLane(lane,true)
	
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.isPlayer = isPlayer
	
	if (not isPlayer) then
		-- car is fast
		if ((math.random() > 0.8)) then
			-- fast cars keep getting faster (computed top progress = 1)
			progress = math.min(1, progress + 0.4 + math.random() * 0.3)
		-- car is normal
		else
			-- normal cars do not get faster after game progress 0.3 (computed top progress = 0.6)
			progress = math.min(1, math.min(0.3, progress) + 0.1 + math.random() * 0.2)
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
	o.echoEnabled = false
	o.aiBlockingCarSpeed = nil
	o.pause = pause
	o.inTunnel = false
			
	if (o.isPlayer) then
		o.color = {1,0,0}
		o.topSpeed = TOP_SPEED
		
		o.sndEngineIdle = sound.getClone(sound.ENGINE_IDLE)
		o.sndEngineIdle:setVolume(PLAYER_ENGINE_SOUND_IDLE_VOLUME * sound.VOLUME_EFFECTS)
		love.audio.play(o.sndEngineIdle)
		
		o.sndEnginePower = sound.getClone(sound.ENGINE_POWER)
		o.sndEnginePower:setVolume(PLAYER_ENGINE_SOUND_POWER_VOLUME * sound.VOLUME_EFFECTS)
		love.audio.play(o.sndEnginePower)
		
		o.sndCurbBump = love.audio.newSource("sounds/curb.wav","static")
		o.sndCurbBump:setVolume(0.7)
		o.curbBumpSoundCount = 1
		
		o.gears = 7
	else
		o.color = colors[math.random(#colors)]
		o.topSpeed = o.performanceFraction * AI_TOP_SPEED
		
		o.sndEnginePower = sound.getClone(sound.ENGINE_POWER)
		o.sndEnginePower:setVolume(AI_ENGINE_SOUND_POWER_VOLUME * sound.VOLUME_EFFECTS)
		love.audio.play(o.sndEnginePower)
		
		o.gears = math.random(3,8)
	end
	
	o.colorInTunnel = {}
	for i = 1,3 do
		o.colorInTunnel[i] = o.color[i] / 2
	end
	
	o.topSpeedForAcceleration = (3 * TOP_SPEED + o.topSpeed) / 4
	o.speedLimitHigherAcceleration = o.topSpeed*0.96
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
	o.collision = nil
	o.broken = false
	o.sparkTime = Car.getSparkTime(o.broken)
	o.sparks = nil
	o.steerFactor = 0
	o.explosionTime = 0
	
	return o
end

function Car.getSparkTime(broken)
	if (not broken) then
		return 3 + math.random() * 20
	else
		return 0.1 + math.random() * 0.3
	end
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
	local hitCurb = false
	local hitTunnelWallLeft = false
	local hitTunnelWallRight = false
	
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
	
	-- left off tarmac
	if (self.x < -MAX_DIST_BEFORE_CURB) then
		-- not in tunnel
		if (not self.inTunnel) then
			-- bump left
			if (self.leftBumpDy == 0) then
				self.leftBumpDy = -1
			end
			-- left onto grass
			if (self.x < -MAX_DIST_BEFORE_GRASS) then
				offRoad = true
				-- right off tarmac
				if (self.x < -MAX_DIST_BEFORE_CURB_OTHER_WHEEL) then
					-- bump right
					if (self.rightBumpDy == 0) then
						self.rightBumpDy = -1
					end
					-- right on curb
					if (self.x >= -MAX_DIST_BEFORE_GRASS_OTHER_WHEEL) then
						hitCurb = true
					end
				end
			-- left on curb
			else
				hitCurb = true
			end
		-- in tunnel
		else
			-- hit wall
			if (self.x < -MAX_DIST_BEFORE_TUNNEL_WALL) then
				self.x = -MAX_DIST_BEFORE_TUNNEL_WALL + math.random() * 10
				hitTunnelWallLeft = true
			end
		end
	-- right off tarmac
	elseif (self.x > MAX_DIST_BEFORE_CURB) then
		-- not in tunnel
		if (not self.inTunnel) then
			-- bump right
			if (self.rightBumpDy == 0) then
				self.rightBumpDy = -1
			end
			-- right onto grass
			if (self.x > MAX_DIST_BEFORE_GRASS) then
				offRoad = true
				-- left off tarmac
				if (self.x > MAX_DIST_BEFORE_CURB_OTHER_WHEEL) then
					-- bump left
					if (self.leftBumpDy == 0) then
						self.leftBumpDy = -1
					end
					-- left on curb
					if (self.x <= MAX_DIST_BEFORE_GRASS_OTHER_WHEEL) then
						hitCurb = true
					end
				end		
			-- right on curb
			else
				hitCurb = true
			end
		-- in tunnel
		else
			-- hit wall
			if (self.x > MAX_DIST_BEFORE_TUNNEL_WALL) then
				self.x = MAX_DIST_BEFORE_TUNNEL_WALL - math.random() * 10
				hitTunnelWallRight = true
			end
		end
	end
	
	if (offRoad) then
		if (self.speed > OFF_ROAD_MAX_SPEED) then
			self.speed = self.speed - BRAKE * dt
		end
	end
	
	if (hitTunnelWallLeft or hitTunnelWallRight) then
		if (self.speed > HIT_TUNNEL_WALL_MAX_SPEED) then
			self.speed = self.speed - BRAKE * dt
		end
		
		-- create wall scrape sparks
		if (self.sparks == nil) then
			self.sparks = {}
		end
		local count = math.random(1,3)
		local sparkDx
		if (hitTunnelWallLeft) then
			sparkDx = -bodyWidth * 2
		else
			sparkDx = bodyWidth * 2
		end
		for i = 1, count do
			table.insert(self.sparks,{
				x = self.x + sparkDx - 5 + math.random(0,10),
				z = self.z + 3 - i * 0.7,
				speed = 0,
				color = {1,1,math.random()}
			})
		end
	end
	
	if (hitCurb and self.isPlayer) then
		self.curbBumpSoundCount = self.curbBumpSoundCount - self.speed/2 * dt
		if (self.curbBumpSoundCount <= 0) then
			self.sndCurbBump:stop()
			self.sndCurbBump:play()
			self.curbBumpSoundCount = self.curbBumpSoundCount + 1
		end
	end
	
	return offRoad
end

function Car:updateSpark(dt)
	self.sparkTime = self.sparkTime - dt
	if (self.sparkTime <= 0) then
		if (self.speed > (self.topSpeed / 2)) then
			if (self.sparks == nil) then
				self.sparks = {}
			end
			local count = math.random(2,5)
			for i = 1, count do
				table.insert(self.sparks,{
					x = self.x - 10 + math.random(0,20),
					z = self.z - i * 0.7,
					speed = 0,
					color = {1,1,math.random()}
				})
			end
		end
		self.sparkTime = Car.getSparkTime(self.broken)
	end
end

function Car:getAcceleration()
	local diff = self.topSpeedForAcceleration - self.speed
	if (self.speed < self.speedLimitHigherAcceleration) then
		return diff / 6
	else
		return diff / 14
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
	self.steerFactor = self.steer / MAX_STEER
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
	
	-- add random steering
	if (self.speed > 0) then
		self.steer = self.steer - 0.2 + math.random() * 0.4
	end
	
	self.steerFactor = self.steer / AI_MAX_STEER
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
			end
			self.aiBlockingCarSpeed = nil
		elseif (self.speed < self.targetSpeed) then
			self.speed = self.speed + acc * dt
			if (self.speed > self.topSpeed) then
				self.speed = self.topSpeed
			end
		else
			if (self.speed > 0) then
				self.speed = self.speed - BRAKE * dt
			end
			if (self.speed <= 0) then
				self.speed = 0
				self.steer = 0
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
	local steerUpdateSpeed = 5
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
	
	if (self.inTunnel) then
		if (not self.echoEnabled) then
			self.sndEnginePower:setEffect("tunnel_echo")
			self.echoEnabled = true
			
			-- change music volume
			sound.setVolume(sound.RACE_MUSIC,sound.VOLUME_MUSIC_IN_TUNNEL)
		end
	else
		if (self.echoEnabled) then
			self.sndEnginePower:setEffect("tunnel_echo",false)
			self.echoEnabled = false
			
			-- reset music volume
			sound.setVolume(sound.RACE_MUSIC,sound.VOLUME_MUSIC)
		end
	end
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
	self.sndEnginePower:setVolume(volume * AI_ENGINE_SOUND_POWER_VOLUME * sound.VOLUME_EFFECTS)
end

function Car:updateEngineSound()
	if (self.isPlayer) then
		self:updateEngineSoundPlayer()
	else
		self:updateEngineSoundCpu()
	end
end

function Car:explode()
	if (self.isPlayer) then
		self.sndEngineIdle:setVolume(0)
		self.sndEnginePower:setVolume(0)
	end
	sound.play(sound.EXPLOSION)
	self.speed = 0
	self.explosionTime = EXPLOSION_TIME + EXPLOSION_WAIT
end

function Car:updateExplosion(dt)
	local delete = false
	self.explosionTime = self.explosionTime - dt
	if (self.explosionTime <= 0) then
		if (self.isPlayer) then
			self.sndEngineIdle:setVolume(PLAYER_ENGINE_SOUND_IDLE_VOLUME * sound.VOLUME_EFFECTS)
			self.sndEnginePower:setVolume(PLAYER_ENGINE_SOUND_POWER_VOLUME * sound.VOLUME_EFFECTS)
			self.steer = 0
			self.x = 0
			-- ...
		else
			delete = true
		end
		self.explosionTime = 0
	end
	return delete
end

function Car:update(dt)
	local delete = false
	local offRoad = self:updateOffRoad(dt)
	local acc = self:getAcceleration()

	if (offRoad) then
		acc = acc * OFF_ROAD_ACC_FACTOR
	end
	
	if (self.explosionTime == 0) then
		self:updateSteer(dt)
	
		if (self.collision == nil) then
			self:updateSpeed(acc,dt)
		else
			-- 50% crash
			if (self.collision.speed > (self.topSpeed * 0.5)) then
				self:explode()
			-- 20% crash
			elseif (self.collision.speed > (self.topSpeed * 0.2)) then
				sound.play(sound.COLLISION)
			-- light touch
			else
				-- ...
			end
		end
	end
	
	if (self.explosionTime == 0) then
		self:updateSteerResult()
		self:updateOutwardForce()
		self:updateSpark(dt)
	else
		delete = self:updateExplosion(dt)
	end
	
	self:updateEngineSound()	
	
	if (not self.isPlayer) then
		-- update z
		self.z = self.z + self.speed * dt
	end
	
	self:updateWheelAnimation(dt)
	
	if (self.explosionTime == 0) then
		-- apply outward force to x
		self.x = self.x - self.outwardForce
	
		-- apply steer result to x
		self.x = self.x + self.steerResult
	end
	
	if (self.x < -(road.ROAD_WIDTH * 2)) then
		self.x = -road.ROAD_WIDTH * 2
		self.steer = 0
	elseif (self.x > (road.ROAD_WIDTH * 2)) then
		self.x = road.ROAD_WIDTH * 2
		self.steer = 0
	end
	
	return delete
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
	self.inTunnel = segment.tunnel
end

function Car:draw()
	local imageScale = self:computeImageScale() * WIDTH_MODIFIER
	local newScreenX = self:computeNewScreenX()
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.setColor(1,1,1)
	
	local screenX = newScreenX/imageScale
	local screenY = self.screenY/imageScale
	
	if ((self.explosionTime == 0) or (self.explosionTime > EXPLOSION_WAIT + EXPLOSION_TIME/2)) then
		local bumpDy = 0
		
		if ((self.leftBumpDy ~= 0) or (self.rightBumpDy ~= 0)) then
			bumpDy = (self.leftBumpDy + self.rightBumpDy) * 0.9
			screenY = screenY + bumpDy
		end
		
		local maxSteerPerspectiveEffect = 10
		local steerPerspectiveEffect = self.steer / MAX_STEER * maxSteerPerspectiveEffect
		local perspectiveEffect = (aspect.GAME_WIDTH/2-newScreenX)/(aspect.GAME_WIDTH/2) * 10 + steerPerspectiveEffect
		local frontWheelDy = -imgFrontWheel[1]:getHeight() - 5 * imageScale
		local accEffect = self.accEffect * 0.01
		
		-- draw shadow
		love.graphics.draw(imgShadow,screenX - shadowWidth/2, screenY - 6)
		
		-- compute body rotation
		local bodyDegreesChange = -self.steerFactor * MAX_BODY_DEGREES_CHANGE
		local bodyRotation = bodyDegreesChange * math.pi/180
		
		-- draw front wheels
		local wheelScaleChange = bodyDegreesChange / MAX_BODY_DEGREES_CHANGE * MAX_WHEEL_SCALE_CHANGE
		local leftWheelScale = 1 + wheelScaleChange
		local rightWheelScale = 1 - wheelScaleChange
		love.graphics.draw(imgFrontWheel[self.rearWheelIndex],screenX + frontWheelLeftDx + perspectiveEffect,screenY + frontWheelDy - accEffect*2 + self.leftBumpDy, 0, leftWheelScale, leftWheelScale)
		love.graphics.draw(imgFrontWheel[self.rearWheelIndex],screenX + frontWheelRightDx + perspectiveEffect,screenY + frontWheelDy - accEffect*2 + self.rightBumpDy, 0, rightWheelScale, rightWheelScale)
		
		local mainColor = self.color
		if (self.inTunnel) then
			mainColor = self.colorInTunnel
		end
		
		-- draw body
		love.graphics.setColor(mainColor)
		love.graphics.draw(imgBody,screenX - perspectiveEffect * 0.2,screenY - bodyHeight/2 + accEffect, bodyRotation, 1, 1, bodyWidth/2, bodyHeight/2)
		
		-- draw helmet
		love.graphics.setColor(1,1,1)
		love.graphics.draw(imgHelmet,screenX - helmetWidth/2  - perspectiveEffect * 0.2,screenY - bodyHeight - helmetHeight + accEffect)
		
		-- draw air scoop
		love.graphics.setColor(mainColor)
		love.graphics.draw(imgAirScoop,screenX - airScoopWidth/2  - perspectiveEffect * 0.6,screenY - bodyHeight - airScoopHeight + accEffect)
		
		-- draw rear wheels
		love.graphics.setColor(1,1,1)
		love.graphics.draw(imgRearWheel[self.rearWheelIndex],screenX - bodyWidth/2 - rearWheelWidth - perspectiveEffect,screenY - rearWheelHeight + self.leftBumpDy, 0, leftWheelScale, leftWheelScale)
		love.graphics.draw(imgRearWheel[self.rearWheelIndex],screenX + bodyWidth/2 - perspectiveEffect,screenY - rearWheelHeight + self.rightBumpDy, 0, rightWheelScale, rightWheelScale)
		
		-- draw rear wing
		local wingDegreesChange = bodyDegreesChange
		local wingRotation = wingDegreesChange * math.pi/180
		love.graphics.setColor(mainColor)
		love.graphics.draw(imgWing,screenX - perspectiveEffect * 1.2,screenY - bodyHeight + 4 + accEffect * 2.5 + bumpDy, wingRotation, 1, 1, wingWidth/2, wingHeight)
		
		-- draw diffuser
		love.graphics.draw(imgDiffuser,screenX - diffuserWidth/2  - perspectiveEffect,screenY - diffuserHeight + accEffect*3)
	end
	
	if (self.explosionTime > EXPLOSION_WAIT) then
		local progress = 1 - ((self.explosionTime - EXPLOSION_WAIT) / EXPLOSION_TIME)
		local total = #imgExplosion
		local i = math.ceil(total * progress)
		
		love.graphics.setColor(1,1,1)
		love.graphics.draw(imgExplosion[i], screenX - imgExplosion[i]:getWidth() / 2 * EXPLOSION_SCALE, screenY - imgExplosion[i]:getHeight() * EXPLOSION_SCALE, 0, EXPLOSION_SCALE, EXPLOSION_SCALE)
	end
	
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

function Car:breakDown(lane)
	self.broken = true
	self.sparkTime = 0
	self.topSpeed = self.topSpeed * 0.7
	self.speed = self.topSpeed
	self.targetSpeed = self.topSpeed
	self.targetX = self.targetX + lane * road.ROAD_WIDTH / 3
end

function Car:getSparks()
	return self.sparks
end

function Car:resetSparks()
	self.sparks = nil
end

function Car:isCar()
	return true
end

function Car:outsideTunnelBounds()
	return (self.x < -MAX_DIST_BEFORE_TUNNEL_WALL) or (self.x > MAX_DIST_BEFORE_TUNNEL_WALL)
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