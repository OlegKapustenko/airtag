#!/bin/bash
while true; do
  /Users/oleg/AirTag/dailyGPX.sh "White 1" static
  /Users/oleg/AirTag/dailyGPX.sh "Oleg 1" iTag
  /Users/oleg/AirTag/dailyGPX.sh "Olga 1" iTag
  /Users/oleg/AirTag/dailyGPX.sh "Black 1" static
  /Users/oleg/AirTag/dailyGPX.sh "KR9N176" static
  /Users/oleg/AirTag/dailyGPX.sh "Kate round" kate
  /Users/oleg/AirTag/dailyGPX.sh "Kate long" kate
  echo -n "."
  sleep 60
done
