#!/bin/bash

# Set your GitHub organization/repository and personal access token (PAT)
GH_OWNER="your-github-name"
GH_REPO="your-repo-name"
GITHUB_PAT="your-github-pat" # Create here: https://github.com/settings/personal-access-tokens
RUNNER_NAME="ephemeral-runner"
RUNNER_DIR="/root/actions-runner"
GH_API_URL="https://api.github.com/repos/$GH_OWNER/$GH_REPO/actions/runners/registration-token"

get_new_token() {
    echo "Fetching new runner token..."
    RUNNER_TOKEN=$(curl -s -X POST -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_PAT" \
        "$GH_API_URL" | jq -r '.token')

    if [[ -z "$RUNNER_TOKEN" || "$RUNNER_TOKEN" == "null" ]]; then
        echo "Failed to fetch runner token! Exiting..."
        exit 1
    fi
}

if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    apt update && apt install -y jq
fi

while true; do
    get_new_token  # Fetch a fresh token before each registration

    echo "Removing previous runner configuration..."

    # Ensure we have a valid token before removing
    if [[ -n "$RUNNER_TOKEN" ]]; then
        RUNNER_ALLOW_RUNASROOT="1" $RUNNER_DIR/config.sh remove --token "$RUNNER_TOKEN"
    fi

    # Force delete previous runner config to avoid "already configured" errors
    rm -rf $RUNNER_DIR/.runner

    # Cleanup workspace and logs
    rm -rf $RUNNER_DIR/_work/*
    rm -rf $RUNNER_DIR/_diag/*
    echo "Cleaned _work & _diag"

    # Configure the runner in ephemeral mode with the new token
    echo "Registering GitHub runner..."
    RUNNER_ALLOW_RUNASROOT="1" $RUNNER_DIR/config.sh --url "https://github.com/$GH_OWNER/$GH_REPO" \
        --token "$RUNNER_TOKEN" --name "$RUNNER_NAME" --ephemeral --unattended

    # Start the runner (ephemeral mode will auto-remove it after one job)
    echo "Starting runner..."
    RUNNER_ALLOW_RUNASROOT="1" $RUNNER_DIR/run.sh

    # Wait before restarting to prevent rapid loops
    sleep 5
done
