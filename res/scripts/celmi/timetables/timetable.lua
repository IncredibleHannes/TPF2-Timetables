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
    [line] = {
        [stop] = {
            plannedDepartures = { 
                [vehicle] = departureTime 
            }
            lastDeparture = { vehicleDepartingInfo }
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

-- flatten a table into a string for printing
-- from https://stackoverflow.com/a/27028488
local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
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
        timetableObject = t
    end
end

function timetable.getStopState()
    return stopState
end

function timetable.setStopState(ttData)
    -- expected format
    --[[
    stopState = {
        [line] = {
            [stop] = {
                plannedDepartures = { 
                    [vehicle] = departureTime 
                }
                lastDeparture = departureTime
            }
        }
    }
    --]]
    if ttData then
        print("timetable data as loaded")
        print(dump(ttData)) -- debug

        -- ensure saved data conforms to currently expected format
        for line, lineData in pairs(ttData) do
            if not type(line) == "number" then
                ttData[line] = nil
            else
                for stop, stopData in pairs(lineData) do
                    if not type(stop) == "number" then
                        ttData[line][stop] = nil
                    else
                        for stopInfo, stopInfoData in pairs(stopData) do
                            if stopInfo == "plannedDepartures" then
                                for vehicle, departureTime in pairs(stopInfoData) do
                                    if not (type(vehicle) == "number"  and type(departureTime) == "number") then
                                        ttData[line][stop][stopInfo][vehicle] = nil
                                    end
                                end
                            elseif stopInfo == "lastDeparture" then
                                if not type(stopInfoData) == "number" then
                                    ttData[line][stop][stopInfo] = nil
                                end
                            else
                                ttData[line][stop][stopInfo] = nil
                            end
                        end
                    end
                end
            end
        end

        print("timetable data after validation")
        print(dump(ttData)) -- debug

        stopState = ttData
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

function timetable.addFrequency(line, frequency)
    if not timetableObject[tostring(line)] then return end
    timetableObject[tostring(line)].frequency = frequency
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
        elseif condition.type == "auto_debounce" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "auto_debounce"
            timetableObject[tostring(line)].stations[stationNumber].conditions.auto_debounce = condition.auto_debounce
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

function timetable.updateDebounce(line, station, indexKey, value, debounceType)
    if not (line and station and indexKey and value) then return -1 end
    if timetableObject[tostring(line)] and
       timetableObject[tostring(line)].stations[station] and
       timetableObject[tostring(line)].stations[station].conditions and
       timetableObject[tostring(line)].stations[station].conditions[debounceType] then
       timetableObject[tostring(line)].stations[station].conditions[debounceType][indexKey] = value
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
    -- get data about the vehicle from the game api
    local time = timetableHelper.getTime()
    local currentLine = timetableHelper.getCurrentLine(vehicle)
    local currentStop = timetableHelper.getCurrentStation(vehicle)
    local currentLineString = tostring(currentLine)
    
    -- check if there is a timetable condition for this vehicle and stop
    if not timetableObject[currentLineString] then return false end
    if not timetableObject[currentLineString].stations then return false end
    if not timetableObject[currentLineString].stations[currentStop] then return false end
    if not timetableObject[currentLineString].stations[currentStop].conditions then return false end
    if not timetableObject[currentLineString].stations[currentStop].conditions.type then return false end

    -- initialize table of waiting vehicles if required
    if not stopState[currentLineString] then
        stopState[currentLineString] = {}
    end
    if not stopState[currentLineString][currentStop] then
        stopState[currentLineString][currentStop] = {}
    end
    if not stopState[currentLineString][currentStop].plannedDepartures then
        stopState[currentLineString][currentStop].plannedDepartures = {}
    end
    if not stopState[currentLineString][currentStop].lastDeparture then
        -- 1 hour before the start of the game to avoid problems with the first departure
        stopState[currentLineString][currentStop].lastDeparture = -3600
    end


    -- check if the vehicle just arrived at the station
    -- such vehicles are not yet registered in plannedDepartures
    -- to avoid recapturing departing vehicles, do not check for new arrivals within 3 seconds after the last departure
    if not stopState[currentLineString][currentStop].plannedDepartures[vehicle]
        and time - stopState[currentLineString][currentStop].lastDeparture > 3 then 

        -- set departure time if condition is set
        -- start with logic for conditions with arrival and departure times
        if timetableObject[currentLineString].stations[currentStop].conditions.type == "ArrDep" then
            -- get the departure time from the condition
            local constraints = timetableObject[currentLineString].stations[currentStop].conditions.ArrDep
            local nextConstraint = timetable.getNextConstraint(constraints, time, {})

            -- convert departure time to game time
            local hourOffset = time - (time % 3600)
            local departureTime = hourOffset + nextConstraint[3] * 60 + nextConstraint[4]

            -- register vehicle with departure time
            stopState[currentLineString][currentStop].plannedDepartures[vehicle] = departureTime

            print(dump(stopState[currentLineString][currentStop]))

        -- logic for conditions with minimal departure interval
        elseif timetableObject[currentLineString].stations[currentStop].conditions.type == "debounce" then

            -- get last departure time and minimum interval
            local condition = timetable.getConditions(currentLine, currentStop, "debounce")
            local interval = condition[1] * 60 + condition[2] 
            -- for auto_debounce, use timetableObject[currentLineString].interval - constraint[1] * 60 - constraint[2]
            local lastDeparture = stopState[currentLineString][currentStop].lastDeparture

            -- calculate next departure time
            local departureTime = lastDeparture + interval

            -- register vehicle with departure time
            stopState[currentLineString][currentStop].plannedDepartures[vehicle] = departureTime
        end
    end

    -- if there are any constraints on departure time, they are now set
    -- now they need to be executed
    -- check if the vehicle is waiting for a departure time
    if stopState[currentLineString][currentStop].plannedDepartures[vehicle] then
        -- check if the departure time has been reached
        if stopState[currentLineString][currentStop].plannedDepartures[vehicle] <= time then
            -- departure time has been reached
            -- remove vehicle from waiting list
            stopState[currentLineString][currentStop].plannedDepartures[vehicle] = nil

            -- update last departure time
            stopState[currentLineString][currentStop].lastDeparture = time

            -- return false to indicate that the vehicle can depart
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
            if stopState[currentLine] and stopState[currentLine].stations[currentStop] then
                stopState[currentLine].stations[currentStop].vehiclesWaiting[vehicle] = nil
            end
            timetableHelper.startVehicle(vehicle)
        end
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

    -- Find the constraint with the closest arrival time
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
        -- for _, used_constraint in pairs(used_constraints) do
        --     if constraint == used_constraint.constraint then
        --         found = true
        --     end
        -- end

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

return timetable

