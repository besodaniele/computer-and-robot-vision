#import "@preview/scholia:0.1.0": *
#import "@preview/numbly:0.1.0": numbly
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
#set heading(numbering: numbly(
  "{1:A}.", // use {level:format} to specify the format
  "{1:A}.{2}.", // if format is not specified, arabic numbers will be used
  "Step {3}.", // here, we only want the 3rd level
))

#include "chapters/appendix.typ"