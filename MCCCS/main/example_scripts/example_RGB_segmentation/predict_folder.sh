#!/bin/bash
set -e # stop script in case of error
dir=$2
dir=${dir%*/}

START=$(date +%s)

	echo -n "[${dir}]"   
	rm -f ${dir}/channel_*
	rm -f ${dir}/*.arff
	rm -f ${dir}/*_quantified.csv
	rm -f ${dir}/foreground*
	$JAVA.SplitRGB ${dir}/*rgb*

	#apply filter
	$JAVA.RGB2HSV ${dir}/*rgb_r.tif ${dir}/*rgb_g.tif ${dir}/*rgb_b.tif 8
	$JAVA.RGB2XYZ ${dir}/*rgb_r.tif ${dir}/*rgb_g.tif ${dir}/*rgb_b.tif 8
	$JAVA.RGB2LAB ${dir}/*rgb_r.tif ${dir}/*rgb_g.tif ${dir}/*rgb_b.tif 8

	for img in ${dir}/channel*;
	do
		$JAVA.FILTER "${img}" "${img}" 2 2 BLUR
		$JAVA.FILTER "${img}" "${img}" 3 3 MEDIAN
	done

	CLASSCOUNT=2

	# reads and applies mask_0.png (if existing, here not), converts all channel*.tif files to arff
	# merges arff files, adds ',?' as class column
	# creates '${dir}_${CLASSCOUNT}.arff', mask_1.png+arff, mask_2.png+arff
	$JAVA.ArffFromImageFileGenerator $CLASSCOUNT "${dir}" 
	cp "${dir}/channel_rgb_r.tif" "${dir}/fgbg_result.tif" # used as mask (all fg)
	rm -f ${dir}/channel_*

	# splits ${dir}_2.arff, applies model, creates classification result 'fgbg_result.arff'
	RELATIVE_SPLIT_ARFF=$(realpath --relative-to="${PWD}" "$SPLIT_ARFF")
	"$RELATIVE_SPLIT_ARFF" "${dir}" "${dir}_2.arff" "true" "fgbg" "100m" 

	$JAVA.ApplyClass0ToImage "${dir}/fgbg_result.tif"
	#$JAVA.ArffToImageFileGenerator $CLASSCOUNT "${dir}/fgbg_result.tif" # looks for fgbg_result.arff
	$JAVA.ArffToProbabilityImageFileGenerator $CLASSCOUNT -1.0 "${dir}/fgbg_result.tif" # looks for fgbg_result.arff
	rm "${dir}/fgbg_result.tif"

	cp "${dir}/foreground.png" "${dir}/foreground_cluster.png"
	$JAVA.Quantify 0 "${dir}/foreground"
	#rm "${dir}/foreground_cluster.png"
	cat ${dir}/*_quantified.csv >> all_prediction_results.csv

	if [ -f "${dir}/mask_2.png" ]
	then
		$JAVA.CreateDiffImage "${dir}/mask_2.png" "${dir}/foreground.png" "${dir}/foreground_diff.png"
	fi

	rm -f ${dir}/*.arff

END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
echo -n "[finished ${dir} in ${DIFF} sec.]"