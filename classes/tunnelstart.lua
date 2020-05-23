-- Max Downforce - classes/tunnelstart.lua
-- 2019-2020 Foppygames

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

function TunnelStart:new(z,trackHasRavine,trackIsInCity)
	o = Entity:new(0,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.solid = true
	o.ravine = trackHasRavine
	if trackIsInCity then
		o.color = {0.10,0.08,0.08}
	else
		o.color = {1,1,1}
	end
	
	return o
end

function TunnelStart:draw()
	-- Note: height set to 202 to avoid seeing top of inner tunnel walls above tunnel start
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local leftWidth = newScreenX - road.ROAD_WIDTH / 2 * imageScale
	local height = 202 * imageScale
	local y = self.screenY - height
	local rightX = newScreenX + road.ROAD_WIDTH / 2 * imageScale
	local roofHeight = 110 * imageScale
	
	-- Note: slightly increase height (after setting y) to avoid seeing thin line of grass under tunnel start
	height = height + 0.5

	love.graphics.setColor(self.color)
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