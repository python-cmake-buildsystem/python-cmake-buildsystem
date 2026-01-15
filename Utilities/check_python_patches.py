import os
import re
import requests
from packaging.version import Version, parse

PATCHES_DIR = os.path.join(os.path.dirname(__file__), '..', 'patches')
PYTHON_RELEASES_URL = 'https://www.python.org/api/v2/downloads/release/'

# Helper: get supported versions from CMakeLists.txt md5 variables
def get_supported_versions():
    cmake_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'CMakeLists.txt'))
    versions = set()
    with open(cmake_path, 'r', encoding='utf-8') as f:
        for line in f:
            m = re.match(r'set\(_download_(\d+)\.(\d+)\.(\d+)_md5', line)
            if m:
                minor = f"{m.group(1)}.{m.group(2)}"
                versions.add(minor)
    def version_key(v):
        major, minor = v.split('.')
        return (int(major), int(minor))
    return sorted(versions, key=version_key)

# Helper: get latest patch for a given minor version
def get_latest_patch_version(minor_version):
    # Query Python.org for all releases
    resp = requests.get(PYTHON_RELEASES_URL)
    resp.raise_for_status()
    data = resp.json()
    candidates = []
    # The API returns a list of releases, not a dict
    for rel in data:
        # Each rel should be a dict with 'name' key
        v = rel.get('name', '').lstrip('Python ').strip()
        if v.startswith(minor_version + '.'):
            try:
                candidates.append(parse(v))
            except Exception:
                continue
    if not candidates:
        return None
    return str(max(candidates))

# Helper: get all patch folders for a minor version
def get_patch_folders(minor_version):
    return [d for d in os.listdir(PATCHES_DIR) if d.startswith(minor_version + '.')]

def main():

    supported = get_supported_versions()
    # --- Update CI.yml and config.yml to use latest patch releases ---
    # Map: minor_version -> latest_patch_version
    latest_patches = {}
    for minor in supported:
        latest = get_latest_patch_version(minor)
        if latest:
            latest_patches[minor] = latest

    # Update .github/workflows/CI.yml
    ci_yml_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '.github', 'workflows', 'CI.yml'))
    if os.path.exists(ci_yml_path):
        with open(ci_yml_path, 'r', encoding='utf-8') as f:
            ci_lines = f.readlines()
        # Update python-version matrix
        for idx, line in enumerate(ci_lines):
            m = re.match(r'(\s*python-version:\s*)\[(.*?)\]', line)
            if m:
                orig_versions = re.findall(r'(\d+\.\d+\.\d+)', m.group(2))
                new_versions = []
                for v in orig_versions:
                    minor = '.'.join(v.split('.')[:2])
                    if minor in latest_patches:
                        new_versions.append(latest_patches[minor])
                    else:
                        new_versions.append(v)
                new_versions_str = ', '.join(new_versions)
                ci_lines[idx] = f'{m.group(1)}[{new_versions_str}]\n'
                break
        # Update job names containing python version
        version_pat = re.compile(r'(python-)(\d+\.\d+\.\d+)([-\w]*)')
        for idx, line in enumerate(ci_lines):
            def repl(m):
                minor = '.'.join(m.group(2).split('.')[:2])
                new_version = latest_patches.get(minor, m.group(2))
                return f'{m.group(1)}{new_version}{m.group(3)}'
            new_line = version_pat.sub(repl, line)
            if new_line != line:
                ci_lines[idx] = new_line
        with open(ci_yml_path, 'w', encoding='utf-8') as f:
            f.writelines(ci_lines)
        print(f"Updated python-version matrix and job names in {ci_yml_path}")

    # Update .circleci/config.yml
    circleci_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '.circleci', 'config.yml'))
    if os.path.exists(circleci_path):
        with open(circleci_path, 'r', encoding='utf-8') as f:
            circle_lines = f.readlines()
        # Replace all python_version: lines in workflows with latest patch
        for idx, line in enumerate(circle_lines):
            m = re.match(r'(\s*python_version:\s*)(\d+\.\d+\.\d+)', line)
            if m:
                minor = '.'.join(m.group(2).split('.')[:2])
                if minor in latest_patches:
                    new_line = f'{m.group(1)}{latest_patches[minor]}\n'
                    if circle_lines[idx] != new_line:
                        circle_lines[idx] = new_line
        # Update job names containing python version
        version_pat = re.compile(r'(python-)(\d+\.\d+\.\d+)([-\w]*)')
        for idx, line in enumerate(circle_lines):
            def repl(m):
                minor = '.'.join(m.group(2).split('.')[:2])
                new_version = latest_patches.get(minor, m.group(2))
                return f'{m.group(1)}{new_version}{m.group(3)}'
            new_line = version_pat.sub(repl, line)
            if new_line != line:
                circle_lines[idx] = new_line
        with open(circleci_path, 'w', encoding='utf-8') as f:
            f.writelines(circle_lines)
        print(f"Updated python_version fields and job names in {circleci_path}")
    updated = False
    supported = get_supported_versions()
    cmake_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'CMakeLists.txt'))
    with open(cmake_path, 'r', encoding='utf-8') as f:
        cmake_lines = f.readlines()

    for minor in supported:
        latest = get_latest_patch_version(minor)
        if not latest:
            continue
        # Check if CMakeLists.txt already has this version
        cmake_var = f'_download_{latest}_md5'
        if any(cmake_var in line for line in cmake_lines):
            continue

        # Get MD5 hash from the Python release page
        release_url = f'https://www.python.org/downloads/release/python-{latest.replace(".", "")}/'
        try:
            resp = requests.get(release_url)
            resp.raise_for_status()
            html = resp.text
            # Try to find the MD5 for the .tgz file in the files table
            # First, try a robust regex for the .tgz row and MD5
            pattern = rf'<tr[^>]*>.*?Python-{latest}\.tgz.*?<td[^>]*>.*?([a-fA-F0-9]{{32}}).*?</td>.*?</tr>'
            match = re.search(pattern, html, re.DOTALL)
            if not match:
                # Fallback: try to find the MD5 in a <tt> tag near the .tgz link
                pattern2 = rf'Python-{latest}\.tgz.*?([a-fA-F0-9]{{32}})'
                match2 = re.search(pattern2, html, re.DOTALL)
                if match2:
                    md5 = match2.group(1)
                else:
                    print(f"MD5 not found on release page for {latest}")
                    continue
            else:
                md5 = match.group(1)
        except Exception as e:
            print(f"Failed to fetch MD5 for {latest} from release page: {e}")
            continue

        # Find where to insert: after the last md5 line for the same minor version
        all_md5_lines = []
        md5_pattern = re.compile(r'set\(_download_(\d+)\.(\d+)\.(\d+)_md5')
        for idx, line in enumerate(cmake_lines):
            m = md5_pattern.match(line.strip())
            if m:
                all_md5_lines.append((int(m.group(1)), int(m.group(2)), int(m.group(3)), idx))
        major, minor_num = map(int, minor.split('.'))
        this_minor_lines = [t for t in all_md5_lines if (t[0], t[1]) == (major, minor_num)]
        if this_minor_lines:
            # Insert after the highest patch for this minor version
            insert_idx = max(this_minor_lines, key=lambda t: t[2])[3] + 1
        else:
            # If no md5 for this minor, insert after the last md5 for any earlier version
            earlier_lines = [t for t in all_md5_lines if (t[0], t[1]) < (major, minor_num)]
            if earlier_lines:
                insert_idx = max(earlier_lines, key=lambda t: (t[0], t[1], t[2]))[3] + 1
            else:
                # Otherwise, insert at the top after all comments
                insert_idx = 0
                for idx, line in enumerate(cmake_lines):
                    if not line.strip().startswith('#'):
                        insert_idx = idx
                        break
        new_line = f'set(_download_{latest}_md5 "{md5}")\n'
        cmake_lines.insert(insert_idx, new_line)
        print(f"Added {new_line.strip()} to CMakeLists.txt after line {insert_idx}")
        updated = True

    # --- Update default PYTHON_VERSION to latest with md5 variable ---
    md5_versions = []
    for line in cmake_lines:
        m = re.match(r'set\(_download_(\d+\.\d+\.\d+)_md5', line)
        if m:
            md5_versions.append(m.group(1))
    if md5_versions:
        latest_md5_version = str(max(md5_versions, key=lambda v: tuple(map(int, v.split('.')))))
        # Update set(PYTHON_VERSION ...) line
        for idx, line in enumerate(cmake_lines):
            if line.strip().startswith('set(PYTHON_VERSION '):
                old = cmake_lines[idx]
                cmake_lines[idx] = f'set(PYTHON_VERSION "{latest_md5_version}" CACHE STRING "The version of Python to build.")\n'
                print(f"Updated default PYTHON_VERSION in CMakeLists.txt: {old.strip()} -> {cmake_lines[idx].strip()}")
                updated = True
                break
    if updated:
        with open(cmake_path, 'w', encoding='utf-8') as f:
            f.writelines(cmake_lines)
    else:
        print("No new patch releases found.")

if __name__ == '__main__':
    main()
