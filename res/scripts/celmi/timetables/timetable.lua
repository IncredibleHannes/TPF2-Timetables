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

conditions = {
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
        local conditionObject = timetableObject[tostring(line)].stations[stationNumber].conditions[type] 
        if not conditionObject then  timetableObject[tostring(line)].stations[stationNumber].conditions[type] = {} end
    else
        if not timetableObject[tostring(line)] then 
            timetableObject[tostring(line)] = { hasTimetable = false, stations = {}}
        end
        timetableObject[tostring(line)].stations[stationNumber] = {inobundTime = 0, conditions = {type = type}}
        local conditionObject = timetableObject[tostring(line)].stations[stationNumber].conditions[type] 
        if not conditionObject then  timetableObject[tostring(line)].stations[stationNumber].conditions[type] = {} end
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


function timetable.getConditions(line, stationNumber, type)
    if not(line and stationNumber) then return -1 end
    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] and timetableObject[tostring(line)].stations[stationNumber].conditions[type] then 
        return timetableObject[tostring(line)].stations[stationNumber].conditions[type]
    else
        return -1
    end
end


-- TEST: timetable.addCondition(1,1,{type = "ArrDep", ArrDep = {{12,14,14,14}}})
function timetable.addCondition(line, stationNumber, condition)
    if not(line and stationNumber and condition) then return -1 end

    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        if condition.type == "ArrDep" then
            timetable.setConditionType(line, stationNumber, condition.type)
            local mergedArrays = timetableHelper.mergeArray(timetableObject[tostring(line)].stations[stationNumber].conditions.ArrDep, condition.ArrDep)
            timetableObject[tostring(line)].stations[stationNumber].conditions.ArrDep = mergedArrays
        elseif condition.type == "minWait" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "minWait"
            timetableObject[tostring(line)].stations[stationNumber].conditions.minWait = condition.minWait
        elseif condition.type == "debounce" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "debounce"
            timetableObject[tostring(line)].stations[stationNumber].conditions.debounce = condition.debounce
        elseif condition.type == "moreFancey" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "moreFancey"
            timetableObject[tostring(line)].stations[stationNumber].conditions.moreFancey = condition.moreFancey     
        end

    else
        if not timetableObject[tostring(line)] then 
            timetableObject[tostring(line)] = {hasTimetable = false, stations = {}}
        end
        timetableObject[tostring(line)].stations[stationNumber] = {inobundTime = 0, conditions = condition}
    end
end

function timetable.updateArrDep(line, station, indexKey, indexValue, value)
    if not (line and station and indexKey and indexValue and value) then return -1 end
    if timetableObject[tostring(line)] and 
       timetableObject[tostring(line)].stations[station] and 
       timetableObject[tostring(line)].stations[station].conditions and 
       timetableObject[tostring(line)].stations[station].conditions.ArrDep and 
       timetableObject[tostring(line)].stations[station].conditions.ArrDep[indexKey] and
       timetableObject[tostring(line)].stations[station].conditions.ArrDep[indexKey][indexValue] then
       timetableObject[tostring(line)].stations[station].conditions.ArrDep[indexKey][indexValue] = value
        return 0
    else
        return -2
    end
end

function timetable.removeCondition(line, station, type, index)
    if not(line and station and index) or (not (timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[station])) then return -1 end

    if type == "ArrDep" then 
        
        local tmpTable = timetableObject[tostring(line)].stations[station].conditions.ArrDep
        if tmpTable and tmpTable[index] then return table.remove(tmpTable, index) end
    else
        -- just remove the whole condition
        local tmpTable = timetableObject[tostring(line)].stations[station].conditions[type]
        if tmpTable and tmpTable[index] then tmpTable = {} end
        return 0
    end
    return -1
end

function timetable.hasTimetable(line)
    
    if timetableObject[tostring(line)] then
        return true--timetableObject[tostring(line)].hasTimetable
    else
        return true--false
    end
end

function timetable.waitingRequired(vehicle)

    local time = timetableHelper.getTime()
    local currentLine = timetableHelper.getCurrentLine(vehicle)
    local currentStop = timetableHelper.getCurrentStation(vehicle)

    if not timetableObject[tostring(currentLine)] then return false end
    if not timetableObject[tostring(currentLine)].stations[currentStop] then return false end
    if not timetableObject[tostring(currentLine)].stations[currentStop].conditions then return false end
    if not timetableObject[tostring(currentLine)].stations[currentStop].conditions.type then return false end

    if timetableObject[tostring(currentLine)].stations[currentStop].conditions.type == "ArrDep" then 
        return true
    else
        return false
    end

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

