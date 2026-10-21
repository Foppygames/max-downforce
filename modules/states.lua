local states = {}

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
local daynight = require("modules.daynight")
local entities = require("modules.entities")
local horizon = require("modules.horizon")
local opponents = require("modules.opponents")
local palette = require("modules.palette")
local perspective = require("modules.perspective")
local road = require("modules.road")
local schedule = require("modules.schedule")
local segments = require("modules.segments")
local sound = require("modules.sound")
local timer = require("modules.timer")
local tracks = require("modules.tracks")
local track1 = require("modules.track1")

local STATE_TITLE = 0
local STATE_RACE = 1
local STATE_GAME_OVER = 2

local CAR_COUNT = 6
local LAP_COUNT = 10

local TIME_AFTER_FINISHED = 5
local TIME_BEFORE_BEEPS = 0.7
local TIME_BEFORE_START = 2.5

local afterFinishedTimer = 0
local beepCounter = 0
local beepTimer = 0
local finished = false
local fullScreen = false
local lap = 0
local player = nil
local previousLastSegmentHadTunnel = false
local previousDisplayTime = nil
local progress = 0
local selectedJoystick
local selectedTrack = nil
local state
local title = ""
local titleShineIndex = 0
local titleShineTimer = 0
local tunnelWallDistance = 0
local version = ""

local imageTrophyBronze = nil
local imageTrophySilver = nil
local imageTrophyGold = nil
local imageGamepadDpad = nil
local imageGamepadModeR = nil
local imageGamepadModeL = nil

local function drawGameOverScreen()
	love.graphics.setColor(palette.HEPT32_7)

	if not finished then
		love.graphics.push()
		love.graphics.scale(2, 2)
		love.graphics.print("GAME OVER", 54, 20)
		love.graphics.pop()
		
		-- still in first lap
		if lap < 2 then
			love.graphics.print("Don't give up!", 138, 70)
		-- beyond first lap
		else
			love.graphics.setColor(palette.HEPT32_27)

			-- in second lap
			if lap == 2 then
				love.graphics.print("You completed 1 full lap", 103, 70)
				love.graphics.setColor(palette.HEPT32_7)
				love.graphics.print("Well done!", 149, 95)
			-- beyond second lap
			else
				love.graphics.print("You completed "..(lap-1).." full laps", 98, 70)

				-- completed more than one lap
				if lap > 2 then
					love.graphics.setColor(palette.HEPT32_7)

					-- completed nine laps
					if lap == 10 then
						love.graphics.print("You win the silver cup!", 107, 95)
						love.graphics.draw(imageTrophySilver, aspect.GAME_WIDTH / 2 - imageTrophySilver:getWidth() / 2, 120)
					-- completed eight laps
					elseif lap == 9 then
						love.graphics.print("You win the bronze cup!", 103, 95)
						love.graphics.draw(imageTrophyBronze,aspect.GAME_WIDTH / 2 - imageTrophyBronze:getWidth() / 2, 120)
					-- completed between two and seven laps
					else
						love.graphics.print("Well done!", 149, 95)
					end
				end
			end
		end
	else
		love.graphics.push()
		love.graphics.scale(2, 2)
		love.graphics.print("CONGRATULATIONS!", 24, 20)
		love.graphics.pop()
		
		love.graphics.setColor(palette.HEPT32_27)
		love.graphics.print("You finished the race", 110, 70)
		
		love.graphics.setColor(palette.HEPT32_7)
		love.graphics.print("You win the gold cup!", 113, 95)
		love.graphics.draw(imageTrophyGold,aspect.GAME_WIDTH / 2 - imageTrophyGold:getWidth() / 2, 120)
		
		love.graphics.setColor(palette.HEPT32_8)
		love.graphics.print("You may consider yourself a member of", 48, 150)
		love.graphics.print("an elite group of grand prix racers", 58, 170)
	end
end

local function drawTitleScreen()
	local titleAllCaps = string.upper(title)

	love.graphics.push()
	love.graphics.scale(2, 2)

	for i = 1, string.len(titleAllCaps) do
		local diff = math.abs(i - titleShineIndex)
		local dy
		local frontColor

		if diff > 1 then
			dy = 0
			frontColor = palette.HEPT32_30
		elseif diff == 1 then
			dy = -0.5
			frontColor = palette.HEPT32_26
		elseif diff == 0 then
			dy = -1.0
			frontColor = palette.HEPT32_7
		end

		love.graphics.setColor(palette.HEPT32_28)
		love.graphics.print(string.sub(titleAllCaps, i, i), 17 + i * 10, 6 + dy + 0.5)

		love.graphics.setColor(frontColor)
		love.graphics.print(string.sub(titleAllCaps, i, i), 17 + i * 10, 6 + dy)		
	end

	love.graphics.pop()
	
	love.graphics.setColor(palette.HEPT32_10)
	love.graphics.print(version, 278, 4)
	
	love.graphics.setColor(palette.HEPT32_7)
	love.graphics.print("Written by Robbert Prins", 93, 45)
	love.graphics.print(sound.MUSIC_CREDITS, sound.MUSIC_CREDITS_X, 65)
	
	love.graphics.setColor(palette.HEPT32_8)
	love.graphics.print("T = track " .. tracks.getSelectedTrackNumber() .. "/" .. tracks.getTrackCount() .. ": " .. tracks.getSelectedTrackName(), 93, 90)
	love.graphics.print("W = windowed / full screen", 93, 105)
	love.graphics.print("M = music: " .. sound.getMusicEnabledLabel(), 93, 120)

	-- more than one control method available
	if controls.getAvailableCount() > 1 then
		love.graphics.print("C = controls: " .. controls.getSelected().label, 93, 135)
	-- one control method available (note: assuming there is never less than one)
	else
		love.graphics.setColor(palette.HEPT32_7)
		love.graphics.print("Controls: " .. controls.getSelected().label, 93, 135)
	end

	love.graphics.setColor(palette.HEPT32_7)

	if controls.getSelected().type == controls.TYPE_GAMEPAD then
		if controls.getSelected().config == controls.CONFIG_GAMEPAD_DPAD then
			love.graphics.draw(imageGamepadDpad, 255, 128)
		elseif controls.getSelected().config == controls.CONFIG_GAMEPAD_L then
			love.graphics.draw(imageGamepadModeL, 255, 128)
		elseif controls.getSelected().config == controls.CONFIG_GAMEPAD_R then
			love.graphics.draw(imageGamepadModeR, 255, 128)
		end
	else
		if controls.getSelected().config == controls.CONFIG_KEYBOARD_ARROWS then
			love.graphics.draw(imageKeyboardModeArrows, 255, 120)
		elseif controls.getSelected().config == controls.CONFIG_KEYBOARD_AZ_COMMA_PERIOD then
			love.graphics.draw(imageKeyboardModeAzCommaPeriod, 259, 120)
		end
	end

	love.graphics.setColor(palette.HEPT32_7)
	love.graphics.print(controls.getSelected().startText, 108 + controls.getSelected().startTextDx, 160)
	
	love.graphics.setColor(palette.HEPT32_27)
	love.graphics.print("Foppygames 2019-2026", 100, 178)
end

local function drawInfoCurrentLap()
	love.graphics.setColor(palette.HEPT32_8)
	love.graphics.print("LAP", 20, 10)
	love.graphics.print(math.max(lap, 1), 20, 25)
	love.graphics.print("/ "..LAP_COUNT, 40, 25)

	if lap == LAP_COUNT then
		love.graphics.print("FINAL LAP", 20, 40)
	elseif lap > LAP_COUNT then
		love.graphics.print("RACE OVER", 20, 40)
	end
end

local function drawInfoPlayerSpeed()
	if player ~= nil then
		love.graphics.setColor(palette.HEPT32_8)
		love.graphics.print("SPEED", aspect.GAME_WIDTH - 60, 10)
		love.graphics.print(player:getSpeedAsKMH(), aspect.GAME_WIDTH - 80, 25)
		love.graphics.print("km/h", aspect.GAME_WIDTH - 50, 25)
	end
end

local function drawInfoTime()
	love.graphics.setColor(palette.HEPT32_27)
	love.graphics.print("TIME", aspect.GAME_WIDTH / 2 - 20, 10)

	local timeScale = 1

	if timer.isDangerous() then
		timeScale = 2
	end

	love.graphics.push()
	love.graphics.scale(timeScale, timeScale)
	love.graphics.print(timer.getDisplayTime(), (aspect.GAME_WIDTH / 2 - 12) / timeScale, 25 / timeScale)
	love.graphics.pop()
end

local function setupStartingGrid()
	local startZ = perspective.zMap[30]
	local dz = (perspective.maxZ - perspective.minZ) / 13
	
	-- player not on first segment
	if (CAR_COUNT * dz) > (segments.getFirstSegmentLength() * (perspective.maxZ - perspective.minZ)) then
		print("Warning: player not on first segment")
	end
	
	-- add cars from back to front
	for i = 1, CAR_COUNT do
		local z = startZ + dz * (i - 1)
		local x = 1

		if i % 2 == 0 then
			z = z + dz / 2
			x = -1
		end

		if i == 1 then
			player = entities.addCar(x, z, true, 1, TIME_BEFORE_START)
		else
			entities.addCar(x, z, false, 0.1, TIME_BEFORE_START)
		end
	end
	
	-- init start sequence
	beepTimer = TIME_BEFORE_BEEPS
	beepCounter = 0
end

local function switchToState(newState)
	-- clean up current state
	if state == STATE_RACE then
		if sound.musicIsEnabled() then
			sound.stop(tracks.getSong())
		end

		sound.stop(sound.CROWD)
	elseif state == STATE_TITLE then
		if sound.musicIsEnabled() then
			sound.stop(sound.TITLE_MUSIC)
		end
	end

	entities.reset(tracks.hasRavine(), tracks.isInCity())

	-- init new state
	state = newState

	if state == STATE_TITLE then
		math.randomseed(os.time())

		if sound.musicIsEnabled() then
			sound.play(sound.TITLE_MUSIC)
		end

		titleShineIndex = 0
	elseif state == STATE_RACE then
		lap = 0
		progress = 0
		finished = false
		afterFinishedTimer = 0
		previousDisplayTime = nil
	
		daynight.reset()
		horizon.reset()
		schedule.reset()
		segments.reset()
		segments.addFirst()
		opponents.reset()
		road.reset(tracks)
		timer.reset(progress, TIME_BEFORE_START)

		TunnelEnd.reset()
	
		setupStartingGrid()
	end
end

function states.init(gameVersion, gameTitle)
	version = gameVersion
	title = gameTitle

	love.window.setTitle(title)
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.graphics.setLineStyle("rough")
	love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf", 10))
	
	imageGamepadDpad = love.graphics.newImage("images/interface/gamepad_dpad.png")
	imageGamepadModeL = love.graphics.newImage("images/interface/gamepad_l.png")
	imageGamepadModeR = love.graphics.newImage("images/interface/gamepad_r.png")
	imageKeyboardModeArrows = love.graphics.newImage("images/interface/keyboard_arrows.png")
	imageKeyboardModeAzCommaPeriod = love.graphics.newImage("images/interface/keyboard_az_comma_period.png")
	imageTrophyBronze = love.graphics.newImage("images/interface/trophy_bronze.png")
	imageTrophyGold = love.graphics.newImage("images/interface/trophy_gold.png")
	imageTrophySilver = love.graphics.newImage("images/interface/trophy_silver.png")
	
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
	if state == STATE_RACE then
		daynight.update(dt)

		if beepTimer > 0 then
			beepTimer = beepTimer - dt

			if beepTimer <= 0 then
				beepCounter = beepCounter + 1

				if beepCounter == 3 then
					sound.play(sound.BEEP_2)

					beepTimer = 0
					
					-- reset music volume after possible countdown
					sound.setVolume(tracks.getSong(), sound.VOLUME_MUSIC)
					
					if sound.musicIsEnabled() then
						sound.play(tracks.getSong())
					end
				else
					sound.play(sound.BEEP_1)

					beepTimer = (TIME_BEFORE_START - TIME_BEFORE_BEEPS) / 2
				end
			end
		end
		
		local playerSpeed

		if player ~= nil then
			playerSpeed = player.speed
		else
			playerSpeed = 0
		end
		
		road.updateTextureOffset(playerSpeed, dt)
		
		schedule.update(playerSpeed, dt)
		
		local entitiesUpdateResult = entities.update(playerSpeed, dt, segments.totalLength)
		
		sound.updateCrowdVolume(entitiesUpdateResult.stadiumNear, dt)
		
		if entities.checkLap() then
			-- reset music volume after possible countdown
			sound.setVolume(tracks.getSong(), sound.VOLUME_MUSIC)
			
			Sign.resetIndex()

			lap = lap + 1
			
			if lap > 1 then
				sound.play(sound.LAP)
			end
			
			if lap > LAP_COUNT then
				timer.halt()
			
				if (not finished) and (player ~= nil) then
					-- turn player car into cpu car
					player:setIsPlayer(false)
					
					-- start count down after finish
					afterFinishedTimer = TIME_AFTER_FINISHED
				end

				finished = true
			else
				progress = lap / LAP_COUNT
				
				if lap > 1 then
					timer.reset(progress, 0)
				end
			end
		end
		
		opponents.update(playerSpeed, progress, entitiesUpdateResult.aiCarCount, dt)
		segments.update(playerSpeed, dt)
		horizon.update(segments.getAtIndex(1).ddx, playerSpeed, dt)
		
		local lastSegment = segments.getAtIndex(segments.getLastIndex())

		if lastSegment.tunnel then
			tunnelWallDistance = tunnelWallDistance + playerSpeed * dt

			while tunnelWallDistance > 3 do
				tunnelWallDistance = tunnelWallDistance - 3

				entities.addTunnelEnd(perspective.maxZ - tunnelWallDistance)
			end
		elseif previousLastSegmentHadTunnel then
			tunnelWallDistance = 0

			TunnelEnd.reset()
		end

		previousLastSegmentHadTunnel = lastSegment.tunnel
		
		if afterFinishedTimer > 0 then
			afterFinishedTimer = afterFinishedTimer - dt

			if afterFinishedTimer <= 0 then
				switchToState(STATE_GAME_OVER)
			end
		end
		
		local timeOk = timer.update(dt)
		
		if timer.isDangerous() then
			local displayTime = timer.getDisplayTime()

			if displayTime ~= previousDisplayTime then
				local steps = timer.getTimeDangerous()
				local stepsTaken = steps - displayTime
				local volume = sound.VOLUME_COUNTDOWN_MIN + stepsTaken * ((sound.VOLUME_COUNTDOWN_MAX - sound.VOLUME_COUNTDOWN_MIN) / steps)

				sound.setVolume(sound.COUNTDOWN, volume)
				sound.setVolume(tracks.getSong(), sound.VOLUME_COUNTDOWN_MAX - volume)
				sound.play(sound.COUNTDOWN)

				previousDisplayTime = displayTime
			end
		end
		
		if not timeOk then
			switchToState(STATE_GAME_OVER)
		end
	elseif state == STATE_TITLE then
		titleShineTimer = titleShineTimer + 18 * dt

		if titleShineTimer >= 1 then
			titleShineTimer = 0
			titleShineIndex = titleShineIndex + 1

			if titleShineIndex > 150 then
				titleShineIndex = 0
			end
		end
	end
end

function states.updateKeyPressed(key)
	if state == STATE_TITLE then
		if key == "m" then
			sound.toggleMusicEnabled()
		end

		if key == "t" then
			tracks.selectNextTrack()
		end

		if key == "w" then
			fullScreen = not fullScreen
			aspect.init(fullScreen)
		end

		if key == "c" then
			selectedJoystick = controls.selectNextAvailable()
		end

		if key == "space" then
			switchToState(STATE_RACE)
		end

		if key == "escape" then
			love.event.quit()
		end
	end

	if state == STATE_RACE then
		if key == "escape" then
			switchToState(STATE_TITLE)
		end
	end

	if state == STATE_GAME_OVER then
		if key == "space" then
			switchToState(STATE_TITLE)
		end
	end
end

function states.updateGamepadPressed(joystick, button)
	if joystick == selectedJoystick then
		if state == STATE_TITLE then
			if (button == "a") or (button == "start") then
				switchToState(STATE_RACE)
			end
		end

		if state == STATE_RACE then
			if button == "back" then
				switchToState(STATE_TITLE)
			end
		end

		if state == STATE_GAME_OVER then
			if (button == "a") or (button == "start") then
				switchToState(STATE_TITLE)
			end
		end
	end
end

function states.draw()
	aspect.apply()
	
	if state == STATE_RACE then
		horizon.draw()

		road.draw(player, entities, segments)

		entities.draw()
		
		drawInfoPlayerSpeed()
		drawInfoCurrentLap()
		drawInfoTime()

		-- temp: draw daynight time
		--[[
		love.graphics.setColor(palette.HEPT32_7)
		love.graphics.print(daynight.getDisplayTime(), aspect.GAME_WIDTH - 80, 40)
		--]]
	elseif state == STATE_TITLE then
		drawTitleScreen()
	elseif state == STATE_GAME_OVER then
		drawGameOverScreen()
	end
	
	aspect.letterbox()
end

function states.updateSelectedJoystick()
	selectedJoystick = controls.init()
end

return states