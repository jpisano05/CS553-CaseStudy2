#!/bin/bash
set -euo pipefail

USER="group05"
PORT="22005"
SERVER="paffenroth-23.dyn.wpi.edu"
GROUP_KEY_PATH="./group_key"
SECURE_KEY_NAME="secure_key"

echo "$USER" "$PORT" "$SERVER" "$GROUP_KEY_PATH" "$SECURE_KEY_NAME"

cd "$(dirname "$0")"
ls

chmod 600 "$GROUP_KEY_PATH"
ls -l "$GROUP_KEY_PATH"

SSH_BASE=(ssh -i "$GROUP_KEY_PATH" -p "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${SERVER}")

if ! "${SSH_BASE[@]}" "echo 'SSH connection successful' >/dev/null 2>&1"; then
    echo "key already replaced"
    exit 1
fi

echo "${SSH_BASE[@]}"

rm -f "$SECURE_KEY_NAME" "$SECURE_KEY_NAME.pub"
ssh-keygen -t ed25519 -f "$SECURE_KEY_NAME" -N "" -C "${USER}@${SERVER}"
chmod 600 "./${SECURE_KEY_NAME}"
chmod 644 "./${SECURE_KEY_NAME}.pub"
ls -l "./${SECURE_KEY_NAME}"
ls -l "./${SECURE_KEY_NAME}.pub"

SECURE_PUB_KEY_CONTENT="$(cat "./${SECURE_KEY_NAME}.pub")"
echo "$SECURE_PUB_KEY_CONTENT"

"${SSH_BASE[@]}" "echo $SECURE_PUB_KEY_CONTENT > ~/.ssh/authorized_keys"

SSH_BASE[2]="./${SECURE_KEY_NAME}"
if ! "${SSH_BASE[@]}" "cat ~/.ssh/authorized_keys"; then
    exit 1
fi

echo "${SSH_BASE[@]}"