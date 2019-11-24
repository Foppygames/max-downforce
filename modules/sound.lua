-- Max Downforce - modules/sound.lua
-- 2019 Foppygames

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
sound.RACE_MUSIC_PATH_FOREST = "music/POL-galactic-chase-long.wav"
sound.RACE_MUSIC_PATH_MOUNTAIN = "music/POL-combat-plan-long.wav"
sound.TITLE_MUSIC_PATH = "music/POL-smash-bros-long.wav"

-- =========================================================
-- variables
-- =========================================================

sound.sources = {}

-- =========================================================
-- public functions
-- =========================================================

function sound.init()
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

function sound.getVolume(index)
	if (sound.sources[index] ~= nil) then
		return sound.sources[index]:getVolume()
	end
	return 0
end

function sound.getClone(index)
	return sound.sources[index]:clone()
end

return sound