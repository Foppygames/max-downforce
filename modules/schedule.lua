-- Max Downforce - modules/schedule.lua
-- 2017-2018 Foppygames

local schedule = {}

-- =========================================================
-- includes
-- =========================================================

local entities = require("modules.entities")
local perspective = require("modules.perspective")
--local utils = require("modules.utils")

-- =========================================================
-- public constants
-- =========================================================

schedule.ITEM_BANNER_START = "banner_start"
schedule.ITEM_BANNER_FOREST_BRIDGE = "banner_forest_bridge"
schedule.ITEM_BUILDINGS_L = "buildings_l"
schedule.ITEM_BUILDINGS_R = "buildings_r"
schedule.ITEM_GRASS_L_R = "grass_l_r"
schedule.ITEM_SIGN_L = "sign_l"
schedule.ITEM_SIGN_R = "sign_r"
schedule.ITEM_TREES_L_R = "trees_l_r"
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
	if (itemType == schedule.ITEM_BUILDINGS_L) then
		entities.addBuilding(-900,z)
	elseif (itemType == schedule.ITEM_BUILDINGS_R) then
		entities.addBuilding(900,z)
	elseif (itemType == schedule.ITEM_GRASS_L_R) then
		entities.addGrass(-1200,z)
		entities.addGrass(-600,z-4)
		entities.addGrass(600,z-4)
		entities.addGrass(1200,z)
	elseif (itemType == schedule.ITEM_SIGN_L) then
		entities.addSign(-700,z)
	elseif (itemType == schedule.ITEM_SIGN_R) then
		entities.addSign(700,z)
	elseif (itemType == schedule.ITEM_STADIUM_L) then
		entities.addStadium(-850,z)
	elseif (itemType == schedule.ITEM_STADIUM_R) then
		entities.addStadium(850,z)
	elseif (itemType == schedule.ITEM_TREES_L_R) then
		entities.addTree(-2000,z,0.6)
		entities.addTree(-1300,z-4,0.8)
		entities.addTree(-600,z-8,1)
		entities.addTree(600,z-8,1)
		entities.addTree(1300,z-4,0.8)
		entities.addTree(2000,z,0.6)
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
			data.distance = data.dz
			processItem(itemType,perspective.maxZ)
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