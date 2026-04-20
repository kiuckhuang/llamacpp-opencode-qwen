#!/bin/bash

# Download LLM model files to the current directory
# Reads URLs from .env (LLM_MODEL and LLM_MMPROJ)
# Run from the models/ folder: cd models && bash ../dl_model.sh

# Load .env file — check current dir, then parent dir
if [ ! -f ".env" ] && [ -f "../.env" ]; then
    export $(grep -v '^#' ../.env | xargs)
elif [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Function to check if file exists and ask for overwrite
check_file() {
    local filepath="$1"
    local label="$2"

    if [ -f "$filepath" ]; then
        local filesize
        filesize=$(du -h "$filepath" 2>/dev/null | cut -f1)
        echo ""
        echo "⚠️  $label already exists: $filepath ($filesize)"
        echo -n "  Overwrite? [y/N]: "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "  Overwriting..."
            return 0
        else
            echo "  Skipping $label."
            return 1
        fi
    fi
    return 0
}

# Function to download file from URL using wget
download_file() {
    local url="$1"
    local output_name="$2"

    # Check if wget is available
    if ! command -v wget &> /dev/null; then
        echo "Error: wget is not installed. Install it first." >&2
        return 1
    fi

    # Check if URL is provided
    if [[ -z "$url" ]]; then
        echo "Error: No URL provided." >&2
        return 1
    fi

    # Extract filename from URL
    local base="$(echo "$url" | cut -d'?' -f1)"
    local filename=$(basename "$base")
    local target_name="${output_name:-$filename}"

    if [[ -z "$target_name" ]]; then
        echo "Error: Could not determine filename." >&2
        return 1
    fi

    echo "Downloading: $target_name"
    echo "From: $url"

    wget -O "$target_name" "$url" --no-check-certificate 2>/tmp/wget_err && {
        echo "✅ Download successful: $target_name"
        return 0
    } || {
        echo "❌ Download failed." >&2
        return 1
    }
}

# Download model
download_model() {
    local model_url="$1"
    local model_name="$2"

    if [[ -z "$model_url" ]]; then
        echo "Error: LLM_MODEL URL is not set in .env or as argument."
        return 1
    fi

    echo "=== Downloading LLM Model ==="

    if ! check_file "$model_name" "Model"; then
        echo "✅ Model already exists, skipping download."
        return 0
    fi

    download_file "$model_url" "$model_name"
}

# Download mmproj
download_mmproj() {
    local mmproj_url="$1"
    local mmproj_name="$2"

    if [[ -z "$mmproj_url" ]]; then
        echo "No LLM_MMPROJ URL found in .env, skipping mmproj download."
        return 0
    fi

    echo ""
    echo "=== Downloading MMProj ==="

    if ! check_file "$mmproj_name" "MMProj"; then
        echo "✅ MMProj already exists, skipping download."
        return 0
    fi

    download_file "$mmproj_url" "$mmproj_name"
}

# Determine filenames from .env or arguments
MODEL_FILENAME="${2:-$(echo "$LLM_MODEL" | cut -d'?' -f1 | xargs basename)}"
MMPROJ_FILENAME="${4:-$(echo "$LLM_MMPROJ" | cut -d'?' -f1 | xargs basename)}"

# Download model
download_model "${1:-$LLM_MODEL}" "$MODEL_FILENAME"
MODEL_SUCCESS=$?

# Download mmproj
download_mmproj "$LLM_MMPROJ" "$MMPROJ_FILENAME"

if [ $MODEL_SUCCESS -eq 0 ]; then
    echo ""
    echo "=== Download complete ==="
    echo "Files saved in current directory."
else
    echo ""
    echo "❌ Model download failed. Check your internet connection."
    exit 1
fi
