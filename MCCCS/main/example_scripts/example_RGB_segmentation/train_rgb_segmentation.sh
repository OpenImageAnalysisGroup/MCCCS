#!/bin/bash
set -e # stop in case of error
echo
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°             Training for FGBG classification of $4                °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
# parms: 1. path to mcccs.jar 2. processing directory 3. s - single-threaded, m -multi-threaded
if [ "$#" -ne 4 ]; then
	echo "Please supply the path to the mcccs.jar as parameter 1, the path to the data-files as parameter 2 and s-single-threaded, m-multi-threaded as parameter 3, description of data set to display progress as parameter 4!"
	exit 1
fi
PROCESS_DIR=$2
source set_env.sh
export MODELPATH=$(realpath $PROCESS_DIR)

echo "PROCESS_DIR          = $PROCESS_DIR"
echo "JAVA                 = $JAVA"
echo "PARALLEL_EXECUTE     = $PARALLEL_EXECUTE"
echo "CREATE_CHANNEL_FILES = $CREATE_CHANNEL_FILES"
echo "MODELPATH            = $MODELPATH"
echo "pwd                  = $(pwd)"
echo

cd "$PROCESS_DIR"
# remove eventually previously created files
rm -f all_results.csv
rm -f all_fgbg.arff
rm -f all_disease.arff
rm -f fgbgClassifier.data
rm -f diseaseClassifier.data
rm -f fgbg.model

echo "Steps per directory:"
echo "1. Split RGB to channel images"
echo "2. Convert images to H/S/V, X/Y/Z, L/A/B (one image per channel)"
echo "3. Perform image operations median and blur to extend the channel list"
echo "4. Threshold ground-truth"
echo "5. Generate ARFF files from color channels and image operation results"
echo
echo "Generate training data:"
RELATIVE_PROCESS_DIR=$(realpath --relative-to="${PWD}" "$PROCESS_DIR")
find * -maxdepth 0 -type d -print0 | $PARALLEL_EXECUTE "$CREATE_CHANNEL_FILES" "$RELATIVE_PROCESS_DIR" {}
echo
echo
echo "Create overall FB/GB training data set file 'all_fgbg.arff'..."

for dir in */;
do
	if  [ ! -f all_fgbg.arff ]
	then
		# add complete file, including header
		cat "${dir}/fgbg_training_sample.arff" > all_fgbg.arff
	else
		# ignore header
		cat "${dir}/fgbg_training_sample.arff" | grep -v @ | grep -v "%"   >> all_fgbg.arff
	fi
done

echo
echo "Classifier-Training:"
echo "Train FGBG classifier from file 'all_fgbg.arff'..."
echo
START=$(date +%s)
$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d "${MODELPATH}/fgbg.model" -W weka.classifiers.trees.RandomForest -- -I 50 -K 0 -S 1
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.trees.J48 -- -C 0.25 -M 2
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.bayes.NaiveBayes
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d "${MODELPATH}/fgbg.model" -W weka.classifiers.trees.RandomForest -- -I 200 -K 0 -S 1
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.bayes.BayesNet -- -D -Q weka.classifiers.bayes.net.search.local.K2 -- -S BAYES -E weka.classifiers.bayes.net.estimate.SimpleEstimator -- -A 0.5
echo
END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
echo
echo "Completed training of classifier model in $DIFF seconds (result model file 'fgbg.model')."
echo
echo "Use model to predict result for training data:"
echo "1. Apply model (prediction step)"
echo "2. Create foreground/background (FGBG) mask"
echo "3. Quantify areas"
echo "4. Create difference image of training masks vs. predicted result image"
echo
find * -maxdepth 0 -type d -print0 | $PARALLEL_EXECUTE "$PREDICT_FOLDER" "$PROCESS_DIR" {}
echo
echo "Transform result CSV file into column oriented CSV file..."

for dir in plant*/;
do
	cat ${dir}*_quantified.csv >> all_results.csv
done

rm -f all_results.csv.transformed
$JAVA.TransformCSV all_results.csv
mv all_results.csv.transformed all_results.csv
echo
echo "Processing finished:"
echo "1. FGBG model is trained: "
echo "      'fgbg.model'"
echo "2. Model has been applied to training data. Area pixel counts have been calculated:"
echo "      'all_results.csv'"
echo
echo READY
