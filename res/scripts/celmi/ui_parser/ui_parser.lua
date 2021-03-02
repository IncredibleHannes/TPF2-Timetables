

local UIParser = {}

UIParser.parseFloatingLayout = function(table)
    local floatingLayout = api.gui.layout.FloatingLayout.new(table.spacing,table.factor)
    if table.id then floatingLayout:setId("timetable.floatingLayoutStationTab") end
    if table.gravity then floatingLayout:setGravity(table.gravity[1], table.gravity[1]) end
    if table.content then
        for k,v in pairs(table.content) do
            floatingLayout:addItem(UIParser.parse(v),k[1], k[2])
        end
    end
    return  floatingLayout
end

UIParser.parseScrollArea  = function(table)
    local scrollArea = api.gui.comp.ScrollArea.new(UIParser.parse(table.content), table.id)
    if table.minimumSize then scrollArea:setMinimumSize(api.gui.util.Size.new(table.minimumSize[1], table.minimumSize[2])) end
    if table.maximumSize then scrollArea:setMinimumSize(api.gui.util.Size.new(table.maximumSize[1], table.maximumSize[2])) end
    scrollArea:setContent(UIParser.parse(table.content))
    return scrollArea
end

UIParser.parseTable = function(table)
    local uiTable = api.gui.comp.Table.new(table.nrows, table.selectMode)
    if table.id then uiTable:setId(table.id) end
    if table.colWidth then
        for k,v in pairs(table.colWidth) do
            uiTable:setColWidth(k,v)
        end
    end
    return uiTable
end

UIParser.parse = function(table)
    for k,v in pairs(table) do
        if k == "FloatingLayout" then
            return UIParser.parseFloatingLayout(v)
        elseif k == "ScrollArea" then
            return UIParser.parseScrollArea(table)
        elseif k == "Table" then
            return UIParser.parseTable(table)
        end
    end
end


return UIParser.parse