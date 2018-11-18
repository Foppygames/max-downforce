-- Max Downforce - modules/entities.lua
-- 2017-2018 Foppygames

local entities = {}

-- =========================================================
-- includes
-- =========================================================

require "classes.building"
require "classes.car"
require "classes.stadium"

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")
local utils = require("modules.utils")

-- =========================================================
-- constants
-- =========================================================

--entities.TYPE_BANNER_START = "banner_start"
--entities.TYPE_CAR = "car"
--entities.TYPE_TREE = "tree"
--entities.TYPE_SIGN = "sign"

-- =========================================================
-- variables
-- =========================================================

local list = {}

local lap = false

local images = {}
local baseScale = {}
local index = nil
local signIndex = 1
	
-- =========================================================
-- functions
-- =========================================================

function entities.init()
	--[[
	images[entities.TYPE_BANNER_START] = love.graphics.newImage("images/banner_start.png")
	]]
	--[[
	images[entities.TYPE_TREE] = {
		love.graphics.newImage("images/tree2.png"),
		love.graphics.newImage("images/tree3.png")
	}
	images[entities.TYPE_SIGN] =  {
		love.graphics.newImage("images/sign1.png"),
		love.graphics.newImage("images/sign2.png"),
		love.graphics.newImage("images/sign3.png")
	}
	]]--
	
	--[[
	baseScale[entities.TYPE_BANNER_START] = 8
	baseScale[entities.TYPE_TREE] = 8
	baseScale[entities.TYPE_SIGN] = 12
	]]--
	
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

-- add entity in correct order of increasing z
--[[
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
	}]]
	
	--[[
	if (entityType == entities.TYPE_TREE) then
		entity.image = images[entityType][math.random(2)]
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
	]]
	
	--[[
	if (entityType == entities.TYPE_TREE) then
		entity.smoothX = true
		entity.x = entity.x + math.random(-aspect.GAME_WIDTH/2,aspect.GAME_WIDTH/2)
	end
	]]
	
	--[[
	if (entityType == entities.TYPE_SIGN) then
		entity.smoothX = true
	end
	]]
	
	--[[
	if (entityType == entities.TYPE_BANNER_START) then
		entity.solid = false
	end
	]]
	
	-- insert at end since most items introduced at horizon (max z)
	--[[table.insert(list,entity)
	
	return entity
end]]

-- Note: y is unscaled height of banner
--[[
function entities.addBanner(entityType,x,y,z)
	local entity = entities.add(entityType,x,z)
	
	entity.isBanner = true
	entity.y = y
	
	return entity
end
]]

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

--[[
function entities.addTree(x,z,color)
	local entity = entities.add(entities.TYPE_TREE,x,z)
	
	entity.color = color
	
	return entity
end
]]

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

--[[
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
]]

function entities.draw()
	for i = #list,1,-1 do
		list[i]:draw()
	end
end

return entities