-- Max Downforce - classes/tree.lua
-- 2018 Foppygames

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil

-- tree is based on entity
Tree = Entity:new()

function Tree.init()
	img = {
		love.graphics.newImage("images/tree2.png"),
		love.graphics.newImage("images/tree3.png")
	}
end

function Tree:new(x,z,color)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img[math.random(2)]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 10
	o.color = color
	
	return o
end

-- use reduced collision width for collision with trunk only
function Tree:getCollisionWidth()
	return self.width / 2
end