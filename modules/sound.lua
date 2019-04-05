-- Max Downforce - modules/sound.lua
-- 2019 Foppygames

local sound = {}

-- =========================================================
-- constants
-- =========================================================

sound.ENGINE_IDLE = 1
sound.ENGINE_POWER = 2

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
		
	sound.sources[sound.ENGINE_POWER] = love.audio.newSource("sounds/power3.ogg","static")
	sound.sources[sound.ENGINE_POWER]:setLooping(true)
end

function sound.getClone(index)
	return sound.sources[index]:clone()
end

return sound