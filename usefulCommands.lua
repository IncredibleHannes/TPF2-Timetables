
-- Make vehicle stop!
api.cmd.sendCommand(api.cmd.make.setUserStopped(18339,false))

-- get game entity
game.interface.getEntity(18339)

-- get all vehicles
game.interface.getVehicles()

-- get all lines
game.interface.getLines()

--print table
debugPrint(--[[<someTable>--]])