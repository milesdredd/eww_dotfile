#!/bin/bash

# Create pipe if it doesn't exist
FIFO="/tmp/notif-pipe"
[ -p "$FIFO" ] || mkfifo "$FIFO"

# Start infinite read loop
while read -r line < "$FIFO"; do
    eww update notif-box="(label :class \"new-noti\" :text \"$line\")"
done
