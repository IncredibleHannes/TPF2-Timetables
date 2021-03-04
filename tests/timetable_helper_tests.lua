--local timetableHelper = require ".res.scripts.celmi.timetables.timetable_helper"

local tests = {}

return {
    test = function()
        for k,v in pairs(tests) do
            print("Running test: " .. tostring(k))
            v()
        end
    end
}