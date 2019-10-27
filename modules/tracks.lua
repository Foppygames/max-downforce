-- Max Downforce - modules/tracks.lua
-- 2019 Foppygames

local tracks = {}

-- =========================================================
-- modules
-- =========================================================

--local entities = require("modules.entities")
local perspective = require("modules.perspective")
local schedule = require("modules.schedule")
local track1 = require("modules.track1")
local track2 = require("modules.track2")

-- =========================================================
-- constants
-- =========================================================

local TRACK_TREES = 1
local TRACK_MOUNTAINS = 2

local SMOOTHING_SEGMENT_DDX_STEP = 0.04
local SMOOTHING_SEGMENT_LENGTH = 0.05

-- =========================================================
-- variables
-- =========================================================

local selectedTrack = nil

-- =========================================================
-- functions
-- =========================================================

local function initTrackModule(trackModule)
	-- smoothen corner exits
	local nextDdx
	for i = #trackModule.segments, 1, -1 do
		if (i == #trackModule.segments) then
			nextDdx = trackModule.segments[1].ddx
		else
			nextDdx = trackModule.segments[i+1].ddx
		end
		if ((trackModule.segments[i].ddx ~= 0) and (nextDdx == 0)) then
			local ddx = trackModule.segments[i].ddx
			local tunnel = trackModule.segments[i].tunnel
			local j = 1
			if (ddx > 0) then
				ddx = ddx - SMOOTHING_SEGMENT_DDX_STEP
				while (ddx > 0) do
					table.insert(trackModule.segments,i+j,{
						ddx = ddx,
						length = SMOOTHING_SEGMENT_LENGTH,
						scheduleItems = {},
						tunnel = tunnel
					})
					ddx = ddx - SMOOTHING_SEGMENT_DDX_STEP
					j = j + 1
				end
			else
				ddx = ddx + SMOOTHING_SEGMENT_DDX_STEP
				while (ddx < 0) do
					table.insert(trackModule.segments,i+j,{
						ddx = ddx,
						length = SMOOTHING_SEGMENT_LENGTH,
						scheduleItems = {},
						tunnel = tunnel
					})
					ddx = ddx + SMOOTHING_SEGMENT_DDX_STEP
					j = j + 1
				end
			end
		end
	end

	-- compute final segment lengths and schedule item startz and dz values
	trackModule.totalLength = 0
	for i = 1, #trackModule.segments do
		trackModule.segments[i].length = trackModule.segments[i].length * (perspective.maxZ - perspective.minZ)
		trackModule.totalLength = trackModule.totalLength + trackModule.segments[i].length
		for j = 1, #trackModule.segments[i].scheduleItems do
			trackModule.segments[i].scheduleItems[j].startZ = trackModule.segments[i].scheduleItems[j].startZ * (perspective.maxZ - perspective.minZ)
			trackModule.segments[i].scheduleItems[j].dz = trackModule.segments[i].scheduleItems[j].dz * (perspective.maxZ - perspective.minZ)
		end
	end
end

function tracks.init()
	initTrackModule(track1)
	initTrackModule(track2)

	selectedTrack = track1
end

function tracks.getSelectedTrack()
	return selectedTrack
end

function tracks.getSelectedTrackName()
	return selectedTrack.name
end

function tracks.selectNextTrack()
	if (selectedTrack == track1) then
		selectedTrack = track2
	else
		selectedTrack = track1
	end
end

return tracks