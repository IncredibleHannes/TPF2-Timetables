local timetable = require "celmi/timetables/timetable"
local timetableHelper = require "celmi/timetables/timetable_helper"

local gui = require "gui"

local clockstate = nil

local menu = {window = nil, lineTableItems = {}}

local timetableGUI = {}

local UIState = {
    currentlySelectedLineTableIndex = nil ,
    currentlySelectedStationIndex = nil,
    currentlySelectedConstraintType = nil,
    currentlySelectedStationTabStation = nil
}
local co = nil
local state = nil

local timetableChanged = false
local clearConstraintWindowLaterHACK = nil

local UIStrings = {
        arr	= _("arr_i18n"),
		arrival	= _("arrival_i18n"),
		dep	= _("dep_i18n"),
		departure = _("departure_i18n"),
		unbunch_time = _("unbunch_time_i18n"),
		unbunch	= _("unbunch_i18n"),
		timetable = _("timetable_i18n"),
		timetables = _("timetables_i18n"),
		line = _("line_i18n"),
		lines = _("lines_i18n"),
		min	= _("time_min_i18n"),
		sec	= _("time_sec_i18n"),
		stations = _("stations_i18n"),
		frequency = _("frequency_i18n"),
		journey_time = _("journey_time_i18n"),
		arr_dep	= _("arr_dep_i18n"),
		no_timetable = _("no_timetable_i18n"),
		all	= _("all_i18n"),
		add	= _("add_i18n"),
		none = _("none_i18n"),
		tooltip	= _("tooltip_i18n")
}

-------------------------------------------------------------
---------------------- stationTab ---------------------------
-------------------------------------------------------------

function timetableGUI.initStationTab()
    if menu.stationTabScrollArea then UIState.floatingLayoutStationTab:removeItem(menu.scrollArea) end

    --left table
    local stationOverview = api.gui.comp.TextView.new('StationOverview')
    menu.stationTabScrollArea = api.gui.comp.ScrollArea.new(stationOverview, "timetable.stationTabStationOverviewScrollArea")
    menu.stationTabStationTable = api.gui.comp.Table.new(1, 'SINGLE')
    menu.stationTabScrollArea:setMinimumSize(api.gui.util.Size.new(300, 700))
    menu.stationTabScrollArea:setMaximumSize(api.gui.util.Size.new(300, 700))
    menu.stationTabScrollArea:setContent(menu.stationTabStationTable)
    timetableGUI.fillStationTabStationTable()
    UIState.floatingLayoutStationTab:addItem(menu.stationTabScrollArea,0,0)

    menu.stationTabLinesScrollArea = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('LineOverview'), "timetable.stationTabLinesScrollArea")
    menu.stationTabLinesTable = api.gui.comp.Table.new(3, 'NONE')
    menu.stationTabLinesScrollArea:setMinimumSize(api.gui.util.Size.new(799, 700))
    menu.stationTabLinesScrollArea:setMaximumSize(api.gui.util.Size.new(799, 700))
    menu.stationTabLinesTable:setColWidth(0,23)
    menu.stationTabLinesTable:setColWidth(1,150)

    menu.stationTabLinesScrollArea:setContent(menu.stationTabLinesTable)
    UIState.floatingLayoutStationTab:addItem(menu.stationTabLinesScrollArea,1,0)
end

function timetableGUI.fillStationTabStationTable()
    menu.stationTabStationTable:deleteAll()

    local lineNames2 ={}
    for k,_ in pairs(timetable.getAllConditionsOfAllStations()) do
        local stationName = timetableHelper.getStationName(k)
        if not (stationName == -1) then
            menu.stationTabStationTable:addRow({api.gui.comp.TextView.new(tostring(stationName))})
            lineNames2[#lineNames2 + 1] = stationName
        end
    end
    menu.stationTabStationTable:onSelect(timetableGUI.fillStationTabLineTable)

    local order = timetableHelper.getOrderOfArray(lineNames2)
    menu.stationTabStationTable:setOrder(order)
    -- select last station again
    if UIState.currentlySelectedStationTabStation
       and menu.stationTabStationTable:getNumRows() > UIState.currentlySelectedStationTabStation  then
        menu.stationTabStationTable:select(UIState.currentlySelectedStationTabStation, true)
    end

end

function timetableGUI.fillStationTabLineTable(index)
    if index == - 1 then return end
    UIState.currentlySelectedStationTabStation = index
    menu.stationTabLinesTable:deleteAll()
    local i = 0
    local constraints
    for _,v in pairs(timetable.getAllConditionsOfAllStations()) do
        if i == index then
            constraints = v
            break
        end
        i = i + 1
    end
    local lineNames2 ={}
    for k,v in  pairs(constraints) do
        local lineName = timetableHelper.getLineName(k)
        lineNames2[#lineNames2 + 1] = lineName

        local lineColour2 = api.gui.comp.TextView.new("●")

        lineColour2:setName("timetable-linecolour-" .. timetableHelper.getLineColour(tonumber(k)))
        lineColour2:setStyleClassList({"timetable-linecolour"})

        local type = timetableHelper.conditionToString(v.conditions[v.conditions.type], v.conditions.type)
        local stConditionString = api.gui.comp.TextView.new(type)
        stConditionString:setName("conditionString")
        menu.stationTabLinesTable:addRow({lineColour2, api.gui.comp.TextView.new(lineName), stConditionString})
    end
    local order = timetableHelper.getOrderOfArray(lineNames2)
    menu.stationTabLinesTable:setOrder(order)

end

-------------------------------------------------------------
---------------------- SETUP --------------------------------
-------------------------------------------------------------

function timetableGUI.initLineTable()
    if menu.scrollArea then UIState.boxlayout2:removeItem(menu.scrollArea) end
    if menu.lineHeader then UIState.boxlayout2:removeItem(menu.lineHeader) end


    menu.scrollArea = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('LineOverview'), "timetable.LineOverview")
    menu.lineTable = api.gui.comp.Table.new(3, 'SINGLE')
    menu.lineTable:setColWidth(0,28)

    menu.lineTable:onSelect(function(index)
        if not index == -1 then UIState.currentlySelectedLineTableIndex = index end
        UIState.currentlySelectedStationIndex = 0
        timetableGUI.fillStationTable(index, true)
    end)

    menu.lineTable:setColWidth(1,240)

    menu.scrollArea:setMinimumSize(api.gui.util.Size.new(300, 670))
    menu.scrollArea:setMaximumSize(api.gui.util.Size.new(300, 670))
    menu.scrollArea:setContent(menu.lineTable)

    timetableGUI.fillLineTable()

    UIState.boxlayout2:addItem(menu.scrollArea,0,1)
end

function timetableGUI.initStationTable()
    if menu.stationScrollArea then UIState.boxlayout2:removeItem(menu.stationScrollArea) end

    menu.stationScrollArea = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('stationScrollArea'), "timetable.stationScrollArea")
    menu.stationTable = api.gui.comp.Table.new(4, 'SINGLE')
    menu.stationTable:setColWidth(0,40)
    menu.stationTable:setColWidth(1,120)
    menu.stationScrollArea:setMinimumSize(api.gui.util.Size.new(500, 700))
    menu.stationScrollArea:setMaximumSize(api.gui.util.Size.new(500, 700))
    menu.stationScrollArea:setContent(menu.stationTable)
    UIState.boxlayout2:addItem(menu.stationScrollArea,0.5,0)
end

function timetableGUI.initConstraintTable()
    if menu.scrollAreaConstraint then UIState.boxlayout2:removeItem(menu.scrollAreaConstraint) end

    menu.scrollAreaConstraint = api.gui.comp.ScrollArea.new(api.gui.comp.TextView.new('scrollAreaConstraint'), "timetable.scrollAreaConstraint")
    menu.constraintTable = api.gui.comp.Table.new(1, 'NONE')
    menu.scrollAreaConstraint:setMinimumSize(api.gui.util.Size.new(300, 700))
    menu.scrollAreaConstraint:setMaximumSize(api.gui.util.Size.new(300, 700))
    menu.scrollAreaConstraint:setContent(menu.constraintTable)
    UIState.boxlayout2:addItem(menu.scrollAreaConstraint,1,0)
end

function timetableGUI.showLineMenu()
    if menu.window ~= nil then
        timetableGUI.initLineTable()
        return menu.window:setVisible(true, true)
    end
    if not api.gui.util.getById('timetable.floatingLayout') then
        local floatingLayout = api.gui.layout.FloatingLayout.new(0,1)
        floatingLayout:setId("timetable.floatingLayout")
    end
    -- new folting layout to arrange all members

    UIState.boxlayout2 = api.gui.util.getById('timetable.floatingLayout')
    UIState.boxlayout2:setGravity(-1,-1)

    timetableGUI.initLineTable()
    timetableGUI.initStationTable()
    timetableGUI.initConstraintTable()

    -- Setting up Line Tab
    menu.tabWidget = api.gui.comp.TabWidget.new("NORTH")
    local wrapper = api.gui.comp.Component.new("wrapper")
    wrapper:setLayout(UIState.boxlayout2 )
    menu.tabWidget:addTab(api.gui.comp.TextView.new(UIStrings.lines), wrapper)


    if not api.gui.util.getById('timetable.floatingLayoutStationTab') then
        local floatingLayout = api.gui.layout.FloatingLayout.new(0,1)
        floatingLayout:setId("timetable.floatingLayoutStationTab")
    end

    UIState.floatingLayoutStationTab = api.gui.util.getById('timetable.floatingLayoutStationTab')
    UIState.floatingLayoutStationTab:setGravity(-1,-1)

    timetableGUI.initStationTab()
    local wrapper2 = api.gui.comp.Component.new("wrapper2")
    wrapper2:setLayout(UIState.floatingLayoutStationTab)
    menu.tabWidget:addTab(api.gui.comp.TextView.new(UIStrings.stations),wrapper2)

    menu.tabWidget:onCurrentChanged(function(i)
        if i == 1 then
            timetableGUI.fillStationTabStationTable()
        end
    end)

    -- create final window
    menu.window = api.gui.comp.Window.new(UIStrings.timetables, menu.tabWidget)
    menu.window:addHideOnCloseHandler()
    menu.window:setMovable(true)
    menu.window:setPinButtonVisible(true)
    menu.window:setResizable(false)
    menu.window:setSize(api.gui.util.Size.new(1100, 780))
    menu.window:setPosition(200,200)
    menu.window:onClose(function()
        menu.lineTableItems = {}
    end)

end

-------------------------------------------------------------
---------------------- LEFT TABLE ---------------------------
-------------------------------------------------------------

function timetableGUI.fillLineTable()
    menu.lineTable:deleteRows(0,menu.lineTable:getNumRows())
    if not (menu.lineHeader == nil) then menu.lineHeader:deleteRows(0,menu.lineHeader:getNumRows()) end

    menu.lineHeader = api.gui.comp.Table.new(6, 'None')
    local sortAll   = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new(UIStrings.all))
    local sortBus   = api.gui.comp.ToggleButton.new(api.gui.comp.ImageView.new("ui/icons/game-menu/hud_filter_road_vehicles.tga"))
    local sortTram  = api.gui.comp.ToggleButton.new(api.gui.comp.ImageView.new("ui/TimetableTramIcon.tga"))
    local sortRail  = api.gui.comp.ToggleButton.new(api.gui.comp.ImageView.new("ui/icons/game-menu/hud_filter_trains.tga"))
    local sortWater = api.gui.comp.ToggleButton.new(api.gui.comp.ImageView.new("ui/icons/game-menu/hud_filter_ships.tga"))
    local sortAir   = api.gui.comp.ToggleButton.new(api.gui.comp.ImageView.new("ui/icons/game-menu/hud_filter_planes.tga"))

    menu.lineHeader:addRow({sortAll,sortBus,sortTram,sortRail,sortWater,sortAir})

    local lineNames = {}
    for k,v in pairs(timetableHelper.getAllRailLines()) do
        local lineColour = api.gui.comp.TextView.new("●")
        lineColour:setName("timetable-linecolour-" .. timetableHelper.getLineColour(v.id))
        lineColour:setStyleClassList({"timetable-linecolour"})
        local lineName = api.gui.comp.TextView.new(v.name)
        lineNames[k] = v.name
        lineName:setName("timetable-linename")
        local buttonImage = api.gui.comp.ImageView.new("ui/checkbox0.tga")
        if timetable.hasTimetable(v.id) then buttonImage:setImage("ui/checkbox1.tga", false) end
        local button = api.gui.comp.Button.new(buttonImage, true)
        button:setStyleClassList({"timetable-avtivateTimetableButton"})
        button:setGravity(1,0.5)
        button:onClick(function()
            local imageVeiw = buttonImage
            local hasTimetable = timetable.hasTimetable(v.id)
            if  hasTimetable then
                timetable.setHasTimetable(v.id,false)
                timetableChanged = true
                imageVeiw:setImage("ui/checkbox0.tga", false)
                -- start all stopped vehicles again if the timetable is disabled for this line
                timetable.startAllLineVehicles(v.id)
            else
                timetable.setHasTimetable(v.id,true)
                timetableChanged = true
                imageVeiw:setImage("ui/checkbox1.tga", false)
            end
        end)
        menu.lineTableItems[#menu.lineTableItems + 1] = {lineColour, lineName, button}
        menu.lineTable:addRow({lineColour,lineName, button})
    end

    local order = timetableHelper.getOrderOfArray(lineNames)
    menu.lineTable:setOrder(order)

    sortAll:onToggle(function()
        for _,v in pairs(menu.lineTableItems) do
                v[1]:setVisible(true,false)
                v[2]:setVisible(true,false)
                v[3]:setVisible(true,false)
        end
        sortBus:setSelected(false,false)
        sortTram:setSelected(false,false)
        sortRail:setSelected(false,false)
        sortWater:setSelected(false,false)
        sortAir:setSelected(false,false)
        sortAll:setSelected(true,false)
    end)

    sortBus:onToggle(function()
        local linesOfType = timetableHelper.isLineOfType("ROAD")
        for k,v in pairs(menu.lineTableItems) do
            if not(linesOfType[k] == nil) then
                v[1]:setVisible(linesOfType[k],false)
                v[2]:setVisible(linesOfType[k],false)
                v[3]:setVisible(linesOfType[k],false)
            end
        end
        sortBus:setSelected(true,false)
        sortTram:setSelected(false,false)
        sortRail:setSelected(false,false)
        sortWater:setSelected(false,false)
        sortAir:setSelected(false,false)
        sortAll:setSelected(false,false)
    end)

    sortTram:onToggle(function()
        local linesOfType = timetableHelper.isLineOfType("TRAM")
        for k,v in pairs(menu.lineTableItems) do
            if not(linesOfType[k] == nil) then
                v[1]:setVisible(linesOfType[k],false)
                v[2]:setVisible(linesOfType[k],false)
                v[3]:setVisible(linesOfType[k],false)
            end
        end
        sortBus:setSelected(false,false)
        sortTram:setSelected(true,false)
        sortRail:setSelected(false,false)
        sortWater:setSelected(false,false)
        sortAir:setSelected(false,false)
        sortAll:setSelected(false,false)
    end)

    sortRail:onToggle(function()
        local linesOfType = timetableHelper.isLineOfType("RAIL")
        for k,v in pairs(menu.lineTableItems) do
            if not(linesOfType[k] == nil) then
                v[1]:setVisible(linesOfType[k],false)
                v[2]:setVisible(linesOfType[k],false)
                v[3]:setVisible(linesOfType[k],false)
            end
        end
        sortBus:setSelected(false,false)
        sortTram:setSelected(false,false)
        sortRail:setSelected(true,false)
        sortWater:setSelected(false,false)
        sortAir:setSelected(false,false)
        sortAll:setSelected(false,false)
    end)

    sortWater:onToggle(function()
        local linesOfType = timetableHelper.isLineOfType("WATER")
        for k,v in pairs(menu.lineTableItems) do
            if not(linesOfType[k] == nil) then
                v[1]:setVisible(linesOfType[k],false)
                v[2]:setVisible(linesOfType[k],false)
                v[3]:setVisible(linesOfType[k],false)
            end
        end
        sortBus:setSelected(false,false)
        sortTram:setSelected(false,false)
        sortRail:setSelected(false,false)
        sortWater:setSelected(true,false)
        sortAir:setSelected(false,false)
        sortAll:setSelected(false,false)
    end)

    sortAir:onToggle(function()
        local linesOfType = timetableHelper.isLineOfType("AIR")
        for k,v in pairs(menu.lineTableItems) do
            if not(linesOfType[k] == nil) then
                v[1]:setVisible(linesOfType[k],false)
                v[2]:setVisible(linesOfType[k],false)
                v[3]:setVisible(linesOfType[k],false)
            end
        end
        sortBus:setSelected(false,false)
        sortTram:setSelected(false,false)
        sortRail:setSelected(false,false)
        sortWater:setSelected(false,false)
        sortAir:setSelected(true,false)
        sortAll:setSelected(false,false)
    end)

    UIState.boxlayout2:addItem(menu.lineHeader,0,0)

end

-------------------------------------------------------------
---------------------- Middle TABLE -------------------------
-------------------------------------------------------------

-- params
-- index: index of currently selected line
-- bool: emit select signal when building table
function timetableGUI.fillStationTable(index, bool)
    --initial checks
    if not index then return end
    if not(timetableHelper.getAllRailLines()[index+1]) or (not menu.stationTable)then return end

    -- initial cleanup
    menu.stationTable:deleteAll()

    UIState.currentlySelectedLineTableIndex = index
    local lineID = timetableHelper.getAllRailLines()[index+1].id


    local header1 = api.gui.comp.TextView.new(UIStrings.frequency .. " " .. timetableHelper.getFrequency(lineID))
    local header2 = api.gui.comp.TextView.new("")
    local header3 = api.gui.comp.TextView.new("")
    local header4 = api.gui.comp.TextView.new("")
    menu.stationTable:setHeader({header1,header2, header3, header4})

    local stationLegTime = timetableHelper.getLegTimes(lineID)
    --iterate over all stations to display them
    for k, v in pairs(timetableHelper.getAllStations(lineID)) do
        menu.lineImage = {}
        local vehiclePositions = timetableHelper.getTrainLocations(lineID)
        if vehiclePositions[tostring(k-1)] then
            if vehiclePositions[tostring(k-1)].atTerminal then
                if vehiclePositions[tostring(k-1)].countStr == "MANY" then
                    menu.lineImage[k] = api.gui.comp.ImageView.new("ui/timetable_line_train_in_station_many.tga")
                else
                    menu.lineImage[k] = api.gui.comp.ImageView.new("ui/timetable_line_train_in_station.tga")
                end
            else
                if vehiclePositions[tostring(k-1)].countStr == "MANY" then
                    menu.lineImage[k] = api.gui.comp.ImageView.new("ui/timetable_line_train_en_route_many.tga")
                else
                    menu.lineImage[k] = api.gui.comp.ImageView.new("ui/timetable_line_train_en_route.tga")
                end
            end
        else
            menu.lineImage[k] = api.gui.comp.ImageView.new("ui/timetable_line.tga")
        end
        local x = menu.lineImage[k]
        menu.lineImage[k]:onStep(function()
            if not x then print("ERRROR") return end
            local vehiclePositions2 = timetableHelper.getTrainLocations(lineID)
            if vehiclePositions2[tostring(k-1)] then
                if vehiclePositions2[tostring(k-1)].atTerminal then
                    if vehiclePositions2[tostring(k-1)].countStr == "MANY" then
                        x:setImage("ui/timetable_line_train_in_station_many.tga", false)
                    else
                        x:setImage("ui/timetable_line_train_in_station.tga", false)
                    end
                else
                    if vehiclePositions2[tostring(k-1)].countStr == "MANY" then
                        x:setImage("ui/timetable_line_train_en_route_many.tga", false)
                    else
                        x:setImage("ui/timetable_line_train_en_route.tga", false)
                    end
                end
            else
                x:setImage("ui/timetable_line.tga", false)
            end
        end)

        local station = timetableHelper.getStation(v)


        local stationNumber = api.gui.comp.TextView.new(tostring(k))

        stationNumber:setStyleClassList({"timetable-stationcolour"})
        stationNumber:setName("timetable-stationcolour-" .. timetableHelper.getLineColour(lineID))
        stationNumber:setMinimumSize(api.gui.util.Size.new(30, 30))


        local stationName = api.gui.comp.TextView.new(station.name)
        stationName:setName("stationName")

        local jurneyTime
        if (stationLegTime and stationLegTime[k]) then
            jurneyTime = api.gui.comp.TextView.new(UIStrings.journey_time .. ": " .. os.date('%M:%S', stationLegTime[k]))
        else
            jurneyTime = api.gui.comp.TextView.new("")
        end
        jurneyTime:setName("conditionString")

        local stationNameTable = api.gui.comp.Table.new(1, 'NONE')
        stationNameTable:addRow({stationName})
        stationNameTable:addRow({jurneyTime})
        stationNameTable:setColWidth(0,120)


        local conditionType = timetable.getConditionType(lineID, k)
        local condStr = timetableHelper.conditionToString(timetable.getConditions(lineID, k, conditionType), conditionType)
        local conditionString = api.gui.comp.TextView.new(condStr)
        conditionString:setName("conditionString")


        conditionString:setMinimumSize(api.gui.util.Size.new(285,50))
        conditionString:setMaximumSize(api.gui.util.Size.new(285,50))

        menu.stationTable:addRow({stationNumber,stationNameTable, menu.lineImage[k], conditionString})
    end

    menu.stationTable:onSelect(function (tableIndex)
        if not (tableIndex == -1) then
            UIState.currentlySelectedStationIndex = tableIndex
            timetableGUI.initConstraintTable()
            timetableGUI.fillConstraintTable(tableIndex,lineID)
        end

    end)

    -- keep track of currently selected station and resets if nessesarry
    if UIState.currentlySelectedStationIndex then
        if menu.stationTable:getNumRows() > UIState.currentlySelectedStationIndex and not(menu.stationTable:getNumRows() == 0) then
            menu.stationTable:select(UIState.currentlySelectedStationIndex, bool)
        end
    end

end

-------------------------------------------------------------
---------------------- Right TABLE --------------------------
-------------------------------------------------------------

function timetableGUI.clearConstraintWindow()
    -- initial cleanup
    menu.constraintTable:deleteRows(1, menu.constraintTable:getNumRows())
end

function timetableGUI.fillConstraintTable(index,lineID)
    --initial cleanup
    if index == -1 then
        menu.constraintTable:deleteAll()
        return
    end
    index = index + 1
    menu.constraintTable:deleteAll()


    -- combobox setup
    local comboBox = api.gui.comp.ComboBox.new()
    comboBox:addItem(UIStrings.no_timetable)
    comboBox:addItem(UIStrings.arr_dep)
    --comboBox:addItem("Minimum Wait")
    comboBox:addItem(UIStrings.unbunch)
    --comboBox:addItem("Every X minutes")
    comboBox:setGravity(1,0)

    local constraintIndex = timetableHelper.constraintStringToInt(timetable.getConditionType(lineID, index))


    comboBox:onIndexChanged(function (i)
        if i == -1 then return end
        timetable.setConditionType(lineID, index, timetableHelper.constraintIntToString(i))
        timetableChanged = true
        timetableGUI.initStationTable()
        timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
        UIState.currentlySelectedConstraintType = i

        timetableGUI.clearConstraintWindow()
        if i == 1 then
            timetableGUI.makeArrDepWindow(lineID, index)
        elseif i == 2 then
            timetableGUI.makeDebounceWindow(lineID, index)
        end
    end)


    local infoImage = api.gui.comp.ImageView.new("ui/info_small.tga")
    infoImage:setTooltip(UIStrings.tooltip)
    infoImage:setName("timetable-info-icon")

    local table = api.gui.comp.Table.new(2, 'NONE')
    table:addRow({infoImage,comboBox})
    menu.constraintTable:addRow({table})
    comboBox:setSelected(constraintIndex, true)
end


function timetableGUI.makeArrDepWindow(lineID, stationID)
    if not menu.constraintTable then return end
    local conditions = timetable.getConditions(lineID,stationID, "ArrDep")

    -- setup add button
    local addButton = api.gui.comp.Button.new(api.gui.comp.TextView.new(UIStrings.add), true)
    addButton:setGravity(1,0)
    addButton:onClick(function()
        timetable.addCondition(lineID,stationID, {type = "ArrDep", ArrDep = {{0,0,0,0}}})
        timetableChanged = true
        clearConstraintWindowLaterHACK = function()
            timetableGUI.initStationTable()
            timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
            timetableGUI.clearConstraintWindow()
            timetableGUI.makeArrDepWindow(lineID, stationID)
        end
    end)

    --setup header
    local headerTable = api.gui.comp.Table.new(4, 'NONE')
    headerTable:setColWidth(0,125)
    headerTable:setColWidth(1,76)
    headerTable:setColWidth(2,50)
    headerTable:setColWidth(3,48)
    headerTable:addRow({api.gui.comp.TextView.new(""),api.gui.comp.TextView.new(UIStrings.min),api.gui.comp.TextView.new(UIStrings.sec),addButton})
    menu.constraintTable:addRow({headerTable})


    -- setup arrival and depature content
    for k,v in pairs(conditions) do
        menu.constraintTable:addRow({api.gui.comp.Component.new("HorizontalLine")})


        local linetable = api.gui.comp.Table.new(5, 'NONE')
        local arivalLabel =  api.gui.comp.TextView.new(UIStrings.arrival .. ":  ")

        arivalLabel:setMinimumSize(api.gui.util.Size.new(80, 30))
        arivalLabel:setMaximumSize(api.gui.util.Size.new(80, 30))

        local arrivalMin = api.gui.comp.DoubleSpinBox.new()
        arrivalMin:setMinimum(0,false)
        arrivalMin:setMaximum(59,false)
        arrivalMin:setValue(v[1],false)
        arrivalMin:onChange(function(value)
            timetable.updateArrDep(lineID, stationID, k, 1, value)
            timetableChanged = true
            timetableGUI.initStationTable()
            timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
        end)

        local arrivalSec = api.gui.comp.DoubleSpinBox.new()
        arrivalSec:setMinimum(0,false)
        arrivalSec:setMaximum(59,false)
        arrivalSec:setValue(v[2],false)
        arrivalSec:onChange(function(value)
            timetable.updateArrDep(lineID, stationID, k, 2, value)
            timetableChanged = true
            timetableGUI.initStationTable()
            timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
        end)

        local deleteButton = api.gui.comp.Button.new(api.gui.comp.TextView.new("X") ,true)
        deleteButton:onClick(function()
            timetable.removeCondition(lineID, stationID, "ArrDep", k)
            timetableChanged = true
            clearConstraintWindowLaterHACK = function()
                timetableGUI.initStationTable()
                timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
                timetableGUI.clearConstraintWindow()
                timetableGUI.makeArrDepWindow(lineID, stationID)
            end
        end)

        linetable:addRow({
            arivalLabel,
            arrivalMin,
            api.gui.comp.TextView.new(":"),
            arrivalSec,
            deleteButton
        })
        menu.constraintTable:addRow({linetable})

        local departureLabel =  api.gui.comp.TextView.new(UIStrings.departure .. ":  ")

        departureLabel:setMinimumSize(api.gui.util.Size.new(80, 30))
        departureLabel:setMaximumSize(api.gui.util.Size.new(80, 30))
        local departureMin = api.gui.comp.DoubleSpinBox.new()
        departureMin:setMinimum(0,false)
        departureMin:setMaximum(59,false)
        departureMin:setValue(v[3],false)
        departureMin:onChange(function(value)
            timetable.updateArrDep(lineID, stationID, k, 3, value)
            timetableChanged = true
            timetableGUI.initStationTable()
            timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
        end)

        local departureSec = api.gui.comp.DoubleSpinBox.new()
        departureSec:setMinimum(0,false)
        departureSec:setMaximum(59,false)
        departureSec:setValue(v[4],false)
        departureSec:onChange(function(value)
            timetable.updateArrDep(lineID, stationID, k, 4, value)
            timetableChanged = true
            timetableGUI.initStationTable()
            timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
        end)


        local deletePlaceholder = api.gui.comp.TextView.new(" ")
        deletePlaceholder:setMinimumSize(api.gui.util.Size.new(12, 30))
        deletePlaceholder:setMaximumSize(api.gui.util.Size.new(12, 30))

        local linetable2 = api.gui.comp.Table.new(5, 'NONE')
        linetable2:addRow({
            departureLabel,
            departureMin,
            api.gui.comp.TextView.new(":"),
            departureSec,
            deletePlaceholder
        })
        menu.constraintTable:addRow({linetable2})


        menu.constraintTable:addRow({api.gui.comp.Component.new("HorizontalLine")})
    end

end

function timetableGUI.makeDebounceWindow(lineID, stationID)
    if not menu.constraintTable then return end
    local condition2 = timetable.getConditions(lineID,stationID, "debounce")

    local debounceTable = api.gui.comp.Table.new(4, 'NONE')
    debounceTable:setColWidth(0,150)
    debounceTable:setColWidth(1,62)
    debounceTable:setColWidth(2,25)
    debounceTable:setColWidth(3,63)

    local debounceMin = api.gui.comp.DoubleSpinBox.new()
    debounceMin:setMinimum(0,false)
    debounceMin:setMaximum(59,false)

    debounceMin:onChange(function(value)
        timetable.updateDebounce(lineID, stationID,  1, value)
        timetableChanged = true
        timetableGUI.initStationTable()
        timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
    end)

    if condition2 and condition2[1] then
        debounceMin:setValue(condition2[1],false)
    end


    local debounceSec = api.gui.comp.DoubleSpinBox.new()
    debounceSec:setMinimum(0,false)
    debounceSec:setMaximum(59,false)

    debounceSec:onChange(function(value)
        timetable.updateDebounce(lineID, stationID, 2, value)
        timetableChanged = true
        timetableGUI.initStationTable()
        timetableGUI.fillStationTable(UIState.currentlySelectedLineTableIndex, false)
    end)
    if condition2 and condition2[2] then
        debounceSec:setValue(condition2[2],false)
    end

    debounceTable:addRow({api.gui.comp.TextView.new(UIStrings.unbunch_time .. ":"), debounceMin,api.gui.comp.TextView.new(":"), debounceSec})

    menu.constraintTable:addRow({debounceTable})

end

-------------------------------------------------------------
--------------------- OTHER ---------------------------------
-------------------------------------------------------------


function timetableGUI.timetableCoroutine()
    while true do
        local vehiclesWithLines = timetableHelper.getAllTimetableRailVehicles(timetable.hasTimetable)
        for vehicle,_ in pairs(vehiclesWithLines) do
            if timetableHelper.isInStation(vehicle) then
                if timetable.waitingRequired(vehicle) then
                    timetableHelper.stopVehicle(vehicle)
                else
                    timetableHelper.startVehicle(vehicle)
                end
            end
            coroutine.yield()
        end
        coroutine.yield()
    end
end

function data()
    return {
        --engine Thread

        handleEvent = function (_, id, _, param)
            if id == "timetableUpdate" then
                if state == nil then state = {timetable = {}} end
                state.timetable = param
                timetable.setTimetableObject(state.timetable)
                timetableChanged = true
            end
        end,

        save = function()
            return state
        end,

        load = function(loadedState)
            if loadedState == nil  or next(loadedState) == nil then  return end
            if loadedState.timetable then
                if state == nil then
                    timetable.setTimetableObject(loadedState.timetable)
                end
            end
            state = loadedState or {timetable = {}}
        end,

        update = function()
            if state == nil then state = {timetable = {}}end
            if co == nil or coroutine.status(co) == "dead" then
                co = coroutine.create(timetableGUI.timetableCoroutine)
            end
            for _ = 0, 20 do
                local err, msg = coroutine.resume(co)
                if not err then print(msg) end
            end

            state.timetable = timetable.getTimetableObject()

        end,

        guiUpdate = function()
            if timetableChanged then
                game.interface.sendScriptEvent("timetableUpdate", "", timetable.getTimetableObject())
                timetableChanged = false
            end
            if clearConstraintWindowLaterHACK then
                clearConstraintWindowLaterHACK()
                clearConstraintWindowLaterHACK = nil
            end

            if not clockstate then
				-- element for the divider
				local line = api.gui.comp.Component.new("VerticalLine")
				-- element for the icon
                local icon = api.gui.comp.ImageView.new("ui/clock_small.tga")
                -- element for the time
				clockstate = api.gui.comp.TextView.new("gameInfo.time.label")

                local buttonLabel = gui.textView_create("gameInfo.timetables.label", UIStrings.timetable)

                local button = gui.button_create("gameInfo.timetables.button", buttonLabel)
                button:onClick(function ()
                    local err, msg = pcall(timetableGUI.showLineMenu)
                    if not err then
                        menu.window:close()
                        menu.window = nil
                        print(msg)
                    end
                end)
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
