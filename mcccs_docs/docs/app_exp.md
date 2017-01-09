# MCCCS application examples

The MCCCS includes several analysis scripts for image processing and file conversion. These scripts are arranged in custom pipelines to process different analysis tasks. Therefore we use the gnu bash shell which is a powerful tool, further more a command language. To understand the whole concept we provide several examples which are based on freely available datasets.

## Data

* Three image sets (A1, A2, A3) from the Leaf Segmentation Challenge (LSC) 2014
* A hyperspec example from Purdue Research Foundation.
* Disease classification for detached barley leaves (in preparation, not published yet).

### Segmentation example 1 - classification
***
This example shows an application for foreground/background segmentation for top view plant images (Arabidopsis thaliana - A1, A2 and tobacco - A3) using a supervised Random Forest classifier. Thethree data sets are split into a training set and a data set forprediction as well. After processing, the segmentation results, namedforeground.png, are stored in each sub folder, e.g. plant_003.

### Hyper-spectral example 1 - classification
***
This example shows an application for a multi-labeled segmentation onan airbone hyper-spectral image data set. Here partly pre-classifiedground-truth image masks are used to train a supervised Random Forestclassifier.Afterprocessing,thesegmentationresult,namedclassified.png is stored in the experiment sub folder (stack_images→ dc).

### Hyper-spectral example 2 - clustering
***
This example shows an application for a multi-labeled segmentation onan airbone hyper-spectral image data set as used in the examplebefore. Instead of using pre-classified ground-truth data to train asupervised classifier here a clustering approach is performed. Afterprocessing, the segmentation result, named clustered.png is stored inthe experiment sub folder (stack_images → dc).

## Preparation

After downloading and installing the required software tools (see installation instructions). The mcccs.zip container can be downloaded from the github releases and extracted on a local file system.

### Download of application examples

The application examples can be downloaded and prepared by executing the prepare_datasets.sh in a terminal. The example data and needed libraries are automatically downloaded and transferred into the common folder structure for processing with the given example scripts. Please make sure that there is sufficient space left on the used device.

## Running examples

The analysis can be started by navigating into the corresponding experiment folder, by executing the process_ ... .sh script in a terminal (e.g. segmentation_example_1_classification → execute process_segmentation_example_1_classification.sh in the experiment folder). The results, including a labeled result image and the belonging numeric data, named all_ ... .csv, are stored into the corresponding sub-folders.

exp images A1 training

### Analysis statistics

The following table includes the number of images for training and prediction for each data set A1, A2 and A3. The second table gives an overview about the individual runtimes in seconds for the application examples and different use of processor units. The test was performed on a machine equipped with a Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz and 32 GB RAM (OS: Ubuntu 16.04).

* Table 1: Overview about the number of images # in the used data sets.

|Dataset|# Training|# Prediction|Image resolution (pixel)
|-----------|--------------|----------------|----------------|
|A1|7|128|500 x 530|
|A2|8|31|530 x 565|
|A3|9|27|2448 x 2048|

* Table 2: Overview about runtimes in sconds s, single = 1 cpu, half = 4 cpu, multi = 8 cpu units in use for parallel job processing (including virtual cpus). Thus of the heavily parallelization of the single commands the execution of parallel jobs shows the biggest effect during the model training.

| |Training s (m)|Prediction s (m)
|-----------|--------------|----------------|
|A1_single|498 (8.3)|1428 (23:8)|
|A1_half|361 (6.0)|1597 (26.6)|
|A1_multi|213 (3.6)|1396 (23.3)|
|A2_single|547 (9.1)|319 (5.3)|
|A2_half|332 (5.5)|353 (5.9)|
|A2_multi|216 (3.6)|318 (5.3)|
|A3_single|7370 (122.8)|3587 (59.8)|
|A3_half|4370 (72.8)|3737 (62.3)|
|A3_multi|2774 (46.2)|3591 (59.9)|

## Customization and usage hints

### Parallel job execution

By excuting more jobs in parallel the RAM comsumption will increase, for less perfomance systems it is recommended to decrese the job number, the following options are possible:

* s - single job started
* h - job number is half number of available cpu units (automatic detection)
* m - job number equals all available cpu units (automatic detection)
* 1 .. n - the used input number specifies the number of parallel started jobs

To learn more about the pipeline details, please have a look in the tutorials section.
