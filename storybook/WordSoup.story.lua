--[[
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

local TextService = game:GetService("TextService")

local Roact = require(script.Parent.Parent.Parent.Roact)
local RecycleListView = require(script.Parent.Parent)

local words = {
    "the", "be", "to", "of", "and", "a", "in", "that", "have", "I", "it",
    "for", "not", "on", "with", "he", "as", "you", "do", "at", "this",
    "but", "his", "by", "from", "they", "we", "say", "her", "she", "or",
    "an", "will", "my", "one", "all", "would", "there", "their", "what",
    "so", "up", "out", "if", "about", "who", "get", "which", "go", "me",
    "when", "make", "can", "like", "time", "no", "just", "him", "know",
    "take", "people", "into", "year", "your", "good", "some", "could",
    "them", "see", "other", "than", "then", "now", "look", "only", "come",
    "its", "over", "think", "also", "back", "after", "use", "two", "how",
    "our", "work", "first", "well", "way", "even", "new", "want", "because",
    "any", "these", "give", "day", "most", "us",
}

local names = {
    "Liam", "Emma", "Noah", "Olivia", "William", "Ava", "James", "Isabella",
    "Oliver", "Sophia", "Benjamin", "Charlotte", "Elijah", "Mia", "Lucas",
    "Amelia", "Mason", "Harper", "Logan", "Evelyn",
}

local users = {}
for i = 1, 20 do
    users[i] = names[math.random(1, #names)] .. math.random(1, 25)
end

local items = {}

for index = 1, 100 do
    local phrase = {}
    local count = math.random(10, 100)
    for _ = 1, count do
        table.insert(phrase, words[math.random(1, #words)])
    end
    items[index] = {
        id = math.random(1, 10000),
        text = table.concat(phrase, ' '),
        hour = math.random(1, 12),
        meridiem = ({"AM", "PM"})[math.random(1, 2)],
        minute = math.random(0, 59),
        username = users[math.random(1, #users)],
    }
end

local function Text(props)
    local font = Enum.Font.SourceSans
    local size = 20
    local item = props.item
    local height, setHeight = Roact.createBinding(0)
    local text = string.format("@%s - %02d:%02d%s\n\n%s", item.username, item.hour, item.minute, item.meridiem, item.text)

    local function update(rbx)
        if rbx then
            local bounds = TextService:GetTextSize(text, size, font, Vector2.new(rbx.AbsoluteSize.X, 100000))
            setHeight(bounds.Y)
        end
    end

    return Roact.createElement("TextLabel", {
        Size = height:map(function(value) return UDim2.new(1, 0, 0, value + 20) end),
        Text = text,
        TextSize = size,
        Font = font,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(49, 50, 51),
        BorderColor3 = Color3.fromRGB(100, 100, 100),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,

        [Roact.Change.AbsoluteSize] = update,
        [Roact.Ref] = update,
    })
end

return function(target)
    local element = Roact.createElement(RecycleListView, {
        items = items,
        getStableId = function(item)
            return tostring(item.id)
        end,
        renderItem = function(item, index)
            return Roact.createElement(Text, {
                item = item,
            })
        end,
        estimateItemSize = function()
            return 80
        end,
    })
    local handle = Roact.mount(element, target)

    return function()
        Roact.unmount(handle)
    end
end
