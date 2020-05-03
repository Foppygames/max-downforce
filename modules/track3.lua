-- Max Downforce - modules/track3.lua
-- 2020 Foppygames

local track3 = {}

-- =========================================================
-- modules
-- =========================================================

local aspect = require("modules.aspect")
local schedule = require("modules.schedule")
local sound = require("modules.sound")

-- =========================================================
-- constants
-- =========================================================

local FIRST_SEGMENT_LENGTH = 0.55
local SKY_HEIGHT = aspect.GAME_HEIGHT * 0.65
local REMAINING_HEIGHT = aspect.GAME_HEIGHT - SKY_HEIGHT

-- =========================================================
-- variables
-- =========================================================

track3.name = "City"
track3.hasRavine = false
track3.isInMountains = false
track3.isInForest = false
track3.isInCity = true
track3.song = sound.RACE_MUSIC_CITY

track3.totalLength = 0

-- Note: length is written as fraction of maxZ, to be converted in segments.init()
-- Note: dz is written as fraction of maxZ, to be converted in segments.init()
-- Note: light property only makes sense on this track as it is in dark by default
-- and tunnels are light; light segments are rendered as if they are tunnel segments
-- (but with curbs), so on the other tracks this would actually make them dark
track3.segments = {
	-- starting grid straight leading up to start/finish
	{
		ddx = 0,
		length = FIRST_SEGMENT_LENGTH,
		scheduleItems = {
			{
				itemType = schedule.ITEM_BANNER_START,
				startZ = FIRST_SEGMENT_LENGTH,
				dz = 0,
				count = 1
			}
		},
		tunnel = false,
		light = true
	},
	-- long straight after start/finish
	{
		ddx = 0,
		length = 3.0,
		scheduleItems = {},
		tunnel = false,
		light = true
	},
	-- long curve right
	{
		ddx = 0.7,
		length = 4,
		scheduleItems = {},
		tunnel = false
	},
	-- short straight
	{
		ddx = 0,
		length = 1,
		scheduleItems = {},
		tunnel = false
	},
	-- long curve left
	{
		ddx = -0.5,
		length = 3,
		scheduleItems = {},
		tunnel = false
	},
	-- very short straight
	{
		ddx = 0,
		length = 0.5,
		scheduleItems = {},
		tunnel = false
	},
	-- long curve right
	{
		ddx = 0.4,
		length = 3,
		scheduleItems = {},
		tunnel = false,
		light = true
	},
	-- long straight towards tunnel
	{
		ddx = 0,
		length = 2.5,
		scheduleItems = {},
		tunnel = false
	},
	-- medium straight, tunnel
	{
		ddx = 0,
		length = 2,
		scheduleItems = {},
		tunnel = true
	},
	-- long curve left, tunnel
	{
		ddx = -0.6,
		length = 4,
		scheduleItems = {},
		tunnel = true
	},
	-- very short straight, tunnel
	{
		ddx = 0,
		length = 0.5,
		scheduleItems = {},
		tunnel = true
	},
	-- long curve right, tunnel
	{
		ddx = 0.6,
		length = 5,
		scheduleItems = {},
		tunnel = true
	},
	-- short straight, tunnel
	{
		ddx = 0,
		length = 1,
		scheduleItems = {},
		tunnel = true
	},
	-- medium straight
	{
		ddx = 0,
		length = 2,
		scheduleItems = {},
		tunnel = false
	},
	-- short curve right
	{
		ddx = 0.7,
		length = 1.5,
		scheduleItems = {},
		tunnel = false
	},
	-- very short straight
	{
		ddx = 0,
		length = 0.5,
		scheduleItems = {},
		tunnel = false
	},
	-- short curve left
	{
		ddx = -0.6,
		length = 1.5,
		scheduleItems = {},
		tunnel = false
	},
	-- very short straight
	{
		ddx = 0,
		length = 0.5,
		scheduleItems = {},
		tunnel = false
	},
	-- long hard curve right
	{
		ddx = 0.85,
		length = 3.6,
		scheduleItems = {},
		tunnel = false
	},
	-- short straight
	{
		ddx = 0,
		length = 1,
		scheduleItems = {},
		tunnel = false
	},
	-- short straight, tunnel
	{
		ddx = 0,
		length = 1,
		scheduleItems = {},
		tunnel = true
	},
	-- very short straight
	{
		ddx = 0,
		length = 0.2,
		scheduleItems = {},
		tunnel = false
	},
	-- short left
	{
		ddx = -0.7,
		length = 1,
		scheduleItems = {},
		tunnel = false
	},
	-- short straight, tunnel
	{
		ddx = 0,
		length = 1,
		scheduleItems = {},
		tunnel = true
	},
	-- very short straight
	{
		ddx = 0,
		length = 0.2,
		scheduleItems = {},
		tunnel = false
	},
	-- long medium curve right
	{
		ddx = 0.6,
		length = 3.6,
		scheduleItems = {},
		tunnel = false
	},
	-- straight before start/finish
	{
		ddx = 0.0,
		length = 1.4,
		scheduleItems = {},
		tunnel = false
	}
}

function track3.drawSky()
	love.graphics.setColor(0,0,0.1)
	love.graphics.rectangle("fill",0,0,aspect.GAME_WIDTH,SKY_HEIGHT)
end

return track3