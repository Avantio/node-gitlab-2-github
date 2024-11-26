docker run  -e GITHUB_PAT="$1" \
           -e GITLAB_PAT="$2" \
           -e REPOS_FILENAME="avantio-devops-test" \
           -e USERS_MAP_FILENAME"=users_map.json" \
           -e TEMPLATE_FILENAME="settings.template.ts" \
           gitlab-migrator