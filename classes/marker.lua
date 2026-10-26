require "classes.entity"

local daynight = require("modules.daynight")

local img = nil

Marker = Entity:new()

function Marker.init()
	img = {
		love.graphics.newImage("images/props/marker_left.png"),
		love.graphics.newImage("images/props/marker_left_light.png"),
		love.graphics.newImage("images/props/marker_right.png"),
		love.graphics.newImage("images/props/marker_right_light.png")
	}
end

function Marker:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()

	local sunLight = math.max(self.minLight, daynight:getSunLight())

	love.graphics.push()
	love.graphics.scale(imageScale, imageScale)
	love.graphics.setColor(self.color[1] * sunLight, self.color[2] * sunLight, self.color[3] * sunLight)
	love.graphics.draw(self.image, newScreenX / imageScale - self.width / 2,self.screenY / imageScale - self.height)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.imageLight, newScreenX / imageScale - self.width / 2,self.screenY / imageScale - self.height)
	love.graphics.pop()
	
	self.storedScreenX = newScreenX
end

function Marker:new(x, z)
	o = Entity:new(x, z)

	setmetatable(o, self)
	
	self.__index = self
	
	if x <= 0 then
		o.image = img[1]
		o.imageLight = img[2]
	else
		o.image = img[3]
		o.imageLight = img[4]
	end

	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = false
	o.baseScale = 4
	o.solid = false
	
	return o
end