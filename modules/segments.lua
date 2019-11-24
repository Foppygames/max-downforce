-- Max Downforce - modules/segments.lua
-- 2017-2019 Foppygames

local segments = {}

-- =========================================================
-- modules
-- =========================================================

local entities = require("modules.entities")
local perspective = require("modules.perspective")
local schedule = require("modules.schedule")
local tracks = require("modules.tracks")

-- =========================================================
-- constants
-- =========================================================

segments.MAX_SEGMENT_DDX = 0.0030

-- =========================================================
-- variables
-- =========================================================

local track = nil
local segmentIndex
local active
local tunnelStarted

-- =========================================================
-- functions
-- =========================================================

function segments.init()
	tracks.init()
	active = {}
end

local function addFromIndex(index,z)
	local segment = {
		z = z
	}
	
	for key,value in pairs(track.segments[segmentIndex]) do
		if (key == "scheduleItems") then
			for i = 1, #value do
				schedule.add(value[i].itemType,value[i].dz,value[i].count,z+value[i].startZ)
			end
		else
			segment[key] = value
			
			if (key == "tunnel") then
				-- segment has tunnel
				if (value) then
					if (not tunnelStarted) then
						entities.addTunnelStart(z)
						tunnelStarted = true
					end
				-- segment has no tunnel
				else
					if (tunnelStarted) then
						entities.addTunnelEnd(z)
						tunnelStarted = false
					end
				end
			end
		end
	end
	
	segment.length = segment.length - (perspective.maxZ - z)
	segment.ddxFraction = segment.ddx
	segment.ddx = segment.ddx*segments.MAX_SEGMENT_DDX
	table.insert(active,segment)
end

local function addNext(dz)
	segmentIndex = segmentIndex + 1
	if (segmentIndex > #track.segments) then
		segmentIndex = 1
	end
	addFromIndex(segmentIndex,perspective.maxZ+dz)
end

function segments.reset()
	track = tracks.getSelectedTrack()
	active = {}
	tunnelStarted = false
end

function segments.addFirst()
	segmentIndex = 1
	addFromIndex(segmentIndex,0)
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

function segments.getFirstSegmentLength()
	return track.segments[1].length
end

function segments.getTotalLength()
	return track.totalLength
end

function segments.getTrackSet()
	return segments.trackSet
end

return segments