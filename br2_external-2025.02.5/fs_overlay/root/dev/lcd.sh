#!/bin/sh

# Script to control an LCD 16x2 HD44780 using a PCF8574A I2C 4-bit interface from the i2c-dev interface
# In our case, the PCF8574 i2c address is 0x3f and i2c bus #1 is used
# The i2c_dev kernel module is loaded and /dev/i2c-1 exists on kernel 5.4

# TODO: Fix bug where spaces arent shown

# LCD hard pins connected to the PCF:
# [7  6  5  4  3  2  1  0 ]
# [D7 D6 D5 D4 BL -E RW RS]


# Instruction registers on the HD44780

# Function set
# [0  0  1  DL N  F  0  0 ]
#  DL: 1=8-Bit, 0=4-Bit
#  N: 1=2 Line, 0=1 Line
#  F: 1=5x10, 0=5x8
#
# For our 1604 4-bit: 00101800

# Display On
# [0  0  0  0  1  D  C  B ]
# D: Display
# C: Cursor
# B: Blink
#
# For us: 00001111

# Display Clear
# [0  0  0  0  0  0  0  1 ]

# Entry Mode Set
# [0  0  0  0  0  1  ID S ]
# ID: 1=Increment, 0=Decrement
#  S: 1=Shift based on ID (1=Left, 0=Right)
# For us: 00000110


# ====================== Variables

RS=1 # Instruction=0 /Data=1
RW=2 # Read=1 /Write=0
EN=4 # Enable=1 / Disable=0
BL=8 # On=1 | Off=0


# ===================== Function definitions

# Function sends instructions 4-bits at a time with EN toggle:
# lcd_write <byte> (1|0)   # 1=data 2=instruction

function lcd_write () {
  echo "DEBUG $1 $2"
  DATA=$2  #
  i2cset -y 1 3f $( printf %x $(( ($1 & 0xf0) | $BL | $DATA | $EN )))
  usleep 10
  i2cset -y 1 3f $( printf %x $(( ($1 & 0xf0) | $BL | $DATA )))
  usleep 10
  i2cset -y 1 3f $( printf %x $(( (($1 & 0xf) << 4) | $BL | $DATA | $EN )))
  usleep 10
  i2cset -y 1 3f $( printf %x $(( (($1 & 0xf) << 4) | $BL | $DATA )))
  usleep 10
}

function lcd_instruction () {
  lcd_write $1 0
}

function lcd_data () {
  lcd_write $1 $RS
}


# ===================== Initialization

lcd_instruction 3   # Init
lcd_instruction 2
lcd_instruction 28  # Function set
lcd_instruction f   # Display cursor and blink
lcd_instruction 1   # Display clear
lcd_instruction 6   # Entry mode set


# ===================== Display the input string
string=$1
echo "Input: $1"

for x in $(echo $1 | fold -w1)
do
  echo "Char: $x"
  lcd_data $(printf '%d' \"$x\")
done
