from pathlib import Path
import csv
from datetime import date
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
_SOURCE_SUFFIXES = {'.py', '.sh', '.sbatch', '.c', '.h', '.cpp', '.hpp', '.s',
                    '.scala', '.sc', '.sv', '.v', '.vh', '.ld', '.td', '.patch'}
_COMMENT_CHANGES = {'comments_removed', 'comments_removed_and_tooling_adaptation'}
_REPORTED_SOURCE_CHANGES = set()
_REPORTED_FUNCTION_CHANGES = {}

def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()

def load(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))

def matches_recorded_source(path, expected):
    path = Path(path).resolve()
    current = digest(path)
    if current == expected:
        return True
    if path.suffix.lower() not in _SOURCE_SUFFIXES:
        return False
    try:
        relative = path.relative_to(ROOT).as_posix()
    except ValueError:
        return False
    inventory = ROOT / 'source_comment_changes.csv'
    if not inventory.is_file():
        return False
    with inventory.open(encoding='utf-8-sig', newline='') as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != ['path', 'before', 'after', 'change']:
            raise ValueError('invalid source comment change columns')
        entries = {}
        for row in reader:
            name = row['path'].replace('\\', '/')
            candidate = Path(name)
            if candidate.is_absolute() or candidate.drive or '..' in candidate.parts:
                raise ValueError('invalid source comment change path: ' + name)
            if name in entries:
                raise ValueError('duplicate source comment change path: ' + name)
            if (row['change'] not in _COMMENT_CHANGES or
                    not re.fullmatch(r'[0-9a-f]{64}', row['before']) or
                    not re.fullmatch(r'[0-9a-f]{64}', row['after'])):
                raise ValueError('invalid source comment change entry: ' + name)
            entries[name] = row
    row = entries.get(relative)
    if row is None or row['before'] != expected or row['after'] != current:
        return False
    key = (relative, expected, current)
    if key not in _REPORTED_SOURCE_CHANGES:
        print('RECORDED_SOURCE_CHANGE_ACCEPTED path=' + relative + ' change=' + row['change'], flush=True)
        _REPORTED_SOURCE_CHANGES.add(key)
    return True

def matches_historical_source(path, expected):
    if matches_recorded_source(path, expected):
        return True
    path = Path(path).resolve()
    if path.suffix.lower() not in _SOURCE_SUFFIXES:
        return False
    try:
        relative = path.relative_to(ROOT).as_posix()
    except ValueError:
        return False
    inventory = ROOT / 'source_function_changes.csv'
    if not inventory.is_file():
        return False
    entries = {}
    with inventory.open(encoding='utf-8-sig', newline='') as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != ['path', 'before', 'after', 'change', 'reason', 'date']:
            raise ValueError('invalid source function change columns')
        for row in reader:
            name = row['path'].replace('\\', '/')
            candidate = Path(name)
            if (not name or candidate.is_absolute() or candidate.drive or
                    '..' in candidate.parts or candidate.as_posix() != name or
                    candidate.suffix.lower() not in _SOURCE_SUFFIXES):
                raise ValueError('invalid source function change path: ' + name)
            if name in entries:
                raise ValueError('duplicate source function change path: ' + name)
            if (row['change'] != 'functional_update' or
                    not re.fullmatch(r'[0-9a-f]{64}', row['before']) or
                    not re.fullmatch(r'[0-9a-f]{64}', row['after']) or
                    row['before'] == row['after'] or not row['reason'].strip() or
                    not re.fullmatch(r'\d{4}-\d{2}-\d{2}', row['date'])):
                raise ValueError('invalid source function change entry: ' + name)
            date.fromisoformat(row['date'])
            entries[name] = row
    row = entries.get(relative)
    if row is None or row['after'] != digest(path):
        return False
    if row['before'] != expected:
        inventory = ROOT / 'source_comment_changes.csv'
        if not inventory.is_file():
            return False
        with inventory.open(encoding='utf-8-sig', newline='') as stream:
            comments = list(csv.DictReader(stream))
        prior = [item for item in comments if item['path'].replace('\\', '/') == relative]
        if (len(prior) != 1 or prior[0]['change'] not in _COMMENT_CHANGES or
                prior[0]['before'] != expected or prior[0]['after'] != row['before']):
            return False
    key = (relative, expected, row['after'])
    if key not in _REPORTED_FUNCTION_CHANGES:
        print('HISTORICAL_SOURCE_CHANGED path=' + relative +
              ' current_code_verified=false reason=' + row['reason'], flush=True)
        _REPORTED_FUNCTION_CHANGES[key] = row['reason']
    return True

def historical_source_changes():
    changes = {key[0]: reason for key, reason in _REPORTED_FUNCTION_CHANGES.items()}
    return [dict(path=path, reason=reason)
            for path, reason in sorted(changes.items())]

def new_output(path, root=ROOT):
    path, root = Path(path).resolve(), root.resolve()
    if path == root or root in path.parents:
        raise ValueError('output must be outside the project: ' + str(path))
    if path.exists() and (not path.is_dir() or any(path.iterdir())):
        raise ValueError('output directory must be new or empty: ' + str(path))
    path.mkdir(parents=True, exist_ok=True)
    return path

def recorded_file(path, expected=None):
    path = Path(path).resolve()
    candidates = [path]
    parents = [path.parent]
    known = (ROOT / 'recorded/raw', ROOT / 'results/recorded_full_soc',
             ROOT / 'results/cluster/20261019', ROOT / 'waveforms')
    if path.parent in known:
        parents.extend(known)
    for parent in dict.fromkeys(parents):
        candidates.append(parent / path.name)
        candidates.extend(sorted(parent.glob(path.stem + '__来自_*' + path.suffix)))
    existing = False
    for candidate in dict.fromkeys(candidates):
        if candidate.is_file():
            existing = True
            if expected is None or digest(candidate) == expected:
                return candidate
    if existing:
        raise ValueError('recorded output content differs: ' + str(path))
    raise FileNotFoundError('missing recorded output: ' + str(path))
