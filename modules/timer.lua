-- Max Downforce - modules/timer.lua
-- 2019 Foppygames

local timer = {}

-- =========================================================
-- includes
-- =========================================================

local utils = require("modules.utils")

-- =========================================================
-- constants
-- =========================================================

-- note: reasonably quick lap is around 50 seconds

local MAX_TIME = 70 -- time available for first lap
local MIN_TIME = 50 -- time available for last lap
local CARRY_FACTOR = 0.1 -- factor of remaining time carried to next lap
local TIME_DANGEROUS = 9

-- =========================================================
-- variables
-- =========================================================

local remaining
local pauseRemaining
local halted

-- =========================================================
-- functions
-- =========================================================

function timer.init()
	-- ...
end

function timer.reset(progress,pause)
	halted = false
	if (progress == 0) then
		remaining = MAX_TIME
	else
		local bonus = remaining * CARRY_FACTOR
		remaining = math.ceil(MAX_TIME - (progress * (MAX_TIME - MIN_TIME)) + bonus)
	end
	pauseRemaining = pause
end

function timer.getDisplayTime()
	return math.ceil(remaining)
end

function timer.update(dt)
	if (not halted) then
		if (pauseRemaining > 0) then
			pauseRemaining = pauseRemaining - dt
			if (pauseRemaining < 0) then
				remaining = remaining + pauseRemaining
			end
		else
			remaining = remaining - dt
		end
		if (remaining < 0) then
			remaining = 0
		end
	end
	return (remaining > 0)
end

function timer.isDangerous()
	return (remaining < TIME_DANGEROUS)
end

function timer.halt()
	halted = true
end

return timer