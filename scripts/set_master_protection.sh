#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_json_file> <github_token>"
    exit 1
fi

JSON_FILE=$1
GITHUB_TOKEN=$2

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Please install jq and try again."
    exit 1
fi

# Iterate over repositories in the JSON file
REPOS=$(jq -c '.repos[]' "$JSON_FILE")
for REPO in $REPOS; do
    REPO_NAME=$(echo "$REPO" | jq -r '.repoName')
    echo "Processing repository: $REPO_NAME"

    # Apply branch protection
    echo "Applying branch protection to $REPO_NAME..."
    curl -L \
        -X PUT \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/Avantio/${REPO_NAME}/branches/master/protection" \
        -d '{
            "required_status_checks": null,
            "enforce_admins": false,
            "required_pull_request_reviews": {
                "dismiss_stale_reviews": false,
                "require_code_owner_reviews": false,
                "required_approving_review_count": 1,
                "bypass_pull_request_allowances": {
                    "users":[],
                    "teams":["master-users"],
                    "apps":[]
                    }
                },
            "restrictions": {
                    "users":[],
                    "teams":["master-users"],
                    "apps":[]
                    },
            "allow_force_pushes": false,
            "allow_deletions": false
        }'

    curl -L \
        -X PATCH \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/Avantio/${REPO_NAME}/branches/master/protection/required_pull_request_reviews" \
        -d '{
            "bypass_pull_request_allowances":{
            "users":[],
            "teams":["master-users"],
            "apps":[]
            }
        }'
    echo "Done processing $REPO_NAME."
done

echo "All repositories processed."