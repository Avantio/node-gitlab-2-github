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

    # # Step 1: Apply ruleset
    # echo "Applying ruleset to $REPO_NAME..."
    # curl -L \
    #     -X POST \
    #     -H "Accept: application/vnd.github+json" \
    #     -H "Authorization: Bearer $GITHUB_TOKEN" \
    #     -H "X-GitHub-Api-Version: 2022-11-28" \
    #     "https://api.github.com/repos/Avantio/${REPO_NAME}/rulesets" \
    #     -d '{
    #         "name": "Protecting master",
    #         "target": "branch",
    #         "enforcement": "active",
    #         "conditions": {
    #             "ref_name": {
    #                 "include": ["refs/heads/master"],
    #                 "exclude": []
    #             }
    #         },
    #         "rules": [
    #             {
    #                 "type": "pull_request",
    #                 "parameters": {
    #                     "required_approving_review_count": 1,
    #                     "required_review_thread_resolution": true,
    #                     "dismiss_stale_reviews_on_push": false,
    #                     "require_code_owner_review": false,
    #                     "require_last_push_approval": false
    #                 }
    #             }
    #         ]
    #     }'

    # Step 2: Apply branch protection
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
                "required_approving_review_count": 1
            },
            "restrictions": null,
            "allow_force_pushes": false,
            "allow_deletions": false
        }'
    echo "Done processing $REPO_NAME."
done

echo "All repositories processed."
