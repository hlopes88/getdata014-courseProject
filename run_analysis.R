#submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the 
#analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed 
#to clean up the data called CodeBook.md

#You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and 
#how they are connected.  

#You should create one R script called run_analysis.R that does the following. 
#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names. 
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each 
#activity and each subject.


message("reshape2 library for the melt() function...")
#
library("reshape2")

dataPath <- "./data"
if (!file.exists(dataPath)) { dir.create(dataPath) }

message("Checking if the data set archive was already downloaded...")
#
fileName <- "Dataset.zip"
filePath <- file.path(dataPath,fileName)
if (!file.exists(filePath)) { 
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    message("Downloading the data set archive...")
    download.file(url=fileURL,destfile=filePath)
}

unzip(zipfile=filePath, exdir=".")

# Set the data path of the extracted archive files...
dataSetPath=getwd()
dataSetPath <- file.path(dataSetPath,"UCI HAR Dataset")


message("Reading training & test column files into respective x,y,s variables...")
#
xTrain <- read.table(file=file.path(dataSetPath,"train","x_train.txt"),header=FALSE)
yTrain <- read.table(file=file.path(dataSetPath,"train","y_train.txt"),header=FALSE,col.names="Class_Label")
sTrain <- read.table(file=file.path(dataSetPath,"train","subject_train.txt"),header=FALSE,col.names="SubjectID")


xTest  <- read.table(file=file.path(dataSetPath,"test", "X_test.txt"),header=FALSE)
yTest  <- read.table(file=file.path(dataSetPath,"test", "y_test.txt"),header=FALSE,col.names="Class_Label")
sTest  <- read.table(file=file.path(dataSetPath,"test", "subject_test.txt"),header=FALSE,col.names="SubjectID")

message("Reading feaure names and sets column/variable names respectively")
#
features <- read.table(file.path(dataSetPath,"features.txt"),header=FALSE)
names(xTrain) <- features[,2]
names(xTest)  <- features[,2]

message("Merging (appending) the training and test data set rows...")
xData <- rbind(xTrain, xTest)
yData <- rbind(yTrain, yTest)
sData <- rbind(sTrain, sTest)

message("Creating a unified data set (data frame)...")
#
data <- cbind(xData, yData, sData)


message("Extracting measurements on mean & standard deviation, for each measurement...")
#
matchingCols <- grep("mean|std|Class|Subject", names(data))
data <- data[,matchingCols]

message("Using descriptive activity names to name the activities in data set...")
message("activity names on the class labels")

activityNames <- read.table(file=file.path(dataSetPath,"activity_labels.txt"),header=FALSE)
names(activityNames) <- c("Class_Label", "Class_Name")
data <- merge(x=data, y=activityNames, by.x="Class_Label", by.y="Class_Label" )

message("Labeling data with descriptive variable names...")
#
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "freq", names(data))
names(data) <- gsub("\\(\\)", "", names(data))
names(data) <- gsub("\\-", ".", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))

message("Removing columns used only for tidying up the data set...")
#
data <- data[,!(names(data) %in% c("Class_Label"))]

message("Melting the data set, note this is why we require reshape2 library...")
#
meltdataset <- melt(data=data, id=c("SubjectID", "Class_Name"))

message("Creating a second, independent, tidy data set")
message("Which contains the average of each variable for each activity and subject...")
#
tidyData <- dcast(data=meltdataset, SubjectID + Class_Name ~ variable, mean)

message("Saving the tidy data set to file...")
#
tidyFilePath <- file.path(dataPath,"TidyDataSet.txt")
write.table(tidyData,file=tidyFilePath,row.names=FALSE)

message("Processing complete, resulting tidy data set can be found at:")
message(tidyFilePath)

