#!/bin/bash

#
# A shell script to download and extract the latest Windows (CUDA 13)
# release of the llama.cpp project from GitHub.
#

# --- Configuration ---
REPO="ggml-org/llama.cpp"

# Load .env if available (overrides defaults)
if [ -f ".env" ]; then
    source .env
fi

DEST_DIR="${LLAMA_CPP_PATH:-llama_bin}"

# --- Script Start ---
set -e # Exit immediately if a command fails.

echo "Starting Llama.cpp Downloader..."

# 1. Check for required tools (curl, jq, wget, unzip)
MISSING_TOOLS=()
for cmd in curl jq wget unzip; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_TOOLS+=("$cmd")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "Missing tools: ${MISSING_TOOLS[*]}"
    echo "Installing via Chocolatey..."
    if command -v choco &> /dev/null; then
        choco install -y "${MISSING_TOOLS[@]}"
    else
        echo "Error: Chocolatey not found. Install it first:"
        echo "  https://chocolatey.org/install"
        exit 1
    fi
fi

# 2. Get the latest release tag from the GitHub API
echo "Finding the latest release tag for '$REPO'..."
API_URL="https://api.github.com/repos/$REPO/releases/latest"

# Use curl to fetch data and jq to parse the 'tag_name' field
LATEST_TAG=$(curl -s "$API_URL" | jq -r .tag_name)

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
    echo "Error: Could not fetch the latest release tag. Check your network or the repository name."
    exit 1
fi

echo "Latest Tag Found: $LATEST_TAG"

# 3. Download the specified release file
# FILE_NAME="llama-${LATEST_TAG}-bin-win-vulkan-x64.zip"
FILE_NAME="llama-${LATEST_TAG}-bin-win-cuda-13.1-x64.zip"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$FILE_NAME"

echo "URL: $DOWNLOAD_URL"
echo "Downloading: $FILE_NAME"
# Use wget to download the file with a progress bar
wget -q "$DOWNLOAD_URL"

if [ ! -f "$FILE_NAME" ]; then
    echo "❌ Error: Download failed. The file was not created."
    exit 1
fi
echo "Download complete."

# 4. Unzip the release file to the destination folder
echo "Extracting files to '$DEST_DIR/'..."

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Unzip, overwriting any existing files without prompting (-o)
unzip -o "$FILE_NAME" -d "$DEST_DIR" > /dev/null
echo "Extraction complete."

# 5. Clean up the downloaded zip file
echo "Cleaning up..."
mkdir -p tests/tmp
mv "$FILE_NAME" tests/tmp
echo "Cleanup complete."

echo "Success! The latest llama.cpp binaries are ready in the '$DEST_DIR' directory."
