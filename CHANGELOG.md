# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2022-11-04
### Added
- support for multiple repositories via environment variables `REPO_PATH_[NAME]`,
  `SSH_CLIENT_PUBLIC_KEYS_[NAME]`, and `SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY_[NAME]`.
  keeping functionality of `BORG_REPO`, `SSH_CLIENT_PUBLIC_KEYS`,
  and `SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY` for downward compatibility.
  keys in `SSH_CLIENT_PUBLIC_KEYS_ALL` are authorized to access all repositories.
- add sshd's `restrict` option to all key authorizations
  (redundant as port forwarding etc is already disabled in `sshd_config`)

## [0.1.1] - 2021-06-20
### Fixed
- fixed repo url in `org.opencontainers.image.source` label
- `docker-compose`: increased memory limit
  (`64MiB` was insufficient for two parallel operations, e.g. `borg create` & `borg list`)

## [0.1.0] - 2021-04-04
### Added
- openssh server listening on tcp port `2200`
- single user `borg`
- public keys in env var `SSH_CLIENT_PUBLIC_KEYS` and `SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY` will be authorized
- launching borgbackup backend when ssh client connects
- only granting access to borgbackup repository at `/repository`
- keys in `SSH_CLIENT_PUBLIC_KEYS_APPEND_ONLY` are restricted to
  [append-only mode](https://borgbackup.readthedocs.io/en/stable/usage/notes.html#append-only-mode)

[Unreleased]: https://github.com/fphammerle/docker-borgbackup-sshd/compare/v1.0.0...master
[1.0.0]: https://github.com/fphammerle/docker-borgbackup-sshd/compare/v0.1.1...v1.0.0
[0.1.1]: https://github.com/fphammerle/docker-borgbackup-sshd/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/fphammerle/docker-borgbackup-sshd/tree/v0.1.0
