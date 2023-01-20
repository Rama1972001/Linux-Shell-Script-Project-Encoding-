#!/bin/bash

function read_file {
    verified=0 #set verification flag to 0 since we are dealing with a new file now
    if [ -e $datacopy ]; then
        rm $datacopy # delete the copy file
    fi
    read -p "Please input the name of the dataset file: " dataset #read the name of the dataset file
    if [ ! -e "$dataset" ]; then                                  #if the file doesnt exist
        echo "The file doesn't exist"
        # check if the first and second line have the same number of values
    elif [ "$(head -1 $dataset | sed "s/;/ /g" | wc -w)" != "$(head -2 $dataset | tail -1 | sed "s/;/ /g" | wc -w)" ]; then
        echo "The format of the data in the dataset file is wrong"
    else #if everything is good, we set verified to 1 and copy it to datacopy file
        cat $dataset >$datacopy
        verified=1
        saved=0 #set saved to 0 since its a new file now
    fi
}

function print_features {
    if [ "$verified" != 1 ]; then #check if file is verified
        echo "You must first read a dataset from a file"
    else # if its verified we print the features
        features=$(head -1 $datacopy)
        echo "The features are: $features"
    fi
}

function encoding {
    if [ "$verified" != 1 ]; then
        echo "You must first read a dataset from a file"
    else
        read -p "Please input the name of the categorical feature for encoding: " feature
        # check if the feature name entered is in the first line
        if [ "$(head -1 $datacopy | grep "$feature;")" != "$(head -1 $datacopy)" ]; then
            echo "The name of categorical feature is wrong"
        else
            index=$(head -1 $datacopy | tr ";" "\n" | grep -nx $feature | cut -d":" -f1) #index of feature
            index_prev=$((index - 1))                                                    #index of the previous feature
            index_next=$((index + 1))                                                    #index of the next feature

            cut -d ';' -f$index $datacopy >column #the column with the feature we're working on
            #the command to find the remaining features is different for the first feature and the other features
            if [ "$index" == 1 ]; then
                cut -d ';' -f2- $datacopy >remaining
            else
                cut -d ';' -f1-$index_prev,$index_next- $datacopy >remaining
            fi
            #remove the last semicolon from the end of each line
            while read -r line; do
                line2=$(echo "$line" | sed 's/.$//')
                echo "$line2" >>remaining2
            done <remaining
            cat remaining2 >remaining
            rm remaining2

            tail -n +2 column | sort -u >unique       #remove the first line (feature name) from column and remove duplicates
            awk '{print $0 " " NR-1}' unique >mapfile #create a mapfile containing "entry line_number"
            mapfile=mapfile
            rm unique
            # one-hot encoding
            if [ "$option" = "o" ]; then
                # now we will take the first column from the mapfile with the unique entries and insert feature_ to its beginning
                #we also move it to a file called col
                sed -e "s/^\([^ ]*\)/$feature\_\1/" mapfile | cut -d ' ' -f1 >>column_hot
                feature=$(cat column_hot | tr '\n' ';') #we copy the column of these entries and create a line of them seperated by semicolons since theyre our new features
                length=$(($(wc -l <mapfile) - 1))       #calculate the number of lines in the mapfile

                # for each line in map file, we replace the number of the line with ones are zeros accordingly
                while read -r line; do
                    key=$(echo "$line" | awk '{print $1}')    #value from the first column of the mapfile (name of the entry)
                    number=$(echo "$line" | awk '{print $2}') #number of the line (entry code using label encoding)

                    replacement="$key "
                    # add 0; unless we've reached the number of the line we're on we add 1;
                    for i in $(eval echo {0..$length}); do
                        if [ "$i" -eq "$number" ]; then
                            replacement+="1;"
                        else
                            replacement+="0;"
                        fi
                    done
                    echo "$replacement" >>mapfile_hot #move the new values to a new mapfile
                done <mapfile
                mapfile=mapfile_hot
            fi

            echo "The distinct values of the categorical features and their codes are: "
            cat $mapfile
            #for each entry in column we replace it with the corresponding code from the mapfile
            while read -r line; do
                code=$(sed -n "/^$line /p" $mapfile | cut -d" " -f2)
                if [ -z "$code" ]; then
                    echo "$feature;" >>column_new
                else
                    echo "$code;" >>column_new
                fi
            done <column
            paste -d";" remaining column_new >$datacopy #paste the rest of the columns with the new column into datacopy

            if [ "$option" = "o" ]; then
                #remove a semicolon (I dont know where it came from)
                while read -r line; do
                    line2=$(echo "$line" | sed 's/.$//')
                    echo "$line2" >>temp
                done <$datacopy
                cat temp >datacopy
                rm temp

                rm mapfile_hot
                rm column_hot
            fi
            #remove the temporary files created to run this code
            rm remaining
            rm mapfile
            rm column_new
            rm column
        fi
    fi
}

function scaling {
    #cheack if file is readed ?
    if [ "$verified" != 1 ]; then
        echo "You must first read a dataset from a file"
    else
        read -p "Please input the name of the feature to be scaled: " feature
        if [ "$(head -1 $datacopy | grep "$feature;")" != "$(head -1 $datacopy)" ]; then
            echo "The name of categorical feature is wrong"
        else
        #the index get the colom of feature of colom we iner
            index=$(head -1 $datacopy | tr ";" "\n" | grep -nx $feature | cut -d":" -f1)
            # num_check is the first entry of the feature, its used to check if its categorical or not
            num_check=$(sed -n '2p' $datacopy | cut -d ';' -f $index)
            if expr "$num_check" + 1 >/dev/null 2>&1; then #if its a number, we scale
                index=$(head -1 $datacopy | tr ";" "\n" | grep -nx $feature | cut -d":" -f1)
                index_prev=$((index - 1))
                index_next=$((index + 1))
                cut -d ';' -f$index $datacopy >column
                if [ "$index" == 1 ]; then
                    cut -d ';' -f2- $datacopy >remaining
                else
                    cut -d ';' -f1-$index_prev,$index_next- $datacopy >remaining
                fi

                while read -r line; do
                    line2=$(echo "$line" | sed 's/.$//')
                    echo "$line2" >>remaining2
                done <remaining
                cat remaining2 >remaining
                rm remaining2
                min=$(tail +2 column | sort -n | head -1)    #the minimum value from the column
                max=$(tail +2 column | sort -n -r | head -1) #the maxiumum value from the column
                echo "Max: $max"
                echo "Min: $min"
                while read -r line; do
                    if [ "$line" == $feature ]; then
                        echo "$feature;" >>column_new
                    else
                        code=$(awk "BEGIN {print ($line - $min) / ($max - $min)}") #the equation to find the scaled value
                        echo "$code;" >>column_new                                 #put new scaled value into a new column
                    fi
                done <column
                paste -d";" remaining column_new >$datacopy #paste the new data into datacopy

                rm remaining
                rm column_new
                rm column
            else #if its not a number, we print an error mesasge
                echo "this feature is categorical feature and must be encoded first"
            fi
        fi
    fi
}

datacopy="datacopy" # the name of the file where we store a copy of the dataset
verified=0          # flag to indicate if a file has been verified already or not
saved=0             # flag to indicate if a file has been saved already or not

#program main menu is a loop
while true; do
    echo " [r] Read a dataset from a file "
    echo " [p] Print the names of the features"
    echo " [l] encode a feature using label encoding"
    echo " [o] encode a feature using one-hot encoding"
    echo " [m] Apply MinMax scalling "
    echo " [s] save the processed dataset"
    echo " [e] Exit"

    # read the user's input
    read -p "Please enter an option: " option

    # Reading the dataset file
    if [ "$option" = "r" ]; then
        read_file
        # Print features
    elif [ "$option" = "p" ]; then
        print_features
    # encoding
    elif [ "$option" == "l" ] || [ "$option" == "o" ]; then
        encoding
        # Scaling a feature
    elif [ "$option" = "m" ]; then
        scaling
        # Saving modified dataset to file
    elif [ "$option" = "s" ]; then
        if [ "$verified" != 1 ]; then
            echo "You must first read a dataset from a file"
        else
            read -p "Please input the name of the file to save the processed dataset: " savefile
            cat $datacopy >$savefile
            saved=1
        fi
        # exit
    elif [ "$option" = "e" ]; then
        if [ "$saved" = 1 ]; then
            read -p "Are you sure you want to exit? [y/n] " yesno
            if [ "$yesno" = "y" ]; then
                if [ -e $datacopy ]; then
                    rm $datacopy # delete the copy file
                fi
                exit 1
            fi
        else
            read -p "The processed dataset is not saved. Are you sure you want to exit? [y/n] " yesno
            if [ "$yesno" = "y" ]; then
                if [ -e $datacopy ]; then
                    rm $datacopy # delete the copy file
                fi
                exit 1
            fi
        fi
    else
        echo "Please select one of the options (r, p, l, o, m, s, e)"
    fi
done
