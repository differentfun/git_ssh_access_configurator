#!/usr/bin/env bash
set -euo pipefail

read -rp "Enter the name to use for git commits: " GIT_NAME
if [[ -z "$GIT_NAME" ]]; then
    echo "A git commit name is required." >&2
    exit 1
fi

read -rp "Enter the email to use for git commits: " GIT_EMAIL
if [[ -z "$GIT_EMAIL" ]]; then
    echo "A valid email for git is required." >&2
    exit 1
fi

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "Configured git user.name='$GIT_NAME' and user.email='$GIT_EMAIL'"

KEY_COMMENT=${1:-"$GIT_EMAIL"}
SSH_DIR="$HOME/.ssh"
KEY_PATH="$SSH_DIR/github_ed25519"
CONFIG_PATH="$SSH_DIR/config"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ ! -f "$KEY_PATH" ]]; then
    ssh-keygen -t ed25519 -C "$KEY_COMMENT" -f "$KEY_PATH" -N ""
else
    echo "Key already exists at $KEY_PATH, not generating a new one." >&2
fi

touch "$CONFIG_PATH"
chmod 600 "$CONFIG_PATH"
if ! grep -q "^Host github.com" "$CONFIG_PATH"; then
cat <<'CONFIG' >> "$CONFIG_PATH"
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
CONFIG
fi

if git config --global --get-all url."git@github.com:".insteadOf >/dev/null 2>&1; then
    git config --global --unset-all url."git@github.com:".insteadof
fi

git config --global --add url."git@github.com:".insteadOf https://github.com/
git config --global --add url."git@github.com:".insteadOf http://github.com/
git config --global --add url."git@github.com:".insteadOf git://github.com/

PUB_KEY=$(cat "$KEY_PATH.pub")
echo "Public key to add on GitHub:"
echo "$PUB_KEY"
