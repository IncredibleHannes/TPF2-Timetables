# Documentation
## Introduction
This is the technical documentation for the TPF2-Timetables mod. It is intended for developers that want to understand or modify the code. Normal users should instead read the [README](README.md).

## Overview
### GUI
The GUI is implemented in the `timetable_gui.lua` file. It is responsible for creating all the menus and for handling the user input. It manages a timeteble object, that specifies if and when a vehicle should stop at a statio.

### Control Logic
The control logic is implemented in the `timetable.lua` file. It reads the timetable object and decides wether a particular vehicle should wait at that time. 

The central function is `timetable.waitingRequired()`, which is called once every ingame second for each vehicle that is currently in a station.

### Game API Interaction
The mod communicates with the game through helper functions contained in the `timetable_helper.lua` file. This includes getting the current time or information about vehicles and stations, and telling vehicles to start or stop.

## API Interaction
### Getting Data
####  [ TransportVehicle Data](https://transportfever2.com/wiki/api/modules/api.type.html#TransportVehicle)


### Sending Commands
Commands are first made using ```api.cmd.make.[...]()``` and then sent with ```api.cmd.sendCommand([...])```.

#### [api.cmd.make.setUserStopped](https://transportfever2.com/wiki/api/modules/api.cmd.html#make.setUserStopped)
Stops a vehicle in the same way the user can by pressing "Stop" in the vehicle window.

#### [api.cmd.make.setVehicleManualDeparture](https://transportfever2.com/wiki/api/modules/api.cmd.html#make.setVehicleManualDeparture)
Inhibits a vehicle from departing a terminal under any circumstance.

#### [api.cmd.make.setVehicleShouldDepart](https://transportfever2.com/wiki/api/modules/api.cmd.html#make.setVehicleShouldDepart)
Commands a vehicle to depart immediately.
