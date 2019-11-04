local Roact = require(script.Parent.Parent.Parent.Roact)
local RecycleListView = require(script.Parent.Parent)

return function(target)
    local items = {}
    for i = 1, 100 do
        items[i] = math.random(1, 10000)
    end
    local element = Roact.createElement(RecycleListView, {
        items = items,
        renderItem = function(item, index)
            return Roact.createElement("TextLabel", {
                Size = UDim2.new(1, 0, 0, item > 7500 and 72 or 36),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 28,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1.0,
                Text = string.format("#%03d: %d", index, item),
            })
        end,
        estimateItemSize = function()
            return 36
        end,
    })
    local handle = Roact.mount(element, target)

    return function()
        Roact.unmount(handle)
    end
end
