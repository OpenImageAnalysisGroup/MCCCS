#!/bin/bash
#author Jean-Michel Pape & Christian Klukas
if [[ ! -f check_requirements.sh ]] ; then
    echo 'File "check_requirements.sh" is not there, aborting.'
    exit
fi
source check_requirements.sh
echo "The following data sets are downloaded from the respective data source websites:"
echo ""
echo "1. The segmentation example 'segmentation_example_1_classification' is available from http://www.plant-phenotyping.org/CVPPP2014-challenge. Please check the website and cite this paper if you use this data for your research:"
echo ""
echo "Hanno Scharr, Massimo Minervini, Andreas Fischbach, Sotirios A. Tsaftaris. Annotated Image Datasets of Rosette Plants. Technical Report No. FZJ-2014-03837, Forschungszentrum Jülich, 2014"
echo ""
echo "2. The classification and clustering examples using a hyperspectral data set 'hyper_example_1_classification' and 'hyper_example_2_clustering' are made available from https://engineering.purdue.edu/~biehl/."
echo ""
echo "Press Enter to continue or ctrl+c to abort."
read
echo "Continue and download of the following data sets and libraries?"
echo "1. https://engineering.purdue.edu/~biehl/Hyperspectral_Project.zip"
echo "2. http://www.plant-phenotyping.org/lw_resource/cvppp_dataset/LSCData.zip"
echo "3. http://downloads.sourceforge.net/project/weka/weka-3-6/3.6.12/weka-3-6-12.zip"
echo "4. http://downloads.openmicroscopy.org/bio-formats/5.1.0/artifacts/bioformats_package.jar"
echo "If the download fails (proxy/firewall), please use your webbrowser for download or modify this script."
echo ""
echo "Press Enter to continue or ctrl + c to abort."
read
#################################################################
# Download example data
#################################################################
mkdir -p example_data
cd example_data
echo "download example data to directory 'example_data'..."
wget -N "https://engineering.purdue.edu/~biehl/Hyperspectral_Project.zip"
echo "unzip downloaded zip file 1 ..."
unzip -o Hyperspectral_Project.zip
echo "create working directory 'hyper_example_1_classification' ..."
mkdir -p hyper_example_1_classification
cp Hyperspectral_Project/dc.tif hyper_example_1_classification/dc.tif
echo 
echo "create working directory 'hyper_example_2_clustering' ..."
mkdir -p hyper_example_2_clustering
cp Hyperspectral_Project/dc.tif hyper_example_2_clustering/dc.tif
wget -N "http://www.plant-phenotyping.org/lw_resource/cvppp_dataset/LSCData.zip"
echo "create working directory 'lsc_challenge' ..."
mkdir -p lsc_challenge
cp LSCData.zip lsc_challenge/LSCData.zip
cd lsc_challenge
unzip -o -q LSCData.zip
rm LSCData.zip
cd ..
echo "prepare A1"
mkdir -p segmentation_example_1_classification/A1_training
mkdir -p segmentation_example_1_classification/A1_prediction
cp lsc_challenge/A1/*00* segmentation_example_1_classification/A1_training
cp lsc_challenge/A1/* segmentation_example_1_classification/A1_prediction

echo "prepare A2"
mkdir -p segmentation_example_1_classification/A2_training
mkdir -p segmentation_example_1_classification/A2_prediction
cp lsc_challenge/A2/*00* segmentation_example_1_classification/A2_training
cp lsc_challenge/A2/* segmentation_example_1_classification/A2_prediction

echo "prepare A3"
mkdir -p segmentation_example_1_classification/A3_training
mkdir -p segmentation_example_1_classification/A3_prediction
cp lsc_challenge/A3/*00* segmentation_example_1_classification/A3_training
cp lsc_challenge/A3/* segmentation_example_1_classification/A3_prediction

cd ..

#################################################################
# Download libs
#################################################################
echo "Download libs: WEKA, Bio-Formats ..."

mkdir -p lib/weka

cd lib/weka/
wget -N "http://downloads.sourceforge.net/project/weka/weka-3-6/3.6.12/weka-3-6-12.zip" 
cp weka-3-6-12.zip weka.zip
cd ..
wget -N "http://downloads.openmicroscopy.org/bio-formats/5.1.0/artifacts/bioformats_package.jar" 
cp bioformats_package.jar bio.jar

cd weka
unzip -o -q weka.zip
cd weka-3-6-12
cp weka.jar ../../weka.jar
cd ..
rm -r weka-3-6-12

cd ../..
#################################################################
# Copy scripts to target example folders
#################################################################
echo "copy scripts into example folders"
cp example_scripts/example_RGB_segmentation/* example_data/segmentation_example_1_classification
cp example_scripts/hyperspec_classification/* example_data/hyper_example_1_classification
cp example_scripts/hyperspec_clustering/* example_data/hyper_example_2_clustering

echo "Move all images and ground-truth images into subfolders for training and prediction."
#segmentation exp
cd example_data/segmentation_example_1_classification/A1_training
bash ../move_all_to_subdir.sh _label.png
bash ../move_all_to_subdir.sh _rgb.png
cd ..

cd A1_prediction
rm -f *label.png
bash ../move_all_to_subdir.sh _rgb.png
cd ..

cd A2_training
bash ../move_all_to_subdir.sh _label.png
bash ../move_all_to_subdir.sh _rgb.png
cd ..

cd A2_prediction
rm -f *label.png
bash ../move_all_to_subdir.sh _rgb.png
cd ..

cd A3_training
bash ../move_all_to_subdir.sh _label.png
bash ../move_all_to_subdir.sh _rgb.png
cd ..

cd A3_prediction
rm -f *label.png
bash ../move_all_to_subdir.sh _rgb.png
cd ..
cd ../..

#classification hyper
cd example_data/hyper_example_2_clustering
mkdir -p stack_images
mkdir -p stack_images/dc
cp dc.tif stack_images/dc.tif
cd stack_images
bash ../move_all_to_subdir.sh tif
cd ../../..

#classification hyper
cd example_data/hyper_example_1_classification
mkdir -p stack_images
mkdir -p stack_images/dc
cp dc.tif stack_images/dc.tif
cd stack_images
bash ../move_all_to_subdir.sh tif
cd ../../..
echo ""
echo ""
echo "***************************************************************"
echo "Finish dataset preparation, MCCCS is ready for testing!"
echo ""
echo "Type the following commands in a shell to perform the analysis:"
echo ""
echo "- Experiment 1 (RGB FG/BG segmentation) -"
echo "cd example_data/segmentation_example_1_classification"
echo "bash process_segmentation_example_1_classification.sh"
echo ""
echo "- Experiment 2 (hyperspectral data classification) -"
echo "cd example_data/hyper_example_1_classification"
echo "bash ./process_hyper_example_1_classification.sh"
echo ""
echo "- Experiment 3 (hyperspectral data clustering) -"
echo "cd example_data/hyper_example_2_clustering"
echo "bash ./process_hyper_example_2_clustering.sh"
echo ""
echo "At this stage of the development 8 GB Memory are necessary to"
echo "perform the analysis without errors!"
echo ""
echo "Overall disk space utilized after running examples 23 GB."
echo "(FGBG segmentation example 1: 19 GB, hyperspectral examples 2 & 3: 3.5 GB)"
echo ""
echo "Calculation time for application examples:"
echo "Segmentation FGBG (A1, A2, A3): ~118 min"
echo "Hyperspec classification: ~1:50 min"
echo "Hyperspec clustering: ~1:47 min"
echo "***************************************************************"
