e-maxx-eng algorithms book
==========================

[![Build Status](https://travis-ci.org/algmyr/e-maxx-eng-book.svg?branch=master)](https://travis-ci.org/algmyr/e-maxx-eng-book)

Scripts to build the articles in the https://github.com/e-maxx-eng/e-maxx-eng project into book form. A preview can be found at: http://algmyr.se/upload/e-maxx.pdf

Prerequisites
-------------

* some LaTeX distribution
* pandoc
* perl
* bash
* grep, sed, ...
* wget
* make

Build process
-------------

Clone or update the submodule using

    git submodule update --init --recursive --remote  # If first time
    git submodule update --recursive --remote         # Otherwise

then

    bash misc/imgfetch.sh
    make

Page layout
-----------

Two layouts are available for easy use: `oneside` and `twoside`.

* `oneside` — normal PDF output, good for screen reading.
* `twoside` — print-friendly PDF output, good for book-style double-sided printing.

### Build commands

Use the script directly to generate the assembled LaTeX file:

    bash misc/assemble.sh oneside > e-maxx-gen.tex
    bash misc/assemble.sh twoside > e-maxx-gen.tex

Then compile with:

    pdflatex -interaction=nonstopmode -halt-on-error e-maxx-gen.tex

Or use the provided Makefile targets:

    make pdf         # normal single-sided PDF output (e-maxx.pdf)
    make print       # two-sided print-friendly PDF output (e-maxx-twoside.pdf)

If you want the default target, use:

    make

### oneside
Normal output with symmetric margins and fewer blank pages.

### twoside
Print-friendly output with two-sided layout, asymmetric inner/outer margins, and proper chapter/page placement for printing.
