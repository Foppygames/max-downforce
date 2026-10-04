--[[
Sun calibration:

This track is an oval that is used for calibrating sun positioning. The sun is calibrated to end up
at the same x it starts at after a full lap, using this oval track as a reference. The oval track
cannot be selected in the published game.

1 - Create oval track that represents 360 degrees of rotation when done a full lap
2 - Calibrate SUN_FULL_CIRCLE_LENGTH in horizon module so it ends up where it starts on oval track
3 - Modify layout of other tracks so they too represent a circular circuit and the sun ends where it starts
4 - Consider changing time limits to take changes in track lengths into account
--]]

local track4 = {}

local aspect = require("modules.aspect")
local schedule = require("modules.schedule")
local sound = require("modules.sound")

local STRAIGHT_LENGTH = 16
local CURVE_DIAMETER = 4 --8
local CURVE_RADIUS = CURVE_DIAMETER / 2
local CURVE_LENGTH = 2 * math.pi * CURVE_RADIUS / 2
local FIRST_SEGMENT_LENGTH = 0.55
local SKY_HEIGHT = aspect.GAME_HEIGHT * 0.5

track4.name = "Oval"
track4.number = 4
track4.hasRavine = false
track4.isInMountains = false
track4.isInForest = true
track4.isInCity = false
track4.song = sound.RACE_MUSIC_FOREST

track4.totalLength = 0

track4.segments = {
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
	-- half of long straight after start/finish
	{
		ddx = 0,
		length = (STRAIGHT_LENGTH - FIRST_SEGMENT_LENGTH) / 2,
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
	-- long curve right
	{
		ddx = 0.7,
		length = CURVE_LENGTH,
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
		length = STRAIGHT_LENGTH,
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
	-- long curve right
	{
		ddx = 0.7,
		length = CURVE_LENGTH,
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
	-- half of long straight before start/finish
	{
		ddx = 0,
		length = (STRAIGHT_LENGTH - FIRST_SEGMENT_LENGTH) / 2,
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
	}
}

function track4.drawSky()
	love.graphics.setColor(0, 0.65, 1)
	love.graphics.rectangle("fill", 0, 0, aspect.GAME_WIDTH, SKY_HEIGHT)
end

function track4.init()
	imgSun = love.graphics.newImage("images/sky/sun.png")
	sunX = aspect.GAME_WIDTH / 2
end
		
return track4