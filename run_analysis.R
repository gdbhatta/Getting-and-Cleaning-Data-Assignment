# Description of run_analysis.R File

# Dataset for the project can be downloaded from:  
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# STEPS

# 1. Merge the training and the test sets to create one data set
# 2. Extract only the measurements on the mean and standard deviation for each measurement 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names 
# 5. Create a second, independent tidy data set with the average of each variable for 
#    each activity and each subject 
#####

#check working directory and set it to the location where dataset was downloaded and unzipped
getwd()
setwd("G:/Data Science Course Materials/Data Cleaning Course/Week4")
filename <- "dataset.zip"

## Download and unzip the dataset
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
}  

# Unzip the file
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresM_SD <- grep(".*mean.*|.*std.*", features[,2])
featuresM_SD.names <- features[featuresM_SD,2]
featuresM_SD.names = gsub('-mean', 'Mean', featuresM_SD.names)
featuresM_SD.names = gsub('-std', 'Std', featuresM_SD.names)
featuresM_SD.names <- gsub('[-()]', '', featuresM_SD.names)

# Load the training dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresM_SD]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load the test dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresM_SD]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge datasets and add labels
merged_Data <- rbind(train, test)
colnames(merged_Data) <- c("subject", "activity", featuresM_SD.names)
colnames(merged_Data)

# Turn activities and subjects into factors
merged_Data$activity <- factor(merged_Data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
merged_Data$subject <- as.factor(merged_Data$subject)

# Load reshape2 package for melt and dcast functions
library(reshape2)

merged_Data.melted <- melt(merged_Data, id = c("subject", "activity"))
merged_Data.mean <- dcast(merged_Data.melted, subject + activity ~ variable, mean)

write.table(merged_Data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)


