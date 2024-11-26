#!/bin/bash

# Check if group argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <group-full-path>"
  exit 1
fi

# Set your GitLab instance URL and private token
GITLAB_URL="https://gitlab.avantio.com/api/v4"
PRIVATE_TOKEN=$2

# Group full path argument
GROUP_FULL_PATH="$1"

# Output JSON file named after the group
OUTPUT_FILE="${GROUP_FULL_PATH//\//_}.json"  # Replace slashes with underscores

# Define GitHub base URL
GITHUB_BASE_URL="https://github.com/Avantio"  # Replace 'username' with your GitHub organization or username

# Initialize the JSON structure
echo '{ "repos": [' > "$OUTPUT_FILE"

# Fetch the list of all non-archived projects within the group (paginated)
PAGE=1
PER_PAGE=100
FIRST_ENTRY=true

while :; do
  # Fetch projects under the given group
  RESPONSE=$(curl -s --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
    "$GITLAB_URL/groups/$GROUP_FULL_PATH/projects?per_page=$PER_PAGE&page=$PAGE&archived=false")

  # Break the loop if the response is empty
  if [ "$(echo "$RESPONSE" | jq '. | length')" -eq 0 ]; then
    break
  fi

  # Parse each project and append to the JSON file
  echo "$RESPONSE" | jq -c --arg github_base "$GITHUB_BASE_URL" '.[] | {
      id: .id,
      repoName: .path_with_namespace,
      gitlabUrl: .web_url,
      githubUrl: ($github_base + "/" + .path_with_namespace)
    }' | while read -r repo; do
    if [ "$FIRST_ENTRY" = true ]; then
      FIRST_ENTRY=false
    else
      echo "," >> "$OUTPUT_FILE"
    fi
    echo "  $repo" >> "$OUTPUT_FILE"
  done

  # Increment page number
  PAGE=$((PAGE + 1))
done

# Close the JSON structure
echo '] }' >> "$OUTPUT_FILE"
