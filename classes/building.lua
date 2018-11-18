-- Max Downforce - classes/building.lua
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

-- building is based on entity
Building = Entity:new()

function Building.init()
	img = love.graphics.newImage("images/building.png")
end

function Building:new(x,z)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	o.image = img
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 7
	
	return o
end