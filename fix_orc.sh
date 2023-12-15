#!/bin/bash

# Ensuring precise globbing is enabled; needed if you're using bash and filenames may contain spaces or newlines.
shopt -s nullglob

# Using absolute or relative path to the directories can be safer
splits_dir="./splits"
outs_dir="./outs"

# Check if the 'splits' directory exists
if [ ! -d "$splits_dir" ]; then
    echo "Directory '$splits_dir' does not exist. Exiting."
    exit 1
fi

# Create the 'outs' directory if it doesn't exist
mkdir -p "$outs_dir"

# Gets a list of files in the 'splits' directory using a safer way by avoiding backticks and parsing ls
files=$(find "$splits_dir" -type f -name "*.txt")

# Iterating over the list of files
for file_path in $files
do
    # Extract just the filename from the path
    file=$(basename "$file_path")

    echo "Processing $file"

    # Check if the file is in the 'outs' directory
    if [ ! -f "$outs_dir/$file" ]; then
        # Run the llm command with the contents of the file
        # < and > are used for input and output redirection which is safer and more performant than using pipes (|)
        llm -s 'here is a badly ocred text. i have cleaned it up somewhat manually. please fix any remaining errors in formatting and spelling and insert missing double dashes and newlines where they have been squased. remember emily dickinson used lots of dashes at the end of lines. seperate the poems into stanzas where appropriate. she usually used 4-line stanzas, though this varies. make more stanzas this time, last time there were too few. try not to add any punctuation if there isnt residue of it in the text, apart from the missing dashes. only return the improved text.' < "$file_path" > "$outs_dir/$file"
    else
        echo "$file already exists in $outs_dir"
    fi

    echo "Done processing $file"
done
