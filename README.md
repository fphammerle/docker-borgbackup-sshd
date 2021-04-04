# docker: borgbackup-sshd 💾 🐳 🐙

Single-user [OpenSSH server](https://www.openssh.com/) restricted to [BorgBackup](https://www.borgbackup.org/) backend

```sh
$ sudo docker run --name borgbackup_sshd \
    -v ssh_host_keys:/etc/ssh/host_keys:rw \
    -v /somewhere:/repository:rw \
    --tmpfs /home/borg/.ssh:mode=1777,size=16k \
    --tmpfs /tmp:mode=1777,size=1M \
    -p 2200:2200 \
    -e SSH_CLIENT_PUBLIC_KEYS="$(cat ~/.ssh/id_*.pub)" \
    -e SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY="$(cat optional-append-only-keys.pub)" \
    --read-only --security-opt=no-new-privileges --cap-drop=ALL \
    docker.io/fphammerle/borgbackup-sshd

$ borg init --encryption=editme ssh://borg@127.0.0.1:2200//repository

$ borg create --stats ssh://borg@127.0.0.1:2200//repository::{hostname}-{utcnow} \
    ~/documents ~/photos ...
```

`sudo docker` may be replaced with `podman`.

Pre-built docker images are available at https://hub.docker.com/r/fphammerle/borgbackup-sshd/tags
(mirror: https://quay.io/repository/fphammerle/borgbackup-sshd?tab=tags)

Annotation of signed git tags `docker/*` contains docker image digests: https://github.com/fphammerle/docker-borgbackup-sshd/tags

Detached signatures of images are available at https://github.com/fphammerle/container-image-sigstore
(exluding automatically built `latest` tag).

### Docker Compose 🐙

1. `git clone https://github.com/fphammerle/docker-borgbackup-sshd`
2. Add public keys to [docker-compose.yml](docker-compose.yml)
3. `docker-compose up --build`
