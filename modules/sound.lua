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
sound.RACE_MUSIC = 5
sound.CROWD = 6

sound.VOLUME_EFFECTS = 0.3
sound.VOLUME_MUSIC = 1.0
sound.VOLUME_MUSIC_IN_TUNNEL = 0.5

-- Note: treating music file differently - missing from repository for licensing reasons
sound.MUSIC_PATH = "music/POL-galactic-chase-long.wav"

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
	
	-- Note: treating music file differently - missing from repository for licensing reasons
	local info = love.filesystem.getInfo(sound.MUSIC_PATH)
	
	-- file exists
	if (info ~= nil) then
		sound.sources[sound.RACE_MUSIC] = love.audio.newSource(sound.MUSIC_PATH,"stream")
		sound.sources[sound.RACE_MUSIC]:setLooping(true)
		sound.sources[sound.RACE_MUSIC]:setVolume(sound.VOLUME_MUSIC)
	-- file does not exist
	else
		sound.sources[sound.RACE_MUSIC] = nil
	end
	
	sound.sources[sound.CROWD] = love.audio.newSource("sounds/crowd.wav","static")
	sound.sources[sound.CROWD]:setLooping(true)
	sound.sources[sound.CROWD]:setVolume(sound.VOLUME_EFFECTS)
end

function sound.play(index)
	if (sound.sources[index] ~= nil) then
		love.audio.stop(sound.sources[index])
		love.audio.play(sound.sources[index])
	end
end

function sound.stop(index)
	if (sound.sources[index] ~= nil) then
		love.audio.stop(sound.sources[index])
	end
end

function sound.isPlaying(index)
	return sound.sources[index]:isPlaying()
end

function sound.setVolume(index,volume)
	if (sound.sources[index] ~= nil) then
		sound.sources[index]:setVolume(volume)
	end
end

function sound.getClone(index)
	return sound.sources[index]:clone()
end

return sound