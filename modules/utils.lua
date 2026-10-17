local utils = {}

-- from: https://gist.github.com/jiaaro/da1f16cab12e957eda79377376faa2f7
function utils.getColorFromHexColor(hexColor)
	if hexColor:sub(1, 1) == "#" then
		hexColor = hexColor:sub(2)
	elseif hexColor:sub(1, 2) == "0x" then
		hexColor = hexColor:sub(3)
	end

	local color = {}
	local colorWidth = (#hexColor < 6) and 1 or 2
	local maxVal = 16 ^ colorWidth - 1

	for i = 1, #hexColor, colorWidth do
		color[#color + 1] = tonumber(hexColor:sub(i, i + colorWidth - 1), 16) / maxVal
	end

	return color
end

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