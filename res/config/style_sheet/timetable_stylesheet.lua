require "tableutil"
local ssu = require "stylesheetutil"

function data()
  local result = { }

  local a = ssu.makeAdder(result)          -- helper function

    a("conditionString", {
      fontFamily = "Noto/NotoSansMono-Regular.ttf",
      fontSize = 10,
    })

    a("!timetable-mono-sc", {
      fontFamily = "Noto/NotoSansMonoCJKsc-Regular.otf",
      fontSize = 10,
    })

    a("!timetable-mono-tc", {
      fontFamily = "Noto/NotoSansMonoCJKtc-Regular.otf",
      fontSize = 10,
    })

    a("!timetable-mono-ja", {
      fontFamily = "Noto/NotoSansMonoCJKjp-Regular.otf",
      fontSize = 10,
    })

    a("!timetable-mono-kr", {
      fontFamily = "Noto/NotoSansMonoCJKkr-Regular.otf",
      fontSize = 10,
    })

    a("stationName", {
      padding = {7,0,0,0},
      fontSize = 14,
    })

    a("!timetable-linecolour", {
      padding = {0,0,0,8},
      fontSize = 26,
    })

    a("!timetable-activateTimetableButton", {
      margin = {0,4,0,0},
      textAlignment = {0.5,0.5}
    })

    a("!timetable-stationcolour", {
      margin = {0,1,2,1},
      fontSize = 15,
      textAlignment = {0.5,0.5}
    })

    a("timetable-stationcolour-default", {
      backgroundColor = {1, 0, 0, 1},
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
  a("timetable-info-icon", {
    padding = {3,3,3,3}
  })

  return result
end