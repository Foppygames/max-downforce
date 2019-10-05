-- Max Downforce - modules/aspect.lua
-- 2017-2018 Foppygames

local aspect = {}

-- =========================================================
-- includes
-- =========================================================

local utils = require("modules.utils")

-- =========================================================
-- constants
-- =========================================================

aspect.WINDOW_WIDTH = 960 --1280 --640
aspect.WINDOW_HEIGHT = 600 --800 --400
aspect.GAME_WIDTH = 320
aspect.GAME_HEIGHT = 200

local BAR_COLOR = {0,0,0}

-- =========================================================
-- variables
-- =========================================================

local windowWidth
local windowHeight
local gameWidth = aspect.GAME_WIDTH
local gameHeight = aspect.GAME_HEIGHT
local scale
local bars
local gameX
local gameY

-- =========================================================
-- public functions
-- =========================================================

function aspect.init(fullScreen)
	if (fullScreen) then
		local _, _, flags = love.window.getMode()
		local width, height = love.window.getDesktopDimensions(flags.display)
		windowWidth = width
		windowHeight = height
		
		-- hide mouse
		love.mouse.setVisible(false)
	else
		windowWidth = aspect.WINDOW_WIDTH
		windowHeight = aspect.WINDOW_HEIGHT
		
		-- show mouse
		love.mouse.setVisible(true)
	end

	bars = {}
	
	local gameAspect = gameWidth / gameHeight
	local windowAspect = windowWidth / windowHeight
	
	if (gameAspect > windowAspect) then
		-- game is wider than window; scale to use full width, use horizontal letterboxing
		scale = windowWidth / gameWidth
		local scaledGameHeight = gameHeight * scale
		local barHeight = math.ceil((windowHeight - scaledGameHeight) / 2)
		gameX = 0
		gameY = barHeight
		table.insert(bars,{
			x = 0,
			y = 0,
			width = windowWidth,
			height = barHeight
		})
		table.insert(bars,{
			x = 0,
			y = windowHeight - barHeight,
			width = windowWidth,
			height = barHeight
		})
	elseif (windowAspect > gameAspect) then
		-- window is wider than game; scale to use full height, use vertical letterboxing
		scale = windowHeight / gameHeight
		local scaledGameWidth = gameWidth * scale
		local barWidth = math.ceil((windowWidth - scaledGameWidth) / 2)
		gameX = barWidth
		gameY = 0
		table.insert(bars,{
			x = 0,
			y = 0,
			width = barWidth,
			height = windowHeight
		})
		table.insert(bars,{
			x = windowWidth-barWidth,
			y = 0,
			width = barWidth,
			height = windowHeight
		})
	else
		-- scale to full width and height, no letterboxing
		scale = windowWidth / gameWidth
		gameX = 0
		gameY = 0
	end
	
	love.window.setMode(aspect.WINDOW_WIDTH,aspect.WINDOW_HEIGHT,{fullscreen=fullScreen,fullscreentype="desktop"})	
end

--function aspect.toggleFullScreen()
--	love.window.setFullscreen( fullscreen, fstype )
--end

function aspect.apply()
	love.graphics.push()
	love.graphics.translate(gameX,gameY)
	love.graphics.scale(scale)
end

function aspect.letterbox()
	love.graphics.pop()
	love.graphics.push()
	love.graphics.setColor(BAR_COLOR[1],BAR_COLOR[2],BAR_COLOR[3])
	for i = 1, #bars do
		love.graphics.rectangle("fill",bars[i].x,bars[i].y,bars[i].width,bars[i].height)
	end
	love.graphics.pop()
end

return aspect