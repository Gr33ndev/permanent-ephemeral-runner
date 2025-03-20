# Permanent Ephemeral Runner for GitHub Actions

This repository provides a Bash script that automates the lifecycle of a GitHub Actions runner in **ephemeral mode**. The script periodically:

- Fetches a new registration token from GitHub,
- Removes any existing runner configuration,
- Cleans up workspace and logs,
- Registers a new ephemeral runner,
- Starts the runner (which will auto-remove itself after completing one job).

This is useful if you need a runner that automatically resets after each job run, ensuring a clean environment for every new execution.

## Prerequisites

- **GitHub Repository & PAT:**  
  - A GitHub repository (or organization repository) where you want to register the self-hosted runner.
  - A [GitHub Personal Access Token (PAT)](https://github.com/settings/personal-access-tokens) with sufficient permissions.

- **Runner Software:**  
  - The GitHub Actions runner software must be downloaded and extracted into the directory specified by `RUNNER_DIR` (default: `/root/actions-runner`).  
  - Follow [GitHub's instructions](https://docs.github.com/en/actions/hosting-your-own-runners) if you need help setting up the runner.

- **Linux Environment:**  
  - This script is designed for a Linux environment and requires tools such as `bash`, `curl`, and `jq`.

## Setup

1. **Clone the Repository:**  
   Clone this repo to your server or local machine:
   ```bash
   git clone https://github.com/Gr33ndev/real-ephemeral-runner/
   cd real-ephemeral-runner
   ```

2. **Configure the Script:**  
   Open the script file (for example, `runner-loop.sh`) in your favorite editor and update the following variables with your details:
   - `GH_OWNER`: Your GitHub username or organization name.
   - `GH_REPO`: The repository name where the runner will be registered.
   - `GITHUB_PAT`: Your GitHub Personal Access Token.
   - `RUNNER_NAME`: (Optional) Name you want for your runner.
   - `RUNNER_DIR`: The directory where the GitHub Actions runner is installed.

3. **Make the Script Executable:**  
   Change the permission to make the script executable:
   ```bash
   chmod +x runner-loop.sh
   ```

## How to Use

Simply run the script:
```bash
./runner-loop.sh
```
The script will then enter a loop where it:
- Obtains a fresh runner token,
- Removes the previous runner configuration,
- Clears old workspace and diagnostic logs,
- Configures and starts a new ephemeral runner, and
- Waits 5 seconds before repeating the process.

**Note:** Since the runner is configured in ephemeral mode, it automatically removes itself after finishing one job. This helps maintain a fresh runner environment for every GitHub Actions workflow run.

## Troubleshooting

- **Token Issues:**  
  If you encounter a "Failed to fetch runner token!" error, verify that your PAT has the required permissions and that the `GH_OWNER` and `GH_REPO` variables are correct.

- **Missing Dependencies:**  
  The script checks for `jq` and will attempt to install it if missing. Make sure your user has the necessary privileges (or install it manually using your package manager).

- **Runner Directory:**  
  Ensure that the `RUNNER_DIR` points to a valid GitHub Actions runner installation. Follow the [GitHub Runner setup guide](https://docs.github.com/en/actions/hosting-your-own-runners) if you need help with the installation.
