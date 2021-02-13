
local result = {}

function result.getTime()
    local time = math.floor(game.interface.getGameTime().time)  
    return time
end 

function result.getAllRailVehicles()
    local res = {}
    vs = game.interface.getVehicles()
    for v in vs do 
        local vObject = game.interface.getEntity(v)
        if (vObject and vObject.carrier == "RAIL" and vObject.line) then
            res.v = vObject.line
        end
    end
    return res
end

function result.isInStation(vehicle)
    local v = game.interface.getEntity(vehicle)
    return v and v.state == "AT_TERMINAL"
end

function result.startVehicle(vehicle)
    api.cmd.sendCommand(api.cmd.make.setUserStopped(vehicle,false))
    return null
end

function result.stopVehicle(vehicle)
    api.cmd.sendCommand(api.cmd.make.setUserStopped(vehicle,true))
    return null
end

return result

