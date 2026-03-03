# SSH Setup Script

#!/bin/bash
set -euo pipefail

# Define constants
USER="group05"
PORT="22000"
SERVER="paffenroth-23.dyn.wpi.edu"
KEY_PATH="../ssh_keys/group_key"

if [ -f "../../.config/api_keys" ]; then
    source "../../.config/api_keys"
else
    echo "keys not found"
    exit 1
fi

LOCAL_DIR="src/app.py"
REMOTE_DIR="./app"

SSH_BASE=(ssh -i "${KEY_PATH}" -p "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${SERVER}")
SCP_BASE=(scp -i "${KEY_PATH}" -P "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

echo "Copying App Frontend to Frontend Sever."

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
 pip install "gradio[oauth]" requests --no-cache-dir"

echo "Start app frontend"

"${SSH_BASE[@]}" \
"cd \"${REMOTE_DIR}\" && \
 (sudo fuser -k 7005/tcp || true) && \
 (tmux kill-session -t gradio 2>/dev/null || true) && \
 HF_TOKEN='${HF_TOKEN}' tmux new-session -d -s gradio \
 ' .venv/bin/python app.py >> gradio.log 2>&1 '"
 
echo "Done"