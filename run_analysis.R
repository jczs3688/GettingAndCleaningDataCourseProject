# Required packages and their functions used
# tools:    checksum
# dplyr:    tbl_df, left_join, bind_cols, bind_rows, select, matches, %>%, group_by, summarize_all, arrange
# tidyr:    gather, separate
# magrittr: %<>%

# Load the required packages
for(p in c("tools", "dplyr", "tidyr", "magrittr")) {
	if(!require(p, character.only = TRUE)) {
		# Install them if they are not installed
		install.packages(p)
		if(!require(p, character.only = TRUE)) {
			# Stop if still unable to load package
			stop(paste("Package", p, "not found"))
		}
	}
}

# Verify the correct file is downloaded
file_url  <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file_name <- "getdata_projectfiles_UCI HAR Dataset.zip"
checksum  <- md5sum(file_name)

# Download if file does not exist or has incorrect checksum
if(is.na(checksum) || checksum != "d29710c9530a31f303801b6bc34bd895") {
	download.file(file_url, file_name)
	checksum <- md5sum(file_name)
}

# Stop if unable to download correct file
if(checksum != "d29710c9530a31f303801b6bc34bd895") {
	stop("Bad checksum")
}

# Unzip files
unzip(file_name)

# Read labels
feature_labels  <- tbl_df(read.table("UCI HAR Dataset/features.txt",            col.names = c("Feature_ID",  "Feature_Name")))
activity_labels <- tbl_df(read.table("UCI HAR Dataset/activity_labels.txt",     col.names = c("Activity_ID", "Activity_Name")))

# Read train data
train_features  <- tbl_df(read.table("UCI HAR Dataset/train/X_train.txt"))
train_activity  <- tbl_df(read.table("UCI HAR Dataset/train/y_train.txt",       col.names = colnames(activity_labels)[1]))
train_subject   <- tbl_df(read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject_ID"))

# Read test data
test_features   <- tbl_df(read.table("UCI HAR Dataset/test/X_test.txt"))
test_activity   <- tbl_df(read.table("UCI HAR Dataset/test/y_test.txt",         col.names = colnames(train_activity)))
test_subject    <- tbl_df(read.table("UCI HAR Dataset/test/subject_test.txt",   col.names = colnames(train_subject)))

# Have to name these columns outside of read.table() so it doesn't mangle the names
colnames(train_features) <- feature_labels[[2]]
colnames(test_features)  <- feature_labels[[2]]

# Label the activity with its corresponding name
test_activity  <- left_join(test_activity,  activity_labels, colnames(test_activity)[1])
train_activity <- left_join(train_activity, activity_labels, colnames(train_activity)[1])

# Glue the variables together
train_data <- bind_cols(train_subject, train_activity, train_features)
test_data  <- bind_cols(test_subject,  test_activity,  test_features)

# Glue the train data and test data together
all_data   <- bind_rows("Train" = train_data, "Test" = test_data, .id = "Data Set")

# Select only the measurements with mean() and std()
extracted_data <- select(all_data, 2, 4, matches("mean\\(\\)|std\\(\\)"))

# Summarize data grouped by activity and subject
summarized_data                     <-
extracted_data                      %>%
group_by(Activity_Name, Subject_ID) %>%
summarize_all(funs(mean))

# Make the variable names more descriptive
colnames(summarized_data)                                           %<>%
gsub("^t",                           "Time",                     .) %>%
gsub("^f",                           "Frequency",                .) %>%
gsub("(Time|Frequency)(.*)Acc(.*)",  "\\1-Accelerometer-\\2\\3", .) %>%
gsub("(Time|Frequency)(.*)Gyro(.*)", "\\1-Gyroscope-\\2\\3",     .) %>%
gsub("Mag",                          "-Magnitude",               .) %>%
gsub("(.*)-mean\\(\\)(.*)" ,         "\\1\\2-Mean()",            .) %>%
gsub("(.*)-std\\(\\)(.*)",           "\\1\\2-Std()",             .)

# Write wide form data to file
write.table(summarized_data, "summarized_data_wide.txt", row.names = FALSE)

# Begin converting to long form and tidying
summarized_data                                      %<>%
# Gather
gather(Variable, Value,
       -Activity_Name, -Subject_ID)                  %>%
# Separate
separate(Variable, c("Measurement_Domain",
                     "Measurement_Device",
                     "Measurement_Variable",
                     "Measurement_Dimension",
                     "Summary_Statistic"),
         "-")                                        %>%
# Arrange
arrange(Activity_Name,
        Subject_ID,
        Measurement_Domain,
        Measurement_Device,
        Measurement_Variable,
        Measurement_Dimension,
        Summary_Statistic,
        Value)

# Write long form data to file
write.table(summarized_data, "summarized_data_long.txt", row.names = FALSE)