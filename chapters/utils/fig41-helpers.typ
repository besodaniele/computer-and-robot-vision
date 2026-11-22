#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Colorblind-safe palette & stroke styles
// ---------------------------------------------------------------------------
#let col-px      = rgb("#00897B") // Teal: continuous input density p(x)
#let col-hist-x  = rgb("#005AB5") // Vivid blue: histogram bins of X
#let col-func    = rgb("#005AB5") // Vivid blue: nonlinear function g(x)
#let col-py      = rgb("#D95F02") // Warm orange: continuous output density p(y)
#let col-hist-y  = rgb("#6A1B9A") // Deep purple: histogram bins of Y

#let st-px       = (paint: col-px, thickness: 1.5pt)
#let st-hist-x   = (paint: col-hist-x, thickness: 0.9pt)
#let st-func     = (paint: col-func, thickness: 1.6pt)
#let st-py       = (paint: col-py, thickness: 1.5pt)
#let st-hist-y   = (paint: col-hist-y, thickness: 0.9pt)

// ---------------------------------------------------------------------------
// 2. Mathematical functions & histogram pushforward computation
// ---------------------------------------------------------------------------
#let gaussian(x, mu, sigma) = {
  1.0 / (calc.sqrt(2.0 * calc.pi) * sigma) * calc.exp(-0.5 * calc.pow((x - mu) / sigma, 2))
}

// Nonlinear function g(x)
#let g-nonlinear(x) = {
  let base = 0.67 - 0.14 * x
  let bump = 0.17 * calc.exp(-calc.pow((x - 0.21) / 0.115, 2))
  let step = -0.26 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  base + bump + step
}

// Computes continuous p(x), X-histogram bins, continuous p(y), and Y-histogram bins
// by passing sub-points from every X bin through g(x)
#let compute-histogram-transform(
  fn,
  mu-x,
  sig-x,
  n-bins-x: 19,
  n-bins-y: 22,
  sub-per-bin: 16,
  n-y: 160,
  bw: 0.014,
) = {
  // 1. Histogram of X on [0, 1]
  let dx-bin = 1.0 / n-bins-x
  let bins-x = range(n-bins-x).map(i => {
    let x0 = i * dx-bin
    let x1 = (i + 1) * dx-bin
    let xm = 0.5 * (x0 + x1)
    let h = gaussian(xm, mu-x, sig-x)
    (x0: x0, x1: x1, height: h, mass: h * dx-bin)
  })

  // Normalize X bin masses so total probability = 1
  let total-mass = bins-x.fold(0.0, (acc, b) => acc + b.mass)
  let bins-x = bins-x.map(b => (
    x0: b.x0,
    x1: b.x1,
    height: b.height / total-mass,
    mass: b.mass / total-mass,
  ))

  // 2. Push multiple sub-points per X bin through g(x) into Y bins on [0, 1]
  let dy-bin = 1.0 / n-bins-y
  let y-counts = range(n-bins-y).map(_ => 0.0)

  for b in bins-x {
    let sub-w = b.mass / sub-per-bin
    for s in range(sub-per-bin) {
      let x-pt = b.x0 + (s + 0.5) / sub-per-bin * (b.x1 - b.x0)
      let y-pt = fn(x-pt)
      let idx = calc.clamp(int(calc.floor(y-pt / dy-bin)), 0, n-bins-y - 1)
      y-counts.at(idx) = y-counts.at(idx) + sub-w
    }
  }

  let bins-y = range(n-bins-y).map(j => (
    y0: j * dy-bin,
    y1: (j + 1) * dy-bin,
    height: y-counts.at(j) / dy-bin,
  ))

  // 3. High-resolution continuous pushforward density p(y)
  let n-fine = 220
  let dx-fine = 1.0 / (n-fine - 1)
  let xs-fine = range(n-fine).map(i => i * dx-fine)
  let ys-fine = xs-fine.map(x => fn(x))
  let w-fine = xs-fine.map(x => gaussian(x, mu-x, sig-x) * dx-fine)

  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-fine).fold(0.0, (acc, i) => acc + w-fine.at(i) * gaussian(y, ys-fine.at(i), bw))
  })

  let max-py = calc.max(..py, ..bins-y.map(b => b.height))

  (
    bins-x: bins-x,
    bins-y: bins-y,
    y-grid: y-grid,
    py: py,
    max-py: max-py,
  )
}

// ---------------------------------------------------------------------------
// 3. Legend & subplot builders
// ---------------------------------------------------------------------------
#let legend-box(items) = {
  box(
    fill: white.transparentize(6%),
    stroke: 0.6pt + luma(60),
    inset: (x: 5pt, y: 3.5pt),
    {
      set text(size: 7pt)
      grid(
        columns: (14pt, auto),
        column-gutter: 5pt,
        row-gutter: 3pt,
        align: (center + horizon, left + horizon),
        ..items.flatten()
      )
    },
  )
}

#let swatch-fill(col) = rect(width: 12pt, height: 6pt, fill: col.transparentize(72%), stroke: 0.9pt + col)
#let swatch-line(st) = box(width: 12pt, height: 6pt, line(start: (0pt, 3pt), end: (12pt, 3pt), stroke: st))

// Top-left plot: continuous p(y) + horizontal histogram bars of Y
#let plot-py-hist(res) = {
  let x-max = res.max-py * 1.38
  let y-grid = res.y-grid
  let py-pairs = range(y-grid.len()).map(i => (res.py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)

  box(width: 4.5cm, height: 4.3cm)[
    #cetz.canvas({
      plot.plot(
        size: (3.55, 3.55),
        axis-style: "left",
        x-min: 0,
        x-max: x-max,
        y-min: 0,
        y-max: 1,
        x-ticks: (x-max * 0.25, x-max * 0.5, x-max * 0.75, x-max),
        y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$p(y)$],
        y-label: text(size: 7.5pt)[$y$],
        {
          // Continuous shaded density p(y)
          plot.annotate({
            cetz.draw.line(
              ..py-poly,
              close: true,
              fill: col-py.transparentize(75%),
              stroke: none,
            )
          })
          plot.add(py-pairs, style: (stroke: st-py))

          // Horizontal histogram rectangles for non-empty Y bins
          plot.annotate({
            for b in res.bins-y {
              if b.height > 0.02 {
                cetz.draw.rect(
                  (0.0, b.y0),
                  (b.height, b.y1),
                  fill: col-hist-y.transparentize(82%),
                  stroke: st-hist-y,
                )
              }
            }
          })
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-fill(col-py), [$p(y)$]),
        (swatch-fill(col-hist-y), [Histogram]),
      )),
    )
  ]
}

// Top-right plot: nonlinear transformation y = g(x)
#let plot-gx-hist(fn) = {
  box(width: 5.6cm, height: 4.3cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.55, 3.55),
        axis-style: "left",
        x-min: 0,
        x-max: 1,
        y-min: 0,
        y-max: 1,
        x-ticks: (0.2, 0.4, 0.6, 0.8, 1.0),
        y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7.5pt)[$y = g(x)$])),
        {
          plot.add(domain: (0, 1), samples: 150, style: (stroke: st-func), fn)
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-line(st-func), [Function $g(x)$]),
      )),
    )
  ]
}

// Bottom-right plot: continuous p(x) + vertical histogram bins of X
#let plot-px-hist(mu-x, sig-x, bins-x) = {
  let peak = gaussian(mu-x, mu-x, sig-x)
  let y-max = peak * 1.48

  box(width: 5.6cm, height: 2.55cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.55, 1.85),
        axis-style: "left",
        x-min: 0,
        x-max: 1,
        y-min: 0,
        y-max: y-max,
        x-ticks: (0.2, 0.4, 0.6, 0.8, 1.0),
        y-ticks: (y-max * 0.2, y-max * 0.4, y-max * 0.6, y-max * 0.8, y-max),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7.5pt)[$p(x)$])),
        {
          // Continuous shaded density p(x)
          plot.add(
            domain: (0, 1),
            samples: 180,
            fill: true,
            style: (stroke: st-px, fill: col-px.transparentize(75%)),
            x => gaussian(x, mu-x, sig-x),
          )

          // Vertical histogram rectangles for non-empty X bins
          plot.annotate({
            for b in bins-x {
              if b.height > 0.02 {
                cetz.draw.rect(
                  (b.x0, 0.0),
                  (b.x1, b.height),
                  fill: col-hist-x.transparentize(82%),
                  stroke: st-hist-x,
                )
              }
            }
          })
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-fill(col-px), [$p(x)$]),
        (swatch-fill(col-hist-x), [Histogram]),
      )),
    )
  ]
}

// ---------------------------------------------------------------------------
// 4. Main exported figure function
// ---------------------------------------------------------------------------
#let fig-histogram-transform(
  mu-x: 0.5,
  sig-x: 0.115,
  n-bins-x: 19,
  n-bins-y: 22,
  caption: auto,
) = {
  let res = compute-histogram-transform(
    g-nonlinear,
    mu-x,
    sig-x,
    n-bins-x: n-bins-x,
    n-bins-y: n-bins-y,
  )

  let fig-caption = if caption == auto [
    Histogram representation of a continuous random variable. The teal shaded area in the lower right plot shows the density of the continuous random variable, $X$. The histogram approximation of this density is overlaid in blue . The random variable is passed through the function displayed in the upper right graph (blue) . The density (orange) and the histogram approximation (purple) of the resulting random variable, $Y$, are plotted in the upper left graph . The histogram of the transformed random variable was computed by passing multiple points from each histogram bin of $X$ through the nonlinear function .
  ] else {
    caption
  }

  figure(
    box(
      stroke: 0.7pt + luma(40),
      inset: (x: 8pt, y: 7pt),
      grid(
        columns: (auto, auto),
        column-gutter: 10pt,
        row-gutter: 6pt,
        plot-py-hist(res),
        plot-gx-hist(g-nonlinear),
        [],
        plot-px-hist(mu-x, sig-x, res.bins-x),
      ),
    ),
    caption: fig-caption,
  )
}