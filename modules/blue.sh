mac=$(bluetoothctl devices Connected | awk '{print $2}' | head -n 1)
if [ -z "$mac" ]; then
    echo '{ "connected": "false", "battery": "null" }'
else
    mac_underscore=$(echo "$mac" | tr ':' '_')
    sink=$(pactl list sinks short | grep -i "$mac_underscore")
    if [ -z "$sink" ]; then
        echo '{ "connected": "false", "battery": "null" }'
    else
        battery=$(bluetoothctl info "$mac" | awk '/Battery:/ {print $2}')
        if [ -z "$battery" ]; then
            battery=$(upower -e | grep -i "$mac_underscore" | xargs -I {} upower -i {} 2>/dev/null | awk '/percentage:/ {print $2}' | tr -d '%')
        fi
        [ -z "$battery" ] && battery="null"
        echo "{ \"connected\" : \"true\", \"battery\" : \"$battery\" }"
        
    fi
fi
