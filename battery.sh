#! /bin/bash

battery_dir="/sys/class/power_supply/BAT1"

cd "$battery_dir"

charge=$(( $(<charge_now)*100 / $(<charge_full) ))
capacity=$(( $(<charge_full)*100 / $(<charge_full_design) ))

echo "charge: $charge%  capacity: $capacity%"
