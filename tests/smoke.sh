#!/usr/bin/env bash
set -Eeuo pipefail
image=${1:?image}
network="sure-test-${RANDOM}"
app="${network}-app"
db="${network}-db"
redis="${network}-redis"
volume="${network}-data"
cleanup() {
  docker rm -f "$app" "$db" "$redis" >/dev/null 2>&1 || true
  docker volume rm "$volume" >/dev/null 2>&1 || true
  docker network rm "$network" >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'echo "Smoke test failed at line $LINENO" >&2; docker logs "$app" 2>&1 | tail -100' ERR
docker network create "$network" >/dev/null
docker volume create "$volume" >/dev/null
docker run -d --name "$db" --network "$network" -e POSTGRES_PASSWORD=test-only -e POSTGRES_USER=sure -e POSTGRES_DB=sure_test postgres:17 >/dev/null
docker run -d --name "$redis" --network "$network" redis:7-alpine redis-server --requirepass test-only >/dev/null
# Supply disposable test credentials via stdin, never production credentials.
python3 - "$db" "$redis" <<'PY' | docker run --rm -i -v "$volume:/data" --entrypoint sh "$image" -c 'cat > /data/options.json'
import json, sys
print(json.dumps({'db_host':sys.argv[1],'postgres_user':'sure','postgres_db':'sure_test','postgres_password':'test-only','redis_url':f'redis://:test-only@{sys.argv[2]}:6379/1'}))
PY
docker run -d --name "$app" --network "$network" -v "$volume:/data" "$image" >/dev/null
wait_ready() {
  for _ in $(seq 1 120); do
    if docker exec "$app" curl -fsS http://127.0.0.1:3000/up >/dev/null 2>&1 \
      && docker exec "$app" pgrep -f '^sidekiq ' >/dev/null \
      && docker exec "$app" pgrep -f '^puma ' >/dev/null; then return 0; fi
    if [ "$(docker inspect -f '{{.State.Running}}' "$app")" != true ]; then break; fi
    sleep 3
  done
  docker logs "$app"
  return 1
}
wait_ready
# Both services run as rails; a real Sidekiq heartbeat exists in Redis.
docker exec "$app" sh -c 'ps -eo user,args | grep "^rails.*sidekiq" | grep -v grep'
for _ in $(seq 1 20); do
  if docker exec -e REDISCLI_AUTH=test-only "$redis" redis-cli -n 1 SCARD processes | grep -Eq '^[1-9][0-9]*$'; then break; fi
  sleep 1
done
docker exec -e REDISCLI_AUTH=test-only "$redis" redis-cli -n 1 SCARD processes | grep -Eq '^[1-9][0-9]*$' 
before=$(docker exec "$app" sha256sum /data/secrets.json)
docker exec -u rails "$app" sh -c 'echo persistent > /data/storage/test-marker'
docker stop -t 85 "$app" >/dev/null
test "$(docker inspect -f '{{.State.ExitCode}}' "$app")" = 0
docker start "$app" >/dev/null
wait_ready
test "$before" = "$(docker exec "$app" sha256sum /data/secrets.json)"
docker exec "$app" grep -q persistent /data/storage/test-marker
# Killing either service must terminate the whole container nonzero.
for service in sidekiq puma; do
  docker exec "$app" pkill -KILL -f "^${service} "
  for _ in $(seq 1 40); do
    [ "$(docker inspect -f '{{.State.Running}}' "$app")" = false ] && break
    sleep 2
  done
  test "$(docker inspect -f '{{.State.Running}}' "$app")" = false
  test "$(docker inspect -f '{{.State.ExitCode}}' "$app")" != 0
  if [ "$service" = sidekiq ]; then docker start "$app" >/dev/null; wait_ready; fi
done
