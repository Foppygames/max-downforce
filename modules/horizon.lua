local horizon = {}

local aspect = require("modules.aspect")
local daynight = require("modules.daynight")
local perspective = require("modules.perspective")
local segments = require("modules.segments")
local tracks = require("modules.tracks")

local IMAGE_INDEXES_FOREST_TRACK = {1, 2, 3}
local IMAGE_INDEXES_MOUNTAIN_TRACK = {1, 4, 2, 4}
local IMAGE_INDEXES_CITY_TRACK = {5, 6, 5}

local SUN_FULL_CIRCLE_LENGTH = aspect.GAME_WIDTH * 4.572
local SUN_SPEED = 1600

local image = {}
local imageIndexes = {}
local width = {}
local count = {}
local x = {}
local y = {}
local speed = {}
local layerCount = 0
local skyHeight
local drawRavineBackground
local ravineBackgroundY
local ravineBackgroundHeight

local imgSun
local sunX

function horizon.init()
	image = {
		love.graphics.newImage("images/horizon/horizon_clouds.png"),
		love.graphics.newImage("images/horizon/horizon_hills.png"),
		love.graphics.newImage("images/horizon/horizon_trees.png"),
		love.graphics.newImage("images/horizon/horizon_hills_2.png"),
		love.graphics.newImage("images/horizon/horizon_skyscrapers.png"),
		love.graphics.newImage("images/horizon/horizon_buildings.png")
	}

	imgSun = love.graphics.newImage("images/sky/sun.png")

	sunX = aspect.GAME_WIDTH / 2
end

function horizon.reset()
	if tracks.isInMountains() then
		imageIndexes = IMAGE_INDEXES_MOUNTAIN_TRACK
		color = COLOR_MOUNTAIN_TRACK
	elseif tracks.isInForest() then
		imageIndexes = IMAGE_INDEXES_FOREST_TRACK
		color = COLOR_FOREST_TRACK
	else
		imageIndexes = IMAGE_INDEXES_CITY_TRACK
		color = COLOR_CITY_TRACK
	end

	layerCount = #imageIndexes

	for i = 1, layerCount, 1 do
		width[i] = image[imageIndexes[i]]:getWidth()
		count[i] = math.ceil(aspect.GAME_WIDTH / width[i]) + 1
		x[i] = -math.random(0, 20)

		if not tracks.hasRavine() then
			y[i] = perspective.HORIZON_Y - image[imageIndexes[i]]:getHeight()
		else
			y[i] = (aspect.GAME_HEIGHT * 0.6) + ((i - 1) * 8) - image[imageIndexes[i]]:getHeight()
		end

		speed[i] = 1600 + (i - 1) * 190
	end

	drawRavineBackground = false

	if layerCount == 0 then
		skyHeight = perspective.HORIZON_Y
	else
		skyHeight = y[1] + image[imageIndexes[1]]:getHeight()

		if tracks.hasRavine() then
			drawRavineBackground = true
			ravineBackgroundY = y[layerCount] + image[imageIndexes[layerCount]]:getHeight()
			ravineBackgroundHeight = aspect.GAME_HEIGHT - ravineBackgroundY
		end
	end

	sunX = aspect.GAME_WIDTH / 2
end

function horizon.update(playerSegmentDdx, playerSpeed, dt)
	-- move horizon layers
	for i = 1, layerCount, 1 do
		x[i] = x[i] - speed[i] * playerSegmentDdx * playerSpeed * dt

		if (x[i] < -width[i]) then
			x[i] = x[i] + width[i]
		elseif (x[i] > 0) then
			x[i] = x[i] - width[i]
		end
	end

	-- move sun
	sunX = sunX - SUN_SPEED * playerSegmentDdx * playerSpeed * dt

	if sunX > SUN_FULL_CIRCLE_LENGTH then
		sunX = -(SUN_FULL_CIRCLE_LENGTH - (sunX - SUN_FULL_CIRCLE_LENGTH))
	end

	if sunX < -SUN_FULL_CIRCLE_LENGTH then
		sunX = SUN_FULL_CIRCLE_LENGTH + (sunX + SUN_FULL_CIRCLE_LENGTH)
	end
end

function horizon.draw()
	love.graphics.setColor(1, 1, 1)
	
	-- draw sky	
	love.graphics.draw(daynight:getSkyGradient(), 0, 0, 0, aspect.GAME_WIDTH, skyHeight)

	-- draw sun
	love.graphics.draw(imgSun, sunX, perspective.HORIZON_Y - daynight.getSunHeight() * perspective.HORIZON_Y)
	
	-- draw horizon layers
	local sunLight = math.max(0.1, daynight:getSunLight())

	love.graphics.setColor(sunLight, sunLight, sunLight)

	for i = 1, layerCount, 1 do
		for j = 0, count[i]-1, 1 do
			love.graphics.draw(image[imageIndexes[i]], x[i] + j * width[i], y[i])
		end
	end

	if drawRavineBackground then
		-- draw mountain color below horizon
		love.graphics.setColor(0.314 * sunLight, 0.533 * sunLight, 0.690 * sunLight)
		love.graphics.rectangle("fill", 0, ravineBackgroundY, aspect.GAME_WIDTH, ravineBackgroundHeight)
	end
end

return horizon