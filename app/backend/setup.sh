# SSH Setup Script

#!/bin/bash
set -euo pipefail

# Define constants
USER="group05"
PORT="22005"
SERVER="paffenroth-23.dyn.wpi.edu"
KEY_PATH="../ssh_keys/group_key"

LOCAL_DIR="./app/backend/src/."
REMOTE_DIR="./app"

SSH_BASE=(ssh -i "${KEY_PATH}" -p "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${SERVER}")
SCP_BASE=(ssh -i "${KEY_PATH}" -p "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

echo "Copying App backend to backend Sever."

"${SSH_BASE[@]}" "rm -rf \"#{REMOTE_DIR}\" && mkdir -p \"${REMOTE_DIR}\""
"${SCP_BASE[@]}" -r "${LOCAL_DIR}" "${USER}@${SERVER}:${REMOTE_DIR}"

echo "Installing API Packages"

"${SSH_BASE[@]}" \
"sudo apt update && \
 sudo apt install -y tmux python3 python3-venv python3-pip"

echo "Creating Python virtual environment"

"${SSH_BASE[@]}" \
"cd \"${REMOTE_DIR}\" && \
 python3 -m venv .venv && \
 source .venv/bin/active && \
 pip install --upgrade pip --no-cache-dir && \
 pip install fastapi uvicorn pydantic torch huggingface_hub transformers --no-cache-dir"

echo "Start app backend"

"${SSH_BASE[@]}" \
"cd \"{REMOTE_DIR}\" && \
 (pkill -f \"uvicorn\" || true) && \
 (tmux kill-session -t backend || true) && \
 tmux new -d -s backend \"source .venv/bin/active && uvicorn backend:api --host 0.0.0.0 --port 9005\""

echo "Done"