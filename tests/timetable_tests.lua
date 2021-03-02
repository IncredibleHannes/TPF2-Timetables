package.loaded["celmi/timetables/timetable_helper"] = {}

local timetable = require ".res.scripts.celmi.timetables.timetable"

local timetableTests = {}

timetableTests[#timetableTests + 1] = function()
    local x = { testfield = 0 }
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
    local x = timetable.getNextConstraint({{30,0,59,0},{9,0,59,0} },1200)
    assert(x[1] == 30 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{30,0,59,0},{11,0,59,0} },1200)
    assert(x[1] == 11 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{51,0,0,0},{50,0,59,0} },1200)
    assert(x[1] == 51 and x[2] == 0 and x[3] == 0 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{51,0,0,0},{49,0,1,0} },1200)
    assert(x[1] == 51 and x[2] == 0 and x[3] == 0 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{0,59,1,0},{1,30,1,30} },60)
    assert(x[1] == 0 and x[2] == 59 and x[3] == 1 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({},1200)
    assert(x == nil, "should return nil")
end


timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.beforeDepature({0,0,30,0},1200)
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({0,0,21,0},1200)
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({0,0,19,0},1200)
    assert(not x, "should be defore departure")
    x = timetable.beforeDepature({0,0,15,0},1200)
    assert(not x, "should be defore departure")
    x = timetable.beforeDepature({0,0,14,59},1200)
    assert(x, "should defore departure")
    x = timetable.beforeDepature({0,0,20,01},1200)
    assert(x, "should defore departure")

end

return {
    test = function()
        for k,v in pairs(timetableTests) do
            print("Running test: " .. tostring(k))
            v()
        end
    end
}
