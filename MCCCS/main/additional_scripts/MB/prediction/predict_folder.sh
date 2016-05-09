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
rm -f ${dir}/*.csv
rm -f *.csv
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

cp -n "${dir}"/*red.tif "${dir}/channel_0.tif"
cp -n "${dir}"/*green.tif "${dir}/channel_1.tif"
cp -n "${dir}"/*blue.tif "${dir}/channel_2.tif"
cp -n "${dir}"/*uv.tif "${dir}/channel_3.tif"

echo -n "[a]"
touch "$dir""/""$dir""_2.arff"
$JAVA.ArffFromImageFileGenerator 2 "${dir}"
#reuse -> replace @attribute class	{class0,class1,...}
#ARFF_CLASS_INFO=$(grep -F "@attribute class" "${dir}/${dir}_2.arff")
#sed -i -e "s/$ARFF_CLASS_INFO/@attribute class {class0,class1}/g" "${dir}/${dir}_2.arff" 

echo -n "[b]" 
$SPLITCMD "${dir}" "${dir}_2.arff" "true" "fgbg"
#$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_2.arff" -serialized $MODELPATH/fgbg.model -classification -remove-old-class -o "${dir}/fgbgresult.arff" -c last -distribution

#create foreground png
cp "${dir}/channel_3.tif" "${dir}/fgbgresult.tif"
$JAVA.ArffToProbabilityImageFileGenerator 2 0.5 "${dir}/fgbgresult.tif"
mv ${dir}/probability_combined.png ${dir}/foreground'.png'

#rm "${dir}/fgbgresult.tif"

#rotate
$JAVA.Rotate l "${dir}/foreground.png"

#start loop for subplates
echo -n "[c]"
# check rois
ROISOK=false
FLIST=$(find ${dir}/roi_*.png 2>/dev/null)
if [[ -z "$FLIST" ]];
then
	FLIST=$(find $(pwd)/roi_*.png) 2>/dev/null;
	ROISOK=true;
fi
# check if no rois
if [[ -z "$FLIST" ]];
then
	echo "No ROIs found!";
	exit;
fi
# remove path from ROIs
FFLIST=""
for r in $FLIST;
do
	FFLIST+=${r##*/};
done
ROINUMS=$(echo $FFLIST | grep -o -E '[0-9]+')
arrr=($ROINUMS)
for (( i=0; i<${#arrr[@]}; i++ ));
do
	IDX=${arrr[$i]}
	echo -n "[$i]"
	# serach current dir for roi
	if [[ "$ROISOK" == false ]];
	then
		$JAVA.ApplyMask ${dir}"/foreground_rot_l.tif" ${dir}"/roi_"$IDX".png"
	else
		$JAVA.ApplyMask ${dir}"/foreground_rot_l.tif" $(pwd)"/roi_"$IDX".png"
	fi
	
	$JAVA.SplitHistBased ${dir}/foreground_rot_l_roi_$IDX.tif

	sleep 2s

	$JAVA.SideSmooth ${dir}/foreground_rot_l_roi_$IDX

	$JAVA.Erode ${dir}/foreground_rot_l_roi_$IDX'smooth_all.png'

	$JAVA.Rotate r ${dir}/foreground_rot_l_roi_$IDX'smooth_all.png'

	#combine FGBG masks
	if [ $i == '0' ];
	then
		$JAVA.CalcImage ${dir}/foreground_rot_l_roi_$IDX'smooth_all_rot_r.tif' ${dir}/foreground_rot_l_roi_$IDX'smooth_all_rot_r.tif' ${dir}/foreground_rot_l_smooth_combined_$IDX'.tif' AND 1
	else
		PREV=$(($i-1))
		$JAVA.CalcImage ${dir}/foreground_rot_l_roi_$IDX'smooth_all_rot_r.tif' ${dir}/foreground_rot_l_smooth_combined_${arrr[$PREV]}'.tif' ${dir}/foreground_rot_l_smooth_combined_$IDX'.tif' AND 1
	fi
done

echo -n "[d]"
#$JAVA.ArffFromImageFileGenerator 3 "${dir}"
#reuse -> replace @attribute class	{class0,class1,...}
ARFF_CLASS_INFO=$(grep -F "@attribute class" "${dir}/${dir}_2.arff")
sed -i -e "s/$ARFF_CLASS_INFO/@attribute class {class0,class1,class2}/g" "${dir}/${dir}_2.arff" 

echo -n "[e]"
$SPLITCMD "${dir}" "${dir}_2.arff" "true" "label"
#$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_2.arff" -serialized $MODELPATH/label.model -classification -remove-old-class -o "${dir}/labelresult.arff" -c last -distribution

#start loop for subplates again
echo -n "[f]"
for (( i=0; i<${#arrr[@]}; i++ ));
do
	IDX=${arrr[$i]}
	echo -n "[$IDX]"
	cp ${dir}/foreground_rot_l_roi_$IDX'smooth_all_rot_r.tif' "${dir}/labelresult.tif"
	$JAVA.ArffToProbabilityImageFileGenerator 3 $CL_REJECT "${dir}/labelresult.tif"
	mv ${dir}/probability_combined.png ${dir}/classified'.png'
	rm "${dir}/labelresult.tif"

	mv ${dir}/classified.png ${dir}/classified_$IDX.png
	$JAVA.Rotate l ${dir}/classified_$IDX.png

	$JAVA.SplitHistBased ${dir}/classified_$IDX'_rot_l.tif'

	sleep 5s

	#combine classified masks
	if [ $i == '0' ];
	then
		$JAVA.CalcImage ${dir}/classified_$IDX'_rot_l.tif' ${dir}/classified_$IDX'_rot_l.tif' ${dir}/classified_combined_$IDX'.png' AND 2
	else
		PREV=$(($i-1))
		$JAVA.CalcImage ${dir}/classified_$IDX'_rot_l.tif' ${dir}/classified_combined_${arrr[$PREV]}'.png' ${dir}/classified_combined_$IDX'.png' AND 2
	fi
done

ARR_SIZE=${#arrr[@]}
ARR_SIZE=$(($ARR_SIZE-1))
LASTELEMENT=${arrr[$ARR_SIZE]}

mv ${dir}/classified_combined_$LASTELEMENT'.png' ${dir}/classified_combined'.png'
$JAVA.Rotate r ${dir}/classified_combined'.png'
mv ${dir}/classified_combined_rot_r'.tif' ${dir}/classified_all_$CL_REJECT.'tif'

echo "delete temporary results"
rm -f ${dir}/classified_combined*
rm -f ${dir}/foreground*
rm -f ${dir}/foreground_*
rm -f ${dir}/*.arff
#rm -f ${dir}/*.csv
#rm -f ${dir}/channel_*


END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
if [ "$NPROCS" == "1" ];
then
	echo " ($DIFF seconds)"
else
	echo -n " (finished ${dir} in ${DIFF} sec.) "
fi
