# Security

Do not post financial data, database dumps, options.json, secrets.json, Redis URLs, SMTP credentials or tokens in issues. For a vulnerability, use GitHub's private vulnerability reporting if enabled; otherwise contact the owner privately before disclosing details.

The app starts as root only to read HA options and prepare restored file permissions, then drops supplementary groups, GID and UID before connecting to services, migrations, Puma or Sidekiq. No shell evaluation of user options. Only documented optional settings are forwarded. No Supervisor API access, host networking, privileged mode or host filesystem mounts.

HA password fields mask values; they do not encrypt options on disk. Generated secrets use mode 0600, `/data/storage` uses 0700 and backups must be encrypted. Root/HA administrators can access secrets. Never change established encryption keys or SECRET_KEY_BASE. Restrict PostgreSQL/Redis to the internal app network or trusted encrypted network and require authentication. `rediss://` and certificate validation are supported by the Redis client.

HTTP is for a trusted LAN or encrypted Tailscale transport. For browser HTTPS use a trusted reverse proxy, set `https_proxy`, and prevent bypass of that proxy. No Funnel or public port forwarding by default. Keep Sure's own authentication enabled.
