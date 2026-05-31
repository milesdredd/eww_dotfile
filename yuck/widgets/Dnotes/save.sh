#!/bin/bash

DIR="$HOME/dailyNotes"
FILE="$DIR/$(date +%F).md"

cat > "$FILE"