local lightmap = {}

local perspective = require("modules.perspective")

local EDGE_VALUES = {0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95}
local SECTOR_COUNT = 160

local map
local sectorLength
local zOffset

function lightmap.addLight(z, padding)
	local mid = math.ceil(z / sectorLength)
	local start = mid - padding - #EDGE_VALUES

	for e = 1, #EDGE_VALUES do
		local i = start + e - 1

		if (i > 0) and (i <= #map) then
			map[i] = EDGE_VALUES[e]
		end
	end

	for i = mid - padding, mid + padding do
		if (i > 0) and (i <= #map) then
			map[i] = 1
		end
	end

	start = mid + padding + #EDGE_VALUES

	for e = 1, #EDGE_VALUES do
		local i = start - e + 1

		if (i > 0) and (i <= #map) then
			map[i] = EDGE_VALUES[e]
		end
	end
end

function lightmap.getSectorLight(z)
	local index = math.ceil(z / sectorLength)

	if index < 1 then
		return 0
	end

	if index > #map then
		return 0
	end

	return map[index]
end

function lightmap.init()
	lightmap.reset()
end

function lightmap.reset()
	map = {}
    
	for i = 1, SECTOR_COUNT * 2 do
      map[i] = 0
    end

	sectorLength = (perspective.maxZ - perspective.minZ) / SECTOR_COUNT

	zOffset = 0
end

function lightmap.scroll(dz, dt)
	zOffset = zOffset + dz * dt

	while zOffset > sectorLength do
		zOffset = zOffset - sectorLength

		table.remove(map, 1)
		table.insert(map, 0)
	end
end

return lightmap