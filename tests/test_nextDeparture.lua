local luaunit = require('luaunit')

-- overwrite api calls to make them testable
package.loaded['celmi/timetables/timetable_helper'] = require('tests/mock_timetable_helper')

-- load the timetable module for testing
-- print(io.popen"cd":read'*l')
local timetable = require(".res.scripts.celmi.timetables.timetable")

-- generate constraints - arrive at 03:00, depart at 05:00, repeat every 10 minutes
local constraints = {}
for i = 0, 5 do
    table.insert(constraints, {3 + i * 10, 0, 5 + i * 10, 0})
end


function testOnTime()
    -- simulate a train arriving at 13:00(780), last departure was at 05:00(300)
    -- expected result is to depart at next departure time, 15:00(900)

    -- start with arrival and last departure exactly on time
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 780, 300), 900)

    -- start varying arrival time by a few seconds
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 785, 300), 900)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 775, 300), 900)

    -- vary last departure time by a few seconds
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 780, 305), 900)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 780, 295), 900)
end


function testArrival()
    -- simulate a train arriving late after a regular departure at 05:00(300)
    -- expected result is to depart at next departure time, 15:00(900)
    -- it should switch to the slot after that for arrivals after 23:00(1380)

    -- late arrivals up to 12 minutes
    -- should still try to depart at 15:00(900)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 840, 300), 900)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 900, 300), 900)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 960, 300), 900)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 1200, 300), 900)

    -- late arrivals later than next arrival time
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 1380, 300), 1500)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 1500, 300), 1500)

    -- very late arrivals around two hours later
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 780 + 2 * 3600, 300), 900 + 2 * 3600)
    luaunit.assertEquals(timetable.getNextDeparture(constraints, 2 * 3600, 300), 300 + 2 * 3600)
end


function testBiggerArrival()
    -- I have noticed some problems with hourly departures that depart at 00:00
    -- the problem appears to be that the arrival time is larger than the departure time
    constraintsHourly = {{55, 0, 0, 0}}

    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 55 * 60, 0), 3600)
    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 54 * 60, 0), 3600)
    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 56 * 60, 0), 3600)

    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 55 * 60 + 3600, 3600), 2 * 3600)
    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 54 * 60 + 3600, 3600), 2 * 3600)
    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 56 * 60 + 3600, 3600), 2 * 3600)

    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 55 * 60 + 3600, 0), 2 * 3600)
    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 54 * 60 + 3600, 0), 1 * 3600)
    luaunit.assertEquals(timetable.getNextDeparture(constraintsHourly, 56 * 60 + 3600, 0), 2 * 3600)


end


os.exit(luaunit.LuaUnit.run())