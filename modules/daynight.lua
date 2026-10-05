local daynight = {}

local MIN_TIME = 0
local MAX_TIME = 24
local SPEED = 0.0166 * 30
local START_TIME = 8
local SUNRISE = 4

local sunHeight
local sunLight
local time

function daynight.init()
	daynight.reset()
end

function daynight.getDisplayTime()
	local hours = math.floor(time)
	local minutes = math.floor((time - hours) * 60)

	if minutes < 10 then
		minutes = "0" .. minutes
	end

	return hours .. ":" .. minutes
end

function daynight.getSunHeight()
	return sunHeight
end

function daynight.getSunLight()
	return sunLight
end

function daynight.reset()
	time = START_TIME

	daynight.update(0)
end

function daynight.update(dt)
	time = time + SPEED * dt

	if time > MAX_TIME then
		time = MIN_TIME + time - MAX_TIME
	end

	sunHeight = 0
	sunLight = 0

	if time > 4 and time < 22 then
		sunHeight = math.sin((time - 4) / 18 * math.pi)
		sunLight = sunHeight
	end
end

return daynight