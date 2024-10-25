
## Installation

```
Modules = {
	poolSystem = "github.com/Donorhan/cubzh-library/pool-system:[commit-id]",
}
```

## How to
`create(startAmount, createFunction, autoResize)`
startAmount : Integer
createFunction : Function
autoResize : Boolean

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
