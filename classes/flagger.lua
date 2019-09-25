-- Max Downforce - classes/flagger.lua
-- 2019 Foppygames

-- classes
require "classes.entity"

-- local constants
local WAVE_TIME = 0.2

-- local variables
local img = nil

-- grass is based on entity
Flagger = Entity:new()

function Flagger.init()
	img = {
		love.graphics.newImage("images/flagger_left_1.png"),
		love.graphics.newImage("images/flagger_left_2.png"),
		love.graphics.newImage("images/flagger_right_1.png"),
		love.graphics.newImage("images/flagger_right_2.png")
	}
end

function Flagger:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	if (x < 0) then
		o.index = 1
	else
		o.index = 3
	end
	
	o.image = img[o.index]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 5
	o.solid = false
	
	o.waveTime = 0
	
	return o
end

function Flagger:update(dt)
	self.waveTime = self.waveTime - dt
	if (self.waveTime <= 0) then
		self.index = self.index + 1
		if ((self.index == 3) or (self.index == 5)) then
			self.index = self.index - 2
		end
		self.image = img[self.index]
		self.waveTime = WAVE_TIME
	end

	return false
end