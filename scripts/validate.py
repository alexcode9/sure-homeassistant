import json
from pathlib import Path
import re
r = Path(__file__).resolve().parents[1]
c = json.loads((r/'sure/config.yaml').read_text())
u = json.loads((r/'upstream.json').read_text())
assert c['arch'] == ['aarch64', 'amd64']
assert c['init'] is False and c['timeout'] >= 90 and c['backup'] == 'cold'
assert c['ports']['3000/tcp'] == 1235
assert not any(c.get(k) for k in ['host_network','docker_api','hassio_api','full_access'])
assert set(c['options']) <= set(c['schema'])
assert re.fullmatch(r'sha256:[0-9a-f]{64}', u['digest'])
assert u['source_repository'] == 'https://github.com/alexcode9/sure'
assert u['upstream_repository'] == 'https://github.com/we-promise/sure'
assert u['image'] == f"ghcr.io/alexcode9/sure:sha-{u['commit']}"
assert re.fullmatch(r'[0-9a-f]{40}', u['commit'])
assert f"FROM {u['image']}@{u['digest']}" in (r/'sure/Dockerfile').read_text()
assert f"BUILD_VERSION={c['version']}" in (r/'sure/Dockerfile').read_text()
print('Metadata, immutable upstream and safe defaults validated')
