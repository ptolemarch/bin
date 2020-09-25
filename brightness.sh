#! /bin/bash

new_brightness=$1; shift

brightness_file="/sys/class/backlight/intel_backlight/brightness"

echo "old brightness: $(<$brightness_file)" 1>&2

[ "$new_brightness" ] && echo "$new_brightness" > "$brightness_file"
