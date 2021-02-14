
local timetable_helper = {}

function timetable_helper.getTime()
    local time = math.floor(game.interface.getGameTime().time)  
    return time
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
    return "red"
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

return timetable_helper

