-- Max Downforce - classes/banner.lua
-- 2018-2020 Foppygames

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
		love.graphics.newImage("images/banner_start.png"),
		love.graphics.newImage("images/banner_forest_bridge.png"),
		love.graphics.newImage("images/banner_city_lights.png")
	}
end

function Banner:new(x,z,forcedImageIndex)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	if (forcedImageIndex ~= nil) then
		o.imageIndex = forcedImageIndex
	else
		o.imageIndex = imgIndex
		imgIndex = imgIndex + 1
		if (imgIndex > #img) then
			imgIndex = 1
		end	
	end
	o.image = img[o.imageIndex]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 8
	o.solid = false
	
	return o
end

function Banner:draw()
	local poleWidth = POLE_WIDTH
	local poleHeight = POLE_HEIGHT
	local color = {1,1,1}
	
	-- banner is forest bridge
	if (self.imageIndex == 2) then
		color = {0.28,0.15,0.05}
		poleWidth = poleWidth * 10
		poleHeight = poleHeight * 1.2
	end
	
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local x1 = newScreenX/imageScale - self.width/2
	local y1 = self.screenY/imageScale - poleHeight
	
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.setColor(self.color,self.color,self.color)
	love.graphics.draw(self.image,x1,y1)
	love.graphics.setColor(color)
	love.graphics.rectangle("fill",x1-poleWidth,y1,poleWidth,poleHeight)
	love.graphics.rectangle("fill",x1+self.width,y1,poleWidth,poleHeight)

	-- banner is not city lights
	if (self.imageIndex ~= 3) then
		-- draw shadow
		love.graphics.setColor(0,0,0,0.3)
		love.graphics.rectangle("fill",x1,self.screenY/imageScale-2,self.width,2)
	end

	love.graphics.pop()
	self.storedScreenX = newScreenX
end

function Banner:isStartBanner()
	return (self.imageIndex == 1)
end