-- Max Downforce - main.lua
-- 2017-2019 Foppygames

-- =========================================================
-- includes
-- =========================================================

require "classes.banner"
require "classes.building"
require "classes.car"
require "classes.sign"
require "classes.stadium"
require "classes.tree"

local aspect = require("modules.aspect")
local entities = require("modules.entities")
local horizon = require("modules.horizon")
local opponents = require("modules.opponents")
local perspective = require("modules.perspective")
local road = require("modules.road")
local schedule = require("modules.schedule")
local segments = require("modules.segments")
local sound = require("modules.sound")
local utils = require("modules.utils")

-- =========================================================
-- constants
-- =========================================================

local STATE_TITLE = 0
local STATE_RACE = 1
local STATE_GAME_OVER = 2

local LAP_COUNT = 10
local CAR_COUNT = 6
local FINISHED_COUNT = 5

-- =========================================================
-- variables
-- =========================================================

local state
local fullScreen = false
local textureOffset = 0
local imageSky = nil
local player = nil
local playerX = 0
local playerSpeed = 0
local lap = 0
local progress = 0
local finished = false
local finishedCount = 0

-- =========================================================
-- functions
-- =========================================================

function love.load()
	setupGame()
	switchToState(STATE_TITLE)
end

function setupGame()
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setLineStyle("rough")
	
	love.audio.setVolume(0.8)
	
	imageSky = love.graphics.newImage("images/sky.png")
	
	Banner.init()
	Building.init()
	Car.init()
	Sign.init()
	Stadium.init()
	Tree.init()
	
	entities.init()
	horizon.init()
	perspective.initZMapAndScaling()
	opponents.init()
	segments.init()
	sound.init()
	aspect.init(fullScreen)
end

function switchToState(newState)
	state = newState
	
	-- actions that apply to all states
	entities.reset()
	love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf",10))
	
	-- actions that apply to specific states
	if (state == STATE_TITLE) then
		-- ...
	elseif (state == STATE_RACE) then
		lap = 0
		progress = 0
		finished = false
		finishedCount = 0

		horizon.reset()
		opponents.reset()
		schedule.reset()
		segments.reset()
		segments.addFirst()
	
		local startZ = perspective.zMap[30]
		local dz = (perspective.maxZ - perspective.minZ) / 13
		
		-- player not on first segment
		if ((CAR_COUNT * dz) > (segments.FIRST_SEGMENT_LENGTH * perspective.maxZ)) then
			print("Warning: player not on first segment")
		end
		
		-- scroll towards player position with respect to end of first segment
		segments.update(segments.FIRST_SEGMENT_LENGTH * perspective.maxZ - ((CAR_COUNT + 4) * dz), 1)
		
		-- add cars from back to front
		for i = 1, CAR_COUNT do
			local z = startZ + dz * (i - 1)
			local x = 1
			if (i % 2 == 0) then
				z = z + dz / 2
				x = -1
			end
			if (i == 1) then
				player = entities.addCar(x,z,true,1)
			else
				entities.addCar(x,z,false,0.1)
			end
		end
	elseif (state == STATE_GAME_OVER) then
		-- ...
	end
end

function love.update(dt)
	if (state == STATE_RACE) then
		local playerX
		
		if (player ~= nil) then
			playerSpeed = player.speed
			playerX = player.x
		else
			playerSpeed = 0
			playerX = nil
		end
		
		-- update texture offset
		textureOffset = textureOffset + playerSpeed * dt
		if (textureOffset > 8) then
			textureOffset = textureOffset - 8
		end
		
		schedule.update(playerSpeed,dt)
		
		local aiCarCount = entities.update(playerSpeed,dt,segments.totalLength)
		
		if (entities.checkLap()) then
			lap = lap + 1
			if (lap > LAP_COUNT) then
				if ((not finished) and (player ~= nil)) then
					-- turn player car into cpu car
					player:setIsPlayer(false)
					
					-- start count down after finish
					finishedCount = FINISHED_COUNT
				end
				finished = true
			else
				progress = lap / LAP_COUNT
				
				print(progress)
			end
		end
		
		opponents.update(playerSpeed,progress,aiCarCount,dt)
		segments.update(playerSpeed,dt)
		horizon.update(segments.getAtIndex(1).ddx,playerSpeed,dt)
		
		if (player ~= nil) then
			if (player.explodeCount > 0) then
				player.explodeCount = player.explodeCount - dt
				if (player.explodeCount <= 0) then
					switchToState(STATE_GAME_OVER)
				end
			end
		end
		
		if (finishedCount > 0) then
			finishedCount = finishedCount - dt
			if (finishedCount <= 0) then
				switchToState(STATE_GAME_OVER)
			end
		end
	end
end

function love.keypressed(key)
	if (state == STATE_TITLE) then
		if (key == "w") then
			fullScreen = not fullScreen
			aspect.init(fullScreen)
		end
		if (key == "space") then
			switchToState(STATE_RACE)
		end
	end
	if (state == STATE_RACE) then
		if (key == "escape") then
			switchToState(STATE_TITLE)
		end
	end
	if (state == STATE_GAME_OVER) then
		if (key == "space") then
			switchToState(STATE_TITLE)
		end
	end
end

function love.draw()
	aspect.apply()
	
	if (state == STATE_TITLE) then
		for i = 1, 5 do
			local color = 1-(5-i)*0.2
			love.graphics.setColor(color,color,color)
			love.graphics.print("Max Downforce",110,20+i*8)	
		end
		
		love.graphics.setColor(0.470,0.902,1)
		love.graphics.print("W = windowed / full screen",75,120)
		
		love.graphics.setColor(1,1,1)
		love.graphics.print("Press space to start",90,170)
	end
	
	if (state == STATE_RACE) then
		-- draw sky
		love.graphics.setColor(1,1,1)
		love.graphics.draw(imageSky,0,0)
		
		horizon.draw()
		
		-- initial vertical position of drawing of road
		local screenY = aspect.GAME_HEIGHT-0.5
		
		if (player ~= nil) then
			playerX = player.x
		end
		
		-- initial horizontal position of drawing of road
		local screenX = aspect.GAME_WIDTH/2 - playerX*perspective.scale[1]
		
		-- correction to always make road point to horizontal center of horizon
		local perspectiveDX = (aspect.GAME_WIDTH/2-screenX)/perspective.GROUND_HEIGHT
				
		-- assuming segments contains at least one segment!
		local segmentIndex = 1
		local lastSegmentIndex = segments.getLastIndex()
		local segment = segments.getAtIndex(segmentIndex)
		
		local dx = 0

		entities.resetForDraw()	
		
		-- values for interpolating entity positions
		local previousZ = perspective.minZ
		local previousScreenX = screenX
		local previousScreenY = screenY
		local previousScale = perspective.scale[1]
		
		-- draw road
		for i = 1, perspective.GROUND_HEIGHT do
			local z = perspective.zMap[i]
			
			-- set colors
			local roadColor = 0.24 --0.28
			local curbColorVariant = 1
			local grassColorVariant = 1
			if (((z + textureOffset) % 8) > 4) then
				roadColor = 0.26 --0.34
				curbColorVariant = 2
				grassColorVariant = 2
			end
			
			if (segment.texture == segments.TEXTURE_START_FINISH) then
				roadColor = 1
			end
			
			if (segmentIndex < lastSegmentIndex) then
				if (z > segments.getAtIndex(segmentIndex+1).z) then
					segmentIndex = segmentIndex + 1
					segment = segments.getAtIndex(segmentIndex)
				end
			end

			local roadWidth = road.ROAD_WIDTH * perspective.scale[i]
			local curbWidth = road.CURB_WIDTH * perspective.scale[i]
			local stripeWidth = road.STRIPE_WIDTH * perspective.scale[i]
			
			local x = screenX - roadWidth / 2
			
			-- update entities x,y,scale
			entities.setupForDraw(z,screenX,screenY,perspective.scale[i],previousZ,previousScreenX,previousScreenY,previousScale,segment)
			
			-- draw grass
			if (grassColorVariant == 1) then
				love.graphics.setColor(0.45,0.8,0.25)
			else
				love.graphics.setColor(0.36,0.6,0.20)
			end
			love.graphics.line(0,screenY,aspect.GAME_WIDTH,screenY)
			
			-- draw tarmac
			love.graphics.setColor(roadColor*1.2,roadColor,roadColor)
			love.graphics.line(x,screenY,x+roadWidth,screenY)
			
			-- draw curbs
			if (curbColorVariant == 1) then
				love.graphics.setColor(1,0.263,0)
			else
				love.graphics.setColor(1,0.95,0.95)
			end
			love.graphics.line(x,screenY,x+curbWidth,screenY)
			love.graphics.line(x+roadWidth-curbWidth,screenY,x+roadWidth,screenY)
			
			-- draw stripes
			if (curbColorVariant == 2) then
				love.graphics.line(screenX-stripeWidth/2,screenY,screenX+stripeWidth/2,screenY)
			end
			
			previousZ = z
			previousScreenX = screenX
			previousScreenY = screenY
			previousScale = perspective.scale[i]
			
			-- no hills, just decrease y by one
			screenY = screenY - 1
			
			-- update the change that is applied to x
			dx = dx + segment.ddx * perspective.zMap[i] * (perspective.zMap[i] / 6) * ((perspective.scale[1]-perspective.scale[i])*2.5)
			
			-- apply the change to x and apply perspective correction 
			screenX = screenX + dx + perspectiveDX
		end
		
		entities.draw()
		
		-- on screen info: player speed
		if (player ~= nil) then
			love.graphics.setColor(0.471,0.902,1)
			love.graphics.print("SPEED",aspect.GAME_WIDTH-60,10)
			love.graphics.print(player:getSpeedAsKMH(),aspect.GAME_WIDTH-80,25)
			love.graphics.print("km/h",aspect.GAME_WIDTH-50,25)
		end
		
		-- on screen info: current lap
		love.graphics.setColor(0.471,0.902,1)
		love.graphics.print("LAP",20,10)
		love.graphics.print(math.max(lap,1),20,25)
		love.graphics.print("/ "..LAP_COUNT,40,25)
		if (lap == LAP_COUNT) then
			love.graphics.print("FINAL LAP",20,40)
		elseif (lap > LAP_COUNT) then
			love.graphics.print("RACE OVER",20,40)
		end
		
		-- on screen info: time
		love.graphics.setColor(1,1,0)
		love.graphics.print("TIME",aspect.GAME_WIDTH/2-20,10)
		love.graphics.print("60",aspect.GAME_WIDTH/2-12,25)
	end
	
	if (state == STATE_GAME_OVER) then
		love.graphics.setColor(1,1,1)
		if (not finished) then
			love.graphics.print("GAME OVER",130,60)
		else
			love.graphics.print("CONGRATULATIONS!",95,60)
		end
	end
	
	aspect.letterbox()
end