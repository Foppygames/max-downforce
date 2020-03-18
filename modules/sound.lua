-- Max Downforce - modules/sound.lua
-- 2019-2020 Foppygames

local sound = {}

-- =========================================================
-- constants
-- =========================================================

sound.ENGINE_IDLE = 1
sound.ENGINE_POWER = 2
sound.EXPLOSION = 3
sound.COLLISION = 4
sound.RACE_MUSIC_FOREST = 5
sound.RACE_MUSIC_MOUNTAIN = 6
sound.CROWD = 7
sound.TITLE_MUSIC = 8
sound.BEEP_1 = 9
sound.BEEP_2 = 10
sound.LAP = 11
sound.COUNTDOWN = 12

sound.VOLUME_EFFECTS = 0.3
sound.VOLUME_EFFECTS_BEEPS = 0.9
sound.VOLUME_MUSIC = 1.0
sound.VOLUME_MUSIC_IN_TUNNEL = 0.5
sound.VOLUME_MUSIC_IN_RAVINE_TUNNEL = 0.7
sound.VOLUME_COUNTDOWN_MIN = 0.3
sound.VOLUME_COUNTDOWN_MAX = 1.0

-- Note: treating music file differently - missing from repository for licensing reasons
sound.RACE_MUSIC_PATH_FOREST = "music/5029-raving-energy-by-kevin-macleod.mp3"
sound.RACE_MUSIC_PATH_MOUNTAIN = "music/5018-your-call-by-kevin-macleod.mp3"
sound.TITLE_MUSIC_PATH = "music/4616-werq-by-kevin-macleod.mp3"

-- =========================================================
-- variables
-- =========================================================

sound.sources = {}

local crowdVolume = 0
local musicEnabled = true

-- =========================================================
-- public functions
-- =========================================================

function sound.init()
	sound.initEffects()

	sound.sources[sound.ENGINE_IDLE] = love.audio.newSource("sounds/engine_idle.wav","static")
	sound.sources[sound.ENGINE_IDLE]:setLooping(true)
	sound.sources[sound.ENGINE_IDLE]:setVolume(sound.VOLUME_EFFECTS)
	
	sound.sources[sound.ENGINE_POWER] = love.audio.newSource("sounds/power3.ogg","static")
	sound.sources[sound.ENGINE_POWER]:setLooping(true)
	sound.sources[sound.ENGINE_POWER]:setVolume(sound.VOLUME_EFFECTS)
	
	sound.sources[sound.EXPLOSION] = love.audio.newSource("sounds/explosion.wav","static")
	sound.sources[sound.EXPLOSION]:setVolume(sound.VOLUME_EFFECTS)
	
	sound.sources[sound.COLLISION] = love.audio.newSource("sounds/collision.wav","static")
	sound.sources[sound.COLLISION]:setVolume(sound.VOLUME_EFFECTS)
	
	-- Note: treating music files differently - missing from repository for licensing reasons
	local info = love.filesystem.getInfo(sound.RACE_MUSIC_PATH_FOREST)
	
	-- file exists
	if (info ~= nil) then
		sound.sources[sound.RACE_MUSIC_FOREST] = love.audio.newSource(sound.RACE_MUSIC_PATH_FOREST,"static")
		sound.sources[sound.RACE_MUSIC_FOREST]:setLooping(true)
		sound.sources[sound.RACE_MUSIC_FOREST]:setVolume(sound.VOLUME_MUSIC)
	-- file does not exist
	else
		sound.sources[sound.RACE_MUSIC_FOREST] = nil
	end

	local info = love.filesystem.getInfo(sound.RACE_MUSIC_PATH_MOUNTAIN)

	-- file exists
	if (info ~= nil) then
		sound.sources[sound.RACE_MUSIC_MOUNTAIN] = love.audio.newSource(sound.RACE_MUSIC_PATH_MOUNTAIN,"static")
		sound.sources[sound.RACE_MUSIC_MOUNTAIN]:setLooping(true)
		sound.sources[sound.RACE_MUSIC_MOUNTAIN]:setVolume(sound.VOLUME_MUSIC)
	-- file does not exist
	else
		sound.sources[sound.RACE_MUSIC_MOUNTAIN] = nil
	end
	
	local info = love.filesystem.getInfo(sound.TITLE_MUSIC_PATH)
	
	-- file exists
	if (info ~= nil) then
		sound.sources[sound.TITLE_MUSIC] = love.audio.newSource(sound.TITLE_MUSIC_PATH,"static")
		sound.sources[sound.TITLE_MUSIC]:setLooping(true)
		sound.sources[sound.TITLE_MUSIC]:setVolume(sound.VOLUME_MUSIC)
	-- file does not exist
	else
		sound.sources[sound.TITLE_MUSIC] = nil
	end
	
	sound.sources[sound.CROWD] = love.audio.newSource("sounds/crowd.wav","static")
	sound.sources[sound.CROWD]:setLooping(true)
	sound.sources[sound.CROWD]:setVolume(sound.VOLUME_EFFECTS)
	
	sound.sources[sound.BEEP_1] = love.audio.newSource("sounds/beep1.wav","static")
	sound.sources[sound.BEEP_1]:setVolume(sound.VOLUME_EFFECTS_BEEPS)
	
	sound.sources[sound.BEEP_2] = love.audio.newSource("sounds/beep2.wav","static")
	sound.sources[sound.BEEP_2]:setVolume(sound.VOLUME_EFFECTS_BEEPS)
	
	sound.sources[sound.LAP] = love.audio.newSource("sounds/lap.wav","static")
	sound.sources[sound.LAP]:setVolume(sound.VOLUME_EFFECTS_BEEPS)
	
	sound.sources[sound.COUNTDOWN] = love.audio.newSource("sounds/countdown.wav","static")
	sound.sources[sound.COUNTDOWN]:setEffect("countdown_echo")
end

function sound.initEffects()
	love.audio.setEffect("tunnel_echo",{
		type = "echo",
		volume = 1,
		delay = 0.2,
		feedback = 0.7,
		spread = 1
	})
	
	love.audio.setEffect("countdown_echo",{
		type = "echo",
		volume = 0.8,
		delay = 0.2,
		feedback = 0.5,
		spread = 1
	})
end
	
function sound.musicIsEnabled()
	return musicEnabled
end

function sound.getMusicEnabledLabel()
	if (musicEnabled) then
		return "on"
	end
	return "off"
end

function sound.play(index)
	if (sound.sources[index] ~= nil) then
		if (sound.sources[index]:isPlaying()) then
			love.audio.stop(sound.sources[index])
		end
		love.audio.play(sound.sources[index])
	end
end

function sound.stop(index)
	if (sound.sources[index] ~= nil) then
		love.audio.stop(sound.sources[index])
	end
end

function sound.isPlaying(index)
	if (sound.sources[index] ~= nil) then
		return sound.sources[index]:isPlaying()
	end
	return false
end

function sound.setVolume(index,volume)
	if (sound.sources[index] ~= nil) then
		sound.sources[index]:setVolume(volume)
	end
end

-- Note: only used while on title screen
function sound.toggleMusicEnabled()
	musicEnabled = not musicEnabled
	if (sound.isPlaying(sound.TITLE_MUSIC)) then
		sound.stop(sound.TITLE_MUSIC)
	else
		sound.play(sound.TITLE_MUSIC)
	end
end

function sound.getVolume(index)
	if (sound.sources[index] ~= nil) then
		return sound.sources[index]:getVolume()
	end
	return 0
end

function sound.getClone(index)
	return sound.sources[index]:clone()
end

function sound.updateCrowdVolume(stadiumNear,dt)
	if (stadiumNear) then
		crowdVolume = crowdVolume + 0.35 * dt
		if (crowdVolume > sound.VOLUME_EFFECTS) then
			crowdVolume = sound.VOLUME_EFFECTS
		end
		sound.setVolume(sound.CROWD,crowdVolume)
		if (not sound.isPlaying(sound.CROWD)) then
			sound.play(sound.CROWD)
		end
	else
		if (sound.isPlaying(sound.CROWD)) then
			crowdVolume = crowdVolume - 0.15 * dt
			if (crowdVolume <= 0) then
				crowdVolume = 0
				sound.stop(sound.CROWD)
			end
			sound.setVolume(sound.CROWD,crowdVolume)
		end
	end
end

return sound