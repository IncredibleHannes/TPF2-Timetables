

local stationTabStationTable = {
    ScrollArea = {
        id = "timetable.stationTabStationOverviewScrollArea",
        minimumSize = { 300, 700 },
        maximumSize = { 300, 700 },
        content = {
            Table = {
                nrows = 1,
                selectMode = "SINGLE",
                id = "timetable.stationTabStationTable"
            }
        }
    }
}

local stationTabLineTable = {
    ScrollArea = {
        id = "timetable.stationTabLinesScrollArea",
        minimumSize = { 799, 700 },
        maximumSize = { 799, 700 },
        content = {
            Table = {
                nrows = 3,
                selectMode = "NONE",
                id = "timetable.stationTabLinesTable",
                colWidth = {
                    [0] = 23,
                    [1] = 150,
                }
            }
        }
    }
}

local stationTabFloatingLayout = {
    FloatingLayout = {
        spacing = 0,
        factor = 1,
        id = "timetable.floatingLayoutStationTab",
        gravity = {-1, -1},
        content = {
            [{0,0}] = stationTabStationTable,
            [{1,0}] = stationTabLineTable
        }
    }
}



return stationTabFloatingLayout