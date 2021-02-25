# TPF2-Timetables
## Project setup
The project is split into 3 parts, represented by 3 differen script files.
### Timetable Logic
All the timetable logic is implemented in ```/res/scripts/celmi/timetables/timetable.lua```
The timetable is stored in a giant LUA table. See wiki for further documentation.
The timetable module provides all neccesarry methods to alter the timetable and to request its information.
It is readonly to the engine thread and read/write to the GUI thread.
### UI Logic
The UI logic is implemented in ```/res/config/game_script/timetable_gui.lua```
It creates all neccecary menues and holds an instance of the timetable, to modify it accordingly to the user inputs.
It also is in charge of checking if a vehicle requires stopping due to the timetable.
### Game API requests
All gamie API requests are summarized in ```res/scripts/celmi/timetables/timetable_helper.lua```.
This module provides usefull util functions and does all Game API calls that are neccecary to get the current state of the game.
## How to Contribute
If you want to contribute to this project, open yourself an issue, place it on the project board, create yourself a branch, and do your work on your branch.
When you are done and want to integrate it, you can open a pullrequest into the develop branch.(You can of cause open them early to get feedback if you like).
The pullrequest can be merged into the dev branch after a review.
For every release to the workshop, a pullrequest into the master branch is created, and a github release will be created aswell.
## Reporting bugs/Submitting feature requetst
Please use the issue feature to submit feadback/feature requests/bug reports.
When reporting a bug, please detail all the steps that are necceary to recreate this bug! Also please append your stdout.txt file when ever possible. 
