-- Max Downforce - modules/horizon.lua
-- 2017-2019 Foppygames

local horizon = {}

-- =========================================================
-- includes
-- =========================================================

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local segments = require("modules.segments")
local tracks = require("modules.tracks")

-- =========================================================
-- public constants
-- =========================================================

local IMAGE_INDEXES_RAVINE_TRACK = {1, 5, 2, 5}
local IMAGE_INDEXES_NON_RAVINE_TRACK = {1, 2, 3}
local COLOR_RAVINE_TRACK = {0.2,0.3,0.6}
local COLOR_NON_RAVINE_TRACK = {1,1,1}

-- =========================================================
-- private variables
-- =========================================================

local image = {}
local imageIndexes = {}
local width = {}
local count = {}
local x = {}
local y = {}
local speed = {}
local layerCount = 0
local color

-- =========================================================
-- public functions
-- =========================================================

function horizon.init()
	image = {
		love.graphics.newImage("images/horizon_clouds.png"),
		love.graphics.newImage("images/horizon_hills.png"),
		love.graphics.newImage("images/horizon_trees.png"),
		love.graphics.newImage("images/horizon_clouds_2.png"),
		love.graphics.newImage("images/horizon_hills_2.png")
	}
end

function horizon.reset()
	if (tracks.hasRavine()) then
		imageIndexes = IMAGE_INDEXES_RAVINE_TRACK
		color = COLOR_RAVINE_TRACK
	else
		imageIndexes = IMAGE_INDEXES_NON_RAVINE_TRACK
		color = COLOR_NON_RAVINE_TRACK
	end

	layerCount = #imageIndexes
	for i = 1,layerCount,1 do
		width[i] = image[imageIndexes[i]]:getWidth()
		count[i] = math.ceil(aspect.GAME_WIDTH / width[i]) + 1
		x[i] = -math.random(0,20)
		if (not tracks.hasRavine()) then
			y[i] = perspective.HORIZON_Y - image[imageIndexes[i]]:getHeight()
		else
			y[i] = (aspect.GAME_HEIGHT * 0.6) + ((i-1) * 8) - image[imageIndexes[i]]:getHeight()
		end
		speed[i] = 1600 + (i-1) * 190
	end
end

function horizon.update(playerSegmentDdx,playerSpeed,dt)
	for i = 1,layerCount,1 do
		x[i] = x[i] - speed[i] * playerSegmentDdx * playerSpeed * dt
		if (x[i] < -width[i]) then
			x[i] = x[i] + width[i]
		elseif (x[i] > 0) then
			x[i] = x[i] - width[i]
		end
	end
end

function horizon.draw()
	love.graphics.setColor(color)
	for i = 1,layerCount,1 do
		for j = 0,count[i]-1,1 do
			love.graphics.draw(image[imageIndexes[i]],x[i]+j*width[i],y[i])
		end
	end
end

return horizon