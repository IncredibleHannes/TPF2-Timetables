# Documentation
## Introduction
This is the technical documentation for the TPF2-Timetables mod. It is intended for developers that want to understand or modify the code. Normal users should instead read the [README](README.md).

---

## Overview
### GUI
The GUI is implemented in the `timetable_gui.lua` file. It is responsible for creating all the menus and for handling the user input. It manages a timeteble object, that specifies if and when a vehicle should stop at a statio.

### Control Logic
The control logic is implemented in the `timetable.lua` file. It reads the timetable object and decides wether a particular vehicle should wait at that time. 

The central function is `timetable.waitingRequired()`, which is called once every ingame second for each vehicle that is currently in a station.

### Game API Interaction
The mod communicates with the game through helper functions contained in the `timetable_helper.lua` file. This includes getting the current time or information about vehicles and stations, and telling vehicles to start or stop.

---

## Wait Logic
Wether or not a train needs to wait depends on a number of factors: 
- the type of timetable constraint 
- the last departure time
- the current time

Those factors can be different for each stop on each line. For every stop, the script tracks the last recorded departure and a list of vehicles currently waiting along with their intended departure time.

When a vehicle is in a station, the function `timetable.waitingRequired()` is repeatedly called. If a timetable constraint exists and the vehicle is not not registered in the waiting list, it assumes the vehicle just arrived and assigns a departure time according to the rules layed out below.  

### Arrival/Departure Constraint
With Arr/Dep constraints the user specifies a number of arrival/departure slots. The departure time specifies whan a vehicle may depart, while the arrival time specifies the earliest arrival time after which a vehicle is considered for that slot. Starting at the last departure, a vehicle will be assigned the last slot that has an arrival time in the past.

The current behavior is that a vehicle will always try to use the first departure slot after the last departure *as long as* the arrival time of the next slot hasn't already been reached.

#### Example
For example, the slots for a stop might look like this:

Arrival | Departure
--- | ---
03:00 | 05:00
13:00 | 15:00
23:00 | 25:00
33:00 | 35:00
43:00 | 45:00
53:00 | 55:00

Let's say the last departure was at 15:00, the next train is due at 23:00 and arrives with a delay of 1 minute at 24:00. The next slot after the last departure only accepts arrivals after 33:00, which is still in the future. So the departure at 25:00 is assigned. 

The same is true if the train arrived one minute early. In fact, a train will alway use the next slot or a later one, even if it arrives only seconds after the last train.

Let's now look at delays approaching the service frequency of 10 minutes. At a delay of 9 minutes it will arrive at 32:00. The slot departing at 25:00 is still satisfies both conditions because the next arrival time of 33:00 is still in the future. It will depart as soon as loading has completed.

After a delay of 10 minutes, the next arrival time of 33:00 is no longer in the future. It therefor switches to that slot and waits until 35:00 to depart. 

#### Future Plans
This behavior is not optimal, as it will lead to vehicles trying to catch up to the original timetable even with unrecoverable delays. However the previous behavior wasn't ideal either, because hard to control when vehicle would give up on their original slot, sometimes leading to vehicles bunching up.

I am thinking about adding the ability to specify a maximum tolerable delay, which will be the threshold after which the train will wait for the next slot. For now my advice is:
- Add a bit of buffer times in bigger stations
- Add lots of buffer time at the end of lines
- Look at the arrival time as the earliest acceptable time to be considered for a departure slot, not as the intended arrival time


### Unbunch Constraints
The objective of Unbunch constraints is to guarantee a minimum separation of trains on a line. It is useful when having fixed departure times is less important than maintaining a regular spacing.

The departure time assigned is always the last departure plus the time span set in the constraint editor. 

---

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
