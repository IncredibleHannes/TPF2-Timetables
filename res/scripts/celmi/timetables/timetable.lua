local timetableHelper = require "celmi/timetables/timetable_helper"

local result = {}

function result.getConditions(line, station)
    local res = {}
    return res
end

function result.addConditions(line, station, condition)
    return null
end

function result.removeConditions(line, station, index)
    return null
end

function result.hasTimetable(line)
    return false
end

function result.waitingRequired(vehicle)
    --condition.departure.min > tonumber(os.date('%M', time)
    return false
end

function result.setHasTimetable(line)
    return null
end


local condition1 = {
    arrival = {
        min = 1,
        sec = 0
    },
    departure = {
        min = 2,
        sec = 30
    }
}

local condition2 = {
    arrival = {
        min = 3,
        sec = 0
    },
    departure = {
        min = 3,
        sec = 30
    }
}


result = {
    timetables = {
        {
            line = testLine,
            stations = {
                station1 = condition1,
                station2 = condition2
            }
        },
    }
}

return result

