local palette = {}

local utils = require("modules.utils")

-- colors from: https://lospec.com/palette-list/hept32
palette.HEPT32_1 = utils.getColorFromHexColor("#000000")
palette.HEPT32_2 = utils.getColorFromHexColor("#180D2F")
palette.HEPT32_3 = utils.getColorFromHexColor("#353658")
palette.HEPT32_4 = utils.getColorFromHexColor("#686B72")
palette.HEPT32_5 = utils.getColorFromHexColor("#8B97B6")
palette.HEPT32_6 = utils.getColorFromHexColor("#C5CDDB")
palette.HEPT32_7 = utils.getColorFromHexColor("#ffffff")
palette.HEPT32_8 = utils.getColorFromHexColor("#5EE9E9")
palette.HEPT32_9 = utils.getColorFromHexColor("#2890DC")
palette.HEPT32_10 = utils.getColorFromHexColor("#1831A7")
palette.HEPT32_11 = utils.getColorFromHexColor("#053239")
palette.HEPT32_12 = utils.getColorFromHexColor("#005F41")
palette.HEPT32_13 = utils.getColorFromHexColor("#08B23B")
palette.HEPT32_14 = utils.getColorFromHexColor("#47F641")
palette.HEPT32_15 = utils.getColorFromHexColor("#E8FF75")
palette.HEPT32_16 = utils.getColorFromHexColor("#FBBE82")
palette.HEPT32_17 = utils.getColorFromHexColor("#DE9751")
palette.HEPT32_18 = utils.getColorFromHexColor("#B66831")
palette.HEPT32_19 = utils.getColorFromHexColor("#8A4926")
palette.HEPT32_20 = utils.getColorFromHexColor("#461C14")
palette.HEPT32_21 = utils.getColorFromHexColor("#1E090D")
palette.HEPT32_22 = utils.getColorFromHexColor("#720D0D")
palette.HEPT32_23 = utils.getColorFromHexColor("#813704")
palette.HEPT32_24 = utils.getColorFromHexColor("#DA2424")
palette.HEPT32_25 = utils.getColorFromHexColor("#EF6E10")
palette.HEPT32_26 = utils.getColorFromHexColor("#ECAB11")
palette.HEPT32_27 = utils.getColorFromHexColor("#ECE910")
palette.HEPT32_28 = utils.getColorFromHexColor("#F78D8D")
palette.HEPT32_29 = utils.getColorFromHexColor("#F94E6D")
palette.HEPT32_30 = utils.getColorFromHexColor("#C12458")
palette.HEPT32_31 = utils.getColorFromHexColor("#841252")
palette.HEPT32_32 = utils.getColorFromHexColor("#3D083B")

-- return the color between color1 and color2
function palette.getProgressedColor(color1, color2, progression)
	return {
		color1[1] + (color2[1] - color1[1]) * progression,
		color1[2] + (color2[2] - color1[2]) * progression,
		color1[3] + (color2[3] - color1[3]) * progression
	}
end

return palette