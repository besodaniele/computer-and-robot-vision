#import "@preview/scholia:0.1.0": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/hydra:0.6.3": hydra
#set page(paper: "a7", margin: (y: 4em), numbering: "1", header: context {
  if calc.odd(here().page()) {
    align(right, emph(hydra(1)))
  } else {
    align(left, emph(hydra(2)))
  }
  line(length: 100%)
})
// options: theme: "light" | "dark" · prose: "notes" | "book" · fonts: (…)
#show: scholia.with()
#cover("Computer and robot vision ", subtitle: "Course notes", author: "Daniele Besozzi", date: "A.A. 26/27")
#set heading(numbering: "1")
#set math.equation(numbering: "1.1")
#outline()
#pagebreak()

#set heading(numbering: "1.1")
= Image formation
#include "chapters/1.typ"
#pagebreak()
= Stereoscopy
#include "chapters/2.typ"
#counter(heading).update(0)
#set heading(numbering: numbly(
  "{1:A}", // use {level:format} to specify the format
  "{1:A}.{2}", // if format is not specified, arabic numbers will be used
  "Step {3}.", // here, we only want the 3rd level
))
#pagebreak()
#include "chapters/appendix.typ"