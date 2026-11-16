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
#let col-proj     = rgb("#334155") // Slate: dotted projection & g(mu) circle

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

// Smooth nonlinear function matching the figure
#let g-nonlinear(x) = {
  let base = 0.67 - 0.14 * x
  let bump = 0.17 * calc.exp(-calc.pow((x - 0.21) / 0.115, 2))
  let step = -0.26 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  base + bump + step
}

// Exact derivative g'(x) for the first-order Taylor expansion at x = mu
#let g-nonlinear-deriv(x) = {
  let d-base = -0.14
  let u-bump = (x - 0.21) / 0.115
  let d-bump = 0.17 * calc.exp(-u-bump * u-bump) * (-2.0 * u-bump / 0.115)
  let s = 1.0 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  let d-step = -0.26 * s * (1.0 - s) / 0.028
  d-base + d-bump + d-step
}

// Computes true p(y), true Gaussian of p(y), and EKF linearized Gaussian
#let transform-ekf(fn, dfn, mu-x, sig-x, n-x: 150, n-y: 130, bw: 0.015) = {
  let dx = 1.0 / (n-x - 1)
  let xs = range(n-x).map(i => i * dx)
  let ys = xs.map(x => fn(x))
  let weights = xs.map(x => gaussian(x, mu-x, sig-x) * dx)

  // True pushforward mean and standard deviation
  let mean-y = range(n-x).fold(0.0, (acc, i) => acc + ys.at(i) * weights.at(i))
  let var-y = range(n-x).fold(0.0, (acc, i) => acc + calc.pow(ys.at(i) - mean-y, 2) * weights.at(i))
  let sig-y = calc.sqrt(var-y)

  // EKF first-order Taylor approximation: mu_ekf = g(mu), sig_ekf = |g'(mu)| * sig_x
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

  (
    y-grid: y-grid,
    py: py,
    py-gauss: py-gauss,
    ekf-gauss: ekf-gauss,
    mean-y: mean-y,
    ekf-mean: ekf-mean,
    slope: slope,
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
#let plot-py-ekf(res, x-max) = {
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
        x-tick-step: x-max / 4,
        y-tick-step: 0.1,
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$p(y)$],
        y-label: text(size: 7.5pt)[$y$],
        {
          // Shaded true density p(y)
          plot.annotate({
            cetz.draw.line(
              ..py-poly,
              close: true,
              fill: col-py.transparentize(75%),
              stroke: none,
            )
          })
          plot.add(py-pairs, style: (stroke: st-py))

          // True moment-matched Gaussian of p(y)
          plot.add(g-pairs, style: (stroke: st-py-gauss))

          // EKF linearized Gaussian approximation
          plot.add(ekf-pairs, style: (stroke: st-ekf-gauss))

          // True mean of p(y): solid crimson line + x marker on y-axis
          plot.add(((0.0, res.mean-y), (x-max, res.mean-y)), style: (stroke: st-mean))
          plot.add(((0.0, res.mean-y),), mark: "x", mark-size: 0.16, mark-style: (stroke: st-mean))

          // Mean of EKF: dashed magenta line + circle marker on y-axis
          plot.add(((0.0, res.ekf-mean), (x-max, res.ekf-mean)), style: (stroke: st-ekf-mean))
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

  // Clip Taylor line segment strictly inside [0, 1] x [0, 1]
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
        x-tick-step: 0.2,
        y-tick-step: 0.1,
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7.5pt)[$y = g(x)$])),
        {
          // Nonlinear function g(x)
          plot.add(domain: (0, 1), samples: 140, style: (stroke: st-func), fn)

          // First-order Taylor approximation tangent at (mu, g(mu))
          plot.add(domain: (x-start, x-end), samples: 2, style: (stroke: st-taylor), taylor)

          // Dotted projection lines from mu to g(mu)
          plot.add(((mu-x, 0.0), (mu-x, gy), (0.0, gy)), style: (stroke: st-proj))

          // Mean mu on x-axis and g(mu) circle on y-axis
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

// Bottom-right plot: input Gaussian density p(x)
#let plot-px-ekf(mu-x, sig-x) = {
  let y-top = 4.6
  let peak = gaussian(mu-x, mu-x, sig-x)
  box(width: 5.6cm, height: 2.55cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.55, 1.85),
        axis-style: "left",
        x-min: 0,
        x-max: 1,
        y-min: 0,
        y-max: y-top,
        x-tick-step: 0.2,
        y-tick-step: 0.8,
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7.5pt)[$p(x)$])),
        {
          plot.add(
            domain: (0, 1),
            samples: 140,
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

// ---------------------------------------------------------------------------
// 4. Main exported figure function
// ---------------------------------------------------------------------------
#let fig-ekf-linearization(caption: auto) = {
  let mu-x = 0.5
  let sig-x = 0.115
  let res = transform-ekf(g-nonlinear, g-nonlinear-deriv, mu-x, sig-x, bw: 0.015)

  let fig-caption = if caption == auto [
    Illustration of linearization applied by the EKF. Instead of passing the Gaussian through the nonlinear function $g$ (blue), it is passed through a linear approximation of $g$ (dashed magenta). The linear function is tangent to $g$ at the mean of the original Gaussian. The resulting Gaussian is shown as the dashed magenta line in the upper left graph. The linearization incurs an approximation error, as indicated by the mismatch between the linearized Gaussian (dashed magenta) and the Gaussian computed from the highly accurate Monte-Carlo estimate (solid purple).
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
        plot-py-ekf(res, 8.2),
        plot-gx-ekf(g-nonlinear, mu-x, res.slope),
        [],
        plot-px-ekf(mu-x, sig-x),
      ),
    ),
    caption: fig-caption,
  )
}