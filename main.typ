#import "@preview/scholia:0.1.0": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/hydra:0.6.3": hydra
#import "@preview/lovelace:0.3.1": *
#set page(paper: "a7", margin: (y: 4em), numbering: "1", header: context {
  if calc.odd(here().page()) {
    align(right, emph(hydra(1)))
  } else {
    align(left, emph(hydra(2)))
  }
  line(length: 100%)
})
// options: theme: "light" | "dark" · prose: "notes" | "book" · fonts: (…)
#show: scholia.with(theme: "light")
#cover("Computer and robot vision ", subtitle: "Course notes", author: "Daniele Besozzi", date: "A.A. 26/27")
#set math.equation(numbering: (n, ..) => {
  numbering("(1.1)", counter(heading).get().first(), n)
})
#set figure(numbering: (n, ..) => {
  numbering("1.1", counter(heading).get().first(), n)
})

#show figure.caption: it => {
  let pattern = "^[^:]+" + sym.space.nobreak + "[\d.]+"
  show regex(pattern): strong
  // show regex(pattern): set text(weight: "bold")
  // show regex(pattern): set text(style: "italic")
  it
}
#show heading.where(level: 1): it => {
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  it
}
#outline(depth:3)
#pagebreak()

#set heading(numbering: "1.1")
= Image formation
#include "chapters/1.typ"
#pagebreak()
= Stereoscopy
#include "chapters/2.typ"
#pagebreak()
= Bayesian filtering
#include "chapters/3.typ"
#pagebreak()

#counter(heading).update(0)
#set heading(numbering: numbly(
  "{1:A}", // use {level:format} to specify the format
  "{1:A}.{2}", // if format is not specified, arabic numbers will be used
  "Step {3}.", // here, we only want the 3rd level
))
#set math.equation(numbering: (n, ..) => {
  numbering("(A.1)", counter(heading).get().first(), n)
})
#set figure(numbering: (n, ..) => {
  numbering("A.1", counter(heading).get().first(), n)
})
#show figure.where(kind: "frame"): set figure(
	numbering: n => numbering("A.1", counter(heading).get().first(), n),
)

#include "chapters/appendix.typ"
