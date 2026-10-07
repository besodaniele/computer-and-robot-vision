#import "@preview/scholia:0.1.0": *
// options: theme: "light" | "dark" · prose: "notes" | "book" · fonts: (…)
#show: scholia.with()
#set math.equation(numbering: "1.")
#cover("Computer and robot vision ", subtitle: "Course notes", author: "Daniele Besozzi", date: "A.A. 26/27")

#outline()
#pagebreak()

#set heading(numbering: "1.1")
= Image formation
#include "chapters/1.typ"