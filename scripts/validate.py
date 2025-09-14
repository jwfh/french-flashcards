#!/usr/bin/env python3
"""Validate structure of flashcard CSV datasets.

Rules:
  * Non-empty lines must contain exactly one pipe (|) separating prompt & answer.
  * No trailing whitespace.
  * File must be UTF-8 decodable.

Exits non-zero if any violations are found. Prints a summary.
"""
from __future__ import annotations
import pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONTENT = ROOT / 'contenu'


def iter_csv_files():
    return sorted(CONTENT.rglob('*.csv'))


def validate_file(path: pathlib.Path):
    errors = []
    try:
        text = path.read_text(encoding='utf-8').splitlines()
    except UnicodeDecodeError as e:
        errors.append(f"{path}: Unicode error: {e}")
        return errors
    for i, line in enumerate(text, 1):
        if not line.strip():
            continue
        if line.rstrip() != line:
            errors.append(f"{path}:{i}: trailing whitespace")
        if line.count('|') != 1:
            errors.append(f"{path}:{i}: expected exactly one '|' (found {line.count('|')}) -> {line[:80]}")
    return errors


def main():
    all_errors = []
    for p in iter_csv_files():
        all_errors.extend(validate_file(p))
    if all_errors:
        print('Validation FAILED:', file=sys.stderr)
        for e in all_errors:
            print(e, file=sys.stderr)
        print(f"Total problems: {len(all_errors)}", file=sys.stderr)
        return 1
    print('Validation passed.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
