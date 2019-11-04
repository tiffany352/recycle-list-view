# RecycleListView

A small Roact library implementing a recycle list view. This is where a
scrolling frame only displays a small pool of fixed elements at once,
which preserves memory and performance when scrolling through a large
list.

Recycle list views are differentiated from infinite scrolling because
infinite scrolling adds new elements as you scroll down, so you use more
and more memory the further down you go. Recycle lists use the same
number of instances no matter how many objects you're displaying, or how
far scrolled down you are.

## Installation

Requires Roact be parented in the same place as this library. Depends on
Roact 1.0+.

When configuring with Rojo, point the source at the `src` directory.

## API

```
Roact.createElement(RecycleListView, { props... })
```

To get started quickly, the most important props to specify are `items`,
`renderItem`, and `estimateItemSize`. You'll also want to provide
`getStableId` if you intend on re-ordering the `items` array (e.g.
applying a search filter).

### `LayoutOrder: int, Size: UDim2, Position: UDim2`

Passed through to underlying instance.

### `itemPadding: UDim`

Padding between items in the list view.

### `items: Item[]`

`Item` can be any Lua type, it is treated as opaque by the library. This
must be an array-like table (no holes with nil values).

### `getStableId: function(item: Item, index: int) -> string`

Returns an ID that should uniquely identify this item, in case you
rearrange the contents of the `items` array. By default uses the `index`
value.

### `renderItem: function(item: Item, index: int) -> Roact.Element`

Given an item, return a Roact element for it.

### `estimateItemSize: function(item: Item, index: int) -> number`

This function is very important for guaranteeing that the recycle list
won't glitch out and be missing items at the bottom. This function's
purpose is to return a "lower bound" on how big an item will be, in
pixels. For example, if each item is a paragraph of text that could be
any size, you would typically return how tall one line is (plus any
padding).

Returning 0 from this function can result in very bad performance, so
don't do it. Also don't return too large of a value, or make this
function too expensive to call repeatedly. In most cases it should
either return a hardcoded number, or something similarly fast.
