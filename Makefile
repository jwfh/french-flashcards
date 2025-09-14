################################################################################
# Build system for French flashcard decks
#
# Automatically discovers non-empty CSV content files under contenu/ (recursively)
# and produces one PDF per CSV using the LaTeX flashcards class via awk -> tex.
#
# Added convenience targets:
#   make cards        Build all PDFs (alias: all)
#   make sources      Generate all intermediate .tex files
#   make archive      Tar.xz of all PDFs
#   make stats        Show per-file card counts
#   make validate     Basic structural validation of CSV lines
#   make clean        Remove build artefacts
#   make distclean    Also remove PDFs
################################################################################

# Find CSV files (relative paths, filtered for non-empty) – portable GNU make style.
CSV_FILES := $(shell find contenu -type f -name '*.csv' -exec sh -c '[ $$(wc -l < "{}") -gt 0 ]' \; -print | sort)

# Remove prefix & suffix to get logical deck id (e.g. contenu/conjugaisons/conjugaisons-présent.csv -> conjugaisons/conjugaisons-présent)
DECK_IDS := $(patsubst contenu/%.csv,%,$(CSV_FILES))

# Escape path separators for output filenames ( / -> __ )
OUTPUT_STEMS := $(foreach d,$(DECK_IDS),$(subst /,__,$(d)))

TEX_FILES := $(addprefix build/,$(addsuffix .tex,$(OUTPUT_STEMS)))
PDF_FILES := $(addprefix build/,$(addsuffix .pdf,$(OUTPUT_STEMS)))

.PHONY: all cards sources archive stats validate clean distclean publication

all: cards
cards: ${PDF_FILES}
sources: ${TEX_FILES}

# Pattern rule helper: map build/<stem>.tex back to original CSV path
# We store a mapping by reconstructing path: reverse of __ -> /

build/%.tex: csv-to-cards.awk
	@mkdir -p build
	@stem="$*"; \
	orig_path=$$(echo $$stem | sed 's|__|/|g'); \
	orig_csv="contenu/$$orig_path.csv"; \
	echo "[AWK] $$orig_csv -> $@"; \
	gawk -f csv-to-cards.awk $$orig_csv > $@

build/%.pdf: build/%.tex
	@echo "[PDF] $<"; \
	pdflatex -interaction=nonstopmode -output-directory build $< >/dev/null

archive publication: cards
	tar cJvf cartes.txz ${PDF_FILES}

stats:
	@echo "Deck statistics:"; \
	for f in ${CSV_FILES}; do \
		count=$$(grep -cv '^$$' $$f); \
		printf '%4d  %s\n' $$count $$f; \
	done | sort -nr

validate:
	@echo "Validating CSV structure (prompt|answer per non-empty line)..."; \
	failed=0; \
	while IFS= read -r f; do \
		while IFS= read -r line; do \
			[ -z "$$line" ] && continue; \
			if [ $$(printf '%s' "$$line" | awk -F'|' '{print NF}') -ne 2 ]; then \
				printf 'Invalid (not 2 fields) in %s: %s\n' "$$f" "$$line"; failed=1; \
			fi; \
			case "$$line" in *' '|) printf 'Trailing space in %s: %s\n' "$$f" "$$line"; failed=1;; esac; \
		done < $$f; \
	done <<EOF
${CSV_FILES}
EOF
	@[ $$failed -eq 0 ] && echo "Validation passed." || (echo "Validation FAILED"; exit 1)

clean:
	rm -f build/*.aux build/*.log build/*.synctex.gz build/*.out || true

distclean: clean
	rm -f build/*.pdf build/*.tex cartes.txz || true

# Ensure build dir exists for phony targets that don't trigger rules
build:
	@mkdir -p build