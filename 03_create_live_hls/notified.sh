#!/usr/bin/env bash

echo "Waiting..."
while read path action file; do
    echo "The file '$file' appeared in directory '$path' via '$action'"
    # do something with the file

    # when a new file is opened - take the last file and submit... 

done
echo "Exiting"