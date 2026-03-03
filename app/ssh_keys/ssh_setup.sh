#!/bin/bash
set -euo pipefail

USER="group05"
PORT="22005"
SERVER="paffenroth-23.dyn.wpi.edu"
GROUP_KEY_PATH="./group_key"
SECURE_KEY_NAME="secure_key"

cd "$(dirname "$0")"

chmod 600 "$GROUP_KEY_PATH"

SSH_BASE=(ssh -i "$GROUP_KEY_PATH" -p "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${SERVER}")

EXISTS=$("${SSH_BASE[@]}" "grep -Ff <(cat ${SECURE_KEY_NAME}.pub 2>/dev/null) ~/.ssh/authorized_keys || true")

if [ -n "$EXISTS" ]; then
    echo "Secure key already present on server. Skipping key generation."
else
    echo "Secure key not found. Generating new key and updating server."
    rm -f "$SECURE_KEY_NAME" "$SECURE_KEY_NAME.pub"
    ssh-keygen -t ed25519 -f "$SECURE_KEY_NAME" -N "" -C "${USER}@${SERVER}"
    chmod 600 "./${SECURE_KEY_NAME}"
    chmod 644 "./${SECURE_KEY_NAME}.pub"
    SECURE_PUB_KEY_CONTENT="$(cat "./${SECURE_KEY_NAME}.pub")"
    "${SSH_BASE[@]}" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$SECURE_PUB_KEY_CONTENT' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    SSH_BASE[2]="./${SECURE_KEY_NAME}"
    if ! "${SSH_BASE[@]}" "cat ~/.ssh/authorized_keys"; then
        echo "Failed to connect with new secure key!"
        exit 1
    fi
fi

echo "SSH setup complete. Use the following command to connect with secure key:"
echo "${SSH_BASE[@]}"