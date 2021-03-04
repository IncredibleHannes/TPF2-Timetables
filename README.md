[![CI](https://github.com/IncredibleHannes/TPF2-Timetables/actions/workflows/blank.yml/badge.svg)](https://github.com/IncredibleHannes/TPF2-Timetables/actions/workflows/blank.yml)
# TPF2-Timetables
## Project setup
The project is split into 3 parts, represented by 3 different script files.
### Timetable Logic
All the timetable logic is implemented in ```/res/scripts/celmi/timetables/timetable.lua```
The timetable is stored in a giant LUA table. See wiki for further documentation. [Link](https://github.com/IncredibleHannes/TPF2-Timetables/wiki/Timetable-object)   
The timetable module provides all necessary methods to alter the timetable and to request its information.
It is read-only to the engine thread and read/write to the GUI thread.
### UI Logic
The UI logic is implemented in ```/res/config/game_script/timetable_gui.lua```
It creates all necessary menus and holds an instance of the timetable, to modify it accordingly to the user inputs.
It also oversees checking if a vehicle requires stopping due to the timetable.
### Game API requests
All game API requests are summarized in ```res/scripts/celmi/timetables/timetable_helper.lua```.
This module provides useful util functions and does all Game API calls that are necessary to get the current state of the game.
## How to Contribute
If you want to contribute to this project, open yourself an issue, place it on the project board, create yourself a branch, and do your work on your branch.
When you are done and want to integrate it, you can open a pull request into the develop branch. (You can of cause open them early to get feedback if you like).
The pull request can be merged into the dev branch after a review.
For every release to the workshop, a pull request into the master branch is created, and a GitHub release will be created as well.

If you plan to activly contribute to this mod, please join our Discord Server and request the role of a colaborator there:
https://discord.gg/7KbVP8Fr6Z
## Reporting bugs/Submitting feature request
Please use the issue feature to submit feedback/feature requests/bug reports.
When reporting a bug, please detail all the steps that are nectary to recreate this bug! Also please append your stdout.txt file whenever possible.


If you like this mod, a donation would be greatly appreciated:

[![img](https://i.imgur.com/GpY6AzF.png)](https://www.paypal.com/donate?hosted_button_id=NZWEU467XUWJ6)


