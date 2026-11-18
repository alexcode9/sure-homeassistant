# Configure Sure Finance

## Before first start

Use Home Assistant OS on a 64-bit ARM or AMD64 host. Prefer SSD storage and enough free RAM for Rails, Sidekiq, PostgreSQL, Redis and HA; measure your actual usage before importing data. No existing installation needs to be removed.

1. In your PostgreSQL service create a **new** login and empty database, owned by that login. A DBA can use `CREATE ROLE sure_user LOGIN;`, set its password interactively with `\password sure_user`, then `CREATE DATABASE sure_production OWNER sure_user;`. The runtime user does not need superuser or global CREATEDB privileges. Never reuse a Maybe database or Sure production database for testing.
2. Configure authenticated Redis, preferably a dedicated instance with persistence enabled and `maxmemory-policy noeviction`. If sharing, allocate an unused logical database (for example `/1`) and ensure other apps do not flush it. A Redis database number is not an access-control boundary. Redis Cluster is not supported by this URL/database setup.
3. Obtain the internal DNS names from your PostgreSQL and Redis apps' information pages. Do not copy guessed add-on prefixes. `localhost` means this Sure container, not HA or another app.
4. Enter the options below. Start Sure only after the new services are ready. Startup waits for authenticated connections, then runs migrations against the configured database.

| Option | Meaning |
| --- | --- |
| `db_host`, `db_port` | PostgreSQL internal DNS and port (default 5432). |
| `postgres_user`, `postgres_db`, `postgres_password` | Dedicated database owner and database; password is required. |
| `redis_url` | `redis://:URL_ENCODED_PASSWORD@REDIS_INTERNAL_HOST:6379/1`, or `rediss://` for TLS. For Redis ACL users use `redis://USER:PASSWORD@HOST:6379/1`. Percent-encode special characters in URL credentials. |
| `app_domain` | Browser hostname, with port if needed, without `http://` or a path; used for email links. |
| `https_proxy` | False for direct HTTP; true when a trusted HTTPS reverse proxy is the only browser entry point. |
| `rails_max_threads` | Total worker threads and database pool (default 3; 2–16). |
| `rails_ai_max_threads` | AI worker threads (default 1), strictly less than total. |
| `dependency_timeout` | Seconds to wait for PostgreSQL/Redis (default 180). Migration timeout is separately 600 seconds. |

Optional `secret_key_base` (at least 64 characters) and the three `active_record_encryption_*` fields may be supplied **before first boot**. Omit them to generate random secrets once in `/data/secrets.json`. Supply either all three encryption keys or none. Established values cannot be changed through options; this prevents accidental loss of decryptability. The app fails if initialized storage is found without its secrets. Preserve both even if all options fields are blank.

Optional SMTP fields: `smtp_address`, `smtp_port`, `smtp_username`, `smtp_password`, `smtp_tls_enabled`, `email_sender`. Configure SMTP for password reset email; verify it before depending on it. Optional AI fields: `openai_access_token`, `openai_model`, `openai_uri_base`. These may send data to the configured provider and incur charges; leave unset unless wanted. The wrapper does not accept arbitrary environment variables or commands.

## Storage and lifecycle

`/rails/storage` points to `/data/storage`. HA preserves `/data` across restarts and image updates. Secrets are stored in `/data/secrets.json`. Puma/Sidekiq and migrations run as `rails`, not root. Migration failure prevents both services from starting. A child exit stops its sibling and exits the app nonzero. Enable HA watchdog for recovery after testing; `/up` checks Rails boot, not all business integrations. Graceful stop quiets Sidekiq and allows up to 55 seconds for its work, within the 90-second HA timeout. Forced termination can cause job retries: verify imported transactions before re-running imports.

## LAN, Tailscale and HTTPS

Direct LAN address: `http://HA_LAN_IP:1235`. Change the mapped host port in the app Network settings if occupied. Port 3000 is internal. This app does not use HA Ingress or HA login.

From a Tailscale-connected client, try `http://HA_TAILSCALE_IP:1235` **only when the Tailscale node actually exposes the HA host's published ports**. A Tailscale app running in userspace can have different reachability. If it fails, first verify LAN access, the app's port mapping, the Tailscale app's networking mode and tailnet ACL/grants. Alternatively use an approved Tailscale subnet router to reach `HA_LAN_IP:1235`. Do not assume an old Tailscale IP is still assigned to this host. Do not open router ports or enable Funnel for this setup.

For HTTPS use a reverse proxy on a trusted host, forwarding to `http://HA_LAN_IP:1235`, preserving Host and sending `X-Forwarded-Proto: https`. Set `https_proxy: true` and `app_domain` to the public-to-your-tailnet hostname; access that HTTPS URL directly. HA's Open Web UI button remains the direct HTTP link. Restrict direct port access if relying on the proxy for TLS. The `/up` health probe intentionally remains available via HTTP.

## Troubleshooting and first acceptance

- Blank or invalid fields: fix options; never share raw options or secrets in logs/issues.
- Waiting for dependencies: confirm internal DNS, port, DB ownership, password, Redis URL escaping and ACLs. Errors are deliberately redacted.
- Migration failure: inspect Rails error logs privately, check DB permissions/version and restore the pre-upgrade backup if necessary. Do not downgrade only the image after a schema change.
- Worker exits: inspect Sidekiq logs and Redis persistence/limits; the app stops rather than silently losing background processing.
- Redirect or cookie problem: check HTTPS proxy setting against the actual browser URL.

First HAOS test: use empty dedicated services, create an account, import a tiny disposable CSV, verify background completion, upload a file, restart, check data, then perform a restore rehearsal into another empty database. Record RAM usage and startup/shutdown duration. Only then consider financial data or start-on-boot. Never migrate or delete the old installation as part of this acceptance test.
