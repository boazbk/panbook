# panbook

Package for typesetting a book into PDF and HTML using pandoc and a bunch of other tools.
I am using it for my [Introduction to Theoretical Computer Science](https://introtcs.org) book.
This is at the moment at a very rough shape, but I hope that with help it can become a package that other people can use to typeset a book or lecture notes in markdown.

The philosophy behind this is that "it's better to give up control of document appearance than to have a source code cluttered with macros" which is somewhat the opposite of TeX's philosophy.

As such I tried to adhere to the following principles:

* Deviate as little as possible from (Pandoc's) standard markdown. The main additions are adding support for labels and references, and environments. 

* No latex commands outside math, and try to minimize custom macros even in math unless they help a lot in readability.

* It's better to use a filter than a macro. (For example, I have a filter to make an identifier using a  sequence of capital letters look good in math, and similarly to make a space before a paragraph that starts with bold text, etc..). 

The main deviations from standard markdown source are the follows:

Some syntax for theorem, definition, algorithms (with pseudocode formatting), etc.. environment. They can either be obtained using the quote markdown syntax, e.g. 

```
> ### {.theorem title="great theorem" #label}
Contents of the theorem continue until the first empty line.

```
or using Pandoc's syntax for blocks, e.g.:

```
::: {.definition title="great definition" #label}
contents of the definition

(can have empty lines)
:::
```

`[labelid](){.ref}` will create a reference of the form "Theorem 5.7" or "Section 2.2" with the corresponding hyperlink. The numbering is obtained from the aux file for the HTML so it will be consistent with the latex.
(Right now I am also using `[](){.eqref}` for references to equations, but I think I should change that to just normal references since we can find out if the object is an equation or not.)

There is also support for bibliography and references.

The main tools are used are:

*  [Pandoc](https://pandoc.org/) and  [panflute](http://scorreia.com/software/panflute/) 

*  The templates for the LaTeX and HTML versions are derived from   [Tufte LaTeX](https://tufte-latex.github.io/tufte-latex/), [Gitbook](https://www.gitbook.com/) and [Bookdown](https://bookdown.org/). 


This is inspired by clojure and lua scripts written by David Steurer to produce our [Sum of Squares lecture notes](https://sumofsquares.org)

### Todo's

There are many of them, but mainly to get this to the point that it can be easy to use for any project and not hardwired to my own setup for this particular book.

### Installing

Should add some instructions here. You can see the makefile for what we need. The Python scripts have some dependencies on various packages.  One aspects which might create pain in installation for a relatively minor benefit is that I use a custom color specs for the latex pseudocode package minted (mainly to give a different color to NAND - not so important), and to install it there is some setup python scripts. Should be easy to modify the latex source just not to use it. 


