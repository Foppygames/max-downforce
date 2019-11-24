-- Max Downforce - classes/marker.lua
-- 2019 Foppygames

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil

-- marker is based on entity
Marker = Entity:new()

function Marker.init()
	img = love.graphics.newImage("images/marker.png")
end

function Marker:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = false
	o.baseScale = 4
	o.solid = false
	
	return o
end