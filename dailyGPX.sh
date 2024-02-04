#!/usr/bin/env bash
# https://gist.github.com/henrik242/1da3a252ca66fb7d17bca5509a67937f
# 
# Reads AirTag data from the FindMy.app cache and converts it to a daily GPX file
#
# Rsyncs the data to a web accessible folder that can be displayed with e.g. 
# https://gist.github.com/henrik242/84ad80dd2170385fe819df1d40224cc4
#
# This should typically be run as a cron job
#

set -o pipefail -o nounset -o errexit

export PATH=/usr/local/bin:$PATH
DATADIR=$HOME/AirTag
_DATADIR=$HOME/AirTag/data
TODAY=$(date +%d)

mkdir -p $DATADIR

if [ $# -ne 2 ]; then
  echo 'usage: $0 "White 1" iTag'
  echo "where White 1 is the name of the iTag, iTag is the target path for the web"
  exit 2
fi

TAGNAME=$1
_PATH=$2
_TAGNAME=$(echo $TAGNAME | tr ' ' '_')
DATA=$DATADIR/airtagdata-${_TAGNAME}_$TODAY.txt
GPX=$DATADIR/airtagdata-${_TAGNAME}_$TODAY.gpx
GPX_LAST=$_DATADIR/airtagdata-${_TAGNAME}_${TODAY}_last.gpx

if [[ $(uname -s) == "Darwin" ]]; then
  TOMORROW=$(date -v +1d +%d)
else
  TOMORROW=$(date --date="tomorrow" +%d)
fi
rm -f $DATADIR/airtagdata-${_TAGNAME}_$TOMORROW.*

DDATA=$(jq -r --arg TAGNAME "$TAGNAME" '.[] | select(.name == $TAGNAME) | .location | "\(.latitude) \(.longitude) \(.altitude) \(.timeStamp/1000 | todate)"' \
   /Users/oleg/Library/Caches/com.apple.findmy.fmipcore/Items.data 2>/dev/null || echo "Null")

if [ "$DDATA" = "Null" ]; then
  DDATA=$(jq -r --arg TAGNAME "$TAGNAME" '.[] | select(.name == $TAGNAME) | .safeLocations[0].location | "\(.latitude) \(.longitude) \(.altitude) \(.timeStamp/1000 | todate)"' \
   /Users/oleg/Library/Caches/com.apple.findmy.fmipcore/Items.data || echo "Null")
fi

LAST_LINE=$(tail -1 $DATA 2>/dev/null || echo "")

if [ "$DDATA" = "Null" ] || [ "$LAST_LINE" = "$DDATA" ]; then
  # echo "nothing changed"
  exit
fi

echo $DDATA >> $DATA
echo "$TAGNAME: $DDATA"
START='<?xml version="1.0" encoding="UTF-8"?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:mytracks="http://mytracks.stichling.info/myTracksGPX/1/0" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" creator="myTracks" version="1.1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
   <trk>
      <name>'$_TAGNAME'</name>
      <extensions>
         <mytracks:color red="0.000000" green="0.000000" blue="1.000000" alpha="1.000000" />
         <mytracks:area showArea="no" areaDistance="0.000000" />
         <mytracks:directionArrows showDirectionArrows="yes" />
         <mytracks:sync syncPhotosOniPhone="no" />
         <mytracks:timezone offset="120" />
      </extensions>
      <trkseg>'

END='      </trkseg>
   </trk>
</gpx>'


echo $START > $GPX
echo $START > $GPX_LAST

function elems() {
    LAT=$1
    LON=$2
    ELE=$3
    TS=$4
}

cat $DATA | while read line; do
  if [ ! "$line" = '' ]; then
    elems $line
  fi
  echo '<trkpt lat="'$LAT'" lon="'$LON'">
            <ele>'$ELE'</ele>
            <time>'$TS'</time>
         </trkpt>' >> $GPX
done
line=$(tail -1 $DATA)
elems $line
echo '<trkpt lat="'$LAT'" lon="'$LON'">
            <ele>'$ELE'</ele>
            <time>'$TS'</time>
         </trkpt>' >> $GPX_LAST

echo $END >> $GPX
echo $END >> $GPX_LAST
cp $GPX $DATADIR/airtagdata_${_TAGNAME}.gpx
cp $GPX $_DATADIR/airtagdata_${_TAGNAME}.gpx
sleep 1
scp $DATA $_DATADIR/*gpx ok@center.dyndns.biz:${_PATH}/data >/dev/null
rm $_DATADIR/*gpx 2>/dev/null
# rsync -a --exclude='*.txt' $DATADIR example.com:public_html/airtag/
