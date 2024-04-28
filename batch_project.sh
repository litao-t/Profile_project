#!/bin/bash
ls *.grd > grd_list
while IFS= read -r line; do
    sh kml2pro.sh profile.kml $line 0.03
done < "grd_list"
rm grd_list
