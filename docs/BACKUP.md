# Consistent backup and restore

A Home Assistant backup of Sure contains `/data`, including options, uploaded files and secrets. It **does not back up external PostgreSQL or Redis**. `backup: cold` only stops Sure for its own HA backup; it does not coordinate other apps. Do not treat independent scheduled snapshots as a consistent full-instance backup.

## Coordinated backup

1. Record wrapper version, upstream digest, PostgreSQL major version and Redis version. Suspend imports/syncs and wait for active jobs to finish in Sure/Sidekiq. Temporarily turn off app watchdog/start-on-boot if they could restart it during maintenance.
2. Stop the Sure app and keep it stopped throughout all following snapshots. Ensure no other Sure web/worker writes to this database, storage or Redis namespace.
3. From the PostgreSQL service or a trusted admin machine, use a compatible client (same major as server recommended): `pg_dump -h DB_HOST -U sure_user -d sure_production -Fc -f sure.dump`. Use an interactive password or protected `.pgpass`, not a password in shell arguments. Capture the dedicated role definition separately without exposing its password. Check the dump exit code and `pg_restore --list sure.dump`.
4. Back up Redis using your Redis service's supported consistent RDB/AOF backup procedure after writers are stopped. Preserve its version, ACLs and persistence settings. A whole-instance Redis restore also affects other logical databases: prefer a dedicated instance, and never restore over shared live Redis. Redis contains pending/retry/scheduled jobs and application cache, not the authoritative finance database. If you intentionally omit it, document that jobs may be lost and reconcile/reschedule in Sure after restoring.
5. Take the HA backup of the **stopped** Sure app. Preserve `/data/storage`, `/data/secrets.json`, configuration and exact image version together with DB/Redis snapshots. Keep the app stopped until these all finish.
6. Encrypt the backup set and copy it off-device. Record checksums and a common timestamp. Start services, then Sure; restore watchdog/start-on-boot preferences. Retain the pre-upgrade set separately.

## Restore rehearsal / disaster recovery

1. Use an isolated HAOS test installation or separate disposable containers and **new empty** PostgreSQL/Redis services. Avoid collision with live DB names, networks, ports and banking integrations. Block outbound integrations until data is checked.
2. Install the exact recorded wrapper image version. Keep Sure stopped. Restore its HA backup (including secrets and storage) without auto-starting it.
3. Recreate the dedicated PostgreSQL login and database, then restore with `pg_restore --exit-on-error --no-owner -h TEST_DB_HOST -U sure_user -d sure_restore sure.dump`. Use the intended DB owner. This command targets only the new empty database; do not add destructive clean flags against production.
4. Restore Redis into its isolated dedicated instance using its matching backup procedure. Check whether jobs will call external providers or duplicate imports before enabling workers. For a deliberate empty Redis restore, reconcile and reschedule pending work manually.
5. Point restored Sure options at the restored services, preserve all secret values, then start. Verify login, accounts, balances, decryptable provider credentials, uploaded files, import completion and background health. Check a known transaction and attachment against the original.
6. Document the rehearsal outcome. To recover production, repeat against the intended replacement services only after verifying targets. Keep the original backups untouched.

## Upgrades and rollback

Migrations occur at startup. Take the coordinated pre-upgrade backup **before** starting a new image. If an upgrade fails, stop it and restore the previous image **and matching database, uploads, keys and Redis snapshot** into fresh services. An image downgrade alone is not a safe database rollback. Never regenerate keys to fix a restore: recover the original keys.
