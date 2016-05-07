#!/bin/bash
dir=$2
dir=${dir%*/}
START=$(date +%s)
echo -n "[${dir}]"   
echo -n "a"
rm -f ${dir}/channel_*
rm -f ${dir}/*.arff
rm -f ${dir}/*_quantified.csv
rm -f ${dir}/foreground.png
$JAVA.SplitRGB ${dir}/*rgb*

#apply filter
echo -n "b"
$JAVA.RGB2HSV ${dir}/*rgb_r.png ${dir}/*rgb_g.png ${dir}/*rgb_b.png 8
$JAVA.RGB2XYZ ${dir}/*rgb_r.png ${dir}/*rgb_g.png ${dir}/*rgb_b.png 8
$JAVA.RGB2LAB ${dir}/*rgb_r.png ${dir}/*rgb_g.png ${dir}/*rgb_b.png 8

echo -n "c"
for img in ${dir}/channel*;
do
$JAVA.FILTER ${img} ${img} 3 3 BLUR
$JAVA.FILTER ${img} ${img} 4 4 MEDIAN
done

echo -n "d"
$JAVA.ArffFromImageFileGenerator 2 "${dir}"

echo -n "e"
$WEKA weka.filters.supervised.attribute.AddClassification -i "${dir}/${dir}_2.arff" -serialized "$MODEL" -classification -remove-old-class -o "${dir}/result.arff" -c last

echo -n "f"
#create foreground png
cp "${dir}/channel_rgb_r.png" "${dir}/result.png"
$JAVA.ApplyClass0ToImage "${dir}/result.png"
rm "${dir}/result.png"

echo -n "g"
cp "${dir}/foreground.png" "${dir}/foreground_cluster.png"
$JAVA.Quantify 0 ${dir}/foreground
rm "${dir}/foreground_cluster.png"
cat ${dir}/*_quantified.csv >> all_prediction_results.csv

rm -f ${dir}/channel_*
rm -f ${dir}/*.arff

END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
echo -n " (finished ${dir} in ${DIFF} sec.) "
