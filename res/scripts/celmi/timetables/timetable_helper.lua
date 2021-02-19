
local timetableHelper = {}


-- returns an vector with the order
function timetableHelper.getOrderOfArray(arr)
    toSort = {}
    for k,v in pairs(arr) do 
        toSort[k] = {key =  k, value = v}
    end
    table.sort(toSort, function(a,b)
        return string.lower(a.value) < string.lower(b.value)
    end)
    res = {}
    for k,v in pairs(toSort) do
        res[k-1] = v.key-1
    end 
    return res
end

function timetableHelper.getTime()
    local time = math.floor(api.engine.getComponent(0,16).gameTime/ 1000)  
    return time
end 
-- returns an array of booleans 
function timetableHelper.isLineOfType(type)
    lines = api.engine.system.lineSystem.getLines()
    res = {}
    for k,l in pairs(lines) do
        res[k] = timetableHelper.lineHasType(l, type)
    end
    return res
end

function timetableHelper.lineHasType(line, type)
    vehicles = api.engine.system.transportVehicleSystem.getLineVehicles(line)
    if vehicles and vehicles[1] and game.interface.getEntity(vehicles[1]).carrier then
        return game.interface.getEntity(vehicles[1]).carrier == type
    end
    return false 
end

function timetableHelper.mergeArray(a,b)
    if a == nil then return b end
    if b == nil then return a end
    ab = {}
    for k, v in pairs(a) do 
        table.insert(ab, v) 
    end
    for k, v in pairs(b) do 
        table.insert(ab, v) 
    end
    return ab
end

function timetableHelper.conditionToString(cond, type)
    if not (cond and type) then return "" end
    if type =="ArrDep" then
        arr = "Arr "
        dep = "Dep "
        for k,v in pairs(cond) do
            arr = arr .. string.format("%02d", v[1]) .. ":" .. string.format("%02d", v[2])  .. "|"
            dep = dep .. string.format("%02d", v[3]) .. ":" .. string.format("%02d", v[4])  .. "|"
        end
        res = arr .. "\n"  .. dep
        return res
    else
        return type
    end
end

function timetableHelper.constraintIntToString(i) 
    if i == 0 then return "None"
    elseif i == 1 then return "ArrDep"
    elseif i == 2 then return "minWait"
    elseif i == 3 then return "debounce"
    elseif i == 4 then return "moreFancey"
    else return "ERROR"
    end
end

function timetableHelper.constraintStringToInt(i) 
    if i == "None" then return 0
    elseif i == "ArrDep" then return 1
    elseif i == "minWait" then return 2
    elseif i == "debounce" then return 3
    elseif i == "moreFancey" then return 4
    else return 0
    end
end

function timetableHelper.getLineColour(v)
    if not(type(v) == "number") then return "default" end
    entityID = 64
    colour = api.engine.getComponent(v,64)
    if (colour and  colour.color) then
        a = string.format("%02d", (colour.color.x * 100))
        b = string.format("%02d", (colour.color.y * 100))
        c = string.format("%02d", (colour.color.z * 100))
        return a .. b .. c
    else
        return "default"
    end 
end

function timetableHelper.getTrainLocations(line) 
    local res = {}
    local vehicles = api.engine.system.transportVehicleSystem.getLineVehicles(line)
    for k,v in pairs(vehicles) do 
        local vehicle = game.interface.getEntity(v)
        local atTerminal = vehicle.state == "AT_TERMINAL"
        if res[tostring(vehicle.stopIndex)] then
            prevAtTerminal = res[tostring(vehicle.stopIndex)].atTerminal
            res[tostring(vehicle.stopIndex)] = { stopIndex = vehicle.stopIndex, vehicle = v, atTerminal = (atTerminal or prevAtTerminal), countStr="MANY" }
        else
            res[tostring(vehicle.stopIndex)] = { stopIndex = vehicle.stopIndex, vehicle = v, atTerminal = atTerminal, countStr="SINGLE" }
        end
    end
    return res
end

function timetableHelper.getVehiclesOnLine(line)
    return api.engine.system.transportVehicleSystem.getLineVehicles(line)
end

function timetableHelper.getFrequency(lineID)
    local line = game.interface.getEntity(lineID)
    if line and line.frequency then
        if line.frequency == 0 then return "--" end
        local x = 1 / line.frequency
        if x > 60 then
            return tostring(math.floor(x/60)) .. " min"
        else
            return tostring(math.floor(x/60)) .. " sec"
        end
    else
        return "--"
    end
end

-- getAllStations :: StationID -> {name :: String}
function timetableHelper.getStation(stationID)
    local stationObject = game.interface.getEntity(stationID)
    if stationObject and stationObject.name then 
        return { name = stationObject.name }
    else
        return {name = "ERROR"}
    end
end

function timetableHelper.getRailStations()
    res = {}
    stations = api.engine.system.stationSystem.getStation2TownMap()
    for k,v in pairs(stations) do
        stationObject = game.interface.getEntity(k)
        if stationObject and stationObject.carriers and stationObject.carriers["RAIL"] then 
            stationName = api.engine.getComponent(k, 63)
            res[#res + 1] = {
                id = k,
                name = stationName.name
            }
        end
        
    end
    return res
end

-- getAllStations :: LineID :: Int -> [Stops]
function timetableHelper.getAllStations(line)
    local lineObject = game.interface.getEntity(line)
    if lineObject and lineObject.stops then
        return lineObject.stops
    else
        return {}
    end
end

function timetableHelper.getAllRailLines()
    local res = {}
    local ls = api.engine.system.lineSystem.getLines()
    for k,l in pairs(ls) do
        local lineName = api.engine.getComponent(l, 63)
        if lineName and lineName.name then 
            res[k] = {id = l, name = lineName.name}
        else
            res[k] = {id = l, name = "ERROR"}
        end
    end
    return res
end

function timetableHelper.getStationID(line, stationNumber)
    lineObject = game.interface.getEntity(line)
    if lineObject and lineObject.stops and lineObject.stops[stationNumber] then
        return lineObject.stops[stationNumber]
    else
        return -1
    end
end

-- returns [{vehicleID: lineID}]
function timetableHelper.getAllRailVehicles()
    local res = {}
    local vehicleMap = api.engine.system.transportVehicleSystem.getLine2VehicleMap()
    for k,v in pairs(vehicleMap) do
        for k2,v2 in pairs(v) do
            res[tostring(v2)] = k 
        end
    end
    return res
end

function timetableHelper.isInStation(vehicle)
    if not(type(vehicle) == "string") then print("wrong type") return false end
    local v = api.engine.getComponent(tonumber(vehicle), 70)
    return v and v.state == 2
end

function timetableHelper.startVehicle(vehicle)
    api.cmd.sendCommand(api.cmd.make.setUserStopped(tonumber(vehicle),false))
    return null
end

function timetableHelper.stopVehicle(vehicle)
    api.cmd.sendCommand(api.cmd.make.setUserStopped(tonumber(vehicle),true))
    return null
end

function timetableHelper.getCurrentStation(v)
    if not v then return -1 end
    local vehicle = api.engine.getComponent(tonumber(v), 70)
    return vehicle.stopIndex + 1

end

function timetableHelper.getCurrentLine(v)
    if not v then return -1 end
    local vehicle = api.engine.getComponent(tonumber(v), 70)
    return vehicle.line

end


function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


function timetableHelper.getLegTimes(line) 
    local vehicleLineMap = api.engine.system.transportVehicleSystem.getLine2VehicleMap()
    if vehicleLineMap[line] == nil or vehicleLineMap[line][1] == nil then return {}end
    local vehicle = vehicleLineMap[line][1]
    vehicleObject = api.engine.getComponent(vehicle, 70)
    if vehicleObject and vehicleObject.sectionTimes then
        return vehicleObject.sectionTimes
    else 
        return {}
    end
end

return timetableHelper

