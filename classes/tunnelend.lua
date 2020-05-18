-- Max Downforce - classes/tunnelend.lua
-- 2019-2020 Foppygames

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

function TunnelEnd:new(z,trackHasRavine,trackIsInCity)
	o = Entity:new(0,z)	
	setmetatable(o, self)
	self.__index = self
	
	count =	count + 1

	o.solid = false
	o.lamp = (count % 5 == 0)
	o.ravine = trackHasRavine
	
	local color
	if trackHasRavine then
		color = 1.0 - math.cos(math.rad(colorAngle)) * 0.1
		o.wallColor = {color*0.45, color*0.32, color*0.027}
		o.roofColor = {color*0.41, color*0.27, color*0.009}
	elseif trackIsInCity then
		color = 1.0 - math.cos(math.rad(colorAngle)) * 0.1
		o.wallColor = {color,color,color*0.4}
		o.roofColor = {color*0.95,color*0.95,color*0.38}
	else
		color = math.cos(math.rad(colorAngle)) / 50
		o.wallColor = {color,color,color*1.3}
		o.roofColor = o.wallColor
	end
	o.endColor = {o.wallColor[1]/3,o.wallColor[2]/3,o.wallColor[3]/3}
	
	if trackHasRavine then
		colorAngle = colorAngle + 36
	else
		colorAngle = colorAngle + 16
	end
	if colorAngle > 360 then
		colorAngle = 0
	end
	
	return o
end

function TunnelEnd:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	
	local wallHeight = 200 * imageScale
	local wallWidth = 300 * imageScale
	local roofHeight = 120 * imageScale
	
	local y = self.screenY - wallHeight
	local leftX1 = newScreenX - road.ROAD_WIDTH / 2 * imageScale - wallWidth
	local rightX1 = newScreenX + road.ROAD_WIDTH / 2 * imageScale
	
	if self.z < (perspective.maxZ * 0.9) then
		love.graphics.setColor(self.wallColor)
		if not self.ravine then
			love.graphics.rectangle("fill",leftX1,y,wallWidth,wallHeight)
		end
		love.graphics.rectangle("fill",rightX1,y,wallWidth,wallHeight)
		
		love.graphics.setColor(self.roofColor)
		if not self.ravine then
			love.graphics.rectangle("fill",leftX1,y-roofHeight,wallWidth*2+(rightX1-leftX1),roofHeight)
		else
			love.graphics.rectangle("fill",leftX1+wallWidth,y-roofHeight,wallWidth+(rightX1-leftX1),roofHeight)
		end

		if self.lamp then
			local lampWidth = 60 * imageScale
			love.graphics.setColor(1,1,1)
			love.graphics.rectangle("fill",newScreenX-lampWidth/2,y,lampWidth,lampWidth/6)
		end
	else
		-- draw filled rectangle to avoid seeing horizon when tunnel actually continues
		if not self.ravine then
			love.graphics.setColor(self.endColor)
			love.graphics.rectangle("fill",leftX1,y-roofHeight,wallWidth*2+(rightX1-leftX1),wallHeight+roofHeight)
		end
	end
end