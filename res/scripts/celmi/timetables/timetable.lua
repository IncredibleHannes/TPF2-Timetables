local timetableHelper = require "celmi/timetables/timetable_helper"

--[[
timetable = {
    line = {
        stations = { stationinfo }
        hasTimetable = true
        frequency = 1 :: int
    }
}

stationInfo = {
    conditions = {condition :: Condition},
    vehiclesWaiting = {
        vehicleNumber = {
            constraint
        }
    }
}

conditions = {
    type = "None"| "ArrDep" | "debounce" | "moreFancey"
    ArrDep = {}
    debounce  = {}
    moreFancey = {}
}

ArrDep = {
    [1] = 12 -- arrival minute
    [2] = 30 -- arrival second
    [3] = 15 -- departure minute
    [4] = 00 -- departure second
}
--]]

local timetable = { }
local timetableObject = { }


function timetable.getTimetableObject()
    return timetableObject
end

function timetable.setTimetableObject(t)
    if t then
        -- make sure the line is a number
        local keysToPatch = { }
        for lineID, lineInfo in pairs(t) do
            if type(lineID) == "string" then
                table.insert(keysToPatch, lineID)
            end
        end

        for _, lineID in pairs(keysToPatch) do
            print("timetable: patching lineID: " .. lineID .. " to be a number")
            local lineInfo = t[lineID]
            t[lineID] = nil
            t[tonumber(lineID)] = lineInfo
        end

        timetableObject = t
        -- print("timetable after loading and processing:")
        -- print(dump(timetableObject))
    end
end

function timetable.setConditionType(line, stationNumber, type)
    local stationID = timetableHelper.getStationID(line, stationNumber)
    if not(line and stationNumber) then return -1 end

    if not timetableObject[line] then
        timetableObject[line] = { hasTimetable = false, stations = {} }
    end
    if not timetableObject[line].stations[stationNumber] then
        timetableObject[line].stations[stationNumber] = { stationID = stationID, conditions = {} }
    end

    local stopInfo = timetableObject[line].stations[stationNumber]
    stopInfo.conditions.type = type

    if not stopInfo.conditions[type] then 
        stopInfo.conditions[type] = {}
    end
    
    if type == "ArrDep" then
        if not stopInfo.vehiclesWaiting then
            stopInfo.vehiclesWaiting = {}
        end
    else
        stopInfo.vehiclesWaiting = nil
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

-- reorders the constraints into the structure res[stationID][lineID][stopNr] = 
-- only returns stations that have constraints
function timetable.getConstraintsByStation()
    local res = { }
    for lineID, lineInfo in pairs(timetableObject) do
        for stopNr, stopInfo in pairs(lineInfo.stations) do
            if stopInfo.stationID and stopInfo.conditions and  stopInfo.conditions.type and not (stopInfo.conditions.type == "None")  then
                if not res[stopInfo.stationID] then res[stopInfo.stationID] = {} end
                if not res[stopInfo.stationID][lineID] then res[stopInfo.stationID][lineID] = {} end
                res[stopInfo.stationID][lineID][stopNr] = stopInfo
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
    if timetableObject[line]
       and timetableObject[line].stations[stationNumber]
       and timetableObject[line].stations[stationNumber].conditions[type] then
        return timetableObject[line].stations[stationNumber].conditions[type]
    else
        return -1
    end
end

function timetable.addFrequency(line, frequency)
    if not timetableObject[line] then return end
    timetableObject[line].frequency = frequency
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
        elseif condition.type == "debounce" then
            timetableObject[line].stations[stationNumber].conditions.type = "debounce"
            timetableObject[line].stations[stationNumber].conditions.debounce = condition.debounce
        elseif condition.type == "auto_debounce" then
            timetableObject[line].stations[stationNumber].conditions.type = "auto_debounce"
            timetableObject[line].stations[stationNumber].conditions.auto_debounce = condition.auto_debounce
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

function timetable.updateDebounce(line, station, indexKey, value, debounceType)
    if not (line and station and indexKey and value) then return -1 end
    if timetableObject[line] and
       timetableObject[line].stations[station] and
       timetableObject[line].stations[station].conditions and
       timetableObject[line].stations[station].conditions[debounceType] then
       timetableObject[line].stations[station].conditions[debounceType][indexKey] = value
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
    for _, vehicle in pairs(vehicles) do
        local vehicleInfo = timetableHelper.getVehicleInfo(vehicle)
        if vehicleInfo then
            if timetable.hasTimetable(line) then
                timetable.updateForVehicle(vehicle, vehicleInfo, line, vehicles)
            elseif not vehicleInfo.autoDeparture then
                timetableHelper.restartAutoVehicleDeparture(vehicle)
            end
        end
    end
end

function timetable.updateForVehicle(vehicle, vehicleInfo, line, vehicles)
    if timetableHelper.isVehicleAtTerminal(vehicleInfo) then
        local stop = vehicleInfo.stopIndex + 1

        if timetable.LineAndStationHasTimetable(line, stop) then
            timetable.departIfReady(vehicle, vehicleInfo, vehicles, line, stop)
        elseif not vehicleInfo.autoDeparture then
            timetableHelper.restartAutoVehicleDeparture(vehicle)
        end

    elseif not vehicleInfo.autoDeparture then
        timetableHelper.restartAutoVehicleDeparture(vehicle)
    end
end

function timetable.LineAndStationHasTimetable(line, stop)
    if not timetableObject[line].stations[stop] then return false end
    if not timetableObject[line].stations[stop].conditions then return false end
    if not timetableObject[line].stations[stop].conditions.type then return false end
    return not (timetableObject[line].stations[stop].conditions.type == "None")
end

function timetable.departIfReady(vehicle, vehicleInfo, vehicles, line, stop)
    if not timetableObject[line] then return end
    if not timetableObject[line].stations then return end
    if not timetableObject[line].stations[stop] then return end
    if not timetableObject[line].stations[stop].conditions then return end
    if not timetableObject[line].stations[stop].conditions.type then return end
    local time = timetableHelper.getTime()

    local conditionType = timetableObject[line].stations[stop].conditions.type
    if conditionType == "ArrDep" then
        timetable.departIfReadyArrDep(vehicle, vehicleInfo, time, line, stop)
    elseif conditionType == "debounce" then
        timetable.departIfReadyDebounce(vehicle, vehicleInfo, vehicles, time, line, stop)
    elseif conditionType == "auto_debounce" then
        timetable.departIfReadyAutoDebounce(vehicle, vehicleInfo, vehicles, time, line, stop)
    end
end

function timetable.departIfReadyArrDep(vehicle, vehicleInfo, time, line, stop)
    local constraints = timetableObject[line].stations[stop].conditions.ArrDep
    if not constraints or contraints == {} then
        timetableObject[line].stations[stop].conditions.type = "None"
        return
    end

    if vehicleInfo.autoDeparture then
        timetableHelper.stopAutoVehicleDeparture(vehicle)
    else
        if not vehicleInfo.doorsOpen then return end

        local arrivalTime = math.floor(vehicleInfo.doorsTime / 1000000)
        if timetable.readyToDepartArrDep(constraints, arrivalTime, time, line, stop, vehicle) then
            timetableHelper.departVehicle(vehicle)
            timetableObject[line].stations[stop].vehiclesWaiting[vehicle] = nil
        end
    end
end

function timetable.readyToDepartArrDep(constraints, arrivalTime, time, line, stop, vehicle)
    if not timetableObject[line].stations[stop].vehiclesWaiting then
        timetableObject[line].stations[stop].vehiclesWaiting = {}
    end

    local vehiclesWaiting = timetableObject[line].stations[stop].vehiclesWaiting
    local departureConstraint = nil
    local validDepartureConstraint = nil
    if vehiclesWaiting[vehicle] then
        departureConstraint = vehiclesWaiting[vehicle]
        validDepartureConstraint = timetable.arrayContainsConstraint(departureConstraint, constraints)
    end
    if not validDepartureConstraint then
        departureConstraint = timetable.getNextDepartureConstraint(constraints, arrivalTime, vehiclesWaiting)
        vehiclesWaiting[vehicle] = departureConstraint
    end


    local lineInfo = timetableHelper.getLineInfo(line)
    local stopInfo = lineInfo.stops[stop]

    if timetable.afterDepartureConstraint(arrivalTime, departureConstraint, time) then
        if timetable.getMinWaitEnabled(line) then
            return timetable.waitedMinimumTime(stopInfo, arrivalTime, time)
        else
            return true
        end
    else
        if timetable.getMaxWaitEnabled(line) then
            return timetable.waitedMaximumTime(stopInfo, arrivalTime, time)
        else
            return false
        end
    end
end

function timetable.setMinWaitEnabled(line, value)
    if timetableObject[line] then
        timetableObject[line].minWaitEnabled = value
    end
end

function timetable.getMinWaitEnabled(line)
    if timetableObject[line] then
        -- if true or nil
        if timetableObject[line].minWaitEnabled ~= false then
            return true
        end
    end

    return false
end

function timetable.setMaxWaitEnabled(line, value)
    if timetableObject[line] then
        timetableObject[line].maxWaitEnabled = value
    end
end

function timetable.getMaxWaitEnabled(line)
    if timetableObject[line] then
        -- if true
        if timetableObject[line].maxWaitEnabled then
            return true
        end
    end

    return false
end

function timetable.waitedMinimumTime(stopInfo, arrivalTime, time)
    local wait = stopInfo.minWaitingTime

    local departureTime = arrivalTime + wait
    return timetable.afterDepartureTime(arrivalTime, departureTime, time)
end

function timetable.waitedMaximumTime(stopInfo, arrivalTime, time)
    local wait = stopInfo.maxWaitingTime
    if wait == -1 then return false end

    local departureTime = arrivalTime + wait
    return timetable.afterDepartureTime(arrivalTime, departureTime, time)
end

function timetable.departIfReadyDebounce(vehicle, vehicleInfo, vehicles, time, line, stop)
    if not vehicleInfo.doorsOpen then return end
    if vehicleInfo.timeUntilCloseDoors >= 3 then return end
    if timetable.anotherVehicleArrivedEarlier(vehicle, vehicleInfo, line, stop) then return end

    local previousDepartureTime = timetableHelper.getPreviousDepartureTime(stop, vehicles)
    local condition = timetable.getConditions(line, stop, "debounce")
    if not condition[1] then condition[1] = 0 end
    if not condition[2] then condition[2] = 0 end

    local nextDepartureTime = previousDepartureTime + ((condition[1] * 60)  + condition[2])
    timetable.departIfAfterDepartureTime(vehicle, vehicleInfo, time, nextDepartureTime)
end

function timetable.departIfReadyAutoDebounce(vehicle, vehicleInfo, vehicles, time, line, stop)
    if not vehicleInfo.doorsOpen then return end
    if vehicleInfo.timeUntilCloseDoors >= 3 then return end
    if #timetableHelper.getVehiclesOnLine(line) == 1 then
        if not vehicleInfo.autoDeparture then
            timetableHelper.restartAutoVehicleDeparture(vehicle)
        end
    end

    if timetable.anotherVehicleArrivedEarlier(vehicle, vehicleInfo, line, stop) then return end

    local previousDepartureTime = timetableHelper.getPreviousDepartureTime(stop, vehicles)
    local frequency = timetableObject[line].frequency
    if not frequency then return end

    local condition = timetable.getConditions(line, stop, "auto_debounce")
    if not condition[1] then condition[1] = 1 end
    if not condition[2] then condition[2] = 0 end
    local nextDepartureTime = previousDepartureTime + frequency - (condition[1]*60 + condition[2])

    timetable.departIfAfterDepartureTime(vehicle, vehicleInfo, time, nextDepartureTime)
end

-- Account for vehicles currently waiting or departing
function timetable.anotherVehicleArrivedEarlier(vehicle, vehicleInfo, line, stop)
    local vehiclesAtStop = timetableHelper.getVehiclesAtStop(line, stop)
    if #vehiclesAtStop <= 1 then return false end
    for _, otherVehicle in pairs(vehiclesAtStop) do
        if otherVehicle ~= vehicle then
            local otherVehicleInfo = timetableHelper.getVehicleInfo(otherVehicle)
            if otherVehicleInfo.doorsOpen then
                return otherVehicleInfo.doorsTime < vehicleInfo.doorsTime
            else
                return true
            end
        end
    end

    return false
end

function timetable.departIfAfterDepartureTime(vehicle, vehicleInfo, time, departureTime)
    if time > departureTime then
        if not vehicleInfo.autoDeparture then
            timetableHelper.restartAutoVehicleDeparture(vehicle)
        end
    else
        if vehicleInfo.autoDeparture then
            timetableHelper.stopAutoVehicleDeparture(vehicle)
        end
    end
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
function timetable.afterDepartureConstraint(arrivalTime, constraint, currentTime)
    arrivalTime = arrivalTime % 3600
    currentTime = currentTime % 3600

    local departureTime = (60 * constraint[3]) + constraint[4]
    return timetable.afterDepartureTime(arrivalTime, departureTime, currentTime)
end

function timetable.afterDepartureTime(arrivalTime, departureTime, currentTime)
    if arrivalTime <= departureTime then
        -- Eg. the arrival time is 10:00 and the departure is 12:00
        return arrivalTime > currentTime or currentTime >= departureTime
    else
        -- Eg. the arrival time is 59:00 and the departure is 01:00
        return arrivalTime > currentTime and currentTime >= departureTime
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
---@param usedConstraints table in format like: {{30,0,59,0}, {9,0,59,0}}
---@return table closestConstraint example: {30,0,59,0}
function timetable.getNextDepartureConstraint(constraints, time, usedConstraints)
    -- Put the constraints in chronological order by arrival time
    table.sort(constraints, function(a, b)
        local aTime = timetable.getArrivalTimeFrom(a)
        local bTime = timetable.getArrivalTimeFrom(b)
        return aTime < bTime
    end)

    -- Find the distance from the arrival time
    local res = {diff = 3601, value = nil}
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
        if not timetable.arrayContainsConstraint(constraint, usedConstraints) then
            return constraint
        end
    end

    -- If all constraints are being used, still return the closest constraint anyway.
    return constraints[res.index]
end

function timetable.arrayContainsConstraint(constraint, array)
    for key, item in pairs(array) do
        if item == constraint then
            return true
        elseif (
            item[1] == constraint[1] and 
            item[2] == constraint[2] and
            item[3] == constraint[3] and
            item[4] == constraint[4]
        ) then
            return true
        end
    end

    return false
end

function timetable.constraintToSeconds(constraint)
    local arrTime = timetable.minToSec(constraint[1], constraint[2])
    local depTime = timetable.minToSec(constraint[3], constraint[4])
    return {arr = arrTime, dep = depTime}
end

function timetable.minToSec(min, sec)
    return min * 60 + sec
end

function timetable.secToMin(sec)
    local min = math.floor(sec / 60) % 60
    local sec = math.floor(sec % 60)
    return min, sec
end

function timetable.minToStr(min, sec)
    return string.format("%02d:%02d", min, sec)
end

function timetable.secToStr(sec)
    local min, sec = timetable.secToMin(sec)
    return timetable.minToStr(min, sec)
end

function timetable.deltaSecToStr(deltaSec)
    return math.floor(deltaSec / 6) / 10
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

---Shifts a time in minutes and seconds by some offset
---Helper function for shiftConstraint() 
---@param time table in format like: {28,45}
---@param offset number in seconds 
---@return table shifted time, example: {30,0}
function timetable.shiftTime(time, offset)
    local timeSeconds = (time[1] * 60 + time[2] + offset) % 3600
    return {math.floor(timeSeconds / 60), timeSeconds % 60}
end


---Shifts a constraint by some offset
---@param constraint table in format like: {30,0,59,0}
---@param offset number in seconds 
---@return constraint table shifted time, example: {31,0,0,0}
function timetable.shiftConstraint(constraint, offset)
    local shiftArr = timetable.shiftTime({constraint[1], constraint[2]}, offset)
    local shiftDep = timetable.shiftTime({constraint[3], constraint[4]}, offset)
    return {shiftArr[1], shiftArr[2], shiftDep[1], shiftDep[2]}
end

-- removes old lines from timetable
function timetable.cleanTimetable()
    for lineID, _ in pairs(timetableObject) do
        if not timetableHelper.lineExists(lineID) then
            timetableObject[lineID] = nil
            print("removed line " .. lineID)
        else
            local stations = timetableHelper.getAllStations(lineID)
            for stationID = #stations + 1, #timetableObject[lineID].stations, 1 do
                timetableObject[lineID].stations[stationID] = nil
                print("removed station " .. stationID)
            end
        end
    end
end

return timetable

