# Getting and Cleaning Data Course Project

`run_analysis.R` does the following:

1. Loads the required packages `tools`, `dplyr`, `tidyr`, and `magrittr`, installing them if needed.

2. In the current working directory: downloads the zip file containing the data if needed, verifies the file with MD5 checksum, then unzips the file.

3. Reads in the files `features.txt`, `activity_labels.txt`, `X_train.txt`, `y_train.txt`, `subject_train.txt`, `X_test.txt`, `y_test.txt`, and `subject_test.txt`. Descriptions of these files are found in `CodeBook.md`.

4. Gives the columns descriptive names. Names for `X_train` and `X_test` come from `features.txt`.

5. Labels each `Activity_ID` with its corresponding `Activity_Name` by performing a `left_join` of `y_train` and `y_test` with `activity_labels`.

6. Merges the columns of each `X_train` and `X_test` with their corresponding `y_train` and `y_test` (which now have columns for activity names) columns.

7. Merges the rows of the train data and test data to complete the aggregate data set.

8. Extracts `Subject_ID`, `Activity_Name`, and only those columns with `mean()` and `std()` in them.

9. Groups the rows first by `Activity_Name` and then by `Subject_ID`.

10. Summarizes by calculating the mean over each group.

11. Renames columns, expanding abbreviations to elucidate their meanings.

12. Writes this wide-form data to the text file `summarized_data_wide.txt`.

13. From here, took the optional step of converting the data to long form as an exercise in working with `tidyr`. To accomplish this, all the measured variables were gathered, separated, and arranged based on their domain, device, what was being measured, the axis (or magnitude) of measurement, and whether the summary statistic was `mean()` or `std()`. `Magnitude` may not technically be a dimension, but in the opinion of the author, splitting them up further would have introduced too many `NA` values and this seems to be a very organized way to decompose the variables and get a clearer picture of their components. The output of long-form data can be found in `summarized_data_long.txt`.

Both wide forms and long forms are shown in the repository. The wide form was used in the Coursera submission because it most clearly shows the rows as being the summaries "for each activity and each subject". However, either should satisfy the requirements.