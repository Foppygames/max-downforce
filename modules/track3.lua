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
	-- starting grid straight leading up to start/finish, lights
	{
		ddx = 0,
		length = FIRST_SEGMENT_LENGTH,
		scheduleItems = {
			{
				itemType = schedule.ITEM_BANNER_CITY_LIGHTS,
				startZ = 0,
				dz = 0.5,
				count = 2
			},
			{
				itemType = schedule.ITEM_STADIUM_L,
				startZ = 0,
				dz = 0.1,
				count = 10
			},
			{
				itemType = schedule.ITEM_STADIUM_R,
				startZ = 0,
				dz = 0.1,
				count = 10
			},
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
	-- long straight after start/finish, part 1, lights
	{
		ddx = 0,
		length = 1.5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_BANNER_CITY_LIGHTS,
				startZ = 0.5,
				dz = 0.5,
				count = 3
			},
			{
				itemType = schedule.ITEM_SIGN_L,
				-- Note: sign image sequence is reset when player completes lap; signs thefore should
				-- be placed out of view from finish line, or they would be created before the reset
				startZ = 1.1,
				dz = 0.4,
				count = 4
			},
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 1.1,
				dz = 0.4,
				count = 4
			}
		},
		tunnel = false,
		light = true
	},
	-- crossing
	{
		ddx = 0,
		length = 0.15,
		scheduleItems = {},
		tunnel = false,
		light = true,
		crossroads = true
	},
	-- long straight after start/finish, part 2, lights
	{
		ddx = 0,
		length = 1.5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_BANNER_CITY_LIGHTS,
				startZ = 0.5,
				dz = 0.5,
				count = 4
			}
		},
		tunnel = false,
		light = true
	},
	-- crossing, lights
	{
		ddx = 0,
		length = 0.15,
		scheduleItems = {},
		tunnel = false,
		light = true,
		crossroads = true
	},
	-- short straight, lights
	{
		ddx = 0,
		length = 0.5,
		scheduleItems = {},
		tunnel = false,
		light = true
	},
	-- long curve left, part 1, lights
	{
		ddx = -0.7,
		length = 1,
		scheduleItems = {
			{
				itemType = schedule.ITEM_SIGN_L,
				startZ = 0.3,
				dz = 0.4,
				count = 6
			},
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 0.4,
				dz = 0.4,
				count = 6
			},
			{
				itemType = schedule.ITEM_BANNER_CITY_LIGHTS,
				startZ = 0.5,
				dz = 0.5,
				count = 2
			}
		},
		tunnel = false,
		light = true
	},
	-- long curve left, part 2
	{
		ddx = -0.7,
		length = 1.5,
		scheduleItems = {},
		tunnel = false
	},
	-- long curve left, part 3, lights
	{
		ddx = -0.7,
		length = 1.5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_STADIUM_L,
				startZ = 0,
				dz = 0.1,
				count = 16
			},
			{
				itemType = schedule.ITEM_STADIUM_R,
				startZ = 0,
				dz = 0.1,
				count = 16
			},
			{
				itemType = schedule.ITEM_BANNER_CITY_LIGHTS,
				startZ = 0,
				dz = 0.5,
				count = 4
			}
		},
		tunnel = false,
		light = true
	},
	-- long curve left, part 4
	{
		ddx = -0.7,
		length = 1.5,
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
	-- medium curve right, part 1
	{
		ddx = 0.65,
		length = 1.6,
		scheduleItems = {},
		tunnel = false
	},
	-- crossing
	{
		ddx = 0.65,
		length = 0.15,
		scheduleItems = {},
		tunnel = false,
		light = false,
		crossroads = true
	},
	-- medium curve right, part 2
	{
		ddx = 0.65,
		length = 1.6,
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
	-- medium curve left
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
	-- long curve right, part 1, towards tunnel
	{
		ddx = 0.3,
		length = 4,
		scheduleItems = {},
		tunnel = false
	},
	-- long curve right, part 2, tunnel
	{
		ddx = 0.3,
		length = 3,
		scheduleItems = {},
		tunnel = true
	},
	-- medium straight, tunnel
	{
		ddx = 0,
		length = 3,
		scheduleItems = {},
		tunnel = true
	},
	-- hard left, tunnel
	{
		ddx = -0.8,
		length = 2,
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
		length = 4,
		scheduleItems = {},
		tunnel = true
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