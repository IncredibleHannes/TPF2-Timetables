require "tableutil"
local ssu = require "stylesheetutil"
 
function data()
  local result = { }
 
  local a = ssu.makeAdder(result)          -- helper function
 
    a("timetable-stationcolour-red", {
        margin = {0,1,2,1},
        backgroundColor = {1, 0, 0, 1},
        fontSize = 15,
        textAlignment = {0.5,0.5}
    })

    a("timetable-linecolour-red", {
        padding = {3,0,3,8},
        color = {1, 0, 0, 1},
        fontSize = 30
    })
    a("timetable-linename", {
        padding = {3,0,3,0},
        fontSize = 15
    })
 
  return result
end