library(plyr)
library(dplyr)
library(data.table)
### read in the two raw data sets 
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", quote="\"")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt", quote="\"")
### Get the activity data
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", quote="\"")
# y_train = activity labels (1-6)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", quote="\"")
# y_test = activity labels (1-6)
### Get the subject IDs
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", quote="\"")
# subject_train = test subjects (1-30)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", quote="\"")
# subject test are the people (1-30)
### convert to factor
subjectTest <- factor(unlist(subject_test), levels = 1:30)
subjectTrain <- factor(unlist(subject_train), levels = 1:30)
### Revalue the y_train and y_test data:
activityTrain <- factor(unlist(y_train[1]))
activityTrain <- revalue(activityTrain,c("1" = "WALKING","2" = "WALKING_UPSTAIRS", "3"="WALLKING_DOWNSTAIRS", "4"= "SITTING", "5" = "STANDING", "6" = "LAYING"))
activityTest <- factor(unlist(y_test[1]))
activityTest <- revalue(activityTest,c("1" = "WALKING","2" = "WALKING_UPSTAIRS", "3"="WALLKING_DOWNSTAIRS", "4"= "SITTING", "5" = "STANDING", "6" = "LAYING"))
### combine subjectTrain + activityTrain and subjectTest + activityTest
trainID <- data.frame("subject" = subjectTrain,"activity" = activityTrain,row.names = NULL)
testID <- data.frame("subject" = subjectTest,"activity" = activityTest, row.names = NULL)
### cbind trainID + X_train and testID + X_test
trainData <- cbind(trainID, X_train)
testData <- cbind(testID, X_test)
### Merge the two into one master dataset
allData <- merge(trainData,testData,row.names=NULL,all = TRUE )
### Get the features
features <- read.table("./UCI HAR Dataset/features.txt", quote="\"")
# features are the 561 column names
### transform the features data into row form
nms <- t(features[2])
### Add Names to allData set
names(allData)[3:563] <- nms
### use grep to create a selector for subject, activity and all mean and std columns: 
allDataNames <- names(allData)
colSelect <- grep("subject|activity|mean|std",allDataNames,ignore.case = TRUE)
### Trim the dataset
allDataMeanStd <- allData[,colSelect]
### sort by subject
allDataMeanStd <- arrange(allDataMeanStd,subject)
### convert to data.table and summarize
allDT <- data.table(allDataMeanStd)
summaryData <- allDT[, lapply(.SD, mean), by=c("subject","activity"), .SDcols=3:86]
### Write the output file
write.table(summaryData,file = "summaryData.txt",sep = " ", row.names = FALSE)
