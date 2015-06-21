---
title: "GettingAndCleaningData_Project_ReadMe"
author: "Doug Olson"
date: "June 20, 2015"
output: html_document
---
What follows is a walk-through of my run_analysis.R script, with a few extra instances of dim() and str()
added to (hopefully) help clarify things.
Libraries needed:
```{r}
library(plyr)
library(dplyr)
library(data.table)
```
### Get the two raw data sets and get info about them:
* train dimensions: [1] 7352  561
* test dimensions: [1] 2947  561
```{r}
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", quote="\"")
dim(X_train)
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt", quote="\"")
dim(X_test)
```
### Get the activity data
* train dimensions: [1] 7352    1
* test dimensions: [1] 2947    1
```{r}
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", quote="\"")
# y_train = activity labels (1-6)
dim(y_train)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", quote="\"")
# y_test = activity labels (1-6)
dim(y_test)
```
### Get the subject IDs
* train dimensions: [1] 7352    1
* test dimensions: [1] 2947    1
```{r}
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", quote="\"")
# subject_train = test subjects (1-30)
dim(subject_train)
str(subject_train)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", quote="\"")
# subject test are the people (1-30)
dim(subject_test)
str(subject_test)
```
### Convert IDs to factor
* need to specify levels, otherwise they will be ordered as they appeared in the dataset, which makes sorting difficult later
```{r}
subjectTest <- factor(unlist(subject_test), levels = 1:30)
subjectTrain <- factor(unlist(subject_train), levels = 1:30)
```
### Revalue the y_train and y_test data:
* convert numeric labels into human readable activities
```{r}
activityTrain <- factor(unlist(y_train[1]))
activityTrain <- revalue(activityTrain,c("1" = "WALKING","2" = "WALKING_UPSTAIRS", "3"="WALLKING_DOWNSTAIRS", "4"= "SITTING", "5" = "STANDING", "6" = "LAYING"))
activityTest <- factor(unlist(y_test[1]))
activityTest <- revalue(activityTest,c("1" = "WALKING","2" = "WALKING_UPSTAIRS", "3"="WALLKING_DOWNSTAIRS", "4"= "SITTING", "5" = "STANDING", "6" = "LAYING"))
```
### combine subjectTrain + activityTrain and subjectTest + activityTest
```{r}
trainID <- data.frame("subject" = subjectTrain,"activity" = activityTrain,row.names = NULL)
testID <- data.frame("subject" = subjectTest,"activity" = activityTest, row.names = NULL)
```
### cbind trainID + X_train and testID + X_test
```{r}
trainData <- cbind(trainID, X_train)
testData <- cbind(testID, X_test)
```
### Merge the two into one master dataset
```{r}
allData <- merge(trainData,testData,row.names=NULL,all = TRUE )
```
### Get the features
* features are the 561 column names

```{r}
features <- read.table("./UCI HAR Dataset/features.txt", quote="\"")
dim(features)
```
### transform the features data into row form
```{r}
nms <- t(features[2])
dim(nms)
```
### Add Names to allData set
```{r}
names(allData)[3:563] <- nms
```
### use grep to create a selector for subject, activity and all mean and std columns: 
```{r}
allDataNames <- names(allData)
colSelect <- grep("subject|activity|mean|std",allDataNames,ignore.case = TRUE)
```
### Use the selector to trim the dataset 
```{r}
allDataMeanStd <- allData[,colSelect]
```
### sort by subject
```{r}
allDataMeanStd <- arrange(allDataMeanStd,subject)
```
### convert to data.table and summarize
```{r}
allDT <- data.table(allDataMeanStd)
summaryData <- allDT[, lapply(.SD, mean), by=c("subject","activity"), .SDcols=3:86]
```
### Write the ourput file
```{r}
write.table(summaryData,file = "summaryData.txt",sep = " ", row.names = FALSE)
```

