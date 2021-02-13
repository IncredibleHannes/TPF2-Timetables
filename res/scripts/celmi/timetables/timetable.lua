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
    type = "ArrDep" | "minWait" | "debounce" | "moreFancey"
    data = {}
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

function timetable.getConditions(line, station)
    local res = {}
    return res
end


-- TEST: timetable.addCondition(1,1,{type = "ArrDep", data = {}})
function timetable.addCondition(line, station, condition)
    if not(line and station and condition) then return null end

    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[tostring(station)] then
        if condition.type == "ArrDep" then
            local conditionArr = timetableObject[tostring(line)].stations[tostring(station)].conditions
            conditionArr[#conditionArr + 1] = condition
        elseif condition.type == "minWait" then
    
        elseif condition.type == "debounce" then
    
        elseif condition.type == "moreFancey" then
        
        end
    else
        if not timetableObject[tostring(line)] then 
            timetableObject[tostring(line)] = {hasTimetable = false, stations = {}}
        end
        timetableObject[tostring(line)].stations[tostring(station)] = {inboundTime = 0, conditions = {condition}}
        -- add line and station
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

