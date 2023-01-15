local mockTimetableHelper = {}
package.loaded["celmi/timetables/timetable_helper"] = mockTimetableHelper

local timetable = require ".res.scripts.celmi.timetables.timetable"

local timetableTests = {}

timetableTests[#timetableTests + 1] = function()
    local x = { [1] = 0 }
    timetable.setTimetableObject(x)
    local y = timetable.getTimetableObject()
    assert(x.testfield == y.testfield, "Error while setting and retriving the same object from the timetable")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.getTimeDifference(0,0)
    assert(x == 0, "Difference between same time should be 0")
    x = timetable.getTimeDifference(5,5)
    assert(x == 0, "Difference between same time should be 0")
    x = timetable.getTimeDifference(59,60)
    assert(x == 1, "Difference between 2 times should be 1")
    x = timetable.getTimeDifference(60,59)
    assert(x == 1, "Difference between 2 times should be 1")
    x = timetable.getTimeDifference(10,5)
    assert(x == 5, "Difference between 2 times should be 5")
    x = timetable.getTimeDifference(0,5)
    assert(x == 5, "Difference between 2 times should be 5")
    x = timetable.getTimeDifference(3300,300)
    assert(x == 600, "Difference between 2 times should be 600")
    x = timetable.getTimeDifference(600,2400)
    assert(x == 1800, "Difference between 2 times should be 1800")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.getNextDepartureConstraint({{30,0,59,0},{9,0,59,0} },1200, {})
    assert(x[1] == 30 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextDepartureConstraint({{30,0,59,0},{11,0,59,0} },1200, {})
    assert(x[1] == 11 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextDepartureConstraint({{51,0,0,0},{50,0,59,0} },1200, {})
    assert(x[1] == 51 and x[2] == 0 and x[3] == 0 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextDepartureConstraint({{51,0,0,0},{49,1,0,0} },1200, {})
    assert(x[1] == 51 and x[2] == 0 and x[3] == 0 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextDepartureConstraint({{0,59,1,0},{1,30,1,30} },60, {})
    assert(x[1] == 0 and x[2] == 59 and x[3] == 1 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextDepartureConstraint({},1200, {})
    assert(x == nil, "should return nil")

    local a = {30,0,59,0}
    x = timetable.getNextDepartureConstraint({a,{9,0,59,0} },1200, {a})
    assert(x[1] == 9 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the only available time constraint")
    x = timetable.getNextDepartureConstraint({a,{30,0,59,0} },1200, {a})
    assert(x[1] == 30 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the only available time constraint")
    x = timetable.getNextDepartureConstraint({a },1200, {a})
    assert(x[1] == 30 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should still return the constraint")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.afterDepartureConstraint(20 * 60, {0,0,40, 0}, 0 * 60)
    assert(x, "should be after departure")
    x = timetable.afterDepartureConstraint(20 * 60, {0,0,40, 0}, 10 * 60)
    assert(x, "should be after departure")
    x = timetable.afterDepartureConstraint(20 * 60, {0,0,40, 0}, 20 * 60)
    assert(not x, "should be before departure")
    x = timetable.afterDepartureConstraint(20 * 60, {0,0,40, 0}, 30 * 60)
    assert(not x, "should be before departure")
    x = timetable.afterDepartureConstraint(20 * 60, {0,0,40, 0}, 40 * 60)
    assert(x, "should be after departure")
    x = timetable.afterDepartureConstraint(20 * 60, {0,0,40, 0}, 50 * 60)
    assert(x, "should be after departure")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.afterDepartureConstraint(40 * 60, {0,0,20, 0}, 0 * 60)
    assert(not x, "should be before departure")
    x = timetable.afterDepartureConstraint(40 * 60, {0,0,20, 0}, 10 * 60)
    assert(not x, "should be before departure")
    x = timetable.afterDepartureConstraint(40 * 60, {0,0,20, 0}, 20 * 60)
    assert(x, "should be after departure")
    x = timetable.afterDepartureConstraint(40 * 60, {0,0,20, 0}, 30 * 60)
    assert(x, "should be after departure")
    x = timetable.afterDepartureConstraint(40 * 60, {0,0,20, 0}, 40 * 60)
    assert(not x, "should be before departure")
    x = timetable.afterDepartureConstraint(40 * 60, {0,0,20, 0}, 50 * 60)
    assert(not x, "should be before departure")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.getTimeUntilNextConstraint({29,0,_,_}, {{29,0,_,_},{39,0,_,_}})
    assert(x == 10*60, "time to closest constraint should be 10 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({29,30,_,_}, {{29,30,_,_},{30,0,_,_}})
    assert(x == 30, "time to closest constraint should be 30 sec instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({29,30,_,_}, {{29,30,_,_},{30,35,_,_}})
    assert(x == 65, "time to closest constraint should be 65 sec instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({30,00,_,_}, {{30,00,_,_},{25,0,_,_}})
    assert(x == 55*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({55,00,_,_}, {{55,00,_,_},{1,0,_,_}})
    assert(x == 6*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({55,00,_,_}, {{55,00,_,_},{1,0,_,_},{54,0,_,_}})
    assert(x == 6*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({55,00,_,_}, {{55,00,_,_},{1,30,_,_},{1,0,_,_},{54,0,_,_}})
    assert(x == 6*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({1,00,_,_}, {{55,00,_,_},{1,0,_,_},{54,0,_,_}})
    assert(x == 53*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({1,30,_,_}, {{55,00,_,_},{1,30,_,_},{54,0,_,_}})
    assert(x == 52*60 + 30, "time to closest constraint should be 55 min instead of ".. x)
end

-- All tests here done with line and station IDs of 1 for simplicity
timetableTests[#timetableTests + 1] = function()
    table.remove(mockTimetableHelper)

    mockTimetableHelper.getStationID = function(line, stationNumber)
        assert(line == 1)
        assert(stationNumber == 1)
        return 1
    end
    mockTimetableHelper.getCurrentLine = function(vehicle)
        assert(vehicle == 1 or vehicle == 2)
        return 1
    end
    mockTimetableHelper.getCurrentStation = function(vehicle)
        assert(vehicle == 1 or vehicle == 2)
        return 1
    end
    mockTimetableHelper.getTimeUntilDepartureReady = function(vehicle)
        assert(vehicle == 1 or vehicle == 2)
        return 1
    end
    mockTimetableHelper.getLineInfo = function(line)
        assert(line == 1)
        return {
            stops = {
                {
                    minWaitingTime = 0,
                    maxWaitingTime = -1
                }
            }
        }
    end
    timetable.setTimetableObject({})
    local constraints = {{55, 0, 58, 0}, {57, 0, 0, 0}, {59, 0, 2, 0}}
    timetable.addCondition(1, 1, {type = "ArrDep", ArrDep = constraints}) 

    local time = (57*60) + 1 -- 57:01
    mockTimetableHelper.getTime = function()
        return time
    end
    local arrivalTime1 = time
    local x = timetable.readyToDepartArrDep(constraints, arrivalTime1, time, 1, 1, 1)
    assert(not x, "Should wait for train")

    time = (59*60) + 11 -- 59:11
    local arrivalTime2 = time
    x = timetable.readyToDepartArrDep(constraints, arrivalTime2, time, 1, 1, 2)
    assert(not x, "Should wait for train")

    time = (0*60) + 0 -- 00:00
    x = timetable.readyToDepartArrDep(constraints, arrivalTime1, time, 1, 1, 1)
    assert(x, "Shouldn't wait for train")

    time = (0*60) + 1 -- 00:01
    x = timetable.readyToDepartArrDep(constraints, arrivalTime1, time, 1, 1, 1)
    assert(x, "Shouldn't wait for train")

    time = (0*60) + 0 -- 00:00
    x = timetable.readyToDepartArrDep(constraints, arrivalTime2, time, 1, 1, 2)
    assert(not x, "Should wait for train")

    time = (2*60) + 0 -- 02:00
    x = timetable.readyToDepartArrDep(constraints, arrivalTime2, time, 1, 1, 2)
    assert(x, "Shouldn't wait for train")

    time = (2*60) + 1 -- 02:01
    x = timetable.readyToDepartArrDep(constraints, arrivalTime2, time, 1, 1, 2)
    assert(x, "Shouldn't wait for train")
end

return {
    test = function()
        for k,v in pairs(timetableTests) do
            print("Running test: " .. tostring(k))
            v()
        end
    end
}
