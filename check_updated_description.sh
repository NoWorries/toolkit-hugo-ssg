#!/bin/bash

# Define the content folder
content_folder="content"

# Iterate through Markdown files in the content folder
for markdown_file in "$content_folder"/*.md; do
  # Check if the file exists and is a regular file
  if [ -f "$markdown_file" ]; then
    # Extract the value of the "description" key
    description=$(grep -iE '^description:' "$markdown_file" | sed 's/^description:[[:space:]]*//i')
    
    # Check if the "description" key is empty or missing
    if [ -z "$description" ]; then
      # Extract the value of the "link" key
      link=$(grep -iE '^link:' "$markdown_file" | sed 's/^link:[[:space:]]*//i')
      
      # Check if the "link" key is not empty
      if [ -n "$link" ]; then
        # Attempt to extract the Open Graph description from the website
        open_graph_description=$(curl -s "$link" | grep -oE '<meta [^>]*name="description"[^>]*content="([^"]*)"' | sed -n 's/.*content="\([^"]*\)".*/\1/p')
        
        # Check if an Open Graph description was found
        if [ -n "$open_graph_description" ]; then
          # Update the Markdown file with the extracted description
          sed -i 's/^description:[[:space:]]*'"$description"'/description: '"$open_graph_description"'/i' "$markdown_file"
          echo "Updated description in $markdown_file"
        else
          echo "Could not extract Open Graph description for $markdown_file"
        fi
      else
        echo "No 'link' key found in $markdown_file"
      fi
    fi
  fi
done
