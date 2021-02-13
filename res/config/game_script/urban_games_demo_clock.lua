local timetable = require "celmi/timetables/timetable"
local timetableHelper = require "celmi/timetables/timetable_helper"

local clockstate = nil

function data()
    return {
        save = function()
            return { }
        end,
        
        load = function(loadedState) 
            if state == nil then return end

            
            --state = loadedState.teststate or {counter = 0} 
        end,

        update = function()
            -- save state here
            timetable.setHasTimetable(232, true)

            -- go through all vehicles and enforce waiting if neccesarry
            for vehicle,line in pairs(timetableHelper.getAllRailVehicles()) do
                if timetable.hasTimetable(line) and timetableHelper.isInStation(vehicle) then
                    print("checkWatining")
                    if timetable.waitingRequired(vehicle) then
                        timetableHelper.stopVehicle(vehicle)
                    else
                        timetableHelper.startVehicle(vehicle)
                    end
                end
            end
            
        end,
        
        guiUpdate = function()
			
            if not clockstate then
				-- element for the divider
				local line = api.gui.comp.Component.new("VerticalLine")
				-- element for the icon
                local icon = api.gui.comp.ImageView.new("ui/clock_small.tga")	
                -- element for the time
				clockstate = api.gui.comp.TextView.new("gameInfo.time.label")			
				-- add elements to ui
				local gameInfoLayout = api.gui.util.getById("gameInfo"):getLayout()
				gameInfoLayout:addItem(line) 
				gameInfoLayout:addItem(icon) 
				gameInfoLayout:addItem(clockstate) 
            end
          
            local time = timetableHelper.getTime() 
            
            if clockstate and time then
                clockstate:setText(os.date('%M:%S', time))
            end     
        end
    }
end
