local GPIO = require('periphery').GPIO

-- Open GPIO /dev/gpiochip0 line 12 with output direction
local gpio_out = GPIO("/dev/gpiochip1", 9, "out")

local value = gpio_in:read()
gpio_out:write(1)

gpio_out:close()
