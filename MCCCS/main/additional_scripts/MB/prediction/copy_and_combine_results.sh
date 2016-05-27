#!/bin/bash
#$1 reject value, $2 path to results, $3 model names
cd $2
DIRNAME=$2
RESDIR="results_$1_${DIRNAME::-1}_$3"
mkdir ../"$RESDIR"
cp all_results_"$1".csv ../"$RESDIR"/.
for dir in */;
do
PREV_PATH=$(find $dir -name *preview.tif);
FOLDER_NAME=${dir::-1};
CL_PATHH=$(find $dir -name classified_all_"$1".tif);
# do montage
echo "combine" $PREV_PATH " and " $CL_PATHH
montage -mode concatenate -tile 2x1 $PREV_PATH $CL_PATHH ../"$RESDIR"/$FOLDER_NAME'_comb.png';
# copy debug image
DEBUG_PATH=$(find $dir -name quantify_debug*);
cp $DEBUG_PATH ../"$RESDIR"/$FOLDER_NAME'_debug.tif'
done
