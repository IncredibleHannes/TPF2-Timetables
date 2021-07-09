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
local currentlyWaiting = { }


function timetable.getTimetableObject()
    return timetableObject
end

function timetable.setTimetableObject(t)
    if t then
        timetableObject = t
    end
end

function timetable.getCurrentlyWaiting()
    return currentlyWaiting
end

function timetable.setCurrentlyWaiting(t)
    if t then
        currentlyWaiting = t
    end
end

function timetable.setConditionType(line, stationNumber, type)
    local stationID = timetableHelper.getStationID(line, stationNumber)
    if not(line and stationNumber) then return -1 end
    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        timetableObject[tostring(line)].stations[stationNumber].conditions.type = type
        local conditionObject = timetableObject[tostring(line)].stations[stationNumber].conditions[type]
        if not conditionObject then  timetableObject[tostring(line)].stations[stationNumber].conditions[type] = {} end
        timetableObject[tostring(line)].stations[stationNumber].stationID = stationID
    else
        if not timetableObject[tostring(line)] then
            timetableObject[tostring(line)] = { hasTimetable = false, stations = {}}
        end

        timetableObject[tostring(line)].stations[stationNumber] = {
            inboundTime = 0,
            stationID = stationID,
            conditions = {type = type}
        }
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


function timetable.getAllConditionsOfStaion(stationID)
    local res = { }
    for k,v in pairs(timetableObject) do
        for _,v2 in pairs(v.stations) do
            if v2.stationID
               and v2.conditions
               and  v2.conditions.type
               and not (v2.conditions.type == "None")
               and tostring(v2.stationID) == tostring(stationID+1) then
                res[k] = {
                    stationID = v2.stationID,
                    conditions = v2.conditions
                }
            end
        end
    end
    return res
end

function timetable.getAllConditionsOfAllStations()
    local res = { }
    for k,v in pairs(timetableObject) do
        for _,v2 in pairs(v.stations) do
            if v2.stationID and v2.conditions and  v2.conditions.type and not (v2.conditions.type == "None")  then
                if not res[v2.stationID] then res[v2.stationID] = {} end
                res[v2.stationID][k] = {
                    conditions = v2.conditions
                }
            end
        end
    end
    return res
end

function timetable.getConditions(line, stationNumber, type)
    if not(line and stationNumber) then return -1 end
    if timetableObject[tostring(line)]
       and timetableObject[tostring(line)].stations[stationNumber]
       and timetableObject[tostring(line)].stations[stationNumber].conditions[type] then
        return timetableObject[tostring(line)].stations[stationNumber].conditions[type]
    else
        return -1
    end
end


-- TEST: timetable.addCondition(1,1,{type = "ArrDep", ArrDep = {{12,14,14,14}}})
function timetable.addCondition(line, stationNumber, condition)
    local stationID = timetableHelper.getStationID(line, stationNumber)
    if not(line and stationNumber and condition) then return -1 end

    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        if condition.type == "ArrDep" then
            timetable.setConditionType(line, stationNumber, condition.type)
            local arrDepCond = timetableObject[tostring(line)].stations[stationNumber].conditions.ArrDep
            local mergedArrays = timetableHelper.mergeArray(arrDepCond, condition.ArrDep)
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
        timetableObject[tostring(line)].stations[stationNumber].stationID = stationID

    else
        if not timetableObject[tostring(line)] then
            timetableObject[tostring(line)] = {hasTimetable = false, stations = {}}
        end
        timetableObject[tostring(line)].stations[stationNumber] = {
            inboundTime = 0,
            stationID = stationID,
            conditions = condition
        }
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

function timetable.updateDebounce(line, station, indexKey, value)
    if not (line and station and indexKey and value) then return -1 end
    if timetableObject[tostring(line)] and
       timetableObject[tostring(line)].stations[station] and
       timetableObject[tostring(line)].stations[station].conditions and
       timetableObject[tostring(line)].stations[station].conditions.debounce then
       timetableObject[tostring(line)].stations[station].conditions.debounce[indexKey] = value
        return 0
    else
        return -2
    end
end

function timetable.removeCondition(line, station, type, index)
    if not(line and station and index) or (not (timetableObject[tostring(line)]
       and timetableObject[tostring(line)].stations[station])) then
        return -1
    end

    if type == "ArrDep" then
        local tmpTable = timetableObject[tostring(line)].stations[station].conditions.ArrDep
        if tmpTable and tmpTable[index] then return table.remove(tmpTable, index) end
    else
        -- just remove the whole condition
        local tmpTable = timetableObject[tostring(line)].stations[station].conditions[type]
        if tmpTable and tmpTable[index] then timetableObject[tostring(line)].stations[station].conditions[type] = {} end
        return 0
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
    local time = timetableHelper.getTime()
    local currentLine = timetableHelper.getCurrentLine(vehicle)
    local currentStop = timetableHelper.getCurrentStation(vehicle)
    local currentLineString = tostring(currentLine)
    if not timetableObject[currentLineString] then return false end
    if not timetableObject[currentLineString].stations[currentStop] then return false end
    if not timetableObject[currentLineString].stations[currentStop].conditions then return false end
    if not timetableObject[currentLineString].stations[currentStop].conditions.type then return false end

    if timetableHelper.getTimeUntilDeparture(vehicle) >= 5 then return false end

    if not currentlyWaiting[currentLineString] then currentlyWaiting[currentLineString] = {stations = {}} end
    if not currentlyWaiting[currentLineString].stations[currentStop] then
          currentlyWaiting[currentLineString].stations[currentStop] = { currentlyWaiting = {}}
    end
    if timetableObject[currentLineString].stations[currentStop].conditions.type == "ArrDep" then
        -- am I currently waiting or just arrived?

        if not (currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting[vehicle]) then
            -- check if is about to depart

            if currentlyWaiting[currentLineString].stations[currentStop].outboundTime
               and (currentlyWaiting[currentLineString].stations[currentStop].outboundTime + 40) > time then
                return false
            end

            -- just arrived
            local nextConstraint = timetable.getNextConstraint(timetableObject[currentLineString].stations[currentStop].conditions.ArrDep, time)
            if not nextConstraint then
                -- no constraints set
                currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting = {}
                return false
            end
            if timetable.beforeDepature(nextConstraint, time, timetableObject[currentLineString].stations[currentStop].conditions.ArrDep) then
                -- Constraint set and I need to wait
                currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting[vehicle] = {
                    type = "ArrDep",
                    arrivalTime = time,
                    constraint = nextConstraint
                }

                return true
            else
                -- Constraint set and its time to depart
                currentlyWaiting[currentLineString].stations[currentStop].outboundTime = time
                currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting = {}
                return false
            end
        else
            -- already waiting
            local arivalTime = currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting[vehicle].arrivalTime
            local constraint = timetable.getNextConstraint(timetableObject[currentLineString].stations[currentStop].conditions.ArrDep, arivalTime)
            if timetable.beforeDepature(constraint, time, timetableObject[currentLineString].stations[currentStop].conditions.ArrDep) then
                -- need to continue waiting
                return true
            else
                -- done waiting
                currentlyWaiting[currentLineString].stations[currentStop].outboundTime = time
                currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting = {}
                return false
            end
        end


    --------------------------------------------------------------------------------------------------------------------
    --------------------------------------- DEBOUNCE -------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------
    elseif timetableObject[currentLineString].stations[currentStop].conditions.type == "debounce" then
        local previousDepartureTime = timetableHelper.getPreviousDepartureTime(tonumber(vehicle))
        local condition = timetable.getConditions(currentLine, currentStop, "debounce")
        if not condition[1] then condition[1] = 0 end
        if not condition[2] then condition[2] = 0 end
        if time > previousDepartureTime + ((condition[1] * 60)  + condition[2]) then
            currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting = {}
            return false
        else
            return true
        end
    else
        currentlyWaiting[currentLineString].stations[currentStop].currentlyWaiting = {}
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

--- Start all vehicles of given line.
---@param line table line id
function timetable.startAllLineVehicles(line)
    for _, vehicle in pairs(timetableHelper.getVehiclesOnLine(line)) do
        if timetableHelper.isInStation(vehicle) then
            local currentLine = tostring(timetableHelper.getCurrentLine(vehicle))
            local currentStop = timetableHelper.getCurrentStation(vehicle)
            if currentlyWaiting[currentLine] and currentlyWaiting[currentLine].stations[currentStop] then
                currentlyWaiting[currentLine].stations[currentStop].currentlyWaiting = {}
            end
            timetableHelper.startVehicle(vehicle)
        end
    end
end


-------------- UTILS FUNCTIONS ----------

-- This function returns true if the train is before its departure time
---@param constraint table in format like: {9,0,59,0}
---@param time number in seconds
---@param allConstraints number table in format like: {{30,0,59,0},{9,0,59,0},...}
function timetable.beforeDepature(constraint, time, allConstraints)
    local arrivalTimeSec = (60 * constraint[3]) + constraint[4]
    local departureTimeSec = (60 * constraint[3]) + constraint[4]
    local normalisedTime = time % (60 * 60)
    local nextArrivalTime = (timetable.getTimeUntilNextConstraint(constraint, allConstraints) + arrivalTimeSec) % (60 * 60)
    --print( normalisedTime/60, departureTimeSec/60, nextArrivalTime/60)
    return not (((normalisedTime > departureTimeSec) == (normalisedTime < nextArrivalTime)) ~= (departureTimeSec > nextArrivalTime))
end

-- This function calcualtes the time from a given constraint to its closest next constraint
---@param constraint table in format like: {9,0,59,0}
---@param allConstraints number table in format like: {{30,0,59,0},{9,0,59,0},...}
---@return number timeUntilNextContraint: {30,0,59,0}
function timetable.getTimeUntilNextConstraint(constraint, allConstraints)
    local res = 60*60
    local constraintSec =((constraint[1] * 60) + constraint[2])
    for _,v in pairs(allConstraints) do
        local toCheckSec = ((v[1] * 60) + v[2])
        if constraintSec > toCheckSec then
            toCheckSec =  toCheckSec + (60*60)
        end
        local difference = toCheckSec - constraintSec
        if difference > 0 and difference < res then
            res = difference
        end
    end
    return res
end

---Find the next valid constraint for given constraints and time
---@param constraints table in format like: {{30,0,59,0},{9,0,59,0}
---@param time number in seconds
---@return table closestConstraint example: {30,0,59,0}
function timetable.getNextConstraint(constraints, time)
    local res = {diff = 40000, value = nil}
    for _, constraint in pairs(constraints) do
        local arrMin = constraint[1]
        local arrSec = constraint[2]
        local arrTime = arrMin * 60 + arrSec

        local diff = timetable.getTimeDifference(arrTime, time % 3600)
        if (diff < res.diff) then
            res = {diff = diff, value = constraint}
        end
    end

    return res.value
end

---Calculates the time difference between two timestamps in seconds.
---Considers that 59 mins is close to 0 mins.
---@param a number in seconds between in range of 0-3599 (inclusive)
---@param b number in seconds between in range of 0-3599 (inclusive)
---@return number
function timetable.getTimeDifference(a, b)
    local absDiff = math.abs(a - b)
    if absDiff > 1800 then
        return 3600 - absDiff
    else
        return absDiff
    end
end


return timetable

