local daynight = require("modules.daynight")
local lightmap = require("modules.lightmap")

require "classes.entity"

local WAVE_TIME = 0.2

local img = nil

Flagger = Entity:new()

function Flagger.init()
	img = {
		love.graphics.newImage("images/props/flagger_left_1.png"),
		love.graphics.newImage("images/props/flagger_left_2.png"),
		love.graphics.newImage("images/props/flagger_right_1.png"),
		love.graphics.newImage("images/props/flagger_right_2.png")
	}
end

function Flagger:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local light
	local sectorLight = lightmap.getSectorLight(self.z) / 2

	if self.inTunnel then
		light = math.min(1, 0.95 + sectorLight / 20)
	else
		local sunLight = math.max(self.minLight + 0.3, daynight.getSunLight())

		light = math.min(1, sunLight + sectorLight)
	end

	love.graphics.push()
	love.graphics.scale(imageScale, imageScale)
	love.graphics.setColor(self.color[1] * light, self.color[2] * light, self.color[3] * light)
	love.graphics.draw(self.image, newScreenX / imageScale - self.width / 2, self.screenY / imageScale - self.height)
	love.graphics.pop()
	
	self.storedScreenX = newScreenX
end

function Flagger:new(x, z)
	o = Entity:new(x, z)

	setmetatable(o, self)

	self.__index = self
	
	if x < 0 then
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
	o.inTunnel = false
	
	return o
end

function Flagger:setupForDraw(z, roadX, screenY, scale, previousZ, previousRoadX, previousScreenY, previousScale, segment, minLight)
	Entity.setupForDraw(self, z, roadX, screenY, scale, previousZ, previousRoadX, previousScreenY, previousScale, segment, minLight)

	self.inTunnel = segment.tunnel
end

function Flagger:update(dt)
	self.waveTime = self.waveTime - dt

	if self.waveTime <= 0 then
		self.index = self.index + 1

		if (self.index == 3) or (self.index == 5) then
			self.index = self.index - 2
		end
		
		self.image = img[self.index]
		self.waveTime = WAVE_TIME
	end

	return false
end