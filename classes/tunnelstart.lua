-- Max Downforce - classes/tunnelstart.lua
-- 2019 Foppygames

-- classes
require "classes.entity"

-- modules
local aspect = require("modules.aspect")
local road = require("modules.road")

-- local constants
-- ...

-- local variables
-- ...

-- tunnel start is based on entity
TunnelStart = Entity:new()

function TunnelStart.init()
	-- ...
end

function TunnelStart:new(z,trackHasRavine)
	o = Entity:new(0,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.solid = true
	o.ravine = trackHasRavine
	
	return o
end

function TunnelStart:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local leftWidth = newScreenX - road.ROAD_WIDTH / 2 * imageScale
	local height = 200 * imageScale
	local y = self.screenY - height
	local rightX = newScreenX + road.ROAD_WIDTH / 2 * imageScale
	local roofHeight = 110 * imageScale
	
	love.graphics.setColor(1,1,1)
	if (not self.ravine) then
		love.graphics.rectangle("fill",0,y,leftWidth,height)
		love.graphics.rectangle("fill",rightX,y,aspect.WINDOW_WIDTH-rightX,height)
		love.graphics.rectangle("fill",0,y-roofHeight,aspect.WINDOW_WIDTH,roofHeight)
	else
		love.graphics.rectangle("fill",rightX,y,aspect.WINDOW_WIDTH-rightX,height)
		love.graphics.rectangle("fill",leftWidth,y-roofHeight,aspect.WINDOW_WIDTH-leftWidth,roofHeight)
	end
end

function TunnelStart:isTunnelStart()
	return true
end