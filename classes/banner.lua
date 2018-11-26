-- Max Downforce - classes/banner.lua
-- 2018 Foppygames

-- classes
require "classes.entity"

-- local constants
local POLE_WIDTH = 1
local POLE_HEIGHT = 30

-- local variables
local img = nil
local imgIndex = 1

-- banner is based on entity
Banner = Entity:new()

function Banner.init()
	img = {
		love.graphics.newImage("images/banner_start.png")
	}
end

function Banner:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img[imgIndex]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 8
	o.solid = false
	
	imgIndex = imgIndex + 1
	if (imgIndex > #img) then
		imgIndex = 1
	end
	
	return o
end

function Banner:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local x1 = newScreenX/imageScale - self.width/2
	local y1 = self.screenY/imageScale - POLE_HEIGHT
	
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.setColor(self.color,self.color,self.color)
	love.graphics.draw(self.image,x1,y1)
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("fill",x1-POLE_WIDTH,y1,POLE_WIDTH,POLE_HEIGHT)
	love.graphics.rectangle("fill",x1+self.width,y1,POLE_WIDTH,POLE_HEIGHT)
	love.graphics.pop()
	self.storedScreenX = newScreenX
end

function Banner:isStartBanner()
	return true
end