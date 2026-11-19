# syntax=docker/dockerfile:1
FROM ghcr.io/alexcode9/sure:sha-8911a680581b338d75ed58b902ad720376354ea8@sha256:1a507d6ff0f8e4649ce2c51473115bb4c714d7da024e739e4f6b3b46321eb1e8
USER root
RUN apt-get update && apt-get install -y --no-install-recommends tini \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /rails/storage && ln -s /data/storage /rails/storage
COPY rootfs/ /opt/sure-ha/
ARG BUILD_VERSION=0.1.2
LABEL io.hass.name="Sure Finance" io.hass.description="Sure personal finance" \
      io.hass.type="addon" io.hass.version="${BUILD_VERSION}" \
      io.hass.arch="aarch64|amd64" \
      org.opencontainers.image.source="https://github.com/alexcode9/sure-homeassistant" \
      org.opencontainers.image.licenses="AGPL-3.0-only"
WORKDIR /rails
ENV SELF_HOSTED=true RAILS_ENV=production BINDING=0.0.0.0 PORT=3000 WEB_CONCURRENCY=1
ENTRYPOINT ["/usr/bin/tini", "--", "bundle", "exec", "ruby", "/opt/sure-ha/runtime.rb"]
CMD []
HEALTHCHECK --interval=30s --timeout=5s --start-period=1250s --retries=3 CMD curl --fail --silent http://127.0.0.1:3000/up >/dev/null || exit 1
