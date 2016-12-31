#!/bin/bash
echo
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°             Prediction for un-classified data of $5               °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"

# stop in case of error:
set -e
chmod +x *.sh
PF="$(pwd)/predict_folder.sh"
export SPLITCMD="$(pwd)/splitArff.sh"
if ! [[ "$(uname)" == CYGWIN* ]]
then
	chmod +x $PF
	chmod +x $SPLITCMD
fi
if [ "$(uname)" == "Darwin" ]; then
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
fi
if [ "$#" -ne 5 ]; then
    	echo "Illegal number of parameters: 1 - path to mcccs.jar, 2 - path to testing data folder, 3 - path to model file and s-single-threaded, m-multi-threaded as parameter 4, description of data set to improve progress output as parameter 5"
	exit 1
fi

export MODELPATH=$(realpath $4)
if [[ "$(uname)" == CYGWIN* ]]
then
	export MODELPATH=$(cygpath ../$4)
fi

source prepare.sh

echo "Path to model file: $MODELPATH"
WORKDIR=$(pwd)
cd "$WORKDIR"
echo
echo "Delete files:"
echo "'all_prediction_results.csv'"
rm -f all_prediction_results.csv
FIRST=yes
echo Java command: $JAVA
echo Weka command: $WEKA
echo
echo "Use model to predict result for data:"
echo "(a) Split RGB channels"
echo "(b) Convert RGB to HSV, XYZ, LAB to extend channel list"
echo "(c) Apply filter (blur, median) to extend channel list"
echo "(d) Create ARFF files from images"
echo "(e) Use trained 'fgbg.model' knowledge to detect fgbg areas"
echo "(f) Apply mask to result image"
echo "(g) Quantify predicted areas"
echo
echo "[Depending on the number of images, the prediction phase may take a longer time]"
echo
find * -maxdepth 0 -type d | grep -F -v CVS | $par $PF $WORKDIR {}
echo
echo "Transform result CSV file into column oriented CSV file..."
rm -f all_prediction_results.csv.transformed
$JAVA.TransformCSV all_prediction_results.csv
mv all_prediction_results.csv.transformed all_prediction_results.csv
echo
echo "Processing finished:"
echo "Model has been applied to training data. Disease infection rate is calculated:"
echo "      'all_prediction_results.csv'"
echo
echo READY
