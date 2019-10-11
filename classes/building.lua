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
	
	return o
end