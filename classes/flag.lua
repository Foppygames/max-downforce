-- Max Downforce - classes/flag.lua
-- 2019 Foppygames

require "classes.entity"

local img = nil
local index

Flag = Entity:new()

function Flag.init()
	img = {
		love.graphics.newImage("images/flag1.png"),
		love.graphics.newImage("images/flag2.png")
	}
	index = 1
end

function Flag:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	index = index + 1
	if (index > #img) then
		index = 1
	end
	o.image = img[index]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 16
	o.solid = false
	
	return o
end