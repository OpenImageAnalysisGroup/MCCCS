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
# 4: path to the model files
# 5: threshold for reject option during classification
if [ "$#" -ne 5 ]; then
    echo "Please supply the path to the mcccs.jar as parameter 1, the path to the data-files as parameter 2, s-single-threaded, m-multi-threaded as parameter 3, path to the model files as parameter 4 and Threshold for reject option as parameter 5!"
	exit 1
fi
# stop in case of error:
#set -e
#set path to preprocess (used for parallel processing)
PREDICT="$(pwd)/predict_folder.sh"
export SPLITCMD="$(pwd)/splitArff.sh"
STARTTIME=$(date)
START_SEC=$(date +%s)
echo "Start: ""$STARTTIME"
echo "$PREDICT"
if ! [[ "$(uname)" == CYGWIN* ]]
then
	chmod +x $PREDICT
	chmod +x "prepare.sh"
fi
if [ "$(uname)" == "Darwin" ]; then
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
fi
echo "prepare"
source prepare.sh
echo Java command: $JAVA
export MODELPATH="../$4"
echo "Path to model files:"
echo "$MODELPATH"
export CL_REJECT=$5
echo "Value for CL_REJECT:"
echo "$CL_REJECT"
echo
echo "Use model to predict result for data:"
echo "(a) Create .arff file for fgbg segmentation."
echo "(b) Classify foreground (fgbg.arff)."
echo "(c) Process subplates."
echo "	(1) Create foreground image."
echo "	(2) Split leaves."
echo "	(3) Reconstruct leaf shape (side smooth)."
echo "(d) Create .arff for disease classification."
echo "(e) Classify disease.arff."
echo "(f) Create classification image for all subplates."
echo "(g) Quantify disease areas."
echo
find * -maxdepth 0 -type d | grep -F -v CVS | $par $PREDICT $2 {}
echo
echo -n "[g]"
for dir in */;
do
	echo "Quantify: $dir"
	$JAVA.Quantify_Enhanced 0 ${dir}/classified_all_$CL_REJECT.'tif'
	cat ${dir}*_quantified.csv >> all_results.csv
done
echo "Transform result CSV file into column oriented CSV file."
rm -f all_results.csv.transformed
$JAVA.TransformCSV all_results.csv
mv all_results.csv.transformed all_results_$CL_REJECT.csv
#rm all_results.csv
echo "copy and combine results ..."
./../copy_and_combine_results.sh "$CL_REJECT" "$2" "models_005_2"
END_ALL=$(date +%s)
DIFF=$(echo "$END_ALL - $START_SEC" | bc)
echo
echo "Processing finished:" $(date) " started at: " "$STARTTIME"" (overall $DIFF seconds)"
echo "Result images are stored in the individual experiment folder,"
echo "numeric results are stored in 'all_results.csv'."
echo
echo READY
