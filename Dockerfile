FROM docker.io/alpine:3.13.4

ARG BORGBACKUP_PACKAGE_VERSION=1.1.15-r0
ARG OPENSSH_SERVER_PACKAGE_VERSION=8.4_p1-r3
ARG USER=borg
ENV SSHD_HOST_KEYS_DIR=/etc/ssh/host_keys
ARG REPO_PATH=/repository
RUN apk add --no-cache \
        borgbackup="$BORGBACKUP_PACKAGE_VERSION" \
        openssh-server="$OPENSSH_SERVER_PACKAGE_VERSION" \
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
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

USER $USER
CMD ["/usr/sbin/sshd", "-D", "-e"]

# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md
ARG REVISION=
LABEL org.opencontainers.image.title="single-user openssh server restricted to borgbackup backend" \
    org.opencontainers.image.source="https://github.com/fphammerle/borgbackup-sshd" \
    org.opencontainers.image.revision="$REVISION"
