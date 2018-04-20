#!/bin/bash
set -e # stop in case of error
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°                          Welcome to the                           °"
echo "°       'Multi Channel Classification and Clustering System'        °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°          V1.0 developed in 2015-2016                              °"
echo "°          by the following members of the Research Group           °"
echo "°          - IMAGE ANALYSIS @ IPK -                                 °"
echo "°                                                                   °"
echo "°          Jean-Michel Pape and                                     °"
echo "°          Dr. Christian Klukas (Head of group)                     °"
echo "°                                                                   °"
echo "°          V2.0 developed in 2017-2018 by                           °"
echo "°          Dr. Christian Klukas                                     °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°              !! Script will stop in case of error. !!             °"
echo "°           !!  Last output is READY in case of no error !!         °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"

source ../segmentation_example_1_classification/set_env.sh
PREPROCESS_HYPER_CLASSIFICATION="$(pwd)/preprocess_hyper_classification.sh"

export CLASSCOUNT=$3

source prepare.sh
echo Java command: $JAVA
echo
echo "Steps per directory:"
echo "1. Split tiff-stack into separate images."
echo "2. Generate ARFF files from training data." 
echo "3. Create (first) or extend (following dirs) 'all_fbgb.arff'."
echo -n "."
find * -maxdepth 0 -type d -print0 | ${PARALLEL_EXECUTE} "${PREPROCESS_HYPER_CLASSIFICATION}" "{}"
echo -n "."

for dir in */;
do
	if  [ ! -f all_label.arff ]
	then
		cat "${dir}/labelTraining.arff" > all_label.arff
	else
		cat "${dir}/labelTraining.arff" | grep -v @ | grep -v "%"   >> all_label.arff
	fi
done

echo
echo
echo "Steps to summarize data:"
echo "1. Train FGBG classifier from all_label.arff file."
echo
echo "Summarize data:"
echo -n "."
$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_label.arff' -d label.model -W weka.classifiers.trees.RandomForest -- -I 100 -K 0 -S 1
echo
echo "Completed training."
echo
echo "Use model to predict result for data:"
echo "1. Convert image to ARFF."
echo "2. Apply model."
echo "3. Create FGBG mask."
echo "4. Quantify areas."
echo "5. Transform result CSV file into column oriented CSV file."
for dir in */;
do
	echo
	dir=${dir%*/}
	echo -n "[${dir}]"  
	
	echo -n "."
	rm -f "${dir}/${dir}.arff"
	echo "${dir}/${dir}.arff"
	$JAVA.ArffFromImageFileGenerator $CLASSCOUNT "${dir}"
		
	echo -n "."
	$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_7.arff" -serialized label.model -classification -remove-old-class -o "${dir}/result.arff" -c last -distribution
	
	echo -n "."
	#create foreground png
	cp "${dir}/channel_001.tif" "${dir}/result.tif"
	$JAVA.ArffToImageFileGenerator $CLASSCOUNT "${dir}/result.tif"
	$JAVA.ArffToProbabilityImageFileGenerator $CLASSCOUNT 0.99 "${dir}/result.tif"
	rm "${dir}/result.tif"
	
	echo -n "."
	cp "${dir}/classified.png" "${dir}/foreground_cluster.png"
	rm -f ${dir}/*_quantified.csv
	$JAVA.Quantify 0 "${dir}/foreground_cluster.png"
	rm "${dir}/foreground_cluster.png"
done
echo
echo "Transform CSV"

for dir in */;
do
	cat ${dir}/*_quantified.csv >> all_results.csv
done

rm -f all_results.csv.transformed
$JAVA.TransformCSV all_results.csv
mv all_results.csv.transformed all_results.csv
echo
echo "Processing finished:"
echo "1. WEKA Model (Random Forest) is trained: "
echo "      'fgbg.model'"
echo "2. Model has been applied to training data. Pixel-count for the different classes is calculated:"
echo "		'all_results.csv'"
echo "3. A labeled result image has been saved:"
echo "		'classfied.png'"
echo
echo READY
