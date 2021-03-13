require "tableutil"
local ssu = require "stylesheetutil"

local defaultColors = {
    { 0.96, 0.19, 0.21 },
    { 1, 0.93, 0.13 },
    { 0.4, 0.87, 0.25 },
    { 0.27, 0.69, 1 },
    { 0.79, 0.3, 0.81 },
    { 0.92, 0.46, 0.15 },
    { 0.54, 0.31, 0.15 },
    { 0, 0.43, 0.12 },
    { 0.16, 0.31, 0.57 },
    { 0.37, 0.17, 0.53 },
    { 0.83, 0.39, 0.44 },
    { 0.84, 0.64, 0.3 },
    { 0.71, 0.83, 0.4 },
    { 0.4, 0.82, 0.65 },
    { 0.62, 0.54, 0.82 },
    { 0.49, 0.16, 0.29 },
    { 0.34, 0.32, 0.24 },
    { 0.47, 0.52, 0.21 },
    { 0.07, 0.56, 0.6 },
    { 0.40, 0.25, 0.83 },
}

-- copied from timetable_helper.lua, import is not possible
local function getColourString(r, g, b)
    local x = string.format("%03.0f", (r * 100))
    local y = string.format("%03.0f", (g * 100))
    local z = string.format("%03.0f", (b * 100))
    return x .. y .. z
end

function data()
    local result = { }
  
    local a = ssu.makeAdder(result)          -- helper function
    
    for _, color in ipairs(defaultColors) do
        local colorString = getColourString(color[1], color[2], color[3])
        local colorArray = {color[1], color[2], color[3], 1}

        a("timetable-stationcolour-" .. colorString, {
            backgroundColor = colorArray,
        })
        a("timetable-linecolour-" .. colorString, {
            color = colorArray,
        })
    end
  
    return result
end