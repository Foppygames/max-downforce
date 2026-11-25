local daynight = {}

local palette = require("modules.palette")
local utils = require("modules.utils")

local MIN_TIME = 0
local MID_TIME = 12
local MAX_TIME = 24
local SPEED = 0.0166 * 4
local SUNRISE = 4

local cycleEnabled = true
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

function daynight.cycleIsEnabled()
	return cycleEnabled
end

function daynight.getCycleEnabledLabel()
	if cycleEnabled then
		return "on"
	end

	return "off"
end

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
	if cycleEnabled then
		time = math.random(8, 10)
	else
		time = tracks.getDefaultTime()
	end

	horizonEveningColors = tracks.getHorizonEveningColors()
	horizonMorningColors = tracks.getHorizonMorningColors()
	skyColorsDay = tracks.getSkyColorsDay()
	skyColorsNight = tracks.getSkyColorsNight()

	if (time > MIN_TIME) and (time <= MID_TIME) then
		daynight.resetHorizonEveningMorningColor(true, false)	
	else
		daynight.resetHorizonEveningMorningColor(false, true)
	end

	daynight.resetSkyColor(true, true)
	daynight.updateSun()
	daynight.updateSkyGradient()
end

function daynight.resetHorizonEveningMorningColor(resetDayColor, resetNightColor)
	if resetDayColor then
		horizonEveningMorningColor = horizonMorningColors[math.random(1, #horizonMorningColors)]
	end

	if resetNightColor then
		horizonEveningMorningColor = horizonEveningColors[math.random(1, #horizonEveningColors)]
	end
end

function daynight.resetSkyColor(resetDayColor, resetNightColor)
	if resetDayColor then
		skyColorDay = skyColorsDay[math.random(1, #skyColorsDay)]
	end

	if resetNightColor then
		skyColorNight = skyColorsNight[math.random(1, #skyColorsNight)]
	end
end

-- Note: only used while on title screen
function daynight.toggleCycleEnabled()
	cycleEnabled = not cycleEnabled
end

function daynight.update(dt)
	if cycleEnabled then
		local updateTimeResult = daynight.updateTime(dt)

		if updateTimeResult > 0 then
			if updateTimeResult == 1 then
				daynight.resetHorizonEveningMorningColor(true, false)
				daynight.resetSkyColor(true, false)
			else
				daynight.resetHorizonEveningMorningColor(false, true)
				daynight.resetSkyColor(false, true)
			end
		end

		daynight.updateSun()
		daynight.updateSkyGradient()
	end
end

function daynight.updateSkyGradient()
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

function daynight.updateSun()
	sunHeight = math.sin((time - 6) / 12 * math.pi)
	sunLight = math.max(0, sunHeight)
end

-- Returns which colors should be updated: 1 for day colors, 2 for night colors, 0 for no update
function daynight.updateTime(dt)
	local oldTime = time

	time = time + SPEED * dt

	if time > MAX_TIME then
		time = MIN_TIME + time - MAX_TIME

		return 1
	elseif oldTime < MID_TIME then
		if time >= MID_TIME then
			return 2
		end
	end

	return 0
end

return daynight