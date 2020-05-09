-- Max Downforce - classes/tree.lua
-- 2018-2019 Foppygames

-- classes
require "classes.entity"

-- local constants
-- ...

-- local variables
local img = nil
local shadowImg = nil
local ravineShadowImg = nil
local shadowHalfWidth = 0
local shadowHalfHeight = 0

-- tree is based on entity
Tree = Entity:new()

function Tree.init()
	img = {
		love.graphics.newImage("images/tree2.png"),
		love.graphics.newImage("images/tree3.png"),
		love.graphics.newImage("images/tree4.png"),
		love.graphics.newImage("images/tree5.png"),
		love.graphics.newImage("images/tree6.png")
	}
	shadowImg = love.graphics.newImage("images/shadow_tree.png")
	ravineShadowImg = love.graphics.newImage("images/shadow_tree_ravine.png")
end

function Tree:new(x,z,color,mountain)
	o = Entity:new(x,z)	
	setmetatable(o, self)
	self.__index = self
	
	if (mountain) then
		if (x > 0) then
			o.image = img[3]
			o.shadowImg = shadowImg
		else
			o.image = img[3+math.random(2)]
			o.shadowImg = ravineShadowImg
		end
	else
		o.image = img[math.random(2)]
		o.shadowImg = shadowImg
	end
	o.shadowHalfWidth = o.shadowImg:getWidth() / 2
	o.shadowHalfHeight = o.shadowImg:getHeight() / 2
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
	love.graphics.draw(self.shadowImg,newScreenX/imageScale - self.shadowHalfWidth,self.screenY/imageScale - self.shadowHalfHeight)
	love.graphics.setColor(self.color,self.color,self.color)
	love.graphics.draw(self.image,newScreenX/imageScale - self.width/2,self.screenY/imageScale - self.height)
	love.graphics.pop()
	self.storedScreenX = newScreenX
end

-- use reduced collision width for collision with trunk only
function Tree:getCollisionWidth()
	return self.width / 2
end

function Tree:setSegment(segment)
	self.segment = segment
	if (segment.isInCity and (not segment.light)) then
		self.color = 0.25
	end
end