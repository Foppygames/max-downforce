-- Max Downforce - modules/schedule.lua
-- 2017-2019 Foppygames

local schedule = {}

-- =========================================================
-- includes
-- =========================================================

local entities = require("modules.entities")
local perspective = require("modules.perspective")

-- =========================================================
-- public constants
-- =========================================================

schedule.ITEM_BANNER_START = "banner_start"
schedule.ITEM_BANNER_FOREST_BRIDGE = "banner_forest_bridge"
schedule.ITEM_LOW_BUILDING_L = "low_building_l"
schedule.ITEM_HIGH_BUILDING_R = "high_building_r"
schedule.ITEM_FLAG_L = "flag_l"
schedule.ITEM_FLAG_R = "flag_r"
schedule.ITEM_GRASS_L = "grass_l"
schedule.ITEM_GRASS_L_R = "grass_l_r"
schedule.ITEM_GRASS_R = "grass_r"
schedule.ITEM_LIGHT_L = "light_l"
schedule.ITEM_LIGHT_L_R = "light_l_r"
schedule.ITEM_LIGHT_R = "light_r"
schedule.ITEM_SIGN_L = "sign_l"
schedule.ITEM_SIGN_R = "sign_r"
schedule.ITEM_TREES_L = "trees_l"
schedule.ITEM_TREES_L_R = "trees_l_r"
schedule.ITEM_TUNNEL_END = "tunnel_end"
schedule.ITEM_TUNNEL_START = "tunnel_start"
schedule.ITEM_STADIUM_L = "stadium_l"
schedule.ITEM_STADIUM_R = "stadium_r"

-- =========================================================
-- private variables
-- =========================================================

local items = {}

-- =========================================================
-- private functions
-- =========================================================

function processItem(itemType,z)
	if (itemType == schedule.ITEM_LOW_BUILDING_L) then
		entities.addLowBuilding(-700,z)
	elseif (itemType == schedule.ITEM_HIGH_BUILDING_R) then
		entities.addHighBuilding(700,z)
	elseif (itemType == schedule.ITEM_FLAG_L) then
		entities.addFlag(-600,z)
	elseif (itemType == schedule.ITEM_FLAG_R) then
		entities.addFlag(600,z)
	elseif (itemType == schedule.ITEM_GRASS_L) then
		entities.addGrass(-1200,z)
		entities.addGrass(-600,z-4)
	elseif (itemType == schedule.ITEM_GRASS_L_R) then
		entities.addGrass(-1200,z)
		entities.addGrass(-600,z-4)
		entities.addGrass(600,z-4)
		entities.addGrass(1200,z)
	elseif (itemType == schedule.ITEM_GRASS_R) then
		entities.addGrass(600,z-4)
		entities.addGrass(1200,z)
	elseif (itemType == schedule.ITEM_LIGHT_L) then
		entities.addLight(-450,z)
	elseif (itemType == schedule.ITEM_LIGHT_L_R) then
		entities.addLight(-450,z)
		entities.addLight(450,z)
	elseif (itemType == schedule.ITEM_LIGHT_R) then
		entities.addLight(450,z)
	elseif (itemType == schedule.ITEM_SIGN_L) then
		entities.addSign(-700,z)
	elseif (itemType == schedule.ITEM_SIGN_R) then
		entities.addSign(700,z)
	elseif (itemType == schedule.ITEM_STADIUM_L) then
		entities.addStadium(-850,z)
	elseif (itemType == schedule.ITEM_STADIUM_R) then
		entities.addStadium(850,z)
	elseif (itemType == schedule.ITEM_TREES_L) then
		entities.addTree(-2500,z,0.4)
		entities.addTree(-1300,z-4,0.7)
		entities.addTree(-505,z-8,1)
	elseif (itemType == schedule.ITEM_TREES_L_R) then
		entities.addTree(-2500,z,0.4)
		entities.addTree(-1300,z-4,0.7)
		entities.addTree(-505,z-8,1)
		entities.addTree(505,z-8,1)
		entities.addTree(1300,z-4,0.7)
		entities.addTree(2500,z,0.4)
	elseif (itemType == schedule.ITEM_TUNNEL_END) then
		entities.addTunnelEnd(z)
	elseif (itemType == schedule.ITEM_TUNNEL_START) then
		entities.addTunnelStart(z)
	elseif (itemType == schedule.ITEM_BANNER_FOREST_BRIDGE) then
		entities.addBanner(0,z,2)
	elseif (itemType == schedule.ITEM_BANNER_START) then
		entities.addBanner(0,z,1)
	end
end

-- =========================================================
-- public functions
-- =========================================================

function schedule.reset()
	items = {}
end

-- note: z parameter is starting z for series of items
-- if z is smaller than maxZ this means items may have to be processed right away
function schedule.add(itemType,dz,count,z)
	if (count > 0) then
		if (items[itemType] ~= nil) then
			items[itemType].dz = dz
			items[itemType].count = count
		else
			items[itemType] = {
				dz = dz, -- distance between each item
				count = count, -- number of items, where -1 is unlimited
				distance = z - perspective.maxZ -- distance till next item
			}
		end
		
		-- process items right away
		if (z < perspective.maxZ) then
			repeat
				processItem(itemType,z)
				z = z + items[itemType].dz
				items[itemType].count = items[itemType].count - 1
			until (z >= perspective.maxZ) or (items[itemType].count <= 0)
			
			if (items[itemType].count <= 0) then
				items[itemType] = nil
			else
				-- set correct distance to next item
				items[itemType].distance = z - perspective.maxZ
			end
			
			-- cancel entity x smoothing to avoid unwanted movement at start of race
			entities.cancelXSmoothing()
		end
	end
end

function schedule.update(playerSpeed,dt)
	for itemType,data in pairs(items) do
		data.distance = data.distance - playerSpeed * dt
		if (data.distance <= 0) then
			processItem(itemType,perspective.maxZ + data.distance)
			data.distance = data.distance + data.dz
			if (data.count ~= -1) then
				data.count = data.count - 1
				if (data.count <= 0) then
					items[itemType] = nil
				end
			end
		end
	end
end

return schedule