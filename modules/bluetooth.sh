#!/bin/bash

if [ "$1" == "--power" ]; then
    if bluetoothctl show | grep -q "Powered: yes"; then
        echo "true"
    else
        echo "false"
    fi
    exit 0
fi

if [ "$1" == "--connected" ]; then
    bluetoothctl devices Connected | while read -r line; do
        if [ -n "$line" ]; then
            MAC=$(echo "$line" | awk '{print $2}')
            NAME=$(echo "$line" | cut -d ' ' -f 3-)
            BATTERY_PERCENTAGE=$(bluetoothctl info "$MAC" | grep "Battery Percentage" | awk -F '[()]' '{print $2}')
            echo "{\"mac\":\"$MAC\",\"name\":\"$NAME\",\"battery\":\"$BATTERY_PERCENTAGE\"}"
        fi
    done | jq -s '.'
    exit 0
fi

if [ "$1" == "--available" ]; then
    CONNECTED_DEVICES=$(bluetoothctl devices Connected)
    bluetoothctl devices | while read -r line; do
        if [ -n "$line" ]; then
            MAC=$(echo "$line" | awk '{print $2}')
            NAME=$(echo "$line" | cut -d ' ' -f 3-)
            if ! echo "$CONNECTED_DEVICES" | grep -q "$MAC"; then
                echo "{\"mac\":\"$MAC\",\"name\":\"$NAME\"}"
            fi
        fi
    done | jq -s '.'
    exit 0
fi

