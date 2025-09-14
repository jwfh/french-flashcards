#!/usr/bin/env python3
"""Compute statistics for flashcard CSV datasets.

Counts lines (non-empty) per file, aggregates by category (derived from path),
and emits a simple report. Optionally outputs JSON with --json.
"""
from __future__ import annotations
import argparse, json, pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONTENT = ROOT / 'contenu'


def iter_csv_files():
    for p in CONTENT.rglob('*.csv'):
        try:
            if p.stat().st_size == 0:
                continue
        except OSError:
            continue
        yield p


def count_lines(path: pathlib.Path) -> int:
    n = 0
    with path.open(encoding='utf-8') as f:
        for line in f:
            if line.strip():
                n += 1
    return n


def main(argv: list[str]):
    ap = argparse.ArgumentParser()
    ap.add_argument('--json', action='store_true', help='Output JSON instead of text')
    args = ap.parse_args(argv)

    rows = []
    cat_totals = {}
    grand = 0
    for csv_path in sorted(iter_csv_files()):
        rel = csv_path.relative_to(ROOT)
        parts = rel.parts
        # Expect contenu/<category>/...
        category = parts[1] if len(parts) > 2 else 'misc'
        cnt = count_lines(csv_path)
        grand += cnt
        cat_totals[category] = cat_totals.get(category, 0) + cnt
        rows.append({'file': str(rel), 'category': category, 'count': cnt})

    if args.json:
        out = {
            'total': grand,
            'by_category': cat_totals,
            'files': rows,
        }
        json.dump(out, sys.stdout, ensure_ascii=False, indent=2)
        return 0

    width = max(len(r['file']) for r in rows) if rows else 10
    print('Per-file counts:')
    for r in rows:
        print(f"{r['count']:5d}  {r['file']}")
    print('\nBy category:')
    for cat, c in sorted(cat_totals.items(), key=lambda x: -x[1]):
        print(f"{c:5d}  {cat}")
    print(f"\nTotal cards: {grand}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:]))
