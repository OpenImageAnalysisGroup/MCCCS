#!/bin/bash
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°                          Welcome to the                           °"
echo "°       'Multi Channel Classification and Clustering System'        °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°          V1.0 developed in 2015-2016                              °"
echo "°          by the following members of the Research Group           °"
echo "°          - IMAGE ANALYSIS @ IPK -                                 °"
echo "°                                                                   °"
echo "°          Jean-Michel Pape and                                     °"
echo "°          Dr. Christian Klukas (Head of group)                     °"
echo "°                                                                   °"
echo "°          V2.0 developed in 2017-2018 by                           °"
echo "°          Dr. Christian Klukas                                     °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°              !! Script will stop in case of error. !!             °"
echo "°           !!  Last output is READY in case of no error !!         °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
set -e # stop script in case of error
START_SEC=$(date +%s)
bash ./train_rgb_segmentation.sh .. A1_training h A1
END_ALL=$(date +%s)
DIFF_T=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_rgb_segmentation.sh .. A1_prediction h A1_training A1
END_ALL=$(date +%s)
DIFF_P=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./train_rgb_segmentation.sh .. A2_training h A2
END_ALL=$(date +%s)
DIFF_TT=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_rgb_segmentation.sh .. A2_prediction h A2_training A2
END_ALL=$(date +%s)
DIFF_PP=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./train_rgb_segmentation.sh .. A3_training h A3
END_ALL=$(date +%s)
DIFF_TTT=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_rgb_segmentation.sh .. A3_prediction h A3_training A3
END_ALL=$(date +%s)
DIFF_PPP=$(echo "$END_ALL - $START_SEC" | bc)

printf "\n+------------------------------------------------------------------------+" &&
printf "\n" && \
printf "|                      Finished FG/BG calculations                       |\n" && \
printf "|------------------------------------------------------------------------|\n" && \
printf "|%8s %14s %16s %13s %16s |\n" "Dataset" "Training (min)" "Prediction (min)" "Training-Img." "Prediction-Img." && \
printf "|------------------------------------------------------------------------|\n" 
printf "|%8s %14s %16s %13s %16s |\n" "A1" $(dc -e "1k ${DIFF_T} 60 / p")   $(dc -e "1k ${DIFF_P} 60 / p")   $(echo $(find A1_training | grep _rgb.png | wc -l)) $(echo $(find A1_prediction | grep _rgb.png | wc -l)) && \
printf "|%8s %14s %16s %13s %16s |\n" "A2" $(dc -e "1k ${DIFF_TT} 60 / p")  $(dc -e "1k ${DIFF_PP} 60 / p") $(echo $(find A2_training | grep _rgb.png | wc -l)) $(echo $(find A2_prediction | grep _rgb.png | wc -l)) && \
printf "|%8s %14s %16s %13s %16s |\n" "A3" $(dc -e "1k ${DIFF_TTT} 60 / p") $(dc -e "1k ${DIFF_PPP} 60 / p") $(echo $(find A3_training | grep _rgb.png | wc -l)) $(echo $(find A3_prediction | grep _rgb.png | wc -l)) && \
printf "+------------------------------------------------------------------------+\n"