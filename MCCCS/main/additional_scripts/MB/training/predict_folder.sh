#!/bin/bash
dir=$2
dir=${dir%*/}
echo -n "[${dir}]" 

START=$(date +%s)

#echo
#echo "delete previous results: foreground*, *.arff, classified.png"
rm -f ${dir}/foreground*
rm -f ${dir}/*.arff
rm -f ${dir}/classified*
rm -f ${dir}/channel_*
rm -f ${dir}/foreground_*
#echo

#rename and copy
cp -n "${dir}"/*red.tif "${dir}/channel_0.tif"
cp -n "${dir}"/*green.tif "${dir}/channel_1.tif"
cp -n "${dir}"/*blue.tif "${dir}/channel_2.tif"
cp -n "${dir}"/*uv.tif "${dir}/channel_3.tif"

#transform into LAB
$JAVA.RGB2ALL "${dir}/channel_0.tif" "${dir}/channel_1.tif" "${dir}/channel_2.tif" 16 7 0

#remove RGB
rm -f "${dir}/channel_0.tif"
rm -f "${dir}/channel_1.tif"
rm -f "${dir}/channel_2.tif"

#Filter
for img in ${dir}/channel*;
do
	$JAVA.FILTER ${img} ${img} 5 5 BLUR
	$JAVA.FILTER ${img} ${img} 5 5 MEDIAN
	$JAVA.FILTER ${img} ${img} 5 5 HARLICK
done

echo -n "[a]"
$JAVA.ArffFromImageFileGenerator 2 "${dir}"

 echo -n "[b]" 
# ${dir}/${dir}_2.arff""
$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_2.arff" -serialized $MODELPATH/fgbg.model -classification -remove-old-class -o "${dir}/fgbgresult.arff" -c last -distribution

#create foreground png
cp "${dir}/channel_3.tif" "${dir}/fgbgresult.tif"
#$JAVA.ApplyClass0ToImage "${dir}/fgbgresult.tif"
$JAVA.ArffToProbabilityImageFileGenerator 2 0.9 "${dir}/fgbgresult.tif"
mv ${dir}/probability_combined.png ${dir}/foreground'.png'

rm "${dir}/fgbgresult.tif"

#rotate
$JAVA.Rotate l "${dir}/foreground.png"

#start loop for subplates
echo -n "[c]"
for i in {1..4}
do
	echo -n "[$i]"
	$JAVA.ApplyMask ${dir}/foreground_rot_l.tif $(pwd)/roi_$i.png

	$JAVA.SplitHistBased ${dir}/foreground_rot_l_roi_$i.tif

	sleep 2s

	$JAVA.SideSmooth ${dir}/foreground_rot_l_roi_$i

	$JAVA.Erode ${dir}/foreground_rot_l_roi_$i'smooth_all.png'

	$JAVA.Rotate r ${dir}/foreground_rot_l_roi_$i'smooth_all.png'

	#combine FGBG masks
	if [ $i == '1' ];
	then
		$JAVA.CalcImage ${dir}/foreground_rot_l_roi_$i'smooth_all_rot_r.tif' ${dir}/foreground_rot_l_roi_$i'smooth_all_rot_r.tif' ${dir}/foreground_rot_l_smooth_combined_$i'.tif' AND 1
	else
		$JAVA.CalcImage ${dir}/foreground_rot_l_roi_$i'smooth_all_rot_r.tif' ${dir}/foreground_rot_l_smooth_combined_$(($i-1))'.tif' ${dir}/foreground_rot_l_smooth_combined_$i'.tif' AND 1
	fi
done

#do classification
#distmap, apply fgbg
#$JAVA.ArffFromImageFileGenerator 3 ${dir}/foreground_rot_l_smooth_combined.tif

echo -n "[d]"
$JAVA.ArffFromImageFileGenerator 3 "${dir}"

echo -n "[e]"
$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_3.arff" -serialized $MODELPATH/label.model -classification -remove-old-class -o "${dir}/labelresult.arff" -c last -distribution

#start loop for subplates again
echo -n "[f]"
for i in {1..4}
do
	echo -n "[$i]"
	cp ${dir}/foreground_rot_l_roi_$i'smooth_all_rot_r.tif' "${dir}/labelresult.tif"
	#$JAVA.ArffToImageFileGenerator 3 "${dir}/labelresult.tif"
	#Probability changed from 0.75 to 0.99 by DD
	$JAVA.ArffToProbabilityImageFileGenerator 3 0.95 "${dir}/labelresult.tif"
	mv ${dir}/probability_combined.png ${dir}/classified'.png'
	rm "${dir}/labelresult.tif"
	
	mv ${dir}/classified.png ${dir}/classified_$i.png
	$JAVA.Rotate l ${dir}/classified_$i.png

	$JAVA.SplitHistBased ${dir}/classified_$i'_rot_l.tif'

	sleep 2s

	#combine classified masks
	if [ $i == '1' ];
	then
		$JAVA.CalcImage ${dir}/classified_$i'_rot_l.tif' ${dir}/classified_$i'_rot_l.tif' ${dir}/classified_combined_$i'.png' AND 2
	else
		$JAVA.CalcImage ${dir}/classified_$i'_rot_l.tif' ${dir}/classified_combined_$(($i-1))'.png' ${dir}/classified_combined_$i'.png' AND 2
	fi

	#echo -n "[g]"
	#rm -f ${dir}/*_quantified.csv
	$JAVA.Quantify 0 ${dir}/classified_$i'_rot_l_'*
	cat ${dir}/*_quantified.csv >> all_results.csv
done

mv ${dir}/classified_combined_4'.png' ${dir}/classified_combined'.png'
$JAVA.Rotate r ${dir}/classified_combined'.png'
mv ${dir}/classified_combined_rot_r'.tif' ${dir}/classified_all.'tif'

echo "delete temporary results"
rm -f ${dir}/classified_combined*
#rm -f ${dir}/foreground*
#rm -f ${dir}/*.arff
#rm -f ${dir}/*.csv
#rm -f ${dir}/channel_*
#rm -f ${dir}/foreground_*

END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
if [ "$NPROCS" == "1" ];
then
	echo " ($DIFF seconds)"
else
	echo -n " (finished ${dir} in ${DIFF} sec.) "
fi
