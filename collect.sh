#!/bin/bash
fileName=/Users/oleg/Library/Caches/com.apple.findmy.fmipcore/Items.data
log=/tmp/geo.log
collect=/tmp/collect.json
d=$(date)
# Get data
cat $fileName | jq > $collect
echo "$d: Collecting geo for " >> $log
names=$(cat $collect | jq '.[].name')
echo "$names" >> $log
