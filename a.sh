#!/bin/bash
while true; do
  current_time=$(date +%s)
  modification_time=$(stat -f %m /Users/oleg/Library/Caches/com.apple.findmy.fmipcore/Items.data)
  delta=$(($current_time-$modification_time))
  if ((current_time - modification_time <= 300)); then
    echo -n "File was updated within the last 5 minutes."
  else
    echo -n "File was not updated within the last 5 minutes."
  fi
  echo "  The delta is $delta"
#  /Users/oleg/AirTag/dailyGPX.sh "Oleg 1" iTag
  /Users/oleg/AirTag/dailyGPX.sh "Olga 1" iTag
  /Users/oleg/AirTag/dailyGPX.sh "KR9N176" iTag
  /Users/oleg/AirTag/dailyGPX.sh "Black 1" static
  /Users/oleg/AirTag/dailyGPX.sh "Valik" denysovy
  /Users/oleg/AirTag/dailyGPX.sh "Olesia" denysovy
  /Users/oleg/AirTag/dailyGPX.sh "Natalia" denysovy
  /Users/oleg/AirTag/dailyGPX.sh "Kate round" kate
  /Users/oleg/AirTag/dailyGPX.sh "Kate long" kate
  /Users/oleg/AirTag/dailyGPX.sh "Alex1" alex
  /Users/oleg/AirTag/dailyGPX.sh "Alex2" alex
  echo -n "."
  sleep 60
done
