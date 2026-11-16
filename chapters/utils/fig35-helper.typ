#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Colorblind-safe palette & stroke styles
// ---------------------------------------------------------------------------
#let col-px       = rgb("#00897B") // Teal: input density p(x)
#let col-func     = rgb("#005AB5") // Vivid blue: nonlinear function g(x)
#let col-taylor   = rgb("#D81B60") // Magenta-pink: Taylor approx. & EKF Gaussian
#let col-py       = rgb("#D95F02") // Warm orange: true resulting density p(y)
#let col-py-gauss = rgb("#6A1B9A") // Deep purple: true Gaussian of p(y)
#let col-mean     = rgb("#C62828") // Crimson: true mean markers & lines
#let col-proj     = rgb("#334155") // Slate: dotted projection lines

#let st-px        = (paint: col-px, thickness: 1.4pt)
#let st-func      = (paint: col-func, thickness: 1.6pt)
#let st-taylor    = (paint: col-taylor, thickness: 1.5pt, dash: "dashed")
#let st-py        = (paint: col-py, thickness: 1.4pt)
#let st-py-gauss  = (paint: col-py-gauss, thickness: 1.5pt)
#let st-ekf-gauss = (paint: col-taylor, thickness: 1.5pt, dash: "dashed")
#let st-mean      = (paint: col-mean, thickness: 1.3pt)
#let st-ekf-mean  = (paint: col-taylor, thickness: 1.3pt, dash: "dashed")
#let st-proj      = (paint: col-proj, thickness: 1.1pt, dash: "dotted")

// ---------------------------------------------------------------------------
// 2. Mathematical functions, Taylor linearization & density transformation
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

// Exact derivative g'(x) for Taylor expansion at x = mu
#let g-nonlinear-deriv(x) = {
  let d-base = -0.14
  let u-bump = (x - 0.21) / 0.115
  let d-bump = 0.17 * calc.exp(-u-bump * u-bump) * (-2.0 * u-bump / 0.115)
  let s = 1.0 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  let d-step = -0.26 * s * (1.0 - s) / 0.028
  d-base + d-bump + d-step
}

// Computes true p(y), true Gaussian of p(y), and EKF linearized Gaussian
#let transform-ekf(fn, dfn, mu-x, sig-x, n-x: 200, n-y: 160, bw: 0.014) = {
  let dx = 1.0 / (n-x - 1)
  let xs = range(n-x).map(i => i * dx)
  let ys = xs.map(x => fn(x))
  let weights = xs.map(x => gaussian(x, mu-x, sig-x) * dx)

  let mean-y = range(n-x).fold(0.0, (acc, i) => acc + ys.at(i) * weights.at(i))
  let var-y = range(n-x).fold(0.0, (acc, i) => acc + calc.pow(ys.at(i) - mean-y, 2) * weights.at(i))
  let sig-y = calc.sqrt(var-y)

  let ekf-mean = fn(mu-x)
  let slope = dfn(mu-x)
  let ekf-sig = calc.abs(slope) * sig-x

  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-x).fold(0.0, (acc, i) => acc + weights.at(i) * gaussian(y, ys.at(i), bw))
  })
  let py-gauss = y-grid.map(y => gaussian(y, mean-y, sig-y))
  let ekf-gauss = y-grid.map(y => gaussian(y, ekf-mean, ekf-sig))

  // Compute maximum density across all 3 output curves so x-max never clips
  let max-py = calc.max(..py, ..py-gauss, ..ekf-gauss)

  (
    y-grid: y-grid,
    py: py,
    py-gauss: py-gauss,
    ekf-gauss: ekf-gauss,
    mean-y: mean-y,
    ekf-mean: ekf-mean,
    slope: slope,
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

#let swatch-fill(col) = rect(width: 12pt, height: 6pt, fill: col.transparentize(72%), stroke: 0.8pt + col)
#let swatch-line(st) = box(width: 12pt, height: 6pt, line(start: (0pt, 3pt), end: (12pt, 3pt), stroke: st))
#let swatch-x(col) = text(fill: col, weight: "bold", size: 7.5pt)[$times$]
#let swatch-o(col) = box(width: 6pt, height: 6pt, circle(radius: 2.3pt, stroke: 1.1pt + col, fill: white))

// Top-left plot: sideways p(y), Gaussian of p(y), and EKF Gaussian
#let plot-py-ekf(res) = {
  // Auto-scale horizontal axis so the tallest peak fills ~72% of the plot width
  let x-max = res.max-py * 1.38
  let y-grid = res.y-grid
  let py-pairs = range(y-grid.len()).map(i => (res.py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)
  let g-pairs = range(y-grid.len()).map(i => (res.py-gauss.at(i), y-grid.at(i)))
  let ekf-pairs = range(y-grid.len()).map(i => (res.ekf-gauss.at(i), y-grid.at(i)))

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
          plot.annotate({
            cetz.draw.line(
              ..py-poly,
              close: true,
              fill: col-py.transparentize(75%),
              stroke: none,
            )
          })
          plot.add(py-pairs, style: (stroke: st-py))
          plot.add(g-pairs, style: (stroke: st-py-gauss))
          plot.add(ekf-pairs, style: (stroke: st-ekf-gauss))

          // True mean of p(y)
          plot.add(((0.0, res.mean-y), (x-max * 0.92, res.mean-y)), style: (stroke: st-mean))
          plot.add(((0.0, res.mean-y),), mark: "x", mark-size: 0.16, mark-style: (stroke: st-mean))

          // Mean of EKF
          plot.add(((0.0, res.ekf-mean), (x-max * 0.92, res.ekf-mean)), style: (stroke: st-ekf-mean))
          plot.add(((0.0, res.ekf-mean),), mark: "o", mark-size: 0.15, mark-style: (stroke: (paint: col-taylor, thickness: 1.2pt), fill: white))
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-fill(col-py), [$p(y)$]),
        (swatch-line(st-py-gauss), [Gaussian of $p(y)$]),
        (swatch-line(st-mean), [Mean of $p(y)$]),
        (swatch-line(st-ekf-gauss), [EKF Gaussian]),
        (swatch-line(st-ekf-mean), [Mean of EKF]),
      )),
    )
  ]
}

// Top-right plot: g(x) and Taylor tangent line at x = mu
#let plot-gx-ekf(fn, mu-x, slope) = {
  let gy = fn(mu-x)
  let taylor(x) = gy + slope * (x - mu-x)

  let x-start = calc.max(0.0, mu-x + (1.0 - gy) / slope)
  let x-end = calc.min(1.0, mu-x + (0.0 - gy) / slope)

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
          plot.add(domain: (0, 1), samples: 140, style: (stroke: st-func), fn)
          plot.add(domain: (x-start, x-end), samples: 2, style: (stroke: st-taylor), taylor)
          plot.add(((mu-x, 0.0), (mu-x, gy), (0.0, gy)), style: (stroke: st-proj))
          plot.add(((mu-x, 0.0),), mark: "x", mark-size: 0.16, mark-style: (stroke: st-mean))
          plot.add(((0.0, gy),), mark: "o", mark-size: 0.15, mark-style: (stroke: (paint: col-taylor, thickness: 1.2pt), fill: white))
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-line(st-func), [Function $g(x)$]),
        (swatch-line(st-taylor), [Taylor approx.]),
        (swatch-x(col-mean), [Mean $mu$]),
        (swatch-o(col-taylor), [$g(mu)$]),
      )),
    )
  ]
}

// Bottom-right plot: input Gaussian density p(x) scaled cleanly to its own peak
#let plot-px-ekf(mu-x, sig-x) = {
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
          plot.add(
            domain: (0, 1),
            samples: 180,
            fill: true,
            style: (stroke: st-px, fill: col-px.transparentize(75%)),
            x => gaussian(x, mu-x, sig-x),
          )
          plot.add(((mu-x, 0.0), (mu-x, peak)), style: (stroke: st-mean))
          plot.add(((mu-x, 0.0),), mark: "x", mark-size: 0.16, mark-style: (stroke: st-mean))
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-fill(col-px), [$p(x)$]),
        (swatch-x(col-mean), [Mean $mu$]),
      )),
    )
  ]
}

// Framed subpanel (a) or (b)
#let subpanel(label, body) = {
  grid(
    columns: (auto, auto),
    column-gutter: 6pt,
    align: (top, top),
    text(weight: "bold", size: 9.5pt)[#label],
    box(
      stroke: 0.7pt + luma(40),
      inset: (x: 8pt, y: 7pt),
      body,
    ),
  )
}

// ---------------------------------------------------------------------------
// 4. Main exported figure function
// ---------------------------------------------------------------------------
#let fig-ekf-uncertainty(
  mu-x: 0.5,
  sig-high: 0.175,
  sig-low: 0.032,
  caption: auto,
) = {
  let res-a = transform-ekf(g-nonlinear, g-nonlinear-deriv, mu-x, sig-high, bw: 0.015)
  let res-b = transform-ekf(g-nonlinear, g-nonlinear-deriv, mu-x, sig-low, bw: 0.008)

  let fig-caption = if caption == auto [
    Dependency of approximation quality on uncertainty. Both Gaussians (lower right, teal) have the same mean and are passed through the same nonlinear function (upper right, blue). The higher uncertainty of the upper Gaussian in *(a)* produces a more distorted density of the resulting random variable (orange area in upper left graph) than the lower uncertainty in *(b)*. The solid purple lines in the upper left graphs show the Gaussians extracted from these densities. The dashed magenta lines represent the Gaussians generated by the linearization applied by the EKF.
  ] else {
    caption
  }

  figure(
    stack(
      dir: ttb,
      spacing: 10pt,
      // Panel (a): High uncertainty
      subpanel("(a)", grid(
        columns: (auto, auto),
        column-gutter: 10pt,
        row-gutter: 6pt,
        plot-py-ekf(res-a),
        plot-gx-ekf(g-nonlinear, mu-x, res-a.slope),
        [],
        plot-px-ekf(mu-x, sig-high),
      )),
      // Panel (b): Low uncertainty
      subpanel("(b)", grid(
        columns: (auto, auto),
        column-gutter: 10pt,
        row-gutter: 6pt,
        plot-py-ekf(res-b),
        plot-gx-ekf(g-nonlinear, mu-x, res-b.slope),
        [],
        plot-px-ekf(mu-x, sig-low),
      )),
    ),
    caption: fig-caption,
  )
}