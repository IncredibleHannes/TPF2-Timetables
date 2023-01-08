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
}

conditions = {
    type = "None"| "ArrDep" | "minWait" | "debounce" | "moreFancey"
    ArrDep = {}
    minWait = {}
    debaunce  = {}
    moreFancey = {}
}

ArrDep = {
    [1] = 12 -- arrival minute
    [2] = 30 -- arrival second
    [3] = 15 -- departure minute
    [4] = 00 -- departure second
}
--]]

--[[
currentlyWaiting = {
    line = {
        station = {
            vehiclesWaiting = { vehicleWaitingInfo }
            vehiclesDeparting = { vehicleDepartingInfo }
        }
    }
}

vehicleWaitingInfo = {
    arrivalTime = 1 :: int
    constraint = {}
    type = "ArrDep"
}

vehicleDepartingInfo = {
    outboundTime = 1 :: int
}
]]

--[[
vehiclesWaiting = {
    vehicleId = {
        outboundTime - time the train should leave the station
    }
}
]]

local timetable = { }
local timetableObject = { }
local vehiclesWaiting = { }


function timetable.getTimetableObject()
    return timetableObject
end

function timetable.setTimetableObject(t)
    if t then
        timetableObject = t
    end
end

function timetable.setConditionType(line, stationNumber, type)
    local stationID = timetableHelper.getStationID(line, stationNumber)
    if not(line and stationNumber) then return -1 end
    if timetableObject[line] and timetableObject[line].stations[stationNumber] then
        timetableObject[line].stations[stationNumber].conditions.type = type
        local conditionObject = timetableObject[line].stations[stationNumber].conditions[type]
        if not conditionObject then  timetableObject[line].stations[stationNumber].conditions[type] = {} end
        timetableObject[line].stations[stationNumber].stationID = stationID
    else
        if not timetableObject[line] then
            timetableObject[line] = { hasTimetable = false, stations = {}}
        end

        timetableObject[line].stations[stationNumber] = {
            stationID = stationID,
            conditions = {type = type}
        }
        local conditionObject = timetableObject[line].stations[stationNumber].conditions[type]
        if not conditionObject then  timetableObject[line].stations[stationNumber].conditions[type] = {} end
    end
end

function timetable.getConditionType(line, stationNumber)
    if not(line and stationNumber) then return "ERROR" end
    if timetableObject[line] and timetableObject[line].stations[stationNumber] then
        if timetableObject[line].stations[stationNumber].conditions.type then
            return timetableObject[line].stations[stationNumber].conditions.type
        else
            timetableObject[line].stations[stationNumber].conditions.type = "None"
            return "None"
        end
    else
        return "None"
    end
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
    if timetableObject[line]
       and timetableObject[line].stations[stationNumber]
       and timetableObject[line].stations[stationNumber].conditions[type] then
        return timetableObject[line].stations[stationNumber].conditions[type]
    else
        return -1
    end
end


-- TEST: timetable.addCondition(1,1,{type = "ArrDep", ArrDep = {{12,14,14,14}}})
function timetable.addCondition(line, stationNumber, condition)
    local stationID = timetableHelper.getStationID(line, stationNumber)
    if not(line and stationNumber and condition) then return -1 end

    if timetableObject[line] and timetableObject[line].stations[stationNumber] then
        if condition.type == "ArrDep" then
            timetable.setConditionType(line, stationNumber, condition.type)
            local arrDepCond = timetableObject[line].stations[stationNumber].conditions.ArrDep
            local mergedArrays = timetableHelper.mergeArray(arrDepCond, condition.ArrDep)
            timetableObject[line].stations[stationNumber].conditions.ArrDep = mergedArrays
        elseif condition.type == "minWait" then
            timetableObject[line].stations[stationNumber].conditions.type = "minWait"
            timetableObject[line].stations[stationNumber].conditions.minWait = condition.minWait
        elseif condition.type == "debounce" then
            timetableObject[line].stations[stationNumber].conditions.type = "debounce"
            timetableObject[line].stations[stationNumber].conditions.debounce = condition.debounce
        elseif condition.type == "moreFancey" then
            timetableObject[line].stations[stationNumber].conditions.type = "moreFancey"
            timetableObject[line].stations[stationNumber].conditions.moreFancey = condition.moreFancey
        end
        timetableObject[line].stations[stationNumber].stationID = stationID

    else
        if not timetableObject[line] then
            timetableObject[line] = {hasTimetable = false, stations = {}}
        end
        timetableObject[line].stations[stationNumber] = {
            stationID = stationID,
            conditions = condition
        }
    end
end

function timetable.updateArrDep(line, station, indexKey, indexValue, value)
    if not (line and station and indexKey and indexValue and value) then return -1 end
    if timetableObject[line] and
       timetableObject[line].stations[station] and
       timetableObject[line].stations[station].conditions and
       timetableObject[line].stations[station].conditions.ArrDep and
       timetableObject[line].stations[station].conditions.ArrDep[indexKey] and
       timetableObject[line].stations[station].conditions.ArrDep[indexKey][indexValue] then
       timetableObject[line].stations[station].conditions.ArrDep[indexKey][indexValue] = value
        return 0
    else
        return -2
    end
end

function timetable.updateDebounce(line, station, indexKey, value)
    if not (line and station and indexKey and value) then return -1 end
    if timetableObject[line] and
       timetableObject[line].stations[station] and
       timetableObject[line].stations[station].conditions and
       timetableObject[line].stations[station].conditions.debounce then
       timetableObject[line].stations[station].conditions.debounce[indexKey] = value
        return 0
    else
        return -2
    end
end

function timetable.removeCondition(line, station, type, index)
    if not(line and station and index) or (not (timetableObject[line]
       and timetableObject[line].stations[station])) then
        return -1
    end

    if type == "ArrDep" then
        local tmpTable = timetableObject[line].stations[station].conditions.ArrDep
        if tmpTable and tmpTable[index] then return table.remove(tmpTable, index) end
    else
        -- just remove the whole condition
        local tmpTable = timetableObject[line].stations[station].conditions[type]
        if tmpTable and tmpTable[index] then timetableObject[line].stations[station].conditions[type] = {} end
        return 0
    end
    return -1
end

function timetable.hasTimetable(line)
    if timetableObject[line] then
        return timetableObject[line].hasTimetable
    else
        return false
    end
end

function timetable.updateFor(line, vehicles)
        if timetable.hasTimetable(line) then
            for _, vehicle in pairs(vehicles) do
                updateFor(vehicle, vehicles, line)
            end
        else
            timetable.restartAutoDepartureForAllLineVehicles(line)
        end
end

function timetable.updateForVehicle(vehicle, line, vehicles)
    local vehicleInfo = api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
    if not vehicleInfo then return end

    -- if vehicle in terminal
    if vehicleInfo.state == api.type.enum.TransportVehicleState.AT_TERMINAL then
        local stop = vehicleInfo.stopIndex + 1

        if timetable.LineAndStationHasTimetable(line, stop) then
            if vehicleInfo.autoDeparture then
                local arrivalTime = vehicleInfo.doorsTime / 1000000
                if timetable.readyToDepart(vehicle, arrivalTime, vehicles, line, stop) then
                    timetableHelper.departVehicle(vehicle)
                end
            else
                timetableHelper.stopAutoVehicleDeparture(vehicle)
            end
        else
            if not vehicleInfo.autoDeparture then
                timetableHelper.restartAutoVehicleDeparture(vehicle)
            end
        end

    else
        if not vehicleInfo.autoDeparture then
            timetableHelper.restartAutoVehicleDeparture(vehicle)
        end
    end
end

function timetable.LineAndStationHasTimetable(line, stop)
    if not timetableObject[line].stations[stop] then return false end
    if not timetableObject[line].stations[stop].conditions then return false end
    if not timetableObject[line].stations[stop].conditions.type then return false end
    return not (timetableObject[line].stations[stop].conditions.type == "None")
end

function timetable.readyToDepart(vehicle, arrivalTime, vehicles, line, stop)
    local time = timetableHelper.getTime()
    if not timetableObject[line] then return true end
    if not timetableObject[line].stations then return true end
    if not timetableObject[line].stations[stop] then return true end
    if not timetableObject[line].stations[stop].conditions then return true end
    if not timetableObject[line].stations[stop].conditions.type then return true end

    if timetableObject[line].stations[stop].conditions.type == "ArrDep" then
        -- am I currently waiting or just arrived?

        local constraints = timetableObject[line].stations[stop].conditions.ArrDep
        local constraint = timetable.getNextConstraint(constraints, arrivalTime, {})
        if not constraint then return true end

        if timetable.beforeDeparture(arrivalTime, constraint, time) then
            return false
        end

        return true

    --------------------------------------------------------------------------------------------------------------------
    --------------------------------------- DEBOUNCE / UNBUNCH ---------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------
    elseif timetableObject[line].stations[stop].conditions.type == "debounce" then
        local previousDepartureTime = timetableHelper.getPreviousDepartureTime(stop, vehicles)
        local condition = timetable.getConditions(currentLine, currentStop, "debounce")
        if not condition[1] then condition[1] = 0 end
        if not condition[2] then condition[2] = 0 end
        local nextDepartureTime = previousDepartureTime + ((condition[1] * 60)  + condition[2])
        if time > nextDepartureTime then
            return true
        else
            return false
        end
    end
        
    return true
end

function timetable.setHasTimetable(line, bool)
    if timetableObject[line] then
        timetableObject[line].hasTimetable = bool
    else
        timetableObject[line] = {stations = {} , hasTimetable = bool}
    end
    return bool
end

--- Start all vehicles of given line.
---@param line table line id
function timetable.restartAutoDepartureForAllLineVehicles(line)
    for _, vehicle in pairs(timetableHelper.getVehiclesOnLine(line)) do
        timetableHelper.restartAutoVehicleDeparture(vehicle)
    end
end


-------------- UTILS FUNCTIONS ----------

--- This function returns true if the train is before its departure time and after its arrival time
---@param arrivalTime number in seconds
---@param constraint table in format like: {9,0,59,0}
---@param currentTime number in seconds
function timetable.beforeDeparture(arrivalTime, constraint, currentTime)
    arrivalTime = arrivalTime % 3600
    currentTime = currentTime % 3600
    local departureTime = (60 * constraint[3]) + constraint[4]
    if arrivalTime < departureTime then
        -- Eg. the arrival time is 10:00 and the departure is 12:00
        return arrivalTime <= currentTime and currentTime < departureTime
    else
        -- Eg. the arrival time is 59:00 and the departure is 01:00
        return arrivalTime <= currentTime or currentTime < departureTime
    end
end

--- This function calcualtes the time from a given constraint to its closest next constraint
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
---@param constraints table in format like: {{30,0,59,0},{9,0,59,0}}
---@param time number in seconds
---@param used_constraints table in format like: {constraint={30,0,59,0},constraint={9,0,59,0}}
---@return table closestConstraint example: {30,0,59,0}
function timetable.getNextConstraint(constraints, time, used_constraints)
    -- Put the constraints in chronological order by arrival time
    table.sort(constraints, function(a, b)
        local aTime = timetable.getArrivalTimeFrom(a)
        local bTime = timetable.getArrivalTimeFrom(b)
        return aTime < bTime
    end)

    -- Find the distance from the arrival time
    local res = {diff = 40000, value = nil}
    for index, constraint in pairs(constraints) do
        local arrTime = timetable.getArrivalTimeFrom(constraint)
        local diff = timetable.getTimeDifference(arrTime, time % 3600)

        if (diff < res.diff) then
            res = {diff = diff, index = index}
        end
    end

    -- Return nil when there are no contraints
    if not res.index then return nil end

    -- Find if the constraint with the closest arrival time is currently being used
    -- If true, find the next consecutive available constraint
    for i = res.index, #constraints + res.index - 1 do
        -- Need to make sure that 2 mod 2 returns 2 rather than 0
        local normalisedIndex = ((i - 1) % #constraints) + 1

        local constraint = constraints[normalisedIndex]
        local found = false
        for _, used_constraint in pairs(used_constraints) do
            if constraint == used_constraint.constraint then
                found = true
            end
        end

        if not found then
            return constraint
        end
    end

    -- If all constraints are being used, still return the closest constraint anyway.
    return constraints[res.index]
end

---Gets the arrival time in seconds from the constraint
---@param constraint table in format like: {9,0,59,0}
function timetable.getArrivalTimeFrom(constraint)
    local arrMin = constraint[1]
    local arrSec = constraint[2]
    return arrMin * 60 + arrSec
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

