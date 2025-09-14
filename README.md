# French Flashcards

Curated CSV datasets for generating printable flashcard PDFs (LaTeX + `flashcards` class) covering French vocabulary, grammar, conjugations and expressions.

## Repository Structure

```
contenu/
  conjugaisons/        # Verb tenses & moods
  vocabulaire/         # Words, verbs, prepositions, antonyms
  grammaire/           # Grammar reference & exercises
  expressions/         # Everyday phrases / conversation
csv-to-cards.awk       # AWK transform: CSV -> LaTeX flashcards document
Makefile               # Build & utility targets (see below)
data_manifest.yaml     # Metadata for every dataset
scripts/
  stats.py             # Rich statistics (JSON/text)
  validate.py          # Structural validation of CSV lines
```

### CSV Format
Each non-empty line: `prompt|answer` (exactly one `|`). You can embed minimal LaTeX markup in either side (e.g. `\textit{}` or small explanatory notes with `\\~\\`). Blank lines are ignored.

### Why `data_manifest.yaml`?
Single source of truth listing all decks with metadata (category, description, tags). Enables tooling, exporters (future Anki / web app), consistency checks, and richer filtering without filename scraping. Extend freely (e.g. add `difficulty`, `source`, `frequency_rank`).

## Make Targets

| Target        | Description |
|---------------|-------------|
| `make cards`  | Build all PDF flashcard sheets into `build/` |
| `make sources`| Generate only the intermediate `.tex` files |
| `make archive`| Create `cartes.txz` containing all PDFs |
| `make stats`  | Quick per-file counts (shell) |
| `make validate` | Basic structural validation (shell) |
| `make clean`  | Remove LaTeX aux files |
| `make distclean` | Also remove PDFs / tex / archive |

## Python Tooling
Optional richer tools:

```
python3 scripts/stats.py           # Text report
python3 scripts/stats.py --json    # JSON output
python3 scripts/validate.py        # Strict validation
```

(They auto-discover datasets under `contenu/`.)

## Adding a New Deck
1. Choose a category (or create a new folder under `contenu/`).
2. Create a UTF-8 CSV file with lines `prompt|answer`.
3. Run `make validate` to ensure structure is correct.
4. Add a corresponding entry to `data_manifest.yaml` (copy a similar block & edit fields).
5. Build PDFs: `make cards`.

## Naming Conventions
- Accents are preserved in filenames (works fine in git & LaTeX).
- Use hyphens `-` to separate multi-word concepts.
- Keep consistent `conjugaisons-<tense>.csv` pattern for conjugation decks.

## Future Ideas
- Export to Anki / CrowdAnki (`anki/` folder + exporter script).
- Frequency-based weighting stats.
- CI workflow (GitHub Actions) to run validation and publish PDFs as release assets.
- Lint for duplicate prompts or answers.

## License
Specify a license (e.g. MIT) if you plan to share publicly.

---
Contributions (new decks, corrections) welcome—keep lines clean and atomic.
