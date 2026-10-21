local daynight = {}

local palette = require("modules.palette")
local utils = require("modules.utils")

local MIN_TIME = 0
local MAX_TIME = 24
local SPEED = 0.0166 * 3
local SUNRISE = 4

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

function daynight.reset()
	time = math.random(4, 18)

	daynight.update(0)
end

function daynight.update(dt)
	time = time + SPEED * dt

	if time > MAX_TIME then
		time = MIN_TIME + time - MAX_TIME
	end

	sunHeight = math.sin((time - 6) / 12 * math.pi)
	sunLight = math.max(0, sunHeight)
	
	-- update sky gradient
	local baseColor = palette.getProgressedColor(palette.HEPT32_2, palette.HEPT32_9, sunHeight)
	local horizonColor = baseColor
	
	-- between sunheight 0.6 and sunheight 0: horizon turns from baseColor to red
	if sunHeight < 0.6 and sunHeight > 0 then
		horizonColor = palette.getProgressedColor(baseColor, palette.HEPT32_30, 1 - (sunHeight / 0.6))
	-- between sunheight 0 and sunheight -0.5: horizon turns from red to black
	elseif sunHeight <= 0 and sunHeight > -0.5 then
		horizonColor = palette.getProgressedColor(palette.HEPT32_30, palette.HEPT32_2, sunHeight / -0.5)
	end

	skyGradient = utils.verticalGradientMesh(
		baseColor,
		baseColor,
		horizonColor
    )
end

return daynight