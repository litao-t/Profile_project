#!/bin/bash
# input: filename.kml (come from google earth)
# e.g. sh kml2pro.sh profile.kml dis_ew.grd 0.03

temp=`echo $1 | awk -F '.' '{print $1}' `
file=$temp".gmt"
if [ ! -f $file ]; then
    gmt kml2gmt $1 > $file
fi
grdfile=`echo $2 | awk -F. '{print $1}'`
dist=$3

while IFS= read -r line; do
    # remove space
    # line=$(echo $line | xargs)
    
    if [[ $line =~ \> ]]; then
        # profile name
        path_name=`echo "$line" | awk -F '"' '{print $2}'`
        prev_lon=""
        prev_lat=""
    else
        # first or second point
        if [[ -z "$prev_lon" ]]; then
            prev_lon=$(echo "$line" | cut -f1)
            prev_lat=$(echo "$line" | cut -f2)

        else
            cur_lon=$(echo "$line" | cut -f1)
            cur_lat=$(echo "$line" | cut -f2)

            gmt project -C$prev_lon/$prev_lat -E$cur_lon/$cur_lat -G$dist -Q > $path_name.tmp
            awk '{print $3}' $path_name.tmp > temp1

            # extract the displacement 
            awk '{print $1,$2}' $path_name".tmp" | gmt grdtrack -G$grdfile".grd" -Z > temp2
            paste temp1 temp2 > $path_name'_'$grdfile.xyz

        fi
    fi
done < "$file"
echo "Projection Done"
rm ./temp* ./*tmp ./*gmt
