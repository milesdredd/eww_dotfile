#!/bin/bash
interface=$(iw dev | awk '$1 == "Interface" {print $2}')
ssid="connected to $(iw dev "$interface" link | awk -F 'SSID: ' '/SSID/ {print $2}')"
signal=$(iw dev "$interface" link | awk '/signal:/ {print $2}')
signal_percent=" signat strength: $((signal + 120))"


if [ "$signal" -ge -40 ]; then
    icon="󰤨"
elif [ "$signal" -ge -50 ]; then
    icon="󰤥"
elif [ "$signal" -ge -70 ]; then
    icon="󰤢"
elif [ "$signal" -ge -90 ]; then
    icon="󰤟󰤟"
else
    icon="󰖪"
fi
if [ -z "$ssid" ]; then 
    icon="󰖪"
    signal_percent=""
fi

echo "{\"icon\":\"$icon\",\"ssid\":\"$ssid\",\"signal\":\"$signal_percent\",\"interface\":\"$interface\"}"

