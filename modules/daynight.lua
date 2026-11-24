local daynight = {}

local palette = require("modules.palette")
local utils = require("modules.utils")

local MIN_TIME = 0
local MID_TIME = 12
local MAX_TIME = 24
local SPEED = 0.0166 * 4
local SUNRISE = 4

local horizonEveningMorningColor
local horizonEveningColors
local horizonMorningColors
local skyColorDay
local skyColorsDay
local skyColorNight
local skyColorsNight

local skyGradient
local sunHeight
local sunLight
local time

function daynight.getDisplayTime()
	local hours = math.floor(time)
	local minutes = math.floor((time - hours) * 60)

	if minutes < 10 then
		minutes = "0" .. minutes
	end

	return hours .. ":" .. minutes
end

function daynight.getSkyGradient()
	return skyGradient
end

function daynight.getSunHeight()
	return sunHeight
end

function daynight.getSunLight()
	return sunLight
end

function daynight.reset(tracks)
	time = math.random(6, 10)

	horizonEveningColors = tracks.getHorizonEveningColors()
	horizonMorningColors = tracks.getHorizonMorningColors()
	skyColorsDay = tracks.getSkyColorsDay()
	skyColorsNight = tracks.getSkyColorsNight()

	daynight.resetColors(true, false)
	daynight.update(0)
end

function daynight.resetColors(resetDayColor, resetNightColor)
	if resetDayColor then
		horizonEveningMorningColor = horizonMorningColors[math.random(1, #horizonMorningColors)]
	end

	if resetNightColor then
		horizonEveningMorningColor = horizonEveningColors[math.random(1, #horizonEveningColors)]
	end

	if (skyColorDay == nil) or resetDayColor then
		skyColorDay = skyColorsDay[math.random(1, #skyColorsDay)]
	end

	if (skyColorNight == nil) or resetNightColor then
		skyColorNight = skyColorsNight[math.random(1, #skyColorsNight)]
	end
end

function daynight.update(dt)
	local oldTime = time

	time = time + SPEED * dt

	if time > MAX_TIME then
		time = MIN_TIME + time - MAX_TIME

		daynight.resetColors(true, false)
	elseif oldTime < MID_TIME then
		if time >= MID_TIME then
			daynight.resetColors(false, true)
		end
	end

	sunHeight = math.sin((time - 6) / 12 * math.pi)
	sunLight = math.max(0, sunHeight)
	
	-- update sky gradient
	local baseColor = palette.getProgressedColor(skyColorNight, skyColorDay, math.max(0, sunHeight))
	local horizonColor = baseColor
	
	-- between sunheight 0.6 and sunheight 0: horizon turns from baseColor to red
	if sunHeight < 0.6 and sunHeight > 0 then
		horizonColor = palette.getProgressedColor(baseColor, horizonEveningMorningColor, 1 - (sunHeight / 0.6))
	-- between sunheight 0 and sunheight -0.5: horizon turns from red to black
	elseif sunHeight <= 0 and sunHeight > -0.5 then
		horizonColor = palette.getProgressedColor(horizonEveningMorningColor, skyColorNight, sunHeight / -0.5)
	end

	skyGradient = utils.verticalGradientMesh(
		baseColor,
		baseColor,
		horizonColor
    )
end

return daynight