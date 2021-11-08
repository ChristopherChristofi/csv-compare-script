# csv-compare-script

## Description:

Batch script, using the cmd windows32 system, that can be simply used to generate a merged data file from the comparsion of an old and new CSV data file that contains updated data records from the old file, where the new file contains new data records, as well as, the loss of data records that were on the old file, however, no longer given in the new file. The primary purpose of this script is to carry over additional text that may be noted on the old file, such as: a column for sales notes, to the matching record on the new file, which would not contain any of the prior notes. Therefore, by using this script a newly generated file can be created that contains all the fixes made to the old file paired with the most up-to-date data of the new file.

## Usage:

- Windows Operating System

The script should be placed in the same directory as both the old csv file - which does not need to follow any naming convention - and the new csv file - which at the current status of the script must be named "new.csv". The directory should only contain these two csv files, as any other csv files within the same directory will also be read in as the old file. The compare.cmd file is executable as is, and does not require any user input. The series of tokenisation patterns can be changed to fit different shaped datasets, the current shape of the test datasets, which this script is designed for, can be found in another of my git repo's (csv_gen.py): https://github.com/christopher-christofi/random-file-dataset-generator. columns: blank (index), unique id, date, time, text, integer, blank (text); the shape of the generated dataset, is as follows: unique id, time, text, integer, blank (text). The name of the generated dataset will be "complete.csv". The intended carry over text found only in the old file is of the last column, blank and without header.