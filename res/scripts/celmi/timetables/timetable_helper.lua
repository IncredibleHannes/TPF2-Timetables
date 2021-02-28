local timetableHelper = {}

-------------------------------------------------------------
---------------------- Vehicle related ----------------------
-------------------------------------------------------------

-- returns [lineID] indext by VehicleID : String
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

---@param lineID : Number
-- returns [{stopIndex: Number, vehicle: Number, atTerminal: Bool, countStr: "SINGLE"| "MANY" }] indext by StopIndes:String
function timetableHelper.getTrainLocations(line) 
    local res = {}
    local vehicles = api.engine.system.transportVehicleSystem.getLineVehicles(line)
    for k,v in pairs(vehicles) do 
        local vehicle = game.interface.getEntity(v)
        local atTerminal = vehicle.state == "AT_TERMINAL"
        if res[tostring(vehicle.stopIndex)] then
            prevAtTerminal = res[tostring(vehicle.stopIndex)].atTerminal
            res[tostring(vehicle.stopIndex)] = { stopIndex = vehicle.stopIndex, vehicle = v, atTerminal = (atTerminal or prevAtTerminal), countStr = "MANY" }
        else
            res[tostring(vehicle.stopIndex)] = { stopIndex = vehicle.stopIndex, vehicle = v, atTerminal = atTerminal, countStr = "SINGLE" }
        end
    end
    return res
end

---@param lineID : Number
-- returns [ vehicle:Number ]
function timetableHelper.getVehiclesOnLine(line)
    return api.engine.system.transportVehicleSystem.getLineVehicles(line)
end

---@param vehicleID : Number | String
-- returns stationIndex : Number
function timetableHelper.getCurrentStation(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return -1 end
    if not v then return -1 end
    local vehicle = api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
    return vehicle.stopIndex + 1

end

---@param vehicleID : Number | String
-- returns lineID : Number
function timetableHelper.getCurrentLine(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return -1 end
    if not v then return -1 end
    local vehicle = api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
    if vehicle and vehicle.line then return vehicle.line else return -1 end
end


---@param vehicleID : Number | String
-- returns Bool
function timetableHelper.isInStation(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    local v = api.engine.getComponent(tonumber(vehicle), api.type.ComponentType.TRANSPORT_VEHICLE)
    return v and v.state == 2
end

---@param vehicleID : Number | String
-- returns Null
function timetableHelper.startVehicle(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    api.cmd.sendCommand(api.cmd.make.setUserStopped(vehicle,false))
    return null
end

---@param vehicleID : Number | String
-- returns Null
function timetableHelper.stopVehicle(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    api.cmd.sendCommand(api.cmd.make.setUserStopped(vehicle,true))

    return null
end

---@param vehicleID : Number | String
-- returns time in seconds from game start
function timetableHelper.getPreviousDepartureTime(vehicle) 
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    local vehicleLineMap = api.engine.system.transportVehicleSystem.getLine2VehicleMap()
    local line = timetableHelper.getCurrentLine(vehicle)
    local departureTimes = {}
    local currentStopIndex = api.engine.getComponent(vehicle, 70).stopIndex
    for k,v in pairs(vehicleLineMap[line]) do
        departureTimes[#departureTimes + 1] = api.engine.getComponent(v, 70).lineStopDepartures[currentStopIndex + 1]
    end 
    return (timetableHelper.maximumArray(departureTimes))/1000
end

---@param vehicleID : Number | String
-- returns Time in seconds and -1 in case of an error
function timetableHelper.getTimeUntilDeparture(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return -1 end
    
    local v = api.engine.getComponent(vehicle, 70).timeUntilCloseDoors
    if v and v.timeUntilCloseDoors then return v.timeUntilCloseDoors else return -1 end
end

-------------------------------------------------------------
---------------------- Line related -------------------------
-------------------------------------------------------------

---@param lineType : String, eg "RAIL", "ROAD", "TRAM", "WATER", "AIR"
-- returns Bool
function timetableHelper.isLineOfType(lineType)
    lines = api.engine.system.lineSystem.getLines()
    res = {}
    for k,l in pairs(lines) do
        res[k] = timetableHelper.lineHasType(l, lineType)
    end
    return res
end

---@param lineID : Number | String 
---@param lineType : String, eg "RAIL", "ROAD", "TRAM", "WATER", "AIR"
-- returns Bool
function timetableHelper.lineHasType(line, lineType)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then print("Expected String or Number") return -1 end

    vehicles = api.engine.system.transportVehicleSystem.getLineVehicles(line)
    if vehicles and vehicles[1] and game.interface.getEntity(vehicles[1]).carrier then
        return game.interface.getEntity(vehicles[1]).carrier == lineType
    end
    return false 
end

---@param lineID : Number | String 
-- returns String, RGB value string eg: "204060" with Red 20, Green 40, Blue 60
function timetableHelper.getLineColour(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "default" end
    colour = api.engine.getComponent(line, api.type.ComponentType.COLOR)
    if (colour and  colour.color) then
        a = string.format("%02d", (colour.color.x * 100))
        b = string.format("%02d", (colour.color.y * 100))
        c = string.format("%02d", (colour.color.z * 100))
        return a .. b .. c
    else
        return "default"
    end 
end

---@param lineID : Number | String 
-- returns lineName : String
function timetableHelper.getLineName(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "ERROR" end
    return api.engine.getComponent(tonumber(line), api.type.ComponentType.NAME).name
end

---@param lineID : Number | String 
-- returns lineFrequency : String, formatted '%M:%S'
function timetableHelper.getFrequency(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "ERROR" end

    local line = game.interface.getEntity(line)
    if line and line.frequency then
        if line.frequency == 0 then return "--" end
        local x = 1 / line.frequency
        return os.date('%M:%S', x)
    else
        return "--"
    end
end

-- returns [{id : number, name : String}]
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

---@param lineID : Number | String 
-- returns [time: Number] Array indexed by station index in sec starting with index 1
function timetableHelper.getLegTimes(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "ERROR" end
    
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

-------------------------------------------------------------
---------------------- Station related ----------------------
-------------------------------------------------------------

---@param stationID : Number | String 
-- returns {name : String}
function timetableHelper.getStation(station)
    if type(station) == "string" then line = tonumber(station) end
    if not(type(station) == "number") then return "ERROR" end

    local stationObject = game.interface.getEntity(station)
    if stationObject and stationObject.name then 
        return { name = stationObject.name }
    else
        return {name = "ERROR"}
    end
end

-- returns [{id : Number, name : String}]
function timetableHelper.getRailStations()
    res = {}
    stations = api.engine.system.stationSystem.getStation2TownMap()
    for k,v in pairs(stations) do
        stationObject = game.interface.getEntity(k)
        stationGroup = game.interface.getEntity(stationObject.stationGroup)
        if stationObject and stationObject.carriers and stationObject.carriers["RAIL"] then 
            res[#res + 1] = {
                id = k,
                name = stationGroup.name
            }
        end
        
    end
    return res
end

---@param lineID : Number | String 
-- returns [id : Number] Array of stationIds 
function timetableHelper.getAllStations(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "ERROR" end

    local lineObject = game.interface.getEntity(line)
    if lineObject and lineObject.stops then
        return lineObject.stops
    else
        return {}
    end
end

---@param stationID : Number | String 
-- returns stationName : String
function timetableHelper.getStationName(station)
    if type(station) == "string" then line = tonumber(station) end
    if not(type(station) == "number") then return "ERROR" end

    local err, res = pcall(function()
        return api.engine.getComponent(station, api.type.ComponentType.NAME)
    end)
    if err then return res.name else return "ERROR" end
end


---@param lineID : Number | String 
---@param stationIndex : Number
-- returns stationID : Number and -1 in Error Case
function timetableHelper.getStationID(line, stationNumber)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return -1 end

    lineObject = game.interface.getEntity(line)
    if lineObject and lineObject.stops and lineObject.stops[stationNumber] then
        return lineObject.stops[stationNumber]
    else
        return -1
    end
end

-------------------------------------------------------------
---------------------- Array Functions ----------------------
-------------------------------------------------------------

---@param arr : Arrray
-- returns [Number], an Array where the index it the source element and the number is the target position
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

---@param a : Arrray
---@param b : Arrray
-- returns Array, the merged arrays a,b
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

-- returns Number, current GameTime in seconds
function timetableHelper.getTime()
    local time = math.floor(api.engine.getComponent(0,16).gameTime/ 1000)  
    return time
end 

---@param tab : [a]
---@param val : a
-- returns Bool, 
function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

---@param arr : [a]
-- returns a, the maximum element of the array
function timetableHelper.maximumArray(arr)
    local max = arr[1]
    for k,v in pairs(arr) do
        if max < arr[k] then
            max = arr[k]
        end
    end
    return max
end

-------------------------------------------------------------
---------------------- Other --------------------------------
-------------------------------------------------------------

---@param cond : TimetableCondition,
---@param type : String, "ArrDep" |"debounce"
-- returns String, ready to display in the UI
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
    elseif type == "debounce" then
        if not cond[1] then cond[1] = 0 end
        if not cond[2] then cond[2] = 0 end
        return "Unbunch Time: " .. string.format("%02d", cond[1]) .. ":" .. string.format("%02d", cond[2]) 
    
    else
        return type
    end
end

---@param i : Index of Combobox,
-- returns String, ready to display in the UI
function timetableHelper.constraintIntToString(i) 
    if i == 0 then return "None"
    elseif i == 1 then return "ArrDep"
    --elseif i == 2 then return "minWait"
    elseif i == 2 then return "debounce"
    --elseif i == 4 then return "moreFancey"
    else return "ERROR"
    end
end

---@param i : String, "ArrDep" |"debounce"
-- returns Number, index of combobox
function timetableHelper.constraintStringToInt(i) 
    if i == "None" then return 0
    elseif i == "ArrDep" then return 1
    --elseif i == "minWait" then return 2
    elseif i == "debounce" then return 2
    --elseif i == "moreFancey" then return 4
    else return 0
    end
end


return timetableHelper
