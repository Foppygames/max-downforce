-- Max Downforce - classes/entity.lua
-- 2018 Foppygames

-- modules
local perspective = require("modules.perspective")

-- entity is not based on another class
Entity = {}
    
function Entity:new(x,z)
	o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = x
	o.z = z
	
	o.roadX = 0
	o.storedScreenX = -1
	o.baseScale = 1
	o.scale = 0
	o.smoothX = false
	o.isBanner = false
	o.solid = true
	o.image = nil
	o.width = 0
	o.height = 0
	
	--print("ENTITY SELF:")
	--print(self)
	
	return o
end

function Entity:update()
	-- ...
end

function Entity:scroll(playerSpeed,dt)
	local delete = false
	
	self.z = self.z - playerSpeed * dt
	if ((self.z < perspective.minZ) or (self.z > perspective.maxZ)) then
		-- entity is start finish banner; count lap
		--[[if (entity.entityType == entities.TYPE_BANNER_START) then
			lap = true
		end]]
		
		-- remove entity
		delete = true
	end

	return {
		blip = nil,
		lap = false,
		delete = delete
	}
end

function Entity:setupForDraw(z,roadX,screenY,scale,previousZ,previousRoadX,previousScreenY,previousScale,segment)
	local fractionTowardsZ = (self.z - previousZ) / (z - previousZ)
	local fractionRemaining = 1 - fractionTowardsZ
	self.roadX = fractionTowardsZ * roadX + fractionRemaining * previousRoadX
	self.screenY = fractionTowardsZ * screenY + fractionRemaining * previousScreenY
	self.scale = fractionTowardsZ * scale + fractionRemaining * previousScale
end

function Entity:computeImageScale()
	return self.baseScale * self.scale
end

function Entity:computeNewScreenX()
	local newScreenX = self.roadX + self.x * self.scale
	if (self.smoothX) then
		if (self.storedScreenX ~= -1) then
			return (newScreenX + self.storedScreenX * 1) / 2
		end
	end
	return newScreenX
end

function Entity:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	love.graphics.push()
	love.graphics.scale(imageScale,imageScale)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.image,newScreenX/imageScale - self.width/2,self.screenY/imageScale - self.height)
	love.graphics.pop()
	self.storedScreenX = newScreenX
end

