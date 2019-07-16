-- Max Downforce - classes/tunnelend.lua
-- 2019 Foppygames

-- classes
require "classes.entity"

-- modules
local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")

-- local constants
-- ...

-- local variables
local colorAngle = 0
local count = 0

-- tunnel end is based on entity
TunnelEnd = Entity:new()

function TunnelEnd.init()
	-- ...
end

function TunnelEnd.reset()
	count = 0
end

function TunnelEnd:new(z)
	o = Entity:new(0,z)	
	setmetatable(o, self)
	self.__index = self
	
	count =	count + 1

	o.solid = false
	o.color = math.cos(math.rad(colorAngle)) / 25
	o.lamp = (count % 5 == 0)
	
	if (math.random() > 0.92) then
		colorAngle = colorAngle + 24
	else
		colorAngle = colorAngle + 8
	end
	if (colorAngle > 360) then
		colorAngle = 0
	end
	
	return o
end

function TunnelEnd:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	
	local wallHeight = 200 * imageScale
	local panelingHeight = 30 * imageScale
	local wallWidth = 300 * imageScale
	
	local y = self.screenY - wallHeight
	local panelingY = self.screenY - panelingHeight
	
	local leftX1 = newScreenX - road.ROAD_WIDTH / 2 * imageScale - wallWidth
	local rightX1 = newScreenX + road.ROAD_WIDTH / 2 * imageScale
	
	local roofHeight = 120 * imageScale
	
	love.graphics.setColor(self.color,self.color,self.color*1.3)
	if (self.z < (perspective.maxZ * 0.9)) then
		love.graphics.rectangle("fill",leftX1,y,wallWidth,wallHeight)
		love.graphics.rectangle("fill",rightX1,y,wallWidth,wallHeight)
		love.graphics.rectangle("fill",leftX1,y-roofHeight,wallWidth*2+(rightX1-leftX1),roofHeight)
		
		-- paneling to hide color difference with black ground
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill",leftX1,panelingY,wallWidth,panelingHeight)
		love.graphics.rectangle("fill",rightX1,panelingY,wallWidth,panelingHeight)
		
		-- lamp
		if (self.lamp) then
			local lampWidth = 60 * imageScale
			love.graphics.setColor(1,1,1)
			love.graphics.rectangle("fill",newScreenX-lampWidth/2,y,lampWidth,lampWidth/6)
		end
	else
		-- filled opening to avoid seeing end when tunnel actually continues
		love.graphics.rectangle("fill",leftX1,y-roofHeight,wallWidth*2+(rightX1-leftX1),wallHeight+roofHeight)
	end
end