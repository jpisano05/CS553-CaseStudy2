# SSH Setup Script

#!/bin/bash
set -euo pipefail

# Define constants
USER="group05"
PORT="22005"
SERVER="paffenroth-23.dyn.wpi.edu"
KEY_PATH="../ssh_keys/secure_key"

LOCAL_DIR="src/api.py"
REMOTE_DIR="./app"

SSH_BASE=(ssh -i "${KEY_PATH}" -p "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${SERVER}")
SCP_BASE=(scp -i "${KEY_PATH}" -P "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

echo "Copying App backend to backend Server."

"${SSH_BASE[@]}" "mkdir -p \"${REMOTE_DIR}\""
"${SCP_BASE[@]}" -r "${LOCAL_DIR}" "${USER}@${SERVER}:${REMOTE_DIR}"

echo "Installing API Packages"

"${SSH_BASE[@]}" \
"sudo apt update && \
 sudo apt install -y tmux python3 python3-venv python3-pip"

echo "Creating Python virtual environment"

"${SSH_BASE[@]}" \
"cd \"${REMOTE_DIR}\" && \
 if [ ! -d .venv ]; then python3 -m venv .venv; fi && \
 source .venv/bin/activate && \
 pip install --upgrade pip --no-cache-dir && \
 pip install fastapi uvicorn pydantic torch huggingface_hub transformers --no-cache-dir"

echo "Start app backend"

"${SSH_BASE[@]}" \
"cd \"${REMOTE_DIR}\" && \
 tmux kill-session -t backend 2>/dev/null || true && \
 tmux new-session -d -s backend bash -c 'source .venv/bin/activate && uvicorn api:app --host 0.0.0.0 --port 9005 >> backend.log 2>&1'"

echo "Done"