# SSH Setup Script

#!/bin/bash
set -euo pipefail

# Define constants
USER="group05"
PORT="22000"
SERVER="paffenroth-23.dyn.wpi.edu"
KEY_PATH="../ssh_keys/secure_key"

LOCAL_DIR = "./app/frontend/src/."
REMOTE_DIR="./app"

SSH_BASE=(ssh -i "${KEY_PATH}" -p "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${SERVER}")
SCP_BASE=(ssh -i "${KEY_PATH}" -p "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

echo "Copying App Frontend to Frontend Sever."

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
 pip install gradio requests --no-cache-dir"

echo "Start app frontend"

"${SSH_BASE[@]}" \
"cd \"{REMOTE_DIR}\" && \
 (sudo fuser -k 7005/tcp || true) && \
 (tmux kill-session -t frontend || true) && \
 tmux new -d -s gradio \".venv/bin/python app.py\""

echo "Done"