
local timetable_helper = {}

function timetable_helper.getTime()
    local time = math.floor(game.interface.getGameTime().time)  
    return time
end 



function timetable_helper.test()
    
    local res = {}
    local vs = game.interface.getVehicles()
    print(vs)
    for k,v in pairs(vs) do   
        local vObject = game.interface.getEntity(v)
        print(vObject)
        if (vObject and vObject.carrier == "RAIL" and vObject.line) then
            res[v]= vObject.line
        end
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

