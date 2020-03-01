-- Max Downforce - modules/perspective.lua
-- 2017-2020 Foppygames

local perspective = {}

-- =========================================================
-- includes
-- =========================================================

local aspect = require("modules.aspect")

-- =========================================================
-- constants
-- =========================================================

perspective.GROUND_HEIGHT = aspect.GAME_HEIGHT / 2
perspective.HORIZON_Y = aspect.GAME_HEIGHT - perspective.GROUND_HEIGHT

-- =========================================================
-- variables
-- =========================================================

perspective.carLength = nil
perspective.maxZ = nil
perspective.minZ = nil
perspective.scale = {}
perspective.zMap = {}

-- =========================================================
-- public functions
-- =========================================================

function perspective.initZMapAndScaling()
	for i = 1, perspective.GROUND_HEIGHT do
		perspective.zMap[i] = -1.0 / (i - perspective.GROUND_HEIGHT * 1.05) * 380
		perspective.scale[i] = 1.0 / (-1.0 / (i - (perspective.GROUND_HEIGHT * 1.01)))
	end

	-- normalize scaling so that scale 1.0 is used at y=1
	local correct = 1.0 / perspective.scale[1]
	for i = 1, perspective.GROUND_HEIGHT do
		perspective.scale[i] = perspective.scale[i] * correct
	end
	
	-- take note of min and max z
	perspective.minZ = perspective.zMap[1]
	perspective.maxZ = perspective.zMap[perspective.GROUND_HEIGHT]

	-- compute car length as a fraction of distance towards horizon
	perspective.carLength = perspective.maxZ / 160
end

return perspective