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


## Proposed Wait Logic
The current wait logic seems more complex than necessary. The purpose of having both vehiclesWaiting and vehiclesDeparting is unclear. But how else might it work?

For each line and station there is a list of vehicles that need to wait. For every vehicle a departure time in seconds since game start is stored. 

For each line and station the last departure time is tracked.

These are the states a vehicle can be in:
- Newly Arrived (not in wait list):
	- Choose the next planned departure time after the last recorded departure
	- Add vehicle to wait list with that departure time
- Waiting (time < departure time)
	- Retain vehicle in station 
- Departing (time > departure time)
	- Remove from wait list
	- Update last departure

The logic for choosing the next departure may have to be reworked. With bigger delays it might be better to choose the next departure after arrival. Maybe the arrival time might be helpful there?

Maybe we could start at the last recorded departure and take the next departure after that. Then shift a departure forward until the next arrival after that is in the future.

Let's say we have a timetable with arrival at 00:00 and departure at 05:00. The timetable repeats every 15 minutes.

- The last departure was at 05:00 and our vehicle arrives at 13:30 (01:30 early)
	- The next departure after the last one would be 20:00
- The last departure was at 05:00 and our vehicle arrives at 24:00 (04:00 late)
	- The next departure after the last one would be 20:00
	- The next arrival after that one would be 30:00 -> in the future
- The last departure was at 05:00 and our vehicle arrives at 38:00 (18:00 late)
	- The next departure after the last one would be 20:00
	- The next arrival after that one would be 30:00 -> 08:00 late
	- Shift to 