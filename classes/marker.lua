require "classes.entity"

local img = nil

Marker = Entity:new()

function Marker.init()
	img = love.graphics.newImage("images/props/marker.png")
end

function Marker:new(x, z)
	o = Entity:new(x, z)

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