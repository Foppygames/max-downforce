-- Max Downforce - modules/timer.lua
-- 2019 Foppygames

local timer = {}

local utils = require("modules.utils")

local MIN_TIME = 60
local MAX_TIME = 100

local remaining

function timer.init()
	-- ...
end

function timer.reset(progress)
	if (progress == 0) then
		remaining = MAX_TIME
	else
		remaining = remaining + MAX_TIME - (progress * (MAX_TIME - MIN_TIME))
	end
end

function timer.getDisplayValue()
	return utils.round(remaining)
end

function timer.update(dt)
	remaining = remaining - dt
	return (remaining > 0)
end

return timer