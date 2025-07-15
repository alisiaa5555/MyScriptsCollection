#!/bin/bash
<<comment
 This script asks user to provide path. If incorrect input is provided, the user will be asked to provide a valid path. 
 Then, script clears compressedLogs.txt file and checks the size of the files in the provided directory. If the file has a size bigger than 1000000000 bytes, the file will be compressed with gz command.
 The output is retured in the compressedLogs.txt file. The size of the file is colored with red.
comment
RED='\033[0;31m' #red color
NC='\033[0m' # No color

while true; do
        echo "Please provide path path: "
        read PATH1

        if  test -d "$PATH1" ; then
        echo ""$PATH1" exists."
        break
    else
        echo "Provided path '$PATH1' doesn't exist. Please provide a correct path."
    fi
done

echo "Checking if there is any file that needs to be compressed..."
>compressedLogs.txt

while IFS="" read -r file1; do
        SIZE=$(stat -c %s "$file1")
        date=$(date +%Y.%m.%d::%H:%M:%S:%N)
        if [[ $SIZE -gt 1000000000 ]]; then
                echo -e "$date:"$file1" has size of ${RED}${SIZE}${NC} and is bigger than 1000000000 bytes." >>compressedLogs.txt
                gzip "$file1"
                echo "$date:File has been compressed.">>compressedLogs.txt
        else
                echo -e "$date:"$file1" has size of ${RED}${SIZE}${NC}.">>compressedLogs.txt
        fi
done < <(find "$PATH1" -type f)

echo "Script ended. Please check compressedLogs.txt file."
