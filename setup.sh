#!/bin/bash

# One-click setup for Qwen-3.6-35B-A3B + OpenCode on Windows

set -e

echo "=== Qwen-3.6-35B-A3B + OpenCode Setup ==="
echo ""

# Create .env from example if it doesn't exist
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "Created .env from .env.example"
    else
        echo "ERROR: .env.example not found."
        exit 1
    fi
fi

# Step 1: Download llama.cpp
echo "[1/4] Downloading llama.cpp..."
bash dl_llama.sh
echo "[1/4] Done!"
echo ""

# Step 2: Download model (into models/ folder)
echo "[2/4] Downloading Qwen-3.6-35B-A3B model (~22GB)..."
echo "(This may take 10-30 minutes depending on your internet)"
echo ""

mkdir -p models
(cd models && bash ../dl_model.sh)
echo "[2/4] Done!"
echo ""

# Step 3: Install global OpenCode config
echo "[3/4] Installing global OpenCode config..."
source .env
mkdir -p "$OPENCODE_DIR"
cp opencode.json "$OPENCODE_DIR/opencode.json"
echo "[3/4] Done!"
echo ""

echo "=== Setup complete! ==="
echo ""
echo "Next steps:"
echo "  1. Install OpenCode:  choco install opencode"
echo "  2. Start server:      bash run_qwen.sh"
echo "  3. Launch OpenCode:   opencode ."
