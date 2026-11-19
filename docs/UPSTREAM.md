# Verified application image contract — HAOS 0.1.2

This add-on embeds Sure v0.7.6-hotfix.1 from the **limited-scope HAOS maintenance branch** [alexcode9/sure/tree/haos-0.7.6-hotfix.1](https://github.com/alexcode9/sure/tree/haos-0.7.6-hotfix.1). It is based on official source commit `4b549c6e72c98d76352cd0645bca585e012ce424` and adds only the Enable Banking/BancoPosta pagination correction (see [fork PR #2](https://github.com/alexcode9/sure/pull/2)); the maintenance publishing workflow is in [fork PR #3](https://github.com/alexcode9/sure/pull/3).

Application source commit: `8911a680581b338d75ed58b902ad720376354ea8`.

Multiarch image: `ghcr.io/alexcode9/sure:sha-8911a680581b338d75ed58b902ad720376354ea8@sha256:1a507d6ff0f8e4649ce2c51473115bb4c714d7da024e739e4f6b3b46321eb1e8`.

[Successful CI and GHCR image publication](https://github.com/alexcode9/sure/actions/runs/44562262343) confirms unit/system tests and ARM64/AMD64 Docker builds and multiarch manifest assembly. This does **not** imply a bank will permit accessing transactions earlier than its authorized historical window. A pagination cursor is tied to the ASPSP-accepted effective `date_from` and must be used consistently across pages. See `upstream.json` for machine-readable pin.

## Underlying official source contract

The existing wrapper architecture remains based on Sure **v0.7.6-hotfix.1**:

- [Official Dockerfile](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/Dockerfile): Rails under `/rails`.
- [Compose example](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/compose.example.yml) and [hosting guide](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/docs/hosting/docker.md): external PostgreSQL/Redis and shared `/rails/storage`.
- [Database config](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/config/database.yml), [Sidekiq config](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/config/sidekiq.yml), and [encryption initializer](https://github.com/we-promise/sure/blob/v0.7.6-hotfix.1/config/initializers/active_record_encryption.rb).

The HAOS wrapper retains its independent entrypoint, persistent /data storage, cold-backup behavior and external database. Review all changes and test coordinated backup/restore before production upgrades.
