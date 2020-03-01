-- Max Downforce - modules/controls.lua
-- 2019-2020 Foppygames

love.joystick.loadGamepadMappings("gamecontrollerdb.txt")
	
local controls = {}

-- =========================================================
-- constants
-- =========================================================

controls.KEYBOARD = 1
controls.GAMEPAD = 2

controls.KEYBOARD_LABEL = "arrow keys"
controls.KEYBOARD_LABEL_DX = 0
controls.KEYBOARD_START_TEXT = "Press space to start"
controls.KEYBOARD_START_TEXT_DX = 0

controls.GAMEPAD_LABEL = "gamepad"
controls.GAMEPAD_LABEL_DX = 8
controls.GAMEPAD_START_TEXT = "Press A to start"
controls.GAMEPAD_START_TEXT_DX = 14

controls.GAMEPAD_X_DEADZONE = 0.02

controls.GAMEPAD_MODE_R = 1
controls.GAMEPAD_MODE_L = 2

-- =========================================================
-- variables
-- =========================================================

controls.available = {}
controls.joystick = nil
controls.selectedIndex = 0
controls.selected = nil
controls.joystickSteerAxis = ""
controls.joystickThrottleAxis = ""

-- =========================================================
-- public functions
-- =========================================================

-- returns joystick object if gamepad method selected
function controls.init()
	local selectedType = nil

	-- method was selected previously
	if (controls.selected ~= nil) then
		-- store its type so it can be reselected if available
		selectedType = controls.selected.type
	end

	-- reset values; function can be called anytime a joystick is added or removed
	controls.available = {}
	controls.joystick = nil
	controls.selectedIndex = 0
	controls.selected = nil

	-- keyboard is assumed available
	table.insert(controls.available,{
		type = controls.KEYBOARD,
		label = controls.KEYBOARD_LABEL,
		labelDx = controls.KEYBOARD_LABEL_DX,
		startText = controls.KEYBOARD_START_TEXT,
		startTextDx = controls.KEYBOARD_START_TEXT_DX,
		mode = nil
	})

	-- joysticks were detected
	if (love.joystick.getJoystickCount() > 0) then
		local joysticks = love.joystick.getJoysticks()

		-- look for first gamepad joystick
		for i,j in ipairs(joysticks) do
			if (j:isGamepad()) then
				controls.joystick = j
				break
			end
		end

		-- gamepad joystick is available
		if (controls.joystick ~= nil) then
			table.insert(controls.available,{
				type = controls.GAMEPAD,
				label = controls.GAMEPAD_LABEL,
				labelDx = controls.GAMEPAD_LABEL_DX,
				startText = controls.GAMEPAD_START_TEXT,
				startTextDx = controls.GAMEPAD_START_TEXT_DX,
				mode = controls.GAMEPAD_MODE_R
			})
			table.insert(controls.available,{
				type = controls.GAMEPAD,
				label = controls.GAMEPAD_LABEL,
				labelDx = controls.GAMEPAD_LABEL_DX,
				startText = controls.GAMEPAD_START_TEXT,
				startTextDx = controls.GAMEPAD_START_TEXT_DX,
				mode = controls.GAMEPAD_MODE_L
			})
		end
	end

	if (#controls.available > 0) then
		-- previously selected type is known
		if (selectedType ~= nil) then
			-- try to select it again
			local i = 1
			while i <= #controls.available do
				if (controls.available[i].type == selectedType) then
					controls.selectedIndex = i
					controls.selected = controls.available[controls.selectedIndex]
					break
				end
				i = i + 1
			end
		end

		-- no method selected yet
		if (controls.selected == nil) then
			-- select the first available control method
			controls.selectedIndex = 1
			controls.selected = controls.available[controls.selectedIndex]
		end
	end

	controls.updateJoystickAxes()
	
	if (controls.selected ~= nil) then
		if (controls.selected.type == controls.GAMEPAD) then
			return controls.joystick
		end
	end

	return nil
end

function controls.getAvailableCount()
	return #controls.available
end

function controls.getSelected()
	return controls.selected
end

-- returns joystick object if gamepad method selected
function controls.selectNextAvailable()
	controls.selectedIndex = controls.selectedIndex + 1
	if (controls.selectedIndex > #controls.available) then
		controls.selectedIndex = 1
	end
	controls.selected = controls.available[controls.selectedIndex]

	controls.updateJoystickAxes()

	if (controls.selected ~= nil) then
		if (controls.selected.type == controls.GAMEPAD) then
			return controls.joystick
		end
	end

	return nil
end

function controls.updateJoystickAxes()
	controls.joystickSteerAxis = ""
	controls.joystickThrottleAxis = ""
	if (controls.selected ~= nil) then
		if (controls.selected.type == controls.GAMEPAD) then
			if (controls.selected.mode == controls.GAMEPAD_MODE_R) then
				controls.joystickSteerAxis = "rightx"
				controls.joystickThrottleAxis = "lefty"
			else
				controls.joystickSteerAxis = "leftx"
				controls.joystickThrottleAxis = "righty"
			end
		end
	end
end

return controls