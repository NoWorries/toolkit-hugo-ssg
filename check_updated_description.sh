#!/bin/bash

# Define the content folder
content_folder="content"

# Use 'find' to locate Markdown files (excluding "_index.md") in subdirectories
find "$content_folder" -type f -name '*.md' ! -name '_index.md' | while read -r markdown_file; do
  # Extract the value of the "description," "link," and "title" keys from the Markdown front matter
  description=$(grep -iE '^description:' "$markdown_file" | sed 's/^description:[[:space:]]*//i')
  link=$(grep -iE '^link:' "$markdown_file" | sed 's/^link:[[:space:]]*//i')
  title=$(grep -iE '^title:' "$markdown_file" | sed 's/^title:[[:space:]]*//i')

  # Check if the "description" key is empty or missing
  if [ -z "$description" ]; then
    # Check if the "link" key is not empty
    if [ -n "$link" ]; then
      # Attempt to fetch the page title from the website
      page_title=$(curl -s "$link" | grep -oE '<title>[^<]*</title>' | sed -e 's/<[^>]*>//g')

      # Check if a page title was found
      if [ -n "$page_title" ]; then
        # Decode HTML entities in the extracted title using perl
        decoded_page_title=$(echo "$page_title" | perl -MHTML::Entities -pe 'decode_entities($_);')
        
        # Update the Markdown file with the decoded title using awk
        awk -v new_title="$decoded_page_title" '/^title:/ { print "title: \"" new_title "\""; next } 1' "$markdown_file" > temp.md
        mv temp.md "$markdown_file"
        echo "Updated title in $markdown_file"
      else
        echo "Could not extract page title for $markdown_file"
      fi

      # Attempt to extract the Open Graph description from the website
      open_graph_description=$(curl -s "$link" | grep -oE '<meta [^>]*name="description"[^>]*content="([^"]*)"' | sed -n 's/.*content="\([^"]*\)".*/\1/p')

      # Check if an Open Graph description was found
      if [ -n "$open_graph_description" ]; then
        # Decode HTML entities in the extracted description using perl
        decoded_open_graph_description=$(echo "$open_graph_description" | perl -MHTML::Entities -pe 'decode_entities($_);')

        # Update the Markdown file with the decoded description using awk
        awk -v new_description="$decoded_open_graph_description" '/^description:/ { print "description: \"" new_description "\""; next } 1' "$markdown_file" > temp.md
        mv temp.md "$markdown_file"
        echo "Updated description in $markdown_file"
      else
        echo "Could not extract Open Graph description for $markdown_file"
      fi
    else
      echo "No 'link' key found in $markdown_file"
    fi
  fi
done
