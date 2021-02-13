local timetable = require "celmi/timetables/timetable"
local timetableHelper = require "celmi/timetables/timetable_helper"

local clockstate = nil


function data()
    return {       
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

            -- go through all vehicles and enforce waiting if neccesarry
            for vehicle,line in timetableHelper.getAllRailVehicles() do
                if timetable.hasTimetable(line) and timetableHelper.isInStation(vehicle) then
                    if timetable.waitingRequired(vehicle) then
                        timetableHelper.stopVehicle(vehicle)
                    else
                        timetableHelper.startVehicle(vehicle)
                    end
                end
            end

            local time = timetableHelper.getTime() 

            if clockstate and time then
                clockstate:setText(os.date('%M:%S', time))
            end     
        end
    }
end
