#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot
// ---------------------------------------------------------------------------
// 1. Colorblind-safe palette & stroke styles
// ---------------------------------------------------------------------------
#let col-px       = rgb("#00897B") // Teal: input density p(x)
#let col-func     = rgb("#005AB5") // Vivid blue: transformation g(x)
#let col-py       = rgb("#D95F02") // Warm orange: resulting density p(y)
#let col-py-gauss = rgb("#7B1FA2") // Deep purple: Gaussian approximation of p(y)
#let col-mean     = rgb("#C62828") // Crimson: mean markers and mean lines
#let col-proj     = rgb("#334155") // Slate: dotted projection & g(mu) circle

#let st-px       = (paint: col-px, thickness: 1.4pt)
#let st-func     = (paint: col-func, thickness: 1.6pt)
#let st-py       = (paint: col-py, thickness: 1.4pt)
#let st-py-gauss = (paint: col-py-gauss, thickness: 1.5pt)
#let st-mean     = (paint: col-mean, thickness: 1.3pt)
#let st-proj     = (paint: col-proj, thickness: 1.1pt, dash: "dotted")

// ---------------------------------------------------------------------------
// 2. Mathematical functions & numerical density transformation
// ---------------------------------------------------------------------------
#let gaussian(x, mu, sigma) = {
  1.0 / (calc.sqrt(2.0 * calc.pi) * sigma) * calc.exp(-0.5 * calc.pow((x - mu) / sigma, 2))
}

// Panel (a): linear function y = a*x + b
#let g-linear(x) = 0.78 - 0.56 * x

// Panel (b): smooth nonlinear function matching Figure 3.3(b)
#let g-nonlinear(x) = {
  let base = 0.67 - 0.14 * x
  let bump = 0.17 * calc.exp(-calc.pow((x - 0.21) / 0.115, 2))
  let step = -0.26 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  base + bump + step
}

// Computes p(y), E[Y], Std[Y], and Gaussian moment-match on a uniform y-grid
#let transform-density(fn, mu-x, sig-x, n-x: 150, n-y: 130, bw: 0.015) = {
  let dx = 1.0 / (n-x - 1)
  let xs = range(n-x).map(i => i * dx)
  let ys = xs.map(x => fn(x))
  let weights = xs.map(x => gaussian(x, mu-x, sig-x) * dx)

  // Output mean and standard deviation
  let mean-y = range(n-x).fold(0.0, (acc, i) => acc + ys.at(i) * weights.at(i))
  let var-y = range(n-x).fold(0.0, (acc, i) => acc + calc.pow(ys.at(i) - mean-y, 2) * weights.at(i))
  let sig-y = calc.sqrt(var-y)

  // KDE-smoothed pushforward density p(y) and moment-matched Gaussian
  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-x).fold(0.0, (acc, i) => acc + weights.at(i) * gaussian(y, ys.at(i), bw))
  })
  let py-gauss = y-grid.map(y => gaussian(y, mean-y, sig-y))

  (
    y-grid: y-grid,
    py: py,
    py-gauss: py-gauss,
    mean-y: mean-y,
    sig-y: sig-y,
  )
}

// ---------------------------------------------------------------------------
// 3. Legend & subplot builders
// ---------------------------------------------------------------------------
#let legend-box(items) = {
  box(
    fill: white.transparentize(8%),
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

// Top-left plot: sideways p(y) vs y
#let plot-py(y-grid, py, mean-y, x-max, py-gauss: none, show-gauss: false) = {
  let py-pairs = range(y-grid.len()).map(i => (py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)

  box(width: 4.3cm, height: 4.1cm)[
    #cetz.canvas({
      plot.plot(
        size: (3.35, 3.35),
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
          // Shaded p(y) region + border
          plot.annotate({
            cetz.draw.line(
              ..py-poly,
              close: true,
              fill: col-py.transparentize(75%),
              stroke: none,
            )
          })

          plot.add(py-pairs, style: (stroke: st-py))

          // Optional Gaussian approximation of p(y)
          if show-gauss and py-gauss != none {
            let g-pairs = range(y-grid.len()).map(i => (py-gauss.at(i), y-grid.at(i)))
            plot.add(g-pairs, style: (stroke: st-py-gauss))
          }

          // Mean of p(y) horizontal line + x marker on y-axis
          plot.add(((0.0, mean-y), (x-max, mean-y)), style: (stroke: st-mean))
          plot.add(((0.0, mean-y),), mark: "x", mark-size: 0.16, mark-style: (stroke: st-mean))
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box(
        if show-gauss {
          (
            (swatch-fill(col-py), [$p(y)$]),
            (swatch-line(st-py-gauss), [Gaussian of $p(y)$]),
            (swatch-line(st-mean), [Mean of $p(y)$]),
          )
        } else {
          (
            (swatch-fill(col-py), [$p(y)$]),
            (swatch-line(st-mean), [Mean of $p(y)$]),
          )
        },
      ),
    )
  ]
}

// Top-right plot: transformation y = g(x)
#let plot-gx(fn, mu-x, func-label, show-gmu-legend: false) = {
  let gy = fn(mu-x)
  box(width: 5.5cm, height: 4.1cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.45, 3.35),
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
        y-label: text(size: 7.5pt)[$y = g(x)$],
        {
          // Curve y = g(x)
          plot.add(domain: (0, 1), samples: 140, style: (stroke: st-func), fn)

          // Dotted projection from x = mu up to (mu, g(mu)) and left to y-axis
          plot.add(((mu-x, 0.0), (mu-x, gy), (0.0, gy)), style: (stroke: st-proj))

          // Mean mu marker on x-axis and g(mu) circle on y-axis
          plot.add(((mu-x, 0.0),), mark: "x", mark-size: 0.16, mark-style: (stroke: st-mean))
          plot.add(((0.0, gy),), mark: "o", mark-size: 0.15, mark-style: (stroke: (paint: col-proj, thickness: 1.2pt), fill: white))
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box(
        if show-gmu-legend {
          (
            (swatch-line(st-func), func-label),
            (swatch-x(col-mean), [Mean $mu$]),
            (swatch-o(col-proj), [$g(mu)$]),
          )
        } else {
          (
            (swatch-line(st-func), func-label),
            (swatch-x(col-mean), [Mean $mu$]),
          )
        },
      ),
    )
  ]
}

// Bottom-right plot: input density p(x)
#let plot-px(mu-x, sig-x, mean-label) = {
  let y-top = 4.6
  let peak = gaussian(mu-x, mu-x, sig-x)
  box(width: 5.5cm, height: 2.55cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.45, 1.85),
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
        y-label: text(size: 7.5pt)[$p(x)$],
        {
          plot.add(
            domain: (0, 1),
            samples: 140,
            fill: true,
            style: (stroke: st-px, fill: col-px.transparentize(75%)),
            x => gaussian(x, mu-x, sig-x),
          )
          // Vertical line at mean mu + x marker on x-axis
          plot.add(((mu-x, 0.0), (mu-x, y-top)), style: (stroke: st-mean))
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
        (swatch-x(col-mean), mean-label),
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
#let fig-gaussian-transform() = {
  let mu-x = 0.5
  let sig-x = 0.115

  let res-a = transform-density(g-linear, mu-x, sig-x, bw: 0.01)
  let res-b = transform-density(g-nonlinear, mu-x, sig-x, bw: 0.015)

  figure(
    stack(
      dir: ttb,
      spacing: 10pt,
      // Panel (a): Linear transformation
      subpanel("(a)", grid(
        columns: (auto, auto),
        column-gutter: 10pt,
        row-gutter: 6pt,
        plot-py(res-a.y-grid, res-a.py, res-a.mean-y, 7.8),
        plot-gx(g-linear, mu-x, [$y = a x + b$]),
        [],
        plot-px(mu-x, sig-x, [Mean of $p(x)$]),
      )),
      // Panel (b): Nonlinear transformation
      subpanel("(b)", grid(
        columns: (auto, auto),
        column-gutter: 10pt,
        row-gutter: 6pt,
        plot-py(
          res-b.y-grid,
          res-b.py,
          res-b.mean-y,
          8.2,
          py-gauss: res-b.py-gauss,
          show-gauss: true,
        ),
        plot-gx(g-nonlinear, mu-x, [Function $g(x)$], show-gmu-legend: true),
        [],
        plot-px(mu-x, sig-x, [Mean $mu$]),
      )),
    ),
    caption: [
      *(a)* Linear and *(b)* nonlinear transformation of a Gaussian random variable. The lower right plots show the density of the original random variable, $X$ (teal). This random variable is passed through the function displayed in the upper right graphs (blue; the transformation of the mean is indicated by the dotted line). The density of the resulting random variable $Y$ is plotted in the upper left graphs (orange), compared against its Gaussian approximation (purple) in *(b)*.
    ],
  )
}