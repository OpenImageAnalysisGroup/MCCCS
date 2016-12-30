#!/bin/bash
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°                          Welcome to the                           °"
echo "°       'Multi Channel Classification and Clustering System'        °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°          V1.0 developed in 2015, 2016                             °"
echo "°          by the following members of the Research Group           °"
echo "°                                                                   °"
echo "°          - IMAGE ANALYSIS at IPK -                                °"
echo "°                                                                   °"
echo "°          Jean-Michel Pape and                                     °"
echo "°          Dr. Christian Klukas (Head of group)                     °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°              !! Script will stop in case of error. !!             °"
echo "°           !!  Last output is READY in case of no error !!         °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
# stop script in case of error
set -e
START_SEC=$(date +%s)
bash ./train_FGBG_CVPPP.sh .. A1_training h A1
END_ALL=$(date +%s)
DIFF_T=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_CVPPP.sh .. A1_prediction h A1_training A1
END_ALL=$(date +%s)
DIFF_P=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./train_FGBG_CVPPP.sh .. A2_training h A2
END_ALL=$(date +%s)
DIFF_TT=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_CVPPP.sh .. A2_prediction h A2_training A2
END_ALL=$(date +%s)
DIFF_PP=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./train_FGBG_CVPPP.sh .. A3_training h A3
END_ALL=$(date +%s)
DIFF_TTT=$(echo "$END_ALL - $START_SEC" | bc)

START_SEC=$(date +%s)
bash ./predict_CVPPP.sh .. A3_prediction h A3_training A3
END_ALL=$(date +%s)
DIFF_PPP=$(echo "$END_ALL - $START_SEC" | bc)

echo "$DIFF_T || $DIFF_P"
echo "$DIFF_TT || $DIFF_PP"
echo "Time training: $DIFF_TTT || time prdiction: $DIFF_PPP"
echo "A1_t: ""$DIFF_T"" A2_t: ""$DIFF_TT"" A3_t: ""$DIFF_TTT"
echo "A1_p: ""$DIFF_P"" A2_p: ""$DIFF_PP"" A3_p: ""$DIFF_PPP"
