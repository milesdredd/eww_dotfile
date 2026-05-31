#!/bin/bash

DIR="$HOME/dailyNotes"
FILE="$DIR/$(date +%F).md"

mkdir -p "$DIR"
touch "$FILE"

cat "$FILE"