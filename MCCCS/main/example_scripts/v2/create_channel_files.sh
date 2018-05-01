#!/bin/bash	
set -e # stop script in case of error
dir=$2
dir=${dir%*/}
echo -n "[${dir}]" 

TIME_START=$(date +%s)
TMP=$(mktemp -d)

# create pipes
mkfifo ${TMP}/p_rgb1_r.tif ${TMP}/p_rgb1_g.tif ${TMP}/p_rgb1_b.tif
mkfifo ${TMP}/p_rgb2_r.tif ${TMP}/p_rgb2_g.tif ${TMP}/p_rgb2_b.tif
mkfifo ${TMP}/p_rgb3_r.tif ${TMP}/p_rgb3_g.tif ${TMP}/p_rgb3_b.tif

mkfifo ${TMP}/p_hsv_h.tif ${TMP}/p_hsv_s.tif ${TMP}/p_hsv_v.tif
mkfifo ${TMP}/p_lab_l.tif ${TMP}/p_lab_a.tif ${TMP}/p_lab_b.tif
mkfifo ${TMP}/p_xyz_x.tif ${TMP}/p_xyz_y.tif ${TMP}/p_xyz_z.tif

# set-up processing pipeline (tree)

	# start filter operations on hsv/xyz/lab channel images (wait for split channel images)
	for p_img in ${TMP}/p_*_*.tif;
	do
		$JAVA.V2.FILTER "${p_img}" "${p_img}" 2 2 BLUR   &
		$JAVA.V2.FILTER "${p_img}" "${p_img}" 3 3 MEDIAN &
	done

	# start rgb to hsv/xyz/lab conversion in background (wait for r/g/b input)
	$JAVA.RGB2HSV -rgb_r ${TMP}/p_rgb1_r.tif -rgb_g ${TMP}/p_rgb1_g.tif -rgb_b ${TMP}/p_rgb1_b.tif -b 8 \
			 -hsv_h ${TMP}/p_hsv_h.tif -hsv_s ${TMP}/p_hsv_s.tif -hsv_v ${TMP}/p_hsv_v.tif &
	$JAVA.RGB2XYZ -rgb_r ${TMP}/p_rgb2_r.tif -rgb_g ${TMP}/p_rgb2_g.tif -rgb_b ${TMP}/p_rgb2_b.tif -b 8 \
			 -xyz_x ${TMP}/p_xyz_x.tif -xyz_y ${TMP}/p_xyz_y.tif -xyz_z ${TMP}/p_xyz_z.tif &
	$JAVA.RGB2LAB -rgb_r ${TMP}/p_rgb3_r.tif -rgb_g ${TMP}/p_rgb3_g.tif -rgb_b ${TMP}/p_rgb3_b.tif -b 8 \
			 -lab_l ${TMP}/p_lab_l.tif -lab_a ${TMP}/p_lab_a.tif -lab_b ${TMP}/p_lab_b.tif &

# split RGB to R/G/B, fill pipeline with data
python3 extract_tiff_channels.py \
	--image ${dir}/*rgb*tiff \
	--channels 0 1 2 \
	--8bitToFloat32 \
	--targets \
		>(tee ${TMP}/p_rgb_r1.tif >(tee ${TMP}/p_rgb_r2.tif ${TMP}/p_rgb_r3.tif) ) \
		>(tee ${TMP}/p_rgb_g1.tif >(tee ${TMP}/p_rgb_g2.tif ${TMP}/p_rgb_g3.tif) ) \
		>(tee ${TMP}/p_rgb_b2.tif >(tee ${TMP}/p_rgb_b2.tif ${TMP}/p_rgb_b3.tif) )

wait # for pipeline to finish

rm ${TMP}/p_*

# read _label.png image and create binary mask
# create mask_1.png, mask_1.arff, mask_2.png, mask_2.arff
$JAVA.ThresholdGTforFGBG ${dir}/*label*

# create fgbgTraining.arff
$JAVA.ArffSampleFileGenerator -2 2500 "${dir}"
mv ${dir}/fgbgTraining.arff ${dir}/fgbg_training_sample.arff

TIME_END=$(date +%s)
TIME_DIFF=$(echo "${TIME_END} - ${TIME_START}" | bc)

if [ "$NPROCS" == "1" ]
then
	echo "[${TIME_DIFF} seconds]"
	else
	echo -n "[finished ${dir} in ${TIME_DIFF} sec.]"
fi
