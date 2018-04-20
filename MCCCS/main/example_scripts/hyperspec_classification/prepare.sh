if [ "$#" -ne 3 ]; then
    echo "Please supply the path to the mcccs.jar as parameter 1, the path to the data-files as parameter 2 and the number of desired cluster-classes as parameter 3!"
	exit 1
fi

cd "$2"
rm -f all_results.csv
rm -f all_label.arff
rm -f labelClassifier.data
rm -f label.model