FROM docker.io/alpine:3.22.1

# https://www.borgbackup.org/releases/
# https://git.alpinelinux.org/aports/log/community/borgbackup?h=3.22-stable
ARG BORGBACKUP_PACKAGE_VERSION=1.4.1-r0
# https://www.openssh.com/releasenotes.html
# https://git.alpinelinux.org/aports/log/main/openssh?h=3.22-stable
ARG OPENSSH_SERVER_PACKAGE_VERSION=10.0_p1-r7
# https://git.alpinelinux.org/aports/log/community/tini?h=3.22-stable
ARG TINI_PACKAGE_VERSION=0.19.0-r3
ARG USER=borg
ENV SSHD_HOST_KEYS_DIR=/etc/ssh/host_keys
ENV REPO_PATH=/repository
RUN apk add --no-cache \
        borgbackup="$BORGBACKUP_PACKAGE_VERSION" \
        openssh-server="$OPENSSH_SERVER_PACKAGE_VERSION" \
        tini=$TINI_PACKAGE_VERSION \
    && adduser -S -s /bin/ash "$USER" \
    && mkdir "$SSHD_HOST_KEYS_DIR" \
    && chown -c "$USER" "$SSHD_HOST_KEYS_DIR" \
    && mkdir "$REPO_PATH" \
    && chown -c "$USER" "$REPO_PATH"
VOLUME $SSHD_HOST_KEYS_DIR
VOLUME $REPO_PATH

COPY sshd_config /etc/ssh/sshd_config
EXPOSE 2200/tcp

ENV SSH_CLIENT_PUBLIC_KEYS=
ENV SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY=
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

USER $USER
CMD ["/usr/sbin/sshd", "-D", "-e"]

# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md
ARG REVISION=
LABEL org.opencontainers.image.title="single-user openssh server restricted to borgbackup backend" \
    org.opencontainers.image.source="https://github.com/fphammerle/docker-borgbackup-sshd" \
    org.opencontainers.image.revision="$REVISION"
