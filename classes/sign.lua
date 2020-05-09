-- Max Downforce - classes/sign.lua
-- 2018 Foppygames

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil
local imgIndex = 1

-- sign is based on entity
Sign = Entity:new()

function Sign.init()
	img = {
		love.graphics.newImage("images/sign1.png"),
		love.graphics.newImage("images/sign2.png"),
		love.graphics.newImage("images/sign3.png")
	}
end

function Sign.resetIndex()
	imgIndex = 1
end

function Sign:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img[imgIndex]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 12
	
	imgIndex = imgIndex + 1
	if (imgIndex > #img) then
		imgIndex = 1
	end
	
	return o
end

function Sign:setSegment(segment)
	self.segment = segment
	if (segment.isInCity and (not segment.light)) then
		self.color = 0.35
	end
end
