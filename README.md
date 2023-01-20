# Linux-Shell-Script-Project-Encoding-

# Data Verification and Encoding Script

This script is designed to read in a dataset file, verify that the data is in the correct format, and perform one-hot or label encoding on a specified categorical feature.
###Please look at the report I have added, it explains everything!

## Usage
* Run the script by executing ./scriptname.sh in your terminal.
* The script will prompt you to input the name of the dataset file.
* If the file exists and the data is in the correct format (first and second line have the same number of values), the script will make a copy of the file and set the verification flag to 1.
* To print the features of the dataset, use the command print_features.
* To perform encoding on a specified categorical feature, use the command encoding. The script will prompt you to input the name of the feature and whether you would like to use one-hot or label encoding.
* If you choose one-hot encoding, the script will create a new set of features with the original feature appended with '_' and a number. It will also create a map file that contains the unique entries of the feature and the corresponding encoded values.
* If you choose label encoding, the script will create a map file that contains the unique entries of the feature and the corresponding encoded values.
* In both cases, the script will replace the original feature with the new encoded features in the dataset file.
## Requirements
* Bash shell
* Awk
* Sed

Please note that this script is provided as an example and should be modified to fit the specific requirements of your dataset and use case.
It is important to note that one-hot encoding is used when the categorical feature has no ordinal relationship between its values, while label encoding is used when there is ordinal relationship between the values.
