local timetableHelper = {}

local UIStrings = {
    arr = _("arr_i18n"),
    dep = _("dep_i18n"),
    unbunchTime = _("unbunch_time_i18n")
}

-- flatten a table into a string for printing
-- from https://stackoverflow.com/a/27028488
-- TF2 also uses debugPrint(object) function where object is a table, string, or other lua element to print
function timetableHelper.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. timetableHelper.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-------------------------------------------------------------
---------------------- Vehicle related ----------------------
-------------------------------------------------------------

function timetableHelper.getVehicleInfo(vehicle)
    return api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
end


function timetableHelper.isVehicleAtTerminal(vehicleInfo)
    return vehicleInfo.state == api.type.enum.TransportVehicleState.AT_TERMINAL
end

-- returns [lineID] indext by VehicleID : String
function timetableHelper.getAllVehicles()
    local res = {}
    local lineVehiclesMap = api.engine.system.transportVehicleSystem.getLine2VehicleMap()
    for line,vehicles in pairs(lineVehiclesMap) do
        for _,vehicle in pairs(vehicles) do
            res[vehicle] = line
        end
    end
    return res
end

---@param line number
-- returns [{stopIndex: Number, vehicle: Number, atTerminal: Bool, countStr: "SINGLE"| "MANY" }]
--         indext by StopIndes : string
function timetableHelper.getTrainLocations(line)
    local res = {}
    local vehicles = api.engine.system.transportVehicleSystem.getLineVehicles(line)
    for _,v in pairs(vehicles) do
        local vehicle = api.engine.getComponent(v, api.type.ComponentType.TRANSPORT_VEHICLE)
        local atTerminal = vehicle.state == api.type.enum.TransportVehicleState.AT_TERMINAL
        if res[vehicle.stopIndex] then
            local prevAtTerminal = res[vehicle.stopIndex].atTerminal
            res[vehicle.stopIndex] = {
                stopIndex = vehicle.stopIndex,
                vehicle = v,
                atTerminal = (atTerminal or prevAtTerminal),
                countStr = "MANY"
            }
        else
            res[vehicle.stopIndex] = {
                stopIndex = vehicle.stopIndex,
                vehicle = v,
                atTerminal = atTerminal,
                countStr = "SINGLE"
            }
        end
    end
    return res
end

---@param line number
-- returns [ vehicle:Number ]
function timetableHelper.getVehiclesOnLine(line)
    return api.engine.system.transportVehicleSystem.getLineVehicles(line)
end

---@param vehicle number | string
-- returns stationIndex : Number
function timetableHelper.getCurrentStation(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return -1 end
    if not vehicle then return -1 end
    local res = api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
    return res.stopIndex + 1

end

---@param vehicle number | string
-- returns lineID : Number
function timetableHelper.getCurrentLine(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return -1 end
    if not vehicle then return -1 end

    local res = api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
    if res and res.line then return res.line else return -1 end
end


---@param vehicle number | string
-- returns Bool
function timetableHelper.isInStation(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    local v = api.engine.getComponent(tonumber(vehicle), api.type.ComponentType.TRANSPORT_VEHICLE)
    return v and v.state == api.type.enum.TransportVehicleState.AT_TERMINAL
end

---@param vehicle number | string
-- returns Null
function timetableHelper.stopAutoVehicleDeparture(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    api.cmd.sendCommand(api.cmd.make.setVehicleManualDeparture(vehicle,true))
end

---@param vehicle number | string
-- returns Null
function timetableHelper.restartAutoVehicleDeparture(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    api.cmd.sendCommand(api.cmd.make.setVehicleManualDeparture(vehicle,false))
end

---@param vehicle number | string
-- returns Null
function timetableHelper.departVehicle(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return false end

    api.cmd.sendCommand(api.cmd.make.setVehicleShouldDepart(vehicle))
end

function timetableHelper.getVehiclesAtStop(line, stop)
    return api.engine.system.transportVehicleSystem.getLineStopVehicles(line, stop)
end

---@param vehicle number | string
-- returns departure time of previous vehicle
function timetableHelper.getPreviousDepartureTime(stop, vehicles)
    if type(stop) == "string" then stop = tonumber(stop) end
    if not(type(stop) == "number") then print("Expected String or Number") return false end

    local departureTimes = {}
    for _,v in pairs(vehicles) do
        -- append to a list using a[#a + 1] = new_item
        local lineVehicle = api.engine.getComponent(v, api.type.ComponentType.TRANSPORT_VEHICLE)
        departureTimes[#departureTimes + 1] = lineVehicle.lineStopDepartures[stop]
    end

    return (timetableHelper.maximumArray(departureTimes))/1000
end

---@param vehicle number | string
-- returns Time in seconds and -1 in case of an error
function timetableHelper.getTimeUntilDepartureReady(vehicle)
    if type(vehicle) == "string" then vehicle = tonumber(vehicle) end
    if not(type(vehicle) == "number") then print("Expected String or Number") return -1 end

    local v = api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
    if v and v.timeUntilCloseDoors then return v.timeUntilCloseDoors else return -1 end
end

-------------------------------------------------------------
---------------------- Line related -------------------------
-------------------------------------------------------------

---@param lineType string, eg "RAIL", "ROAD", "TRAM", "WATER", "AIR"
-- returns Bool
function timetableHelper.isLineOfType(lineType)
    local lines = api.engine.system.lineSystem.getLines()
    local res = {}
    for k,l in pairs(lines) do
        res[k] = timetableHelper.lineHasType(l, lineType)
    end
    return res
end

---@param line  number | string
---@param lineType string, eg "RAIL", "ROAD", "TRAM", "WATER", "AIR"
-- returns Bool
function timetableHelper.lineHasType(line, lineType)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then print("Expected String or Number") return -1 end

    local vehicles = api.engine.system.transportVehicleSystem.getLineVehicles(line)
    if vehicles and vehicles[1] then
        local component = api.engine.getComponent(vehicles[1], api.type.ComponentType.TRANSPORT_VEHICLE)
        if component and component.carrier then
            return component.carrier  == api.type.enum.Carrier[lineType]
        end
    end
    return false
end

-- similar function in timetable_colors.lua stylesheet, import is not possible
-- if you change it here, also change it there!
local function getColorString(r, g, b)
    local x = string.format("%03.0f", (r * 100))
    local y = string.format("%03.0f", (g * 100))
    local z = string.format("%03.0f", (b * 100))
    return x .. y .. z
end

---@param line number | string
-- returns String, RGB value string eg: "204060" with Red 20, Green 40, Blue 60
function timetableHelper.getLineColour(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "default" end
    local colour = api.engine.getComponent(line, api.type.ComponentType.COLOR)
    if (colour and  colour.color) then
        return getColorString(colour.color.x, colour.color.y, colour.color.z)
    else
        return "default"
    end
end

---@param line number | string
-- returns lineName : String
function timetableHelper.getLineName(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "ERROR" end

    local err, res = pcall(function()
        return api.engine.getComponent(line, api.type.ComponentType.NAME)
    end)
    local component = res
    if err and component and component.name then
        return component.name
    else
        return "ERROR"
    end
end

---@param line number | string
-- returns lineFrequency : String, formatted '%M:%S'
function timetableHelper.getFrequencyString(line)
    local frequency = timetableHelper.getFrequencyMinSec(line)
    if frequency == -1 then return "ERROR" end
    if frequency == -2 then return "--" end

    return frequency.min .. ":" .. frequency.sec
end

function timetableHelper.getFrequencyMinSec(line)
    local frequency = timetableHelper.getFrequency(line)
    if frequency <= 0 then return frequency end
    return { min = math.floor(frequency / 60), sec = math.floor(frequency % 60) }
end

---@param line number | string
-- returns lineFrequency in seconds
function timetableHelper.getFrequency(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return -1 end

    local lineEntity = game.interface.getEntity(line)

    if lineEntity and lineEntity.frequency then
        if lineEntity.frequency == 0 then return -2 end
        return 1 / lineEntity.frequency
        
    else
        return -2
    end
end

-- returns [{id : number, name : String}]
function timetableHelper.getAllLines()
    local res = {}
    local ls = api.engine.system.lineSystem.getLines()

    for k,l in pairs(ls) do
        local lineName = api.engine.getComponent(l, api.type.ComponentType.NAME)
        if lineName and lineName.name then
            res[k] = {id = l, name = lineName.name}
        else
            res[k] = {id = l, name = "ERROR"}
        end
    end

    return res
end

-- returns [lineID]
function timetableHelper.lineExists(lineID)
    local apiLines = api.engine.system.lineSystem.getLines()

    for apiLineNr, apiLineID in pairs(apiLines) do
        if tonumber(lineID) == tonumber(apiLineID) then return true end
    end

    return false
end

---@param line number | string
-- returns [time: Number] Array indexed by station index in sec starting with index 1
function timetableHelper.getLegTimes(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "ERROR" end
    local vehicleLineMap = api.engine.system.transportVehicleSystem.getLine2VehicleMap()
    if vehicleLineMap[line] == nil or vehicleLineMap[line][1] == nil then return {}end
    local vehicle = vehicleLineMap[line][1]
    local vehicleObject = api.engine.getComponent(vehicle, api.type.ComponentType.TRANSPORT_VEHICLE)
    if vehicleObject and vehicleObject.sectionTimes then
        return vehicleObject.sectionTimes
    else
        return {}
    end
end

-------------------------------------------------------------
---------------------- Station related ----------------------
-------------------------------------------------------------

---@param station number | string
-- returns {name : String}
function timetableHelper.getStation(station)
    if type(station) == "string" then station = tonumber(station) end
    if not(type(station) == "number") then return "ERROR" end

    local stationObject = api.engine.getComponent(station, api.type.ComponentType.NAME)
    if stationObject and stationObject.name then
        return { name = stationObject.name }
    else
        return {name = "ERROR"}
    end
end

function timetableHelper.getLineInfo(line)
    return api.engine.getComponent(line, api.type.ComponentType.LINE)
end

---@param line number | string
-- returns [id : Number] Array of stationIds
function timetableHelper.getAllStations(line)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return "ERROR" end

    local lineObject = api.engine.getComponent(line, api.type.ComponentType.LINE)
    if lineObject and lineObject.stops then
        local res = {}
        for k, v in pairs(lineObject.stops) do
            res[k] = v.stationGroup
        end
        return res
    else
        return {}
    end
end

---@param station number | string
-- returns stationName : String
function timetableHelper.getStationName(station)
    if type(station) == "string" then station = tonumber(station) end
    if not(type(station) == "number") then return "ERROR" end

    local err, res = pcall(function()
        return api.engine.getComponent(station, api.type.ComponentType.NAME)
    end)
    if err and res then return res.name else return "ERROR" end
end


---@param line number | string
---@param stationNumber number
-- returns stationID : Number and -1 in Error Case
function timetableHelper.getStationID(line, stationNumber)
    if type(line) == "string" then line = tonumber(line) end
    if not(type(line) == "number") then return -1 end

    local lineObject = api.engine.getComponent(line, api.type.ComponentType.LINE)
    if lineObject and lineObject.stops and lineObject.stops[stationNumber] then
        return lineObject.stops[stationNumber].stationGroup
    else
        return -1
    end
end

-------------------------------------------------------------
---------------------- Array Functions ----------------------
-------------------------------------------------------------

---@param arr table
-- returns [Number], an Array where the index it the source element and the number is the target position
function timetableHelper.getOrderOfArray(arr)
    local toSort = {}
    for k,v in pairs(arr) do
        toSort[k] = {key =  k, value = v}
    end
    table.sort(toSort, function(a,b)
        return string.lower(a.value) < string.lower(b.value)
    end)
    local res = {}
    for k,v in pairs(toSort) do
        res[k-1] = v.key-1
    end
    return res
end

---@param a table
---@param b table
-- returns Array, the merged arrays a,b
function timetableHelper.mergeArray(a,b)
    if a == nil then return b end
    if b == nil then return a end
    local ab = {}
    for _, v in pairs(a) do
        table.insert(ab, v)
    end
    for _, v in pairs(b) do
        table.insert(ab, v)
    end
    return ab
end


-- returns [{vehicleID: lineID}]
function timetableHelper.getAllVehiclesAtTerminal()
    return api.engine.system.transportVehicleSystem.getVehiclesWithState(api.type.enum.TransportVehicleState.AT_TERMINAL)
    --[[local res = {}
    local vehicleMap = api.engine.system.transportVehicleSystem.getLine2VehicleMap()
    for k,v in pairs(vehicleMap) do
        if (hasTimetable(k)) then
            for _,v2 in pairs(v) do
                res[v2] = k
            end
        end
    end
    return res]]--
end


-- returns Number, current GameTime in seconds
function timetableHelper.getTime()
    local time = api.engine.getComponent(api.engine.util.getWorld(), api.type.ComponentType.GAME_TIME).gameTime
    if time then
        time = math.floor(time/ 1000)
        return time
    else
        return 0
    end
end

---@param tab table
---@param val any
-- returns Bool,
function timetableHelper.hasValue(tab, val)
    for _, v in pairs(tab) do
        if v == val then
            return true
        end
    end

    return false
end

---@param arr table
-- returns a, the maximum element of the array
function timetableHelper.maximumArray(arr)
    local max = arr[1]
    for k,_ in pairs(arr) do
        if max < arr[k] then
            max = arr[k]
        end
    end
    return max
end


-------------------------------------------------------------
---------------------- Other --------------------------------
-------------------------------------------------------------

---@param cond table : TimetableCondition,
---@param type string, "ArrDep" |"debounce"
-- returns String, ready to display in the UI
function timetableHelper.conditionToString(cond, type)
    if (not cond) or (not type) then return "" end
    if type =="ArrDep" then
        local arr = UIStrings.arr
        local dep = UIStrings.dep
        for _,v in pairs(cond) do
            arr = arr .. string.format("%02d", v[1]) .. ":" .. string.format("%02d", v[2])  .. "|"
            dep = dep .. string.format("%02d", v[3]) .. ":" .. string.format("%02d", v[4])  .. "|"
        end
        local res = arr .. "\n"  .. dep
        return res
    elseif type == "debounce" then
        if not cond[1] then cond[1] = 0 end
        if not cond[2] then cond[2] = 0 end
        return UIStrings.unbunchTime .. ": " .. string.format("%02d", cond[1]) .. ":" .. string.format("%02d", cond[2])
    elseif type == "auto_debounce" then
        if not cond[1] then cond[1] = 0 end
        if not cond[2] then cond[2] = 0 end
    return "Margin Time: " .. string.format("%02d", cond[1]) .. ":" .. string.format("%02d", cond[2])
    else
        return type
    end
end

---@param i number Index of Combobox,
-- returns String, ready to display in the UI
function timetableHelper.constraintIntToString(i)
    if i == 0 then return "None"
    elseif i == 1 then return "ArrDep"
    --elseif i == 2 then return "minWait"
    elseif i == 2 then return "debounce"
    elseif i == 3 then return "auto_debounce"
    --elseif i == 4 then return "moreFancey"
    else return "ERROR"
    end
end

---@param i string, "ArrDep" |"debounce"
-- returns Number, index of combobox
function timetableHelper.constraintStringToInt(i)
    if i == "None" then return 0
    elseif i == "ArrDep" then return 1
    --elseif i == "minWait" then return 2
    elseif i == "debounce" then return 2
    elseif i == "auto_debounce" then return 3
    --elseif i == "moreFancey" then return 4
    else return 0
    end

end


return timetableHelper