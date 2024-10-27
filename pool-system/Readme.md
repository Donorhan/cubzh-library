
## Installation

```
Modules = {
	poolSystem = "github.com/Donorhan/cubzh-library/pool-system:[commit-id]",
}
```

## How to
```
local createCoin = function()
	return { coinPosition = Number3(0, 1, 0) }
end

local poolCoins = poolSystem.create(5, createCoin, true)
local coin_1 = poolCoins:acquire()
local coin_2 = poolCoins:acquire()
poolCoins:release(coin_1)
local coin_3 = poolCoins:acquire() -- will use coin_1 instance

```

## Functions
`create(startAmount: interger, createFunction: function, autoResize:  boolean)`
Create a new pool

`release(object: Object)`
Release the object from the pool

`releaseAll()`
Release all items in the loop

`resize(new_size: integer)`
Resize the pool manually

`forEach(func: function)`
Loop all objects in the pool
