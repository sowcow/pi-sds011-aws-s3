# What

- Given Raspbery Pi and SDS011 sensor
- Automatically configure it to record and synchronize measurements into AWS S3

# Steps

## AWS

- requires aws cli being installed and configured for access (needs default region to place bucket in it I assume)
- change value (Default: ...) of bucket name at the top of `aws.yaml`
- run `rake aws` (it stores secrets in a json file and `store.service`)

## Pi

- requires ansible and sshpass to be installed
- requires ssh into Pi to be available
- change IP or other values in `hosts_pi.ini`
- run `rake pi`

## Other commands

- `rake clean` - should remove stored secrets in files around
- `rake drop` - remove stack, but if data is already there - it needs manual removal

# Data format

CSV contents order:
- systime 
- PM 2.5
- PM10

Example:
1719675639,0.452889,1.700000

# Parameters

Check `record_data.sh` for hardcoded humidity and recording timing values (one recording every 5 seconds).
`do_store_data.sh` has synchronization timing value.

# Other notes

I use https://github.com/paulvha/sds011 for sensor driver. I didn't dig too much into what mode or parameters would be optimal but continuous mode seem to have startup time which seem unneeded if humidity is going to be adjusted every minute for example.

Anyway after playing around resolution may loose value if the driver/device can average things for me but I didn't dig.

I'm thinking to add humidity at some point (median?).

Not decided about UI yet.

Unexpectedly terraform ended-up being useless given chat-gpt can just generate cloudformation that doesn't have compatibility issues.
