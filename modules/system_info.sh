#!/bin/bash

brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
volume=$(pamixer --get-volume)
echo "{\"brightness\": $brightness, \"volume\": $volume}"