# I wrote this script to automate copying of the subfolders with name in date format: YYYYMMDD and the fildes it contains.
# The script checks the $PATH_FROM path and finds the directories like SDN*. In each directory, there are subdirectories with date format YYYYMMDD.
# The script compares today's date (variable $FILE_DATE) with the subdirectories' names (variable $folder2).
# If there is a match, the script copies the matching subdirectories including the files they contain
# to the destination path (variable $FULL_DEST). The folders' structure is maintained.
# Additionally, the script checks last month's date and if there are matching folders, it deletes them in order to free the data.
# The output is logged to the file cp_log.txt.

├── SDN
│   ├── 20250914
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   ├── 20250915
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   ├── 20250916
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   └── 20250917
│       ├── Plik1.txt
│       ├── Plik2.txt
│       └── Plik3.txt
├── SDN2
│   ├── 20250914
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   ├── 20250915
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   ├── 20250916
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   └── 20250917
│       ├── Plik1.txt
│       ├── Plik2.txt
│       └── Plik3.txt
├── SDN3
│   ├── 20250914
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   ├── 20250915
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   ├── 20250916
│   │   ├── Plik1.txt
│   │   ├── Plik2.txt
│   │   └── Plik3.txt
│   └── 20250917
│       ├── Plik1.txt
│       ├── Plik2.txt
│       └── Plik3.txt
#!/bin/bash

PATH_FROM="/mnt/private"
PATH_TO="/home/XXXXX/smb_files"
LOG_FILE="$PATH_TO/cp_log.txt"

#CLEAR LOG FLE
>$LOG_FILE

LOG_DATE=$(date +%Y.%m.%d::%H:%M)
FILE_DATE=$(date +%Y%m%d)

#find folder names and assign to a variable FIND_FOLDERS
FIND_FOLDERS=$(find "$PATH_FROM" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

if test -d $PATH_FROM; then
        echo "$LOG_DATE: $PATH_FROM exisits.">>$LOG_FILE
        #connect path  to get /mnt/private/SDN etc ($CON_PATH var)
        for folder in ${FIND_FOLDERS[@]}; do
                CON_PATH="$PATH_FROM/$folder" #example: /mnt/private/SDN3
                FIND_FOLDERS2=$(find "$PATH_FROM/$folder" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
                for folder2 in ${FIND_FOLDERS2[@]}; do
                        FULL_PATH="$PATH_FROM/$folder/$folder2"
                        if [[ $folder2 == $FILE_DATE ]]; then #checks if 20250919 equals 20250919
                                FULL_DEST="$PATH_TO/$folder"
                                echo "Full path is $FULL_DEST.">>$LOG_FILE
                                echo "directory $folder2 inside $folder  equals today's date: $FILE_DATE. Trying to copy the files.">>$LOG_FILE
                                mkdir -p "$FULL_DEST" #create directory if it doesn't exisits.
                                cp -r "$FULL_PATH" "$FULL_DEST"
                                echo -e "Listing directories...\n $(tree $PATH_TO)">>$LOG_FILE #List directories tree.
                        fi
                done

                        #GET DATE minus last month
                        LAST_MONTH=$(date -d "last month" +%Y%m%d)
                        #Delte directories older than 30 days.
                        for del in ${FIND_FOLDERS2[@]}; doi
                                #if the folder's name equals last month's date, delete this folder from the destination.
                                if [[ $del  == $LAST_MONTH ]]; then
                                        echo "$del equals $LAST_MONTH">>$LOG_FILE
                                        echo "Folder to be deleted: $FULL_DEST/$del">>$LOG_FILE
                                        rm -rf "$FULL_DEST/$del"
                                fi
                done
        done
echo -e "Listing directories...\n $(tree $PATH_TO)">>$LOG_FILE

else
        echo "$LOG_DATE: $PATH_FROM doesn't exisits">>$LOG_FILE
fi

echo "The script ended. Please check $LOG_FILE for information."
