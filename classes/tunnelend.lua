require "classes.entity"

local aspect = require("modules.aspect")
local daynight = require("modules.daynight")
local lightmap = require("modules.lightmap")
local palette = require("modules.palette")
local perspective = require("modules.perspective")
local road = require("modules.road")

local count = 3
local wallColor

TunnelEnd = Entity:new()

function TunnelEnd.reset(_wallColor)
	count = 3
	wallColor = _wallColor
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
	
	-- Note: slightly increase height (after setting y) to avoid seeing thin line of grass under last tunnel wall
	if self.last then
		wallHeight = wallHeight + 0.5
	end

	if self.z < (perspective.maxZ * 0.9) then
		love.graphics.setColor(self.wallColor)

		if not self.ravine then
			love.graphics.rectangle("fill", leftX1, y, wallWidth, wallHeight)
		end

		love.graphics.rectangle("fill", rightX1, y, wallWidth, wallHeight)
		
		love.graphics.setColor(self.roofColor)

		if not self.ravine then
			love.graphics.rectangle("fill", leftX1, y - roofHeight, wallWidth * 2 + (rightX1 - leftX1), roofHeight)
		else
			love.graphics.rectangle("fill", leftX1 + wallWidth, y - roofHeight, wallWidth + (rightX1 - leftX1), roofHeight)
		end

		if self.lamp then
			local lampWidth = 60 * imageScale

			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("fill", newScreenX - lampWidth / 2, y, lampWidth, lampWidth / 6)
		end
	else
		-- draw filled rectangle to avoid seeing horizon when tunnel actually continues
		if not self.ravine then
			love.graphics.setColor(self.endColor)
			love.graphics.rectangle("fill", leftX1, y - roofHeight, wallWidth * 2 + (rightX1 - leftX1), wallHeight + roofHeight)
		end
	end
end

function TunnelEnd:new(z, trackHasRavine, trackIsInCity, last)
	o = Entity:new(0, z)	

	setmetatable(o, self)

	self.__index = self
	
	count =	count + 1

	o.solid = false
	o.lamp = (count % 6 == 0)
	o.ravine = trackHasRavine
	o.last = last

	if o.lamp then
		lightmap.addLight(z, 10)
	end
	
	local light = math.min(1, 0.95 + lightmap.getSectorLight(z) / 20)
	
	o.wallColor = {light * wallColor[1], light * wallColor[2], light * wallColor[3]}
	
	light = light * 0.90

	o.roofColor = {light * wallColor[1], light * wallColor[2], light * wallColor[3]}
	o.endColor = {o.wallColor[1] / 2, o.wallColor[2] / 2, o.wallColor[3] / 2}
	
	return o
end