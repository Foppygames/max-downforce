-- Max Downforce - classes/light.lua
-- 2019 Foppygames

require "classes.entity"

local img = nil

Light = Entity:new()

function Light.init()
	img = love.graphics.newImage("images/light.png")
end

function Light:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 16
	o.solid = false
	
	return o
end