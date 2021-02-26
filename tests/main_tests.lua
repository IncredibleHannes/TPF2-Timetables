timetableTests = require "tests.timetable_tests"
timetableHelperTests = require "tests.timetable_helper_tests"


print("running timetable tests")
timetableTests.test()

print("running timetable helper tests")
timetableHelperTests.test()
