ifeq ($(OS),Windows_NT)
    GHOSTSCRIPT = gswin64c
else
    GHOSTSCRIPT = gs
endif

opts := -f markdown+fenced_divs-auto_identifiers --section-divs --katex

latex-book/%.tex: content/%.md book-filter.py content/metadata.yaml
	@echo "<<<LATEX-BOOK $*>>>"
	@pandoc -f markdown+smart+fenced_divs-auto_identifiers+backtick_code_blocks --preserve-tabs --section-divs  --biblatex -F book-filter.py   -o $@ $< content/metadata.yaml

html/%.html: content/%.md book-filter.py bookaux.yaml content/metadata.yaml book-template.html
		@echo "<<<HTML-BOOK $*>>>"
		@pandoc -f markdown+smart+fenced_divs+backtick_code_blocks --preserve-tabs  -F book-filter.py --mathjax --template book-template.html  -o $@ $< content/metadata.yaml

binaries/%.docx: content/%.md
		@echo "<<<WORD $*>>>"
		cd binaries && pandoc -f markdown+smart+fenced_divs+latex_macros+backtick_code_blocks   -o  ../$@ ../content/macros.tex ../content/msword.md ../$< ../content/metadata.yaml


lectures := $(patsubst content/%.md,%,$(wildcard content/lec*.md))




book-targets := $(foreach l,$(lectures),latex-book/$(l).tex)


html-targets := $(foreach l,$(lectures),html/$(l).html)

docx-targets := $(foreach l,$(lectures),binaries/$(l).docx)


.PHONY: aux-yaml all-html all-tex all-word book rename-book-parts compress-book split-book-to-handouts just-deploy deploy clean-html



aux-yaml:
	@echo "Preparing bookaux.yaml"
	python auxtoyaml.py "latex-book/"
	

all-html: aux-yaml $(html-targets) html/index.html

all-tex: $(book-targets)

all-word: $(docx-targets)

latex-book/lnotes_book.pdf: all-tex
	@echo "<<<PDF-BOOK WINDOWS>>>"
	cd latex-book && xelatex -quiet -shell-escape  lnotes_book.tex && Biber lnotes_book && xelatex -quiet -shell-escape  lnotes_book.tex

book: all-tex latex-book/lnotes_book.pdf all-html 

rename-book-parts:
	scripts/rename.sh

compress-book:
	  $(GHOSTSCRIPT)  \
	  -sDEVICE=pdfwrite \
	  -dPDFSETTINGS=/ebook \
	  -dDownsampleColorImages=true \
	  -dDownsampleGrayImages=true \
	  -dDownsampleMonoImages=true \
	  -dColorImageResolution=300 \
	  -dGrayImageResolution=300 \
	  -dMonoImageResolution=300 \
	  -dColorImageDownsampleThreshold=1.0 \
	  -dGrayImageDownsampleThreshold=1.0 \
	  -dMonoImageDownsampleThreshold=1.0 \
	  -dNOPAUSE -dQUIET -dBATCH  -dCompatibilityLevel=1.4 \
	  -sOutputFile=binaries/lnotes_book.pdf  latex-book/lnotes_book.pdf


split-book-to-handouts: latex-book/lnotes_book.pdf
	cd latex-book && \
	cp -f ../toc.yaml toc.yaml && \
	python ../splitchapters.py lnotes_book.pdf toc.yaml

	#rm -rf pdf-handout-split
	#mkdir pdf-handout-split
	#cd sejda-console-3.2.50 && \
	#bin/sejda-console splitbybookmarks -l 2 -z yes -o ../pdf-handout-split -f ../latex-book/lnotes_book.pdf -p "[BOOKMARK_NAME_STRICT]" && \
	#bin/sejda-console splitbybookmarks -l 1  -z yes --existingOutput skip -o ../pdf-handout-split -f ../latex-book/lnotes_book.pdf -p "[BOOKMARK_NAME_STRICT]"

just-deploy:
	scripts/deploy.sh

deploy: book all-word split-book-to-handouts rename-book-parts
	scripts/deploy.sh
