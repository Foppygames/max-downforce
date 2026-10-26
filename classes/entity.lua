local daynight = require("modules.daynight")
local perspective = require("modules.perspective")

Entity = {}

function Entity:new(x, z)
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
	o.solid = true
	o.image = nil
	o.width = 0
	o.height = 0
	o.color = {1, 1, 1}
	o.segment = nil
	o.minLight = 0
	
	return o
end

-- returns whether entity is to be deleted
function Entity:update(dt)
	return false
end

function Entity:scroll(playerSpeed, dt)
	local lap = false
	local delete = false
	
	self.z = self.z - playerSpeed * dt

	if (self.z < perspective.minZ) or (self.z > perspective.maxZ) then
		-- entity is start banner; count lap
		if self:isStartBanner() then
			lap = true
		end
		
		-- remove entity
		delete = true
	end

	return {
		lap = lap,
		delete = delete
	}
end

function Entity:setupForDraw(z, roadX, screenY, scale, previousZ, previousRoadX, previousScreenY, previousScale, segment, minLight)
	if self.segment == nil then
		self:setSegment(segment)
	end

	local fractionTowardsZ = (self.z - previousZ) / (z - previousZ)
	local fractionRemaining = 1 - fractionTowardsZ

	self.roadX = fractionTowardsZ * roadX + fractionRemaining * previousRoadX
	self.screenY = fractionTowardsZ * screenY + fractionRemaining * previousScreenY
	self.scale = fractionTowardsZ * scale + fractionRemaining * previousScale
	self.minLight = minLight
end

function Entity:computeImageScale()
	return self.baseScale * self.scale
end

function Entity:computeNewScreenX()
	local newScreenX = self.roadX + self.x * self.scale

	if self.smoothX and (self.storedScreenX ~= -1) then
		return (newScreenX + self.storedScreenX * 1) / 2
	end

	return newScreenX
end

function Entity:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()

	local sunLight = math.max(self.minLight, daynight:getSunLight())

	love.graphics.push()
	love.graphics.scale(imageScale, imageScale)
	love.graphics.setColor(self.color[1] * sunLight, self.color[2] * sunLight, self.color[3] * sunLight)
	love.graphics.draw(self.image, newScreenX / imageScale - self.width / 2,self.screenY / imageScale - self.height)
	love.graphics.pop()
	
	self.storedScreenX = newScreenX
end

function Entity:isCar()
	return false
end

function Entity:isStadium()
	return false
end

function Entity:isStartBanner()
	return false
end

function Entity:isTunnelStart()
	return false
end

function Entity:getCollisionWidth()
	return self.width
end

function Entity:setSegment(segment)
	self.segment = segment
end

-- cleans up object prior to deletion
function Entity:clean()
	-- ...
end
