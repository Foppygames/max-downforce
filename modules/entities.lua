-- Max Downforce - modules/entities.lua
-- 2017-2018 Foppygames

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
end

function entities.reset()
	-- stop audio
	local i = 1
	while i <= #list do
		local entity = list[i]
		if (entity.sndEngineIdle ~= nil) then
			love.audio.stop(entity.sndEngineIdle)
		end
		if (entity.sndEnginePower ~= nil) then
			love.audio.stop(entity.sndEnginePower)
		end
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

function entities.addCar(x,z,isPlayer,performanceFraction) --aheadOfPlayer
	local car = Car:new(x,z,isPlayer,performanceFraction) --aheadOfPlayer
	
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

--[[local function checkCarCollisions(entity,player,dt)
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
							-- car explodes
							entity.speed = 0
							entity.acc = 0
							if (entity.explodeCount == 0) then
								entity.explodeCount = 2
							end
							
							return true
						end
						
					end
				
				end
				
			end
			
		end
		
		i = i + 1
	end	
	
	return false
end]]

function entities.update(playerSpeed,dt,trackLength)
	lap = false
	newBlips = {}
	
	local i = 1
	while i <= #list do
		-- update
		list[i]:update(dt)
		
		-- scroll
		result = list[i]:scroll(playerSpeed,dt)
		
		if (result.blip) then
			table.insert(newBlips,result.blip)
		end
		
		if (result.lap) then
			lap = true
		end
		
		if (result.delete) then
			table.remove(list,i)
		else
			i = i + 1
		end
	end
	
	-- sort all entities on increasing z
	table.sort(list,function(a,b) return a.z < b.z end)
	
	return newBlips
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

return entities