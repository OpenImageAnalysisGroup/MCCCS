#!/bin/bash
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°                          Welcome to the                           °"
echo "°       'Multi Channel Classification and Clustering System'        °"
echo "°                                                                   °"
echo "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
echo "°                                                                   °"
echo "°          V1.0 developed in 2015, 2016                             °"
echo "°          by the following members of the                          °"
echo "°                                                                   °"
echo "°          - OPEN IMAGE ANALYSIS GROUP -                            °"
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
set -e
chmod +x *.sh
bash ./train_FGBG_CVPPP.sh .. A1_training m A1
bash ./predict_CVPPP.sh .. A1_prediction A1_training/fgbg.model m A1

bash ./train_FGBG_CVPPP.sh .. A2_training m A2
bash ./predict_CVPPP.sh .. A2_prediction A2_training/fgbg.model m A2

bash ./train_FGBG_CVPPP.sh .. A3_training m A3
bash ./predict_CVPPP.sh .. A3_prediction A3_training/fgbg.model m A3


