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
		love.graphics.newImage("images/banner_city_lights.png"),
		love.graphics.newImage("images/banner_city_lanterns.png")
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

	o.poleColor = {1,1,1}
	o.poleWidth = POLE_WIDTH
	o.poleHeight = POLE_HEIGHT
	
	-- banner is forest bridge
	if (forcedImageIndex == 2) then
		o.poleColor = {0.28,0.15,0.05}
		o.poleWidth = o.poleWidth * 10
		o.poleHeight = o.poleHeight * 1.2
	-- banner is city lights
	elseif (forcedImageIndex == 3) then
		o.poleColor = {0.65,0.65,0.65}
		o.poleWidth = o.poleWidth * 2
		o.poleHeight = o.poleHeight * 1.4
	-- banner is city lanterns
	elseif (forcedImageIndex == 4) then
		o.poleColor = {0,0,0}
		o.poleWidth = o.poleWidth * 3
		o.poleHeight = o.poleHeight * 1.6
	end
	
	return o
end

function Banner:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local x1 = newScreenX/imageScale - self.width/2
	local y1 = self.screenY/imageScale - self.poleHeight
	
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.setColor(self.color,self.color,self.color)
	love.graphics.draw(self.image,x1,y1)
	love.graphics.setColor(self.poleColor)
	love.graphics.rectangle("fill",x1-self.poleWidth,y1,self.poleWidth,self.poleHeight)
	love.graphics.rectangle("fill",x1+self.width,y1,self.poleWidth,self.poleHeight)

	-- banner is not city lights or lanterns
	if (self.imageIndex < 3) then
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