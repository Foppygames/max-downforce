-- Max Downforce - classes/tunnelend.lua
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

-- tunnel end is based on entity
TunnelEnd = Entity:new()

function TunnelEnd.init()
	-- ...
end

function TunnelEnd:new(z)
	o = Entity:new(0,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.solid = false
	
	return o
end

function TunnelEnd:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local leftWidth = newScreenX - road.ROAD_WIDTH / 2 * imageScale
	local height = 200 * imageScale
	local y = self.screenY - height
	local rightX = newScreenX + road.ROAD_WIDTH / 2 * imageScale
	local roofHeight = 50 * imageScale
	
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,y,leftWidth,height)
	love.graphics.rectangle("fill",rightX,y,aspect.WINDOW_WIDTH-rightX,height)
	love.graphics.rectangle("fill",0,y-roofHeight,aspect.WINDOW_WIDTH,roofHeight)
end