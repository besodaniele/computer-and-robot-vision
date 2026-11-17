#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Colorblind-safe palette & stroke styles
// ---------------------------------------------------------------------------
#let col-px        = rgb("#00897B") // Teal: input density p(x)
#let col-func      = rgb("#005AB5") // Vivid blue: nonlinear function g(x)
#let col-ukf       = rgb("#D81B60") // Magenta-pink: UKF Gaussian, mean & g(sigma points)
#let col-py        = rgb("#D95F02") // Warm orange: true resulting density p(y)
#let col-py-gauss  = rgb("#6A1B9A") // Deep purple: true Gaussian of p(y)
#let col-mean      = rgb("#C62828") // Crimson: true mean & sigma-point markers
#let col-proj      = rgb("#334155") // Slate: dotted projection lines

#let st-px         = (paint: col-px, thickness: 1.4pt)
#let st-func       = (paint: col-func, thickness: 1.6pt)
#let st-py         = (paint: col-py, thickness: 1.4pt)
#let st-py-gauss   = (paint: col-py-gauss, thickness: 1.5pt)
#let st-ukf-gauss  = (paint: col-ukf, thickness: 1.5pt, dash: "dashed")
#let st-mean       = (paint: col-mean, thickness: 1.3pt)
#let st-ukf-mean   = (paint: col-ukf, thickness: 1.3pt, dash: "dashed")
#let st-proj       = (paint: col-proj, thickness: 1.0pt, dash: "dotted")

// ---------------------------------------------------------------------------
// 2. Mathematical functions, UKF sigma points & density transformation
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

// Computes true p(y), true Gaussian of p(y), and 1D UKF sigma-point approximation
#let transform-ukf(fn, mu-x, sig-x, lambda: 1.2, n-x: 200, n-y: 160, bw: 0.014) = {
  let dx = 1.0 / (n-x - 1)
  let xs = range(n-x).map(i => i * dx)
  let ys = xs.map(x => fn(x))
  let weights = xs.map(x => gaussian(x, mu-x, sig-x) * dx)

  // True pushforward mean and standard deviation
  let mean-y = range(n-x).fold(0.0, (acc, i) => acc + ys.at(i) * weights.at(i))
  let var-y = range(n-x).fold(0.0, (acc, i) => acc + calc.pow(ys.at(i) - mean-y, 2) * weights.at(i))
  let sig-y = calc.sqrt(var-y)

  // 2n + 1 = 3 sigma points for n = 1
  let spread = calc.sqrt(1.0 + lambda) * sig-x
  let sp-x = (mu-x - spread, mu-x, mu-x + spread)
  let sp-y = sp-x.map(x => fn(x))
  let w0 = lambda / (1.0 + lambda)
  let wi = 1.0 / (2.0 * (1.0 + lambda))
  let sp-w = (wi, w0, wi)

  // Reconstructed UKF mean and standard deviation from mapped sigma points
  let ukf-mean = range(3).fold(0.0, (acc, k) => acc + sp-w.at(k) * sp-y.at(k))
  let ukf-var = range(3).fold(0.0, (acc, k) => acc + sp-w.at(k) * calc.pow(sp-y.at(k) - ukf-mean, 2))
  let ukf-sig = calc.sqrt(ukf-var)

  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-x).fold(0.0, (acc, i) => acc + weights.at(i) * gaussian(y, ys.at(i), bw))
  })
  let py-gauss = y-grid.map(y => gaussian(y, mean-y, sig-y))
  let ukf-gauss = y-grid.map(y => gaussian(y, ukf-mean, ukf-sig))

  let max-py = calc.max(..py, ..py-gauss, ..ukf-gauss)

  (
    y-grid: y-grid,
    py: py,
    py-gauss: py-gauss,
    ukf-gauss: ukf-gauss,
    mean-y: mean-y,
    ukf-mean: ukf-mean,
    sp-x: sp-x,
    sp-y: sp-y,
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

// Top-left plot: sideways p(y), Gaussian of p(y), and UKF Gaussian
#let plot-py-ukf(res) = {
  let x-max = res.max-py * 1.38
  let y-grid = res.y-grid
  let py-pairs = range(y-grid.len()).map(i => (res.py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)
  let g-pairs = range(y-grid.len()).map(i => (res.py-gauss.at(i), y-grid.at(i)))
  let ukf-pairs = range(y-grid.len()).map(i => (res.ukf-gauss.at(i), y-grid.at(i)))

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
          plot.add(g-pairs, style: (stroke: st-py-gauss))
          plot.add(ukf-pairs, style: (stroke: st-ukf-gauss))

          // True mean of p(y): solid crimson line + x marker on y-axis
          plot.add(((0.0, res.mean-y), (x-max * 0.92, res.mean-y)), style: (stroke: st-mean))
          plot.add(((0.0, res.mean-y),), mark: "x", mark-size: 0.16, mark-style: (stroke: st-mean))

          // Mean of UKF: dashed magenta line + circle marker on y-axis
          plot.add(((0.0, res.ukf-mean), (x-max * 0.92, res.ukf-mean)), style: (stroke: st-ukf-mean))
          plot.add(((0.0, res.ukf-mean),), mark: "o", mark-size: 0.15, mark-style: (stroke: (paint: col-ukf, thickness: 1.2pt), fill: white))
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
        (swatch-line(st-ukf-gauss), [UKF Gaussian]),
        (swatch-line(st-ukf-mean), [Mean of UKF]),
      )),
    )
  ]
}

// Top-right plot: g(x) and 3 sigma points projected onto y-axis
#let plot-gx-ukf(fn, res) = {
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
          // Nonlinear function g(x)
          plot.add(domain: (0, 1), samples: 140, style: (stroke: st-func), fn)

          // Dotted projection lines for all 3 sigma points
          for k in range(3) {
            let sx = res.sp-x.at(k)
            let sy = res.sp-y.at(k)
            plot.add(((sx, 0.0), (sx, sy), (0.0, sy)), style: (stroke: st-proj))
          }

          // Sigma-point x markers on x-axis
          plot.add(
            res.sp-x.map(sx => (sx, 0.0)),
            mark: "x",
            mark-size: 0.16,
            mark-style: (stroke: st-mean),
            style: (stroke: none),
          )

          // Mapped g(sigma points) circles on y-axis
          plot.add(
            res.sp-y.map(sy => (0.0, sy)),
            mark: "o",
            mark-size: 0.15,
            mark-style: (stroke: (paint: col-ukf, thickness: 1.2pt), fill: white),
            style: (stroke: none),
          )
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-line(st-func), [Function $g(x)$]),
        (swatch-x(col-mean), [Sigma-points]),
        (swatch-o(col-ukf), [$g($sigma points$)$]),
      )),
    )
  ]
}

// Bottom-right plot: input Gaussian density p(x)
#let plot-px-ukf(mu-x, sig-x) = {
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

// ---------------------------------------------------------------------------
// 4. Main exported figure function
// ---------------------------------------------------------------------------
#let fig-ukf-linearization(
  mu-x: 0.5,
  sig-x: 0.115,
  lambda: 1.2,
  caption: auto,
) = {
  let res = transform-ukf(g-nonlinear, mu-x, sig-x, lambda: lambda, bw: 0.014)

  let fig-caption = if caption == auto [
    Illustration of linearization applied by the UKF. The filter first extracts $2n + 1$ weighted sigma points from the $n$-dimensional Gaussian ($n = 1$ in this example; crimson crosses on the $x$-axis). These sigma points are passed through the nonlinear function $g$ (blue). The linearized Gaussian (dashed magenta) is then extracted from the mapped sigma points (magenta circles on the vertical axis in the upper right plot). As for the EKF, the linearization incurs an approximation error, indicated by the mismatch between the linearized Gaussian (dashed magenta) and the Gaussian computed from the highly accurate Monte-Carlo estimate (solid purple).
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
        plot-py-ukf(res),
        plot-gx-ukf(g-nonlinear, res),
        [],
        plot-px-ukf(mu-x, sig-x),
      ),
    ),
    caption: fig-caption,
  )
}