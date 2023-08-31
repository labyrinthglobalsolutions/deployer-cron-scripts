#!/bin/bash

# Define an array of repositories and their local directories
REPOSITORIES=(
    "https://github.com/labyrinthglobalsolutions/lgs-frontend.git|/home/ubuntu/deploy/lgs-frontend"
    "https://github.com/labyrinthglobalsolutions/lgs-backend.git|/home/ubuntu/deploy/lgs-backend"
    # Add more repositories as needed
)

# Set the log directory
LOG_DIR="/home/ubuntu/deploy/logs"

# Create the log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Redirect all output to the log file
exec > >(tee -a "$LOG_DIR/script_log.txt") 2>&1

# Loop through each repository and perform actions
for repo_info in "${REPOSITORIES[@]}"; do
    IFS='|' read -ra repo_data <<< "$repo_info"
    repo_url="${repo_data[0]}"
    local_dir="${repo_data[1]}"

    cd "$local_dir" || continue

    echo "Checking repository: $repo_url"

    # Get the current commit hash
    current_commit=$(git rev-parse HEAD)

    # Fetch the latest changes from the remote repository
    git fetch origin

    # Get the latest commit hash from the remote repository
    latest_commit=$(git rev-parse origin/main)

    # Compare the commit hashes to check for changes
    if [ "$current_commit" != "$latest_commit" ]; then
        echo "Changes detected. Pulling the latest changes..."
        git pull origin main
        echo "$repo_url: Pull complete."

        # Sleep for 5 seconds
        sleep 5

        # Trigger the redeploy script with sudo
        sudo ./redeploy.sh
    else
        echo "$repo_url: No changes detected."
    fi
done
