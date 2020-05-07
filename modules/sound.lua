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

-- Note: used to pick music to be used in build
sound.USE_OFFICIAL_MUSIC = false

-- use official music by PlayOnLoop.com (excluded from repository)
if (sound.USE_OFFICIAL_MUSIC) then
	sound.RACE_MUSIC_PATH_FOREST = "music/POL-galactic-chase-long.wav"
	sound.RACE_MUSIC_PATH_MOUNTAIN = "music/POL-combat-plan-long.wav"
	sound.TITLE_MUSIC_PATH = "music/POL-smash-bros-long.wav"
	sound.MUSIC_CREDITS = "Music from PlayOnLoop.com"
	sound.MUSIC_CREDITS_X = 70
-- use music by Kevin MacLeod licensed under Creative Commons (included in repository)
else
	sound.RACE_MUSIC_PATH_FOREST = "music/5029-raving-energy-by-kevin-macleod.mp3"
	sound.RACE_MUSIC_PATH_MOUNTAIN = "music/5018-your-call-by-kevin-macleod.mp3"
	sound.TITLE_MUSIC_PATH = "music/4616-werq-by-kevin-macleod.mp3"
	sound.MUSIC_CREDITS = "Music by Kevin MacLeod (incompetech.com)"
	sound.MUSIC_CREDITS_X = 20
end

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

	sound.initMusic(sound.RACE_MUSIC_PATH_FOREST,sound.RACE_MUSIC_FOREST)
	sound.initMusic(sound.RACE_MUSIC_PATH_MOUNTAIN,sound.RACE_MUSIC_MOUNTAIN)
	sound.initMusic(sound.TITLE_MUSIC_PATH,sound.TITLE_MUSIC)

	sound.initSound("sounds/engine_idle.wav",sound.ENGINE_IDLE,true,sound.VOLUME_EFFECTS)
	sound.initSound("sounds/power3.ogg",sound.ENGINE_POWER,true,sound.VOLUME_EFFECTS)
	sound.initSound("sounds/explosion.wav",sound.EXPLOSION,nil,sound.VOLUME_EFFECTS)
	sound.initSound("sounds/collision.wav",sound.COLLISION,nil,sound.VOLUME_EFFECTS)
	sound.initSound("sounds/crowd.wav",sound.CROWD,true,sound.VOLUME_EFFECTS)
	sound.initSound("sounds/beep1.wav",sound.BEEP_1,nil,sound.VOLUME_EFFECTS_BEEPS)
	sound.initSound("sounds/beep2.wav",sound.BEEP_2,nil,sound.VOLUME_EFFECTS_BEEPS)
	sound.initSound("sounds/lap.wav",sound.LAP,nil,sound.VOLUME_EFFECTS_BEEPS)
	sound.initSound("sounds/countdown.wav",sound.COUNTDOWN,nil,nil)
end

function sound.initSound(path,id,loop,volume)
	sound.sources[id] = love.audio.newSource(path,"static")
	if (loop) then
		sound.sources[id]:setLooping(loop)
	end
	if (volume) then
		sound.sources[id]:setVolume(volume)
	end
end

function sound.initMusic(path,id)
	local info = love.filesystem.getInfo(path)
	
	-- file exists
	if (info ~= nil) then
		sound.sources[id] = love.audio.newSource(path,"static")
		sound.sources[id]:setLooping(true)
		sound.sources[id]:setVolume(sound.VOLUME_MUSIC)
	-- file does not exist
	else
		sound.sources[id] = nil
	end
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