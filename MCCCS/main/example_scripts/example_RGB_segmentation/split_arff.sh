#!/bin/bash
# parameter: $1 dir, $2 arff_name, $3 split - true/false, $4 outputname $5 size of split in bytes (500.000.000 B ~ 500 MB)
# get length of header
HEADERLEN=$(sed -n '/%/,/@data/ p' "$1/$2" | wc -l)
# extract header
sed -n '/%/,/@data/p' "$1/$2" > $1/header.arff
# split beginning from $HEADERLEN
if [[ "$3" == true ]]
then
	rm -f $1/split_arff_*
	tail -n +$HEADERLEN "$1/$2" | split -C $5 -d - "$1/split_arff_"
fi
# add header and do classification
IDX=0
for splitarff in $1/split_arff_*;
do
	# be sure that IDX has three digits
	while [[ ${#IDX} -lt 3 ]]; 
	do 
		IDX="0"$IDX
	done
	
	cat "$1/header.arff" "$splitarff" > "${splitarff}.arff"
	rm "$splitarff"
	# classification by WEKA
	$WEKA weka.filters.supervised.attribute.AddClassification -i "${splitarff}.arff" -serialized "$MODELPATH/$4.model" -classification -remove-old-class -o "$1/split_result_${IDX}.arff" -c last -distribution
	rm -f "${splitarff}.arff"
	IDX=$((10#$IDX + 1))
done
rm "$1/header.arff"
# merge classified arffs
# get length of header
HEADERLEN=$(sed -n '/@relation/,/@data/ p' "$1/split_result_000.arff" | wc -l)
# extract header
sed -n '/@relation/,/@data/p' "$1/split_result_000.arff" > "$1/header_result.arff"
# add header and merge
for file in $1/split_result_*;
do
	tail -n +$((HEADERLEN + 1)) "$file" >> "$1/temp_result.arff"
	rm "$file"
done
cat "$1/header_result.arff" "$1/temp_result.arff" > "$1/$4_result.arff"
rm -f "$1/temp_result.arff"
rm -f "$1/header_result.arff"
