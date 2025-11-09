#!/bin/bash

bat=$(acpi -b)
capacity=$(echo "$bat" | grep -o '[0-9]\+%' | tr -d '%')
status=$(echo "$bat" | awk '{print $3}' | tr -d ',')
if [ "$status" = "Charging" ]; then
    icon="⚡"
elif [ "$capacity" -ge 90 ]; then
    icon="🔋"
elif [ "$capacity" -ge 70 ]; then
    icon="🟩"
elif [ "$capacity" -ge 50 ]; then
    icon="🟨"
elif [ "$capacity" -ge 30 ]; then
    icon="🟥"
else
    icon="🔴"
fi


echo "$icon $capacity%"

