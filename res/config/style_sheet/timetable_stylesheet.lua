require "tableutil"
local ssu = require "stylesheetutil"
 
function data()
  local result = { }
 
  local a = ssu.makeAdder(result)          -- helper function
 
    a("timetable-linecolour-red", {
        padding = {0,0,0,8},
        color = {1, 0, 0, 1},
        fontSize = 15
    })
    a("timetable-linename", {
        padding = {0,0,0,0},
        fontSize = 15
    })
 
  return result
end