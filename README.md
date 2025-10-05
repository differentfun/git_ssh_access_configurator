# git_ssh_access_configurator

Bash script to quickly configure Git and SSH access to GitHub on a local machine.

This repository contains a single script: `setup_github_ssh.sh`.

## What it does

- Sets global Git `user.name` and `user.email`.
- Generates an Ed25519 SSH keypair at `~/.ssh/github_ed25519` (if missing).
- Updates `~/.ssh/config` by adding a `github.com` host configuration.
- Adds global `url.<base>.insteadOf` rules to automatically use SSH instead of HTTPS for GitHub.
- Prints the public key to add on GitHub.

## Prerequisites

- Bash (Linux/macOS, or Windows via WSL or Git Bash).
- Git installed (`git --version`).
- OpenSSH client installed (`ssh -V`).
- A GitHub account to add the public key to.

## Quick start

1. Clone or download this repository.
2. Make the script executable (if needed):

   ```bash
   chmod +x setup_github_ssh.sh
   ```

3. Run the script (argument is optional and becomes the key comment):

   ```bash
   ./setup_github_ssh.sh "optional-key-comment"
   ```

4. When prompted, enter:
   - `git user.name` (required)
   - `git user.email` (required)

5. Copy the public key printed at the end.

## Add the key on GitHub

1. On GitHub go to: `Settings` → `SSH and GPG keys` → `New SSH key`.
2. Paste the contents of `~/.ssh/github_ed25519.pub` (the script prints it for convenience).
3. Save.

## Verify

- Verify SSH connectivity:

  ```bash
  ssh -T git@github.com
  ```

  On first attempt you may be asked to confirm the server fingerprint; answer `yes`.
  If successful, you'll see something like: `Hi <username>! You've successfully authenticated...`.

- Verify saved Git configuration:

  ```bash
  git config --global --get user.name
  git config --global --get user.email
  git config -l --global | grep url\."git@github\.com:"\.insteadOf
  ```

## Behavior and customization

- The script is idempotent: if `~/.ssh/github_ed25519` exists, it won't be regenerated.
- The key is generated with type `ed25519` and no passphrase; comment = email (or provided argument).
- The SSH configuration added (if missing) is:

  ```sshconfig
  Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/github_ed25519
      IdentitiesOnly yes
      AddKeysToAgent yes
  ```

- The global `insteadOf` rules rewrite URLs like `https://github.com/...` to `git@github.com:...`.
- To regenerate a new key, delete `~/.ssh/github_ed25519` and `~/.ssh/github_ed25519.pub`, then run the script again.

## Restore / Removal

If you want to revert the changes:

- Remove (or edit) the `Host github.com` block in `~/.ssh/config`.
- Delete the keys if you no longer need them:

  ```bash
  rm -f ~/.ssh/github_ed25519 ~/.ssh/github_ed25519.pub
  ```

- Remove the added `insteadOf` rules:

  ```bash
  git config --global --unset-all url."git@github.com:".insteadOf || true
  ```

## Troubleshooting

- Permission denied (publickey):
  - Ensure the public key has been added on GitHub.
  - Add the key to the agent: `ssh-add ~/.ssh/github_ed25519`.
  - Check permissions: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/config ~/.ssh/github_ed25519`.

- `Host key verification failed` or fingerprint prompt: confirm with `yes` on first connect.

- `insteadOf` rules do not seem to apply:
  - Check with `git config -l --global | grep url.`.
  - If needed, remove and re-add the rules as shown above and run the script again.

## Compatibility

Tested on Linux. Also works on macOS. On Windows, use WSL or Git Bash.
