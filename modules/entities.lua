-- Max Downforce - modules/entities.lua
-- 2017-2020 Foppygames

local entities = {}

-- =========================================================
-- includes
-- =========================================================

require "classes.banner"
require "classes.building"
require "classes.car"
require "classes.flag"
require "classes.grass"
require "classes.light"
require "classes.marker"
require "classes.pillar"
require "classes.sign"
require "classes.spark"
require "classes.stadium"
require "classes.tree"
require "classes.tunnelend"
require "classes.tunnelstart"

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")
local utils = require("modules.utils")

-- =========================================================
-- variables
-- =========================================================

local baseScale = {}
local images = {}
local index = nil
local lap = false
local list = {}
local ravine = false
local city = false

-- =========================================================
-- public functions
-- =========================================================

function entities.init()
	list = {}
	index = nil
end

function entities.reset(trackHasRavine,trackIsInCity)
	ravine = trackHasRavine
	city = trackIsInCity
	local i = 1
	while i <= #list do
		list[i]:clean()
		i = i + 1
	end
	list = {}
end

function entities.checkLap()
	return lap
end

function entities.addBanner(x,z,forcedImageIndex)
	local banner = Banner:new(x,z,forcedImageIndex)
	-- Note: entities inserted at end of list since they are typically introduced at horizon,
	-- so this means less work has to be done when sorting the list on entity z values later
	table.insert(list,banner)
	return banner
end

function entities.addCityBuilding(x,z)
	local building = Building:new(x,z,false,true)
	table.insert(list,building)
	return building
end

function entities.addHighBuilding(x,z)
	local building = Building:new(x,z,true,false)
	table.insert(list,building)
	return building
end

function entities.addLowBuilding(x,z)
	local building = Building:new(x,z,false,false)
	table.insert(list,building)
	return building
end

function entities.addCar(x,z,isPlayer,progress,pause)
	local car = Car:new(x,z,isPlayer,progress,pause,ravine,city)
	table.insert(list,car)
	return car
end

function entities.addFlag(x,z)
	local flag = Flag:new(x,z)
	table.insert(list,flag)
	return flag
end

function entities.addFlagger(x,z)
	local flagger = Flagger:new(x,z)
	table.insert(list,flagger)
	return flagger
end

function entities.addGrass(x,z,mountain)
	local grass = Grass:new(x,z,mountain)
	table.insert(list,grass)
	return grass
end

function entities.addLight(x,z)
	local light = Light:new(x,z)
	table.insert(list,light)
	return light
end

function entities.addMarker(x,z)
	local marker = Marker:new(x,z)
	table.insert(list,marker)
	return marker
end

function entities.addPillar(x,z)
	local pillar = Pillar:new(x,z)
	table.insert(list,pillar)
	return pillar
end

function entities.addSpark(x,z,speed,color)
	local spark = Spark:new(x,z,speed,color)
	table.insert(list,spark)
	return spark
end

function entities.addStadium(x,z)
	local stadium = Stadium:new(x,z)
	table.insert(list,stadium)
	return stadium
end

function entities.addSign(x,z)
	local sign = Sign:new(x,z)
	table.insert(list,sign)
	return sign
end

function entities.addTree(x,z,color,mountain)
	local tree = Tree:new(x,z,color,mountain)
	table.insert(list,tree)
	return tree
end

function entities.addTunnelEnd(z)
	local tunnelEnd = TunnelEnd:new(z,ravine,city)
	table.insert(list,tunnelEnd)
	return tunnelEnd
end

function entities.addTunnelStart(z)
	local tunnelStart = TunnelStart:new(z,ravine,city)
	table.insert(list,tunnelStart)
	return tunnelStart
end

-- returns collision speed if car collides with other entity, nil otherwise
-- Note: this function modifies car speed in case of collision
local function checkCollision(car)
	local baseCarWidth = Car.getBaseTotalCarWidth()
	local carLength = perspective.carLength
	local carWidth = baseCarWidth * car.baseScale
	
	local i = 1
	while i <= #list do
		local other = list[i]
		if (other ~= car) then
			-- other entity is scenery
			if (not other:isCar()) then
				if (other.solid) then
					-- collision on z
					if ((car.z < other.z) and ((car.z + carLength) >= other.z)) then
						local collision = false
						local collisionDx = 0
						-- other entity is start of tunnel
						if (other:isTunnelStart()) then
							-- collision on x
							if (car:outsideTunnelBounds()) then
								-- to the right of track or track has no ravine
								if ((car.x > 0) or (not car.ravine)) then
									collision = true
								end
							end
						-- other entity is not start of tunnel
						else
							local dx = math.abs(other.x - car.x)
							-- collision on x
							if (dx < (other:getCollisionWidth() * other.baseScale / 2 + carWidth / 2)) then
								collision = true
								collisionDx = dx
							end
						end
						if (collision) then
							-- car is halted
							local speed = car.speed
							car.speed = 0
							car.accEffect = 0
							return {
								speed = speed,
								dx = collisionDx
							}
						end
					end
				end
			-- other entity is car
			else
				-- collision on z
				if ((car.z < other.z) and ((car.z + carLength) >= other.z)) then
					-- closing in on each other
					if (car.speed > other.speed) then
						local dx = math.abs(other.x - car.x)
						-- collision on x
						if (dx < (baseCarWidth * other.baseScale / 2 + carWidth / 2)) then
							-- other car is not exploding
							if (not other:exploding()) then
								-- car is blocked
								local speed = car.speed - other.speed
								car.speed = other.speed * 0.90
								car.accEffect = 0
								return {
									speed = speed,
									dx = dx/2
								}
							end
						end
					end
				end
			end
		end
		i = i + 1
	end	
	
	return nil
end

-- checks if a car is ahead
local function lookAhead(car,x)
	local baseCarWidth = Car.getBaseTotalCarWidth()
	local carLength = perspective.carLength
	local carWidth = baseCarWidth * car.baseScale
	local checkDistance = carLength * (1 + 8 * (car.speed / car.topSpeed))
	
	if (x == nil) then
		x = car.x
	end
	
	local i = 1
	while i <= #list do
		local other = list[i]
		if (other ~= car) then
			-- other entity is car
			if (other:isCar()) then
				-- collision on z
				if ((car.z < other.z) and ((car.z + checkDistance) >= other.z)) then
					-- closing in on each other
					if (car.speed > other.speed) then
						local dX = math.abs(other.x - x)
						-- collision on x
						if (dX < (baseCarWidth * other.baseScale / 2 + carWidth / 2)) then 
							return {
								collision = true,
								collisionX = other.x,
								collisionDz = other.z - car.z,
								blockingCarSpeed = other.speed
							}
						end
					end
				end
			end
		end
		i = i + 1
	end	
	
	return {collision = false}
end

function entities.update(playerSpeed,dt,trackLength)
	lap = false
	
	local stadiumNear = false
	local aiCarCount = 0
	
	local i = 1
	while i <= #list do
		if (list[i]:isCar()) then
			-- update collision property of car
			list[i].collision = checkCollision(list[i])
			
			-- check for sparks to be generated
			local sparks = list[i]:getSparks()
			if (sparks ~= nil) then
				for j = 1,#sparks,1 do
					entities.addSpark(sparks[j].x,sparks[j].z,sparks[j].speed,sparks[j].color)
				end
				list[i]:resetSparks()
			end
		end
		
		-- update
		local delete = list[i]:update(dt)
		
		-- scroll
		result = list[i]:scroll(playerSpeed,dt)
		
		delete = delete or result.delete
		
		if (result.lap) then
			lap = true
		end
		
		if (list[i]:isCar()) then
			if (not delete) then
				if (not list[i].isPlayer) then
					aiCarCount = aiCarCount + 1
					
					local lookAheadResult = lookAhead(list[i],list[i].x)
					
					-- possible collision detected
					if (lookAheadResult.collision) then
						-- check other lane
						local otherLaneX
						if (list[i].x < 0) then
							otherLaneX = Car.getXFromLane(1,false)
						else
							otherLaneX = Car.getXFromLane(-1,false)
						end
						local otherLaneResult = lookAhead(list[i],otherLaneX)
						
						-- consider changing lane
						list[i]:selectNewLane(lookAheadResult.collisionX,lookAheadResult.collisionDz,lookAheadResult.blockingCarSpeed,otherLaneResult)
					end
				end
			end
		elseif (list[i]:isStadium()) then
			if (stadiumNear == false) then
				if (list[i].z < (perspective.maxZ / 2)) then
					stadiumNear = true
				end
			end
		end
		
		if (delete) then
			list[i]:clean()
		
			table.remove(list,i)
		else
			i = i + 1
		end
	end
	
	-- sort all entities on increasing z
	table.sort(list,function(a,b) return a.z < b.z end)
	
	return {
		aiCarCount = aiCarCount,
		stadiumNear = stadiumNear
	}
end

function entities.resetForDraw()
	index = 1
end

function entities.setupForDraw(z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
	while (index <= #list) and (list[index].z <= z) do
		list[index]:setupForDraw(z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
		index = index + 1
	end
end

function entities.draw()
	for i = #list,1,-1 do
		list[i]:draw()
	end
end

function entities.cancelXSmoothing()
	for i = #list,1,-1 do
		list[i].smoothX = false
	end
end

return entities