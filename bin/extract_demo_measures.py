#!/usr/bin/env python3
"""
Extract Measure, Library, and ValueSet resources from demo measure bundles
and write them into the MCT backend configuration files.

Usage:
    python3 bin/extract_demo_measures.py [demo_measures_dir]

Default demo_measures_dir: demo_measures/
"""

import json
import os
import sys


DEMO_DIR = sys.argv[1] if len(sys.argv) > 1 else 'demo_measures'
MEASURES_OUT = 'java/src/main/resources/configuration/measures/measures-bundle.json'
TERMINOLOGY_OUT = 'java/src/main/resources/configuration/terminology/terminology-bundle.json'

EXTRACT_TYPES = {'Measure', 'Library', 'ValueSet'}


def main():
    if not os.path.isdir(DEMO_DIR):
        print(f'Error: directory not found: {DEMO_DIR}')
        sys.exit(1)

    seen = set()
    measures_entries = []  # Measure + Library
    terminology_entries = []  # ValueSet
    duplicates_skipped = 0
    files_processed = 0

    json_files = sorted(f for f in os.listdir(DEMO_DIR) if f.endswith('.json'))
    print(f'Found {len(json_files)} bundle files in {DEMO_DIR}/\n')

    for filename in json_files:
        filepath = os.path.join(DEMO_DIR, filename)
        with open(filepath, 'r') as f:
            bundle = json.load(f)

        entries = bundle.get('entry', [])
        file_counts = {'Measure': 0, 'Library': 0, 'ValueSet': 0}
        file_dups = 0

        for entry in entries:
            resource = entry.get('resource', {})
            rtype = resource.get('resourceType')
            if rtype not in EXTRACT_TYPES:
                continue

            rid = resource.get('id', resource.get('url', ''))
            key = (rtype, rid)

            if key in seen:
                file_dups += 1
                duplicates_skipped += 1
                continue

            seen.add(key)
            clean_entry = {'resource': resource}

            if rtype == 'ValueSet':
                terminology_entries.append(clean_entry)
            else:
                measures_entries.append(clean_entry)

            file_counts[rtype] += 1

        files_processed += 1
        parts = [f'{v} {k}' for k, v in file_counts.items() if v > 0]
        dup_note = f' ({file_dups} duplicates skipped)' if file_dups else ''
        print(f'  {filename}: {", ".join(parts)}{dup_note}')

    print(f'\n--- Summary ---')
    measure_count = sum(1 for e in measures_entries if e['resource']['resourceType'] == 'Measure')
    library_count = sum(1 for e in measures_entries if e['resource']['resourceType'] == 'Library')
    valueset_count = len(terminology_entries)
    print(f'Files processed: {files_processed}')
    print(f'Measures:  {measure_count}')
    print(f'Libraries: {library_count}')
    print(f'ValueSets: {valueset_count}')
    print(f'Duplicates skipped: {duplicates_skipped}')

    # Write measures bundle (Measure + Library)
    measures_bundle = {
        'resourceType': 'Bundle',
        'type': 'collection',
        'entry': measures_entries
    }
    os.makedirs(os.path.dirname(MEASURES_OUT), exist_ok=True)
    with open(MEASURES_OUT, 'w') as f:
        json.dump(measures_bundle, f, indent=2)
    measures_size = os.path.getsize(MEASURES_OUT)
    print(f'\nWrote {MEASURES_OUT} ({measures_size / 1024 / 1024:.1f} MB, {len(measures_entries)} entries)')

    # Write terminology bundle (ValueSet)
    terminology_bundle = {
        'resourceType': 'Bundle',
        'type': 'collection',
        'entry': terminology_entries
    }
    os.makedirs(os.path.dirname(TERMINOLOGY_OUT), exist_ok=True)
    with open(TERMINOLOGY_OUT, 'w') as f:
        json.dump(terminology_bundle, f, indent=2)
    terminology_size = os.path.getsize(TERMINOLOGY_OUT)
    print(f'Wrote {TERMINOLOGY_OUT} ({terminology_size / 1024 / 1024:.1f} MB, {len(terminology_entries)} entries)')


if __name__ == '__main__':
    main()
