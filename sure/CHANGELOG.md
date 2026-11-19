# Changelog

## 0.1.2

Backport Enable Banking/BancoPosta transaction pagination fix onto the same Sure v0.7.6-hotfix.1 maintenance line: preserve the ASPSP-accepted `date_from` across `continuation_key` pages, prevent changing date ranges mid-pagination, and log when bank consent limits older history. No schema changes intended by this patch. Historical transactions earlier than the ASPSP-authorized window may still require renewed bank consent or statement import. This update does not automatically re-fetch previously truncated account history.

## 0.1.1

Switch to the independently built, immutable multi-arch Sure application image from [alexcode9/sure](https://github.com/alexcode9/sure), pinned to upstream v0.7.6-hotfix.1 source commit `4b549c6e72c98d76352cd0645bca585e012ce424`. No application-code changes in this release. ARM64 and AMD64 compatibility must pass CI and the new HAOS image must be verified before deployment; this release does not automatically upgrade an installed app.

## 0.1.0

Initial experimental wrapper for official Sure v0.7.6-hotfix.1. Native ARM64/AMD64 CI, authenticated dependency checks, migration gate, supervised non-root Puma/Sidekiq, persistent secrets/uploads, cold HA backups, upstream review checks and documented coordinated restore. No HAOS hardware acceptance or legacy data migration claimed.
