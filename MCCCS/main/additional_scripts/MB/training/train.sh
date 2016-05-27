#!/bin/bash
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°                          Welcome to the                           °"
echo "°       'Multi Channel Classification and Clustering System'        °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°          V1.0 developed in January till April 2015                °"
echo "°          by the following members of the Research Group           °"
echo "°                                                                   °"
echo "°          - IMAGE ANALYSIS at IPK -                                °"
echo "°                                                                   °"
echo "°          Jean-Michel Pape and                                     °"
echo "°          Dr. Christian Klukas (Head of group)                     °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°          Pipeline for for disease classification.                 °"
echo "°          Implemented by Jean-Michel Pape                          °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°              !! Script will stop in case of error. !!             °"
echo "°           !!  Last output is READY in case of no error !!         °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
# parameter:
# 1: path to the mcccs.jar
# 2: path to the data-files
# 3: number of procs
if [ "$#" -ne 3 ]; then
    echo "Please supply the path to the mcccs.jar as parameter 1, the path to the data-files as parameter 2 and s-single-threaded, m-multi-threaded as parameter 3!"
	exit 1
fi
# stop in case of error:
#set -e
#set path to preprocess (used for parallel processing)
PRES="$(pwd)/preprocess.sh"
echo "$PRES"
if ! [[ "$(uname)" == CYGWIN* ]]
then
	chmod +x $PRES
	chmod +x "prepare.sh"
fi
if [ "$(uname)" == "Darwin" ]; then
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
fi
echo "prepare"
source prepare.sh
FIRST=yes
echo Java command: $JAVA
echo
echo "Steps per directory:"
echo "(a) Generate Zero-Mask and PowerSet images from training ground-truth data files."
echo "(b) Generate ARFF files from training data." 
echo "(c) Create (first) or extend (following dirs) 'all_fbgb.arff' and 'all_disease.arff'."
echo
#find * -maxdepth 0 -type d | grep -F -v CVS | $par $PRES $2 {}
echo
for dir in */;
do
	echo -n "[c]"
	if [ $FIRST == "yes" ];
	then
		# add complete file, including header
		cat "${dir}/fgbgTraining.arff" >> all_fgbg.arff
		cat "${dir}/labelTraining.arff" >> all_label.arff
	else
		# ignore header
		# echo "Add data without header file to Arff"
		cat "${dir}/fgbgTraining.arff" | grep -v @ | grep -v "%"   >> all_fgbg.arff
		if [[ ( $dir != "MB0005-02_20150610_160508__SBCC-EXIB-P12A_000/" ) && ( $dir != "MB0005-02_20150610_165114__SBCC-EXIB-P10A_000/" ) && ( $dir != "MB0005-02_20150610_153256__SBCC-EXIB-P7D/" ) && ( $dir != "MB0005-02_20150610_153433__SBCC-EXIB-P9A/" ) ]];
		#if [ $dir == "ss" ];
		then
			cat "${dir}/labelTraining.arff"  | grep -v @ | grep -v "%"   >> all_label.arff;
		fi
	fi
	FIRST=no
done
echo
echo "Steps for classifier training:"
echo "(a) Train FGBG classifier using all_fgbg.arff file."
echo "(b) Train disease classifier using all_disease.arff file."
echo "Summarize data:"
echo -n "[a]"
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.trees.RandomForest -- -I 200
$WEKA weka.classifiers.trees.RandomForest -t 'all_fgbg.arff' -d fgbg.model -I 200
echo -n "[b]"
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_label.arff' -d label.model -W weka.classifiers.trees.RandomForest -- -I 100
$WEKA weka.classifiers.trees.RandomForest -t 'all_label.arff' -d label.model -I 50
echo
echo "Completed training."
echo
echo "Use model to predict result for data:"
echo "(a) Create .arff file for fgbg segmentation."
echo "(b) Classify foreground (fgbg.arff)."
echo "(c) Create foreground image (and composite if possible)."
echo "(d) Split leaves."
echo "(e) Reconstruct leaf shape (side smooth)."
echo "(f) Create .arff for disease classification."
echo "(g) Classify disease.arff."
echo "(h) Create classification image."
echo "(i) Quantify disease areas."
for dir in */;
do
	echo
    dir=${dir%*/}
    	echo -n "Process directory '${dir}': "

	echo -n "[a]"
	$JAVA.ArffFromImageFileGenerator 2 "${dir}"

 	echo -n "[b]"
	$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_2.arff" -serialized fgbg.model -classification -remove-old-class -o "${dir}/fgbgresult.arff" -c last -distribution

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

	#do classification
	echo -n "[d]"
	#$JAVA.ArffFromImageFileGenerator 3 "${dir}"
	ARFF_CLASS_INFO=$(grep -F "@attribute class" "${dir}/${dir}_2.arff")
	sed -i -e "s/$ARFF_CLASS_INFO/@attribute class {class0,class1,class2,class3}/g" "${dir}/${dir}_2.arff" 

	echo -n "[e]"
	$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_2.arff" -serialized label.model -classification -remove-old-class -o "${dir}/labelresult.arff" -c last -distribution

	#start loop for subplates again
	echo -n "[f]"
	for (( i=0; i<${#arrr[@]}; i++ ));
	do
		IDX=${arrr[$i]}
		echo -n "[$IDX]"
		cp ${dir}/foreground_rot_l_roi_$IDX'smooth_all_rot_r.tif' "${dir}/labelresult.tif"
		#$JAVA.ArffToImageFileGenerator 3 "${dir}/labelresult.tif"
		$JAVA.ArffToProbabilityImageFileGenerator 4 0.8 "${dir}/labelresult.tif"
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

		#echo -n "[g]"
		#rm -f ${dir}/*_quantified.csv
		$JAVA.Quantify 0 ${dir}/classified_$IDX'_rot_l_'*
		cat ${dir}/*_quantified.csv >> all_results.csv
	done
done

	ARR_SIZE=${#arrr[@]}
	ARR_SIZE=$(($ARR_SIZE-1))
	LASTELEMENT=${arrr[$ARR_SIZE]}

	mv ${dir}/classified_combined_$LASTELEMENT'.png' ${dir}/classified_combined'.png'
	$JAVA.Rotate r ${dir}/classified_combined'.png'
	mv ${dir}/classified_combined_rot_r'.tif' ${dir}/classified_all.'tif'

	echo "delete temporary results"
	rm -f ${dir}/classified_combined*
	#rm -f ${dir}/foreground*
	#rm -f ${dir}/*.arff
	#rm -f ${dir}/*.csv
	#rm -f ${dir}/channel_*
	#rm -f ${dir}/foreground_*
	echo
	echo "Transform result CSV file into column oriented CSV file."
	rm -f all_results.csv.transformed
	$JAVA.TransformCSV all_results.csv
	mv all_results.csv.transformed all_results.csv
echo
echo "Processing finished:"
echo
echo READY
