# AddClassAttributeFromARFFimageAndMasks

Reads the image ARFF file, and all provided mask ARFF files.
Outputs N rows for each class.
Requires less memory, as all input ARFF files are read row by row, so only
one row of each input ARFF needs to stay in memory. In addition sets of valid row indices for
each mask file need to be constructed, to allow random selection of random samples. From the
mask ARFF files, the correct class of the current image row is detected, and the according class
information is added at the end of each image ARFF line.
The input mask files need to be read two times, the first time the number of
samples in each class are determined, so that in the main run the correct number
of samples may be selected randomly from the class rows. At least two mask arff files should be provided (though one would be enough, but then all image rows would belong to a single class.
        
* @param	class sample size N
* @param	output arff file
* @param	image arff file
* @param	mask arff file 0
* @param	mask arff file 1
* @param	mask arff file 2 
* @param	[..]

* @return	ARFF file


# ApplyClass0ToGrayScaleImage

Converts classified ARFF result file to an image by using a labeled mask image.

* @param	input filename(s)
* @return	image file


# ApplyClass0ToImage

Converts classified ARFF result file to an image by using a labeled mask image.

* @param	input filename(s) for ARFF files
* @return	visualization image of class 0 from input file


# ApplyMask

Converts classified ARFF result file to an image by using a labeled mask image.

* @param	directory with input file(s) images
* @param	directory with input file(s) images ROIs

* @return	cleared image (by given ROI)


# ApplyMaskImage

Applies a mask on the input image, the output will be saved in a separate target file.

* @param	image	path to input image
* @param	mask	path to mask image
* @param	target	path to output directory

* @return	image file


# ApplyROIAndCrop

Apply a mask to given an image and return a cropped version with specified name (target file) and extension (file format).

* @param	image
* @param	mask
* @param	target file name
* @param	file format

* @return	image file


# ArffFromImageFileGenerator

Converts image into an ARFF file.

* @param	class-count
* @param	input filename

* @return ARFF file


# ArffSampleFileGenerator

Sample Extraction from input images, generates .arff file for classifier training.

* @param	class-count (negative in case of foreground/background segmentation)
* @param	sample-size
* @param	input filename(s)

* @return	ARFF file


# ArffToImageFileGenerator

Converts classified ARFF result file to an image by using FG mask.

* @param	channel count (int)
* @param	input ARFF file(s)

* @return	classified image


# ArffToProbabilityImageFileGenerator

Converts classified ARFF result file (including pixel-probabilities for each class) to an grayscale-image (use of FG mask is possible).

* @param	channel count (positive value = .png output, negative value = .tif output)
* @param	threshold for acceptance
* @param	input filename(s) of ARFF file(s)

* @return	grayscale image


# ClacImage

Create image by calculating the difference, sum, division or multiplication of two images.

* @param	image A
* @param	image B
* @param	output file
* @param	one of this: +,-,*,/, absdiff, and
* @param	RGB or Float mode

* @return	difference image according to operation mode


# CalculateDistanceMap

Calculate distance map float image. Modes: 0 - eucl. distance map X, 1 - eucl. distance map Y, 2 - eucl. distance map dist, 3 - euchl. distance map degree*255/360.

* @param	mode 0/1/2/3
* @param	input mask
* @param	target TIFF file (distance map)

* @return	distance map image (tif)


# ColoredRegionGrowing

Nearest-neighbor approach, to find colorized areas near uncolored foreground
area. Assign color of nearest colorized pixel to uncolored pixels. Input is a
colored image, with some uncolored (white) areas, mask image, background
pixels (black) are ignored during processing.

* @param	input image (RGB)
* @param	image for over-drawing (edges)
* @param	target filename

* @return	result image


# ColoredRegionGrowingSingle

Nearest-neighbor approach, to find colorized areas near uncolored foreground
area. Assign color of nearest colorized pixel to uncolored pixels. Input is a
colored image, with some uncolored (white) areas, mask image, background
pixels (black) are ignored during processing.

* @param	input image (RGB)
* @param	target filename

* @return	result image


# CombineDirectionalProbabilityImages

Combines two probability images.

* @param	image 1 (grayscale tif)
* @param	image 2 (grayscale tif)
* @param	taarget filename
* @param	Modes: 0 - img1 = X, img2 = Y; 1 - img1 = DIST, img2 = DEGREE*255/360

* @return	image file


# ConvertPSIIToTif

Command to convert .dumm (raw image files for PSII measurements) and
.fimg (result image files, including the results for a feature as 
calculated during PSII analysis) to .tif image files.
 
* @param	path to folder including files for conversion

* @return	converted images (saved into same folder as used for input)


# CreateCircularGradientImage

Creates an circular gradient image (tif float), the most far point from the
center has value 0, the center point has value 1. The dimensions of the
target image are determined from the given input (template) image. 

* @param	input image
* @param	filename output (should have tif extension)

* @return	image file


# CreateDiffImage

Create difference image, indicating true positive and true negative in white.
False positive in blue and false negative in red.

* @param	ground truth mask
* @param	prediction
* @param	output file name for difference image

* @return	difference image


# Erode

This command performs the erode operation on a given input image (black pixels will be regarded as foreground, white as background).

* @param	input image

* @return	image


# ExportImagesFromHyperSpec

Creates separate images from hyper-spectral image data set (BSQ, BIL format).

* @param	prefix for output filename
* @param	overflow threshold or negative value to disable
* @param	filenames (input)

* @return	image files (channel images)


# FILTER

Based on an input image an image operation is performed and a target result file is saved.

* @param	input image
* @param	target file
* @param	mask size (int)
* @param	sigma for gaussian blur (double)
* @param	operation mode (SHARPEN, BLUR, MEDIAN, TEXTURE, HARLICK, ALL)

* @return	filtered result image


# MakeRGBComposite

This command combines three images 'channel_0, channel_1, channel_2' (0 = red, 1 = green, 2 = blue) to an RGB composite image.

* @param	input R/G/B images ('channel_0, channel_1, channel_2' (0 = red, 1 = green, 2 = blue))

* @return	RGB composite image


# MergeArffFiles

Merges two or more ARFF files (concatinates the column data)

* @param	target file
* @param	input filenames
* @param	-ColIndex for ARFF files to be merged specified
* @param	optionally specific columns may be removed from the output (1...x)
* @param	by adding +str an string can be added into the last column! Return Code 1"

* @return	merged ARFF file


# PoersetGenerator

Generates inverted mask of given masks (AND + INV). Also generates a powerset of the input combinations of images.
All these images are then saved.

* @param	class count (int)
* @param	input image(s)

* @return	powerset combinations


# QuantifyEnhanced

Compared to the simple Quantify command (works for one object in an image), it is possible to analyze and distinguish several separated objects in an image. The results are saved into a .csv file and a debug image.

* @param	output mode (0 = percentage, 1 = absolute values)
* @param	image file

* @return	csv file
* @return	debug image


# Quantify

Reads and image and quantifies (counts) the foreground pixels, marked with different colors.
For each color a the corresponding infection rate is calculated.

* @param	output mode (0 = percentage, 1 = absolute values)
* @param	image file (starting with classified_, cluster or ends with _cluster)

* @return	csv file

# RGB2ALL

Create color channel files in diverse color spaces.

* @param	R/G/B input images (split channels)
* @param	color channel index (0..19, -1 = all, ? = list)
* @param	input color space index (0..4, -1 = all, ? = list)

* @return	channel_xyz_x.png, ... (diverse set of color channels)

# RGB2Bayer

Create Bayer patterned image file (gray scale).

* @param	R/G/B image files

* @return	bayer_pattern image (tif)


# RGB2HSB

Create H/S/B image files from R/G/B image files.

* @param	R/G/B image files
* @return	channel_hsv_h.png, channel_hsv_s.png, channel_hsv_v.png


# RGB2LAB

Create L/a/b image files from R/G/B files.

* @param	R/G/B image files

* @return	channel_lab_l.png, channel_lab_a.png, channel_lab_b.png


# RGB2XYZ

Transform R/G/B input image files to the corresponding X/Y/Z image files.

* @param	R/G/B image files

* @return	channel_xyz_x.png, channel_xyz_y.png, channel_xyz_z.png


# RgbBayer2Arff

Converts RGB image (Bayer pattern) to an ARFF file.

* @param	R/G/B image files
* @param	bayer pattern

* @return	one 'output.arff'


# Rotate

Rotates an image in left or right direction by 90 degree.

* @param	input image
* @param	direction [l,r]

* @return	image


# RoundMaskRatio

Determine the difference in the brightness of a inner circle to the area of a outer ring around that circle. Function is related to BlSpotMatcher in IAP.

* @param	input image
* @param	target File
* @param	outer circle radius
* @param	dark or bright background

* @return	contrast image


# SideSmooth

Smoothes the left and right-hand side borders of a single object within the image.
Uses a polynom to fit a curve and reconstructs the image object with the smoothed-out
side borders.

* @param	binary image

* @return	binary image


# Split

Splits leaves within image (objects which all reach a certain top-position and which at the same time
reach a certain lower-end position. Objects which don't 'touch' these virtual top and lower borders, which
are of less height, are removed. Then each object which full-fills these criteria, a new image with only
that specific object is created.
 
* @input	image file
* @return	file_1.png, file_2.png, file_3.png, ...  - objects separated


# SplitHistBased

Splits leaves within image (objects which all reach a certain top-position and which at the same time
reach a certain lower-end position. Objects which don't 'touch' these virtual top and lower borders, which
are of less height, are removed. Then each object which full-fills these criteria, a new image with only
that specific object is created.

* @param	image file

* @return	file_1.png, file_2.png, file_3.png - objects separated, sorted by x-position of the segment centers


# SplitRGB

Splits RGB image into separate channel images.

* @return	channel0.png, channel1.png, channel2.png or .tif files.
* @param	image - input image


# SplitTiffStackToImages

Splits input Tiff-stack into separate images (e.g. useful for hyper-spectral datasets).

* @param	tif stack

* @return	separate images, channel_1.tif, channel_2.tif, ...


# ThresholdGTforFGBG

Apply threshold to ground truth (GT) images to generate binary foreground- and background-masks, and the corresponding ARFF files for classifier training.

* @param	colored ground truth image
* @return	mask_1.png, mask_2.png (forground and background mask images), and according mask_1.arff, mask_2.arff files!


# TransformCSV

Reads the CSV result file and transforms some rows to columns and
renames infection color ids to human-readable traits.
Cleans-up some content of the column entries, fills empty with 0.0.
 
* @param	csv file
* @return	csv file


