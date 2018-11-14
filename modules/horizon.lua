-- Max Downforce - modules/horizon.lua
-- 2017-2018 Foppygames

local horizon = {}

-- =========================================================
-- includes
-- =========================================================

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local segments = require("modules.segments")

-- =========================================================
-- public constants
-- =========================================================

-- ...

-- =========================================================
-- private variables
-- =========================================================

local image = {}
local layer = 0
local width = {}
local count = {}
local x = {}
local y = {}
local speed = {}

-- =========================================================
-- public functions
-- =========================================================

function horizon.init()
	image = {
		love.graphics.newImage("images/horizon_clouds.png"),
		love.graphics.newImage("images/horizon_hills.png"),
		love.graphics.newImage("images/horizon_trees.png"),
	}
	layers = #image
	for i = 1,layers,1 do
		width[i] = image[i]:getWidth()
		count[i] = math.ceil(aspect.GAME_WIDTH / width[i]) + 1
		x[i] = 0
		y[i] = perspective.HORIZON_Y - image[i]:getHeight()
		speed[i] = 1600 + (i-1) * 190
	end
end

function horizon.reset()
	layers = #image
	for i = 1,layers,1 do
		x[i] = 0
	end
end

function horizon.update(playerSegmentDdx,playerSpeed,dt)
	for i = 1,layers,1 do
		x[i] = x[i] - speed[i] * playerSegmentDdx * playerSpeed * dt
		if (x[i] < -width[i]) then
			x[i] = x[i] + width[i]
		elseif (x[i] > 0) then
			x[i] = x[i] - width[i]
		end
	end
end

function horizon.draw()
	love.graphics.setColor(1,1,1)
	for i = 1,layers,1 do
		for j = 0,count[i]-1,1 do
			love.graphics.draw(image[i],x[i]+j*width[i],y[i])
		end
	end
end

return horizon