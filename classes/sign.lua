require "classes.entity"

local daynight = require("modules.daynight")

local img = nil
local imgIndex = 1

Sign = Entity:new()

function Sign.init()
	img = {
		love.graphics.newImage("images/props/sign1.png"),
		love.graphics.newImage("images/props/sign1_light.png"),
		love.graphics.newImage("images/props/sign2.png"),
		love.graphics.newImage("images/props/sign2_light.png"),
		love.graphics.newImage("images/props/sign3.png"),
		love.graphics.newImage("images/props/sign3_light.png")
	}
end

function Sign.resetIndex()
	imgIndex = 1
end

function Sign:draw()
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

function Sign:new(x, z)
	o = Entity:new(x, z)

	setmetatable(o, self)

	self.__index = self
	
	o.image = img[imgIndex]
	o.imageLight = img[imgIndex + 1]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 12
	
	imgIndex = imgIndex + 2

	if imgIndex > #img then
		imgIndex = 1
	end
	
	return o
end

function Sign:setSegment(segment)
	self.segment = segment

	--[[if segment.isInCity and (not segment.light) then
		self.color = 0.35
	end--]]
end
