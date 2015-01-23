##Check if data has been downloaded and unzip
if(!file.exists("DataSet")){

##Download and unzip file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file (fileUrl, destfile="./DataSet.zip")
dataDownloaded=date()
dataDownloaded
unzip("./DataSet.zip", exdir="DataSet")
}

##Check if the "plyr" package is installed. If not, install and load plyr
if(!require("plyr")){
    install.packages("plyr")
}

library(plyr)

#Step 1. Merge the training and the test sets to create one data set
##Read train and test files
trainX <- read.table("./DataSet/UCI HAR DataSet/train/X_train.txt")
trainY <- read.table("./DataSet/UCI HAR DataSet/train/Y_train.txt")
trainSubject <- read.table("./DataSet/UCI HAR DataSet/train/subject_train.txt")

testX <- read.table("./DataSet/UCI HAR DataSet/test/X_test.txt")
testY <- read.table("./DataSet/UCI HAR DataSet/test/Y_test.txt")
testSubject <- read.table("./DataSet/UCI HAR DataSet/test/subject_test.txt")


##Merge train and test dataset together
X_df <- rbind(trainX, testX)
Y_df <- rbind(trainY, testY)
subject_df <- rbind(trainSubject, testSubject)

##Rename Y_df as "activities" and subject_df as "subject"
names(Y_df) <- "activities"
names(subject_df) <- "subjects"

##Step2. Extract only the measurements on the mean and standard deviation for each measurement
##Read column name
features <- read.table("./DataSet/UCI HAR DataSet/features.txt")
features_MeanAndStdv <- grep ("-(mean|std)\\(\\)", features[,2])
df_MeanAndStdv <- X_df[,features_MeanAndStdv]

#Step3. Use descriptive activity names to name the activities in the data set
##Read activities file
Activities <- read.table("./DataSet/UCI HAR DataSet/activity_labels.txt")

##Replace variables in Y_df with descriptive activity names
Y_df[,1] <- Activities[Y_df[,1], 2]

##Step4. Appropraitely label the data set with descriptive variable names
names(df_MeanAndStdv) <- features[features_MeanAndStdv, 2]

##Combine subjects, label and data together
df <- cbind(subject_df, Y_df, df_MeanAndStdv)

##Step5. From the dataset in step 4, create a second, independent tidy data set
##with the average of each variable for each activity and each subject.
average_df <- ddply(df, .(subjects, activities), function(x) colMeans(x[, 3:68]))

##Write table
write.table(average_df, "average_df.txt", row.names=FALSE)