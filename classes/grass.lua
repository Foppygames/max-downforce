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
		love.graphics.newImage("images/grass_flowers.png"),
		love.graphics.newImage("images/grass_mountain.png")
	}
end

function Grass:new(x,z,mountain)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	if (mountain) then
		o.image = img[3]
		o.baseScale = 6
	else
		o.image = img[math.random(2)]
		o.baseScale = 10
	end
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.solid = false
	
	return o
end