# Sure Finance for Home Assistant OS

Community Home Assistant app maintained in this repository, wrapping **official [we-promise/sure](https://github.com/we-promise/sure)**. No legacy Maybe image or application fork. Experimental: container CI is required before release; on-device HAOS acceptance is still pending.

- ARM64 (`aarch64`, including 64-bit Raspberry Pi) and AMD64.
- Puma and Sidekiq run together as the unprivileged `rails` user, under a fail-fast supervisor and Tini.
- External PostgreSQL and Redis; no bundled database and no access to Docker, host files or Supervisor API.
- Immutable upstream image, persistent upload storage and automatically generated persistent encryption secrets.
- Port **1235**, independent of an existing Maybe installation on 1234.
- Weekly upstream release checks open review issues. Updates are never automatically merged or deployed.

## Installation (when you are ready)

Add `https://github.com/alexcode9/sure-homeassistant` in Home Assistant **Settings → Apps → App Store → Repositories**. Install Sure Finance, enter a **new dedicated** PostgreSQL database/user and dedicated Redis database URL, then start it. Installation and startup are deliberately separate; start-on-boot defaults off. Enable watchdog and start-on-boot after acceptance testing.

Open `http://HOME_ASSISTANT_LAN_IP:1235`. For HTTPS proxies set `https_proxy: true` and open the HTTPS URL directly. There is no Ingress integration; use Sure's own authentication.

**Do not point this app at an existing Maybe database.** Nothing in this repository deploys to your Pi, stops existing apps, or migrates old installations.

[Configuration, networking and troubleshooting](sure/DOCS.md) · [Backup and restore](docs/BACKUP.md) · [Release procedure](docs/RELEASING.md) · [Verified upstream contract](docs/UPSTREAM.md)

## Development

```sh
python3 scripts/validate.py
ruby tests/runtime_test.rb
docker build -t sure-ha-test sure
tests/smoke.sh sure-ha-test
```

The smoke test creates and deletes only its randomly named test containers, network and volume. It uses PostgreSQL 17 and Redis 7 with disposable passwords, verifies migrations, HTTP health, a real Sidekiq heartbeat, storage/secret persistence, graceful stop, and failure propagation for both services. GitHub Actions runs it natively on both architectures. It does not access Home Assistant.

## License and source

AGPL-3.0 (see LICENSE). The wrapper source is here; the full corresponding upstream application source is pinned in [upstream.json](upstream.json) and available at [the exact upstream commit](https://github.com/we-promise/sure/tree/4b549c6e72c98d76352cd0645bca585e012ce424). Preserve these source links when redistributing images. This is an independent community package, not an official Home Assistant or Sure product.
