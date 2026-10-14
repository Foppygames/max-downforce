local utils = {}

function utils.round(num) 
	if num >= 0 then 
		return math.floor(num + .5) 
	else 
		return math.ceil(num - .5)
	end
end

-- from: https://www.love2d.org/wiki/Gradients
function utils.verticalGradientMesh(...)
    local colorLen = select("#", ...)

    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    local meshData = {}

	for i = 1, colorLen do
		local color = select(i, ...)
		local y = (i - 1) / (colorLen - 1)

		meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3]}
		meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3]}
	end
    
    return love.graphics.newMesh(meshData, "strip", "static")
end

return utils