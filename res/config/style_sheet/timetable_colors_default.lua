require "tableutil"
local ssu = require "stylesheetutil"

-- extract colors with common api
-- for _, c in ipairs(game.config.gui.lineColors) do; print("{" .. c[1] .. ", "  .. c[2] .. ", "  .. c[3] .. "}"); end;

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

-- https://steamcommunity.com/sharedfiles/filedetails/?id=2033800555
local marc345 = {
    {0.50196078431373, 0, 0},
    {0.50196078431373, 0.16470588235294, 0},
    {0.50196078431373, 0.37647058823529, 0},
    {0.29411764705882, 0.50196078431373, 0},
    {0, 0.50196078431373, 0.16862745098039},
    {0.003921568627451, 0.45882352941176, 0.50196078431373},
    {0, 0.22352941176471, 0.50196078431373},
    {0.2078431372549, 0, 0.50196078431373},
    {0.45882352941176, 0, 0.50196078431373},
    {0.50196078431373, 0, 0.16862745098039},
    {0.70196078431373, 0, 0},
    {0.70196078431373, 0.23137254901961, 0},
    {0.70196078431373, 0.52549019607843, 0},
    {0.4078431372549, 0.70196078431373, 0},
    {0, 0.70196078431373, 0.23529411764706},
    {0.007843137254902, 0.64313725490196, 0.70196078431373},
    {0, 0.31372549019608, 0.70196078431373},
    {0.29411764705882, 0, 0.70196078431373},
    {0.64313725490196, 0, 0.70196078431373},
    {0.70196078431373, 0, 0.23529411764706},
    {1, 0, 0},
    {1, 0.33333333333333, 0},
    {1, 0.74901960784314, 0},
    {0.5843137254902, 1, 0},
    {0, 1, 0.33333333333333},
    {0, 1, 1},
    {0, 0.45098039215686, 1},
    {0.4156862745098, 0, 1},
    {0.91764705882353, 0, 1},
    {1, 0, 0.33333333333333},
    {0.98039215686275, 0.24705882352941, 0.24705882352941},
    {1, 0.50196078431373, 0.25098039215686},
    {1, 0.81176470588235, 0.25098039215686},
    {0.69019607843137, 1, 0.25098039215686},
    {0.25098039215686, 1, 0.50196078431373},
    {0.25098039215686, 0.93725490196078, 1},
    {0.25098039215686, 0.58823529411765, 1},
    {0.56078431372549, 0.25098039215686, 1},
    {0.93725490196078, 0.25098039215686, 1},
    {1, 0.25098039215686, 0.50196078431373},
    {0.96078431372549, 0.48235294117647, 0.48235294117647},
    {1, 0.66666666666667, 0.50196078431373},
    {1, 0.87450980392157, 0.50196078431373},
    {0.7921568627451, 1, 0.50196078431373},
    {0.50196078431373, 1, 0.66666666666667},
    {0.50196078431373, 0.95686274509804, 1},
    {0.50196078431373, 0.72549019607843, 1},
    {0.70980392156863, 0.50196078431373, 1},
    {0.95686274509804, 0.50196078431373, 1},
    {1, 0.50196078431373, 0.66666666666667},
    {1, 0.54117647058824, 0.4},
    {1, 0.70196078431373, 0.4},
    {1, 0.94901960784314, 0.4},
    {0.6, 1, 0.4},
    {0.4, 1, 0.74901960784314},
    {0.50196078431373, 0.83137254901961, 1},
    {0.4, 0.4, 1},
    {0.8, 0.4, 1},
    {1, 0.50196078431373, 0.83529411764706},
    {1, 1, 1},
    {1, 0.42352941176471, 0.25098039215686},
    {1, 0.62352941176471, 0.25098039215686},
    {1, 0.93333333333333, 0.2},
    {0.50196078431373, 1, 0.25098039215686},
    {0.25098039215686, 1, 0.68627450980392},
    {0.25098039215686, 0.74901960784314, 1},
    {0.25098039215686, 0.25098039215686, 1},
    {0.74901960784314, 0.25098039215686, 1},
    {1, 0.25098039215686, 0.74901960784314},
    {0.74901960784314, 0.74901960784314, 0.74901960784314},
    {1, 0.23529411764706, 0},
    {1, 0.50196078431373, 0},
    {1, 0.91764705882353, 0},
    {0.33333333333333, 1, 0},
    {0, 1, 0.5843137254902},
    {0, 0.66666666666667, 1},
    {0, 0, 1},
    {0.66666666666667, 0, 1},
    {1, 0, 0.66666666666667},
    {0.50196078431373, 0.50196078431373, 0.50196078431373},
    {0.6, 0.14117647058824, 0},
    {0.6, 0.30196078431373, 0},
    {0.6, 0.54901960784314, 0},
    {0.2, 0.6, 0},
    {0, 0.6, 0.34901960784314},
    {0, 0.49803921568627, 0.74901960784314},
    {0, 0, 0.6},
    {0.4, 0, 0.6},
    {0.6, 0, 0.40392156862745},
    {0.25098039215686, 0.25098039215686, 0.25098039215686},
    {0.34901960784314, 0.082352941176471, 0},
    {0.34901960784314, 0.17647058823529, 0},
    {0.34901960784314, 0.32156862745098, 0},
    {0.11764705882353, 0.34901960784314, 0},
    {0, 0.34901960784314, 0.20392156862745},
    {0, 0.33333333333333, 0.50196078431373},
    {0, 0, 0.34901960784314},
    {0.23529411764706, 0, 0.34901960784314},
    {0.34901960784314, 0, 0.23529411764706},
    {0, 0, 0}
}

local availableColorSchemes = {
    defaultColors, marc345
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
    local lookup = { }
  
    local a = ssu.makeAdder(result)          -- helper function
    
    for _, schema in ipairs(availableColorSchemes) do
        for _, color in ipairs(schema) do
            local colorString = getColourString(color[1], color[2], color[3])
            if not lookup[colorString] then
                lookup[colorString] = true
            
                local colorArray = {color[1], color[2], color[3], 1}

                a("timetable-stationcolour-" .. colorString, {
                    backgroundColor = colorArray,
                })
                a("timetable-linecolour-" .. colorString, {
                    color = colorArray,
                })
            end
        end
    end
  
    return result
end