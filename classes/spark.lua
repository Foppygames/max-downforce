-- Max Downforce - classes/spark.lua
-- 2019 Foppygames

-- classes
require "classes.entity"

-- modules
local perspective = require("modules.perspective")

-- local constants
-- ...

-- local variables
local img = nil

-- spark is based on entity
Spark = Entity:new()

function Spark.init()
	img = {
		love.graphics.newImage("images/spark1.png"),
		love.graphics.newImage("images/spark2.png"),
		love.graphics.newImage("images/spark3.png"),
		love.graphics.newImage("images/spark4.png"),
		love.graphics.newImage("images/spark5.png")
	}
end

function Spark:new(x,z,speed,color)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.speed = speed
	o.color = color
	
	o.imageIndex = 1
	o.imageTime = 1
	o.imageSpeed = math.random(10,30)
	o.image = img[o.imageIndex]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.solid = false
	o.baseScale = math.random(3,5)
	
	return o
end

function Spark:update(dt)
	local delete = false
	if (self.speed > 0) then
		self.z = self.z + self.speed * dt
		self.speed = self.speed - 400 * dt
		if (self.speed <= 0) then
			self.speed = 0
		end
	end
	self.imageTime = self.imageTime - self.imageSpeed * dt
	if (self.imageTime <= 0) then
		self.imageIndex = self.imageIndex + 1
		if (self.imageIndex > #img) then
			self.imageIndex = 1
			delete = true
		end
		self.image = img[self.imageIndex]
		self.imageTime = self.imageTime + 1
	end
	return delete
end