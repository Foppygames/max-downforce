-- Max Downforce - modules/entities.lua
-- 2017-2019 Foppygames

local entities = {}

-- =========================================================
-- includes
-- =========================================================

require "classes.banner"
require "classes.building"
require "classes.car"
require "classes.sign"
require "classes.stadium"
require "classes.tree"

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")
local utils = require("modules.utils")

-- =========================================================
-- constants
-- =========================================================

-- ...

-- =========================================================
-- variables
-- =========================================================

local list = {}

local lap = false

local images = {}
local baseScale = {}
local index = nil
	
-- =========================================================
-- functions
-- =========================================================

function entities.init()
	list = {}
	index = nil
end

function entities.reset()
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

function entities.addBanner(x,z)
	local banner = Banner:new(x,z)
	
	-- insert at end since most items introduced at horizon (max z)
	table.insert(list,banner)
	
	return banner
end

function entities.addBuilding(x,z)
	local building = Building:new(x,z)
	
	-- insert at end since most items introduced at horizon (max z)
	table.insert(list,building)
	
	return building
end

function entities.addCar(x,z,isPlayer,progress)
	local car = Car:new(x,z,isPlayer,progress)
	
	-- insert at end since most items introduced at horizon (max z)
	table.insert(list,car)
	
	return car
end

function entities.addStadium(x,z)
	local stadium = Stadium:new(x,z)
	
	-- insert at end since most items introduced at horizon (max z)
	table.insert(list,stadium)
	
	return stadium
end

function entities.addSign(x,z)
	local sign = Sign:new(x,z)
	
	-- insert at end since most items introduced at horizon (max z)
	table.insert(list,sign)
	
	return sign
end

function entities.addTree(x,z,color)
	local tree = Tree:new(x,z,color)
	
	-- insert at end since most items introduced at horizon (max z)
	table.insert(list,tree)
	
	return tree
end

-- checks if car collides with other entity
local function checkCollision(car)
	local baseCarWidth = Car.getBaseTotalCarWidth()
	local carLength = perspective.maxZ / 50
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
						local dX = math.abs(other.x - car.x)
						-- collision on x
						if (dX < (other:getCollisionWidth() * other.baseScale / 2 + carWidth / 2)) then 
							-- car is halted
							car.speed = 0
							car.accEffect = 0
							--if (entity.explodeCount == 0) then
							--	entity.explodeCount = 2
							--end
							return {collision = true}
						end
					end
				end
			-- other entity is car
			else
				-- collision on z
				if ((car.z < other.z) and ((car.z + carLength) >= other.z)) then
					-- closing in on each other
					if (car.speed > other.speed) then
						local dX = math.abs(other.x - car.x)
						-- collision on x
						if (dX < (baseCarWidth * other.baseScale / 2 + carWidth / 2)) then 
							-- car is blocked
							car.speed = other.speed * 0.8
							car.accEffect = 0
							return {collision = true}
						end
					end
				end
			end
		end
		i = i + 1
	end	
	
	return {collision = false}
end

-- checks if a car is ahead
local function lookAhead(car,x)
	local baseCarWidth = Car.getBaseTotalCarWidth()
	local carLength = perspective.maxZ / 50
	local carWidth = Car.getBaseTotalCarWidth() * car.baseScale
	local checkDistance = carLength * (1 + 5 * (car.speed / car.topSpeed)) --8
	
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
	
	local aiCarCount = 0
	
	local i = 1
	while i <= #list do
		if (list[i]:isCar()) then
			list[i].collided = false
			local checkCollisionResult = checkCollision(list[i])
			if (checkCollisionResult.collision) then
				list[i].collided = true
			end
		end
		
		-- update
		list[i]:update(dt)
		
		-- scroll
		local result = list[i]:scroll(playerSpeed,dt)
		
		if (result.lap) then
			lap = true
		end
		
		if (list[i]:isCar()) then
			if (not result.delete) then
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
		end
		
		if (result.delete) then
			list[i]:clean()
		
			table.remove(list,i)
		else
			i = i + 1
		end
	end
	
	-- sort all entities on increasing z
	table.sort(list,function(a,b) return a.z < b.z end)
	
	return aiCarCount
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