-- Max Downforce - modules/states.lua
-- 2019-2020 Foppygames

local states = {}

-- =========================================================
-- includes
-- =========================================================

require "classes.banner"
require "classes.building"
require "classes.car"
require "classes.flag"
require "classes.flagger"
require "classes.grass"
require "classes.light"
require "classes.marker"
require "classes.pillar"
require "classes.sign"
require "classes.stadium"
require "classes.spark"
require "classes.tree"

local aspect = require("modules.aspect")
local controls = require("modules.controls")
local entities = require("modules.entities")
local horizon = require("modules.horizon")
local opponents = require("modules.opponents")
local perspective = require("modules.perspective")
local road = require("modules.road")
local schedule = require("modules.schedule")
local segments = require("modules.segments")
local sound = require("modules.sound")
local timer = require("modules.timer")
local tracks = require("modules.tracks")

-- =========================================================
-- constants
-- =========================================================

local STATE_TITLE = 0
local STATE_RACE = 1
local STATE_GAME_OVER = 2

local CAR_COUNT = 6
local COLORS_CURBS_NO_RAVINE = {{1, 0.26, 0}, {1, 0.95, 0.95}}
local COLORS_CURBS_RAVINE = {{0.1, 0.26, 0.8}, {1, 0.95, 0.95}}
local COLORS_CURBS_CITY = {
	light = {{1, 0.26, 0}, {1, 0.95, 0.95}},
	no_light = {{0.8, 0.1, 0}, {0.8, 0.6, 0.6}}
}
local COLORS_GRASS_NO_RAVINE = {{0.45, 0.8, 0.25}, {0.36, 0.6, 0.20}}
local COLORS_GRASS_RAVINE = {{0.5, 0.36, 0.03}, {0.45, 0.31, 0.01}}
local COLORS_GRASS_CITY = {{0.03, 0.0, 0.0}, {0.06, 0.05, 0.05}}
local COLORS_STRIPES_RAVINE = {
	tunnel = {0.9, 0.9, 0},
	no_tunnel = {1, 0.95, 0.95}
}
local COLORS_STRIPES_NO_RAVINE = {
	tunnel = {0.8, 0.8, 0},
	no_tunnel = {1, 0.95, 0.95}
}
local COLORS_STRIPES_CITY = {
	tunnel = {1, 0.95, 0.95},
	no_tunnel = {0.8, 0.6, 0.6}
}
local COLORS_TARMAC_RAVINE = {
	tunnel = {{0.24, 0.2, 0.26}, {0.24, 0.2, 0.26}},
	no_tunnel = {{0.39, 0.28, 0.28}, {0.42, 0.30, 0.30}}
}
local COLORS_TARMAC_NO_RAVINE = {
	tunnel = {{0.1, 0.1, 0.13}, {0.11, 0.11, 0.14}},
	no_tunnel = {{0.34, 0.28, 0.28}, {0.37, 0.30, 0.30}}
}
local COLORS_TARMAC_CITY = {
	tunnel = {{0.39, 0.28, 0.28}, {0.42, 0.30, 0.30}},
	no_tunnel = {{0.22, 0.14, 0.18}, {0.24, 0.16, 0.20}}
}
local LAP_COUNT = 10
local TIME_AFTER_FINISHED = 5
local TIME_BEFORE_BEEPS = 0.7
local TIME_BEFORE_START = 2.5

-- =========================================================
-- variables
-- =========================================================

local afterFinishedTimer = 0
local beepCounter = 0
local beepTimer = 0
local curbColors = nil
local finished = false
local fullScreen = false --true
local grassColors = nil
local lap = 0
local player = nil
local previousLastSegmentHadTunnel = false
local previousDisplayTime = nil
local previousRavineX = nil
local progress = 0
local ravineMinX = nil
local ravineMinXY = nil
local selectedJoystick
local selectedTrack = nil
local state
local stripeColors = nil
local tarmacColors = nil
local textureOffset = 0
local title = ""
local titleShineIndex = 0
local titleShineTimer = 0
local trackHasRavine
local trackIsInMountains
local trackIsInForest
local trackIsInCity
local tunnelWallDistance = 0
local version = ""

local imageTrophyBronze = nil
local imageTrophySilver = nil
local imageTrophyGold = nil
local imageGamepadModeR = nil
local imageGamepadModeL = nil

-- =========================================================
-- private functions
-- =========================================================

local function drawGameOverScreen()
	love.graphics.setColor(1,1,1)
	if (not finished) then
		love.graphics.push()
		love.graphics.scale(2,2)
		love.graphics.print("GAME OVER",45,20)
		love.graphics.pop()
		
		-- still in first lap
		if (lap < 2) then
			love.graphics.print("Don't give up!",120,70)
		-- beyond first lap
		else
			love.graphics.setColor(1,1,0)
			-- in second lap
			if (lap == 2) then
				love.graphics.print("You completed 1 full lap",85,70)
				love.graphics.setColor(1,1,1)
				love.graphics.print("Well done!",131,95)
			-- beyond second lap
			else
				love.graphics.print("You completed "..(lap-1).." full laps",80,70)
				-- completed more than one lap
				if (lap > 2) then
					love.graphics.setColor(1,1,1)
					-- completed nine laps
					if (lap == 10) then
						love.graphics.print("You win the silver cup!",89,95)
						love.graphics.draw(imageTrophySilver,aspect.GAME_WIDTH/2-imageTrophySilver:getWidth()/2,120)
					-- completed eight laps
					elseif (lap == 9) then
						love.graphics.print("You win the bronze cup!",85,95)
						love.graphics.draw(imageTrophyBronze,aspect.GAME_WIDTH/2-imageTrophyBronze:getWidth()/2,120)
					-- completed between two and seven laps
					else
						love.graphics.print("Well done!",131,95)
					end
				end
			end
		end
	else
		love.graphics.push()
		love.graphics.scale(2,2)
		love.graphics.print("CONGRATULATIONS!",15,20)
		love.graphics.pop()
		love.graphics.setColor(1,1,0)
		love.graphics.print("You finished the race",92,70)
		love.graphics.setColor(1,1,1)
		love.graphics.print("You win the gold cup!",95,95)
		love.graphics.draw(imageTrophyGold,aspect.GAME_WIDTH/2-imageTrophyGold:getWidth()/2,120)
		love.graphics.setColor(0.471,0.902,1)
		love.graphics.print("You may consider yourself a member of",30,150)
		love.graphics.print("an elite group of grand prix racers",40,170)
	end
end

local function drawTitleScreen()
	local titleAllCaps = string.upper(title)
	love.graphics.push()
	love.graphics.scale(2,2)
	for i = 1, string.len(titleAllCaps) do
		local diff = math.abs(i - titleShineIndex)
		if (diff > 1) then
			love.graphics.setColor(1,0,0)
		elseif (diff == 1) then
			love.graphics.setColor(1,0.5,0.5)
		else
			love.graphics.setColor(1,1,1)
		end
		love.graphics.print(string.sub(titleAllCaps,i,i),8 + i * 10,6)
	end
	love.graphics.pop()
	
	love.graphics.setColor(0.1,0.1,0.3)
	love.graphics.print(version,260,4)
	
	love.graphics.setColor(1,1,1)
	love.graphics.print("Written by Robbert Prins",75,45)
	love.graphics.print(sound.MUSIC_CREDITS,sound.MUSIC_CREDITS_X,65)
	
	love.graphics.setColor(0.470,0.902,1)
	love.graphics.print("T = track: '"..tracks.getSelectedTrackName().."'",75,90)
	love.graphics.print("W = windowed / full screen",75,105)
	love.graphics.print("M = music: "..sound.getMusicEnabledLabel(),75,120)

	-- more than one control method available
	if (controls.getAvailableCount() > 1) then
		love.graphics.setColor(0.470,0.902,1)
		love.graphics.print("C = controls: "..controls.getSelected().label,75,135)
	-- one control method available (note: assuming there is never less than one)
	else
		love.graphics.setColor(1,1,1)
		love.graphics.print("Controls: "..controls.getSelected().label,75,135)
	end

	if (controls.getSelected().type == controls.GAMEPAD) then
		love.graphics.setColor(1,1,1)
		if (controls.getSelected().mode == controls.GAMEPAD_MODE_R) then
			love.graphics.draw(imageGamepadModeR,225,135)
		else
			love.graphics.draw(imageGamepadModeL,225,135)
		end
	end

	love.graphics.setColor(1,1,1)
	love.graphics.print(controls.getSelected().startText,90+controls.getSelected().startTextDx,160)
	
	love.graphics.setColor(1,1,0)
	love.graphics.print("Foppygames 2019-2020",82,178)
end

local function drawInfoCurrentLap()
	love.graphics.setColor(0.471,0.902,1)
	love.graphics.print("LAP",20,10)
	love.graphics.print(math.max(lap,1),20,25)
	love.graphics.print("/ "..LAP_COUNT,40,25)
	if (lap == LAP_COUNT) then
		love.graphics.print("FINAL LAP",20,40)
	elseif (lap > LAP_COUNT) then
		love.graphics.print("RACE OVER",20,40)
	end
end

local function drawInfoPlayerSpeed()
	if (player ~= nil) then
		love.graphics.setColor(0.471,0.902,1)
		love.graphics.print("SPEED",aspect.GAME_WIDTH-60,10)
		love.graphics.print(player:getSpeedAsKMH(),aspect.GAME_WIDTH-80,25)
		love.graphics.print("km/h",aspect.GAME_WIDTH-50,25)
	end
end

local function drawInfoTime()
	love.graphics.setColor(1,1,0)
	love.graphics.print("TIME",aspect.GAME_WIDTH/2-20,10)
	local timeScale = 1
	if (timer.isDangerous()) then
		timeScale = 2
	end
	love.graphics.push()
	love.graphics.scale(timeScale,timeScale)
	love.graphics.print(timer.getDisplayTime(),(aspect.GAME_WIDTH/2-12)/timeScale,25/timeScale)
	love.graphics.pop()
end

local function drawGrass(trackHasRavine,tunnel,crossroads,light,colorIndex,ravineX,screenY,roadX)
	if (crossroads) then
		if (tunnel or light) then
			love.graphics.setColor(tarmacColors.tunnel[colorIndex])
		else
			love.graphics.setColor(tarmacColors.no_tunnel[colorIndex])
		end
	else
		love.graphics.setColor(grassColors[colorIndex])
	end
	if (trackHasRavine) then	
		if (not tunnel) then
			love.graphics.line(ravineX,screenY,aspect.GAME_WIDTH,screenY)	
		else
			love.graphics.line(ravineX,screenY,roadX,screenY)
			love.graphics.setColor(0,0,0)
			love.graphics.line(roadX,screenY,aspect.GAME_WIDTH,screenY)
		end
	else
		if (tunnel) then
			love.graphics.setColor(0,0,0)
		end
		love.graphics.line(0,screenY,aspect.GAME_WIDTH,screenY)
	end
end

local function drawTarmac(trackHasRavine,tunnel,colorIndex,roadX,screenY,roadWidth)
	if (tunnel) then
		love.graphics.setColor(tarmacColors.tunnel[colorIndex])
	else
		love.graphics.setColor(tarmacColors.no_tunnel[colorIndex])
	end
	love.graphics.line(roadX,screenY,roadX+roadWidth,screenY)
end

local function drawTunnelRoof(segment,screenY,x,roadWidth)
	-- experiment: draw tunnel roof as upside down black road
	-- Note: cancelled for now, would work together with reversed order drawing
	-- so tunnel walls are drawn as part of drawing road instead of using entities
	if (segment.tunnel) then
		love.graphics.setColor(1,0,0)
		local roofY = screenY - (200 * perspective.scale[i])
		love.graphics.line(x,roofY,x+roadWidth,roofY)
	end
end

local function drawCurbs(light,colorIndex,roadX,screenY,curbWidth,roadWidth)
	if (trackIsInCity) then
		if (light) then
			love.graphics.setColor(curbColors.light[colorIndex])
		else
			love.graphics.setColor(curbColors.no_light[colorIndex])
		end
	else
		love.graphics.setColor(curbColors[colorIndex])
	end
	love.graphics.line(roadX,screenY,roadX+curbWidth,screenY)
	love.graphics.line(roadX+roadWidth-curbWidth,screenY,roadX+roadWidth,screenY)
end

local function drawStripes(tunnel,trackHasRavine,screenX,stripeWidth,screenY)
	if (tunnel) then
		love.graphics.setColor(stripeColors.tunnel)
	else
		love.graphics.setColor(stripeColors.no_tunnel)
	end
	love.graphics.line(screenX-stripeWidth/2,screenY,screenX+stripeWidth/2,screenY)
end

local function setCurbColors()
	if (trackIsInMountains) then
		curbColors = COLORS_CURBS_RAVINE
	elseif (trackIsInForest) then
		curbColors = COLORS_CURBS_NO_RAVINE
	else
		curbColors = COLORS_CURBS_CITY
	end
end

local function setGrassColors()
	if (trackIsInMountains) then
		grassColors = COLORS_GRASS_RAVINE
	elseif (trackIsInForest) then
		grassColors = COLORS_GRASS_NO_RAVINE
	else
		grassColors = COLORS_GRASS_CITY
	end
end

local function setStripeColors()
	if (trackIsInMountains) then
		stripeColors = COLORS_STRIPES_RAVINE
	elseif (trackIsInForest) then
		stripeColors = COLORS_STRIPES_NO_RAVINE
	else
		stripeColors = COLORS_STRIPES_CITY
	end
end

local function setTarmacColors()
	if (trackIsInMountains) then
		tarmacColors = COLORS_TARMAC_RAVINE
	elseif (trackIsInForest) then
		tarmacColors = COLORS_TARMAC_NO_RAVINE
	else
		tarmacColors = COLORS_TARMAC_CITY
	end
end

local function setupStartingGrid()
	local startZ = perspective.zMap[30]
	local dz = (perspective.maxZ - perspective.minZ) / 13
	
	-- player not on first segment
	if ((CAR_COUNT * dz) > (segments.getFirstSegmentLength() * (perspective.maxZ - perspective.minZ))) then
		print("Warning: player not on first segment")
	end
	
	-- add cars from back to front
	for i = 1, CAR_COUNT do
		local z = startZ + dz * (i - 1)
		local x = 1
		if (i % 2 == 0) then
			z = z + dz / 2
			x = -1
		end
		if (i == 1) then
			player = entities.addCar(x,z,true,1,TIME_BEFORE_START)
		else
			entities.addCar(x,z,false,0.1,TIME_BEFORE_START)
		end
	end
	
	-- init start sequence
	beepTimer = TIME_BEFORE_BEEPS
	beepCounter = 0
end

local function switchToState(newState)
	-- clean up current state
	if (state == STATE_RACE) then
		if (sound.musicIsEnabled()) then
			sound.stop(tracks.getSong())
		end
		sound.stop(sound.CROWD)
	elseif (state == STATE_TITLE) then
		if (sound.musicIsEnabled()) then
			sound.stop(sound.TITLE_MUSIC)
		end
	end
	entities.reset(tracks.hasRavine(),tracks.isInCity())

	-- init new state
	state = newState
	if (state == STATE_TITLE) then
		math.randomseed(os.time())
		if (sound.musicIsEnabled()) then
			sound.play(sound.TITLE_MUSIC)
		end
		titleShineIndex = 0
	elseif (state == STATE_RACE) then
		lap = 0
		progress = 0
		finished = false
		afterFinishedTimer = 0
		previousDisplayTime = nil
		trackHasRavine = tracks.hasRavine()
		trackIsInMountains = tracks.isInMountains()
		trackIsInForest = tracks.isInForest()
		trackIsInCity = tracks.isInCity()

		horizon.reset()
		schedule.reset()
		segments.reset()
		segments.addFirst()
		opponents.reset()
		timer.reset(progress,TIME_BEFORE_START)
		TunnelEnd.reset()
	
		setupStartingGrid()
		setCurbColors()
		setGrassColors()
		setStripeColors()
		setTarmacColors()
	end
end

-- =========================================================
-- public functions
-- =========================================================

function states.init(gameVersion,gameTitle)
	version = gameVersion
	title = gameTitle

	love.window.setTitle(title)
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setLineStyle("rough")
	love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf",10))
	
	imageTrophyBronze = love.graphics.newImage("images/trophy_bronze.png")
	imageTrophySilver = love.graphics.newImage("images/trophy_silver.png")
	imageTrophyGold = love.graphics.newImage("images/trophy_gold.png")
	imageGamepadModeR = love.graphics.newImage("images/gamepad_r.png")
	imageGamepadModeL = love.graphics.newImage("images/gamepad_l.png")

	Banner.init()
	Building.init()
	Car.init()
	Flag.init()
	Flagger.init()
	Grass.init()
	Light.init()
	Marker.init()
	Pillar.init()
	Sign.init()
	Spark.init()
	Stadium.init()
	Tree.init()
	
	aspect.init(fullScreen)
	entities.init()
	horizon.init()
	perspective.initZMapAndScaling()
	opponents.init()
	segments.init()
	sound.init()

	selectedJoystick = controls.init()

	switchToState(STATE_TITLE)
end

function states.update(dt)
	if (state == STATE_RACE) then
		if (beepTimer > 0) then
			beepTimer = beepTimer - dt
			if (beepTimer <= 0) then
				beepCounter = beepCounter + 1
				if (beepCounter == 3) then
					sound.play(sound.BEEP_2)
					beepTimer = 0
					
					-- reset music volume after possible countdown
					sound.setVolume(tracks.getSong(),sound.VOLUME_MUSIC)
					
					if (sound.musicIsEnabled()) then
						sound.play(tracks.getSong())
					end
				else
					sound.play(sound.BEEP_1)
					beepTimer = (TIME_BEFORE_START - TIME_BEFORE_BEEPS) / 2
				end
			end
		end
		
		local playerSpeed
		if (player ~= nil) then
			playerSpeed = player.speed
		else
			playerSpeed = 0
		end
		
		-- update texture offset
		textureOffset = textureOffset + playerSpeed * dt
		if (textureOffset > 8) then
			textureOffset = textureOffset - 8
		end
		
		schedule.update(playerSpeed,dt)
		
		local entitiesUpdateResult = entities.update(playerSpeed,dt,segments.totalLength)
		
		sound.updateCrowdVolume(entitiesUpdateResult.stadiumNear,dt)
		
		if (entities.checkLap()) then
			-- reset music volume after possible countdown
			sound.setVolume(tracks.getSong(),sound.VOLUME_MUSIC)
			
			Sign.resetIndex()

			lap = lap + 1
			
			if (lap > 1) then
				sound.play(sound.LAP)
			end
			
			if (lap > LAP_COUNT) then
				timer.halt()
			
				if ((not finished) and (player ~= nil)) then
					-- turn player car into cpu car
					player:setIsPlayer(false)
					
					-- start count down after finish
					afterFinishedTimer = TIME_AFTER_FINISHED
				end
				finished = true
			else
				progress = lap / LAP_COUNT
				
				if (lap > 1) then
					timer.reset(progress,0)
				end
			end
		end
		
		opponents.update(playerSpeed,progress,entitiesUpdateResult.aiCarCount,dt)
		segments.update(playerSpeed,dt)
		horizon.update(segments.getAtIndex(1).ddx,playerSpeed,dt)
		
		local lastSegment = segments.getAtIndex(segments.getLastIndex())
		if (lastSegment.tunnel) then
			tunnelWallDistance = tunnelWallDistance + playerSpeed * dt
			while (tunnelWallDistance > 3) do
				tunnelWallDistance = tunnelWallDistance - 3
				entities.addTunnelEnd(perspective.maxZ - tunnelWallDistance)
			end
		elseif (previousLastSegmentHadTunnel) then
			tunnelWallDistance = 0
			TunnelEnd.reset()
		end
		previousLastSegmentHadTunnel = lastSegment.tunnel
		
		if (afterFinishedTimer > 0) then
			afterFinishedTimer = afterFinishedTimer - dt
			if (afterFinishedTimer <= 0) then
				switchToState(STATE_GAME_OVER)
			end
		end
		
		local timeOk = timer.update(dt)
		
		if (timer.isDangerous()) then
			local displayTime = timer.getDisplayTime()
			if (displayTime ~= previousDisplayTime) then
				local steps = timer.getTimeDangerous()
				local stepsTaken = steps - displayTime
				local volume = sound.VOLUME_COUNTDOWN_MIN + stepsTaken * ((sound.VOLUME_COUNTDOWN_MAX - sound.VOLUME_COUNTDOWN_MIN) / steps)
				sound.setVolume(sound.COUNTDOWN,volume)
				sound.setVolume(tracks.getSong(),sound.VOLUME_COUNTDOWN_MAX - volume)
				sound.play(sound.COUNTDOWN)
				previousDisplayTime = displayTime
			end
		end
		
		if (not timeOk) then
			switchToState(STATE_GAME_OVER)
		end
	elseif (state == STATE_TITLE) then
		titleShineTimer = titleShineTimer + 20 * dt
		if (titleShineTimer >= 1) then
			titleShineTimer = 0
			titleShineIndex = titleShineIndex + 1
			if (titleShineIndex > 150) then
				titleShineIndex = 0
			end
		end
	end
end

function states.updateKeyPressed(key)
	if (state == STATE_TITLE) then
		if (key == "m") then
			sound.toggleMusicEnabled()
		end
		if (key == "t") then
			tracks.selectNextTrack()
		end
		if (key == "w") then
			fullScreen = not fullScreen
			aspect.init(fullScreen)
		end
		if (key == "c") then
			selectedJoystick = controls.selectNextAvailable()
		end
		if (key == "space") then
			switchToState(STATE_RACE)
		end
		if (key == "escape") then
			love.event.quit()
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

function states.updateGamepadPressed(joystick,button)
	if (joystick == selectedJoystick) then
		if (state == STATE_TITLE) then
			if ((button == "a") or (button == "start")) then
				switchToState(STATE_RACE)
			end
		end
		if (state == STATE_RACE) then
			if (button == "back") then
				switchToState(STATE_TITLE)
			end
		end
		if (state == STATE_GAME_OVER) then
			if ((button == "a") or (button == "start")) then
				switchToState(STATE_TITLE)
			end
		end
	end
end

function states.draw()
	aspect.apply()
	
	if (state == STATE_RACE) then
		-- draw sky
		tracks.getSelectedTrack().drawSky()

		-- draw horizon
		horizon.draw()

		-- draw ravine
		if (trackHasRavine) then
			if (ravineMinX ~= nil) then
				love.graphics.setColor(0.25,0.18,0.015)
				love.graphics.rectangle("fill",ravineMinX,ravineMinXY,aspect.GAME_WIDTH-ravineMinX,aspect.GAME_HEIGHT-ravineMinXY)	
			end
		end

		-- initial vertical position of drawing of road
		local screenY = aspect.GAME_HEIGHT-0.5
		
		local playerX
		if (player ~= nil) then
			playerX = player.x
		else
			playerX = 0
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
		
		previousRavineX = nil
		ravineMinX = nil

		-- draw road
		for i = 1, perspective.GROUND_HEIGHT do
			local z = perspective.zMap[i]
			
			-- set default color index
			local colorIndex = 1
			
			-- toggle colors for horizontal striping effect
			if (((z + textureOffset) % 8) > 4) then
				colorIndex = 2
			end
			
			-- consider switching to next segment
			if (segmentIndex < lastSegmentIndex) then
				if (z > segments.getAtIndex(segmentIndex+1).z) then
					segmentIndex = segmentIndex + 1
					segment = segments.getAtIndex(segmentIndex)
				end
			end
			
			local roadWidth = road.ROAD_WIDTH * perspective.scale[i]
			local curbWidth = road.CURB_WIDTH * perspective.scale[i]
			local stripeWidth = road.STRIPE_WIDTH * perspective.scale[i]
			local roadX = screenX - roadWidth / 2
			local ravineX = roadX - road.RAVINE_ROADSIDE_WIDTH * perspective.scale[i]
			
			-- keep track of smallest ravine x for drawing ravine wall
			if (trackHasRavine) then
				if ((previousRavineX ~= nil) and (ravineX < previousRavineX)) then
					if ((ravineMinX == nil) or (ravineX < ravineMinX)) then
						ravineMinX = ravineX
						ravineMinXY = screenY
					end
				end
			end

			previousRavineX = ravineX

			-- update entities x,y,scale
			entities.setupForDraw(z,screenX,screenY,perspective.scale[i],previousZ,previousScreenX,previousScreenY,previousScale,segment)
			
			-- draw grass and road elements
			drawGrass(trackHasRavine,segment.tunnel,segment.crossroads,segment.light,colorIndex,ravineX,screenY,roadX)
			drawTarmac(trackHasRavine,segment.tunnel or segment.light,colorIndex,roadX,screenY,roadWidth)
			if (colorIndex ~= 1) then
				drawStripes(segment.tunnel or segment.light,trackHasRavine,screenX,stripeWidth,screenY)
			end
			if (not (segment.tunnel or segment.crossroads)) then
				drawCurbs(segment.light,colorIndex,roadX,screenY,curbWidth,roadWidth)
			end
			
			-- draw tunnel roof as upside down road, see function for details
			--states.drawTunnelRoof(segment,screenY,x,roadWidth)
				
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
		
		-- draw on screen info
		drawInfoPlayerSpeed()
		drawInfoCurrentLap()
		drawInfoTime()
	elseif (state == STATE_TITLE) then
		drawTitleScreen()
	elseif (state == STATE_GAME_OVER) then
		drawGameOverScreen()
	end
	
	aspect.letterbox()
end

function states.updateSelectedJoystick()
	selectedJoystick = controls.init()
end

return states