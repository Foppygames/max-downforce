local road = {}

local aspect = require("modules.aspect")
local daynight = require("modules.daynight")
local perspective = require("modules.perspective")

road.ROAD_WIDTH = aspect.GAME_WIDTH * 1.6
road.CURB_WIDTH = road.ROAD_WIDTH / 15
road.STRIPE_WIDTH = road.CURB_WIDTH / 3
road.RAVINE_ROADSIDE_WIDTH = road.CURB_WIDTH * 6

local COLORS_CURBS_NO_RAVINE = {{1, 0.26, 0}, {1, 0.95, 0.95}}
local COLORS_CURBS_RAVINE = {{0.1, 0.26, 0.8}, {1, 0.95, 0.95}}
local COLORS_CURBS_CITY = {
	light = {{1, 0.26, 0}, {1, 0.95, 0.95}},
	no_light = {{0.8, 0.1, 0}, {0.8, 0.6, 0.6}}
}

local COLORS_GRASS_NO_RAVINE = {{0.45, 0.8, 0.25}, {0.36, 0.6, 0.20}}
local COLORS_GRASS_RAVINE = {{0.5, 0.36, 0.03}, {0.45, 0.31, 0.01}}
local COLORS_GRASS_CITY = {{0.4, 0.4, 0.44}, {0.5, 0.5, 0.55}}

local COLORS_STRIPES_RAVINE = {
	tunnel = {0.9, 0.9, 0},
	no_tunnel = {1, 0.95, 0.95}
}
local COLORS_STRIPES_NO_RAVINE = {
	tunnel = {0.8, 0.8, 0},
	no_tunnel = {1, 0.95, 0.95}
}
local COLORS_STRIPES_CITY = {
	tunnel = {1, 0.95, 0.95},
	no_tunnel = {0.8, 0.6, 0.6}
}
local COLORS_TARMAC_RAVINE = {
	tunnel = {{0.24, 0.2, 0.26}, {0.24, 0.2, 0.26}},
	no_tunnel = {{0.39, 0.28, 0.28}, {0.42, 0.30, 0.30}}
}
local COLORS_TARMAC_NO_RAVINE = {
	tunnel = {{0.1, 0.1, 0.13}, {0.11, 0.11, 0.14}},
	no_tunnel = {{0.34, 0.28, 0.28}, {0.37, 0.30, 0.30}}
}
local COLORS_TARMAC_CITY = {
	tunnel = {{0.39, 0.28, 0.28}, {0.42, 0.30, 0.30}},
	no_tunnel = {{0.22, 0.14, 0.18}, {0.24, 0.16, 0.20}}
}

local curbColors = nil
local grassColors = nil
local previousRavineX = nil
local ravineMinX = nil
local ravineMinXY = nil
local stripeColors = nil
local tarmacColors = nil
local textureOffset = 0
local trackHasRavine
local trackIsInMountains
local trackIsInForest
local trackIsInCity

local function drawGrass(tunnel, crossroads, light, colorIndex, ravineX, screenY, roadX)
	local sunLight = math.max(0.1, daynight:getSunLight())
	
	if crossroads then
		if tunnel or light then
			love.graphics.setColor(tarmacColors.tunnel[colorIndex])
		else
			love.graphics.setColor(
				tarmacColors.no_tunnel[colorIndex][1] * sunLight,
				tarmacColors.no_tunnel[colorIndex][2] * sunLight,
				tarmacColors.no_tunnel[colorIndex][3] * sunLight
			)
		end
	else
		love.graphics.setColor(
			grassColors[colorIndex][1] * sunLight,
			grassColors[colorIndex][2] * sunLight,
			grassColors[colorIndex][3] * sunLight
		)
	end

	if trackHasRavine then	
		if not tunnel then
			love.graphics.line(ravineX, screenY, aspect.GAME_WIDTH, screenY)	
		else
			love.graphics.line(ravineX, screenY, roadX, screenY)

			love.graphics.setColor(0.45, 0.32, 0.027)

			love.graphics.line(roadX, screenY, aspect.GAME_WIDTH, screenY)
		end
	else
		if tunnel then
			if trackIsInCity then
				love.graphics.setColor(1, 1, 0.6)
			else
				love.graphics.setColor(0, 0, 0)
			end
		end

		love.graphics.line(0, screenY, aspect.GAME_WIDTH, screenY)
	end
end

local function drawTarmac(tunnel, colorIndex, roadX, screenY, roadWidth)
	if tunnel then
		love.graphics.setColor(tarmacColors.tunnel[colorIndex])
	else
		local sunLight = math.max(0.3, daynight:getSunLight())

		love.graphics.setColor(
			tarmacColors.no_tunnel[colorIndex][1] * sunLight,
			tarmacColors.no_tunnel[colorIndex][2] * sunLight,
			tarmacColors.no_tunnel[colorIndex][3] * sunLight
		)
	end

	love.graphics.line(roadX, screenY, roadX + roadWidth, screenY)
end

local function drawCrosswalk(tunnel, screenX, stripeWidth, screenY, crosswalk)
	if tunnel then
		love.graphics.setColor(stripeColors.tunnel)
	else
		love.graphics.setColor(stripeColors.no_tunnel)
	end

	for i = -4, 4 do
		local startX = screenX + i * 2 * stripeWidth - stripeWidth / 2

		love.graphics.line(startX, screenY, startX + stripeWidth, screenY)
	end
end

local function drawCurbs(light, colorIndex, roadX, screenY, curbWidth, roadWidth)
	local sunLight = math.max(0.3, daynight:getSunLight())

	if trackIsInCity then
		if light then
			love.graphics.setColor(curbColors.light[colorIndex])
		else
			love.graphics.setColor(
				curbColors.no_light[colorIndex][1] * sunLight,
				curbColors.no_light[colorIndex][2] * sunLight,
				curbColors.no_light[colorIndex][3] * sunLight
			)
		end
	else
		love.graphics.setColor(
			curbColors[colorIndex][1] * sunLight,
			curbColors[colorIndex][2] * sunLight,
			curbColors[colorIndex][3] * sunLight
		)
	end

	love.graphics.line(roadX, screenY, roadX + curbWidth, screenY)
	love.graphics.line(roadX + roadWidth - curbWidth, screenY, roadX + roadWidth, screenY)
end

local function drawStripes(tunnel, screenX, stripeWidth, screenY, crosswalk)
	local sunLight = math.max(0.3, daynight:getSunLight())

	if tunnel then
		love.graphics.setColor(stripeColors.tunnel)
	else
		love.graphics.setColor(
			stripeColors.no_tunnel[1] * sunLight,
			stripeColors.no_tunnel[2] * sunLight,
			stripeColors.no_tunnel[3] * sunLight
		)
	end

	if crosswalk then
		local width = stripeWidth * 2

		for i = -4, 4 do
			local startX = screenX + i * 2 * width - width / 2

			love.graphics.line(startX, screenY, startX+width, screenY)
		end
	else
		love.graphics.line(screenX - stripeWidth / 2, screenY, screenX + stripeWidth / 2, screenY)
	end
end

function road.draw(player, entities, segments)
    -- draw ravine
    if trackHasRavine then
        if ravineMinX ~= nil then
            love.graphics.setColor(0.25, 0.18, 0.015)
            love.graphics.rectangle("fill", ravineMinX, ravineMinXY, aspect.GAME_WIDTH - ravineMinX, aspect.GAME_HEIGHT - ravineMinXY)	
        end
    end

    -- initial vertical position of drawing of road
    local screenY = aspect.GAME_HEIGHT - 0.5

    local playerX

    if player ~= nil then
        playerX = player.x
    else
        playerX = 0
    end
    
    -- initial horizontal position of drawing of road
    local screenX = aspect.GAME_WIDTH / 2 - playerX * perspective.scale[1]
    
    -- correction to always make road point to horizontal center of horizon
    local perspectiveDX = (aspect.GAME_WIDTH / 2 - screenX) / perspective.GROUND_HEIGHT
            
    -- assuming segments contains at least one segment!
    local segmentIndex = 1
    local lastSegmentIndex = segments.getLastIndex()
    local segment = segments.getAtIndex(segmentIndex)
    
    local dx = 0

    entities.resetForDraw()
    
    -- values for interpolating entity positions
    local previousZ = perspective.minZ
    local previousScreenX = screenX
    local previousScreenY = screenY
    local previousScale = perspective.scale[1]
    
    previousRavineX = nil
    ravineMinX = nil

    -- draw road
    for i = 1, perspective.GROUND_HEIGHT do
        local z = perspective.zMap[i]
        
        -- set default color index
        local colorIndex = 1
        
        -- toggle colors for horizontal striping effect
        if ((z + textureOffset) % 8) > 4 then
            colorIndex = 2
        end
        
        -- consider switching to next segment
        if segmentIndex < lastSegmentIndex then
            if z > segments.getAtIndex(segmentIndex+1).z then
                segmentIndex = segmentIndex + 1

                segment = segments.getAtIndex(segmentIndex)
            end
        end
        
        local roadWidth = road.ROAD_WIDTH * perspective.scale[i]
        local curbWidth = road.CURB_WIDTH * perspective.scale[i]
        local stripeWidth = road.STRIPE_WIDTH * perspective.scale[i]
        local roadX = screenX - roadWidth / 2
        local ravineX = roadX - road.RAVINE_ROADSIDE_WIDTH * perspective.scale[i]
        
        -- keep track of smallest ravine x for drawing ravine wall
        if trackHasRavine then
            if (previousRavineX ~= nil) and (ravineX < previousRavineX) then
                if (ravineMinX == nil) or (ravineX < ravineMinX) then
                    ravineMinX = ravineX
                    ravineMinXY = screenY
                end
            end
        end

        previousRavineX = ravineX

        -- update entities x, y, scale
        entities.setupForDraw(z, screenX, screenY, perspective.scale[i], previousZ, previousScreenX, previousScreenY, previousScale, segment)
        
        -- draw grass and road elements
        drawGrass(segment.tunnel, segment.crossroads, segment.light, colorIndex, ravineX, screenY, roadX)
        drawTarmac(segment.tunnel or segment.light, colorIndex, roadX, screenY, roadWidth)

        if segment.crosswalk then
            drawCrosswalk(segment.tunnel or segment.light, screenX, stripeWidth * 2, screenY)
        elseif colorIndex ~= 1 then
            drawStripes(segment.tunnel or segment.light, screenX, stripeWidth, screenY)
        end

        if not (segment.tunnel or segment.crossroads) then
            drawCurbs(segment.light, colorIndex, roadX, screenY, curbWidth, roadWidth)
        end
        
        previousZ = z
        previousScreenX = screenX
        previousScreenY = screenY
        previousScale = perspective.scale[i]
        
        -- no hills, just decrease y by one
        screenY = screenY - 1
        
        -- update the change that is applied to x
        dx = dx + segment.ddx * perspective.zMap[i] * (perspective.zMap[i] / 6) * ((perspective.scale[1] - perspective.scale[i]) * 2.5)
        
        -- apply the change to x and apply perspective correction 
        screenX = screenX + dx + perspectiveDX
    end
end

local function setCurbColors()
	if trackIsInMountains then
		curbColors = COLORS_CURBS_RAVINE
	elseif trackIsInForest then
		curbColors = COLORS_CURBS_NO_RAVINE
	else
		curbColors = COLORS_CURBS_CITY
	end
end

local function setGrassColors()
	if trackIsInMountains then
		grassColors = COLORS_GRASS_RAVINE
	elseif trackIsInForest then
		grassColors = COLORS_GRASS_NO_RAVINE
	else
		grassColors = COLORS_GRASS_CITY
	end
end

local function setStripeColors()
	if trackIsInMountains then
		stripeColors = COLORS_STRIPES_RAVINE
	elseif trackIsInForest then
		stripeColors = COLORS_STRIPES_NO_RAVINE
	else
		stripeColors = COLORS_STRIPES_CITY
	end
end

local function setTarmacColors()
	if trackIsInMountains then
		tarmacColors = COLORS_TARMAC_RAVINE
	elseif trackIsInForest then
		tarmacColors = COLORS_TARMAC_NO_RAVINE
	else
		tarmacColors = COLORS_TARMAC_CITY
	end
end

function road.reset(hasRavine, isInMountains, isInForest, isInCity)
    trackHasRavine = hasRavine
	trackIsInMountains = isInMountains
	trackIsInForest = isInForest
	trackIsInCity = isInCity

    setCurbColors()
	setGrassColors()
	setStripeColors()
	setTarmacColors()
end

function road.updateTextureOffset(playerSpeed, dt)
    textureOffset = textureOffset + playerSpeed * dt

	if textureOffset > 8 then
		textureOffset = textureOffset - 8
	end
end

return road