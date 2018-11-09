-- Max Downforce - modules/segments.lua
-- 2017-2018 Foppygames

local segments = {}

-- =========================================================
-- includes
-- =========================================================

local perspective = require("modules.perspective")
local schedule = require("modules.schedule")

-- =========================================================
-- constants
-- =========================================================

segments.MAX_SEGMENT_DDX = 0.0028

segments.TEXTURE_NORMAL = "normal"
segments.TEXTURE_START_FINISH = "start_finish"

local SMOOTHING_SEGMENT_DDX_STEP = 0.06 --0.08
local SMOOTHING_SEGMENT_LENGTH = 0.04

-- =========================================================
-- variables
-- =========================================================

-- note: length is written as fraction of maxZ, to be converted in segments.init()
-- note: dz is written as fraction of maxZ, to be converted in segments.init()
local track = {
	-- piece of straight containing grid in stadium area
	{
		ddx = 0,
		length = 0.79,
		scheduleItems = {
			{
				itemType = schedule.ITEM_STADIUM_L,
				startZ = 0.00,
				dz = 0.1,
				count = 8
			},
		},
		texture = segments.TEXTURE_NORMAL
	},
	-- piece of straight with start/finish texture plus banner in stadium area
	{
		ddx = 0,
		length = 0.01,
		scheduleItems = {
			{
				itemType = schedule.ITEM_BANNER_START,
				startZ = 0.01,
				dz = 0,
				count = 1
			}
		},
		texture = segments.TEXTURE_START_FINISH
	},
	-- medium straight after start/finish in stadium area
	{
		ddx = 0,
		length = 2.0,
		scheduleItems = {
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
		texture = segments.TEXTURE_NORMAL
	},
	-- medium curve right
	-- leave stadiums behind
	{
		ddx = 0.7,
		length = 1.5,
		scheduleItems = {
		},
		texture = segments.TEXTURE_NORMAL
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
		texture = segments.TEXTURE_NORMAL
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
				dz = 0.1,
				count = 20
			}
		},
		texture = segments.TEXTURE_NORMAL
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
				dz = 0.05,
				count = 7/0.05
			}
		},
		texture = segments.TEXTURE_NORMAL
	},
	-- cicane: right + short straight
	-- in forest
	{
		ddx = 0.6,
		length = 0.5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	{
		ddx = 0.0,
		length = 0.5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- cicane: left + short straight
	-- in forest
	{
		ddx = -0.5,
		length = 0.5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	{
		ddx = 0.0,
		length = 0.5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- cicane: easy right
	-- in forest
	{
		ddx = 0.4,
		length = 1.0,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- long easy right
	-- in forest
	{
		ddx = 0.1,
		length = 3,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- long easy left
	-- leaving the forest
	{
		ddx = -0.2,
		length = 2,
		scheduleItems = {
			{
				itemType = schedule.ITEM_TREES_L_R,
				startZ = 0.0,
				dz = 0.1,
				count = 2/0.1
			}
		},
		texture = segments.TEXTURE_NORMAL
	},
	-- medium straight
	{
		ddx = 0.0,
		length = 2,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- sweep right
	{
		ddx = 0.4,
		length = 2,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- continuing into harder long sweep right
	{
		ddx = 0.8,
		length = 3,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- long straight back towards stadium area
	{
		ddx = 0.0,
		length = 5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- hard right
	{
		ddx = 0.8,
		length = 2,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- medium straight into stadium area
	{
		ddx = 0.0,
		length = 1.5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- very hard left through stadiums
	{
		ddx = -1.0,
		length = 4,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- medium straight leaving stadiums behind
	{
		ddx = 0.0,
		length = 1.5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- hard very long right onto start/finish straight
	{
		ddx = 0.8,
		length = 5,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	},
	-- straight before start/finish into stadium area
	{
		ddx = 0,
		length = 3,
		scheduleItems = {},
		texture = segments.TEXTURE_NORMAL
	}
	
}
local trackIndex
local active

segments.totalLength = 0

-- =========================================================
-- functions
-- =========================================================

local function addFromIndex(index,z)
	local segment = {
		z = z
	}
	
	for key,value in pairs(track[trackIndex]) do
		if (key == "scheduleItems") then
			for i = 1, #value do
				schedule.add(value[i].itemType,value[i].dz,value[i].count,z+value[i].startZ)
			end
		else
			segment[key] = value
		end
	end
	
	segment.length = segment.length - (perspective.maxZ - z)
	segment.ddxFraction = segment.ddx
	segment.ddx = segment.ddx*segments.MAX_SEGMENT_DDX
	table.insert(active,segment)
end

local function addNext(dz)
	trackIndex = trackIndex + 1
	if (trackIndex > #track) then
		trackIndex = 1
	end
	addFromIndex(trackIndex,perspective.maxZ+dz)
end

function segments.init()
	active = {}
	
	-- smoothen corner exits
	local nextDdx
	for i = #track, 1, -1 do
		if (i == #track) then
			nextDdx = track[1].ddx
		else
			nextDdx = track[i+1].ddx
		end
		if ((track[i].ddx ~= 0) and (nextDdx == 0)) then
			local texture = track[i].texture
			local ddx = track[i].ddx
			local j = 1
			if (ddx > 0) then
				ddx = ddx - SMOOTHING_SEGMENT_DDX_STEP
				while (ddx > 0) do
					table.insert(track,i+j,{
						ddx = ddx,
						length = SMOOTHING_SEGMENT_LENGTH,
						scheduleItems = {},
						texture = texture
					})
					ddx = ddx - SMOOTHING_SEGMENT_DDX_STEP
					j = j + 1
				end
			else
				ddx = ddx + SMOOTHING_SEGMENT_DDX_STEP
				while (ddx < 0) do
					table.insert(track,i+j,{
						ddx = ddx,
						length = SMOOTHING_SEGMENT_LENGTH,
						scheduleItems = {},
						texture = texture
					})
					ddx = ddx + SMOOTHING_SEGMENT_DDX_STEP
					j = j + 1
				end
			end
		end
	end
	
	-- compute final segment lengths and schedule item startz and dz values
	segments.totalLength = 0
	for i = 1, #track do
		track[i].length = track[i].length * (perspective.maxZ - perspective.minZ)
		segments.totalLength = segments.totalLength + track[i].length
		for j = 1, #track[i].scheduleItems do
			track[i].scheduleItems[j].startZ = track[i].scheduleItems[j].startZ * (perspective.maxZ - perspective.minZ)
			track[i].scheduleItems[j].dz = track[i].scheduleItems[j].dz * (perspective.maxZ - perspective.minZ)
		end
	end
end

function segments.reset()
	active = {}
end

function segments.addFirst()
	trackIndex = 1
	addFromIndex(trackIndex,0)
end

function segments.update(speed,dt)
	local removeFromStart = 0
	for i, segment in ipairs(active) do
		if (segment.z > perspective.minZ) then
			segment.z = segment.z - speed * dt
			if (segment.z <= perspective.minZ) then
				segment.z = perspective.minZ
				if (i > 1) then
					removeFromStart = removeFromStart + 1
				end
			end
		end
		segment.length = segment.length - speed * dt
	end
	
	if (#active > 0) then
		if (active[#active].length <= 0) then
			-- add next segment
			addNext(active[#active].length)
		end
	end
	
	-- remove segments now behind us
	while (removeFromStart > 0) do
		table.remove(active,1)
		removeFromStart = removeFromStart - 1
	end
end

function segments.getLastIndex()
	return #active
end

function segments.getAtIndex(index)
	return active[index]
end

return segments