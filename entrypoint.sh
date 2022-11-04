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
    if echo -E "$2" | grep -q '^[a-z]'; then
        echo "command=\"/usr/bin/borg serve --restrict-to-repository '$1'$3\" $2" >> ~/.ssh/authorized_keys
    fi
}
printenv SSH_CLIENT_PUBLIC_KEYS | while IFS=$'\n' read -r key; do
    authorize_key "$REPO_PATH" "$key" ""
done
unset SSH_CLIENT_PUBLIC_KEYS
# https://borgbackup.readthedocs.io/en/stable/usage/notes.html#append-only-mode
printenv SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY | while IFS=$'\n' read -r key; do
    authorize_key "$REPO_PATH" "$key" " --append-only"
done
unset SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY
unset REPO_PATH
while IFS=$'\n' read line; do
    repo_name="$(echo -E "$line" | cut -d = -f 1 | cut -d _ -f 3-)"
    repo_path="$(printenv "REPO_PATH_${repo_name}")"
    unset "REPO_PATH_${repo_name}"
    printenv "SSH_CLIENT_PUBLIC_KEYS_${repo_name}" | while IFS=$'\n' read -r key; do
        authorize_key "$repo_path" "$key" ""
    done
    unset "SSH_CLIENT_PUBLIC_KEYS_${repo_name}"
    printenv "SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY_${repo_name}" | while IFS=$'\n' read -r key; do
        authorize_key "$repo_path" "$key" " --append-only"
    done
    unset "SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY_${repo_name}"
done < <(printenv | grep '^REPO_PATH_')

set -x

exec "$@"
