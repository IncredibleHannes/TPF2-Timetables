# TPF2-Timetables
## Overview
This is a mod for Transport Fever 2 that adds a timetable system to the game. It allows you to specify when a vehicle should stop at a station and when it should depart. This is useful for creating realistic schedules for your trains, buses and other vehicles.

For every stop you can choose between three modes:
- **None**: The vehicle will use the vanilla logic, i.e. it will stop, wait for loading to complete, sometimes wait a bit extra for unbunching and then depart.
- **Arrival/Departure**: The vehicle will stop at the station and depart only at the next specified departure time. It chooses the last slot with a departure time after the last recorded departure and an arrival time in the past.
- **Unbunch**: The vehicle will depart no sooner than the specified time span after the last recorded departure for that line and station.
- **AutoUnbunch**: The vehicle departures will be spaced out by the frequency of the line. The associate time is the "give" in the system and allows for delays in and between stations. I would recommend a minimum value of 1 minute but this should be increased to 2 or even 3 minutes for less frequent or more delayed routes.

More technical information can be found in the [documentation](documentation.md).

## The Current State of the Project
This mod has already been released on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2408373260) by it's original Creator, [@IncredibleHannes](https://github.com/IncredibleHannes/TPF2-Timetables). Unfortunately that release is from March 2021, and a few things have changed in the game since then. 

Additionally, changes have been made to the mod by several people that were never released. Those people include me [@Gregory365](https://github.com/Gregory365/TPF2-Timetables), [@quittung](https://github.com/quittung/TPF2-Timetables), [@IncredibleHannes](https://github.com/IncredibleHannes/TPF2-Timetables), and others.

My aim with this fork is to compile the changes that make sense, rework the code to improve reliability and maintainability, add documentation and eventually release a new version of the mod on the Steam Workshop.

## New Features this version brings
- Support for multiple vehicles at the same station (no two vehicles can pick the same time slot)
- Use nearest arrival time to calculate a vehicles intended departure time
- Remember the state of vehicles after a save-load cycle so not to always depart immediately
- **AutoUnbunch**: space out vehicles by the frequency of the line
- Improved performance
- Updated timetable colours to support Spring Update line colours
- Minimum wait time is supported
- Maximum wait time can be support (enable first is mod settings)

## Breaking changes
- Timetables can be transfered from the old version (but not back again)
- Use *nearest* arrival time instead of *next* arrival time to calculate a vehicles intended departure time

## Installing the Mod without Steam
First get the files by pressing the green "Code" button on the top right of the page and then "Download ZIP". Then extract the files to your mods folder. The mods folder is located in your Transport Fever 2 folder. On Windows it is usually `C:\Program Files (x86)\Steam\steamapps\common\Transport Fever 2\mods`. 

When you're done, there should be a folder names `TPF2-Timetables` in your mods folder. Inside that folder there should be a file named `mod.lua`. TPF2 should now detect the mod and complain about the mod format being deprecated. You can ignore that warning.

If someone knows how to install the mod without that warning, please let me know.

## How to Contribute
Found a bug? Have an idea for a new feature? Want to help with the documentation? Please open an issue or a pull request. I'm happy to help and answer questions.

If you want to actively develop, fork this repo, make your changes and create a pull request. I'll review it and merge it if it looks good and fits in with the rest of the mod. If you want to discuss your changes before you start working on them, please open an issue or contact me on Discord (Gregory365#5262).

There is a [Discord server](https://discord.gg/7KbVP8Fr6Z) for this mod that was created by the orginal creator. You can use it to discuss the mod, ask questions or just hang out.
