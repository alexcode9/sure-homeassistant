"""Report updates for review. Never modify the image or apply migrations."""
import json
from pathlib import Path
import subprocess
current = json.loads(Path('upstream.json').read_text())
latest = json.loads(subprocess.check_output(['gh', 'api', 'repos/we-promise/sure/releases/latest']))
tag = latest['tag_name']
if tag == current['version']:
    print('Pinned release is current')
    raise SystemExit(0)
if latest['draft'] or latest['prerelease']:
    raise SystemExit('Refusing draft or prerelease')
title = f"Review Sure upstream {tag}"
repo = 'alexcode9/sure-homeassistant'
existing = json.loads(subprocess.check_output(['gh','issue','list','--repo',repo,'--state','all','--search',title,'--json','title']))
if any(issue['title'] == title for issue in existing):
    print('Review issue already exists')
    raise SystemExit(0)
body = f"New official release: {latest['html_url']}\n\nCurrent pin: {current['version']}.\n\nFollow docs/RELEASING.md: inspect upstream configuration and migrations, resolve the immutable multiarch digest, update both pins, test both architectures and a backup restore, then publish a NEW wrapper version. No automatic merge, migration, tag or deployment."
subprocess.run(['gh','issue','create','--repo',repo,'--title',title,'--body',body],check=True)
