# Qwen-3.6-35B-A3B + OpenCode on Windows

Run a powerful AI coding assistant on your own PC using llama.cpp and OpenCode.

---

## Prerequisites

- **Windows 10/11** with NVIDIA GPU (**RTX 5090 32GB** recommended)
- **25GB+ free disk space**
- **Git Bash** — [Download](https://git-scm.com/download/win)
- **Chocolatey** — [Install](https://chocolatey.org/install)
- **Admin rights** — Git Bash must be run as administrator (for Chocolatey)

> `curl`, `jq`, `wget`, `unzip` are auto-installed via Chocolatey if missing.

---

## Quick start

Open **Git Bash as Administrator** (right-click → Run as administrator) and run:

### 1. Clone and setup

```bash
git clone https://github.com/kiuckhuang/llamacpp-opencode-qwen.git
cd llamacpp-opencode-qwen
bash setup.sh
```

This downloads llama.cpp and the Qwen model (~22GB). Grab a coffee — it takes 10-30 minutes.

### 2. Install OpenCode

```bash
choco install opencode
```

> Chocolatey requires admin rights. Make sure you're running Git Bash as administrator.

### 3. Start the server

```bash
bash run_qwen.sh
```

Wait for `HTTP server started`, then keep this terminal open.

### 4. Open OpenCode

```bash
opencode .
```

That's it. Start chatting!

---

## Daily usage

Every time you want to use it:

```bash
bash run_qwen.sh   # Start server (keep open)
opencode .         # Launch OpenCode
```

---

## Manual setup (step by step)

If you prefer to run each step individually:

```bash
bash dl_llama.sh        # Download llama.cpp binaries
mkdir -p models && (cd models && bash ../dl_model.sh)
choco install opencode  # Install OpenCode
bash run_qwen.sh        # Start server
opencode .              # Launch OpenCode
```

---

## Using a different model

1. Edit `.env` — replace `LLM_MODEL` with your model URL
2. Run `bash dl_model.sh` (downloads directly into `models/`)
3. Edit `opencode.json` — update the model entry in the `provider.llama.cpp.models` section
4. Restart the server

> **Note:** The llama.cpp provider is installed globally (in `~/.config/opencode/opencode.json`), so it's available in any project. Only the default model is set per-project.

---

## Troubleshooting

**"Model not found"**
- Make sure the `.gguf` file is inside the `models/` folder

**"Connection refused"**
- Ensure `run_qwen.sh` is still running

**"CUDA out of memory"**
- Close other GPU apps, or lower `--n-gpu-layers` in `run_qwen.sh`

---

## Files

| File | Purpose |
|---|---|
| `setup.sh` | One-click setup (downloads everything + installs global config) |
| `run_qwen.sh` | Start the AI server |
| `opencode.json` | Project config (default model) |
| `dl_llama.sh` | Download llama.cpp binaries |
| `dl_model.sh` | Download LLM model |
| `.env` | Model download URLs |

---

## Credits

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Qwen3.6-35B-A3B](https://huggingface.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive)
- [OpenCode](https://opencode.ai)
