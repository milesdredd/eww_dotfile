#!/bin/bash

BRIGHTNESS_FILE="/sys/class/leds/platform::kbd_backlight/brightness"

current_brightness=$(cat $BRIGHTNESS_FILE)

new_brightness=$(( (current_brightness + 1) % 3 ))

echo $new_brightness | sudo tee $BRIGHTNESS_FILE > /dev/null
