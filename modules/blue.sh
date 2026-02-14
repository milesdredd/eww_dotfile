#!/bin/bash

mac=$(bluetoothctl devices Connected | awk '{print $2}' | head -n 1)

if [ -z "$mac" ]; then
    echo '{ "connected": "false", "battery": "null" }'
else
    raw=$(bluetoothctl info "$mac" | awk -F'[: ]+' '/Battery/ {print $3; exit}')

    if [[ "$raw" =~ ^0x ]]; then
        battery=$((raw))
    else
        battery=$(echo "$raw" | tr -d '%')
    fi

    [ -z "$battery" ] && battery="null"

    echo "{ \"connected\": \"true\", \"battery\": \"$battery\" }"
fi

