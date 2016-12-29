#!/bin/bash
echo
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°             Training for FGBG classification of $4                °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
# parms: 1. path to mcccs.jar 2. processing directory 3. s - single-threaded, m -multi-threaded
# stop in case of error:
if [ "$#" -ne 4 ]; then
    echo "Please supply the path to the mcccs.jar as parameter 1, the path to the data-files as parameter 2 and s-single-threaded, m-multi-threaded as parameter 3, description of data set to display progress as parameter 4!"
	exit 1
fi
set -e
PREDICTCMD="$(pwd)/predict_folder.sh"
export SPLITCMD="$(pwd)/splitArff.sh"
PRES="$(pwd)/preprocess.sh"
if ! [[ "$(uname)" == CYGWIN* ]]
then
	chmod +x $PREDICTCMD
	chmod +x $PRES
	chmod +x "prepare.sh"
fi
if [ "$(uname)" == "Darwin" ]; then
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
fi
source prepare.sh
echo Java command: $JAVA
echo
echo "Steps per directory:"
echo "(a) Split RGB to channel images."
echo "(b) Convert images to HSV, XYZ, LAB."
echo "(c) Perform image operations to extend the channel list."
echo "(d) Generate ARFF files from training data." 
echo "(e) Create or extend ARFF file 'all_fbgb.arff'."
echo
find * -maxdepth 0 -type d | grep -F -v CVS | $par $PRES $2 {}
echo
echo "Create overall FB/GB training data set file 'all_fgbg.arff'..."
FIRST="yes"
for dir in */;
do
	if  [ "$dir" = "CVS/" ]; then
		echo -n "[Ignore CVS directory]"
		continue
 	fi
	if  [ "$FIRST" = "yes" ]; then
		# add complete file, including header
		# echo "Add complete file to Arff."
		cat "${dir}fgbgTraining.arff" >> all_fgbg.arff
	else
		# ignore header
		cat "${dir}fgbgTraining.arff" | grep -v @ | grep -v "%"   >> all_fgbg.arff
	fi
	FIRST="no"
done
echo
echo
echo "Classifier-Training:"
echo "Train FGBG classifier from file 'all_fgbg.arff'..."
echo
START=$(date +%s)
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.trees.J48 -- -C 0.25 -M 2
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.bayes.NaiveBayes
$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.trees.RandomForest -- -I 200 -K 0 -S 1
#$WEKA weka.classifiers.meta.FilteredClassifier -t 'all_fgbg.arff' -d fgbg.model -W weka.classifiers.bayes.BayesNet -- -D -Q weka.classifiers.bayes.net.search.local.K2 -- -S BAYES -E weka.classifiers.bayes.net.estimate.SimpleEstimator -- -A 0.5
echo
END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
echo "Completed training of classifier model in $DIFF seconds (file 'fgbg.model')."
echo
echo "Use model to predict result for training data:"
echo "(a) Convert images to ARFF."
echo "(b) Apply model (prediction step)."
echo "(c) Create foreground/background (FGBG) mask."
echo "(d) Create difference image of training masks vs. predicted result image."
echo "(e) Quantify areas."
#export MODELPATH="$(pwd)/"
#echo "Path to model file: $MODELPATH"
WORKDIR=$(pwd)
cd "$WORKDIR"
find * -maxdepth 0 -type d | grep -F -v CVS | $par $PREDICTCMD $WORKDIR {}
echo
echo "Transform result CSV file into column oriented CSV file..."
for dir in plant*/;
do
	if  [ "$dir" = "CVS" ]; then
		echo "Ignore CVS directory."
	else
	cat ${dir}/*_quantified.csv >> all_results.csv
	fi
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
