# GPIO used PA17

import gpiod
import time

chip=gpiod.Chip('gpiochip0')
line = gpiod.find_line("PA17")
lines = chip.get_lines([line.offset()])
lines.request(consumer='foobar', type=gpiod.LINE_REQ_DIR_OUT, default_vals=[0])

while True:
    lines.set_values([1])
    time.sleep(1)
    lines.set_values([0])
    time.sleep(1)
