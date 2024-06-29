#!/bin/bash

# will create .csv files there
cd /home/pi/air_data

while true; do
	# 12 * 5 = 60 sec. (can update humidity value every minute as optional todo, likely just store value in external file by another service)
	for (( i=1; i<=12; i++ ))
	do
		# doing one-shot queries seem to work, continuous way of doing it has weird limit on length and then introduces some break in time between calls
		sudo /home/pi/sensor/src/sds -q -l 1 -w 5 -H 50 | awk '/PM10/ {print systime() "," $3 "" $5}' >> "$(date +'%Y-%m-%d--%H').csv"
		sleep 5
		# -w 5 and sleep 5 need to be in sync maybe or there could be software bug about it
	done


done
