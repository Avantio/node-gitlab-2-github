#!/bin/bash

# Check if the input file is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_json_file> <github_token>"
    exit 1
fi
JSON_FILE=$1
GITHUB_TOKEN=$2
ORG_NAME="Avantio"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Please install jq and try again."
    exit 1
fi

# Read repository names from the JSON file and create repositories
REPOS=$(jq -c '.repos[]' "$JSON_FILE")

for REPO in $REPOS; do
    REPO_NAME=$(echo "$REPO" | jq -r '.repoName')
    
    echo "Creating private repository: $REPO_NAME"
    
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        --data "{\"name\":\"$REPO_NAME\", \"private\": true}" \
        "https://api.github.com/orgs/$ORG_NAME/repos")

    if [ "$RESPONSE" -eq 201 ]; then
        echo "Repository $REPO_NAME created successfully."
    else
        echo "Failed to create repository $REPO_NAME. HTTP status code: $RESPONSE"
    fi
done

