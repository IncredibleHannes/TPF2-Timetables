local timetable = require "celmi/timetables/timetable"
local timetableHelper = require "celmi/timetables/timetable_helper"

local gui = require "gui"

local clockstate = nil

local menu = {window = nil}

function showLineMenu()
    print("test")
    if menu.window ~= nil then return menu.window:setVisible(true, true) end
    -- id + orientatin "VERTICAL" | "HORIZONTAL"
    local floatingLayout = api.gui.layout.FloatingLayout.new(1,1)
    floatingLayout:setId("timetable.floatingLayout")
    
    -- Label + true
    local testButton = api.gui.comp.Button.new(api.gui.comp.TextView.new('test'), true)
    -- lable * id
    local scrollArea = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('LineOverview'), "timetable.LineOverview")
    -- numCols + mode 
    local lineTable = api.gui.comp.Table.new(1, 'SINGLE')
    local boxlayout2 = api.gui.util.getById('timetable.floatingLayout')


    for k,v in pairs(timetableHelper.getAllRailLines()) do
        lineTable:addRow({api.gui.comp.TextView.new(k)})
    end

    scrollArea:setContent(lineTable)
    scrollArea:setMinimumSize(api.gui.util.Size.new(300, 400))
    scrollArea:setMaximumSize(api.gui.util.Size.new(300, 400))
    
   

    boxlayout2:addItem(testButton,2,2)
    boxlayout2:addItem(scrollArea,1,1)
    menu.window = api.gui.comp.Window.new('Timetables',  floatingLayout)
    menu.window:addHideOnCloseHandler()
    menu.window:setMovable(true)
    menu.window:setPinButtonVisible(true)
    menu.window:setResizable(false)
    menu.window:setSize(api.gui.util.Size.new(1000, 440))

end

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

                
                local buttonLabel = gui.textView_create("gameInfo.timetables.label", "TestText")
                local button = gui.button_create("gameInfo.timetables.button", buttonLabel)
                button:onClick(showLineMenu)
                game.gui.boxLayout_addItem("gameInfo.layout", button.id)
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
