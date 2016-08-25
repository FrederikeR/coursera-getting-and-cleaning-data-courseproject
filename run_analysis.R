library(reshape2)
library(data.table)

filename <- "data_course_project.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


# =========================================================================
# 1. Merges the training and the test sets to create one data set.
# =========================================================================

# Load train datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt", stringsAsFactors = F)
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt", stringsAsFactors = F)
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactors = F)
train_data <- cbind(train_subjects, train_activities, train)

# Load test datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt", stringsAsFactors = F)
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt", stringsAsFactors = F)
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactors = F)
test_data <- cbind(test_subjects, test_activities, test)

# merge datasets
all_data <- rbind(train_data, test_data)


# =========================================================================
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# =========================================================================

# Load activity labels + features
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = F)
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors = F)

# Extract only the data on mean and standard deviation
features.wanted <- grep(".*mean.*|.*std.*", features[,2])
features.wanted.names <- features[features.wanted,2]
features.wanted.names <- gsub('-mean', 'Mean', features.wanted.names)
features.wanted.names <- gsub('-std', 'Std', features.wanted.names)
features.wanted.names <- gsub('[-()]', '', features.wanted.names)


# =========================================================================
# 4. Appropriately labels the data set with descriptive variable names. 
# =========================================================================

# add labels to the dataset
colnames(all_data) <- c("subject", "activity", features.wanted.names)

# =========================================================================
# 3. Uses descriptive activity names to name the activities in the data set
# =========================================================================

# turn activities & subjects into factors
all_data$activity <- factor(all_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])
all_data$subject <- as.factor(all_data$subject)


# =========================================================================
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# =========================================================================

all_data.melted <- melt(all_data, id = c("subject", "activity"))
all_data.mean <- dcast(all_data.melted, subject + activity ~ variable, mean)

write.table(x=all_data.mean, file="mean_data.txt", row.names = FALSE, quote = FALSE)



