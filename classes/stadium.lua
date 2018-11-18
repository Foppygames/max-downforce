-- Max Downforce - classes/stadium.lua
-- 2018 Foppygames

-- modules
local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local road = require("modules.road")

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil

-- stadium is based on entity
Stadium = Entity:new()

function Stadium.init()
	img = {
		love.graphics.newImage("images/stadium_left.png"),
		love.graphics.newImage("images/stadium_right.png")
	}
end

function Stadium:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	if (x < 0) then
		o.image = img[1]
	else
		o.image = img[2]
	end
	
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 14
	
	return o
end