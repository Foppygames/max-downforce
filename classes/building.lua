require "classes.entity"

local daynight = require("modules.daynight")

local img = nil

Building = Entity:new()

function Building.init()
	img = {
		love.graphics.newImage("images/props/building_low.png"),
		love.graphics.newImage("images/props/building_low_light.png"),
		love.graphics.newImage("images/props/building_high.png"),
		love.graphics.newImage("images/props/building_high_light.png"),
		love.graphics.newImage("images/props/building_city.png"),
		love.graphics.newImage("images/props/building_city_light.png")
	}
end

function Building:new(x, z, high, city)
	o = Entity:new(x, z)

	setmetatable(o, self)

	self.__index = self
	
	if high then
		o.image = img[3]
		o.imageLight = img[4]
	elseif city then
		o.image = img[5]
		o.imageLight = img[6]
	else
		o.image = img[1]
		o.imageLight = img[2]
	end

	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 12
	o.mirrorX = 1

	if (not high) and (x > 0) then
		o.mirrorX = -1
	end
	
	return o
end

function Building:draw()
	local imageScaleX = self:computeImageScale()
	local imageScaleY = imageScaleX

	imageScaleX = imageScaleX * self.mirrorX

	local newScreenX = self:computeNewScreenX()
	local sunLight = math.max(0.4, daynight:getSunLight())

	love.graphics.push()
	love.graphics.scale(imageScaleX, imageScaleY)
	love.graphics.setColor(self.color[1] * sunLight, self.color[2] * sunLight, self.color[3] * sunLight)
	love.graphics.draw(self.image, newScreenX / imageScaleX - self.width / 2, self.screenY / imageScaleY - self.height)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.imageLight, newScreenX / imageScaleX - self.width / 2, self.screenY / imageScaleY - self.height)
	love.graphics.pop()

	self.storedScreenX = newScreenX
end

function Building:setSegment(segment)
	self.segment = segment

	--[[if segment.isInCity and (not segment.light) then
		self.color = 0.35
	end--]]
end