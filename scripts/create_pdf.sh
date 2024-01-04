#!/usr/bin/env bash

# Create PDF from Markdown using Pandoc
# Uses the lists of files in the `lists` directory.
# Usage: ./create_pdf.sh [list name]

list_name=$1
# Dir is 'lists' by default, or the second argument
dir=${2:-lists}

# Check if list name is provided and file is found
if [ -z "$list_name" ]; then
    echo "No list name provided."
    exit 1
elif [ ! -f "$dir/$list_name.txt" ]; then
    echo "List not found."
    exit 1
fi

# The list is a list of file names, one per line. The files are in the `poems` directory.
# The list name is used as the PDF file name.

# Create a temporary file to store the Markdown content
# The file is deleted after the PDF is created.

# Make a temp file with the extension .qmd so that Pandoc will render it.
tmp_file=$(mktemp -t xXXXXXX.qmd)
if [ ! -f "$tmp_file" ]; then
    echo "Failed to create temp file."
    exit 1
fi
trap "rm -f $tmp_file" EXIT

# Add YAML block to turn off page numbers at the start of the temp file
cat > "$tmp_file" << EOM
---
header-includes:
  - \\pagenumbering{gobble}
---

EOM


list_file="$dir/$list_name.txt"
echo "Creating PDF from $list_file"

# Read the list file line by line
while IFS= read -r poem_file; do
    # Check if file exists
    if [ ! -f "poems/$poem_file" ]; then
        echo "File not found: $poem_file"
        exit 1
    fi

    # Add the file content to the temporary file. First the name of the file, then two newlines, then the content.
    echo -e "$poem_file\n\n" >> "$tmp_file"
    # To stop Pandoc from turning the stanzas into paragraphs, add two spaces at the end of each line.
    sed -e 's/$/  /' "poems/$poem_file" >> "$tmp_file"
    # Add a page break after each poem.
    echo -e "{{< pagebreak >}}" >> "$tmp_file"
done < "$list_file"

# Create the PDF. (You have to name the tempfile to x.qmd to render it.)

quarto render "$tmp_file" --to pdf --output "$list_name.pdf"

# Move the file into the directory
mv "$list_name.pdf" "$dir/$list_name.pdf"
