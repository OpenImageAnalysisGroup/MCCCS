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
bash ./train_rgb_segmentation.sh .. A1_training f A1
END_ALL=$(date +%s)
DIFF_T=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_rgb_segmentation.sh .. A1_prediction f A1_training A1
END_ALL=$(date +%s)
DIFF_P=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./train_rgb_segmentation.sh .. A2_training f A2
END_ALL=$(date +%s)
DIFF_TT=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_rgb_segmentation.sh .. A2_prediction f A2_training A2
END_ALL=$(date +%s)
DIFF_PP=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./train_rgb_segmentation.sh .. A3_training f A3
END_ALL=$(date +%s)
DIFF_TTT=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_rgb_segmentation.sh .. A3_prediction f A3_training A3
END_ALL=$(date +%s)
DIFF_PPP=$(echo "$END_ALL - $START_SEC" | bc)

printf "\n+--------------------------------------+" &&
printf "\n" && \
printf "|     Finished FG/BG calculations      |\n" && \
printf "|--------------------------------------|\n" && \
printf "|%8s %13s %14s |\n" "Dataset" "Training (s)" "Prediction (s)" && \
printf "|--------------------------------------|\n" && \
printf "|%8s %13s %14s |\n" "A1" "$DIFF_T" "$DIFF_P" && \
printf "|%8s %13s %14s |\n" "A1" "$DIFF_TT" "$DIFF_PP" && \
printf "|%8s %13s %14s |\n" "A1" "$DIFF_TTT" "$DIFF_PPP" && \
printf "+--------------------------------------+\n"
