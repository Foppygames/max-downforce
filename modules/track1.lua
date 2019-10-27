-- Max Downforce - modules/track1.lua
-- 2019 Foppygames

local track1 = {}

-- =========================================================
-- modules
-- =========================================================

local schedule = require("modules.schedule")

-- =========================================================
-- constants
-- =========================================================

local FIRST_SEGMENT_LENGTH = 0.55

-- =========================================================
-- variables
-- =========================================================

track1.name = "Trees"
track1.totalLength = 0

-- note: length is written as fraction of maxZ, to be converted in segments.init()
-- note: dz is written as fraction of maxZ, to be converted in segments.init()
track1.segments = {
	-- starting grid straight leading up to start/finish
	{
		ddx = 0,
		length = FIRST_SEGMENT_LENGTH,
		scheduleItems = {
			{
				itemType = schedule.ITEM_STADIUM_L,
				startZ = 0.25,
				dz = 0.1,
				count = 3
			},
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
	-- medium straight after start/finish
	-- in stadium area
	{
		ddx = 0,
		length = 2.0,
		scheduleItems = {
			{
				itemType = schedule.ITEM_FLAG_L,
				startZ = 0.05,
				dz = 0.2,
				count = 10
			},
			{
				itemType = schedule.ITEM_FLAG_R,
				startZ = 2.05,
				dz = 0.2,
				count = 10
			},
			{
				itemType = schedule.ITEM_STADIUM_L,
				startZ = 0.0,
				dz = 0.1,
				count = 40
			},
			{
				itemType = schedule.ITEM_STADIUM_R,
				startZ = 0.0,
				dz = 0.1,
				count = 40
			}
		},
		tunnel = false
	},
	-- medium curve right
	-- leave stadiums behind
	{
		ddx = 0.7,
		length = 1.5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_L_R,
				startZ = 2.2,
				dz = 0.2,
				count = 2
			},
			{
				itemType = schedule.ITEM_GRASS_L_R,
				startZ = 2.4,
				dz = 0.2,
				count = 19
			}
		},
		tunnel = false
	},
	-- long straight
	{
		ddx = 0,
		length = 4,
		scheduleItems = {
			{
				itemType = schedule.ITEM_SIGN_L,
				startZ = 0.6,
				dz = 0.6,
				count = 5
			},
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 0.9,
				dz = 0.6,
				count = 5
			}
		},
		tunnel = false
	},
	-- easy long curve right
	-- into the forest
	{
		ddx = 0.3,
		length = 2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_L_R,
				startZ = 0.0,
				dz = 0.2,
				count = 10
			},
			{
				itemType = schedule.ITEM_BANNER_FOREST_BRIDGE,
				startZ = 1.9,
				dz = 0.2,
				count = 2
			}
		},
		tunnel = false
	},
	-- short straight
	-- in forest
	{
		ddx = 0.0,
		length = 1.0,
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_L_R,
				startZ = 0.0,
				dz = 0.2,
				count = 45 --9/0.2
			}
		},
		tunnel = false
	},
	-- cicane: right + short straight
	-- in forest
	{
		ddx = 0.6,
		length = 0.5,
		scheduleItems = {},
		tunnel = false
	},
	{
		ddx = 0.0,
		length = 0.5,
		scheduleItems = {},
		tunnel = false
	},
	-- cicane: left + short straight
	-- in forest
	{
		ddx = -0.5,
		length = 0.5,
		scheduleItems = {},
		tunnel = false
	},
	{
		ddx = 0.0,
		length = 0.5,
		scheduleItems = {},
		tunnel = false
	},
	-- cicane: easy right
	-- in forest
	{
		ddx = 0.4,
		length = 1.0,
		scheduleItems = {},
		tunnel = false
	},
	-- long easy right
	-- in forest
	{
		ddx = 0.1,
		length = 3,
		scheduleItems = {},
		tunnel = false
	},
	-- long easy left
	-- leaving the forest
	{
		ddx = -0.2,
		length = 2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_GRASS_L_R,
				startZ = 0.9,
				dz = 0.2,
				count = 6
			},
			{
				itemType = schedule.ITEM_BANNER_FOREST_BRIDGE,
				startZ = 1,
				dz = 0.2,
				count = 2
			}
		},
		tunnel = false
	},
	-- medium straight
	{
		ddx = 0.0,
		length = 2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_GRASS_L_R,
				startZ = 0.0,
				dz = 0.2,
				count = 25
			}
		},
		tunnel = false
	},
	-- sweep right
	{
		ddx = 0.4,
		length = 2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_SIGN_L,
				startZ = 0.6,
				dz = 0.6,
				count = 4
			},
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 0.9,
				dz = 0.6,
				count = 3
			}
		},
		tunnel = false
	},
	-- continuing into harder long sweep right
	{
		ddx = 0.8,
		length = 3,
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_L_R,
				startZ = 1.0,
				dz = 0.2,
				count = 20
			}
		},
		tunnel = false
	},
	-- long slightly curved straight back towards stadium area
	{
		ddx = 0.0,
		length = 1,
		scheduleItems = {},
		tunnel = false
	},
	{
		ddx = 0.1,
		length = 3,
		scheduleItems = {
			{
				itemType = schedule.ITEM_GRASS_L_R,
				startZ = 0.0,
				dz = 0.4,
				count = 7
			},
			{
				itemType = schedule.ITEM_LIGHT_L_R,
				startZ = 1.0,
				dz = 0.2,
				count = 5
			},
			{
				itemType = schedule.ITEM_SIGN_L,
				startZ = 2.6,
				dz = 0,
				count = 1
			},
			{
				itemType = schedule.ITEM_SIGN_R,
				startZ = 2.6,
				dz = 0,
				count = 1
			},
			{
				itemType = schedule.ITEM_FLAG_L,
				startZ = 2.75,
				dz = 0.1,
				count = 2
			},
			{
				itemType = schedule.ITEM_FLAG_R,
				startZ = 2.75,
				dz = 0.1,
				count = 2
			}
		},
		tunnel = false
	},
	-- short slightly curved straight, start of tunnel
	{
		ddx = 0.1,
		length = 0.8,
		scheduleItems = {},
		tunnel = true
	},
	-- hard right, tunnel
	{
		ddx = 0.8,
		length = 2,
		scheduleItems = {},
		tunnel = true
	},
	-- short straight, tunnel
	{
		ddx = 0,
		length = 0.5,
		scheduleItems = {},
		tunnel = true
	},
	-- medium left, tunnel
	{
		ddx = -0.4,
		length = 2,
		scheduleItems = {},
		tunnel = true
	},
	-- short straight, tunnel
	{
		ddx = 0,
		length = 0.8,
		scheduleItems = {},
		tunnel = true
	},
	-- easy right, tunnel
	{
		ddx = 0.2,
		length = 1,
		scheduleItems = {},
		tunnel = true
	},
	-- medium straight into stadium area
	{
		ddx = 0.0,
		length = 1.5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_GRASS_L,
				startZ = 0.1,
				dz = 0.2,
				count = 7
			},
			{
				itemType = schedule.ITEM_GRASS_R,
				startZ = 0.1,
				dz = 0.2,
				count = 5
			},
			{
				itemType = schedule.ITEM_LIGHT_L,
				startZ = 1.0,
				dz = 0.2,
				count = 20
			},
			{
				itemType = schedule.ITEM_STADIUM_R,
				startZ = 1.0,
				dz = 0.1,
				count = 40
			}
		},
		tunnel = false
	},
	-- very hard left through stadiums
	{
		ddx = -1.0,
		length = 4,
		scheduleItems = {
			{
				itemType = schedule.ITEM_GRASS_L,
				startZ = 0.0,
				dz = 0.2,
				count = 32
			},
			{
				itemType = schedule.ITEM_GRASS_R,
				startZ = 3.5,
				dz = 0.2,
				count = 13
			}
		},
		tunnel = false
	},
	-- stadiums
	{
		ddx = 0.0,
		length = 1.5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_LIGHT_R,
				startZ = 1.0,
				dz = 0.2,
				count = 20
			},
			{
				itemType = schedule.ITEM_STADIUM_L,
				startZ = 1.0,
				dz = 0.1,
				count = 40
			}
		},
		tunnel = false
	},
	-- hard very long right onto straight
	{
		ddx = 0.8,
		length = 5,
		scheduleItems = {
			{
				itemType = schedule.ITEM_GRASS_R,
				startZ = 3.5,
				dz = 0.2,
				count = 12
			},
			{
				itemType = schedule.ITEM_TREES_L,
				startZ = 3.6,
				dz = 0.2,
				count = 20
			}
		},
		tunnel = false
	},
	-- straight towards starting grid
	{
		ddx = 0,
		length = 2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_GRASS_R,
				startZ = 0,
				dz = 0.15,
				count = 10
			},
			{
				itemType = schedule.ITEM_LOW_BUILDING_L,
				startZ = 1.6,
				dz = 0.2,
				count = 3
			},
			{
				itemType = schedule.ITEM_LIGHT_R,
				startZ = 1.6,
				dz = 0.2,
				count = 2
			},
			{
				itemType = schedule.ITEM_HIGH_BUILDING_R,
				startZ = 2.0,
				dz = 0,
				count = 1
			},
			{
				itemType = schedule.ITEM_TREES_L_R,
				startZ = 2.2,
				dz = 0,
				count = 1
			}
		},
		tunnel = false
	}
}

return track1