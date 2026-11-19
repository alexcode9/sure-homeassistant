# Changelog

## 0.1.2 (pending verified image)

Backport the BancoPosta / Enable Banking transaction pagination fix onto the exact Sure v0.7.6-hotfix.1 codebase used by add-on 0.1.1. The first page's bank-accepted `date_from` is reused for all pages bound to its `continuation_key`, preventing the "dateFrom is not the same as in continuationKey" error that previously discarded later pages. A bank-imposed shorter history range is recorded as a warning.

The fix does not bypass bank consent/PSD2 historical-data limits or automatically re-fetch movements missing from a previously completed import. Historical backfill may require renewed bank authorization or statement import. Upgrade only after the new immutable ARM64/AMD64 image and HAOS add-on CI pass; keep PostgreSQL backups.


## 0.1.1

Switch to the independently built, immutable multi-arch Sure application image from [alexcode9/sure](https://github.com/alexcode9/sure), pinned to upstream v0.7.6-hotfix.1 source commit `4b549c6e72c98d76352cd0645bca585e012ce424`. No application-code changes in this release. ARM64 and AMD64 compatibility must pass CI and the new HAOS image must be verified before deployment; this release does not automatically upgrade an installed app.

## 0.1.0

Initial experimental wrapper for official Sure v0.7.6-hotfix.1. Native ARM64/AMD64 CI, authenticated dependency checks, migration gate, supervised non-root Puma/Sidekiq, persistent secrets/uploads, cold HA backups, upstream review checks and documented coordinated restore. No HAOS hardware acceptance or legacy data migration claimed.
