require "classes.entity"

local daynight = require("modules.daynight")
local lightmap = require("modules.lightmap")
local palette = require("modules.palette")

local POLE_WIDTH = 1
local POLE_HEIGHT = 30

local img = nil
local imgIndex = 1

Banner = Entity:new()

function Banner.init()
	img = {
		love.graphics.newImage("images/props/banner_start.png"),
		nil,
		love.graphics.newImage("images/props/banner_forest_bridge.png"),
		nil,
		love.graphics.newImage("images/props/banner_city_lights.png"),
		love.graphics.newImage("images/props/banner_city_lights_light.png"),
		love.graphics.newImage("images/props/banner_city_lanterns.png"),
		love.graphics.newImage("images/props/banner_city_lanterns_light.png")
	}
end

function Banner:new(x, z, forcedImageIndex)
	o = Entity:new(x, z)	

	setmetatable(o, self)

	self.__index = self
	
	if forcedImageIndex ~= nil then
		o.imageIndex = forcedImageIndex
	else
		o.imageIndex = imgIndex

		imgIndex = imgIndex + 1

		if imgIndex > #img then
			imgIndex = 1
		end	
	end

	o.image = img[o.imageIndex]
	o.imageLight = img[o.imageIndex + 1]
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()
	o.smoothX = true
	o.baseScale = 8
	o.solid = false
	o.poleColor = {1, 1, 1}
	o.poleWidth = POLE_WIDTH
	o.poleHeight = POLE_HEIGHT
	
	-- banner is forest bridge
	if forcedImageIndex == 3 then
		o.poleColor = palette.HEPT32_17
		o.poleWidth = o.poleWidth * 8
		o.poleHeight = math.ceil(o.poleHeight * 1.2)
	-- banner is city lights
	elseif forcedImageIndex == 5 then
		o.poleColor = palette.HEPT32_6
		o.poleWidth = o.poleWidth * 2
		o.poleHeight = math.ceil(o.poleHeight * 1.4)
	-- banner is city lanterns
	elseif forcedImageIndex == 7 then
		o.poleColor = palette.HEPT32_22
		o.poleWidth = o.poleWidth * 3
		o.poleHeight = math.ceil(o.poleHeight * 1.6)
	-- banner is start
	elseif forcedImageIndex == 1 then
		lightmap.addLight(z, 12)
	end
	
	return o
end

function Banner:draw()
	local imageScale = self:computeImageScale()
	local newScreenX = self:computeNewScreenX()
	local sunLight = math.max(self.minLight + 0.1, daynight.getSunLight())
	local x1 = newScreenX / imageScale - self.width / 2
	local y1 = self.screenY / imageScale - self.poleHeight

	love.graphics.push()
	love.graphics.scale(imageScale, imageScale)
	love.graphics.setColor(self.color[1] * sunLight, self.color[2] * sunLight, self.color[3] * sunLight)
	love.graphics.draw(self.image, x1, y1)
	love.graphics.setColor(self.poleColor[1] * sunLight, self.poleColor[2] * sunLight, self.poleColor[3] * sunLight)
	love.graphics.rectangle("fill", x1 - self.poleWidth, y1, self.poleWidth, self.poleHeight)
	love.graphics.rectangle("fill", x1 + self.width, y1, self.poleWidth, self.poleHeight)
	
	if self.imageLight ~= nil then
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.imageLight, x1, y1)
	end

	-- banner is not city lights or lanterns
	if self.imageIndex < 5 then
		-- draw shadow
		love.graphics.setColor(0, 0, 0, 0.3)
		love.graphics.rectangle("fill", x1, self.screenY / imageScale - 2, self.width, 2)
	end

	love.graphics.pop()

	self.storedScreenX = newScreenX
end

function Banner:isStartBanner()
	return self.imageIndex == 1
end