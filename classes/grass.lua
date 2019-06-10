-- Max Downforce - classes/grass.lua
-- 2019 Foppygames

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil

-- grass is based on entity
Grass = Entity:new()

function Grass.init()
	img = {
		love.graphics.newImage("images/grass.png"),
		love.graphics.newImage("images/grass_flowers.png")
	}
end

function Grass:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img[math.random(2)]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 10
	o.solid = false
	
	return o
end