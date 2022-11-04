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
        echo "command=\"/usr/bin/borg serve --restrict-to-repository '$1'$3\",restrict $2" >> ~/.ssh/authorized_keys
    fi
}
authorize_keys() {
    printenv "$1" | while IFS=$'\n' read -r key; do
        authorize_key "$2" "$key" "$3"
    done
    unset "$1"
}
authorize_keys SSH_CLIENT_PUBLIC_KEYS "$REPO_PATH" ""
# https://borgbackup.readthedocs.io/en/stable/usage/notes.html#append-only-mode
authorize_keys SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY "$REPO_PATH" " --append-only"
unset REPO_PATH
while IFS=$'\n' read line; do
    repo_name="$(echo -E "$line" | cut -d = -f 1 | cut -d _ -f 3-)"
    if [ "$repo_name" = "ALL" ]; then
        echo 'Invalid repository name "ALL". Remove environment variable REPO_PATH_ALL.'
        exit 1
    fi
    repo_path="$(printenv "REPO_PATH_${repo_name}")"
    unset "REPO_PATH_${repo_name}"
    authorize_keys "SSH_CLIENT_PUBLIC_KEYS_${repo_name}" "$repo_path" ""
    authorize_keys "SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY_${repo_name}" "$repo_path" " --append-only"
done < <(printenv | grep '^REPO_PATH_')

set -x

exec "$@"
