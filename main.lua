-- Max Downforce - main.lua
-- 2017-2018 Foppygames

require "classes.car"

-- =========================================================
-- includes
-- =========================================================

-- classes
require "classes.car"

-- modules
local aspect = require("modules.aspect")
local blips = require("modules.blips")
local entities = require("modules.entities")
local horizon = require("modules.horizon")
local perspective = require("modules.perspective")
local road = require("modules.road")
local schedule = require("modules.schedule")
local segments = require("modules.segments")
local utils = require("modules.utils")

-- =========================================================
-- constants
-- =========================================================

local STATE_TITLE = 0
local STATE_RACE = 1
local STATE_GAME_OVER = 2

local LAP_COUNT = 10

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
local cars = 20
local pos = 20

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
	
	Car.init()
	
	entities.init()
	blips.init()
	horizon.init()
	perspective.initZMapAndScaling()
	segments.init()
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
		blips.reset()
		horizon.reset()
		segments.reset()
		segments.addFirst()
	
		local aiTotal = cars-1
		local aiNumber = 1
		local startZ = perspective.zMap[30];
		local dz = (perspective.maxZ - perspective.minZ) / 24
		--local aheadOfPlayer = false
		
		for i = 1, aiTotal+1 do
			local z = startZ+(dz/2)*(i-1)*2
			local x = road.ROAD_WIDTH/6
			if (i % 2 == 0) then
				z = z + dz / 2
				x = x * -1
			end
			if ((i - 1) == (cars - pos)) then
				player = entities.addCar(x,z,true,1) --aheadOfPlayer
				--aheadOfPlayer = true
			else
				entities.addCar(x,z,false,Car.getAiPerformanceFraction(aiNumber,aiTotal)) --aheadOfPlayer
				aiNumber = aiNumber + 1
			end
			
			--print("player after loop "..i..":")
			--print(player)
			
		end
	elseif (state == STATE_GAME_OVER) then
		-- ...
	end
end

function love.update(dt)
	if (state == STATE_RACE) then
		if (player ~= nil) then
			playerSpeed = player.speed
		else
			
			print("love.update() player is nil!")
		
			playerSpeed = 0
		end
		
		-- update texture offset
		textureOffset = textureOffset + playerSpeed * dt
		if (textureOffset > 8) then
			textureOffset = textureOffset - 8
		end
		
		schedule.update(playerSpeed,dt)
		local newBlips = entities.update(playerSpeed,dt,segments.totalLength)
		if (entities.checkLap()) then
			lap = lap + 1
		end
		blips.addBlips(newBlips)
		blips.update(playerSpeed,dt,segments.totalLength)
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
			local color = 255-((5-i)*55)
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
			local roadColor = 0.298
			local curbColorVariant = 1
			local grassColorVariant = 1
			if (((z + textureOffset) % 8) > 4) then
				roadColor = 0.314
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
				love.graphics.setColor(0.176,0.286,0.141)
			else
				love.graphics.setColor(0.149,0.243,0.122)
			end
			love.graphics.line(0,screenY,aspect.GAME_WIDTH,screenY)
			
			-- draw tarmac
			love.graphics.setColor(roadColor,roadColor,roadColor)
			love.graphics.line(x,screenY,x+roadWidth,screenY)
			
			-- draw curbs
			if (curbColorVariant == 1) then
				love.graphics.setColor(0.882,0.263,0)
			else
				love.graphics.setColor(1,1,1)
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
			love.graphics.print("SPEED",aspect.GAME_WIDTH-80,10)
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
		
		-- on screen info: current position
		love.graphics.setColor(0.471,0.902,1)
		love.graphics.print("POS",aspect.GAME_WIDTH/2-20,10)
		love.graphics.print(pos,aspect.GAME_WIDTH/2-20,25)
		love.graphics.print("/ "..cars,aspect.GAME_WIDTH/2,25)
	end
	
	if (state == STATE_GAME_OVER) then
		love.graphics.setColor(1,1,1)
		love.graphics.print("GAME OVER",130,60)
	end
	
	aspect.letterbox()
end