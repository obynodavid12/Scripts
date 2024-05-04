#!/bin/bash

# Define an array of GitHub repository URLs
REPOS=(
    "https://github.com/obynodavid12/Scripts.git"
    "https://github.com/obynodavid12/argocd-demo.git"
    # Add more repositories as needed
)

# Loop through each repository
for repo_url in "${REPOS[@]}"; do
    # Extract repository name
    repo_name=$(basename "$repo_url" .git)
    echo "$repo_name"
    # Check if the repository exists locally
    if [ ! -d "$repo_name" ]; then
        # Clone the repository if it doesn't exist
        git clone "$repo_url"
    else
        # Pull the latest changes if the repository exists
        cd "$repo_name" || exit
        git pull
        cd ..
    fi

    # Execute filtering command (replace with your actual command)
    # Example: Filtering files containing specific keywords
    grep -rnw "$repo_name" -e "xyz-3.0.0.0.0\|xyz-3.0.0.0.0" > "${repo_name}_filtered_results.txt"
done
