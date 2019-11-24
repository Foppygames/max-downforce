-- Max Downforce - classes/building.lua
-- 2018 Foppygames

-- modules
-- ...

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil

-- building is based on entity
Building = Entity:new()

function Building.init()
	img = {
		love.graphics.newImage("images/building_low.png"),
		love.graphics.newImage("images/building_high.png")
	}
end

function Building:new(x,z,high)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	if (high) then
		o.image = img[2]
	else
		o.image = img[1]
	end
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 12
	o.mirrorX = 1
	if ((not high) and (x > 0)) then
		o.mirrorX = -1
	end
	
	return o
end

function Building:draw()
	local imageScaleX = self:computeImageScale()
	local imageScaleY = imageScaleX
	imageScaleX = imageScaleX * self.mirrorX
	local newScreenX = self:computeNewScreenX()
	love.graphics.push()
	love.graphics.scale(imageScaleX,imageScaleY)
	love.graphics.setColor(self.color,self.color,self.color)
	love.graphics.draw(self.image,newScreenX/imageScaleX - self.width/2,self.screenY/imageScaleY - self.height)
	love.graphics.pop()
	self.storedScreenX = newScreenX
end