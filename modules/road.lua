local road = {}

local aspect = require("modules.aspect")
local daynight = require("modules.daynight")
local perspective = require("modules.perspective")

road.ROAD_WIDTH = aspect.GAME_WIDTH * 1.6
road.CURB_WIDTH = road.ROAD_WIDTH / 15
road.STRIPE_WIDTH = road.CURB_WIDTH / 3
road.RAVINE_ROADSIDE_WIDTH = road.CURB_WIDTH * 6

local curbColors = nil
local grassColor = nil
local previousRavineX = nil
local ravineMinX = nil
local ravineMinXY = nil
local stripeColor = nil
local tarmacColor = nil
local textureOffset = 0
local trackHasRavine
local trackIsInCity
local trackIsInForest
local trackIsInMountains

local function drawGrass(tunnel, crossroads, light, colorIndex, ravineX, screenY, roadX, minLight)
	local sunLight = math.max(minLight, daynight:getSunLight())
	
	if crossroads then
		if tunnel or light then
			love.graphics.setColor(tarmacColor[colorIndex])
		else
			love.graphics.setColor(
				tarmacColor[colorIndex][1] * sunLight,
				tarmacColor[colorIndex][2] * sunLight,
				tarmacColor[colorIndex][3] * sunLight
			)
		end
	else
		love.graphics.setColor(
			grassColor[1] * sunLight,
			grassColor[2] * sunLight,
			grassColor[3] * sunLight
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

local function drawTarmac(light, colorIndex, roadX, screenY, roadWidth, minLight)
	if light then
		love.graphics.setColor(tarmacColor[colorIndex])
	else
		local sunLight = math.max(minLight, daynight:getSunLight())

		love.graphics.setColor(
			tarmacColor[colorIndex][1] * sunLight,
			tarmacColor[colorIndex][2] * sunLight,
			tarmacColor[colorIndex][3] * sunLight
		)
	end

	love.graphics.line(roadX, screenY, roadX + roadWidth, screenY)
end

local function drawCrosswalk(light, screenX, stripeWidth, screenY, minLight)
	if light then
		love.graphics.setColor(stripeColor)
	else
		local sunLight = math.max(minLight, daynight:getSunLight())

		love.graphics.setColor(
			stripeColor[1] * sunLight,
			stripeColor[2] * sunLight,
			stripeColor[3] * sunLight
		)
	end

	for i = -4, 4 do
		local startX = screenX + i * 2 * stripeWidth - stripeWidth / 2

		love.graphics.line(startX, screenY, startX + stripeWidth, screenY)
	end
end

local function drawCurbs(light, colorIndex, roadX, screenY, curbWidth, roadWidth, minLight)
	if light then
		love.graphics.setColor(curbColors[colorIndex])
	else
		local sunLight = math.max(minLight + 0.02, daynight:getSunLight())
		
		love.graphics.setColor(
			curbColors[colorIndex][1] * sunLight,
			curbColors[colorIndex][2] * sunLight,
			curbColors[colorIndex][3] * sunLight
		)
	end
	
	love.graphics.line(roadX, screenY, roadX + curbWidth, screenY)
	love.graphics.line(roadX + roadWidth - curbWidth, screenY, roadX + roadWidth, screenY)
end

local function drawStripes(light, screenX, stripeWidth, screenY, crosswalk, minLight)
	if light then
		love.graphics.setColor(stripeColor)
	else
		local sunLight = math.max(minLight + 0.02, daynight:getSunLight())

		love.graphics.setColor(
			stripeColor[1] * sunLight,
			stripeColor[2] * sunLight,
			stripeColor[3] * sunLight
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

	-- minimum light factor decreases towards horizon
	local deltaMinLight = 0.3 / perspective.GROUND_HEIGHT
	local minLight = 0.3

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
        entities.setupForDraw(z, screenX, screenY, perspective.scale[i], previousZ, previousScreenX, previousScreenY, previousScale, segment, minLight)
        
		-- draw grass and road elements
        drawGrass(segment.tunnel, segment.crossroads, segment.light, colorIndex, ravineX, screenY, roadX, minLight)
        drawTarmac(segment.tunnel or segment.light, colorIndex, roadX, screenY, roadWidth, minLight)

        if segment.crosswalk then
            drawCrosswalk(segment.tunnel or segment.light, screenX, stripeWidth * 2, screenY, minLight)
        elseif colorIndex ~= 1 then
            drawStripes(segment.tunnel or segment.light, screenX, stripeWidth, screenY, false, minLight)
        end

        if not (segment.tunnel or segment.crossroads) then
            drawCurbs(segment.light, colorIndex, roadX, screenY, curbWidth, roadWidth, minLight)
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

		-- increase minimum light factor
		minLight = minLight - deltaMinLight
    end
end

function road.reset(tracks)
    trackHasRavine = tracks.hasRavine()
	trackIsInMountains = tracks.isInMountains()
	trackIsInForest = tracks.isInForest()
	trackIsInCity = tracks.isInCity()

	curbColors = tracks.getCurbColors()
	grassColor = tracks.getGrassColor()
	stripeColor = tracks.getStripeColor()
	tarmacColor = tracks.getTarmacColors()
end

function road.updateTextureOffset(playerSpeed, dt)
    textureOffset = textureOffset + playerSpeed * dt

	if textureOffset > 8 then
		textureOffset = textureOffset - 8
	end
end

return road