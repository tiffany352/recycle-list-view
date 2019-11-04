--[[
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

local Roact = require(script.Parent.Roact)
local RecycleItem = require(script.RecycleItem)
local e = Roact.createElement

local function calculateScrollInfo(currentIndex, scrollDelta, viewHeight, buffer, numItems, getItemSize)
    local newIndex
    local scrollPos

    local function canScrollDown(testIndex)
        local height = 0
        for index = testIndex + 1, numItems do
            height = height + getItemSize(index)
            if height > viewHeight then return true end
        end
        return false
    end

    local currentItemSize = getItemSize(currentIndex)
    if scrollDelta < 0 then
        if currentIndex > 1 then
            newIndex = currentIndex - 1
            scrollPos = scrollDelta + getItemSize(newIndex)
            while scrollPos < 0 and newIndex > 1 do
                -- Scroll up
                newIndex = newIndex - 1
                scrollPos = scrollPos + getItemSize(newIndex)
            end
        else
            newIndex = currentIndex
            scrollPos = 0
        end
    elseif scrollDelta > currentItemSize then
        if canScrollDown(currentIndex) then
            newIndex = currentIndex + 1
            scrollPos = scrollDelta - currentItemSize
            while scrollPos > getItemSize(newIndex) and canScrollDown(newIndex) do
                -- Scroll down
                newIndex = newIndex + 1
                scrollPos = scrollPos - getItemSize(newIndex)
            end
        else
            newIndex = currentIndex
            scrollPos = currentItemSize
        end
    else
        newIndex = currentIndex
        scrollPos = scrollDelta
    end
    local newItemSize = getItemSize(newIndex)

    local first = math.max(1, newIndex - buffer)

    local bufferSize = 0
    for index = first, newIndex - 1 do
        bufferSize = bufferSize + getItemSize(index)
    end

    local last = newIndex
    local height = getItemSize(last)
    while height < viewHeight + scrollPos and last <= numItems do
        last = last + 1
        height = height + getItemSize(last)
    end

    local scrollbarInfo = {
        first = (newIndex + scrollPos / newItemSize) / numItems,
        last = (last + (scrollPos + viewHeight - height) / getItemSize(last)) / numItems,
    }

    -- Add buffer
    last = math.min(last + buffer, numItems)

    local doDebug = false
    if doDebug then
        local inputs = {
            currentIndex = currentIndex,
            scrollDelta = scrollDelta,
            viewHeight = viewHeight,
            buffer = buffer,
            numItems = numItems,
        }

        local outputs = {
            newIndex = newIndex,
            first = first,
            last = last,
            bufferSize = bufferSize,
            scrollPos = scrollPos,
        }

        local lines = {}
        table.insert(lines, "== Updating scroll info ==")
        table.insert(lines, "Inputs:")
        for key, value in pairs(inputs) do
            table.insert(lines, string.format("  %s: %s", key, tostring(value)))
        end
        table.insert(lines, "Outputs:")
        for key, value in pairs(outputs) do
            table.insert(lines, string.format("  %s: %s", key, tostring(value)))
        end
        print(table.concat(lines, '\n'))
    end

    return newIndex, first, last, bufferSize, scrollPos, scrollbarInfo
end

local RecycleListView = Roact.Component:extend("RecycleListView")

RecycleListView.defaultProps = {
    LayoutOrder = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),

    itemPadding = UDim.new(0, 0),
    -- Must be at least 1
    itemBuffer = 1,

    items = {},
    getStableId = function(item, index)
        return tostring(index)
    end,
    renderItem = function(item, index)
        return nil
    end,
    -- Should be a lower bound
    estimateItemSize = function(item, index)
        return 100
    end,
}

function RecycleListView:init()
    self.state = {
        firstIndex = 1,
        lastIndex = 0,
    }
    self.currentIndex = 1
    self.itemSizes = {}
    self.scrollRef = Roact.createRef()
    self.bufferSize, self.setBufferSize = Roact.createBinding(0)
    self.scrollbarInfo, self.setScrollbarInfo = Roact.createBinding({ first = 0, last = 1 })

    self.onCanvasPosition = function(rbx)
        local value = rbx.CanvasPosition.Y - 1000
        self:updateScrollInfo(value)
    end

    self.onResize = function(rbx)
        local value = rbx.CanvasPosition.Y - 1000
        self:updateScrollInfo(value)
    end
end

function RecycleListView:getSize(index)
    local item = self.itemSizes[index]
    if item then
        return item:getValue()
    else
        return self.props.estimateItemSize(self.props.items[index], index)
    end
end

function RecycleListView:updateScrollInfo(delta)
    local newIndex, first, last, bufferSize, scrollPos, scrollbarInfo = calculateScrollInfo(
        self.currentIndex,
        delta,
        self.scrollRef.current.AbsoluteSize.Y,
        self.props.itemBuffer,
        #self.props.items,
        function(index)
            return self:getSize(index)
        end
    )
    self.currentIndex = newIndex
    self:setState({
        firstIndex = first,
        lastIndex = last,
    })
    self.setBufferSize(bufferSize)
    self.scrollRef.current.CanvasPosition = Vector2.new(0, scrollPos + 1000)
    self.setScrollbarInfo(scrollbarInfo)
end

function RecycleListView:didMount()
    self.scrollRef.current.CanvasPosition = Vector2.new(0, 1000)
    self:updateScrollInfo(0.0)
end

local function calcBufferOffset(size)
    return UDim2.new(1, 0, 0, 1000 - size)
end

local function calcScrollbarPos(info)
    return UDim2.new(0, 0, info.first, 0)
end

local function calcScrollbarSize(info)
    return UDim2.new(1, 0, info.last - info.first, 0)
end

function RecycleListView:render()
    local children = {
        Layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = self.props.itemPadding,
        }),
        Offset = Roact.createElement("Frame", {
            LayoutOrder = -1,
            Size = self.bufferSize:map(calcBufferOffset),
            BackgroundTransparency = 1.0,
        }),
    }
    self.items = {}
    for index = self.state.firstIndex, self.state.lastIndex do
        local item = self.props.items[index]
        local key = string.format("[%s]", self.props.getStableId(item, index))
        local element = Roact.createElement(RecycleItem, {
            item = item,
            index = index,
            renderItem = self.props.renderItem,
            parent = self,
        })
        children[key] = element
    end

    return e("Frame", {
        LayoutOrder = self.props.LayoutOrder,
        Size = self.props.Size,
        Position = self.props.Position,
        BackgroundTransparency = 1.0,
    }, {
        Scroll = e("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 0,
            BackgroundTransparency = 1.0,
            CanvasSize = UDim2.new(0, 0, 0, 2000),

            [Roact.Ref] = self.scrollRef,
            [Roact.Change.CanvasPosition] = self.onCanvasPosition,
            [Roact.Change.AbsoluteSize] = self.onResize,
        }, children),
        Gutter = e("ImageButton", {
            Size = UDim2.new(0, 10, 1, 0),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1.0,
        }, {
            ScrollBar = e("Frame", {
                Size = self.scrollbarInfo:map(calcScrollbarSize),
                Position = self.scrollbarInfo:map(calcScrollbarPos),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(174, 176, 179),
            }),
        })
    })
end

return RecycleListView
