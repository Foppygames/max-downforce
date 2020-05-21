-- Max Downforce - modules/road.lua
-- 2017-2020 Foppygames

local road = {}

-- =========================================================
-- includes
-- =========================================================

local aspect = require("modules.aspect")

-- =========================================================
-- constants
-- =========================================================

road.ROAD_WIDTH = aspect.GAME_WIDTH * 1.6
road.CURB_WIDTH = road.ROAD_WIDTH / 15
road.STRIPE_WIDTH = road.CURB_WIDTH / 3
road.RAVINE_ROADSIDE_WIDTH = road.CURB_WIDTH * 6

return road