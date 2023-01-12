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

--[[
stopState = {
    "format" = 3,
    "data" = {
        [line] = {
            [stop] = {
                "lastArrival" = 1234,
                "lastDeparture" = 1234,
                "lastVehicle" = 1234,
                "plannedDeparture" = 1234|nil
            }
        }
    }
}
]]

-- flatten a table into a string for printing
-- adapted from https://stackoverflow.com/a/27028488
local function dump(o, depth)
    if not depth then depth = 0 end

    if type(o) == 'table' then
        local s = '{\n'
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. string.rep('    ', depth + 1) .. '['..k..'] = ' .. dump(v, depth + 1)
        end
        return s .. string.rep('    ', depth) .. '}\n'
    else
        return tostring(o) .. "\n"
    end
end

local timetable = { }
local timetableObject = { }
local stopState = { }


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

function timetable.getStopState()
    return stopState
end

function timetable.setStopState(ttData)
    local currentVersion = 3
    local fallback = {
        format = currentVersion,
        data = { }
    }

    if ttData and next(ttData) then
        -- ensure saved data conforms to currently expected format
        if not ttData.format or ttData.format ~= currentVersion then
            print("stopState: format version mismatch, rejecting loaded state")
            ttData = {format = currentVersion}
        end

        stopState = ttData
    else
        stopState = fallback
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
            inboundTime = 0,
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

-- gets the constraints for a specific station
function timetable.getConstraintsForStation(stationID)
    local constraintsByStation = timetable.getConstraintsByStation()

    if constraintsByStation[stationID] then
        return constraintsByStation[stationID]
    else
        return {}
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
        elseif condition.type == "minWait" then
            timetableObject[line].stations[stationNumber].conditions.type = "minWait"
            timetableObject[line].stations[stationNumber].conditions.minWait = condition.minWait
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
            inboundTime = 0,
            stationID = stationID,
            conditions = condition
        }
    end
end

function timetable.updateArrDep(line, stopNr, indexKey, indexValue, value)
    if not (line and stopNr and indexKey and indexValue and value) then return -1 end
    if timetableObject[line] and
       timetableObject[line].stations[stopNr] and
       timetableObject[line].stations[stopNr].conditions and
       timetableObject[line].stations[stopNr].conditions.ArrDep and
       timetableObject[line].stations[stopNr].conditions.ArrDep[indexKey] and
       timetableObject[line].stations[stopNr].conditions.ArrDep[indexKey][indexValue] then

        timetableObject[line].stations[stopNr].conditions.ArrDep[indexKey][indexValue] = value
        
        -- update departure for all waiting vehicles on that stop
        local stopInfo = stopState.data[line][stopNr]
        if stopInfo.plannedDeparture then
            timetable.planArrDep(line, stopNr, stopInfo.lastVehicle, stopInfo.lastArrival)
        end

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


function timetable.planArrDep(line, stop, vehicle, arrivalTime)
    -- get the departure time from the condition
    local constraints = timetableObject[line].stations[stop].conditions.ArrDep
    local stopInfo = stopState.data[line][stop]
    local departureTime = timetable.getNextDeparture(constraints, arrivalTime, stopInfo.lastDeparture)

    -- register vehicle with departure time
    stopInfo.lastArrival = arrivalTime
    stopInfo.plannedDeparture = departureTime
end


function timetable.planUnbunch(line, stop, vehicle, arrivalTime)
    -- get last departure time and minimum interval
    local condition = timetable.getConditions(line, stop, "debounce")
    local stopInfo = stopState.data[line][stop]
    local interval = condition[1] * 60 + condition[2]
    -- for auto_debounce, use timetableObject[currentLine].interval - constraint[1] * 60 - constraint[2]
    local lastDeparture = stopInfo.lastDeparture

    -- calculate next departure time
    local departureTime = lastDeparture + interval

    -- register vehicle with departure time
    stopInfo.lastArrival = arrivalTime
    stopInfo.plannedDeparture = departureTime
end


function timetable.waitingRequired(vehicle)
    -- get data about the vehicle from the game api
    local time = timetableHelper.getTime()
    local currentLine = timetableHelper.getCurrentLine(vehicle)
    local currentStop = timetableHelper.getCurrentStation(vehicle)

    -- check if there is a timetable condition for this vehicle and stop
    if not timetableObject[currentLine] then return false end
    if not timetableObject[currentLine].stations then return false end
    if not timetableObject[currentLine].stations[currentStop] then return false end
    if not timetableObject[currentLine].stations[currentStop].conditions then return false end
    if not timetableObject[currentLine].stations[currentStop].conditions.type then return false end

    -- initialize table of waiting vehicles if required
    if not stopState.data[currentLine] then
        stopState.data[currentLine] = {}
    end
    if not stopState.data[currentLine][currentStop] then
        stopState.data[currentLine][currentStop] = {}
    end

    local stopInfo = stopState.data[currentLine][currentStop]

    if not stopInfo.lastDeparture then
        -- initialize last departure to 30 minutes before now 
        -- TODO: ideally that offset would depend on the interval of the timetable 
        stopInfo.lastDeparture = time - 1800
    end


    -- check if the vehicle just arrived at the station and has a timetable
    -- in that case, no departure time is planned
    -- to avoid recapturing departing vehicles, do not check for new arrivals within 3 seconds after the last departure
    if  timetableObject[currentLine].hasTimetable
        and not stopInfo.plannedDeparture
        and time - stopInfo.lastDeparture > 3 then

        -- set departure time if condition is set
        if timetableObject[currentLine].stations[currentStop].conditions.type == "ArrDep" then
            timetable.planArrDep(currentLine, currentStop, vehicle, time)

        elseif timetableObject[currentLine].stations[currentStop].conditions.type == "debounce" then
            timetable.planUnbunch(currentLine, currentStop, vehicle, time)

        end

        if stopInfo.plannedDeparture then
            stopInfo.lastVehicle = vehicle

            print(  "vehicle " .. vehicle .. " will depart at " ..
                    timetable.secToStr(stopInfo.plannedDeparture) ..
                    " (in " ..
                    math.floor((stopInfo.plannedDeparture - time) / 6) / 10
                    .. " min) " .. " from station " .. currentStop .. " on line " .. currentLine .. " with type " ..
                    timetableObject[currentLine].stations[currentStop].conditions.type)
        end
    end

    -- if there are any constraints on departure time, they are now set
    -- now they need to be executed
    -- check if the vehicle is waiting for a departure time
    if stopInfo.plannedDeparture then
        -- check if the departure time has been reached or the timetable has been disable in the meantime
        if  (stopInfo.plannedDeparture <= time
            and timetableHelper.getTimeUntilDepartureReady(vehicle) < 1)
            or not timetableObject[currentLine].hasTimetable then
            -- departure time has been reached
            -- remove vehicle from waiting list
            stopInfo.plannedDeparture = nil

            -- update last departure time
            stopInfo.lastDeparture = time

            -- return false to indicate that the vehicle can depart
            print("vehicle " .. vehicle .. " departing")
            return false
        else
            -- departure time has not been reached yet
            -- return true to indicate that the vehicle has to wait
            return true
        end
    else
        -- no constraints exist
        -- return false to indicate that the vehicle can depart
        return false
    end
end

function timetable.setHasTimetable(line, bool)
    if timetableObject[line] then
        timetableObject[line].hasTimetable = bool
    else
        timetableObject[line] = {stations = {} , hasTimetable = bool}
    end

    print("setting hasTimetable for line " .. line .. " to " .. tostring(bool))

    return bool
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

    -- print("arrivalTime: " .. arrivalTime)
    -- print("currentTime: " .. currentTime)
    -- print("departureTime: " .. departureTime)

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
---@param time number in seconds game time
---@param lastDeparture number in seconds game time 
---@return number nextDeparture example: {30,0,59,0}
function timetable.getNextDeparture(constraints, time, lastDeparture)
    -- Sort the constraints by departure time
    table.sort(constraints, function(a, b)
        local aTime = timetable.constraintToSeconds(a).dep
        local bTime = timetable.constraintToSeconds(b).dep
        return aTime < bTime
    end)

    local hourStart = time - (time % 3600)
    local hourCount = 0
    local departureIndex = 1

    local lastValid = nil


    local function constraintToAbsTime(constraint)
        local function calcAbsTime(relTime)
            return hourStart + hourCount * 3600 + relTime
        end

        local constraintRelSec = timetable.constraintToSeconds(constraint)

        local constraintAbsSec = {}
        for key, relTime in pairs(constraintRelSec) do
            constraintAbsSec[key] = calcAbsTime(relTime)
        end

        if constraintAbsSec.arr > constraintAbsSec.dep then
            constraintAbsSec.arr = constraintAbsSec.arr - 3600
        end

        return constraintAbsSec
    end
    
    -- go through all constraints until we find an answer
    while hourCount < 5 do
        while departureIndex <= #constraints do
            -- calculate the absolute time of this slot
            local constraintAbsTime = constraintToAbsTime(constraints[departureIndex])

            -- check if the slot satisfies these conditions:
            -- 1. the departure time is after the last recorded departure
            -- 2. the arrival time in the past OR it is the first slot after the last recorded departure
            constraintValid =   constraintAbsTime.dep > lastDeparture 
                                and (constraintAbsTime.arr <= time or lastValid == nil)
            
            
            -- at first we will not satisfy the first conditionToString, because we are before the last departure
            -- then we will satisfy both for a while
            -- finally we will not satisfy the second condition, because we are before the arrival time
            -- -> when we get invalid answers after valid ones, we can return the last valid answer
            if constraintValid then
                lastValid = constraintAbsTime.dep
            else 
                if lastValid ~= nil then
                    return lastValid
                end
            end
            
            --increment the departure index
            departureIndex = departureIndex + 1
        end

        -- increment the hour count
        hourCount = hourCount + 1
        departureIndex = 1
    end

    -- if we get here, we have not found a valid answer withing the next 5 hours
    -- since the timetable should repeat at least hourly, we can assume that there is no valid time slot
    return -1
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
    local sec = sec % 60
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
        end
    end
end

function timetable.dumpStopState(lineID, stopNr)
    if not stopState.data then return "data block not initialized" end
    if not stopState.data[lineID] then return "lineID " .. lineID .. " of type " .. type(lineID) .. " not found \n" .. timetable.secToStr(timetableHelper.getTime()) end
    if not stopState.data[lineID][stopNr] then return "stopNr " .. stopNr .. " not found" end

    return "lineID: " .. lineID .. ", stopNr:" .. stopNr .. "\n" .. dump(stopState.data[lineID][stopNr])
end

function timetable.getStateOfStop(lineID, stopNr)
    if not stopState.data then return end
    if not stopState.data[lineID] then return end
    if not stopState.data[lineID][stopNr] then return end

    return stopState.data[lineID][stopNr]
end

return timetable

