SRCS = $(wildcard e-maxx-eng/src/*/*.md)
TEXS = $(patsubst %.md, %.tex, $(SRCS))
LATEXMK_FLAGS = -pdf

.PHONY: all clean book

# Book
book: e-maxx.pdf misc/imgfetch.sh
travis: LATEXMK_FLAGS += -interaction=nonstopmode -auxdir=aux
travis: book

print: book

p: print

	bash misc/assemble.sh > $@

%.tex: %.md misc/fixes.pl
	perl misc/fixes.pl $< | pandoc -f markdown+header_attributes+raw_attribute+raw_html+tex_math_dollars -t latex -o $@

clean:
	@rm -f $(TEXS)
	@rm -f e-maxx.*
