#!/bin/bash	
set -e # stop script in case of error
dir=$2
dir=${dir%*/}
echo -n "[${dir}]" 

START=$(date +%s)

	# remove eventually previously created files:
	rm -f ${dir}/channel_*
	rm -f ${dir}/mask_1.png
	rm -f ${dir}/mask_2.png
	rm -f ${dir}/*.arff
	rm -f ${dir}/*_quantified.csv
	rm -f ${dir}/foreground*

	$JAVA.SplitRGB ${dir}/*rgb*

	$JAVA.RGB2HSV ${dir}/*rgb_r.tif ${dir}/*rgb_g.tif ${dir}/*rgb_b.tif 8
	$JAVA.RGB2XYZ ${dir}/*rgb_r.tif ${dir}/*rgb_g.tif ${dir}/*rgb_b.tif 8
	$JAVA.RGB2LAB ${dir}/*rgb_r.tif ${dir}/*rgb_g.tif ${dir}/*rgb_b.tif 8

	for img in ${dir}/channel*;
	do
		$JAVA.FILTER "${img}" "${img}" 2 2 BLUR
		$JAVA.FILTER "${img}" "${img}" 3 3 MEDIAN
	done

	# read _label.png image and create binary mask
	# create mask_1.png, mask_1.arff, mask_2.png, mask_2.arff
	$JAVA.ThresholdGTforFGBG ${dir}/*label*

	# create fgbgTraining.arff
	$JAVA.ArffSampleFileGenerator -2 2500 "${dir}"
	mv ${dir}/fgbgTraining.arff ${dir}/fgbg_training_sample.arff

END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)

if [ "$NPROCS" == "1" ]
then
	echo "[$DIFF seconds]"
else
	echo -n "[finished ${dir} in ${DIFF} sec.]"
fi
