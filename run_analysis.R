# -------------------------------------------------------------------------------
# Getting and Cleaning Data - Peer-review project
# -------------------------------------------------------------------------------
# Instructions
# -------------------------------------------------------------------------------
#The data linked to from the course website represent data collected from 
#the accelerometers from the Samsung Galaxy S smartphone. A full description 
#is available at the site where the data was obtained: 
  
#http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

#Here are the data for the project: 
#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

#You should create one R script called run_analysis.R that does the following. 
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each 
#    activity and each subject. 
# -------------------------------------------------------------------------------
# Set working directory & Load Libraries
# -------------------------------------------------------------------------------
# Assume we are downloading everything to Desktop.
setwd("~/Desktop")
# -------------------------------------------------------------------------------
# Download source files and set up working directory
# -------------------------------------------------------------------------------
if(!file.exists("./data")){dir.create("./data")}
fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileURL,destfile="./data/sets.zip",method="curl")
unzip("./data/sets.zip", exdir="./data")
setwd("~/Desktop/data")
# -------------------------------------------------------------------------------
# Load files to R
# -------------------------------------------------------------------------------
features<-read.table("UCI HAR Dataset/features.txt",stringsAsFactors = FALSE)

# Training Sets
train<-read.table("UCI HAR Dataset/train/X_train.txt",stringsAsFactors = FALSE,sep = "")
train_activity<-read.table("UCI HAR Dataset/train/y_train.txt",stringsAsFactors = FALSE,sep = "")
names(train_activity)[1]<-"activity"
train_subject<-read.table("UCI HAR Dataset/train/subject_train.txt",stringsAsFactors = FALSE,sep = "")
names(train_subject)[1]<-"userID"

# Test Sets
test<-read.table("UCI HAR Dataset/test/X_test.txt",stringsAsFactors = FALSE,sep = "")
test_activity<-read.table("UCI HAR Dataset/test/y_test.txt",stringsAsFactors = FALSE,sep = "")
names(test_activity)[1]<-"activity"
test_subject<-read.table("UCI HAR Dataset/test/subject_test.txt",stringsAsFactors = FALSE,sep = "")
names(test_subject)[1]<-"userID"

# -------------------------------------------------------------------------------
# Rename heads w/ corresponding feature names and extract mean and std
# -------------------------------------------------------------------------------
names(train)<-features[,2]
names(test)<-features[,2]
req<-grep("std\\(\\)|mean\\(\\)",features[,2])
train<-train[,req] # This gives me the required features
test<-test[,req] # This gives me the required features
names(train)<-gsub("\\(\\)","",names(train))
names(train)<-gsub("-","_",names(train))
names(test)<-gsub("\\(\\)","",names(test))
names(test)<-gsub("-","_",names(test))
# -------------------------------------------------------------------------------
# Add Subject Column
# -------------------------------------------------------------------------------
train$userID<-train_subject$userID
test$userID<-test_subject$userID
train<-train[,c(67,1:66)]
test<-test[,c(67,1:66)]
# -------------------------------------------------------------------------------
# Add Activity Column
# -------------------------------------------------------------------------------
train$activity<-train_activity$activity
test$activity<-test_activity$activity
train<-train[,c(1,68,2:67)]
test<-test[,c(1,68,2:67)]
# -------------------------------------------------------------------------------
# Combine Test and Train Sets
# -------------------------------------------------------------------------------
data <- rbind(train, test)
data <- data[order(data$userID, data$activity),]
# -------------------------------------------------------------------------------
# Replace Activity Names
# -------------------------------------------------------------------------------
# Activity Names can be founda on the activity_labels.txt file
data$activity<-as.factor(data$activity)
levels(data$activity)<-list("walking"="1","walking_upstairs"="2","walking_downstairs"="3","sitting"="4","standing"="5","laying"="6")
# -------------------------------------------------------------------------------
# Set sequential row numbers & write file
# -------------------------------------------------------------------------------
row.names(data) <- NULL 
write.csv(data,file="merged_sets.csv",row.names=FALSE)
# -------------------------------------------------------------------------------
# Compute average of each variable for each activity and each subject and write file
# -------------------------------------------------------------------------------
data_sum<-aggregate(. ~ userID+activity,data = data,mean )
data_sum<-data_sum[order(data_sum$userID,decreasing=FALSE),]
row.names(data_sum) <- NULL
names(data_sum)[3:68]<-paste("Avg", names(data_sum)[3:68], sep="_")
write.csv(data_sum,file="Avg_by_user_by_activity.csv",row.names=FALSE)
