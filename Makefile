SRCS = $(wildcard e-maxx-eng/src/*/*.md)
TEXS = $(patsubst %.md, %.tex, $(SRCS))
LATEXMK_FLAGS = -pdf

.PHONY: all clean book pdf pdf-twoside print

all: pdf

book: pdf

pdf: e-maxx.pdf

pdf-twoside: e-maxx-twoside.pdf

print: pdf-twoside

p: print

travis: LATEXMK_FLAGS += -interaction=nonstopmode -auxdir=aux
travis: pdf

e-maxx.pdf: $(TEXS)
	bash misc/assemble.sh oneside > e-maxx-gen.tex
	pdflatex -interaction=nonstopmode -halt-on-error e-maxx-gen.tex
	mv e-maxx-gen.pdf e-maxx.pdf

e-maxx-twoside.pdf: $(TEXS)
	bash misc/assemble.sh twoside > e-maxx-gen.tex
	pdflatex -interaction=nonstopmode -halt-on-error e-maxx-gen.tex
	mv e-maxx-gen.pdf e-maxx-twoside.pdf

%.tex: %.md misc/fixes.pl
	perl misc/fixes.pl $< | pandoc -f markdown+header_attributes+raw_attribute+raw_html+tex_math_dollars -t latex -o $@

clean:
	@rm -f $(TEXS)
	@rm -f e-maxx.*
	@rm -f e-maxx-gen.tex e-maxx-gen.log e-maxx-gen.aux e-maxx-gen.out
