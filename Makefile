# Makefile for the LaTeX documentation

# --- CONFIGURATION VARIABLES ---
DELIV_NAME = BOM_Report_Proposal_Anh_Tu_DUONG
MAIN_BASE  = main
BIB_FILES  = $(wildcard *.bib)

# --- SYSTEM COMMANDS ---
LATEX      = pdflatex
BIBTEX     = bibtex

# --- DIRECTORIES & FILES ---
FINAL_PDF  = $(DELIV_NAME).pdf
MAIN_SRC   = $(MAIN_BASE).tex
TEX_FILES  = $(wildcard sections/*.tex) $(wildcard style/*.tex)
BUILD_PDF  = build/$(MAIN_BASE).pdf

# --- RULES ---
all: $(FINAL_PDF)

$(FINAL_PDF): $(BUILD_PDF)
	@echo "--- Copying and renaming PDF to $(FINAL_PDF) ---"
	@cp $(BUILD_PDF) $(FINAL_PDF)
	@echo "--- Build complete. Final document is $(FINAL_PDF) ---"

# The main build rule for creating the PDF inside the 'build/' directory.
$(BUILD_PDF): $(MAIN_SRC) $(TEX_FILES) $(BIB_FILES)
	@echo "--- [1/4] Compiling LaTeX (for BibTeX) ---"
	@$(LATEX) -output-directory=build $(MAIN_SRC)
	
	@# --- MODIFIED BIBTEX STEP ---
	@# Only run BibTeX if the .aux file contains citation keys.
	@if grep -q '\\citation' build/$(MAIN_BASE).aux; then \
		echo "--- [2/4] Running BibTeX ---"; \
		cd build && $(BIBTEX) $(MAIN_BASE) && cd ..; \
	else \
		echo "--- [2/4] Skipping BibTeX (no citations found) ---"; \
	fi

	@echo "--- [3/4] Compiling LaTeX (to include bibliography) ---"
	@$(LATEX) -output-directory=build $(MAIN_SRC)

	@echo "--- [4/4] Compiling LaTeX (to fix cross-references) ---"
	@$(LATEX) -output-directory=build $(MAIN_SRC)

# Rule to clean up EVERYTHING.
clean:
	@echo "--- Cleaning up project directory ---"
	@rm -rf build
	@rm -f $(FINAL_PDF)
	@echo "Done."

# This rule ensures the 'build/' directory exists before compiling.
$(BUILD_PDF): | build

build:
	@mkdir -p build

.PHONY: all clean
