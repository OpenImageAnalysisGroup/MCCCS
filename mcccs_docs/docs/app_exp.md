# MCCCS application examples

The MCCCS includes several analysis scripts for image processing and file conversion. These scripts are arranged in custom pipelines to process different analysis tasks. Therefore we use the gnu bash shell which is a powerful tool, further more a command language. To understand the whole concept we provide several examples which are based on freely available datasets.

## Data

* Three image sets (A1, A2, A3) from the Leaf Segmentation Challenge (LSC) 2014
* A hyperspec example from Purdue Research Foundation.
* Disease classification for detached barley leaves (in preparation, not published yet).

### Segmentation example 1 - classification
***
This example shows an application for foreground/background segmentation for top view plant images (Arabidopsis thaliana - A1, A2and tobacco - A3) using a supervised Random Forest classifier. Thethree data sets are split into a training set and a data set forprediction as well. After processing, the segmentation results, namedforeground.png, are stored in each sub folder, e.g. plant_003.

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

## Customization and usage hints

To learn more about the pipeline details, please have a look in the tutorials section.
