# SSH Setup Script
#!/bin/bash
set -euo pipefail
# Define constants
USER="group05"
PORT="22005"
SERVER="paffenroth-23.dyn.wpi.edu"
GROUP_KEY_PATH="./group_key"
SECURE_KEY_NAME="secure_key"
echo "$USER" "$PORT" "$SERVER" "$GROUP_KEY_PATH" "$SECURE_KEY_NAME"
# Move to the script's directory
cd "$(dirname "$0")"
ls
# Set initial SSH key permissions
chmod 600 "$GROUP_KEY_PATH"
ls -l "$GROUP_KEY_PATH"
# Setup SSH command
SSH_BASE=(ssh -i "$GROUP_KEY_PATH" -p "$PORT" -o StrictHostKeyChecking=no -
o UserKnownHostsFile=/dev/null "${USER}@${SERVER}")
echo "${SSH_BASE[@]}"
# Create new SSH key
rm -f "$SECURE_KEY_NAME" "$SECURE_KEY_NAME.pub"
ssh-keygen -t ed25519 -f "$SECURE_KEY_NAME" -N "" -C "${USER}@${SERVER}"
chmod 600 "./${SECURE_KEY_NAME}"
chmod 644 "./${SECURE_KEY_NAME}.pub"
ls -l "./${SECURE_KEY_NAME}"
ls -l "./${SECURE_KEY_NAME}.pub"
# Store public key
SECURE_PUB_KEY_CONTENT="$(cat "./${SECURE_KEY_NAME}.pub")"
echo "$SECURE_PUB_KEY_CONTENT"
# Replace authorized keys with secure key
"${SSH_BASE[@]}" \
"echo $SECURE_PUB_KEY_CONTENT > ~/.ssh/authorized_keys"
# Try connecting via new key
SSH_BASE[2]="./${SECURE_KEY_NAME}"
if ! "${SSH_BASE[@]}" "cat ~/.ssh/authorized_keys"; then
exit 1
fi
# Print command to use to test
echo "${SSH_BASE[@]}"