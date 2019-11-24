-- Max Downforce - modules/track2.lua
-- 2019 Foppygames

local track2 = {}

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

track2.name = "Mountain"
track2.hasRavine = true
track2.song = sound.RACE_MUSIC_MOUNTAIN

track2.totalLength = 0

-- note: length is written as fraction of maxZ, to be converted in segments.init()
-- note: dz is written as fraction of maxZ, to be converted in segments.init()
track2.segments = {
	-- starting grid straight leading up to start/finish
	{
		ddx = 0,
		length = FIRST_SEGMENT_LENGTH,
		scheduleItems = {
			{
				itemType = schedule.ITEM_STADIUM_R,
				startZ = 0.25,
				dz = 0.1,
				count = 3
			},
			{
				itemType = schedule.ITEM_BANNER_START,
				startZ = FIRST_SEGMENT_LENGTH,
				dz = 0,
				count = 1
			}
		},
		tunnel = false
	},
	-- long straight after start/finish
	{
		ddx = 0,
		length = 3.0,
		scheduleItems = {
			{
				itemType = schedule.ITEM_FLAG_L,
				startZ = 0.25,
				dz = 0.25,
				count = 11
			},
			{
				itemType = schedule.ITEM_STADIUM_R,
				startZ = 0,
				dz = 0.1,
				count = 10
			},
			{
				itemType = schedule.ITEM_LOW_BUILDING_R,
				startZ = 1.2,
				dz = 0.2,
				count = 9
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R_BACK,
				startZ = 1.2,
				dz = 0.2,
				count = 9
			}
		},
		tunnel = false
	},
	-- long curve right
	{
		ddx = 0.7,
		length = 4,
		scheduleItems = {
			{
				itemType = schedule.ITEM_STADIUM_R,
				startZ = 0,
				dz = 0.1,
				count = 40
			},
			{
				itemType = schedule.ITEM_MARKER_L,
				startZ = 0,
				dz = 0.2,
				count = 20
			},
			{
				itemType = schedule.ITEM_BANNER_FOREST_BRIDGE,
				startZ = 0.5,
				dz = 0.2,
				count = 5
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R,
				startZ = 4.1,
				dz = 0.2,
				count = 9
			},
			{
				itemType = schedule.ITEM_GRASS_MOUNTAIN_L,
				startZ = 4.0,
				dz = 0.1,
				count = 40
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 0,
				dz = 0.4,
				count = 8
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R_BACK,
				startZ = 0,
				dz = 0.2,
				count = 16
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_L,
				startZ = 2.25,
				dz = 0.2,
				count = 10
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R,
				startZ = 3.2,
				dz = 0.2,
				count = 35
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_MARKER_L,
				startZ = 0,
				dz = 0.2,
				count = 15
			},
			{
				itemType = schedule.ITEM_BANNER_FOREST_BRIDGE,
				startZ = 0.5,
				dz = 0.4,
				count = 5
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_L,
				startZ = 2.6,
				dz = 0.3,
				count = 12
			}
		},
		tunnel = false
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_PILLAR_L,
				startZ = 0,
				dz = 0.15,
				count = 93
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_L,
				startZ = 3,
				dz = 0.3,
				count = 20
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R,
				startZ = 0.1,
				dz = 0.2,
				count = 10
			}
		},
		tunnel = false
	},
	-- short curve right
	{
		ddx = 0.7,
		length = 1.5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_MARKER_L,
				startZ = 0,
				dz = 0.2,
				count = 10
			},
			{
				itemType = schedule.ITEM_GRASS_MOUNTAIN_R,
				startZ = 0,
				dz = 0.1,
				count = 57
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_BANNER_FOREST_BRIDGE,
				startZ = 0.2,
				dz = 0.2,
				count = 7
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_MARKER_L,
				startZ = 0.1,
				dz = 0.2,
				count = 18
			},
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 0.2,
				dz = 0.3,
				count = 10
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R,
				startZ = 3.1,
				dz = 0.2,
				count = 13
			},
			{
				itemType = schedule.ITEM_GRASS_MOUNTAIN_L,
				startZ = 3.55,
				dz = 0.1,
				count = 32
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_PILLAR_L,
				startZ = 0,
				dz = 0.2,
				count = 6
			}
		},
		tunnel = true
	},
	-- very short straight
	{
		ddx = 0,
		length = 0.2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 0.4,
				dz = 0.3,
				count = 6
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_L,
				startZ = 0.3,
				dz = 0.3,
				count = 6
			},
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R_BACK,
				startZ = 0.2,
				dz = 0.2,
				count = 10
			}
		},
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
		scheduleItems = {
			{
				itemType = schedule.ITEM_PILLAR_L,
				startZ = 0,
				dz = 0.2,
				count = 6
			}
		},
		tunnel = true
	},
	-- very short straight
	{
		ddx = 0,
		length = 0.2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_MOUNTAIN_R_BACK,
				startZ = 0.1,
				dz = 0.2,
				count = 28
			}
		},
		tunnel = false
	},
	-- long medium curve right
	{
		ddx = 0.6,
		length = 3.6,
		scheduleItems = {
			{
				itemType = schedule.ITEM_MARKER_L,
				startZ = 0.1,
				dz = 0.2,
				count = 18
			}
		},
		tunnel = false
	},
	-- straight before start/finish
	{
		ddx = 0.0,
		length = 1.4,
		scheduleItems = {
			{
				itemType = schedule.ITEM_FLAG_R,
				startZ = 0.5,
				dz = 0.25,
				count = 5
			}
		},
		tunnel = false
	}
}

function track2.drawSky()
	-- draw sky above horizon
	love.graphics.setColor(0.9,0.4,0.5)
	love.graphics.rectangle("fill",0,0,aspect.GAME_WIDTH,SKY_HEIGHT)

 	-- draw mountain color below horizon
	love.graphics.setColor(0.06,0.16,0.415)
	love.graphics.rectangle("fill",0,SKY_HEIGHT,aspect.GAME_WIDTH,REMAINING_HEIGHT)
end

return track2