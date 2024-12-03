import os
import json
import subprocess

# Get the filenames and PATs from environment variables
repos_filename = os.getenv("REPOS_FILENAME", "avantio-devops-test")
users_map_filename = os.getenv("USERS_MAP_FILENAME", "users_map.json")
template_filename = os.getenv("TEMPLATE_FILENAME", "settings.template.ts")
github_pat = os.getenv("GITHUB_PAT", "")  # GitHub Personal Access Token
gitlab_pat = os.getenv("GITLAB_PAT", "")  # GitLab Personal Access Token
mirror_repos = os.getenv("MIRROR_REPOS", "true")  # Whether to mirror the repos to GitHub

# Function to mirror the GitLab repo to GitHub
def mirror_repo(gitlab_url, github_url, repo_name):
    # Directory name for the mirrored repository
    repo_dir = f"{repo_name}.git"
    
    # Check if the repository has already been cloned
    if os.path.exists(repo_dir):
        print(f"Repository '{repo_name}' already cloned. Skipping clone.")
        # Change to the existing directory
        os.chdir(repo_dir)
    else:
        # Authenticate with the GitLab PAT by inserting it into the GitLab URL
        authenticated_gitlab_url = gitlab_url.replace(
            "https://gitlab.avantio.com", f"https://oauth2:{gitlab_pat}@gitlab.avantio.com"
        )
        
        # Clone the repo from GitLab using the `--mirror` option
        subprocess.run(f"git clone --mirror {authenticated_gitlab_url}", shell=True)
        
        # Change to the newly created repo directory
        os.chdir(repo_dir)
    
    # Authenticate with the GitHub PAT by inserting it into the GitHub URL
    authenticated_github_url = github_url.replace(
        "https://github.com", f"https://git:{github_pat}@github.com"
    )

    print(f"Pushing mirror of '{repo_name}' to GitHub at {authenticated_github_url}")
    
    # Push to GitHub using the `--mirror` option
    subprocess.run(f"git push --no-verify --mirror {authenticated_github_url}", shell=True)
    
    # Set push URL to the mirror location with PAT authentication
    subprocess.run(f"git remote set-url --push origin {authenticated_github_url}", shell=True)
    
    # Periodically update the repo on GitHub with what you have in GitLab
    subprocess.run("git fetch -p origin", shell=True)
    subprocess.run("git push --no-verify --mirror", shell=True)
    
    # Return to the main directory
    os.chdir("..")

# Load JSON files
with open(repos_filename + '.json', 'r') as repos_file:
    repos_data = json.load(repos_file)

with open(users_map_filename, 'r') as users_map_file:
    users_map_data = json.load(users_map_file)

# Load the configuration template
with open(template_filename, 'r') as template_file:
    template_content = template_file.read()

# Function to convert the usermap into a valid JSON string
def format_usermap(usermap):
    return json.dumps(usermap, indent=2)  # Convert to JSON with indentation for readability

# Generate and execute settings.ts for each repository
for repo in repos_data['repos']:
    repo_id = repo['id']
    repo_name = repo['repoName']
    gitlab_url = repo['gitlabUrl']
    github_url = repo['githubUrl']
    
    # Mirror the GitLab repository to GitHub
    if (mirror_repos == "true"):
        mirror_repo(gitlab_url, github_url, repo_name)
    
    # Replace values in the template
    settings_content = template_content.replace('projectId: 0,', f'projectId: {repo_id},')
    settings_content = settings_content.replace("repo: 'REPLACE_ME',", f"repo: '{repo_name}',")
    settings_content = settings_content.replace("'GITHUB_TOKEN'", f"'{github_pat}'")
    settings_content = settings_content.replace("'GITLAB_TOKEN'", f"'{gitlab_pat}'")

    # Inject the usermap
    formatted_usermap = format_usermap(users_map_data)
    settings_content = settings_content.replace('usermap: {', f'usermap: {formatted_usermap},')

    # Write the new settings.ts file
    settings_filename = f'settings.ts'
    with open(settings_filename, 'w') as output_file:
        output_file.write(settings_content)

    # Run `npm start` for each generated settings.ts file if needed
    subprocess.run('npm run start', shell=True)
