#!/bin/bash

# Navigate to the root of the Jekyll project
cd "$(dirname "$0")/.."

# Array of file extensions to process
extensions=("PNG" "JPG" "JPEG" "GIF" "MOV" "MP3" "MP4")

# Loop through each extension and rename to lowercase
for ext in "${extensions[@]}"; do
  find ./media -type f -name "*.$ext" | while read file; do
    # Generate intermediate name with a temporary extension
    temp_file="${file%.$ext}.temp"
    lowercase_file="${file%.$ext}.${ext,,}"

    # Rename to the temporary name first, then to the lowercase name
    mv "$file" "$temp_file"
    mv "$temp_file" "$lowercase_file"
    echo "Renamed: $file -> $lowercase_file"
  done
done

echo "All uppercase file extensions have been renamed to lowercase."
