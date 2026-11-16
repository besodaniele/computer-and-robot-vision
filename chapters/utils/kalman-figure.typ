#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// 1D Gaussian PDF
#let gaussian(x, mu, var) = {
  1 / calc.sqrt(2 * calc.pi * var) * calc.exp(-((x - mu) * (x - mu)) / (2 * var))
}

// Colorblind-safe palette & stroke styles
#let col-belief      = rgb("#005AB5") // Vivid blue: active / resulting belief
#let col-measurement = rgb("#DC3220") // Vermilion red: new measurement
#let col-prior       = rgb("#7A869A") // Muted slate: prior belief
#let col-prior-meas  = rgb("#E07A5F") // Soft coral (dashed): prior measurement

#let st-belief      = (paint: col-belief, thickness: 1.6pt)
#let st-measurement = (paint: col-measurement, thickness: 1.6pt)
#let st-prior       = (paint: col-prior, thickness: 1.0pt)
#let st-prior-meas  = (paint: col-prior-meas, thickness: 1.0pt, dash: "dashed")

// Legend line swatch
#let swatch(stroke-style, label) = box[
  #box(width: 14pt, height: 6pt, baseline: 1pt, line(length: 14pt, stroke: stroke-style))
  #h(3pt)#label
]

// Single subplot panel (a)–(f)
#let kf-panel(label, curves, x-max: 30, y-max: 0.25) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 4pt,
    align: (top, top),
    text(weight: "bold", size: 9.5pt)[#label],
    {
      set text(size: 6.5pt)
      cetz.canvas({
        plot.plot(
          size: (4.9, 3.35),
          x-min: 0,
          x-max: x-max,
          y-min: 0,
          y-max: y-max,
          x-tick-step: 5,
          y-tick-step: 0.05,
          x-label: none,
          y-label: none,
          {
            for c in curves {
              plot.add(
                domain: (0, x-max),
                samples: 200,
                style: (stroke: c.stroke),
                x => gaussian(x, c.mu, c.var),
              )
            }
          },
        )
      })
    },
  )
}

// Exported figure function (defaults match the original simulation)
#let fig-kalman-filter(
  mu0: 8.0,
  var0: 16.0,
  z1: 6.0,
  var-z1: 4.0,
  u: 15.0,
  var-u: 9.0,
  z2: 25.0,
  var-z2: 9.0,
  caption: auto,
) = {
  // Step 1: Integrate first measurement z1
  let k1 = var0 / (var0 + var-z1)
  let mu1 = mu0 + k1 * (z1 - mu0)
  let var1 = (1 - k1) * var0

  // Step 2: Motion update to the right by u
  let mu2-pred = mu1 + u
  let var2-pred = var1 + var-u

  // Step 3: Integrate second measurement z2
  let k2 = var2-pred / (var2-pred + var-z2)
  let mu2 = mu2-pred + k2 * (z2 - mu2-pred)
  let var2 = (1 - k2) * var2-pred

  let fig-caption = if caption == auto [
    Illustration of Kalman filters: *(a)* initial belief (blue), *(b)* a measurement (red) with the associated uncertainty alongside the prior belief (gray), *(c)* belief after integrating the measurement into the belief using the Kalman filter algorithm (blue), *(d)* belief after motion to the right (blue), which introduces uncertainty, *(e)* a new measurement (red) with associated uncertainty, and *(f)* the resulting belief (blue).
  ] else {
    caption
  }

  figure(
    block(width: 13.4cm)[
      #align(center)[
        #set text(size: 8pt)
        #swatch(st-belief)[Active / updated belief]
        #h(10pt)
        #swatch(st-measurement)[New measurement]
        #h(10pt)
        #swatch(st-prior)[Prior belief]
        #h(10pt)
        #swatch(st-prior-meas)[Prior measurement]
      ]
      #v(4pt)
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 18pt,
        row-gutter: 12pt,
        // (a) Initial belief
        kf-panel("(a)", (
          (mu: mu0, var: var0, stroke: st-belief),
        )),
        // (b) Measurement with associated uncertainty
        kf-panel("(b)", (
          (mu: mu0, var: var0, stroke: st-prior),
          (mu: z1, var: var-z1, stroke: st-measurement),
        )),
        // (c) Belief after integrating the measurement
        kf-panel("(c)", (
          (mu: mu0, var: var0, stroke: st-prior),
          (mu: z1, var: var-z1, stroke: st-prior-meas),
          (mu: mu1, var: var1, stroke: st-belief),
        )),
        // (d) Belief after motion to the right
        kf-panel("(d)", (
          (mu: mu1, var: var1, stroke: st-prior),
          (mu: mu2-pred, var: var2-pred, stroke: st-belief),
        )),
        // (e) New measurement with associated uncertainty
        kf-panel("(e)", (
          (mu: mu2-pred, var: var2-pred, stroke: st-prior),
          (mu: z2, var: var-z2, stroke: st-measurement),
        )),
        // (f) Resulting belief
        kf-panel("(f)", (
          (mu: mu2-pred, var: var2-pred, stroke: st-prior),
          (mu: z2, var: var-z2, stroke: st-prior-meas),
          (mu: mu2, var: var2, stroke: st-belief),
        )),
      )
    ],
    caption: fig-caption,
  )
}