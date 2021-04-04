#!/bin/sh

set -eu

# sync with https://github.com/fphammerle/docker-gitolite/blob/master/entrypoint.sh
if [ ! -f "$SSHD_HOST_KEYS_DIR/rsa" ]; then
    ssh-keygen -t rsa -b 4096 -N '' -f "$SSHD_HOST_KEYS_DIR/rsa"
fi
if [ ! -f "$SSHD_HOST_KEYS_DIR/ed25519" ]; then
    ssh-keygen -t ed25519 -N '' -f "$SSHD_HOST_KEYS_DIR/ed25519"
fi
unset SSHD_HOST_KEYS_DIR

authorize_key() {
    if echo -E "$1" | grep -q '^[a-z]'; then
        echo "command=\"/usr/bin/borg serve --restrict-to-repository '$REPO_PATH'$2\" $1" >> ~/.ssh/authorized_keys
    fi
}
printenv SSH_CLIENT_PUBLIC_KEYS | while IFS=$'\n' read -r key; do
    authorize_key "$key" ""
done
unset SSH_CLIENT_PUBLIC_KEYS
# https://borgbackup.readthedocs.io/en/stable/usage/notes.html#append-only-mode
printenv SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY | while IFS=$'\n' read -r key; do
    authorize_key "$key" " --append-only"
done
unset SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY
unset REPO_PATH

set -x

exec "$@"
