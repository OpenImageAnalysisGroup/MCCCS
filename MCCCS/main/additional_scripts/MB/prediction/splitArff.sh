#!/bin/bash
# parameter: $1 dir, $2 arff_name, $3 split - true/false, $4 outputname
# get length of header
HEADERLEN=$(sed -n '/%/,/@data/ p' "$1/$2" | wc -l)
#echo "headerlen: $HEADERLEN"
# extract header
sed -n '/%/,/@data/p' "$1/$2" > $1/header.arff
# split beginning from $HEADERLEN
if [[ "$3" == true ]];
then
	tail -n +$HEADERLEN "$1/$2" | split -C 500000000 -d - $1/'split_arff'
fi
# add header and do classification
IDX=0
for splitarff in $1/split_arff*;
do
	# be sure that IDX has three digits
	while [[ ${#IDX} -lt 3 ]]; 
	do 
		IDX="0"$IDX
	done
	echo $splitarff
	cat "$1/header.arff" $splitarff > $splitarff".arff"
	# <(printf "\n%%")
	# classify
	$WEKA weka.filters.supervised.attribute.AddClassification -i "$splitarff.arff" -serialized $MODELPATH/$4.model -classification -remove-old-class -o "$1""/split_arff_result$IDX"".arff" -c last -distribution
	rm $splitarff".arff"
	IDX=$((10#$IDX + 1))
done
rm "$1/header.arff"
# merge classified arffs
# get length of header
HEADERLEN=$(sed -n '/@relation/,/@data/ p' "$1/""split_arff_result0"".arff" | wc -l)
echo "headerlen: $HEADERLEN"
# extract header
sed -n '/@relation/,/@data/p' "$1/split_arff_result0.arff" > "$1/header_result.arff"
# add header and concatenate
for file in $1/split_arff_result*;
do
	echo $file
	tail -n +$((HEADERLEN + 1)) "$file" >> $1"/tempresult.arff"
	rm $file
done
cat "$1/header_result.arff" $1"/tempresult.arff" > $1"/$4result.arff"
rm $1"/tempresult.arff"
exit
