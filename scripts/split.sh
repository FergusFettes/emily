#!/bin/bash

INPUT_FILE="$1"

# Check if input file is provided and exists
if [[ -z "$INPUT_FILE" ]] || [[ ! -f "$INPUT_FILE" ]]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Make the splits directory if it does not exist
mkdir -p splits

# Initialize variables
previous_number=0
current_number=1
is_first_section=true
current_output_file=""
tempfile_content=""

# read file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]*$ ]]; then
        # End of a section, start of a new section
        if [ "$is_first_section" = false ]; then
            echo "$tempfile_content" > "splits/$previous_number.txt"
            tempfile_content=""
        else
            is_first_section=false
        fi

        current_number="${BASH_REMATCH[1]}"

        # Check if the number is consecutive
        if (( current_number != previous_number + 1 )); then
            echo "Missing number; last number was $previous_number."
            exit 1
        fi
        
        previous_number=$current_number
    else
        # Append line to the temporary content buffer
        tempfile_content+=$line$'\n'
    fi
done < "$INPUT_FILE"

# Save the last section
if [ -n "$tempfile_content" ] && [ "$is_first_section" = false ]; then
    echo "$tempfile_content" > "splits/$current_number.txt"
fi

# Truncate the original file up to the last processed number
sed -i "1,/$current_number/d" "$INPUT_FILE"

# Indicate if the script finished successfully
if [ "$is_first_section" = true ]; then
    echo "No section numbers found in the document."
    exit 0
else
    echo "Document split successfully. Last section number was $current_number."
fi
