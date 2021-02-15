
local timetable_helper = {}


-- returns an vector with the order
function timetable_helper.getOrderOfArray(arr)
    toSort = {}
    for k,v in pairs(arr) do 
        toSort[k] = {key =  k, value = v}
    end
    table.sort(toSort, function(a,b)
        return a.value < b.value
    end)
    res = {}
    for k,v in pairs(toSort) do
        res[k] = v.key
    end 
    return res
end

function timetable_helper.getTime()
    local time = math.floor(game.interface.getGameTime().time)  
    return time
end 

function timetable_helper.mergeArray(a,b)
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

function timetable_helper.conditionToString(cond, type)
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

function timetable_helper.constraintIntToString(i) 
    if i == 0 then return "None"
    elseif i == 1 then return "ArrDep"
    elseif i == 2 then return "minWait"
    elseif i == 3 then return "debounce"
    elseif i == 4 then return "moreFancey"
    else return "ERROR"
    end
end

function timetable_helper.constraintStringToInt(i) 
    if i == "None" then return 0
    elseif i == "ArrDep" then return 1
    elseif i == "minWait" then return 2
    elseif i == "debounce" then return 3
    elseif i == "moreFancey" then return 4
    else return 0
    end
end

function timetable_helper.getLineColour(v)
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


-- getAllStations :: StationID -> {name :: String}
function timetable_helper.getStation(stationID)
    local stationObject = game.interface.getEntity(stationID)
    if stationObject and stationObject.name then 
        return { name = stationObject.name }
    else
        return {name = "ERROR"}
    end
end

-- getAllStations :: LineID :: Int -> [Stops]
function timetable_helper.getAllStations(line)
    local lineObject = game.interface.getEntity(line)
    if lineObject and lineObject.stops then
        return lineObject.stops
    else
        return {}
    end
end

function timetable_helper.getAllRailLines()
    local res = {}
    local ls = api.engine.system.lineSystem.getLines()
    for k,l in pairs(ls) do
        lObject = game.interface.getEntity(l)
        res[k] = {id = l, name = lObject.name}
    end
    return res
end

-- returns [{vehicleID: lineID}]
function timetable_helper.getAllRailVehicles()
    local res = {}
    local vs = game.interface.getVehicles()
    for k,v in pairs(vs) do   
        local vObject = game.interface.getEntity(v)
        if (vObject and vObject.carrier == "RAIL" and vObject.line) then
            res[v] = vObject.line
        end
    end
    return res
end

function timetable_helper.isInStation(vehicle)
    local v = game.interface.getEntity(vehicle)
    return v and v.state == "AT_TERMINAL"
end

function timetable_helper.startVehicle(vehicle)
    api.cmd.sendCommand(api.cmd.make.setUserStopped(vehicle,false))
    return null
end

function timetable_helper.stopVehicle(vehicle)
    api.cmd.sendCommand(api.cmd.make.setUserStopped(vehicle,true))
    return null
end

function timetable_helper.getCurrentStation(v)
    if not v then return -1 end
    vehicle = game.interface.getEntity(v)
    return vehicle.stopIndex + 1

end

function timetable_helper.getCurrentLine(v)
    if not v then return -1 end
    vehicle = game.interface.getEntity(v)
    return vehicle.line

end

return timetable_helper

