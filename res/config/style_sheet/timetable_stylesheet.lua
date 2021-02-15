require "tableutil"
local ssu = require "stylesheetutil"
 
function data()
  local result = { }
 
  local a = ssu.makeAdder(result)          -- helper function
 
    a("conditionString", {
      fontFamily = "Noto/NotoSansMono-Regular.ttf",
      fontSize = 11,
    })

    a("timetable-stationcolour-543115", {
      margin = {0,1,2,1},
      backgroundColor = {0.54, 0.31, 0.15, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-543115", {
      padding = {0,0,0,8},
      color = {0.54, 0.31, 0.15, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-924615", {
      margin = {0,1,2,1},
      backgroundColor = {0.92, 0.46, 0.15, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-924615", {
      padding = {0,0,0,8},
      color = {0.92, 0.46, 0.15, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-793081", {
      margin = {0,1,2,1},
      backgroundColor = {0.73, 0.30, 0.81, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-793081", {
      padding = {0,0,0,8},
      color = {0.73, 0.30, 0.81, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-2768100", {
      margin = {0,1,2,1},
      backgroundColor = {0.27, 0.68, 1.0, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-2768100", {
      padding = {0,0,0,8},
      color = {0.27, 0.68, 1.0, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-371752", {
      margin = {0,1,2,1},
      backgroundColor = {0.37, 0.17, 0.52, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-371752", {
      padding = {0,0,0,8},
      color = {0.37, 0.17, 0.52, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-153156", {
      margin = {0,1,2,1},
      backgroundColor = {0.15, 0.31, 0.56, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-153156", {
      padding = {0,0,0,8},
      color = {0.15, 0.31, 0.56, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-408725", {
      margin = {0,1,2,1},
      backgroundColor = {0.40, 0.87, 0.25, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-408725", {
      padding = {0,0,0,8},
      color = {0.40, 0.87, 0.25, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-004311", {
      margin = {0,1,2,1},
      backgroundColor = {0.00, 0.43, 0.11, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-004311", {
      padding = {0,0,0,8},
      color = {0.00, 0.43, 0.11, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-465120", {
      margin = {0,1,2,1},
      backgroundColor = {0.46, 0.51, 0.20, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-465120", {
      padding = {0,0,0,8},
      color = {0.46, 0.51, 0.20, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-402582", {
      margin = {0,1,2,1},
      backgroundColor = {0.40, 0.25, 0.82, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-402582", {
      padding = {0,0,0,8},
      color = {0.40, 0.25, 0.82, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-075660", {
      margin = {0,1,2,1},
      backgroundColor = {0.07, 0.56, 0.60, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-075660", {
      padding = {0,0,0,8},
      color = {0.07, 0.56, 0.60, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-823843", {
      margin = {0,1,2,1},
      backgroundColor = {0.82, 0.38, 0.43, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-823843", {
      padding = {0,0,0,8},
      color = {0.82, 0.38, 0.43, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-708240", {
      margin = {0,1,2,1},
      backgroundColor = {0.70, 0.82, 0.40, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-708240", {
      padding = {0,0,0,8},
      color = {0.70, 0.82, 0.40, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-836330", {
      margin = {0,1,2,1},
      backgroundColor = {0.83, 0.63, 0.30, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-836330", {
      padding = {0,0,0,8},
      color = {0.83, 0.63, 0.30, 1},
      fontSize = 26
    })
    
    a("timetable-stationcolour-1009312", {
      margin = {0,1,2,1},
      backgroundColor = {1.0, 0.93, 0.12, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-1009312", {
      padding = {0,0,0,8},
      color = {1.0, 0.93, 0.12, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-408164", {
      margin = {0,1,2,1},
      backgroundColor = {0.40, 0.81, 0.64, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-408164", {
      padding = {0,0,0,8},
      color = {0.40, 0.81, 0.64, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-491528", {
      margin = {0,1,2,1},
      backgroundColor = {0.49, 0.15, 0.28, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-491528", {
      padding = {0,0,0,8},
      color = {0.49, 0.15, 0.28, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-625481", {
      margin = {0,1,2,1},
      backgroundColor = {0.65, 0.58, 0.81, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-625481", {
      padding = {0,0,0,8},
      color = {0.65, 0.58, 0.81, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-343123", {
      margin = {0,1,2,1},
      backgroundColor = {0.34, 0.31, 0.23, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-343123", {
      padding = {0,0,0,8},
      color = {0.34, 0.31, 0.23, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-951820", {
      margin = {0,1,2,1},
      backgroundColor = {0.95, 0.18, 0.20, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })
    a("timetable-linecolour-951820", {
      padding = {0,0,0,8},
      color = {0.95, 0.18, 0.20, 1},
      fontSize = 26
    })

    a("timetable-stationcolour-default", {
      margin = {0,1,2,1},
      backgroundColor = {1, 0, 0, 1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })

    a("timetable-linecolour-default", {
        padding = {0,0,0,8},
        color = {1, 0, 0, 1},
        fontSize = 26
    })
    
    a("timetable-linename", {
        padding = {3,0,3,0},
        fontSize = 15
    })
 
  return result
end