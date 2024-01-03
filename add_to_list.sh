#!/bin/bash

# Clear the terminal output
clear

# Check if the correct number of arguments is given
if [ "$#" -ne 2 ]; then
    echo "Usage: ./show_set.sh <tag> <number>"
    exit 1
fi

# Extract arguments into variables
number=$2
tag=$1
input_file="poems/${number}"
tag_file="lists/${tag}.txt"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi

# Display the content of the file
echo $number
echo ""
echo ""
sed 's/^/\t/' "$input_file" | cat
echo ""
echo ""

read -p "" response

case $response in
    [nN][oO]|[nN])  # If the user explicitly says 'no'
        echo "No changes made."
        ;;
    [eE])  # If the user presses 'e', open the file in hx editor
        hx "$input_file"
        echo "$number" >> "$tag_file"
        ;;
    *)  # For 'yes' or any other answer (including empty response), do the tagging
        echo "$number" >> "$tag_file"
        # echo "Tagged with \"$tag\"."
        ;;
esac

exit 0
