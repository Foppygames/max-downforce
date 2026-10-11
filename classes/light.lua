require "classes.entity"

local daynight = require("modules.daynight")

local img = nil

Light = Entity:new()

function Light.init()
	img = {
		love.graphics.newImage("images/props/light.png"),
		love.graphics.newImage("images/props/light_light.png")
	}
end

function Light:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()

	local sunLight = math.max(0.3, daynight:getSunLight())

	love.graphics.push()
	love.graphics.scale(imageScale, imageScale)
	love.graphics.setColor(self.color[1] * sunLight, self.color[2] * sunLight, self.color[3] * sunLight)
	love.graphics.draw(self.image, newScreenX / imageScale - self.width / 2, self.screenY / imageScale - self.height)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.imageLight, newScreenX / imageScale - self.width / 2, self.screenY / imageScale - self.height)
	love.graphics.pop()
	
	self.storedScreenX = newScreenX
end

function Light:new(x, z)
	o = Entity:new(x, z)

	setmetatable(o, self)
	
	self.__index = self
	
	o.image = img[1]
	o.imageLight = img[2]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 16
	o.solid = false
	
	return o
end