package.loaded["celmi/timetables/timetable_helper"] = {}

timetable = require ".res.scripts.celmi.timetables.timetable" 
--timetableHelper = require ".res.scripts.celmi.timetables.timetable_helper"


tests = {}

tests[#tests + 1] = function()
    x = { testfield = 0 }
    timetable.setTimetableObject(x)
    y = timetable.getTimetableObject()
    assert(x.testfield == y.testfield, "Error while setting and retriving the same object from the timetable")
end

return {
    test = function()
        for k,v in pairs(tests) do
            print("Running test: " .. tostring(k))
            v()
        end
    end
}