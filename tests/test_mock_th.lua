local luaunit = require('luaunit')

-- overwrite api calls to make them testable
package.loaded['celmi/timetables/timetable_helper'] = require('tests/mock_timetable_helper')
timetableHelper = require('celmi/timetables/timetable_helper')


function testModuleOverwrite()
    -- ensure that the module was overwritten
    luaunit.assertEquals(timetableHelper.test(), "test")
end


os.exit(luaunit.LuaUnit.run())