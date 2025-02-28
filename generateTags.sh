#!/usr/bin/env bash
#set -euxo pipefail

for file in *; 
do
    echo "Processing file: $file";
    coords=`exiftool -c "%+.6f" "$file" |grep "GPS Position" | cut -d":" -f2 | tr -d ' '`
    #echo "coords=$coords"
    lat=`echo $coords | cut -d"," -f1`
    long=`echo $coords | cut -d"," -f2`
    #echo "lat=$lat  long=$long"
    exifData=`curl -Ls "https://us1.api-bdc.net/data/reverse-geocode-client?latitude=$lat&longitude=$long"`
    city=`echo $exifData | jq '.city' | tr -d '"'`
    country=`echo $exifData | jq '.countryName' | tr -d '"'` 
    echo "meta: $city - $country"
    echo "$city, $country" > .$file
    #echo $exifData
done 