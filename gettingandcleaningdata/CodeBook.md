CodeBook for Peer Assessment Project
====================================

Version 1.0.
Dated 26/05/2014

## Feature Selection 

### merged_sets.csv

The features in this set were obtained from the original features of the train and test sets of the [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

From the original set:

  The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals ``tAcc-XYZ`` and ``tGyro-XYZ``. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (``tBodyAcc-XYZ`` and ``tGravityAcc-XYZ``) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. *

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (``tBodyAccJerk-XYZ`` and ``tBodyGyroJerk-XYZ``). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (``tBodyAccMag``, ``tGravityAccMag``, ``tBodyAccJerkMag``, ``tBodyGyroMag``, ``tBodyGyroJerkMag``). 

For each record it is provided:

* userID: An identifier of the subject who carried out the experiment.
* activity: The activity label, one of "walking", "walking_upstairs", "walking_downstairs", "sitting", "standing", "laying".
* Measurements on the mean and standard deviation for each type of accelerometer / gyroscope measurement (66), incl. ``tBodyAcc_mean_XYZ``, ``tBodyAcc_std_XYZ``, ``tGravityAcc_mean_XYZ``, ``tGravityAcc_std_XYZ``, ``tBodyAccJerk_mean_XYZ``, ``tBodyAccJerk_std_XYZ``, ``tBodyGyro_mean_XYZ``, ``tBodyGyro_std_XYZ``, ``tBodyGyroJerk_mean_XYZ``, ``tBodyGyroJerk_std_XYZ``, ``tBodyAccMag_mean``, ``tBodyAccMag_std``, ``tGravityAccMag_mean``, ``tGravityAccMag_std``, ``tBodyAccJerkMag_mean``, ``tBodyAccJerkMag_std``, ``tBodyGyroMag_mean``, ``tBodyGyroMag_std``, ``tBodyGyroJerkMag_mean``, ``tBodyGyroJerkMag_std``, ``fBodyAcc_mean_XYZ``, ``fBodyAcc_std_XYZ``, ``fBodyAccJerk_mean_XYZ``, ``fBodyAccJerk_std_XYZ``, ``fBodyGyro_mean_XYZ``, ``fBodyGyro_std_XYZ``, ``fBodyAccMag_mean``, ``fBodyAccMag_std``, ``fBodyBodyAccJerkMag_mean``, ``fBodyBodyAccJerkMag_std``, ``fBodyBodyGyroMag_mean``, ``fBodyBodyGyroMag_std``, ``fBodyBodyGyroJerkMag_mean``, ``fBodyBodyGyroJerkMag_std``

-XYZ is used to denote 3-axial signals in the X, Y and Z directions.

### Avg_by_user_by_activity.csv

This file contains and independent tidy data set with the average of each variable for each activity and each subject. For each record, it is provided:

* userID: An identifier of the subject who carried out the experiment.
* activity: The activity label, one of "walking", "walking_upstairs", "walking_downstairs", "sitting", "standing", "laying".
* Average measurements per subject per activity, on the mean and standard deviation for each type of accelerometer / gyroscope measurement (66). Feature names are constructed by appending "Avg" to the feature name in the set described above (see merged_sets.csv). For example:

*Avg_tBodyAcc_mean_X*

records the average value of ``tBodyAcc_mean_X`` for each activity for a given subject.

### Cleaning Data

#### Running run_analysis.R

The ``run_analysis.R`` script was originally created on ``R Studio Version 0.98.501`` running on an Intel Mac OS X 10.6.8, with ``R version 3.0``. The script sets Desktop to be the working directory and downloads the data from the original source to a folder "data" that is created if the script can't locate it on the Desktop. The script then proceeds to unzip the downloaded file and re-sets the working directory to be the "data" folder within Desktop, from which all data sets are loaded.

#### Pre-processing

The script starts by loading all relevant files and adding subject and activity features to the training and test sets. The subject feature is renamed "userID". The features are then renamed according to the labels contained in the ``features.txt`` file, and the total number of features is reduced to those related to mean and standard deviation of the original measurements. The names rely on underscores for clarity.

Activity labels are changed from numerical identifiers to explicit string identifiers by treating activity as an R factor and re-mapping the levels. 

#### Merging train and test sets

The script merges the train and test sets into a single dataframe using rbind, and re-orders it by userID and activity. The output is then recorded as the merged_sets.csv file, which is stored in the working directory.

#### Creating Averages data set

A second tidy data set is generated from the original one by aggregating data per user and per activity and taking the mean. The resulting set contains 180 observations (30 subjects times 6 activities = 180 observations). The features are then re-labelled by appending the "Avg" string. The output is then recorded on the ``Avg_by_user_by_activity.csv`` file that is stored in the working directory.

### Notes

The ``run_analysis.R`` script is fully commented and supplementary information can be obtained there. 



