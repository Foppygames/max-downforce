-- Max Downforce - classes/tree.lua
-- 2018 Foppygames

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil
local shadowImg = nil
local shadowHeight = 0

-- tree is based on entity
Tree = Entity:new()

function Tree.init()
	img = {
		love.graphics.newImage("images/tree2.png"),
		love.graphics.newImage("images/tree3.png")
	}
	shadowImg = love.graphics.newImage("images/shadow_tree.png")
	shadowHalfWidth = shadowImg:getWidth() / 2
	shadowHalfHeight = shadowImg:getHeight() / 2
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

function Tree:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.draw(shadowImg,newScreenX/imageScale - shadowHalfWidth,self.screenY/imageScale - shadowHalfHeight)
	love.graphics.setColor(self.color,self.color,self.color)
	love.graphics.draw(self.image,newScreenX/imageScale - self.width/2,self.screenY/imageScale - self.height)
	love.graphics.pop()
	self.storedScreenX = newScreenX
end

-- use reduced collision width for collision with trunk only
function Tree:getCollisionWidth()
	return self.width / 2
end