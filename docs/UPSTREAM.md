# Verified upstream contract

Reviewed 2026-11-18 against official release **v0.7.6-hotfix.1**, commit `4b549c6e72c98d76352cd0645bca585e012ce424`. GHCR OCI index digest `sha256:002cde609f3af4b69ba2564c2482f3996e1fe29092dd169962b9b6ed943fcb10` contains `linux/amd64` and `linux/arm64`. The image tag omits the leading `v`.

Primary sources (read the pinned revision when updating):

- [Official Dockerfile](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/Dockerfile): Debian Ruby 3.4.9, `/rails`, UID/GID 1000, Rails and dependencies already built.
- [Compose example](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/compose.example.yml) and [Docker hosting guide](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/docs/hosting/docker.md): web + Sidekiq, external PostgreSQL/Redis, shared `/rails/storage`.
- [Database config](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/config/database.yml): `DB_HOST`, `DB_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`.
- [Sidekiq config](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/config/sidekiq.yml): total `RAILS_MAX_THREADS` includes the AI capsule `RAILS_AI_MAX_THREADS`; defaults 3 and 1. Do not override upstream queues.
- [Encryption initializer](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/config/initializers/active_record_encryption.rb): all three explicit encryption variables or none. This wrapper persists explicit random keys.
- [Home Assistant current config reference](https://contributors.home-assistant.io/apps/reference/configuration/): multiarch image name without tag; version selects image tag; `/data` is persistent; cold backup stops the app. Separate app `build.yaml` is deprecated. `.github/workflows/build.yaml` is a GitHub workflow, not that deprecated file.

The wrapper replaces upstream ENTRYPOINT to run `db:prepare` once before either child starts. It preserves jemalloc preload. It does not invoke the upstream Compose backup sidecar: that expects Compose files and its own runtime stamp. Use the coordinated HA/external-database procedure here instead. `/up` is Rails boot health, not a full dependency or queue health check; monitor Sidekiq and integrations in Sure too.
