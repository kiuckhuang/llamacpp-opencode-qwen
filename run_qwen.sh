#!/bin/bash

# Load .env file if it exists
if [ -f ".env" ]; then
    source .env
fi

# Set variables (with defaults)
LLAMA_CPP_PATH="${LLAMA_CPP_PATH:-./llama_bin}"

# Detect Windows executable extension
if [[ "$(uname)" == *"MINGW"* ]] || [[ "$(uname)" == *"MSYS"* ]] || [[ "$(uname)" == *"CYGWIN"* ]]; then
    EXE_EXT=".exe"
    echo "Detected Windows environment (Git Bash)"
else
    EXE_EXT=""
fi

# Extract model filenames from .env URLs
MODEL_NAME="$(basename "$(echo "$LLM_MODEL" | cut -d'?' -f1)")"
MMPROJ_NAME="$(basename "$(echo "$LLM_MMPROJ" | cut -d'?' -f1)")"
MODEL_PATH="models/$MODEL_NAME"
MMPROJ_PATH="models/$MMPROJ_NAME"

# Server settings
HOST="0.0.0.0"
PORT="8080"

# Check if model file exists
if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model file not found at $MODEL_PATH"
    echo "Please download the model first by running: bash dl_model.sh"
    exit 1
fi

echo "=== Starting llama.cpp Server ==="
echo "Model: $MODEL_PATH"
echo "API: http://localhost:$PORT/v1"
echo ""

# Run server
"$LLAMA_CPP_PATH/llama-server${EXE_EXT}" \
  --host "$HOST" \
  --port "$PORT" \
  --model "$MODEL_PATH" \
  --jinja \
  --flash-attn "on" \
  --batch-size 2048 \
  --ctx-size 0 \
  --threads 16 \
  --n-gpu-layers 99 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --prio -1 \
  --reasoning on \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0.0 \
  --presence-penalty 0.0 \
  --repeat-penalty 1.0 \
  --image-min-tokens 1024 \
  --chat-template-kwargs '{"preserve_thinking":true}' \
  $([ -f "$MMPROJ_PATH" ] && echo "--mmproj $MMPROJ_PATH")
