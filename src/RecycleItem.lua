--[[
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

local Roact = require(script.Parent.Parent.Roact)
local e = Roact.createElement

local function toUDim2(height)
    return UDim2.new(1, 0, 0, height)
end

local RecycleItem = Roact.Component:extend("RecycleItem")

function RecycleItem:init()
    self.size, self.setSize = Roact.createBinding(0)

    self.ref = Roact.createRef()
    self.onContentSize = function(rbx)
        self.setSize(rbx.AbsoluteContentSize.Y)
    end
end

function RecycleItem:didMount()
    if self.ref.current then
        self.setSize(self.ref.current.AbsoluteContentSize.Y)
    end
    self.props.parent.itemSizes[self.props.index] = self.size
end

function RecycleItem:didUpdate()
    self.props.parent.itemSizes[self.props.index] = self.size
end

function RecycleItem:render()
    return e("Frame", {
        LayoutOrder = self.props.index,
        Size = self.size:map(toUDim2),
        BackgroundTransparency = 1.0,
    }, {
        Layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            [Roact.Ref] = self.ref,
            [Roact.Change.AbsoluteContentSize] = self.onContentSize,
        }),
        Contents = self.props.renderItem(self.props.item, self.props.index),
    })
end

return RecycleItem
