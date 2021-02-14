local timetableHelper = require "celmi/timetables/timetable_helper"


--[[
timetable = {
    line = {
        stations = { stationinfo }
        hasTimetable = true
    }
}

stationInfo = {
    conditions = {condition :: Condition},
    inboundTime = 1 :: int
}

condition = {
    type = "None"| "ArrDep" | "minWait" | "debounce" | "moreFancey"
    ArrDep = {}
    minWait = {}
    debaunce  = {}
    moreFancey = {}
}
--]]
local timetable = { }
local timetableObject = { }

function timetable.getTimetableObject()
    return timetableObject
end

function timetable.setTimetableObject(t)
    if t then
        timetableObject = t
    end
end

function timetable.setConditionType(line, stationNumber, type)
    if not(line and stationNumber) then return -1 end
    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        timetableObject[tostring(line)].stations[stationNumber].conditions.type = type
    else
        if not timetableObject[tostring(line)] then 
            timetableObject[tostring(line)] = { hasTimetable = false, stations = {}}
        end
        timetableObject[tostring(line)].stations[stationNumber] = {inobundTime = 0, conditions = {type = type}}
    end
end

function timetable.getConditionType(line, stationNumber)
    if not(line and stationNumber) then return "ERROR" end
    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then 
        if timetableObject[tostring(line)].stations[stationNumber].conditions.type then
            return timetableObject[tostring(line)].stations[stationNumber].conditions.type
        else 
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "None"
            return "None"
        end
    else
        return "None"
    end
end


function timetable.getConditions(line, stationNumber)
    if not(line and stationNumber) then return -1 end
    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then 
        return timetableObject[tostring(line)].stations[stationNumber].conditions
    else
        return -1
    end
end


-- TEST: timetable.addCondition(1,1,{type = "ArrDep", ArrDep = {{12,14,14,14}}})
function timetable.addCondition(line, stationNumber, condition)
    if not(line and stationNumber and condition) then return -1 end

    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        if condition.type == "ArrDep" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "ArrDep"
            timetableObject[tostring(line)].stations[stationNumber].conditions.ArrDep = condition.ArrDep
        elseif condition.type == "minWait" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "minWait"
            timetableObject[tostring(line)].stations[stationNumber].conditions.ArrDep = condition.minWait
        elseif condition.type == "debounce" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "debounce"
            timetableObject[tostring(line)].stations[stationNumber].conditions.ArrDep = condition.debounce
        elseif condition.type == "moreFancey" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "moreFancey"
            timetableObject[tostring(line)].stations[stationNumber].conditions.ArrDep = condition.moreFancey     
        end

    else
        if not timetableObject[tostring(line)] then 
            timetableObject[tostring(line)] = {hasTimetable = false, stations = {}}
        end
        timetableObject[tostring(line)].stations[stationNumber] = {inobundTime = 0, conditions = condition}
    end
end

function timetable.removeCondition(line, station, index)
    if not(line and station and index) and (not (timetableObject[line] and timetableObject[tostring(line)].stations[tostring(station)])) then return -1 end

    if timetableObject[tostring(line)].stations[tostring(station)] then
        return table.remove(timetableObject[tostring(line)].stations[tostring(station)].conditions, index)
    end
    return -1
end

function timetable.hasTimetable(line)
    if timetableObject[tostring(line)] then
        return timetableObject[tostring(line)].hasTimetable
    else
        return false
    end
end

function timetable.waitingRequired(vehicle)
    local res = true
    local time = timetableHelper.getTime()
    if tonumber(os.date('%M', time)) % 3 == 0 then
        res = false
    end
    return res
end

function timetable.setHasTimetable(line, bool)
    if timetableObject[tostring(line)] then
        timetableObject[tostring(line)].hasTimetable = bool
    else 
        timetableObject[tostring(line)] = {stations = {} , hasTimetable = bool}
    end
    return bool
end

return timetable

