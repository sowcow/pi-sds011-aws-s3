# What

- Given Raspbery Pi with SDS011 sensor
- Automatically configure it to record and synchronize measurements into own AWS S3
- Then visualize charts (it is early stage, using raw local data and simplest R language script)
- Running no-dependencies ruby script on Pi for buffering to not kill SD-cards and to not bother with bash

Prerequisites are at the start of each usage step below.

# Steps

## AWS

- requires aws account
- requires aws cli being installed and configured for access (needs default region to place bucket in it I assume)
- requires ruby language installed to run `rake` commands locally
- change value (Default: ...) of bucket name at the top of `aws.yaml`
- run `rake aws` (it stores secrets in a json file and `store.service`)

## Pi

- requires ansible and sshpass to be installed
- requires ssh into Pi to be available
- change IP or other values in `hosts_pi.ini`
- run `rake pi`

## Visuals

- requires having R language installed
- run `rake pull` to get files from S3
- run `rake render` to produce pdf and png files

## Other commands

- `rake clean` - should remove stored secrets in files around
- `rake drop` - remove stack, but if data is already there - it needs manual removal

If Pi SD card has died then to setup new one by using existing AWS stack:
- `rake secrets`
- `rake pi`
- `rake clean`

# Data format

CSV contents order:
- systime 
- PM 2.5
- PM10

Example:
1719675639,0.452889,1.700000

After doing `rake pull` it creates combined `local_data/all.csv` file, other files are with data per hour.

# Parameters

Check `record_data.sh` for hardcoded humidity and recording timing/resolution values (one recording every 5 seconds).
`do_store_data.sh` has synchronization timing value (under 2 hours max. "latency" given buffer of one file written every hour).

That should produce ~7Mb of data per year with similar outgoing traffic.

# Other notes

- I use https://github.com/paulvha/sds011 for sensor driver. I didn't dig too much into what mode or parameters would be optimal but continuous mode seem to have startup time which seem unneeded if humidity is going to be adjusted every minute for example.
- Anyway after playing around resolution may loose value if the driver/device can average things for me but I didn't dig.
- I'm thinking to add humidity at some point, it should be used to correct the sensor (median?).
- Unexpectedly terraform ended-up being useless given chat-gpt can just generate cloudformation that doesn't have compatibility issues.
- Not decided about UI yet (custom mini AWS app vs ready-made app if if is no-nonsense and is too powerful to ignore)
- Not having python running on the Pi feels good
- Initial version killed SD-card in less then 24 hours so I added some buffering and introducerd ruby
