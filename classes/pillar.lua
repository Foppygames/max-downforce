-- Max Downforce - classes/pillar.lua
-- 2019 Foppygames

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil
local shadowImg = nil
local shadowHalfHeight = 0

-- pillar is based on entity
Pillar = Entity:new()

function Pillar.init()
	img = love.graphics.newImage("images/pillar.png")
	shadowImg = love.graphics.newImage("images/shadow_pillar.png")
	shadowHalfHeight = shadowImg:getHeight() / 2
end

function Pillar:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = false
	o.baseScale = 10
	o.solid = true
	
	return o
end

function Pillar:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.draw(shadowImg,newScreenX/imageScale,self.screenY/imageScale - shadowHalfHeight)
	love.graphics.setColor(self.color,self.color,self.color)
	love.graphics.draw(self.image,newScreenX/imageScale - self.width/2,self.screenY/imageScale - self.height)
	love.graphics.pop()
	self.storedScreenX = newScreenX
end

function Pillar:getCollisionWidth()
	return self.width / 4
end