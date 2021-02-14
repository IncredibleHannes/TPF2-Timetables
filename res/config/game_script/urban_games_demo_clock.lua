local timetable = require "celmi/timetables/timetable"
local timetableHelper = require "celmi/timetables/timetable_helper"

local gui = require "gui"

local clockstate = nil

local menu = {window = nil}

local UIState = { 
    currentlySelectedLineTableIndex = nil ,
    currentlySelectedStationIndex = nil
}

function fillLineTable()
    menu.lineTable:deleteAll()
    for k,v in pairs(timetableHelper.getAllRailLines()) do
        lineColour = api.gui.comp.TextView.new("O")
        lineColour:setName("timetable-linecolour-" .. timetableHelper.getLineColour(v))
        lineName = api.gui.comp.TextView.new(v.name)
        lineName:setName("timetable-linename")
        menu.lineTable:addRow({lineColour,lineName})
    end
end

function selectLine(index)
    if not index then return end
    if not(timetableHelper.getAllRailLines()[index+1]) or (not menu.stationTable)then return end
    UIState.currentlySelectedLineTableIndex = index
    menu.stationTable:deleteAll()
    local lineID = timetableHelper.getAllRailLines()[index+1].id

    --iterate over all stations to display them
    for k, v in pairs(timetableHelper.getAllStations(lineID)) do
        local station = timetableHelper.getStation(v)
        local stationNumber = api.gui.comp.TextView.new(tostring(k))
        stationNumber:setName("timetable-stationcolour-" .. timetableHelper.getLineColour(lineID))
        stationNumber:setMinimumSize(api.gui.util.Size.new(28, 28))
        

        local conditionType = api.gui.comp.TextView.new(timetable.getConditionType(lineID, k))
        conditionType:setMinimumSize(api.gui.util.Size.new(150,60))
        conditionType:setMaximumSize(api.gui.util.Size.new(150,60))
      
        menu.stationTable:addRow({stationNumber,api.gui.comp.TextView.new(station.name), conditionType})
        
        menu.stationTable:onSelect(function (index)
            if not (index == -1) then UIState.currentlySelectedStationIndex = index end
            selectStation(index,lineID,index) 
        end)
    end

    -- keep track of currently selected station and resets if nessesarry
    print(UIState.currentlySelectedStationIndex )
    if UIState.currentlySelectedStationIndex then 
        if menu.stationTable:getNumCols() > UIState.currentlySelectedStationIndex  then 
            menu.stationTable:select(UIState.currentlySelectedStationIndex, true)
        end
    else
        menu.stationTable:select(0, true)
    end


end

function selectStation(index,lineID, lineNumber)
    if index == -1 then
        menu.constraintTable:deleteAll()
        return 
    end
    index = index + 1
    menu.constraintTable:deleteAll()
    
    local comboBox = api.gui.comp.ComboBox.new()

    comboBox:addItem("None")
    comboBox:addItem("ArrDep")
    comboBox:addItem("minWait")
    comboBox:addItem("debounce")
    comboBox:addItem("moreFancey")

    comboBox:setGravity(1,0)

    comboBox:setSelected(timetableHelper.constraintStringToInt(timetable.getConditionType(lineID, index)), false)

    comboBox:onIndexChanged(function (i) 
        timetable.setConditionType(lineID, index, timetableHelper.constraintIntToString(i))
        selectLine(UIState.currentlySelectedLineTableIndex)
    end)

    menu.constraintTable:addRow({comboBox})
    
    local conditionType = timetable.getConditionType(lineID, index)
    menu.constraintTable:addRow({api.gui.comp.TextView.new(conditionType)})


end

function showLineMenu()
    print("test")
    if menu.window ~= nil then
        fillLineTable()
        return menu.window:setVisible(true, true)  
    end
    -- new folting layout to arrange all members
    local floatingLayout = api.gui.layout.FloatingLayout.new(0,1)
    floatingLayout:setId("timetable.floatingLayout")
    
   
    -- setup lineTable
    local scrollArea = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('LineOverview'), "timetable.LineOverview")
    menu.lineTable = api.gui.comp.Table.new(2, 'SINGLE')
    menu.lineTable:setColWidth(0,28)
    fillLineTable()
    menu.lineTable:onSelect(function(index)
        if not index == -1 then UIState.currentlySelectedLineTableIndex = index end
        UIState.currentlySelectedStationIndex = 0
        selectLine(index)
    end)
    scrollArea:setContent(menu.lineTable)
    scrollArea:setMinimumSize(api.gui.util.Size.new(300, 400))
    scrollArea:setMaximumSize(api.gui.util.Size.new(300, 400))


    -- setup station table
    local stationScrollArea = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('stationScrollArea'), "timetable.stationScrollArea")
    menu.stationTable = api.gui.comp.Table.new(3, 'SINGLE')
    menu.stationTable:setColWidth(0,40)
    stationScrollArea:setMinimumSize(api.gui.util.Size.new(400, 400))
    stationScrollArea:setMaximumSize(api.gui.util.Size.new(400, 400))
    stationScrollArea:setContent(menu.stationTable)

    -- setup constraint tabl
    
    local scrollAreaConstraint = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('scrollAreaConstraint'), "timetable.scrollAreaConstraint")
    menu.constraintTable = api.gui.comp.Table.new(1, 'NONE') 
    scrollAreaConstraint:setContent(menu.constraintTable)
    scrollAreaConstraint:setMinimumSize(api.gui.util.Size.new(300, 400))
    scrollAreaConstraint:setMaximumSize(api.gui.util.Size.new(300, 400))

    -- create final window
    local boxlayout2 = api.gui.util.getById('timetable.floatingLayout')
    boxlayout2:setGravity(-1,-1)
    boxlayout2:addItem(scrollArea,0,0)
    boxlayout2:addItem(stationScrollArea,0.5,0)
    boxlayout2:addItem(scrollAreaConstraint,1,0)

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
