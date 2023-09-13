#!/bin/bash

# Define the content folder
content_folder="content"

# Initialize a counter for processed files and skipped files
processed_count=0
skipped_count=0

# Initialize an array to store successfully updated files
success_files=()

# Get today's date in the format YYYY-MM-DD
today_date=$(date +%F)

# Use 'find' to locate Markdown files (excluding "_index.md") in subdirectories
find "$content_folder" -type f -name '*.md' ! -name '_index.md' | while read -r markdown_file; do
  # Extract the value of the "link" and "image" keys from the Markdown front matter
  link=$(grep -iE '^link:' "$markdown_file" | sed 's/^link:[[:space:]]*//i')
  image=$(grep -iE '^image:' "$markdown_file" | sed 's/^image:[[:space:]]*//i')

  # Check if there's an existing "image" key
  if grep -q -iE '^image:' "$markdown_file"; then
    # Check if the "image" key is empty using awk
    is_empty_image=$(awk '/^image:[[:space:]]*$/ {print "empty"}' "$markdown_file")
    if [ "$is_empty_image" = "empty" ] || [ -z "$image" ]; then
      # Generate a unique filename for the screenshot based on the Markdown file's folder
      folder_path=$(dirname "$markdown_file")
      screenshot_filename="screenshot_${today_date}.png"

      # Use Puppeteer to take a screenshot of the webpage
      node -e "
        const puppeteer = require('puppeteer');
        (async () => {
          const browser = await puppeteer.launch({ headless: 'new' });
          const page = await browser.newPage();
          await page.setViewport({ width: 1280, height: 1920 });
          await page.goto('$link', { waitUntil: 'domcontentloaded' });
          await page.screenshot({ path: '$folder_path/$screenshot_filename' });
          await browser.close();
        })();
      "

      # Update the existing "image" key value in the frontmatter without adding a new pair using awk
      awk -v new_image="$screenshot_filename" '/^image:/ {$2 = "\"" new_image "\""} 1' "$markdown_file" > "$markdown_file.tmp"
      mv "$markdown_file.tmp" "$markdown_file"

      # Add the file to the list of successfully updated files
      success_files+=("$markdown_file")

      processed_count=$((processed_count + 1))
    else
      ((skipped_count++))
    fi
  else
    # Generate a unique filename for the screenshot based on the Markdown file's folder
    folder_path=$(dirname "$markdown_file")
    screenshot_filename="screenshot_${today_date}.png"

    # Use Puppeteer to take a screenshot of the webpage
    node -e "
      const puppeteer = require('puppeteer');
      (async () => {
        const browser = await puppeteer.launch({ headless: 'new' });
        const page = await browser.newPage();
        await page.setViewport({ width: 1280, height: 1920 });
        await page.goto('$link', { waitUntil: 'domcontentloaded' });
        await page.screenshot({ path: '$folder_path/$screenshot_filename' });
        await browser.close();
      })();
    "

    # Add the "image" key and value to the frontmatter without adding a new pair using awk
    awk -v new_image="$screenshot_filename" '/^---$/ {print "image: \"" new_image "\""; image_added=1} 1' "$markdown_file" > "$markdown_file.tmp"
    mv "$markdown_file.tmp" "$markdown_file"

    # Add the file to the list of successfully updated files
    success_files+=("$markdown_file")

    processed_count=$((processed_count + 1))
  fi

  # Clear the current line and print the updated count of processed files
  clear
  echo -ne "Processed files: $processed_count"

done

# Print a newline character to end the line
echo

# Display the count of skipped files
echo "Skipped $skipped_count files."

# Display the list of successfully updated files
if [ ${#success_files[@]} -gt 0 ]; then
  echo "Successfully updated files:"
  for file in "${success_files[@]}"; do
    echo "$file"
  done
else
  echo "No files were successfully updated."
fi
