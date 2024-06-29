#!/bin/bash

cd /home/pi/air_data

while true; do
	aws s3 sync . s3://$BUCKET_NAME --size-only
	sleep 300 # 5 minutes
done
